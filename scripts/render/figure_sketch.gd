class_name FigureSketch
extends RefCounted
## The Compêndio's enemy drawn in ink on the Livro's paper (AP-4, ART-07.4, spec docs/art/ap4_spec.md 2.1): the figure's
## own baked model (no AI) in three passes over the page, see-through between the lines: depth only
## (figure_sketch.gdshader), the contour (figure_sketch_edge.gdshader) and the lines inside, creases, hatching in the
## shade, a wash where its paint is dark (eye sockets, belts) and the paper tinted over the whole body, an elite's steel
## washed in the Livro's gilt (figure_sketch_ink.gdshader); under the feet a few level strokes of ink, not a shade
## (figure_sketch_ground.gdshader; the CrowdRenderer's round shade is off: the paper has no floor).
## For a CrowdRenderer of one figure standing at its origin (FigureView), after register(def):
##   FigureSketch.apply(renderer, def, Book.INK, view_px)       # the drawing and the strokes under the feet
##   var t := FigureSketch.pose_time(model, &"idle")              # the idle time that shows its weapon from the side
##   FigureSketch.fit(camera, def, model, &"idle", aspect)         # orthographic camera framing every pose, 4% margin
##   renderer.add_kind(kind, def, &"idle", t, Vector3.ZERO, FigureSketch.yaw(model), ...)
## (the three-quarter view: VIEW_YAW to the side where the weapon shows longer, the camera PITCH down).

const DEPTH := preload("res://assets/shaders/figure_sketch.gdshader")
const EDGE := preload("res://assets/shaders/figure_sketch_edge.gdshader")
const LINES := preload("res://assets/shaders/figure_sketch_ink.gdshader")
const GROUND := preload("res://assets/shaders/figure_sketch_ground.gdshader")
## The contour, in metres of the figure at size 1 (a skeleton's is about 2 m tall).
const EDGE_WIDTH := 0.025
## Hatching strokes this many pixels apart at 1080 lines (scaled by the view's height), never under HATCH_MIN.
const HATCH_PX := 5.0
const HATCH_MIN := 3.0
## The three-quarter view: the figure turned this far to the right of the screen, the camera this far down.
const VIEW_YAW := 30.0
const PITCH := 12.0
## Air around every pose of the clip shown, a share of the frame's height.
const MARGIN := 0.04
## The strokes under the feet: across this share of the feet's width; (left, right, height) in the quad's UV, the longest
## under the foot it stands on (the left one on the screen in the idle of every figure here), ALPHA, 1 px at 1080.
const GROUND_SPAN := 0.7
const GROUND_STROKES: Array[Vector3] = [Vector3(0.0, 0.78, 0.15), Vector3(0.12, 1.0, 0.42), Vector3(0.3, 0.86, 0.7),
	Vector3(0.05, 0.5, 0.95)]
const GROUND_ALPHA := 0.5
## The quad of the strokes: this tall against the figure's height, from the soles down.
const GROUND_DEPTH := 0.05
## The most saturation the lines keep (the Livro's ink is 0.56).
const INK_SAT := 0.32
## Parts that are weapons (BakedModel.parts and marks), for the pose that shows one.
const WEAPONS := ["sword", "staff", "crossbow", "shield", "orb"]


## The turn of the three-quarter view: VIEW_YAW to the right of the screen, or to the left when the figure's weapon
## shows longer that way (a blade held towards the camera, the skeleton's); the same for every pose of the clip.
static func yaw(baked: BakedModel = null, clip: StringName = &"idle") -> float:
	var right := deg_to_rad(VIEW_YAW)
	if baked == null:
		return right
	var key := "%d:%s" % [baked.get_instance_id(), clip]
	if not _sides.has(key):
		_sides[key] = right if _weapon_reach(baked, clip, right).x >= _weapon_reach(baked, clip, -right).x else -right
	return _sides[key]


static var _sides := {}


