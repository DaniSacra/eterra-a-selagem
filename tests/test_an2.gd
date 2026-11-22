extends GutTest
## AN-2: the angels Velael (Veu: Fraqueza), Galael (Mare: push) and Qeshael (Marca: crit), their Blessings and Elos.

const NEW := [Boon.Family.VEU, Boon.Family.MARE, Boon.Family.MARCA]


func _game() -> Game:
	var game: Game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	game.horde.clear_crowd()
	return game


func _take(game: Game, id: StringName) -> void:
	game.boons.take(game.boons.find(id))


func test_damage_rules() -> void:
	assert_eq(DamageCalc.weakened(10.0, 0.25, false), 10.0)
	assert_almost_eq(DamageCalc.weakened(10.0, 0.25, true), 7.5, 0.001)
	assert_almost_eq(DamageCalc.weakened(10.0, 0.9, true), 4.0, 0.001, "the cut stops at MAX_WEAK_CUT")
	assert_eq(DamageCalc.marked(20.0, 0.25, true), 25.0)
	assert_eq(DamageCalc.marked(20.0, 0.25, false), 20.0)
	assert_eq(DamageCalc.shoved(20.0, 0.5, true), 30.0)
	assert_eq(DamageCalc.shoved(20.0, 0.5, false), 20.0)


func test_three_angels_with_their_families() -> void:
	var angels := Encounter.load_catalog()
	assert_eq(angels.size(), 7)
	var by := {}
	for a in angels:
		by[a.id] = a.family
		assert_ne(T.t(a.name_key), String(a.name_key))
		assert_ne(T.t(a.line_key), String(a.line_key))
		assert_false(T.t(a.line_key).contains("—"), "no dash")
	assert_eq(by[&"velael"], Boon.Family.VEU)
	assert_eq(by[&"galael"], Boon.Family.MARE)
	assert_eq(by[&"qeshael"], Boon.Family.MARCA)
	for id in [&"velael", &"galael", &"qeshael"]:
		assert_not_null(AngelArt.texture(id), "%s has its portrait" % id)


func test_nine_blessings_a_family_one_a_button_and_twelve_elos() -> void:
	var state := BoonState.new(BoonState.load_catalog())
	for f: int in NEW:
		var n := 0
		var slots := {}
		for b in state.catalog:
			if b.family == f:
				n += 1
				if b.slot != Boon.Slot.NONE:
					slots[b.slot] = b.id
				assert_ne(T.t("boon_%s" % b.id), "boon_%s" % b.id)
				assert_ne(T.t("boon_%s_desc" % b.id), "boon_%s_desc" % b.id)
		assert_eq(n, 9, "family %d" % f)
		assert_eq(slots.size(), 4, "a Blessing for attack, special, Brado and Investida")
	var elos := state.catalog.filter(func(b: Boon) -> bool: return b.is_duo())
	assert_eq(elos.size(), 12)
	for e: Boon in elos:
		assert_ne(T.t("boon_%s_desc" % e.id), "boon_%s_desc" % e.id)
		for list in e.requires_sets:
			for id in list:
				assert_not_null(state.find(StringName(id)), "%s names %s" % [e.id, id])
	for a in Encounter.load_catalog():
		assert_true(Encounter.eligible(state, a), "%s has cards from the start" % a.id)


func test_the_glossary_knows_fraqueza_and_marca() -> void:
	assert_eq(Glossary.terms_of(T.t("boon_golpe_veu_desc")), [&"weak"] as Array[StringName])
	assert_eq(Glossary.terms_of(T.t("boon_golpe_marca_desc")), [&"mark"] as Array[StringName])
	assert_true(Glossary.emphasize("Causa Fraqueza.").contains(Glossary.mark("Fraqueza", &"weak")))


