extends GutTest
## Blessings V2 (docs/design/bencaos_v2/IMPLEMENTACAO_V2.md 6): the pure rules, in CelRules, CelState and CelChain: Veneno,
## Sangramento, Eletrificação, the anticipation, the lineage and its budget, the meters of the Abertura, the held blow.


func test_the_held_blow_counts_double_and_rates_one_and_a_half() -> void:
	assert_eq(CelRules.hold_count(3.0, true), 6.0)
	assert_eq(CelRules.hold_count(3.0, false), 3.0)
	assert_eq(CelRules.hold_rate(4.0, true), 6.0)
	assert_eq(CelRules.hold_rate(4.0, false), 4.0)


# ---------- Veneno ----------

func test_poison_stops_at_five_stacks_and_one_clock_returns_never_adds() -> void:
	var st := CelState.new()
	st.add_poison(3, 5.0, 1.0)
	st.add_poison(4, 5.0, 1.0)
	assert_eq(st.poison, CelRules.POISON_MAX)
	st.step(2.0)
	st.poison_t -= 0.0
	st.add_poison(1, 5.0, 0.5)
	assert_almost_eq(st.poison_t, 5.0, 0.001, "renewed to the full time, not 3 + 5")
	assert_almost_eq(st.poison_dps, 1.0, 0.001, "the greater DPS stays while it lasts")
	st.add_poison(1, 20.0, 1.0)
	assert_almost_eq(st.poison_t, CelRules.POISON_TIME_MAX, 0.001, "the clock stops at its ceiling")
	st.clear_poison()
	assert_eq(st.poison, 0)
	st.add_poison(1, 5.0, 0.4)
	assert_almost_eq(st.poison_dps, 0.4, 0.001, "gone, it starts over at its own DPS")


func test_poison_tick_grows_only_to_thirty_percent() -> void:
	assert_almost_eq(CelRules.poison_tick(2, 1.0, 0.0), 1.0, 0.001, "two stacks of 1 a second, half a second")
	assert_almost_eq(CelRules.poison_tick(2, 1.0, 0.2), 1.2, 0.001)
	assert_almost_eq(CelRules.poison_tick(2, 1.0, 5.0), 1.3, 0.001, "the growth stops at +30%")


func test_dot_cap_shrinks_poison_and_bleed_and_never_the_burn() -> void:
	assert_eq(CelRules.dot_scale(4.0, 5.0, 5.0), 1.0, "4 + 10 fits in 16")
	assert_almost_eq(CelRules.dot_scale(6.0, 10.0, 10.0), 0.5, 0.001, "6 + 20 over 16: the other two take half")
	assert_eq(CelRules.dot_scale(20.0, 3.0, 0.0), 0.0, "a burn over the ceiling leaves no room (it is not cut)")
	assert_eq(CelRules.dot_scale(5.0, 0.0, 0.0), 1.0)


# ---------- Sangramento ----------

func test_bleed_is_proportional_and_the_pool_holds_three_shares() -> void:
	assert_almost_eq(CelRules.bleed_add(0.4, 150.0) / CelRules.bleed_add(0.4, 10.0), 15.0, 0.001, "a thrust of 150 bleeds 15 times a blow of 10")
	assert_almost_eq(CelRules.bleed_add(2.0, 100.0), 80.0, 0.001, "the share stops at 80%")
	var st := CelState.new()
	st.add_bleed(10.0)
	st.add_bleed(10.0)
	st.add_bleed(10.0)
	st.add_bleed(10.0)
	st.add_bleed(10.0)
	assert_almost_eq(st.bleed_pool, 30.0, 0.001, "never past three shares of the last blow")


func test_the_bleed_tick_empties_the_pool_in_its_time_and_the_rest_goes() -> void:
	var st := CelState.new()
	st.add_bleed(40.0)
	var paid := 0.0
	for i in 8:
		paid += st.bleed_tick(0.5)
	assert_almost_eq(paid, 40.0, 0.01, "four seconds pay it all")
	assert_almost_eq(st.bleed_pool, 0.0, 0.01)
	assert_eq(st.bleed_tick(0.5), 0.0)


# ---------- Eletrificação ----------

func test_shock_five_charges_a_window_that_renews_and_a_discharge_with_resonance() -> void:
	var st := CelState.new()
	st.add_shock(3)
	st.add_shock(4)
	assert_eq(st.shock, CelRules.SHOCK_MAX)
	st.step(5.0)
	assert_eq(st.shock, 5, "the window is 6 s")
	st.add_shock(1)
	assert_almost_eq(st.shock_t, CelRules.SHOCK_WINDOW, 0.001, "renewed to the ceiling, not added")
	st.step(6.1)
	assert_eq(st.shock, 0)
	assert_almost_eq(CelRules.discharge_dmg(3.0, 5, 0.0, 0), 15.0, 0.001, "15 at level 1, common")
	assert_almost_eq(CelRules.discharge_dmg(3.0, 5, 0.1, 2), 18.0, 0.001, "10% for each charged neighbour")
	assert_almost_eq(CelRules.discharge_dmg(3.0, 5, 0.1, 9), 21.0, 0.001, "the neighbours stop at four: +40%")


# ---------- anticipation ----------

