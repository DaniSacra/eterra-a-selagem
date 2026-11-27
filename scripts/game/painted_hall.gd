class_name PaintedHall
extends Node3D
## GP-8: the painting IS the room's look. Each painted room (ROOMS: the Salao, the Sala 00, the Antessala) has a painting
## that gpt-image-2 made over a capture of the game itself (docs/art/painted_gpt), so the painter's camera is a real game
## camera (POSES). painted.gdshader projects the painting from that camera onto the room's own solid meshes (floor, walls,
## pillars, statues, the abyss's pillars), so at the painter's pose each pixel is the painting's and anywhere else the
## painting sits on the right shapes, with the right parallax. The game camera is not touched: yaw, pitch and fov are the
## painter's (Feel: 35, 30, 24); only the distance (the game's near one is nearer than the painter's) and the pan differ.
## Collision, doors and everything that moves are the room's own, untouched: what the painting replaces is only how the
## static stone looks. Two far planes (the abyss under the room, a wall beyond it) carry the painting where no mesh is.
##
## What is painted and what stays 3D (apply): opaque meshes (stone, floor, banners, the doors' leaves, the abyss's pillars and
## ruins) take the painting; decals, the abyss's fog and glow are hidden (painted); lights, flames, embers, water, hazards,
## the altar's lion and glow stay as they are. A door's leaves and its black face wear the painting while shut and get their
## own look back when the door opens (PaintedHall._process). Swapping a painting is replacing its file in
## assets/rooms/painted (the pose is the one the painting was made at, see docs/art/painted_gpt/README.md).
## Switches: --painted forces it on, --painted=off turns it off (DEFAULT_ON decides without them).

const SHADER := "res://assets/shaders/painted.gdshader"
## The painting's frame is the 16:9 capture, stretched to the file's 3:2: the projection maps its UV 0..1 to this aspect.
const ASPECT := 16.0 / 9.0
## Off until Daniel approves the paintings: --painted turns it on (flip this to ship it on).
const DEFAULT_ON := false
## The painters' cameras, by room (layout id): the painting, and the game camera's flags it was made with.
const ROOMS := {
	&"hall": {&"painting": "res://assets/rooms/painted/sala01.png", &"yaw": 35.0, &"pitch": 30.0, &"fov": 24.0, &"dist": 68.0, &"at": Vector2(2.0, 1.0)},
	&"sala00": {&"painting": "res://assets/rooms/painted/sala00.png", &"yaw": 35.0, &"pitch": 30.0, &"fov": 24.0, &"dist": 52.0, &"at": Vector2(0.0, 0.0)},
	&"ante": {&"painting": "res://assets/rooms/painted/antessala.png", &"yaw": 35.0, &"pitch": 30.0, &"fov": 24.0, &"dist": 80.0, &"at": Vector2(0.0, 0.0)},
}
## Shaders whose meshes take the painting (the room's solid stone, floor and the abyss's pillars and ruins).
## (by the start of the file name: the stylized twins end in _paint or _fade).
const SOLID: Array[String] = ["masonry", "catacomb_floor", "depth_stone", "abyss_ruins"]
## Shaders whose meshes are hidden (the painting has them): the floor's decals, the abyss's fog, mist and glow.
const HIDDEN: Array[String] = ["floor_decal", "abyss_fog", "abyss_mist", "abyss_glow"]
## The far planes: the one under the room (depth below the floor) and the wall beyond it (how far behind the painter's
## point, along the camera's way, how high), both this wide.
const UNDER_DEPTH := 34.0
const WALL_DISTANCE := 70.0
const WALL_TOP := 120.0
const SPAN := 160.0
## Hide the translucent cards (flame and glow sprites, fake shadows): the painting has them painted.
const HIDE_CARDS := true

var room: StringName = &"hall"
var _mat: ShaderMaterial
var _see: Dictionary = {}
## Door -> its meshes and what they wore before (given back when it opens), the black faces by their door's x.
var _doors: Array[HallDoor] = []
var _worn: Dictionary = {}


