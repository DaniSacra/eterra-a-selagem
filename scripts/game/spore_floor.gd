class_name SporeFloor
extends RefCounted
## Chapter II, A-5 (Pulso do Bosque): the clouds of spores of a garden in a fight. Runs its SporeHazard and lays each cloud on
## the floor as the Esporinho's burst (Ground.add_cloud: a circle that warms up and bursts on whoever stands in it, the paladin
## and the enemies alike). Rooms makes one when the room's HazardDef is of kind SPORES and steps it during the fight.

var hazard: SporeHazard
var game: Game
var zones: Array[Ground.Zone] = []
## Life it took from the enemies and enemies it felled.
var enemy_damage := 0.0
var kills := 0
## [second of the room, clouds lit] per burst group, for the RESULT.
var patterns: Array = []
var _t := 0.0


## awake: whether the descent reached HazardDef.from_progress (asleep: it never draws a cloud).
func _init(g: Game, def: HazardDef, rng: RandomNumberGenerator, awake := true) -> void:
	game = g
	hazard = SporeHazard.new(def, rng)
	if not awake:
		hazard.left = INF
	g.ground.hazard_landed.connect(_on_landed)


func step(dt: float) -> void:
	_t += dt
	match hazard.step(dt, game.player.pos):
		ArenaHazard.Event.ARMED:
			zones.clear()
			patterns.append([snappedf(_t, 0.01), hazard.lit.size()])
			for at in hazard.lit:
				zones.append(game.ground.add_cloud(at, hazard.def.cloud_radius, hazard.def.warn, hazard.def.hero_damage,
					hazard.def.enemy_damage))
			Audio.play(CombatSounds.EVENTS[&"rune_arm"])
		ArenaHazard.Event.FIRED:
			Audio.play(CombatSounds.EVENTS[&"rune_fire"])
		ArenaHazard.Event.ENDED:
			zones.clear()


func busy() -> int:
	return 1 if hazard.phase == ArenaHazard.Phase.ARM or hazard.phase == ArenaHazard.Phase.FIRE else 0


func tally() -> Dictionary:
	return {"patterns": patterns}


## The fight is over (or the room left): what is warming up goes away without bursting.
func stop() -> void:
	for z in zones:
		Ground.end_zone(z)
	zones.clear()
	if game.ground.hazard_landed.is_connected(_on_landed):
		game.ground.hazard_landed.disconnect(_on_landed)


func _on_landed(z: Ground.Zone) -> void:
	if not zones.has(z):
		return
	var h := game.horde
	h.dealing = z.source
	for e in h.list.duplicate():
		if not e.alive or e.def.behavior == EnemyDef.Behavior.BOSS or not Ground.inside(z, e.pos):
			continue
		var before: float = e.hp
		if h.damage(e, z.hazard, Vector2.ZERO, 0.0, RuneFloor.NUMBER_COLOR):
			kills += 1
		enemy_damage += maxf(0.0, before - e.hp)
	h.dealing = &""
