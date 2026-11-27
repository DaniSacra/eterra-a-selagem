extends GutTest
## GP-1, the Warrior V1 (docs/design/heroes/warrior_v1_2026-11-26.md 14): the blows of the two buttons (tap and hold), the Magia
## spent when a blow lands, the Ritmo de Batalha, the Dons that changed, the Blessings' new slots and the save's version 17.

const F := 1.0 / 60.0

var game: Game
var pad: Controls.VirtualPad


func after_each() -> void:
	Controls.virtual = null
	Controls.flush()


func _run(ids: Array[StringName] = []) -> void:
	game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	game.rooms.start_at(RunMap.Kind.FOUNTAIN)
	game.horde.clear_crowd()
	game.player.pos = Vector2.ZERO
	game.equip_talents(ids)
	pad = Controls.VirtualPad.new()
	Controls.virtual = pad
	var p := game.player
	p.state = Player.State.MOVE
	p.invuln = 0.0
	p.runner.reset()
	p.magick.value = p.magick.max_value


func _enemy(id: StringName, at: Vector2) -> Enemy:
	var e := game.horde.spawn(game.horde.def(id), game.arena.resolve(at, 0.6), false)
	e.cooldown = 99.0
	e.hp = 5000.0
	return e


func _node(id: StringName) -> ComboNode:
	for n in game.player.tree.all_nodes():
		if n.id == id:
			return n
	return null


## One frame with the buttons in `press` going down now and those in `hold` kept down; the rest are let go.
func _frame(press: Array = [], hold: Array = []) -> void:
	for a: StringName in press:
		pad.press(a)
	for a: StringName in pad.held.keys():
		if not press.has(a) and not hold.has(a):
			pad.release(a)
	game.player.step(F, Vector2.ZERO, Vector2.RIGHT)
	game.combat.step(F)
	game.projectiles.step(F)
	pad.end_frame()


func _frames(n: int, hold: Array = []) -> void:
	for i in n:
		_frame([], hold)


## A button held for `seconds` (the press frame included), then let go.
func _hold(action: StringName, seconds: float) -> void:
	_frame([action], [action])
	_frames(roundi(seconds / F), [action])
	_frame()


func _tap(action: StringName) -> void:
	_frame([action])
	_frame()


func _played() -> Array[StringName]:
	var played: Array[StringName] = []
	game.player.runner.move_started.connect(func(n: ComboNode) -> void: played.append(n.id))
	return played


# ---------- the data ----------

func test_the_warriors_numbers() -> void:
	var h := HeroDef.warrior()
	assert_eq(h.max_hp, 40.0)
	assert_eq(h.magick_max, 30.0)
	assert_eq(h.dodge_charges, 1)
	assert_eq(h.dodge_recharge, 0.8)
	assert_eq(h.passive_tags, [&"finisher"] as Array[StringName], "the Lança and the Esmagador pay, they do not refund")
	assert_eq(h.cd_refund_hit, 0.0)
	assert_eq(h.cd_refund_break, 0.0)
	assert_eq(h.cd_floor, 0.0)
	assert_eq(HeroDef.maga().magick_max, 50.0, "the Maga keeps hers")


func test_the_tree_has_exactly_the_four_blows_and_none_of_the_brado_or_the_investida() -> void:
	for path in [HeroDef.warrior().combos, "res://data/combos/paladin_fifth.tres"]:
		var tree: ComboTree = load(path)
		var ids: Array[StringName] = []
		for n in tree.neutral:
			ids.append(n.id)
			assert_ne(n.input, ComboNode.In.SHOUT)
			assert_ne(n.input, ComboNode.In.RUSH)
		assert_eq(ids, [&"cut1", &"smash", &"sweep", &"lance"] as Array[StringName])
		assert_eq(ComboTree.find(tree.neutral, ComboNode.In.CHARGE_LIGHT).id, &"smash")
		assert_eq(ComboTree.find(tree.neutral, ComboNode.In.HEAVY).id, &"sweep")
		assert_eq(ComboTree.find(tree.neutral, ComboNode.In.CHARGE).id, &"lance")


