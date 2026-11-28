extends GutTest
## Maga Redesign V1 (docs/design/heroes/maga_redesign_v1_pack/, docs/design/heroes/maga_redesign_v1.md): the fan of three, the cone, the
## spells that grow while held and strike on the release (Mana paid then, area grown by the hold and capped by the Mana), the reactions
## in every order with their limits, the Tempestade Celestial's route, the HUD's four squares and the old saves. The pure rules (ComboNode's
## release charge, ArcaneKit.fan, ChainPlan) are tested bare; the rest in a run.

const DT := 1.0 / 60.0
const F := ElementBook.FIRE
const I := ElementBook.ICE
const V := ElementBook.VOLT

var game: Game
var pad := Controls.VirtualPad.new()
var strikes: Array[StringName] = []


func after_each() -> void:
	Controls.virtual = null
	Controls.clear_presses()
	Dev.drop("hero")
	strikes.clear()


func _start() -> void:
	Dev.put("hero", "maga")
	game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	game.rooms.start_at(RunMap.Kind.FOUNTAIN)
	game.horde.clear_crowd()
	for e in game.horde.list.duplicate():
		e.alive = false
	game.horde.list.clear()
	Controls.virtual = pad
	pad.aim = Vector2.RIGHT
	game.player.pos = Vector2.ZERO
	game.player.facing = Vector2.RIGHT
	game.player.magick.value = 50.0
	game.ults.equip(HeroDef.maga().ultimates[0])
	game.player.struck.connect(func(node: ComboNode, _o: Vector2, _d: Vector2) -> void: strikes.append(node.id))
	_step(2)


func _step(n := 1) -> void:
	for i in n:
		game._step(DT)
		pad.end_frame()
		for a: StringName in pad.held.keys():
			pad.release(a)
		pad.released.clear()


## The button down for `frames` frames (no release): the charge grows.
func _hold_down(action: StringName, frames: int) -> void:
	for i in frames:
		pad.press(action)
		game._step(DT)
		pad.end_frame()


## Lets go of the button and plays a second.
func _let_go(action: StringName) -> void:
	pad.release(action)
	pad.released.clear()
	_step(60)


func _dummy(at: Vector2, id := &"skeleton") -> Enemy:
	var e := game.horde.spawn(game.horde.def(id), at, false)
	e.hp = 5000.0
	e.max_hp = 5000.0
	e.cooldown = 999.0
	e.stun_t = 1000.0
	return e


func _boss(at: Vector2) -> Enemy:
	var d := game.horde.def(&"skeleton").duplicate() as EnemyDef
	d.behavior = EnemyDef.Behavior.BOSS
	var e := game.horde.spawn(d, at, false)
	e.hp = 5000.0
	e.max_hp = 5000.0
	e.cooldown = 999.0
	e.stun_t = 1000.0
	return e


func _node(input: ComboNode.In) -> ComboNode:
	return ComboTree.find((load(HeroDef.maga().combos) as ComboTree).neutral, input)


func _friendly(kind := Projectiles.Kind.SPARK) -> Array[Projectiles.Shot]:
	var out: Array[Projectiles.Shot] = []
	for s in game.projectiles.shots:
		if not Projectiles.hostile(s) and s.kind == kind:
			out.append(s)
	return out


# ---------- the pure rules ----------

func test_a_fan_opens_evenly_around_the_aim() -> void:
	var way := ArcaneKit.fan(Vector2.RIGHT, 3, 24.0)
	assert_eq(way.size(), 3)
	assert_almost_eq(rad_to_deg(Vector2.RIGHT.angle_to(way[0])), -12.0, 0.01)
	assert_almost_eq(rad_to_deg(Vector2.RIGHT.angle_to(way[1])), 0.0, 0.01)
	assert_almost_eq(rad_to_deg(Vector2.RIGHT.angle_to(way[2])), 12.0, 0.01)
	assert_eq(ArcaneKit.fan(Vector2.UP, 1, 24.0), [Vector2.UP] as Array[Vector2], "one shot goes straight")


