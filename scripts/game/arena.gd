class_name Arena
extends Node3D
## The great hall of the catacombs under the old church of Valmor, built from the dungeon kit:
## a square floor of stone tiles, walls on three sides (the camera looks in from the open south),
## pillars that block the way, torches on the walls. Positions on the floor are Vector2 (x, z) in meters.

const HALF := 36.0
const TILE := 4.0
const DUNGEON := "res://assets/models/dungeon/"
## Layer of the crowd: torches do not light it (CrowdRenderer adds the hero's light itself).
const CROWD_LAYER := 2
## Pillars that stand in the hall: (x, z) and the radius that blocks movement.
const PILLARS: Array[Vector3] = [
	Vector3(-14, -14, 1.0), Vector3(14, -14, 1.0), Vector3(-14, 14, 1.0), Vector3(14, 14, 1.0),
	Vector3(-26, 0, 1.0), Vector3(26, 0, 1.0), Vector3(0, -26, 1.0), Vector3(0, 24, 1.0),
	Vector3(-27, -25, 1.0), Vector3(27, -25, 1.0), Vector3(-27, 25, 1.0), Vector3(27, 25, 1.0),
]
const FLOOR_VARIANTS: Array[String] = ["floor_tile_large"]
const WALL_VARIANTS: Array[String] = ["wall", "wall", "wall_cracked", "wall_arched", "wall", "wall_broken"]

## Where Morvath's crypt opens, in the middle of the north wall.
var door_pos := Vector2(0, -HALF + 2.0)
var _meshes: Dictionary = {}
var _rng := RandomNumberGenerator.new()
var _door_light: OmniLight3D


func build() -> void:
	_rng.seed = 1406
	_floor()
	_walls()
	for p in PILLARS:
		_place("pillar_decorated" if _rng.randf() < 0.5 else "pillar", Vector3(p.x, 0, p.y), _rng.randi() % 4 * PI * 0.5)
		for k in 2:
			var a := _rng.randf() * TAU
			_place("candle_triple" if k == 0 else "candle_lit", Vector3(p.x + cos(a) * 1.4, 0, p.y + sin(a) * 1.4), _rng.randf() * TAU)
	_decorate()


## Keeps a circle of this radius inside the hall and out of the pillars.
func resolve(pos: Vector2, radius: float) -> Vector2:
	var lim := HALF - 1.2 - radius
	pos.x = clampf(pos.x, -lim, lim)
	pos.y = clampf(pos.y, -lim, lim)
	for p in PILLARS:
		var c := Vector2(p.x, p.y)
		var d := pos - c
		var min_d := p.z + radius
		if d.length_squared() < min_d * min_d:
			pos = c + (d.normalized() if d.length_squared() > 0.0001 else Vector2.DOWN) * min_d
	return pos


func inside(pos: Vector2, margin: float = 0.0) -> bool:
	var lim := HALF - 1.2 - margin
	return absf(pos.x) < lim and absf(pos.y) < lim


## The crypt doors open for the last fight: a cold light in the north wall.
func open_door() -> void:
	if _door_light:
		_door_light.light_color = Color(0.75, 0.45, 1.0)
		_door_light.light_energy = 6.0
		_door_light.omni_range = 16.0


func _floor() -> void:
	var n := int(HALF * 2.0 / TILE)
	for ix in n:
		for iz in n:
			var x := -HALF + TILE * (ix + 0.5)
			var z := -HALF + TILE * (iz + 0.5)
			var v: String = FLOOR_VARIANTS[_rng.randi() % FLOOR_VARIANTS.size()]
			_place(v, Vector3(x, 0, z), _rng.randi() % 4 * PI * 0.5)
	# a dark skirt beyond the hall so the edges never show the void
	var skirt := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(HALF * 6.0, HALF * 6.0)
	skirt.mesh = plane
	var m := StandardMaterial3D.new()
	m.albedo_color = Color(0.035, 0.03, 0.05)
	skirt.material_override = m
	skirt.position.y = -0.12
	add_child(skirt)


