class_name HeroBody
extends RefCounted
## The hero's body: the Meshy model of the approved "Explorador" (docs/art/hero_explorer.md; scarf, mantle, straps
## and buckles are his own), his own clips (made from a CC0 animation library by tools/bake_hero.gd) and the sword
## in his right hand. Shared by the game (Player), the title screen and tools/pose_lab.gd. The provisional "Sombra"
## body (hero_sombra/, repainted by tools/recolor_hero.gd and dressed by HeroGear) is kept, unused.

const MODEL := "res://assets/models/meshy/hero_explorer/hero_explorer-rigged.glb"
const ANIMS := "res://assets/models/meshy/hero_explorer/hero_anims.res"
## How much of his own colours he shows away from any light (emission from the albedo): the game's lights are warm
## and few, and from the back (where the camera sees him most) the leathers went black and the gold edge took over.
const FILL := 0.28
## The model is this tall as it comes; the game draws him HEIGHT tall. His reach, radius and every number of the
## fight follow the Hades II scale (2.5 m, GAME_HEIGHT); cycle 5 draws him a little taller than that so he reads
## next to the crowd as on the reference painting (docs/art/cycle5_spec.md A3; only the drawing changes).
const MODEL_HEIGHT := 1.8
const GAME_HEIGHT := 2.5
const HEIGHT := 2.75
## The sword at this many times the Knight's own sword at GAME_HEIGHT; it grows with the model.
const SWORD_SCALE := 1.0
## Eterra Stylized (STY-06; docs/art/stylized_spec.md 2.3): his shader in that look and its outline pass.
const PAINT := preload("res://assets/shaders/hero_paint.gdshader")
const PAINT_OUTLINE := preload("res://assets/shaders/hero_outline.gdshader")
## The outline: meters of the world, colour (T20: 0.045 m, cold dark ink).
const OUTLINE_WIDTH := 0.045
const OUTLINE_COLOR := Color(0.05, 0.07, 0.08)


## The model at the game's size, playing his own clips. Returns [model, AnimationPlayer, sword].
static func make() -> Array:
	var model := (load(MODEL) as PackedScene).instantiate() as Node3D
	model.scale = Vector3.ONE * (HEIGHT / MODEL_HEIGHT)
	var anim := PoseBaker.find_player(model)
	anim.stop()
	for lib in anim.get_animation_library_list():
		anim.remove_animation_library(lib)
	anim.add_animation_library(&"", load(ANIMS))
	_fill(model)
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
	var size := SWORD_SCALE * MODEL_HEIGHT / GAME_HEIGHT / unit
	sword.transform = Transform3D(Basis(Quaternion(Vector3.UP, blade)).scaled(Vector3.ONE * size), clips.get_meta(&"grip_at", Vector3.ZERO))
	return sword


## His own painted texture, also a little as light (FILL), so he keeps his colours where the room's light does not
## reach. In the stylized look (VisualProfile, F7 flips it live) his own shader instead (painted(), with the same FILL)
## and the outline shell after it.
static func _fill(model: Node3D) -> void:
	for n in model.find_children("*", "MeshInstance3D", true, false):
		var mi := n as MeshInstance3D
		var mat := (mi.get_active_material(0) as StandardMaterial3D).duplicate() as StandardMaterial3D
		var paint := painted(mat)
		mat.emission_enabled = true
		mat.emission = Color.WHITE
		# multiply: the colour times the texture (the default, add, puts the full white on top of it)
		mat.emission_operator = BaseMaterial3D.EMISSION_OP_MULTIPLY
		mat.emission_texture = mat.albedo_texture
		mat.emission_energy_multiplier = FILL
		mi.material_override = mat
		VisualProfile.vary(mi, {&"material_override": paint})


## His stylized material from the model's own (StandardMaterial3D): the painting, its colour, FILL; the outline after.
static func painted(own: StandardMaterial3D) -> ShaderMaterial:
	var mat := ShaderMaterial.new()
	mat.shader = PAINT
	mat.set_shader_parameter(&"albedo", own.albedo_texture)
	mat.set_shader_parameter(&"tint", own.albedo_color)
	mat.set_shader_parameter(&"fill", FILL)
	var edge := ShaderMaterial.new()
	edge.shader = PAINT_OUTLINE
	edge.set_shader_parameter(&"width", OUTLINE_WIDTH)
	edge.set_shader_parameter(&"color", OUTLINE_COLOR)
	mat.next_pass = edge
	return mat


## Both looks' materials of a mesh of his body (the classic one and, if it has one, the stylized one).
static func materials(mi: MeshInstance3D) -> Array[Material]:
	var out: Array[Material] = []
	var classic: Variant = VisualProfile.classic_of(mi, &"material_override", mi.material_override)
	var styled: Variant = VisualProfile.styled(mi, &"material_override")
	for m: Variant in [classic, styled]:
		if m is Material and not out.has(m):
			out.append(m)
	return out


## Whether a material of his body takes the fill (the painting as light; Player lightens it in the blink after a hit).
static func fills(mat: Material) -> bool:
	if mat is ShaderMaterial:
		return (mat as ShaderMaterial).shader == PAINT
	var own := mat as StandardMaterial3D
	return own != null and own.emission_enabled and own.shading_mode != BaseMaterial3D.SHADING_MODE_UNSHADED


## The fill of a material of his body (fills() true): the classic one's emission energy, the stylized one's `fill`.
static func set_fill(mat: Material, fill: float) -> void:
	if mat is ShaderMaterial:
		(mat as ShaderMaterial).set_shader_parameter(&"fill", fill)
	elif mat is StandardMaterial3D:
		(mat as StandardMaterial3D).emission_energy_multiplier = fill
