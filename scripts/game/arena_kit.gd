class_name ArenaKit
extends RefCounted
## The building blocks of the catacomb platforms (the art direction of 2026-11-14: monumental catacombs over an
## abyss, blue-petrol stone, gold firelight, green ways onward, purple depths, red for Morvath). Each function puts one
## finished element under `root` (meshes, its lights, its particles) and records what blocks the way in `circles`
## and `boxes`, which Arena.resolve reads. Arena lays them out from a RoomLayout; a new room is data, not code.
## Pieces come from KayKit Dungeon Remastered (CC0, assets/models/dungeon_r); the hooded statues are built in
## Masonry (no model yet); what the kit lacks (bowls, chains, the portal light, the cliffs, the mist) is built here.

const KIT := "res://assets/models/dungeon_r/"
const CROWD_LAYER := 2
## The depths (cliffs, far arcades, the tower) are also on this layer: only the abyss lights reach them, and the warm
## lights of the hall leave them out (WARM_MASK), so the depths stay cold and dark against their mist.
const DEPTH_LAYER := 4
const WARM_MASK := ~(CROWD_LAYER | DEPTH_LAYER)
## The facade and the statues by the portal: the portal's spill down the steps leaves them out (it would turn them green).
const FACADE_LAYER := 8
## The palette of the catacombs.
const STONE_DARK := Color(0.07, 0.09, 0.12)
const FIRE := Color(1.0, 0.58, 0.25)
const PORTAL := Color(0.3, 1.0, 0.5)
## The portal's sheet of light: a deeper green than its light, so its bright heart stays green and not white.
const PORTAL_SHEET := Color(0.22, 1.0, 0.34)
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
## Brazier (the picture's: a deep bronze bowl with a rim on a capped stone pedestal, a tall flame): the pedestal's
## height, the bowl (top radius, bottom radius, height), the rim's thickness, the fire (radius, tongues, tongue size)
## and a tongue's life, what blocks the way, the fire's light.
const BRAZIER_PEDESTAL := 0.9
const BRAZIER_BOWL := Vector3(0.65, 0.35, 0.45)
const BRAZIER_RIM := 0.06
const BRAZIER_FIRE := Vector3(0.6, 36, 0.4)
const BRAZIER_FIRE_LIFE := 0.8
const BRAZIER_RADIUS := 0.6
const BRONZE := Color(0.2, 0.13, 0.07)
## A fire's tongue at its hottest (the colour ramp takes it to orange and out), and the white-gold heart of the inner
## tongues; both stay under 2 so the glow only softens them and the tongues keep their shape.
const FLAME := Color(1.9, 1.15, 0.42)
const FLAME_HEART := Color(1.8, 1.6, 1.0)
## A tongue's size (width, height) as shares of the fire's tongue size; the inner tongues' share of that.
const TONGUE := Vector2(0.75, 1.7)
const HEART := 0.6
## The coals in the bowl and the rim of bronze lit from inside by them (so it reads against the flame).
const COALS := Color(1.4, 0.45, 0.1)
const RIM_GLOW := Color(0.85, 0.3, 0.08)
const RIM_GLOW_ENERGY := 0.3
const BRAZIER_LIGHT := 4.5
const BRAZIER_RANGE := 10.0
const BRAZIER_ATTENUATION := 1.3
const BRAZIER_COLOR := Color(1.0, 0.68, 0.42)
## The floor round a fire bowl's foot is wet (it mirrors the fire): from this radius it dries, by that one it is dry.
## At most WET_SPOTS of them (the floor shader's array).
const BRAZIER_WET := Vector2(1.5, 3.0)
const WET_SPOTS := 8
## A portal's glow and light while closed and open (a closed portal still glows: the room's green accent).
const PORTAL_DIM := 1.5
const PORTAL_OPEN := 2.0
const PORTAL_LIGHT_DIM := 2.5
const PORTAL_LIGHT := 3.5
const PORTAL_RANGE := 5.5
## Where the portal's light hangs in front of its sheet (m), and two small lights on the doorway's inner faces
## (energy at full light, range).
const PORTAL_LIGHT_AHEAD := 1.2
const PORTAL_SIDE := Vector2(1.5, 2.5)
## The medallion reads by its value, not by light (the picture's does not glow).
const MEDALLION_GLOW := 0.1
## A statue's plinth height, as a share of the statue's.
const STATUE_PLINTH := 0.1
## Chains: meters between two links, and the links' size.
const LINK_GAP := 0.32
const LINK_SIZE := 0.2
const LINK_WIRE := 0.12
const LINK_STRETCH := 1.6
## The iron's faint cold rim against the mist.
const CHAIN_RIM := 0.25

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
var _bronze_mat: StandardMaterial3D
var _rim_mat: StandardMaterial3D
var _iron: StandardMaterial3D
## A rectangle of floor (x, z) the floor plates keep wet (in front of the portal).
var wet_zone := Rect2()
## The floors' materials and the wet rings round the fire bowls on them (x, z, radius where it starts drying, dry).
var _floors: Array[ShaderMaterial] = []
var _wet_spots := PackedVector4Array()


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


