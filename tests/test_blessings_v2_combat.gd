extends GutTest
## Blessings V2 in play (IMPLEMENTACAO_V2.md 6): each rule on a real Combat of a real Game: a state only of a blow that hurts,
## Veneno and its Saturação, Sangramento, Eletrificação with Descarga, Condução and Sobrecarga, the anticipation that takes what it
## brings forward, the propagation that never propagates, the Abertura of a boss, Amparo, Fluxo Contínuo, the zones and the Maga.

const DT := 1.0 / 60.0
const HOLD: Array = ["light", "thrust", "finisher", "omega"]

var game: Game
var _key := 500


func before_each() -> void:
	Dev.put("seed", "1")


func after_each() -> void:
	Dev.drop("hero")
	Dev.put("seed", "1")


func _start(hero := "") -> void:
	if hero != "":
		Dev.put("hero", hero)
	game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	game.rooms.start_at(RunMap.Kind.FOUNTAIN)
	game.horde.clear_crowd()
	game.player.pos = Vector2.ZERO
	game.horde.target = Vector2.ZERO
	game.boons.ult_open = true


func _take(id: StringName, rarity := Boon.Rarity.COMMON) -> void:
	game.boons.take(game.boons.find(id), rarity)


func _enemy(at := Vector2(4.0, 0.0), hp := 100000.0) -> Enemy:
	var e := game.horde.spawn(game.horde.def(&"skeleton"), at, false)
	e.hp = hp
	e.max_hp = hp
	return e


func _boss() -> Enemy:
	var e := _enemy()
	e.def = e.def.duplicate()
	e.def.behavior = EnemyDef.Behavior.BOSS
	return e


func _guardian() -> Enemy:
	var e := _enemy()
	e.def = e.def.duplicate()
	e.def.heavy = true
	return e


func _hit(e: Enemy, tags: Array, base := 10.0, same_action := false) -> void:
	var t: Array[StringName] = []
	for x in tags:
		t.append(StringName(x))
	if not same_action:
		_key += 1
	game.combat.kill_blow = _key
	game.combat.hit_enemy(e, base, t, Vector2.RIGHT, 0.0)
	game.combat.kill_blow = 0


func _dealt(e: Enemy, tags: Array, base := 10.0) -> float:
	var before := e.hp
	_hit(e, tags, base)
	return before - e.hp


func _run(seconds: float) -> void:
	for i in roundi(seconds / DT):
		game.combat.celestial.step(DT)
		game.horde.step(DT)


func _by(source: String) -> float:
	return float(game.horde.dealt.by.get(source, 0.0))


func _cel() -> Celestial:
	return game.combat.celestial


# ---------- a state only of a blow that hurts ----------

func test_a_blow_shut_by_a_guard_or_dealing_nothing_or_on_a_ward_puts_nothing() -> void:
	_start()
	_take(&"golpe_peste")
	var e := _enemy()
	var tags: Array[StringName] = [&"light"]
	_cel().after_hit(e, tags, 10.0, false, true)
	assert_null(e.cel, "shut by the guard: no state")
	_cel().after_hit(e, tags, 0.0, false, false)
	assert_null(e.cel, "dealt nothing")
	_cel().after_hit(e, tags, 10.0, true, false)
	assert_null(e.cel, "dead")
	var warded := _enemy(Vector2(6.0, 0.0))
	warded.invulnerable = true
	game.combat.kill_blow = 1
	assert_false(game.combat.hit_enemy(warded, 10.0, tags, Vector2.RIGHT, 0.0))
	assert_null(warded.cel, "Morvath's ward takes no poison")
	_cel().apply_poison(warded, 3, 0, 1.0)
	_cel().apply_shock(warded, 3, 0, 1.0)
	assert_null(warded.cel)
	game.combat.kill_blow = 0
	_hit(e, ["light"])
	assert_eq(e.cel.poison, 1, "a blow that hurts does")


# ---------- Veneno ----------

func test_poison_one_application_a_blow_the_hold_doubles_and_the_tick_is_its_own_source() -> void:
	_start()
	_take(&"golpe_peste")
	var e := _enemy()
	_hit(e, ["light"])
	_hit(e, ["light"], 10.0, true)
	assert_eq(e.cel.poison, 1, "two contacts of one action: one application")
	_hit(e, ["light"])
	assert_eq(e.cel.poison, 2, "a combo of blows applies once a blow")
	_hit(e, HOLD)
	assert_eq(e.cel.poison, 4, "the held blow: the double of the count")
	assert_almost_eq(e.cel.poison_dps, 0.8, 0.001)
	var before := e.hp
	_run(1.0)
	assert_gt(before - e.hp, 2.5, "four stacks of 0,8 for a second")
	assert_lt(before - e.hp, 3.6)
	assert_almost_eq(_by("veneno"), before - e.hp, 0.5, "dealt by its own name")
	_run(5.0)
	assert_eq(e.cel.poison, 0, "it ran out in five seconds")


