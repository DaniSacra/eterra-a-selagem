extends GutTest
## E2-07 and E2-09 (docs/design/warrior_spec.md 3.1, 4.2, 4.3, 4.5): the Warrior's passive (P-A, 2 of Magia a
## finisher that lands) and every Gift of the tree, one test (or more) each. The rules are GiftState's (pure); the
## game's side (HeroGifts, Combat, Player, Rooms) is checked in a real run.

const L := ComboNode.In.LIGHT
const SPIN: Array[StringName] = [&"light", &"spin", &"finisher"]
const CUT: Array[StringName] = [&"light"]
const DASH: Array[StringName] = [&"light", &"dash"]
const LANCE: Array[StringName] = [&"light", &"thrust", &"finisher", &"omega"]
const BURST: Array[StringName] = [&"heavy", &"wave", &"charge", &"omega"]
const BOLT: Array[StringName] = [&"heavy", &"wave"]

var game: Game


## The rules with these Gifts equipped (none: the game of before).
func _state(ids: Array[StringName] = []) -> GiftState:
	var boons := BoonState.new()
	boons.equip_talents(HeroDef.warrior().talents().defs(ids))
	return GiftState.new(HeroDef.warrior(), boons)


## A run in the fountain room (nobody else), the paladin at the middle, with these Gifts.
func _run(ids: Array[StringName] = []) -> void:
	game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	game.rooms.start_at(RunMap.Kind.FOUNTAIN)
	game.horde.clear_crowd()
	game.player.pos = Vector2.ZERO
	game.equip_talents(ids)


func _enemy(id: StringName, at: Vector2) -> Enemy:
	var e := game.horde.spawn(game.horde.def(id), game.arena.resolve(at, 0.6), false)
	e.cooldown = 99.0
	return e


func _node(tree: ComboTree, id: StringName) -> ComboNode:
	for n in tree.all_nodes():
		if n.id == id:
			return n
	return null


func _spin() -> ComboNode:
	return _node(game.player.tree, &"cut3")


# ---------- the passive (P-A) ----------

func test_the_passive_gives_two_of_magia_for_each_finisher_that_lands() -> void:
	var s := _state()
	assert_eq(s.passive_magick(SPIN, 1), 2.0, "the spin")
	assert_eq(s.passive_magick(DASH, 1), 2.0, "the Corte Veloz that lands")
	assert_eq(s.passive_magick(LANCE, 1), 2.0, "the attack's Omega")
	assert_eq(s.passive_magick(BURST, 1), 2.0, "the special's Omega")
	assert_eq(s.passive_magick(SPIN, 0), 0.0, "a finisher in the air gives nothing")
	assert_eq(s.passive_magick(CUT, 3), 0.0, "a plain cut is no finisher")
	assert_eq(s.passive_magick(BOLT, 1), 0.0, "nor the plain special")


func test_an_ultimate_blow_never_feeds_the_passive() -> void:
	var s := _state()
	for list: Array in [[&"ultimate", &"light"], [&"ultimate", &"cast"], [&"ultimate", &"finisher", &"omega"]]:
		var tags: Array[StringName] = []
		tags.assign(list)
		assert_false(s.is_finisher(tags), "%s" % [tags])
		assert_eq(s.passive_magick(tags, 5), 0.0, "%s" % [tags])


func test_the_passive_counts_once_a_blow_and_never_past_the_maximum() -> void:
	_run()
	var p := game.player
	for k in 3:
		_enemy(&"skeleton", Vector2.from_angle(TAU * k / 3.0) * 1.6)
	p.magick.value = 10.0
	game.combat.strike(_spin(), p.pos, Vector2.RIGHT)
	assert_eq(p.magick.value, 12.0, "three hit, two of Magia once")
	p.magick.value = p.magick.max_value - 1.0
	game.combat.landed.emit(_spin(), SPIN, 1)
	assert_eq(p.magick.value, p.magick.max_value, "never past the maximum")
	p.magick.value = 10.0
	game.combat.strike(_node(p.tree, &"cut1"), p.pos, Vector2.RIGHT)
	assert_eq(p.magick.value, 10.0, "a plain cut gives nothing")


func test_the_special_omega_counts_once_with_its_wave() -> void:
	_run()
	var p := game.player
	for k in 3:
		_enemy(&"skeleton", Vector2(3.0 + k * 1.2, 0))
	p.magick.value = 10.0
	game.combat.strike(_node(p.tree, &"burst"), p.pos, Vector2.RIGHT)
	for i in 30:
		game.projectiles.step(1.0 / 60.0)
	assert_eq(p.magick.value, 12.0, "the wave struck three, the passive gave once")


