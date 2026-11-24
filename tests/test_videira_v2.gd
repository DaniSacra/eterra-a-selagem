extends GutTest
## A Videira, V2: its own station in the Santuário (HubPlan.VINE: place, sign, gate, guide) and its screen (VineScreen:
## three branches in columns, balance, buy with a question, keys and mouse); the Forjador is only the Forja again.

var hub: Hub
var _saved: Dictionary


func before_each() -> void:
	_saved = Save.data
	Save.data = SaveData.defaults()
	Controls.virtual = null
	Controls.clear_presses()


func after_each() -> void:
	Save.data = _saved
	Controls.clear_presses()


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


func _hub() -> Hub:
	hub = (load(SceneGo.HUB) as PackedScene).instantiate()
	add_child_autofree(hub)
	return hub


# ---------- the place ----------

func test_the_station_is_in_the_plan_and_off_every_other_piece() -> void:
	assert_true(HubPlan.STATIONS.has(HubPlan.VINE))
	var l := HubPlan.layout()
	assert_true(l.floor.contains(HubPlan.use_point(HubPlan.VINE), Player.RADIUS), "its use point on the floor")
	assert_true(HubPlan.ANCHOR.has(HubPlan.VINE) and HubPlan.SHOW.has(HubPlan.VINE))
	for other in HubPlan.STATIONS:
		if other != HubPlan.VINE:
			assert_gt(HubPlan.use_point(HubPlan.VINE).distance_to(HubPlan.use_point(other)), HubPlan.FOCUS_OUT * 2.0, "apart from %s" % other)
	var mine: ArenaObstacle
	for o in l.obstacles:
		if o.piece == &"hub_vine":
			mine = o
	assert_not_null(mine, "the arch blocks")
	assert_eq(_overlaps(l, mine), [], "no piece of the hub under the arch")
	assert_gt(HubPlan.USE[HubPlan.VINE].distance_to(HubPlan.VINE_ARCH), 1.0, "the use point stands before it")


## The pieces (blocking, bar the one itself) whose footprint touches `mine`'s, in the hub's own frame.
func _overlaps(l: RoomLayout, mine: ArenaObstacle) -> Array:
	var a := _rect(mine)
	var out := []
	for o in l.obstacles:
		if o != mine and o.blocks_move and a.intersects(_rect(o)):
			out.append(o.piece)
	return out


func _rect(o: ArenaObstacle) -> Rect2:
	var c := HubPlan.to_local(o.center)
	var h := Vector2(o.radius, o.radius) if o.shape == ArenaObstacle.Shape.CIRCLE else o.half
	return Rect2(c - h, h * 2.0)


# ---------- the gate and the guide ----------

func test_the_station_opens_where_the_forjadors_choice_did() -> void:
	var d := SaveData.defaults()
	assert_false(HubGate.is_open(d, HubPlan.VINE), "closed on a new save")
	SaveData.hero(d, SaveData.FIRST_HERO).firsts = {"guardian": 1}
	assert_true(HubGate.is_open(d, HubPlan.VINE), "the first guardian, as the Preparo's did")
	assert_eq(HubGate.is_open(d, HubPlan.VINE), Vine.open(d))
	var e := SaveData.defaults()
	e.vine.bought = ["vida_1"]
	assert_true(HubGate.is_open(e, HubPlan.VINE), "anything bought keeps it open")
	assert_true(HubGate.TEXT.has(HubPlan.VINE))


func test_the_guide_keeps_its_saved_id_and_points_at_the_station() -> void:
	var def: HubGuideDef
	for g in HubGuide.catalog():
		if g.id == &"account":
			def = g
	assert_not_null(def, "the id written in the saves stays")
	assert_eq(def.station, HubPlan.VINE)
	assert_eq(def.condition, &"account")
	assert_false(T.t(def.text_key).contains("Forjador"), "no word of the Forjador any more")
	var d := SaveData.defaults()
	HubGuide.mark_shown(d, [&"account"])
	SaveData.hero(d, SaveData.FIRST_HERO).firsts = {"guardian": 1}
	assert_false(HubGuide.pending(d).any(func(g: HubGuideDef) -> bool: return g.id == &"account"), "shown once only")


func test_the_forjador_is_only_the_forja_again() -> void:
	SaveData.hero(Save.data, SaveData.FIRST_HERO).firsts = {"guardian": 1}
	assert_true(Vine.open(Save.data))
	_hub()
	hub.use(HubPlan.SMITH)
	assert_true(hub.host.screen is ForgeScreen, "no choice between two things any more")
	assert_false(T.table.entries.has("vine_smith_forge"))


# ---------- the screen ----------

