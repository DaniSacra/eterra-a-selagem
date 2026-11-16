class_name Projectiles
extends Node3D
## Everything that flies: enemy bolts and Morvath's dark orbs (hurt the paladin), the Onda de Luz and the blades of
## the light gifts (hurt enemies, pass through them). Positions are (x, z) on the floor; they fly at a fixed height.

signal hit_player(amount: float, from: Vector2)
## A hostile shot was fired or died on stone (RoomTally.SHOT_*), by its shooter (shooter()), on piece (blocked_by).
signal shot_logged(by: String, what: String, piece: String)
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
## Height of a shot that creeps along the floor (Shot.low).
const LOW_HEIGHT := 0.3

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
## Enemy shots (bolts, orbs, the curse): their ball and halo (cycle 10, BUG-006), and the halo's radius as a share of
## the ball's (at most 1.5: a crowd of sorcerers never fills the air with light).
const ORB_SHADER := preload("res://assets/shaders/enemy_orb.gdshader")
const HALO_SHADER := preload("res://assets/shaders/enemy_orb_halo.gdshader")
const HALO := 1.5
## The dart flies at the speed of Hades II's special (ProjectileStaffBall, 5000 units: 62.5 m/s; GF-07).
const SPARK_SPEED := 5000.0 / 80.0
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
	## How fast that turning fades (radians a second, each second): the vines stop following after a while.
	var turn_decay := 0.0
	## It creeps along the floor (an enemy's vine) instead of flying at chest height.
	var low := false
	## Which attack fired it (a boss's attack id; the hurt_by count of the fight).
	var source: StringName = &""
	## Which kind of enemy fired it (EnemyDef.id, Horde.acting; &"": none, as the boss's own): "Derrotado por".
	var by: StringName = &""
	## Seconds it has flown (the crescent's look: its first flare, its fade at the end).
	var age := 0.0
	## Seconds its shooter's warning showed before it left (the aim held; the run's log, warn_s).
	var warned := 0.0
	## Its shooter was off the screen as it fired (1), on it (0), unknown (-1) (Horde.screen_flag).
	var offscreen := -1

## How far a shot is from the stone when it dies on it (meters; its ball is about this round).
const SHOT_EDGE := 0.15
## A shot flying this far past the room's floor is gone.
const SHOT_MARGIN := 12.0

var shots: Array[Shot] = []
## Shots that died on cover (RESULT shots_blocked).
var blocked := 0
## The source of the shot that hurt the paladin last (Shot.source), read by the game as hit_player is emitted.
var last_source: StringName = &""
## Which kind of enemy fired it (Shot.by).
var last_by: StringName = &""
## That shot's warning in seconds (its shooter's aim and its flight) and Shot.offscreen, for the run's log.
var last_warn := -1.0
var last_offscreen := -1
var horde: Horde
var player: Player
var fx: Fx
var _pools: Dictionary = {}
var _orb_mats: Dictionary = {}
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
	s.by = horde.acting if horde else &""
	if hostile(s):
		s.offscreen = horde.screen_flag(from) if horde else -1
		shot_logged.emit(shooter(s), RoomTally.SHOT_FIRED, "")
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
			s.turn = maxf(0.0, s.turn - s.turn_decay * dt)
		var to := s.pos + s.vel * dt
		var arena := horde.arena if horde else null
		# the room's cover stops every shot but a boss's crescents (cycle C12, BUG-015): it dies on the stone with a spark
		var stop := arena.shot_hit(s.pos, to, SHOT_EDGE, s.low) if arena != null and s.kind != Kind.SOUL else -1.0
		if stop >= 0.0:
			to = s.pos.lerp(to, stop)
		s.pos = to
		s.life -= dt
		s.age += dt
		s.flown += s.vel.length() * dt
		var gone := s.life <= 0.0 or (arena != null and not arena.bounds().grow(SHOT_MARGIN).has_point(s.pos))
		if stop >= 0.0:
			gone = true
			blocked += 1
			if hostile(s):
				shot_logged.emit(shooter(s), RoomTally.SHOT_BLOCKED, String(arena.last_cover.piece) if arena.last_cover else "")
			fx.burst(&"spark", Vector3(s.pos.x, LOW_HEIGHT if s.low else HEIGHT, s.pos.y), Vector3(-s.vel.x, 0, -s.vel.y).normalized())
		elif not gone:
			if s.kind == Kind.SOUL:
				if player.alive() and not s.seen.has(player) and touches_soul(s, player.pos, Player.RADIUS):
					s.seen[player] = true
					last_source = s.source
					last_by = s.by
					last_warn = s.warned + s.age
					last_offscreen = s.offscreen
					hit_player.emit(s.damage, s.pos - s.vel.normalized())
					fx.burst(&"soul", Vector3(player.pos.x, HEIGHT, player.pos.y))
			elif hostile(s):
				if player.alive() and s.pos.distance_to(player.pos) < s.radius + Player.RADIUS:
					var safe := player.invulnerable()
					last_source = s.source
					last_by = s.by
					last_warn = s.warned + s.age
					last_offscreen = s.offscreen
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


