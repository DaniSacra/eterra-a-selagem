class_name CrowdRenderer
extends Node3D
## Draws hundreds of characters from baked poses: one MultiMesh per (kind of enemy, animation), plus one MultiMesh of
## soft round shadows. Each frame: begin(), add() once per character, commit(). E1a (VX-04): the poses are a vertex
## animation (BakedModel), and each character is drawn between two of them (its instance colour: pose, next pose,
## share; crowd_pose.gdshaderinc), never jumping from one to the next (until then, one MultiMesh per frame).

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
## Eterra Stylized (STY-06, T20, docs/art/stylized_spec.md 2.3): every figure gets the shell, 0.04 m of near-black warm
## ink (1.6 px at 1080 at the game's camera); the classic look keeps the numbers above, and no shell on the commons.
const STYLE_OUTLINE_WIDTH := 0.04
const STYLE_OUTLINE_COLOR := Color(0.07, 0.06, 0.06)
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
## C17, QW-104: at the end of a wind-up's hold the body clears to this share of a blow's flash (crowd.gdshader
## `tell_light`), warm, never past `flash_cap` (under the glow's threshold).
const TELL_LIGHT := 0.5


## How far the body has cleared at this point of its wind-up (0..1 of `tell`), the crowd.gdshader `ready` without
## TELL_LIGHT: nothing before the hold (the last `hold` share), all of it as the blow comes.
static func tell_ready(tell: float, hold: float) -> float:
	return smoothstep(1.0 - clampf(hold, 0.05, 1.0), 1.0, clampf(tell, 0.0, 1.0))
## With many enemies on the floor (more than Horde.BARS_FOR_ALL) the life bars thin out: opacity and height.
const BAR_CROWD_FADE := 0.7
const BAR_CROWD_HEIGHT := 0.75
const OUTLINE := preload("res://assets/shaders/crowd_outline.gdshader")
const FLOATS := 16  # 12 for the transform, 4 for the custom state
## A posed figure's instance: 12 for the transform, 4 for the colour (which poses, how far between), 4 for the state.
const POSED := 20
const SHADER := preload("res://assets/shaders/crowd.gdshader")
const BAR := preload("res://assets/shaders/life_bar.gdshader")
## The thin life bar over enemies' heads (Hades II): meters wide per meter of the enemy's radius, meters tall,
## and how far above the head (its middle). Cycle 8 (4 to 20 enemies a room, each one read on its own): a little
## taller, and an armored bar grows down by BAR_ARMOR_HEIGHT for the armor's own strip on top, so the armor never
## covers the life; its top edge stays where the plain bar's is (the damage numbers start clear of it).
const BAR_WIDTH := 2.2
const BAR_MIN_WIDTH := 1.1
const BAR_HEIGHT := 0.18
const BAR_ARMOR_HEIGHT := 0.09
const BAR_ABOVE := 0.35
## Bars are drawn over everything, so where two overlap the one nearer the camera is drawn last, whole (sorted when
## there are at most this many: every room of the game; the stress tests skip it).
const BAR_SORT_MAX := 48
## An elite's bar: the frame in old gold (it still says "elite" once the armor is gone) and this much wider.
const BAR_ELITE_WIDTH := 1.15
## The HUD's old gold (UiKit.OLD_GOLD; not named here: the labs draw the crowd without the game's autoloads).
const BAR_ELITE_FRAME := Color("8e7444")

class Batch:
	var mmi: MultiMeshInstance3D
	var mm: MultiMesh
	var data := PackedFloat32Array()
	var count := 0
	var capacity := 0
	## Floats per instance: POSED with the poses and the custom state, FLOATS with the state only, 12 with neither.
	var per := FLOATS

## One animation of one kind of enemy, looked up once: its batch (made when first drawn) and its timing
## (BakedModel.blend_at's numbers), so add() costs no dictionary walk per character.
class Clip:
	var batch: Batch
	## Row of its first pose in the model's pose images, how many poses, poses a second, and whether it loops.
	var first := 0
	var frames := 0
	var rate := 10.0
	var loops := false

