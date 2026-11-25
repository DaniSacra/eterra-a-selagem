extends GutTest
## The effects pass of 2026-11-25: the hit star on every landed blow, the dust puff of a death, the floor darkening under
## the shock, and the screen flash only when asked and never with the comfort options off.

var fx: Fx


func before_each() -> void:
	var camera := Camera3D.new()
	camera.position = Vector3(0, 30, 30)
	add_child_autofree(camera)
	camera.look_at(Vector3.ZERO)
	var overlay := Control.new()
	add_child_autofree(overlay)
	fx = Fx.new()
	add_child_autofree(fx)
	fx.setup(camera, overlay)


func test_contact_throws_a_star() -> void:
	fx.contact(Vector3(1, 1, 1), Vector3.RIGHT, Color(0.3, 1.0, 0.5))
	assert_eq(fx.showing(&"stars"), 1)


func test_stars_have_a_frame_budget() -> void:
	for i in 20:
		fx.hit_star(Vector3(i, 1, 0), Color.WHITE)
	assert_eq(fx.showing(&"stars"), Fx.BUDGET_STARS)


func test_bone_death_leaves_a_puff_and_a_star() -> void:
	fx.burst(&"bone", Vector3(0, 0.6, 0))
	assert_eq(fx.showing(&"puffs"), 1)
	assert_eq(fx.showing(&"stars"), 1)


func test_shock_darkens_the_floor() -> void:
	fx.shock(Vector2.ZERO, 2.0, Color.GREEN, 1.0)
	assert_eq(fx.showing(&"scorches"), 1)


func test_screen_flash_follows_the_options() -> void:
	assert_eq(fx.flash_level(), 0.0)
	fx.screen_flash(1.0)
	assert_gt(fx.flash_level(), 0.0)
	assert_lte(fx.flash_level(), Fx.SCREEN_FLASH_PEAK)
	fx.tick(1.0)
	assert_eq(fx.flash_level(), 0.0)
	fx.impact_frames = false
	fx.screen_flash(1.0)
	assert_eq(fx.flash_level(), 0.0)
	fx.impact_frames = true
	fx.shake_scale = 0.0
	fx.screen_flash(1.0)
	assert_eq(fx.flash_level(), 0.0)
