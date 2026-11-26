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
	assert_eq(l.key(), &"lesson_power", "GP-1: the Corte Circular after the combo")
	l.feed(&"power")
	assert_eq(l.key(), &"lesson_dodge")
	l.feed(&"crossed")
	assert_eq(l.key(), &"lesson_special", "the Lança")
	l.feed(&"special")
	assert_eq(l.key(), &"obj_bless", "then the Blessing")
	assert_true(l.blessing_due())
	assert_false(l.done())
	l.feed(&"blessing")
	assert_true(l.done())
	assert_eq(l.key(), &"")


func test_a_finisher_alone_makes_the_clicks_and_a_gesture_out_of_turn_still_counts() -> void:
	var l := AnteLesson.new()
	l.feed(&"crossed")  # (the stream before the third click)
	l.feed(&"finisher")
	assert_true(l.is_done(&"attack"))
	assert_true(l.is_done(&"dodge"))
	assert_eq(l.current(), &"power", "the line asks the first one not done")


func test_the_warrior_has_no_brado_or_investida_step_and_the_maga_keeps_hers() -> void:
	var l := AnteLesson.new()
	assert_false(l.steps.has(&"shout"))
	assert_false(l.steps.has(&"rush"))
	for e in [&"finisher", &"power", &"special", &"crossed"]:
		l.feed(e)
	assert_true(l.blessing_due())
	var m := AnteLesson.new(true)
	assert_true(m.steps.has(&"shout") and m.steps.has(&"rush"))
	assert_false(m.steps.has(&"power"))


func test_the_robot_skips_every_tip_but_the_stream_and_the_blessing() -> void:
	var l := AnteLesson.new()
	for s in l.steps:
		if s != &"dodge" and s != &"blessing":
			l.skip(s)
	assert_eq(l.current(), &"dodge")
	l.feed(&"crossed")
	assert_true(l.blessing_due(), "the Blessing is for him too")


func test_every_tip_has_its_text_with_the_binding() -> void:
	for k in AnteLesson.KEYS.values():
		assert_ne(T.t(k), String(k), "%s has its text" % k)
	for k: StringName in [&"lesson_attack", &"lesson_special", &"lesson_power", &"lesson_dodge", &"lesson_shout", &"lesson_rush"]:
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
