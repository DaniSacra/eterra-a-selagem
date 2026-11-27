class_name PaintedHall
extends Node3D
## GP-8, technique A (prototype, `--painted[=fit|game]`, only the Salao of room 1): the painting IS the room. The approved
## painting (assets/rooms/painted/sala01.jpg) is projected from a "painter's camera" onto a few plain surfaces (floor, low
## walls, the north wall, a far backdrop) by painted.gdshader, so at that camera each pixel is the painting's own. The game
## camera takes the painter's yaw, pitch, fov and distance and only pans after the hero (--cam-yaw/-pitch/-fov/-dist are
## put while this node lives), so the painting is never bent. The 3D pieces of the hall are hidden; the hero, the fighters,
## the effects and the door medals stay 3D on top. Collision stays the truth: the painted floor is a sub-rectangle of the
## hall (FLOOR), the rest is walled off by two invisible boxes. Numbers and what was learnt: docs/reference/art_core.md
## (GP-8 technique A).

const PAINTING := "res://assets/rooms/painted/sala01.jpg"
const SHADER := "res://assets/shaders/painted.gdshader"
## The painting's size (px): the painter's camera has this aspect.
const SIZE := Vector2(1672.0, 941.0)
## The painter's cameras. "fit": found by least squares so the painting's floor corners and the two doors land on the plan
## (the approved painting is NOT a pinhole view: this is the best it gets, up to 65 px off at the north-west corner and
## only possible at a 15 degree pitch). "game": the numbers asked of a NEW painting (docs/art/requests/midjourney_gp8/02),
## the game's own camera pushed back; the approved painting does not fit it.
const POSES := {
	&"fit": {&"yaw": 32.3, &"pitch": 15.0, &"fov": 9.65, &"dist": 80.0, &"at": Vector2(6.27, -3.71)},
	&"game": {&"yaw": 35.0, &"pitch": 30.0, &"fov": 24.0, &"dist": 68.0, &"at": Vector2(2.0, 1.0)},
}
## The part of the hall the painting shows (x, z): from the west balustrade to the east one, north wall to south edge.
const FLOOR := Rect2(-7.5, -15.0, 21.5, 30.0)
## How far inside the painted edge a body stops (the balustrade's thickness), meters.
const INSET := 0.8
## The broken column in the painting's middle right (pixel of its foot) and its blocking radius.
const STUB_PIXEL := Vector2(1250.0, 655.0)
const STUB_RADIUS := 0.7
## Where the paladin walks in (inside the painted floor).
const START := Vector2(0.0, 9.0)
## The camera follows the hero inside this box around the painter's point (the painting ends beyond it), half sizes.
const CAM_REACH := Vector2(3.0, 5.0)
## How deep the walls under the floor go (the painting shows the platform's flank), their top over the floor.
const FLANK := 14.0
const RAIL_TOP := 1.6
const NORTH_Z := -16.5
const BACKDROP_X := -30.0

var pose: Dictionary = POSES[&"fit"]
var _owned: Array[String] = []


## True for the hall room that --painted dresses (the opening hall, not the Antessala).
static func wanted(arena: Arena) -> bool:
	return Dev.has("painted") and arena.layout != null and arena.layout.id == &"hall" and arena.layout.hazard == null


static func pose_named(name_: String) -> Dictionary:
	return POSES.get(StringName(name_), POSES[&"fit"])


## World to clip of the painter's camera (what painted.gdshader reads).
static func projector(p: Dictionary) -> Projection:
	var at := Vector3(p[&"at"].x, 0.0, p[&"at"].y)
	var eye := at + Feel.cam_offset_of(p[&"dist"], p[&"pitch"], p[&"yaw"])
	var view := Transform3D(Basis.looking_at(at - eye, Vector3.UP), eye).affine_inverse()
	return Projection.create_perspective(p[&"fov"], SIZE.x / SIZE.y, 1.0, 400.0) * Projection(view)


## Where a world point falls in the painting, in its pixels.
static func to_pixel(p: Dictionary, world: Vector3) -> Vector2:
	var c := projector(p) * Vector4(world.x, world.y, world.z, 1.0)
	return Vector2((c.x / c.w * 0.5 + 0.5) * SIZE.x, (0.5 - c.y / c.w * 0.5) * SIZE.y)


