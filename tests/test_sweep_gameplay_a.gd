extends GutTest
## Sweep 2026-11-25, lote A: the Golpe Supremo is not announced before its milestone (P1-4, P2-8), Esc on a Videira figure
## goes back to the sky (P0-1) and --vine-zoom opens on the figure asked.

var _saved: Dictionary


func before_each() -> void:
	_saved = Save.data
	Save.data = SaveData.defaults()


func after_each() -> void:
	Save.data = _saved
	Dev.drop("vine-zoom")


func _data(xp: int, runs: int) -> Dictionary:
	var d := SaveData.defaults()
	var block := SaveData.hero(d, "warrior")
	block.mastery_xp = xp
	SaveData.open_revealed(block)
	d.runs = runs
	return d


func _texts(n: Node) -> PackedStringArray:
	var out := PackedStringArray()
	for l in n.find_children("*", "Label", true, false):
		out.append((l as Label).text)
	return out


func test_the_six_buttons_list_hides_shift_while_the_ultimate_is_closed() -> void:
	var closed := AbilityList.new().setup(220.0, false)
	add_child_autofree(closed)
	assert_false((closed._lines[&"ultimate"] as Control).visible, "no Shift line")
	assert_true((closed._lines[&"light_attack"] as Control).visible)
	var open_list := AbilityList.new().setup(220.0, true)
	add_child_autofree(open_list)
	assert_true((open_list._lines[&"ultimate"] as Control).visible, "Shift with the milestone open")


func test_need_ult_shows_only_while_the_ultimate_is_closed() -> void:
	var st := BoonState.new(BoonState.load_catalog())
	var ult: Boon = null
	for b in st.catalog:
		if b.slot == Boon.Slot.ULT and not b.reserve and b.requires_sets.is_empty() and b.needs_tag == &"":
			ult = b
			break
	assert_not_null(ult)
	assert_true(BoonNeeds.lines(ult, st.catalog, true).is_empty(), "open: nothing asked")
	assert_true(BoonNeeds.lines(ult, st.catalog, false).has(T.t(&"need_ult")), "closed: it asks the Supremo")


func test_the_golpe_supremo_is_not_listed_in_the_livro_while_its_milestone_is_closed() -> void:
	var s := HeroScreen.new()
	add_child_autofree(s)
	s.open(_data(0, 0), HeroScreen.Chapter.HERO)
	assert_false(_texts(s).has(T.t(&"howto_ultimate")), "closed: no Supremo row")
	assert_false(_texts(s).has(T.t(&"ult_cleave")))
	var o := HeroScreen.new()
	add_child_autofree(o)
	o.open(_data(HeroDef.warrior().mastery.total_to(6), 6), HeroScreen.Chapter.HERO)
	assert_true(_texts(o).has(T.t(&"ult_cleave")) or _texts(o).has(T.t(&"howto_ultimate")), "open: the Supremo is there")


func _vine(d: Dictionary) -> VineScreen:
	var s := VineScreen.new()
	add_child_autofree(s)
	s.open(d)
	return s


func test_esc_on_a_figure_goes_back_to_the_sky_and_does_not_leave() -> void:
	var s := _vine(_data(0, 0))
	var closed := []
	s.closed.connect(func() -> void: closed.append(true))
	s.zoom_in(&"vida")
	var esc := InputEventAction.new()
	esc.action = &"ui_cancel"
	esc.pressed = true
	s._unhandled_input(esc)
	assert_eq(s.zoomed, &"", "back to the sky")
	assert_eq(closed, [], "still in the Videira")


func test_vine_zoom_opens_on_the_figure_asked_and_stays() -> void:
	for fig in [&"vida", &"provisao", &"perseveranca"]:
		Dev.put("vine-zoom", String(fig))
		var s := _vine(_data(0, 0))
		await wait_process_frames(3)
		Dev.drop("vine-zoom")
		assert_eq(s.zoomed, fig, "open on %s" % fig)
		assert_eq(s.vine.find(s.shown).branch, fig)