func test_poison_renews_the_one_clock_and_takes_a_boss() -> void:
	_start()
	_take(&"golpe_peste")
	var boss := _boss()
	_hit(boss, ["light"])
	assert_eq(boss.cel.poison, 1, "a boss takes poison")
	_run(2.0)
	_hit(boss, ["light"])
	assert_almost_eq(boss.cel.poison_t, 5.0, 0.05, "the clock returns to five, never seven")
	_take(&"peste_persistente")
	_run(1.0)
	_hit(boss, ["light"])
	assert_almost_eq(boss.cel.poison_t, 6.5, 0.05, "30% more, under the ceiling of eight")


func test_saturation_bursts_at_five_takes_two_and_waits_four_seconds() -> void:
	_start()
	_take(&"pesado_peste")
	_take(&"saturacao")
	var e := _enemy()
	var near := _enemy(Vector2(5.0, 0.0))
	_hit(e, ["heavy", "wave"])
	assert_eq(e.cel.poison, 3)
	assert_eq(int(_cel().tally.get(&"saturate", 0)), 0)
	_hit(e, ["heavy", "wave"])
	assert_eq(int(_cel().tally.get(&"saturate", 0)), 1, "five stacks: it bursts")
	assert_eq(e.cel.poison, 3, "five and three more is five, and two are spent")
	assert_gt(_by("saturacao"), 12.0, "the burst on it and half on the one near")
	assert_lt(near.hp, near.max_hp, "half of the burst on the neighbour")
	_hit(e, ["heavy", "wave"])
	assert_eq(int(_cel().tally.get(&"saturate", 0)), 1, "four seconds of recharge on it")
	_run(4.1)
	_hit(e, ["heavy", "wave"])
	assert_eq(int(_cel().tally.get(&"saturate", 0)), 2)


func test_without_saturation_the_five_stacks_only_stay_at_the_ceiling() -> void:
	_start()
	_take(&"pesado_peste")
	var e := _enemy()
	for i in 3:
		_hit(e, ["heavy", "wave"])
	assert_eq(e.cel.poison, 5)
	assert_eq(int(_cel().tally.get(&"saturate", 0)), 0)


func test_deterioration_grows_to_thirty_percent_double_with_a_burn_and_resets() -> void:
	_start()
	_take(&"golpe_peste")
	_take(&"deterioracao")
	var e := _enemy()
	_hit(e, ["light"])
	_run(1.0)
	assert_almost_eq(e.cel.poison_age, 1.0, 0.1)
	e.burn_t = 10.0
	e.burn_dps = 0.1
	_run(1.0)
	assert_almost_eq(e.cel.poison_age, 3.0, 0.2, "twice as fast while it burns")
	_hit(e, ["light"])
	_run(2.0)
	var grow := minf(_cel()._glob(&"cel_poison_grow") * e.cel.poison_age, 0.3)
	assert_almost_eq(grow, 0.3, 0.001, "the +30% is the ceiling")
	e.cel.clear_poison()
	assert_eq(e.cel.poison_age, 0.0, "gone, it starts again")


func test_poison_under_frost_runs_down_half_as_fast_and_never_stops() -> void:
	_start()
	_take(&"golpe_peste")
	_take(&"peste_persistente")
	var e := _enemy()
	_hit(e, ["light"])
	var t0: float = e.cel.poison_t
	e.cel.cold = 1
	e.cel.cold_t = 99.0
	_run(1.0)
	assert_almost_eq(t0 - e.cel.poison_t, 0.5, 0.15, "half of a second a second")
	assert_gt(t0 - e.cel.poison_t, 0.2, "it never stops")


func test_the_three_dots_together_never_pass_sixteen_a_second_and_the_burn_is_not_cut() -> void:
	_start()
	_take(&"golpe_peste")
	var e := _enemy()
	e.burn_t = 10.0
	e.burn_dps = 8.0
	_hit(e, ["light"])
	e.cel.poison = 5
	e.cel.poison_dps = 10.0
	e.cel.poison_t = 6.0
	e.cel.bleed_pool = 100.0
	e.cel.bleed_t = 4.0
	var before := e.hp
	_run(1.0)
	var lost := before - e.hp
	assert_lt(lost, 16.0 + 1.5, "burn 8 plus what is left for the poison and the bleed")
	assert_almost_eq(e.burn_dps, 8.0, 0.001, "the burn is the game's and is never cut")