## The longest the weapon shows on the screen over the clip turned by yaw_rad, and the pose where it does (x, frame).
static func _weapon_reach(baked: BakedModel, clip: StringName, yaw_rad: float) -> Vector2:
	var weapon: Array = []
	for name: String in WEAPONS:
		weapon.append_array(baked.parts.get(name, []))
		weapon.append_array(baked.marks.get(name, []))
	var frames := baked.frame_count(clip)
	if weapon.is_empty() or frames == 0:
		return Vector2.ZERO
	var turn := Basis(Vector3.UP, yaw_rad)
	var best := Vector2(-1.0, 0.0)
	for f in frames:
		var box := Rect2()
		var first := true
		for i in range(0, weapon.size(), maxi(1, weapon.size() / 200)):
			var sp := _on_screen(baked.position(clip, f, int(weapon[i])), turn)
			if first:
				box = Rect2(sp, Vector2.ZERO)
				first = false
			else:
				box = box.expand(sp)
		if box.size.length() > best.x:
			best = Vector2(box.size.length(), f)
	return best


## The three passes for a baked figure, chained (depth, contour, lines). `gild`: the EnemyDef's (elites).
static func material(baked: BakedModel, ink: Color = Color(0.16, 0.11, 0.07), view_px: float = 1080.0, gild := 0.0) -> ShaderMaterial:
	# the lines a little less saturated than the Livro's ink (INK_SAT): where an anti-aliased line meets the paper it
	# stays brown-grey, so only an elite's gilt reads as gold on the page
	ink = Color.from_hsv(ink.h, minf(ink.s, INK_SAT), ink.v)
	var depth := ShaderMaterial.new()
	depth.shader = DEPTH
	depth.render_priority = -2
	var edge := ShaderMaterial.new()
	edge.shader = EDGE
	edge.render_priority = -1
	edge.set_shader_parameter(&"ink", Vector3(ink.r, ink.g, ink.b))
	edge.set_shader_parameter(&"width", EDGE_WIDTH)
	var lines := ShaderMaterial.new()
	lines.shader = LINES
	lines.render_priority = 0
	lines.set_shader_parameter(&"ink", Vector3(ink.r, ink.g, ink.b))
	lines.set_shader_parameter(&"gilt", Vector3(Book.GILT.r, Book.GILT.g, Book.GILT.b))
	lines.set_shader_parameter(&"gild", 1.0 if gild > 0.0 else 0.0)
	lines.set_shader_parameter(&"albedo", baked.albedo)
	lines.set_shader_parameter(&"glow_from", baked.glow_from)
	lines.set_shader_parameter(&"hatch_px", maxf(HATCH_MIN, HATCH_PX * view_px / 1080.0))
	for m: ShaderMaterial in [depth, edge, lines]:
		CrowdRenderer._set_poses(m, baked)
	depth.next_pass = edge
	edge.next_pass = lines
	return depth


## Turns a CrowdRenderer's registered kind into the drawing (before its first add_kind), takes away the round shade
## under the feet and puts the strokes there (a child of the renderer, under a figure at its origin).
static func apply(renderer: CrowdRenderer, d: EnemyDef, ink: Color = Color(0.16, 0.11, 0.07), view_px: float = 1080.0) -> void:
	var k := renderer.kind(d)
	k.material = material(k.model, ink, view_px, d.gild)
	renderer.ground_shade = false
	var old := renderer.get_node_or_null(^"SketchGround")
	if old != null:
		old.free()
	renderer.add_child(ground(k.model, d, ink, view_px))