## What drawing one kind of enemy needs (render() asks for it for each of hundreds of characters every frame).
class Kind:
	var model: BakedModel
	var material: Material
	## Requested animation -> Clip (an animation the model lacks resolves as add() always did: walk, else idle).
	var clips: Dictionary = {}
	## Seconds of the attack clip, and whether the figure has a braced pose.
	var attack_time := 0.0
	var has_brace := false
	## E1c: it has a wind-up clip of its own (its attack clip starts where that one stops: Horde.render), and the
	## seconds of its hit pose (stretched over a stun).
	var has_windup := false
	var hit_time := 0.0
	## Meters a second the floor runs under its planted foot when the walk plays at its own pace, at size 1
	## (BakedModel.ground_speed; 0: not measured, Horde.walk_rate falls back to its old pace).
	var ground := 0.0

## Visual layers of everything drawn here (torches skip the crowd's layer).
var layers := 1
var _models: Dictionary = {}  # model id -> BakedModel
var _materials: Dictionary = {}  # enemy id -> ShaderMaterial
var _kinds: Dictionary = {}  # enemy id -> Kind
## Batches with something to draw this frame, and the ones shown last frame (hidden when they go unused).
var _used: Array[Batch] = []
var _shown: Array[Batch] = []
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
	bar_mat.set_shader_parameter(&"elite_frame", BAR_ELITE_FRAME)
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
	# QW-104: the body clears in the hold of its own wind-up (its windup_hold share), to TELL_LIGHT of the flash
	mat.set_shader_parameter(&"tell_hold", clampf(d.windup_hold, 0.05, 1.0))
	mat.set_shader_parameter(&"tell_light", TELL_LIGHT)
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
	_set_poses(mat, baked)
	var edge := ShaderMaterial.new()
	edge.shader = OUTLINE
	edge.set_shader_parameter(&"color", OUTLINE_COLOR)
	edge.set_shader_parameter(&"width", OUTLINE_WIDTH)
	edge.set_shader_parameter(&"intensity", OUTLINE_INTENSITY)
	edge.set_shader_parameter(&"style_width", STYLE_OUTLINE_WIDTH)
	edge.set_shader_parameter(&"style_color", STYLE_OUTLINE_COLOR)
	_set_poses(edge, baked)
	# elites and the boss always have the shell; every figure has it in the stylized look (F7 flips it live)
	if d.rim > 0.0:
		mat.next_pass = edge
	else:
		VisualProfile.vary(mat, {&"next_pass": edge})
	_materials[d.id] = mat
	var kind := Kind.new()
	kind.model = baked
	kind.material = mat
	kind.attack_time = baked.duration(&"attack")
	kind.has_brace = baked.frame_count(&"brace") > 0
	kind.has_windup = baked.frame_count(&"windup") > 0
	kind.hit_time = baked.duration(&"hit")
	kind.ground = float(baked.ground_speed.get(&"walk", 0.0))
	_kinds[d.id] = kind


## The model's poses on a material of the crowd (crowd_pose.gdshaderinc).
static func _set_poses(mat: ShaderMaterial, baked: BakedModel) -> void:
	var tex := baked.pose_textures()
	mat.set_shader_parameter(&"pose_positions", tex[0])
	mat.set_shader_parameter(&"pose_normals", tex[1])
	mat.set_shader_parameter(&"pose_vertices", baked.vertices)
	mat.set_shader_parameter(&"pose_width", BakedModel.WIDTH)


## The cached look of a registered kind of enemy (register() first).
func kind(d: EnemyDef) -> Kind:
	return _kinds[d.id]


func _clip(k: Kind, anim: StringName) -> Clip:
	var c: Clip = k.clips.get(anim)
	if c == null:
		var m := k.model
		var shown := anim
		if m.frame_count(shown) == 0:
			shown = &"walk" if shown != &"idle" and m.frame_count(&"walk") > 0 else &"idle"
		c = k.clips.get(shown) if shown != anim else null
		if c == null:
			c = Clip.new()
			c.first = int(m.first.get(shown, 0))
			c.frames = m.frame_count(shown)
			c.rate = m.pose_rate(shown)
			c.loops = m.loops.get(shown, false)
			k.clips[shown] = c
		k.clips[anim] = c
	return c


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
	add_kind(_kinds[d.id], d, anim, t, pos, yaw, state, squash, tilt, lean)


