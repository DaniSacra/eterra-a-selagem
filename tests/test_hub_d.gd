extends GutTest
## HUB-D, the hub's finish (environment): at every station the camera shows the station whole with the hero (the Portal
## glued him to the top edge with the portal cut off), far and near; the station in focus gets its light a step
## brighter and a thread of gold round its slab; the forge burns brighter by rank; the paving and the cypresses stand
## off every way; the two materials of Fatia 1 have their own medallion.

const ASPECTS: Array[float] = [16.0 / 9.0, 4.0 / 3.0, 21.0 / 9.0]


## Where the camera settles with the hero standing at `hero` and the station `id` in focus (Hub.lean, CamRig.follow
## and hold_at, settled): far holds on the plan's point, near follows him (CamFrame.slack).
func _settled(id: StringName, hero: Vector2, distance: float, aspect: float) -> Vector2:
	var f := Feel.live()
	var l := HubPlan.layout()
	var slack := CamFrame.slack(distance, f.cam_distance, f.cam_pitch, f.cam_fov, aspect)
	var near := distance < f.cam_distance
	var base := CamFrame.hold(l.cam_target, hero if near else l.cam_target, l.cam_reach, hero, distance, f.cam_pitch, f.cam_yaw, f.cam_fov, aspect, true, slack)
	var lean := HubPlan.frame_for(id, base, distance, f.cam_pitch, f.cam_yaw, f.cam_fov, aspect)
	return CamFrame.hold(l.cam_target, lean, l.cam_reach, hero, distance, f.cam_pitch, f.cam_yaw, f.cam_fov, aspect, true, slack)


func test_at_every_station_the_camera_shows_it_whole_with_him() -> void:
	var f := Feel.live()
	for distance: float in [f.cam_distance, f.cam_distance_near]:
		for aspect in ASPECTS:
			for id in HubPlan.STATIONS:
				var s: Vector3 = HubPlan.SHOW[id]
				var show := HubPlan.to_world(Vector2(s.x, s.y))
				# on the use point and anywhere the focus holds round it
				for off: Vector2 in [Vector2.ZERO, Vector2(1.5, 0), Vector2(-1.5, 0), Vector2(0, 1.5), Vector2(0, -1.5)]:
					var hero := HubPlan.use_point(id) + HubPlan.to_world(off)
					var at := _settled(id, hero, distance, aspect)
					var h := CamFrame.screen_of(hero, CamFrame.HERO_HEIGHT, at, distance, f.cam_pitch, f.cam_yaw, f.cam_fov, aspect)
					var p := CamFrame.screen_of(show, s.z, at, distance, f.cam_pitch, f.cam_yaw, f.cam_fov, aspect)
					var tag := "%s at %.0f m, aspect %.2f, off %s" % [id, distance, aspect, off]
					assert_between(h.x, CamFrame.SAFE - 0.005, 1.0 - CamFrame.SAFE + 0.005, tag + ": hero across")
					assert_between(h.y, CamFrame.SAFE - 0.005, 1.0 - CamFrame.SAFE + 0.005, tag + ": hero up")
					assert_between(p.x, 0.0, 1.0, tag + ": the station across")
					assert_between(p.y, 0.0, 1.0, tag + ": the station up")


func test_at_the_portal_its_head_is_in_the_screen() -> void:
	var f := Feel.live()
	for distance: float in [f.cam_distance, f.cam_distance_near]:
		var hero := HubPlan.use_point(HubPlan.PORTAL)
		var at := _settled(HubPlan.PORTAL, hero, distance, 16.0 / 9.0)
		var s: Vector3 = HubPlan.SHOW[HubPlan.PORTAL]
		var p := CamFrame.screen_of(HubPlan.to_world(Vector2(s.x, s.y)), s.z, at, distance, f.cam_pitch, f.cam_yaw, f.cam_fov, 16.0 / 9.0)
		assert_gt(p.y, HubPlan.SHOW_MARGIN - 0.005, "the portal's head %.0f m: %.3f" % [distance, p.y])
		var h := CamFrame.screen_of(hero, CamFrame.HERO_HEIGHT, at, distance, f.cam_pitch, f.cam_yaw, f.cam_fov, 16.0 / 9.0)
		assert_gt(h.y, CamFrame.SAFE + 0.1, "he is not glued to the top any more (%.0f m: %.3f)" % [distance, h.y])


## Art review H-P0-1: with the far camera, from the arrival and from every station, the portal's sill a fifth to
## three tenths down the screen and its whole arch in it.
func test_far_the_portal_shows_whole_from_everywhere() -> void:
	var f := Feel.live()
	var sill := HubPlan.to_world(Vector2(0.0, HubLook.SHEET_V))
	var head: Vector3 = HubPlan.PORTAL_TOP
	var spots := {&"arrival": HubPlan.to_world(HubPlan.ARRIVAL)}
	for id in HubPlan.STATIONS:
		spots[id] = HubPlan.use_point(id)
	for aspect in ASPECTS:
		for key: StringName in spots:
			var id: StringName = key if key != &"arrival" else &""
			var at := _settled(id, spots[key], f.cam_distance, aspect)
			var y := CamFrame.screen_of(sill, HubLook.TERRACE_Y, at, f.cam_distance, f.cam_pitch, f.cam_yaw, f.cam_fov, aspect).y
			var top := CamFrame.screen_of(HubPlan.to_world(Vector2(head.x, head.y)), head.z, at, f.cam_distance, f.cam_pitch, f.cam_yaw, f.cam_fov, aspect).y
			var tag := "%s, aspect %.2f" % [key, aspect]
			assert_between(y, 0.15, 0.30, tag + ": the sill %.3f" % y)
			assert_gt(top, 0.0, tag + ": the arch's top %.3f" % top)


