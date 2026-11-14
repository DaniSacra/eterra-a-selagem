class_name Retarget
extends RefCounted
## Poses one body from another skeleton: the hero (Meshy, 24 bones, A-pose, centimeters) takes the pose of an
## animated mannequin (other proportions, T-pose). Used by tools/bake_hero.gd to turn animation clips made for
## other rigs into the hero's own clips.
##
## Each mapped bone takes the source bone's turn away from its rest, in model space, applied to the target's rest
## after that rest has been swung to point where the source's rest points (so A-pose arms match T-pose arms).
## The hips also carry the source's lift and sway, scaled by the height of the two hips.

## Target (hero) bone -> source bone, for each source rig.
const RIGS := {
	&"kaykit": {
		&"Hips": &"hips", &"Spine02": &"spine", &"Spine": &"chest", &"Head": &"head",
		&"LeftArm": &"upperarm.l", &"LeftForeArm": &"lowerarm.l", &"LeftHand": &"hand.l",
		&"RightArm": &"upperarm.r", &"RightForeArm": &"lowerarm.r", &"RightHand": &"hand.r",
		&"LeftUpLeg": &"upperleg.l", &"LeftLeg": &"lowerleg.l", &"LeftFoot": &"foot.l", &"LeftToeBase": &"toes.l",
		&"RightUpLeg": &"upperleg.r", &"RightLeg": &"lowerleg.r", &"RightFoot": &"foot.r", &"RightToeBase": &"toes.r",
	},
	# Quaternius Universal Animation Library (Rigify names)
	&"ual": {
		&"Hips": &"DEF-hips", &"Spine02": &"DEF-spine.001", &"Spine01": &"DEF-spine.002", &"Spine": &"DEF-spine.003",
		&"neck": &"DEF-neck", &"Head": &"DEF-head",
		&"LeftShoulder": &"DEF-shoulder.L", &"LeftArm": &"DEF-upper_arm.L", &"LeftForeArm": &"DEF-forearm.L", &"LeftHand": &"DEF-hand.L",
		&"RightShoulder": &"DEF-shoulder.R", &"RightArm": &"DEF-upper_arm.R", &"RightForeArm": &"DEF-forearm.R", &"RightHand": &"DEF-hand.R",
		&"LeftUpLeg": &"DEF-thigh.L", &"LeftLeg": &"DEF-shin.L", &"LeftFoot": &"DEF-foot.L", &"LeftToeBase": &"DEF-toe.L",
		&"RightUpLeg": &"DEF-thigh.R", &"RightLeg": &"DEF-shin.R", &"RightFoot": &"DEF-foot.R", &"RightToeBase": &"DEF-toe.R",
	},
	# Quaternius Universal Animation Library 2 (Unreal names)
	&"ual2": {
		&"Hips": &"pelvis", &"Spine02": &"spine_01", &"Spine01": &"spine_02", &"Spine": &"spine_03",
		&"neck": &"neck_01", &"Head": &"Head",
		&"LeftShoulder": &"clavicle_l", &"LeftArm": &"upperarm_l", &"LeftForeArm": &"lowerarm_l", &"LeftHand": &"hand_l",
		&"RightShoulder": &"clavicle_r", &"RightArm": &"upperarm_r", &"RightForeArm": &"lowerarm_r", &"RightHand": &"hand_r",
		&"LeftUpLeg": &"thigh_l", &"LeftLeg": &"calf_l", &"LeftFoot": &"foot_l", &"LeftToeBase": &"ball_l",
		&"RightUpLeg": &"thigh_r", &"RightLeg": &"calf_r", &"RightFoot": &"foot_r", &"RightToeBase": &"ball_r",
	},
}
## The hero bone each one points at, to line the two rests up. The source side points at the bone mapped to the
## same one. A bone left out (or whose aim is not mapped) keeps its parent's correction.
const AIM := {
	&"Hips": &"Spine02", &"Spine02": &"Spine01", &"Spine01": &"Spine", &"Spine": &"neck", &"neck": &"Head",
	&"LeftShoulder": &"LeftArm", &"LeftArm": &"LeftForeArm", &"LeftForeArm": &"LeftHand",
	&"RightShoulder": &"RightArm", &"RightArm": &"RightForeArm", &"RightForeArm": &"RightHand",
	&"LeftUpLeg": &"LeftLeg", &"LeftLeg": &"LeftFoot", &"LeftFoot": &"LeftToeBase",
	&"RightUpLeg": &"RightLeg", &"RightLeg": &"RightFoot", &"RightFoot": &"RightToeBase",
}

var source: Skeleton3D
var target: Skeleton3D
## Each entry: [target bone, source bone, source rest (model space), corrected target rest (model space)], parents first.
var _bones: Array = []
var _src_space: Basis
var _tgt_space: Basis
var _src_space_full: Basis
var _tgt_space_inv_full: Basis
var _hips_src := -1
var _hips_tgt := -1
var _hips_src_rest := Vector3.ZERO
var _hips_tgt_rest := Vector3.ZERO
var _hips_ratio := 1.0