## add() with the kind already looked up (Horde.render: once per character, not once per question).
## from_row and fade (E1c, a figure whose clip just changed): it is drawn from the pose row it showed last (from_row)
## toward the new clip's pose by `fade` (0..1), not cut from one to the other. Returns the pose row it shows now (the
## nearest of its blend), for the next change; -1 when nothing was drawn.
func add_kind(k: Kind, d: EnemyDef, anim: StringName, t: float, pos: Vector3, yaw: float, state: Color, squash := Vector3.ONE, tilt := 0.0, lean := 0.0, from_row := -1, fade := 1.0) -> int:
	var c := _clip(k, anim)
	# BakedModel.blend_at
	var n := c.frames
	if n == 0:
		# a clip with no poses: draw nothing rather than `% 0`, which crashes an exported game
		return -1
	var p := t * c.rate
	var a := 0
	var next := 0
	if c.loops:
		p = fposmod(p, float(n))
		a = mini(int(p), n - 1)
		next = (a + 1) % n
	else:
		p = clampf(p, 0.0, float(n - 1))
		a = mini(int(p), n - 1)
		next = mini(a + 1, n - 1)
	var b := c.batch
	if b == null:
		b = _new_batch(k.model.mesh, k.material, true, true)
		c.batch = b
	if b.count == 0:
		_used.append(b)
	var basis := Basis(Vector3.UP, yaw)
	if tilt != 0.0:
		basis = basis * Basis(Vector3.RIGHT, tilt)
	if lean != 0.0:
		basis = basis * Basis(Vector3.BACK, lean)
	basis = basis.scaled(squash * d.size)
	var row := c.first + (a if p - a < 0.5 else next)
	if from_row >= 0 and fade < 1.0:
		# T5b P1-3: toward the new clip's own blend (its pose a and the next by p - a), not its nearest pose, which
		# stepped from pose to pose through the fade (up to 0.55 m in a frame on Morvath)
		_put(b, basis.x, basis.y, basis.z, pos, state, Color(from_row, c.first + a, clampf(fade, 0.0, 1.0), fade_target(a, next, p - a, n)))
		row = from_row if fade < 0.5 else row
	else:
		_put(b, basis.x, basis.y, basis.z, pos, state, Color(c.first + a, c.first + next, p - a, 1.0))
	if state.a < 0.5:
		var r := d.radius * 2.6 * (1.0 - state.a) / maxf(1.0 + pos.y * 0.3, 1.0)
		_put(_shadow, Vector3(r, 0, 0), Vector3.UP, Vector3(0, 0, r), Vector3(pos.x, 0.03, pos.z), Color())
	return row


## T5b P1-3: the alpha of a fading instance's colour (crowd_pose.gdshaderinc reads it when negative): the new clip's
## pose `a` blends toward `next` by `frac`. -(1 + frac): the next pose of the clip; -2: none (a one-shot's last pose);
## -(2 + n + frac): a loop of n poses back to its first. On the Compatibility renderer the instance colour is a half
## float (11 bits): frac stays a step of it under 1 (a multiple of it), so it never rounds up to the next code.
static func fade_target(a: int, next: int, frac: float, n: int) -> float:
	if next == a:
		return -2.0
	var whole := 1.0 if next == a + 1 else 2.0 + n
	var quantum := pow(2.0, floorf(log(whole + 1.0) / log(2.0)) - 10.0)
	return -(whole + clampf(frac, 0.0, 1.0 - quantum))


## The inverse of fade_target as the shader reads it: [step to the next pose (1, 0 or 1 - n), frac].
static func fade_pick(code: float) -> Array:
	var x := -code
	var whole := int(floorf(x))
	var f := x - whole
	var step := 1 if whole == 1 else 0 if whole == 2 else 3 - whole
	return [step, f]


