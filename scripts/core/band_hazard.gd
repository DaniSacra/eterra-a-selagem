class_name BandHazard
extends RefCounted
## The bands that strike in turn (RP-11, H-3, the chain that sweeps the bridge; docs/design/rooms_progression.md):
## HazardDef.bands, one at a time and in order. After start_delay seconds of calm, every HazardDef.cycle seconds the
## next band warms up for warn seconds and strikes whoever stands in it on the first frame of fire seconds (the paladin
## hero_damage, each enemy enemy_damage, and the push of the band: BandFloor, through the Ground's warning). A band over
## a door's mouth is skipped. Pure: BandFloor lays it on the floor.

enum Phase { IDLE, ARM, FIRE }

var def: HazardDef
## The band warming up or striking now (-1: none), its phase and the seconds left in it.
var active := -1
var phase := Phase.IDLE
var left := 0.0
## Seconds until the next band warms up, and which one it is.
var wait := 0.0
var next := 0
## Whether each band may ever strike (0: over a door's mouth).
var live := PackedByteArray()
## How many bands struck.
var fired := 0
## Seconds from one band's warning to the next's at this depth (HazardDef.cycle_at).
var cycle := 6.0


## doors: the mouths (and zones) of the room's doors; a band touching one never strikes.
func _init(hazard: HazardDef, doors: Array[Rect2], progress := 0.0) -> void:
	def = hazard
	cycle = def.cycle_at(progress)
	wait = def.start_delay
	live.resize(def.bands.size())
	for i in def.bands.size():
		var ok := 1
		for d in doors:
			if d.grow(0.5).intersects(def.bands[i]):
				ok = 0
		live[i] = ok


func count() -> int:
	return def.bands.size()


## One step. Returns the band that began to warm up in this step and the one that struck (-1: none), as
## {"armed": int, "fired": int}.
## bodies: where the enemies stand (read only with HazardDef.band_busy).
func step(dt: float, bodies := PackedVector2Array()) -> Dictionary:
	var armed := -1
	var struck := -1
	match phase:
		Phase.ARM:
			left -= dt
			if left <= 0.0:
				phase = Phase.FIRE
				left += def.fire
				fired += 1
				struck = active
		Phase.FIRE:
			left -= dt
			if left <= 0.0:
				phase = Phase.IDLE
				active = -1
	wait -= dt
	if wait <= 0.0 and phase == Phase.IDLE:
		wait += cycle
		var i := _busiest(bodies) if def.band_busy else -1
		if i < 0:
			i = _next_live()
		else:
			next = (i + 1) % def.bands.size()
		if i >= 0:
			active = i
			phase = Phase.ARM
			left = def.warn
			armed = i
	return {"armed": armed, "fired": struck}


## The next band that may strike, in order (-1: none).
func _next_live() -> int:
	for k in def.bands.size():
		var i := (next + k) % def.bands.size()
		if live[i] == 1:
			next = (i + 1) % def.bands.size()
			return i
	return -1


## The live band with the most bodies in it (-1: none has any; ties: the first in turn from next).
func _busiest(bodies: PackedVector2Array) -> int:
	var best := -1
	var most := 0
	for k in def.bands.size():
		var i := (next + k) % def.bands.size()
		if live[i] == 0:
			continue
		var n := 0
		for p in bodies:
			if def.bands[i].has_point(p):
				n += 1
		if n > most:
			most = n
			best = i
	return best


## What band i shows now: x warming 0 to 1, y the strike 1 falling to 0.
func state(i: int) -> Vector2:
	if i != active:
		return Vector2.ZERO
	if phase == Phase.ARM:
		return Vector2(clampf(1.0 - left / maxf(def.warn, 0.001), 0.0, 1.0), 0.0)
	return Vector2(0.0, clampf(left / maxf(def.fire, 0.001), 0.0, 1.0))


## The fight is over: nothing warms up any more.
func stop() -> void:
	active = -1
	phase = Phase.IDLE
	wait = INF
