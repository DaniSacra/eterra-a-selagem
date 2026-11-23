extends GutTest
## 2026-11-23 (Daniel: "he stays idle too long"): the random rest between attacks that shrinks with life (AttackGap),
## the idle measure (IdleStats), the Cavaleiro's and Morvath's data, and the Ancião's call of ranged dead at the edge.

func _game() -> Game:
	var game := (load("res://scenes/game.tscn") as PackedScene).instantiate() as Game
	add_child_autofree(game)
	game.rooms.start_at(RunMap.Kind.FOUNTAIN)
	game.horde.clear_crowd()
	game.player.pos = Vector2.ZERO
	game.horde.target = Vector2.ZERO
	return game


func test_gap_range_slides_with_life() -> void:
	assert_eq(AttackGap.range_at(0.3, 1.5, 0.2, 0.7, 1.0), Vector2(0.3, 1.5))
	assert_eq(AttackGap.range_at(0.3, 1.5, 0.2, 0.7, 0.0), Vector2(0.2, 0.7))
	var mid := AttackGap.range_at(0.3, 1.5, 0.2, 0.7, 0.5)
	assert_almost_eq(mid.x, 0.25, 0.001)
	assert_almost_eq(mid.y, 1.1, 0.001)
	assert_eq(AttackGap.range_at(0.3, 1.5, 0.2, 0.7, 7.0), Vector2(0.3, 1.5), "life share is clamped")


func test_gap_is_uniform_inside_the_range_and_seeded() -> void:
	var a := RandomNumberGenerator.new()
	var b := RandomNumberGenerator.new()
	a.seed = 9
	b.seed = 9
	var lo := 9.0
	var hi := 0.0
	for i in 400:
		var g := AttackGap.pick(0.3, 1.5, 0.2, 0.7, 1.0, a)
		assert_eq(g, AttackGap.pick(0.3, 1.5, 0.2, 0.7, 1.0, b), "the same seed, the same gaps")
		lo = minf(lo, g)
		hi = maxf(hi, g)
	assert_gte(lo, 0.3)
	assert_lte(hi, 1.5)
	assert_gt(hi - lo, 1.0, "it spreads over the range, not one value")


func test_idle_stats_leave_earned_time_out() -> void:
	var s := IdleStats.new()
	s.tick(1.0, true, false)
	s.tick(1.0, false, false)
	s.tick(5.0, true, true)  # a stun: not counted
	s.tick(1.0, false, false, true)
	for g in [0.4, 0.6, 1.0, 2.0]:
		s.add_gap(g)
	var r := s.report()
	assert_almost_eq(float(r.fight), 3.0, 0.05)
	assert_almost_eq(float(r.share), 0.33, 0.01)
	assert_almost_eq(float(r.share_rec), 0.67, 0.01)
	assert_almost_eq(float(r.mean), 1.0, 0.001)
	assert_eq(float(r.max), 2.0)
	assert_eq(float(r.p90), 2.0)


func test_data_gaps_for_knight_and_morvath() -> void:
	var k := load("res://data/enemies/knight.tres") as EnemyDef
	assert_eq([k.gap_min, k.gap_max, k.gap_min0, k.gap_max0], [0.3, 1.5, 0.2, 0.7])
	var b := load("res://data/bosses/morvath.tres") as BossDef
	assert_eq([b.gap_min, b.gap_max, b.gap_min0, b.gap_max0], [0.1, 0.7, 0.05, 0.3])
	for a in b.attacks:
		assert_true(a.layers.is_empty(), "%s: attacks come one at a time (Daniel, 2026-11-23)" % a.id)


func test_knight_rests_a_random_gap_after_its_recovery() -> void:
	var game := _game()
	var h := game.horde
	var k := h.spawn(h.def(&"knight"), Vector2(8, 0), false)
	var seen: Array[float] = []
	for i in 12:
		k.state = Enemy.State.RECOVER
		k.state_t = k.def.recover_time
		k.cooldown = 9.0
		h._behave(k, 0.016)
		seen.append(k.cooldown)
	for g in seen:
		assert_gte(g, 0.3)
		assert_lte(g, 1.5)
	assert_gt(seen.max() - seen.min(), 0.1, "not always the same")


func test_elder_calls_two_archers_to_the_edge_away_from_the_paladin() -> void:
	var game := _game()
	var h := game.horde
	var elder := h.spawn(h.def(&"priest_elder"), Vector2(2, 0), false)
	elder.call_cd = 0.0
	elder.cooldown = 0.0
	var spots := h.edge_spots(2)
	assert_eq(spots.size(), 2)
	for s in spots:
		assert_gt(s.distance_to(h.target), 6.0, "at the edge, not at his feet")
	assert_gt(spots[0].distance_to(spots[1]), 4.0, "apart")
	elder.rows = 1
	var got := h._raise_dead(elder, h._calls(elder), &"", true)
	assert_eq(got.size(), 2, "two at a time")
	for r in got:
		assert_eq(r.def.id, &"archer")
	elder.raised.append_array(got)
	assert_eq(h._calls(elder), 0, "never more than 2 standing")
	elder.raised.append_array(h._raise_dead(elder, 1, &"", true))
	assert_eq(h._calls(elder), 0)
