class_name CrowdRenderer
extends Node3D
## Draws hundreds of characters from baked poses: one MultiMesh per (kind of enemy, animation, frame), plus one
## MultiMesh of soft round shadows. Each frame: begin(), add() once per character, commit().

## The common crowd is light bone with painted shading, as in the reference (docs/art/ref/arena_catacumbas_1672.png):
## each enemy in its own palette after Daniel's sheet (tools/make_palettes.gd), a little calmed, lit by a fixed key from the top left
## of the screen with darker feet and a thin dark edge, so every figure reads as a shaded body on the dark floor.
## (Until 2026-11-14 it was grey, lifted toward one value and glowing flat: plaster cut-outs that the cold ambient
## turned green.) How much colour goes, how much of the def's tint stays (the tints are cold and green), how much
## the scene's cold light still lights it.
const CROWD_GREY := 0.15
const CROWD_TINT_KEEP := 0.3
const CROWD_SCENE_LIGHT := 0.55
## Elites keep their colours, under the same light as the crowd (cycle 5: no longer a step brighter, the gilded look
## made them the brightest thing in the room), a little calmed.
const ELITE_SHADE := Color(1, 1, 1)
const ELITE_GREY := 0.12
## The painted light of every figure in the crowd (crowd.gdshader): key on the lit side, fill on the far side,
## brightness at the feet, how dark the edge goes.
const KEY := 0.8
const KEY_FILL := 0.16
const FOOT_SHADE := 0.55
const INK := 0.65
## Outline of elites and the boss (crowd_outline.gdshader): dark ink, like the stroke of the painting (cycle 5: no
## longer the rim's glowing gold; the elite reads by its gold trims and its armor bar), meters in the world (any
## size), brightness.
const OUTLINE_COLOR := Color(0.1, 0.08, 0.06)
const OUTLINE_WIDTH := 0.022
const OUTLINE_INTENSITY := 1.0
## Painted figures (the Meshy models): how much the bright saturated spots of the painting (eyes, gems, orbs, embers)
## shine by themselves, and the old gold the steel of an elite turns to (EnemyDef.gild says how much).
const PAINT_GLOW := 2.2
## The share of the edge light (EnemyDef.rim) a painted figure takes: its many small folds all catch it.
const PAINT_RIM := 0.3
## Their black and purple cloth is painted near black, and the floor is dark: the shadows of the painting are lifted
## (a gamma on its colours; 1 = as painted) so the robed figures read as bodies.
const PAINT_GAMMA := 0.7
const GILD_COLOR := Color(0.62, 0.46, 0.22)
## The old gold goes on the steel only (cycle 7): skull, bones and cloth keep the colours of the common figure
## (until then the whole elite took 0.3 of it and its skull read yellow).
const GILD_REST := 0.0
## A staff's orb and gems, in the colour of the figure's magic: always lit under the glow's threshold, swelling
## past it while it winds up (crowd.gdshader `orb`, `orb_tell`).
## Morvath fights beside the hero, whose warm light turned his violet robes grey and brown: he takes this share of it.
const BOSS_HERO_LIGHT := 0.25
const ORB_GLOW := 1.2
const ORB_TELL := 1.8
## With many enemies on the floor (more than Horde.BARS_FOR_ALL) the life bars thin out: opacity and height.
const BAR_CROWD_FADE := 0.7
const BAR_CROWD_HEIGHT := 0.75
const OUTLINE := preload("res://assets/shaders/crowd_outline.gdshader")
const FLOATS := 16  # 12 for the transform, 4 for the custom state
const SHADER := preload("res://assets/shaders/crowd.gdshader")
const BAR := preload("res://assets/shaders/life_bar.gdshader")
## The thin life bar over enemies' heads (Hades II): meters wide per meter of the enemy's radius, meters tall,
## and how far above the head.
const BAR_WIDTH := 2.2
const BAR_MIN_WIDTH := 1.1
const BAR_HEIGHT := 0.13
const BAR_ABOVE := 0.35

class Batch:
	var mmi: MultiMeshInstance3D
	var data := PackedFloat32Array()
	var count := 0
	var capacity := 0

## Visual layers of everything drawn here (torches skip the crowd's layer).
var layers := 1
var _models: Dictionary = {}  # model id -> BakedModel
var _materials: Dictionary = {}  # enemy id -> ShaderMaterial
var _batches: Dictionary = {}  # enemy id -> anim -> Array[Batch] (one per frame)
var _used: Array[Batch] = []
var _shadow: Batch
var _bars: Batch


func _ready() -> void:
	var plane := PlaneMesh.new()
	plane.size = Vector2(1, 1)
	var m := StandardMaterial3D.new()
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	m.albedo_color = Color(0.0, 0.0, 0.02, 0.55)
	m.albedo_texture = Fx.soft_dot()
	m.disable_receive_shadows = true
	plane.material = m
	_shadow = _new_batch(plane, null, false)
	var quad := QuadMesh.new()
	quad.size = Vector2(1, 1)
	var bar_mat := ShaderMaterial.new()
	bar_mat.shader = BAR
	bar_mat.render_priority = 10
	_bars = _new_batch(quad, bar_mat, true)