## Who fired a shot, for the run's log: its kind (EnemyDef.id), or "morvath" for the boss's own.
static func shooter(s: Shot) -> String:
	return shooter_of(s.by)


## The same, from the kind that fired it (Shot.by; &"": the boss's own).
static func shooter_of(by: StringName) -> String:
	return String(by) if by != &"" else "morvath"


static func hostile(s: Shot) -> bool:
	return s.kind == Kind.BOLT or s.kind == Kind.ORB or s.kind == Kind.SOUL or s.kind == Kind.CURSE


## A crescent (SOUL) touches a body of this radius at p: within its depth along the flight and its width across.
static func touches_soul(s: Shot, p: Vector2, radius: float) -> bool:
	var d := p - s.pos
	var ahead := s.vel.normalized()
	return absf(d.dot(ahead)) <= s.radius + radius and absf(d.cross(ahead)) <= s.half_width + radius * 0.5


func _place(s: Shot) -> void:
	s.node.position = Vector3(s.pos.x, SOUL_HEIGHT if s.kind == Kind.SOUL else (LOW_HEIGHT if s.low else HEIGHT), s.pos.y)
	if s.vel.length_squared() > 0.0:
		s.node.rotation.y = atan2(s.vel.x, s.vel.y)
	if s.kind == Kind.SOUL:
		_place_soul(s)
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
			# a boss's crescent of spectral fire (soul_crescent.gdshader) and its short trail (boss_wake.gdshader)
			mat.shader = SOUL_SHADER
			mat.set_shader_parameter(&"intensity", SOUL_INTENSITY)
			mi.add_child(_soul_trail())
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
		# a ball in the shooter's hue with a small heart and a soft blended halo (enemy_orb*.gdshader): one material
		# per part for every shot, the hue per shot (_tint), nothing over the glow threshold
		var sphere := SphereMesh.new()
		sphere.radius = look[1]
		sphere.height = look[1] * 2.0
		sphere.radial_segments = 10
		sphere.rings = 6
		mi.mesh = sphere
		mi.material_override = _orb_material(ORB_SHADER)
		if kind == Kind.BOLT:
			mi.scale = Vector3(0.6, 0.6, 2.4)
		var glow := MeshInstance3D.new()
		var q := QuadMesh.new()
		q.size = Vector2.ONE * look[1] * 2.0 * HALO
		glow.mesh = q
		glow.material_override = _orb_material(HALO_SHADER)
		glow.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		mi.add_child(glow)
	add_child(mi)
	return mi


## The colour of a pooled bolt or orb, its core and its halo: the hue of the shooter's magic (its largest channel
## at 1; the magic colours are written over 1 for the crowd's lamps and would draw white).
func _tint(node: Node3D, color: Color) -> void:
	var hue := Vector3(color.r, color.g, color.b) / maxf(maxf(color.r, color.g), maxf(color.b, 0.001))
	(node as GeometryInstance3D).set_instance_shader_parameter(&"hue", hue)
	for c in node.get_children():
		if c is GeometryInstance3D:
			(c as GeometryInstance3D).set_instance_shader_parameter(&"hue", hue)


