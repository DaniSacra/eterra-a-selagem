extends GutTest
## Cycle C12c "Qualidade da experiência" (docs/design/roadmap_plan.md, section H): no column of light past the glow
## threshold nor over the paladin or Morvath, door gems under it, Morvath walks in without a column (GP-01); the run's
## log that tells an unfair blow from one not dodged (GP-02); the limiter on the Master bus (GP-05); the camera's
## target never jumps (GP-06). GP-03 and GP-04 (the arenas) are in test_arenas.gd.

var game: Game


func _start(kind := RunMap.Kind.COMBAT) -> void:
	game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	if kind != RunMap.Kind.COMBAT:
		game.rooms.start_at(kind)


# ---------- GP-01: columns and gems ----------

func test_every_column_stops_under_the_glow_by_default() -> void:
	_start()
	game.fx.beam(Vector2(5, 5), Color(3, 3, 3))
	assert_lte(float(game.fx.last_beam.cap), 1.0, "the default cap is the glow threshold")
	assert_eq(Fx.BEAM_CORE_CAP, 1.0)
	assert_eq(Skills.BEAM_CORE_CAP, Fx.BEAM_CORE_CAP, "one cap for every column")


## Every place the game raises a column goes through Game.column (or the default cap); none asks for no cap.
func test_no_script_raises_a_column_past_the_cap() -> void:
	var callers := {}
	for path in _scripts("res://scripts"):
		var text := FileAccess.get_file_as_string(path)
		if path.ends_with("/fx.gd"):
			continue
		assert_false(text.contains("BEAM_NO_CAP"), "%s never asks for no cap" % path)
		if text.contains("fx.beam("):
			callers[path.get_file()] = true
	assert_eq(callers.keys().size(), 2, "only Game.column and the eruption's own column (default cap): %s" % [callers.keys()])
	assert_true(callers.has("game.gd") and callers.has("ground.gd"))


func test_the_reward_column_on_the_paladin_is_faint_and_far_from_him_full() -> void:
	_start()
	game.player.pos = game.arena.middle
	game.rooms._room_cleared()
	assert_false(game.fx.last_beam.is_empty(), "the reward's column rose")
	assert_lte(float(game.fx.last_beam.cap), 1.0)
	assert_almost_eq(float(game.fx.last_beam.intensity), Fx.BEAM_INTENSITY * Skills.BEAM_OVER_BOSS, 0.001, "on him it is faint")
	game.player.pos = game.arena.middle + Vector2(0, 6)
	game.column(game.arena.middle, Color.WHITE, 1.4, 12.0, 1.0)
	assert_almost_eq(float(game.fx.last_beam.intensity), Fx.BEAM_INTENSITY, 0.001, "behind him, far: its full light")
	assert_lte(float(game.fx.last_beam.cap), 1.0)


func test_a_column_in_front_of_him_on_the_screen_is_faint() -> void:
	_start()
	game.player.pos = Vector2.ZERO
	var toward_cam := Vector2(sin(deg_to_rad(game.cam_yaw())), cos(deg_to_rad(game.cam_yaw())))
	game.column(toward_cam * 6.0, Color.WHITE, 1.4, 14.0, 1.0)
	assert_almost_eq(float(game.fx.last_beam.intensity), Fx.BEAM_INTENSITY * Skills.BEAM_OVER_BOSS, 0.001)
	assert_true(Skills.covers(Vector2.ZERO, Player.RADIUS, toward_cam * 6.0, 1.4, 14.0, game.cam_yaw(), 30.0))
	assert_false(Skills.covers(Vector2.ZERO, Player.RADIUS, -toward_cam * 6.0, 1.4, 14.0, game.cam_yaw(), 30.0))