func test_the_nine_buds_stand_on_the_table_of_the_spec_with_a_tag_beside_each() -> void:
	var s := _screen(_data(100, 30))
	assert_eq(s.buds.size(), 11, "Vida has 5 steps since the redesign (Respiro, Ainda de Pé)")
	assert_eq(s.tags.size(), 11)
	var want := {&"vida_1": Vector2(395, 452), &"vida_3": Vector2(262, 288), &"viajante": Vector2(490, 390),
		&"reserva": Vector2(490, 160), &"prata": Vector2(590, 450), &"materiais": Vector2(760, 200)}
	for id: StringName in want:
		assert_lt(((s.buds[id] as Control).position + (s.buds[id] as Control).size * 0.5).distance_to(want[id]), 5.0, "%s on its place" % id)
	assert_eq((s.tags[&"estoque"] as Control).position, Vector2(512, 252))
	var all := []
	for id: StringName in s.tags:
		all.append(Rect2((s.tags[id] as Control).position, VineLayout.TAG_SIZE))
	for i in all.size():
		assert_false(VineScreen.PANEL_RECT.intersects(all[i]), "a tag clear of the panel")
		for j in range(i + 1, all.size()):
			assert_false((all[i] as Rect2).intersects(all[j]), "no tag over another")


func test_a_tag_says_the_name_and_the_price_in_the_right_material() -> void:
	var s := _screen(_data(100, 30))
	var tag := s.tags[&"viajante"] as VineTag
	assert_eq((tag.find_child("name", true, false) as Label).text, T.t(&"vine_viajante"))
	assert_eq(tag.cost.id, MaterialPurse.MEMORY, "Provisão is paid in Memória")
	assert_eq((s.tags[&"vida_1"] as VineTag).cost.amount, 5)


func test_the_panel_reads_what_it_does_what_it_costs_and_what_you_have() -> void:
	var s := _screen(_data(30, 2))
	assert_eq(s.shown, &"vida_1", "opens on the first root that can grow")
	assert_eq((s.find_child("name", true, false) as Label).text, T.t(&"vine_vida_1"))
	assert_eq((s.find_child("state", true, false) as Label).text, T.t(&"vine_can"))
	assert_string_contains((s.find_child("life", true, false) as RichTextLabel).text, "5", "the branch's life total")
	assert_eq((s.find_child("cost", true, false) as MaterialCount).amount, 5)
	assert_eq((s.find_child("have", true, false) as Label).text, T.t(&"vine_have", {"n": 30}))
	assert_true(s.water_button.text.contains("Regar") and s.water_button.text.contains("5"), "the price on the button")
	s._show(&"viajante")
	assert_eq((s.find_child("state", true, false) as Label).text, T.t(&"vine_short_n", {"n": 1, "m": "Memória"}))
	assert_eq((s.find_child("have", true, false) as Label).text, T.t(&"vine_have", {"n": 2}))
	assert_true(s.water_button.disabled)
	assert_eq(s.water_button.text, T.t(&"vine_short_n", {"n": 1, "m": "Memória"}), "the reason in place of the verb")
	s._show(&"vida_2")
	assert_eq((s.find_child("state", true, false) as Label).text, T.t(&"vine_locked", {"a": T.t(&"vine_vida_1")}))
	assert_string_contains((s.find_child("life", true, false) as RichTextLabel).text, "10", "Seiva and Caule together")


func test_watering_asks_nothing_spends_once_and_grows_the_plant() -> void:
	var d := _data(30, 0)
	var s := _screen(d)
	var heard := []
	s.bought.connect(func(id: StringName) -> void: heard.append(id))
	assert_false(s.select(&"vida_2"), "locked: stays")
	assert_false(s.select(&"viajante"), "short: stays")
	assert_eq(s.pending, &"")
	assert_true(s.select(&"vida_1"))
	assert_eq(s.pending, &"vida_1")
	assert_eq(MaterialPurse.amount(d, MaterialPurse.SILVER), 30, "nothing spent by choosing")
	assert_true(s.confirm())
	assert_false(s.confirm(), "a second Regar spends nothing")
	assert_eq(heard, [&"vida_1"])
	assert_eq(MaterialPurse.amount(d, MaterialPurse.SILVER), 25)
	assert_eq(s.vine.state(d, &"vida_1"), Vine.State.OWNED)
	assert_eq((s.find_child("state", true, false) as Label).text, T.t(&"vine_owned"))
	assert_eq(T.t(&"vine_owned"), "Já cresceu")
	assert_true((s.tags[&"vida_1"] as VineTag).owned, "the tag turned over")
	assert_eq(s.plant.states[&"vida_1"], Vine.State.OWNED)
	assert_eq(((s.find_child("purse", true, false)).get_node("silver") as MaterialCount).amount, 25, "the balance follows")
	assert_eq(s.vine.state(d, &"vida_2"), Vine.State.AVAILABLE, "the next root of the branch opens")
	assert_string_contains((s.find_child("count", true, false) as Label).text, "1")


