extends GutTest
## PT-2: the reward medallion of each door hangs on the door's own arch (ArenaExit.medal_*), never loose on the floor in
## front of it, and the picture of each reward comes from one place (RewardIcon) that falls back to today's.

const STAGE := "res://data/stages/catacombs.tres"
const SEED := 1406

var stage: StageDef

func before_all() -> void:
	stage = load(STAGE)

func _arena(layout: RoomLayout, exits: int) -> Arena:
	var a := Arena.new()
	add_child_autofree(a)
	a.build(layout, exits, SEED)
	return a

func test_every_anchor_is_in_the_arch_of_its_door() -> void:
	for l in stage.layouts:
		var a := _arena(l, mini(3, l.exits.size()))
		for i in a.exits.size():
			var m := a.door_anchor(i)
			var edge := l.exits[i].edge()
			assert_lt(Vector2(m.x, m.z).distance_to(edge), 2.5, "%s door %d: on the door's edge" % [l.id, i])
			assert_gt(m.y, 3.0, "%s door %d: above the paladin's head and the passage" % [l.id, i])
			assert_lt(m.y - RewardGem.RADIUS * RewardGem.DOOR_SCALE, ArenaRoom.WALL_DOOR.y, "%s door %d: floats over the lintel, its foot under the crown" % [l.id, i])
			assert_lt(a.door_sign_y(i), m.y - RewardGem.RADIUS * RewardGem.DOOR_SCALE + 0.01, "%s door %d: text starts under the disc" % [l.id, i])
			assert_eq(a.door_at_anchor(Vector2(m.x, m.z)), i, "%s door %d: found by its anchor" % [l.id, i])

func test_two_doors_never_share_a_medallion_spot() -> void:
	for l in stage.layouts:
		var a := _arena(l, mini(3, l.exits.size()))
		for i in a.exits.size():
			for k in range(i + 1, a.exits.size()):
				var p := a.door_anchor(i)
				var q := a.door_anchor(k)
				assert_gt(Vector2(p.x, p.z).distance_to(Vector2(q.x, q.z)), 4.0, "%s: doors %d and %d keep apart" % [l.id, i, k])

func test_the_hall_without_a_layout_hangs_it_too() -> void:
	var a := Arena.new()
	add_child_autofree(a)
	a.exits.append(Vector2(0, -9))
	a.exit_inward.append(Vector2(0, 1))
	var m := a.door_anchor(0)
	assert_almost_eq(m.z, -9.0 + ArenaExit.EDGE_FROM_SPOT, 0.01, "at the edge, in from the spot")
	assert_almost_eq(m.y, ArenaExit.new().medal_up, 0.001)

func test_medallions_in_a_run_hang_at_their_door() -> void:
	var game: Game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	game.rooms.start_at(RunMap.Kind.COMBAT)
	game.horde.clear_crowd()
	game.rooms._open_doors()
	await wait_process_frames(2)
	assert_gt(game.rooms._door_labels.size(), 0)
	for i in game.rooms._door_labels.size():
		var m := game.arena.door_anchor(i)
		var root := game.rooms._door_labels[i]
		assert_almost_eq(root.position.x, m.x, 0.01)
		assert_almost_eq(root.position.z, m.z, 0.01)
		var turning := root.find_children("*", "Node3D", true, false).filter(func(n: Node) -> bool: return n is RewardGem.Sway)
		assert_eq(turning.size(), 1, "door %d: one disc" % i)
		assert_almost_eq((turning[0] as Node3D).position.y, m.y, 0.01, "door %d: at the arch's height" % i)
		var sign := root.find_child("DoorSign", false, false) as Node3D
		assert_almost_eq(sign.position.y, game.arena.door_sign_y(i), 0.01, "door %d: its text under the disc" % i)

func test_icons_fall_back_to_the_painting_of_today() -> void:
	assert_eq(RewardIcon.path(&"gold"), "res://assets/ui/rewards/gold.png")
	assert_eq(RewardIcon.id_of(RunMap.Reward.HEART, RunMap.Kind.COMBAT), &"heart")
	assert_eq(RewardIcon.id_of(RunMap.Reward.NONE, RunMap.Kind.SHOP), &"shop")
	assert_eq(RewardIcon.all_ids().size(), 11 + 7 + 7)
	for id in RewardIcon.all_ids():
		if not ResourceLoader.exists(RewardIcon.path(id)):
			assert_null(RewardIcon.texture(id), "%s: no file, no texture" % id)
	# Rev. 02 (2026-11-23): the painted icon wins over the medallion's old painting; no id, no texture (the fallback)
	assert_eq(RewardGem.painting(RunMap.Reward.GOLD, RunMap.Kind.COMBAT), RewardIcon.texture(&"gold"))
	assert_eq(RewardGem.painting(RunMap.Reward.POM, RunMap.Kind.COMBAT), RewardIcon.texture(&"pom"))
	assert_null(RewardIcon.texture(&""))
	assert_null(RewardIcon.texture(&"no_such_reward"))

func _disc_px(cam: Camera3D, p: Vector3) -> Rect2:
	var c := cam.unproject_position(p)
	var r := c.distance_to(cam.unproject_position(p + cam.global_transform.basis.x * RewardGem.RADIUS * RewardGem.DOOR_SCALE))
	return Rect2(c - Vector2(r, r), Vector2(r, r) * 2.0)

## Every real room of the descent: the layouts, each of its variants, the boss, shop, Provação and Altar rooms, and
## the exit counts a room can open (2 and 3 doors, as many as it has exits).
func _all_arenas() -> Array[Arena]:
	var layouts: Array[RoomLayout] = []
	layouts.append_array(stage.layouts)
	for l in [stage.shop_layout, stage.trial_layout, stage.altar_layout]:
		if l != null:
			layouts.append(l)
	var out: Array[Arena] = []
	for base in layouts:
		for v in base.variant_count():
			var l := base.variant(v)
			for n in range(2, mini(3, l.exits.size()) + 1):
				out.append(_arena(l, n))
	var hall := Arena.new()
	add_child_autofree(hall)
	hall.exits.append_array([Vector2(10.5, -13.8), Vector2(14.2, -11.8)])
	hall.exit_inward.append_array([Vector2(0, 1), Vector2(-1, 0)])
	out.append(hall)
	return out

## SW-C9: with the standard camera (near) the projected discs of no two doors overlap, in every room of the descent
## (the layouts and their variants, the Provação, the Altar, the shop, the guardians' halls) and in the Hall.
func test_projected_discs_never_overlap() -> void:
	var f := Feel.live()
	var cam := Camera3D.new()
	add_child_autofree(cam)
	cam.fov = f.cam_fov
	var yaw := deg_to_rad(f.cam_yaw)
	var pitch := deg_to_rad(f.cam_pitch)
	cam.rotation = Vector3(-pitch, yaw, 0.0)
	var checked := 0
	for a in _all_arenas():
		var all := a.door_anchors()
		if all.size() < 2:
			continue
		var target := Vector3(all[0].x, 0.0, all[0].z)
		cam.position = target + (cam.global_transform.basis.z) * f.cam_distance_near
		for i in all.size():
			for k in range(i + 1, all.size()):
				var ri := _disc_px(cam, all[i])
				var rk := _disc_px(cam, all[k])
				var tag := "%s (%d doors): doors %d and %d" % [a.name_key, all.size(), i, k]
				assert_false(ri.intersects(rk), tag + ": discs apart on the screen")
				checked += 1
	assert_gt(checked, 20, "many rooms checked")
