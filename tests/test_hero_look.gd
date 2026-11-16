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


## Standing, running, sprinting and dashing he carries Emeth ahead of him, pointing forward and a little down, the
## hand ahead of the hips (Daniel, 2026-11-15, from an Ember & Blade frame; it used to trail behind his back: the
## fist held the blade out of the pinky side and the old idle kept the hand behind the hip). He faces +Z.
func test_he_carries_the_blade_ahead_of_him() -> void:
	var body: Array = HeroBody.make()
	var model: Node3D = body[0]
	add_child_autofree(model)
	var anim: AnimationPlayer = body[1]
	var sword: Node3D = body[2]
	var sk := PoseBaker.find_skeleton(model)
	var hand := sk.find_bone(&"RightHand")
	var hips := sk.find_bone(&"Hips")
	var space := Transform3D(Retarget._space(sk, model), Vector3.ZERO)
	for clip: StringName in [&"Idle", &"Run", &"Sprint", &"Dash"]:
		var length := anim.get_animation(clip).length
		for i in 6:
			anim.play(clip)
			anim.seek(length * i / 5.0, true)
			var at := sk.get_bone_global_pose(hand)
			var grip := space * at.origin
			var tip := space * (at * sword.transform * Vector3(0, EmethSword.TIP, 0))
			var blade := (tip - grip).normalized()
			var where := "%s at %.2f s" % [clip, length * i / 5.0]
			assert_gt(blade.z, 0.7, "%s: the blade points ahead of him" % where)
			assert_between(blade.y, -0.6, 0.05, "%s: level or a little down" % where)
			assert_gt(tip.z - (space * sk.get_bone_global_pose(hips).origin).z, 0.6, "%s: the tip well ahead of his hips" % where)


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


## Covered, he is the same body: lit and painted as his own materials are, the blade with the light of Emeth's own
## shader, a little see-through (docs/art/cycle7_spec.md 3.2, items 1 and 4).
func test_the_xray_draws_the_body_and_the_blade_as_their_own_materials_do() -> void:
	var body: Array = HeroBody.make()
	var model: Node3D = autofree(body[0])
	var skin := (model.find_children("*", "MeshInstance3D", true, false)[0] as MeshInstance3D).get_active_material(0)
	var covered := Player.xray_params(skin)
	assert_almost_eq(float(covered[&"fill"]), HeroBody.FILL, 0.001, "the same painting as light as the body")
	assert_almost_eq(float(covered[&"opacity"]), 0.85, 0.001)
	assert_false(covered.has(&"blade"), "the body is not a blade")
	assert_between(float(covered[&"floor_light"]), 0.05, 0.3, "shadows lifted, not recoloured")
	var sword := body[2] as MeshInstance3D
	var emeth := (sword.get_node("Blade") as MeshInstance3D).material_override as ShaderMaterial
	var blade := Player.xray_params(emeth)
	assert_eq(float(blade[&"blade"]), 1.0, "the blade shows through a cover")
	assert_almost_eq(float(blade[&"opacity"]), 0.8, 0.001)
	assert_eq(blade[&"blade_color"], emeth.get_shader_parameter(&"blade_color"), "Emeth's own emerald")
	assert_lt(float(blade[&"blade_glow"]), Game.GLOW_THRESHOLD, "under the glow threshold, covered too")
	var core := Player.xray_params((sword.get_node("Blade/Core") as MeshInstance3D).material_override)
	assert_eq(float(core[&"own_light"]), 1.0, "the pale edge of the blade has its own light")
	var shader_params: Array = Player.XRAY.get_shader_uniform_list().map(func(u: Dictionary) -> String: return u.name)
	for param: StringName in blade:
		assert_has(shader_params, String(param), "xray.gdshader knows it")


