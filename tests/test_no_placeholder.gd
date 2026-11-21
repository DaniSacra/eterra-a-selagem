extends GutTest
## Cycle C12d, VX-11: no "PALADIN_n" placeholder ever reaches the player. A clause naming a paladin not yet named
## by Daniel is dropped ("Luz" instead of "Luz, dom de PALADIN_4") and comes back by itself once the name is set.

const MARK := "PALADIN_"


func _texts_in(node: Node, out: Array[String]) -> void:
	if node is Label:
		out.append((node as Label).text)
	elif node is Button:
		out.append((node as Button).text)
	elif node is RichTextLabel:
		out.append((node as RichTextLabel).get_parsed_text())
	for c in node.get_children():
		_texts_in(c, out)


func _assert_clean(root: Node, what: String) -> void:
	var texts: Array[String] = []
	_texts_in(root, texts)
	assert_gt(texts.size(), 0, "%s shows some text" % what)
	for s in texts:
		assert_false(s.contains(MARK), "%s: \"%s\"" % [what, s])


func test_no_text_in_the_table_shows_a_placeholder() -> void:
	for key: String in T.table.entries:
		if key.begins_with(MARK):
			continue  # the placeholders themselves, never shown on their own
		assert_false(T.t(key).contains(MARK), "%s: %s" % [key, T.t(key)])


func test_a_clause_comes_back_once_the_paladin_is_named() -> void:
	var table := TextTable.new()
	table.entries = {"PALADIN_4": "PALADIN_4", "family_luz": "Luz[, dom de {P4}]", "plain": "a [b] c"}
	assert_eq(table.text(&"family_luz"), "Luz")
	assert_eq(table.text(&"plain"), "a b c", "a clause with no paladin always stays")
	table.entries["PALADIN_4"] = "Aurel"
	assert_eq(table.text(&"family_luz"), "Luz, dom de Aurel")


func test_every_family_card_shows_no_placeholder() -> void:
	var state := BoonState.new(BoonState.load_catalog())
	# one gift of each family, offered on the level up screen
	var offers: Array[Boon] = []
	var seen := {}
	for b in state.catalog:
		if not seen.has(b.family):
			seen[b.family] = true
			offers.append(b)
	assert_eq(seen.size(), Boon.FAMILY_KEY.size(), "every family is offered")
	for i in range(0, offers.size(), 3):
		var choice := BoonChoice.new()
		add_child_autofree(choice)
		choice.open(offers.slice(i, i + 3), state)
		_assert_clean(choice, "gift cards %d" % i)


func test_the_gifts_panel_shows_no_placeholder() -> void:
	var state := BoonState.new(BoonState.load_catalog())
	var seen := {}
	for b in state.catalog:
		if not b.is_duo() and not seen.has(b.family):
			seen[b.family] = true
			state.take(b)
	var panel := BoonsScreen.new()
	panel.state = state
	add_child_autofree(panel)
	panel.open()
	_assert_clean(panel, "gifts panel")


# ---------- VX-12: the hit count stays small ----------

## The tallest figure of the hit count at the top of its pop, in pixels at 1080 lines (the HUD is laid out at 720).
func test_hit_count_digits_stay_under_48_px_at_1080() -> void:
	var ts := TextServerManager.get_primary_interface()
	var font: Font = UiKit.TITLE_FONT
	var px := roundi(Hud.FONT_COMBO * (1.0 + Hud.COMBO_POP) * 1080.0 / 720.0)
	var tallest := 0.0
	for rid: RID in font.get_rids():
		var size := Vector2i(px, 0)
		for d in "0123456789":
			var g := ts.font_get_glyph_index(rid, px, d.unicode_at(0), 0)
			ts.font_render_glyph(rid, size, g)
			tallest = maxf(tallest, ts.font_get_glyph_size(rid, size, g).y)
	assert_gt(tallest, 0.0, "measured")
	assert_lte(tallest, 48.0, "figures %.1f px tall" % tallest)
	assert_lte(Hud.MOVE_ALPHA, 0.9, "the move's name is dimmed (0.9 since the art review of 2026-11-21: it sits on the row band)")