func test_no_passive_turns_it_off_for_comparisons() -> void:
	var s := _state()
	s.passive = false
	assert_eq(s.passive_magick(SPIN, 1), 0.0)


# ---------- with no Gift, the game of before ----------

func test_with_no_gift_every_rule_answers_the_game_of_before() -> void:
	var s := _state()
	assert_eq(s.on_kill(LANCE), 0, "no fury")
	assert_eq(s.attack_speed(), 1.0)
	assert_eq(s.fury_stun(SPIN), 0.0)
	assert_false(s.dash_back(SPIN))
	assert_false(s.on_landed(SPIN, 3))
	assert_eq(s.omega_discount(), 0.0)
	assert_false(s.chains_on(SPIN, 9))
	assert_false(s.chains_on(DASH, 1))
	assert_eq(float(s.wave(SPIN).damage), 0.0)
	assert_false(s.rise())
	assert_eq(s.room_heal(), 0.0)


func test_every_gift_does_something() -> void:
	for t in HeroDef.warrior().talents().catalog:
		assert_true(not t.mods.is_empty() or t.combos != "", "%s has numbers or a combo tree" % t.id)


# ---------- Combo: Quarto Corte, Passo Encadeado, Golpe sem Fim ----------

func test_quarto_corte_adds_a_thrust_before_the_spin_keeping_the_tags() -> void:
	var t: TalentDef = HeroDef.warrior().talents().find(&"quarto_corte")
	var plain: ComboTree = load("res://data/combos/paladin.tres")
	var fourth: ComboTree = load(t.combos)
	var cut2 := ComboTree.find(fourth.neutral, L).following()[0]
	var thrust := cut2.following()[0]
	assert_eq(thrust.id, &"thrust4")
	assert_true(thrust.has_tag(&"light"), "a blow of the attack: the attack's Blessings count on it")
	assert_eq(thrust.damage, 30.0)
	assert_eq(thrust.shape, ComboNode.Shape.LINE, "a thrust")
	assert_eq(thrust.following()[0].id, &"cut3", "then the spin")
	assert_eq(thrust.lunge, 0.0, "struck standing still")
	for n in plain.all_nodes():
		var same := _node(fourth, n.id)
		assert_not_null(same, String(n.id))
		assert_eq(same.tags, n.tags, "%s keeps its tags" % n.id)
		assert_eq(same.damage, n.damage, "%s keeps its numbers" % n.id)
		assert_eq(same.recovery, n.recovery, String(n.id))
	assert_eq(fourth.all_nodes().size(), plain.all_nodes().size() + 1)


## The combo's damage a second, press to press (windup, glint, attack lock), within 10% of today's: a trade, not a gain.
func test_quarto_corte_keeps_the_combo_dps_within_ten_percent() -> void:
	var dps := func(tree: ComboTree) -> float:
		var damage := 0.0
		var time := 0.0
		var n := ComboTree.find(tree.neutral, L)
		while n != null:
			damage += n.damage
			time += n.lead() + n.recovery
			n = ComboTree.find(n.following(), L)
		return damage / time
	var before: float = dps.call(load("res://data/combos/paladin.tres"))
	var after: float = dps.call(load(HeroDef.warrior().talents().find(&"quarto_corte").combos))
	assert_between(after / before, 0.9, 1.1, "%.1f a second against %.1f" % [after, before])


func test_quarto_corte_plays_four_blows_in_the_game() -> void:
	_run([&"quarto_corte"])
	var runner := ComboRunner.new(game.player.tree)
	var started: Array[StringName] = []
	runner.move_started.connect(func(n: ComboNode) -> void: started.append(n.id))
	for i in 4:
		runner.press(L)
		runner.step(0.0)
		for k in int((runner.node.duration() + 0.02) * 120.0):
			runner.step(1.0 / 120.0)
	assert_eq(started, [&"cut1", &"cut2", &"thrust4", &"cut3"] as Array[StringName])