func test_the_gift_taken_the_fountain_and_a_falling_gift_stay_under_the_cap() -> void:
	_start()
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	game._take(game.boons.offers(rng, 1)[0])
	assert_lte(float(game.fx.last_beam.cap), 1.0, "a gift taken")
	assert_almost_eq(float(game.fx.last_beam.intensity), Fx.BEAM_INTENSITY * Skills.BEAM_OVER_BOSS, 0.001, "it stands on him")
	game.spawn_fountain(game.player.pos + Vector2(8, 0))
	assert_lte(float(game.fx.last_beam.cap), 1.0, "the fountain")
	game.skills._beam(game.player.pos + Vector2(9, 0), Color(3, 1, 0.3), 1.6, 16.0, 0.5)
	assert_lte(float(game.fx.last_beam.cap), 1.0, "a gift falling")
	var z := game.ground.add_warning(game.player.pos + Vector2(10, 0), 2.0, 0.1, 1.0)
	z.eruption = true
	game.fx.last_beam = {}
	for i in 12:
		game.ground.step(1.0 / 60.0)
	assert_lte(float(game.fx.last_beam.get("cap", 0.0)), 1.0, "an eruption")


func test_morvath_walks_in_without_a_column_over_him() -> void:
	_start()
	game.fx.last_beam = {}
	game.rooms.start_at(RunMap.Kind.BOSS)
	assert_not_null(game.boss, "he is there")
	if not game.fx.last_beam.is_empty():
		assert_gt(Vector2(game.fx.last_beam.at).distance_to(game.boss.e.pos), game.boss.e.def.radius + 3.0, "no column on him")


func test_door_gems_keep_their_hue_under_the_glow() -> void:
	for c: Color in [Color(1.0, 0.8, 0.3), Color(0.4, 0.9, 1.0), Color(0.9, 0.3, 0.3), Color(0.1, 0.1, 0.1)]:
		var g := Rooms.gem_color(c)
		assert_lte(maxf(g.r, maxf(g.g, g.b)), 1.0, "no channel past 1 for %s" % c)
		assert_almost_eq(g.h, c.h, 0.01, "the same hue")
	assert_eq(Rooms.gem_color(Color(0.1, 0.1, 0.1)), Color(0.22, 0.22, 0.22), "a dark one is still lifted")


func test_the_gems_drawn_in_a_room_stay_under_the_glow() -> void:
	_start()
	game.player.pos = game.arena.middle
	game.rooms._room_cleared()
	game.rooms._collect()
	await wait_process_frames(2)
	assert_false(game.rooms._gems.is_empty(), "doors with gems")
	# QW-106 (C18): a lit medallion of old gold, no unlit primitive and no light of its own; its glow under 1
	for gem in game.rooms._gems:
		if not is_instance_valid(gem):
			continue
		var marker := gem.get_parent()
		for n in marker.find_children("*", "", true, false):
			assert_false(n is OmniLight3D, "no light per reward")
			if n is MeshInstance3D:
				var mesh := (n as MeshInstance3D).mesh
				assert_false(mesh is BoxMesh or mesh is PrismMesh or mesh is SphereMesh, "no primitive gem")
				var mat := (n as MeshInstance3D).material_override
				if mat is ShaderMaterial and (mat as ShaderMaterial).shader == RewardGem.HALO_SHADER:
					assert_lte(float(mat.get_shader_parameter(&"peak")), 1.0, "the halo under the glow")


# ---------- GP-02: the run's log ----------

func test_a_room_counts_its_variant_gold_gifts_dodges_blows_and_shots() -> void:
	var t := RoomTally.new()
	t.enter(2, "crypt", 25.0, 10.0, false, 1, 40, 3)
	t.dodge()
	t.dodge()
	t.hurt("mage", 4.0)
	t.hurt("mage", 4.0)
	t.hurt("knight", 6.0)
	t.hurt("knight", 0.0)
	t.shot("mage", RoomTally.SHOT_FIRED)
	t.shot("mage", RoomTally.SHOT_FIRED)
	t.shot("mage", RoomTally.SHOT_HIT)
	t.shot("mage", RoomTally.SHOT_BLOCKED, "sarcophagus")
	t.shot("crossbow", RoomTally.SHOT_BLOCKED, "column")
	var r: Dictionary = t.rooms(30.0)[0]
	assert_eq(r.variant, 1)
	assert_eq(r.gold_in, 40)
	assert_eq(r.boons_in, 3)
	assert_eq(r.dodges, 2)
	assert_eq(r.hits, 3, "a blow of nothing lost is not one")
	assert_eq(r.hits_by, {"mage": 2, "knight": 1})
	assert_eq(r.hurt_by, {"mage": 8.0, "knight": 6.0})
	assert_eq(r.shots.mage, {"fired": 2, "hit": 1, "blocked": 1})
	assert_eq(r.shots.crossbow, {"fired": 0, "hit": 0, "blocked": 1})
	assert_eq(r.blocked_by, {"sarcophagus": 1, "column": 1})
	assert_eq(r.time, 20.0)


