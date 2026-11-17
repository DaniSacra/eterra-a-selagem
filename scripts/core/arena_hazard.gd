class_name ArenaHazard
extends RefCounted
## The floor that strikes on its own (E5, the Câmara das Runas Instáveis; docs/art/e5_spec.md 3.2 to 3.4): square
## tiles in bands and blocks, never circles (D-29), that warm up for HazardDef.warn seconds, strike for fire seconds
## (everyone standing on them is hurt on the first frame: the paladin and the enemies, E5-D3) and rest for rest
## seconds before the next pattern. Rules of reading, always kept: at most max_share of the tiles lit (dense_share for
## the dense patterns, only with few enemies standing), and every lit tile has an unlit floor tile beside it (from
## anywhere on the floor, unlit floor within one tile, 3 m). Nothing lights in the first start_delay seconds, on the
## tiles of a door, on the quiet stone or on a tile cut by the floor's edge. Pure: RuneFloor lays it on the floor.

enum Phase { CALM, ARM, FIRE, REST }
## What a step did: nothing, a pattern began to warm up (lay its warnings), it struck, it ended (rest).
enum Event { NONE, ARMED, FIRED, ENDED }
const PATTERNS: Array[StringName] = [&"sweep", &"comb", &"cut", &"checker", &"frame", &"islands"]
## The dense ones: more of the floor at once, only with few enemies standing.
const DENSE: Array[StringName] = [&"comb", &"checker"]

var def: HazardDef
var phase := Phase.CALM
## Seconds left in the phase.
var left := 0.0
## The pattern lit now (&"": none), and its tiles (1: lit; index row * cols + col).
var pattern: StringName = &""
var lit := PackedByteArray()
## Tiles that may light at all (1), and tiles that are floor (1: an unlit one there is a safe step).
var live := PackedByteArray()
var floor_tile := PackedByteArray()
## How many patterns struck.
var fired := 0
var _rng: RandomNumberGenerator
## The sweep's row and way, the comb's and the checker's parity, the frame's ring.
var _sweep := 0
var _sweep_way := 1
var _parity := 0
var _ring := 0


## floor: the arena's floor; doors: the mouths (and zones) of its doors, whose tiles never light.
func _init(hazard: HazardDef, floor: FloorShape, doors: Array[Rect2], rng: RandomNumberGenerator) -> void:
	def = hazard
	_rng = rng
	var n := def.cols * def.rows
	live.resize(n)
	floor_tile.resize(n)
	lit.resize(n)
	for r in def.rows:
		for c in def.cols:
			var box := tile_rect(c, r)
			var i := r * def.cols + c
			var whole := true
			var some := false
			for p in _probes(box):
				if floor.covers(p):
					some = true
				else:
					whole = false
			floor_tile[i] = 1 if some else 0
			var ok := whole
			for q in def.quiet:
				if q.grow(-0.01).intersects(box):
					ok = false
			for d in doors:
				if d.grow(0.5).intersects(box):
					ok = false
			live[i] = 1 if ok else 0
	phase = Phase.CALM
	left = def.start_delay


## The floor of tile (c, r).
func tile_rect(c: int, r: int) -> Rect2:
	return Rect2(def.origin + Vector2(c, r) * def.tile, Vector2.ONE * def.tile)


## The tile under p (-1, -1 off the grid).
func tile_at(p: Vector2) -> Vector2i:
	var q := (p - def.origin) / def.tile
	var t := Vector2i(floori(q.x), floori(q.y))
	if t.x < 0 or t.y < 0 or t.x >= def.cols or t.y >= def.rows:
		return Vector2i(-1, -1)
	return t


## True when p stands on a lit tile.
func is_lit(p: Vector2) -> bool:
	var t := tile_at(p)
	return t.x >= 0 and lit[t.y * def.cols + t.x] == 1


## The share of the tiles that may light which are lit now.
func share() -> float:
	var total := 0
	var on := 0
	for i in live.size():
		total += live[i]
		on += lit[i]
	return float(on) / maxf(1.0, total)


## One step: hero, where the paladin stands; standing, how many enemies stand.
func step(dt: float, hero: Vector2, standing: int) -> Event:
	left -= dt
	if left > 0.0:
		return Event.NONE
	match phase:
		Phase.CALM, Phase.REST:
			_draw(hero, standing)
			phase = Phase.ARM
			left = def.warn
			return Event.ARMED
		Phase.ARM:
			phase = Phase.FIRE
			left = def.fire
			fired += 1
			return Event.FIRED
		Phase.FIRE:
			phase = Phase.REST
			left = def.rest
			for i in lit.size():
				lit[i] = 0
			pattern = &""
			return Event.ENDED
	return Event.NONE


## The lit tiles as rectangles, one per run of lit tiles along a row (they never overlap).
func rects() -> Array[Rect2]:
	var out: Array[Rect2] = []
	for r in def.rows:
		var c := 0
		while c < def.cols:
			if lit[r * def.cols + c] == 0:
				c += 1
				continue
			var from := c
			while c < def.cols and lit[r * def.cols + c] == 1:
				c += 1
			out.append(Rect2(tile_rect(from, r).position, Vector2(c - from, 1) * def.tile))
	return out