func test_the_release_charge_grows_between_the_least_and_the_most() -> void:
	var c := _node(ComboNode.In.CHARGE_LIGHT)
	assert_true(c.is_release())
	assert_eq([c.charge_share(0.3), c.charge_share(0.6), c.charge_share(1.5), c.charge_share(9.0)], [0.0, 0.0, 1.0, 1.0], "never grows past its full")
	assert_almost_eq(c.charge_share(1.05), 0.5, 0.001)
	assert_eq([c.power_at(0.0), c.power_at(1.0), c.area_at(0.0), c.area_at(1.0), c.cost_at(0.0), c.cost_at(1.0)], [50.0, 150.0, 1.5, 3.5, 15.0, 25.0])
	var w := _node(ComboNode.In.CHARGE)
	assert_eq([w.charge_time, w.charge_max, w.area_at(0.0), w.area_at(1.0), w.cost_at(0.0), w.cost_at(1.0)], [0.6, 1.8, 2.0, 6.0, 10.0, 30.0])
	assert_false(_node(ComboNode.In.LIGHT).is_release(), "a tap has no charge")


func test_the_mana_caps_the_growth_it_can_pay() -> void:
	var c := _node(ComboNode.In.CHARGE_LIGHT)
	assert_eq(c.afford_share(14.0), 0.0, "short of the least: nothing")
	assert_almost_eq(c.afford_share(20.0), 0.5, 0.001)
	assert_eq(c.afford_share(25.0), 1.0)
	assert_eq(c.afford_share(50.0), 1.0)
	assert_almost_eq(c.afford_share(20.0, 2.0), 0.0, 0.001, "a Blessing that doubles the price halves what 20 buys (15*2 = 30 > 20)")


func test_the_storm_goes_nearest_first_to_distinct_bodies_in_reach_of_each_jump() -> void:
	var plan := ChainPlan.new()
	var pts: Array[Vector2] = []
	for i in 8:
		pts.append(Vector2(3.0 + 3.0 * i, 0.0))
	var route := plan.route(Vector2.ZERO, Vector2(3, 0), pts)
	assert_eq(route.size(), 6, "up to 6 distinct bodies")
	var seen := {}
	for r in route:
		assert_false(seen.has(r.index), "no body twice (no loops)")
		seen[r.index] = true
		assert_false(r.repeat)
	assert_eq(route.map(func(r: Dictionary) -> int: return r.index), [0, 1, 2, 3, 4, 5])
	assert_true(route[0].share > route[5].share, "each jump is weaker")


func test_the_storm_does_not_jump_past_its_range_and_needs_a_first_body_in_reach() -> void:
	var plan := ChainPlan.new()
	var gap: Array[Vector2] = [Vector2(3, 0), Vector2(8.5, 0), Vector2(9.0, 0.0)]
	var r := plan.route(Vector2.ZERO, Vector2(3, 0), gap)
	assert_eq(r.map(func(x: Dictionary) -> int: return x.index), [0, 0, 0], "5.5 m is past a jump of 5: it stays on its body (isolated, solo strikes)")
	assert_eq(plan.route(Vector2.ZERO, Vector2(30, 0), [Vector2(30, 0)] as Array[Vector2]).size(), 0, "past her reach: no first body")


func test_an_isolated_body_takes_a_few_weaker_strikes() -> void:
	var plan := ChainPlan.new()
	var r := plan.route(Vector2.ZERO, Vector2(4, 0), [Vector2(4, 0)] as Array[Vector2])
	assert_eq(r.size(), plan.solo)
	assert_eq([r[0].repeat, r[1].repeat, r[2].repeat], [false, true, true])
	assert_true(r[0].share > r[1].share and r[1].share > r[2].share)
	var two := plan.route(Vector2.ZERO, Vector2(4, 0), [Vector2(4, 0), Vector2(6, 0)] as Array[Vector2])
	assert_eq(two.size(), 2, "two bodies: one strike each, no repeats")


# ---------- the data ----------