func test_the_run_keeps_each_blow_in_context_up_to_sixty() -> void:
	var t := RoomTally.new()
	t.enter(3, "rift", 30.0, 0.0)
	t.hurt_context("scythe", 12.34, 12.0, 0.8, true, false)
	t.hurt_context("mage", 13.0, 4.0, -1.0, false, true)
	assert_eq(t.hurt_ctx[0], {"by": "scythe", "t": 12.3, "room": 3, "dmg": 12.0, "warn_s": 0.8, "dash_ready": true, "offscreen": false})
	assert_eq(t.hurt_ctx[1].warn_s, -1.0, "no warning known")
	assert_true(t.hurt_ctx[1].offscreen)
	for i in 100:
		t.hurt_context("mage", 20.0 + i, 1.0, 1.0, true, false)
	assert_eq(t.hurt_ctx.size(), RoomTally.HURT_CTX_MAX, "at most 60")


func test_the_run_keeps_the_gifts_at_morvath_the_shop_and_the_fountain() -> void:
	var t := RoomTally.new()
	assert_eq(t.run_fields(), {"boons_at_boss": -1, "shop": {}, "route_shop": {}, "fountain_used": false, "hurt_ctx": [], "events": []})
	t.enter(4, "hall", 20.0, 0.0)
	t.fountain()
	t.enter(6, "hall", 30.0, 50.0)
	t.shop_entered(90)
	t.bought("heal", 40)
	t.bought("boon", 45)
	t.enter(7, "seal_chamber", 28.0, 70.0, true, 0, 5, 6)
	var f := t.run_fields()
	assert_eq(f.boons_at_boss, 6)
	assert_eq(t.hp_at_boss, 28.0)
	assert_eq(f.shop, {"gold": 90, "bought": ["heal", "boon"], "spent": 85})
	assert_true(f.fountain_used)


func test_the_log_says_who_played() -> void:
	assert_eq(RunLog.source(true), "bot")
	assert_eq(RunLog.source(false), "human")
	assert_gte(RunLog.VERSION, 2, "these fields since version 2 (version 3: test_run_log.gd)")
	for k in ["source", "boons_at_boss", "shop", "fountain_used", "hurt_ctx"]:
		assert_true(RunLog.FIELDS.has(k), "the entry has %s" % k)


