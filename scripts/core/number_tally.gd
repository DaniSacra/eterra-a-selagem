class_name NumberTally
extends RefCounted
## Which damage numbers are on screen (pure; Fx draws them, one label per entry). Hits that follow each other on the
## same target join one number that keeps counting up (the Hades II way), so a pack struck by a combo shows one
## number per enemy, not a pile of them (cycle 7 review: about 16 in one group of `19`). At most CROWD numbers
## stand within CROWD_RADIUS of each other and at most MAX_SHOWN on the whole screen: past that, the smallest
## give way to bigger ones. The numbers of big blows (finishers, the held moves) are never hidden for a smaller one
## nor by the crowd limit; only a screen already full of them lets the smallest go for a bigger one.
## A swing through a pack (cycle 8 review, P2): past GROUP_FROM plain numbers in one frame, the plain ones of that
## frame join one total (a group entry, at the middle of the hits it sums) that keeps counting while the swing goes
## on (GROUP_JOIN). Big numbers are never summed. No number stands within HERO_CLEAR pixels of the paladin's head
## (clear_of, applied where Fx places the labels).

## Seconds a number shows.
const LIFE := 0.75
## A hit on the same target within this many seconds of the last one joins its number (a whole combo of three,
## the finisher wind-up included, counts up in one number that turns emerald on the finisher).
const MERGE_TIME := 0.6
const CROWD := 6
const CROWD_RADIUS := 3.0
const MAX_SHOWN := 12
## Plain numbers in one frame before the rest of that frame's join one total.
const GROUP_FROM := 6
## A total keeps taking the next frames' overflow for this many seconds (one swing that sweeps over a few frames).
const GROUP_JOIN := 0.15
## Font size Fx draws a total with (pixels at 720 lines): a little over a plain number, under a big one.
const GROUP_SIZE := 20
## Pixels (at 720 lines) a number keeps from the paladin's head on screen.
const HERO_CLEAR := 60.0


class Entry:
	## Who took it (0: nobody to join with, as the paladin's own wounds or a word).
	var key := 0
	## The number shown (below 0: a word, not a number).
	var amount := -1.0
	var color := Color.WHITE
	var big := false
	var pos := Vector3.ZERO
	var life := 0.0
	var shown := false
	## A total of one swing's plain hits (GROUP_FROM).
	var group := false


var entries: Array[Entry] = []
## Whether the last add() joined a number that was already showing.
var merged := false
## The frame being counted, how many plain hits it had, the entries it made and the total they joined (-1: none).
var _frame := -1
var _frame_hits := 0
var _frame_new: Array[int] = []
var _group := -1


func _init(pool: int) -> void:
	for i in pool:
		entries.append(Entry.new())


## A hit of `amount` on `key` at `at`: the index of the entry that shows it, or -1 when it is not shown. frame: the
## frame it lands in (Engine.get_process_frames), so one swing's many plain hits join a total; -1 never sums.
func add(key: int, at: Vector3, amount: float, color: Color, big: bool, frame: int = -1) -> int:
	merged = false
	if frame >= 0 and not big:
		if frame != _frame:
			_frame = frame
			_frame_hits = 0
			_frame_new.clear()
		_frame_hits += 1
		if _frame_hits > GROUP_FROM:
			return _join_group(at, amount, color)
	var i := _add_one(key, at, amount, color, big)
	if i >= 0 and frame >= 0 and not big and not merged and not _frame_new.has(i):
		_frame_new.append(i)
	return i


func _add_one(key: int, at: Vector3, amount: float, color: Color, big: bool) -> int:
	if key != 0:
		for i in entries.size():
			var e := entries[i]
			if e.shown and e.key == key and e.amount >= 0.0 and e.life <= MERGE_TIME and (big or e.color == color):
				e.amount += amount
				if big and not e.big:
					e.big = true
					e.color = color
				e.life = 0.0
				e.pos = at
				merged = true
				return i
	if not _room(at, amount, big, true) or not _room(at, amount, big, false):
		return -1
	var i := _free()
	var e := entries[i]
	e.key = key
	e.amount = amount
	e.color = color
	e.big = big
	e.pos = at
	e.life = 0.0
	e.shown = true
	e.group = false
	return i