func test_the_kit_numbers_of_the_pack() -> void:
	var k := HeroDef.maga().arcane
	var h := HeroDef.maga()
	assert_eq([h.max_hp, h.magick_max, h.magick_regen, h.dodge_charges, h.dodge_recharge, k.blink_distance], [30.0, 50.0, 3.0, 2, 1.0, 4.5])
	assert_eq([k.spark_fan, k.spark_fan_deg, k.spark_range, k.breath_damage, k.breath_range, k.breath_deg, k.slow_pct, k.shard_slow_time],
		[3, 24.0, 11.0, 12.0, 5.0, 90.0, 0.3, 2.0])
	assert_eq([k.frost_time, k.frost_dps, k.frost_step], [5.0, 6.0, 1.0])
	assert_eq([k.storm_damage, k.storm_targets, k.storm_jump], [90.0, 6, 5.0])
	assert_eq(k.reaction_magick, 0.0, "no Magia back from a reaction unless the kit turns it on")
	var spark := _node(ComboNode.In.LIGHT)
	assert_eq([spark.effect_power, spark.effect_fan, spark.effect_fan_deg, spark.effect_radius, spark.magick_cost], [8.0, 3, 24.0, 11.0, 0.0])
	assert_eq(_node(ComboNode.In.HEAVY).magick_cost, 0.0)
	var combust := _node(ComboNode.In.CHARGE_LIGHT)
	assert_eq([combust.power_at(0.0), combust.power_at(1.0)], [50.0, 150.0])


func test_one_supremo_a_weapon_and_the_old_move_texts_stay() -> void:
	var h := HeroDef.maga()
	assert_eq(h.ultimates.size(), 1)
	assert_eq(h.ult_for_weapon(2).id, &"storm")
	for key: StringName in [&"move_arc", &"move_shard", &"move_frost", &"ult_converge", &"move_breath", &"move_combust", &"move_winter", &"ult_storm", &"ult_storm_desc"]:
		assert_ne(T.t(key), String(key), "%s is in the table" % key)
		assert_false(T.t(key).contains("—"), "no em dash")


# ---------- the blows in play ----------

func test_a_tap_throws_three_bolts_at_once_in_a_fan_as_one_cast() -> void:
	_start()
	pad.press(&"light_attack")
	_step(2)
	for i in 9:
		_step()
		if _friendly().size() >= 3:
			break
	var bolts := _friendly()
	assert_eq(bolts.size(), 3, "three bolts from one click")
	var group: int = bolts[0].group
	assert_ne(group, 0)
	for b in bolts:
		assert_eq(b.group, group, "one conjuration")
		assert_eq(b.damage, 8.0)
	var angles := bolts.map(func(b: Projectiles.Shot) -> float: return rad_to_deg(b.vel.angle()))
	angles.sort()
	assert_almost_eq(float(angles[2]) - float(angles[0]), 24.0, 0.5, "24 degrees in all")
	assert_eq(strikes, [&"spark"], "one click, one blow")
	assert_eq(game.player.magick.spent, 0.0, "free")


func test_a_burst_of_one_cast_makes_one_reaction_a_target_and_pays_back_once() -> void:
	_start()
	game.arcane.kit.reaction_magick = 3.0
	game.player.magick.value = 10.0
	var spark: Array[StringName] = [&"light", &"bolt", &"arcane", &"fire"]
	var e := _dummy(Vector2(4, 0))
	game.arcane.apply_element(e, I)
	var group := 777001
	for i in 3:
		var s := Projectiles.Shot.new()
		s.tags = spark
		s.group = group
		s.damage = 8.0
		game.arcane.shot_landed(e, s)
	assert_eq(game.arcane.tally.thermal, 1, "three bolts of one cast on one target: one reaction (it consumed both states)")
	assert_almost_eq(game.player.magick.value, 13.0, 0.1, "one payback")
	var others: Array[Enemy] = []
	for i in 3:
		var o := _dummy(Vector2(6 + i, 0))
		game.arcane.apply_element(o, I)
		others.append(o)
	game.arcane.react_charge = 0.0
	game.player.magick.value = 10.0
	game.arcane._cj.clear()
	for o in others:
		var s := Projectiles.Shot.new()
		s.tags = spark
		s.group = 777002
		game.arcane.shot_landed(o, s)
	assert_almost_eq(game.player.magick.value, 13.0, 0.1, "three targets of one cast: 3 of Mana once")
	assert_lte(game.arcane.react_charge, 10.0, "the charge of one cast is capped")


