class_name ArenaKit
extends RefCounted
## The building blocks of the catacomb platforms (the art direction of 2026-11-14: monumental catacombs over an
## abyss, blue-petrol stone, gold firelight, green ways onward, purple depths, red for Morvath). Each function puts one
## finished element under `root` (meshes, its lights, its particles) and records what blocks the way in `circles`
## and `boxes`, which Arena.resolve reads. Arena lays them out from a RoomLayout; a new room is data, not code.
## Pieces come from KayKit Dungeon Remastered (CC0, assets/models/dungeon_r) and the hooded statue from the baked
## KayKit hooded figure; what the kit lacks (bowls, chains, the portal light, the cliffs, the mist) is built here.

const KIT := "res://assets/models/dungeon_r/"
const CROWD_LAYER := 2
## The depths (cliffs, far arcades, the tower) are also on this layer: only the abyss lights reach them, and the warm
## lights of the hall leave them out (WARM_MASK), so the depths stay cold and dark against their mist.
const DEPTH_LAYER := 4
const WARM_MASK := ~(CROWD_LAYER | DEPTH_LAYER)
## The palette of the catacombs.
const STONE_DARK := Color(0.07, 0.09, 0.12)
const FIRE := Color(1.0, 0.58, 0.25)
const PORTAL := Color(0.3, 1.0, 0.5)
const ABYSS := Color(0.34, 0.17, 0.52)
## The mist of the abyss (teal, lighter than the stone in it) and the violet glowing up from under it.
const MIST := Color(0.03, 0.2, 0.25)
const ABYSS_GLOW := Color(0.45, 0.3, 0.95)
const ABYSS_GLOW_ENERGY := 1.6
## Forward+ only: violet glowing fog filling the sides of the abyss (density, emission).
const ABYSS_FOG_DENSITY := 0.04
const ABYSS_FOG_EMISSION := Color(0.25, 0.12, 0.5)
const METAL := Color(0.16, 0.17, 0.2)
const MORVATH := Color(1.0, 0.18, 0.15)
## Pieces that take the dressed-stone material (the rest keep the kit's colours: red banners, candles, flames).
const STONY: Array[String] = ["barrier", "barrier_column", "barrier_corner", "barrier_half", "floor_foundation_allsides",
	"floor_foundation_corner", "floor_foundation_front", "floor_foundation_front_and_sides", "stairs_wide", "stairs_walled",
	"wall", "wall_arched", "wall_doorway", "wall_pillar", "wall_corner", "wall_half", "wall_endcap", "wall_archedwindow_open",
	"pillar", "pillar_decorated", "column", "rubble_half", "rubble_large", "floor_tile_large", "floor_tile_large_rocks"]
## Brazier: the bowl's radius and height above the floor; the fire's light.
const BRAZIER_TOP := 1.25
const BRAZIER_LIGHT := 3.5
const BRAZIER_RANGE := 10.0
const BRAZIER_ATTENUATION := 1.3
const BRAZIER_COLOR := Color(1.0, 0.68, 0.42)
## A portal's glow and light while closed and open (a closed portal still glows: the room's green accent).
const PORTAL_DIM := 2.0
const PORTAL_OPEN := 2.8
const PORTAL_LIGHT_DIM := 4.0
const PORTAL_LIGHT := 5.5
const PORTAL_RANGE := 9.0
## The medallion reads by its value, not by light (the picture's does not glow).
const MEDALLION_GLOW := 0.1
## Chains: meters between two links, and the links' size.
const LINK_GAP := 0.32
const LINK_SIZE := 0.2

var root: Node3D
var rng := RandomNumberGenerator.new()
## Blocking circles (x, z, radius) and boxes on the floor, for Arena.resolve.
var circles: Array[Vector3] = []
var boxes: Array[Rect2] = []
## The portals' glowing sheets and lights, to dim or light them (Arena.light_exit).
var portals: Array[Array] = []
## Built stone (and the dressed-stone material the kit's stony pieces take too).
var masonry: Masonry
var _meshes := {}
var _glow_mats := {}
## A rectangle of floor (x, z) the floor plates keep wet (in front of the portal).
var wet_zone := Rect2()


func _init(parent: Node3D, seed_: int) -> void:
	root = parent
	rng.seed = seed_
	masonry = Masonry.new(parent)


