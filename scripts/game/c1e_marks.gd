class_name C1eMarks
extends Node3D
## Lote C1e signals, drawing only (no rule, no number of play; the floor's warnings are Ground's): the thin amber ring that closes
## round a Gritador in its wind-up, an X of two thin bars where the Coveiro's dead will rise, and the thin ring at the feet of an
## enemy born with a modifier (ModDef.ring) or sped by a shout. It reads the crowd each frame; nothing reads it back. No disc: rings
## and bars only (the filled circle on the floor is Morvath's).

const RING_WIDTH := 0.06
const WIND_R0 := 2.4
const WIND_R1 := 0.5
const WIND_COLOR := Color(1.0, 0.78, 0.3)
const X_COLOR := Color(0.78, 0.9, 0.62)
const X_ARM := 0.5
## The Saltador's four corners in L (lote B): ember orange, thin, the colour of its warning on the floor.
const LEAP_COLOR := Color(1.0, 0.55, 0.15)
## The knight's flying shield: its rim (radius, the height of its arc) and the colour of it and of the corners where it lands.
const SHIELD_COLOR := Color(0.85, 0.88, 0.95)
const SHIELD_R := 0.6
const SHIELD_ARC := 5.0
## The shield on the floor sits this far off it (meters, times the knight's size is added by its own half height).
const SHIELD_REST := 0.02
## The Armadilheiro's plate (lote C): an X of two thin bars and the four edges of its square, ivory, brightening as it nears the spikes.
const PLATE_COLOR := Color(0.96, 0.92, 0.78)
const HASTE_COLOR := Color(1.0, 0.95, 0.7)
const FOOT_ALPHA := 0.8

var horde: Horde
## The floor (the Armadilheiro's plates are its zones tagged Ground.PLATE_TAG: this draws their X).
var ground: Ground
var _rings: Array[MeshInstance3D] = []
var _bars: Array[MeshInstance3D] = []
var _mats: Dictionary = {}
var _ring_mesh: TorusMesh
var _bar_mesh: BoxMesh
## The knight's own shield, cut from its model (ThrownShield), one mesh and material for all, and the nodes in use.
var _shield_mesh: ArrayMesh
var _shield_mat: StandardMaterial3D
var _shield_nodes: Array[MeshInstance3D] = []


## The radius of the Gritador's closing ring `t` seconds into a wind-up of `windup` s.
static func wind_radius(t: float, windup: float) -> float:
	return lerpf(WIND_R0, WIND_R1, clampf(t / maxf(windup, 0.001), 0.0, 1.0))


func step() -> void:
	if horde == null:
		return
	var ring_n := 0
	var bar_n := 0
	var shield_n := 0
	for e in horde.list:
		if not e.alive or e.state == Enemy.State.DOWN:
			continue
		var d := e.def
		if d.behavior == EnemyDef.Behavior.SUPPORT and e.state == Enemy.State.WINDUP:
			if d.shout_radius > 0.0:
				_put_ring(ring_n, e.pos, wind_radius(e.state_t, d.attack_windup), WIND_COLOR, 0.9)
				ring_n += 1
			for at in e.spots:
				for sign in [1.0, -1.0]:
					var m := _node(_bars, bar_n, false, X_COLOR)
					bar_n += 1
					m.position = Vector3(at.x, 0.075, at.y)
					m.rotation = Vector3(0.0, sign * PI * 0.25, 0.0)
					m.scale = Vector3.ONE
		if d.behavior == EnemyDef.Behavior.LEAP and e.state == Enemy.State.WINDUP and not e.helpless():
			bar_n = _put_corners(bar_n, e.lands_at, LeapRules.corner_at(e.state_t, d.attack_windup, d.leap_half), LEAP_COLOR)
		if e.mod != null:
			_put_ring(ring_n, e.pos, 0.75 * d.size, e.mod.ring, FOOT_ALPHA)
			ring_n += 1
		if e.haste_t > 0.0:
			_put_ring(ring_n, e.pos, 0.55 * d.size, HASTE_COLOR, 0.5)
			ring_n += 1
	# the knight's shield in the air: four corners closing on where it will land, and the shield itself (a steel rim) in its arc
	for sh in horde.shields:
		var half := sh.owner.def.throw_half
		bar_n = _put_corners(bar_n, sh.land, LeapRules.corner_at(sh.t, sh.total, half), LEAP_COLOR)
		var k := clampf(sh.t / maxf(sh.total, 0.001), 0.0, 1.0)
		var at := sh.from.lerp(sh.land, k)
		if _put_shield(shield_n, sh.owner, at, 1.0 + ThrownShield.arc(k, SHIELD_ARC), ThrownShield.flight_basis(sh.t, sh.total)):
			shield_n += 1
		else:
			_put_ring(ring_n, at, SHIELD_R, SHIELD_COLOR, 1.0, 1.0 + ThrownShield.arc(k, SHIELD_ARC))
			ring_n += 1
	# and lying where it landed until it is back in his hand (Enemy.away_t counts down)
	for e in horde.list:
		if e.alive and e.away_t > 0.0 and e.away_t < 90.0 and e.def.throw_flight > 0.0:
			if _put_shield(shield_n, e, e.shield_lies, 0.0, ThrownShield.flight_basis(e.def.throw_flight, e.def.throw_flight)):
				shield_n += 1
	if ground != null:
		for z in ground.zones:
			if z.tags.has(Ground.PLATE_TAG) and z.life > 0.0:
				bar_n = _put_plate(bar_n, z)
	_hide_from(_rings, ring_n)
	_hide_from(_bars, bar_n)
	_hide_from(_shield_nodes, shield_n)


