extends GutTest


func test_plain_hit_is_the_base_damage() -> void:
	assert_eq(DamageCalc.hit(10.0, 0.0, false, false, 0.0, false, 0.0), 10.0)


func test_gift_bonus_adds_a_percentage() -> void:
	assert_eq(DamageCalc.hit(20.0, 0.25, false, false, 0.0, false, 0.0), 25.0)


## C13-07 (D-10): the combo counter adds no damage (Hades II has no such bonus).
func test_the_combo_counter_adds_no_damage() -> void:
	assert_false(DamageCalc.new().has_method(&"combo_bonus"), "the bonus is gone")
	assert_eq(DamageCalc.hit(100.0, 0.0, false, false, 0.0, false, 0.0), 100.0)


func test_launched_enemies_take_half_again() -> void:
	assert_eq(DamageCalc.hit(10.0, 0.0, true, false, 0.0, false, 0.0), 15.0)


func test_frozen_enemies_shatter_for_extra() -> void:
	assert_eq(DamageCalc.hit(20.0, 0.0, false, true, 0.5, false, 0.0), 30.0)
	assert_eq(DamageCalc.hit(20.0, 0.0, false, false, 0.5, false, 0.0), 20.0, "not frozen, no shatter")


func test_light_doubles_against_the_undead_only() -> void:
	assert_eq(DamageCalc.hit(10.0, 0.0, false, false, 0.0, true, 2.0), 20.0)
	assert_eq(DamageCalc.hit(10.0, 0.0, false, false, 0.0, false, 2.0), 10.0)
	assert_eq(DamageCalc.hit(10.0, 0.0, false, false, 0.0, true, 0.0), 10.0, "without the gift nothing changes")


func test_everything_stacks_and_never_drops_below_one() -> void:
	assert_eq(DamageCalc.hit(10.0, 0.5, true, true, 1.0, true, 2.0), 90.0)
	assert_eq(DamageCalc.hit(0.1, 0.0, false, false, 0.0, false, 0.0), 1.0)


func test_spatial_hash_buckets_by_cell_and_clears() -> void:
	var h := SpatialHash.new(10.0)
	h.insert(Vector2(5, 5), "a")
	h.insert(Vector2(9, 1), "b")
	h.insert(Vector2(15, 5), "c")
	assert_eq(h.at_cell(0, 0).size(), 2)
	assert_eq(h.at_cell(1, 0), ["c"])
	assert_eq(h.at_cell(7, 7).size(), 0)
	h.clear()
	assert_eq(h.at_cell(0, 0).size(), 0)
	h.insert(Vector2(-1, -1), "d")
	assert_eq(h.at_cell(-1, -1), ["d"])


func test_armor_takes_the_blow_and_the_breaking_blow_does_not_spill() -> void:
	assert_eq(DamageCalc.against_armor(0.0, 30.0), [0.0, 30.0] as Array[float])
	assert_eq(DamageCalc.against_armor(100.0, 30.0), [70.0, 0.0] as Array[float])
	assert_eq(DamageCalc.against_armor(20.0, 30.0), [0.0, 0.0] as Array[float])


func test_magick_is_spent_only_when_there_is_enough() -> void:
	var m := Magick.new(100.0)
	assert_true(m.spend(60.0))
	assert_false(m.spend(60.0), "40 left is not enough")
	assert_almost_eq(m.value, 40.0, 0.001)
	m.gain(500.0)
	assert_almost_eq(m.value, 100.0, 0.001, "never above the maximum")
	assert_almost_eq(m.ratio(), 1.0, 0.001)
