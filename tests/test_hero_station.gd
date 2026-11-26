extends GutTest
## PT-9: the Maga is locked until Morvath was sealed once, and the hero's pick left the Portal for a station of its own
## beside the Vendedor (HubPlan.HEROES, HeroPickScreen), with its guide when the Maga opens.

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


func _screen(d: Dictionary) -> HeroPickScreen:
	var s := HeroPickScreen.new()
	add_child_autofree(s)
	s.open(d)
	return s


func _hub() -> Hub:
	hub = (load(SceneGo.HUB) as PackedScene).instantiate()
	add_child_autofree(hub)
	return hub


func _rect(o: ArenaObstacle) -> Rect2:
	var c := HubPlan.to_local(o.center)
	var h := Vector2(o.radius, o.radius) if o.shape == ArenaObstacle.Shape.CIRCLE else o.half
	return Rect2(c - h, h * 2.0)


# ---------- the Maga's lock ----------

func test_the_maga_is_locked_until_the_first_morvath_sealed() -> void:
	var d := SaveData.defaults()
	assert_true(SaveData.hero_open(d, "warrior"))
	assert_false(SaveData.hero_open(d, "maga"))
	assert_eq(SaveData.open_heroes(d), ["warrior"])
	d.hero = "maga"
	assert_eq(SaveData.picked_hero(d), "warrior", "a Maga picked before the lock reads as the Warrior")
	d.wins = 1
	assert_true(SaveData.hero_open(d, "maga"))
	assert_eq(SaveData.picked_hero(d), "maga")
	assert_eq(SaveData.open_heroes(d), ["warrior", "maga"])


func test_the_game_plays_the_warrior_while_she_is_locked() -> void:
	Save.data.hero = "maga"
	assert_eq(SaveData.picked_hero(Save.data), "warrior")


# ---------- the place ----------

func test_the_station_is_in_the_upper_gallery_and_off_every_other_piece() -> void:
	assert_true(HubPlan.STATIONS.has(HubPlan.HEROES))
	var l := HubPlan.layout()
	assert_true(l.floor.contains(HubPlan.use_point(HubPlan.HEROES), Player.RADIUS))
	assert_lt(HubPlan.USE[HubPlan.HEROES].distance_to(HubPlan.USE[HubPlan.VENDOR]), 20.0, "in the stall's quarter: the upper gallery (SV-R)")
	for other in HubPlan.STATIONS:
		if other != HubPlan.HEROES:
			assert_gt(HubPlan.use_point(HubPlan.HEROES).distance_to(HubPlan.use_point(other)), HubPlan.FOCUS_OUT * 2.0, "apart from %s" % other)
	var mine: ArenaObstacle
	var vine: ArenaObstacle
	for o in l.obstacles:
		if o.piece == &"hub_heroes":
			mine = o
		elif o.piece == &"hub_vine":
			vine = o
	assert_not_null(mine)
	var a := _rect(mine)
	for o in l.obstacles:
		if o != mine and o.blocks_move:
			assert_false(a.intersects(_rect(o)), "%s off the standards" % o.piece)
	assert_false(_rect(vine).intersects(a), "and off the Videira")


func test_the_station_opens_after_the_first_victory() -> void:
	var d := SaveData.defaults()
	assert_false(HubGate.is_open(d, HubPlan.HEROES))
	d.runs = 5
	assert_false(HubGate.is_open(d, HubPlan.HEROES), "SW-O5: not with the Vendedor, only after the first victory")
	var w := SaveData.defaults()
	w.wins = 1
	assert_true(HubGate.is_open(w, HubPlan.HEROES), "and for a save that sealed Morvath")
	assert_true(HubGate.TEXT.has(HubPlan.HEROES))
	assert_ne(T.t(HubGate.TEXT[HubPlan.HEROES]), String(HubGate.TEXT[HubPlan.HEROES]))


func test_the_guide_comes_when_the_maga_opens() -> void:
	var def: HubGuideDef
	for g in HubGuide.catalog():
		if g.id == &"maga":
			def = g
	assert_not_null(def)
	assert_eq(def.station, HubPlan.HEROES)
	assert_true(HubGuide.CONDITIONS.has(def.condition))
	var d := SaveData.defaults()
	assert_false(HubGuide.due(d, def), "locked: no guide")
	d.wins = 1
	assert_true(HubGuide.due(d, def))
	HubGuide.mark_shown(d, [&"maga"])
	assert_false(HubGuide.pending(d).any(func(g: HubGuideDef) -> bool: return g.id == &"maga"), "once")


