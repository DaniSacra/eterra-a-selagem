class_name PlateHazard
extends RefCounted
## The slabs that strike when stepped on (RP-06, H-2, the "laje de pisar"; docs/design/rooms_progression.md): fixed
## rectangles of the floor (HazardDef.plates), always marked. Anyone standing on one (the paladin or an enemy: the
## steam trap of the Hades II arms for both) arms it: it lights from the edge to the middle for HazardDef.warn seconds,
## strikes whoever stands on it on the first frame of fire seconds (the paladin hero_damage, each enemy enemy_damage:
## PlateFloor, through the Ground's warning) and rests rearm seconds before it may arm again. Rules: nothing arms in the
## first start_delay seconds, nor before the descent reaches from_progress (awake false: the slabs lie at rest, drawn,
## and never strike), nor a slab over a door's mouth. Pure: PlateFloor lays it on the floor.

enum Phase { IDLE, ARM, FIRE, REST }
## At most this many slabs warm up or strike at once (docs/design/rooms_progression.md, Sworn 5: never more than three
## of a room's own warnings on the floor; the 222700 lesson): one more stepped on waits until one is done.
const MOST_AT_ONCE := 3

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


## doors: the mouths (and zones) of the room's doors; a slab touching one never arms.
func _init(hazard: HazardDef, doors: Array[Rect2], is_awake := true) -> void:
	def = hazard
	awake = is_awake
	calm = def.start_delay
	var n := def.plates.size()
	phase.resize(n)
	left.resize(n)
	live.resize(n)
	by_hero.resize(n)
	ember.resize(n)
	for i in n:
		var ok := 1
		for d in doors:
			if d.grow(0.5).intersects(def.plates[i]):
				ok = 0
		live[i] = ok


func count() -> int:
	return def.plates.size()


## The slab under p (-1: none).
func plate_at(p: Vector2) -> int:
	for i in def.plates.size():
		if def.plates[i].has_point(p):
			return i
	return -1


## One step. hero: where the paladin stands (Vector2.INF: none); bodies: where the enemies stand. Returns the slabs
## that began to arm in this step (their warnings go on the floor now) and the ones that struck, as
## {"armed": PackedInt32Array, "fired": PackedInt32Array}.
func step(dt: float, hero: Vector2, bodies: PackedVector2Array) -> Dictionary:
	var armed := PackedInt32Array()
	var struck := PackedInt32Array()
	calm = maxf(0.0, calm - dt)
	var going := busy()
	for i in def.plates.size():
		ember[i] = maxf(0.0, ember[i] - dt)
		match phase[i]:
			Phase.IDLE:
				if not awake or calm > 0.0 or live[i] == 0 or going >= MOST_AT_ONCE:
					continue
				var rect := def.plates[i]
				var hero_on := rect.has_point(hero)
				var enemy_on := false
				if not hero_on:
					for b in bodies:
						if rect.has_point(b):
							enemy_on = true
							break
				if hero_on or enemy_on:
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
	for i in def.plates.size():
		phase[i] = Phase.IDLE
		left[i] = 0.0
	awake = false
