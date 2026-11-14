class_name Projectiles
extends Node3D
## Everything that flies: enemy bolts and Morvath's dark orbs (hurt the paladin), the Onda de Luz and the blades of
## the light gifts (hurt enemies, pass through them). Positions are (x, z) on the floor; they fly at a fixed height.

signal hit_player(amount: float, from: Vector2)
## A friendly shot touched an enemy: the game decides the damage and the gifts that apply.
signal shot_hit(e: Enemy, shot: Shot)

## SPARK: the paladin's bolt of light (the special): a bright streak with a trail.
enum Kind { BOLT, ORB, WAVE, BLADE, SPARK }

const HEIGHT := 1.1
## Meters per second of the paladin's bolt of light.
const SPARK_SPEED := 30.0
const LOOK := {
	Kind.BOLT: [Color(3.0, 0.5, 0.3), 0.18, 0.6], Kind.ORB: [Color(1.6, 0.4, 2.8), 0.45, 0.45],
	Kind.WAVE: [Color(3.0, 2.4, 1.2), 0.0, 0.0], Kind.BLADE: [Color(2.8, 2.4, 1.4), 0.0, 0.0],
	Kind.SPARK: [Color(4.0, 3.0, 1.5), 0.22, 0.0],
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

var shots: Array[Shot] = []
var horde: Horde
var player: Player
var fx: Fx
var _pools: Dictionary = {}
var _found: Array[Enemy] = []


func fire(kind: Kind, from: Vector2, dir: Vector2, speed: float, damage: float, radius: float = 0.4, life: float = 3.0) -> Shot:
	var s := Shot.new()
	s.kind = kind
	s.pos = from
	s.vel = dir.normalized() * speed
	s.damage = damage
	s.radius = radius
	s.life = life
	s.node = _take(kind)
	s.node.visible = true
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
	if kind == Kind.SPARK:
		var trail := s.node.get_node(^"Trail") as CPUParticles3D
		trail.restart()
		return s
	s.node.scale = Vector3.ONE * size
	var mat: ShaderMaterial = (s.node as MeshInstance3D).material_override
	mat.set_shader_parameter(&"color", color)
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
	if s.kind == Kind.WAVE or s.kind == Kind.BLADE:
		var mat: ShaderMaterial = (s.node as MeshInstance3D).material_override
		mat.set_shader_parameter(&"t", 0.45)


func _take(kind: Kind) -> Node3D:
	var pool: Array = _pools.get(kind, [])
	if not pool.is_empty():
		return pool.pop_back()
	var mi := MeshInstance3D.new()
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var look: Array = LOOK[kind]
	if kind == Kind.WAVE or kind == Kind.BLADE:
		# a crescent: the slash arc frozen at its brightest
		mi.mesh = _crescent()
		var mat := ShaderMaterial.new()
		mat.shader = Fx.SLASH
		mat.set_shader_parameter(&"intensity", 3.0)
		mi.material_override = mat
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
		elif kind == Kind.SPARK:
			# the streak is a stretched child, so the trail and the glow keep their shape
			var core := MeshInstance3D.new()
			core.mesh = mi.mesh
			core.material_override = mi.material_override
			core.scale = Vector3(0.7, 0.7, 4.0)
			core.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			mi.mesh = null
			mi.add_child(core)
			mi.add_child(_trail(look[0]))
		var glow := MeshInstance3D.new()
		glow.mesh = Fx.quad(look[1] * 5.0, look[0])
		glow.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		(glow.mesh as QuadMesh).material.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
		mi.add_child(glow)
	add_child(mi)
	return mi


func _release(s: Shot) -> void:
	s.node.visible = false
	s.node.scale = Vector3(0.6, 0.6, 2.4) if s.kind == Kind.BOLT else Vector3.ONE
	if s.kind == Kind.SPARK:
		fx.burst(&"light", s.node.position)
	if not _pools.has(s.kind):
		_pools[s.kind] = []
	(_pools[s.kind] as Array).append(s.node)


## The streak of light left behind a bolt (in the world, so it stays where the bolt passed).
func _trail(color: Color) -> CPUParticles3D:
	var p := CPUParticles3D.new()
	p.name = "Trail"
	p.local_coords = false
	p.amount = 40
	p.lifetime = 0.3
	p.emission_shape = CPUParticles3D.EMISSION_SHAPE_SPHERE
	p.emission_sphere_radius = 0.12
	p.direction = Vector3.UP
	p.spread = 180.0
	p.initial_velocity_min = 0.3
	p.initial_velocity_max = 1.2
	p.gravity = Vector3.ZERO
	p.scale_amount_min = 0.6
	p.scale_amount_max = 1.2
	p.mesh = Fx.quad(0.35, color)
	p.color_ramp = Fx.fade_ramp(Color(1, 1, 1, 1))
	return p


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