func test_the_lance_is_the_one_of_before_but_for_its_button_and_tags() -> void:
	var tree: ComboTree = load(HeroDef.warrior().combos)
	var lance := ComboTree.find(tree.neutral, ComboNode.In.CHARGE)
	assert_eq(lance.damage, 150.0)
	assert_eq(lance.magick_cost, 20.0)
	assert_eq(lance.charge_time, 0.8)
	assert_eq(lance.reach, 1080.0 / 80.0)
	assert_eq(lance.width, 1.8)
	assert_true(lance.both_ways)
	assert_eq(lance.recovery, 0.78)
	assert_eq(lance.move_hold, 0.78)
	assert_eq(lance.shape, ComboNode.Shape.LINE)
	for t in [&"heavy", &"omega", &"thrust", &"lance"]:
		assert_true(lance.has_tag(t))
	assert_false(lance.has_tag(&"finisher"), "no refund of Magia")
	assert_false(lance.has_tag(&"light"))


func test_the_smash_and_the_sweep() -> void:
	var tree: ComboTree = load(HeroDef.warrior().combos)
	var smash := ComboTree.find(tree.neutral, ComboNode.In.CHARGE_LIGHT)
	assert_eq(smash.damage, 75.0)
	assert_eq(smash.magick_cost, 12.0)
	assert_eq(smash.charge_time, 0.6)
	assert_eq(smash.reach, 2.6)
	assert_eq(smash.width, 120.0)
	assert_true(smash.has_tag(&"omega") and smash.has_tag(&"smash"))
	var sweep := ComboTree.find(tree.neutral, ComboNode.In.HEAVY)
	assert_eq(sweep.damage, 35.0)
	assert_eq(sweep.magick_cost, 8.0)
	assert_eq(sweep.shape, ComboNode.Shape.CIRCLE)
	assert_eq(sweep.reach, 3.4)
	assert_eq(sweep.effect, ComboNode.Effect.NONE, "no Brado: no buff")
	assert_eq(DealtBy.source(smash.tags), &"omega_attack")
	assert_eq(DealtBy.source(sweep.tags), &"shout")
	assert_eq(DealtBy.source(ComboTree.find(tree.neutral, ComboNode.In.CHARGE).tags), &"omega_special")


func test_the_quebra_weights() -> void:
	var w := Feel.live().poise_weights
	assert_eq(w.omega_attack, 1.0, "the Esmagador breaks a common at once")
	assert_eq(w.omega_special, 0.7)
	assert_eq(w.shout, 0.6)
	assert_eq(w.dash, 0.5)


func test_the_controls_have_no_q_and_e_blows() -> void:
	assert_false(Controls.REMAPPABLE.has(&"shout"))
	assert_false(Controls.REMAPPABLE.has(&"rush"))
	assert_false(Controls.PAD_REMAPPABLE.has(&"shout"))
	assert_false(Controls.PAD_REMAPPABLE.has(&"rush"))
	assert_eq(Controls.DEFAULT_KEYS[&"interact"], [KEY_E])
	assert_false(Controls.DEFAULT_KEYS.values().any(func(keys: Array) -> bool: return keys.has(KEY_Q)) and not Controls.DEFAULT_KEYS.has(&"shout"))
	assert_eq(Controls.DEFAULT_KEYS[&"ultimate"], [KEY_SHIFT])
	assert_eq(Controls.keys_for(&"interact", {}), [KEY_E])
	var held := {"light_attack": {"type": "key", "code": KEY_E}}
	assert_eq(Controls.keys_for(&"interact", held), [KEY_F], "a player who put the attack on E: interact goes to the spare F")


func test_q_and_e_start_no_blow() -> void:
	_run()
	var played := _played()
	_frame([&"shout", &"rush"])
	_frames(40)
	assert_eq(played, [] as Array[StringName], "the Warrior has no move on them")


# ---------- the buttons ----------

func test_a_tap_of_the_left_plays_the_combo_on_the_release() -> void:
	_run()
	var played := _played()
	_frame([&"light_attack"], [&"light_attack"])
	assert_eq(played, [] as Array[StringName], "not at the press")
	_frames(3, [&"light_attack"])
	_frame()
	_frames(5)
	assert_eq(played, [&"cut1"] as Array[StringName])
	assert_eq(game.player.magick.value, game.player.magick.max_value, "free")


