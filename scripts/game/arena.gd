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
## Multiplies the kit's warm sandstone into cool slate (the painterly night look).
const STONE_TINT := Color(0.6, 0.74, 0.8)
## Cold light that falls through cracks in the church floor above: (x, z) on the floor.
## Dust in each shaft: specks, seconds each lives, meters across and above the floor, size, colour (additive).
const DUST_AMOUNT := 36
const DUST_LIFE := 7.0
const DUST_RADIUS := 2.4
const DUST_HEIGHT := 5.0
const DUST_SIZE := 0.08
const DUST_COLOR := Color(0.4, 0.5, 0.55)
## The painted floor overlay is cut in this many pieces a side.
const FLOOR_CHUNKS := 8
const SHAFTS: Array[Vector2] = [Vector2(-6, 4), Vector2(9, -8), Vector2(-18, -16), Vector2(19, 12), Vector2(-20, 20), Vector2(2, -19)]

## Half the size of the room (x, z). The great hall of the endless mode is HALF on both.
var half := Vector2(HALF, HALF)
var pillars: Array[Vector3] = PILLARS
var shafts: Array[Vector2] = SHAFTS
## Doors out of the room, in the north wall (x, z of the doorway on the floor).
var exits: Array[Vector2] = []
## Floor footprints of the solid props (stairs, rubble, barrels): nobody walks through or under them.
var boxes: Array[Rect2] = []
## How far into the room the stairs of a door reach: the paladin leaves by stepping onto them.
const STAIRS_DEPTH := 4.0
## Half the width of a flight of stairs, a little less than the model (the paladin leaves by touching its foot).
const STAIRS_HALF_WIDTH := 3.3
## Meters between the middles of two doors.
const STAIRS_GAP := 8.5
## Share of a rough prop's footprint that blocks (its outline is ragged; the bounding box would feel like glass).
const ROUGH_SOLID := 0.7
var _exit_lights: Array[OmniLight3D] = []
## The great hall (no layout): the open south side gets a line of rubble. Rooms keep it clear, since the low
## camera looks in from there.
var _hall := true
## Where Morvath's crypt opens, in the middle of the north wall.
var door_pos := Vector2(0, -HALF + 2.0)
var _meshes: Dictionary = {}
var _rng := RandomNumberGenerator.new()
var _door_light: OmniLight3D
var _torches: PackedVector2Array = []


## Builds the room. layout: its size and pillars (none: the great hall). exit_count: doors in the north wall.
func build(layout: RoomLayout = null, exit_count: int = 0, seed_: int = 1406) -> void:
	_rng.seed = seed_
	_hall = layout == null
	if layout != null:
		half = layout.half
		pillars = layout.pillars
		shafts = layout.shafts
	door_pos = Vector2(0, -half.y + 2.0)
	exits.clear()
	boxes.clear()
	for i in exit_count:
		# far enough apart that two flights of stairs (7 m wide) never overlap
		var spread := maxf(half.x * 0.55, STAIRS_GAP * (exit_count - 1) * 0.5)
		var x := 0.0 if exit_count == 1 else lerpf(-spread, spread, float(i) / (exit_count - 1))
		# on the middle of a wall piece, so the arched piece is the doorway
		var piece := clampi(roundi((x + half.x) / TILE - 0.5), 0, ceili(half.x * 2.0 / TILE) - 1)
		exits.append(Vector2(-half.x + TILE * (piece + 0.5), -half.y + 1.0))
	_floor()
	_walls()
	for p in pillars:
		_place("pillar_decorated" if _rng.randf() < 0.5 else "pillar", Vector3(p.x, 0, p.y), _rng.randi() % 4 * PI * 0.5)
		for k in 2:
			var a := _rng.randf() * TAU
			_place("candle_triple" if k == 0 else "candle_lit", Vector3(p.x + cos(a) * 1.4, 0, p.y + sin(a) * 1.4), _rng.randf() * TAU)
	_decorate()
	_shafts()
	_floor_detail()


## Keeps a circle of this radius inside the hall and out of the pillars.
func resolve(pos: Vector2, radius: float) -> Vector2:
	pos.x = clampf(pos.x, -half.x + 1.2 + radius, half.x - 1.2 - radius)
	pos.y = clampf(pos.y, -half.y + 1.2 + radius, half.y - 1.2 - radius)
	for p in pillars:
		var c := Vector2(p.x, p.y)
		var d := pos - c
		var min_d := p.z + radius
		if d.length_squared() < min_d * min_d:
			pos = c + (d.normalized() if d.length_squared() > 0.0001 else Vector2.DOWN) * min_d
	for b in boxes:
		pos = push_out_of_box(pos, radius, b)
	return pos


