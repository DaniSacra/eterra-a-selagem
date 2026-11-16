extends GutTest
## Cycle 10, the look of Morvath's fight and of the crowd (only drawn): the ritual's shield and its specks never past
## the glow, its curtain rises once around him and is gone, his corrupted emerald stays apart from the Emeth's green,
## enemy shots keep their hue under the glow with a small halo, the burn is embers (never a gold body), and the room's
## mood turns the air and the fires of any scenery and gives them back exactly.

## Game.GLOW_THRESHOLD (game.gd is not loaded here).
const GLOW := 1.3


func _hsv(c: Color) -> Vector3:
	return Vector3(c.h * 360.0, c.s, c.v)


## A uniform's default as written in the shader's code (a float, or a vec3/vec4 as a Color): the headless renderer
## does not compile shaders, so their parameters are read from the source.
func _default(shader: Shader, name_: StringName) -> Variant:
	var re := RegEx.create_from_string("uniform\\s+\\w+\\s+%s\\b[^=;]*=\\s*([^;]+);" % name_)
	var m := re.search(shader.code)
	assert_not_null(m, "uniform %s" % name_)
	if m == null:
		return null
	var v := m.get_string(1).strip_edges()
	if v.begins_with("vec"):
		var n := v.substr(v.find("(") + 1).trim_suffix(")").split(",")
		return Color(float(n[0]), float(n[1]), float(n[2]))
	return float(v)


# ---------- the ritual's shield ----------

func test_the_shield_specks_stay_small_and_under_the_glow() -> void:
	assert_lte(BossShield.MOTE_SIZE, 0.12, "no speck larger than a hand")
	var green := BossShield.COLOR * BossShield.MOTE_LIGHT
	var blue := BossShield.MOTE_BLUE * BossShield.MOTE_BLUE_LIGHT
	for c in [green, blue]:
		assert_lte(maxf(c.r, maxf(c.g, c.b)), 1.2, "never past 1.2 (B2 of the cycle 9 review)")


func test_his_corrupted_emerald_is_colder_and_darker_than_the_emeth() -> void:
	var his := _hsv(BossShield.COLOR)
	var emeth := _hsv(Color(0.08, 0.85, 0.27))
	assert_almost_eq(his.x, 165.0, 6.0, "a cold teal green")
	assert_lte(his.z, 0.7, "dark")
	assert_lte(his.y, 0.6, "turbid")
	assert_gt(his.x - emeth.x, 20.0, "the Emeth's green is warmer")
	var column: Color = _default(Ground.COLUMN_SHADER, &"color")
	var rune: Color = _default(Ground.RUNE_SHADER, &"color")
	for c in [column, rune]:
		assert_gt(_hsv(c).x, 155.0, "the columns and circles share it")
		assert_lte(_hsv(c).z, 0.75)


func test_the_curtain_rises_once_around_him_and_is_gone() -> void:
	var s := BossShield.create(3.0)
	add_child_autofree(s)
	var m := s.material_override as ShaderMaterial
	s.visible = true
	m.set_shader_parameter(&"power", 0.2)
	s._process(0.016)
	assert_true(s._curtain.visible, "it rises as the shield grows in")
	assert_lte(BossShield.CURTAIN_STRENGTH, 0.4, "faint where it crosses him")
	assert_gte(BossShield.CURTAIN, 1.0, "on the shield's edge, not over him")
	m.set_shader_parameter(&"power", 1.0)
	for i in ceili(BossShield.CURTAIN_TIME / 0.05) + 2:
		s._process(0.05)
	assert_false(s._curtain.visible, "and is gone")
	for i in 20:
		s._process(0.05)
	assert_false(s._curtain.visible, "only once while the shield stands")
	s.visible = false
	s._process(0.05)
	s.visible = true
	m.set_shader_parameter(&"power", 0.1)
	s._process(0.016)
	assert_true(s._curtain.visible, "again when a shield is raised anew")


# ---------- enemy shots ----------

func test_enemy_shots_keep_their_hue_under_the_glow() -> void:
	var p := Projectiles.new()
	add_child_autofree(p)
	var s := p.fire(Projectiles.Kind.ORB, Vector2.ZERO, Vector2.RIGHT, 5.0, 1.0, 0.45, 2.0, Color(1.7, 1.25, 3.2))
	var hue: Vector3 = (s.node as GeometryInstance3D).get_instance_shader_parameter(&"hue")
	assert_almost_eq(maxf(hue.x, maxf(hue.y, hue.z)), 1.0, 0.0001, "the hue, not the raw HDR magic")
	assert_almost_eq(hue.z, 1.0, 0.0001, "the sorcerer's violet stays violet")
	var heart: float = _default(Projectiles.ORB_SHADER, &"heart")
	var share: float = _default(Projectiles.ORB_SHADER, &"heart_share")
	assert_lte(heart, GLOW, "its heart under the glow")
	assert_lte(share, 0.3, "a small heart")
	var halo: MeshInstance3D = s.node.get_child(0)
	assert_lte((halo.mesh as QuadMesh).size.x * 0.5, 0.45 * 1.5 + 0.0001, "a halo no wider than 1.5 radii")
	assert_eq(halo.material_override, p._orb_material(Projectiles.HALO_SHADER), "one material for every shot")


