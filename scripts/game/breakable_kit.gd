class_name BreakableKit
## The things that break, drawn (AT-Q2; docs/art/at_q0_breakables.md sections 2 to 5): BreakFloor calls build for each
## piece whole, crack for a crate's first blow and shatter on the break. Common things of whoever lived there: clay,
## wood, branch; matte, no light of their own, no mark, never the hazards' grammar (no chevron, ember, amber, iron).
## Each piece stands on a soft contact shadow, its top a light lip; the same piece in both looks. Materials are shared
## by colour (one a colour a room), only a cracked crate gets its own. Pieces never collide; shards neither.

## The lip on top of every body (1.25 to 1.45 of the body), the inside of a mouth and a broken shard (one step lighter,
## unpainted clay), the wet band of a water jar, the foot (darker).
const LIP := 1.2
const INSIDE := 1.15
const MOUTH := 0.35
const WET := 0.7
const WET_SPECULAR := 0.25
const FOOT := 0.8
const SPECULAR := 0.12
## The painted band on clay (0.05 m on the shoulder) per room (hue, saturation, value; spec section 3); none in the
## runes and the Câmara do Selo.
const BAND_WIDE := 0.05
const BAND := {
	&"hall": Vector3(195, 0.3, 0.3), &"crypt": Vector3(20, 0.3, 0.25), &"garden": Vector3(40, 0.3, 0.5),
	&"sanctuary": Vector3(38, 0.4, 0.45), &"altar": Vector3(16, 0.35, 0.3), &"trial": Vector3(195, 0.3, 0.3),
	&"": Vector3(195, 0.3, 0.3),
}
const NO_BAND: Array[StringName] = [&"runes", &"seal_chamber"]
## The contact shadow round the foot (0.2 m out of the body) and the wet ring of a water jar (0.6 m, alpha 0.3).
const SHADOW_OUT := 0.2
const SHADOW_ALPHA := 0.32
const WET_RING := 0.6
const WET_RING_ALPHA := 0.3
## Wood: the boards' gap, a board's thickness, the battens, the nail heads (dark, no bright metal).
const BOARD := 0.03
const BOARD_GAP := 0.012
const NAIL := Color(0.06, 0.055, 0.05)
## The sapling's leaves: how many, their size (round and soft), the soil it grows out of.
const LEAVES := 8
const LEAF := 0.07
const SOIL := Color(0.2, 0.16, 0.12)
## A crate's first blow: the front board leans CRACK_LEAN degrees, a dark diagonal split.
const CRACK_LEAN := 2.0
const SPLIT := Color(0.05, 0.045, 0.04)
## The shards: how many by material, how far they land (m, round the piece, away from the blow), the hop (at most
## 0.5 m), the flight, how long they lie (4 s), how far and how fast they sink, then go.
const SHARDS := {Breakables.Stuff.CERAMIC: 8, Breakables.Stuff.WATER: 8, Breakables.Stuff.WOOD: 7,
	Breakables.Stuff.BRANCH: 3}
const LAND := Vector2(0.35, 1.0)
const HOP := 0.45
const FLIGHT := 0.32
const LIE := 4.0
const SINK := 0.05
const SINK_TIME := 0.5
## The water spilled (2.2): a dark stain opening from 0.3 to STAIN m in STAIN_OPEN s, drying from its edge in DRY s.
const STAIN := 1.4
const STAIN_OPEN := 0.25
const DRY := 3.0
const STAIN_COLOR := Color(0.12, 0.13, 0.14)
## The sapling's leaves fall slowly and lie as the garden's fallen leaves.
const LEAF_FALL := 0.9

## GR-22: every body a share darker than the room's data colour (jars read luma 150 to 170 against a floor of 30 to 80).
const BODY_VALUE := 0.72

static var _mats := {}


