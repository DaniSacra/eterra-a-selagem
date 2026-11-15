class_name HeroGear
extends RefCounted
## What the approved "Explorador" sheet wears over the provisional body (docs/art/hero_explorer.md): a steel pauldron
## on each shoulder, a brass buckle, a pouch, a teal mantle on the back and
## wide cuffs on the boots. Simple shapes on the bones (they follow every clip; nothing in the skeleton or the clips
## changes). Provisional until a real model of the explorer is made.
##
## Each piece is placed in the model's rest pose, in meters on the 1.8 m model (+Z is his front), and hung on a bone.

const STEEL := Color(0.4, 0.36, 0.38)
const GOLD := Color(0.9, 0.62, 0.25)
const LEATHER := Color(0.42, 0.25, 0.15)
const TEAL := Color(0.14, 0.32, 0.28)
## The mantle: width and length (meters on the 1.8 m model), its centre, how far it leans back from the spine.
const MANTLE := Vector2(0.4, 0.76)
const MANTLE_AT := Vector3(0, 1.05, -0.17)
const MANTLE_TILT := 0.12


static func dress(model: Node3D, skeleton: Skeleton3D) -> void:
	var to_model := _skeleton_to_model(skeleton, model)
	# little metal: a polished plate mirrors the cold teal air and turns the shoulders white from above
	var steel := _mat(STEEL, 0.2, 0.6)
	var gold := _mat(GOLD, 0.8, 0.35)
	var leather := _mat(LEATHER, 0.0, 0.8)
	# the pauldrons: two overlapping plates over each shoulder, tilted out and down the arm
	for side: Array in [[&"LeftArm", 1.0], [&"RightArm", -1.0]]:
		for k in 2:
			var plate := _box(Vector3(0.15, 0.035 - k * 0.006, 0.17 - k * 0.02), steel)
			_hang(skeleton, to_model, side[0], plate,
				Transform3D(Basis.from_euler(Vector3(0, 0, (-0.45 - k * 0.25) * side[1])), Vector3((0.17 + k * 0.05) * side[1], 1.42 - k * 0.05, -0.01)))
	# the brass buckle at the front of the belt
	_hang(skeleton, to_model, &"Hips", _box(Vector3(0.075, 0.055, 0.015), gold), Transform3D(Basis(), Vector3(0, 1.105, 0.13)))
	# a pouch on the right hip
	_hang(skeleton, to_model, &"Hips", _box(Vector3(0.07, 0.09, 0.05), leather), Transform3D(Basis(), Vector3(-0.15, 1.06, 0.07)))
	# the mantle: a teal sheet hanging from the shoulders down the back below the knees (the camera sees him from
	# behind most of the time: it is his biggest patch of colour), a thin gold hem
	var mantle := _box(Vector3(MANTLE.x, MANTLE.y, 0.02), _mat(TEAL, 0.0, 0.9))
	_hang(skeleton, to_model, &"Spine", mantle, Transform3D(Basis.from_euler(Vector3(MANTLE_TILT, 0, 0)), MANTLE_AT))
	var hem := _box(Vector3(MANTLE.x + 0.01, 0.02, 0.025), gold)
	var bottom := MANTLE_AT + Basis.from_euler(Vector3(MANTLE_TILT, 0, 0)) * Vector3(0, -MANTLE.y * 0.5, -0.01)
	_hang(skeleton, to_model, &"Spine", hem, Transform3D(Basis.from_euler(Vector3(MANTLE_TILT, 0, 0)), bottom))
	# wide leather cuffs at the top of the boots
	for side: Array in [[&"LeftLeg", 1.0], [&"RightLeg", -1.0]]:
		var cuff := CylinderMesh.new()
		cuff.top_radius = 0.066
		cuff.bottom_radius = 0.06
		cuff.height = 0.08
		cuff.radial_segments = 10
		var mi := MeshInstance3D.new()
		mi.mesh = cuff
		mi.material_override = leather
		_hang(skeleton, to_model, side[0], mi, Transform3D(Basis(), Vector3(0.095 * side[1], 0.47, 0.01)))


## Hangs `piece` on `bone` so it sits at `rest` (model meters) when the skeleton is in its rest pose.
static func _hang(skeleton: Skeleton3D, to_model: Transform3D, bone: StringName, piece: Node3D, rest: Transform3D) -> void:
	var i := skeleton.find_bone(bone)
	if i < 0:
		return
	var holder := BoneAttachment3D.new()
	holder.bone_name = bone
	skeleton.add_child(holder)
	holder.add_child(piece)
	# model meters -> skeleton space -> the bone's own space
	piece.transform = skeleton.get_bone_global_rest(i).affine_inverse() * to_model.affine_inverse() * rest


## The skeleton's space in the model's (the glTF puts the skeleton under scaled nodes).
static func _skeleton_to_model(skeleton: Skeleton3D, model: Node3D) -> Transform3D:
	var t := Transform3D.IDENTITY
	var n: Node = skeleton
	while n != null and n != model:
		t = (n as Node3D).transform * t
		n = n.get_parent()
	return t


static func _box(size: Vector3, mat: Material) -> MeshInstance3D:
	var b := BoxMesh.new()
	b.size = size
	var mi := MeshInstance3D.new()
	mi.mesh = b
	mi.material_override = mat
	return mi


static func _mat(c: Color, metal: float, rough: float) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = c
	m.metallic = metal
	m.roughness = rough
	m.emission_enabled = true
	m.emission = c * HeroBody.FILL
	return m