func test_passo_encadeado_makes_the_corte_veloz_the_first_blow() -> void:
	assert_true(_state([&"quarto_corte", &"passo_encadeado"]).chains_on(DASH, 0), "landing or not")
	assert_false(_state([&"quarto_corte"]).chains_on(DASH, 1))
	# the runner: dodge, attack (the Corte Veloz), and the next press is cut2, pressed during its recovery (kept)
	var runner := ComboRunner.new(load("res://data/combos/paladin.tres"))
	var started: Array[StringName] = []
	runner.move_started.connect(func(n: ComboNode) -> void: started.append(n.id))
	runner.on_dodge()
	runner.press(L)
	runner.on_dodge_end()
	runner.step(0.0)
	assert_eq(started, [&"dash_cut"] as Array[StringName])
	for k in 12:
		runner.step(1.0 / 120.0)
		if runner.stage() == ComboRunner.Stage.STRIKE:
			runner.chain_from(runner.opener())  # what HeroGifts does when it lands
	runner.press(L)  # in its recovery: kept for when it ends
	for k in 120:
		runner.step(1.0 / 120.0)
	assert_eq(started, [&"dash_cut", &"cut2"] as Array[StringName], "the press is not lost and goes on at cut2")


func test_passo_encadeado_in_the_game_even_in_the_air() -> void:
	_run([&"quarto_corte", &"passo_encadeado"])
	var p := game.player
	game.combat.strike(_node(p.tree, &"dash_cut"), p.pos, Vector2.RIGHT)
	assert_null(p.runner._chain_from, "only while a move is under way")
	p.runner.on_dodge()
	p.runner.press(L)
	p.runner.on_dodge_end()
	p.runner.step(0.0)
	assert_eq(p.runner.node.id, &"dash_cut")
	game.combat.strike(p.runner.node, p.pos, Vector2.RIGHT)  # it lands on nobody
	assert_eq(p.runner._chain_from, p.runner.opener(), "it counts as cut1")


func test_without_passo_encadeado_the_corte_veloz_starts_over() -> void:
	var runner := ComboRunner.new(load("res://data/combos/paladin.tres"))
	var started: Array[StringName] = []
	runner.move_started.connect(func(n: ComboNode) -> void: started.append(n.id))
	runner.on_dodge()
	runner.press(L)
	runner.on_dodge_end()
	runner.step(0.0)
	for k in 60:
		runner.step(1.0 / 120.0)
	runner.press(L)
	runner.step(1.0 / 120.0)
	assert_eq(started, [&"dash_cut", &"cut1"] as Array[StringName])


func test_golpe_sem_fim_starts_over_at_cut2_when_the_spin_lands_on_three() -> void:
	var s := _state([&"quarto_corte", &"passo_encadeado", &"impeto", &"golpe_sem_fim"])
	assert_true(s.chains_on(SPIN, 3))
	assert_false(s.chains_on(SPIN, 2), "two is not enough")
	assert_false(s.chains_on(CUT, 5), "only the spin")
	_run([&"quarto_corte", &"passo_encadeado", &"impeto", &"golpe_sem_fim"])
	var p := game.player
	for k in 3:
		_enemy(&"knight", Vector2.from_angle(TAU * k / 3.0 + 0.3) * 1.8)
	p.runner.press(L)
	var started: Array[StringName] = []
	p.runner.move_started.connect(func(n: ComboNode) -> void: started.append(n.id))
	# cut1, cut2, the thrust, the spin, then one more press
	for blow in 5:
		p.runner.press(L)
		for k in 70:
			p.invuln = 10.0
			game._step(1.0 / 60.0)
			if started.size() > blow:
				break
	assert_eq(started.slice(0, 5), [&"cut1", &"cut2", &"thrust4", &"cut3", &"cut2"] as Array[StringName])


# ---------- Fúria: Ímpeto, Avanço Feroz, Fúria Plena ----------

func test_impeto_gives_a_charge_a_kill_up_to_three_gone_in_three_seconds() -> void:
	var s := _state([&"impeto"])
	assert_eq(s.on_kill([]), 1, "a kill of any kind, a burn's too")
	s.on_kill(CUT)
	s.on_kill(CUT)
	assert_eq(s.on_kill(CUT), 0, "three at most")
	assert_eq(s.fury, 3)
	assert_almost_eq(s.attack_speed(), 1.18, 0.0001, "6% faster a charge")
	s.step(2.9)
	s.on_kill(CUT)
	s.step(2.9)
	assert_eq(s.fury, 3, "a kill keeps them 3 s more")
	s.step(0.2)
	assert_eq(s.fury, 0, "3 s without a kill: all gone")
	assert_eq(s.attack_speed(), 1.0)


