class_name Ground
extends Node3D
## Areas on the floor. WARNING: an enemy attack announced before it lands (hurts the paladin when it fills).
## The others hurt enemies standing in them every TICK: EMBER (fire), MARK (light), HOLY (consecrated, slows),
## STEAM (blinds), BIND (the paladin's circle of light: holds the enemies inside). Positions are (x, z) in meters.

signal hit_player(amount: float, from: Vector2)

enum Kind { WARNING, EMBER, MARK, HOLY, STEAM, BIND }
enum Shape { CIRCLE, LINE, ARC }

const SHADER := preload("res://assets/shaders/ground.gdshader")
const TICK := 0.25
const POOL := 48
## Strength of the drawing of each kind of area: warnings bright enough to read on the dark floor, the paladin's
## circle of light (big, 3 s) a soft glow so the fight inside still reads, the rest in between.
const WARNING_STRENGTH := 1.4
const BIND_STRENGTH := 0.24
const AREA_STRENGTH := 0.8
## Meters of the bright rim around a warning (its size is always the attack's).
const RIM_METERS := 0.28
## The ring where an enemy's blow lands, when its caster has no colour of its own.
const LAND_COLOR := Color(1.0, 0.3, 0.2)
const COLORS := {
	Kind.WARNING: Color(1.0, 0.18, 0.12), Kind.EMBER: Color(1.0, 0.42, 0.1), Kind.MARK: Color(1.0, 0.82, 0.35),
	Kind.HOLY: Color(1.0, 0.85, 0.45), Kind.STEAM: Color(0.75, 0.85, 0.95), Kind.BIND: Color(1.0, 0.95, 0.8),
}

class Zone:
	var kind := Kind.WARNING
	var shape := Shape.CIRCLE
	var pos := Vector2.ZERO
	var dir := Vector2.DOWN
	## Circle and arc: radius. Line: length.
	var radius := 1.0
	## Line: width. Arc: opening in degrees.
	var width := 1.0
	var life := 1.0
	var total := 1.0
	var power := 0.0
	var tick := 0.0
	var color := Color.WHITE
	var tags: Array[StringName] = []
	## Colour of the ring where a warning lands (alpha 0: LAND_COLOR).
	var land_color := Color(0, 0, 0, 0)
	## Damage dealt to everything inside when the zone runs out (the held circle of light). 0 = none.
	var burst := 0.0
	var node: MeshInstance3D
	var mat: ShaderMaterial

var zones: Array[Zone] = []
var player: Player
## Called with (enemy, zone) for every enemy inside a damaging area at each tick.
var on_zone_hit: Callable
## Called with (zone) when a zone with a burst runs out.
var on_zone_burst: Callable
var horde: Horde
var fx: Fx
var _pool: Array[MeshInstance3D] = []
var _found: Array[Enemy] = []


## burst: the colour of the magic where the blow lands (the caster's EnemyDef.magic_color); alpha 0: the default.
func add_warning(at: Vector2, radius: float, time: float, damage: float, burst := Color(0, 0, 0, 0)) -> Zone:
	var z := _add(Kind.WARNING, Shape.CIRCLE, at, Vector2.DOWN, radius, 0.0, time, damage)
	z.land_color = burst
	return z


func add_line_warning(from: Vector2, dir: Vector2, length: float, width: float, time: float, damage: float) -> Zone:
	return _add(Kind.WARNING, Shape.LINE, from, dir, length, width, time, damage)


func add_arc_warning(at: Vector2, dir: Vector2, radius: float, degrees: float, time: float, damage: float) -> Zone:
	return _add(Kind.WARNING, Shape.ARC, at, dir, radius, degrees, time, damage)


func add_zone(kind: Kind, at: Vector2, radius: float, time: float, power: float, tags: Array[StringName] = []) -> Zone:
	var z := _add(kind, Shape.CIRCLE, at, Vector2.DOWN, radius, 0.0, time, power)
	z.tags = tags
	return z


func clear_warnings() -> void:
	for z in zones:
		if z.kind == Kind.WARNING:
			z.life = -1.0
			z.power = 0.0


func clear() -> void:
	for z in zones:
		_release(z)
	zones.clear()


static func inside(z: Zone, p: Vector2, margin: float = 0.0) -> bool:
	var d := p - z.pos
	match z.shape:
		Shape.LINE:
			var along := d.dot(z.dir)
			return along >= -margin and along <= z.radius + margin and absf(d.cross(z.dir)) <= z.width * 0.5 + margin
		Shape.ARC:
			return d.length() <= z.radius + margin and (d.length() < 0.6 or absf(z.dir.angle_to(d)) <= deg_to_rad(z.width) * 0.5)
	return d.length() <= z.radius + margin