## A thin life bar over one enemy's head. top: the top of its head (world). life, armor: what is left (0..1).
## crowded: the floor is full, the bar is drawn thinner and fainter so the bars do not make a grid over the heads.
## trail: where the pale trail of a recent loss ends (BarTrails; <= life for none).
func add_bar(d: EnemyDef, top: Vector3, life: float, armor: float, crowded := false, trail := 0.0) -> void:
	var w := maxf(BAR_MIN_WIDTH, d.radius * BAR_WIDTH) * (BAR_ELITE_WIDTH if d.elite else 1.0)
	var h := BAR_HEIGHT * (BAR_CROWD_HEIGHT if crowded else 1.0)
	var at := top + Vector3(0, BAR_ABOVE, 0)
	if armor > 0.0:
		var extra := BAR_ARMOR_HEIGHT * (BAR_CROWD_HEIGHT if crowded else 1.0)
		h += extra
		at.y -= extra * 0.5
	life = clampf(life, 0.0, 1.0)
	_put(_bars, Vector3(w, 0, 0), Vector3(0, h, 0), Vector3.BACK, at,
		Color(life, clampf(armor, 0.0, 1.0), (BAR_CROWD_FADE if crowded else 1.0) + (2.0 if d.elite else 0.0), maxf(life, clampf(trail, 0.0, 1.0))))


## Orders this frame's bars from the farthest to the nearest along the camera's view (forward: where it looks).
func sort_bars(forward: Vector3) -> void:
	var n := _bars.count
	var per := _bars.per
	var src := _bars.data
	var order: Array[Vector2] = []
	for i in n:
		var o := i * per
		order.append(Vector2(-(src[o + 3] * forward.x + src[o + 7] * forward.y + src[o + 11] * forward.z), i))
	order.sort()
	var out := src.duplicate()
	for k in n:
		var from := int(order[k].y) * per
		for f in per:
			out[k * per + f] = src[from + f]
	_bars.data = out


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
	var cam := get_viewport().get_camera_3d() if is_inside_tree() else null
	if cam and _bars.count > 1 and _bars.count <= BAR_SORT_MAX:
		sort_bars(-cam.global_basis.z)
	# what was shown last frame and has nothing now goes (begin() set its count to 0); only those are touched
	for b in _shown:
		if b.count == 0:
			b.mmi.visible = false
	for b in _used:
		if b.count == 0:
			b.mmi.visible = false
			continue
		b.mmi.visible = true
		b.mm.buffer = b.data
		b.mm.visible_instance_count = b.count
	_shown.assign(_used)


## One instance: the columns of its basis, where it stands, its state (custom data, when the batch has it) and its
## poses (the colour, when the batch has it).
func _put(b: Batch, x: Vector3, y: Vector3, z: Vector3, at: Vector3, state: Color, poses := Color()) -> void:
	if b.count >= b.capacity:
		b.capacity = maxi(32, b.capacity * 2)
		b.data.resize(b.capacity * b.per)
		b.mm.instance_count = b.capacity
	var o := b.count * b.per
	var d := b.data
	d[o] = x.x; d[o + 1] = y.x; d[o + 2] = z.x; d[o + 3] = at.x
	d[o + 4] = x.y; d[o + 5] = y.y; d[o + 6] = z.y; d[o + 7] = at.y
	d[o + 8] = x.z; d[o + 9] = y.z; d[o + 10] = z.z; d[o + 11] = at.z
	if b.per == POSED:
		d[o + 12] = poses.r; d[o + 13] = poses.g; d[o + 14] = poses.b; d[o + 15] = poses.a
		d[o + 16] = state.r; d[o + 17] = state.g; d[o + 18] = state.b; d[o + 19] = state.a
	elif b.per == FLOATS:
		d[o + 12] = state.r; d[o + 13] = state.g; d[o + 14] = state.b; d[o + 15] = state.a
	b.count += 1


## colors: the instances carry their poses (a posed figure of the crowd).
func _new_batch(mesh: Mesh, mat: Material, custom: bool, colors := false) -> Batch:
	var b := Batch.new()
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.use_colors = colors
	mm.use_custom_data = custom
	mm.mesh = mesh
	b.mm = mm
	b.per = (POSED if colors else FLOATS) if custom else 12
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