## One kit piece: name, place, turn around Y, scale. solid: share of its footprint that blocks (0: none).
func piece(name_: String, pos: Vector3, yaw: float = 0.0, size := Vector3.ONE, solid := 0.0) -> MeshInstance3D:
	if not _meshes.has(name_):
		var scene: Node = (load(KIT + name_ + ".glb") as PackedScene).instantiate()
		var src := _first_mesh(scene)
		_meshes[name_] = [src.mesh, _local(src, scene)]
		scene.free()
	var e: Array = _meshes[name_]
	var mi := MeshInstance3D.new()
	mi.mesh = e[0]
	mi.transform = Transform3D(Basis(Vector3.UP, yaw) * Basis.from_scale(size), pos) * (e[1] as Transform3D)
	if STONY.has(name_):
		for i in mi.mesh.get_surface_count():
			mi.set_surface_override_material(i, _stone(mi.mesh.surface_get_material(i)))
	root.add_child(mi)
	if solid > 0.0:
		var box := mi.transform * mi.mesh.get_aabb()
		var r := Rect2(box.position.x, box.position.z, box.size.x, box.size.z)
		var g := (1.0 - solid) * 0.5
		boxes.append(r.grow_individual(-r.size.x * g, -r.size.y * g, -r.size.x * g, -r.size.y * g))
	return mi


## A row of a piece from a to b (on the floor), one every `step` meters, facing across the line.
func row(name_: String, a: Vector3, b: Vector3, step: float, yaw_offset: float = 0.0, size := Vector3.ONE) -> void:
	var n := maxi(1, roundi(a.distance_to(b) / step))
	var dir := (b - a) / n
	var yaw := atan2(dir.x, dir.z) - PI * 0.5 + yaw_offset
	for i in n:
		piece(name_, a + dir * (i + 0.5), yaw, size)


## A stone fire bowl on a short column: the warm light of the room. y: the ground it stands on; solid: it blocks
## the way (a circle of 0.6 m).
func brazier(at: Vector2, y: float = 0.0, solid := true, light := BRAZIER_LIGHT) -> void:
	var base := Vector3(at.x, y, at.y)
	piece("column", base, rng.randf() * TAU, Vector3(1.1, 0.8, 1.1))
	var bowl := MeshInstance3D.new()
	var cyl := CylinderMesh.new()
	cyl.top_radius = 0.62
	cyl.bottom_radius = 0.3
	cyl.height = 0.34
	cyl.radial_segments = 10
	bowl.mesh = cyl
	bowl.material_override = _plain(METAL, 0.5)
	bowl.position = base + Vector3(0, BRAZIER_TOP - 0.05, 0)
	root.add_child(bowl)
	var coals := MeshInstance3D.new()
	var disc := CylinderMesh.new()
	disc.top_radius = 0.52
	disc.bottom_radius = 0.52
	disc.height = 0.04
	coals.mesh = disc
	coals.material_override = _glow(Color(2.4, 0.7, 0.15))
	coals.position = base + Vector3(0, BRAZIER_TOP + 0.1, 0)
	root.add_child(coals)
	fire(base + Vector3(0, BRAZIER_TOP + 0.15, 0), 0.5, 22)
	var l := OmniLight3D.new()
	l.position = base + Vector3(0, BRAZIER_TOP + 1.2, 0)
	l.light_color = BRAZIER_COLOR
	l.light_energy = light
	l.omni_range = BRAZIER_RANGE
	l.omni_attenuation = BRAZIER_ATTENUATION
	l.shadow_enabled = true
	l.light_cull_mask = WARM_MASK
	root.add_child(l)
	if solid:
		circles.append(Vector3(at.x, at.y, 0.6))


