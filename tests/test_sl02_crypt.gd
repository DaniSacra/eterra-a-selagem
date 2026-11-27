extends GutTest
## SL-01b and SL-02 (docs/art/ref/sala02_2026-11-25): the canal the Salao's river and the Antessala's stream share, the
## Cripta's big closed doors with the medallion in the doorway, and its broken fountain (walkable, blocks nothing).

const STAGE := "res://data/stages/catacombs.tres"
const SEED := 1406

var stage: StageDef


func before_all() -> void:
	stage = load(STAGE)


func _crypt(exits: int, variant := 0) -> Arena:
	var l: RoomLayout = stage.layouts.filter(func(x: RoomLayout) -> bool: return x.id == &"crypt")[0]
	var a := Arena.new()
	add_child_autofree(a)
	a.build(l.variant(variant), exits, SEED)
	return a


func test_the_stream_of_the_antessala_is_the_halls_canal() -> void:
	var gap := GapFloor.new([Rect2(-16.5, -10.6, 33.0, 2.6)] as Array[Rect2])
	add_child_autofree(gap)
	var kerbs := gap.find_children("CanalKerb", "MeshInstance3D", true, false)
	assert_eq(kerbs.size(), 1, "the stone kerb of both banks")
	assert_eq((kerbs[0] as MeshInstance3D).mesh.get_surface_count(), 2, "its tops and its inner wall")
	var water := 0
	for c in gap.get_children():
		var m := (c as GeometryInstance3D).material_override as ShaderMaterial if c is GeometryInstance3D else null
		if m != null and m.shader == Canal.WATER:
			water += 1
	assert_eq(water, 1, "water of the hall's shader")


func test_the_kerb_is_left_open_over_a_ford() -> void:
	var line := PackedVector2Array([Vector2(0, 0), Vector2(5, 0), Vector2(10, 0)])
	var widths := PackedFloat32Array([1.0, 1.0, 1.0])
	var node := Node3D.new()
	add_child_autofree(node)
	var mat := Canal.water(Vector2.ZERO)
	Canal.dress(node, line, widths, mat, true, [])
	var whole := ((node.find_child("CanalKerb", true, false) as MeshInstance3D).mesh as ArrayMesh).surface_get_array_len(0)
	var node2 := Node3D.new()
	add_child_autofree(node2)
	var ford: Array[Vector2] = [Vector2(0.0, 0.3)]
	Canal.dress(node2, line, widths, mat, true, ford)
	var open := ((node2.find_child("CanalKerb", true, false) as MeshInstance3D).mesh as ArrayMesh).surface_get_array_len(0)
	assert_lt(open, whole, "fewer stones where the paladin wades")


func test_the_cripta_has_two_big_doors_apart_and_their_medallions_hang_in_them() -> void:
	var a := _crypt(2)
	var look := a.look as CryptLook
	assert_not_null(look)
	assert_eq(look._doors_built.size(), 2, "the two ways in use have a door; the third is plain wall")
	assert_false(a.exit_rod, "no rod: the disc hangs in the doorway")
	var x0 := a.exits[0].x
	var x1 := a.exits[1].x
	assert_gte(absf(x1 - x0), 5.5, "centres 5.5 m or more apart")
	assert_gte(absf(x1 - x0) - CatacombHall.DOOR_CLEAR.x - 2.0 * CatacombHall.DOOR_FRAME, 0.5, "masonry stands between the frames")
	for i in 2:
		var p := a.door_anchor(i)
		assert_between(p.y, 2.0, 3.5, "door %d: the disc in the doorway" % i)
		assert_almost_eq(look._doors_built[i].swing(), 0.0, 0.001, "door %d stands closed" % i)
	a.open_exit(1)
	assert_gt(look._doors_built[1].swing(), -0.0001, "the chosen door opens")
	assert_true(look._doors_built[1].is_open)
	assert_false(look._doors_built[0].is_open, "the other stays closed")


func test_the_fountain_is_water_to_walk_through() -> void:
	for v in 2:
		var a := _crypt(2, v)
		var b := CryptLook.FOUNTAIN_BASIN
		for p: Vector2 in [Vector2(b.x, b.y), Vector2(b.x - 0.8, b.y + 0.6), CryptLook.FOUNTAIN_RUNOFF[1]]:
			assert_true(a.on_floor(p, Player.RADIUS), "variant %d: %s is floor" % [v, p])
			assert_false(a.overlaps(p, Player.RADIUS), "variant %d: nothing blocks the basin at %s" % [v, p])
			assert_eq(a.resolve(p, Player.RADIUS), p, "walked through, never pushed")
