extends GutTest
## The Chamber of the Seal (BossChamber, cycle C11): nothing stands on the walkable circle, the fight starts inside it,
## the seal's five states run their timeline with values the shader can take, and the chamber follows Morvath's cues.

var chamber: BossChamber


func before_all() -> void:
	chamber = BossChamber.new()
	add_child(chamber)
	chamber.build()


func after_all() -> void:
	chamber.free()


func test_footprints_stay_outside_the_floor() -> void:
	assert_gt(chamber.circles.size(), 20, "the perimeter's pieces are listed")
	for c in chamber.circles:
		assert_true(Vector2(c.x, c.y).length() - c.z >= BossChamber.FLOOR_RADIUS - 0.001,
			"piece at %s (r %.2f) clear of the floor" % [Vector2(c.x, c.y), c.z])


func test_nothing_stands_on_the_walkable_circle() -> void:
	# every vertex inside the floor's circle lies flat on the floor (the floor itself and nothing standing up)
	var inside := 0
	for n in chamber.find_children("*", "MeshInstance3D", true, false):
		var mi := n as MeshInstance3D
		if mi.mesh == null:
			continue
		var xf := mi.global_transform
		for s in mi.mesh.get_surface_count():
			var verts: PackedVector3Array = mi.mesh.surface_get_arrays(s)[Mesh.ARRAY_VERTEX]
			for v in verts:
				var p := xf * v
				if Vector2(p.x, p.z).length() < BossChamber.FLOOR_RADIUS - 0.01 and p.y > 0.02:
					inside += 1
	assert_eq(inside, 0, "no geometry stands above the walkable floor")


func test_spawns_and_camera_inside() -> void:
	var hero_r := BossChamber.FLOOR_RADIUS - BossChamber.WALK_RADIUS
	assert_true(chamber.on_floor(chamber.hero_spawn, hero_r), "hero starts on the floor")
	assert_true(chamber.on_floor(chamber.boss_spawn, 1.4), "Morvath (radius 1.4) starts on the floor")
	assert_lt(chamber.cam_target.length(), BossChamber.WALK_RADIUS)
	assert_almost_eq(chamber.walk_radius, BossChamber.FLOOR_RADIUS - hero_r, 0.001)
	assert_gt(chamber.hero_spawn.distance_to(chamber.boss_spawn), 8.0, "they start apart")


func test_seal_timing_matches_boss() -> void:
	assert_eq(SealLook.VICTORY_TIME, Boss.VICTORY_TIME)
	assert_eq(SealLook.VICTORY_STREAM, Boss.VICTORY_STREAM)
	assert_eq(SealLook.VICTORY_PORTAL, Boss.VICTORY_PORTAL)
	assert_eq(SealLook.VICTORY_RITUAL, Boss.VICTORY_RITUAL)
	assert_eq(SealLook.VICTORY_CALM, Boss.VICTORY_CALM)
	assert_eq(SealLook.VICTORY_SEAL, Boss.VICTORY_SEAL)
	assert_eq(SealLook.PORTAL_PULSE_HZ, Boss.PORTAL_PULSE_HZ)


func test_every_state_gives_shader_values() -> void:
	var shader: Shader = load("res://assets/shaders/chamber_floor.gdshader")
	var names := {}
	for u in shader.get_shader_uniform_list():
		names[StringName(u.name)] = true
	for s in SealLook.State.values():
		var look := SealLook.new()
		look.enter(s)
		for t in 40:
			look.step(0.1)
			var v := look.values()
			for k: StringName in v:
				var key := &"seal_turns" if k == &"turn" else (&"seal_violet_left" if k == &"violet" else StringName("seal_" + k))
				assert_true(names.has(key), "uniform %s exists" % key)
				var x: Variant = v[k]
				if x is float:
					assert_false(is_nan(x), "%s is a number" % k)
			assert_between(float(v[&"crack_core"]), 0.0, 1.0, "crack light within the glow cap")
			assert_between(float(v[&"flash"]), 0.0, 1.0)
			assert_between(float(v[&"gold_glow"]), 0.0, 1.0)


func test_states_by_name_and_timeline() -> void:
	for name in [&"normal", &"prep", &"ritual", &"final", &"victory"]:
		assert_true(SealLook.NAMES.has(name), "state %s by name" % name)
	var look := SealLook.new()
	look.enter(SealLook.State.BREAK)
	look.step(SealLook.BREAK_TIME + 0.1)
	assert_eq(look.state, SealLook.State.NORMAL, "the break settles back to rest")
	look.set_phase(3)
	look.step(5.0)
	assert_almost_eq(look.crack_grow, 3.0, 0.01, "the crack grows to the phase")
	look.enter(SealLook.State.FINAL)
	look.step(10.0)
	assert_gt(look.veins(), 0.0, "the veins spread in the last phase")


func test_cues_drive_the_seal() -> void:
	var c := chamber
	c.on_cue(&"phase_shift", Vector2(0, -3), Vector2.DOWN, 2.0, 1.6)
	assert_eq(c.seal.state, SealLook.State.PREP)
	c.on_cue(&"shield_up", Vector2.ZERO, Vector2.DOWN, 1.0, 1.0)
	assert_eq(c.seal.state, SealLook.State.RITUAL)
	c.on_cue(&"shield_break", Vector2.ZERO, Vector2.DOWN, 1.0, 1.0)
	assert_eq(c.seal.state, SealLook.State.BREAK)
	c.on_cue(&"phase_shift", Vector2.ZERO, Vector2.DOWN, 4.0, 1.6)
	assert_eq(c.seal.state, SealLook.State.FINAL)
	c.on_cue(&"victory_blow", Vector2.ZERO, Vector2.DOWN, 1.0, Boss.VICTORY_TIME)
	assert_eq(c.seal.state, SealLook.State.VICTORY)
	c.set_seal_state(&"normal")
	assert_eq(c.seal.state, SealLook.State.NORMAL)


func test_point_toward_counts_round_the_screen() -> void:
	var seen := {}
	for i in 8:
		seen[chamber.point_toward(Vector2.from_angle(TAU * i / 8.0 + 0.1))] = true
	assert_eq(seen.size(), 8, "each direction picks its own point")