## True for a room that has a painting in the stylized look (the painting is that look's stone), unless --painted=off. The hall is the opening one (not a hazard room).
static func wanted(arena: Arena) -> bool:
	if arena.layout == null or not ROOMS.has(arena.layout.id):
		return false
	if Dev.arg("painted") == "off" or not VisualProfile.stylized():
		return false
	if arena.layout.id == &"hall" and arena.layout.hazard != null:
		return false
	return DEFAULT_ON or Dev.has("painted")


## The painter's pose of a room (a copy), or an empty dictionary.
static func pose_of(id: StringName) -> Dictionary:
	return (ROOMS[id] as Dictionary).duplicate() if ROOMS.has(id) else {}


## World to clip of the painter's camera (what painted.gdshader reads).
static func projector(p: Dictionary) -> Projection:
	var at := Vector3(p[&"at"].x, 0.0, p[&"at"].y)
	var eye := at + Feel.cam_offset_of(p[&"dist"], p[&"pitch"], p[&"yaw"])
	var view := Transform3D(Basis.looking_at(at - eye, Vector3.UP), eye).affine_inverse()
	return Projection.create_perspective(p[&"fov"], ASPECT, 1.0, 400.0) * Projection(view)


## Where a world point falls in the painting, as UV 0..1.
static func to_uv(p: Dictionary, world: Vector3) -> Vector2:
	var c := projector(p) * Vector4(world.x, world.y, world.z, 1.0)
	return Vector2(c.x / c.w * 0.5 + 0.5, 0.5 - c.y / c.w * 0.5)


## The floor point (x, z) under a UV of the painting.
static func to_floor(p: Dictionary, uv: Vector2) -> Vector2:
	var inv := projector(p).inverse()
	var ndc := Vector2(uv.x * 2.0 - 1.0, 1.0 - uv.y * 2.0)
	var a := inv * Vector4(ndc.x, ndc.y, -1.0, 1.0)
	var b := inv * Vector4(ndc.x, ndc.y, 1.0, 1.0)
	var pa := Vector3(a.x, a.y, a.z) / a.w
	var pb := Vector3(b.x, b.y, b.z) / b.w
	var hit := pa.lerp(pb, pa.y / (pa.y - pb.y))
	return Vector2(hit.x, hit.z)


## Dresses the built room (its look has finished): its solid meshes take the painting, the far planes are added.
static func apply(arena: Arena) -> void:
	var node := PaintedHall.new()
	node.name = "PaintedHall"
	node.room = arena.layout.id
	arena.add_child(node)
	node._dress(arena)


func _dress(arena: Arena) -> void:
	var p := pose_of(room)
	_mat = _material(p, 0.0)
	_walk(arena, arena)
	var at := Vector3(p[&"at"].x, 0.0, p[&"at"].y)
	var away := -Feel.cam_offset_of(1.0, p[&"pitch"], p[&"yaw"])
	away.y = 0.0
	away = away.normalized()
	var side := away.cross(Vector3.UP) * SPAN
	var far := at + away * WALL_DISTANCE
	_quad(at + Vector3(-SPAN, -UNDER_DEPTH, -SPAN), at + Vector3(SPAN, -UNDER_DEPTH, -SPAN), at + Vector3(SPAN, -UNDER_DEPTH, SPAN), at + Vector3(-SPAN, -UNDER_DEPTH, SPAN))
	_quad(far - side + Vector3(0, -UNDER_DEPTH, 0), far + side + Vector3(0, -UNDER_DEPTH, 0), far + side + Vector3(0, WALL_TOP, 0), far - side + Vector3(0, WALL_TOP, 0))


## One painted material, with the stone's see-through opening round the paladin when `see` is on (cached by its numbers).
func _material(p: Dictionary, see: float, from: ShaderMaterial = null) -> ShaderMaterial:
	var key := [see, from.get_shader_parameter(&"see_radius") if from else 0.0, from.get_shader_parameter(&"see_height") if from else 0.0]
	if _see.has(key):
		return _see[key]
	var mat := ShaderMaterial.new()
	mat.shader = load(SHADER)
	mat.set_shader_parameter(&"painting", load(p[&"painting"]))
	mat.set_shader_parameter(&"projector", projector(p))
	if see > 0.0:
		mat.set_shader_parameter(&"see_through", see)
		for k: StringName in [&"see_radius", &"see_height", &"see_keep", &"see_gap"]:
			var v: Variant = from.get_shader_parameter(k)
			if v != null:
				mat.set_shader_parameter(k, v)
	_see[key] = mat
	return mat


