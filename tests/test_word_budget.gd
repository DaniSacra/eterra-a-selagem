extends GutTest
## WordBudget (UX-08): the name of a reaction three times a run, six words alive at once.


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


func test_six_words_alive_at_once() -> void:
	var b := WordBudget.new()
	var shown := 0
	for i in 40:
		if b.admit(float(i) * 0.01):
			shown += 1
	assert_eq(shown, WordBudget.MAX_LIVE)
	assert_true(b.admit(WordBudget.LIFE + 0.01), "once the first ones are gone it admits again")


func test_stress_never_over_six_alive() -> void:
	var b := WordBudget.new()
	var live: Array[float] = []
	var t := 0.0
	for i in 3000:  # a horde asks for a word every 10 ms for 30 s
		t += 0.01
		while not live.is_empty() and t - live[0] >= WordBudget.LIFE:
			live.pop_front()
		if b.admit(t):
			live.append(t)
		assert_lte(live.size(), WordBudget.MAX_LIVE)