func step(dt: float) -> void:
	var i := zones.size() - 1
	while i >= 0:
		# a landing blow can end the run and clear every zone
		if i >= zones.size():
			i = zones.size() - 1
			continue
		var z := zones[i]
		z.life -= dt
		if z.kind == Kind.WARNING:
			if z.life <= 0.0:
				if z.power > 0.0:
					_land(z)
				if zones.has(z):
					_release(z)
					zones.erase(z)
			else:
				z.mat.set_shader_parameter(&"progress", 1.0 - z.life / z.total)
		else:
			z.tick -= dt
			if z.tick <= 0.0:
				z.tick = TICK
				horde.in_circle(z.pos, z.radius, _found)
				for e in _found.duplicate():
					on_zone_hit.call(e, z)
			z.mat.set_shader_parameter(&"fade", clampf(z.life / 0.4, 0.0, 1.0) * clampf((z.total - z.life) / 0.2, 0.0, 1.0))
			if z.life <= 0.0 and zones.has(z):
				_release(z)
				zones.erase(z)
				if z.burst > 0.0 and on_zone_burst.is_valid():
					on_zone_burst.call(z)
		i -= 1


## A warning fills: the blow lands. A burst shows where, and the paladin is hit if still inside.
func _land(z: Zone) -> void:
	var center := z.pos + (z.dir * z.radius * 0.5 if z.shape == Shape.LINE else Vector2.ZERO)
	if z.shape == Shape.CIRCLE:
		fx.ring(z.pos, z.radius * 1.1, z.land_color if z.land_color.a > 0.0 else LAND_COLOR, 0.3)
		fx.burst(&"shadow", Vector3(z.pos.x, 0.3, z.pos.y))
	if player and player.alive() and inside(z, player.pos, Player.RADIUS * 0.6):
		hit_player.emit(z.power, center)


func _add(kind: Kind, shape: Shape, at: Vector2, dir: Vector2, radius: float, width: float, time: float, power: float) -> Zone:
	var z := Zone.new()
	z.kind = kind
	z.shape = shape
	z.pos = at
	z.dir = dir.normalized() if dir.length_squared() > 0.0001 else Vector2.DOWN
	z.radius = radius
	z.width = width
	z.life = time
	z.total = time
	z.power = power
	z.color = COLORS[kind]
	z.node = _pool.pop_back() if not _pool.is_empty() else _new_node()
	z.mat = z.node.material_override
	z.node.visible = true
	var m := z.mat
	m.set_shader_parameter(&"color", z.color)
	m.set_shader_parameter(&"progress", 0.0)
	m.set_shader_parameter(&"style", 0 if kind == Kind.WARNING else 1)
	m.set_shader_parameter(&"shape", shape)
	m.set_shader_parameter(&"fade", 1.0)
	m.set_shader_parameter(&"strength", WARNING_STRENGTH if kind == Kind.WARNING else BIND_STRENGTH if kind == Kind.BIND else AREA_STRENGTH)
	m.set_shader_parameter(&"size_m", maxf(0.1, width * 0.5 if shape == Shape.LINE else radius))
	m.set_shader_parameter(&"rim_m", RIM_METERS)
	var y := 0.06 + zones.size() * 0.0005
	match shape:
		Shape.LINE:
			z.node.scale = Vector3(width, 1.0, radius)
			z.node.rotation = Vector3(0, atan2(z.dir.x, z.dir.y), 0)
			var mid := at + z.dir * radius * 0.5
			z.node.position = Vector3(mid.x, y, mid.y)
		Shape.ARC:
			m.set_shader_parameter(&"arc_half", deg_to_rad(width) * 0.5)
			z.node.scale = Vector3(radius * 2.0, 1.0, radius * 2.0)
			# the shader opens the arc towards -V of the quad; turn the quad so that points along dir
			z.node.rotation = Vector3(0, atan2(-z.dir.x, -z.dir.y), 0)
			z.node.position = Vector3(at.x, y, at.y)
		_:
			z.node.scale = Vector3(radius * 2.0, 1.0, radius * 2.0)
			z.node.rotation = Vector3.ZERO
			z.node.position = Vector3(at.x, y, at.y)
	zones.append(z)
	return z


func _new_node() -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(1, 1)
	mi.mesh = plane
	var mat := ShaderMaterial.new()
	mat.shader = SHADER
	mi.material_override = mat
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(mi)
	return mi


func _release(z: Zone) -> void:
	z.node.visible = false
	_pool.append(z.node)