## A real room: a mage's bolts are counted fired, hit and stopped on stone (by the piece), the blow in context.
func test_in_game_shots_and_blows_are_logged() -> void:
	_start(RunMap.Kind.FOUNTAIN)
	var heard: Array = []
	game.run_logged.connect(func(_o: String, e: Dictionary) -> void: heard.append(e))
	var p := game.player
	p.invuln = 0.0
	# a bolt into the paladin
	game.horde.acting = &"mage"
	var s := game.projectiles.fire(Projectiles.Kind.BOLT, p.pos + Vector2(3, 0), Vector2.LEFT, 10.0, 2.0)
	s.warned = 1.0
	game.horde.acting = &""
	for i in 30:
		game.projectiles.step(1.0 / 60.0)
		if not game.projectiles.shots.has(s):
			break
	# a bolt into a column of the hall
	var pillar := game.arena.cover[0]
	var from := pillar.center + Vector2(4, 0)
	game.horde.acting = &"mage"
	var b := game.projectiles.fire(Projectiles.Kind.BOLT, from, Vector2.LEFT, 10.0, 2.0)
	game.horde.acting = &""
	for i in 60:
		game.projectiles.step(1.0 / 60.0)
		if not game.projectiles.shots.has(b):
			break
	# a skeleton's swing, raised 0.5 s
	game.horde.last_by = &"skeleton"
	game.horde.last_warn = 0.5
	game.horde.last_offscreen = 1
	p.invuln = 0.0
	p.dodge_charges = 0
	game._on_hit_player(3.0, p.pos + Vector2.RIGHT, game.horde)
	var room: Dictionary = game.room_tally.rooms(game.time)[-1]
	assert_eq(int(room.shots.mage.fired), 2)
	assert_eq(int(room.shots.mage.hit), 1)
	assert_eq(int(room.shots.mage.blocked), 1)
	assert_eq(int(room.blocked_by.get(String(pillar.piece), 0)), 1, "named by the piece it died on")
	assert_eq(int(room.hits), 2)
	assert_eq(room.hits_by, {"mage": 1, "skeleton": 1})
	var ctx := game.room_tally.hurt_ctx
	assert_eq(ctx.size(), 2)
	assert_eq(ctx[0].by, "mage")
	assert_gt(float(ctx[0].warn_s), 1.0, "its aim and its flight")
	assert_true(ctx[0].dash_ready)
	assert_eq(ctx[1].by, "skeleton")
	assert_almost_eq(float(ctx[1].warn_s), 0.5, 0.001)
	assert_false(ctx[1].dash_ready)
	assert_true(ctx[1].offscreen)
	game.player.dodged.emit(Vector2.RIGHT)
	assert_eq(int(game.room_tally.rooms(game.time)[-1].dodges), 1)
	game.log_run("quit")
	assert_eq(heard.size(), 1)
	var e: Dictionary = heard[0]
	assert_eq(e.source, "human", "no robot here")
	for k in RunLog.FIELDS:
		assert_true(e.has(k), "the entry has %s" % k)
	assert_eq(e.hurt_ctx.size(), 2)
	for k in ["variant", "dodges", "hits", "hits_by", "shots", "blocked_by", "gold_in", "boons_in", "depth", "layout", "hp_in", "hurt_by", "time", "contact"]:
		assert_true(e.rooms[-1].has(k), "the room has %s" % k)


## A crescent of Morvath: its warning counts the lane he marked first.
func test_a_boss_crescent_counts_the_lane_marked_before_it() -> void:
	_start(RunMap.Kind.BOSS)
	var z := game.ground.add_line_warning(game.boss.e.pos, Vector2.DOWN, 6.0, 1.0, 0.7, 0.0)
	z.source = &"blades"
	for i in 50:
		game.ground.step(1.0 / 60.0)
	assert_almost_eq(game.ground.warned_for(&"blades"), 0.7, 0.001)
	game.projectiles.last_source = &"blades"
	game.projectiles.last_by = &""
	game.projectiles.last_warn = 0.3
	game.projectiles.last_offscreen = 0
	game.player.invuln = 0.0
	game._on_hit_player(3.0, game.player.pos, game.projectiles)
	var ctx: Dictionary = game.room_tally.hurt_ctx[-1]
	assert_eq(ctx.by, "blades")
	assert_almost_eq(float(ctx.warn_s), 1.0, 0.001, "the lane and the flight")
	assert_eq(int(game.room_tally.rooms(game.time)[-1].shots.morvath.hit), 1, "his own shot")


# ---------- GP-05: the limiter ----------

