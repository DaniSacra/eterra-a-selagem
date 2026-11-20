class_name EmethSword
extends RefCounted
## Emeth, the sword of truth (Daniel's concept art of 2026-11-14): the Meshy model made from it, a blade of emerald
## crystal with gold veins, a horned golden guard with an emerald, a red grip and a pommel with an emerald. It has
## the size and the grip of the sword of simple shapes it replaced (and of the KayKit sword before that): the blade
## along +Y from the grip, which is at the origin; the tip at TIP. Shared by the game and the title screen through
## HeroBody.

const MODEL := "res://assets/models/meshy/emeth/emeth.glb"
const SHADER := preload("res://assets/shaders/emeth.gdshader")
## The model's own space (blade along +Y, 1.9 long, its middle at the origin): where the pommel ends, the grip
## meets the guard, the blade starts and ends.
const MODEL_POMMEL := -0.95
const MODEL_GRIP_TOP := -0.42
const MODEL_BLADE_FROM := -0.1
const MODEL_TIP := 0.95
## The sword's space (HeroBody places it in the hand): the hand closes at the origin, right under the guard; the
## grip ends GRIP_TOP above it and the blade's tip is at TIP, as on the sword it replaced.
const GRIP_TOP := 0.13
const TIP := 1.5
## Emerald, not cyan (cycle 5, docs/art/cycle5_spec.md A2: 18d961 on the screen; the tone mapper turns a bright green
## toward cyan, so the colour is set a little yellower than that).
const GREEN := Color(0.08, 0.85, 0.27)
## How bright the blade's body is: under the WorldEnvironment glow threshold (Game.GLOW_THRESHOLD, after the
## exposure), so the blade keeps its shape.
const BLADE_GLOW := 1.0
## The most a swing lifts it to, for an instant (Fx.blade_pulse): past the threshold, so the blade answers the blow
## without ever lighting the room (it is no light, only its own surface).
const PULSE_GLOW := 1.6
## The group the blade's mesh is in, so the effects find it.
const GROUP := &"emeth_blade"
## The light edge down the middle of the blade, the only part that blooms: its colour, brightness, width and
## depth in meters (it stands a little out of both faces of the crystal) and the share of the blade it runs along.
const CORE := Color(0.6, 1.0, 0.75)
const CORE_GLOW := 1.25
const CORE_WIDTH := 0.022
const CORE_DEPTH := 0.076
const CORE_SPAN := Vector2(0.08, 0.86)
## Eterra Stylized (STY-06, T22): the pale edge in that look, ivory-mint with no channel past 1.0 (nothing blooms).
## STY-09: (0.72, 0.95, 0.8) still reached 255 on the screen (exposure 1.25), white pixels down the raised blade; now
## under the screen's ceiling (ScreenTone.SAFE) with the stylized look's saturation.
const STYLE_CORE := Color(0.56, 0.76, 0.63)
## Temperar (Fatia 1): the highest rank of the blade the shader draws (set_temper).
const TEMPER_MAX := 2


## The sword: an empty holder at the grip with the model under it (HeroBody places the holder in the hand).
static func make() -> MeshInstance3D:
	var root := MeshInstance3D.new()
	var scene := (load(MODEL) as PackedScene).instantiate()
	var model := scene.find_children("*", "MeshInstance3D", true, false)[0] as MeshInstance3D
	var blade := MeshInstance3D.new()
	blade.name = &"Blade"
	blade.mesh = model.mesh
	var size := scale()
	blade.transform = Transform3D(Basis().scaled(Vector3.ONE * size), Vector3(0, GRIP_TOP - MODEL_GRIP_TOP * size, 0))
	var mat := ShaderMaterial.new()
	mat.shader = SHADER
	mat.set_shader_parameter(&"albedo", (model.mesh.surface_get_material(0) as BaseMaterial3D).albedo_texture)
	mat.set_shader_parameter(&"blade_from", MODEL_BLADE_FROM)
	mat.set_shader_parameter(&"blade_color", GREEN)
	mat.set_shader_parameter(&"blade_glow", BLADE_GLOW)
	blade.material_override = mat
	blade.add_to_group(GROUP)
	root.add_child(blade)
	scene.free()
	# the pale edge down the middle of the blade (in the model's space, under the blade)
	var core := MeshInstance3D.new()
	core.name = &"Core"
	var strip := BoxMesh.new()
	var length := MODEL_TIP - MODEL_BLADE_FROM
	strip.size = Vector3(CORE_WIDTH, length * (CORE_SPAN.y - CORE_SPAN.x), CORE_DEPTH)
	core.mesh = strip
	core.position.y = MODEL_BLADE_FROM + length * (CORE_SPAN.x + CORE_SPAN.y) * 0.5
	var light := StandardMaterial3D.new()
	light.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	light.albedo_color = CORE * CORE_GLOW
	VisualProfile.vary(light, {&"albedo_color": STYLE_CORE})
	core.material_override = light
	blade.add_child(core)
	return root


## The blade's material of the sword that lives under a node (the game's own, not the title screen's); null if none.
static func blade_of(under: Node) -> ShaderMaterial:
	if under == null or not under.is_inside_tree():
		return null
	for n in under.get_tree().get_nodes_in_group(GROUP):
		if under.is_ancestor_of(n):
			return (n as MeshInstance3D).material_override as ShaderMaterial
	return null


## The pulse of a swing on a blade's material: k 1 lifts its light to PULSE_GLOW, 0 leaves it still.
static func set_pulse(blade: ShaderMaterial, k: float) -> void:
	blade.set_shader_parameter(&"pulse", (PULSE_GLOW - BLADE_GLOW) * clampf(k, 0.0, 1.0))


## A boss's curse on the blade's material: k 1 lets the violet creep up the crystal (emeth.gdshader corrupt), 0 is
## Emeth's emerald whole.
static func set_corrupt(blade: ShaderMaterial, k: float) -> void:
	blade.set_shader_parameter(&"corrupt", clampf(k, 0.0, 1.0))


## Temperar (Fatia 1): the Forjador's rank of the blade (ForgeRank, 0 to TEMPER_MAX; fractions grow the marks in,
## for the moment of the upgrade): one vein of old gold and one more reach of the pale edge thread per rank
## (emeth.gdshader temper). 0 is the blade as it always was.
static func set_temper(blade: ShaderMaterial, rank: float) -> void:
	blade.set_shader_parameter(&"temper", clampf(rank, 0.0, float(TEMPER_MAX)))


## The model's size in the sword's space: its blade and guard fill GRIP_TOP to TIP.
static func scale() -> float:
	return (TIP - GRIP_TOP) / (MODEL_TIP - MODEL_GRIP_TOP)