func test_a_hold_of_the_left_is_the_smash_and_never_the_combo_too() -> void:
	_run()
	var p := game.player
	_enemy(&"skeleton", Vector2(1.6, 0))
	var played := _played()
	_frame([&"light_attack"], [&"light_attack"])
	_frames(15, [&"light_attack"])
	assert_true(p.charging, "the charge is on past the threshold")
	assert_eq(played, [] as Array[StringName], "and nothing is played yet")
	_frames(10, [&"light_attack"])
	assert_eq(played, [&"smash"] as Array[StringName], "the smash begins inside the charge, and no cut1")
	assert_eq(p.magick.spent, 0.0, "the Magia goes when the blow lands, not when it begins")
	_frames(20, [&"light_attack"])
	assert_eq(p.magick.spent, 12.0, "12 Magia once it landed")
	_frame()
	_frames(60)
	assert_eq(played, [&"smash"] as Array[StringName], "the release after the blow plays nothing")
	assert_eq(p.magick.spent, 12.0)


func test_the_dodge_in_the_smashs_windup_spends_no_magia() -> void:
	_run()
	var p := game.player
	_enemy(&"skeleton", Vector2(1.6, 0))
	var played := _played()
	_frame([&"light_attack"], [&"light_attack"])
	_frames(20, [&"light_attack"])
	assert_eq(played, [&"smash"] as Array[StringName], "its windup is under way")
	_frame([&"dodge"], [&"light_attack"])
	_frames(60, [&"light_attack"])
	assert_eq(p.magick.value, 30.0, "the dodge cut it before it landed: nothing spent")
	assert_eq(p.magick.spent, 0.0, "and nothing for the ultimate's charge")
	_frame()
	_frames(30)
	assert_eq(played, [&"smash"] as Array[StringName], "no tap on the release after the dodge")


func test_a_hold_let_go_before_the_charge_fills_does_nothing() -> void:
	_run()
	var played := _played()
	_hold(&"light_attack", 0.25)
	_frames(60)
	assert_eq(played, [] as Array[StringName], "(the blow is committed when its windup starts, 0.3 s in)")
	assert_eq(game.player.magick.value, 30.0)


func test_a_hold_without_the_magia_is_refused_once_and_does_nothing() -> void:
	_run()
	var p := game.player
	p.magick.value = 5.0
	var played := _played()
	var refused := [0]
	p.magick_refused.connect(func() -> void: refused[0] += 1)
	_hold(&"light_attack", 0.8)
	_frames(30)
	assert_eq(refused[0], 1, "the Magia bar flashes once")
	assert_eq(played, [] as Array[StringName], "no combo as a consolation")
	_tap(&"light_attack")
	_frames(10)
	assert_eq(played, [&"cut1"] as Array[StringName], "the tap is free")


func test_a_tap_of_the_right_is_the_sweep_for_8_magia() -> void:
	_run()
	var p := game.player
	var e := _enemy(&"skeleton", Vector2(2.0, 0))
	var hp := e.hp
	var played := _played()
	_tap(&"heavy_attack")
	_frames(3)
	assert_eq(played, [&"sweep"] as Array[StringName])
	assert_eq(p.magick.value, 30.0, "not spent in the windup")
	_frames(25)
	assert_eq(p.magick.value, 22.0, "8 Magia once it landed")
	assert_lt(e.hp, hp)


func test_the_sweep_without_magia_is_refused() -> void:
	_run()
	var p := game.player
	p.magick.value = 7.0
	var played := _played()
	var refused := [0]
	p.magick_refused.connect(func() -> void: refused[0] += 1)
	_tap(&"heavy_attack")
	_frames(30)
	assert_eq(played, [] as Array[StringName])
	assert_eq(refused[0], 1)
	assert_eq(p.magick.value, 7.0)


func test_a_hold_of_the_right_is_the_lance_and_30_magia_pay_one() -> void:
	_run()
	var p := game.player
	var e := _enemy(&"skeleton", Vector2(5.0, 0))
	var hp := e.hp
	var played := _played()
	_hold(&"heavy_attack", 1.0)
	_frames(60)
	assert_eq(played, [&"lance"] as Array[StringName])
	assert_eq(p.magick.value, 10.0, "20 Magia")
	assert_lt(e.hp, hp, "through the line")
	var refused := [0]
	p.magick_refused.connect(func() -> void: refused[0] += 1)
	_hold(&"heavy_attack", 1.0)
	_frames(30)
	assert_eq(played, [&"lance"] as Array[StringName], "a second one is out of Magia")
	assert_eq(refused[0], 1)


