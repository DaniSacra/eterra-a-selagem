extends GutTest
## PT-25-8 and PT-25-9: the Antessala's tips one at a time (AnteLesson) and the stream only a dash crosses (GapRule).

const STREAM := Rect2(-16.5, -10.6, 33.0, 2.6)


# ---------- the tips ----------

func test_the_tips_come_one_at_a_time_in_order() -> void:
	var l := AnteLesson.new()
	assert_eq(l.key(), &"lesson_attack")
	l.feed(&"light")
	l.feed(&"light")
	assert_eq(l.key(), &"lesson_attack", "two clicks are not three")
	l.feed(&"light")
	assert_eq(l.key(), &"lesson_heavy", "2026-11-26: the Golpe Esmagador (the attack held) after the combo")
	l.feed(&"heavy")
	assert_eq(l.key(), &"lesson_power", "GP-1: the Corte Circular")
	l.feed(&"power")
	assert_eq(l.key(), &"lesson_special", "the Lança")
	l.feed(&"special")
	assert_eq(l.key(), &"lesson_dodge", "then the stream")
	l.feed(&"crossed")
	assert_eq(l.key(), &"lesson_trap", "then the trap's slab")
	assert_false(l.done())
	l.feed(&"passed")
	assert_true(l.done(), "the Blessing is the Sala 00's: nothing left here")
	assert_eq(l.key(), &"")
	assert_false(l.steps.has(&"blessing"), "no Blessing step in the Antessala")


func test_a_finisher_alone_makes_the_clicks_and_a_gesture_out_of_turn_still_counts() -> void:
	var l := AnteLesson.new()
	l.feed(&"crossed")  # (the stream before the third click)
	l.feed(&"finisher")
	assert_true(l.is_done(&"attack"))
	assert_true(l.is_done(&"dodge"))
	assert_eq(l.current(), &"heavy", "the line asks the first one not done")
	l.feed(&"passed")  # (the slab passed by before the Esmagador)
	l.feed(&"special")
	assert_eq(l.current(), &"heavy", "still the first not done")
	l.feed(&"heavy")
	assert_eq(l.current(), &"power")


func test_no_hero_has_a_brado_or_investida_step_and_the_maga_is_told_with_her_own_words() -> void:
	var l := AnteLesson.new()
	assert_false(l.steps.has(&"shout"))
	assert_false(l.steps.has(&"rush"))
	for e in [&"finisher", &"heavy", &"power", &"special", &"crossed", &"passed"]:
		l.feed(e)
	assert_true(l.done())
	var m := AnteLesson.new(true)
	assert_false(m.steps.has(&"shout") or m.steps.has(&"rush"), "GP-5: nothing on Q or E for her either")
	assert_eq(m.steps, AnteLesson.ORDER_MAGA)
	assert_false(m.steps.has(&"heavy"), "no Esmagador for her: her holds are the Combustão and the Inverno")
	assert_eq(m.key(), &"lesson_spark_maga")
	m.feed(&"spark")
	assert_eq(m.key(), &"lesson_breath_maga", "her words, her order")


func test_the_robot_skips_every_tip_but_the_stream() -> void:
	var l := AnteLesson.new()
	for s in l.steps:
		if s != &"dodge":
			l.skip(s)
	assert_eq(l.current(), &"dodge")
	l.feed(&"crossed")
	assert_true(l.done(), "the door opens for him too")


func test_every_tip_has_its_text_with_the_binding() -> void:
	for k in AnteLesson.KEYS.values():
		assert_ne(T.t(k), String(k), "%s has its text" % k)
	for k: StringName in [&"lesson_attack", &"lesson_heavy", &"lesson_special", &"lesson_power", &"lesson_dodge", &"lesson_trap", &"obj_altar", &"altar_intro"]:
		assert_false(Objective.text(k).contains("{"), "%s has no hole left" % k)
		assert_false(Objective.text(k).contains("—"), "no long dash")
	assert_eq(Objective.pick({"kind": &"ante", "lesson": &"lesson_dodge", "near_plates": true}), &"lesson_dodge", "the tip first in the Antessala")


