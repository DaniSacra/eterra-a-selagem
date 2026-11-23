extends GutTest
## E5's rooms (docs/art/e5_spec.md): the Santuário, the Ponte, the Câmara das Runas, the Provação and the Altar
## Esquecido build from any RoomLayout with their look id, in every variant; nothing of the scenery stands on the
## walkable floor but the layout's own pieces; lights with shadows stay under each room's cap; the runes' tiles, the
## altar's and the trial's states and a door's breath answer. The plans are the lab's (tools/e5_layouts.gd, the spec's
## numbers) until the stage's come from tools/make_data.gd.

const E5 := preload("res://tools/e5_layouts.gd")
## Spec 8.8: lights with shadows at most (the moon is the world's, not counted).
const SHADOW_CAP := {&"sanctuary": 6, &"bridge": 4, &"runes": 4, &"trial": 1, &"altar": 2}
const LOOK_CLASS := {&"sanctuary": "SanctuaryLook", &"bridge": "BridgeLook", &"runes": "RunesLook", &"trial": "TrialLook",
	&"altar": "AltarLook"}
## Anything higher than this over the walkable floor is standing on it (rubble, chips and slabs lie under it); higher
## than OVERHEAD hangs over it (a cornice, the springing of a vault), nothing to walk into. EDGE_TRIM: the brink's own
## trim (a sill, a curb, a chipped lip) may reach this far over the edge.
const STANDING := 0.3
const OVERHEAD := 3.0
const EDGE_TRIM := 0.3
## How far round a piece of the layout its own dressing may reach (candles on a base, a capital's overhang).
const PIECE_MARGIN := 0.45
## A door's cheeks and the posts at its sides stand this far round its mouth; a bridge's head posts this far round
## where its deck meets a platform.
const DOOR_SIDES := 1.2
const BRIDGE_HEAD := 1.4


func _build(id: StringName, variant: int, doors := 3) -> Arena:
	var a := Arena.new()
	add_child_autofree(a)
	a.build(E5.layout(id, variant), doors, 1406)
	return a


func test_every_room_and_variant_builds_with_its_look() -> void:
	for id: StringName in E5.IDS:
		var l := E5.layout(id)
		for v in l.variant_count():
			var a := _build(id, v)
			assert_not_null(a.look, "%s %d has a look" % [id, v])
			assert_eq(a.look.get_script().get_global_name(), StringName(LOOK_CLASS[id]), "%s draws with its own look" % id)
			assert_true(ArenaRoom.LOOKS.has(id), "%s is a look the arena knows" % id)


func test_lights_with_shadows_stay_under_each_cap() -> void:
	for id: StringName in E5.IDS:
		for v in E5.layout(id).variant_count():
			var a := _build(id, v)
			assert_lte(a.look.shadowed, int(SHADOW_CAP[id]), "%s %d: %d lights with shadows" % [id, v, a.look.shadowed])
			# after its event (the altar lit, the trial chosen) too
			if a.look.has_method("demo"):
				a.look.call("demo", "after")
				var n := 0
				for l in a.look.find_children("*", "Light3D", true, false):
					if (l as Light3D).shadow_enabled and (l as Light3D).visible:
						n += 1
				assert_lte(n, int(SHADOW_CAP[id]), "%s %d after its event: %d" % [id, v, n])


func test_nothing_stands_on_the_walkable_floor_but_the_layouts_pieces() -> void:
	for id: StringName in E5.IDS:
		for v in E5.layout(id).variant_count():
			var a := _build(id, v)
			var l := a.layout
			var bad := 0
			var first := Vector3.ZERO
			var where := {}
			for n in a.look.find_children("*", "MeshInstance3D", true, false):
				var mi := n as MeshInstance3D
				if mi.mesh == null or mi.has_meta(&"air"):
					continue
				var xf := mi.global_transform
				for s in mi.mesh.get_surface_count():
					var verts: PackedVector3Array = mi.mesh.surface_get_arrays(s)[Mesh.ARRAY_VERTEX]
					for vert in verts:
						var p := xf * vert
						if p.y <= STANDING or p.y > OVERHEAD:
							continue
						var q := Vector2(p.x, p.z)
						if not l.floor.contains(q, EDGE_TRIM) or _near_piece(l, q) or _in_mouth(l, q) or _at_join(l, q):
							continue
						if bad == 0:
							first = p
						if not where.has(mi.name):
							where[mi.name] = p
						bad += 1
			assert_eq(bad, 0, "%s %d: nothing stands on the floor (first at %s; %s)" % [id, v, first, where])


