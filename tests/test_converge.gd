extends GutTest

var p: ConvergePlan
var b: ElementBook
var t: RefCounted


func before_each() -> void:
	p = ConvergePlan.new()
	b = ElementBook.new()
	t = RefCounted.new()


func test_shape() -> void:
	assert_eq(p.count(), 9)
	assert_almost_eq(p.duration(), 4.5, 0.001)
	assert_almost_eq(p.damage_per_tick() * p.count(), 90.0, 0.001)


func test_phase_elements() -> void:
	for i in 3:
		assert_eq(p.elements_at(i), [ElementBook.ICE] as Array[StringName])
	for i in range(3, 6):
		assert_eq(p.elements_at(i), [ElementBook.FIRE] as Array[StringName])
	assert_eq(p.elements_at(6), [ElementBook.VOLT] as Array[StringName])
	assert_eq(p.elements_at(7), [ElementBook.VOLT, ElementBook.FIRE] as Array[StringName])
	assert_eq(p.elements_at(8), [ElementBook.VOLT, ElementBook.ICE] as Array[StringName])


func _run(resists: bool) -> Array:
	var kinds: Array = []
	for i in p.count():
		for el in p.elements_at(i):
			for r in b.apply(t, el, resists):
				kinds.append([i, r.kind])
		b.tick(p.tick)
	return kinds


func test_full_run_reactions() -> void:
	var k := _run(false)
	# thermal in the fire phase (cold from the ice phase still holds), overload and crystal at the end
	assert_eq(k[0], [3, Reaction.Kind.THERMAL])
	assert_true(k.has([7, Reaction.Kind.OVERLOAD]))
	assert_true(k.has([8, Reaction.Kind.CRYSTAL]))


func test_boss_never_frozen() -> void:
	b.apply(t, ElementBook.ICE, true)
	var got := false
	for i in p.count():
		for el in p.elements_at(i):
			for r in b.apply(t, el, true):
				if r.kind == Reaction.Kind.CRYSTAL:
					got = true
					assert_eq(r.freeze, 0.0)
					assert_gt(r.poise, 0.0)
		b.tick(p.tick)
	assert_true(got)