func model(id: StringName) -> BakedModel:
	if not _models.has(id):
		_models[id] = load("res://assets/baked/%s.res" % id)
	return _models[id]


func model_of(d: EnemyDef) -> BakedModel:
	return model(d.model)


## Prepares the look of a kind of enemy (its model's texture, tint, edge and outline).
func register(d: EnemyDef) -> void:
	if _materials.has(d.id):
		return
	var mat := ShaderMaterial.new()
	mat.shader = SHADER
	var baked := model(d.model)
	mat.set_shader_parameter(&"albedo", d.palette if d.palette and not baked.painted else baked.albedo)
	mat.set_shader_parameter(&"glow_from", baked.glow_from)
	mat.set_shader_parameter(&"paint_glow", PAINT_GLOW * d.shine if baked.painted else 0.0)
	mat.set_shader_parameter(&"paint_gamma", PAINT_GAMMA if baked.painted else 1.0)
	mat.set_shader_parameter(&"gild", d.gild if baked.painted else 0.0)
	mat.set_shader_parameter(&"gild_color", GILD_COLOR)
	mat.set_shader_parameter(&"gild_rest", GILD_REST)
	var magic := EnemyFx.magic_of(d) if d.magic_color.a > 0.0 else Color(0, 0, 0)
	mat.set_shader_parameter(&"magic", Vector3(magic.r, magic.g, magic.b))
	mat.set_shader_parameter(&"orb", ORB_GLOW)
	mat.set_shader_parameter(&"orb_tell", ORB_TELL)
	mat.set_shader_parameter(&"crest", d.crest)
	mat.set_shader_parameter(&"hero_light", BOSS_HERO_LIGHT if d.behavior == EnemyDef.Behavior.BOSS else 1.0)
	mat.set_shader_parameter(&"crest_from", baked.height * 0.8)
	# the common crowd in calmed bone colours; elites and the boss in their own colours, with a thin dark outline
	var common := not d.elite and d.behavior != EnemyDef.Behavior.BOSS
	# an elite's cloth and bone stay the colour of the common figure's (cycle 7): the same share of the tint
	var tint := Color.WHITE.lerp(d.tint, CROWD_TINT_KEEP) * (Color.WHITE if common else ELITE_SHADE) if d.behavior != EnemyDef.Behavior.BOSS else d.tint
	mat.set_shader_parameter(&"tint", tint)
	mat.set_shader_parameter(&"desaturate", (CROWD_GREY if common else ELITE_GREY) - d.vivid)
	mat.set_shader_parameter(&"scene_light", CROWD_SCENE_LIGHT)
	mat.set_shader_parameter(&"key", KEY)
	mat.set_shader_parameter(&"key_fill", KEY_FILL)
	mat.set_shader_parameter(&"foot_shade", FOOT_SHADE)
	mat.set_shader_parameter(&"ink", INK)
	mat.set_shader_parameter(&"rim_color", d.rim_color)
	mat.set_shader_parameter(&"rim_power", d.rim * (PAINT_RIM if baked.painted else 1.0))
	if d.rim > 0.0:
		var edge := ShaderMaterial.new()
		edge.shader = OUTLINE
		edge.set_shader_parameter(&"color", OUTLINE_COLOR)
		edge.set_shader_parameter(&"width", OUTLINE_WIDTH)
		edge.set_shader_parameter(&"intensity", OUTLINE_INTENSITY)
		mat.next_pass = edge
	_materials[d.id] = mat
	_batches[d.id] = {}


func begin() -> void:
	for b in _used:
		b.count = 0
	_used.clear()
	_shadow.count = 0
	_used.append(_shadow)
	_bars.count = 0
	_used.append(_bars)


## One character: kind, animation, seconds into it, where it stands, which way it faces (radians around Y),
## and its state (r flash, g frost, b burn, a dissolve).
## squash: scale on top of the def's size (a blow flattens and widens). tilt: tumbling backwards, in radians.
## lean: tipped to its side, in radians (an unsteady runner's sway).
func add(d: EnemyDef, anim: StringName, t: float, pos: Vector3, yaw: float, state: Color, squash := Vector3.ONE, tilt := 0.0, lean := 0.0) -> void:
	var m := model(d.model)
	if m.frame_count(anim) == 0:
		anim = &"walk" if anim != &"idle" and m.frame_count(&"walk") > 0 else &"idle"
	var b := _batch(d, anim, m.frame_at(anim, t))
	if b.count == 0:
		_used.append(b)
	var s := d.size
	var basis := Basis(Vector3.UP, yaw)
	if tilt != 0.0:
		basis = basis * Basis(Vector3.RIGHT, tilt)
	if lean != 0.0:
		basis = basis * Basis(Vector3.BACK, lean)
	_put(b, Transform3D(basis.scaled(squash * s), pos), state)
	if state.a < 0.5:
		var r := d.radius * 2.6 * (1.0 - state.a) / maxf(1.0 + pos.y * 0.3, 1.0)
		_put(_shadow, Transform3D(Basis().scaled(Vector3(r, 1.0, r)), Vector3(pos.x, 0.03, pos.z)), Color())


