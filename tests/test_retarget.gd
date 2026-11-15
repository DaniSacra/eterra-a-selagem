extends GutTest
## Retarget.turn: where a bone points in the skeleton's space for a solved pose, so that tools/bake.gd can hold an
## arm where one clip has it while the body follows another.


func _arm() -> Skeleton3D:
	var sk: Skeleton3D = autofree(Skeleton3D.new())
	for bone: String in ["Hips", "Spine02", "RightArm"]:
		var b := sk.add_bone(bone)
		sk.set_bone_parent(b, b - 1)
		sk.set_bone_rest(b, Transform3D(Basis(), Vector3(0, 1, 0)))
	return sk


func test_turn_follows_the_parents_and_holds_against_them() -> void:
	var sk := _arm()
	var rt := Retarget.new(sk, sk, sk, sk, {&"Hips": &"Hips", &"Spine02": &"Spine02", &"RightArm": &"RightArm"})
	var arm := sk.find_bone("RightArm")
	var spine := sk.find_bone("Spine02")
	assert_true(rt.turn(arm, {}).is_equal_approx(Basis()), "at rest")
	assert_true(rt.turn(-1, {}).is_equal_approx(Basis()), "no bone: no turn")
	var twist := Quaternion(Vector3.UP, 1.0)
	var raise := Quaternion(Vector3.RIGHT, 0.5)
	# a clip that twists the trunk, another that raises the arm
	var run := {spine: twist}
	var guard := {arm: raise}
	assert_true(rt.turn(arm, run).is_equal_approx(Basis(twist)), "the arm goes with the trunk")
	# the arm held where the guard has it, under the twisted trunk
	run[arm] = (rt.turn(spine, run).inverse() * rt.turn(arm, guard)).get_rotation_quaternion()
	assert_true(rt.turn(arm, run).is_equal_approx(Basis(raise)), "held where the guard clip points it")
