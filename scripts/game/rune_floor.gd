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
## RP-14: how much brighter the column a crystal will discharge along shows at rest from its 2nd charge (the ember's
## scale: combat_cadence.md 9.3, the charges read without seeing the crystal).
const HINT := 0.3

var hazard: ArenaHazard
var game: Game
## The warnings on the floor now.
var zones: Array[Ground.Zone] = []
## Life it took from the enemies, enemies it felled, and how many times it struck.
var enemy_damage := 0.0
var kills := 0
var _found: Array[Enemy] = []
## AT-RB2: the room's patterns as they armed, [second of the room, name, tiles lit] (at most PATTERNS_KEPT), for the
## RESULT (rooms[].hazard.patterns) and to name what a capture shows.
var patterns: Array = []
const PATTERNS_KEPT := 16
var _t := 0.0
## The arena's own rune floor (null: another look; the warnings draw then) and whether it shows any tile now.
var look: RunesLook
var _shown := false
## RP-14: the crystals the paladin charges (null: none in this room), a mark on the floor before each (placeholder
## until the environment artist's crystal), and what the discharges dealt to the enemies (inside enemy_damage).
var crystals: CrystalHazard
var crystal_marks: Array[MeshInstance3D] = []
var crystal_damage := 0.0
var crystal_kills := 0
## Where the hint of a crystal at its 2nd charge stands (the column, -1: none).
var _hinted := -1
## The column of the discharge on the floor now (-1: none).
var _col := -1


## crystal_awake: whether the descent reached HazardDef.crystal_from (else the crystals take no charge).
func _init(g: Game, def: HazardDef, rng: RandomNumberGenerator, crystal_awake := true) -> void:
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
	if not def.crystals.is_empty():
		crystals = CrystalHazard.new(def, crystal_awake)
		for c in def.crystals:
			# a slab of 1.6 x 0.8 m on the floor's edge before the crystal, lit as it charges (GroundLook.set_plate)
			var n := GroundLook.new_node()
			g.arena.add_child(n)
			GroundLook.plate(n, Rect2(c.x - 0.8, c.y + 0.6, 1.6, 0.8), PlateFloor.Y)
			crystal_marks.append(n)
		g.combat.reached.connect(_on_reached)


func step(dt: float) -> void:
	_t += dt
	hazard.bodies.clear()
	for e in game.horde.list:
		if e.alive and e.def.behavior != EnemyDef.Behavior.BOSS:
			hazard.bodies.append(e.pos)
	match hazard.step(dt, game.player.pos, game.horde.count()):
		ArenaHazard.Event.ARMED:
			zones.clear()
			if patterns.size() < PATTERNS_KEPT:
				var lit := 0
				for i in hazard.lit.size():
					lit += hazard.lit[i]
				patterns.append([snappedf(_t, 0.01), String(hazard.pattern), lit])
			for r in hazard.rects():
				zones.append(game.ground.add_hazard(r, hazard.def.warn, hazard.def.hero_damage, hazard.def.enemy_damage,
					look == null, hazard.def.rune_source))
			Audio.play(CombatSounds.EVENTS[&"rune_arm"])  # one per pattern, however many tiles it lights
		ArenaHazard.Event.FIRED:
			Audio.play(CombatSounds.EVENTS[&"crystal_fire" if hazard.pattern == &"discharge" else &"rune_fire"])
		ArenaHazard.Event.ENDED:
			# (its warnings landed with the strike, in the Ground's step of the same frame or the next)
			zones.clear()
	if look != null:
		_shown = paint(hazard, look, _shown)
	if crystals != null:
		for i in crystal_marks.size():
			if is_instance_valid(crystal_marks[i]):
				var on := hazard.discharging() and _col == crystals.col(i)
				GroundLook.set_plate(crystal_marks[i], Vector3(crystals.fill(i) * 0.5, 1.0 if on else 0.0, 0.0))
			# SW-G7: the room's crystal (its notches, the edge going amber when full), when the room has the piece
			var piece := look.hazard_piece(Ground.CRYSTAL_SOURCE, i) if look != null else null
			if piece != null and is_instance_valid(piece):
				var on2 := hazard.discharging() and _col == crystals.col(i)
				piece.set_charge(crystals.charge[i], on2 or crystals.charge[i] >= crystals.def.crystal_hits)
				piece.set_state(Vector3(0.0, 1.0 if on2 else 0.0, 0.0), not crystals.awake)


## RP-14: a blow of the paladin; a crystal it fills discharges along its column now (the runes' pattern warming up, if
## any, goes dark unstruck).
func _on_reached(shape: int, origin: Vector2, dir: Vector2, reach: float, width: float) -> void:
	var got := crystals.hit(shape, origin, dir, reach, width, hazard.discharging() or hazard.phase == ArenaHazard.Phase.CALM)
	for i: int in got.charged:
		Audio.play(CombatSounds.EVENTS[&"crystal_charge"])
		if crystals.charge[i] >= crystals.def.crystal_hits - 1:
			_hint(crystals.col(i))
	var full: int = got.full
	if full < 0:
		return
	var col := crystals.col(full)
	_hint(-1)
	if not hazard.discharging() and hazard.discharge(col):
		_col = col
		for z in zones:
			Ground.end_zone(z)
		zones.clear()
		for r in hazard.rects():
			zones.append(game.ground.add_hazard(r, hazard.def.warn, hazard.def.hero_damage, hazard.def.enemy_damage,
				look == null, hazard.def.crystal_source))
		Audio.play(CombatSounds.EVENTS[&"crystal_arm"])
		var at := crystals.def.crystals[full]
		game.fx.burst(&"dust", Vector3(at.x, 0.6, at.y))


## The column a crystal will discharge along shown a step brighter at rest (-1: none).
func _hint(col: int) -> void:
	if _hinted >= 0:
		hazard.hint_col(_hinted, 0.0)
	_hinted = col
	if col >= 0:
		hazard.hint_col(col, HINT)


## Whether a warning of this floor is on the floor now (Rooms: the room's warnings at once, R9).
func busy() -> int:
	return 1 if hazard.phase == ArenaHazard.Phase.ARM or hazard.phase == ArenaHazard.Phase.FIRE else 0


## The room's numbers (RoomTally.hazard): the crystals', when there are any.
func tally() -> Dictionary:
	if crystals == null:
		return {"patterns": patterns}
	return {"patterns": patterns, "crystal_charges": crystals.charged, "discharges": crystals.discharged,
		"crystal_damage": snappedf(crystal_damage, 0.1), "crystal_kills": crystal_kills}


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
	if crystals != null:
		crystals.awake = false
		if game.combat.reached.is_connected(_on_reached):
			game.combat.reached.disconnect(_on_reached)
		for n in crystal_marks:
			if is_instance_valid(n):
				GroundLook.set_plate(n, Vector3.ZERO)


func _on_landed(z: Ground.Zone) -> void:
	if not zones.has(z):
		return
	var h := game.horde
	h.dealing = z.source
	for e in h.list.duplicate():
		if not e.alive or e.def.behavior == EnemyDef.Behavior.BOSS or not Ground.inside(z, e.pos):
			continue
		var before: float = e.hp
		var felled := h.damage(e, z.hazard, Vector2.ZERO, 0.0, NUMBER_COLOR)
		if felled:
			kills += 1
		enemy_damage += maxf(0.0, before - e.hp)
		if z.source == hazard.def.crystal_source:
			crystal_damage += maxf(0.0, before - e.hp)
			crystal_kills += 1 if felled else 0
	h.dealing = &""