## A deep bronze fire bowl on a capped stone pedestal: the warm light of the room. y: the ground it stands on; solid:
## it blocks the way (a circle of BRAZIER_RADIUS).
func brazier(at: Vector2, y: float = 0.0, solid := true, light := BRAZIER_LIGHT) -> void:
	var base := Vector3(at.x, y, at.y)
	masonry.post(base, 0.0, BRAZIER_PEDESTAL)
	var foot := BRAZIER_PEDESTAL + Masonry.POST_STEP.y + Masonry.POST_CAP.y
	var bowl := MeshInstance3D.new()
	var cyl := CylinderMesh.new()
	cyl.top_radius = BRAZIER_BOWL.x
	cyl.bottom_radius = BRAZIER_BOWL.y
	cyl.height = BRAZIER_BOWL.z
	cyl.radial_segments = 14
	bowl.mesh = cyl
	bowl.material_override = _bronze()
	bowl.position = base + Vector3(0, foot + BRAZIER_BOWL.z * 0.5, 0)
	root.add_child(bowl)
	var rim := MeshInstance3D.new()
	var torus := TorusMesh.new()
	torus.inner_radius = BRAZIER_BOWL.x - BRAZIER_RIM
	torus.outer_radius = BRAZIER_BOWL.x + BRAZIER_RIM
	torus.rings = 16
	torus.ring_segments = 6
	rim.mesh = torus
	rim.material_override = _rim()
	rim.position = base + Vector3(0, foot + BRAZIER_BOWL.z, 0)
	root.add_child(rim)
	var coals := MeshInstance3D.new()
	var disc := CylinderMesh.new()
	disc.top_radius = BRAZIER_BOWL.x - 0.08
	disc.bottom_radius = BRAZIER_BOWL.x - 0.08
	disc.height = 0.04
	coals.mesh = disc
	coals.material_override = _glow(COALS)
	coals.position = base + Vector3(0, foot + BRAZIER_BOWL.z - 0.06, 0)
	root.add_child(coals)
	fire(base + Vector3(0, foot + BRAZIER_BOWL.z - 0.02, 0), BRAZIER_FIRE.x, int(BRAZIER_FIRE.y), BRAZIER_FIRE.z, BRAZIER_FIRE_LIFE)
	var l := OmniLight3D.new()
	l.position = base + Vector3(0, foot + 1.6, 0)
	l.light_color = BRAZIER_COLOR
	l.light_energy = light
	l.omni_range = BRAZIER_RANGE
	l.omni_attenuation = BRAZIER_ATTENUATION
	l.shadow_enabled = true
	l.light_cull_mask = WARM_MASK
	root.add_child(l)
	if solid:
		circles.append(Vector3(at.x, at.y, BRAZIER_RADIUS))
	if _wet_spots.size() < WET_SPOTS:
		_wet_spots.append(Vector4(at.x, at.y, BRAZIER_WET.x, BRAZIER_WET.y))
		for f in _floors:
			_wet(f)


## Flames rising from a point: radius of the fire, how many tongues, the size of a tongue, how long one lives. Upright
## tongues (pointed, ArenaKit.tongue) in orange round a smaller white-gold heart, and embers drifting up.
func fire(at: Vector3, radius: float, amount: int, tongue := 0.42, life := 0.7) -> void:
	_flames(at, radius, amount, tongue, life, FLAME, Color(1.0, 0.75, 0.45, 1.0))
	_flames(at, radius * 0.45, maxi(3, roundi(amount / 3.0)), tongue * HEART, life * 0.8, FLAME_HEART, Color(1.0, 0.95, 0.8, 1.0))
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
	e.mesh = Fx.quad(0.05, Color(1.8, 0.8, 0.3))
	e.color_ramp = Fx.fade_ramp(Color(1, 1, 1, 1))
	root.add_child(e)