## Moves a circle out of a rectangle on the floor (the shortest way out when its centre is inside).
static func push_out_of_box(pos: Vector2, radius: float, b: Rect2) -> Vector2:
	var q := pos.clamp(b.position, b.end)
	var d := pos - q
	var len_sq := d.length_squared()
	if len_sq >= radius * radius:
		return pos
	if len_sq > 0.000001:
		return q + d / sqrt(len_sq) * radius
	var left := pos.x - b.position.x
	var right := b.end.x - pos.x
	var top := pos.y - b.position.y
	var bottom := b.end.y - pos.y
	var least := minf(minf(left, right), minf(top, bottom))
	if least == bottom:
		return Vector2(pos.x, b.end.y + radius)
	if least == top:
		return Vector2(pos.x, b.position.y - radius)
	if least == left:
		return Vector2(b.position.x - radius, pos.y)
	return Vector2(b.end.x + radius, pos.y)


func inside(pos: Vector2, margin: float = 0.0) -> bool:
	return absf(pos.x) < half.x - 1.2 - margin and absf(pos.y) < half.y - 1.2 - margin


## Lights a door (its reward can be taken through it) or dims it.
func light_exit(i: int, on: bool, color: Color = Color(1.0, 0.85, 0.5)) -> void:
	if i < _exit_lights.size():
		_exit_lights[i].light_color = color
		_exit_lights[i].light_energy = 5.0 if on else 0.6


## The door the paladin stands in, or -1.
func exit_at(pos: Vector2) -> int:
	var foot := -half.y + 1.4 + STAIRS_DEPTH
	for i in exits.size():
		if absf(pos.x - exits[i].x) < STAIRS_HALF_WIDTH and pos.y < foot + 1.0:
			return i
	return -1


## The crypt doors open for the last fight: a cold light in the north wall.
func open_door() -> void:
	if _door_light:
		_door_light.light_color = Color(0.75, 0.45, 1.0)
		_door_light.light_energy = 6.0
		_door_light.omni_range = 16.0


func _floor() -> void:
	var nx := ceili(half.x * 2.0 / TILE)
	var nz := ceili(half.y * 2.0 / TILE)
	for ix in nx:
		for iz in nz:
			var x := -half.x + TILE * (ix + 0.5)
			var z := -half.y + TILE * (iz + 0.5)
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
	var nx := ceili(half.x * 2.0 / TILE)
	var nz := ceili(half.y * 2.0 / TILE)
	for i in nx:
		var t := -half.x + TILE * (i + 0.5)
		var north: String = WALL_VARIANTS[_rng.randi() % WALL_VARIANTS.size()]
		if (exits.is_empty() and (i == nx / 2 or i == nx / 2 - 1)) or _near_exit(t):
			north = "wall_arched"
		_place(north, Vector3(t, 0, -half.y - 0.5), 0.0)
		if i % 2 == 1 and not _near_exit(t):
			_torch(Vector3(t, 2.4, -half.y + 0.1), 0.0)
		# the open south side: a broken line of rubble and low stones
		if _hall and _rng.randf() < 0.55:
			_place("rubble_large" if _rng.randf() < 0.5 else "rubble_half", Vector3(t + _rng.randf_range(-1, 1), 0, half.y + 0.6), _rng.randf() * TAU)
	for i in nz:
		var t := -half.y + TILE * (i + 0.5)
		_place(WALL_VARIANTS[_rng.randi() % WALL_VARIANTS.size()], Vector3(-half.x - 0.5, 0, t), PI * 0.5)
		_place(WALL_VARIANTS[_rng.randi() % WALL_VARIANTS.size()], Vector3(half.x + 0.5, 0, t), -PI * 0.5)
		if i % 2 == 1:
			_torch(Vector3(-half.x + 0.1, 2.4, t), PI * 0.5)
			_torch(Vector3(half.x - 0.1, 2.4, t), -PI * 0.5)
	for c: Vector2 in [Vector2(-1, -1), Vector2(1, -1)]:
		_place("wall_corner", Vector3(c.x * (half.x + 0.5), 0, c.y * (half.y + 0.5)), 0.0 if c.x < 0 else -PI * 0.5)
	_exit_lights.clear()
	for x in exits:
		_place("stairs_wide", Vector3(x.x, 0, -half.y + 1.4), 0.0, 1.0)
		var l := OmniLight3D.new()
		l.position = Vector3(x.x, 2.6, -half.y + 1.2)
		l.light_color = Color(0.5, 0.45, 0.6)
		l.light_energy = 0.6
		l.omni_range = 7.0
		l.light_cull_mask = ~CROWD_LAYER
		add_child(l)
		_exit_lights.append(l)
	_door_light = OmniLight3D.new()
	_door_light.position = Vector3(door_pos.x, 2.5, door_pos.y)
	_door_light.light_color = Color(0.5, 0.4, 0.8)
	_door_light.light_energy = 1.5
	_door_light.omni_range = 9.0
	_door_light.light_cull_mask = ~CROWD_LAYER
	add_child(_door_light)