func test_contagion_copies_once_to_two_and_a_copy_does_not_copy() -> void:
	_start()
	_take(&"golpe_peste")
	_take(&"contagio")
	var a := _enemy(Vector2(4.0, 0.0))
	var b := _enemy(Vector2(5.0, 0.0))
	var c := _enemy(Vector2(5.5, 0.5))
	var d := _enemy(Vector2(6.0, -0.5))
	_hit(a, ["light"])
	_hit(a, ["light"])
	_hit(a, ["light"])
	_hit(a, ["light"])
	_hit(a, ["light"])
	a.alive = false
	_cel().on_killed(a)
	var got := 0
	for o in [b, c, d]:
		if o.cel != null and o.cel.poison > 0:
			got += 1
			assert_eq(o.cel.poison, 3, "half of five, rounded (50%)")
	assert_eq(got, 2, "to two of them")
	for o in [b, c, d]:
		if o.cel != null and o.cel.poison > 0:
			o.alive = false
			var lock: float = o.cel.copy_lock
			assert_gt(lock, 0.0)
			_cel().on_killed(o)
	var still := 0
	for o in [b, c, d]:
		if o.alive and o.cel != null and o.cel.poison > 0:
			still += 1
	assert_eq(still, 0, "the copy did not copy when it died")


# ---------- Sangramento ----------

func test_bleed_is_a_share_of_the_blow_bounded_and_only_on_a_marked_one_from_the_special() -> void:
	_start()
	_take(&"golpe_marca")
	_take(&"pesado_marca")
	var e := _enemy()
	_hit(e, ["heavy", "wave"], 100.0)
	assert_eq(e.cel.bleed_pool, 0.0, "not marked: no bleed")
	_hit(e, ["light"])
	var direct := _dealt(e, ["heavy", "wave"], 100.0)
	assert_almost_eq(e.cel.bleed_pool, direct * 0.4, 1.0, "40% of the blow itself")
	_run(0.5)
	assert_gt(_by("sangramento"), 0.0)
	_run(4.0)
	assert_almost_eq(_by("sangramento"), direct * 0.4, 1.5, "it pays all of it in four seconds")
	assert_eq(e.cel.bleed_pool, 0.0)


func test_the_pool_never_passes_three_shares_and_the_tick_never_crits() -> void:
	_start()
	_take(&"golpe_marca")
	_take(&"pesado_marca")
	var e := _enemy()
	_hit(e, ["light"])
	for i in 6:
		_hit(e, ["heavy", "wave"], 100.0)
	var last := 100.0 * 0.4
	assert_lte(e.cel.bleed_pool, last * 3.0 * 1.2, "three shares of the last blow")
	var crits := int(_cel().tally.get(&"crit", 0))
	_run(3.0)
	assert_eq(int(_cel().tally.get(&"crit", 0)), crits, "a tick rolls no die")


func test_the_army_bleeds_the_marked_and_a_crit_bleeds_once_without_a_bleed() -> void:
	_start()
	_take(&"golpe_marca")
	_take(&"exercito_ecos")
	_take(&"sombra_revelada")
	var e := _enemy()
	_hit(e, ["light"])
	_cel().on_ult()
	assert_gt(_cel().army_t, 0.0)
	var dmg := _dealt(e, ["heavy", "wave"], 100.0)
	assert_almost_eq(e.cel.bleed_pool, dmg * 0.2, 1.0, "20% in the army's window")
	var other := _enemy(Vector2(6.0, 1.0))
	_cel().army_t = 0.0
	_hit(other, ["light"])
	_cel()._hit_crit = 1.5
	var tags: Array[StringName] = [&"light"]
	_key += 1
	game.combat.kill_blow = _key
	_cel().after_hit(other, tags, 40.0, false, false)
	game.combat.kill_blow = 0
	assert_almost_eq(other.cel.bleed_pool, 10.0, 0.5, "a crit on a marked one: 25% of the blow")


# ---------- Eletrificação ----------

func test_shock_a_charge_gives_a_spark_and_stops_at_five_and_a_boss_takes_it_without_a_stun() -> void:
	_start()
	_take(&"golpe_trovao")
	var e := _enemy()
	_hit(e, ["light"])
	assert_eq(e.cel.shock, 1)
	assert_gte(_by("faisca"), 1.0, "a spark a charge, right away")
	var boss := _boss()
	for i in 7:
		_hit(boss, ["light"])
	assert_eq(boss.cel.shock, 5)
	assert_eq(int(_cel().tally.get(&"stun", 0)), 0, "charges stun no one")
	assert_eq(boss.frozen_t, 0.0)


func test_discharge_at_five_clears_the_charges_and_waits_four_seconds() -> void:
	_start()
	_take(&"golpe_trovao")
	_take(&"pesado_trovao")
	_take(&"descarga")
	var e := _enemy()
	_hit(e, ["heavy", "wave"])
	assert_eq(e.cel.shock, 3)
	_hit(e, ["light"])
	_hit(e, ["light"])
	assert_eq(int(_cel().tally.get(&"discharge", 0)), 1, "five charges: the discharge")
	assert_eq(e.cel.shock, 0)
	assert_almost_eq(_by("descarga"), 15.0, 0.5, "3 a charge, five charges")
	assert_gt(e.cel.discharge_cd, 3.5)
	for i in 5:
		_hit(e, ["light"])
	assert_eq(int(_cel().tally.get(&"discharge", 0)), 1, "four seconds of recharge on it")


