class_name Projectiles
extends Node3D
## Everything that flies: enemy bolts and Morvath's dark orbs (hurt the paladin), the Onda de Luz and the blades of
## the light gifts (hurt enemies, pass through them). Positions are (x, z) on the floor; they fly at a fixed height.

signal hit_player(amount: float, from: Vector2)
## A friendly shot touched an enemy: the game decides the damage and the gifts that apply.
signal shot_hit(e: Enemy, shot: Shot)

## SPARK: the paladin's Seta de Luz (the special): a straight dart of the sword's emerald. WAVE: its held version, a
## broader dart with one on each side.
enum Kind { BOLT, ORB, WAVE, BLADE, SPARK }

const DART := preload("res://assets/shaders/emeth_dart.gdshader")
## The dart of the special, in meters: its length, half its width and the trail behind it.
const DART_LENGTH := 2.0
const DART_HALF := 0.15
const DART_TRAIL := 1.5
## The held version: longer and broader (0.45 m across).
const OMEGA_LENGTH := 2.6
const OMEGA_HALF := 0.225
## Meters behind the point its bow wave is drawn for each meter to the side (emeth_dart.gdshader).
const OMEGA_WAVE_BACK := 3.4

const HEIGHT := 1.1
## Meters per second of the paladin's bolt of light.
const SPARK_SPEED := 30.0
const LOOK := {
	Kind.BOLT: [Color(3.0, 0.5, 0.3), 0.18, 0.6], Kind.ORB: [Color(1.6, 0.4, 2.8), 0.45, 0.45],
	Kind.WAVE: [Color(3.0, 2.4, 1.2), 0.0, 0.0], Kind.BLADE: [Color(2.8, 2.4, 1.4), 0.0, 0.0],
	Kind.SPARK: [Color(0.3, 1.0, 0.45), 0.0, 0.0],
}

class Shot:
	var kind := Kind.BOLT
	var pos := Vector2.ZERO
	var vel := Vector2.ZERO
	var damage := 0.0
	var radius := 0.4
	var life := 3.0
	var knockback := 0.0
	var color := Color.WHITE
	var tags: Array[StringName] = []
	var status: StringName = &""
	var status_power := 0.0
	## Enemies already hit (piercing shots hit each one once).
	var seen: Dictionary = {}
	var node: Node3D
	## Meters flown (only for the look: the trail grows as the dart leaves the blade).
	var flown := 0.0

var shots: Array[Shot] = []
var horde: Horde
var player: Player
var fx: Fx
var _pools: Dictionary = {}
var _found: Array[Enemy] = []


## color: the shooter's magic (EnemyDef.magic_color) for bolts and orbs; alpha 0 keeps the kind's own look.
func fire(kind: Kind, from: Vector2, dir: Vector2, speed: float, damage: float, radius: float = 0.4, life: float = 3.0, color := Color(0, 0, 0, 0)) -> Shot:
	var s := Shot.new()
	s.kind = kind
	s.pos = from
	s.vel = dir.normalized() * speed
	s.damage = damage
	s.radius = radius
	s.life = life
	s.node = _take(kind)
	s.node.visible = true
	if kind == Kind.BOLT or kind == Kind.ORB:
		_tint(s.node, color if color.a > 0.0 else (LOOK[kind] as Array)[0])
	_place(s)
	shots.append(s)
	return s


## A friendly crescent (the Onda de Luz, the light blades) that flies distance meters through the crowd.
func fire_wave(kind: Kind, from: Vector2, dir: Vector2, damage: float, distance: float, size: float, color: Color, tags: Array[StringName]) -> Shot:
	var speed: float = SPARK_SPEED if kind == Kind.SPARK else 22.0 if kind == Kind.WAVE else 19.0
	var s := fire(kind, from, dir, speed, damage, size * 0.5, distance / speed)
	s.color = color
	s.tags = tags
	s.knockback = 10.0
	var mat: ShaderMaterial = (s.node as MeshInstance3D).material_override
	mat.set_shader_parameter(&"color", color)
	if kind == Kind.BLADE:
		s.node.scale = Vector3.ONE * size
		return s
	# a dart: the quad turns around the flight to face the camera
	var omega := kind == Kind.WAVE
	var length := OMEGA_LENGTH if omega else DART_LENGTH
	var half := OMEGA_HALF if omega else DART_HALF
	mat.set_shader_parameter(&"axis", Vector3(dir.x, 0.0, dir.y).normalized())
	mat.set_shader_parameter(&"omega", 1.0 if omega else 0.0)
	mat.set_shader_parameter(&"dart_m", length)
	mat.set_shader_parameter(&"half_m", half)
	# the held one reaches far ahead of its middle: its point leads
	mat.set_shader_parameter(&"nose_m", maxf(length * 0.5, s.radius * 0.6) if omega else length * 0.5)
	mat.set_shader_parameter(&"reach_m", s.radius)
	mat.set_shader_parameter(&"length_m", maxf(length + DART_TRAIL, OMEGA_WAVE_BACK) if omega else length + DART_TRAIL)
	mat.set_shader_parameter(&"width_m", maxf(s.radius * 2.0, half * 4.0) if omega else half * 4.0)
	mat.set_shader_parameter(&"trail_m", 0.01)
	return s


func clear_hostile() -> void:
	var i := shots.size() - 1
	while i >= 0:
		if _hostile(shots[i]):
			_release(shots[i])
			shots.remove_at(i)
		i -= 1