func test_going_back_from_regar_spends_nothing() -> void:
	var d := _data(30, 0)
	var s := _screen(d)
	s.select(&"vida_1")
	s.cancel()
	assert_eq(s.pending, &"")
	assert_eq(MaterialPurse.amount(d, MaterialPurse.SILVER), 30)
	assert_eq(s.vine.bought_count(d), 0)
	assert_false(s.confirm())


func test_the_balance_shows_prata_and_memoria() -> void:
	var s := _screen(_data(42, 7))
	var purse := s.find_child("purse", true, false)
	assert_eq((purse.get_node("silver") as MaterialCount).amount, 42)
	assert_eq((purse.get_node("memory") as MaterialCount).amount, 7)


func test_keys_and_the_mouse_walk_the_buds_and_reach_regar() -> void:
	var s := _screen(_data(50, 10))
	await wait_process_frames(3)
	assert_true((s.buds[&"vida_1"] as Button).has_focus(), "the first root that can grow has the focus")
	for id: StringName in s.buds:
		assert_eq((s.buds[id] as Button).focus_mode, Control.FOCUS_ALL, "%s walkable" % id)
	var b := s.buds[&"vida_1"] as Button
	assert_eq(b.get_node(b.focus_neighbor_top), s.buds[&"vida_2"], "up grows")
	assert_eq(b.get_node(b.focus_neighbor_right), s.buds[&"viajante"], "right passes to the next branch on the same step")
	# a click on a bud that can grow sends the focus to Regar; cancel goes back to the bud
	(s.buds[&"vida_1"] as Button).pressed.emit()
	await wait_process_frames(2)
	assert_eq(s.pending, &"vida_1")
	assert_true(s.water_button.has_focus())
	s.cancel()
	await wait_process_frames(2)
	assert_true((s.buds[&"vida_1"] as Button).has_focus(), "the focus goes back to the bud")
	assert_eq(s.pending, &"")


func test_from_the_last_branch_the_right_arrow_reaches_regar() -> void:
	var s := _screen(_data(50, 10))
	await wait_process_frames(2)
	s._show(&"prata")
	assert_false(s.water_button.disabled)
	var b := s.buds[&"prata"] as Button
	assert_eq(b.get_node(b.focus_neighbor_right), s.water_button)
	assert_eq(s.water_button.get_node(s.water_button.focus_neighbor_left), b)


func test_it_fits_the_screen_and_reads_without_scrolling() -> void:
	var s := _screen(_data(50, 10))
	await wait_process_frames(3)
	var view := s.get_viewport().get_visible_rect().size
	var stage := s.find_child("stage", true, false) as Control
	assert_true(Rect2(Vector2.ZERO, view).encloses(Rect2(stage.global_position, stage.size * stage.scale)), "the stage inside the window")
	var panel := s.find_child("panel", true, false) as Control
	assert_gte(panel.size.y, panel.get_combined_minimum_size().y, "the panel holds all its lines")


# ---------- the layout and the numbers ----------

func test_the_focus_walks_up_to_grow_and_across_to_the_next_branch() -> void:
	var v := Vine.new(Vine.load_catalog())
	assert_eq(VineLayout.neighbor(v, &"vida_1", Vector2.UP), &"vida_2")
	assert_eq(VineLayout.neighbor(v, &"vida_3", Vector2.UP), &"respiro", "Vida goes on to its 4th step")
	assert_eq(VineLayout.neighbor(v, &"ainda_de_pe", Vector2.UP), &"ainda_de_pe", "the top stays")
	assert_eq(VineLayout.neighbor(v, &"vida_1", Vector2.DOWN), &"vida_1")
	assert_eq(VineLayout.neighbor(v, &"vida_2", Vector2.RIGHT), &"estoque")
	assert_eq(VineLayout.neighbor(v, &"memoria", Vector2.LEFT), &"estoque")
	assert_eq(VineLayout.neighbor(v, &"vida_2", Vector2.LEFT), &"vida_2", "no branch to the left of Vida")
	assert_eq(VineLayout.neighbor(v, &"materiais", Vector2.RIGHT), &"materiais")


func test_the_first_focus_is_the_lowest_root_that_can_grow() -> void:
	var v := Vine.new(Vine.load_catalog())
	assert_eq(VineLayout.first_focus(v, _data(0, 0)), &"vida_1", "nothing can grow: Seiva")
	var d := _data(30, 10)
	d.vine.bought = ["vida_1", "vida_2"]
	assert_eq(VineLayout.first_focus(v, d), &"viajante", "the first rows come before Vida's third")