## Flames rising from a point: radius of the fire, how many tongues.
func fire(at: Vector3, radius: float, amount: int) -> void:
	var f := CPUParticles3D.new()
	f.position = at
	f.amount = amount
	f.lifetime = 0.7
	f.emission_shape = CPUParticles3D.EMISSION_SHAPE_SPHERE
	f.emission_sphere_radius = radius * 0.6
	f.direction = Vector3.UP
	f.spread = 10.0
	f.initial_velocity_min = 0.8
	f.initial_velocity_max = 1.6
	f.gravity = Vector3(0, 1.2, 0)
	f.scale_amount_min = 0.6
	f.scale_amount_max = 1.3
	f.mesh = Fx.quad(0.42, Color(2.2, 0.95, 0.28))
	f.color_ramp = Fx.fade_ramp(Color(1, 1, 1, 1))
	root.add_child(f)
	# embers drifting up out of it
	var e := CPUParticles3D.new()
	e.position = at
	e.amount = 6
	e.lifetime = 2.2
	e.emission_shape = CPUParticles3D.EMISSION_SHAPE_SPHERE
	e.emission_sphere_radius = radius
	e.direction = Vector3.UP
	e.spread = 25.0
	e.initial_velocity_min = 0.7
	e.initial_velocity_max = 1.4
	e.gravity = Vector3(0.2, 0.3, 0)
	e.mesh = Fx.quad(0.06, Color(4.0, 1.6, 0.4))
	e.color_ramp = Fx.fade_ramp(Color(1, 1, 1, 1))
	root.add_child(e)


## A hooded figure carved in stone, standing on a plinth. height: of the figure, in meters; y: the ground under the
## plinth; tint: the stone's colour (green near a portal); solid: it blocks the way.
func statue(at: Vector2, yaw: float, height: float = 4.2, y: float = 0.0, tint := Color(0.25, 0.27, 0.31), solid := true) -> void:
	piece("floor_foundation_allsides", Vector3(at.x, y, at.y), yaw, Vector3(0.75, 0.45, 0.75) * Vector3(height / 4.2, 1, height / 4.2))
	var model: BakedModel = load("res://assets/baked/statue.res")
	var mi := MeshInstance3D.new()
	mi.mesh = model.anims[&"idle"][0]
	var k := height / maxf(model.height, 0.01)
	mi.transform = Transform3D(Basis(Vector3.UP, yaw).scaled(Vector3.ONE * k), Vector3(at.x, y + 0.9, at.y))
	var m := StandardMaterial3D.new()
	# all one carved stone: no paint, the folds read from the light alone
	m.albedo_color = tint
	m.roughness = 1.0
	m.rim_enabled = true
	m.rim = 0.35
	m.rim_tint = 0.6
	mi.material_override = m
	root.add_child(mi)
	if solid:
		circles.append(Vector3(at.x, at.y, 1.0))


## A chain hanging between two points, sagging `sag` meters at its middle.
func chain(a: Vector3, b: Vector3, sag: float, size: float = 1.0) -> void:
	var n := maxi(2, ceili(a.distance_to(b) / (LINK_GAP * size)))
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	var torus := TorusMesh.new()
	torus.inner_radius = LINK_SIZE * size * 0.55
	torus.outer_radius = LINK_SIZE * size
	torus.rings = 8
	torus.ring_segments = 6
	mm.mesh = torus
	mm.instance_count = n
	for i in n:
		var t := (i + 0.5) / n
		var p := a.lerp(b, t) + Vector3.DOWN * sag * 4.0 * t * (1.0 - t)
		var q := a.lerp(b, t + 0.01) + Vector3.DOWN * sag * 4.0 * (t + 0.01) * (1.0 - t - 0.01)
		var along := (q - p).normalized()
		var side := along.cross(Vector3.UP).normalized()
		if side.length() < 0.1:
			side = Vector3.RIGHT
		var up := side.cross(along)
		# links stand along the chain, every other one turned a quarter
		var basis := Basis(up, along, side) if i % 2 == 0 else Basis(side, along, -up)
		mm.set_instance_transform(i, Transform3D(basis.scaled(Vector3(1.0, 1.6, 1.0)), p))
	var mmi := MultiMeshInstance3D.new()
	mmi.multimesh = mm
	mmi.material_override = _plain(METAL, 0.45)
	mmi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	root.add_child(mmi)


## A doorway filled with green light, the way on: the arch piece, the glowing sheet and its light.
func portal(at: Vector3, yaw: float, size: float = 1.0) -> void:
	piece("wall_doorway", at, yaw, Vector3.ONE * size)
	portal_glow(at + Vector3(0, 1.5 * size, 0), yaw, Vector2(2.2, 3.0) * size)


