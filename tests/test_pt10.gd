extends GutTest
## PT-10: the key inside the Blessing's sentence, the ichthys and the altar of the Encanto's choice.


func test_the_key_stands_inside_the_sentence() -> void:
	var st := BoonState.new(BoonState.load_catalog())
	var b := st.find(&"golpe_brasa")
	var plain := BoonChoice.describe(b, 1)
	assert_true(plain.begins_with("O ataque ["), plain)
	assert_false(plain.contains("{"), plain)
	var marked := BoonChoice.describe(b, 1, 1.0, true)
	assert_true(marked.contains("[lb]") or marked.contains("[img"), "the key in bbcode: brackets escaped, or the mouse icon (PT-26-1)")


func test_every_blessing_of_a_button_says_its_key_or_none_misses_a_placeholder() -> void:
	var st := BoonState.new(BoonState.load_catalog())
	for b in st.catalog:
		assert_false(BoonChoice.describe(b, 1).contains("{"), String(b.id))


func test_a_blessing_that_acts_alone_has_no_key_in_its_words() -> void:
	assert_eq(BoonChoice.key_in_text(&""), "")
	assert_false(BoonChoice.describe(BoonState.new(BoonState.load_catalog()).find(&"consolo"), 1).contains("["))


func test_the_ichthys_has_two_crossing_arcs_ending_at_one_nose() -> void:
	var a := Ichthys.arcs(Vector2(50, 50), 40.0)
	assert_eq(a.size(), 2)
	assert_eq(a[0][a[0].size() - 1], a[1][a[1].size() - 1], "one nose")
	assert_ne(a[0][0], a[1][0], "two tails")
	assert_lt(a[0][a[0].size() / 2].y, a[1][a[1].size() / 2].y, "one bulges up, the other down")


func test_the_enchant_screen_has_the_altar_and_moves_the_page_right() -> void:
	var s := EnchantChoice.new()
	add_child_autofree(s)
	s.size = Vector2(1280, 720)
	var opts: Array = Enchants.load_catalog().slice(0, 2)
	s.open_enchants(opts)
	await wait_process_frames(2)
	var altar := s.get_node_or_null("altar") as Control
	assert_not_null(altar)
	assert_gt(altar.size.x, 100.0)
	assert_eq(s.cards().size(), 2)