## A piece whole at its place (the root's children: its body, its shadow).
static func build(p: BreakablePiece, color_: Color, room: StringName) -> Node3D:
	var color := color_ * BODY_VALUE
	var root := Node3D.new()
	root.name = "Breakable"
	root.position = Vector3(p.at.x, 0.0, p.at.y)
	var seed_ := int(p.at.x * 37.0 + p.at.y * 53.0)
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_
	root.rotation.y = rng.randf() * TAU
	var body := Node3D.new()
	body.name = "Body"
	root.add_child(body)
	var h := p.height
	var r := p.radius
	match p.form:
		BreakablePiece.Form.VASE:
			_clay(body, color, room, [Vector2(0.45, 0), Vector2(0.75, 0.15), Vector2(1.0, 0.42), Vector2(0.82, 0.68),
				Vector2(0.38, 0.84), Vector2(0.34, 0.92), Vector2(0.5, 1.0)], r * 0.95, h, 0.68)
		BreakablePiece.Form.URN:
			_clay(body, color, room, [Vector2(0.5, 0), Vector2(0.8, 0.2), Vector2(1.0, 0.6), Vector2(0.95, 0.78),
				Vector2(0.6, 0.9), Vector2(0.62, 0.96)], r * 0.95, h, 0.74)
			_add(body, _lathe([Vector2(0.62, 0.0), Vector2(0.5, 0.05), Vector2(0.12, 0.08), Vector2(0.1, 0.12),
				Vector2(0.0, 0.13)], Vector2(r * 0.95, h)), _mat(color * LIP), Vector3(0, h * 0.96, 0))
		BreakablePiece.Form.OFFERING:
			_clay(body, color, room, [Vector2(0.45, 0), Vector2(0.62, 0.1), Vector2(0.95, 0.42), Vector2(1.0, 0.5)],
				r, h * 0.5, 0.3)
			_clay(body, color.darkened(0.08), room, [Vector2(0.4, 0), Vector2(0.7, 0.25), Vector2(0.6, 0.7),
				Vector2(0.3, 0.85), Vector2(0.38, 1.0)], r * 0.45, h * 0.62, 0.5, Vector3(r * 0.2, h * 0.22, 0))
		BreakablePiece.Form.WATER:
			_clay(body, color, room, [Vector2(0.55, 0), Vector2(0.85, 0.2), Vector2(1.0, 0.5), Vector2(0.9, 0.78),
				Vector2(0.72, 0.9), Vector2(0.8, 1.0)], r * 0.95, h, 0.8)
			var wet := _mat(color * WET)
			wet.metallic_specular = WET_SPECULAR
			wet.roughness = 0.45
			_add(body, _lathe([Vector2(0.56, 0), Vector2(0.86, 0.2), Vector2(1.01, 0.5)], Vector2(r * 0.95, h)), wet)
			_decal(root, WET_RING, STAIN_COLOR, WET_RING_ALPHA)
		BreakablePiece.Form.CRATE:
			_crate(body, color, minf(h, r * 1.5), r * 1.5)
		BreakablePiece.Form.PLANK:
			_planks(body, color, r, h, rng)
		BreakablePiece.Form.BENCH:
			_bench(body, color, r, h)
		BreakablePiece.Form.BRANCH:
			_branches(body, color, h, rng)
		BreakablePiece.Form.SAPLING:
			_sapling(body, color, r, h, rng)
	_decal(root, r + SHADOW_OUT, Color.BLACK, SHADOW_ALPHA)
	return root


## A crate's first blow: its front board leans and a dark split runs across it.
static func crack(piece: Node3D) -> void:
	var front := piece.find_child("Front", true, false) as MeshInstance3D
	if front == null:
		return
	front.rotation_degrees.z += CRACK_LEAN
	var split := MeshInstance3D.new()
	var b := BoxMesh.new()
	var w := (front.mesh as BoxMesh).size
	b.size = Vector3(w.x * 1.1, 0.012, w.z + 0.004)
	split.mesh = b
	split.material_override = _mat(SPLIT)
	split.rotation.z = 0.6
	front.add_child(split)