func test_the_weight_of_thunder_forces_the_discharge_from_three_charges() -> void:
	_start()
	_take(&"golpe_trovao")
	_take(&"pesado_trovao")
	_take(&"descarga")
	var e := _enemy()
	_hit(e, ["light"])
	_hit(e, ["light"])
	_hit(e, ["light"])
	assert_eq(e.cel.shock, 3)
	_hit(e, ["heavy", "wave"])
	assert_eq(int(_cel().tally.get(&"discharge", 0)), 1, "the Especial empties what had three")
	assert_almost_eq(_by("descarga"), 9.0, 0.5, "three charges as they were")
	assert_eq(e.cel.shock, 3, "and puts its own three")


func test_conduction_jumps_with_half_and_no_charges_and_never_again() -> void:
	_start()
	_take(&"pesado_trovao")
	_take(&"descarga")
	_take(&"conducao")
	var e := _enemy()
	var a := _enemy(Vector2(5.0, 0.0))
	var b := _enemy(Vector2(6.0, 0.0))
	var far := _enemy(Vector2(12.0, 0.0))
	_hit(e, ["heavy", "wave"])
	_hit(e, ["heavy", "wave"])
	assert_eq(int(_cel().tally.get(&"discharge", 0)), 1)
	assert_eq(int(_cel().tally.get(&"conduct", 0)), 1)
	assert_gt(_by("conducao"), 0.0)
	assert_lt(a.hp, a.max_hp)
	assert_lt(b.hp, b.max_hp)
	assert_eq(far.hp, far.max_hp, "out of the reach")
	assert_true(a.cel == null or a.cel.shock == 0, "the jump carries no charges")
	assert_eq(int(_cel().tally.get(&"discharge", 0)), 1, "a conduction never discharges")


func test_overload_charges_whoever_is_charged_and_has_a_dot_and_may_set_off_the_discharge() -> void:
	_start()
	_take(&"golpe_trovao")
	_take(&"sobrecarga")
	_take(&"descarga")
	var e := _enemy()
	_hit(e, ["light"])
	_run(2.0)
	assert_eq(e.cel.shock, 1, "no DoT on it: no overload")
	e.burn_t = 30.0
	e.burn_dps = 0.1
	_run(1.0)
	_hit(e, ["light"])
	var before: int = e.cel.shock
	_run(2.0)
	assert_gt(int(_cel().tally.get(&"overload", 0)), 0, "with a burn it charges by itself")
	e.cel.shock = 4
	e.cel.over_acc = 0.9
	_run(0.6)
	assert_eq(int(_cel().tally.get(&"discharge", 0)) >= 1, true, "tick, overload, discharge")
	assert_gte(before, 1)


func test_resonance_adds_a_tenth_for_each_charged_neighbour() -> void:
	_start()
	_take(&"golpe_trovao")
	_take(&"descarga")
	_take(&"ressonancia_eletrica")
	var e := _enemy()
	var near := _enemy(Vector2(5.0, 0.0))
	near.cel = CelState.new()
	near.cel.shock = 2
	near.cel.shock_t = 6.0
	_cel()._tracked.append(near)
	e.cel = CelState.new()
	e.cel.shock = 4
	e.cel.shock_t = 6.0
	_cel()._tracked.append(e)
	_hit(e, ["light"])
	assert_almost_eq(_by("descarga"), 15.0 * 1.1, 0.8, "5 charges of 3 and 10% for the neighbour")


# ---------- antecipação ----------

func test_the_anticipation_brings_forward_a_share_and_takes_the_same_share_out_of_the_burn() -> void:
	_start()
	_take(&"golpe_brasa")
	_take(&"pesado_brasa")
	var e := _enemy()
	_hit(e, ["light"])
	var owed: float = e.burn_dps * e.burn_t
	var t0 := e.burn_t
	_hit(e, ["heavy", "wave"])
	assert_almost_eq(_by("antecipacao"), owed * 0.5, 0.8, "half of what was owed")
	assert_almost_eq(e.burn_t, 3.0, 0.001, "and then the new burn renews the time (antecipate first, apply after)")
	assert_almost_eq(e.burn_dps, 5.0, 0.001)
	assert_gt(t0, 2.9)
	_hit(e, ["heavy", "wave"])
	assert_eq(int(_cel().tally.get(&"antic", 0)), 1, "two seconds of recharge on that enemy")


