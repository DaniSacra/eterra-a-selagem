extends GutTest
## Cycle 9, the look of Morvath's fight (only drawn): his ritual circles mark exactly the area that hurts and dissolve
## after landing, the ritual's shield follows the power Boss gives it and breaks in shards, the crypt's portal grows
## restless in his last phase and is sealed when he falls, and the obelisks open round the paladin behind them.


func _ground() -> Ground:
	var g := Ground.new()
	add_child_autofree(g)
	return g


func _param(node: MeshInstance3D, name_: StringName) -> Variant:
	return (node.material_override as ShaderMaterial).get_shader_parameter(name_)


# ---------- the ritual circles ----------

func test_a_ritual_circle_covers_exactly_the_area_that_hurts() -> void:
	var g := _ground()
	var at := Vector2(3, -4)
	var z := g.rune_burst(at, 2.5, 1.0, Ground.Rune.ERUPTION, 5.0)
	assert_eq((z.node.material_override as ShaderMaterial).shader, Ground.RUNE_SHADER, "drawn as his rune")
	# the quad is 1 m, the shader draws to its edge (d = 1) and not past it: its half width is the radius
	assert_almost_eq(z.node.scale.x * 0.5, z.radius, 0.0001)
	assert_almost_eq(z.node.scale.z * 0.5, z.radius, 0.0001)
	assert_almost_eq(_param(z.node, &"size_m"), z.radius, 0.0001, "the rim is laid on the area's edge")
	assert_eq(Vector2(z.node.position.x, z.node.position.z), at, "centred on the blow")
	assert_true(Ground.inside(z, at + Vector2(2.49, 0)), "just inside the rim hurts")
	assert_false(Ground.inside(z, at + Vector2(2.51, 0)), "just outside does not")
	assert_eq(z.power, 5.0, "the eruption keeps its damage")


func test_his_eruptions_become_ritual_circles_on_their_own() -> void:
	var g := _ground()
	# as Boss makes them: a warning in his colour, marked as an eruption after it is made
	var z := g.add_warning(Vector2(1, 1), 2.0, 1.2, 4.0, Boss.SPECTRAL)
	z.eruption = true
	g.step(0.016)
	assert_eq(z.rune, Ground.Rune.ERUPTION)
	assert_eq((z.node.material_override as ShaderMaterial).shader, Ground.RUNE_SHADER)
	assert_almost_eq(z.node.scale.x * 0.5, 2.0, 0.0001)
	var plain := g.add_warning(Vector2(-5, 0), 1.0, 1.0, 2.0)
	g.step(0.016)
	assert_eq(plain.rune, Ground.Rune.NONE, "every other warning keeps its own red look")
	assert_eq((plain.node.material_override as ShaderMaterial).shader, GroundLook.SHADER)


func test_the_circle_fills_then_lands_and_dissolves_with_its_column() -> void:
	var g := _ground()
	var z := g.rune_burst(Vector2.ZERO, 2.0, 1.0, Ground.Rune.ERUPTION, 3.0)
	g.step(0.5)
	assert_almost_eq(_param(z.node, &"progress"), 0.5, 0.01, "the warning fills with time")
	g.step(0.55)
	assert_false(g.zones.has(z), "the blow has landed: the zone is gone")
	assert_eq(g.dissolving(), 1, "the circle and its column live on a moment, only drawn")
	g.step(maxf(Ground.RUNE_AFTER, Ground.ERUPTION_TIME) + 0.01)
	assert_eq(g.dissolving(), 0, "then they are gone")


func test_a_called_off_circle_vanishes_without_landing() -> void:
	var g := _ground()
	g.rune_burst(Vector2.ZERO, 2.0, 1.0, Ground.Rune.ERUPTION, 3.0)
	g.clear_warnings()
	g.step(0.016)
	assert_eq(g.zones.size(), 0)
	assert_eq(g.dissolving(), 0, "no column for a blow that never came")


func test_a_summon_circle_hurts_no_one_and_still_shows_the_rising() -> void:
	var g := _ground()
	var z := g.rune_burst(Vector2(2, 2), 1.2, 0.8, Ground.Rune.SUMMON)
	assert_eq(z.power, 0.0)
	assert_eq(_param(z.node, &"kind"), Ground.Rune.SUMMON)
	g.step(0.85)
	assert_eq(g.dissolving(), 1, "energy rises where the dead stand up")
	assert_null(g.rune_burst(Vector2(5, 5), 1.2, 0.0, Ground.Rune.SUMMON), "no warning: one rising at once")
	assert_eq(g.dissolving(), 2)
	g.clear()
	assert_eq(g.dissolving(), 0, "clearing the floor takes them too")


func test_circles_are_pooled() -> void:
	var g := _ground()
	for i in 3:
		g.rune_burst(Vector2(i * 5, 0), 2.0, 0.2, Ground.Rune.ERUPTION, 1.0)
	g.step(0.25)
	g.step(2.0)
	var nodes := g.get_child_count()
	for i in 3:
		g.rune_burst(Vector2(i * 5, 0), 2.0, 0.2, Ground.Rune.ERUPTION, 1.0)
	g.step(0.25)
	g.step(2.0)
	assert_eq(g.get_child_count(), nodes, "the second round reuses the first one's circles and columns")


