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

func test_the_screen_has_three_columns_of_three_with_name_effect_cost_and_state() -> void:
	var d := _data(100, 30)
	var s := _screen(d)
	assert_eq(s.cards.size(), 9)
	for branch in Vine.BRANCHES:
		var col := s.find_child(String(branch), true, false)
		assert_not_null(col, "a column for %s" % branch)
		assert_eq(col.get_children().filter(func(c: Node) -> bool: return c is Button).size(), 3)
	var first: Button = s.cards[&"vida_1"]
	assert_eq((first.find_child("name", true, false) as Label).text, T.t(&"vine_vida_1"))
	assert_eq((first.find_child("desc", true, false) as Label).text, T.t(&"vine_vida_1_desc"))
	var cost := first.find_child("cost", true, false) as MaterialCount
	assert_eq(cost.id, MaterialPurse.SILVER)
	assert_eq(cost.amount, 5)
	assert_eq((s.cards[&"viajante"].find_child("cost", true, false) as MaterialCount).id, MaterialPurse.MEMORY, "Provisão is paid in Memória")
	assert_eq((s.cards[&"vida_2"].find_child("state", true, false) as Label).text, T.t(&"vine_locked", {"a": T.t(&"vine_vida_1")}))
	assert_eq(T.t(&"vine_line"), "Raízes que fortalecem todas as jornadas")
	assert_eq((s.find_child("line", true, false) as Label).text, T.t(&"vine_line"))


func test_the_balance_shows_prata_and_memoria() -> void:
	var s := _screen(_data(42, 7))
	var purse := s.find_child("purse", true, false)
	assert_eq((purse.get_node("silver") as MaterialCount).amount, 42)
	assert_eq((purse.get_node("memory") as MaterialCount).amount, 7)


func test_buying_asks_first_then_spends_and_says_it() -> void:
	var d := _data(30, 0)
	var s := _screen(d)
	var heard := []
	s.bought.connect(func(id: StringName) -> void: heard.append(id))
	assert_false(s.select(&"vida_2"), "locked: no question")
	assert_false(s.select(&"viajante"), "short: no question")
	assert_eq(s.pending, &"")
	assert_true(s.select(&"vida_1"))
	assert_eq(s.pending, &"vida_1")
	assert_true(s.buy_button.visible and s.cancel_button.visible and not s.back_button.visible)
	assert_string_contains((s.find_child("info", true, false) as Label).text, T.t(&"vine_vida_1"))
	assert_string_contains((s.find_child("info", true, false) as Label).text, "5")
	assert_eq(MaterialPurse.amount(d, MaterialPurse.SILVER), 30, "nothing spent by asking")
	assert_true(s.confirm())
	assert_eq(heard, [&"vida_1"])
	assert_eq(MaterialPurse.amount(d, MaterialPurse.SILVER), 25)
	assert_eq(s.vine.state(d, &"vida_1"), Vine.State.OWNED)
	assert_eq((s.cards[&"vida_1"].find_child("state", true, false) as Label).text, T.t(&"vine_owned"))
	assert_eq(((s.find_child("purse", true, false)).get_node("silver") as MaterialCount).amount, 25, "the balance follows")
	assert_eq(s.vine.state(d, &"vida_2"), Vine.State.AVAILABLE, "the next node of the branch opens")
	assert_false(s.confirm(), "no question open")
	assert_true(s.back_button.visible and not s.buy_button.visible)


func test_cancelling_spends_nothing() -> void:
	var d := _data(30, 0)
	var s := _screen(d)
	s.select(&"vida_1")
	s.cancel()
	assert_eq(s.pending, &"")
	assert_eq(MaterialPurse.amount(d, MaterialPurse.SILVER), 30)
	assert_eq(s.vine.bought_count(d), 0)
	assert_false(s.confirm())


func test_a_short_root_is_marked_and_cannot_be_bought() -> void:
	var s := _screen(_data(3, 0))
	assert_eq((s.cards[&"vida_1"].find_child("state", true, false) as Label).text, T.t(&"vine_short"))
	assert_false(s.select(&"vida_1"))


func test_keys_and_the_mouse_reach_every_card_and_the_foot() -> void:
	var s := _screen(_data(50, 10))
	await wait_process_frames(3)
	assert_true((s.cards[&"vida_1"] as Button).has_focus(), "the first root that can be bought has the focus")
	for id: StringName in s.cards:
		assert_eq((s.cards[id] as Button).focus_mode, Control.FOCUS_ALL, "%s walkable" % id)
	var down := s.cards[&"vida_1"] as Button
	assert_eq(down.get_node(down.focus_neighbor_bottom), s.cards[&"vida_2"])
	assert_eq(down.get_node(down.focus_neighbor_right), s.cards[&"viajante"])
	var last := s.cards[&"vida_3"] as Button
	assert_eq(last.get_node(last.focus_neighbor_bottom), s.back_button, "down from the last row reaches Voltar")
	# a click on a card asks, the focus goes to Comprar; Cancelar goes back to the card; Voltar closes
	(s.cards[&"vida_1"] as Button).pressed.emit()
	await wait_process_frames(2)
	assert_eq(s.pending, &"vida_1")
	assert_true(s.buy_button.has_focus())
	var closed := [false]
	s.closed.connect(func() -> void: closed[0] = true)
	s.cancel()
	await wait_process_frames(2)
	assert_true((s.cards[&"vida_1"] as Button).has_focus(), "the focus goes back to the card")
	s.back_button.pressed.emit()
	assert_true(closed[0])


func test_it_fits_the_screen() -> void:
	var s := _screen(_data(50, 10))
	await wait_process_frames(3)
	var view := s.get_viewport().get_visible_rect().size
	var page := s.find_child("page", true, false) as Control
	assert_lte(page.get_global_rect().end.x, view.x, "inside across")
	assert_lte(page.get_global_rect().end.y, view.y - ActionBar.HEIGHT, "inside down, over the bar")
	for id: StringName in s.cards:
		var r := (s.cards[id] as Control).get_global_rect()
		assert_true(Rect2(Vector2.ZERO, view).encloses(r), "%s on the screen" % id)
		assert_gt(r.size.x, 150.0, "%s wide enough to read" % id)


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