func test_a_burn_antecipated_is_shortened_by_the_same_share() -> void:
	_start()
	_take(&"golpe_brasa")
	var e := _enemy()
	_hit(e, ["light"])
	e.burn_t = 2.0
	var chain := CelChain.new(900)
	var hp0 := e.hp
	_cel()._antic(e, 0.5, false, chain)
	assert_almost_eq(e.burn_t, 1.0, 0.001)
	assert_almost_eq(_by("antecipacao"), 3.5, 0.6, "half of 3,5 times two seconds")
	assert_almost_eq(e.hp, hp0 - _by("antecipacao"), 1.0, "nothing else was paid")


func test_combustion_splashes_a_half_and_brings_forward_a_fifth_of_every_dot() -> void:
	_start()
	_take(&"golpe_brasa")
	_take(&"combustao")
	var e := _enemy()
	var near := _enemy(Vector2(5.0, 0.0))
	var far := _enemy(Vector2(9.0, 0.0))
	_hit(e, ["light"])
	_hit(e, ["light"])
	e.cel.add_poison(2, 5.0, 2.0)
	_hit(e, ["light"])
	assert_eq(int(_cel().tally.get(&"combustion", 0)), 1)
	assert_almost_eq(near.max_hp - near.hp, 4.5, 1.1, "half of the 9 on the one near")
	assert_eq(far.hp, far.max_hp)
	assert_gt(_by("antecipacao"), 0.0, "20% of the burn and the poison it owed")
	assert_lt(e.cel.poison_t, 5.0, "taken out of the poison as well")


# ---------- propagação ----------

func test_the_gust_copies_a_share_to_one_neighbour_and_the_copy_does_not_copy() -> void:
	_start()
	_take(&"golpe_brasa")
	var e := _enemy()
	var a := _enemy(Vector2(5.0, 0.0))
	var b := _enemy(Vector2(6.0, 0.0))
	_hit(e, ["light"])
	_cel().spread(e, 0.3, -77)
	assert_gt(a.burn_t, 0.0, "the nearest takes it")
	assert_almost_eq(a.burn_dps, 3.5 * 0.3, 0.01)
	assert_gte(a.burn_t, 1.4, "half of the time (at least two seconds: a second min)")
	assert_eq(b.burn_t, 0.0, "one neighbour a hit")
	_cel().spread(a, 0.3, -77)
	assert_eq(b.burn_t, 0.0, "a copy does not copy (the lock)")


func test_a_gust_makes_at_most_four_copies() -> void:
	_start()
	_take(&"golpe_brasa")
	var sources: Array[Enemy] = []
	var targets: Array[Enemy] = []
	for i in 6:
		var s := _enemy(Vector2(4.0 + i * 8.0, 0.0))
		targets.append(_enemy(Vector2(5.0 + i * 8.0, 0.0)))
		_hit(s, ["light"])
		sources.append(s)
	for s in sources:
		_cel().spread(s, 0.3, -5)
	var burning := 0
	for t in targets:
		if t.burn_t > 0.0:
			burning += 1
	assert_eq(burning, CelRules.GUST_COPIES, "four copies a gust")


func test_the_whirl_spreads_to_at_most_two_and_marca_persistente_passes_once() -> void:
	_start()
	_take(&"golpe_marca")
	_take(&"marca_persistente")
	var e := _enemy()
	var next := _enemy(Vector2(6.0, 0.0))
	_hit(e, ["light"])
	assert_gt(e.cel.mark_t, 0.0)
	e.alive = false
	_cel().on_killed(e)
	assert_gt(next.cel.mark_t, 0.0, "the Mark passes to the nearest")
	var third := _enemy(Vector2(7.0, 0.0))
	next.alive = false
	_cel().on_killed(next)
	assert_true(third.cel == null or third.cel.mark_t <= 0.0, "what passed does not pass again")


# ---------- the Abertura ----------

func test_cold_fills_the_boss_meter_and_opens_a_window_of_a_quarter_more_without_touching_him() -> void:
	_start()
	_take(&"golpe_geada")
	var boss := _boss()
	var plain := _dealt(_boss(), ["light"], 100.0)
	for i in 7:
		_hit(boss, ["light"])
	assert_eq(boss.cel.window_t, 0.0)
	_hit(boss, ["light"])
	assert_gt(boss.cel.window_t, 3.0, "eight points of Frio")
	assert_eq(boss.frozen_t, 0.0, "he does not freeze")
	assert_eq(int(_cel().tally.get(&"stun", 0)), 0)
	assert_eq(boss.broken_t, 0.0, "his poise is untouched")
	var open := _dealt(boss, ["heavy", "wave"], 100.0)
	var closed := _dealt(_boss(), ["heavy", "wave"], 100.0)
	assert_almost_eq(open / closed, 1.25, 0.05, "+25% in the window")
	_run(4.2)
	assert_eq(boss.cel.window_t, 0.0)
	for i in 10:
		_hit(boss, ["light"])
	assert_eq(boss.cel.window_t, 0.0, "ten seconds of rest: the meter does not fill")
	assert_gt(plain, 0.0)