func test_a_blow_that_cannot_be_paid_when_it_lands_strikes_nothing() -> void:
	_run()
	var p := game.player
	var e := _enemy(&"skeleton", Vector2(2.0, 0))
	var hp := e.hp
	_tap(&"heavy_attack")
	_frames(3)
	p.magick.value = 2.0
	_frames(30)
	assert_eq(e.hp, hp, "no blow for free")
	assert_eq(p.magick.value, 2.0, "and nothing spent")


func test_the_curse_locks_the_whole_right_button() -> void:
	_run()
	var p := game.player
	p.curse.apply(5.0, 0.5, 0.0)
	var played := _played()
	_tap(&"heavy_attack")
	_hold(&"heavy_attack", 1.0)
	_frames(30)
	assert_eq(played, [] as Array[StringName])
	_tap(&"light_attack")
	_frames(10)
	assert_eq(played, [&"cut1"] as Array[StringName], "the left goes on")


func test_reset_takes_every_button_to_rest() -> void:
	_run()
	var p := game.player
	_frame([&"light_attack"], [&"light_attack"])
	_frames(15, [&"light_attack"])
	assert_true(p.charging)
	p.reset_intents()
	assert_false(p.charging)
	_frames(60, [&"light_attack"])
	assert_false(p.charging, "still held: ignored until it is let go")
	_frame()
	_tap(&"light_attack")
	_frames(10)
	assert_eq(p.runner.node.id if p.runner.node != null else &"", &"cut1")


# ---------- the Magia ----------

func test_magia_economy() -> void:
	_run()
	var p := game.player
	assert_eq(p.magick.max_value, 30.0)
	assert_eq(Game.MAGICK_PER_ELITE, 24.0)
	p.magick.value = 29.0
	p.magick.gain(24.0)
	assert_eq(p.magick.value, 30.0, "never past the maximum")
	assert_false(p.magick.spend(31.0))
	assert_eq(p.magick.value, 30.0, "never negative: a blow too dear is not spent")


func test_every_blow_costs_at_most_the_effective_maximum_with_every_don() -> void:
	var hero := HeroDef.warrior()
	var tree: ComboTree = load(hero.combos)
	for t in hero.talents().catalog:
		var boons := BoonState.new()
		boons.equip_talents([t] as Array[TalentDef])
		var max_magick := hero.magick_max + boons.stat(&"magick_max")
		for n in tree.all_nodes():
			var cost := Player.omega_cost(n.magick_cost, 0.0, boons.stat(&"omega_cost_pct") if n.has_tag(&"omega") else 0.0)
			assert_lte(cost, max_magick, "%s with %s" % [n.id, t.id])


# ---------- the Ritmo de Batalha ----------

func test_the_rhythm_arms_renews_expires_and_clears() -> void:
	var h := HeroDef.warrior()
	var r := BattleRhythm.new(h)
	assert_eq(h.rhythm_time, 3.0)
	assert_false(r.armed())
	r.arm()
	assert_true(r.armed())
	r.step(2.0)
	r.arm()
	assert_eq(r.left, 3.0, "renews, never adds")
	assert_eq(r.tally.rhythm_armed, 1)
	r.step(3.1)
	assert_false(r.armed())
	assert_eq(r.tally.rhythm_expired, 1)
	r.arm()
	r.clear()
	assert_false(r.armed())
	assert_eq(r.tally.rhythm_expired, 1, "a clear is no expiry")
	assert_false(BattleRhythm.new(HeroDef.maga()).enabled(), "the Maga has none")


func test_the_rhythm_is_spent_by_the_strong_blows_only() -> void:
	var r := BattleRhythm.new(HeroDef.warrior())
	_run()
	for pair: Array in [[&"smash", BattleRhythm.Kind.SMASH], [&"sweep", BattleRhythm.Kind.POWER], [&"lance", BattleRhythm.Kind.SPECIAL]]:
		r.arm()
		assert_eq(r.consume(_node(pair[0])), pair[1], "%s" % pair[0])
		assert_false(r.armed())
	r.arm()
	assert_eq(r.consume(_node(&"cut1")), BattleRhythm.Kind.NONE, "the combo never spends it")
	assert_eq(r.consume(_node(&"cut3")), BattleRhythm.Kind.NONE)
	assert_true(r.armed())


