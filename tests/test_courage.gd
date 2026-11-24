extends GutTest


func test_stacks_up_to_the_limit() -> void:
	var s := 0
	for i in 5:
		s = Courage.after(s, "death", 3)
	assert_eq(s, Courage.MAX_STACKS)
	assert_eq(Courage.life(s), 9.0)
	assert_eq(Courage.pomegranates(s), 3)


func test_resets_past_room_five_or_on_victory() -> void:
	assert_eq(Courage.after(2, "death", 6), 0)
	assert_eq(Courage.after(2, "death", 5), 3)
	assert_eq(Courage.after(2, "victory", 3), 0)
	assert_eq(Courage.after(2, "quit", 3), 2)


func test_vow_turns_it_off() -> void:
	assert_eq(Courage.active(3, true), 0)
	assert_eq(Courage.active(3, false), 3)
	assert_eq(Courage.active(9, false), Courage.MAX_STACKS)


func test_saved_per_hero() -> void:
	var data := SaveData.defaults()
	Courage.set_stacks(data, "warrior", 2)
	assert_eq(Courage.stacks_of(data, "warrior"), 2)
	assert_eq(Courage.stacks_of(data, "maga"), 0)