func test_a_guardian_fills_only_with_impact_and_an_elite_not_at_all() -> void:
	_start()
	_take(&"golpe_firme")
	var g := _guardian()
	for i in 9:
		_hit(g, ["light"])
	assert_eq(g.cel.window_t, 0.0)
	_hit(g, ["light"])
	assert_gt(g.cel.window_t, 3.0, "ten points of Impacto")
	assert_eq(int(_cel().tally.get(&"stun", 0)), 0, "nothing is stunned")
	var elite := _enemy(Vector2(7.0, 0.0))
	elite.def = elite.def.duplicate()
	elite.def.elite = true
	for i in 12:
		_hit(elite, ["light"])
	assert_eq(elite.cel.window_t, 0.0, "the elite stays as it was")
	assert_eq(elite.cel.meter_i, 0)
	# the guardian's frost is the one it had (no meter of Frio)
	var gc := _guardian()
	_cel().apply_cold(gc, 9, 0)
	assert_eq(gc.cel.meter_c, 0)


func test_the_forca_inabalavel_counts_the_window_as_stunned_and_summed_not_multiplied() -> void:
	_start()
	_take(&"golpe_firme")
	_take(&"forca_inabalavel")
	var boss := _boss()
	for i in 10:
		_hit(boss, ["light"])
	assert_gt(boss.cel.window_t, 0.0)
	var open := _dealt(boss, ["heavy", "wave"], 100.0)
	var closed := _dealt(_boss(), ["heavy", "wave"], 100.0)
	assert_almost_eq(open / closed, 1.0 + 0.25 + 0.3, 0.06, "one sum: +25% and +30%")


func test_the_estilhacamento_fires_on_the_first_blow_of_the_window() -> void:
	_start()
	_take(&"golpe_geada")
	_take(&"estilhaco")
	var boss := _boss()
	for i in 8:
		_hit(boss, ["light"])
	var first := _dealt(boss, ["heavy", "wave"], 100.0)
	var second := _dealt(boss, ["heavy", "wave"], 100.0)
	assert_gt(first / second, 1.3, "the first one shatters (+40%) and only once")


# ---------- Vigília, Nivael ----------

func test_amparo_gives_points_when_the_shield_is_spent_and_not_when_it_runs_out() -> void:
	_start()
	_take(&"passo_firme")
	_take(&"amparo")
	_take(&"golpe_firme")
	var cel := _cel()
	game.player.shield_ready = false
	cel.on_dodge()
	assert_true(game.player.shield_ready)
	game.player.shield_ready = false  # the blow took it
	cel.step(DT)
	assert_gt(cel.guard_bonus_t, 0.0)
	var e := _enemy()
	cel.apply_impact(e, 1, 0)
	assert_eq(e.cel.impact, 3, "one point and two more of the shield")
	cel.apply_impact(e, 1, 0)
	assert_eq(e.cel.impact, 4, "only the first Impact")
	cel.step(8.0)
	cel.on_dodge()
	cel.step(2.0)
	assert_false(game.player.shield_ready, "it ran out")
	assert_eq(cel.guard_bonus_t, 0.0, "an expired shield gives nothing")


func test_the_pulse_of_the_stun_passes_a_point_to_three_neighbours_and_never_stuns_by_itself() -> void:
	_start()
	_take(&"golpe_firme")
	_take(&"forca_inabalavel")
	var e := _enemy()
	var near: Array[Enemy] = []
	for i in 4:
		near.append(_enemy(Vector2(4.5 + i * 0.3, 0.4)))
	_cel().apply_impact(e, 5, 0)
	var got := 0
	for o in near:
		if o.cel != null and o.cel.impact == 1:
			got += 1
	assert_eq(got, 3, "one point to three")
	assert_eq(int(_cel().tally.get(&"stun", 0)), 1, "the pulse alone stunned no one")


func test_geada_profunda_gives_a_point_of_impact_to_whoever_has_frost() -> void:
	_start()
	_take(&"golpe_geada")
	_take(&"circulo_firme")
	_take(&"geada_profunda")
	var e := _enemy()
	_cel().apply_impact(e, 1, 0)
	assert_eq(e.cel.impact, 1)
	_cel().apply_cold(e, 1, 0)
	_cel().apply_impact(e, 1, 0)
	assert_eq(e.cel.impact, 3, "with frost: a point more")