func _walk(n: Node, arena: Arena) -> void:
	for c in n.get_children():
		if c == self:
			continue
		if c is HallDoor:
			_doors.append(c)
		# a piece the look hides (the classic-only ones) is left alone; the room itself may still be hidden while it is built
		if c is Node3D and not (c as Node3D).visible:
			continue
		if c is GeometryInstance3D:
			_one(c as GeometryInstance3D)
		if c.get_child_count() > 0:
			_walk(c, arena)


## What a mesh does: takes the painting, hides, or stays.
func _one(g: GeometryInstance3D) -> void:
	var m: Material = g.material_override
	if m == null:
		var mesh: Mesh = null
		if g is MeshInstance3D:
			mesh = (g as MeshInstance3D).mesh
		elif g is MultiMeshInstance3D and (g as MultiMeshInstance3D).multimesh != null:
			mesh = (g as MultiMeshInstance3D).multimesh.mesh
		if mesh != null and mesh.get_surface_count() > 0:
			m = mesh.surface_get_material(0)
	if m is ShaderMaterial:
		var sm := m as ShaderMaterial
		var file := sm.shader.resource_path.get_file().get_basename()
		if file in HIDDEN:
			VisualProfile.vary(g, {&"visible": false})
		elif SOLID.any(func(k: String) -> bool: return file.begins_with(k)):
			_wear(g, _material(pose_of(room), float(sm.get_shader_parameter(&"see_through") if sm.get_shader_parameter(&"see_through") != null else 0.0), sm))
	elif m is StandardMaterial3D:
		var sm := m as StandardMaterial3D
		if sm.transparency == BaseMaterial3D.TRANSPARENCY_DISABLED and sm.blend_mode == BaseMaterial3D.BLEND_MODE_MIX:
			_wear(g, _material(pose_of(room), 0.0))
		elif HIDE_CARDS:
			VisualProfile.vary(g, {&"visible": false})


func _wear(g: GeometryInstance3D, mat: ShaderMaterial) -> void:
	var door := _door_of(g)
	if door >= 0:
		_worn[g] = [door, g.material_override]
	# through the look's registry: the painting is the stylized look's stone (F7 brings the classic one back)
	VisualProfile.vary(g, {&"material_override": mat})


## The door a mesh belongs to (the leaves are the door's children; its black faces stand in the wall at its x): its index.
func _door_of(g: Node) -> int:
	for i in _doors.size():
		if _doors[i].is_ancestor_of(g):
			return i
	if g is MeshInstance3D and (g as MeshInstance3D).material_override is StandardMaterial3D:
		var sm := (g as MeshInstance3D).material_override as StandardMaterial3D
		if sm.shading_mode == BaseMaterial3D.SHADING_MODE_UNSHADED and sm.albedo_color == HallDoor.BLACK:
			for i in _doors.size():
				if absf(_doors[i].global_position.x - (g as Node3D).global_position.x) < 0.05:
					return i
	return -1


## A door that opens gives its leaves and its black inside their own look back (the painting shows it shut).
func _process(_dt: float) -> void:
	for g: GeometryInstance3D in _worn.keys():
		var door := _doors[_worn[g][0]]
		if door.is_open:
			VisualProfile.vary(g, {&"material_override": _worn[g][1]})
			_worn.erase(g)


func _quad(a: Vector3, b: Vector3, c: Vector3, d: Vector3) -> void:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for v: Vector3 in [a, b, c, a, c, d]:
		st.add_vertex(v)
	st.generate_normals()
	var mi := MeshInstance3D.new()
	mi.mesh = st.commit()
	mi.material_override = _mat
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(mi)
