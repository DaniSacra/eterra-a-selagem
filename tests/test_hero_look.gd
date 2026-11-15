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