## One more plain hit past GROUP_FROM in a frame: it joins the swing's total. A new total takes in the numbers this
## frame already made (they go) and stands at the middle of them all; it always shows.
func _join_group(at: Vector3, amount: float, color: Color) -> int:
	if _group >= 0:
		var g := entries[_group]
		if g.shown and g.group and g.life <= GROUP_JOIN:
			g.amount += amount
			g.life = 0.0
			merged = true
			return _group
	var sum := amount
	var mid := at
	var n := 1
	for k in _frame_new:
		var e := entries[k]
		if e.shown and not e.big and not e.group:
			sum += e.amount
			mid += e.pos
			n += 1
			e.shown = false
	_frame_new.clear()
	var i := _free()
	var g := entries[i]
	g.key = 0
	g.amount = sum
	g.color = color
	g.big = false
	g.group = true
	g.pos = mid / float(n)
	g.life = 0.0
	g.shown = true
	_group = i
	return i


## Where a number's label centre goes so that it keeps `clear` pixels from the paladin's head on screen (pushed
## straight away from it; straight up when it sits right on it).
static func clear_of(at: Vector2, head: Vector2, clear: float) -> Vector2:
	var d := at - head
	if d.length() >= clear:
		return at
	var dir := d.normalized() if d.length() > 0.5 else Vector2.UP
	return head + dir * clear


## A floating word: always shown (it takes the oldest place when there is none free).
func add_word(at: Vector3, color: Color) -> int:
	merged = false
	var i := _free()
	var e := entries[i]
	e.key = 0
	e.amount = -1.0
	e.color = color
	e.big = false
	e.group = false
	e.pos = at
	e.life = 0.0
	e.shown = true
	return i


## Time passes: numbers past LIFE go.
func age(dt: float) -> void:
	for e in entries:
		if e.shown:
			e.life += dt
			if e.life > LIFE:
				e.shown = false


func hide(i: int) -> void:
	entries[i].shown = false


## How many numbers (not words) show.
func shown_count() -> int:
	var n := 0
	for e in entries:
		if e.shown and e.amount >= 0.0:
			n += 1
	return n


## Whether a new number fits near `at` (crowd) or on the screen (not crowd): when the place is full, the smallest
## number there that is not a big one gives way, if the new one is bigger (or big). Big numbers ignore the crowd; the
## screen holds MAX_SHOWN even of them: a full screen of big ones lets the smallest go for a bigger one.
func _room(at: Vector3, amount: float, big: bool, crowd: bool) -> bool:
	var count := 0
	var least: Entry = null
	var least_big: Entry = null
	for e in entries:
		if not e.shown or e.amount < 0.0:
			continue
		if crowd and Vector2(e.pos.x - at.x, e.pos.z - at.z).length() >= CROWD_RADIUS:
			continue
		count += 1
		if not e.big and (least == null or e.amount < least.amount):
			least = e
		if e.big and (least_big == null or e.amount < least_big.amount):
			least_big = e
	if count < (CROWD if crowd else MAX_SHOWN):
		return true
	if least != null and (big or amount > least.amount):
		least.shown = false
		return true
	if not big:
		return false
	if crowd:
		return true
	if least_big != null and amount > least_big.amount:
		least_big.shown = false
		return true
	return false


## A place for a new entry: a free one, else the oldest that is not a big number, else the oldest.
func _free() -> int:
	var best := -1
	for i in entries.size():
		var e := entries[i]
		if not e.shown:
			return i
		if best < 0 or (entries[best].big and not e.big) or (entries[best].big == e.big and e.life > entries[best].life):
			best = i
	return best