# ---------- the screen ----------

func test_the_screen_shows_the_maga_behind_a_padlock_with_what_frees_her() -> void:
	var s := _screen(SaveData.defaults())
	assert_eq(s.cards.keys(), ["warrior", "maga"])
	var maga: Button = s.cards["maga"]
	assert_not_null(maga.find_child("lock", true, false), "the padlock")
	assert_eq((maga.find_child("why", true, false) as Label).text, T.t(&"heroes_maga_lock"))
	assert_eq((maga.find_child("state", true, false) as Label).text, T.t(&"heroes_locked"))
	assert_null((s.cards["warrior"] as Button).find_child("lock", true, false))
	assert_eq(((s.cards["warrior"] as Button).find_child("state", true, false) as Label).text, T.t(&"heroes_picked"))
	assert_false(T.t(&"heroes_maga_lock").contains("—"))


func test_a_locked_maga_cannot_be_picked_and_an_open_one_can() -> void:
	var d := SaveData.defaults()
	var s := _screen(d)
	var heard := []
	s.picked.connect(func(id: String) -> void: heard.append(id))
	assert_false(s.pick("maga"))
	(s.cards["maga"] as Button).pressed.emit()
	assert_eq(SaveData.picked_hero(d), "warrior")
	assert_eq(heard, [])
	d.wins = 1
	var open := _screen(d)
	open.picked.connect(func(id: String) -> void: heard.append(id))
	assert_null((open.cards["maga"] as Button).find_child("lock", true, false), "no padlock once Morvath was sealed")
	assert_true(open.pick("maga"))
	assert_eq(d.hero, "maga", "kept in the save for the next descent")
	assert_eq(heard, ["maga"])
	assert_eq(((open.cards["maga"] as Button).find_child("state", true, false) as Label).text, T.t(&"heroes_picked"))
	assert_true(open.pick("warrior"))
	assert_eq(SaveData.picked_hero(d), "warrior")


func test_keys_walk_between_the_heroes_and_it_fits_the_screen() -> void:
	var d := SaveData.defaults()
	d.wins = 1
	var s := _screen(d)
	await wait_process_frames(3)
	assert_true((s.cards["warrior"] as Button).has_focus(), "the picked one has the focus")
	var w := s.cards["warrior"] as Button
	assert_eq(w.get_node(w.focus_neighbor_right), s.cards["maga"])
	assert_eq(w.get_node(w.focus_neighbor_bottom), s.back_button)
	var view := s.get_viewport().get_visible_rect()
	for id: String in s.cards:
		assert_true(view.encloses((s.cards[id] as Control).get_global_rect()), "%s inside the screen" % id)


# ---------- the hub ----------

func test_the_hub_uses_the_station_and_the_portal_no_longer_picks() -> void:
	Save.data.wins = 1
	_hub()
	assert_not_null(hub.arena.look.hero_station)
	hub.use(HubPlan.HEROES)
	var s := hub.host.screen as HeroPickScreen
	assert_not_null(s)
	s.pick("maga")
	assert_eq(Save.data.hero, "maga")
	hub.host.close()
	hub.use(HubPlan.PORTAL)
	assert_null(hub.host.screen.find_child("hero", true, false), "no hero button at the Portal")
	assert_eq(hub.host.screen.find_child("line", true, false).text, T.t(&"hub_descend_line_maga"))


func test_the_standards_dim_the_locked_maga() -> void:
	var holder := Node3D.new()
	add_child_autofree(holder)
	var st := HeroStation.make(holder, Vector3.ZERO)
	assert_eq((st.cloths["maga"].material_override as StandardMaterial3D).albedo_color, HeroStation.LOCKED)
	var d := SaveData.defaults()
	d.wins = 1
	st.refresh(d)
	assert_eq((st.cloths["maga"].material_override as StandardMaterial3D).albedo_color, HeroStation.COLORS["maga"])
