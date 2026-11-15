class_name NumberTally
extends RefCounted
## Which damage numbers are on screen (pure; Fx draws them, one label per entry). Hits that follow each other on the
## same target join one number that keeps counting up (the Hades II way), so a pack struck by a combo shows one
## number per enemy, not a pile of them (cycle 7 review: about 16 in one group of `19`). At most CROWD numbers
## stand within CROWD_RADIUS of each other and at most MAX_SHOWN on the whole screen: past that, the smallest
## give way to bigger ones. The numbers of big blows (finishers, the held moves) are never hidden for a smaller one
## nor by the crowd limit; only a screen already full of them lets the smallest go for a bigger one.

## Seconds a number shows.
const LIFE := 0.75
## A hit on the same target within this many seconds of the last one joins its number (a whole combo of three,
## the finisher wind-up included, counts up in one number that turns emerald on the finisher).
const MERGE_TIME := 0.6
const CROWD := 6
const CROWD_RADIUS := 3.0
const MAX_SHOWN := 12


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


var entries: Array[Entry] = []
## Whether the last add() joined a number that was already showing.
var merged := false


func _init(pool: int) -> void:
	for i in pool:
		entries.append(Entry.new())


## A hit of `amount` on `key` at `at`: the index of the entry that shows it, or -1 when it is not shown.
func add(key: int, at: Vector3, amount: float, color: Color, big: bool) -> int:
	merged = false
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
	return i


## A floating word: always shown (it takes the oldest place when there is none free).
func add_word(at: Vector3, color: Color) -> int:
	merged = false
	var i := _free()
	var e := entries[i]
	e.key = 0
	e.amount = -1.0
	e.color = color
	e.big = false
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
