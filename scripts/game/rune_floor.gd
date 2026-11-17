class_name RuneFloor
extends RefCounted
## The floor of the Câmara das Runas Instáveis in a fight (E5; docs/art/e5_spec.md 3.4): runs its ArenaHazard and
## lays each pattern on the floor as warnings (Ground.add_hazard, one per run of tiles along a row). As a warning
## lands it strikes the paladin (as any warning, Ground) and every enemy standing in it (hazard_landed, here: the
## common ones; guardians and Morvath never fight there). Counts what it dealt for the room's numbers. Rooms makes one
## when the room's layout has a HazardDef and steps it during the fight.
## Drawing: when the arena's look is the RunesLook the floor itself shows the tiles (paint: each tile's arming, strike
## and ember every frame, the sweep's chevrons, one apply) and the warnings are not drawn (nothing twice); on any other
## look (a lab, a test) the warnings are the amber of GroundLook.Style.HAZARD.

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
## The arena's own rune floor (null: another look; the warnings draw then) and whether it shows any tile now.
var look: RunesLook
var _shown := false


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
	look = g.arena.look as RunesLook
	if look != null and not fits(def, look):
		push_warning("RuneFloor: the look's tiles are not the hazard's grid; drawing the warnings instead")
		look = null


func step(dt: float) -> void:
	match hazard.step(dt, game.player.pos, game.horde.count()):
		ArenaHazard.Event.ARMED:
			zones.clear()
			for r in hazard.rects():
				zones.append(game.ground.add_hazard(r, hazard.def.warn, hazard.def.hero_damage, hazard.def.enemy_damage,
					look == null))
		ArenaHazard.Event.ENDED:
			# (its warnings landed with the strike, in the Ground's step of the same frame or the next)
			zones.clear()
	if look != null:
		_shown = paint(hazard, look, _shown)


## True when the look's tiles are the hazard's (same origin, size and count): the floor drawn is the floor that strikes.
static func fits(def: HazardDef, l: RunesLook) -> bool:
	return l.grid() == Vector2i(def.cols, def.rows) and is_equal_approx(RunesLook.TILE, def.tile) \
		and l.tile_rect(Vector2i.ZERO).position.is_equal_approx(def.origin)


## Writes every tile's state of the hazard on the look and shows it (one apply). shown: whether the look showed a lit
## tile last time; at rest with nothing left to show it is not touched again. Returns whether it shows one now.
static func paint(h: ArenaHazard, l: RunesLook, shown: bool) -> bool:
	var any := false
	for i in h.lit.size():
		var s := h.state(i)
		if s.x > 0.0 or s.y > 0.0 or s.z > 0.0:
			any = true
			break
	if not any and not shown:
		return false
	var cols := h.def.cols
	for i in h.lit.size():
		var s := h.state(i)
		l.set_tile(Vector2i(i % cols, i / cols), s.x, s.y, s.z)
	l.set_chevrons(h.chevron if h.phase == ArenaHazard.Phase.ARM else Vector2.ZERO)
	l.apply()
	return any


## The fight is over (or the room left): what is warming up goes away without striking.
func stop() -> void:
	for z in zones:
		Ground.end_zone(z)
	zones.clear()
	if look != null and is_instance_valid(look):
		look.clear_tiles()
		look.set_chevrons(Vector2.ZERO)
		look.apply()
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