func _near_piece(l: RoomLayout, q: Vector2) -> bool:
	for o in l.obstacles:
		if o.depth(q, PIECE_MARGIN) > 0.0:
			return true
	return false


func _in_mouth(l: RoomLayout, q: Vector2) -> bool:
	for e in l.exits:
		if e.mouth.grow(DOOR_SIDES).has_point(q):
			return true
	return false


## Near a corner of one floor polygon lying on another's edge (where a bridge's deck meets a platform).
func _at_join(l: RoomLayout, q: Vector2) -> bool:
	for i in l.floor.polys.size():
		for v in l.floor.polys[i]:
			if v.distance_to(q) > BRIDGE_HEAD:
				continue
			for j in l.floor.polys.size():
				if j == i:
					continue
				var o := l.floor.polys[j]
				for k in o.size():
					var c := Geometry2D.get_closest_point_to_segment(v, o[k], o[(k + 1) % o.size()])
					if c.distance_to(v) < 0.15:
						return true
	return false


func test_the_runes_tiles_take_their_state() -> void:
	var a := _build(&"runes", 0)
	var look := a.look as RunesLook
	assert_eq(look.grid(), Vector2i(10, 8), "a tile of 3 m: 10 x 8 over the room")
	look.set_tile(Vector2i(2, 3), 0.5, 0.0, 0.0)
	look.set_tile(Vector2i(9, 7), 0.0, 1.0, 0.0)
	look.apply()
	var img := look.state_image()
	assert_almost_eq(img.get_pixel(2, 3).r, 0.5, 0.01, "arming fraction in red")
	assert_almost_eq(img.get_pixel(9, 7).g, 1.0, 0.01, "firing in green")
	assert_gt(look.heat(), 0.4, "the pillars warm while a tile arms")
	assert_eq(look.tile_at(Vector2(-13.5, -10.5)), Vector2i(0, 0), "the north-west tile")
	assert_eq(look.tile_at(Vector2(14.0, 11.0)), Vector2i(9, 7), "the south-east tile")
	look.clear_tiles()
	look.apply()
	assert_almost_eq(look.heat(), 0.0, 0.001, "at rest the pillars are cold")


func test_the_quiet_stone_never_takes_a_frame() -> void:
	var a := _build(&"runes", 1)
	var look := a.look as RunesLook
	var img := look.state_image()
	var quiet := look.tile_at(Vector2(-1.5, -1.5))
	assert_almost_eq(img.get_pixel(quiet.x, quiet.y).a, RunesLook.QUIET, 0.01, "the quiet stone's tile is marked quiet")
	var rune := look.tile_at(Vector2(-7.5, -7.5))
	assert_almost_eq(img.get_pixel(rune.x, rune.y).a, 1.0, 0.01, "the others are rune tiles")


func test_a_door_breathes_the_next_rooms_air() -> void:
	var a := _build(&"sanctuary", 0, 2)
	var card := a.look.breath(0, &"rift")
	assert_not_null(card, "a used door breathes")
	var c: Color = (card.material_override as ShaderMaterial).get_shader_parameter(&"color")
	assert_lte(maxf(c.r, maxf(c.g, c.b)), ArenaRoom.BREATH_PEAK + 0.001, "never past its brightest")
	assert_gt(c.b, c.g, "the rift's air is violet")
	assert_null(a.look.breath(2, &"crypt"), "a door not used does not")


func test_the_altar_and_the_trial_change_state() -> void:
	var altar := _build(&"altar", 0).look as AltarLook
	assert_false(altar.lit(), "the altar's candles are out at first")
	altar.kindle(0.0)
	assert_true(altar.lit(), "and lit after the event")
	var trial := _build(&"trial", 0).look as TrialLook
	assert_almost_eq(trial.vein_level(), 1.0, 0.001, "the veins glow before the choice")
	trial.settle(0.0)
	assert_almost_eq(trial.vein_level(), TrialLook.SETTLED, 0.001, "and lose their light after it")


func test_the_trial_entry_slab_lies_flush_with_the_floor() -> void:
	var holder := Node3D.new()
	add_child_autofree(holder)
	var slab := TrialLook.entry_slab(holder, Vector2(3, -2))
	assert_eq(slab.name, &"TrialSlab", "a node to free when the slab goes")
	var top := -INF
	for n in slab.find_children("*", "MeshInstance3D", true, false):
		var mi := n as MeshInstance3D
		if mi.mesh == null or mi.mesh is QuadMesh:
			continue
		top = maxf(top, mi.get_aabb().end.y + mi.position.y)
	assert_lte(top, 0.02, "nothing of its stone stands over the floor")