func test_a_tap_on_the_right_is_a_cone_of_90_degrees_and_5_metres_with_frio_and_a_30_percent_slow() -> void:
	_start()
	var inside := _dummy(Vector2(4, 0))
	var edge := _dummy(Vector2(3.2, 3.0))  # 43 degrees off, 4.4 m: inside
	var wide := _dummy(Vector2(2.0, 3.6))  # 61 degrees off: outside
	var far := _dummy(Vector2(6.5, 0))
	var node := _node(ComboNode.In.HEAVY)
	var hp := inside.hp
	game.arcane.cast(node, game.player.pos, Vector2.RIGHT)
	assert_lt(inside.hp, hp, "damaged")
	assert_true(game.arcane.book.has_ice(inside), "Frio")
	assert_true(game.arcane.book.has_ice(edge), "the cone's edge")
	assert_false(game.arcane.book.has_ice(wide), "outside the 90 degrees")
	assert_false(game.arcane.book.has_ice(far), "past 5 m")
	assert_eq([inside.slow_t > 1.9, inside.slow_keep], [true, 0.7], "30% slower for 2 s")
	_step(150)
	assert_eq(inside.slow_keep, Enemy.SLOW_KEEP, "the share goes back when it ends")


func test_fire_then_the_cone_and_the_cone_then_fire_are_both_a_thermal_shock() -> void:
	_start()
	var a := _dummy(Vector2(3, 0))
	var b := _dummy(Vector2(3, 1))
	game.arcane.apply_element(a, F)
	game.arcane.cast(_node(ComboNode.In.HEAVY), game.player.pos, Vector2.RIGHT)
	assert_eq(game.arcane.tally.thermal, 1, "fire, then the cone")
	var shot := Projectiles.Shot.new()
	shot.tags = [&"omega", &"light", &"arcane", &"fire"] as Array[StringName]
	shot.damage = 50.0
	shot.blast = 1.5
	game.arcane.shot_landed(b, shot)
	assert_eq(game.arcane.tally.thermal, 2, "the cone's Frio, then the ball: the burst makes the shock")
	_step(20)


func test_the_ball_bursts_as_wide_as_the_hold_grew_it() -> void:
	_start()
	var first := _dummy(Vector2(5, 0))
	var near := _dummy(Vector2(5, 3.0))
	var tags: Array[StringName] = [&"omega", &"light", &"arcane", &"fire"]
	var small := Projectiles.Shot.new()
	small.tags = tags
	small.damage = 50.0
	small.blast = 1.5
	var hp := near.hp
	game.arcane.shot_landed(first, small)
	assert_eq(near.hp, hp, "3 m away is outside a 1.5 m burst")
	var big := Projectiles.Shot.new()
	big.tags = tags
	big.damage = 150.0
	big.blast = 3.5
	game.arcane.shot_landed(_dummy(Vector2(8, 0)), big)
	var third := _dummy(Vector2(8, 3.0))
	game.arcane.shot_landed(first, big)
	assert_lt(near.hp, hp, "3 m away is inside a 3.5 m burst")
	assert_true(third.alive)


func test_the_ball_hits_harder_the_more_it_grew() -> void:
	_start()
	var node := _node(ComboNode.In.CHARGE_LIGHT)
	var least := game.combat.throw_wave(node, Vector2.ZERO, Vector2.RIGHT, Color.WHITE, node.tags, 0.0)
	var most := game.combat.throw_wave(node, Vector2.ZERO, Vector2.RIGHT, Color.WHITE, node.tags, 1.0)
	assert_eq([least.damage, most.damage], [50.0, 150.0])
	assert_eq([least.blast, most.blast], [1.5, 3.5])


# ---------- tap and hold, the price and the cancel ----------