# ---------- the burn ----------

func test_the_burn_is_embers_not_a_gold_body() -> void:
	var crowd: Shader = load("res://assets/shaders/crowd.gdshader")
	assert_lte(float(_default(crowd, &"burn_rim")), 0.5, "the rim of fire")
	var coal: Color = _default(crowd, &"coal_color")
	var rim: Color = _default(crowd, &"burn_color")
	for c in [coal, rim]:
		assert_lte(maxf(c.r, maxf(c.g, c.b)), GLOW, "under the glow")
		assert_lt(c.g / c.r, 0.5, "orange embers, never yellow")
	assert_lte(float(_default(crowd, &"burn_coals")), 0.1, "a few coals, not the whole body")


# ---------- the room's mood ----------

func test_a_mood_turns_the_air_and_fires_and_gives_them_back() -> void:
	var env := Environment.new()
	env.ambient_light_color = Color(0.3, 0.4, 0.46)
	env.ambient_light_energy = 0.9
	env.background_color = Color(0.06, 0.22, 0.27)
	env.fog_light_color = Color(0.06, 0.22, 0.27)
	env.fog_height_density = 0.6
	var scenery := Node3D.new()
	add_child_autofree(scenery)
	var fire := OmniLight3D.new()
	fire.light_color = Color(1.0, 0.68, 0.42)
	fire.light_energy = 4.5
	scenery.add_child(fire)
	var key := OmniLight3D.new()
	key.light_color = Color(0.92, 0.8, 0.78)
	key.light_energy = 5.6
	scenery.add_child(key)
	var portal := OmniLight3D.new()
	portal.light_color = Color(1.0, 0.1, 0.1)
	portal.light_energy = 6.0
	scenery.add_child(portal)
	var mood := RoomMood.new(scenery, env)
	mood.keep.append(portal)
	add_child_autofree(mood)
	var look := RoomMood.LAST_BREATH
	mood.blend(look, true, 1.0)
	for i in 30:
		mood._process(0.05)
	assert_almost_eq(mood.weight(), 1.0, 0.001)
	assert_true(env.background_color.is_equal_approx(look.sky), "the depths take the mood's colour")
	assert_true(env.fog_light_color.is_equal_approx(look.fog))
	assert_lt(fire.light_energy, 4.5, "the fires gutter")
	assert_gt(fire.light_energy, 4.5 * look.fires_gain * 0.8, "but never go out")
	assert_almost_eq(key.light_energy, 5.6, 0.0001, "the cool key over the hall's middle is not a fire")
	assert_almost_eq(portal.light_energy, 6.0, 0.0001, "the portal's light stays the portal's")
	assert_gte(env.ambient_light_energy, 0.9 * look.ambient_gain * (1.0 - look.breath) - 0.001, "the room is not darkened")
	mood.blend(look, false, 1.0)
	for i in 30:
		mood._process(0.05)
	assert_eq(mood.weight(), 0.0)
	assert_true(env.background_color.is_equal_approx(Color(0.06, 0.22, 0.27)), "exactly as it was")
	assert_true(env.ambient_light_color.is_equal_approx(Color(0.3, 0.4, 0.46)))
	assert_almost_eq(env.ambient_light_energy, 0.9, 0.0001)
	assert_almost_eq(fire.light_energy, 4.5, 0.0001)
	assert_true(fire.light_color.is_equal_approx(Color(1.0, 0.68, 0.42)))


func test_a_room_that_leaves_in_its_mood_gives_the_world_back() -> void:
	var env := Environment.new()
	env.background_color = Color(0.06, 0.22, 0.27)
	var mood := RoomMood.new(null, env)
	add_child(mood)
	mood.blend(RoomMood.LAST_BREATH, true, 0.5)
	mood._process(0.25)
	assert_false(env.background_color.is_equal_approx(Color(0.06, 0.22, 0.27)))
	remove_child(mood)
	mood.free()
	assert_true(env.background_color.is_equal_approx(Color(0.06, 0.22, 0.27)), "a new room starts in its own air")