## Lines the two skeletons up. src_root, tgt_root: the roots of the two models (their skeletons may sit under
## scaled nodes inside them). map: target bone -> source bone (one of RIGS).
func _init(src: Skeleton3D, src_root: Node3D, tgt: Skeleton3D, tgt_root: Node3D, map: Dictionary) -> void:
	source = src
	target = tgt
	var src_full := _space(src, src_root)
	var tgt_full := _space(tgt, tgt_root)
	_src_space_full = src_full
	_tgt_space_inv_full = tgt_full.inverse()
	_src_space = src_full.orthonormalized()
	_tgt_space = tgt_full.orthonormalized()
	var fixes := {}
	for ti in tgt.get_bone_count():
		var t := tgt.get_bone_name(ti)
		if not map.has(t):
			continue
		var si := src.find_bone(map[t])
		if si < 0:
			continue
		var s0 := _src_space * src.get_bone_global_rest(si).basis.orthonormalized()
		var t0 := _tgt_space * tgt.get_bone_global_rest(ti).basis.orthonormalized()
		var fix := Basis.IDENTITY
		var aim: StringName = AIM.get(t, &"")
		var ta := tgt.find_bone(aim)
		var sa := src.find_bone(map.get(aim, &""))
		if ta >= 0 and sa >= 0:
			var dt := (_tgt_space * (tgt.get_bone_global_rest(ta).origin - tgt.get_bone_global_rest(ti).origin)).normalized()
			var ds := (_src_space * (src.get_bone_global_rest(sa).origin - src.get_bone_global_rest(si).origin)).normalized()
			fix = Basis(Quaternion(dt, ds))
		else:
			var parent := tgt.get_bone_parent(ti)
			while parent >= 0 and not fixes.has(parent):
				parent = tgt.get_bone_parent(parent)
			if parent >= 0:
				fix = fixes[parent]
		fixes[ti] = fix
		_bones.append([ti, si, s0, fix * t0])
	_hips_tgt = tgt.find_bone(&"Hips")
	_hips_src = src.find_bone(map[&"Hips"])
	_hips_src_rest = src.get_bone_global_rest(_hips_src).origin
	_hips_tgt_rest = tgt.get_bone_global_rest(_hips_tgt).origin
	var src_h := (src_full * _hips_src_rest).y
	var tgt_h := (tgt_full * _hips_tgt_rest).y
	_hips_ratio = tgt_h / maxf(src_h, 0.001)


## The rotation and scale from a skeleton's own space to its model's root.
static func _space(sk: Node3D, root: Node3D) -> Basis:
	var b := Basis.IDENTITY
	var n: Node = sk
	while n != null and n != root:
		b = (n as Node3D).transform.basis * b
		n = n.get_parent()
	return b


## The target's local rotation for each mapped bone, for the source's current pose: {bone: Quaternion}.
## Bones left out keep their rest.
func solve() -> Dictionary:
	var out := {}
	var turned := {}
	for e: Array in _bones:
		var ti: int = e[0]
		var s := _src_space * source.get_bone_global_pose(e[1]).basis.orthonormalized()
		var want: Basis = s * (e[2] as Basis).inverse() * (e[3] as Basis)
		var want_skel := (_tgt_space.inverse() * want).orthonormalized()
		var parent := target.get_bone_parent(ti)
		var parent_rot := _turn(parent, out, turned) if parent >= 0 else Basis.IDENTITY
		var local := (parent_rot.inverse() * want_skel).get_rotation_quaternion()
		out[ti] = local
		turned[ti] = parent_rot * Basis(local)
	return out


## The target hips' position (skeleton space) for the source's current pose. flat: drop the walk along the floor
## (clips that carry their own root motion).
func hips_position(flat := false) -> Vector3:
	var moved := _src_space_full * (source.get_bone_global_pose(_hips_src).origin - _hips_src_rest) * _hips_ratio
	if flat:
		moved = Vector3(0, moved.y, 0)
	return _hips_tgt_rest + _tgt_space_inv_full * moved


func hips_bone() -> int:
	return _hips_tgt


## Something fixed to a source bone (a held sword), placed on the matching target bone: from the source's rest,
## model-space direction and offset -> the target bone's own frame, in the target skeleton's units.
## Returns [direction, offset].
func carry(target_bone: StringName, dir: Vector3, offset: Vector3) -> Array:
	var ti := target.find_bone(target_bone)
	for e: Array in _bones:
		if e[0] == ti:
			var frame: Basis = (e[3] as Basis).inverse()
			var unit := 1.0 / _tgt_space_inv_full.get_scale().x
			return [(frame * dir).normalized(), frame * offset * _hips_ratio / unit]
	return [Vector3.UP, Vector3.ZERO]


## A source bone's rest position in its model's space (meters).
func source_rest(bone: StringName) -> Vector3:
	return _src_space_full * source.get_bone_global_rest(source.find_bone(bone)).origin


## A target bone's turn in skeleton space: solved bones from `solved`, the others at their rest.
func _turn(bone: int, solved: Dictionary, memo: Dictionary) -> Basis:
	if memo.has(bone):
		return memo[bone]
	var parent := target.get_bone_parent(bone)
	var local: Quaternion = solved[bone] if solved.has(bone) else target.get_bone_rest(bone).basis.get_rotation_quaternion()
	var b := (_turn(parent, solved, memo) if parent >= 0 else Basis.IDENTITY) * Basis(local)
	memo[bone] = b
	return b
