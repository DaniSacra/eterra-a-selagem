extends GutTest
## The options' near camera (Daniel, 2026-11-19; CamRig.near, CamFrame.slack and widen): saved and read, Hades II's
## distance, and in every room with a fixed frame (cam_bounds, cam_target with cam_reach: Runes, Provação, Altar, the
## Seal Chamber, the hub) the paladin stays in the safe frame wherever he stands, the camera never jumping.

const STAGE := "res://data/stages/catacombs.tres"
const ASPECTS: Array[float] = [16.0 / 9.0, 16.0 / 10.0]

var _camera_before: Variant


func before_each() -> void:
	_camera_before = Save.option("camera")


func after_each() -> void:
	Save.data.options["camera"] = _camera_before


func test_the_option_is_far_by_default_and_survives_the_save() -> void:
	assert_eq(SaveData.defaults().options.camera, "far", "far by default: nothing changes until Daniel chooses")
	assert_eq(SaveData.merged({"options": {"camera": "near"}}).options.camera, "near")
	assert_eq(SaveData.merged({"options": {}}).options.camera, "far", "a save from before the option")
	assert_eq(T.t(&"opt_camera"), "Câmera")
	assert_eq(T.t(&"opt_camera_near"), "Perto")
	assert_eq(T.t(&"opt_camera_far"), "Longe")


func test_the_option_sets_the_distance_live() -> void:
	var f := Feel.live()
	assert_almost_eq(f.cam_distance_near, 37.0, 0.001, "Hades II's ZoomFraction 0.85: about 28 m across")
	assert_almost_eq(f.cam_distance, 54.0, 0.001)
	Save.set_option("camera", "near")
	assert_true(CamRig.near())
	assert_almost_eq(CamRig.distance(), f.cam_distance_near, 0.001)
	Save.set_option("camera", "far")
	assert_false(CamRig.near())
	assert_almost_eq(CamRig.distance(), f.cam_distance, 0.001)


func test_the_far_camera_has_no_slack() -> void:
	var f := Feel.live()
	assert_eq(CamFrame.slack(f.cam_distance, f.cam_distance, f.cam_pitch, f.cam_fov, 16.0 / 9.0), Vector2.ZERO)
	var s := CamFrame.slack(f.cam_distance_near, f.cam_distance, f.cam_pitch, f.cam_fov, 16.0 / 9.0)
	assert_gt(s.x, 5.0, "across: what the far camera saw more on each side")
	assert_gt(s.y, 5.0)
	# widen with no slack is the base itself (the far camera's frame is the one of before)
	assert_eq(CamFrame.widen(Vector2(1, 2), Vector2(9, -7), Vector2.ZERO, f.cam_yaw), Vector2(1, 2))


## Every room whose camera is held (a fixed point or a box), as it stands in each variant.
func _held_rooms() -> Array[RoomLayout]:
	var stage: StageDef = load(STAGE)
	var out: Array[RoomLayout] = []
	var all: Array[RoomLayout] = stage.layouts.duplicate()
	all.append_array([stage.boss_layout, stage.trial_layout, stage.altar_layout, HubPlan.layout()])
	for l in all:
		if l == null:
			continue
		for n in l.variant_count():
			var v := l.variant(n)
			if v.cam_reach > 0.0 or v.cam_bounds.has_area():
				out.append(v)
	return out


## Where the near camera looks with the paladin at `hero` (CamRig.look_at and hold_at, settled on him).
func _near_at(l: RoomLayout, hero: Vector2, aspect: float) -> Vector2:
	var f := Feel.live()
	var d := f.cam_distance_near
	var slack := CamFrame.slack(d, f.cam_distance, f.cam_pitch, f.cam_fov, aspect)
	if l.cam_reach > 0.0:
		return CamFrame.hold(l.cam_target, hero, l.cam_reach, hero, d, f.cam_pitch, f.cam_yaw, f.cam_fov, aspect, true, slack)
	var p := CamFrame.widen(hero.clamp(l.cam_bounds.position, l.cam_bounds.end), hero, slack, f.cam_yaw)
	return CamFrame.keep(p, hero, d, f.cam_pitch, f.cam_yaw, f.cam_fov, aspect)


func test_near_keeps_the_paladin_in_the_safe_frame_in_every_held_room() -> void:
	var f := Feel.live()
	var rooms := _held_rooms()
	assert_gt(rooms.size(), 8, "Runes, Provação, Altar, the chamber, the hub and the boxed arenas")
	for l in rooms:
		var floor := l.floor if l.floor != null else FloorShape.rect(l.half)
		var box := floor.bounds()
		var checked := 0
		for aspect in ASPECTS:
			for ix in int(box.size.x) + 1:
				for iz in int(box.size.y) + 1:
					var hero := box.position + Vector2(ix, iz)
					if not floor.contains(hero, Player.RADIUS):
						continue
					checked += 1
					var at := _near_at(l, hero, aspect)
					var s := CamFrame.screen_of(hero, CamFrame.HERO_HEIGHT, at, f.cam_distance_near, f.cam_pitch, f.cam_yaw, f.cam_fov, aspect)
					assert_between(s.x, CamFrame.SAFE - 0.005, 1.0 - CamFrame.SAFE + 0.005, "%s %s across" % [l.id, hero])
					assert_between(s.y, CamFrame.SAFE - 0.005, 1.0 - CamFrame.SAFE + 0.005, "%s %s up" % [l.id, hero])
		assert_gt(checked, 50, "%s: the floor was walked" % l.id)


func test_near_in_the_seal_chamber_follows_him_without_a_jump() -> void:
	Save.set_option("camera", "near")
	var game: Game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	game.rooms.start_at(RunMap.Kind.BOSS)
	game.set_process(false)
	game.snap_camera()
	var view := game.get_viewport().get_visible_rect().size
	var dt := 1.0 / 60.0
	var last := Vector2.INF
	var worst := 0.0
	var a := 0.0
	for i in 600:
		a += dt * 0.6
		game.player.place(Vector2.from_angle(a) * (4.0 + 7.5 * absf(sin(i * dt * 0.7))))
		game.cam.follow(dt, Vector3.ZERO)
		if last.is_finite():
			worst = maxf(worst, game.cam.at.distance_to(last))
		last = game.cam.at
		if i > 60:
			var s := game.camera.unproject_position(Vector3(game.player.pos.x, CamFrame.HERO_HEIGHT, game.player.pos.y)) / view
			assert_between(s.x, 0.05, 0.95, "on the screen across at %s" % game.player.pos)
			assert_between(s.y, 0.05, 0.95, "on the screen up at %s" % game.player.pos)
	assert_lte(worst, CamFrame.MAX_SPEED * dt + 0.001, "never a jump (GP-06)")
	assert_almost_eq(game.camera.global_position.distance_to(Vector3(game.cam.at.x, 0, game.cam.at.y)), Feel.live().cam_distance_near, 0.01,
		"the near distance")
