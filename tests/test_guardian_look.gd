extends GutTest
## The guardians' houses draw with their own look (GuardianLook, art pack 2026-11-23), never the Cripta's: the Knight's
## hall the armory, the Elder's chamber the chapel; what they draw stands behind the floor's edge or hangs over it
## (nothing on the walkable floor but the layout's pieces), the lights with shadows stay under the cap, and no round
## mark is painted on the floor.

const STAGE := "res://data/stages/catacombs.tres"
const HOUSES := {&"knight_hall": &"armory", &"elder_hall": &"chapel"}
## Higher than STANDING over the walkable floor stands on it; higher than OVERHEAD hangs over it (as test_artpack_env).
const STANDING := 0.3
const OVERHEAD := 2.6
const EDGE_TRIM := 0.35
const PIECE_MARGIN := 0.45
const DOOR_SIDES := 1.2
const SHADOW_CAP := 8


func _layout(id: StringName) -> RoomLayout:
	var stage: StageDef = load(STAGE)
	for l in stage.layouts:
		if l.id == id:
			return l
	return null


func _build(id: StringName) -> Arena:
	var a := Arena.new()
	add_child_autofree(a)
	a.build(_layout(id), 3, 1406)
	return a


func test_each_house_has_its_own_look_never_the_cripta() -> void:
	for id: StringName in HOUSES:
		var l := _layout(id)
		assert_eq(l.look, HOUSES[id], "%s names its look" % id)
		assert_true(ArenaRoom.LOOKS.has(l.look), "%s is a look the arena knows" % l.look)
		var a := _build(id)
		assert_true(a.look is GuardianLook, "%s draws with GuardianLook" % id)
		assert_false(a.look is CryptLook, "%s is not the Cripta" % id)
		assert_eq((a.look as GuardianLook).armory(), id == &"knight_hall")


func test_the_two_houses_differ() -> void:
	var k := _build(&"knight_hall").look as GuardianLook
	var e := _build(&"elder_hall").look as GuardianLook
	assert_ne(k.stone_tint(), e.stone_tint())
	assert_ne(k.floor_look()[&"stone_a"], e.floor_look()[&"stone_a"])
	assert_ne(k.style()[&"stone"], e.style()[&"stone"])


func test_lights_with_shadows_stay_under_the_cap() -> void:
	for id: StringName in HOUSES:
		var a := _build(id)
		assert_lte(a.look.shadowed, SHADOW_CAP)
		var n := 0
		for l in a.look.find_children("*", "Light3D", true, false):
			if (l as Light3D).shadow_enabled:
				n += 1
		assert_lte(n, SHADOW_CAP, "%s: %d lights with shadows" % [id, n])


func after_each() -> void:
	ArenaRoom.leave_air()
	VisualProfile.set_look(VisualProfile.Look.CLASSIC)


func test_nothing_stands_on_the_walkable_floor_but_the_layouts_pieces() -> void:
	for look: int in [VisualProfile.Look.CLASSIC, VisualProfile.Look.STYLIZED]:
		VisualProfile.set_look(look)
		_check_floor()


func _check_floor() -> void:
	for id: StringName in HOUSES:
		var a := _build(id)
		var l := a.layout
		var bad := 0
		var where := {}
		for n in a.look.find_children("*", "MeshInstance3D", true, false):
			var mi := n as MeshInstance3D
			if mi.mesh == null or mi.mesh is QuadMesh or mi.has_meta(&"air"):
				continue
			var xf := mi.global_transform
			for s in mi.mesh.get_surface_count():
				var verts: PackedVector3Array = mi.mesh.surface_get_arrays(s)[Mesh.ARRAY_VERTEX]
				for vert in verts:
					var p := xf * vert
					if p.y <= STANDING or p.y > OVERHEAD:
						continue
					var q := Vector2(p.x, p.z)
					if not l.floor.contains(q, EDGE_TRIM) or _near_piece(l, q) or _in_mouth(l, q):
						continue
					if not where.has(mi.name):
						where[mi.name] = p
					bad += 1
		assert_eq(bad, 0, "%s: nothing stands on the floor but its pieces (%s)" % [id, where])


func test_no_round_mark_on_the_floor() -> void:
	# round floor marks are Morvath's: nothing the houses draw is a flat disc on the floor (a Torus or a flat cylinder
	# lying at floor level wider than a candle's dish)
	for id: StringName in HOUSES:
		var a := _build(id)
		var rings := 0
		var meshes := a.look.find_children("*", "MeshInstance3D", true, false)
		for n in meshes:
			var mi := n as MeshInstance3D
			if mi.mesh is TorusMesh and mi.global_position.y < 0.2:
				rings += 1
		assert_eq(rings, 0, "%s: no ring on the floor" % id)
		assert_gt(meshes.size(), 100, "%s is dressed" % id)


func _near_piece(l: RoomLayout, q: Vector2) -> bool:
	for o in l.obstacles:
		if o.depth(q, 0.0) < PIECE_MARGIN:
			return true
	return false


func _in_mouth(l: RoomLayout, q: Vector2) -> bool:
	for e in l.exits:
		if e.mouth.grow(DOOR_SIDES).has_point(q):
			return true
	return false