# ---------- the stream ----------

func test_walking_into_the_stream_stays_on_the_bank_it_came_from() -> void:
	var south := Vector2(3.0, STREAM.end.y + 0.3)
	var end := GapRule.keep_out([STREAM], south, south + Vector2(0.0, -2.0))
	assert_gt(end.y, STREAM.end.y, "south bank")
	var north := Vector2(3.0, STREAM.position.y - 0.3)
	end = GapRule.keep_out([STREAM], north, north + Vector2(0.0, 2.0))
	assert_lt(end.y, STREAM.position.y, "north bank")
	assert_eq(GapRule.keep_out([STREAM], south, south + Vector2(1.0, 0.5)), south + Vector2(1.0, 0.5), "on his bank he walks free")


func test_one_who_lands_inside_goes_to_the_nearest_bank() -> void:
	var in_south := Vector2(0.0, STREAM.end.y - 0.4)
	assert_gt(GapRule.keep_out([STREAM], in_south, in_south).y, STREAM.end.y)
	var in_north := Vector2(0.0, STREAM.position.y + 0.4)
	assert_lt(GapRule.keep_out([STREAM], in_north, in_north).y, STREAM.position.y)


func test_the_robots_hop_starts_on_the_bank_toward_the_goal() -> void:
	var reach := 5.6  # (the dash: 450 / 80 m)
	var goal := Vector2(10.5, -14.0)
	assert_eq(GapRule.hop([STREAM], Vector2(2.0, 0.0), goal, reach), Vector2.ZERO, "far from the bank it walks")
	var at := Vector2(9.0, STREAM.end.y + 0.3)
	var dir := GapRule.hop([STREAM], at, goal, reach)
	assert_gt(dir.length(), 0.9, "on the bank it dashes")
	assert_lt(dir.y, 0.0, "north, toward the goal")
	assert_eq(GapRule.hop([STREAM], Vector2(9.0, STREAM.position.y - 0.3), goal, reach), Vector2.ZERO, "past it, no hop")
	assert_eq(GapRule.hop([STREAM], at, goal, 1.0), Vector2.ZERO, "a stream wider than the dash is no hop")


func test_a_stream_the_dash_crosses_is_between_2_and_4_m() -> void:
	assert_gte(STREAM.size.y, 2.0)
	assert_lte(STREAM.size.y, 4.0)


# ---------- the Maga's lesson (F6) ----------

func test_the_maga_lesson_walks_her_four_blows_in_order() -> void:
	var m := AnteLesson.new(true)
	assert_eq(m.steps.size(), 6)
	var want: Array[StringName] = [&"lesson_spark_maga", &"lesson_breath_maga", &"lesson_combust_maga", &"lesson_winter_maga", &"lesson_dodge", &"lesson_trap"]
	for e: StringName in [&"spark", &"breath", &"combust", &"winter", &"crossed", &"passed"]:
		assert_eq(m.key(), want.pop_front(), "the tip before %s" % e)
		m.feed(e)
	assert_true(m.done(), "the door opens after her four blows, the stream and the slab")


func test_a_maga_blow_out_of_turn_counts_and_the_warriors_gestures_do_not() -> void:
	var m := AnteLesson.new(true)
	m.feed(&"winter")
	m.feed(&"finisher")  # (the Warrior's: no step of hers)
	assert_eq(m.current(), &"spark", "the first not done")
	assert_true(m.is_done(&"winter"))
	for s in [&"spark", &"breath", &"combust"]:
		m.feed(s)
	assert_eq(m.current(), &"dodge")


func test_the_maga_tips_say_tap_or_hold_and_have_no_hole_and_no_dash() -> void:
	for k: StringName in AnteLesson.KEYS_MAGA.values():
		var t := Objective.text(k)
		assert_false(t.contains("{"), "%s has no hole left" % k)
		assert_false(t.contains("—"))
	assert_true(T.t(&"lesson_combust_maga").begins_with("Segure"))
	assert_true(T.t(&"lesson_winter_maga").begins_with("Segure"))
	assert_true(T.t(&"lesson_spark_maga").begins_with("Aperte"))
