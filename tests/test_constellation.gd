extends GutTest
## SW-M1 to SW-M3 (Fase 5): the constellation map. The camera's zoom (SkyCamera), the star scatter (StarField), the tip of a
## node (NodeTip: real numbers now and next, price, what comes first), the Videira's zoom by key, click, wheel and back,
## the Dons on a night sky, and the wallet in the top right corner of the Livro.

var _saved: Dictionary


func before_each() -> void:
	_saved = Save.data
	Save.data = SaveData.defaults()


func after_each() -> void:
	Save.data = _saved


func _data(silver := 0, memory := 0) -> Dictionary:
	var d := SaveData.defaults()
	MaterialPurse.give(d, MaterialPurse.SILVER, silver)
	MaterialPurse.give(d, MaterialPurse.MEMORY, memory)
	return d


func _screen(d: Dictionary) -> VineScreen:
	var s := VineScreen.new()
	add_child_autofree(s)
	s.open(d)
	return s


# ---------- the camera ----------

func test_the_camera_rests_as_the_identity_and_maps_both_ways() -> void:
	var cam := VineLayout.sky_camera()
	assert_eq(cam.to_screen(Vector2(100, 200)), Vector2(100, 200))
	cam.close_on(Vector2(400, 410), VineLayout.READ_AT)
	cam.snap()
	assert_eq(cam.to_screen(Vector2(400, 410)), VineLayout.READ_AT, "the figure's centre lands where the panel leaves room")
	assert_eq(cam.zoom, SkyCamera.ZOOM_IN)
	var w := Vector2(432, 377)
	assert_lt(cam.to_world(cam.to_screen(w)).distance_to(w), 0.001)


func test_the_zoom_slides_smoothly_and_settles_without_overshoot() -> void:
	var cam := VineLayout.sky_camera()
	VineLayout.close_on(cam, &"vida")
	assert_true(cam.closed_in())
	var last := cam.zoom
	for i in 120:
		cam.step(1.0 / 60.0)
		assert_gte(cam.zoom, last - 0.0001, "only closes in")
		assert_lte(cam.zoom, SkyCamera.ZOOM_IN + 0.0001, "never past the target")
		last = cam.zoom
	assert_true(cam.settled(), "settled in 2 seconds")
	assert_almost_eq(cam.progress(), 1.0, 0.001)
	cam.open_out()
	for i in 120:
		cam.step(1.0 / 60.0)
	assert_true(cam.settled())
	assert_almost_eq(cam.progress(), 0.0, 0.001)
	assert_false(cam.closed_in())


func test_the_wheel_zooms_by_notches_inside_the_limits() -> void:
	var cam := VineLayout.sky_camera()
	cam.close_on(Vector2(640, 285), VineLayout.READ_AT)
	cam.wheel(1)
	assert_gt(cam.target_zoom, SkyCamera.ZOOM_IN)
	for i in 30:
		cam.wheel(1)
	assert_eq(cam.target_zoom, SkyCamera.ZOOM_MAX)
	for i in 60:
		cam.wheel(-1)
	assert_eq(cam.target_zoom, SkyCamera.ZOOM_MIN)


# ---------- the sky ----------

func test_the_star_scatter_is_the_same_for_a_seed_and_stays_on_the_screen() -> void:
	var a := StarField.make(7, 100)
	var b := StarField.make(7, 100)
	assert_eq(a.size(), 100)
	assert_eq(a, b, "same seed, same sky")
	assert_ne(a, StarField.make(8, 100))
	for st in a:
		assert_true(Rect2(0, 0, 1, 1).has_point(st.p))
		assert_gte(st.depth, StarField.FAR)
		assert_gt(st.r, 0.0)


# ---------- the tip of a node ----------