func test_a_hold_strikes_only_on_the_release_and_pays_then_never_before() -> void:
	_start()
	_dummy(Vector2(4, 0))
	_hold_down(&"light_attack", 80)  # 1.33 s: charged, the button still down
	assert_true(game.player.charging)
	assert_eq(strikes, [] as Array[StringName], "nothing strikes while it is held, not even the tap")
	assert_eq(game.player.magick.spent, 0.0, "nothing paid while it charges")
	_let_go(&"light_attack")
	assert_eq(strikes, [&"combust"], "the Combustão only, on the release")
	assert_gt(game.player.magick.spent, 14.99)
	assert_lte(game.player.magick.spent, 25.0)


func test_let_go_before_the_least_charge_does_nothing_and_costs_nothing() -> void:
	_start()
	_dummy(Vector2(4, 0))
	_hold_down(&"heavy_attack", 30)  # 0.5 s: past the tap, short of the 0.6 s
	_let_go(&"heavy_attack")
	assert_eq(strikes, [] as Array[StringName], "neither the winter nor the cone")
	assert_eq(game.player.magick.spent, 0.0)


func test_the_dodge_before_the_spell_lands_costs_nothing() -> void:
	_start()
	_dummy(Vector2(4, 0))
	_hold_down(&"light_attack", 60)
	pad.release(&"light_attack")
	pad.press(&"dodge")
	_step(2)
	_step(60)
	assert_false(strikes.has(&"combust"), "the dodge cut the windup")
	assert_eq(game.player.magick.spent, 0.0)


func test_the_dodge_while_charging_costs_nothing_and_strikes_nothing() -> void:
	_start()
	_dummy(Vector2(4, 0))
	_hold_down(&"heavy_attack", 60)
	pad.press(&"dodge")
	_step(2)
	_step(60)
	assert_eq(strikes, [] as Array[StringName])
	assert_eq(game.player.magick.spent, 0.0)


func test_the_area_grows_with_the_hold_and_never_past_its_full() -> void:
	_start()
	_hold_down(&"heavy_attack", 45)  # 0.75 s
	_let_go(&"heavy_attack")
	var small := game.arcane.frost.radius
	assert_gte(small, 2.0)
	assert_lt(small, 3.0)
	game.arcane._end_frost()
	_start()
	_hold_down(&"heavy_attack", 140)  # 2.3 s: past the 1.8 s
	var cost_full := game.player.charge_cost_now()
	_let_go(&"heavy_attack")
	assert_almost_eq(game.arcane.frost.radius, 6.0, 0.001, "full, and it did not grow on")
	assert_almost_eq(cost_full, 30.0, 0.5)


func test_the_mana_limits_how_big_it_can_grow() -> void:
	_start()
	game.player.magick.value = 12.0  # pays the 10 of the least charge and 2 more of 20
	_hold_down(&"heavy_attack", 140)
	var capped := game.player.charge_share_now()
	assert_lt(capped, 0.5, "the hold is long, the Mana is short")
	_let_go(&"heavy_attack")
	assert_lt(game.arcane.frost.radius, 4.5)
	assert_gte(game.player.magick.value, 0.0, "never into debt")


func test_without_mana_for_the_least_a_hold_does_not_execute_nor_become_a_click() -> void:
	_start()
	_dummy(Vector2(4, 0))
	game.player.magick.value = 9.0
	var refused := [0]
	game.player.magick_refused.connect(func() -> void: refused[0] += 1)
	_hold_down(&"heavy_attack", 80)
	_let_go(&"heavy_attack")
	assert_gte(refused[0], 1)
	assert_eq(strikes, [] as Array[StringName], "no winter, and no silent cone either")
	assert_eq(game.player.magick.value >= 9.0, true)


func test_the_cost_shown_grows_with_the_hold() -> void:
	_start()
	_hold_down(&"light_attack", 45)
	var early := game.player.charge_cost_now()
	_hold_down(&"light_attack", 40)
	var late := game.player.charge_cost_now()
	assert_gte(early, 15.0)
	assert_gt(late, early)
	assert_lte(late, 25.0)


func test_the_mana_comes_back_walking() -> void:
	_start()
	game.player.magick.value = 10.0
	pad.move = Vector2.RIGHT
	for i in 60:
		pad.press(&"move_right")
		_step()
	pad.move = Vector2.ZERO
	assert_almost_eq(game.player.magick.value, 13.0, 0.3, "3 a second, moving too")