## Art review H-P0-2: with the near camera, at the arrival and at every station, the floor's south edge never above
## 0.85 of the screen (the tower's wall under it out of the frame).
func test_near_the_south_edge_stays_low() -> void:
	var f := Feel.live()
	var d := f.cam_distance_near
	var spots: Array[Vector2] = [HubPlan.ARRIVAL]
	for id in HubPlan.STATIONS:
		spots.append(HubPlan.USE[id])
	for aspect in ASPECTS:
		for spot in spots:
			var hero := HubPlan.to_world(spot)
			var slack := CamFrame.slack(d, f.cam_distance, f.cam_pitch, f.cam_fov, aspect)
			var l := HubPlan.layout()
			var at := CamFrame.hold(l.cam_target, HubPlan.near_want(hero), l.cam_reach, hero, d, f.cam_pitch, f.cam_yaw, f.cam_fov, aspect, true, slack)
			var edge := HubPlan.to_world(Vector2(spot.x, HubPlan.SOUTH))
			var y := CamFrame.screen_of(edge, 0.0, at, d, f.cam_pitch, f.cam_yaw, f.cam_fov, aspect).y
			assert_gt(y, 0.85, "at %s, aspect %.2f: the south edge %.3f" % [spot, aspect, y])


## LR-07 (room-designer): no two places of the hub more than 4 s apart walking (straight).
func test_no_two_stations_more_than_four_seconds_apart() -> void:
	var speed := Feel.live().speed
	var spots: Array[Vector2] = [HubPlan.ARRIVAL]
	for id in HubPlan.STATIONS:
		spots.append(HubPlan.USE[id])
	for a in spots:
		for b in spots:
			assert_lt(a.distance_to(b) / speed, 4.05, "%s to %s: %.1f s" % [a, b, a.distance_to(b) / speed])


func test_frame_for_leaves_a_shown_station_alone() -> void:
	var f := Feel.live()
	var from := HubPlan.to_world(Vector2(0, 0))
	var at := HubPlan.frame_for(&"nothing", from, f.cam_distance, f.cam_pitch, f.cam_yaw, f.cam_fov, 16.0 / 9.0)
	assert_eq(at, from)
	# the Livro's shelf from a camera already over it: no move
	var shelf: Vector3 = HubPlan.SHOW[HubPlan.BOOK]
	var over := HubPlan.to_world(Vector2(shelf.x - 6.0, shelf.y))
	assert_eq(HubPlan.frame_for(HubPlan.BOOK, over, f.cam_distance, f.cam_pitch, f.cam_yaw, f.cam_fov, 16.0 / 9.0), over)


func test_the_square_s_new_pieces_stand_off_every_way() -> void:
	var l := HubPlan.layout()
	var ways: Array = []
	var fountain := Vector2(HubPlan.FOUNTAIN.x, HubPlan.FOUNTAIN.y)
	for id in HubPlan.STATIONS:
		var to: Vector2 = HubPlan.USE[id]
		ways.append([HubPlan.ARRIVAL, to])
		ways.append([fountain if to.y > fountain.y else HubLook.MEDALLION, to])
	for o in l.obstacles:
		if not o.piece in [&"hub_cypress", &"hub_urn", &"hub_bed", &"hub_fire", &"hub_bench"]:
			continue
		var c := HubPlan.to_local(o.center)
		var r := o.radius if o.shape == ArenaObstacle.Shape.CIRCLE else o.half.length()
		assert_true(l.floor.contains(o.center, r), "%s %s on the floor" % [o.piece, c])
		for w: Array in ways:
			var a: Vector2 = w[0]
			var b: Vector2 = w[1]
			var near := Geometry2D.get_closest_point_to_segment(c, a, b)
			# the fountain's way starts out of its basin
			if w[0] == fountain and near.distance_to(fountain) < 3.0:
				continue
			assert_gt(near.distance_to(c), r + Player.RADIUS + 0.5, "%s %s off the way %s to %s" % [o.piece, c, a, b])