func _flames(at: Vector3, radius: float, amount: int, size: float, life: float, color: Color, hot: Color) -> void:
	var f := CPUParticles3D.new()
	f.position = at
	f.amount = amount
	f.lifetime = life
	f.emission_shape = CPUParticles3D.EMISSION_SHAPE_SPHERE
	f.emission_sphere_radius = radius * 0.6
	f.direction = Vector3.UP
	f.spread = 8.0
	f.initial_velocity_min = 0.5
	f.initial_velocity_max = 1.1
	f.gravity = Vector3(0, 0.8, 0)
	f.scale_amount_min = 0.7
	f.scale_amount_max = 1.2
	# each tongue narrows as it rises, from its hot colour to an orange edge and out
	var taper := Curve.new()
	taper.add_point(Vector2(0, 0.6))
	taper.add_point(Vector2(0.3, 1.0))
	taper.add_point(Vector2(1, 0.2))
	f.scale_amount_curve = taper
	f.mesh = tongue(Vector2(TONGUE.x, TONGUE.y) * size, color)
	var ramp := Gradient.new()
	ramp.offsets = PackedFloat32Array([0.0, 0.4, 1.0])
	ramp.colors = PackedColorArray([hot, Color(1.0, 0.55, 0.3, 0.8), Color(0.8, 0.25, 0.1, 0.0)])
	f.color_ramp = ramp
	root.add_child(f)


static var _tongue_tex: ImageTexture

## A flame's tongue: an upright card (turning round Y to the camera) with a pointed, round-bottomed shape, its colour
## added on top (HDR, so the core blooms a little). size: width and height in meters.
static func tongue(size: Vector2, color: Color) -> QuadMesh:
	if _tongue_tex == null:
		var w := 32
		var h := 64
		var img := Image.create(w, h, false, Image.FORMAT_RGBA8)
		for y in h:
			var v := 1.0 - (y + 0.5) / h
			# the radius of the tongue at height v: round at the foot, widest low, a long point
			var r := 0.95 * pow(1.0 - v, 0.85) * sqrt(clampf(v / 0.22, 0.0, 1.0))
			for x in w:
				var u := absf((x + 0.5) / w * 2.0 - 1.0)
				var a := clampf((r - u) / maxf(r * 0.55, 0.02), 0.0, 1.0)
				# brighter in the middle and low down
				var core := clampf(1.0 - u / maxf(r, 0.01), 0.0, 1.0) * (1.0 - v * 0.5)
				img.set_pixel(x, y, Color(1, 1, 1, a * (0.55 + 0.45 * core)))
		_tongue_tex = ImageTexture.create_from_image(img)
	var q := QuadMesh.new()
	q.size = size
	q.center_offset = Vector3(0, size.y * 0.35, 0)
	var m := StandardMaterial3D.new()
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.billboard_mode = BaseMaterial3D.BILLBOARD_FIXED_Y
	m.billboard_keep_scale = true
	m.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	m.vertex_color_use_as_albedo = true
	m.albedo_color = color
	m.albedo_texture = _tongue_tex
	m.disable_receive_shadows = true
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	q.material = m
	return q


## A hooded figure carved in stone (Masonry.hooded_statue), standing on a plinth. height: of the figure, in meters;
## y: the ground under the plinth; tint: the stone's colour (green near a portal); solid: it blocks the way.
func statue(at: Vector2, yaw: float, height: float = 4.2, y: float = 0.0, tint := Color(0.25, 0.27, 0.31), solid := true) -> void:
	var plinth := STATUE_PLINTH * height
	# a carved base of two bevelled steps
	var low := Masonry.BASE_STEPS.x * height
	masonry.block(Vector3(at.x, y, at.y), Vector3(1.0, 0.0, 1.0) * height * 0.56 + Vector3(0, low, 0), yaw)
	masonry.block(Vector3(at.x, y + low, at.y), Vector3(1.0, 0.0, 1.0) * height * 0.48 + Vector3(0, plinth - low, 0), yaw)
	masonry.hooded_statue(Vector3(at.x, y + plinth, at.y), yaw, height, tint)
	if solid:
		circles.append(Vector3(at.x, at.y, height * 0.25))