# ---------- the ritual's shield ----------

func test_the_shield_keeps_its_circle_on_the_floor_and_breaks_in_shards() -> void:
	var s := BossShield.create(3.0)
	add_child_autofree(s)
	assert_false(s.visible, "hidden until Boss raises it")
	assert_almost_eq((s.mesh as SphereMesh).radius, 3.0, 0.0001)
	# as Boss drives it: visible, its middle 0.7 of the radius up, a little small while it grows, its power
	s.visible = true
	s.position = Vector3(2, 2.1, -1)
	s.scale = Vector3.ONE * 0.8
	(s.material_override as ShaderMaterial).set_shader_parameter(&"power", 0.5)
	s._process(0.016)
	var circle: MeshInstance3D = s._circle
	assert_almost_eq(circle.global_position.y, BossShield.CIRCLE_Y, 0.001, "the circle lies on the floor")
	assert_almost_eq(circle.global_transform.basis.get_scale().x, 1.0, 0.001, "at its own size")
	assert_almost_eq(_param(circle, &"strength"), BossShield.CIRCLE_STRENGTH * 0.5, 0.001, "and grows in with the shield")
	assert_eq(_param(s, &"shatter"), 0.0)
	(s.material_override as ShaderMaterial).set_shader_parameter(&"power", 2.2)
	s._process(BossShield.SHATTER_TIME * 0.5)
	assert_almost_eq(_param(s, &"shatter"), 0.5, 0.01, "it breaks: the glass goes in shards")
	s._process(BossShield.SHATTER_TIME)
	assert_eq(_param(s, &"shatter"), 1.0)
	assert_eq(_param(circle, &"strength"), 0.0, "and its circle with it")


# ---------- the portal in his last phase, and the sealing ----------

func _kit() -> ArenaKit:
	var root := Node3D.new()
	add_child_autofree(root)
	var kit := ArenaKit.new(root, 1)
	kit.portal_glow(Vector3(0, 2.5, -12), 0.0, Vector2(3, 4))
	return kit


func test_the_last_phase_stirs_the_portal_and_the_sealing_calms_it() -> void:
	var kit := _kit()
	var sheet: ShaderMaterial = kit.portals[0][0]
	var light: OmniLight3D = kit.portals[0][1]
	var omen := PortalOmen.new(kit)
	add_child_autofree(omen)
	kit.light_portal(0, true, Boss.SPECTRAL)
	omen.final(true)
	omen._process(PortalOmen.RAMP)
	assert_almost_eq(sheet.get_shader_parameter(&"unrest") as float, 1.0, 0.001, "restless")
	assert_gt(light.light_energy, ArenaKit.PORTAL_LIGHT * 1.1, "its light rises")
	assert_lt(light.light_energy, ArenaKit.PORTAL_LIGHT * (PortalOmen.FINAL_GAIN + PortalOmen.WAVER) + 0.01, "with control")
	omen.seal(1.0, Vector2(0, 3))
	omen._process(0.5)
	assert_true(omen.busy())
	omen._process(0.6)
	assert_false(omen.busy(), "sealed")
	assert_eq(sheet.get_shader_parameter(&"unrest"), 0.0)
	assert_eq(sheet.get_shader_parameter(&"seal"), 0.0)
	assert_eq(sheet.get_shader_parameter(&"color"), ArenaKit.PORTAL_SHEET, "back to its own green")
	assert_eq(sheet.get_shader_parameter(&"power"), ArenaKit.PORTAL_DIM, "and closed")
	assert_almost_eq(light.light_energy, ArenaKit.PORTAL_LIGHT_DIM, 0.001)


func test_the_last_phase_ends_calm() -> void:
	var kit := _kit()
	var sheet: ShaderMaterial = kit.portals[0][0]
	var omen := PortalOmen.new(kit)
	add_child_autofree(omen)
	kit.light_portal(0, true, Boss.SPECTRAL)
	omen.final(true)
	omen._process(PortalOmen.RAMP)
	omen.final(false)
	omen._process(PortalOmen.RAMP)
	assert_eq(sheet.get_shader_parameter(&"unrest"), 0.0)
	assert_almost_eq((kit.portals[0][1] as OmniLight3D).light_energy, ArenaKit.PORTAL_LIGHT, 0.001, "its plain open light")


# ---------- the obelisks ----------

func test_obelisks_open_round_the_paladin_and_plain_stone_does_not() -> void:
	var root := Node3D.new()
	add_child_autofree(root)
	var m := Masonry.new(root)
	m.obelisk(Vector3.ZERO, 5.0, 2.0, Vector2(1, 1).normalized())
	var seen := 0
	for c in root.get_children():
		var mat := (c as MeshInstance3D).material_override as ShaderMaterial
		if mat != null and mat.shader == Masonry.SHADER:
			assert_eq(mat.get_shader_parameter(&"see_through"), 1.0, "every stone of the obelisk, its niche too")
			seen += 1
	assert_gt(seen, 4)
	assert_eq(m.stone(0.0).get_shader_parameter(&"see_through"), null, "the plain stone keeps the shader's default (0): whole")