func test_anticipation_takes_from_what_remains_and_pays_nothing_twice() -> void:
	var r := CelRules.anticipate(40.0, 0.25)
	assert_almost_eq(r[0], 10.0, 0.001)
	assert_almost_eq(r[1], 30.0, 0.001)
	assert_almost_eq(r[0] + r[1], 40.0, 0.001, "paid now plus what is left: the total before")
	assert_almost_eq(CelRules.anticipate(40.0, 5.0)[1], 0.0, 0.001, "never more than all")


# ---------- the lineage ----------

func test_the_lineage_allows_only_the_edges_of_the_table() -> void:
	var direct := CelChain.new(1)
	for kind: StringName in [&"combust", &"shatter", &"saturate", &"discharge", &"echo", &"whirl", &"rupture", &"antic", &"copy"]:
		assert_true(direct.may(kind), "direct to %s" % kind)
	assert_false(direct.may(&"conduct"), "no conduction of a direct blow")
	assert_false(direct.may(&"overload"))
	assert_false(direct.may(&"direct"), "nothing goes back to a direct blow")
	assert_false(direct.enter(&"echo").may(&"echo"), "no echo of an echo")
	assert_false(direct.enter(&"copy").may(&"copy"), "no copy of a copy")
	assert_false(direct.enter(&"discharge").may(&"discharge"), "no discharge of a discharge")
	var discharge := direct.enter(&"discharge")
	assert_true(discharge.may(&"conduct"))
	assert_false(discharge.enter(&"conduct").may(&"conduct"), "no conduction of a conduction")
	assert_false(direct.enter(&"shatter").enter(&"frag").may(&"copy"), "a fragment goes nowhere")
	assert_false(direct.enter(&"antic").may(&"antic"), "an anticipation goes nowhere")
	assert_false(direct.enter(&"antic").may(&"copy"))
	assert_null(direct.enter(&"conduct"), "an edge out of the table gives no event")
	assert_true(direct.enter(&"combust").may(&"antic"))
	assert_true(direct.enter(&"rupture").may(&"pulse"))


func test_the_longest_lineage_is_tick_overload_discharge_conduct_and_depth_three_is_the_ceiling() -> void:
	var tick := CelChain.new(0, &"tick")
	var overload := tick.enter(&"overload")
	assert_not_null(overload)
	var discharge := overload.enter(&"discharge")
	assert_not_null(discharge)
	var conduct := discharge.enter(&"conduct")
	assert_not_null(conduct)
	assert_eq(conduct.depth, CelRules.CHAIN_DEPTH)
	for kind in CelRules.EDGES.keys():
		assert_false(conduct.may(kind), "past the depth nothing follows")
	assert_false(CelRules.may_chain(&"discharge", &"conduct", CelRules.CHAIN_DEPTH))


# ---------- the meters of the Abertura ----------

func test_the_cold_meter_fills_in_eight_and_the_impact_meter_in_ten() -> void:
	var st := CelState.new()
	assert_false(st.add_meter(&"c", 7, CelRules.METER_COLD))
	assert_true(st.add_meter(&"c", 1, CelRules.METER_COLD))
	assert_almost_eq(st.window_t, CelRules.WINDOW_TIME, 0.001)
	var st2 := CelState.new()
	assert_false(st2.add_meter(&"i", 9, CelRules.METER_IMPACT))
	assert_true(st2.add_meter(&"i", 1, CelRules.METER_IMPACT))
	var st3 := CelState.new()
	assert_true(st3.add_meter(&"i", 8, CelRules.METER_IMPACT - 2), "Ruptura: the meter is two points shorter")


func test_the_window_is_four_seconds_then_ten_without_points() -> void:
	var st := CelState.new()
	assert_true(st.add_meter(&"c", 8, CelRules.METER_COLD))
	assert_true(st.shatterable(), "the first blow of the Abertura shatters")
	st.step(3.9)
	assert_gt(st.window_t, 0.0)
	assert_false(st.add_meter(&"c", 100, CelRules.METER_COLD), "no points while it rests")
	assert_eq(st.meter_c, 0)
	st.step(0.2)
	assert_eq(st.window_t, 0.0, "four seconds")
	assert_false(st.add_meter(&"i", 100, CelRules.METER_IMPACT), "still resting for ten more")
	st.step(CelRules.WINDOW_LOCK)
	assert_true(st.add_meter(&"i", 10, CelRules.METER_IMPACT), "ten seconds later it sums again")


func test_a_meter_that_is_left_alone_empties_in_eight_seconds() -> void:
	var st := CelState.new()
	st.add_meter(&"c", 5, CelRules.METER_COLD)
	st.step(CelRules.METER_WINDOW + 0.1)
	assert_eq(st.meter_c, 0)


func test_only_a_boss_or_a_guardian_has_a_meter() -> void:
	var boss := EnemyDef.new()
	boss.behavior = EnemyDef.Behavior.BOSS
	var guardian := EnemyDef.new()
	guardian.heavy = true
	var elite := EnemyDef.new()
	elite.elite = true
	assert_true(CelRules.meter_target(boss))
	assert_true(CelRules.meter_target(guardian))
	assert_false(CelRules.meter_target(elite))
	assert_false(CelRules.meter_target(EnemyDef.new()))