func test_impeto_plays_every_blow_faster() -> void:
	var lands_at := func(speed: float) -> float:
		var runner := ComboRunner.new(load("res://data/combos/paladin.tres"))
		runner.speed = speed
		var landed := [-1.0]
		var t := [0.0]
		runner.move_hit.connect(func(_n: ComboNode) -> void: landed[0] = t[0])
		runner.press(L)
		runner.step(0.0)
		while landed[0] < 0.0 and t[0] < 2.0:
			runner.step(1.0 / 600.0)
			t[0] += 1.0 / 600.0
		return landed[0]
	var plain: float = lands_at.call(1.0)
	var fast: float = lands_at.call(1.18)
	assert_almost_eq(fast, plain / 1.18, 0.004)


func test_impeto_shows_its_charges_as_embers_and_speeds_the_runner() -> void:
	_run([&"impeto"])
	var p := game.player
	var e := _enemy(&"skeleton", Vector2(1.5, 0))
	e.hp = 1.0
	game.combat.strike(_spin(), p.pos, Vector2.RIGHT)
	game._step(1.0 / 60.0)
	assert_eq(game.hero_gifts.state.fury, 1)
	assert_almost_eq(p.runner.speed, 1.06, 0.0001)
	var shown := 0
	for ember in p._embers:
		shown += 1 if ember.visible else 0
	assert_eq(shown, 1, "one ember a charge")
	var mat := p._embers[0].material_override as ShaderMaterial
	var peak := float(mat.get_shader_parameter(&"peak"))
	assert_lte(peak, 1.0, "under the glow")
	var heart := Player.EMBER_COLOR.lerp(Color.WHITE, Player.EMBER_PALE)
	var top := maxf(heart.r, maxf(heart.g, heart.b))
	assert_lte(ScreenTone.peak8(Color(heart.r / top, heart.g / top, heart.b / top) * peak, false), ScreenTone.SCREEN_MAX, "its pale heart keeps its colour on the screen")
	assert_eq(p._embers[1].material_override, mat, "one material for the three")


func test_avanco_feroz_gives_the_dodge_back_on_a_finisher_kill_once_a_blow() -> void:
	var s := _state([&"impeto", &"avanco_feroz"])
	assert_true(s.dash_back(SPIN))
	assert_true(s.dash_back(LANCE))
	assert_false(s.dash_back(CUT), "a plain cut that kills does not")
	assert_false(s.dash_back([]), "nor a burn")
	_run([&"impeto", &"avanco_feroz"])
	var p := game.player
	p.dodge_max = 2
	p.dodge_charges = 0
	for k in 3:
		_enemy(&"skeleton", Vector2.from_angle(TAU * k / 3.0) * 1.6).hp = 1.0
	game.combat.strike(_spin(), p.pos, Vector2.RIGHT)
	assert_eq(p.dodge_charges, 1, "three fell, one charge back: never an endless dodge")
	_enemy(&"skeleton", Vector2(1.5, 0)).hp = 1.0
	game.combat.strike(_node(p.tree, &"cut1"), p.pos, Vector2.RIGHT)
	assert_eq(p.dodge_charges, 1, "a plain cut gives nothing")


func test_furia_plena_stuns_longer_with_every_charge_armor_too() -> void:
	var s := _state([&"quarto_corte", &"impeto", &"furia_plena"])
	s.on_kill(CUT)
	s.on_kill(CUT)
	assert_eq(s.fury_stun(SPIN), 0.0, "two charges are not enough")
	s.on_kill(CUT)
	assert_eq(s.fury_stun(SPIN), 0.5)
	assert_eq(s.fury_stun(CUT), 0.0, "only finishers")
	_run([&"quarto_corte", &"impeto", &"furia_plena"])
	var p := game.player
	var elite := _enemy(&"skeleton_elite", Vector2(1.6, 0))
	assert_gt(elite.armor, 0.0)
	game.combat.strike(_spin(), p.pos, Vector2.RIGHT)
	assert_eq(elite.stun_t, 0.0, "without the charges the armor takes it")
	for k in 3:
		game.hero_gifts.state.on_kill(CUT)
	game.combat.strike(_spin(), p.pos, Vector2.RIGHT)
	assert_gte(elite.stun_t, elite.def.stun_heavy_time + 0.5 - 0.001, "with every charge it stuns through the armor")
	var knight := _enemy(&"knight", Vector2(-1.6, 0))
	game.combat.strike(_spin(), p.pos, Vector2.RIGHT)
	assert_eq(knight.stun_t, 0.0, "never a guardian")


