class_name Slender
extends SkeletonModifier3D
## Turns the chunky KayKit rig into a slimmer figure after the animation has posed it:
## a smaller head, longer legs and a longer trunk. Used live on the paladin and by tools/bake.gd on the crowd.

const HEAD := 0.58
const LEGS := 1.7
const TRUNK := 1.25
const SLIM := 0.84


func _process_modification_with_delta(_delta: float) -> void:
	apply(get_skeleton())


## Scales the bones of a posed KayKit skeleton. Call once per pose (the animation writes the pose again each frame).
static func apply(sk: Skeleton3D) -> void:
	if sk == null:
		return
	var hips := sk.find_bone("hips")
	if hips < 0:
		return
	# legs: stretched along the bone, the hips lifted so the feet stay on the floor
	var leg_len := 0.0
	for side in [".l", ".r"]:
		var up := sk.find_bone("upperleg" + side)
		var low := sk.find_bone("lowerleg" + side)
		var foot := sk.find_bone("foot" + side)
		sk.set_bone_pose_scale(up, Vector3(SLIM, LEGS, SLIM))
		sk.set_bone_pose_scale(foot, Vector3(1.0 / SLIM, 1.0 / LEGS, 1.0 / SLIM))
		leg_len = (sk.get_bone_rest(low).origin.length() + sk.get_bone_rest(foot).origin.length())
	var pos := sk.get_bone_pose_position(hips)
	pos.y += leg_len * (LEGS - 1.0)
	sk.set_bone_pose_position(hips, pos)
	# trunk: a longer, narrower body; the head shrinks back against the stretch
	var spine := sk.find_bone("spine")
	sk.set_bone_pose_scale(spine, Vector3(SLIM, TRUNK, SLIM))
	var head := sk.find_bone("head")
	sk.set_bone_pose_scale(head, Vector3(HEAD / SLIM, HEAD / TRUNK, HEAD / SLIM))
