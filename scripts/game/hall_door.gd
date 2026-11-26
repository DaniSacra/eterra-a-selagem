class_name HallDoor
extends Node3D
## SL-01 (docs/art/ref/sala01_2026-11-25/05-portas.md): one of the two doors in the north wall of the catacomb hall. Two
## leaves of dark wood with iron straps, together a pointed arch, standing closed and solid; only when the way is chosen
## do they swing in (90 degrees, into the doorway's depth) and show the black inside. Never a portal, never stairs.
## Pure visual: the leaves block nothing (the wall is the edge of the floor), the choice and the leaving are Rooms'.

## A leaf's thickness (m), its wood and its iron (dark, matt: nothing glows), the straps' heights as shares of the
## straight part's height and their size (height, how much thicker than the leaf).
const THICK := 0.1
const WOOD := Color(0.085, 0.056, 0.04)
const IRON := Color(0.1, 0.1, 0.115)
const STRAPS: Array[float] = [0.14, 0.4, 0.66, 0.92]
const STRAP := Vector2(0.18, 0.05)
## PT-25-10 (big doors): the planks' battens on each leaf (how many, their width, how much thicker than the leaf), their
## wood, and the ring pull at the meeting stile (radius, tube, height as a share of the spring line).
const BATTENS := 3
const BATTEN := Vector2(0.09, 0.03)
const BATTEN_WOOD := Color(0.06, 0.04, 0.03)
const RING := Vector2(0.14, 0.022)
const RING_AT := 0.5
## What the doorway's black is (nothing glows) and how deep the stone jambs reach back from the wall face.
const BLACK := Color(0.012, 0.012, 0.016)
## How far a leaf swings when it opens (radians) and how long it takes (s).
const OPEN_ANGLE := PI * 0.5
const OPEN_TIME := 0.45
## The points of the arch's half in a polygon (a leaf's top, the black face's cap).
const ARC_STEPS := 8

var is_open := false
var _hinges: Array[Node3D] = []
var _tween: Tween


## A closed door with its middle `at` (on the floor, in the plane of its front), facing south (+z): `span` wide, its
## pointed top `height` over the floor, the arch's radius `arc` times the span (Masonry.voussoir_arch's).
static func make(parent: Node3D, at: Vector3, span: float, height: float, arc: float) -> HallDoor:
	var d := HallDoor.new()
	d.name = "HallDoor"
	d.position = at
	parent.add_child(d)
	d._build(span, height, arc)
	return d


## The whole doorway of a wall (PT-25-10, the hall's and the crypt's): at `at` (the middle of the opening on the wall's
## face, on the floor, the wall facing +z) the stone jambs `frame` wide (stone `order`) lining a recess `depth` deep, a
## threshold, the ring of voussoirs, the black cap and the black face at the back, and the closed leaves standing `out`
## in front of the face. The wall round it is the caller's (it cuts the opening). Returns the door.
static func doorway(m: Masonry, root: Node3D, order: Material, at: Vector3, clear: Vector2, arc: float, frame: float,
		depth: float, out: float) -> HallDoor:
	var hw := clear.x * 0.5
	var spring := spring_of(clear.x, clear.y, arc)
	var zf := at.z
	for sd: float in [-1.0, 1.0]:
		m.block(Vector3(at.x + sd * (hw + frame * 0.5), 0.0, zf + 0.15 - (depth + 0.25) * 0.5),
			Vector3(frame, spring, depth + 0.25 + 0.15), 0.0, order)
	m.block(Vector3(at.x, -0.5, zf + 0.15 - (depth + 0.15) * 0.5), Vector3(clear.x, 0.49, depth + 0.15), 0.0, order)
	m.voussoir_arch(Vector3(at.x, 0.0, zf + out), Vector2(0, 1), clear.x, spring, frame, 0.4, order, arc)
	var black := StandardMaterial3D.new()
	black.albedo_color = BLACK
	black.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	black.cull_mode = BaseMaterial3D.CULL_DISABLED
	var whole := outline(clear.x, clear.y, arc)
	var cap := outline(clear.x, clear.y, arc, false, true)
	for z: float in [zf + out * 0.5, zf - depth]:
		var f := MeshInstance3D.new()
		f.mesh = face(cap if z > zf - 0.5 else whole)
		f.material_override = black
		f.position = Vector3(at.x, 0.0, z)
		f.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		root.add_child(f)
	return make(root, Vector3(at.x, 0.0, zf + out + 0.05), clear.x, clear.y, arc)


## The spring line's height under the pointed top (the arch rises sqrt(r^2 - cx^2) over it).
static func spring_of(span: float, height: float, arc: float) -> float:
	var r := span * arc
	var cx := r - span * 0.5
	return height - sqrt(r * r - cx * cx)


## The outline of the opening from its left foot, round the top to its right foot, as (x, y) from its middle: a
## rectangle up to the spring line with the pointed cap over it. `half` false: the left half only (its foot, the cap's
## left arc, the apex), for a leaf. `cap`: only the pointed cap over the spring line (its feet on that line).
static func outline(span: float, height: float, arc: float, half := false, cap := false) -> PackedVector2Array:
	var r := span * arc
	var cx := r - span * 0.5
	var spring := spring_of(span, height, arc)
	var top := PackedVector2Array()
	if not cap:
		top.append(Vector2(-span * 0.5, 0.0))
	top.append(Vector2(-span * 0.5, spring))
	var skip := top.size()
	var sweep := acos(cx / r)
	for i in range(1, ARC_STEPS + 1):
		var a := sweep * float(i) / ARC_STEPS
		top.append(Vector2(cx - r * cos(a), spring + r * sin(a)))
	if half:
		top.append(Vector2(0.0, 0.0))
		return top
	for i in range(ARC_STEPS - 2, -1, -1):
		var p := top[skip + i]
		top.append(Vector2(-p.x, p.y))
	top.append(Vector2(span * 0.5, spring))
	if not cap:
		top.append(Vector2(span * 0.5, 0.0))
	return top


