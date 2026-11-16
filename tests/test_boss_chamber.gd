extends GutTest
## Morvath's round chamber in play (cycle C11, docs/design/boss_arena.md): the circle is the whole collision and
## nobody is ever held at its edge (walking slides along it, the dodge stops at it, a siege of his dead against it
## is broken by the dodge), the camera keeps to its point and shows the paladin, and in the fight his lanes end at
## the edge, his crescents come undone just past it, his dead rise wholly on the floor, he opens the curse and the
## storm from the middle, and his warnings carry his signature.

const STAGE := "res://data/stages/catacombs.tres"
const DT := 1.0 / 60.0
const EPS := 0.01

var stage: StageDef
var layout: RoomLayout
var game: Game


func before_all() -> void:
	stage = load(STAGE)
	layout = stage.boss_layout


# ---------- the data ----------

func test_morvath_fights_in_the_round_chamber_and_the_rooms_stay_the_hall() -> void:
	assert_true(layout.chamber, "the boss's layout is a chamber")
	assert_true(layout.floor != null and layout.floor.is_round(), "a round floor")
	assert_almost_eq(layout.floor.radius, 12.5, 0.001, "12.5 m to the balustrade (12 m for the paladin's middle)")
	assert_true(layout.floor.contains(layout.hero_spawn, Player.RADIUS), "the paladin walks in on the floor")
	assert_true(layout.floor.contains(layout.boss_spawn, 1.4), "Morvath stands on the floor")
	assert_lt(layout.boss_spawn.distance_to(layout.floor.center), 2.0, "on the seal")
	assert_almost_eq(layout.cam_reach, 3.0, 0.001)
	for l in stage.layouts:
		assert_false(l.chamber, "the common rooms are the hall")
	assert_false(stage.shop_layout.chamber)


func _chamber() -> Arena:
	var a := Arena.new()
	add_child_autofree(a)
	a.build(layout, 0, 1406)
	return a


func test_the_arena_is_the_circle_and_nothing_else() -> void:
	var a := _chamber()
	assert_true(a.round_floor())
	assert_eq(a.start, layout.hero_spawn)
	assert_eq(a.boss_spawn, layout.boss_spawn)
	assert_eq(a.door_pos, layout.floor.center, "the ending's energy goes to the middle of the seal")
	assert_true(a.pillars.is_empty() and a.boxes.is_empty() and a.walk.is_empty() and a.exits.is_empty(), "no other collision")
	for k in 72:
		var far := Vector2.from_angle(TAU * k / 72.0) * 30.0
		assert_almost_eq(a.resolve(far, Player.RADIUS).length(), 12.0, EPS, "the same 12 m every way (no corner)")
		assert_almost_eq(a.resolve(far, 1.4).length(), 11.1, EPS, "Morvath's middle up to 11.1 m")
	assert_true(a.inside(Vector2(0, 11.9), Player.RADIUS))
	assert_false(a.inside(Vector2(0, 12.1), Player.RADIUS))


func test_walking_into_the_edge_slides_along_it() -> void:
	var a := _chamber()
	var p := Vector2(0, 12.0)
	var speed := Feel.live().speed
	for i in 120:
		# pushing outward and a little sideways, as a player running along the balustrade
		var out := p.normalized()
		var way := (out + out.orthogonal() * 0.6).normalized()
		var q := a.resolve(p + way * speed * DT, Player.RADIUS)
		assert_lte(q.length(), 12.0 + 0.0001, "never past the edge")
		assert_gt(q.distance_to(p), speed * DT * 0.4, "never held by the edge (step %d)" % i)
		p = q
	# 2 s pushing at 30 degrees off the tangent: about 6.9 m along the edge, 0.57 rad of the circle
	assert_gt(absf(p.angle() - PI * 0.5), 0.5, "went a good way around")


# ---------- in the game ----------

func _empty_chamber() -> Player:
	game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	game.rooms.start_at(RunMap.Kind.BOSS)
	# no Morvath: the chamber alone
	game.boss = null
	for e in game.horde.list:
		e.alive = false
	game.horde.list.clear()
	game.player.invuln = 100.0
	return game.player