func test_two_dodges_recharge_in_a_second_and_the_blink_is_4_and_a_half() -> void:
	_start()
	assert_eq([game.player.dodge_charges, game.player.dodge_max], [2, 2])
	var from := game.player.pos
	pad.move = Vector2.RIGHT
	pad.press(&"dodge")
	_step()
	assert_eq(game.player.dodge_charges, 1)
	assert_almost_eq(game.player.pos.distance_to(from), 4.5, 0.6)


# ---------- the reactions ----------

func test_every_pair_reacts_in_both_orders_and_consumes_both_states() -> void:
	_start()
	var want := {[F, I]: "thermal", [F, V]: "overload", [I, V]: "crystal"}
	for pair: Array in want:
		for order in [pair, [pair[1], pair[0]]]:
			var before: int = game.arcane.tally[want[pair]]
			var e := _dummy(Vector2(4 + randf() * 3.0, randf_range(-2.0, 2.0)))
			game.arcane.apply_element(e, order[0])
			game.arcane.apply_element(e, order[1])
			assert_eq(game.arcane.tally[want[pair]], before + 1, "%s in order %s" % [want[pair], order])
			assert_false(game.arcane.book.has_element(e, pair[0]) or game.arcane.book.has_element(e, pair[1]), "both states consumed")
	assert_eq(game.arcane.tally.reactions, 6)


func test_no_triple_reaction_in_the_basic_kit() -> void:
	_start()
	var e := _dummy(Vector2(4, 0))
	game.arcane.apply_element(e, F)
	game.arcane.apply_element(e, I)
	game.arcane.apply_element(e, V)
	assert_eq(game.arcane.tally.reactions, 1, "fire and ice are spent: the volt needs a new state to react")
	assert_true(game.arcane.book.has_volt(e))


func test_a_reaction_has_a_gap_per_target_so_a_burst_does_not_triple_it() -> void:
	_start()
	var e := _dummy(Vector2(4, 0))
	game.arcane.apply_element(e, F)
	game.arcane.apply_element(e, I)
	game.arcane.apply_element(e, F)
	game.arcane.apply_element(e, I)
	assert_eq(game.arcane.tally.thermal, 1, "react_gap holds the second one back")


func test_the_frozen_ground_reapplies_frio_every_second_until_a_common_one_freezes() -> void:
	_start()
	var e := _dummy(Vector2(4, 0))
	game.arcane.cast(_node(ComboNode.In.CHARGE), game.player.pos, Vector2.RIGHT)
	assert_not_null(game.arcane.frost)
	_step(130)
	assert_true(game.arcane.book.has_ice(e) or e.frozen_t > 0.0 or e.thaw_t > 0.0, "chilled by the ground")
	_step(100)
	assert_gte(game.arcane.tally.freezes, 1, "the third Frio, two ticks in, freezes a common body")


func test_the_ground_then_a_fire_burst_reacts_again_as_the_ground_reapplies() -> void:
	_start()
	var e := _dummy(Vector2(4, 0))
	game.arcane.cast(_node(ComboNode.In.CHARGE), game.player.pos, Vector2.RIGHT)
	_step(5)
	game.arcane.apply_element(e, F)
	assert_eq(game.arcane.tally.thermal, 1, "ground first, then fire")
	_step(70)
	game.arcane.apply_element(e, F)
	assert_eq(game.arcane.tally.thermal, 2, "the ground put Frio back: a second reaction")


func test_a_boss_is_never_frozen_nor_stunned_by_the_elements() -> void:
	_start()
	var b := _boss(Vector2(4, 0))
	for i in 4:
		game.arcane.apply_element(b, I)
	assert_eq(b.frozen_t, 0.0, "the third Frio does not freeze a boss")
	game.arcane.apply_element(b, V)  # ice and volt: Cristalização
	assert_eq(b.frozen_t, 0.0, "the Cristalização breaks Postura on a boss, never freezes it")
	assert_eq(b.slow_t, 0.0, "nor slows him with the Frio")


# ---------- the Tempestade Celestial ----------

func _storm_ready() -> void:
	_start()
	game.ults.equip(HeroDef.maga().ultimates[0])