func test_the_tip_says_now_and_next_with_the_real_numbers() -> void:
	var v := Vine.new(Vine.load_catalog())
	var d := _data(30, 0)
	var t := NodeTip.of_vine(v, d, &"vida_1")
	assert_true(t.has_values)
	assert_eq([t.now_text(), t.next_text()], ["+0", "+5"])
	t = NodeTip.of_vine(v, d, &"vida_2")
	assert_eq([t.now_text(), t.next_text()], ["+0", "+10"], "a locked node shows the total once the way is open")
	d.vine.bought = ["vida_1"]
	t = NodeTip.of_vine(v, d, &"vida_2")
	assert_eq([t.now_text(), t.next_text()], ["+5", "+10"], "adds to what the branch already gives")
	d.vine.bought = ["vida_1", "vida_2"]
	assert_eq(NodeTip.of_vine(v, d, &"vida_3").next_text(), "+15")


func test_the_tip_reads_shares_as_percent_and_switches_without_numbers() -> void:
	var v := Vine.new(Vine.load_catalog())
	var d := _data(30, 10)
	var silver := NodeTip.of_vine(v, d, &"prata")
	assert_eq([silver.now_text(), silver.next_text()], ["+0%", "+25%"], "the data's 0,25 reads 25%")
	assert_false(NodeTip.of_vine(v, d, &"viajante").has_values, "a merchant is a switch, not a number")
	var rise := NodeTip.of_vine(v, d, &"ainda_de_pe")
	assert_eq(rise.next_text(), "+50%")


func test_an_owned_node_has_nothing_next() -> void:
	var v := Vine.new(Vine.load_catalog())
	var d := _data(30, 0)
	d.vine.bought = ["vida_1"]
	var t := NodeTip.of_vine(v, d, &"vida_1")
	assert_eq(t.now_text(), t.next_text())
	assert_eq(t.state, Vine.State.OWNED)


func test_the_tip_has_the_price_what_you_have_and_what_comes_first() -> void:
	var v := Vine.new(Vine.load_catalog())
	var d := _data(7, 2)
	var t := NodeTip.of_vine(v, d, &"vida_2")
	assert_eq(t.cost, 10)
	assert_eq(t.material, MaterialPurse.SILVER)
	assert_eq(t.have, 7)
	assert_eq(t.needs, &"vine_vida_1", "open the one before first")
	assert_eq(t.state, Vine.State.LOCKED)
	var first := NodeTip.of_vine(v, d, &"vida_1")
	assert_eq(first.needs, &"", "the first of a branch asks for none")
	assert_eq(first.state, Vine.State.AVAILABLE)
	var memory := NodeTip.of_vine(v, d, &"viajante")
	assert_eq(memory.material, MaterialPurse.MEMORY)
	assert_eq(memory.have, 2)
	assert_eq(memory.missing, 1)


func test_the_tip_of_an_unknown_node_is_empty() -> void:
	var t := NodeTip.of_vine(Vine.new(Vine.load_catalog()), _data(), &"nope")
	assert_eq(t.id, &"")
	assert_false(t.has_values)


# ---------- the Videira's map ----------

func test_the_map_opens_on_the_whole_sky_and_a_figure_closes_the_camera_on_it() -> void:
	var s := _screen(_data(30, 5))
	assert_eq(s.zoomed, &"")
	assert_false(s.cam.closed_in())
	assert_false((s.find_child("panel", true, false) as Control).visible, "no panel in the whole sky")
	assert_eq((s.find_child("line", true, false) as Label).text, T.t(&"vine_pick"))
	s.zoom_in(&"provisao")
	assert_eq(s.zoomed, &"provisao")
	assert_eq(s.cam.target_center, VineLayout.center(&"provisao"))
	assert_true((s.find_child("panel", true, false) as Control).visible)
	assert_eq((s.find_child("line", true, false) as Label).text, T.t(&"vine_line"))
	s.zoom_out()
	assert_eq(s.zoomed, &"")
	assert_eq(s.cam.target_zoom, SkyCamera.ZOOM_OUT)


func test_back_and_the_wheel_walk_the_zoom_and_close_only_from_the_sky() -> void:
	var s := _screen(_data(30, 5))
	var closed := []
	s.closed.connect(func() -> void: closed.append(true))
	s.wheel_zoom(1)
	assert_eq(s.zoomed, &"vida", "the wheel closes on the focused star's figure")
	s.wheel_zoom(1)
	assert_gt(s.cam.target_zoom, SkyCamera.ZOOM_IN, "and goes on closer")
	s._back()
	assert_eq(s.zoomed, &"", "back opens out")
	assert_eq(closed, [], "and does not leave")
	s.zoom_in(&"vida")
	s.wheel_zoom(-1)
	assert_eq(s.zoomed, &"", "the wheel out reaches the whole sky")
	s._back()
	assert_eq(closed.size(), 1, "back from the whole sky leaves")


