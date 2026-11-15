extends GutTest
## The explorer's look (docs/art/cycle5_spec.md A2, A3): his own Meshy model, drawn a little taller than his size in
## the fight, with clips baked for that body and the sword's grip measured on it.


func test_drawn_taller_than_his_size_in_the_fight() -> void:
	assert_gt(HeroBody.HEIGHT, HeroBody.GAME_HEIGHT, "drawn taller (A3)")
	assert_almost_eq(HeroBody.GAME_HEIGHT, 2.5, 0.001, "the fight keeps the Hades II scale")


func test_the_explorer_body_has_its_clips_and_grip() -> void:
	assert_true(HeroBody.MODEL.contains("hero_explorer"), "the real explorer model, not the provisional Sombra")
	var lib: AnimationLibrary = load(HeroBody.ANIMS)
	for clip: StringName in [&"Idle", &"Run", &"Sprint", &"Roll", &"Slash_A", &"Slash_B", &"Slash_C", &"Death"]:
		assert_true(lib.has_animation(clip), String(clip))
	assert_true(lib.has_meta(&"grip_at") and lib.has_meta(&"grip_dir"), "the grip measured on his hand")


## Emeth is the Meshy model made from Daniel's art, where the sword of simple shapes was: the hand at the origin
## under the guard, the blade up to the same tip, only the blade lit and under the glow threshold.
func test_emeth_is_the_model_with_the_size_and_grip_of_the_sword_it_replaced() -> void:
	var sword: MeshInstance3D = autofree(EmethSword.make())
	var blade := sword.get_node("Blade") as MeshInstance3D
	assert_not_null(blade.mesh, "the model's mesh")
	assert_gt(blade.mesh.get_faces().size() / 3, 1000, "the real model, not a handful of shapes")
	var box := blade.transform * blade.mesh.get_aabb()
	assert_almost_eq(box.end.y, EmethSword.TIP, 0.02, "the tip where the old blade ended")
	assert_almost_eq(box.position.y, -0.4, 0.03, "the pommel where the old one was")
	assert_almost_eq(EmethSword.scale(), 1.0, 0.05, "the model is the game's size as it comes")
	# the hand closes on the grip: narrow around the origin, the guard just above it
	var grip_width := 0.0
	var guard_width := 0.0
	for v in blade.mesh.get_faces():
		var p := blade.transform * v
		if absf(p.y) < 0.1:
			grip_width = maxf(grip_width, absf(p.x))
		elif p.y > EmethSword.GRIP_TOP and p.y < EmethSword.GRIP_TOP + 0.3:
			guard_width = maxf(guard_width, absf(p.x))
	assert_lt(grip_width, 0.07, "the grip at the hand")
	assert_gt(guard_width, 0.2, "the horned guard right above the hand")


func test_only_the_blade_of_emeth_is_lit_and_it_does_not_bloom() -> void:
	var sword: MeshInstance3D = autofree(EmethSword.make())
	var mat := (sword.get_node("Blade") as MeshInstance3D).material_override as ShaderMaterial
	assert_eq(mat.shader, EmethSword.SHADER)
	assert_almost_eq(float(mat.get_shader_parameter(&"blade_from")), EmethSword.MODEL_BLADE_FROM, 0.001, "light from the guard up")
	assert_gt(EmethSword.MODEL_BLADE_FROM, EmethSword.MODEL_GRIP_TOP, "guard, grip and pommel are not lit")
	assert_lt(EmethSword.BLADE_GLOW, Game.GLOW_THRESHOLD, "the blade's body stays under the glow threshold")
	var green: Color = mat.get_shader_parameter(&"blade_color")
	assert_true(green.g > green.b * 2.0 and green.g > green.r * 4.0, "emerald, not cyan")
	var core := sword.get_node("Blade/Core") as MeshInstance3D
	assert_lt(core.mesh.get_aabb().size.x, 0.03, "a thin edge of light down the middle")


## Through a crowd he shows in his own colours (xray.gdshader): each mesh of his gives its painted texture.
func test_the_xray_paints_each_mesh_with_its_own_texture() -> void:
	var body: Array = HeroBody.make()
	var model: Node3D = autofree(body[0])
	var meshes := model.find_children("*", "MeshInstance3D", true, false)
	assert_gt(meshes.size(), 1, "his body and the sword")
	var textured := 0
	for n in meshes:
		var look := Player.xray_look((n as MeshInstance3D).get_active_material(0))
		var c: Color = look[1]
		assert_true(maxf(c.r, maxf(c.g, c.b)) <= 1.0, "no colour over 1: the x-ray never blooms")
		textured += 1 if look[0] != null else 0
	assert_gt(textured, 1, "the body and the Emeth are painted from their textures")
	assert_null(Player.xray_look(null)[0])


func test_the_xray_is_drawn_after_the_life_bars_and_the_ring_is_not_a_warning() -> void:
	assert_gt(Player.XRAY_PRIORITY, 10, "after the enemies' life bars (CrowdRenderer)")
	assert_gt(Player.RING_COLOR.g, Player.RING_COLOR.r * 2.0, "petrol, never the red of a warning")
	assert_lt(Player.RING_OPEN, 0.5, "faint on the open floor")
