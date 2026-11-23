extends GutTest
## The Maga's Gift tree as a triangle on the Livro de Ahk (M2, docs/design/heroes/maga_m2.md section 6): three branches at 120
## degrees, 23 nodes, the apex cycle, keys and pad; and the Warrior's diamond unchanged.

const XP_MAX := 5000


func _data(hero: String, xp: int, equipped: Array = []) -> Dictionary:
	var d := SaveData.defaults()
	d["wins"] = 1
	d["hero"] = hero
	var block := SaveData.hero(d, hero)
	block.mastery_xp = xp
	SaveData.open_revealed(block)
	block.equipped = equipped
	return d


func _screen(data: Dictionary) -> HeroScreen:
	var s := HeroScreen.new()
	add_child_autofree(s)
	s.open(data, HeroScreen.Chapter.GIFTS)
	return s


func test_it_opens_with_the_maga_and_draws_23_nodes_in_a_triangle() -> void:
	var s := _screen(_data("maga", XP_MAX))
	assert_eq(s.loadout.hero.id, &"maga")
	assert_true(s.tree.triangle)
	assert_eq(s.tree.nodes.size(), 23)
	assert_ne(T.t(s.loadout.hero.name_key), String(s.loadout.hero.name_key))


func test_the_three_branches_sit_120_degrees_apart_and_no_node_overlaps() -> void:
	var s := _screen(_data("maga", XP_MAX))
	var apex: Array[Vector2] = []
	var spots: Array[Vector2] = []
	for n in s.tree.nodes:
		var at: Vector2 = n.get_meta(&"at")
		assert_lte(absf(at.x), TalentTree.HALF.x + 30.0, str(n.def.id))
		assert_lte(absf(at.y), TalentTree.HALF.y + 30.0, str(n.def.id))
		for o in spots:
			assert_gt(at.distance_to(o), TalentNode.SIDE + 4.0, "%s overlaps" % n.def.id)
		spots.append(at)
		if n.def.tier == TalentDef.Tier.APEX:
			apex.append(at)
	assert_eq(apex.size(), 3)
	for i in 3:
		var a := apex[i].normalized()
		var b := apex[(i + 1) % 3].normalized()
		assert_almost_eq(absf(rad_to_deg(a.angle_to(b))), 120.0, 2.0)


func test_each_branch_has_its_own_colour_and_glyph() -> void:
	var seen := {}
	for b in [TalentDef.Branch.PIRO, TalentDef.Branch.ARCA, TalentDef.Branch.CTRL]:
		seen[TalentNode.BRANCH_COLOR[b]] = true
		seen[TalentNode.glyph_of(b)] = true
		assert_ne(T.t(HeroLoadout.BRANCH_KEY[b]), String(HeroLoadout.BRANCH_KEY[b]))
		var c: Color = TalentNode.BRANCH_COLOR[b]
		assert_lt(c.b, maxf(c.r, c.g) + 0.001, "amber and ivory, not violet")
	assert_eq(seen.size(), 6)


func test_the_apexes_close_a_cycle() -> void:
	var s := _screen(_data("maga", XP_MAX))
	var to := {}
	for n in s.tree.nodes:
		if n.def.tier == TalentDef.Tier.APEX:
			to[n.def.branch] = n.def.partner
	assert_eq(to, {TalentDef.Branch.PIRO: TalentDef.Branch.ARCA, TalentDef.Branch.ARCA: TalentDef.Branch.CTRL,
		TalentDef.Branch.CTRL: TalentDef.Branch.PIRO})


func test_keys_walk_the_triangle_and_the_panel_tells_cost_and_effect() -> void:
	var s := _screen(_data("maga", XP_MAX))
	var start := s.tree.node(&"brasa_viva")
	start.grab_focus()
	var next := start.find_valid_focus_neighbor(SIDE_BOTTOM)
	assert_true(next is TalentNode, "the pad leaves the first node")
	assert_ne(next, start)
	var seen := {}
	var cur: Control = s.tree.centre
	cur.grab_focus()
	for side in [SIDE_TOP, SIDE_RIGHT, SIDE_BOTTOM, SIDE_LEFT]:
		var n := cur.find_valid_focus_neighbor(side)
		if n is TalentNode:
			seen[n.name] = true
	assert_gt(seen.size(), 1)
	start.grab_focus()
	assert_ne(s._desc.text, "")
	assert_ne(s._cost.text, "")


func test_a_gift_is_bought_and_taken_off_with_the_press() -> void:
	var s := _screen(_data("maga", XP_MAX))
	s.tree.node(&"brasa_viva").pressed.emit()
	assert_true(s.loadout.is_equipped(&"brasa_viva"))
	assert_eq(s.tree.node(&"brasa_viva").state, HeroLoadout.State.EQUIPPED)
	s.tree.node(&"brasa_viva").pressed.emit()
	assert_false(s.loadout.is_equipped(&"brasa_viva"))


func test_a_locked_gift_refuses() -> void:
	var s := _screen(_data("maga", 0))
	s.tree.node(&"inferno_runico").pressed.emit()
	assert_false(s.loadout.is_equipped(&"inferno_runico"))


func test_the_warriors_tree_is_still_the_diamond() -> void:
	var s := _screen(_data("warrior", XP_MAX))
	assert_false(s.tree.triangle)
	assert_eq(s.loadout.hero.id, &"warrior")
	assert_eq(s.tree.nodes.size(), 23)
	assert_eq(s.tree._branches().size(), 4)
	var sust: TalentDef = s.loadout.book.catalog.filter(func(t: TalentDef) -> bool: return t.tier == TalentDef.Tier.SUSTAIN)[0]
	assert_eq(s.tree.node(sust.id).get_meta(&"at"), TalentTree.SUSTAIN_AT)


func test_the_tree_fits_both_resolutions() -> void:
	for room: Vector2 in [Vector2(520, 560), Vector2(780, 800)]:
		var k := TalentTree.fit(room)
		assert_between(k, TalentTree.FIT_MIN, TalentTree.FIT_MAX)
