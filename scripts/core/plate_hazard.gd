class_name PlateHazard
extends RefCounted
## The slabs that strike when stepped on (RP-06, H-2, the "laje de pisar"; docs/design/rooms_progression.md): fixed
## rectangles of the floor (HazardDef.plates), always marked. Anyone standing on one (the paladin or an enemy: the
## steam trap of the Hades II arms for both) arms it: it lights from the edge to the middle for HazardDef.warn seconds,
## strikes whoever stands on it on the first frame of fire seconds (the paladin hero_damage, each enemy enemy_damage:
## PlateFloor, through the Ground's warning) and rests rearm seconds before it may arm again. Rules: nothing arms in the
## first start_delay seconds, nor before the descent reaches from_progress (awake false: the slabs lie at rest, drawn,
## and never strike), nor a slab over a door's mouth. RP-10: a slab may be a strip along a root (HazardDef.strips) and
## may wait for someone to linger on it (HazardDef.dwell). Pure: PlateFloor lays it on the floor.

enum Phase { IDLE, ARM, FIRE, REST }
## At most this many slabs warm up or strike at once (docs/design/rooms_progression.md, Sworn 5; combat_cadence.md 9.2
## R9: at most two of a room's own warnings on the whole floor, the "never three"): one more stepped on waits until one
## is done. The room's other hazards count against it (step's `others`).
const MOST_AT_ONCE := 2

var def: HazardDef
## Whether the slabs may arm at all in this room (the descent reached HazardDef.from_progress).
var awake := true
## Each slab's phase and the seconds left in it (IDLE: none), and whether it may ever arm (0: over a door's mouth).
var phase := PackedInt32Array()
var left := PackedFloat32Array()
var live := PackedByteArray()
## Who armed each slab last: true the paladin, false an enemy.
var by_hero := PackedByteArray()
## Seconds of calm left at the start of the fight.
var calm := 0.0
## How many slabs struck, and how many times the paladin and the enemies armed one.
var fired := 0
var armed_by_hero := 0
var armed_by_enemy := 0
## Seconds of the ember of the last strike of each slab (ArenaHazard.EMBER down to 0).
var ember := PackedFloat32Array()
## Seconds the paladin and seconds an enemy has stood on each idle slab (it arms at HazardDef.dwell and
## HazardDef.dwell_of_enemy()).
var stay := PackedFloat32Array()
var foe_stay := PackedFloat32Array()
## Each slab as a band of the floor (Ground's LINE): from the middle of one end, along dir, length long, width across.
## A rectangle runs west to east; a strip (RP-10, a root) from its a to its b.
var from := PackedVector2Array()
var dirs := PackedVector2Array()
var lengths := PackedFloat32Array()
var widths := PackedFloat32Array()


## doors: the mouths (and zones) of the room's doors; a slab touching one never arms.
func _init(hazard: HazardDef, doors: Array[Rect2], is_awake := true) -> void:
	def = hazard
	awake = is_awake
	calm = def.start_delay
	for r in def.plates:
		from.append(Vector2(r.position.x, r.get_center().y))
		dirs.append(Vector2.RIGHT)
		lengths.append(r.size.x)
		widths.append(r.size.y)
	for s in def.strips:
		var a := Vector2(s.x, s.y)
		var b := Vector2(s.z, s.w)
		from.append(a)
		dirs.append((b - a).normalized())
		lengths.append(a.distance_to(b))
		widths.append(def.strip_width)
	var n := from.size()
	phase.resize(n)
	left.resize(n)
	live.resize(n)
	by_hero.resize(n)
	ember.resize(n)
	stay.resize(n)
	foe_stay.resize(n)
	for i in n:
		var ok := 1
		for d in doors:
			if d.grow(0.5).intersects(bounds(i)):
				ok = 0
		live[i] = ok


func count() -> int:
	return from.size()


## Whether p is on slab i.
func on(i: int, p: Vector2) -> bool:
	var d := p - from[i]
	var along := d.dot(dirs[i])
	return along >= 0.0 and along <= lengths[i] and absf(d.cross(dirs[i])) <= widths[i] * 0.5


