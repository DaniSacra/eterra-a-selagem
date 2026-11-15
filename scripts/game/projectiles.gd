class_name Projectiles
extends Node3D
## Everything that flies: enemy bolts and Morvath's dark orbs (hurt the paladin), the Onda de Luz and the blades of
## the light gifts (hurt enemies, pass through them). Positions are (x, z) on the floor; they fly at a fixed height.

signal hit_player(amount: float, from: Vector2)
## A friendly shot touched an enemy: the game decides the damage and the gifts that apply.
signal shot_hit(e: Enemy, shot: Shot)
## A hostile shot with a status (Shot.status, the boss's curse) struck the paladin while he could be hurt.
signal status_player(status: StringName)

## SPARK: the paladin's Seta de Luz (the special): a straight dart of the sword's emerald. WAVE: its held version, a
## broader dart with one on each side. SOUL: a boss's spectral crescent, wide across its flight, that goes on after
## it strikes (each one hurts the paladin once). CURSE: a boss's bolt that follows the paladin a little and curses him.
enum Kind { BOLT, ORB, WAVE, BLADE, SPARK, SOUL, CURSE }

## Meters a crescent (SOUL) reaches along its flight, before and behind its middle line.
const SOUL_DEPTH := 0.45
## Height of the crescents over the floor (they read on the floor, like the warnings they follow).
const SOUL_HEIGHT := 0.55

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
	Kind.SPARK: [Color(0.3, 1.0, 0.45), 0.0, 0.0], Kind.SOUL: [Color(0.38, 1.55, 1.1), 0.0, 0.0],
	Kind.CURSE: [Color(1.0, 0.22, 1.5), 0.42, 0.42],
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
	## A crescent (SOUL): half its width across the flight.
	var half_width := 0.0
	## Seconds it still turns after the paladin, and how fast (radians a second).
	var homing := 0.0
	var turn := 0.0

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
	if kind == Kind.BOLT or kind == Kind.ORB or kind == Kind.CURSE:
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


## A boss's spectral crescent: width meters across, flying distance meters (it strikes the paladin once).
func fire_soul(from: Vector2, dir: Vector2, speed: float, damage: float, width: float, distance: float, color: Color) -> Shot:
	var s := fire(Kind.SOUL, from, dir, speed, damage, SOUL_DEPTH, distance / maxf(speed, 0.1))
	s.half_width = width * 0.5
	s.color = color
	s.node.scale = Vector3(width / CRESCENT_SPAN, 1.0, width / CRESCENT_SPAN * 0.85)
	((s.node as MeshInstance3D).material_override as ShaderMaterial).set_shader_parameter(&"color", color)
	return s


## A boss's curse: a bolt that turns after the paladin (turn degrees a second for homing seconds) and curses him.
func fire_curse(from: Vector2, dir: Vector2, speed: float, damage: float, radius: float, life: float, turn_deg: float, homing: float, color := Color(0, 0, 0, 0)) -> Shot:
	var s := fire(Kind.CURSE, from, dir, speed, damage, radius, life, color)
	s.status = &"curse"
	s.turn = deg_to_rad(turn_deg)
	s.homing = homing
	return s


## True while a shot that hurts the paladin flies.
func hostile_left() -> bool:
	for s in shots:
		if hostile(s):
			return true
	return false


func clear_hostile() -> void:
	var i := shots.size() - 1
	while i >= 0:
		if hostile(shots[i]):
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
		if s.homing > 0.0 and player.alive():
			s.homing -= dt
			var want := s.vel.angle_to(player.pos - s.pos)
			s.vel = s.vel.rotated(clampf(want, -s.turn * dt, s.turn * dt))
		s.pos += s.vel * dt
		s.life -= dt
		s.flown += s.vel.length() * dt
		var gone := s.life <= 0.0 or absf(s.pos.x) > Arena.HALF * 2.0 or absf(s.pos.y) > Arena.HALF * 2.0
		if not gone:
			if s.kind == Kind.SOUL:
				if player.alive() and not s.seen.has(player) and touches_soul(s, player.pos, Player.RADIUS):
					s.seen[player] = true
					hit_player.emit(s.damage, s.pos - s.vel.normalized())
					fx.burst(&"soul", Vector3(player.pos.x, HEIGHT, player.pos.y))
			elif hostile(s):
				if player.alive() and s.pos.distance_to(player.pos) < s.radius + Player.RADIUS:
					var safe := player.invulnerable()
					hit_player.emit(s.damage, s.pos - s.vel.normalized())
					if s.status != &"" and not safe:
						status_player.emit(s.status)
					fx.burst(&"curse" if s.kind == Kind.CURSE else &"spark", Vector3(s.pos.x, HEIGHT, s.pos.y))
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


static func hostile(s: Shot) -> bool:
	return s.kind == Kind.BOLT or s.kind == Kind.ORB or s.kind == Kind.SOUL or s.kind == Kind.CURSE


## A crescent (SOUL) touches a body of this radius at p: within its depth along the flight and its width across.
static func touches_soul(s: Shot, p: Vector2, radius: float) -> bool:
	var d := p - s.pos
	var ahead := s.vel.normalized()
	return absf(d.dot(ahead)) <= s.radius + radius and absf(d.cross(ahead)) <= s.half_width + radius * 0.5


func _place(s: Shot) -> void:
	s.node.position = Vector3(s.pos.x, SOUL_HEIGHT if s.kind == Kind.SOUL else HEIGHT, s.pos.y)
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
	if kind == Kind.BLADE or kind == Kind.SOUL:
		# a crescent: the ribbon of a sword arc held at the end of its sweep (thick in the middle, thin at the ends)
		mi.mesh = _crescent()
		var mat := ShaderMaterial.new()
		mat.shader = Fx.SLASH
		mat.set_shader_parameter(&"intensity", 2.4)
		mat.set_shader_parameter(&"sweep", 1.0)
		mat.set_shader_parameter(&"t", 1.0)
		mat.set_shader_parameter(&"tail", 0.85)
		if kind == Kind.SOUL:
			# a boss's crescent of spectral fire (soul_crescent.gdshader)
			mat.shader = SOUL_SHADER
			mat.set_shader_parameter(&"intensity", SOUL_INTENSITY)
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


## Meters across the crescent mesh at scale 1 (its two tips, 70 degrees each side of its middle).
const CRESCENT_SPAN := 1.88
## How bright a boss's crescent is drawn (it must not drown the warnings).
const SOUL_INTENSITY := 1.0
const SOUL_SHADER := preload("res://assets/shaders/soul_crescent.gdshader")
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
