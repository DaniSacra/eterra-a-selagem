extends GutTest
## The HUD's own rules: the trail a hit leaves on a bar, when an action reads as busy, where the chevron for
## something out of view goes, and when a body counts as standing behind the actions.

const VIEW := Rect2(0, 0, 1280, 720)
const FRAME := Rect2(30, 96, 1220, 508)


func _bar() -> HudBar:
	var b := HudBar.new().setup(Color.RED, Vector2(200, 20))
	add_child_autofree(b)
	return b


func test_bar_trail_shows_what_a_hit_took_then_drains() -> void:
	var b := _bar()
	b.show_value(1.0)
	assert_eq(b.trail(), 1.0, "no trail while nothing was lost")
	b.show_value(0.6)
	assert_eq(b.trail(), 1.0, "the trail starts where the bar was")
	b._process(HudBar.TRAIL_TIME * HudBar.TRAIL_HOLD * 0.9)
	assert_eq(b.trail(), 1.0, "and holds there for a moment")
	b._process(HudBar.TRAIL_TIME * 0.4)
	assert_between(b.trail(), 0.61, 0.99, "then drains")
	b._process(HudBar.TRAIL_TIME)
	assert_eq(b.trail(), 0.6, "down to the fill, within TRAIL_TIME")


func test_bar_trail_keeps_the_older_loss_on_a_second_hit() -> void:
	var b := _bar()
	b.show_value(0.5)
	b.show_value(0.3)
	assert_eq(b.trail(), 1.0)


func test_bar_gain_leaves_no_trail() -> void:
	var b := _bar()
	b.show_value(0.5)
	b._process(1.0)
	b.show_value(0.8)
	assert_eq(b.trail(), 0.8)


func test_bar_glint_only_on_a_visible_change() -> void:
	var b := _bar()
	b.show_value(0.5)
	b._process(1.0)
	b.show_value(0.5 + HudBar.TIP_MIN * 0.5)
	assert_eq(b._tip, 0.0, "a slow refill does not keep the glint on")
	b.show_value(0.6)
	assert_eq(b._tip, 1.0)


func test_slot_busy_only_without_charges() -> void:
	var s := ActionSlot.new().setup(&"dodge", Boon.Slot.DASH)
	add_child_autofree(s)
	s.refresh(null, 0.5, 1, 2)
	assert_false(s.busy(), "one dodge left: it recharges but is ready")
	s.refresh(null, 0.5, 0, 2)
	assert_true(s.busy())
	s.refresh(null, 0.0, 2, 2)
	assert_false(s.busy())
	var cast := ActionSlot.new().setup(&"cast", Boon.Slot.CAST)
	add_child_autofree(cast)
	cast.refresh(null, 0.3)
	assert_true(cast.busy())


func test_slot_shines_when_the_recharge_ends() -> void:
	var s := ActionSlot.new().setup(&"cast", Boon.Slot.CAST)
	add_child_autofree(s)
	s.refresh(null, 0.4)
	assert_eq(s._flash, 0.0)
	s.refresh(null, 0.0)
	assert_eq(s._flash, 1.0)
	s._process(ActionSlot.READY_FLASH)
	assert_eq(s._flash, 0.0)


func test_sweep_runs_around_the_diamond() -> void:
	assert_eq(ActionSlot._sweep(Vector2.ZERO, 10.0, 0.0).size(), 1, "nothing yet")
	var half := ActionSlot._sweep(Vector2.ZERO, 10.0, 0.5)
	assert_eq(half[half.size() - 1], Vector2(0, 10), "half way: at the bottom point")
	var full := ActionSlot._sweep(Vector2.ZERO, 10.0, 1.0)
	assert_eq(full.size(), 5)
	assert_eq(full[4], full[0], "closed")


func test_no_chevron_for_what_is_on_screen() -> void:
	assert_null(Hud.edge_point(Vector2(640, 360), VIEW, FRAME))
	assert_null(Hud.edge_point(Vector2(10, 700), VIEW, FRAME), "in view, even outside the chevrons' frame")


func test_chevron_sits_on_the_frame_towards_the_target() -> void:
	var right: Vector2 = Hud.edge_point(Vector2(2000, 350), VIEW, FRAME)
	assert_almost_eq(right.x, FRAME.end.x, 0.01)
	assert_almost_eq(right.y, 350.0, 0.01)
	var up: Vector2 = Hud.edge_point(Vector2(640, -400), VIEW, FRAME)
	assert_almost_eq(up.y, FRAME.position.y, 0.01)
	var corner: Vector2 = Hud.edge_point(Vector2(-900, 2000), VIEW, FRAME)
	assert_true(FRAME.grow(0.01).has_point(corner))
	assert_almost_eq(corner.y, FRAME.end.y, 0.01, "never over the bottom row")


func test_body_behind_the_actions() -> void:
	var actions := Rect2(500, 640, 280, 62)
	assert_true(Hud.body_rect(Vector2(640, 690), 70.0).intersects(actions), "feet on the row")
	assert_true(Hud.body_rect(Vector2(640, 730), 70.0).intersects(actions), "feet below the screen, head on the row")
	assert_false(Hud.body_rect(Vector2(640, 630), 70.0).intersects(actions), "standing above the row")
	assert_false(Hud.body_rect(Vector2(300, 690), 70.0).intersects(actions), "beside it")