## The floor point (x, z) under a pixel of the painting.
static func to_floor(p: Dictionary, pixel: Vector2) -> Vector2:
	var inv := projector(p).inverse()
	var ndc := Vector2(pixel.x / SIZE.x * 2.0 - 1.0, 1.0 - pixel.y / SIZE.y * 2.0)
	var a := inv * Vector4(ndc.x, ndc.y, -1.0, 1.0)
	var b := inv * Vector4(ndc.x, ndc.y, 1.0, 1.0)
	var pa := Vector3(a.x, a.y, a.z) / a.w
	var pb := Vector3(b.x, b.y, b.z) / b.w
	var t := pa.y / (pa.y - pb.y)
	var hit := pa.lerp(pb, t)
	return Vector2(hit.x, hit.z)


## Dresses the built hall: hides its 3D pieces, swaps its colliders for the painted floor's, adds the projected surfaces.
static func apply(arena: Arena) -> void:
	var node := PaintedHall.new()
	node.name = "PaintedHall"
	node.pose = pose_named(Dev.arg("painted"))
	for c in arena.get_children():
		if c is Node3D:
			(c as Node3D).visible = false
	arena.add_child(node)
	node._build(arena)


func _enter_tree() -> void:
	# the camera of the game takes the painter's (a switch typed on the command line wins)
	for k: String in ["yaw", "pitch", "fov", "dist"]:
		if not Dev.has("cam-" + k):
			Dev.put("cam-" + k, str(pose[StringName(k)]))
			_owned.append("cam-" + k)


func _exit_tree() -> void:
	for k in _owned:
		Dev.drop(k)
	_owned.clear()


func _build(arena: Arena) -> void:
	var at: Vector2 = pose[&"at"]
	arena.walk.clear()
	arena.start = START
	arena.start_facing = Vector2(1, -1).normalized()
	arena.showcase = Vector3(at.x, 0.0, at.y)
	arena.cam_bounds = Rect2(at - CAM_REACH, CAM_REACH * 2.0)
	arena.pillars.clear()
	arena.boxes.clear()
	var west := FLOOR.position.x + INSET
	var east := FLOOR.end.x - INSET
	arena.boxes.append(Rect2(west - 14.0, -20.0, 14.0, 40.0))
	arena.boxes.append(Rect2(east, -20.0, 14.0, 40.0))
	var stub := to_floor(pose, STUB_PIXEL)
	arena.pillars.append(Vector3(stub.x, stub.y, STUB_RADIUS))
	var mat := ShaderMaterial.new()
	mat.shader = load(SHADER)
	mat.set_shader_parameter(&"painting", load(PAINTING))
	mat.set_shader_parameter(&"projector", projector(pose))
	var r := FLOOR
	var xw := r.position.x
	var xe := r.end.x
	var zn := r.position.y
	var zs := r.end.y
	_quad(mat, Vector3(xw, 0, zn), Vector3(xe, 0, zn), Vector3(xe, 0, zs), Vector3(xw, 0, zs))
	# the flanks and low walls: each from deep under the floor to the balustrade's top
	_quad(mat, Vector3(xw, -FLANK, zs + 0.5), Vector3(xe + 0.5, -FLANK, zs + 0.5), Vector3(xe + 0.5, RAIL_TOP, zs + 0.5), Vector3(xw, RAIL_TOP, zs + 0.5))
	_quad(mat, Vector3(xe + 0.5, -FLANK, zn), Vector3(xe + 0.5, -FLANK, zs + 0.5), Vector3(xe + 0.5, RAIL_TOP, zs + 0.5), Vector3(xe + 0.5, RAIL_TOP, zn))
	_quad(mat, Vector3(xw - 0.5, -FLANK, zn), Vector3(xw - 0.5, -FLANK, zs + 0.5), Vector3(xw - 0.5, RAIL_TOP, zs + 0.5), Vector3(xw - 0.5, RAIL_TOP, zn))
	# the north wall, tall, and a far backdrop for the arcades beyond the west edge
	_quad(mat, Vector3(xw - 6.0, -FLANK, NORTH_Z), Vector3(xe + 6.0, -FLANK, NORTH_Z), Vector3(xe + 6.0, 18.0, NORTH_Z), Vector3(xw - 6.0, 18.0, NORTH_Z))
	_quad(mat, Vector3(BACKDROP_X, -30.0, 30.0), Vector3(BACKDROP_X, -30.0, NORTH_Z), Vector3(BACKDROP_X, 40.0, NORTH_Z), Vector3(BACKDROP_X, 40.0, 30.0))


func _quad(mat: Material, a: Vector3, b: Vector3, c: Vector3, d: Vector3) -> void:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for v: Vector3 in [a, b, c, a, c, d]:
		st.add_vertex(v)
	st.generate_normals()
	var mi := MeshInstance3D.new()
	mi.mesh = st.commit()
	mi.material_override = mat
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(mi)
