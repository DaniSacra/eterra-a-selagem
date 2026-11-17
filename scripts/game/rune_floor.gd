class_name RuneFloor
extends RefCounted
## The floor of the Câmara das Runas Instáveis in a fight (E5; docs/art/e5_spec.md 3.4): runs its ArenaHazard and
## lays each pattern on the floor as amber warnings (Ground.add_hazard, one per run of tiles along a row). As a warning
## lands it strikes the paladin (as any warning, Ground) and every enemy standing in it (hazard_landed, here: the
## common ones; guardians and Morvath never fight there). Counts what it dealt for the room's numbers. Rooms makes one
## when the room's layout has a HazardDef and steps it during the fight.

## The colour of the numbers of what it deals to the enemies (the warnings' amber).
const NUMBER_COLOR := Color(1.0, 0.7, 0.35)

var hazard: ArenaHazard
var game: Game
## The warnings on the floor now.
var zones: Array[Ground.Zone] = []
## Life it took from the enemies, enemies it felled, and how many times it struck.
var enemy_damage := 0.0
var kills := 0
var _found: Array[Enemy] = []


func _init(g: Game, def: HazardDef, rng: RandomNumberGenerator) -> void:
	game = g
	var doors: Array[Rect2] = []
	for z in g.arena.exit_zones:
		doors.append(z)
	if g.arena.layout != null:
		for e in g.arena.layout.exits:
			doors.append(e.mouth)
	hazard = ArenaHazard.new(def, g.arena.shape(), doors, rng)
	g.ground.hazard_landed.connect(_on_landed)


func step(dt: float) -> void:
	match hazard.step(dt, game.player.pos, game.horde.count()):
		ArenaHazard.Event.ARMED:
			zones.clear()
			for r in hazard.rects():
				zones.append(game.ground.add_hazard(r, hazard.def.warn, hazard.def.hero_damage, hazard.def.enemy_damage))
		ArenaHazard.Event.ENDED:
			# (its warnings landed with the strike, in the Ground's step of the same frame or the next)
			zones.clear()


## The fight is over (or the room left): what is warming up goes away without striking.
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
	h.dealing = Ground.HAZARD_SOURCE
	for e in h.list.duplicate():
		if not e.alive or e.def.behavior == EnemyDef.Behavior.BOSS or not Ground.inside(z, e.pos):
			continue
		var before: float = e.hp
		if h.damage(e, z.hazard, Vector2.ZERO, 0.0, NUMBER_COLOR):
			kills += 1
		enemy_damage += maxf(0.0, before - e.hp)
	h.dealing = &""