## The rim through a cover is a hair of ivory, never cyan nor a thick white outline (item 2).
func test_the_xray_rim_is_a_warm_hair() -> void:
	assert_lte(Player.XRAY_RIM_WIDTH, 1.5, "pixels on a 941 line screen")
	assert_lte(Player.XRAY_RIM.a, 0.5)
	assert_gt(Player.XRAY_RIM.r, Player.XRAY_RIM.b + 0.1, "warm (ivory), not cyan")
	assert_lte(Player.KEY_LIGHT.a, 0.35, "the painted light on his shoulders stays small (cycle 7 review, B5: up to 0.35)")


## After a hit he never turns white (a struck enemy does): a flash of at most 0.05 s, then his own colours lighter
## and back (item 3).
func test_a_hit_lightens_his_own_colours_and_never_paints_him_white() -> void:
	assert_lte(Player.HURT_FLASH, 0.05)
	assert_almost_eq(Player.HURT_LIGHTEN, 0.35, 0.001)
	assert_eq(Player.blink_lighten(0.0), 0.0, "no blink when he is not hurt")
	var on := 0
	var steps := 130
	for i in steps:
		var lighten := Player.blink_lighten(HeroDef.warrior().hurt_invuln * float(i + 1) / steps)
		assert_true(lighten == 0.0 or lighten == Player.HURT_LIGHTEN)
		on += 1 if lighten > 0.0 else 0
	assert_between(float(on) / steps, 0.4, 0.6, "half the time lighter, half as he is")
	var flash := Player.FLASH.get_shader_uniform_list().map(func(u: Dictionary) -> String: return u.name)
	assert_has(flash, "key", "the painted light is on the uncovered body too")


## The ring says where he looks: a wedge on that side, a little brighter, still thin and petrol (item 5).
func test_the_ring_has_a_brighter_wedge_where_he_faces() -> void:
	assert_almost_eq(Player.RING_WEDGE, 30.0, 0.001)
	assert_almost_eq(Player.RING_WEDGE_GAIN, 1.4, 0.001)
	var ring := Player.RING.get_shader_uniform_list().map(func(u: Dictionary) -> String: return u.name)
	assert_has(ring, "facing")
	assert_lt(Player.RING_OPEN * Player.RING_WEDGE_GAIN, 0.5, "still faint on the open floor")


func test_the_xray_is_drawn_after_the_life_bars_and_the_ring_is_not_a_warning() -> void:
	assert_gt(Player.XRAY_PRIORITY, 10, "after the enemies' life bars (CrowdRenderer)")
	assert_gt(Player.RING_COLOR.g, Player.RING_COLOR.r * 2.0, "petrol, never the red of a warning")
	assert_lt(Player.RING_OPEN, 0.5, "faint on the open floor")


## Behind stone he is fainter than through the crowd and the ring is not drawn over it (cycle 8, B3): the x-ray of
## each mesh has a pass for each, told apart by the stencil the crowd writes.
func test_behind_stone_he_is_fainter_than_through_the_crowd() -> void:
	var body: Array = HeroBody.make()
	var model: Node3D = autofree(body[0])
	var skin := (model.find_children("*", "MeshInstance3D", true, false)[0] as MeshInstance3D).get_active_material(0)
	var crowd := Player.xray_params(skin)
	var stone := Player.xray_params(skin, true)
	assert_lt(float(stone[&"opacity"]), float(crowd[&"opacity"]) * 0.6, "clearly fainter behind stone")
	assert_eq(float(stone[&"cover_light"]), 0.0, "no extra light behind stone")
	assert_lt(float(stone[&"floor_light"]), float(crowd[&"floor_light"]))
	assert_true(Player.XRAY.code.contains("compare_equal, 1"), "through the crowd: where the crowd drew")
	assert_true(Player.XRAY_BEHIND.code.contains("compare_not_equal, 1"), "behind stone: where it did not")
	assert_true(load("res://assets/shaders/crowd.gdshader").code.contains("stencil_mode write, compare_always, 1"),
		"the crowd marks where it is the front surface")
	assert_false(Player.RING.code.contains("stencil_mode"), "the ring on the open floor needs no stencil")
	assert_true(Player.RING_THROUGH_SHADER.code.contains("compare_equal, 1"), "the ring shows only through the crowd")