## The shared material of an enemy shot's ball or halo.
func _orb_material(shader: Shader) -> ShaderMaterial:
	if not _orb_mats.has(shader):
		var m := ShaderMaterial.new()
		m.shader = shader
		_orb_mats[shader] = m
	return _orb_mats[shader]


func _release(s: Shot) -> void:
	s.node.visible = false
	s.node.scale = Vector3(0.6, 0.6, 2.4) if s.kind == Kind.BOLT else Vector3.ONE
	if s.kind == Kind.SPARK:
		# the dart breaks into a few chips of its own colour where it ends
		fx.chips(s.node.position, Vector3(s.vel.x, 0.0, s.vel.y), s.color, 5, 5.0, 0.1, 0.3, 0.9)
	elif s.kind == Kind.SOUL:
		# the crescent comes apart where it is: specks across its width drift on and rise, a wisp of its smoke
		var across := s.vel.normalized().orthogonal()
		for k in 3:
			var at := s.pos + across * s.half_width * (k - 1) * 0.6
			fx.chips(Vector3(at.x, SOUL_HEIGHT, at.y), Vector3(s.vel.x, 2.0, s.vel.y), s.color if k != 1 else Boss.VIOLET, 2, 2.5, 0.12, 0.45, 0.6)
		fx.burst(&"soul", Vector3(s.pos.x, SOUL_HEIGHT, s.pos.y))
	if not _pools.has(s.kind):
		_pools[s.kind] = []
	(_pools[s.kind] as Array).append(s.node)


## Meters across the crescent mesh at scale 1 (its two tips, 70 degrees each side of its middle).
const CRESCENT_SPAN := 1.88
## How bright a boss's crescent is drawn (it must not drown the warnings).
const SOUL_INTENSITY := 1.0
const SOUL_SHADER := preload("res://assets/shaders/soul_crescent.gdshader")
var _crescent_mesh: ArrayMesh

## Meters of trail a crescent leaves behind its middle at most: as far back as its hit reaches a body (SOUL_DEPTH
## plus the paladin's radius), the share of its width the trail takes, and how long it flares as it leaves and fades
## as it ends (s).
const SOUL_TRAIL := SOUL_DEPTH + Player.RADIUS
const SOUL_TRAIL_WIDTH := 0.55
const SOUL_FLARE := 0.12
const SOUL_FADE := 0.22


func _soul_trail() -> MeshInstance3D:
	var trail := MeshInstance3D.new()
	trail.mesh = Fx.strip()
	trail.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var mat := ShaderMaterial.new()
	mat.shader = Fx.WAKE
	mat.set_shader_parameter(&"trail_mode", true)
	mat.set_shader_parameter(&"body", Boss.VIOLET)
	mat.set_shader_parameter(&"edge", LOOK[Kind.SOUL][0])
	mat.set_shader_parameter(&"edge_light", 0.35)
	mat.set_shader_parameter(&"body_light", 0.45)
	trail.material_override = mat
	return trail


## The crescent's flare, fade and trail (its scale is the parent's: the trail is put back in meters).
func _place_soul(s: Shot) -> void:
	var mat: ShaderMaterial = (s.node as MeshInstance3D).material_override
	var fade := clampf(s.life / SOUL_FADE, 0.0, 1.0)
	mat.set_shader_parameter(&"fade", fade)
	mat.set_shader_parameter(&"flare", maxf(0.0, 1.0 - s.age / SOUL_FLARE))
	var trail: MeshInstance3D = s.node.get_child(0) if s.node.get_child_count() > 0 else null
	if trail == null:
		return
	var sx := maxf(s.node.scale.x, 0.001)
	var sz := maxf(s.node.scale.z, 0.001)
	var length := minf(s.flown, SOUL_TRAIL)
	trail.visible = length > 0.05
	trail.scale = Vector3(s.half_width * 2.0 * SOUL_TRAIL_WIDTH / sx, 1.0, length / sz)
	trail.position = Vector3(0.0, -0.02, -length / sz)
	(trail.material_override as ShaderMaterial).set_shader_parameter(&"fade", fade)


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