func test_the_master_bus_ends_in_a_limiter_at_minus_one_db() -> void:
	var limiter := Audio.limit_master()
	var bus := AudioServer.get_bus_index(&"Master")
	var found := 0
	for i in AudioServer.get_bus_effect_count(bus):
		if AudioServer.get_bus_effect(bus, i) is AudioEffectHardLimiter:
			found += 1
			assert_true(AudioServer.is_bus_effect_enabled(bus, i))
	assert_eq(found, 1, "one limiter, put there as Audio starts")
	assert_almost_eq(limiter.ceiling_db, Audio.LIMIT_DB, 0.001)
	assert_lte(Audio.LIMIT_DB, -1.0, "the ceiling stays at -1 dB or under (-1.5 since the music, E4-06)")
	assert_eq(Audio.limit_master(), limiter, "never twice")


# ---------- GP-06: the camera's target ----------

func test_the_camera_target_never_jumps_past_its_speed() -> void:
	var at := CamFrame.follow(Vector2.ZERO, Vector2(10, 0), 1.0 / 60.0)
	assert_almost_eq(at.x, CamFrame.MAX_SPEED / 60.0, 0.0001)
	assert_lt(CamFrame.MAX_SPEED / 60.0, 0.5, "under half a meter a frame at 60 FPS")
	assert_eq(CamFrame.follow(Vector2.ZERO, Vector2(0.1, 0), 1.0 / 60.0), Vector2(0.1, 0), "a small step is taken whole")


func test_the_jump_trace_keeps_the_largest_and_starts_over() -> void:
	var t := CamFrame.JumpTrace.new()
	t.add(Vector2.ZERO, {"t": 0.0})
	t.add(Vector2(0.2, 0), {"t": 0.1})
	t.add(Vector2(0.9, 0), {"t": 0.2})
	t.add(Vector2(1.0, 0), {"t": 0.3})
	assert_almost_eq(t.worst, 0.7, 0.0001)
	assert_eq(t.worst_at.t, 0.2)
	var r := t.cut()
	assert_eq(int(r.frames), 4)
	t.add(Vector2(50, 50), {"t": 1.0})
	assert_eq(t.worst, 0.0, "the first frame after a cut is no jump")


func test_a_new_room_frames_the_paladin_at_once() -> void:
	_start()
	game.player.pos = Vector2(5, 3)
	game.snap_camera()
	assert_eq(Vector2(game.cam.target.x, game.cam.target.z), Vector2(5, 3))
	assert_false(game.cam.at.is_finite(), "the next frame places it anew")


func test_in_game_walking_and_dashing_the_target_moves_under_half_a_meter_a_frame() -> void:
	_start()
	game._cam_trace = CamFrame.JumpTrace.new()
	game.snap_camera()
	for i in 90:
		game.player.step(1.0 / 60.0, Vector2.RIGHT, Vector2.ZERO)
		if i % 20 == 0:
			game.player.dodge_charges = game.player.dodge_max
			game.player._start_dodge(Vector2.RIGHT if i < 45 else Vector2.LEFT)
		game._follow(1.0 / 60.0, Vector3.ZERO)
	assert_lt(game._cam_trace.worst, 0.5)
	assert_gt(game._cam_trace.frames, 80)


static func _scripts(dir: String) -> Array[String]:
	var out: Array[String] = []
	for f in DirAccess.get_files_at(dir):
		if f.ends_with(".gd"):
			out.append(dir.path_join(f))
	for d in DirAccess.get_directories_at(dir):
		out.append_array(_scripts(dir.path_join(d)))
	return out


# ---------- QA-01 finding: a warning left on the floor after the room is won ----------

func test_winning_a_room_clears_the_warnings_on_the_floor() -> void:
	_start()
	game.ground.add_line_warning(game.player.pos + Vector2(-3, 0), Vector2.RIGHT, 6.0, 1.2, 0.8, 3.0)
	game.ground.add_warning(game.player.pos, 2.0, 0.8, 3.0)
	game.rooms._room_cleared()
	var left := 0
	for z in game.ground.zones:
		if z.kind == Ground.Kind.WARNING and z.power > 0.0:
			left += 1
	assert_eq(left, 0, "no warning left to hurt him after the room is won")
	var hp := game.player.hp
	for i in 90:
		game._step(1.0 / 60.0)
	assert_eq(game.player.hp, hp, "nothing on the floor hurts him")