# ---------- Emeth: Corte Crescente, Onda Atravessante ----------

func _friendly_waves() -> Array:
	return game.projectiles.shots.filter(func(s: Projectiles.Shot) -> bool: return not Projectiles.hostile(s))


func test_corte_crescente_throws_an_emerald_wave_from_the_spin() -> void:
	var s := _state([&"corte_crescente"])
	var w := s.wave(SPIN)
	assert_eq(float(w.damage), 16.0)
	assert_eq(float(w.reach), 6.0)
	assert_eq(float(s.wave(CUT).damage), 0.0, "only the spin")
	_run()
	game.combat.strike(_spin(), game.player.pos, Vector2.RIGHT)
	assert_eq(_friendly_waves().size(), 0, "no wave without the Gift")
	_run([&"corte_crescente"])
	game.combat.strike(_spin(), game.player.pos, Vector2.RIGHT)
	var waves := _friendly_waves()
	assert_eq(waves.size(), 1, "the spin throws one, landing or not")
	var shot: Projectiles.Shot = waves[0]
	assert_eq(shot.damage, 16.0)
	assert_eq(shot.color, Combat.EMETH, "emerald")
	assert_true(shot.tags.has(&"finisher"), "the finisher's Blessings count on it")
	assert_false(shot.tags.has(&"omega"))
	assert_true(shot.counted, "its hits are not another landing of the blow")
	assert_almost_eq(shot.vel.length() * shot.life, 6.0, 0.01, "6 m")
	assert_lte(Projectiles.wave_peak(shot.color), 1.0, "under the glow")


func test_onda_atravessante_takes_the_special_through_stone() -> void:
	assert_eq(_state([&"corte_crescente", &"fio_longo", &"lamina_faminta", &"onda_atravessante"]).value(&"wave_through", BOLT), 1.0)
	_run()
	game.combat.strike(_node(game.player.tree, &"bolt"), game.player.pos, Vector2.RIGHT)
	assert_false((_friendly_waves()[0] as Projectiles.Shot).through, "stone stops it without the Gift")
	_run([&"corte_crescente", &"fio_longo", &"lamina_faminta", &"onda_atravessante"])
	game.combat.strike(_node(game.player.tree, &"bolt"), game.player.pos, Vector2.RIGHT)
	assert_true((_friendly_waves()[0] as Projectiles.Shot).through)


func test_a_wave_through_stone_is_not_stopped_by_a_column() -> void:
	_run([&"corte_crescente", &"fio_longo", &"lamina_faminta", &"onda_atravessante"])
	# a tall column in the way (Arena.shot_hit stops a shot that meets it)
	var column := Vector2(0, -6)
	game.arena.cover.append(ArenaObstacle.circle(column, 0.7, &"column", 3.0, true, true))
	var from := column - Vector2.RIGHT * 4.0
	assert_gte(game.arena.shot_hit(from, column + Vector2.RIGHT * 4.0, Projectiles.SHOT_EDGE), 0.0, "the column is in the way")
	for through: bool in [false, true]:
		var before := game.projectiles.blocked
		var s := game.projectiles.fire_wave(Projectiles.Kind.SPARK, from, Vector2.RIGHT, 1.0, 8.0, 1.6, Combat.EMETH, BOLT)
		s.through = through
		for k in 30:
			game.projectiles.step(1.0 / 60.0)
		assert_eq(game.projectiles.blocked - before, 0 if through else 1, "through stone: %s" % through)


# ---------- Magia: Lâmina Faminta, Coração da Emeth ----------

func test_lamina_faminta_halves_an_omega_begun_within_a_second_of_a_finisher() -> void:
	var s := _state([&"lamina_faminta"])
	assert_false(s.on_landed(SPIN, 0), "a finisher in the air opens nothing")
	assert_false(s.on_landed(CUT, 2), "a plain cut opens nothing")
	assert_true(s.on_landed(SPIN, 1))
	assert_eq(s.omega_discount(), 0.5)
	assert_eq(Player.omega_cost(20.0, s.omega_discount()), 10.0)
	s.step(0.99)
	assert_eq(s.omega_discount(), 0.5)
	s.step(0.02)
	assert_eq(s.omega_discount(), 0.0, "1 s later the full price")
	_run([&"lamina_faminta"])
	_enemy(&"skeleton", Vector2(1.5, 0))
	game.combat.strike(_spin(), game.player.pos, Vector2.RIGHT)
	game.hero_gifts.step(0.0)
	assert_eq(game.player.omega_discount, 0.5, "the paladin pays half")
	assert_eq(game.fx.showing(&"glints"), 1, "the glint stays on the tip")