func test_the_winter_prolonged_keeps_the_dots_a_second_and_the_estilhaco_throws_fragments() -> void:
	_start()
	_take(&"golpe_geada")
	_take(&"inverno_prolongado")
	var e := _enemy()
	e.burn_t = 2.0
	e.burn_dps = 3.0
	_cel().apply_cold(e, 3, 0)
	assert_almost_eq(e.burn_t, 3.0, 0.001, "a second more when it freezes")
	_start()
	_take(&"toque_geada")
	_take(&"estilhaco")
	var f := _enemy()
	var near := _enemy(Vector2(5.0, 0.0))
	var far := _enemy(Vector2(10.0, 0.0))
	_cel().apply_cold(f, 3, 0)
	assert_true(f.cel.shatterable())
	var dmg := _dealt(f, ["heavy", "wave"], 100.0)
	assert_gt(dmg, 130.0, "the shatter: 40% more")
	assert_gt(near.max_hp - near.hp, 0.0, "a fragment on the one near")
	assert_eq(far.hp, far.max_hp)
	assert_eq(int(_cel().tally.get(&"frag", 0)), 1)


# ---------- Velael, Galael, Qeshael ----------

func test_crepusculo_prolongs_the_conditions_and_veu_persistente_does_on_a_renewal() -> void:
	_start()
	_take(&"golpe_veu")
	_take(&"crepusculo")
	var e := _enemy()
	e.burn_t = 2.0
	e.burn_dps = 3.0
	var tags: Array[StringName] = [&"skill", &"veu", &"crepusculo"]
	game.combat.skill_hit(e, 0.0, tags, Vector2.RIGHT, 0.0, &"weak", 5.0)
	assert_almost_eq(e.burn_t, 4.0, 0.001, "two seconds more")
	_take(&"veu_persistente")
	var f := _enemy(Vector2(7.0, 0.0))
	f.burn_t = 2.0
	f.burn_dps = 3.0
	_hit(f, ["light"])
	assert_almost_eq(f.burn_t, 2.0, 0.001, "the first weakening only weakens")
	_hit(f, ["light"])
	assert_almost_eq(f.burn_t, 3.0, 0.001, "the renewal prolongs the others by one second")


func test_vulnerability_and_the_fire_grow_with_the_conditions_up_to_three() -> void:
	_start()
	_take(&"golpe_veu")
	_take(&"vulnerabilidade")
	var e := _enemy()
	var plain := _dealt(_enemy(Vector2(9.0, 0.0)), ["heavy", "wave"], 100.0)
	_hit(e, ["light"])
	e.cel.add_poison(1, 5.0, 1.0)
	e.cel.mark_t = 5.0
	e.cel.shock = 1
	e.cel.shock_t = 5.0
	e.cel.cold = 1
	e.cel.cold_t = 5.0
	var more := _dealt(e, ["heavy", "wave"], 100.0)
	assert_almost_eq(more / plain, 1.0 + 0.15 + 0.03 * 3.0, 0.05, "15% and 3% a condition, up to three")
	_start()
	_take(&"golpe_brasa")
	_take(&"fogo_crescente")
	var f := _enemy()
	f.cel = CelState.new()
	_cel()._tracked.append(f)
	f.cel.mark_t = 5.0
	f.cel.add_poison(1, 5.0, 1.0)
	_hit(f, ["light"])
	assert_almost_eq(f.burn_dps, 3.5 * (1.0 + 0.2 + 0.05 * 2.0), 0.01, "two other conditions")
	_hit(f, ["light"])
	assert_almost_eq(f.burn_dps, 3.5 * 1.3, 0.01, "the burn itself is no 'another'")


func test_essence_gives_two_mana_with_three_conditions() -> void:
	_start()
	_take(&"golpe_veu")
	_take(&"essencia_restauradora")
	game.player.magick.value = 0.0
	var e := _enemy()
	_hit(e, ["light"])
	e.cel.add_poison(1, 5.0, 1.0)
	e.cel.mark_t = 5.0
	e.cel.shock = 1
	e.cel.shock_t = 5.0
	_cel().on_killed(e)
	assert_almost_eq(game.player.magick.value, 2.0, 0.001)


func test_flow_gives_a_stack_more_for_another_button_and_not_for_the_same() -> void:
	_start()
	_take(&"golpe_mare")
	_take(&"cadencia")
	_take(&"fluxo_continuo")
	var cel := _cel()
	var node := ComboNode.new()
	node.tags = [&"light"]
	cel.on_action(node)
	assert_eq(cel.cadence, 1, "the first has no button before it")
	cel.on_action(node)
	assert_eq(cel.cadence, 2, "the same button: one")
	var heavy := ComboNode.new()
	heavy.tags = [&"heavy"]
	cel.on_action(heavy)
	assert_eq(cel.cadence, 4, "another button: one more")


func test_the_hold_of_the_held_blow_doubles_counts_and_a_half_the_rates() -> void:
	_start()
	_take(&"golpe_brasa")
	var e := _enemy()
	_hit(e, HOLD)
	assert_almost_eq(e.burn_dps, 3.5 * 1.5, 0.001)
	_start()
	_take(&"golpe_trovao")
	var f := _enemy()
	_hit(f, HOLD)
	assert_eq(f.cel.shock, 2)
	_start()
	_take(&"golpe_geada")
	var g := _enemy()
	_hit(g, HOLD)
	assert_eq(g.cel.cold, 2)


