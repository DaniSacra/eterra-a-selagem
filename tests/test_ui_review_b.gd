extends GutTest
## UI review 2026-11-24b: the Dons caption wraps on words, a shop sign stays inside the screen, the Videira says the
## state once, the Maestria says it is a level.


func test_caption_wraps_on_words_and_keeps_every_word() -> void:
	var text := "O combo ganha um quarto golpe, uma estocada longa que atravessa a fila"
	var lines := MedallionView.caption_lines(text)
	assert_gt(lines.size(), 1, "long text takes two lines")
	assert_eq(" ".join(lines), text, "nothing is cut")
	var box := MedallionView.caption_box_size(lines)
	assert_lte(box.x, MedallionView.CAPTION_W + 16.0 + 40.0)


func test_node_numbers_are_readable() -> void:
	assert_gte(MedallionView.NODE_NUM_MIN, 16)


func test_sign_is_pushed_inside_the_screen() -> void:
	var screen := Rect2(0, 0, 1280, 720)
	var out := DoorSign.clamp_to_screen(Rect2(1250, -10, 100, 40), screen)
	assert_true(screen.encloses(out))
	assert_eq(DoorSign.clamp_to_screen(Rect2(500, 300, 100, 40), screen).position, Vector2(500, 300))


func test_own_life_of_a_node() -> void:
	var v := Vine.new(Vine.load_catalog())
	assert_eq(Vine.own_life(v.find(&"vida_1")), 5)
	assert_eq(Vine.own_life(v.find(&"prata")), 0)
	assert_true(VineScreen.can_water(Vine.State.AVAILABLE))
	assert_false(VineScreen.can_water(Vine.State.SHORT))


func test_mastery_label_says_level() -> void:
	assert_string_contains(T.t(&"hero_mastery_level", {"n": 3}), "nível 3")