func _still(at: Vector2) -> Enemy:
	var e := game.horde.spawn(game.horde.def(&"skeleton"), at, false)
	e.stun_t = 1000.0
	return e


func _play(seconds: float, move: Vector2) -> void:
	for i in int(seconds / DT):
		game.player.step(DT, move, Vector2.ZERO)
		game.horde.target = game.player.pos
		game.horde.step(DT)


func test_the_dodge_stops_at_the_edge() -> void:
	var p := _empty_chamber()
	assert_true(game.arena.round_floor(), "the boss room is the chamber")
	for k in 8:
		var way := Vector2.from_angle(TAU * k / 8.0 + 0.1)
		p.place(way * 10.0)
		p.dodge_charges = p.dodge_max
		p._start_dodge(way)
		for i in int((Feel.live().dodge_time + 0.1) / DT):
			_play(DT, way)
			assert_lte(p.pos.length(), 12.0 + 0.0001, "the dodge never leaves the floor (way %d)" % k)
		assert_almost_eq(p.pos.length(), 12.0, 0.05, "it ends at the edge (way %d)" % k)


func test_a_siege_against_the_edge_never_holds_him() -> void:
	for k in 6:
		var p := _empty_chamber()
		var a := TAU * k / 6.0 + 0.3
		var out := Vector2.from_angle(a)
		var side := out.orthogonal()
		p.place(out * 12.0)
		# his dead shoulder to shoulder on the inner side, the balustrade behind him
		var ring: Array[Enemy] = []
		for j in 7:
			var t := lerpf(-PI * 0.55, PI * 0.55, j / 6.0)
			ring.append(_still(p.pos - out.rotated(t) * 1.6))
		game.horde.rehash()
		var start := p.pos
		# walking along the edge: the bodies at his sides hold him, the edge never does
		_play(0.6, side)
		for e in ring:
			assert_gte(p.pos.distance_to(e.pos), e.def.radius + Player.RADIUS - EPS, "never inside a body")
		assert_lte(p.pos.length(), 12.0 + 0.0001)
		# the dodge through them always gets him out, into the floor
		p.dodge_charges = p.dodge_max
		p._start_dodge(-out)
		_play(Feel.live().dodge_time + DT, -out)
		assert_lt(p.pos.length(), 12.0 - 2.0, "the dodge took him out of the siege (way %d)" % k)
		var free := p.pos
		_play(0.5, -out)
		assert_gt(p.pos.distance_to(free), 1.0, "and he walks on (way %d)" % k)
		assert_gt(p.pos.distance_to(start), 3.0)
		game.queue_free()
		await wait_process_frames(1)


func test_an_open_edge_lets_him_run_around_the_chamber() -> void:
	var p := _empty_chamber()
	p.place(Vector2(0, 12))
	# a few of his dead stand inside, none on the edge: running along it goes all the way round
	for j in 5:
		_still(Vector2.from_angle(TAU * j / 5.0) * 6.0)
	game.horde.rehash()
	var turned := 0.0
	var last := p.pos.angle()
	for i in int(12.0 / DT):
		var out := p.pos.normalized()
		_play(DT, (out.orthogonal() + out * 0.3).normalized())
		turned += absf(angle_difference(last, p.pos.angle()))
		last = p.pos.angle()
	# 75 m of edge at 6.75 m/s
	assert_gt(turned, TAU, "a whole turn around the chamber in 12 s")


# ---------- the camera ----------