func test_a_crit_makes_the_applications_of_that_blow_stronger_only() -> void:
	_start()
	_take(&"circulo_radiante")
	_take(&"esplendor")
	_take(&"golpe_peste")
	var e := _enemy()
	var tags: Array[StringName] = [&"light"]
	_cel()._hit_crit = 1.5
	_key += 1
	game.combat.kill_blow = _key
	_cel().after_hit(e, tags, 10.0, false, false)
	assert_eq(e.cel.poison, 2, "a stack more on the crit")
	assert_almost_eq(e.cel.poison_dps, 0.8 * 1.5, 0.001, "and 50% stronger")
	var f := _enemy(Vector2(6.0, 0.0))
	_key += 1
	game.combat.kill_blow = _key
	_cel()._hit_crit = 1.0
	_cel().after_hit(f, tags, 10.0, false, false)
	game.combat.kill_blow = 0
	assert_eq(f.cel.poison, 1, "the next blow, not a crit, does not inherit it")
	assert_almost_eq(f.cel.poison_dps, 0.8, 0.001)


# ---------- zones, skills ----------

func test_the_plague_zone_gives_one_stack_a_second_and_the_skills_apply() -> void:
	_start()
	_take(&"circulo_peste")
	var e := _enemy(Vector2(1.0, 0.0))
	var z := game.ground.add_zone(Ground.Kind.PLAGUE, Vector2.ZERO, 2.5, 4.0, 1.0)
	game.combat.on_zone_hit(e, z)
	game.combat.on_zone_hit(e, z)
	assert_eq(e.cel.poison, 1, "a stack a second: the second touch is inside the gap")
	_run(1.1)
	game.combat.on_zone_hit(e, z)
	assert_eq(e.cel.poison, 2)
	assert_eq(e.cel.poison_dps, 1.0)
	assert_eq(e.hp, e.max_hp - _by("veneno"), "the zone itself deals no contact damage")
	_start()
	_take(&"epidemia_celestial")
	var a := _enemy(Vector2(3.0, 0.0))
	game.skills.trigger(SkillDef.Trigger.ULT)
	assert_eq(a.cel.poison, 3, "three stacks")
	_start()
	_take(&"tempestade_celestial")
	var b := _enemy(Vector2(3.0, 0.0))
	game.skills.trigger(SkillDef.Trigger.ULT)
	for i in 90:
		game.skills.step(DT)
		_run(DT)
	assert_eq(b.cel.shock, 2, "two charges from a ray (one ray on the only one near)")


func test_the_dodge_trail_of_peste_lays_poison_ground() -> void:
	_start()
	_take(&"passo_peste")
	assert_almost_eq(game.boons.stat(&"dodge_plague_dps"), 1.0, 0.001)
	var before := game.ground.zones.size()
	game.call(&"_on_dodged", Vector2.RIGHT)
	var plague := 0
	for z in game.ground.zones:
		if z.kind == Ground.Kind.PLAGUE:
			plague += 1
	assert_eq(plague, 3, "three patches of the trail")
	assert_gte(game.ground.zones.size(), before + 3)


# ---------- the budget ----------

func test_the_budget_of_an_action_and_of_a_frame() -> void:
	_start()
	_take(&"golpe_peste")
	var cel := _cel()
	var direct := CelChain.new(31)
	var made := 0
	for i in 12:
		if cel._go(direct, &"echo") != null:
			made += 1
	assert_eq(made, CelRules.ACTION_REACT_CAP, "eight reactions an action")
	cel.step(DT)
	var frame := 0
	for i in 40:
		if cel._go(CelChain.new(100 + i), &"echo") != null:
			frame += 1
	assert_eq(frame, CelRules.FRAME_REACT_CAP, "twenty four a frame")
	assert_gt(int(cel.tally.get(&"blocked", 0)), 0, "what was refused is counted")
	assert_lte(cel._neighbours(_enemy(), 50.0, 99).size(), 0, "no neighbour of a lone one")


# ---------- the Maga ----------

func test_the_maga_carries_the_new_blessings_without_an_error() -> void:
	_start("maga")
	for id: StringName in [&"golpe_peste", &"golpe_trovao", &"descarga", &"saturacao", &"pesado_marca", &"golpe_marca"]:
		var b := game.boons.find(id)
		if game.boons.offerable(b) or b.slot == Boon.Slot.NONE:
			_take(id)
	var e := _enemy()
	_hit(e, ["light", "bolt", "arcane", "fire"])
	_hit(e, ["heavy", "bolt", "arcane", "ice"])
	_run(2.0)
	assert_gt(int(_cel().tally.size()), 0)
	assert_eq(game.arcane.book.keys().size(), 0, "her own book of elements is untouched")