func test_coracao_da_emeth_feeds_the_ultimate_and_the_passive() -> void:
	var ids: Array[StringName] = [&"corte_crescente", &"fio_longo", &"lamina_faminta", &"coracao_da_emeth"]
	var boons := BoonState.new()
	boons.equip_talents(HeroDef.warrior().talents().defs(ids))
	assert_eq(boons.stat(&"ult_charge_pct"), 0.25, "the ultimate reads it: 25% faster")
	assert_eq(_state(ids).passive_magick(SPIN, 1), 3.0, "the passive gives 3")


# ---------- bridges ----------

func test_investida_the_corte_veloz_that_kills_gives_the_dodge_back() -> void:
	var s := _state([&"quarto_corte", &"impeto", &"investida"])
	assert_true(s.dash_back(DASH))
	assert_false(s.dash_back(SPIN), "only the Corte Veloz")
	_run([&"quarto_corte", &"impeto", &"investida"])
	var p := game.player
	p.dodge_charges = 0
	_enemy(&"skeleton", Vector2(2.0, 0)).hp = 1.0
	game.combat.strike(_node(p.tree, &"dash_cut"), p.pos, Vector2.RIGHT)
	assert_eq(p.dodge_charges, 1)


func test_sangue_quente_an_omega_kill_gives_two_charges() -> void:
	var s := _state([&"impeto", &"lamina_faminta", &"sangue_quente"])
	assert_eq(s.on_kill(LANCE), 2)
	assert_eq(s.on_kill(CUT), 1, "a plain kill one")
	assert_eq(_state([&"impeto"]).on_kill(LANCE), 1, "without the bridge one")


func test_onda_carregada_the_special_omega_throws_the_spin_wave() -> void:
	var s := _state([&"lamina_faminta", &"corte_crescente", &"onda_carregada"])
	assert_eq(float(s.wave(BURST).damage), 16.0)
	assert_eq(float(s.wave(BOLT).damage), 0.0, "only its Omega")
	_run([&"lamina_faminta", &"corte_crescente", &"onda_carregada"])
	game.combat.strike(_node(game.player.tree, &"burst"), game.player.pos, Vector2.RIGHT)
	var damages := _friendly_waves().map(func(w: Projectiles.Shot) -> float: return w.damage)
	assert_true(damages.has(16.0), "its own wave and the spin's: %s" % [damages])
	assert_eq(damages.size(), 2)


func test_fio_do_passo_the_corte_veloz_throws_a_short_wave() -> void:
	var s := _state([&"corte_crescente", &"quarto_corte", &"fio_do_passo"])
	assert_eq(float(s.wave(DASH).damage), 12.0)
	_run([&"corte_crescente", &"quarto_corte", &"fio_do_passo"])
	game.combat.strike(_node(game.player.tree, &"dash_cut"), game.player.pos, Vector2.RIGHT)
	var waves := _friendly_waves()
	assert_eq(waves.size(), 1)
	assert_eq((waves[0] as Projectiles.Shot).kind, Projectiles.Kind.SPARK, "the special's small wave")


# ---------- sustain ----------

func test_respiro_heals_two_a_room_won() -> void:
	_run([&"respiro"])
	game.player.hp = 10.0
	game.hero_gifts.room_won()
	assert_eq(game.player.hp, 12.0)
	_run()
	game.player.hp = 10.0
	game.hero_gifts.room_won()
	assert_eq(game.player.hp, 10.0, "nothing without it")


func test_ainda_de_pe_stands_him_up_once_with_half_his_life() -> void:
	_run([&"ainda_de_pe"])
	var p := game.player
	var fell := [0]
	p.died.connect(func() -> void: fell[0] += 1)
	p.invuln = 0.0
	p.hurt(p.hp + 5.0, p.pos + Vector2.RIGHT)
	assert_true(p.alive(), "he gets up")
	assert_eq(p.hp, roundf(p.max_hp * 0.5))
	assert_eq(fell[0], 0)
	p.invuln = 0.0
	p.state = Player.State.MOVE
	p.hurt(p.hp + 5.0, p.pos + Vector2.RIGHT)
	assert_false(p.alive(), "once a descent")
	assert_eq(fell[0], 1)
