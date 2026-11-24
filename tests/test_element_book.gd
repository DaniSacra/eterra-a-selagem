extends GutTest

const F := ElementBook.FIRE
const I := ElementBook.ICE
const V := ElementBook.VOLT

var b: ElementBook
var e: RefCounted


func before_each() -> void:
	b = ElementBook.new()
	e = RefCounted.new()


func _pair(first: StringName, second: StringName) -> Array[Reaction]:
	b.apply(e, first)
	return b.apply(e, second)


func test_six_pair_orders() -> void:
	var cases := [[F, I, Reaction.Kind.THERMAL], [I, F, Reaction.Kind.THERMAL],
		[F, V, Reaction.Kind.OVERLOAD], [V, F, Reaction.Kind.OVERLOAD],
		[I, V, Reaction.Kind.CRYSTAL], [V, I, Reaction.Kind.CRYSTAL]]
	for c in cases:
		b.clear_all()
		var r := _pair(c[0], c[1])
		assert_eq(r.size(), 1, "one reaction %s+%s" % [c[0], c[1]])
		assert_eq(r[0].kind, c[2])


func test_reaction_values() -> void:
	assert_eq(_pair(F, I)[0].damage, 20.0)
	b.clear_all()
	var o := _pair(F, V)[0]
	assert_eq(o.damage, 15.0)
	assert_eq(o.radius, 1.8)
	b.clear_all()
	assert_eq(_pair(I, V)[0].freeze, 0.8)


func test_consumes_pair_only() -> void:
	b.apply(e, F)
	b.apply(e, V)  # overload consumes both
	assert_false(b.has_fire(e))
	assert_false(b.has_volt(e))
	b.clear_all()
	b.apply(e, F)
	b.apply(e, V)
	assert_eq(b.tracked(), 1)


func test_priority_thermal_then_overload_then_crystal() -> void:
	b.apply(e, V)
	b.apply(e, I)  # crystal now, consumes both
	b.clear_all()
	# three states at once: build without a reaction through react_gap
	b.react_gap = 1.0
	b.apply(e, F)
	b.apply(e, V)  # overload, gap starts
	b.clear_all()
	var row := b._row(e)
	row["burn"] = 3.0
	row["cold"] = 3.0
	row["hits"] = 1
	row["volt"] = 3.0
	var r := b.apply(e, F)
	assert_eq(r[0].kind, Reaction.Kind.THERMAL)
	assert_true(b.has_volt(e), "volt survives thermal")
	assert_false(b.has_fire(e))
	assert_false(b.has_ice(e))
	b.clear_all()
	row = b._row(e)
	row["burn"] = 3.0
	row["volt"] = 3.0
	row["cold"] = 0.0
	assert_eq(b.apply(e, F)[0].kind, Reaction.Kind.OVERLOAD)


func test_renewal_no_duplicate() -> void:
	b.apply(e, F)
	b.tick(2.0)
	b.apply(e, F)
	assert_almost_eq(b._row(e)["burn"], 3.0, 0.001)
	assert_eq(b.apply(e, F).size(), 0)


func test_react_gap_blocks_repeat() -> void:
	_pair(F, I)
	var r := _pair(F, I)
	assert_eq(r.size(), 0, "same instant: no second reaction")
	assert_true(b.has_fire(e), "states kept for later")
	b.tick(0.5)
	assert_eq(b.apply(e, I).size(), 1)


func test_expiry() -> void:
	b.apply(e, F)
	b.apply(e, I)  # reacts; reapply to test expiry alone
	b.clear_all()
	b.apply(e, V)
	b.tick(3.1)
	assert_false(b.has_volt(e))
	assert_eq(b.apply(e, F).size(), 0, "expired volt does not react")
	b.tick(3.1)
	b.tick(0.6)
	assert_eq(b.tracked(), 0)


func test_burn_damage_ticks() -> void:
	b.apply(e, F)
	var d := b.tick(1.0)
	assert_almost_eq(float(d[e]), 4.0, 0.001)
	b.tick(5.0)
	assert_false(b.tick(1.0).has(e))


func test_cold_hits_progressive() -> void:
	b.apply(e, I)
	assert_eq(b.cold_hits(e), 1)
	b.apply(e, I)
	b.apply(e, I)
	assert_true(b.cold_full(e))
	b.apply(e, I)
	assert_eq(b.cold_hits(e), 3)
	b.tick(3.1)
	assert_eq(b.cold_hits(e), 0)


func test_boss_gets_poise_not_freeze() -> void:
	b.apply(e, I, true)
	var r := b.apply(e, V, true)
	assert_eq(r[0].freeze, 0.0)
	assert_eq(r[0].poise, 25.0)


func test_reaction_applies_no_state() -> void:
	_pair(F, I)
	assert_false(b.has_fire(e) or b.has_ice(e) or b.has_volt(e))


func test_react_pct_boosts() -> void:
	b.react_pct = 0.5
	assert_eq(_pair(F, I)[0].damage, 30.0)


func test_death_and_room_clear() -> void:
	var o := RefCounted.new()
	b.apply(e, F)
	b.apply(o, V)
	b.clear(e)
	assert_false(b.has_fire(e))
	assert_true(b.has_volt(o))
	b.clear_all()
	assert_eq(b.tracked(), 0)
	assert_eq(b.apply(o, F).size(), 0, "no ghost state after room change")


func test_targets_independent() -> void:
	var o := RefCounted.new()
	b.apply(e, F)
	assert_eq(b.apply(o, I).size(), 0)
