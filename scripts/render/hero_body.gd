class_name HeroBody
extends RefCounted
## The hero's body: the Meshy model, his own clips (made from a CC0 animation library by tools/bake_hero.gd) and
## the sword in his right hand. Shared by the game (Player) and tools/pose_lab.gd.

const MODEL := "res://assets/models/meshy/hero_sombra/hero_sombra-rigged.glb"
const ANIMS := "res://assets/models/meshy/hero_sombra/hero_anims.res"
## The body repainted toward the approved explorer sheet (tools/recolor_hero.gd); provisional, see docs/art/hero_explorer.md.
const SKIN := "res://assets/models/meshy/hero_sombra/hero_explorer_albedo.png"
## How much of his own colours he shows away from any light (emission from the albedo): the game's lights are warm
## and few, and from the back (where the camera sees him most) the leathers went black and the gold edge took over.
const FILL := 0.28
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
	_explorer(model)
	return [model, anim, _arm(model, anim.get_animation_library(&""))]


## The sword in the right hand, held where tools/bake_hero.gd found the grip (stored on the clips' library).
static func _arm(model: Node3D, clips: AnimationLibrary) -> MeshInstance3D:
	var skeleton := PoseBaker.find_skeleton(model)
	var hand := skeleton.find_bone(&"RightHand")
	if hand < 0:
		return null
	var grip := BoneAttachment3D.new()
	grip.bone_name = &"RightHand"
	skeleton.add_child(grip)
	# Emeth, the sword of truth (Daniel's concept of 2026-11-14), the size of the KayKit sword it replaced
	var sword := EmethSword.make()
	grip.add_child(sword)
	var space := Retarget._space(skeleton, model)
	var unit := space.get_scale().x
	var blade: Vector3 = clips.get_meta(&"grip_dir", Vector3.UP)
	var size := SWORD_SCALE * MODEL_HEIGHT / HEIGHT / unit
	sword.transform = Transform3D(Basis(Quaternion(Vector3.UP, blade)).scaled(Vector3.ONE * size), clips.get_meta(&"grip_at", Vector3.ZERO))
	return sword


## The explorer's look over the provisional body: the repainted texture and his gear (HeroGear).
static func _explorer(model: Node3D) -> void:
	for n in model.find_children("*", "MeshInstance3D", true, false):
		var mi := n as MeshInstance3D
		var mat := (mi.get_active_material(0) as StandardMaterial3D).duplicate() as StandardMaterial3D
		var skin: Texture2D = load(SKIN)
		mat.albedo_texture = skin
		mat.emission_enabled = true
		mat.emission = Color.WHITE
		# multiply: the colour times the texture (the default, add, puts the full white on top of it)
		mat.emission_operator = BaseMaterial3D.EMISSION_OP_MULTIPLY
		mat.emission_texture = skin
		mat.emission_energy_multiplier = FILL
		mi.material_override = mat
	HeroGear.dress(model, PoseBaker.find_skeleton(model))