func _torch(pos: Vector3, yaw: float) -> void:
	_place("torch_mounted", pos, yaw)
	_torches.append(Vector2(pos.x + sin(yaw) * 2.0, pos.z + cos(yaw) * 2.0))
	var l := OmniLight3D.new()
	l.position = pos + Vector3(sin(yaw), 0.5, cos(yaw)) * 0.6
	l.light_color = Color(1.0, 0.6, 0.3)
	l.light_energy = 1.8
	l.omni_range = 9.0
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
	for i in int((half.x + half.y) * 0.36):
		var side := _rng.randi() % 3
		var pos := Vector3(_rng.randf_range(-half.x + 3.0, half.x - 3.0), 0, -half.y + 1.6) if side == 0 \
			else Vector3(-half.x + 1.6 if side == 1 else half.x - 1.6, 0, _rng.randf_range(-half.y + 3.0, half.y - 3.0))
		if side == 0 and (_near_exit(pos.x, 3.0) or (exits.is_empty() and absf(pos.x - door_pos.x) < 5.0)):
			continue
		# the long side along the wall, so a pile never reaches far into the room
		var yaw := (0.0 if side == 0 else PI * 0.5) + (PI if _rng.randf() < 0.5 else 0.0)
		_place(props[_rng.randi() % props.size()], pos, yaw, ROUGH_SOLID)
	for i in 8:
		var banner := "banner_patternA_white" if i % 3 else "banner_thin_yellow"
		if i < 4:
			var x := _rng.randf_range(-half.x + 3.0, half.x - 3.0)
			if not _near_exit(x, 2.5):
				_place(banner, Vector3(x, 0, -half.y + 0.1), 0.0)
		else:
			var side := -1.0 if i % 2 == 0 else 1.0
			_place(banner, Vector3(side * (half.x - 0.1), 0, _rng.randf_range(-half.y + 3.0, half.y - 3.0)), -side * PI * 0.5)
	if exits.is_empty():
		_place("stairs_wide", Vector3(door_pos.x, 0, -half.y + 2.0), 0.0, 1.0)


func _near_exit(x: float, margin: float = 1.9) -> bool:
	for e in exits:
		if absf(x - e.x) < margin:
			return true
	return false


func _shafts() -> void:
	for p in shafts:
		var l := SpotLight3D.new()
		l.position = Vector3(p.x, 14.0, p.y)
		l.rotation_degrees = Vector3(-90, 0, 0)
		l.light_color = Color(0.75, 0.95, 1.0)
		l.light_energy = 9.0
		l.spot_range = 18.0
		l.spot_angle = 18.0
		l.spot_angle_attenuation = 0.6
		l.light_cull_mask = ~CROWD_LAYER
		add_child(l)
		_dust(Vector3(p.x, 0, p.y))


## Fine dust drifting down through a shaft of light, always there, barely seen (the weather of the catacombs).
func _dust(at: Vector3) -> void:
	var d := CPUParticles3D.new()
	d.position = at + Vector3(0, DUST_HEIGHT, 0)
	d.amount = DUST_AMOUNT
	d.lifetime = DUST_LIFE
	d.preprocess = DUST_LIFE
	d.emission_shape = CPUParticles3D.EMISSION_SHAPE_BOX
	d.emission_box_extents = Vector3(DUST_RADIUS, 1.5, DUST_RADIUS)
	d.direction = Vector3(0.35, -1.0, 0.15)
	d.spread = 15.0
	d.initial_velocity_min = 0.6
	d.initial_velocity_max = 1.1
	d.gravity = Vector3.ZERO
	d.scale_amount_min = 0.5
	d.scale_amount_max = 1.0
	d.mesh = Fx.quad(DUST_SIZE, DUST_COLOR)
	var ramp := Gradient.new()
	ramp.set_color(0, Color(1, 1, 1, 0))
	ramp.add_point(0.2, Color(1, 1, 1, 1))
	ramp.add_point(0.8, Color(1, 1, 1, 1))
	ramp.set_color(ramp.get_point_count() - 1, Color(1, 1, 1, 0))
	d.color_ramp = ramp
	d.layers = 1
	add_child(d)


