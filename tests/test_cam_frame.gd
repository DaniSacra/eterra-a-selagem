extends GutTest
## The game camera's framing (CamFrame): the paladin never stands near an edge of the screen, wherever the room's
## margins hold the camera (QA of cycle 5, M3: the west landing), and the margins follow the camera's distance.

const ASPECT := 1672.0 / 941.0


func _screen(feel: Feel, hero: Vector2, target: Vector2, aspect: float = ASPECT) -> Vector2:
	return CamFrame.screen_of(hero, CamFrame.HERO_HEIGHT, target, feel.cam_distance, feel.cam_pitch, feel.cam_yaw, feel.cam_fov, aspect)


func _keep(feel: Feel, target: Vector2, hero: Vector2, aspect: float = ASPECT) -> Vector2:
	return CamFrame.keep(target, hero, feel.cam_distance, feel.cam_pitch, feel.cam_yaw, feel.cam_fov, aspect)


func test_what_the_camera_looks_at_is_the_middle_of_the_screen() -> void:
	var s := CamFrame.screen_of(Vector2(3, -2), 0.0, Vector2(3, -2), 54.0, 30.0, 35.0, 24.0, ASPECT)
	assert_almost_eq(s.x, 0.5, 0.001)
	assert_almost_eq(s.y, 0.5, 0.001)


func test_screen_directions_follow_the_turned_camera() -> void:
	# a step to the screen's right (Feel.screen_to_floor, as the keys do) shows to the right, a step up shows higher
	var right := CamFrame.screen_of(Feel.screen_to_floor(Vector2.RIGHT, 35.0) * 4.0, 0.0, Vector2.ZERO, 54.0, 30.0, 35.0, 24.0, ASPECT)
	assert_gt(right.x, 0.55)
	assert_almost_eq(right.y, 0.5, 0.001)
	var up := CamFrame.screen_of(Feel.screen_to_floor(Vector2.UP, 35.0) * 4.0, 0.0, Vector2.ZERO, 54.0, 30.0, 35.0, 24.0, ASPECT)
	assert_lt(up.y, 0.45)
	assert_almost_eq(up.x, 0.5, 0.001)


func test_screen_of_matches_a_real_camera() -> void:
	var feel := load(Feel.PATH) as Feel
	var cam: Camera3D = add_child_autofree(Camera3D.new())
	cam.fov = feel.cam_fov
	var target := Vector3(-4, 0, 5)
	cam.look_at_from_position(target + Feel.cam_offset_of(feel.cam_distance, feel.cam_pitch, feel.cam_yaw), target, Vector3.UP)
	var view := cam.get_viewport().get_visible_rect().size
	var hero := Vector2(-15, 19)
	var real := cam.unproject_position(Vector3(hero.x, CamFrame.HERO_HEIGHT, hero.y)) / view
	var ours := _screen(feel, hero, Vector2(target.x, target.z), view.x / view.y)
	assert_almost_eq(ours.x, real.x, 0.002)
	assert_almost_eq(ours.y, real.y, 0.002)


func test_the_paladin_is_never_near_an_edge_of_the_screen() -> void:
	var feel := load(Feel.PATH) as Feel
	var lo := CamFrame.SAFE - 0.001
	# every corner he can walk to (the hall is 32 x 30 m, the landing reaches 20.5 m south), the camera held anywhere
	# inside the room's margins, on a wide and on a narrow screen
	for aspect: float in [ASPECT, 4.0 / 3.0, 21.0 / 9.0]:
		for hero: Vector2 in [Vector2(-16, 20.5), Vector2(-16, 9), Vector2(-3.6, 20.5), Vector2(16, 15), Vector2(16, -15), Vector2(-16, -15), Vector2(0, 0), Vector2(0, -19)]:
			for target: Vector2 in [Vector2(-7, 6.9), Vector2(7, 6.9), Vector2(7, -10.5), Vector2(-7, -10.5), Vector2.ZERO, hero]:
				var s := _screen(feel, hero, _keep(feel, target, hero, aspect), aspect)
				assert_between(s.x, lo, 1.0 - lo, "x, hero %s, camera %s" % [hero, target])
				assert_between(s.y, lo, 1.0 - lo, "y, hero %s, camera %s" % [hero, target])


func test_the_camera_stays_put_while_he_is_inside_the_safe_frame() -> void:
	var feel := load(Feel.PATH) as Feel
	for hero: Vector2 in [Vector2(0, 0), Vector2(5, 3), Vector2(-6, -4), Vector2(2, 9)]:
		var s := _screen(feel, hero, Vector2.ZERO)
		assert_between(s.x, CamFrame.SAFE, 1.0 - CamFrame.SAFE, "the case is inside the frame")
		assert_between(s.y, CamFrame.SAFE, 1.0 - CamFrame.SAFE, "the case is inside the frame")
		assert_almost_eq(_keep(feel, Vector2.ZERO, hero), Vector2.ZERO, Vector2.ONE * 0.0001)


func test_the_camera_moves_only_as_far_as_needed() -> void:
	var feel := load(Feel.PATH) as Feel
	# the far corner of the west landing, the camera held by the room's margins (QA M3: he was at 5% of the width)
	var hero := Vector2(-16, 20.5)
	var held := Vector2(-7, 6.9)
	assert_lt(_screen(feel, hero, held).x, 0.11, "the case: near the left edge before the rule")
	var at := _keep(feel, held, hero)
	assert_almost_eq(_screen(feel, hero, at).x, CamFrame.SAFE, 0.001, "right on the safe frame, no farther")
	assert_lt(at.distance_to(held), hero.distance_to(held) * 0.5, "the camera does not centre on him")


func test_margins_follow_the_distance_of_the_camera() -> void:
	assert_almost_eq(CamFrame.margin(Game.CAM_MARGIN.x, CamFrame.MARGIN_DISTANCE), Game.CAM_MARGIN.x, 0.0001)
	assert_almost_eq(CamFrame.margin(10.0, 54.0), 9.0, 0.0001, "a closer camera travels closer to the walls")
