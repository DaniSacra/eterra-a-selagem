extends GutTest
## Apogeu's books (redesign 2026-11-24, B.2): pure rules, per target.


func test_it_sums_per_target() -> void:
	var l := ApogeeLedger.new()
	l.add(1, 15.0)
	l.add(1, 10.0)
	l.add(2, 7.0)
	assert_eq(l.total(1), 25.0)
	assert_eq(l.total(2), 7.0, "two targets of the same spin never share")
	assert_eq(l.total(3), 0.0)


func test_the_finisher_is_a_share_of_the_sum_capped_at_four_times_itself() -> void:
	var l := ApogeeLedger.new()
	l.add(1, 40.0)
	assert_eq(l.finisher(1, 1.5, 100.0), 60.0)
	assert_eq(l.finisher(1, 1.5, 10.0), 40.0, "400% of a 10 blow")
	assert_eq(l.finisher(9, 1.5, 10.0), 0.0, "nothing known of the target")


func test_nothing_or_less_is_not_added() -> void:
	var l := ApogeeLedger.new()
	l.add(1, 0.0)
	l.add(1, -4.0)
	assert_eq(l.size(), 0)


func test_reset_clear_and_idle() -> void:
	var l := ApogeeLedger.new()
	l.add(1, 5.0)
	l.add(2, 5.0)
	l.reset(1)
	assert_eq(l.total(1), 0.0)
	assert_eq(l.total(2), 5.0)
	l.step(3.9)
	assert_eq(l.total(2), 5.0)
	l.add(2, 1.0)
	l.step(3.9)
	assert_eq(l.total(2), 6.0, "a blow renews the wait")
	l.step(0.2)
	assert_eq(l.total(2), 0.0, "4 s without a blow")
	l.add(3, 5.0)
	l.clear()
	assert_eq(l.size(), 0)
