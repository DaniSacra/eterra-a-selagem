extends GutTest
## UI-3 of the hero redesign (04_PLANO.md A.1, A.7, E step 3): the glyphs of the Warrior's twelve Gifts and of the six
## branches, the branch tables that survive an unknown branch, the medallion's twelve nodes drawn by hand.

const WARRIOR_12: Array[StringName] = [&"disciplina", &"cadencia", &"maestria_marcial", &"apogeu", &"forca_concentrada",
	&"determinacao", &"concentracao", &"forca_titanica", &"ruptura", &"alcance_marcial", &"imposicao", &"investida_implacavel"]
const NEW_BRANCHES: Array[StringName] = [&"COMBO", &"IMPETO", &"DOMINIO", &"ELEMENTALISMO", &"CONJURACAO", &"FEITICARIA"]
## The proposed places [id, angle, radius, diameter] (what make_data.gd's MEDALLION_WARRIOR gets).
const PLACES := [
	[&"crown", 0, 254, 72],
	[&"disciplina", 40, 254, 48], [&"cadencia", 60, 254, 48], [&"maestria_marcial", 60, 308, 48], [&"apogeu", 80, 254, 72],
	[&"forca_concentrada", 160, 254, 48], [&"determinacao", 180, 254, 48], [&"concentracao", 180, 308, 48], [&"forca_titanica", 200, 254, 72],
	[&"ruptura", 280, 254, 48], [&"alcance_marcial", 300, 254, 48], [&"imposicao", 300, 308, 48], [&"investida_implacavel", 320, 254, 72]]


func test_every_new_branch_has_a_colour_a_glyph_and_an_ink() -> void:
	for n in NEW_BRANCHES:
		var b: int = TalentDef.Branch.get(String(n), -1)
		assert_gte(b, 0, "%s is a branch" % n)
		assert_true(TalentNode.BRANCH_COLOR.has(n))
		assert_ne(TalentNode.glyph_of(b), TalentNode.Glyph.CENTRE, "%s has a glyph of its own" % n)
		assert_true(GiftArt.INK.has(n))


func test_an_unknown_branch_falls_back_never_crashes() -> void:
	assert_eq(TalentNode.glyph_of(999), TalentNode.Glyph.CENTRE)
	assert_eq(TalentNode.branch_color(999), TalentNode.CENTRE)
	assert_eq(GiftArt.ink(999), GiftArt.ULT_INK)
	assert_false(TalentGlyph.has(&"dom_que_nao_existe"))


func test_the_twelve_gifts_have_distinct_glyphs() -> void:
	for id in WARRIOR_12:
		assert_true(TalentGlyph.has(id), "%s has a glyph" % id)
	var seen := {}
	for id in WARRIOR_12:
		assert_false(seen.has(id))
		seen[id] = true


func test_glyphs_draw_without_error() -> void:
	var c := Control.new()
	c.custom_minimum_size = Vector2(120, 120)
	var ids: Array[StringName] = WARRIOR_12.duplicate()
	ids.append(&"dom_que_nao_existe")
	var results := {}
	c.draw.connect(func() -> void:
		for id in ids:
			results[id] = TalentGlyph.draw(c, id, Vector2(60, 60), 30.0, Color.WHITE, Color.BLACK)
		for g in TalentNode.Glyph.values():
			TalentNode.branch_glyph(c, g, Vector2(60, 60), 30.0, Color.WHITE))
	add_child_autofree(c)
	c.queue_redraw()
	await wait_frames(2)
	for id in WARRIOR_12:
		assert_true(results.get(id, false), "%s drew" % id)
	assert_false(results.get(&"dom_que_nao_existe", true))


func test_the_medallion_view_ignores_places_without_a_gift() -> void:
	var def := MedallionDef.new()
	for row: Array in PLACES:
		var n := MedallionNodeDef.new()
		n.id = row[0]
		n.kind = MedallionNodeDef.Kind.CROWN if n.id == MedallionDef.CROWN_ID else MedallionNodeDef.Kind.GIFT
		n.angle = float(row[1])
		n.radius = float(row[2])
		n.diameter = float(row[3])
		def.nodes.append(n)
	var cat: Array[TalentDef] = [_gift(&"disciplina", TalentDef.Branch.COMBO, TalentDef.Tier.ENTRY)]
	var shown := MedallionView.only_known(def, cat)
	assert_eq(shown.nodes.size(), 2, "the crown and the one Gift the catalog has")
	assert_same(MedallionView.only_known(def, _catalog_for(def)), def, "nothing missing: the same def")


func test_the_proposed_places_link_each_branch_and_do_not_touch() -> void:
	var def := MedallionDef.new()
	for row: Array in PLACES:
		var n := MedallionNodeDef.new()
		n.id = row[0]
		n.kind = MedallionNodeDef.Kind.CROWN if n.id == MedallionDef.CROWN_ID else MedallionNodeDef.Kind.GIFT
		n.angle = float(row[1])
		n.radius = float(row[2])
		n.diameter = float(row[3])
		def.nodes.append(n)
	for a in def.nodes:
		for b in def.nodes:
			if a.id != b.id:
				assert_gt(def.position_of(a).distance_to(def.position_of(b)), (a.diameter + b.diameter) * 0.5 + 2.0, "%s and %s apart" % [a.id, b.id])
	var cat: Array[TalentDef] = []
	for k in 3:
		var br: int = [TalentDef.Branch.COMBO, TalentDef.Branch.IMPETO, TalentDef.Branch.DOMINIO][k]
		cat.append(_gift(WARRIOR_12[k * 4], br, TalentDef.Tier.ENTRY))
		cat.append(_gift(WARRIOR_12[k * 4 + 1], br, TalentDef.Tier.MIDDLE))
		cat.append(_gift(WARRIOR_12[k * 4 + 2], br, TalentDef.Tier.MIDDLE))
		cat.append(_gift(WARRIOR_12[k * 4 + 3], br, TalentDef.Tier.APEX))
		# what a Gift needs is a named Gift (04_PLANO A.1): the middles the entry, the apex the second middle
		cat[-3].needs = cat[-4].id
		cat[-2].needs = cat[-4].id
		cat[-1].needs = cat[-2].id
	var edges := MedallionNav.new(def, cat).edges()
	assert_gte(edges.size(), 9, "entry to two middles and the apex to its middle, per branch")


func _gift(id: StringName, branch: int, tier: int) -> TalentDef:
	var t := TalentDef.new()
	t.id = id
	t.branch = branch as TalentDef.Branch
	t.tier = tier as TalentDef.Tier
	return t


func _catalog_for(def: MedallionDef) -> Array[TalentDef]:
	var cat: Array[TalentDef] = []
	for n in def.nodes:
		if n.kind == MedallionNodeDef.Kind.GIFT:
			cat.append(_gift(n.id, TalentDef.Branch.COMBO, TalentDef.Tier.ENTRY))
	return cat