## The painted look of the floor laid over the tiles (assets/shaders/floor_detail.gdshader): a dark wash, pale
## clearings, stains, cracks, clean pools under the torches and haze at the edges. Lit like the stone, so it is cut
## in FLOOR_CHUNKS x FLOOR_CHUNKS pieces (each piece only gets the few lights near it).
func _floor_detail() -> void:
	var mat := ShaderMaterial.new()
	mat.shader = preload("res://assets/shaders/floor_detail.gdshader")
	# first of all see-through things, so sword ink, warnings and effects always draw over it
	mat.render_priority = Material.RENDER_PRIORITY_MIN
	mat.set_shader_parameter(&"half_size", maxf(half.x, half.y))
	var list := _torches.slice(0, 32)
	mat.set_shader_parameter(&"torches", list)
	mat.set_shader_parameter(&"torch_count", list.size())
	var size := maxf(half.x, half.y)
	var chunks := maxi(2, ceili(FLOOR_CHUNKS * size / HALF))
	var side := size * 2.0 / chunks
	var plane := PlaneMesh.new()
	plane.size = Vector2(side, side)
	for ix in chunks:
		for iz in chunks:
			var mi := MeshInstance3D.new()
			mi.mesh = plane
			mi.material_override = mat
			mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			mi.position = Vector3(-size + side * (ix + 0.5), 0.06, -size + side * (iz + 0.5))  # just above the tiles (their top is at 0.05)
			add_child(mi)


## A mesh of the dungeon kit at a spot, turned around Y.
## A prop against a wall blocks all the way to it (nobody slips into the gap behind, or gets pushed there).
func _to_wall(r: Rect2) -> Rect2:
	var reach := 2.5
	if r.position.y < -half.y + reach:
		r = r.expand(Vector2(r.position.x, -half.y - 2.0))
	if r.end.y > half.y - reach:
		r = r.expand(Vector2(r.position.x, half.y + 2.0))
	if r.position.x < -half.x + reach:
		r = r.expand(Vector2(-half.x - 2.0, r.position.y))
	if r.end.x > half.x - reach:
		r = r.expand(Vector2(half.x + 2.0, r.position.y))
	return r


## solid: share of the footprint that blocks the way (0: walk through it, like candles and banners).
func _place(name_: String, pos: Vector3, yaw: float, solid: float = 0.0) -> MeshInstance3D:
	if not _meshes.has(name_):
		var scene: Node = (load(DUNGEON + name_ + ".glb") as PackedScene).instantiate()
		var mi := _first_mesh(scene)
		_meshes[name_] = [mi.mesh, mi.transform]
		scene.free()
	var entry: Array = _meshes[name_]
	var out := MeshInstance3D.new()
	out.mesh = entry[0]
	out.transform = Transform3D(Basis(Vector3.UP, yaw), pos) * (entry[1] as Transform3D)
	for i in out.mesh.get_surface_count():
		out.set_surface_override_material(i, _tinted(out.mesh.surface_get_material(i)))
	add_child(out)
	if solid > 0.0:
		var box := out.transform * (out.mesh.get_aabb())
		var r := Rect2(box.position.x, box.position.z, box.size.x, box.size.z)
		r = r.grow_individual(-r.size.x * (1.0 - solid) * 0.5, -r.size.y * (1.0 - solid) * 0.5,
			-r.size.x * (1.0 - solid) * 0.5, -r.size.y * (1.0 - solid) * 0.5)
		boxes.append(_to_wall(r))
	return out


var _tints: Dictionary = {}


## The kit's material in the cool stone tint (one copy per source material).
func _tinted(m: Material) -> Material:
	if not m is StandardMaterial3D:
		return m
	if not _tints.has(m):
		var t := (m as StandardMaterial3D).duplicate() as StandardMaterial3D
		t.albedo_color *= STONE_TINT
		_tints[m] = t
	return _tints[m]


func _first_mesh(n: Node) -> MeshInstance3D:
	if n is MeshInstance3D:
		return n
	for c in n.get_children():
		var m := _first_mesh(c)
		if m:
			return m
	return null