## True when every lit tile has an unlit floor tile beside it (up, down, left or right).
func safe_everywhere() -> bool:
	for r in def.rows:
		for c in def.cols:
			if lit[r * def.cols + c] == 1 and not _has_safe_side(c, r):
				return false
	return true


# ---------- the patterns ----------

## Draws the next pattern (among those the room allows now) and lights it within the rules.
func _draw(hero: Vector2, standing: int) -> void:
	var allowed: Array[StringName] = []
	for p in def.patterns:
		if DENSE.has(p) and standing > def.dense_standing:
			continue
		allowed.append(p)
	if allowed.is_empty():
		allowed.append(&"sweep")
	pattern = allowed[_rng.randi() % allowed.size()]
	for i in lit.size():
		lit[i] = 0
	match pattern:
		&"sweep":
			_rows([_sweep, _sweep + 4])
			_sweep += _sweep_way
			if _sweep + 4 >= def.rows or _sweep < 0:
				_sweep_way = -_sweep_way
				_sweep = clampi(_sweep + _sweep_way * 2, 0, maxi(0, def.rows - 5))
		&"comb":
			var every: Array[int] = []
			for r in range(_parity, def.rows, 2):
				every.append(r)
			_rows(every)
			_parity = 1 - _parity
		&"cut":
			_cut(hero)
		&"checker":
			for r in def.rows:
				for c in def.cols:
					if (r + c) % 2 == _parity:
						lit[r * def.cols + c] = 1
			_parity = 1 - _parity
		&"frame":
			for r in def.rows:
				for c in def.cols:
					if mini(mini(c, r), mini(def.cols - 1 - c, def.rows - 1 - r)) == _ring:
						lit[r * def.cols + c] = 1
			_ring = 1 - _ring
		&"islands":
			_islands()
	_fit(def.dense_share if DENSE.has(pattern) else def.max_share)


func _rows(list: Array) -> void:
	for r: int in list:
		if r < 0 or r >= def.rows:
			continue
		for c in def.cols:
			lit[r * def.cols + c] = 1


## A row and a column crossing on a tile beside the paladin's (a corner of it), never on his own tile.
func _cut(hero: Vector2) -> void:
	var t := tile_at(hero)
	if t.x < 0:
		t = Vector2i(def.cols / 2, def.rows / 2)
	var col := t.x + (1 if _rng.randf() < 0.5 else -1)
	var row := t.y + (1 if _rng.randf() < 0.5 else -1)
	col = col if col >= 0 and col < def.cols else t.x - (col - t.x)
	row = row if row >= 0 and row < def.rows else t.y - (row - t.y)
	for c in def.cols:
		lit[row * def.cols + c] = 1
	for r in def.rows:
		lit[r * def.cols + col] = 1


## Up to HazardDef.islands blocks of 2 x 2 tiles, never touching each other.
func _islands() -> void:
	var placed: Array[Vector2i] = []
	for attempt in 40:
		if placed.size() >= def.islands:
			break
		var at := Vector2i(_rng.randi_range(0, def.cols - 2), _rng.randi_range(0, def.rows - 2))
		var clear := true
		for p in placed:
			if absi(p.x - at.x) <= 2 and absi(p.y - at.y) <= 2:
				clear = false
		if not clear:
			continue
		placed.append(at)
		for dr in 2:
			for dc in 2:
				lit[(at.y + dr) * def.cols + at.x + dc] = 1


## Keeps the rules: only tiles that may light, never more than `most` of them, every lit one beside an unlit floor
## tile (tiles taken off at random until the share fits, then any without a safe side, until none is left).
func _fit(most: float) -> void:
	var on: Array[int] = []
	var total := 0
	for i in lit.size():
		total += live[i]
		if lit[i] == 1 and live[i] == 0:
			lit[i] = 0
		if lit[i] == 1:
			on.append(i)
	var cap := floori(most * total + 0.0001)
	while on.size() > cap:
		var k := _rng.randi() % on.size()
		lit[on[k]] = 0
		on.remove_at(k)
	var changed := true
	while changed:
		changed = false
		for r in def.rows:
			for c in def.cols:
				if lit[r * def.cols + c] == 1 and not _has_safe_side(c, r):
					lit[r * def.cols + c] = 0
					changed = true


func _has_safe_side(c: int, r: int) -> bool:
	for d: Vector2i in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
		var n := Vector2i(c, r) + d
		if n.x < 0 or n.y < 0 or n.x >= def.cols or n.y >= def.rows:
			continue
		var i := n.y * def.cols + n.x
		if floor_tile[i] == 1 and lit[i] == 0:
			return true
	return false


## Points of a tile that must be floor for it to light: its middle and points 0.1 m inside its corners.
static func _probes(box: Rect2) -> PackedVector2Array:
	var g := box.grow(-0.1)
	return PackedVector2Array([box.get_center(), g.position, Vector2(g.end.x, g.position.y), g.end, Vector2(g.position.x, g.end.y)])
