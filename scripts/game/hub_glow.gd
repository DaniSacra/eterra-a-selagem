class_name HubGlow
extends RefCounted
## The Santuário's warm pools of light on the paving (hub refine round 3): the art's cream-rose floor is lit in pools of
## golden light round its lanterns, doors and fire, and dark only at the rim. Each pool is a soft disc (a centre and a few
## rings, the vertex colour fading to nothing) laid a hair over the floor, unshaded and added to what is there, all of them
## one mesh and one material (no light, no shader of its own). A vertex that would fall off the floor (over the drop, in a
## basin) is drawn in toward the centre until it is on it, so a pool never hangs in the air.
##   var g := HubGlow.new(on_floor)  # on_floor: Callable(Vector2) -> bool, in the hub's local (u, v)
##   g.pool(Vector2(u, v), radius, strength, color); ...; g.build(frame)

const HEIGHT := 0.035
const RINGS := 3
const SEGMENTS := 16
## How the strength falls from the centre to the rim: (1 - r / R) ^ FALLOFF at each ring.
const FALLOFF := 1.7
## The share of the radius a vertex is drawn in by, tried in turn, until it is on the floor (the last: all the way in).
const PULL: Array[float] = [1.0, 0.8, 0.6, 0.4, 0.2, 0.0]

var _on_floor: Callable
var _st := SurfaceTool.new()
var _count := 0


func _init(on_floor: Callable) -> void:
	_on_floor = on_floor
	_st.begin(Mesh.PRIMITIVE_TRIANGLES)


func count() -> int:
	return _count


## A pool of `radius` m round `c` (local u, v) at `strength` (the colour's share added at the centre).
func pool(c: Vector2, radius: float, strength: float, color: Color) -> void:
	if not _on_floor.call(c):
		return
	var rings: Array[PackedVector3Array] = []
	for i in RINGS:
		var ring := PackedVector3Array()
		var r := radius * float(i + 1) / RINGS
		var level := pow(1.0 - float(i + 1) / (RINGS + 1), FALLOFF) if i < RINGS - 1 else 0.0
		for k in SEGMENTS:
			var a := TAU * k / SEGMENTS
			var dir := Vector2(cos(a), sin(a))
			var q := c
			for pull: float in PULL:
				q = c + dir * r * pull
				if _on_floor.call(q):
					break
			ring.append(Vector3(q.x, q.y, level))
		rings.append(ring)
	var centre := _col(color, strength)
	for i in RINGS:
		var outer := rings[i]
		for k in SEGMENTS:
			var k2 := (k + 1) % SEGMENTS
			if i == 0:
				_vertex(c, centre)
				_vertex(Vector2(outer[k].x, outer[k].y), _col(color, strength * outer[k].z))
				_vertex(Vector2(outer[k2].x, outer[k2].y), _col(color, strength * outer[k2].z))
			else:
				var inner := rings[i - 1]
				var a := inner[k]
				var b := inner[k2]
				var o1 := outer[k]
				var o2 := outer[k2]
				_vertex(Vector2(a.x, a.y), _col(color, strength * a.z))
				_vertex(Vector2(o1.x, o1.y), _col(color, strength * o1.z))
				_vertex(Vector2(o2.x, o2.y), _col(color, strength * o2.z))
				_vertex(Vector2(a.x, a.y), _col(color, strength * a.z))
				_vertex(Vector2(o2.x, o2.y), _col(color, strength * o2.z))
				_vertex(Vector2(b.x, b.y), _col(color, strength * b.z))
	_count += 1


## Adds every pool as one mesh under `frame` (HubLook's frame: x = u, z = -v). Nothing if no pool was added.
func build(frame: Node3D) -> void:
	if _count == 0:
		return
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat.vertex_color_use_as_albedo = true
	var mi := MeshInstance3D.new()
	mi.name = "WarmPools"
	mi.mesh = _st.commit()
	mi.material_override = mat
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	frame.add_child(mi)


func _col(color: Color, k: float) -> Color:
	return Color(color.r * k, color.g * k, color.b * k, 1.0)


func _vertex(p: Vector2, c: Color) -> void:
	_st.set_color(c)
	_st.add_vertex(Vector3(p.x, HEIGHT, -p.y))
