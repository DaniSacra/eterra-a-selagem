extends GutTest
## The Cripta B, Jardim B and Fendas pack of 2026-11-23: visual-only additions (a lion frame in the ossuary's floor, flower
## patches in the garden, lion banners on the bridge heads); nothing here may touch the rooms' collision.

func test_blossom_colours_are_never_red_or_violet() -> void:
	for c in Masonry.BLOSSOM_COLORS:
		assert_lt(c.r - c.b, 0.7, "warm cream or soft yellow only")
		assert_gt(c.g, 0.75, "no red (warning) and no violet (Morvath)")
	assert_gt(Masonry.BLOSSOM_PETALS, 3)


func test_blossoms_make_a_mesh_without_collision() -> void:
	var root := Node3D.new()
	add_child_autofree(root)
	var sm := Masonry.new(root)
	var mi := sm.blossoms(Vector3.ZERO, 8, 0.5, 3)
	assert_not_null(mi.mesh)
	assert_eq(mi.find_children("*", "CollisionObject3D", true, false).size(), 0)


func test_the_crypt_lion_frame_is_square_and_in_b_only() -> void:
	assert_true(CryptLook.STY_LION_FRAME_B)
	assert_lt(CryptLook.STY_FRAME_B, CryptLook.STY_FRAMES_B[1].x - CryptLook.STY_FRAMES_B[0].x + 0.2, "the pair does not overlap")


func test_the_bridge_banner_hangs_clear_of_the_deck() -> void:
	assert_gt(RiftLook.HEAD_POLE.y, RiftLook.HEAD_BANNER.y, "the pole is taller than the cloth")