func test_the_focus_passing_to_another_figure_takes_the_camera_along() -> void:
	var s := _screen(_data(30, 5))
	s.zoom_in(&"vida")
	s._show(&"estoque")
	assert_eq(s.zoomed, &"provisao")
	assert_eq(s.cam.target_center, VineLayout.center(&"provisao"))


func test_the_accept_chip_opens_a_figure_from_the_sky() -> void:
	var s := _screen(_data(30, 5))
	assert_eq(s.bar.item(&"ui_accept").verb.text, T.t(&"vine_open_figure").to_upper())
	s.zoom_in(&"vida")
	assert_eq(s.bar.item(&"ui_accept").verb.text, T.t(&"bar_water").to_upper())


func test_the_tip_panel_names_the_price_with_its_icon_and_what_you_have() -> void:
	var s := _screen(_data(7, 2))
	s.zoom_in(&"vida")
	s._show(&"vida_2")
	var cost := s._cost
	assert_eq(cost.amount, 10)
	assert_not_null(cost.mark, "the material's icon")
	assert_eq(s._have.text, T.t(&"vine_have", {"n": 7}))
	assert_eq(s.water_button.text, T.t(&"vine_locked", {"a": ""}), "Abra o anterior primeiro")
	assert_eq(T.t(&"vine_locked"), "Abra o anterior primeiro")
	assert_string_contains((s.find_child("values", true, false) as RichTextLabel).text, "+10")


func test_the_figures_light_up_with_what_is_grown() -> void:
	var d := _data(30, 0)
	var s := _screen(d)
	s.select(&"vida_1")
	assert_eq(s.zoomed, &"vida", "choosing a star that can grow opens its figure")
	s.confirm()
	assert_eq(s.sky.states[&"vida_1"], Vine.State.OWNED)
	assert_eq(s.sky.bloom_id, &"vida_1")


func test_no_text_of_the_sky_is_a_missing_key() -> void:
	for key: StringName in [&"vine_pick", &"vine_open_figure", &"vine_needs", &"vine_tip_values", &"dons_cost_free"]:
		assert_ne(T.t(key), String(key))
		assert_false(T.t(key).contains("—"), "no long dash in %s" % key)


# ---------- the Dons and the Livro ----------

func test_the_dons_stand_on_the_night_sky() -> void:
	var s := DonsScreen.new()
	add_child_autofree(s)
	s.open(SaveData.defaults(), "warrior")
	assert_true(s.find_child("ground", true, false) is SkyGround)


func test_a_dom_that_costs_devotion_says_how_many_are_free() -> void:
	var d := SaveData.defaults()
	SaveData.hero(d, "warrior").mastery_xp = 3000
	var s := DonsScreen.new()
	add_child_autofree(s)
	s.open(d, "warrior")
	for n in s.view.def.nodes:
		if n.kind == MedallionNodeDef.Kind.GIFT and s.loadout.state(s.view.nav.talent(n.id)) == HeroLoadout.State.OPEN:
			var info := s._gift_info(n.id, n)
			assert_eq(info.cost_right, T.t(&"dons_cost_free", {"n": s.loadout.devotion() - s.loadout.used()}))
			return
	pending("no open Dom in this save")


func test_the_livro_keeps_the_wallet_in_the_top_right_corner() -> void:
	var book := HeroScreen.new()
	add_child_autofree(book)
	book.open(_data(3, 4), HeroScreen.Chapter.HERO)
	var plate := book.find_child("wallet_plate", true, false) as Control
	assert_not_null(plate)
	assert_eq(plate.anchor_right, 1.0)
	assert_eq(plate.anchor_top, 0.0)
	assert_not_null(plate.find_child("coins", true, false))
	assert_eq(plate.find_children("*", "MaterialCount", true, false).size(), 3)