## A thin life bar over one enemy's head. top: the top of its head (world). life, armor: what is left (0..1).
## crowded: the floor is full, the bar is drawn thinner and fainter so the bars do not make a grid over the heads.
func add_bar(d: EnemyDef, top: Vector3, life: float, armor: float, crowded := false) -> void:
	var w := maxf(BAR_MIN_WIDTH, d.radius * BAR_WIDTH)
	_put(_bars, Transform3D(Basis().scaled(Vector3(w, BAR_HEIGHT * (BAR_CROWD_HEIGHT if crowded else 1.0), 1.0)), top + Vector3(0, BAR_ABOVE, 0)),
		Color(clampf(life, 0.0, 1.0), clampf(armor, 0.0, 1.0), BAR_CROWD_FADE if crowded else 1.0, 0))


## The state of one character for add(), as crowd.gdshader reads it. flash: 0..1 (how white the blow left it);
## absorbed: the blow landed on armor (a gleam of old gold instead); tell: 0..1 of its wind-up; broken: its armor is gone.
static func state(flash: float, frozen: bool, burning: bool, dissolve := 0.0, absorbed := false, tell := 0.0, broken := false) -> Color:
	return Color(-flash if absorbed else flash, (1.0 if frozen else 0.0) + (0.5 if broken else 0.0),
		(1.0 if burning else 0.0) + 0.5 * clampf(tell, 0.0, 1.0), dissolve)


## What the shader reads back from a state: [flash, absorbed, frost, armored, burn, tell] (the same arithmetic as
## crowd.gdshader, kept beside the packing so a test holds the two together).
static func unpack(s: Color) -> Array[float]:
	var frost := 1.0 if s.g >= 0.75 else 0.0
	var burn := 1.0 if s.b >= 0.75 else 0.0
	return [maxf(s.r, 0.0), maxf(-s.r, 0.0), frost, 1.0 - clampf((s.g - frost) * 2.0, 0.0, 1.0), burn, clampf((s.b - burn) * 2.0, 0.0, 1.0)]


func commit() -> void:
	for b in _all_batches():
		var mm := b.mmi.multimesh
		if b.count == 0:
			b.mmi.visible = false
			continue
		b.mmi.visible = true
		mm.buffer = b.data
		mm.visible_instance_count = b.count


func _put(b: Batch, xf: Transform3D, state: Color) -> void:
	if b.count >= b.capacity:
		b.capacity = maxi(32, b.capacity * 2)
		b.data.resize(b.capacity * FLOATS if b.mmi.multimesh.use_custom_data else b.capacity * 12)
		b.mmi.multimesh.instance_count = b.capacity
	var per := FLOATS if b.mmi.multimesh.use_custom_data else 12
	var o := b.count * per
	var d := b.data
	var x := xf.basis.x
	var y := xf.basis.y
	var z := xf.basis.z
	d[o] = x.x; d[o + 1] = y.x; d[o + 2] = z.x; d[o + 3] = xf.origin.x
	d[o + 4] = x.y; d[o + 5] = y.y; d[o + 6] = z.y; d[o + 7] = xf.origin.y
	d[o + 8] = x.z; d[o + 9] = y.z; d[o + 10] = z.z; d[o + 11] = xf.origin.z
	if per == FLOATS:
		d[o + 12] = state.r; d[o + 13] = state.g; d[o + 14] = state.b; d[o + 15] = state.a
	b.count += 1


func _batch(d: EnemyDef, anim: StringName, frame: int) -> Batch:
	var by_anim: Dictionary = _batches[d.id]
	if not by_anim.has(anim):
		var frames: Array = model(d.model).anims[anim]
		var arr: Array[Batch] = []
		arr.resize(frames.size())
		by_anim[anim] = arr
	var arr: Array[Batch] = by_anim[anim]
	if arr[frame] == null:
		arr[frame] = _new_batch(model(d.model).anims[anim][frame], _materials[d.id], true)
	return arr[frame]


func _new_batch(mesh: Mesh, mat: Material, custom: bool) -> Batch:
	var b := Batch.new()
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.use_custom_data = custom
	mm.mesh = mesh
	b.mmi = MultiMeshInstance3D.new()
	b.mmi.multimesh = mm
	if mat:
		b.mmi.material_override = mat
	b.mmi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	b.mmi.layers = layers
	b.mmi.visible = false
	# the batches move every frame; a huge box keeps them from being culled by stale bounds
	b.mmi.custom_aabb = AABB(Vector3(-200, -10, -200), Vector3(400, 60, 400))
	add_child(b.mmi)
	return b


func _all_batches() -> Array[Batch]:
	var out: Array[Batch] = [_shadow, _bars]
	for id: StringName in _batches:
		for anim: StringName in _batches[id]:
			for b: Batch in _batches[id][anim]:
				if b != null:
					out.append(b)
	return out
