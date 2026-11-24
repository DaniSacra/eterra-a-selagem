extends GutTest
## WordBudget (UX-08): the name of a reaction three times a run, six words a second.


func test_name_is_told_three_times() -> void:
	var b := WordBudget.new()
	var told := 0
	for i in 8:
		if b.named(&"react_thermal"):
			told += 1
	assert_eq(told, WordBudget.NAMED_MAX)
	assert_true(b.named(&"react_overload"), "each reaction has its own count")
	b.reset()
	assert_true(b.named(&"react_thermal"))


func test_six_words_a_second() -> void:
	var b := WordBudget.new()
	var shown := 0
	for i in 40:
		if b.admit(float(i) * 0.01):
			shown += 1
	assert_eq(shown, WordBudget.PER_SECOND)
	assert_true(b.admit(1.0), "a second later it admits again")