## The glowing sheet of a portal (its middle at `center`, facing along yaw) and its light, dim until lit.
func portal_glow(center: Vector3, yaw: float, size: Vector2) -> void:
	var sheet := MeshInstance3D.new()
	var q := QuadMesh.new()
	q.size = size
	sheet.mesh = q
	var m := ShaderMaterial.new()
	m.shader = preload("res://assets/shaders/portal.gdshader")
	m.set_shader_parameter(&"color", PORTAL)
	m.set_shader_parameter(&"power", PORTAL_DIM)
	sheet.material_override = m
	sheet.transform = Transform3D(Basis(Vector3.UP, yaw), center)
	root.add_child(sheet)
	var l := OmniLight3D.new()
	l.position = center + Basis(Vector3.UP, yaw) * Vector3(0, 0.3, 2.2)
	l.light_color = PORTAL
	l.light_energy = PORTAL_LIGHT_DIM
	l.omni_range = PORTAL_RANGE
	l.omni_attenuation = 1.2
	l.light_cull_mask = WARM_MASK
	root.add_child(l)
	portals.append([m, l])


## Lights or dims a portal (open: the room is cleared and its reward waits behind it).
func light_portal(i: int, on: bool, tint: Color = PORTAL) -> void:
	if i >= portals.size():
		return
	(portals[i][0] as ShaderMaterial).set_shader_parameter(&"power", PORTAL_OPEN if on else PORTAL_DIM)
	(portals[i][0] as ShaderMaterial).set_shader_parameter(&"color", tint)
	var l: OmniLight3D = portals[i][1]
	l.light_color = tint
	l.light_energy = PORTAL_LIGHT if on else PORTAL_LIGHT_DIM


## Violet light glowing up out of the abyss: an upright card facing the camera's way (yaw), its foot at `foot`.
func abyss_glow(foot: Vector3, size: Vector2, yaw: float, energy := ABYSS_GLOW_ENERGY) -> void:
	var card := MeshInstance3D.new()
	var q := QuadMesh.new()
	q.size = size
	card.mesh = q
	if not _glow_mats.has(energy):
		var m := ShaderMaterial.new()
		m.shader = preload("res://assets/shaders/abyss_glow.gdshader")
		m.set_shader_parameter(&"color", ABYSS_GLOW)
		m.set_shader_parameter(&"energy", energy)
		_glow_mats[energy] = m
	card.material_override = _glow_mats[energy]
	card.transform = Transform3D(Basis(Vector3.UP, yaw), foot + Vector3(0, size.y * 0.5, 0))
	card.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	root.add_child(card)


## Forward+ only: a box of violet glowing fog in the abyss (the browser's renderer has no fog volumes: the glow cards
## carry the colour there).
func abyss_fog(center: Vector3, size: Vector3) -> void:
	if RenderingServer.get_current_rendering_method() == "gl_compatibility":
		return
	var v := FogVolume.new()
	v.shape = RenderingServer.FOG_VOLUME_SHAPE_BOX
	v.size = size
	v.position = center
	var fm := FogMaterial.new()
	fm.density = ABYSS_FOG_DENSITY
	fm.albedo = Color(0.3, 0.2, 0.5)
	fm.emission = ABYSS_FOG_EMISSION
	fm.edge_fade = 0.4
	v.material = fm
	root.add_child(v)


