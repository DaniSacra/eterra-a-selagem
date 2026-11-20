extends GutTest
## The light of Elun over what the paladin may take (RewardShaft, vfx_pass_spec.md 6).


func _shaft(strength := 1.0) -> RewardShaft:
	var root := Node3D.new()
	add_child_autofree(root)
	return RewardShaft.make(root, Vector3(2, 0, 3), RewardShaft.IVORY, strength)


func _run(s: RewardShaft, seconds: float) -> void:
	var t := 0.0
	while t < seconds and is_instance_valid(s):
		s._process(1.0 / 60.0)
		t += 1.0 / 60.0


func test_it_comes_down_lands_and_stays() -> void:
	var s := _shaft()
	assert_false(s.visible, "nothing until appear")
	s.appear()
	_run(s, RewardShaft.WAIT * 0.5)
	assert_eq(s.stage, RewardShaft.Stage.WAITING)
	_run(s, RewardShaft.WAIT * 0.5 + RewardShaft.DOWN + RewardShaft.LAND + 0.1)
	assert_eq(s.stage, RewardShaft.Stage.HERE, "down and landed")
	assert_true(s.visible)
	assert_almost_eq(s.global_position, Vector3(2, 0, 3), Vector3.ONE * 0.001, "its foot where asked")


func test_taken_it_goes_up_and_frees_itself() -> void:
	var s := _shaft()
	s.appear(0.0, true)
	assert_eq(s.stage, RewardShaft.Stage.HERE, "now: there at once")
	s.take()
	assert_eq(s.stage, RewardShaft.Stage.UP)
	_run(s, RewardShaft.UP + 0.05)
	await get_tree().process_frame
	assert_false(is_instance_valid(s), "gone after the light went up")


func test_shop_strength_eases() -> void:
	var s := _shaft(RewardShaft.SHOP_CAN)
	s.appear(0.0, true)
	s.set_strength(RewardShaft.SHOP_CANNOT)
	_run(s, RewardShaft.STRENGTH_TIME + 0.05)
	assert_almost_eq(s.strength, RewardShaft.SHOP_CANNOT, 0.01)


func test_colours_stay_pale_and_keep_their_tone() -> void:
	for reward: int in RewardShaft.TONE:
		var c := RewardShaft.tint_of(reward)
		assert_lte(c.s, 0.3, "pale: %d" % reward)
		var tone: Vector2 = RewardShaft.TONE[reward]
		if tone.y >= 0.2:
			var off := absf(fmod(c.h * 360.0 - tone.x + 540.0, 360.0) - 180.0)
			assert_lt(off, 15.0, "hue of %d near its tone" % reward)
	assert_eq(RewardShaft.tint_of(RunMap.Reward.BOON), RewardShaft.IVORY, "two angels: ivory")
	for f in AngelSeal.TINT.size():
		var c := RewardShaft.tint_of(RunMap.Reward.BOON, f)
		assert_ne(c, RewardShaft.IVORY, "angel %d tints it" % f)