## The level strokes under the feet of a figure at the origin, in the three-quarter view.
static func ground(baked: BakedModel, d: EnemyDef, ink: Color = Color(0.16, 0.11, 0.07), view_px: float = 1080.0) -> MeshInstance3D:
	var feet := feet_span(baked, &"idle") * d.size
	var h := baked.height * d.size
	var quad := QuadMesh.new()
	quad.size = Vector2(feet.y - feet.x, h * GROUND_DEPTH) * Vector2(GROUND_SPAN, 1.0)
	var m := ShaderMaterial.new()
	m.shader = GROUND
	m.render_priority = 1
	m.set_shader_parameter(&"ink", Vector3(ink.r, ink.g, ink.b))
	m.set_shader_parameter(&"alpha", GROUND_ALPHA)
	m.set_shader_parameter(&"line_px", maxf(1.0, view_px / 1080.0))
	m.set_shader_parameter(&"count", GROUND_STROKES.size())
	m.set_shader_parameter(&"strokes", PackedVector3Array(GROUND_STROKES))
	var mi := MeshInstance3D.new()
	mi.name = "SketchGround"
	mi.mesh = quad
	mi.material_override = m
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	# its top at the soles, its middle under the middle of the feet on the screen
	mi.position = right() * (feet.x + feet.y) * 0.5 + up() * (-quad.size.y * 0.5)
	return mi


## The camera's right and up in the world, for the three-quarter view (looking down PITCH degrees along -z).
static func right() -> Vector3:
	return Vector3.RIGHT


static func up() -> Vector3:
	var p := deg_to_rad(PITCH)
	return Vector3(0.0, cos(p), -sin(p))


static func _back() -> Vector3:
	var p := deg_to_rad(PITCH)
	return Vector3(0.0, sin(p), cos(p))


## A vertex of the baked figure (size 1) turned by the view, on the screen plane (metres): x right, y up.
static func _on_screen(v: Vector3, turn: Basis) -> Vector2:
	var w := turn * v
	return Vector2(w.dot(right()), w.dot(up()))


## The left and right of the feet on the screen (size 1), from the lowest tenth of the figure in the clip's first pose.
static func feet_span(baked: BakedModel, clip: StringName) -> Vector2:
	var turn := Basis(Vector3.UP, yaw(baked, clip))
	var pose := baked.pose(clip, 0)
	var lo := INF
	var hi := -INF
	for v in range(0, pose.size(), 3):
		if pose[v].y < baked.height * 0.1:
			var s := _on_screen(pose[v], turn)
			lo = minf(lo, s.x)
			hi = maxf(hi, s.x)
	if lo > hi:
		return Vector2(-0.3, 0.3)
	return Vector2(lo, hi)


## The seconds into the clip whose pose shows the weapon longest on the screen in the three-quarter view (0 when the
## figure carries no named weapon).
static func pose_time(baked: BakedModel, clip: StringName) -> float:
	var best := _weapon_reach(baked, clip, yaw(baked, clip))
	return best.y / maxf(baked.pose_rate(clip), 0.001)


## The box of every pose of the clip on the screen plane (metres, size 1), the weapon included.
static func clip_box(baked: BakedModel, clip: StringName) -> Rect2:
	var turn := Basis(Vector3.UP, yaw(baked, clip))
	var box := Rect2()
	var first := true
	for f in maxi(1, baked.frame_count(clip)):
		for v in baked.vertices:
			var s := _on_screen(baked.position(clip, f, v), turn)
			if first:
				box = Rect2(s, Vector2.ZERO)
				first = false
			else:
				box = box.expand(s)
	return box


## Points an orthographic camera (keep height) at every pose of the clip with MARGIN of the frame's height all round.
static func fit(cam: Camera3D, d: EnemyDef, baked: BakedModel, clip: StringName, aspect: float) -> void:
	var box := clip_box(baked, clip)
	box = Rect2(box.position * d.size, box.size * d.size)
	# the contour drawn outside the body, and the strokes under the feet
	box = box.grow(EDGE_WIDTH * d.size)
	var below := baked.height * d.size * GROUND_DEPTH
	box = box.expand(box.position + Vector2(0.0, -below))
	var need := maxf(box.size.y, box.size.x / maxf(aspect, 0.01))
	cam.projection = Camera3D.PROJECTION_ORTHOGONAL
	cam.keep_aspect = Camera3D.KEEP_HEIGHT
	cam.size = need / (1.0 - 2.0 * MARGIN)
	cam.rotation_degrees = Vector3(-PITCH, 0.0, 0.0)
	var mid := box.get_center()
	cam.position = right() * mid.x + up() * mid.y + _back() * 10.0
