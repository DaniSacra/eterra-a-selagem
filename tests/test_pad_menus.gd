extends GutTest
## QA (A8, HUB-E): the gamepad's A presses the button in focus and B goes back, in every menu (Controls.MENU_BUTTONS
## adds them to ui_accept and ui_cancel; the engine's own are only Enter, Space and Escape). The flows by real pad
## events: tools/title_pad_check.gd and tools/hub_pad_check.gd.


func test_ui_accept_answers_the_pad_a() -> void:
	var a := InputEventJoypadButton.new()
	a.button_index = JOY_BUTTON_A
	a.pressed = true
	assert_true(InputMap.event_is_action(a, &"ui_accept"), "A is ui_accept")


func test_ui_cancel_answers_the_pad_b() -> void:
	var b := InputEventJoypadButton.new()
	b.button_index = JOY_BUTTON_B
	b.pressed = true
	assert_true(InputMap.event_is_action(b, &"ui_cancel"), "B is ui_cancel")