func test_a_finisher_that_lands_arms_and_one_in_the_air_does_not() -> void:
	_run()
	var rhythm := game.hero_gifts.rhythm
	game.combat.strike(_node(&"cut3"), game.player.pos, Vector2.RIGHT)
	assert_false(rhythm.armed(), "nobody there")
	_enemy(&"skeleton", Vector2(1.5, 0))
	game.combat.strike(_node(&"cut1"), game.player.pos, Vector2.RIGHT)
	assert_false(rhythm.armed(), "a plain cut")
	game.combat.strike(_node(&"cut3"), game.player.pos, Vector2.RIGHT)
	assert_true(rhythm.armed())


func test_the_lance_with_the_rhythm_hits_half_again_and_goes_farther() -> void:
	_run()
	var lance := _node(&"lance")
	var far := _enemy(&"skeleton", Vector2(15.0, 0))
	var near := _enemy(&"skeleton", Vector2(4.0, 0))
	var plain_before := near.hp
	game.combat.strike(lance, game.player.pos, Vector2.RIGHT)
	var plain := plain_before - near.hp
	assert_eq(far.hp, 5000.0, "15 m is past 13.5 m")
	game.hero_gifts.rhythm.arm()
	near.hp = 5000.0
	game.combat.strike(lance, game.player.pos, Vector2.RIGHT)
	var boosted := 5000.0 - near.hp
	assert_almost_eq(boosted, plain * 1.5, 2.0, "50 per cent more")
	assert_lt(far.hp, 5000.0, "17.5 m reaches it")
	assert_false(game.hero_gifts.rhythm.armed(), "spent")
	assert_eq(game.hero_gifts.rhythm.tally.rhythm_used_special, 1)


func test_the_sweep_with_the_rhythm_stuns_the_commons_and_the_elites_take_the_quebra() -> void:
	_run()
	var sweep := _node(&"sweep")
	var common := _enemy(&"skeleton", Vector2(1.5, 0))
	var elite := _enemy(&"skeleton_elite", Vector2(-1.5, 0))
	var poise_before := elite.poise
	game.combat.strike(sweep, game.player.pos, Vector2.RIGHT)
	var plain_loss := poise_before - elite.poise
	var plain_stun := common.stun_t
	common.stun_t = 0.0
	elite.poise = poise_before
	game.hero_gifts.rhythm.arm()
	game.combat.strike(sweep, game.player.pos, Vector2.RIGHT)
	assert_gte(common.stun_t, 1.0, "the common one is stunned for a second")
	assert_lt(plain_stun, common.stun_t)
	assert_lte(elite.stun_t, 0.0, "never the elite")
	assert_gt(poise_before - elite.poise, plain_loss, "it gets more Quebra")


func test_the_smash_with_the_rhythm_wears_more_quebra() -> void:
	_run()
	var smash := _node(&"smash")
	var a := _enemy(&"skeleton_elite", Vector2(1.5, 0))
	var before := a.poise
	game.combat.strike(smash, game.player.pos, Vector2.RIGHT)
	var plain := before - a.poise
	a.poise = before
	game.hero_gifts.rhythm.arm()
	game.combat.strike(smash, game.player.pos, Vector2.RIGHT)
	assert_gt(before - a.poise, plain)


func test_the_rhythm_clears_on_the_ultimate_and_death() -> void:
	_run()
	game.hero_gifts.rhythm.arm()
	game.player.ult_started.emit(Vector2.RIGHT)
	assert_false(game.hero_gifts.rhythm.armed())
	game.hero_gifts.rhythm.arm()
	game.player.hurt(9999.0, Vector2(5, 0))
	assert_false(game.hero_gifts.rhythm.armed(), "the fall clears it")


func test_a_dodge_before_the_strong_blow_lands_keeps_the_rhythm() -> void:
	_run()
	_enemy(&"skeleton", Vector2(1.6, 0))
	game.hero_gifts.rhythm.arm()
	_frame([&"light_attack"], [&"light_attack"])
	_frames(22, [&"light_attack"])
	_frame([&"dodge"], [&"light_attack"])
	_frames(40, [&"light_attack"])
	assert_true(game.hero_gifts.rhythm.armed() or game.hero_gifts.rhythm.tally.rhythm_expired > 0, "not spent by a cut blow")
	assert_eq(game.hero_gifts.rhythm.tally.rhythm_used_smash, 0)