func test_the_camera_keeps_to_its_point_and_shows_him_everywhere() -> void:
	var f := Feel.live()
	var target := layout.cam_target
	for aspect in [16.0 / 9.0, 16.0 / 10.0, 4.0 / 3.0, 21.0 / 9.0]:
		for zoom in [1.0, 1.0 + Game.OMEGA_ZOOM]:
			var fov: float = f.cam_fov / zoom
			for k in 72:
				var hero := layout.floor.center + Vector2.from_angle(TAU * k / 72.0) * (layout.floor.radius - Player.RADIUS)
				var at := CamFrame.hold(target, target, layout.cam_reach, hero, f.cam_distance, f.cam_pitch, f.cam_yaw, fov, aspect)
				assert_lte(at.distance_to(target), layout.cam_reach + 0.001, "never more than 3 m off its point")
				var s := CamFrame.screen_of(hero, CamFrame.HERO_HEIGHT, at, f.cam_distance, f.cam_pitch, f.cam_yaw, fov, aspect)
				for v in [s.x, s.y]:
					assert_between(v, CamFrame.SAFE - 0.005, 1.0 - CamFrame.SAFE + 0.005, "the paladin in the safe frame (aspect %.2f, zoom %.2f, %s)" % [aspect, zoom, hero])
	# in 16:9 the whole chamber fits with the camera on its point: it never needs to move
	var still := 0
	for k in 72:
		var hero := Vector2.from_angle(TAU * k / 72.0) * 12.0
		if CamFrame.hold(target, target, 3.0, hero, f.cam_distance, f.cam_pitch, f.cam_yaw, f.cam_fov, 16.0 / 9.0).distance_to(target) < 0.01:
			still += 1
	assert_eq(still, 72, "16:9: the camera stays on its point wherever he stands")


func test_the_game_camera_looks_at_the_chamber_point() -> void:
	_empty_chamber()
	game.player.place(Vector2(-8, 8))
	var f := Feel.live()
	var at := game.cam_look_at(Vector2(30, 30), f.cam_distance, f.cam_fov)
	assert_lte(at.distance_to(layout.cam_target), layout.cam_reach + 0.001, "the hall's margins do not apply: its point")


# ---------- the fight ----------

func _fight() -> Boss:
	game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	game.rooms.start_at(RunMap.Kind.BOSS)
	return game.boss


## Plays the fight with the paladin running around the chamber (out of reach, so it lasts), watching every step.
func _run(seconds: float, each: Callable) -> void:
	var t := 0.0
	var a := 0.0
	while t < seconds and game.boss != null:
		game.player.invuln = 10.0
		a += DT * 0.35
		game.player.place(Vector2.from_angle(a) * (6.0 + 5.5 * absf(sin(t * 0.4))))
		game._step(DT)
		each.call()
		t += DT


func _to_phase(boss: Boss, phase: int) -> void:
	boss.e.hp = boss.e.max_hp * (boss.def.thresholds[phase - 2] + 0.01)
	boss.phase = phase - 1
	boss._ritual_done = phase > boss.def.ritual_phase
	boss.e.hp_floor = boss.e.max_hp * boss.def.thresholds[phase - 2]
	game.horde.damage(boss.e, 99999.0, Vector2.DOWN, 0.0)
	game._step(DT)


func test_his_lanes_end_at_the_edge_and_his_crescents_come_undone_past_it() -> void:
	var boss := _fight()
	assert_almost_eq(boss.e.pos.distance_to(layout.boss_spawn), 0.0, 0.3, "he begins on the seal")
	var r := layout.floor.radius
	var seen := {"lanes": 0, "souls": 0, "signed": 0, "adds": 0}
	var risen := {}
	var check := func() -> void:
		assert_lte(boss.e.pos.length(), r - boss.e.def.radius + EPS, "his body on the floor")
		for z in game.ground.zones:
			if z.kind != Ground.Kind.WARNING or z.source == &"" or z.source == &"adds":
				continue
			if z.shape == Ground.Shape.LINE:
				seen.lanes += 1
				assert_lte((z.pos + z.dir * z.radius).length(), r + EPS, "%s: the lane ends at the edge" % z.source)
			if z.rune == Ground.Rune.NONE and not z.eruption and z.node != null:
				if float((z.node.material_override as ShaderMaterial).get_shader_parameter(&"signed")) > 0.5:
					seen.signed += 1
		for s in game.projectiles.shots:
			if s.kind == Projectiles.Kind.SOUL:
				seen.souls += 1
				assert_lte(s.pos.length(), r + boss.def.soul_overrun + boss.def.blade_speed * DT + EPS, "a crescent undone past the edge")
		for e in game.horde.list:
			if e != boss.e and e.alive and not risen.has(e):
				risen[e] = true
				seen.adds += 1
				assert_lte(e.pos.length(), r - Boss.RUNE_RADIUS + EPS, "his dead rise with their rune on the floor")
	_run(40.0, check)
	_to_phase(boss, 2)
	_run(25.0, check)
	_to_phase(boss, 4)
	_run(30.0, check)
	assert_gt(int(seen.lanes), 20, "his lanes were watched")
	assert_gt(int(seen.souls), 20, "his crescents were watched")
	assert_gt(int(seen.adds), 3, "his dead were watched")
	assert_eq(int(seen.signed) > 0, true, "his warnings carry his signature")


