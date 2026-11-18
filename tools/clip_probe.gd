extends "res://tools/bake.gd"
## Reads the hands through a clip carried to a figure, to time a new clip on an old one (VX-14: a heavier clip for
## Morvath with the same length and the same moment of the blow): per sample, the share of the clip, the sword
## hand's height, its speed (meters a second of the clip at size 1) and how far apart the hands are, then the
## moments where the hand is highest and fastest, and (A-T5-4) how far each hand is in front of the chest by second.
## ~/tools/godot/godot --headless --path . -s tools/clip_probe.gd -- <id> <rig>:<clip>[:<from>:<to>] ...
## (the clip's own length without from and to; "<clip>+2h" holds the blade in both hands, "two_hands").

const SAMPLES := 40


func _process(_delta: float) -> bool:
	if _done:
		return true
	_done = true
	var args := Array(OS.get_cmdline_user_args())
	var spec: Dictionary = MODELS[args.pop_front()]
	var model := (load(MESHY % [spec.meshy, spec.meshy]) as PackedScene).instantiate() as Node3D
	get_root().add_child(model)
	var skeleton := PoseBaker.find_skeleton(model)
	var retargets := {}
	var idle: Array = spec.anims.idle
	_pose_meshy(skeleton, model, retargets, idle, 0.0, {})
	var armature := skeleton.get_parent() as Node3D
	armature.scale *= float(spec.height) / PoseBaker.snapshot(model, skeleton).get_aabb().end.y
	retargets.clear()
	var to_root := func() -> Transform3D: return PoseBaker.local_to(model, skeleton)
	for arg: String in args:
		var parts := arg.split(":")
		var rig := StringName(parts[0])
		var player: AnimationPlayer = _rig(rig)[1]
		var from := float(parts[2]) if parts.size() > 3 else 0.0
		var to := float(parts[3]) if parts.size() > 3 else player.get_animation(parts[1].trim_suffix("+2h")).length
		var a := [rig, parts[1].trim_suffix("+2h"), SAMPLES, false, {"from": from, "to": to, "two_hands": parts[1].ends_with("+2h")}]
		var last := Vector3.ZERO
		var top := [-INF, 0.0]
		var fast := [0.0, 0.0]
		var rows := PackedStringArray()
		var ahead := PackedStringArray()
		var dt := (to - from) / (SAMPLES - 1)
		for i in SAMPLES:
			var t := from + dt * i
			_pose_meshy(skeleton, model, retargets, a, t, {})
			var xf: Transform3D = to_root.call()
			var right := xf * skeleton.get_bone_global_pose(skeleton.find_bone("RightHand")).origin
			var left := xf * skeleton.get_bone_global_pose(skeleton.find_bone("LeftHand")).origin
			var speed := 0.0 if i == 0 else right.distance_to(last) / dt
			last = right
			var share := float(i) / (SAMPLES - 1)
			if right.y > top[0]:
				top = [right.y, share]
			if speed > fast[0]:
				fast = [speed, share]
			rows.append("%.2f:%.2f/%.1f/%.2f" % [share, right.y, speed, right.distance_to(left)])
			var chest := xf * skeleton.get_bone_global_pose(skeleton.find_bone("Spine")).origin
			ahead.append("%.2f:%+.2f/%+.2f" % [from + dt * i, left.z - chest.z, right.z - chest.z])
		print("CLIP %s:%s %.2f to %.2f (%.2f s): highest %.2f m at %.2f, fastest %.1f m/s at %.2f" % [rig, parts[1], from, to, to - from, top[0], top[1], fast[0], fast[1]])
		print("  share:height/speed/hands apart  " + " ".join(rows))
		print("  second:left/right hand ahead of the chest (m, +z the front)  " + " ".join(ahead))
	model.free()
	quit()
	return true