func test_fraqueza_cuts_what_the_enemy_deals() -> void:
	var game := _game()
	_take(game, &"golpe_veu")
	var e := game.horde.spawn(game.horde.def(&"skeleton"), Vector2(3, 0), false)
	var tags: Array[StringName] = [&"light"]
	game.combat.hit_enemy(e, 1.0, tags, Vector2.RIGHT, 0.0)
	assert_gt(e.weak_t, 0.0, "the attack weakens")
	assert_almost_eq(game.horde._out(e), game.horde.damage_scale * (1.0 - Combat.WEAK_CUT), 0.001)
	_take(game, &"entardecer")
	game.combat.hit_enemy(e, 1.0, tags, Vector2.RIGHT, 0.0)
	assert_almost_eq(game.horde.weak_cut, Combat.WEAK_CUT + 0.1, 0.001, "Entardecer deepens it")
	e.weak_t = 0.0
	assert_eq(game.horde._out(e), game.horde.damage_scale, "it wears off")


func test_marca_makes_the_marked_take_more() -> void:
	var game := _game()
	_take(game, &"golpe_marca")
	var e := game.horde.spawn(game.horde.def(&"guard"), Vector2(3, 0), false)
	var tags: Array[StringName] = [&"light"]
	var before := e.hp
	game.combat.hit_enemy(e, 20.0, tags, Vector2.RIGHT, 0.0)
	var first := before - e.hp - e.armor * 0.0
	assert_gt(e.mark_t, 0.0)
	var f := game.horde.spawn(game.horde.def(&"guard"), Vector2(-3, 0), false)
	var g := game.horde.spawn(game.horde.def(&"guard"), Vector2(0, 3), false)
	f.armor = 0.0
	g.armor = 0.0
	g.mark_t = 5.0
	var a := f.hp
	var b := g.hp
	var plain: Array[StringName] = [&"x"]
	game.combat.hit_enemy(f, 20.0, plain, Vector2.ZERO, 0.0, false)
	game.combat.hit_enemy(g, 20.0, plain, Vector2.ZERO, 0.0, false)
	assert_eq(a - f.hp, 20.0)
	assert_eq(b - g.hp, 25.0, "a quarter more on the marked")
	_take(game, &"olho_atento")
	var c := g.hp
	game.combat.hit_enemy(g, 20.0, plain, Vector2.ZERO, 0.0, false)
	assert_gt(c - g.hp, 25.0, "Olho Atento adds to the crit")
	assert_gte(first, 0.0)


func test_mare_pushes_farther_and_hits_the_sliding_harder() -> void:
	var game := _game()
	var e := game.horde.spawn(game.horde.def(&"skeleton"), Vector2(3, 0), false)
	var tags: Array[StringName] = [&"light"]
	game.combat.hit_enemy(e, 1.0, tags, Vector2.RIGHT, 4.0)
	var plain := e.push.length()
	_take(game, &"golpe_mare")
	var f := game.horde.spawn(game.horde.def(&"skeleton"), Vector2(-3, 0), false)
	game.combat.hit_enemy(f, 1.0, tags, Vector2.RIGHT, 4.0)
	assert_gt(f.push.length(), plain, "pushed farther")
	assert_gt(f.shove_t, 0.0)
	_take(game, &"arrebentacao")
	var g := game.horde.spawn(game.horde.def(&"guard"), Vector2(0, -3), false)
	g.armor = 0.0
	g.shove_t = 1.0
	var hp := g.hp
	var other: Array[StringName] = [&"x"]
	game.combat.hit_enemy(g, 20.0, other, Vector2.ZERO, 0.0, false)
	assert_gt(hp - g.hp, 20.0, "more on whoever still slides")


func test_skill_statuses_weaken_and_mark() -> void:
	var game := _game()
	var e := game.horde.spawn(game.horde.def(&"guard"), Vector2(3, 0), false)
	game.combat.skill_hit(e, 1.0, [&"skill"] as Array[StringName], Vector2.RIGHT, 0.0, &"weak", 3.0)
	game.combat.skill_hit(e, 1.0, [&"skill"] as Array[StringName], Vector2.RIGHT, 0.0, &"mark", 4.0)
	assert_eq(e.weak_t, 3.0)
	assert_eq(e.mark_t, 4.0)
