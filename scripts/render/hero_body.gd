class_name HeroBody
extends RefCounted
## The hero's body: the Meshy model, his own clips (made from a CC0 animation library by tools/bake_hero.gd) and
## the sword in his right hand. Shared by the game (Player) and tools/pose_lab.gd.

const MODEL := "res://assets/models/meshy/hero_sombra/hero_sombra-rigged.glb"
const ANIMS := "res://assets/models/meshy/hero_sombra/hero_anims.res"
## The KayKit Knight only lends its sword (blade along +Y from the grip).
const SWORD_FROM := "res://assets/models/characters/Knight.glb"
const SWORD_MESH := "1H_Sword"
## The model is this tall as it comes; the game shows him HEIGHT tall (Hades II scale: 2.5 m).
const MODEL_HEIGHT := 1.8
const HEIGHT := 2.5
## The sword at this many times the Knight's own sword, in meters at the game's size.
const SWORD_SCALE := 1.0


## The model at the game's size, playing his own clips. Returns [model, AnimationPlayer, sword].
static func make() -> Array:
	var model := (load(MODEL) as PackedScene).instantiate() as Node3D
	model.scale = Vector3.ONE * (HEIGHT / MODEL_HEIGHT)
	var anim := PoseBaker.find_player(model)
	anim.stop()
	for lib in anim.get_animation_library_list():
		anim.remove_animation_library(lib)
	anim.add_animation_library(&"", load(ANIMS))
	return [model, anim, _arm(model, anim.get_animation_library(&""))]


## The sword in the right hand, held where tools/bake_hero.gd found the grip (stored on the clips' library).
static func _arm(model: Node3D, clips: AnimationLibrary) -> MeshInstance3D:
	var knight := (load(SWORD_FROM) as PackedScene).instantiate()
	var src := knight.find_child(SWORD_MESH, true, false) as MeshInstance3D
	var mesh := src.mesh if src else null
	knight.free()
	var skeleton := PoseBaker.find_skeleton(model)
	var hand := skeleton.find_bone(&"RightHand")
	if mesh == null or hand < 0:
		return null
	var grip := BoneAttachment3D.new()
	grip.bone_name = &"RightHand"
	skeleton.add_child(grip)
	var sword := MeshInstance3D.new()
	sword.mesh = mesh
	grip.add_child(sword)
	var space := Retarget._space(skeleton, model)
	var unit := space.get_scale().x
	var blade: Vector3 = clips.get_meta(&"grip_dir", Vector3.UP)
	var size := SWORD_SCALE * MODEL_HEIGHT / HEIGHT / unit
	sword.transform = Transform3D(Basis(Quaternion(Vector3.UP, blade)).scaled(Vector3.ONE * size), clips.get_meta(&"grip_at", Vector3.ZERO))
	return sword
