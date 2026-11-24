extends GutTest
## The Maga's body (M1c, 2026-11-23): her own Meshy model with her clips and the two-ended staff in her right hand;
## the Warrior keeps his.


func test_she_has_her_own_model_clips_and_staff() -> void:
	var body: Array = HeroBody.make(&"maga")
	var model: Node3D = body[0]
	add_child_autofree(model)
	assert_true(model.scene_file_path.contains("hero_maga_img"), "her model, not the Warrior's")
	var anim: AnimationPlayer = body[1]
	# her moves play Cast, the Passo its Blink; every name the Warrior's clips have is there too (the game may ask)
	for clip: StringName in [&"Idle", &"Run", &"Sprint", &"Cast", &"Blink", &"Hit", &"Death"]:
		assert_true(anim.has_animation(clip), String(clip))
	for clip: StringName in (load(HeroBody.ANIMS) as AnimationLibrary).get_animation_list():
		assert_true(anim.has_animation(clip), "the Warrior's %s too" % clip)
	var staff: Node3D = body[2]
	assert_not_null(staff)
	assert_true(staff.has_node(^"Upper") and staff.has_node(^"Lower"), "a head at each end")
	assert_false(staff.has_node(^"Blade"), "no Emeth: the sword's effects find nothing on her")


func test_the_staff_heads_stay_over_the_floor_standing_and_running() -> void:
	var body: Array = HeroBody.make(&"maga")
	var model: Node3D = body[0]
	add_child_autofree(model)
	var anim: AnimationPlayer = body[1]
	var staff: Node3D = body[2]
	var sk := PoseBaker.find_skeleton(model)
	var hand := sk.find_bone(&"RightHand")
	var space := Transform3D(Retarget._space(sk, model), Vector3.ZERO)
	for clip: StringName in [&"Idle", &"Run", &"Sprint", &"Cast", &"Blink"]:
		var length := anim.get_animation(clip).length
		for i in 6:
			anim.play(clip)
			anim.seek(length * i / 5.0, true)
			var at := sk.get_bone_global_pose(hand)
			for way: float in [1.0, -1.0]:
				var head := space * (at * staff.transform * Vector3(0, way * MagaStaff.HALF, 0))
				assert_gt(head.y, 0.2, "%s at %d/5: a head %.2f m over the floor (model 1.8 m)" % [clip, i, head.y])


func test_the_warrior_keeps_his_body() -> void:
	var body: Array = HeroBody.make(&"warrior")
	add_child_autofree(body[0])
	assert_true((body[0] as Node3D).scene_file_path.contains("hero_explorer"))
	assert_true((body[2] as Node3D).has_node(^"Blade"), "Emeth in his hand")


func test_the_hud_shows_the_magas_own_face() -> void:
	assert_ne(HeroCrest.portrait_of(&"maga"), HeroCrest.PORTRAIT, "her face, cut from the approved art")
	assert_eq(HeroCrest.portrait_of(&"warrior"), HeroCrest.PORTRAIT)
	assert_eq(HeroCrest.portrait_of(&""), HeroCrest.PORTRAIT)