func _walls() -> void:
	var n := int(HALF * 2.0 / TILE)
	for i in n:
		var t := -HALF + TILE * (i + 0.5)
		var north: String = WALL_VARIANTS[_rng.randi() % WALL_VARIANTS.size()]
		if i == n / 2 or i == n / 2 - 1:
			north = "wall_arched"
		_place(north, Vector3(t, 0, -HALF - 0.5), 0.0)
		_place(WALL_VARIANTS[_rng.randi() % WALL_VARIANTS.size()], Vector3(-HALF - 0.5, 0, t), PI * 0.5)
		_place(WALL_VARIANTS[_rng.randi() % WALL_VARIANTS.size()], Vector3(HALF + 0.5, 0, t), -PI * 0.5)
		# torches every other wall piece
		if i % 2 == 1:
			_torch(Vector3(t, 2.4, -HALF + 0.1), 0.0)
			_torch(Vector3(-HALF + 0.1, 2.4, t), PI * 0.5)
			_torch(Vector3(HALF - 0.1, 2.4, t), -PI * 0.5)
		# the open south side: a broken line of rubble and low stones
		if _rng.randf() < 0.55:
			_place("rubble_large" if _rng.randf() < 0.5 else "rubble_half", Vector3(t + _rng.randf_range(-1, 1), 0, HALF + 0.6), _rng.randf() * TAU)
	for c: Vector2 in [Vector2(-1, -1), Vector2(1, -1)]:
		_place("wall_corner", Vector3(c.x * (HALF + 0.5), 0, c.y * (HALF + 0.5)), 0.0 if c.x < 0 else -PI * 0.5)
	_door_light = OmniLight3D.new()
	_door_light.position = Vector3(door_pos.x, 2.5, door_pos.y)
	_door_light.light_color = Color(0.5, 0.4, 0.8)
	_door_light.light_energy = 1.5
	_door_light.omni_range = 9.0
	_door_light.light_cull_mask = ~CROWD_LAYER
	add_child(_door_light)


func _torch(pos: Vector3, yaw: float) -> void:
	_place("torch_mounted", pos, yaw)
	var l := OmniLight3D.new()
	l.position = pos + Vector3(sin(yaw), 0.5, cos(yaw)) * 0.6
	l.light_color = Color(1.0, 0.6, 0.3)
	l.light_energy = 2.2
	l.omni_range = 8.0
	l.omni_attenuation = 1.4
	l.light_cull_mask = ~CROWD_LAYER
	add_child(l)
	var flame := CPUParticles3D.new()
	flame.position = pos + Vector3(sin(yaw), 0.65, cos(yaw)) * 0.45
	flame.amount = 10
	flame.lifetime = 0.5
	flame.direction = Vector3.UP
	flame.spread = 12.0
	flame.initial_velocity_min = 0.6
	flame.initial_velocity_max = 1.2
	flame.gravity = Vector3(0, 1.0, 0)
	flame.scale_amount_min = 0.5
	flame.scale_amount_max = 0.9
	flame.mesh = Fx.quad(0.22, Color(3.0, 1.4, 0.4))
	flame.color_ramp = Fx.fade_ramp(Color(1, 1, 1, 1))
	add_child(flame)


func _decorate() -> void:
	var props: Array[String] = ["barrel_large", "rubble_half", "rubble_large", "sword_shield_broken", "rubble_half"]
	for i in 26:
		var side := _rng.randi() % 3
		var t := _rng.randf_range(-HALF + 3.0, HALF - 3.0)
		var pos := Vector3(t, 0, -HALF + 1.6) if side == 0 else Vector3(-HALF + 1.6, 0, t) if side == 1 else Vector3(HALF - 1.6, 0, t)
		if absf(pos.x - door_pos.x) < 5.0 and side == 0:
			continue
		_place(props[_rng.randi() % props.size()], pos, _rng.randf() * TAU)
	for i in 8:
		var banner := "banner_patternA_white" if i % 3 else "banner_thin_yellow"
		if i < 4:
			_place(banner, Vector3(_rng.randf_range(-28, 28), 0, -HALF + 0.1), 0.0)
		else:
			var side := -1.0 if i % 2 == 0 else 1.0
			_place(banner, Vector3(side * (HALF - 0.1), 0, _rng.randf_range(-28, 28)), -side * PI * 0.5)
	_place("stairs_wide", Vector3(door_pos.x, 0, -HALF + 2.0), 0.0)


## A mesh of the dungeon kit at a spot, turned around Y.
func _place(name_: String, pos: Vector3, yaw: float) -> MeshInstance3D:
	if not _meshes.has(name_):
		var scene: Node = (load(DUNGEON + name_ + ".glb") as PackedScene).instantiate()
		var mi := _first_mesh(scene)
		_meshes[name_] = [mi.mesh, mi.transform]
		scene.free()
	var entry: Array = _meshes[name_]
	var out := MeshInstance3D.new()
	out.mesh = entry[0]
	out.transform = Transform3D(Basis(Vector3.UP, yaw), pos) * (entry[1] as Transform3D)
	add_child(out)
	return out


func _first_mesh(n: Node) -> MeshInstance3D:
	if n is MeshInstance3D:
		return n
	for c in n.get_children():
		var m := _first_mesh(c)
		if m:
			return m
	return null
