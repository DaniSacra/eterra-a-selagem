extends GutTest
## GP-1 (warrior_v1 3): tap or hold on one blow button (ButtonIntent), pure.

const T := 0.2
const F := 1.0 / 60.0


func _press(it: ButtonIntent, can_hold := true) -> ButtonIntent.Out:
	return it.update(F, true, true, can_hold, T)


func _hold(it: ButtonIntent, seconds: float, can_hold := true) -> Array:
	var outs: Array = []
	for i in roundi(seconds / F):
		var out := it.update(F, false, true, can_hold, T)
		if out != ButtonIntent.Out.NONE:
			outs.append(out)
	return outs


func test_a_tap_let_go_before_the_threshold_is_one_tap() -> void:
	var it := ButtonIntent.new()
	assert_eq(_press(it), ButtonIntent.Out.NONE, "nothing at the press: the tap comes on the release")
	assert_eq(_hold(it, 0.1), [])
	assert_eq(it.update(F, false, false, true, T), ButtonIntent.Out.TAP)
	assert_eq(it.state, ButtonIntent.State.REST)
	assert_eq(it.update(F, false, false, true, T), ButtonIntent.Out.NONE, "once")


func test_a_press_and_release_inside_one_frame_is_a_tap() -> void:
	var it := ButtonIntent.new()
	assert_eq(it.update(F, true, false, true, T), ButtonIntent.Out.TAP)


func test_a_hold_past_the_threshold_never_taps() -> void:
	var it := ButtonIntent.new()
	_press(it)
	var outs := _hold(it, 0.5)
	assert_eq(outs, [ButtonIntent.Out.HOLD_BEGAN], "the hold begins once, at the threshold")
	assert_true(it.holding())
	assert_gt(it.held_t, 0.45, "the charge clock counts from the press")
	assert_eq(it.update(F, false, false, true, T), ButtonIntent.Out.NONE, "let go before the charge filled: nothing comes")
	assert_eq(it.state, ButtonIntent.State.REST)


func test_a_fired_hold_ignores_the_button_until_it_is_let_go() -> void:
	var it := ButtonIntent.new()
	_press(it)
	_hold(it, 0.3)
	it.fire()
	assert_eq(_hold(it, 0.5), [])
	assert_eq(it.update(F, false, false, true, T), ButtonIntent.Out.NONE, "letting go after the blow is no tap")
	assert_eq(it.state, ButtonIntent.State.REST)
	_press(it)
	assert_eq(it.update(F, false, false, true, T), ButtonIntent.Out.TAP, "a new press starts over")


func test_a_hold_without_magia_is_refused_once_and_never_taps() -> void:
	var it := ButtonIntent.new()
	_press(it, false)
	var outs := _hold(it, 0.6, false)
	assert_eq(outs, [ButtonIntent.Out.REFUSED], "once")
	assert_eq(it.update(F, false, false, false, T), ButtonIntent.Out.NONE, "and no tap on the release")
	assert_eq(it.state, ButtonIntent.State.REST)


func test_the_fallback_gives_the_tap_with_the_refusal() -> void:
	var it := ButtonIntent.new()
	it.update(F, true, true, false, T, true)
	var outs: Array = []
	for i in 20:
		var out := it.update(F, false, true, false, T, true)
		if out != ButtonIntent.Out.NONE:
			outs.append(out)
	assert_eq(outs, [ButtonIntent.Out.REFUSED_TAP])


func test_the_dodge_cancels_in_every_state_and_the_button_waits_for_its_release() -> void:
	for stage in [0.05, 0.4]:
		var it := ButtonIntent.new()
		_press(it)
		_hold(it, stage)
		it.cancel(true)
		assert_eq(_hold(it, 0.5), [], "ignored while still down")
		assert_eq(it.update(F, false, false, true, T), ButtonIntent.Out.NONE, "no tap on the release")
		assert_eq(it.state, ButtonIntent.State.REST)
	var refused := ButtonIntent.new()
	_press(refused, false)
	_hold(refused, 0.3, false)
	refused.cancel(false)
	assert_eq(refused.state, ButtonIntent.State.REST, "a button already up goes straight to rest")


func test_a_new_press_after_the_release_starts_over() -> void:
	var it := ButtonIntent.new()
	_press(it)
	_hold(it, 0.5)
	it.update(F, false, false, true, T)
	_press(it)
	assert_eq(_hold(it, 0.1), [])
	assert_eq(it.update(F, false, false, true, T), ButtonIntent.Out.TAP)


func test_the_threshold_is_the_feels() -> void:
	assert_eq(Feel.live().hold_threshold, 0.2)
	assert_false(Feel.live().hold_fallback_tap)