## A flat polygon (x, y) as a mesh facing +z at depth z, fanned from its first point (convex outlines only).
static func face(points: PackedVector2Array, z := 0.0) -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_normal(Vector3.BACK)
	for i in range(1, points.size() - 1):
		for p: Vector2 in [points[0], points[i], points[i + 1]]:
			st.add_vertex(Vector3(p.x, p.y, z))
	return st.commit()


func _build(span: float, height: float, arc: float) -> void:
	var half := span * 0.5
	var spring := spring_of(span, height, arc)
	var wood := StandardMaterial3D.new()
	wood.albedo_color = WOOD
	wood.roughness = 0.9
	wood.cull_mode = BaseMaterial3D.CULL_DISABLED
	var iron := StandardMaterial3D.new()
	iron.albedo_color = IRON
	iron.roughness = 0.6
	iron.metallic = 0.4
	for side: float in [-1.0, 1.0]:
		# the leaf in its own frame: its hinge at the origin, reaching `half` toward the middle (+x; the right one mirrored)
		var hinge := Node3D.new()
		hinge.position = Vector3(side * half, 0.0, 0.0)
		hinge.scale = Vector3(-side, 1.0, 1.0)
		add_child(hinge)
		_hinges.append(hinge)
		var leaf := MeshInstance3D.new()
		leaf.mesh = _slab(outline(span, height, arc, true), THICK)
		leaf.material_override = wood
		leaf.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		hinge.add_child(leaf)
		for share in STRAPS:
			var strap := MeshInstance3D.new()
			var box := BoxMesh.new()
			box.size = Vector3(half - 0.06, STRAP.x, THICK + STRAP.y)
			strap.mesh = box
			strap.material_override = iron
			strap.position = Vector3(half * 0.5, spring * share, 0.0)
			strap.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			hinge.add_child(strap)
		var plank := StandardMaterial3D.new()
		plank.albedo_color = BATTEN_WOOD
		plank.roughness = 0.95
		for k in BATTENS:
			var batten := MeshInstance3D.new()
			var bb := BoxMesh.new()
			bb.size = Vector3(BATTEN.x, spring * 1.02, THICK + BATTEN.y)
			batten.mesh = bb
			batten.material_override = plank
			batten.position = Vector3(half * (float(k) + 0.5) / BATTENS, spring * 0.51, 0.0)
			batten.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			hinge.add_child(batten)
		# a ring pull at the meeting stile
		var ring := MeshInstance3D.new()
		var torus := TorusMesh.new()
		torus.inner_radius = RING.x - RING.y
		torus.outer_radius = RING.x + RING.y
		torus.rings = 12
		torus.ring_segments = 6
		ring.mesh = torus
		ring.material_override = iron
		ring.rotation.x = PI * 0.5
		ring.position = Vector3(half - 0.3, spring * RING_AT, THICK * 0.5 + RING.y * 1.5)
		ring.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		hinge.add_child(ring)


## A leaf's solid: the polygon (x from the hinge, which is its first point's x) pushed `thick` deep, both faces and the edges.
static func _slab(points: PackedVector2Array, thick: float) -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var n := points.size()
	var pts := PackedVector2Array()
	for p in points:
		pts.append(Vector2(p.x - points[0].x, p.y))
	for z: float in [thick * 0.5, -thick * 0.5]:
		st.set_normal(Vector3.BACK if z > 0.0 else Vector3.FORWARD)
		for i in range(1, n - 1):
			for p: Vector2 in [pts[0], pts[i], pts[i + 1]]:
				st.add_vertex(Vector3(p.x, p.y, z))
	for i in n:
		var a := pts[i]
		var b := pts[(i + 1) % n]
		st.set_normal(Vector3(b.y - a.y, a.x - b.x, 0.0).normalized())
		for v: Vector3 in [Vector3(a.x, a.y, thick * 0.5), Vector3(b.x, b.y, thick * 0.5), Vector3(b.x, b.y, -thick * 0.5),
				Vector3(a.x, a.y, thick * 0.5), Vector3(b.x, b.y, -thick * 0.5), Vector3(a.x, a.y, -thick * 0.5)]:
			st.add_vertex(v)
	return st.commit()


## Swings the leaves in over `time` seconds (0: at once). The door stays open (a room is left through it).
func open(time := OPEN_TIME) -> void:
	if is_open:
		return
	is_open = true
	if _tween != null:
		_tween.kill()
	for i in _hinges.size():
		# the left leaf (hinge at -x, reaching +x) turns +90 degrees to point into the wall (-z); the right one, mirrored, -90
		var to := OPEN_ANGLE * (1.0 if i == 0 else -1.0)
		if time <= 0.0 or not is_inside_tree():
			_hinges[i].rotation.y = to
			continue
		if _tween == null or not _tween.is_valid():
			_tween = create_tween().set_parallel(true)
		_tween.tween_property(_hinges[i], "rotation:y", to, time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


## The leaves' angle now (0 closed, OPEN_ANGLE open), for the tests.
func swing() -> float:
	return absf(_hinges[0].rotation.y) if not _hinges.is_empty() else 0.0
