class_name SporeHazard
extends RefCounted
## Chapter II, A-5 (Pulso do Bosque): the clouds of spores of a mushroom garden. The same cycle as the runes' floor (ArenaHazard:
## CALM, ARM, FIRE, REST): a few of the room's mushrooms (HazardDef.spots) warm up a cloud for HazardDef.warn seconds, burst it
## (everyone in it, the paladin and the enemies, takes the hazard's damage on the first frame) and rest. A cloud never rises over
## the paladin: a mushroom he is within cloud_radius + SPARE of is not drawn. Pure: SporeFloor lays it on the floor.

const SPARE := 1.0

var def: HazardDef
var phase := ArenaHazard.Phase.CALM
var left := 0.0
## The spots of the clouds warming up or bursting now (empty at rest).
var lit := PackedVector2Array()
## How many bursts struck.
var fired := 0
var _rng: RandomNumberGenerator


func _init(hazard: HazardDef, rng: RandomNumberGenerator) -> void:
	def = hazard
	_rng = rng
	left = def.start_delay


## One step: hero, where the paladin stands.
func step(dt: float, hero: Vector2) -> ArenaHazard.Event:
	left -= dt
	if left > 0.0:
		return ArenaHazard.Event.NONE
	match phase:
		ArenaHazard.Phase.CALM, ArenaHazard.Phase.REST:
			lit = _draw(hero)
			if lit.is_empty():
				left = def.rest  # (the paladin stands by every one: try again after a rest)
				return ArenaHazard.Event.NONE
			phase = ArenaHazard.Phase.ARM
			left = def.warn
			return ArenaHazard.Event.ARMED
		ArenaHazard.Phase.ARM:
			phase = ArenaHazard.Phase.FIRE
			left = def.fire
			fired += 1
			return ArenaHazard.Event.FIRED
		ArenaHazard.Phase.FIRE:
			phase = ArenaHazard.Phase.REST
			left = def.rest
			lit = PackedVector2Array()
			return ArenaHazard.Event.ENDED
	return ArenaHazard.Event.NONE


## Up to def.clouds spots, at random, none within cloud_radius + SPARE of the paladin.
func _draw(hero: Vector2) -> PackedVector2Array:
	var pool: Array[Vector2] = []
	for s in def.spots:
		if s.distance_to(hero) > def.cloud_radius + SPARE:
			pool.append(s)
	var out := PackedVector2Array()
	while out.size() < def.clouds and not pool.is_empty():
		var k := _rng.randi() % pool.size()
		out.append(pool[k])
		pool.remove_at(k)
	return out