# ---------- the Dons ----------

func test_the_twelve_dons() -> void:
	var talents := HeroDef.warrior().talents()
	assert_eq(talents.catalog.size(), 12)
	assert_null(talents.find(&"voz_do_leao"))
	var rows := {&"disciplina": [2, 1, 0], &"cadencia": [2, 4, 1], &"maestria_marcial": [3, 9, 3], &"apogeu": [4, 16, 4],
		&"forca_concentrada": [2, 2, 1], &"determinacao": [2, 6, 2], &"concentracao": [3, 11, 3], &"forca_titanica": [4, 17, 4],
		&"ruptura": [2, 3, 1], &"imposicao": [3, 13, 3], &"alcance_marcial": [3, 8, 3], &"investida_implacavel": [4, 18, 4]}
	for id: StringName in rows:
		var t := talents.find(id)
		assert_not_null(t, "%s" % id)
		assert_eq([t.cost, t.unlock_level, t.memory_cost], rows[id], "%s: Vagas, Maestria, Memória" % id)
	assert_eq(talents.find(&"alcance_marcial").needs, &"ruptura")


func test_alcance_marcial_widens_the_sweep() -> void:
	_run([&"ruptura", &"alcance_marcial"])
	var sweep := _node(&"sweep")
	var shape := Combat.swing_shape(sweep, game.boons.stat(&"reach_pct", sweep.tags))
	assert_almost_eq(float(shape.hit_reach), 3.4 * 1.25, 0.01)
	assert_almost_eq(game.boons.stat(&"push_pct", sweep.tags), 0.3, 0.001)
	assert_eq(game.boons.stat(&"reach_pct", _node(&"lance").tags), 0.0, "only the Poder")


func test_forca_titanica_doubles_the_cost_triples_the_damage_and_raises_the_maximum() -> void:
	_run([&"forca_concentrada", &"forca_titanica"])
	var p := game.player
	game.hero_gifts.step(0.0)
	assert_eq(p.magick.max_value, 40.0)
	assert_eq(p.cost_of(_node(&"lance"), 0.0), 40.0, "the whole bar")
	assert_eq(p.cost_of(_node(&"smash"), 0.0), 24.0)
	assert_eq(p.cost_of(_node(&"sweep"), 0.0), 8.0, "the sweep is no charged blow")
	var e := _enemy(&"skeleton", Vector2(4.0, 0))
	game.combat.strike(_node(&"lance"), p.pos, Vector2.RIGHT)
	assert_almost_eq(5000.0 - e.hp, 150.0 * 1.4 * 3.0, 2.0, "150 x 1.4 x 3")


func test_ruptura_reads_the_smash_too() -> void:
	_run([&"ruptura"])
	assert_almost_eq(game.boons.stat(&"armor_pct", _node(&"smash").tags), 0.5, 0.001)
	assert_almost_eq(game.boons.stat(&"armor_pct", _node(&"cut3").tags), 0.5, 0.001)
	assert_eq(game.boons.stat(&"armor_pct", _node(&"cut1").tags), 0.0)


func test_investida_implacavel_stuns_the_commons_the_roll_crosses_once() -> void:
	_run([&"ruptura", &"imposicao", &"investida_implacavel"])
	game.hero_gifts.step(0.0)
	var p := game.player
	var common := _enemy(&"skeleton", Vector2(2.0, 0))
	var elite := _enemy(&"skeleton_elite", Vector2(3.0, 0.2))
	var aside := _enemy(&"skeleton", Vector2(2.0, 4.0))
	var before := elite.poise
	game.combat.dodge_through(Vector2.ZERO, Vector2(4.8, 0))
	assert_almost_eq(common.stun_t, 2.0, 0.1, "2 s")
	assert_lte(elite.stun_t, 0.0, "elites take the Quebra, not the stun")
	assert_lt(elite.poise, before)
	assert_lte(aside.stun_t, 0.0, "out of the roll's path")
	assert_eq(game.combat.dash_crossed, 2)


func test_without_the_don_the_roll_stuns_no_one() -> void:
	_run()
	var common := _enemy(&"skeleton", Vector2(2.0, 0))
	game.combat.dodge_through(Vector2.ZERO, Vector2(4.8, 0))
	assert_lte(common.stun_t, 0.0)


