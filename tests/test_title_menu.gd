extends GutTest
## Title menu (TitleMenu, TitleButton): the buttons follow the art of the title screen, not the screen.


## Stand-in for TitleBackdrop: the art at a known place and scale.
class Backdrop:
	extends Control
	signal layout_changed
	var rect := Rect2(200, 0, 1280, 720)

	func art_rect() -> Rect2:
		return rect

	func art_scale() -> float:
		return rect.size.x / 1672.0


func _menu() -> TitleMenu:
	var m := TitleMenu.new()
	add_child_autofree(m)
	return m


func test_buttons_sit_on_the_painted_frames() -> void:
	var back := Backdrop.new()
	add_child_autofree(back)
	var m := _menu()
	m.setup(back)
	var s := 1280.0 / 1672.0
	var start := m.button(TitleButton.Kind.START)
	assert_almost_eq(start.position.x, 200.0 + 926.0 * s, 0.01)
	assert_almost_eq(start.position.y, 401.0 * s, 0.01)
	assert_almost_eq(start.size.x, 449.0 * s, 0.01)
	var quit := m.button(TitleButton.Kind.QUIT)
	assert_almost_eq(quit.position.y, 657.0 * s, 0.01)
	# the three small ones are 71 art pixels apart and share the axis of Iniciar (x = 1151 in the art)
	for b in m.buttons:
		assert_almost_eq(b.position.x + b.size.x * 0.5, 200.0 + 1150.75 * s, 0.5)
	assert_almost_eq(m.buttons[2].position.y - m.buttons[1].position.y, 71.0 * s, 0.01)


func test_follows_the_backdrop_when_it_moves() -> void:
	var back := Backdrop.new()
	add_child_autofree(back)
	var m := _menu()
	m.setup(back)
	back.rect = Rect2(0, 100, 836, 470.5)
	back.layout_changed.emit()
	assert_almost_eq(m.buttons[0].position, Vector2(926, 401) * 0.5 + Vector2(0, 100), Vector2(0.01, 0.01))
	assert_almost_eq(m.buttons[0].size, Vector2(449, 89) * 0.5, Vector2(0.01, 0.01))


func test_alone_it_contains_the_art_in_its_own_size() -> void:
	var holder := Control.new()
	holder.size = Vector2(1680, 720)
	add_child_autofree(holder)
	var m := TitleMenu.new()
	holder.add_child(m)
	assert_almost_eq(m.art_scale(), 720.0 / 941.0, 0.0001)
	assert_almost_eq(m.art_origin().x, 200.0, 1.0)


func test_only_the_hexagon_takes_the_mouse() -> void:
	var m := _menu()
	var b := m.button(TitleButton.Kind.HOWTO)
	assert_true(b._has_point(b.size * 0.5))
	assert_false(b._has_point(Vector2(1, 1)), "the corner is outside the slanted end")
	assert_eq(m.mouse_filter, Control.MOUSE_FILTER_IGNORE)


func test_each_button_emits_its_signal() -> void:
	var m := _menu()
	watch_signals(m)
	for b in m.buttons:
		b.pressed.emit()
	assert_signal_emit_count(m, "start_pressed", 1)
	assert_signal_emit_count(m, "howto_pressed", 1)
	assert_signal_emit_count(m, "settings_pressed", 1)
	assert_signal_emit_count(m, "quit_pressed", 1)


func test_up_and_down_do_not_wrap() -> void:
	var m := _menu()
	var b := m.buttons
	assert_eq(b[0].get_node(b[0].focus_neighbor_top), b[0])
	assert_eq(b[0].get_node(b[0].focus_neighbor_bottom), b[1])
	assert_eq(b[2].get_node(b[2].focus_neighbor_bottom), b[3])
	assert_eq(b[3].get_node(b[3].focus_neighbor_bottom), b[3])


func test_without_quit_the_others_keep_their_places() -> void:
	var m := _menu()
	var before := m.buttons[2].position
	m.set_quit_visible(false)
	assert_false(m.buttons[3].visible)
	assert_eq(m.buttons[2].position, before)
	assert_eq(m.buttons[2].get_node(m.buttons[2].focus_neighbor_bottom), m.buttons[2])
	m.set_quit_visible(true)
	assert_eq(m.buttons[2].get_node(m.buttons[2].focus_neighbor_bottom), m.buttons[3])


func test_focus_first_and_lock() -> void:
	var m := _menu()
	m.focus_first()
	assert_true(m.buttons[0].has_focus())
	assert_false(m.buttons[0].show_ring, "no ring before the first navigation")
	m.set_enabled(false)
	assert_true(m.buttons[0].disabled)
	assert_false(m.buttons[0].greyed, "locked for a transition keeps the look")
	m.set_enabled(true)
	assert_false(m.buttons[0].disabled)


func test_ring_shows_after_navigation_and_hides_with_the_mouse() -> void:
	var m := _menu()
	m.focus_first()
	var ev := InputEventKey.new()
	ev.keycode = KEY_DOWN
	ev.physical_keycode = KEY_DOWN
	ev.pressed = true
	m._input(ev)
	assert_true(m.buttons[0].show_ring)
	m.buttons[1].mouse_entered.emit()
	assert_false(m.buttons[0].show_ring)
	assert_true(m.buttons[1].has_focus(), "the mouse takes the focus with it")


func test_intro_hides_then_finishes() -> void:
	var m := _menu()
	m.intro()
	assert_eq(m.buttons[0].appear, 0.0)
	m.finish_intro()
	assert_eq(m.buttons[3].appear, 1.0)


func test_labels_come_from_the_text_table() -> void:
	for key: StringName in TitleButton.TEXT_KEYS.values():
		assert_true(T.table.entries.has(String(key)), String(key))
		assert_false(T.t(key).contains("—"))
