extends GutTest
## The art pipeline: every grid is well formed and uses only the master palette.


func _grid_names() -> PackedStringArray:
	var names := PackedStringArray()
	for file in DirAccess.get_files_at(GridSprite.GRID_DIR):
		if file.ends_with(".json"):
			names.append(file.get_basename())
	return names


func test_palette_matches_the_rpg_families() -> void:
	var pal := Palette.main()
	assert_eq(pal.tones(&"luz")[0], "#fff6c0")
	assert_eq(pal.tones(&"materia").size(), 8)
	assert_true(pal.has_hex("#26202E"), "lookup ignores case")
	assert_false(pal.has_hex("#123456"))


func test_every_grid_is_valid() -> void:
	var names := _grid_names()
	assert_gt(names.size(), 5)
	for n in names:
		var errs := GridSprite.check(GridSprite.load_def(n))
		assert_eq(errs.size(), 0, "%s: %s" % [n, ", ".join(errs)])


func test_every_grid_colour_is_in_the_master_palette() -> void:
	var pal := Palette.main()
	for n in _grid_names():
		for hex: String in GridSprite.load_def(n).pal.values():
			assert_true(pal.has_hex(hex), "%s uses %s, which is not in the palette" % [n, hex])


func test_no_sprite_outline_is_pure_black() -> void:
	for n in _grid_names():
		assert_false(GridSprite.load_def(n).pal.values().has("#000000"), n)


func test_strip_lays_frames_side_by_side() -> void:
	var def := {"size": [2, 1], "pal": {"a": "#ffffff", "b": "#a8323e"}, "frames": [["a."], [".b"]]}
	var img := GridSprite.to_strip(def)
	assert_eq(img.get_size(), Vector2i(4, 1))
	assert_eq(img.get_pixel(0, 0), Color.WHITE)
	assert_eq(img.get_pixel(1, 0).a, 0.0)
	assert_eq(img.get_pixel(3, 0), Color.html("#a8323e"))


func test_check_reports_bad_rows_and_letters() -> void:
	var def := {"size": [2, 2], "pal": {"a": "#ffffff"}, "frames": [["a.", "ax", "a."]]}
	assert_eq(GridSprite.check(def).size(), 2)


func test_recolor_swaps_only_the_named_colours() -> void:
	var def := {"size": [2, 1], "pal": {"a": "#ffffff", "b": "#a8323e"}, "frames": [["ab"]]}
	var out := GridSprite.recolor_hex(def, {"#a8323e": "#3a78c8"})
	assert_eq(out.pal.b, "#3a78c8")
	assert_eq(out.pal.a, "#ffffff")
	assert_eq(def.pal.b, "#a8323e", "the original is untouched")


func test_paladin_has_an_animation_for_every_state() -> void:
	var anims: Dictionary = GridSprite.load_def("paladin").anims
	for a in ["idle", "run", "dodge", "hurt", "death", "charge"]:
		assert_true(anims.has(a), a)


func test_sprite_frames_follow_the_grid_animations() -> void:
	var sf := Art.frames(&"paladin")
	assert_true(sf.has_animation(&"run"))
	assert_eq(sf.get_frame_count(&"run"), 4)
	assert_true(sf.get_animation_loop(&"run"))
	assert_false(sf.get_animation_loop(&"death"))