func test_he_opens_the_curse_and_the_storm_from_the_middle() -> void:
	var boss := _fight()
	_run(3.0, func() -> void: pass)
	boss.e.pos = Vector2(8, 3)
	for phase in [3, 4]:
		boss.e.pos = Vector2(-7, 5)
		_to_phase(boss, phase)
		var opener: StringName = boss.def.phase_openers[phase - 1]
		var where := [Vector2.INF]
		var c := func(n: StringName) -> void:
			if n == opener and where[0] == Vector2.INF:
				where[0] = boss.e.pos
		boss.moment.connect(c)
		_run(boss.def.roar_time + Boss.CENTER_TIME + 2.0, func() -> void: pass)
		boss.moment.disconnect(c)
		assert_ne(where[0], Vector2.INF, "phase %d opened on %s" % [phase, opener])
		assert_lt((where[0] as Vector2).distance_to(layout.floor.center), 1.5, "phase %d opened from the middle" % phase)


func test_the_dash_only_with_room_and_its_lane_cut() -> void:
	var boss := _fight()
	_run(3.0, func() -> void: pass)
	boss.e.pos = Vector2(0, 9.0)
	assert_lt(boss._dash_room(Vector2.DOWN), boss.def.dash_min_free, "toward the near edge: no room")
	assert_gte(boss._dash_room(Vector2.UP), boss.def.dash_min_free, "across the floor: room")
	assert_almost_eq(boss._dash_room(Vector2.UP), minf(boss.def.dash_length, 9.0 + layout.floor.radius - boss.e.def.radius), 0.01, "never past dash_length")
	boss.e.pos = Vector2.ZERO
	assert_almost_eq(boss._dash_room(Vector2.RIGHT), layout.floor.radius - boss.e.def.radius, 0.01, "from the seal: stops with his body at the edge")


func test_the_storm_lanes_show_their_order_of_leaving() -> void:
	var boss := _fight()
	_to_phase(boss, 4)
	var levels: Array = []
	var marks := {}
	var shown := [false]
	boss.moment.connect(func(n: StringName) -> void:
		if n == &"storm":
			shown[0] = true)
	var check := func() -> void:
		if boss._lanes.is_empty() or levels.size() > 0:
			return
		var live := 0
		for z in boss._lanes:
			if z != null and z.node != null:
				live += 1
		if live == boss.def.storm_count:
			for i in boss._storm_queue():
				var m := boss._lanes[i].node.material_override as ShaderMaterial
				levels.append(float(m.get_shader_parameter(&"order_level")))
				marks[int(m.get_shader_parameter(&"order_marks"))] = true
	_run(30.0, check)
	assert_true(shown[0], "the storm came")
	assert_eq(levels.size(), boss.def.storm_count)
	assert_eq(levels[0], 1.0, "the next to leave is the brightest")
	for i in range(1, levels.size()):
		assert_lt(levels[i], levels[i - 1], "each later one dimmer")
	assert_eq(marks.size(), boss.def.storm_count, "each its own count of marks (1 to 6)")