func test_the_storm_crosses_six_distinct_bodies_and_never_goes_back() -> void:
	_storm_ready()
	var bodies: Array[Enemy] = []
	for i in 8:
		bodies.append(_dummy(Vector2(3.0 + 3.0 * i, 0.0)))
	game.ults._storm_start(Vector2.RIGHT)
	var queued := game.ults._storm.map(func(s: Dictionary) -> Enemy: return s.e)
	assert_eq(queued.size(), 6)
	for i in queued.size():
		for j in range(i + 1, queued.size()):
			assert_ne(queued[i], queued[j], "no body twice")
	_step(60)
	var volted := 0
	for b in bodies:
		if game.arcane.book.has_volt(b):
			volted += 1
	assert_eq(volted, 6, "Eletrização on the six")
	assert_false(game.arcane.book.has_volt(bodies[7]), "the seventh is out of the chain")
	assert_true(game.ults._storm.is_empty())
	assert_lt(bodies[0].hp, bodies[0].max_hp - 80.0, "about 90 on the first")
	assert_lt(bodies[0].hp, bodies[5].hp, "each jump hits a little weaker (the last one lost less)")


func test_the_storm_on_one_isolated_boss_strikes_it_three_times_at_half() -> void:
	_storm_ready()
	var b := _boss(Vector2(5, 0))
	game.ults._storm_start(Vector2.RIGHT)
	assert_eq(game.ults._storm.size(), 3, "isolated: three strikes")
	_step(40)
	var lost := b.max_hp - b.hp
	assert_gt(lost, 90.0 * 0.5 * 2.0, "worth it on a lone boss")
	assert_lt(lost, 90.0 * 3.0, "and never the whole chain at full")
	assert_eq(b.frozen_t, 0.0)


func test_the_storm_makes_overload_on_burning_groups_and_crystal_on_the_frozen_ground() -> void:
	_storm_ready()
	var a := _dummy(Vector2(4, 0))
	var b := _dummy(Vector2(6, 0))
	game.arcane.apply_element(a, F)
	game.arcane.apply_element(b, I)
	game.ults._storm_start(Vector2.RIGHT)
	_step(30)
	assert_eq(game.arcane.tally.overload, 1, "fire then the Supremo's volt: Sobrecarga")
	assert_eq(game.arcane.tally.crystal, 1, "ice then the Supremo's volt: Cristalização")


# ---------- the HUD ----------

func test_the_maga_hud_has_four_blow_squares_with_their_prices() -> void:
	Dev.put("hero", "maga")
	game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	await wait_process_frames(2)
	var hud := game.hud
	assert_eq(hud._slots.size(), 5, "M1, M2, hold M1, hold M2, then the dodge (the Supremo is its own square)")
	assert_eq([hud._slots[0].action, hud._slots[0].hold, hud._slots[1].action, hud._slots[1].hold], [&"light_attack", false, &"heavy_attack", false])
	assert_eq([hud._slots[2].action, hud._slots[2].hold, hud._slots[3].action, hud._slots[3].hold], [&"light_attack", true, &"heavy_attack", true])
	assert_eq([hud._slots[0].cost, hud._slots[1].cost, hud._slots[2].cost, hud._slots[3].cost], [0, 0, 15, 10])
	assert_eq(hud._slots[4].action, &"dodge")


# ---------- the saves ----------

func test_an_old_save_with_the_old_moves_and_ultimate_loads_and_merges_the_same_twice() -> void:
	var d := SaveData.defaults()
	d.moves = ["spark", "spark2", "spark3", "arc", "shard", "frost", "combust"]
	var b: Dictionary = SaveData.hero_defaults()
	b["ultimate"] = "converge"
	b["mastery_xp"] = 500
	d.heroes["maga"] = b
	d.version = 19
	var once := SaveData.merged(d.duplicate(true))
	var twice := SaveData.merged(once.duplicate(true))
	assert_eq(once.moves, d.moves, "discovered moves are kept")
	assert_eq(int(once.heroes.maga.mastery_xp), 500)
	assert_eq(twice.moves, once.moves)
	assert_eq(twice.heroes.maga, once.heroes.maga, "idempotent")
