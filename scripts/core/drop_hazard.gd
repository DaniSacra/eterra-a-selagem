class_name DropHazard
extends RefCounted
## The stones that fall from a torn vault (RP-20; docs/design/rooms_progression.md, combat_cadence.md 9.3): squares of
## HazardDef.drop_size on HazardDef.drop_zones, at most drop_count at once, one every drop_every seconds after
## start_delay. A share drop_aim of them is aimed at the paladin when he stands in a zone (the square round his feet,
## kept inside the zone), the others fall anywhere in a zone (chosen by its area). Each warns warn seconds and strikes
## on the first frame of fire seconds. A square is laid only whole on the floor, off the doors' mouths, off every other
## stone and off the room's other warnings (`blocked`), and only while the room has a warning to spare (`free`): else
## it waits for the next frame (combat_cadence.md 9.2 R9: never three of the room's own warnings at once, never two
## over the same point). Asleep before HazardDef.from_progress. Pure: DropFloor lays it on the floor.

enum Phase { ARM, FIRE }
## Candidates tried for a square before it waits for the next frame.
const TRIES := 16

var def: HazardDef
var awake := true
var calm := 0.0
## Seconds until the next stone may come.
var wait := 0.0
## The stones on the floor now: each {"rect": Rect2, "phase": Phase, "left": float}.
var stones: Array[Dictionary] = []
## How many stones fell, and how many were aimed at him.
var fired := 0
var aimed := 0
var _floor: FloorShape
var _doors: Array[Rect2] = []
var _rng := RandomNumberGenerator.new()


## floor: the room's floor (a square is laid only whole on it); doors: the mouths of its doors; seed: the room's own
## (the same fight drops the same way, never touching the run's dice).
func _init(hazard: HazardDef, floor: FloorShape, doors: Array[Rect2], seed: int, is_awake := true) -> void:
	def = hazard
	_floor = floor
	_doors = doors
	_rng.seed = seed
	awake = is_awake
	calm = def.start_delay
	wait = 0.0


## One step. hero: where he stands (Vector2.INF: none); blocked: the room's other warnings now; free: how many more of
## the room's warnings may go on the floor. Returns {"armed": Array[Rect2], "fired": Array[Rect2]}.
func step(dt: float, hero: Vector2, blocked: Array[Rect2], free: int) -> Dictionary:
	var armed: Array[Rect2] = []
	var struck: Array[Rect2] = []
	var k := stones.size() - 1
	while k >= 0:
		var s := stones[k]
		s.left -= dt
		if s.left <= 0.0:
			if s.phase == Phase.ARM:
				s.phase = Phase.FIRE
				s.left += def.fire
				fired += 1
				struck.append(s.rect)
			else:
				stones.remove_at(k)
		k -= 1
	if not awake:
		return {"armed": armed, "fired": struck}
	calm = maxf(0.0, calm - dt)
	wait = maxf(0.0, wait - dt)
	if calm > 0.0 or wait > 0.0 or warming() >= def.drop_count or free <= 0:
		return {"armed": armed, "fired": struck}
	var r := _pick(hero, blocked)
	if r.size != Vector2.ZERO:
		stones.append({"rect": r, "phase": Phase.ARM, "left": def.warn})
		armed.append(r)
		wait = def.drop_every
	return {"armed": armed, "fired": struck}


## How many stones warm up now (the ones striking are no warning any more).
func warming() -> int:
	var n := 0
	for s in stones:
		if s.phase == Phase.ARM:
			n += 1
	return n


## A square whole on the floor, off the doors, other stones and `blocked` (Rect2() when none of TRIES fits).
func _pick(hero: Vector2, blocked: Array[Rect2]) -> Rect2:
	var side := def.drop_size
	var home := -1
	for i in def.drop_zones.size():
		if def.drop_zones[i].has_point(hero):
			home = i
	var aim := home >= 0 and _rng.randf() < def.drop_aim
	for t in TRIES:
		var zi := home if aim and t < TRIES / 2 else _zone()
		var z := def.drop_zones[zi]
		var c: Vector2
		if aim and t < TRIES / 2:
			c = hero + Vector2(_rng.randf_range(-0.4, 0.4), _rng.randf_range(-0.4, 0.4)) * side
		else:
			c = Vector2(_rng.randf_range(z.position.x, z.end.x), _rng.randf_range(z.position.y, z.end.y))
		c.x = clampf(c.x, z.position.x + side * 0.5, z.end.x - side * 0.5)
		c.y = clampf(c.y, z.position.y + side * 0.5, z.end.y - side * 0.5)
		var r := Rect2(c - Vector2.ONE * side * 0.5, Vector2.ONE * side)
		if fits(r, blocked):
			if aim and t < TRIES / 2:
				aimed += 1
			return r
	return Rect2()


## A zone by its area.
func _zone() -> int:
	var total := 0.0
	for z in def.drop_zones:
		total += z.get_area()
	var roll := _rng.randf() * total
	for i in def.drop_zones.size():
		roll -= def.drop_zones[i].get_area()
		if roll <= 0.0:
			return i
	return def.drop_zones.size() - 1


## Whether square r may take a stone now: whole on the floor, off the doors, the other stones and `blocked`.
func fits(r: Rect2, blocked: Array[Rect2]) -> bool:
	for p in [r.position, r.end, Vector2(r.position.x, r.end.y), Vector2(r.end.x, r.position.y), r.get_center()]:
		if _floor != null and not _floor.covers(p):
			return false
	for d in _doors:
		if d.grow(0.5).intersects(r):
			return false
	for s in stones:
		if (s.rect as Rect2).grow(0.3).intersects(r):
			return false
	for b in blocked:
		if b.grow(0.3).intersects(r):
			return false
	return true


## The fight is over: nothing more falls (what is falling stops unstruck: DropFloor ends its warnings).
func stop() -> void:
	stones.clear()
	awake = false