func test_the_roll_calls_dodge_through_when_it_ends() -> void:
	_run([&"ruptura", &"imposicao", &"investida_implacavel"])
	game.hero_gifts.step(0.0)
	var common := _enemy(&"skeleton", Vector2(2.0, 0))
	game.player.facing = Vector2.RIGHT
	_frame([&"dodge"])
	_frames(20)
	assert_gte(game.combat.dash_crossed, 1, "the roll's end hands its segment to Combat.dodge_through")


# ---------- the Blessings and the Psalms ----------

func test_the_blessing_slots_follow_the_new_buttons() -> void:
	var lance := ["heavy", "omega", "thrust", "lance"] as Array
	var tags: Array[StringName] = []
	for t in lance:
		tags.append(StringName(t))
	assert_eq(CelRules.slot_of(tags), Boon.Slot.SPECIAL)
	assert_eq(CelRules.slot_of(_node_tags(&"smash")), Boon.Slot.ATTACK)
	assert_eq(CelRules.slot_of(_node_tags(&"sweep")), Boon.Slot.CAST)
	assert_eq(CelRules.slot_of(_node_tags(&"cut3")), Boon.Slot.ATTACK)


func _node_tags(id: StringName) -> Array[StringName]:
	var tree: ComboTree = load(HeroDef.warrior().combos)
	for n in tree.all_nodes():
		if n.id == id:
			return n.tags
	return []


func test_the_lance_sets_off_the_special_blessings_and_the_sweep_the_poder() -> void:
	var tree: ComboTree = load(HeroDef.warrior().combos)
	var by := {}
	for n in tree.all_nodes():
		by[n.id] = n
	assert_eq(Skills.trigger_of(by[&"lance"]), SkillDef.Trigger.SPECIAL, "pesado_mare fires with the Lança")
	assert_eq(Skills.trigger_of(by[&"sweep"]), SkillDef.Trigger.SHOUT)
	assert_eq(Skills.trigger_of(by[&"smash"]), SkillDef.Trigger.OMEGA)
	assert_eq(Skills.trigger_of(by[&"cut3"]), SkillDef.Trigger.FINISHER)


func test_the_buttons_of_the_slots() -> void:
	assert_eq(Boon.SLOT_BUTTON[Boon.Slot.CAST], &"heavy_attack")
	assert_eq(Boon.SLOT_BUTTON[Boon.Slot.SPECIAL], &"heavy_attack")
	assert_eq(Boon.TAG_BUTTON[&"cast"], &"heavy_attack")
	assert_eq(Boon.TAG_BUTTON[&"dash"], &"dodge")
	assert_eq(Boon.gesture_key(Boon.Slot.CAST), &"tap_hint")
	assert_eq(Boon.gesture_key(Boon.Slot.SPECIAL), &"hold_hint")
	assert_eq(Boon.gesture_key(Boon.Slot.ATTACK), &"tap_hold_hint")
	for k in [&"tap_hint", &"hold_hint", &"tap_hold_hint"]:
		assert_ne(T.t(k), String(k))


func test_circulo_mare_makes_the_sweep_faster() -> void:
	var b: Boon = load("res://data/boons/v1_47_circulo_mare.tres")
	assert_eq(b.slot, Boon.Slot.CAST)
	assert_eq(b.mods[0].stat, &"cel_speed")
	assert_ne(T.t(&"boon_circulo_mare"), "boon_circulo_mare")
	assert_true(T.t(&"boon_circulo_mare_desc").contains("Poder"))


func test_the_pastor_throws_waves_with_the_lance() -> void:
	_run()
	var rules := game.psalm_play.rules
	var pastor: PsalmDef = null
	for p in rules.catalog:
		if p.effect == PsalmDef.Effect.FLOCK:
			pastor = p
	assert_not_null(pastor)
	assert_eq(pastor.slot, Boon.Slot.SPECIAL)
	assert_gt(pastor.damage, 0.0)
	assert_gt(pastor.radius, 0.0)