func step(dt: float) -> void:
	var i := shots.size() - 1
	while i >= 0:
		# a hit can end the run and clear the shots
		if i >= shots.size():
			i = shots.size() - 1
			continue
		var s := shots[i]
		s.pos += s.vel * dt
		s.life -= dt
		s.flown += s.vel.length() * dt
		var gone := s.life <= 0.0 or absf(s.pos.x) > Arena.HALF * 2.0 or absf(s.pos.y) > Arena.HALF * 2.0
		if not gone:
			if _hostile(s):
				if player.alive() and s.pos.distance_to(player.pos) < s.radius + Player.RADIUS:
					hit_player.emit(s.damage, s.pos - s.vel.normalized())
					fx.burst(&"spark", Vector3(s.pos.x, HEIGHT, s.pos.y))
					gone = true
			else:
				horde.in_circle(s.pos, s.radius, _found)
				for e in _found:
					if not s.seen.has(e):
						s.seen[e] = true
						shot_hit.emit(e, s)
		if gone:
			if shots.has(s):
				_release(s)
				shots.erase(s)
		else:
			_place(s)
		i -= 1


func _hostile(s: Shot) -> bool:
	return s.kind == Kind.BOLT or s.kind == Kind.ORB


func _place(s: Shot) -> void:
	s.node.position = Vector3(s.pos.x, HEIGHT, s.pos.y)
	if s.vel.length_squared() > 0.0:
		s.node.rotation.y = atan2(s.vel.x, s.vel.y)
	if s.kind == Kind.WAVE or s.kind == Kind.SPARK:
		s.node.rotation.y = 0.0
		((s.node as MeshInstance3D).material_override as ShaderMaterial).set_shader_parameter(&"trail_m", clampf(s.flown, 0.01, DART_TRAIL))


func _take(kind: Kind) -> Node3D:
	var pool: Array = _pools.get(kind, [])
	if not pool.is_empty():
		return pool.pop_back()
	var mi := MeshInstance3D.new()
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var look: Array = LOOK[kind]
	if kind == Kind.BLADE:
		# a crescent: the ribbon of a sword arc held at the end of its sweep (thick in the middle, thin at the ends)
		mi.mesh = _crescent()
		var mat := ShaderMaterial.new()
		mat.shader = Fx.SLASH
		mat.set_shader_parameter(&"intensity", 2.4)
		mat.set_shader_parameter(&"sweep", 1.0)
		mat.set_shader_parameter(&"t", 1.0)
		mat.set_shader_parameter(&"tail", 0.85)
		mi.material_override = mat
	elif kind == Kind.WAVE or kind == Kind.SPARK:
		var q := QuadMesh.new()
		q.size = Vector2.ONE
		mi.mesh = q
		var mat := ShaderMaterial.new()
		mat.shader = DART
		mi.material_override = mat
		# the shader draws it meters away from the quad's own box
		mi.extra_cull_margin = 12.0
	else:
		var sphere := SphereMesh.new()
		sphere.radius = look[1]
		sphere.height = look[1] * 2.0
		sphere.radial_segments = 10
		sphere.rings = 6
		mi.mesh = sphere
		var m := StandardMaterial3D.new()
		m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		m.albedo_color = look[0]
		mi.material_override = m
		if kind == Kind.BOLT:
			mi.scale = Vector3(0.6, 0.6, 2.4)
		var glow := MeshInstance3D.new()
		glow.mesh = Fx.quad(look[1] * 5.0, look[0])
		glow.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		(glow.mesh as QuadMesh).material.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
		mi.add_child(glow)
	add_child(mi)
	return mi


## The colour of a pooled bolt or orb: its core and its glow.
func _tint(node: Node3D, color: Color) -> void:
	((node as MeshInstance3D).material_override as StandardMaterial3D).albedo_color = color
	for c in node.get_children():
		if c is MeshInstance3D and (c as MeshInstance3D).mesh is QuadMesh:
			((c as MeshInstance3D).mesh.surface_get_material(0) as StandardMaterial3D).albedo_color = color


func _release(s: Shot) -> void:
	s.node.visible = false
	s.node.scale = Vector3(0.6, 0.6, 2.4) if s.kind == Kind.BOLT else Vector3.ONE
	if s.kind == Kind.SPARK:
		# the dart breaks into a few chips of its own colour where it ends
		fx.chips(s.node.position, Vector3(s.vel.x, 0.0, s.vel.y), s.color, 5, 5.0, 0.1, 0.3, 0.9)
	if not _pools.has(s.kind):
		_pools[s.kind] = []
	(_pools[s.kind] as Array).append(s.node)


var _crescent_mesh: ArrayMesh

## A crescent 1 meter across, bulging forward (+Z), with the UVs of a slash.
func _crescent() -> ArrayMesh:
	if _crescent_mesh:
		return _crescent_mesh
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var seg := 16
	var half := deg_to_rad(70.0)
	for i in seg:
		var a0 := -half + 2.0 * half * i / seg
		var a1 := -half + 2.0 * half * (i + 1) / seg
		var p := [Vector3(sin(a0) * 0.25, 0, cos(a0) * 0.25 - 0.3), Vector3(sin(a0), 0, cos(a0) - 0.3),
			Vector3(sin(a1) * 0.25, 0, cos(a1) * 0.25 - 0.3), Vector3(sin(a1), 0, cos(a1) - 0.3)]
		var u0 := 1.0 - absf(float(i) / seg - 0.5) * 2.0
		var u1 := 1.0 - absf(float(i + 1) / seg - 0.5) * 2.0
		var uv := [Vector2(0.3 + 0.4 * u0, 0), Vector2(0.3 + 0.4 * u0, 1), Vector2(0.3 + 0.4 * u1, 0), Vector2(0.3 + 0.4 * u1, 1)]
		for k: int in [0, 1, 2, 2, 1, 3]:
			st.set_uv(uv[k])
			st.add_vertex(p[k])
	_crescent_mesh = st.commit()
	return _crescent_mesh