## The rectangle round slab i (the slab itself when it is one).
func bounds(i: int) -> Rect2:
	var side := Vector2(-dirs[i].y, dirs[i].x) * widths[i] * 0.5
	var end := from[i] + dirs[i] * lengths[i]
	var r := Rect2(from[i] + side, Vector2.ZERO)
	for q in [from[i] - side, end + side, end - side]:
		r = r.expand(q)
	return r


## The slab under p (-1: none).
func plate_at(p: Vector2) -> int:
	for i in count():
		if on(i, p):
			return i
	return -1


## One step. hero: where the paladin stands (Vector2.INF: none); bodies: where the enemies stand. Returns the slabs
## that began to arm in this step (their warnings go on the floor now) and the ones that struck, as
## {"armed": PackedInt32Array, "fired": PackedInt32Array}. others: the room's other hazards' warnings on the floor now
## (R9: they and these slabs together never pass MOST_AT_ONCE).
func step(dt: float, hero: Vector2, bodies: PackedVector2Array, others := 0) -> Dictionary:
	var armed := PackedInt32Array()
	var struck := PackedInt32Array()
	calm = maxf(0.0, calm - dt)
	var going := busy()
	for i in count():
		ember[i] = maxf(0.0, ember[i] - dt)
		match phase[i]:
			Phase.IDLE:
				if not awake or calm > 0.0 or live[i] == 0:
					stay[i] = 0.0
					foe_stay[i] = 0.0
					continue
				var hero_on := on(i, hero)
				var enemy_on := false
				for b in bodies:
					if on(i, b):
						enemy_on = true
						break
				stay[i] = stay[i] + dt if hero_on else 0.0
				foe_stay[i] = foe_stay[i] + dt if enemy_on else 0.0
				hero_on = hero_on and stay[i] >= def.dwell
				enemy_on = enemy_on and foe_stay[i] >= def.dwell_of_enemy()
				if (hero_on or enemy_on) and going + others < MOST_AT_ONCE:
					stay[i] = 0.0
					foe_stay[i] = 0.0
					phase[i] = Phase.ARM
					left[i] = def.warn
					by_hero[i] = 1 if hero_on else 0
					if hero_on:
						armed_by_hero += 1
					else:
						armed_by_enemy += 1
					armed.append(i)
					going += 1
			Phase.ARM:
				left[i] -= dt
				if left[i] <= 0.0:
					phase[i] = Phase.FIRE
					left[i] += def.fire
					fired += 1
					struck.append(i)
			Phase.FIRE:
				left[i] -= dt
				if left[i] <= 0.0:
					phase[i] = Phase.REST
					left[i] += def.rearm
					ember[i] = ArenaHazard.EMBER
			Phase.REST:
				left[i] -= dt
				if left[i] <= 0.0:
					phase[i] = Phase.IDLE
					left[i] = 0.0
	return {"armed": armed, "fired": struck}


## What slab i shows now: x arming 0 to 1 over the warning (the light reaching from its edge to its middle), y the
## strike 1 falling to 0, z the ember of its last strike 1 falling to 0.
func state(i: int) -> Vector3:
	var arm := 0.0
	var strike := 0.0
	if phase[i] == Phase.ARM:
		arm = clampf(1.0 - left[i] / maxf(def.warn, 0.001), 0.0, 1.0)
	elif phase[i] == Phase.FIRE:
		strike = clampf(left[i] / maxf(def.fire, 0.001), 0.0, 1.0)
	return Vector3(arm, strike, ember[i] / ArenaHazard.EMBER)


## How many slabs warm up or strike now (never more than MOST_AT_ONCE).
func busy() -> int:
	var n := 0
	for p in phase:
		if p == Phase.ARM or p == Phase.FIRE:
			n += 1
	return n


## The fight is over: nothing warms up any more (the slabs stay drawn at rest).
func stop() -> void:
	for i in count():
		phase[i] = Phase.IDLE
		stay[i] = 0.0
		foe_stay[i] = 0.0
		left[i] = 0.0
	awake = false