func test_a_branch_path_passes_through_its_buds() -> void:
	for b in Vine.BRANCHES:
		var pts := VineLayout.path(b)
		assert_eq(pts[0], VineLayout.FORK)
		for step in range(1, (VineLayout.BUD[b] as Array).size() + 1):
			assert_lt(pts[step * VineLayout.SAMPLES].distance_to(VineLayout.bud(b, step)), 0.01)
		var hull := Rect2(VineLayout.FORK, Vector2.ZERO)
		for step in range(1, (VineLayout.BUD[b] as Array).size() + 1):
			hull = hull.expand(VineLayout.bud(b, step))
		for p in pts:
			assert_true(hull.grow(45.0).has_point(p), "%s does not run past its buds" % b)


func test_the_life_total_and_what_is_missing_come_from_the_data() -> void:
	var v := Vine.new(Vine.load_catalog())
	assert_eq(v.life_total(&"vida_1"), 5)
	assert_eq(v.life_total(&"vida_3"), 15)
	assert_eq(v.life_total(&"prata"), 0, "only Vida gives life")
	assert_eq(v.missing(_data(3, 0), &"vida_1"), 2)
	assert_eq(v.missing(_data(30, 0), &"vida_1"), 0)


# ---------- the hub ----------

func test_the_station_opens_the_screen_and_the_planting_follows_the_purchases() -> void:
	SaveData.hero(Save.data, SaveData.FIRST_HERO).firsts = {"guardian": 1}
	MaterialPurse.give(Save.data, MaterialPurse.SILVER, 100)
	_hub()
	assert_not_null(hub.arena.look.vine_station, "the station stands in the hub")
	assert_eq(hub.arena.look.vine_station.stages_shown(), 0)
	hub.player.pos = HubPlan.use_point(HubPlan.VINE)
	await wait_process_frames(3)
	assert_eq(hub.focus.current, HubPlan.VINE, "walking up to it brings its sign")
	hub.use(HubPlan.VINE)
	var s := hub.host.screen as VineScreen
	assert_not_null(s)
	s.select(&"vida_1")
	s.confirm()
	assert_eq(hub.arena.look.vine_station.stages_shown(), 1, "one node bought, one stage grown")
	assert_eq(Vine.growth(Save.data), {&"vida": 1, &"provisao": 0, &"perseveranca": 0})


func test_the_planting_shows_the_stages_bought_and_only_those() -> void:
	var holder := Node3D.new()
	add_child_autofree(holder)
	var v := VineStation.make(holder, Vector3.ZERO)
	assert_eq(v.name, "VineStation")
	assert_eq(v.stages_shown(), 0)
	v.grown({&"vida": 2, &"provisao": 0, &"perseveranca": 3})
	assert_eq(v.stages_shown(), 5)
	v.grown({&"vida": 9, &"provisao": -1})
	assert_eq(v.stages_shown(), 3, "clamped to the three stages of a branch")
	v.grown({})
	assert_eq(v.stages_shown(), 0)


func test_vida_has_places_for_five_steps_inside_the_stage_and_clear_of_each_other() -> void:
	assert_eq((VineLayout.BUD[&"vida"] as Array).size(), 5, "Respiro and Ainda de Pé are steps 4 and 5 of Vida")
	var tags: Array[Rect2] = []
	for b in VineLayout.BUD:
		assert_eq((VineLayout.TAG[b] as Array).size(), (VineLayout.BUD[b] as Array).size(), "a tag for each bud")
		for step in range(1, (VineLayout.BUD[b] as Array).size() + 1):
			var r := Rect2(VineLayout.tag(b, step), VineLayout.TAG_SIZE)
			assert_true(Rect2(Vector2.ZERO, VineLayout.STAGE).encloses(r), "%s %d tag inside the stage" % [b, step])
			assert_false(VineScreen.PANEL_RECT.intersects(r), "%s %d tag clear of the panel" % [b, step])
			for o in tags:
				assert_false(o.intersects(r), "%s %d tag over another" % [b, step])
			tags.append(r)
		assert_gt(VineLayout.NAME_AT[b].y, 40.0, "the name stays under the stage's top")


func test_a_path_is_only_as_long_as_the_nodes_it_has() -> void:
	assert_eq(VineLayout.path(&"vida", 3).size(), 3 * VineLayout.SAMPLES + 1)
	assert_eq(VineLayout.path(&"vida").size(), 5 * VineLayout.SAMPLES + 1)
	assert_eq(VineLayout.path(&"vida", 9).size(), 5 * VineLayout.SAMPLES + 1, "no more than the places")