## The break: the whole piece goes (BreakFloor hides it after its squash) and its shards fly low away from `away`,
## hop once, lie LIE s, sink and go; a water jar's stain opens and dries; a sapling's leaves fall slowly.
static func shatter(parent: Node3D, p: BreakablePiece, color_: Color, away: Vector3) -> void:
	var color := color_ * BODY_VALUE
	var stuff := Breakables.material_of(p.form)
	var rng := RandomNumberGenerator.new()
	rng.seed = int(p.at.x * 91.0 + p.at.y * 29.0)
	var at := Vector3(p.at.x, 0.0, p.at.y)
	var out := Vector2(away.x, away.z).normalized() if Vector2(away.x, away.z).length() > 0.01 else Vector2.RIGHT
	var n: int = SHARDS[stuff]
	var mats := [_mat(color), _mat(color * INSIDE)]
	if p.form == BreakablePiece.Form.SAPLING:
		_leaves_fall(parent, p, color, rng)
		n = 2
	for k in n:
		var mi := MeshInstance3D.new()
		mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		match stuff:
			Breakables.Stuff.WOOD:
				var b := BoxMesh.new()
				b.size = Vector3(rng.randf_range(0.1, 0.3), BOARD, rng.randf_range(0.04, 0.09)) if k > 2 \
					else Vector3(p.radius * 1.3, BOARD, 0.12)
				mi.mesh = b
				mi.material_override = mats[0]
			Breakables.Stuff.BRANCH:
				var c := CylinderMesh.new()
				c.top_radius = 0.02
				c.bottom_radius = 0.03
				c.height = p.height * rng.randf_range(0.3, 0.5)
				c.radial_segments = 5
				c.rings = 1
				mi.mesh = c
				mi.material_override = mats[0]
			_:
				mi.mesh = _shard(rng.randf_range(0.08, 0.14) if k > 0 else p.radius * 0.6, rng)
				mi.material_override = mats[k % 2]
		parent.add_child(mi)
		var dir := out.rotated(rng.randf_range(-1.4, 1.4)) if k % 3 != 2 else out.rotated(rng.randf_range(-3.1, 3.1))
		var land := at + Vector3(dir.x, 0.0, dir.y) * rng.randf_range(LAND.x, LAND.y)
		var lie := Basis(Vector3.UP, rng.randf() * TAU)
		if stuff == Breakables.Stuff.BRANCH:
			lie = lie * Basis(Vector3.RIGHT, PI * 0.5)
		mi.transform = Transform3D(Basis(Vector3(rng.randf(), 1, rng.randf()).normalized(), rng.randf() * TAU),
			at + Vector3(0, p.height * 0.5, 0))
		var tw := mi.create_tween()
		var mid := (at + land) * 0.5 + Vector3(0, minf(HOP, p.height * 0.5 + 0.2), 0)
		tw.tween_property(mi, "position", mid, FLIGHT * 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
		tw.parallel().tween_property(mi, "basis", lie, FLIGHT)
		tw.tween_property(mi, "position", land + Vector3(0, 0.015, 0), FLIGHT * 0.5).set_ease(Tween.EASE_IN) \
			.set_trans(Tween.TRANS_QUAD)
		tw.tween_property(mi, "position", land + Vector3(0, 0.05, 0), 0.06)
		tw.tween_property(mi, "position", land + Vector3(0, 0.015, 0), 0.06)
		tw.tween_interval(LIE)
		tw.tween_property(mi, "position", land + Vector3(0, 0.015 - SINK, 0), SINK_TIME)
		tw.tween_callback(mi.queue_free)
	if p.form == BreakablePiece.Form.WATER:
		_stain(parent, at)


# --- the bodies ------------------------------------------------------------------------------------------------------

## A clay body from `outline` (radius share, height share) to radius r and height h: the body, a light lip on its top,
## the painted band at `band` of the height, the dark mouth, a darker foot.
static func _clay(body: Node3D, color: Color, room: StringName, outline: Array, r: float, h: float, band: float,
		at := Vector3.ZERO) -> void:
	var s := Vector2(r, h)
	_add(body, _lathe(outline, s), _mat(color), at)
	var top: Vector2 = outline[outline.size() - 1]
	_add(body, _ring(top.x * r, top.x * r * 0.82, 0.035), _mat(color * LIP), at + Vector3(0, h - 0.035, 0))
	_add(body, _disc(top.x * r * 0.82), _mat(color * MOUTH), at + Vector3(0, h - 0.04, 0))
	_add(body, _ring(outline[0].x * r * 1.01, outline[0].x * r * 0.5, 0.04), _mat(color * FOOT), at)
	if room in NO_BAND:
		return
	var b: Vector3 = BAND.get(room, BAND[&""])
	var rb := _radius_at(outline, band) * r * 1.012
	_add(body, _ring(rb, rb * 0.97, BAND_WIDE, true), _mat(Color.from_hsv(b.x / 360.0, b.y, b.z)),
		at + Vector3(0, band * h - BAND_WIDE * 0.5, 0))


static func _crate(body: Node3D, color: Color, h: float, w: float) -> void:
	var core := _mat(color * 0.55)
	_add(body, _box(Vector3(w - BOARD * 2.0, h - 0.01, w - BOARD * 2.0)), core, Vector3(0, h * 0.5, 0))
	var boards := 3
	var bh := (h - BOARD_GAP * (boards - 1)) / boards
	for face in 4:
		var yaw := face * PI * 0.5
		var n := Vector3(sin(yaw), 0, cos(yaw))
		for k in boards:
			var mi := _add(body, _box(Vector3(w, bh, BOARD)), _mat(color * (1.0 if k % 2 == 0 else 0.9)),
				n * (w * 0.5 - BOARD * 0.5) + Vector3(0, bh * 0.5 + k * (bh + BOARD_GAP), 0))
			mi.rotation.y = yaw
			if face == 0 and k == 1:
				mi.name = "Front"
		for side: float in [-1.0, 1.0]:
			var bat := _add(body, _box(Vector3(0.07, h, BOARD)), _mat(color * 0.75),
				n * (w * 0.5 + BOARD * 0.4) + Vector3(0, h * 0.5, 0) + n.cross(Vector3.UP) * side * (w * 0.5 - 0.06))
			bat.rotation.y = yaw
			for y: float in [0.12, 0.88]:
				_add(body, _box(Vector3.ONE * 0.022), _mat(NAIL), n * (w * 0.5 + BOARD) + Vector3(0, h * y, 0)
					+ n.cross(Vector3.UP) * side * (w * 0.5 - 0.06))
	_add(body, _box(Vector3(w, BOARD, w)), _mat(color * LIP), Vector3(0, h - BOARD * 0.5, 0))


static func _planks(body: Node3D, color: Color, r: float, h: float, rng: RandomNumberGenerator) -> void:
	var count := 3
	var t := h / count
	for k in count:
		var mi := _add(body, _box(Vector3(r * 2.1, t * 0.9, r * 0.6)), _mat(color * (1.0 - 0.07 * k)),
			Vector3(rng.randf_range(-0.05, 0.05), t * (k + 0.45), rng.randf_range(-0.04, 0.04)))
		mi.rotation.y = rng.randf_range(-0.15, 0.15)
		_add(mi, _box(Vector3(r * 2.1, 0.012, r * 0.6)), _mat(color * LIP), Vector3(0, t * 0.45, 0))


static func _bench(body: Node3D, color: Color, r: float, h: float) -> void:
	var seat := Node3D.new()
	body.add_child(seat)
	seat.position = Vector3(-r * 0.9, 0.0, 0)
	seat.rotation.z = atan2(h * 0.9, r * 1.9)
	_add(seat, _box(Vector3(r * 2.1, 0.06, r * 0.75)), _mat(color), Vector3(r * 1.05, 0.03, 0))
	_add(seat, _box(Vector3(r * 2.1, 0.012, r * 0.75)), _mat(color * LIP), Vector3(r * 1.05, 0.066, 0))
	_add(seat, _box(Vector3(0.02, 0.064, r * 0.5)), _mat(SPLIT), Vector3(r * 1.0, 0.03, 0.02))
	_add(body, _box(Vector3(0.08, h * 0.85, r * 0.6)), _mat(color * 0.8), Vector3(r * 0.8, h * 0.42, 0))
	_add(body, _box(Vector3(0.08, h * 0.25, 0.08)), _mat(color * 0.7), Vector3(-r * 0.4, h * 0.12, r * 0.2)).rotation.z = 0.9


static func _branches(body: Node3D, color: Color, h: float, rng: RandomNumberGenerator) -> void:
	var bark := _mat(color)
	for k in rng.randi_range(3, 5):
		var stick := Node3D.new()
		body.add_child(stick)
		stick.position = Vector3(rng.randf_range(-0.1, 0.1), 0, rng.randf_range(-0.1, 0.1))
		stick.rotation = Vector3(rng.randf_range(-0.25, 0.25), rng.randf() * TAU, rng.randf_range(-0.3, 0.3))
		var l := h * rng.randf_range(0.75, 1.05)
		var y := 0.0
		for part in 3:
			var seg := l / 3.0
			var c := CylinderMesh.new()
			c.top_radius = 0.018 - part * 0.004
			c.bottom_radius = 0.026 - part * 0.004
			c.height = seg
			c.radial_segments = 5
			c.rings = 1
			var mi := _add(stick, c, bark, Vector3(rng.randf_range(-0.03, 0.03), y + seg * 0.5, 0))
			mi.rotation.z = rng.randf_range(-0.25, 0.25)
			y += seg * 0.95
		var twig := CylinderMesh.new()
		twig.top_radius = 0.006
		twig.bottom_radius = 0.012
		twig.height = l * 0.3
		twig.radial_segments = 4
		twig.rings = 1
		_add(stick, twig, bark, Vector3(0.04, l * 0.6, 0)).rotation.z = -0.8


static func _sapling(body: Node3D, color: Color, r: float, h: float, rng: RandomNumberGenerator) -> void:
	_add(body, _lathe([Vector2(1.0, 0), Vector2(0.7, 0.5), Vector2(0.0, 0.8)], Vector2(r * 0.8, 0.1)), _mat(SOIL))
	var stem := CylinderMesh.new()
	stem.top_radius = 0.006
	stem.bottom_radius = 0.014
	stem.height = h * 0.9
	stem.radial_segments = 5
	stem.rings = 1
	var green := color.darkened(0.35)
	_add(body, stem, _mat(green), Vector3(0, h * 0.45, 0)).rotation.z = rng.randf_range(-0.1, 0.1)
	var leaf := SphereMesh.new()
	leaf.radius = LEAF
	leaf.height = LEAF * 0.5
	leaf.radial_segments = 8
	leaf.rings = 3
	for k in LEAVES:
		var a := TAU * k / LEAVES * 2.4
		var y := h * (0.3 + 0.62 * float(k) / LEAVES)
		var reach := 0.06 + 0.1 * (1.0 - float(k) / LEAVES)
		var mi := _add(body, leaf, _mat(color * (1.0 if k % 2 == 0 else 0.88)), Vector3(cos(a) * reach, y, sin(a) * reach))
		mi.rotation = Vector3(rng.randf_range(-0.6, 0.6), a, rng.randf_range(0.2, 0.6))


static func _leaves_fall(parent: Node3D, p: BreakablePiece, color: Color, rng: RandomNumberGenerator) -> void:
	var leaf := SphereMesh.new()
	leaf.radius = LEAF
	leaf.height = LEAF * 0.4
	leaf.radial_segments = 8
	leaf.rings = 3
	var mat := _mat(color)
	for k in LEAVES:
		var mi := MeshInstance3D.new()
		mi.mesh = leaf
		mi.material_override = mat
		mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		parent.add_child(mi)
		var from := Vector3(p.at.x, p.height * rng.randf_range(0.4, 0.9), p.at.y)
		mi.position = from
		var land := from + Vector3(rng.randf_range(-0.5, 0.5), 0, rng.randf_range(-0.5, 0.5))
		land.y = 0.01
		var tw := mi.create_tween()
		tw.tween_property(mi, "position", land, LEAF_FALL * rng.randf_range(0.8, 1.3)).set_trans(Tween.TRANS_SINE)
		tw.parallel().tween_property(mi, "rotation", Vector3(0, rng.randf() * TAU, 0), LEAF_FALL)
		tw.tween_interval(LIE)
		tw.tween_property(mi, "position", land - Vector3(0, SINK, 0), SINK_TIME)
		tw.tween_callback(mi.queue_free)


static func _stain(parent: Node3D, at: Vector3) -> void:
	var mi := MeshInstance3D.new()
	var q := QuadMesh.new()
	q.size = Vector2.ONE * 2.0
	mi.mesh = q
	var m := ShaderMaterial.new()
	m.shader = preload("res://assets/shaders/water_stain.gdshader")
	m.set_shader_parameter(&"color", STAIN_COLOR)
	m.set_shader_parameter(&"seed", at.x * 0.37 + at.z * 0.71)
	mi.material_override = m
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mi.transform = Transform3D(Basis(Vector3.RIGHT, -PI * 0.5).scaled(Vector3.ONE * STAIN), at + Vector3(0, 0.014, 0))
	parent.add_child(mi)
	m.set_shader_parameter(&"open", 0.3 / STAIN)
	m.set_shader_parameter(&"dry", 0.0)
	var tw := mi.create_tween()
	tw.tween_method(func(v: float) -> void: m.set_shader_parameter(&"open", v), 0.3 / STAIN, 1.0, STAIN_OPEN)
	tw.tween_method(func(v: float) -> void: m.set_shader_parameter(&"dry", v), 0.0, 1.0, DRY)
	tw.tween_callback(mi.queue_free)


# --- meshes and materials --------------------------------------------------------------------------------------------

static func _mat(c: Color) -> StandardMaterial3D:
	var key := c.to_html()
	if _mats.has(key):
		return _mats[key]
	var m := StandardMaterial3D.new()
	m.albedo_color = Color(c.r, c.g, c.b)
	m.roughness = 0.95
	m.metallic_specular = SPECULAR
	_mats[key] = m
	return m


static func _add(under: Node3D, mesh: Mesh, mat: Material, at := Vector3.ZERO) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.material_override = mat
	mi.position = at
	under.add_child(mi)
	return mi


static func _box(s: Vector3) -> BoxMesh:
	var b := BoxMesh.new()
	b.size = s
	return b


static func _radius_at(outline: Array, y: float) -> float:
	for i in outline.size() - 1:
		var a: Vector2 = outline[i]
		var b: Vector2 = outline[i + 1]
		if y >= a.y and y <= b.y:
			return lerpf(a.x, b.x, (y - a.y) / maxf(b.y - a.y, 0.0001))
	return (outline[outline.size() - 1] as Vector2).x


## A turned body from `outline` (radius, height shares) scaled by s (radius, height).
static func _lathe(outline: Array, s: Vector2) -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var seg := 14
	for i in outline.size() - 1:
		var a: Vector2 = outline[i] * s
		var b: Vector2 = outline[i + 1] * s
		for k in seg:
			var t0 := TAU * k / seg
			var t1 := TAU * (k + 1) / seg
			var p0 := Vector3(cos(t0) * a.x, a.y, sin(t0) * a.x)
			var p1 := Vector3(cos(t1) * a.x, a.y, sin(t1) * a.x)
			var p2 := Vector3(cos(t1) * b.x, b.y, sin(t1) * b.x)
			var p3 := Vector3(cos(t0) * b.x, b.y, sin(t0) * b.x)
			st.add_vertex(p0)
			st.add_vertex(p1)
			st.add_vertex(p2)
			st.add_vertex(p0)
			st.add_vertex(p2)
			st.add_vertex(p3)
	st.generate_normals()
	return st.commit()


## A ring from outer to inner radius, `h` high (a band with its outer face only when `band`).
static func _ring(outer: float, inner: float, h: float, band := false) -> ArrayMesh:
	if band:
		return _lathe([Vector2(outer, 0.0), Vector2(outer, h)], Vector2.ONE)
	return _lathe([Vector2(outer, 0.0), Vector2(outer, h), Vector2(inner, h)], Vector2.ONE)


static func _disc(r: float) -> ArrayMesh:
	return _lathe([Vector2(r, 0.0), Vector2(0.0, 0.0)], Vector2.ONE)


## A curved shard of clay about `size` across.
static func _shard(size: float, rng: RandomNumberGenerator) -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var corners := 5
	var pts: Array[Vector3] = []
	for k in corners:
		var a := TAU * k / corners + rng.randf_range(-0.3, 0.3)
		var d := size * rng.randf_range(0.5, 1.0)
		pts.append(Vector3(cos(a) * d, 0.04 * sin(a * 0.5) * size / 0.1, sin(a) * d * 0.7))
	for k in corners:
		st.add_vertex(Vector3(0, 0.02, 0))
		st.add_vertex(pts[k])
		st.add_vertex(pts[(k + 1) % corners])
	st.generate_normals()
	return st.commit()


## A soft round decal on the floor, r m, its colour at `alpha` in the middle (contact shadow, wet ring).
static func _decal(root: Node3D, r: float, c: Color, alpha: float) -> void:
	var key := "decal" + c.to_html() + str(alpha)
	var m: ShaderMaterial = _mats.get(key)
	if m == null:
		m = ShaderMaterial.new()
		m.shader = preload("res://assets/shaders/soft_shadow.gdshader")
		m.set_shader_parameter(&"color", c)
		m.set_shader_parameter(&"alpha", alpha)
		_mats[key] = m
	var mi := MeshInstance3D.new()
	var q := QuadMesh.new()
	q.size = Vector2.ONE * r * 2.0
	mi.mesh = q
	mi.material_override = m
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mi.transform = Transform3D(Basis(Vector3.RIGHT, -PI * 0.5), Vector3(0, 0.011, 0))
	root.add_child(mi)
