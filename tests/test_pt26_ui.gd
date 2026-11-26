extends GutTest
## PT-26-1 and PT-26-4: the mouse icon where the text said "Clique esquerdo", and every Blessing in the build column.


func _state() -> BoonState:
	return BoonState.new(BoonState.load_catalog())


func test_the_mouse_names_become_icons_and_other_text_stays() -> void:
	var left := T.t(&"mouse_1")
	assert_eq(MouseGlyph.button_of(left), MOUSE_BUTTON_LEFT)
	assert_eq(MouseGlyph.button_of(T.t(&"mouse_2")), MOUSE_BUTTON_RIGHT)
	assert_eq(MouseGlyph.button_of("Q"), 0)
	var said := MouseGlyph.keyed("Aperte %s 3 vezes" % left)
	assert_false(said.contains(left), "the words are gone")
	assert_true(said.contains("[img="), "the icon is in")
	assert_eq(MouseGlyph.keyed("Aperte Q [x]"), "Aperte Q [lb]x]", "brackets are escaped, a key stays words")
	assert_true(MouseGlyph.has_mouse("Use %s" % left))
	assert_false(MouseGlyph.has_mouse("Use Q"))


func test_each_button_has_its_own_lit_drawing() -> void:
	var images: Array[Image] = []
	for b in MouseGlyph.BUTTONS:
		var tex := MouseGlyph.texture(b)
		assert_not_null(tex)
		assert_eq(tex.get_size(), Vector2(MouseGlyph.W, MouseGlyph.H) * MouseGlyphArt.SCALE)
		images.append(MouseGlyphArt.rasterize(b))
	assert_ne(images[0].get_data(), images[1].get_data(), "left and right differ")
	assert_ne(images[0].get_data(), images[2].get_data(), "left and middle differ")
	assert_eq(images[0].get_pixel(0, 0).a, 0.0, "the corner is clear")


func test_a_key_plate_draws_a_mouse_for_a_mouse_button_and_words_for_a_key() -> void:
	var cap := StationSign.KeyCap.new()
	add_child_autofree(cap)
	cap.set_key(T.t(&"mouse_2"), false)
	assert_eq(cap.mouse, MOUSE_BUTTON_RIGHT)
	cap.set_key("Q", false)
	assert_eq(cap.mouse, 0)
	cap.set_key(T.t(&"mouse_2"), true)
	assert_eq(cap.mouse, 0, "the pad's own button is never a mouse")


func test_the_card_sentence_and_the_plaque_carry_the_icon() -> void:
	var was := Controls.using_pad
	Controls.using_pad = false
	assert_true(BoonChoice.key_in_text(&"light_attack", true).contains("[img="))
	assert_false(BoonChoice.key_in_text(&"light_attack", false).contains("[img="), "plain text stays plain")
	var plaque := BoonCard.key_plaque(&"light_attack")
	add_child_autofree(plaque)
	assert_true(plaque.get_node("Key") is TextureRect)
	var q := BoonCard.key_plaque(&"shout")
	add_child_autofree(q)
	assert_true(q.get_node("Key") is Label, "Q stays a key")
	Controls.using_pad = was


func test_the_column_lists_every_blessing_with_its_state() -> void:
	var st := _state()
	var attack: Array[Boon] = []
	var passive: Array[Boon] = []
	for b in st.catalog:
		if b.is_duo():
			continue
		if b.slot == Boon.Slot.ATTACK and attack.is_empty():
			attack.append(b)
		elif b.slot == Boon.Slot.SPECIAL and attack.size() < 2:
			attack.append(b)
		elif b.slot == Boon.Slot.NONE and passive.size() < 2:
			passive.append(b)
	var col := BuildColumn.new().setup()
	add_child_autofree(col)
	for b in attack + passive:
		st.take(b, Boon.Rarity.COMMON)
	var taken: Array[Boon] = st.owned().filter(func(b: Boon) -> bool: return not b.is_duo())
	assert_gte(taken.size(), 2, "a build of several")
	col.show_build(st)
	var shown: Array[Boon] = []
	for e in col.entries:
		if e.visible:
			shown.append(e.boon)
	for c in col.find_child("extras", true, false).get_children():
		if c is BuildColumn.Entry:
			shown.append((c as BuildColumn.Entry).boon)
	for b in taken:
		assert_true(b in shown, "%s is on the column" % b.id)
	assert_eq(shown.size(), taken.size())
	assert_gt(col.size.y, BuildColumn.height_for(0, 1), "the extras make it taller")
