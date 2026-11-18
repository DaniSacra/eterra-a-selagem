extends GutTest
## E5's looks wired to the rules (docs/art/e5_spec.md): the stage's plans use the pieces the looks draw, the wall fire
## bowls stand off the floor, the rune floor drives the RunesLook's tiles (and the warnings are not drawn twice), the
## trial's slab is the look's cracked slab, the trial settles and the altar kindles after their choice, and every
## door that opens breathes the air of the room behind it.

const STAGE := "res://data/stages/catacombs.tres"
## The pieces each E5 room must have in its plan (any variant), as the looks draw them.
const PIECES := {
	&"sanctuary": [&"column", &"column_base", &"drums", &"bench_broken", &"sarcophagus", &"brazier"],
	&"bridge": [&"pylon", &"column", &"sarcophagus"],
	&"runes": [&"rune_pillar", &"quiet", &"brazier"],
}
## A wall fire bowl's middle at least this far out of the walkable floor (its bowl and fire are 0.7 m round).
const BOWL_OUT := 0.9

var stage: StageDef


func before_all() -> void:
	stage = load(STAGE)


func _layout(id: StringName) -> RoomLayout:
	for l in stage.layouts:
		if l.id == id:
			return l
	return null


func _game() -> Game:
	var game: Game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	return game


func test_the_stage_plans_use_the_looks_pieces() -> void:
	for id: StringName in PIECES:
		var l := _layout(id)
		assert_not_null(l, "%s is in the stage" % id)
		var seen := {}
		for v in l.variant_count():
			for o in l.variant(v).obstacles:
				seen[o.piece] = true
		for p: StringName in PIECES[id]:
			assert_true(seen.has(p), "%s has a %s" % [id, p])
		assert_false(seen.has(&"drum") or seen.has(&"bench"), "%s: no piece the looks do not know" % id)
	var trial := stage.trial_layout
	assert_eq(trial.look, &"trial")
	assert_eq(trial.obstacles.map(func(o: ArenaObstacle) -> StringName: return o.piece), [&"trial_block"])
	var altar := stage.altar_layout
	assert_eq(altar.obstacles.map(func(o: ArenaObstacle) -> StringName: return o.piece), [&"altar", &"bench", &"bench_broken"],
		"a whole bench and a broken one")


func test_the_quiet_stone_and_the_fallen_column_stop_what_they_should() -> void:
	var b := _layout(&"runes").variant(1)
	var quiet: Array = b.obstacles.filter(func(o: ArenaObstacle) -> bool: return o.piece == &"quiet")
	assert_eq(quiet.size(), 1, "B has the quiet stone")
	assert_false(quiet[0].blocks_move, "it stops no body")
	assert_false(quiet[0].blocks_shots, "nor a shot")
	var stump: Array = _layout(&"sanctuary").obstacles.filter(func(o: ArenaObstacle) -> bool: return o.piece == &"column_base")
	assert_eq(stump.size(), 1)
	assert_true(stump[0].blocks_move, "the fallen column's base stops bodies")
	assert_false(stump[0].blocks_shots, "a shot flies over it")
	# nothing of the A plan lies on the B's quiet stone of the runes
	for o in _layout(&"runes").obstacles:
		assert_ne(o.piece, &"quiet", "A has no quiet stone")


func test_wall_fire_bowls_stand_off_the_floor() -> void:
	var all: Array[RoomLayout] = [stage.trial_layout, stage.altar_layout]
	for l in stage.layouts:
		all.append(l)
	var n := 0
	for l in all:
		for v in l.variant_count():
			var lv := l.variant(v)
			for o in lv.obstacles:
				if o.piece != &"brazier" or not [&"sanctuary", &"bridge", &"runes"].has(l.id):
					continue
				n += 1
				assert_false(o.blocks_move, "%s: a bowl blocks nothing" % l.id)
				assert_lte(lv.floor.edge_distance(o.center), -BOWL_OUT + 0.001, "%s %d: the bowl at %s is %.2f m out" %
					[l.id, v, o.center, -lv.floor.edge_distance(o.center)])
	assert_gt(n, 0, "the rooms have their bowls")