func test_sentinela_is_never_offered_and_alcance_marcial_is_in_a_group() -> void:
	var psalms := Psalms.new(Psalms.load_catalog())
	psalms.circle = false
	for p in psalms.eligible(null, []):
		assert_ne(p.effect, PsalmDef.Effect.SENTINEL)
	var sentinela: PsalmDef = null
	for p in psalms.catalog:
		if p.effect == PsalmDef.Effect.SENTINEL:
			sentinela = p
	var flat := []
	for group in sentinela.requires:
		flat.append_array(group)
	assert_true(flat.has(PsalmDef.GIFT + "alcance_marcial"))
	assert_false(flat.has(PsalmDef.GIFT + "voz_do_leao"))


func test_the_encantos_of_the_investida_are_reserve() -> void:
	var catalog := Enchants.load_catalog()
	for e in catalog:
		if e.id == &"retorno_do_corte" or e.id == &"eco_do_passo":
			assert_true(e.reserve, "%s" % e.id)
	var learned := Enchants.learned(catalog, {})
	assert_false(learned.any(func(e: EnchantDef) -> bool: return e.reserve))
	assert_true(learned.any(func(e: EnchantDef) -> bool: return e.id == &"lamina_triplice"))


# ---------- the save ----------

func _save_with(opened: Array, equipped: Array) -> Dictionary:
	var d := SaveData.defaults()
	d.version = 16
	d.heroes.warrior.opened = opened.duplicate()
	d.heroes.warrior.unlocked = opened.duplicate()
	d.heroes.warrior.equipped = equipped.duplicate()
	return d


func test_the_save_is_version_17() -> void:
	assert_eq(SaveData.VERSION, 19)
	assert_eq(SaveData.defaults().version, 19)


func test_the_migration_gives_the_memoria_back_and_frees_the_vaga() -> void:
	var d := _save_with(["disciplina", "voz_do_leao", "ruptura"], ["disciplina", "voz_do_leao"])
	d.heroes.warrior.ultimate = "corte_do_juizo"
	var given := SaveData.migrate_removed_dons(d, SaveData.GP1_REMOVED_DONS, ["warrior"])
	assert_eq(given, {"warrior": 3})
	assert_false(d.heroes.warrior.opened.has("voz_do_leao"))
	assert_false(d.heroes.warrior.unlocked.has("voz_do_leao"))
	assert_false(d.heroes.warrior.equipped.has("voz_do_leao"))
	assert_eq(d.heroes.warrior.opened, ["disciplina", "ruptura"], "the others stay")
	assert_eq(d.heroes.warrior.equipped, ["disciplina"])
	assert_eq(d.heroes.warrior.ultimate, "corte_do_juizo", "the ultimate stays")
	var again := SaveData.migrate_removed_dons(d, SaveData.GP1_REMOVED_DONS, ["warrior"])
	assert_eq(again, {"warrior": 0}, "idempotent")


func test_the_migration_on_an_empty_save_and_a_don_only_equipped() -> void:
	var empty := SaveData.defaults()
	assert_eq(SaveData.migrate_removed_dons(empty, SaveData.GP1_REMOVED_DONS, ["warrior"]), {"warrior": 0})
	var d := _save_with([], ["voz_do_leao"])
	assert_eq(SaveData.migrate_removed_dons(d, SaveData.GP1_REMOVED_DONS, ["warrior"]), {"warrior": 0}, "never opened: nothing to give back")
	assert_eq(d.heroes.warrior.equipped, [])


func test_a_loaded_old_save_runs_the_step_once_and_the_old_redesign_still_clears_the_ultimate() -> void:
	var d := _save_with(["voz_do_leao"], ["voz_do_leao"])
	d.options.bindings = {"shout": {"type": "key", "code": KEY_Q}, "pad:rush": {"type": "pad", "code": 4},
		"interact": {"type": "key", "code": KEY_G}, "dodge": {"type": "key", "code": KEY_SPACE}}
	d.materials = {"memory": 2}
	var out := SaveData.merged(d)
	assert_eq(out.version, SaveData.VERSION)
	var bindings: Dictionary = out.options.bindings
	assert_false(bindings.has("shout"))
	assert_false(bindings.has("pad:rush"))
	assert_true(bindings.has("interact"), "his own interact stays")
	assert_true(bindings.has("dodge"))
	assert_false(out.heroes.warrior.opened.has("voz_do_leao"))
	assert_eq(SaveData.drop_removed_bindings(out.options), 0, "idempotent")
	var twice := SaveData.merged(out)
	assert_eq(twice.heroes.warrior.opened, out.heroes.warrior.opened)