## A chain hanging between two points, sagging `sag` meters at its middle.
func chain(a: Vector3, b: Vector3, sag: float, size: float = 1.0) -> void:
	var n := maxi(2, ceili(a.distance_to(b) / (LINK_GAP * size)))
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	var torus := TorusMesh.new()
	torus.inner_radius = maxf(LINK_SIZE * size - LINK_WIRE * size * 0.5, LINK_SIZE * size * 0.2)
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
		# each link lies along the chain (the ring's hole across it), stretched, every other one turned a quarter
		var hole := side if i % 2 == 0 else up
		var basis := Basis(along * LINK_STRETCH, hole, along.cross(hole))
		mm.set_instance_transform(i, Transform3D(basis, p))
	var mmi := MultiMeshInstance3D.new()
	mmi.multimesh = mm
	if _iron == null:
		_iron = _plain(METAL, 0.45)
		_iron.rim_enabled = true
		_iron.rim = CHAIN_RIM
		_iron.rim_tint = 0.2
	mmi.material_override = _iron
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
	m.set_shader_parameter(&"color", PORTAL_SHEET)
	m.set_shader_parameter(&"power", PORTAL_DIM)
	m.set_shader_parameter(&"size", size)
	sheet.material_override = m
	sheet.transform = Transform3D(Basis(Vector3.UP, yaw), center)
	root.add_child(sheet)
	var l := OmniLight3D.new()
	l.position = center + Basis(Vector3.UP, yaw) * Vector3(0, 0.3, PORTAL_LIGHT_AHEAD)
	l.light_color = PORTAL
	l.light_energy = PORTAL_LIGHT_DIM
	l.omni_range = PORTAL_RANGE
	l.omni_attenuation = 1.2
	l.light_cull_mask = WARM_MASK
	root.add_child(l)
	var entry: Array = [m, l]
	for s: float in [-1.0, 1.0]:
		var side := OmniLight3D.new()
		side.position = center + Basis(Vector3.UP, yaw) * Vector3(s * (size.x * 0.5 - 0.4), -size.y * 0.15, 0.8)
		side.light_color = PORTAL
		side.light_energy = PORTAL_SIDE.x * PORTAL_LIGHT_DIM / PORTAL_LIGHT
		side.omni_range = PORTAL_SIDE.y
		side.light_cull_mask = WARM_MASK
		root.add_child(side)
		entry.append(side)
	portals.append(entry)


## Lights or dims a portal (open: the room is cleared and its reward waits behind it).
func light_portal(i: int, on: bool, tint: Color = PORTAL) -> void:
	if i >= portals.size():
		return
	(portals[i][0] as ShaderMaterial).set_shader_parameter(&"power", PORTAL_OPEN if on else PORTAL_DIM)
	(portals[i][0] as ShaderMaterial).set_shader_parameter(&"color", PORTAL_SHEET if tint == PORTAL else tint)
	var l: OmniLight3D = portals[i][1]
	l.light_color = tint
	l.light_energy = PORTAL_LIGHT if on else PORTAL_LIGHT_DIM
	for k in range(2, portals[i].size()):
		var side: OmniLight3D = portals[i][k]
		side.light_color = tint
		side.light_energy = PORTAL_SIDE.x * (1.0 if on else PORTAL_LIGHT_DIM / PORTAL_LIGHT)


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
	card.extra_cull_margin = maxf(size.x, size.y)
	root.add_child(card)


## A bank of pale mist in the abyss (abyss_mist.gdshader): a wide low card turning to the camera, its middle at
## `center`, ragged at its edges.
func mist_bank(center: Vector3, size: Vector2, color: Color, alpha: float) -> void:
	var card := MeshInstance3D.new()
	var q := QuadMesh.new()
	q.size = size
	card.mesh = q
	var m := ShaderMaterial.new()
	m.shader = preload("res://assets/shaders/abyss_mist.gdshader")
	m.set_shader_parameter(&"color", color)
	m.set_shader_parameter(&"alpha", alpha)
	card.material_override = m
	card.position = center
	card.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	card.extra_cull_margin = maxf(size.x, size.y)
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
	m.set_shader_parameter(&"rock_normal", Masonry.ROCK_NORMAL)
	m.set_shader_parameter(&"rock_height", Masonry.ROCK_HEIGHT)
	_floors.append(m)
	_wet(m)
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


func _wet(m: ShaderMaterial) -> void:
	var spots := _wet_spots.duplicate()
	spots.resize(WET_SPOTS)
	m.set_shader_parameter(&"wet_spots", spots)
	m.set_shader_parameter(&"wet_spot_count", _wet_spots.size())


func _stone(_m: Material) -> Material:
	return masonry.stone()


## The bowl's rim: bronze lit warm from inside by the coals.
func _rim() -> StandardMaterial3D:
	if _rim_mat == null:
		_rim_mat = _plain(BRONZE * 1.6, 0.4)
		_rim_mat.metallic = 0.7
		_rim_mat.emission_enabled = true
		_rim_mat.emission = RIM_GLOW
		_rim_mat.emission_energy_multiplier = RIM_GLOW_ENERGY
	return _rim_mat


func _bronze() -> StandardMaterial3D:
	if _bronze_mat == null:
		_bronze_mat = _plain(BRONZE, 0.45)
		_bronze_mat.metallic = 0.8
	return _bronze_mat


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
