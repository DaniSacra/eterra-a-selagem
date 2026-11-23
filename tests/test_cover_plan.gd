extends GutTest
## CoverPlan: where the bot stands to keep a stone between it and the shooters.

func _col(at: Vector2, shots := true) -> ArenaObstacle:
	return ArenaObstacle.circle(at, 0.9, &"column", 2.0, shots)


func test_crosses_circle() -> void:
	var c := _col(Vector2.ZERO)
	assert_true(CoverPlan.crosses(Vector2(-5, 0), Vector2(5, 0), c))
	assert_false(CoverPlan.crosses(Vector2(-5, 3), Vector2(5, 3), c))
	assert_false(CoverPlan.crosses(Vector2(-5, 0), Vector2(5, 0), _col(Vector2.ZERO, false)), "low wall: shots pass")


func test_crosses_box() -> void:
	var b := ArenaObstacle.box(Vector2.ZERO, Vector2(2, 0.5), 0.0, &"block", 2.0)
	assert_true(CoverPlan.crosses(Vector2(0, -4), Vector2(0, 4), b))
	assert_false(CoverPlan.crosses(Vector2(3, -4), Vector2(3, 4), b))


func test_pick_puts_the_stone_between() -> void:
	var obs: Array[ArenaObstacle] = [_col(Vector2(4.5, 4.5))]
	var shooters: Array[Vector2] = [Vector2(-8, 4.5)]
	var spot: Variant = CoverPlan.pick(Vector2(2, 2), shooters, obs, 7.0, 0.4)
	assert_not_null(spot)
	assert_true(CoverPlan.hidden(shooters[0], spot as Vector2, obs))
	assert_gt((spot as Vector2).x, 4.5, "behind it, away from the shooter")


func test_pick_none_when_far_or_empty() -> void:
	var obs: Array[ArenaObstacle] = [_col(Vector2(20, 20))]
	var shooters: Array[Vector2] = [Vector2(-8, 4.5)]
	assert_null(CoverPlan.pick(Vector2.ZERO, shooters, obs, 7.0, 0.4))
	assert_null(CoverPlan.pick(Vector2.ZERO, [] as Array[Vector2], obs, 7.0, 0.4))


func test_pick_skips_unwalkable_and_prefers_most_hidden() -> void:
	var obs: Array[ArenaObstacle] = [_col(Vector2(3, 0)), _col(Vector2(-3, 0))]
	var shooters: Array[Vector2] = [Vector2(0, 8)]
	var none: Variant = CoverPlan.pick(Vector2.ZERO, shooters, obs, 7.0, 0.4, func(_q: Vector2) -> bool: return false)
	assert_null(none)
	var nearest: Variant = CoverPlan.pick(Vector2(2.5, 0), shooters, obs, 7.0, 0.4)
	assert_gt((nearest as Vector2).x, 0.0, "the column at hand")