## The abyss around a platform of half size `half`: mist in layers over a deep glow, and dark cliffs under the
## platform's sides (from the floor down out of sight).
func abyss(half: Vector2, depth: float = 18.0, cliff := true) -> void:
	var span := maxf(half.x, half.y) * 6.0
	for k in 4:
		var plane := MeshInstance3D.new()
		var pm := PlaneMesh.new()
		pm.size = Vector2(span, span)
		plane.mesh = pm
		var m := ShaderMaterial.new()
		m.shader = preload("res://assets/shaders/abyss_fog.gdshader")
		m.set_shader_parameter(&"color", MIST * (1.0 + k * 0.15))
		m.set_shader_parameter(&"floor_layer", 1.0 if k == 0 else 0.0)
		m.set_shader_parameter(&"density", 0.55 - k * 0.08)
		m.set_shader_parameter(&"scale", 0.05 + k * 0.02)
		m.set_shader_parameter(&"drift", Vector2(0.3, 0.1) * (1.0 + k * 0.4))
		plane.material_override = m
		plane.position = Vector3(0, -depth + k * depth * 0.24, 0)
		plane.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		root.add_child(plane)
	_wisps(half)
	if not cliff:
		return
	# the cliff under the platform: one dark block, its top just under the floor
	var rock := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(half.x * 2.0, depth, half.y * 2.0)
	rock.mesh = box
	var cm := StandardMaterial3D.new()
	cm.albedo_color = STONE_DARK
	var tex := NoiseTexture2D.new()
	var noise := FastNoiseLite.new()
	noise.frequency = 0.08
	noise.fractal_octaves = 4
	tex.noise = noise
	tex.seamless = true
	cm.albedo_texture = tex
	cm.uv1_triplanar = true
	cm.uv1_scale = Vector3.ONE * 0.12
	cm.roughness = 1.0
	rock.material_override = cm
	rock.position = Vector3(0, -depth * 0.5 - 0.12, 0)
	root.add_child(rock)


## Purple wisps rising out of the depths along the sides.
func _wisps(half: Vector2) -> void:
	for s in [-1.0, 1.0]:
		var w := CPUParticles3D.new()
		w.position = Vector3(s * (half.x + 3.0), -6.0, 0)
		w.amount = 24
		w.lifetime = 6.0
		w.preprocess = 6.0
		w.emission_shape = CPUParticles3D.EMISSION_SHAPE_BOX
		w.emission_box_extents = Vector3(2.5, 1.0, half.y)
		w.direction = Vector3.UP
		w.spread = 15.0
		w.initial_velocity_min = 0.6
		w.initial_velocity_max = 1.2
		w.gravity = Vector3.ZERO
		w.mesh = Fx.quad(0.1, Color(1.2, 0.5, 2.2))
		w.color_ramp = Fx.fade_ramp(Color(1, 1, 1, 1))
		root.add_child(w)


## The floor of a platform (catacomb_floor.gdshader), cut in pieces so each only takes the lights near it.
func floor_plate(center: Vector3, size: Vector2, ring_radius: float = 0.0, ring_center := Vector2.ZERO) -> void:
	var m := ShaderMaterial.new()
	m.shader = preload("res://assets/shaders/catacomb_floor.gdshader")
	m.set_shader_parameter(&"ring_radius", ring_radius)
	m.set_shader_parameter(&"ring_glow", MEDALLION_GLOW)
	m.set_shader_parameter(&"ring_center", ring_center)
	m.set_shader_parameter(&"wet_zone", Vector4(wet_zone.position.x, wet_zone.position.y, wet_zone.end.x, wet_zone.end.y))
	# the rose's long points run across the screen, as in the picture
	m.set_shader_parameter(&"rose_turn", deg_to_rad(Feel.live().cam_yaw))
	m.set_shader_parameter(&"calm_radius", minf(size.x, size.y) * 0.32)
	var nx := maxi(1, ceili(size.x / 8.0))
	var nz := maxi(1, ceili(size.y / 8.0))
	var pm := PlaneMesh.new()
	pm.size = Vector2(size.x / nx, size.y / nz)
	for ix in nx:
		for iz in nz:
			var mi := MeshInstance3D.new()
			mi.mesh = pm
			mi.material_override = m
			mi.position = center + Vector3(-size.x * 0.5 + pm.size.x * (ix + 0.5), 0, -size.y * 0.5 + pm.size.y * (iz + 0.5))
			root.add_child(mi)


func _stone(_m: Material) -> Material:
	return masonry.stone()


func _plain(c: Color, roughness: float) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = c
	m.roughness = roughness
	m.metallic = 0.6
	return m


func _glow(c: Color) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.albedo_color = c
	return m


## A mesh's place relative to its scene's root (the glTF may nest it under a moved node).
func _local(mi: Node3D, top: Node) -> Transform3D:
	var t := mi.transform
	var n := mi.get_parent()
	while n != null and n != top and n is Node3D:
		t = (n as Node3D).transform * t
		n = n.get_parent()
	return t


func _first_mesh(n: Node) -> MeshInstance3D:
	if n is MeshInstance3D:
		return n
	for c in n.get_children():
		var m := _first_mesh(c)
		if m:
			return m
	return null