## The four corners in L round `at` (a square of half-side `c`), returning the bars used so far.
func _put_corners(bar_n: int, at: Vector2, c: float, color: Color) -> int:
	for sx in [1.0, -1.0]:
		for sz in [1.0, -1.0]:
			# an L: one bar along each edge of the square, from the corner inward
			for along_x in [true, false]:
				var m := _node(_bars, bar_n, false, color)
				bar_n += 1
				var corner := Vector2(at.x + sx * c, at.y + sz * c)
				var inward := Vector2(-sx, 0.0) if along_x else Vector2(0.0, -sz)
				var mid := corner + inward * LeapRules.ARM * 0.5
				m.position = Vector3(mid.x, 0.075, mid.y)
				m.rotation = Vector3(0.0, 0.0 if along_x else PI * 0.5, 0.0)
				m.scale = Vector3(LeapRules.ARM, 1.0, 1.7)
	return bar_n


## The plate's X and square (a plate is the zone's line: `radius` along, `width` across), returning the bars used so far.
func _put_plate(bar_n: int, z: Ground.Zone) -> int:
	var c := z.pos + z.dir * z.radius * 0.5
	var half := z.width * 0.5
	var alpha := 0.55 + 0.45 * clampf(1.0 - z.life / maxf(z.total, 0.001), 0.0, 1.0)
	for sign in [1.0, -1.0]:
		var m := _node(_bars, bar_n, false, Color(PLATE_COLOR, alpha))
		bar_n += 1
		m.position = Vector3(c.x, 0.075, c.y)
		m.rotation = Vector3(0.0, sign * PI * 0.25, 0.0)
		m.scale = Vector3(half * 1.4 / X_ARM, 1.0, 1.0)
	for k in 4:
		var m := _node(_bars, bar_n, false, Color(PLATE_COLOR, alpha * 0.8))
		bar_n += 1
		var side := Vector2.RIGHT.rotated(PI * 0.5 * k)
		var at := c + side * half
		m.position = Vector3(at.x, 0.075, at.y)
		m.rotation = Vector3(0.0, 0.0 if k % 2 == 1 else PI * 0.5, 0.0)
		m.scale = Vector3(half / X_ARM, 1.0, 1.0)
	return bar_n


## Puts the knight's own shield `lift` over the floor at `at` (the ground plane), turned by `basis`; false when the model
## has none to cut (the caller draws the steel ring instead).
func _put_shield(i: int, knight: Enemy, at: Vector2, lift: float, basis: Basis) -> bool:
	if _shield_mesh == null:
		var baked := horde.renderer.model_of(knight.def)
		_shield_mesh = ThrownShield.build(baked)
		if _shield_mesh == null:
			return false
		_shield_mat = ThrownShield.material(baked)
	if i >= _shield_nodes.size():
		var m := MeshInstance3D.new()
		m.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		m.mesh = _shield_mesh
		m.material_override = _shield_mat
		add_child(m)
		_shield_nodes.append(m)
	var node := _shield_nodes[i]
	var size := knight.def.size
	node.visible = true
	node.position = Vector3(at.x, SHIELD_REST + (ThrownShield.half_height(_shield_mesh) * size) + lift, at.y)
	node.basis = basis.scaled(Vector3.ONE * size)
	return true


func _put_ring(i: int, at: Vector2, r: float, color: Color, alpha: float, y := 0.07) -> void:
	var m := _node(_rings, i, true, Color(color, alpha))
	m.position = Vector3(at.x, y, at.y)
	m.scale = Vector3(r, 1.0, r)


func _hide_from(pool: Array[MeshInstance3D], used: int) -> void:
	for i in range(used, pool.size()):
		pool[i].visible = false


func _node(pool: Array[MeshInstance3D], i: int, ring: bool, color: Color) -> MeshInstance3D:
	if i >= pool.size():
		var m := MeshInstance3D.new()
		m.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		m.mesh = _ring() if ring else _bar()
		add_child(m)
		pool.append(m)
	var node := pool[i]
	node.material_override = _flat(color)
	node.visible = true
	return node


func _ring() -> TorusMesh:
	if _ring_mesh == null:
		_ring_mesh = TorusMesh.new()
		_ring_mesh.inner_radius = 1.0 - RING_WIDTH
		_ring_mesh.outer_radius = 1.0
		_ring_mesh.rings = 40
		_ring_mesh.ring_segments = 4
	return _ring_mesh


func _bar() -> BoxMesh:
	if _bar_mesh == null:
		_bar_mesh = BoxMesh.new()
		_bar_mesh.size = Vector3(X_ARM * 2.0, 0.01, 0.07)  # (a Saltador's L scales it: x to its arm over this)
	return _bar_mesh


func _flat(c: Color) -> StandardMaterial3D:
	var key := c.to_html()
	if not _mats.has(key):
		var m := StandardMaterial3D.new()
		m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		m.albedo_color = c
		m.cull_mode = BaseMaterial3D.CULL_DISABLED
		_mats[key] = m
	return _mats[key]