func test_the_runes_look_is_the_hazards_grid() -> void:
	var l := _layout(&"runes")
	for v in l.variant_count():
		var a := Arena.new()
		add_child_autofree(a)
		a.build(l.variant(v), 3, 1406)
		var look := a.look as RunesLook
		assert_not_null(look, "the runes draw with their own look")
		assert_true(RuneFloor.fits(l.variant(v).hazard, look), "variant %d: 10 x 8 tiles of 3 m from (-15, -12)" % v)
		assert_eq(look.grid(), Vector2i(10, 8))
		if v == 1:
			assert_true(look.is_quiet(look.tile_at(Vector2(0.5, 0.5))), "B's quiet stone is quiet on the floor too")


## The hazard's tiles on the look: arming, the strike, the ember, the sweep's chevrons, then the floor at rest.
func test_the_rune_floor_paints_the_tiles() -> void:
	var l := _layout(&"runes")
	var a := Arena.new()
	add_child_autofree(a)
	a.build(l, 3, 1406)
	var look := a.look as RunesLook
	var def: HazardDef = l.hazard.duplicate()
	def.patterns = [&"sweep"]
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	var doors: Array[Rect2] = []
	for e in l.exits:
		doors.append(e.mouth)
	var h := ArenaHazard.new(def, l.floor, doors, rng)
	assert_false(RuneFloor.paint(h, look, false), "nothing to show in the calm")
	assert_eq(h.step(def.start_delay + 0.01, Vector2.ZERO, 4), ArenaHazard.Event.ARMED)
	h.step(def.warn * 0.5, Vector2.ZERO, 4)
	assert_true(RuneFloor.paint(h, look, false))
	var first := -1
	for i in h.lit.size():
		if h.lit[i] == 1:
			first = i
			break
	assert_gt(first, -1, "a band is lit")
	var t := Vector2i(first % def.cols, first / def.cols)
	var px := look.state_image().get_pixelv(t)
	assert_almost_eq(px.r, 0.5, 0.02, "the lit tile is half armed")
	assert_gt(look.heat(), 0.4, "the pillars' grooves warm with it")
	assert_ne(look.floor_mat.get_shader_parameter(&"chevron_dir"), Vector2.ZERO, "a sweep shows where it goes")
	var dark := -1
	for i in h.lit.size():
		if h.lit[i] == 0 and h.live[i] == 1:
			dark = i
			break
	assert_eq(look.state_image().get_pixel(dark % def.cols, dark / def.cols).r, 0.0, "an unlit tile stays at rest")
	assert_eq(h.step(def.warn * 0.5, Vector2.ZERO, 4), ArenaHazard.Event.FIRED)
	RuneFloor.paint(h, look, true)
	assert_gt(look.state_image().get_pixelv(t).g, 0.9, "the strike")
	assert_eq(look.floor_mat.get_shader_parameter(&"chevron_dir"), Vector2.ZERO, "no chevrons once it strikes")
	assert_eq(h.step(def.fire, Vector2.ZERO, 4), ArenaHazard.Event.ENDED)
	h.step(ArenaHazard.EMBER * 0.5, Vector2.ZERO, 4)
	assert_true(RuneFloor.paint(h, look, true))
	px = look.state_image().get_pixelv(t)
	assert_almost_eq(px.b, 0.5, 0.05, "its ember fading")
	assert_eq(px.g, 0.0, "the strike is over")
	h.step(ArenaHazard.EMBER, Vector2.ZERO, 4)
	assert_false(RuneFloor.paint(h, look, true), "the floor back at rest")
	assert_eq(look.state_image().get_pixelv(t).b, 0.0)


