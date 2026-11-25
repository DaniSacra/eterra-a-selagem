extends GutTest
## C-1 to C-4 (art 2026-11-25): the hall's living floor, the pit grate's frame, the warm pools and the candle drawings.


func test_hall_life_lays_decals_and_nothing_that_blocks() -> void:
	var root := Node3D.new()
	add_child_autofree(root)
	var sty := Masonry.new(root)
	HallLife.dress(root, sty)
	var life := root.get_node("HallLife")
	# the stain (2), the dust, the cracks: each a strip
	assert_eq(life.get_child_count(), 2 + HallLife.DUST + HallLife.CRACKS)
	assert_true(HallLife.SLAB_SIZE.y < 0.2, "slabs lie low")
	assert_true(HallLife.HEAP_SIZE.y < 0.3, "rubble under the knee")
	for c in life.get_children():
		assert_false(c is CollisionObject3D)


func test_the_three_candle_drawings_differ() -> void:
	var v := CatacombHall.CANDLE_VARIANTS
	assert_eq(v.size(), 3)
	assert_ne(v[0], v[1])
	assert_ne(v[1], v[2])


func test_grate_frame_is_dark_stone_with_no_white() -> void:
	assert_lt(HazardPiece.GRATE_FRAME_STONE.get_luminance(), 0.2)
	for c in HazardPiece.GRATE_PIT:
		assert_gt(c.get_luminance(), 0.0, "never pure black")
	var parent := Node3D.new()
	add_child_autofree(parent)
	var g := HazardPiece.grate(parent, Rect2(0, 0, 3.0, 2.0), 1.0)
	assert_not_null(g)


func test_warm_pool_is_a_floor_spot_off_the_crowd() -> void:
	var parent := Node3D.new()
	add_child_autofree(parent)
	var s := ArenaRoom.pool_spot(parent, Vector2(1, 2), 3.0, ArenaRoom.POOL_WARM, 2.0)
	assert_false(s.shadow_enabled)
	assert_eq(s.light_cull_mask & Arena.CROWD_LAYER, 0)