func test_focus_brightens_the_station_and_eases_back() -> void:
	var hub: Hub = (load(SceneGo.HUB) as PackedScene).instantiate()
	add_child_autofree(hub)
	await get_tree().process_frame
	var look := hub.arena.look as HubLook
	assert_not_null(look)
	var base := look.station_light(HubPlan.BOOK)
	var energy := base.light_energy
	look.focus(HubPlan.BOOK)
	for i in 30:
		look._process(1.0 / 60.0)
	var twin: Light3D = look._focus_twin[HubPlan.BOOK]
	assert_true(twin.visible)
	assert_almost_eq(twin.light_energy, energy * HubLook.FOCUS_GAIN, 0.001, "a quarter more light")
	assert_false(twin.shadow_enabled)
	assert_eq(base.light_energy, energy, "the station's own light untouched (F7 keeps its values)")
	var rim: MeshInstance3D = look._focus_rim[HubPlan.BOOK]
	assert_true(rim.visible)
	var gold := (rim.material_override as StandardMaterial3D).albedo_color
	assert_lte(ScreenTone.peak8(Color(gold.r, gold.g, gold.b)), ScreenTone.SAFE, "the gold under the screen's ceiling")
	look.focus(&"")
	for i in 30:
		look._process(1.0 / 60.0)
	assert_false(twin.visible, "eased out")
	assert_false(rim.visible)


func test_the_forge_burns_brighter_by_rank() -> void:
	var hub: Hub = (load(SceneGo.HUB) as PackedScene).instantiate()
	add_child_autofree(hub)
	await get_tree().process_frame
	var look := hub.arena.look as HubLook
	var glow := look._forge_glow.albedo_color.a
	look.set_forge_rank(0)
	assert_null(look._forge_twin, "no twin light at rank 0")
	var last := glow
	for n in range(1, HubLook.FORGE_RANKS + 1):
		look.set_forge_rank(n)
		look._process(1.0 / 60.0)
		assert_gt(look._forge_glow.albedo_color.a, last, "rank %d glows more" % n)
		last = look._forge_glow.albedo_color.a
		assert_almost_eq(look._forge_twin.light_energy, look._forge_light.light_energy * HubLook.FORGE_RANK_LIGHT * n, 0.001)
		assert_false(look._forge_twin.shadow_enabled)
	assert_lte(last, 1.0)
	look.set_forge_rank(99)
	assert_eq(look.forge_rank, HubLook.FORGE_RANKS, "clamped")
	look.set_forge_rank(0)
	assert_false(look._forge_twin.visible)


func test_silver_and_memory_have_their_own_medallion() -> void:
	var gold := RewardGem.face_material(RunMap.Reward.GOLD, RunMap.Kind.COMBAT)
	var silver := RewardGem.face_material(RunMap.Reward.SILVER, RunMap.Kind.COMBAT)
	var memory := RewardGem.face_material(RunMap.Reward.MEMORY, RunMap.Kind.COMBAT)
	assert_ne(silver, gold, "one material a kind")
	assert_eq(int(silver.get_shader_parameter(&"mark")), RewardGem.Mark.INGOT)
	assert_eq(int(memory.get_shader_parameter(&"mark")), RewardGem.Mark.LEAF)
	assert_true(silver.get_shader_parameter(&"all_gold"), "the silver is the coin's face in silver")
	assert_eq(silver.get_shader_parameter(&"gold"), RewardGem.SILVER)
	assert_true(memory.get_shader_parameter(&"parchment"))
	assert_false(memory.get_shader_parameter(&"all_gold"))
	assert_eq(memory.get_shader_parameter(&"mark_metal"), RewardGem.INK)
	for c: Color in [RewardGem.SILVER, RewardGem.PARCHMENT]:
		assert_lte(c.s, RewardGem.ENAMEL_MAX.x, "never saturated")
		assert_lt(ScreenTone.peak8(c), ScreenTone.SAFE)
	assert_lte(RewardGem.PARCHMENT.v, RewardGem.ENAMEL_MAX.y + 0.06, "the parchment about the enamel's value")
	assert_eq(RewardGem.face_stuff(RunMap.Reward.BOON, RunMap.Kind.COMBAT).a, 0.0, "the Blessing stays enamel")


## The two NPCs block where they are drawn (GD 2026-11-19): the Forjador's circle on the spot where HubLook._people puts
## him (his hammer landing on the anvil), the Vendedor's behind his counter.
func test_the_npcs_block_where_they_stand() -> void:
	var hit: Vector3 = HubNpc.strike_point()
	var turn := Basis(Vector3.UP, PI * 0.5)
	var drawn := Vector3(HubPlan.ANVIL.x, 0.0, -(HubPlan.ANVIL.y + 0.05)) - turn * Vector3(hit.x, 0.0, hit.z)
	assert_lt(Vector2(drawn.x, -drawn.z).distance_to(HubPlan.SMITH_SPOT), 0.1, "the Forjador's circle under him")
	var found := {}
	for o: ArenaObstacle in HubPlan.layout().obstacles:
		if o.piece == &"hub_smith" or o.piece == &"hub_vendor":
			found[o.piece] = HubPlan.to_local(o.center)
	assert_lt((found[&"hub_smith"] as Vector2).distance_to(HubPlan.SMITH_SPOT), 0.01)
	assert_lt((found[&"hub_vendor"] as Vector2).distance_to(HubPlan.VENDOR_SPOT), 0.01)
	assert_gt(HubPlan.VENDOR_SPOT.y, HubPlan.COUNTER.y + HubPlan.COUNTER_HALF.y, "the Vendedor behind the counter")