## In a real fight in the runes the look shows the bands and the warnings strike without drawing them; on another look
## the amber warnings are drawn as before.
func test_the_fight_in_the_runes_draws_once() -> void:
	var game := _game()
	var r := RunMap.Room.new(RunMap.Kind.COMBAT, RunMap.Reward.GOLD, 6, stage.layouts.find(_layout(&"runes")), 0)
	game.rooms._enter(r)
	var rf := game.rooms.runes
	assert_not_null(rf)
	assert_not_null(rf.look, "the floor drives the look")
	for i in 220:
		game.rooms.step(1.0 / 60.0)
		game.ground.step(1.0 / 60.0)
	var bands := game.ground.zones.filter(func(z: Ground.Zone) -> bool: return z.hazard > 0.0)
	assert_gt(bands.size(), 0, "bands warming")
	for z: Ground.Zone in bands:
		assert_false(z.node.visible, "the floor shows them, the warning does not")
	assert_gt(rf.look.heat(), 0.0, "the look's tiles are warming")
	game.rooms._room_cleared()
	assert_eq(rf.look.heat(), 0.0, "the floor goes back to rest with the fight")
	var drawn := game.ground.add_hazard(Rect2(-3, -3, 6, 3), 1.0, 4.0, 35.0)
	assert_true(drawn.node.visible, "a hazard with no rune floor of its own is drawn in amber")


func test_the_slab_is_the_trials_cracked_slab() -> void:
	var game := _game()
	var rooms := game.rooms
	var here := RunMap.Room.new(RunMap.Kind.COMBAT, RunMap.Reward.GOLD, 3, 1, 0)
	here.trial = true  # the graph put the Provação's "?" here (DV-1)
	rooms._enter(here)
	game.horde.clear_crowd()
	rooms._open_doors()
	assert_not_null(rooms.slab)
	var node := rooms._slab_node
	assert_not_null(node.find_child("TrialSlab", true, false), "TrialLook.entry_slab")
	assert_eq(node.find_children("*", "OmniLight3D", true, false).size(), 0, "no lamp of its own: the crack glows")
	var sign: Node3D = node.find_children("*", "Node3D", true, false).filter(func(n: Node) -> bool: return n is DoorSign).front()
	var at: Vector2 = rooms.slab.at
	assert_almost_eq(Vector2(sign.global_position.x, sign.global_position.z), at, Vector2.ONE * 0.01, "its sign over it")


func test_the_trial_settles_and_the_altar_kindles() -> void:
	var game := _game()
	var rooms := game.rooms
	rooms.map.depth = 3
	rooms._enter(RunMap.Room.new(RunMap.Kind.TRIAL, RunMap.Reward.NONE, 3, -1))
	var trial := game.arena.look as TrialLook
	assert_not_null(trial)
	assert_almost_eq(trial.vein_level(), 1.0, 0.01, "the veins burn until the choice")
	rooms.take_trial(0)
	await wait_seconds(TrialLook.SETTLE_TIME + 0.2)
	assert_almost_eq(trial.vein_level(), TrialLook.SETTLED, 0.02, "and settle after it")
	rooms._enter(RunMap.Room.new(RunMap.Kind.ALTAR, RunMap.Reward.NONE, 4, -1))
	var altar := game.arena.look as AltarLook
	assert_not_null(altar)
	assert_false(altar.lit())
	rooms.gold = 100
	assert_true(rooms.take_altar(Altar.Option.CANDLES))
	assert_true(altar.lit(), "its candles burn after the trade")


func test_every_open_door_breathes_the_next_rooms_air() -> void:
	var game := _game()
	var rooms := game.rooms
	rooms.map.depth = 2
	rooms._enter(RunMap.Room.new(RunMap.Kind.COMBAT, RunMap.Reward.GOLD, 2, stage.layouts.find(_layout(&"bridge")), 0))
	game.horde.clear_crowd()
	rooms.stage.trial_chance = 0.0
	rooms._open_doors()
	assert_gt(rooms.next_rooms.size(), 0)
	for i in rooms.next_rooms.size():
		var card := game.arena.look.get_node_or_null("Breath%d" % i)
		assert_not_null(card, "door %d breathes" % i)
		var want: Color = ArenaRoom.BREATH.get(rooms.door_look(i), ArenaRoom.BREATH[&"hall"])
		assert_true(ArenaRoom.BREATH.has(rooms.door_look(i)) or rooms.door_look(i) == &"",
			"door %d leads to a look with an air (%s)" % [i, rooms.door_look(i)])
		assert_not_null(want)
	var boss := RunMap.Room.new(RunMap.Kind.BOSS, RunMap.Reward.NONE, 11, -1)
	rooms.next_rooms = [boss]
	assert_eq(rooms.door_look(0), &"chamber", "Morvath's door breathes the chamber's air")
