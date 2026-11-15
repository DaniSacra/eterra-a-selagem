extends GutTest
## What a frame may start (FxBudget) and which damage numbers show (NumberTally): cycle 8, fewer effects piling on
## the paladin; one number per target that counts up; finishers never hidden.

const PALE := Color(0.9, 0.9, 0.85)
const EMERALD := Color(0.3, 1.0, 0.45)


func test_a_budget_grants_up_to_its_limit_each_frame() -> void:
	var b := FxBudget.new({&"chips": 10, &"gashes": 2})
	assert_eq(b.take(&"chips", 6), 6)
	assert_eq(b.take(&"chips", 6), 4, "only what is left of the frame")
	assert_eq(b.take(&"chips", 6), 0)
	assert_true(b.allows(&"gashes"))
	assert_true(b.allows(&"gashes"))
	assert_false(b.allows(&"gashes"))
	assert_eq(b.used(&"chips"), 10)
	b.reset()
	assert_eq(b.take(&"chips", 3), 3, "a new frame has the whole budget again")
	assert_true(b.allows(&"gashes"))


func test_a_kind_without_a_limit_is_never_held_back() -> void:
	var b := FxBudget.new({&"chips": 1})
	assert_eq(b.take(&"bursts", 50), 50)
	assert_eq(b.take(&"chips", 0), 0)


func test_hits_on_the_same_target_join_one_number() -> void:
	var t := NumberTally.new(20)
	var a := t.add(7, Vector3.ZERO, 20.0, PALE, false)
	t.age(0.2)
	var b := t.add(7, Vector3(0.3, 0, 0), 25.0, PALE, false)
	assert_eq(a, b, "the second hit joins the first number")
	assert_true(t.merged)
	assert_eq(t.entries[a].amount, 45.0)
	assert_eq(t.entries[a].life, 0.0, "the joined number shows again from its pop")
	assert_eq(t.shown_count(), 1)


func test_other_targets_and_late_hits_get_their_own_number() -> void:
	var t := NumberTally.new(20)
	var a := t.add(7, Vector3.ZERO, 20.0, PALE, false)
	assert_ne(t.add(8, Vector3.ZERO, 20.0, PALE, false), a, "another enemy")
	assert_false(t.merged)
	t.age(NumberTally.MERGE_TIME + 0.05)
	assert_ne(t.add(7, Vector3.ZERO, 20.0, PALE, false), a, "too long after the last hit")
	var c := t.add(0, Vector3.ZERO, 5.0, PALE, false)
	assert_ne(t.add(0, Vector3.ZERO, 5.0, PALE, false), c, "no key: never joined")


func test_a_finisher_joins_and_turns_the_number_big() -> void:
	var t := NumberTally.new(20)
	var a := t.add(3, Vector3.ZERO, 20.0, PALE, false)
	assert_eq(t.add(3, Vector3.ZERO, 60.0, EMERALD, true), a)
	assert_true(t.entries[a].big)
	assert_eq(t.entries[a].color, EMERALD)
	assert_eq(t.entries[a].amount, 80.0)


func test_another_colour_keeps_its_own_number() -> void:
	# a burn or an armour hit is not the same number as the sword's
	var t := NumberTally.new(20)
	var a := t.add(3, Vector3.ZERO, 20.0, PALE, false)
	assert_ne(t.add(3, Vector3.ZERO, 4.0, Color(1.0, 0.45, 0.12), false), a)


func test_a_crowd_shows_at_most_its_limit_and_keeps_the_biggest() -> void:
	var t := NumberTally.new(40)
	for i in NumberTally.CROWD + 4:
		t.add(i + 1, Vector3(randf() * 0.5, 0, 0), 10.0 + i, PALE, false)
	assert_eq(t.shown_count(), NumberTally.CROWD)
	var least := INF
	for e in t.entries:
		if e.shown:
			least = minf(least, e.amount)
	assert_eq(least, 14.0, "the smallest gave way to the bigger ones")
	assert_eq(t.add(99, Vector3.ZERO, 1.0, PALE, false), -1, "a smaller one does not show")


func test_the_screen_shows_at_most_max_shown() -> void:
	var t := NumberTally.new(40)
	for i in NumberTally.MAX_SHOWN + 6:
		# each far from the others: only the screen's limit holds them
		t.add(i + 1, Vector3(i * 10.0, 0, 0), 10.0, PALE, false)
	assert_eq(t.shown_count(), NumberTally.MAX_SHOWN)


func test_finishers_are_never_hidden() -> void:
	var t := NumberTally.new(40)
	for i in NumberTally.CROWD:
		assert_gt(t.add(i + 1, Vector3.ZERO, 500.0, PALE, false), -1)
	for i in 4:
		assert_gt(t.add(100 + i, Vector3.ZERO, 60.0, EMERALD, true), -1, "a finisher shows even next to bigger numbers")
	for i in 4:
		t.add(200 + i, Vector3.ZERO, 900.0, PALE, false)
	var bigs := 0
	for e in t.entries:
		if e.shown and e.big:
			bigs += 1
	assert_eq(bigs, 4, "no common number pushes a finisher out")


func test_a_screen_full_of_finishers_keeps_the_biggest() -> void:
	var t := NumberTally.new(40)
	for i in NumberTally.MAX_SHOWN + 4:
		t.add(i + 1, Vector3.ZERO, 100.0 + i, EMERALD, true)
	assert_eq(t.shown_count(), NumberTally.MAX_SHOWN, "never more than the screen holds")
	assert_eq(t.add(99, Vector3.ZERO, 50.0, EMERALD, true), -1, "a smaller finisher does not push a bigger one out")
	for e in t.entries:
		if e.shown:
			assert_gte(e.amount, 104.0, "the biggest stay")


func test_numbers_go_after_their_life_and_words_always_show() -> void:
	var t := NumberTally.new(3)
	t.add(1, Vector3.ZERO, 10.0, PALE, false)
	t.age(NumberTally.LIFE + 0.01)
	assert_eq(t.shown_count(), 0)
	for i in 5:
		assert_gt(t.add_word(Vector3.ZERO, PALE), -1)
