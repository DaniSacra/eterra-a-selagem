extends GutTest
## RD2-08: the slab that teaches arms by itself. A slab idle for auto_cycle seconds arms on its own with the usual warning
## when an enemy stands near it, only up to auto_until of the descent; asleep or in the first calm it never does; the
## paladin's step still arms it at once, and a cycle starts again after its rest.

const DT := 1.0 / 60.0


func _def() -> HazardDef:
	var h := HazardDef.new()
	h.kind = HazardDef.Kind.PLATES
	h.plates = [Rect2(0, 0, 3, 3)]
	h.warn = 1.5
	h.fire = 0.25
	h.rearm = 5.0
	h.start_delay = 3.0
	h.auto_cycle = 6.0
	h.auto_near = 2.5
	h.auto_until = 0.26
	return h


func _arms(h: PlateHazard, seconds: float, hero: Vector2, bodies: PackedVector2Array) -> int:
	var n := 0
	for i in roundi(seconds / DT):
		n += (h.step(DT, hero, bodies).armed as PackedInt32Array).size()
	return n


func test_it_arms_by_itself_when_the_pack_is_near() -> void:
	var h := PlateHazard.new(_def(), [], true, 0.2)
	var near := PackedVector2Array([Vector2(4.0, 1.5)])  # 1 m off the slab's edge (not on it)
	assert_true(h.auto)
	assert_eq(_arms(h, 5.9, Vector2.INF, near), 0, "not before the cycle (6 s) is done")
	assert_eq(_arms(h, 0.3, Vector2.INF, near), 1, "then it arms with no one on it")
	assert_eq(h.armed_by_cycle, 1)
	assert_eq(h.armed_by_hero + h.armed_by_enemy, 0 + h.armed_by_enemy)
	assert_eq(h.phase[0], PlateHazard.Phase.ARM)
	# the warning is the usual one: it strikes 1.5 s after it armed (0.3 s of it went by in the step above, less a frame or two)
	var t := 0.0
	var struck := 0
	while struck == 0 and t < 3.0:
		struck += (h.step(DT, Vector2.INF, near).fired as PackedInt32Array).size()
		t += DT
	assert_gt(t, 1.5 - 0.3 - 0.1, "a fair warning, not before it ran")
	assert_lt(t, 1.5 - 0.2 + 0.05)


func test_it_waits_for_the_pack() -> void:
	var h := PlateHazard.new(_def(), [], true, 0.2)
	var far := PackedVector2Array([Vector2(20.0, 20.0)])
	assert_eq(_arms(h, 12.0, Vector2.INF, far), 0, "no one near: nothing arms")
	assert_eq(_arms(h, 0.1, Vector2.INF, PackedVector2Array([Vector2(3.5, 1.0)])), 1, "the pack comes: it arms at once, it was ready")


func test_not_deep_in_the_descent_nor_asleep() -> void:
	var near := PackedVector2Array([Vector2(1.5, 1.5)])
	var deep := PlateHazard.new(_def(), [], true, 0.5)
	assert_false(deep.auto, "past auto_until (depth 4)")
	assert_eq(_arms(deep, 20.0, Vector2.INF, PackedVector2Array([Vector2(50, 50)])), 0)
	var asleep := PlateHazard.new(_def(), [], false, 0.2)
	assert_eq(_arms(asleep, 20.0, Vector2.INF, near), 0, "asleep: it lies at rest")
	var calm := PlateHazard.new(_def(), [], true, 0.2)
	assert_eq(_arms(calm, 2.9, Vector2.INF, near), 0, "nothing in the first 3 s")


func test_the_cycle_starts_again_after_the_rest() -> void:
	var h := PlateHazard.new(_def(), [], true, 0.2)
	var near := PackedVector2Array([Vector2(4.0, 1.5)])
	assert_eq(_arms(h, 6.3, Vector2.INF, near), 1)
	# 1.5 warn + 0.25 fire + 5 rest, then 6 s ready: never twice within that
	assert_eq(_arms(h, 11.0, Vector2.INF, near), 0)
	assert_eq(_arms(h, 2.0, Vector2.INF, near), 1, "the next one after its own 6 s")
