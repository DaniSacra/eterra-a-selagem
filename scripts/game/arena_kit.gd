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
## The statues out in the abyss (cycle 7): the fires beside them and the violet below leave them out, so they stay the
## same cold stone as the ones by the portal; each takes only a weak warm light on the side turned to its bowl.
const STATUE_LAYER := 16
const WARM_MASK := ~(CROWD_LAYER | DEPTH_LAYER | STATUE_LAYER)
## The facade and the statues by the portal: the portal's spill down the steps leaves them out (it would turn them green).
const FACADE_LAYER := 8
## The palette of the catacombs.
const STONE_DARK := Color(0.07, 0.09, 0.12)
const FIRE := Color(1.0, 0.58, 0.25)
const PORTAL := Color(0.3, 1.0, 0.5)
## The portal's sheet of light: a deeper green than its light, so its bright heart stays green and not white.
const PORTAL_SHEET := Color(0.22, 1.0, 0.34)
const ABYSS := Color(0.4, 0.3, 0.52)
## The mist of the abyss (teal, lighter than the stone in it) and the violet glowing up from under it.
## C18 (ART P1-2, a scenery in one tone that lets the effects saturate): the mist and the violet glow at most 0.5
## and 0.45 of saturation (they were 0.88 and 0.68: the abyss was the most saturated mass of the frame).
const MIST := Color(0.11, 0.19, 0.22)
const ABYSS_GLOW := Color(0.6, 0.52, 0.78)
const ABYSS_GLOW_ENERGY := 1.6
const ABYSS_GLOW_SHAPE := Vector3(0.7, 2.2, 0.45)
## The far ruins' stone (abyss_ruins.gdshader), the cold edge on the tops of their blocks, and the height of a course.
const RUIN_STONE := Color(0.039, 0.11, 0.149)
const RUIN_EDGE := Color(0.24, 0.42, 0.48)
const RUIN_COURSE := 1.6
## Forward+ only: violet glowing fog filling the sides of the abyss (density, emission).
const ABYSS_FOG_DENSITY := 0.04
const ABYSS_FOG_EMISSION := Color(0.25, 0.22, 0.33)
const ABYSS_FOG_ALBEDO := Color(0.36, 0.31, 0.46)
const METAL := Color(0.16, 0.17, 0.2)
const MORVATH := Color(1.0, 0.18, 0.15)
## A banner of the facade (cycle 6, plain: no emblem until Daniel names Eterra's): crimson cloth, its faint own
## glow (so it is neither black in the cold light nor green by the portal), old gold trim (width in m), how dark the
## folds are, how many folds, and the dark bar it hangs from.
const BANNER_CLOTH := Color(0.6, 0.1, 0.12)
const BANNER_GLOW := Color(0.34, 0.036, 0.042)
const BANNER_TRIM := Color(0.5, 0.36, 0.14)
const BANNER_TRIM_WIDTH := 0.08
const BANNER_FOLD := 0.62
const BANNER_FOLDS := 5
const BANNER_BAR := Color(0.06, 0.05, 0.05)
## The raised sword on a banner (_banner_sword): its height (m), the blade's and the guard's share of it; the blade's
## half width at the guard, the grip's half width and the pommel's radius (shares of its height). A sword, never a
## cross (O-1 of the C11 QA: a blade as thin as the grip read as the long arm of a cross): the blade three times the
## grip's width at the guard, one long taper to the point.
const BANNER_SWORD := Vector3(1.2, 0.74, 0.24)
const BANNER_SWORD_WIDTH := Vector3(0.085, 0.026, 0.065)
## C12a QW-008 (at 1080 lines the sword was a speck at the cloth's top, under the frame's edge in the game camera): its
## middle this share of the way down the cloth (was a third), the gold a little lighter than the trim, and a dark edge
## round the blade and the guard (this many meters wider, in the bar's iron) so it reads on the folds of red.
const BANNER_SWORD_AT := 0.6
const BANNER_SWORD_GOLD := 1.3
const BANNER_SWORD_EDGE := 0.035
## What a banner carries (banner): nothing, the raised sword (the Chamber of the Seal's) or the standing lion of Eterra
## (cycle C12, Daniel 2026-11-16: the arenas' and the catacomb hall's banners), the seal's drawing in old gold.
enum Emblem { NONE, SWORD, LION }
const BANNER_LION_SHADER := preload("res://assets/shaders/banner_lion.gdshader")
const LION_FIELD := preload("res://assets/textures/seal/lion_sdf.res")
## The lion's patch: its side as a share of the cloth's width, its middle this share of the way down the cloth, and
## the quads across it (it follows the folds).
const BANNER_LION := 0.92
const BANNER_LION_AT := 0.42
const BANNER_LION_GRID := 8
## The lion's gold (a step over the trim, as the sword's) and its dark edge (field pixels).
const BANNER_LION_GOLD := Color(0.66, 0.48, 0.2)
const BANNER_LION_EDGE := 5.0
## The stylized look (STY-05, docs/art/stylized_spec.md 1.3 T14): the hall's and the arenas' lion banners in a dark
## petrol cloth (the reliquary's hue, RewardGem.CLOTH_COLOR, at half its value: the facade's cold fill lights it to
## the spec's value of 0.25 at most), a faint glow of their own in the same hue, the trim in old
## gold; every second one torn at its foot: the foot this share of the length up, notches down to this share of it.
const BANNER_PAINT_CLOTH := Color(0.035, 0.085, 0.095)
const BANNER_PAINT_GLOW := Color(0.012, 0.032, 0.036)
const BANNER_PAINT_TRIM := Color(0.42, 0.31, 0.13)
const BANNER_TORN := Vector2(0.86, 0.12)
## The stylized twins of the scenery's shaders and of the kit's material (VisualProfile, paint_look).
const FLOOR_SHADER := preload("res://assets/shaders/catacomb_floor.gdshader")
const FLOOR_PAINT := preload("res://assets/shaders/catacomb_floor_paint.gdshader")
## The garden's floor moss and its painted twin (room redesign lot C: one grey green in three steps).
const MOSS_SHADER := preload("res://assets/shaders/root_moss.gdshader")
const MOSS_PAINT := preload("res://assets/shaders/root_moss_paint.gdshader")
## The runes' floor (RunesLook) and its painted twin (room redesign lot D: the same material, the same tiles' state).
const RUNE_FLOOR := preload("res://assets/shaders/rune_floor.gdshader")
const RUNE_FLOOR_PAINT := preload("res://assets/shaders/rune_floor_paint.gdshader")
const KAYKIT_MATERIAL := preload("res://assets/models/kaykit_material.tres")
const KAYKIT_PAINT := preload("res://assets/models/kaykit_paint.tres")
## Pieces that take the dressed-stone material (the rest keep the kit's colours: red banners, candles, flames).
const STONY: Array[String] = ["barrier", "barrier_column", "barrier_corner", "barrier_half", "floor_foundation_allsides",
	"floor_foundation_corner", "floor_foundation_front", "floor_foundation_front_and_sides", "stairs_wide", "stairs_walled",
	"wall", "wall_arched", "wall_doorway", "wall_pillar", "wall_corner", "wall_half", "wall_endcap", "wall_archedwindow_open",
	"pillar", "pillar_decorated", "column", "rubble_half", "rubble_large", "floor_tile_large", "floor_tile_large_rocks"]
## Brazier (the picture's: a deep bronze bowl with a rim on a capped stone pedestal, a tall flame): the pedestal's
## height, the bowl (top radius, bottom radius, height), the rim's thickness, the fire (radius, tongues, tongue size)
## and a tongue's life, what blocks the way, the fire's light.
const BRAZIER_PEDESTAL := 0.9
const BRAZIER_BOWL := Vector3(0.85, 0.42, 0.5)
const BRAZIER_RIM := 0.06
## AP-1 (ART-02.3): the flame a third lower than it was (tongue 0.8, life 0.8: taller than the hero's head), its light
## unchanged.
const BRAZIER_FIRE := Vector3(0.6, 22, 0.56)
const BRAZIER_FIRE_LIFE := 0.68
const BRAZIER_RADIUS := 0.6
## The lights of a lit door take the reward's colour this far toward this warm white (light_portal).
const DOOR_LIGHT_WHITE := Color(1.0, 0.86, 0.66)
const DOOR_LIGHT_MIX := 0.55
const BRONZE := Color(0.2, 0.13, 0.07)
## A fire's licks (cycle 6: crisp and blended, not added, so the body of the flame is one orange shape with a
## red edge and not a haze): the outer ones at their foot, the amber inner ones, and the red they cool to as they
## narrow. AP-1 (ART-02.3): no white heart any more (it was (1.9, 1.15, 0.35) under a core of (2.6, 2.3, 1.4), past
## 235 in all three channels on the screen); the heart is amber, its brightest channel under the glow threshold.
const FLAME := Color(1.25, 0.52, 0.1)
const FLAME_HEART := Color(1.2, 0.62, 0.14)
const FLAME_EDGE := Color(0.85, 0.26, 0.05)
## A tongue's size (width, height) as shares of the fire's tongue size; the inner tongues' share of that, and the
## share of the fire's radius they rise from (a fuller white-gold heart, the outer tongues and the light unchanged).
const TONGUE := Vector2(0.9, 2.0)
const HEART := 0.75
const HEART_SPREAD := 0.5
## The share of the fire's radius the tongues rise from (close together: one body of flame, not a comb of spikes).
const FLAME_SPREAD := 0.35
## The fixed core of a fire (cycle 6: a card, not particles, so every frame has its heart; AP-1: amber, never white,
## added over the licks so it stays low): its colour, size (m), and its flicker (share of its size, slowest and fastest
## beat in Hz).
const FLAME_CORE := Color(0.55, 0.3, 0.07)
const FLAME_CORE_SIZE := Vector2(0.42, 0.66)
const FLAME_CORE_FLICKER := Vector3(0.12, 9.0, 13.0)
## Embers over a fire: how many, how high over its foot they start.
const EMBERS := 10
const EMBERS_FROM := 0.7
const EMBER := Color(1.25, 0.55, 0.18)
## The bed of ash in the bowl (dark, so the bowl does not read as an orange disc) and the share of the bowl's mouth
## the glowing coals take.
const ASH := Color(0.05, 0.025, 0.015)
## A cold bowl's ash (brazier(..., lit = false)): grey, never glowing.
const COLD_ASH := Color(0.2, 0.195, 0.2)
const COALS_SHARE := 0.78
## The coals in the bowl and the rim of bronze lit from inside by them (so it reads against the flame).
const COALS := Color(1.1, 0.3, 0.05)
const RIM_GLOW := Color(0.85, 0.3, 0.08)
const RIM_GLOW_ENERGY := 0.12
const BRAZIER_LIGHT := 4.5
const BRAZIER_RANGE := 10.0
const BRAZIER_ATTENUATION := 1.3
const BRAZIER_COLOR := Color(1.0, 0.68, 0.42)
## The floor round a fire bowl's foot is wet (it mirrors the fire): from this radius it dries, by that one it is dry.
## At most WET_SPOTS of them (the floor shader's array).
const BRAZIER_WET := Vector2(1.5, 3.0)
const WET_SPOTS := 8
## A portal's glow and light while closed and open (a closed portal still glows: the room's green accent).
## (cycle 7: the sheet's own values keep it under the tonemap's white but for its core, see portal.gdshader; closed
## and open differ more by the light on the stone than by the sheet).
const PORTAL_DIM := 0.85
const PORTAL_OPEN := 1.0
const PORTAL_LIGHT_DIM := 2.5
const PORTAL_LIGHT := 3.5
const PORTAL_RANGE := 5.5
## Where the portal's light hangs in front of its sheet (m) and how far under the sheet's middle (share of its
## height; cycle 7: low, so it rakes up the jambs and the arch and leaves the tops dark), and two small lights on
## the doorway's inner faces (energy at full light, range; PORTAL_SIDE_AT: m in from the sheet's side, share of its
## height under its middle, m ahead of it).
const PORTAL_LIGHT_AHEAD := 1.0
const PORTAL_LIGHT_DROP := 0.3
const PORTAL_SIDE := Vector2(1.5, 2.5)
const PORTAL_SIDE_AT := Vector3(0.4, 0.3, 0.8)
## The medallion reads by its value, not by light (the picture's does not glow).
const MEDALLION_GLOW := 0.0
## A statue's plinth height, as a share of the statue's; the width of its two steps (shares of the height: the upper
## one narrower than the robe's hem, which hangs over it); the value of a statue's stone unless told otherwise.
const STATUE_PLINTH := 0.1
const STATUE_BASE := Vector2(0.52, 0.41)
const STATUE_VALUE := 0.8
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
## Lights away from a portal that take its colour when it is lit (the hall's spill down the steps), by portal index:
## [light, its own colour for the portal's green, its own energy]; their energy stays their own (but for surge).
var portal_tinted: Dictionary = {}
## The middle of each portal's sheet of light (where the sealing gathers), and the colour each was last lit with.
var portal_centers: Array[Vector3] = []
var portal_tints: Dictionary = {}
## Built stone (and the dressed-stone material the kit's stony pieces take too).
var masonry: Masonry
var _meshes := {}
var _glow_mats := {}
var _bronze_mat: StandardMaterial3D
var _rim_mat: StandardMaterial3D
var _iron: StandardMaterial3D
var _banner_mat: StandardMaterial3D
var _banner_paint_mat: StandardMaterial3D
var _banners := 0
var _core_mesh: QuadMesh
var _coals_mat: StandardMaterial3D
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
	var e := _kit_mesh(name_)
	var mi := MeshInstance3D.new()
	mi.mesh = e[0]
	mi.transform = Transform3D(Basis(Vector3.UP, yaw) * Basis.from_scale(size), pos) * (e[1] as Transform3D)
	if STONY.has(name_):
		for i in mi.mesh.get_surface_count():
			mi.set_surface_override_material(i, _stone(mi.mesh.surface_get_material(i)))
	root.add_child(mi)
	if solid > 0.0:
		_block(mi.transform * mi.mesh.get_aabb(), solid)
	return mi


## A kit piece's mesh and its place in its scene (loaded once).
func _kit_mesh(name_: String) -> Array:
	if not _meshes.has(name_):
		var scene: Node = (load(KIT + name_ + ".glb") as PackedScene).instantiate()
		var src := _first_mesh(scene)
		_meshes[name_] = [src.mesh, _local(src, scene)]
		scene.free()
	return _meshes[name_]


## Records the middle `solid` share of a piece's footprint as a blocking box.
func _block(box: AABB, solid: float) -> void:
	var r := Rect2(box.position.x, box.position.z, box.size.x, box.size.z)
	var g := (1.0 - solid) * 0.5
	boxes.append(r.grow_individual(-r.size.x * g, -r.size.y * g, -r.size.x * g, -r.size.y * g))


## A wooden crate (Masonry.crate) in the place, size and footprint of the kit's "box_small", which it replaces (that
## one's pale blue frame is not in the picture). Same arguments as piece(); the blocking box is the kit piece's.
func crate(pos: Vector3, yaw: float = 0.0, size := Vector3.ONE, solid := 0.0) -> void:
	var e := _kit_mesh("box_small")
	var xf := Transform3D(Basis(Vector3.UP, yaw) * Basis.from_scale(size), pos) * (e[1] as Transform3D)
	var local: AABB = (e[0] as Mesh).get_aabb()
	var dims := (xf.basis.get_scale() * local.size).abs()
	var middle := xf * local.get_center()
	masonry.crate(Vector3(middle.x, middle.y - dims.y * 0.5, middle.z), dims, yaw)
	if solid > 0.0:
		_block(xf * local, solid)


## A banner hanging on the facade from `top` (the middle of its bar), facing along yaw: cloth with a pointed foot,
## folds as darker upright bands, old gold trim down its sides and round the point, a tassel. size: width, length.
## emblem (Emblem): the raised sword of Eterra's canon in old gold on it (BANNER_SWORD; the Chamber of the Seal's banners)
## or the standing lion (BANNER_LION; the arenas' and the hall's).
func banner(top: Vector3, yaw: float, size: Vector2, layers := FACADE_LAYER, emblem := Emblem.NONE) -> void:
	var mi := MeshInstance3D.new()
	mi.mesh = _banner_mesh(size, emblem, BANNER_CLOTH, BANNER_TRIM, false)
	if _banner_mat == null:
		_banner_mat = _cloth_material(BANNER_GLOW)
	mi.material_override = _banner_mat
	mi.transform = Transform3D(Basis(Vector3.UP, yaw), top)
	mi.layers = layers
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	root.add_child(mi)
	if emblem == Emblem.LION:
		# the stylized look's twin: petrol cloth, every second one torn (only one of the two is drawn)
		var twin := MeshInstance3D.new()
		twin.mesh = _banner_mesh(size, emblem, BANNER_PAINT_CLOTH, BANNER_PAINT_TRIM, _banners % 2 == 1)
		_banners += 1
		if _banner_paint_mat == null:
			_banner_paint_mat = _cloth_material(BANNER_PAINT_GLOW)
		twin.material_override = _banner_paint_mat
		twin.transform = mi.transform
		twin.layers = layers
		twin.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		twin.visible = false
		root.add_child(twin)
		VisualProfile.vary(mi, {&"visible": false})
		VisualProfile.vary(twin, {&"visible": true})
		var lion := MeshInstance3D.new()
		lion.mesh = _banner_lion(size)
		lion.material_override = _lion_material()
		lion.transform = mi.transform
		lion.layers = layers
		lion.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		root.add_child(lion)


## A banner's cloth: folds as darker upright bands of `cloth`, `trim` down its sides and round the pointed foot, the
## bar, the sword (emblem) and the tassel; torn: the foot a ragged edge with no trim nor tassel.
func _banner_mesh(size: Vector2, emblem: Emblem, cloth: Color, trim_color: Color, torn: bool) -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var half := size.x * 0.5
	var point := half
	var n := BANNER_FOLDS * 4
	var trim := BANNER_TRIM_WIDTH
	# the torn edge's notches (its own generator: the kit's draws stay those of the classic look)
	var notches := PackedFloat32Array()
	if torn:
		var r := RandomNumberGenerator.new()
		r.seed = hash(size) + _banners
		for i in n + 1:
			notches.append(r.randf() * BANNER_TORN.y * size.y)
	# the foot of the cloth at column i (x): a point in the middle, or the torn edge
	var foot := func(x: float, i: int) -> float:
		if torn:
			return -size.y * BANNER_TORN.x + notches[i]
		return -size.y + point * absf(x) / half
	for i in n:
		var x0 := -half + size.x * i / n
		var x1 := -half + size.x * (i + 1) / n
		var quad: Array[Vector3] = []
		var shade: Array[float] = []
		for k in 2:
			var x: float = [x0, x1][k]
			var wave := cos((x + half) / size.x * TAU * BANNER_FOLDS)
			quad.append(Vector3(x, 0.0, wave * 0.05))
			quad.append(Vector3(x, float(foot.call(x, i + k)), wave * 0.08))
			shade.append(lerpf(BANNER_FOLD, 1.0, wave * 0.5 + 0.5))
		_banner_quad(st, quad[0], quad[2], quad[3], quad[1], cloth * shade[0], cloth * shade[1])
		if torn:
			continue
		# the trim round the point
		var lift := Vector3(0, 0, 0.012)
		_banner_quad(st, quad[1] + Vector3(0, trim * 1.4, 0) + lift, quad[3] + Vector3(0, trim * 1.4, 0) + lift, quad[3] + lift, quad[1] + lift,
			trim_color * shade[0], trim_color * shade[1])
	# the trim down the sides, the bar and the tassel
	for sd: float in [-1.0, 1.0]:
		var a := Vector3(sd * half, 0.0, 0.07)
		var b := Vector3(sd * (half - trim), 0.0, 0.07)
		var drop := Vector3(0, float(foot.call(sd * half, 0 if sd < 0.0 else n)), 0)
		_banner_quad(st, a, b, b + drop + Vector3(0, -trim, 0), a + drop, trim_color, trim_color)
	var bar := Vector3(half + 0.18, 0.07, 0.09)
	_banner_quad(st, Vector3(-bar.x, bar.y, bar.z), Vector3(bar.x, bar.y, bar.z), Vector3(bar.x, -bar.y, bar.z), Vector3(-bar.x, -bar.y, bar.z),
		BANNER_BAR, BANNER_BAR)
	if emblem == Emblem.SWORD:
		_banner_sword(st, size)
	if not torn:
		var tip := Vector3(0, -size.y, 0.09)
		_banner_quad(st, tip + Vector3(0, 0.05, 0), tip + Vector3(0.09, -0.16, 0), tip + Vector3(0, -0.42, 0), tip + Vector3(-0.09, -0.16, 0),
			trim_color, trim_color * 0.7)
	st.generate_normals()
	return st.commit()


## The cloth's material: its vertex colours, both faces, matte, a faint glow of its own so it is never black.
func _cloth_material(glow: Color) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.vertex_color_use_as_albedo = true
	m.cull_mode = BaseMaterial3D.CULL_DISABLED
	m.roughness = 1.0
	m.emission_enabled = true
	m.emission = glow
	return m


## The stylized look of everything built under the kit's root (STY-04, STY-05; VisualProfile): the dressed stone and
## the floors take their painted twins (masonry_paint, catacomb_floor_paint; the wood keeps its own colour), the moss
## its painted twin (root_moss_paint, lot C: style keys shadow and moss), the kit's pieces the painted kit material. Call once the room is built (after Masonry.merge). Materials made while the look
## was stylized are put back to their classic shader first, so the classic one is always the one registered.
## Room redesign (biome preset, docs/art/room_redesign_lotA_spec.md 1.1): `style` (the room's style(), every key
## optional) adds its numbers to every material it paints: stone (paint_stone), pool_gain (the stone's fire pools,
## paint_pool_gain: candles standing on a lid burn it white at the floor's gain), abyss_glow (the colour of the
## abyss's glow cards, abyss_glow), pool_saturation (stone and floor, the
## pools' share of the fire's colour), shadow (paint_shadow, also the kit's
## painted pieces, on a copy of the shared material), floor_stone, slab_hue, edge_value (the floor's), joint_cold and
## olive_share (stone and floor); a material with the meta PAINT_OWN takes those values on top (bone that must not
## turn to stone: OWN_KEEP).
func paint_look(style := {}) -> void:
	var swaps := {Masonry.SHADER: Masonry.PAINT_SHADER, FLOOR_SHADER: FLOOR_PAINT, MOSS_SHADER: MOSS_PAINT,
		RUNE_FLOOR: RUNE_FLOOR_PAINT}
	var seen := {}
	var kit_paint: Material = KAYKIT_PAINT
	if style.has(&"shadow"):
		kit_paint = KAYKIT_PAINT.duplicate()
		(kit_paint as ShaderMaterial).set_shader_parameter(&"paint_shadow", style[&"shadow"])
	for n in root.find_children("*", "GeometryInstance3D", true, false):
		var g := n as GeometryInstance3D
		_paint_material(g.material_override, swaps, seen, style)
		if not g is MeshInstance3D:
			continue
		var mi := g as MeshInstance3D
		var kit := false
		for i in mi.get_surface_override_material_count():
			var over := mi.get_surface_override_material(i)
			_paint_material(over, swaps, seen, style)
			if over == null and mi.mesh != null and mi.mesh.surface_get_material(i) == KAYKIT_MATERIAL:
				kit = true
		if kit and mi.material_override == null:
			VisualProfile.vary(mi, {&"material_override": kit_paint})


## Which keys of a room's style go to which painted shader (paint_look).
const STONE_KEYS := {&"stone": &"paint_stone", &"shadow": &"paint_shadow", &"joint_cold": &"joint_cold", &"olive_share": &"olive_share",
	&"pool_gain": &"paint_pool_gain", &"pool_saturation": &"paint_pool_saturation"}
## The moss (lot C): the shadow's colour and its own grey green (style key moss).
const MOSS_KEYS := {&"shadow": &"paint_shadow", &"moss": &"paint_moss"}
const FLOOR_KEYS := {&"floor_stone": &"floor_stone", &"shadow": &"paint_shadow", &"joint_cold": &"joint_cold",
	&"olive_share": &"olive_share", &"slab_hue": &"slab_hue", &"slab_paint": &"slab_paint", &"edge_value": &"edge_value",
	&"pool_saturation": &"paint_pool_saturation"}
## A material's own stylized numbers (meta: shader parameter name to value), over the room's (paint_look).
const PAINT_OWN := &"paint_own"
## Stone that keeps its own colour in the stylized look (bone, wood): paint_keep with its saturation and value whole.
const OWN_KEEP := {&"paint_keep": 1.0, &"wood_saturation": 1.0, &"wood_value": 1.0}


func _paint_material(mat: Material, swaps: Dictionary, seen: Dictionary, style := {}) -> void:
	var sm := mat as ShaderMaterial
	if sm == null or seen.has(sm):
		return
	seen[sm] = true
	for classic: Shader in swaps:
		if sm.shader == swaps[classic]:
			sm.shader = classic
	if not swaps.has(sm.shader):
		return
	var values := {&"shader": swaps[sm.shader]}
	var keys: Dictionary = STONE_KEYS if sm.shader == Masonry.SHADER else (MOSS_KEYS if sm.shader == MOSS_SHADER else FLOOR_KEYS)
	for k: StringName in keys:
		if style.has(k):
			values[StringName("shader_parameter/" + keys[k])] = style[k]
	if masonry.is_wood(sm):
		values[&"shader_parameter/paint_keep"] = 1.0
	var own: Dictionary = sm.get_meta(PAINT_OWN, {})
	for k: StringName in own:
		values[StringName("shader_parameter/" + k)] = own[k]
	VisualProfile.vary(sm, values)


## The fires of the stylized look (STY-04, STY-10; the hall's loop, shared by every room since the room redesign, spec
## 1.3): every warm light under `at` (its red over its blue by RoomMood.FIRE_FROM) not on the depths' layer paints a
## pool: a fire bowl's (brazier, meta BOWL) and a candle's reach, the bowls' falloff, their energy as a share of the
## classic one (times `compat` in the browser's renderer), never a shadow. The lights in `off` are hidden.
## fire: {bowl_range, candle_range, bowl_attenuation, bowl_gain, candle_gain, compat}.
func stylize_fires(at: Node, fire: Dictionary, off: Array = []) -> void:
	var compat := RenderingServer.get_current_rendering_method() == "gl_compatibility"
	var share: float = fire.get(&"compat", 1.0) if compat else 1.0
	for n in at.find_children("*", "OmniLight3D", true, false):
		var l := n as OmniLight3D
		if l.has_meta(NOT_FIRE):
			continue
		if off.has(l):
			VisualProfile.vary(l, {&"visible": false})
		elif not fire.is_empty() and l.light_color.r - l.light_color.b >= RoomMood.FIRE_FROM and l.light_cull_mask != DEPTH_LAYER:
			var bowl := l.has_meta(BOWL)
			VisualProfile.vary(l, {
				&"omni_range": fire.get(&"bowl_range" if bowl else &"candle_range", l.omni_range),
				&"omni_attenuation": fire.get(&"bowl_attenuation", l.omni_attenuation) if bowl else l.omni_attenuation,
				&"light_energy": l.light_energy * float(fire.get(&"bowl_gain" if bowl else &"candle_gain", 1.0)) * share
					* float(l.get_meta(FIRE_SHARE, 1.0)),
				&"shadow_enabled": l.shadow_enabled and l.has_meta(KEEP_SHADOW),
			})
	for l: Node in off:
		if l is Light3D and not l is OmniLight3D:
			VisualProfile.vary(l, {&"visible": false})


## The meta of a fire bowl's light (brazier; stylize_fires).
const BOWL := &"bowl"
## The meta of a warm light that is no fire (room redesign lot D: the runes' lights over the armed tiles, the danger's
## own, set every frame): stylize_fires leaves it as it is.
const NOT_FIRE := &"not_fire"
## The meta of a fire that keeps its shadow in the stylized look (lot D: the altar's candles once lit, its one shadow).
const KEEP_SHADOW := &"keep_shadow"
## The meta of a fire's own share of its stylized energy (stylize_fires; a room's few fires that burnt the floor).
const FIRE_SHARE := &"fire_share"
## The metals in the stylized look (spec 1.2): matte, a little metallic, old gold, iron and bronze.
const STY_METAL := Vector2(0.75, 0.35)
const STY_GOLD := Color(0.42, 0.31, 0.13)
const STY_IRON := Color(0.16, 0.16, 0.17)
const STY_BRONZE := Color(0.32, 0.22, 0.12)


## The kit's and a tomb kit's metals in the stylized look (spec 1.2).
func stylize_metal(tomb: TombKit = null) -> void:
	var pairs: Array = [[_bronze_mat, STY_BRONZE]]
	if tomb != null:
		pairs.append([tomb._gold_mat, STY_GOLD])
		pairs.append([tomb._iron_mat, STY_IRON])
	for p: Array in pairs:
		if p[0] != null:
			VisualProfile.vary(p[0], {&"albedo_color": p[1], &"roughness": STY_METAL.x, &"metallic": STY_METAL.y})


## What is built only for the stylized look (room redesign): a Masonry of its own under a node hidden in the classic
## look (so the classic frame never changes and nothing of it merges with the classic stone). Call stylize (or
## styled_done) once it is all built.
func styled() -> Masonry:
	if _styled == null:
		var node := Node3D.new()
		node.name = "Styled"
		root.add_child(node)
		style_only(node)
		_styled = Masonry.new(node)
	return _styled


var _styled: Masonry


## Any of the kit's pieces built for the stylized look only (room redesign lot B: braziers, banners, statues): `build`
## runs with the stylized Masonry in place of the room's, and what it added to the kit's root goes under the hidden
## "Styled" node, its lights without shadow; the floor's wet rings (a brazier's) stay the classic ones. scale (round `at`, on the ground): the
## piece smaller (its stone not merged then), its lights left unscaled at their scaled place (their reach is the
## light's own). Returns the node holding the piece.
func styled_build(build: Callable, at := Vector3.ZERO, scale := 1.0) -> Node3D:
	var sm := styled()
	var own := masonry
	var wet := _wet_spots.duplicate()
	var from_root := root.get_child_count()
	var from_sm := sm.root.get_child_count()
	var from_built := sm._built.size()
	masonry = sm
	build.call()
	masonry = own
	if _wet_spots.size() != wet.size():
		_wet_spots = wet
		for f in _floors:
			_wet(f)
	var holder := Node3D.new()
	holder.name = "StyledPiece"
	var added: Array[Node] = []
	for i in range(from_root, root.get_child_count()):
		added.append(root.get_child(i))
	if not is_equal_approx(scale, 1.0):
		for i in range(from_sm, sm.root.get_child_count()):
			added.append(sm.root.get_child(i))
		sm._built.resize(from_built)
	sm.root.add_child(holder)
	holder.transform = Transform3D(Basis.from_scale(Vector3.ONE * scale), at)
	var to_local := Transform3D(Basis(), -at)
	for n in added:
		n.get_parent().remove_child(n)
		if n is Light3D:
			# nothing of the stylized look casts a shadow (the classic room's count of shadowed lights stays its own)
			var l := n as Light3D
			l.shadow_enabled = false
			l.position = at + (l.position - at) * scale
			sm.root.add_child(l)
		else:
			holder.add_child(n)
			if n is Node3D:
				(n as Node3D).transform = to_local * (n as Node3D).transform
	return holder


## A node shown only in the stylized look.
static func style_only(node: Node3D) -> void:
	node.visible = false
	VisualProfile.vary(node, {&"visible": true})


## The whole stylized look of a room (spec 1.1): the stylized pieces joined, the stone, floor and kit painted with the
## preset, the fires (their lights under `lights`), the metals.
func stylize(style: Dictionary, lights: Node, tomb: TombKit = null) -> void:
	if _styled != null:
		_styled.merge()
	paint_look(style)
	stylize_fires(lights, style.get(&"fire", {}), style.get(&"off", []))
	if style.has(&"abyss_glow"):
		for m: ShaderMaterial in _glow_mats.values():
			VisualProfile.vary(m, {&"shader_parameter/color": style[&"abyss_glow"]})
	if style.get(&"metal", false):
		stylize_metal(tomb)


## The lion's patch on a banner: a square grid of quads just in front of the folds (so it bends with them), UV 0..1
## over it (banner_lion.gdshader draws the lion inside), each vertex's red the fold's shade.
func _banner_lion(size: Vector2) -> ArrayMesh:
	var key := "lion%.2f_%.2f" % [size.x, size.y]
	if _meshes.has(key):
		return _meshes[key]
	var side := size.x * BANNER_LION
	var mid_y := -size.y * BANNER_LION_AT
	var n := BANNER_LION_GRID
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var at := func(u: float, v: float) -> Vector3:
		var x := (u - 0.5) * side
		var y := mid_y + (0.5 - v) * side
		var wave := cos((x + size.x * 0.5) / size.x * TAU * BANNER_FOLDS)
		return Vector3(x, y, wave * lerpf(0.05, 0.08, -y / size.y) + 0.02)
	var shade := func(u: float) -> float:
		var wave := cos(((u - 0.5) * side + size.x * 0.5) / size.x * TAU * BANNER_FOLDS)
		return lerpf(BANNER_FOLD, 1.0, wave * 0.5 + 0.5) * 0.6 + 0.4
	for i in n:
		for j in n:
			var u0 := float(i) / n
			var u1 := float(i + 1) / n
			var v0 := float(j) / n
			var v1 := float(j + 1) / n
			for q: Vector2 in [Vector2(u0, v0), Vector2(u1, v0), Vector2(u1, v1), Vector2(u0, v0), Vector2(u1, v1), Vector2(u0, v1)]:
				st.set_color(Color(shade.call(q.x), 0, 0))
				st.set_uv(q)
				st.add_vertex(at.call(q.x, q.y))
	st.generate_normals()
	var mesh := st.commit()
	_meshes[key] = mesh
	return mesh


static var _lion_mat: ShaderMaterial


## One material for every lion (never one per banner).
static func _lion_material() -> ShaderMaterial:
	if _lion_mat == null:
		_lion_mat = ShaderMaterial.new()
		_lion_mat.shader = BANNER_LION_SHADER
		_lion_mat.set_shader_parameter(&"lion", LION_FIELD)
		_lion_mat.set_shader_parameter(&"gold", BANNER_LION_GOLD)
		_lion_mat.set_shader_parameter(&"edge_color", BANNER_BAR)
		_lion_mat.set_shader_parameter(&"edge_px", BANNER_LION_EDGE)
	return _lion_mat


## The raised sword on a banner (docs/art/boss_chamber_spec.md 5.4): point up, the blade BANNER_SWORD.y of its height
## narrowing to the point, a short guard (BANNER_SWORD.z of the height) with its tips falling a little, the grip and a
## round pommel; BANNER_SWORD.x tall, its middle BANNER_SWORD_AT of the way down the cloth, laid on its folds, with a
## dark edge round blade and guard. No ring behind it and no equal arms: it reads as a sword, never as a cross.
func _banner_sword(st: SurfaceTool, size: Vector2) -> void:
	var h := BANNER_SWORD.x
	var foot := -size.y * BANNER_SWORD_AT - h * 0.5
	var blade := h * BANNER_SWORD.y
	var guard := h * BANNER_SWORD.z
	var grip := h - blade - 0.06 - h * BANNER_SWORD_WIDTH.z * 2.0
	# a point of the emblem at (x, y on the cloth), just in front of the folds
	var lift := [0.02]
	var on := func(x: float, y: float) -> Vector3:
		var wave := cos((x + size.x * 0.5) / size.x * TAU * BANNER_FOLDS)
		return Vector3(x, y, wave * lerpf(0.05, 0.08, -y / size.y) + lift[0])
	var g := BANNER_TRIM * BANNER_SWORD_GOLD
	var shade := g * 0.75
	var base := foot + h - blade
	var w := h * BANNER_SWORD_WIDTH.x
	# the dark edge, just behind the gold: the blade's outline to past the point and the guard's bar
	var e := BANNER_SWORD_EDGE
	var gy0 := base - 0.06
	lift[0] = 0.015
	_banner_quad(st, on.call(-w - e, base - e), on.call(w + e, base - e), on.call(0.0, foot + h + e * 1.5), on.call(-w * 0.45 - e, foot + h - blade * 0.55),
		BANNER_BAR, BANNER_BAR)
	_banner_quad(st, on.call(w + e, base - e), on.call(w * 0.45 + e, foot + h - blade * 0.55), on.call(0.0, foot + h + e * 1.5), on.call(0.0, foot + h + e * 1.5),
		BANNER_BAR, BANNER_BAR)
	var gd := h * BANNER_SWORD.z * 0.5 + e
	_banner_quad(st, on.call(-gd, gy0 - 0.03 - e), on.call(gd, gy0 - 0.03 - e), on.call(gd, gy0 + 0.05 + e), on.call(-gd, gy0 + 0.05 + e), BANNER_BAR, BANNER_BAR)
	lift[0] = 0.02
	# the blade: its two halves, the one away from the light a little darker, one long taper to the point
	_banner_quad(st, on.call(-w, base), on.call(0.0, base), on.call(0.0, foot + h), on.call(-w * 0.45, foot + h - blade * 0.55), g, g)
	_banner_quad(st, on.call(0.0, base), on.call(w, base), on.call(w * 0.45, foot + h - blade * 0.55), on.call(0.0, foot + h), shade, shade)
	# the guard, its tips falling
	var gy := base - 0.06
	_banner_quad(st, on.call(-guard * 0.5, gy - 0.03), on.call(guard * 0.5, gy - 0.03), on.call(guard * 0.42, gy + 0.05), on.call(-guard * 0.42, gy + 0.05), g, g)
	_banner_quad(st, on.call(-guard * 0.5, gy - 0.05), on.call(-guard * 0.42, gy + 0.06), on.call(-guard * 0.56, gy - 0.12), on.call(-guard * 0.56, gy - 0.12), g, g)
	_banner_quad(st, on.call(guard * 0.5, gy - 0.05), on.call(guard * 0.42, gy + 0.06), on.call(guard * 0.56, gy - 0.12), on.call(guard * 0.56, gy - 0.12), g, g)
	# the grip and the round pommel
	var gw := h * BANNER_SWORD_WIDTH.y
	var r := h * BANNER_SWORD_WIDTH.z
	_banner_quad(st, on.call(-gw, gy - 0.03), on.call(gw, gy - 0.03), on.call(gw, gy - 0.03 - grip), on.call(-gw, gy - 0.03 - grip), shade, shade)
	var pc := Vector2(0.0, gy - 0.03 - grip - r * 0.8)
	for i in 8:
		var a0 := TAU * i / 8.0
		var a1 := TAU * (i + 1) / 8.0
		_banner_quad(st, on.call(pc.x, pc.y), on.call(pc.x + cos(a0) * r, pc.y + sin(a0) * r), on.call(pc.x + cos(a1) * r, pc.y + sin(a1) * r),
			on.call(pc.x, pc.y), g, g)


## One quad of a banner (a, b, c, d round it), the colour ca on the a-d side and cb on the b-c side.
func _banner_quad(st: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, d: Vector3, ca: Color, cb: Color) -> void:
	var pts: Array[Vector3] = [a, b, c, a, c, d]
	var cols: Array[Color] = [ca, cb, cb, ca, cb, ca]
	for i in 6:
		st.set_color(cols[i])
		st.add_vertex(pts[i])


## A row of a piece from a to b (on the floor), one every `step` meters, facing across the line.
func row(name_: String, a: Vector3, b: Vector3, step: float, yaw_offset: float = 0.0, size := Vector3.ONE) -> void:
	var n := maxi(1, roundi(a.distance_to(b) / step))
	var dir := (b - a) / n
	var yaw := atan2(dir.x, dir.z) - PI * 0.5 + yaw_offset
	for i in n:
		piece(name_, a + dir * (i + 0.5), yaw, size)


## A deep bronze fire bowl on a capped stone pedestal: the warm light of the room. y: the ground it stands on; solid:
## it blocks the way (a circle of BRAZIER_RADIUS). Returns its light. lit false: a cold bowl of grey ash, no fire nor
## light (returns null).
func brazier(at: Vector2, y: float = 0.0, solid := true, light := BRAZIER_LIGHT, lit := true) -> OmniLight3D:
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
	bowl.material_override = _bronze() if lit else _cold_metal()
	bowl.position = base + Vector3(0, foot + BRAZIER_BOWL.z * 0.5, 0)
	root.add_child(bowl)
	var rim := MeshInstance3D.new()
	var torus := TorusMesh.new()
	torus.inner_radius = BRAZIER_BOWL.x - BRAZIER_RIM
	torus.outer_radius = BRAZIER_BOWL.x + BRAZIER_RIM
	torus.rings = 16
	torus.ring_segments = 6
	rim.mesh = torus
	rim.material_override = _rim() if lit else _cold_metal()
	rim.position = base + Vector3(0, foot + BRAZIER_BOWL.z, 0)
	root.add_child(rim)
	# a bed of dark ash in the bowl and the coals glowing in its middle (brightest at the heart, out before the rim)
	var ash := MeshInstance3D.new()
	var disc := CylinderMesh.new()
	disc.top_radius = BRAZIER_BOWL.x - BRAZIER_RIM
	disc.bottom_radius = BRAZIER_BOWL.x - BRAZIER_RIM
	disc.height = 0.03
	disc.radial_segments = 14
	ash.mesh = disc
	if lit:
		ash.material_override = _glow(ASH)
	else:
		var cold := _plain(COLD_ASH, 0.95)
		cold.metallic = 0.0
		ash.material_override = cold
	ash.position = base + Vector3(0, foot + BRAZIER_BOWL.z + 0.015, 0)
	root.add_child(ash)
	if not lit:
		# a cold bowl (room redesign lot D, the trial's T3): grey ash, no coals, no fire, no light
		if solid:
			circles.append(Vector3(at.x, at.y, BRAZIER_RADIUS))
		return null
	var coals := MeshInstance3D.new()
	var bed := PlaneMesh.new()
	bed.size = Vector2.ONE * BRAZIER_BOWL.x * 2.0 * COALS_SHARE
	coals.mesh = bed
	coals.material_override = _coals()
	coals.position = base + Vector3(0, foot + BRAZIER_BOWL.z + 0.04, 0)
	coals.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
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
	l.set_meta(BOWL, true)
	root.add_child(l)
	if solid:
		circles.append(Vector3(at.x, at.y, BRAZIER_RADIUS))
	if _wet_spots.size() < WET_SPOTS:
		_wet_spots.append(Vector4(at.x, at.y, BRAZIER_WET.x, BRAZIER_WET.y))
		for f in _floors:
			_wet(f)
	return l


## Flames rising from a point: radius of the fire, how many tongues, the size of a tongue, how long one lives. Upright
## tongues (pointed, ArenaKit.tongue) in orange round a smaller white-gold heart, and embers drifting up.
func fire(at: Vector3, radius: float, amount: int, tongue := 0.42, life := 0.7) -> void:
	_flames(at, radius, amount, tongue, life, FLAME, FLAME_EDGE, 0)
	_flames(at, radius * HEART_SPREAD, maxi(3, roundi(amount / 3.0)), tongue * HEART, life * 0.8, FLAME_HEART, FLAME, 1)
	# the fixed core: one near-white tongue that only flickers in size (each fire to its own beat)
	if _core_mesh == null:
		_core_mesh = ArenaKit.tongue(FLAME_CORE_SIZE, FLAME_CORE, Tongue.DROP, 2)
	var core := MeshInstance3D.new()
	core.mesh = _core_mesh
	core.position = at + Vector3(0, 0.02, 0)
	core.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	root.add_child(core)
	if core.is_inside_tree():
		var beat := RandomNumberGenerator.new()
		beat.seed = hash(Vector3i(at * 100.0))
		var tw := core.create_tween().set_loops()
		for i in 8:
			var k := 1.0 + beat.randf_range(-FLAME_CORE_FLICKER.x, FLAME_CORE_FLICKER.x)
			tw.tween_property(core, "scale", Vector3(2.0 - k, k, 1.0), 0.5 / beat.randf_range(FLAME_CORE_FLICKER.y, FLAME_CORE_FLICKER.z))
	# embers drifting up out of it
	var e := CPUParticles3D.new()
	e.position = at + Vector3(0, EMBERS_FROM, 0)
	e.amount = EMBERS
	e.lifetime = 2.2
	e.emission_shape = CPUParticles3D.EMISSION_SHAPE_SPHERE
	e.emission_sphere_radius = radius
	e.direction = Vector3.UP
	e.spread = 25.0
	e.initial_velocity_min = 0.7
	e.initial_velocity_max = 1.4
	e.gravity = Vector3(0.2, 0.3, 0)
	e.mesh = Fx.quad(0.05, EMBER)
	e.color_ramp = Fx.fade_ramp(Color(1, 1, 1, 1))
	root.add_child(e)


## One layer of a fire's licks: they rise from `radius`, go from `color` to `edge` as they narrow, and fade out.
func _flames(at: Vector3, radius: float, amount: int, size: float, life: float, color: Color, edge: Color, priority: int) -> void:
	var f := CPUParticles3D.new()
	f.position = at
	f.amount = amount
	f.lifetime = life
	f.emission_shape = CPUParticles3D.EMISSION_SHAPE_SPHERE
	f.emission_sphere_radius = radius * FLAME_SPREAD
	f.direction = Vector3.UP
	f.spread = 8.0
	f.initial_velocity_min = 0.5
	f.initial_velocity_max = 1.1
	f.gravity = Vector3(0, 0.8, 0)
	f.scale_amount_min = 0.7
	f.scale_amount_max = 1.2
	# each tongue narrows as it rises, from its hot colour to an orange edge and out
	var taper := Curve.new()
	taper.add_point(Vector2(0, 0.7))
	taper.add_point(Vector2(0.3, 1.0))
	taper.add_point(Vector2(1, 0.35))
	f.scale_amount_curve = taper
	f.mesh = tongue(Vector2(TONGUE.x, TONGUE.y) * size, color, Tongue.LICK, priority)
	# the ramp only cools the lick's own colour (which is HDR, in the material) toward its edge
	var cool := Color(edge.r / color.r, edge.g / color.g, edge.b / color.b)
	var ramp := Gradient.new()
	ramp.offsets = PackedFloat32Array([0.0, 0.7, 1.0])
	ramp.colors = PackedColorArray([Color.WHITE, Color.WHITE.lerp(cool, 0.7), Color(cool, 0.0)])
	f.color_ramp = ramp
	root.add_child(f)


## The shapes of a flame's tongue (tongue): a soft long point added on top (candles); a drop with a soft edge, added
## (the fixed core of a fire); a crisp lick blended over what is behind (the body of a fire: licks hide each other
## instead of piling up into a haze, so the flame keeps a painted outline).
enum Tongue { POINT, DROP, LICK }
static var _tongue_tex: Array[ImageTexture] = [null, null, null]

## A flame's tongue: an upright card (turning round Y to the camera) with a pointed, round-bottomed shape in its
## colour (HDR, so the core blooms a little). size: width and height in meters; shape: a Tongue; priority: drawn
## over the tongues of lower priority.
static func tongue(size: Vector2, color: Color, shape := Tongue.POINT, priority := 0) -> QuadMesh:
	if _tongue_tex[shape] == null:
		var w := 32
		var h := 64
		var drop := shape == Tongue.DROP
		var soft: float = [0.55, 0.8, 0.22][shape]
		var img := Image.create(w, h, false, Image.FORMAT_RGBA8)
		for y in h:
			var v := 1.0 - (y + 0.5) / h
			# the radius of the tongue at height v: round at the foot, widest low, a long point (or a drop's belly)
			var r := 0.95 * pow(1.0 - v, 0.55 if drop else 0.85) * sqrt(clampf(v / (0.3 if drop else 0.22), 0.0, 1.0))
			for x in w:
				var u := absf((x + 0.5) / w * 2.0 - 1.0)
				var a := clampf((r - u) / maxf(r * soft, 0.02), 0.0, 1.0)
				# brighter in the middle and low down
				var core := clampf(1.0 - u / maxf(r, 0.01), 0.0, 1.0) * (1.0 - v * 0.5)
				var alpha := a * (0.55 + 0.45 * core)
				if drop:
					alpha = a * a * (0.4 + 0.6 * core)
				elif shape == Tongue.LICK:
					alpha = a
				img.set_pixel(x, y, Color(1, 1, 1, alpha))
		_tongue_tex[shape] = ImageTexture.create_from_image(img)
	var q := QuadMesh.new()
	q.size = size
	q.center_offset = Vector3(0, size.y * 0.35, 0)
	var m := StandardMaterial3D.new()
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.billboard_mode = BaseMaterial3D.BILLBOARD_FIXED_Y
	m.billboard_keep_scale = true
	m.blend_mode = BaseMaterial3D.BLEND_MODE_MIX if shape == Tongue.LICK else BaseMaterial3D.BLEND_MODE_ADD
	m.vertex_color_use_as_albedo = true
	m.albedo_color = color
	m.albedo_texture = _tongue_tex[shape]
	m.disable_receive_shadows = true
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	m.render_priority = priority
	q.material = m
	return q


## A hooded figure carved in stone (Masonry.hooded_statue), standing on a plinth. height: of the figure, in meters;
## y: the ground under the plinth; value: how light its stone is (the same stone for all); solid: it blocks the way.
func statue(at: Vector2, yaw: float, height: float = 4.2, y: float = 0.0, value := STATUE_VALUE, solid := true) -> void:
	var plinth := STATUE_PLINTH * height
	# a carved base of two bevelled steps, the upper one narrower than the robe's hem
	var low := Masonry.BASE_STEPS.x * height
	masonry.block(Vector3(at.x, y, at.y), Vector3(1.0, 0.0, 1.0) * height * STATUE_BASE.x + Vector3(0, low, 0), yaw)
	masonry.block(Vector3(at.x, y + low, at.y), Vector3(1.0, 0.0, 1.0) * height * STATUE_BASE.y + Vector3(0, plinth - low, 0), yaw)
	masonry.hooded_statue(Vector3(at.x, y + plinth, at.y), yaw, height, value)
	if solid:
		circles.append(Vector3(at.x, at.y, height * 0.25))


## A light on the statues of STATUE_LAYER alone (the weak warm light of a fire bowl, or a cold one from the hall):
## a spot from `from` at `to`, with no shadow.
func statue_glow(from: Vector3, to: Vector3, energy: float, reach: float, cone: float, color := FIRE, attenuation := 1.0) -> void:
	var up := SpotLight3D.new()
	root.add_child(up)
	up.look_at_from_position(from, to)
	up.light_color = color
	up.light_energy = energy
	up.spot_range = reach
	up.spot_angle = cone
	up.spot_attenuation = attenuation
	up.light_cull_mask = STATUE_LAYER


## A chain hanging between two points, sagging `sag` meters at its middle.
func chain(a: Vector3, b: Vector3, sag: float, size: float = 1.0) -> void:
	chains([[a, b]], sag, size)


## Chains hanging between pairs of points ([a, b] each), all of one size and sag, in one MultiMesh (one draw call; RS-C1:
## the crypt's crown hangs from four).
func chains(pairs: Array, sag: float, size: float = 1.0) -> void:
	var counts: Array[int] = []
	var total := 0
	for pair: Array in pairs:
		counts.append(maxi(2, ceili((pair[0] as Vector3).distance_to(pair[1]) / (LINK_GAP * size))))
		total += counts[-1]
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	var torus := TorusMesh.new()
	torus.inner_radius = maxf(LINK_SIZE * size - LINK_WIRE * size * 0.5, LINK_SIZE * size * 0.2)
	torus.outer_radius = LINK_SIZE * size
	torus.rings = 8
	torus.ring_segments = 6
	mm.mesh = torus
	mm.instance_count = total
	var k := 0
	for c in pairs.size():
		var a: Vector3 = pairs[c][0]
		var b: Vector3 = pairs[c][1]
		var n := counts[c]
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
			mm.set_instance_transform(k, Transform3D(basis, p))
			k += 1
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


## The glowing sheet of a portal (its middle at `center`, facing along yaw) and its light, dim until lit. arch: the
## sheet is cut to a pointed arch (x = its springing's height over the sheet's foot, y = its span, z = the radius of
## its arcs, all in m; zero: the whole rectangle glows).
func portal_glow(center: Vector3, yaw: float, size: Vector2, arch := Vector3.ZERO) -> void:
	var sheet := MeshInstance3D.new()
	var q := QuadMesh.new()
	q.size = size
	sheet.mesh = q
	var m := ShaderMaterial.new()
	m.shader = preload("res://assets/shaders/portal.gdshader")
	m.set_shader_parameter(&"color", PORTAL_SHEET)
	m.set_shader_parameter(&"power", PORTAL_DIM)
	m.set_shader_parameter(&"size", size)
	m.set_shader_parameter(&"arch", arch)
	sheet.material_override = m
	sheet.transform = Transform3D(Basis(Vector3.UP, yaw), center)
	root.add_child(sheet)
	var l := OmniLight3D.new()
	l.position = center + Basis(Vector3.UP, yaw) * Vector3(0, -size.y * PORTAL_LIGHT_DROP, PORTAL_LIGHT_AHEAD)
	l.light_color = PORTAL
	l.light_energy = PORTAL_LIGHT_DIM
	l.omni_range = PORTAL_RANGE
	l.omni_attenuation = 1.2
	l.light_cull_mask = WARM_MASK
	root.add_child(l)
	var entry: Array = [m, l]
	for s: float in [-1.0, 1.0]:
		var side := OmniLight3D.new()
		side.position = center + Basis(Vector3.UP, yaw) * Vector3(s * (size.x * 0.5 - PORTAL_SIDE_AT.x), -size.y * PORTAL_SIDE_AT.y, PORTAL_SIDE_AT.z)
		side.light_color = PORTAL
		side.light_energy = PORTAL_SIDE.x * PORTAL_LIGHT_DIM / PORTAL_LIGHT
		side.omni_range = PORTAL_SIDE.y
		side.light_cull_mask = WARM_MASK
		root.add_child(side)
		entry.append(side)
	portals.append(entry)
	portal_centers.append(center)


## Lights or dims a portal (open: the room is cleared and its reward waits behind it).
func light_portal(i: int, on: bool, tint: Color = PORTAL) -> void:
	if i >= portals.size():
		return
	portal_tints[i] = tint
	(portals[i][0] as ShaderMaterial).set_shader_parameter(&"power", PORTAL_OPEN if on else PORTAL_DIM)
	(portals[i][0] as ShaderMaterial).set_shader_parameter(&"color", PORTAL_SHEET if tint == PORTAL else tint)
	# the light a reward's colour throws on the walls, half toward a warm white (C18, one tone for the scenery: a red
	# heart's or a blue Magick's door washed the whole corner of the room in pure colour); Morvath's red stays whole
	if tint != PORTAL and tint != MORVATH:
		tint = tint.lerp(DOOR_LIGHT_WHITE, DOOR_LIGHT_MIX)
	var l: OmniLight3D = portals[i][1]
	l.light_color = tint
	l.light_energy = PORTAL_LIGHT if on else PORTAL_LIGHT_DIM
	for k in range(2, portals[i].size()):
		var side: OmniLight3D = portals[i][k]
		side.light_color = tint
		side.light_energy = PORTAL_SIDE.x * (1.0 if on else PORTAL_LIGHT_DIM / PORTAL_LIGHT)
	for extra: Array in portal_tinted.get(i, []):
		(extra[0] as Light3D).light_color = extra[1] if tint == PORTAL else tint


## A light that shows the colour of portal i whenever light_portal tints it (its own colour while the portal is green).
func tint_with_portal(i: int, light: Light3D) -> void:
	if not portal_tinted.has(i):
		portal_tinted[i] = []
	(portal_tinted[i] as Array).append([light, light.light_color, light.light_energy])


## Morvath's hold on portal i (cycle 9, portal.gdshader): unrest 0..1 (the last phase: restless veils, a slow violet
## pulse), seal 0..1 (the sealing: a ring of light closing on the core). gain: its lights (and the lights it tints)
## times their open energy, 1 being the plain open portal; below 0 its lights are left as light_portal set them and
## the lights it tints go back to their own energy.
func portal_mood(i: int, unrest: float, seal: float, gain: float) -> void:
	if i >= portals.size():
		return
	var m: ShaderMaterial = portals[i][0]
	m.set_shader_parameter(&"unrest", unrest)
	m.set_shader_parameter(&"seal", seal)
	if gain < 0.0:
		for extra: Array in portal_tinted.get(i, []):
			(extra[0] as Light3D).light_energy = extra[2]
		return
	(portals[i][1] as OmniLight3D).light_energy = PORTAL_LIGHT * gain
	for k in range(2, portals[i].size()):
		(portals[i][k] as OmniLight3D).light_energy = PORTAL_SIDE.x * gain
	for extra: Array in portal_tinted.get(i, []):
		(extra[0] as Light3D).light_energy = (extra[2] as float) * gain


## Violet light glowing up out of the abyss: an upright card facing the camera's way (yaw), its foot at `foot`.
## shape: how far up the card the glow goes (0 to 1 of its height), how fast it fades up from its foot, and the share
## of its width that fades out at each side (0.5: from the middle on).
func abyss_glow(foot: Vector3, size: Vector2, yaw: float, energy := ABYSS_GLOW_ENERGY, shape := ABYSS_GLOW_SHAPE) -> void:
	var card := MeshInstance3D.new()
	var q := QuadMesh.new()
	q.size = size
	card.mesh = q
	var key := Vector4(energy, shape.x, shape.y, shape.z)
	if not _glow_mats.has(key):
		var m := ShaderMaterial.new()
		m.shader = preload("res://assets/shaders/abyss_glow.gdshader")
		m.set_shader_parameter(&"color", ABYSS_GLOW)
		m.set_shader_parameter(&"energy", energy)
		m.set_shader_parameter(&"reach", shape.x)
		m.set_shader_parameter(&"falloff", shape.y)
		m.set_shader_parameter(&"side", shape.z)
		_glow_mats[key] = m
	card.material_override = _glow_mats[key]
	card.transform = Transform3D(Basis(Vector3.UP, yaw), foot + Vector3(0, size.y * 0.5, 0))
	card.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	card.extra_cull_margin = maxf(size.x, size.y)
	root.add_child(card)


## A card of far ruins in the abyss (abyss_ruins.gdshader): an upright quad that does not turn to the camera, its
## middle at `center`, facing along yaw. The silhouettes are drawn by the shader, cut by alpha scissor in the opaque
## pass (no blending): towers of stacked blocks a `column` wide apart (their mean top and spread in `tops`), arches and
## decks between some, a cave's roof on top if `roof` is set (its height, how much lower to the west, and where
## along the card it starts to drop and is lowest). mist: the
## colour they fade into (haze: the share of it in the stone; sink: the heights where the feet start to sink and are gone).
## patches: only on the backdrop (the farthest card, which also paints the mist where no stone stands): two lighter
## patches of mist (x = m from the card's middle, y = height, z and w = radii).
func ruin_card(center: Vector3, size: Vector2, yaw: float, mist: Color, haze: float, column: float, seed_: float, tops: Vector2,
		sink: Vector2, roof := Vector4.ZERO, patches: Array[Vector4] = []) -> void:
	var card := MeshInstance3D.new()
	var q := QuadMesh.new()
	q.size = size
	card.mesh = q
	var m := ShaderMaterial.new()
	m.shader = preload("res://assets/shaders/abyss_ruins.gdshader")
	m.set_shader_parameter(&"stone_color", RUIN_STONE)
	m.set_shader_parameter(&"edge_color", RUIN_EDGE)
	m.set_shader_parameter(&"mist_color", mist)
	m.set_shader_parameter(&"haze", haze)
	m.set_shader_parameter(&"column", column)
	m.set_shader_parameter(&"seed", seed_)
	m.set_shader_parameter(&"top", tops)
	m.set_shader_parameter(&"sink", sink)
	m.set_shader_parameter(&"roof", Vector2(roof.x, roof.y))
	m.set_shader_parameter(&"roof_fall", Vector2(roof.z, roof.w))
	m.set_shader_parameter(&"half_width", size.x * 0.5)
	m.set_shader_parameter(&"course", RUIN_COURSE)
	if patches.size() == 2:
		m.set_shader_parameter(&"backdrop", 1.0)
		m.set_shader_parameter(&"patch_a", patches[0])
		m.set_shader_parameter(&"patch_b", patches[1])
	card.material_override = m
	card.transform = Transform3D(Basis(Vector3.UP, yaw), center)
	card.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	card.layers = DEPTH_LAYER
	root.add_child(card)


## A bank of pale mist in the abyss (abyss_mist.gdshader): a wide low card turning to the camera, its middle at
## `center`, ragged at its edges; grain: a finer mottle mixed in; bands: how much it parts into level streaks; drift: how
## fast it runs sideways (the shader's, UV per second; below 0: the shader's own).
func mist_bank(center: Vector3, size: Vector2, color: Color, alpha: float, grain := 0.0, bands := 0.0, drift := -1.0) -> void:
	var card := MeshInstance3D.new()
	var q := QuadMesh.new()
	q.size = size
	card.mesh = q
	var m := ShaderMaterial.new()
	m.shader = preload("res://assets/shaders/abyss_mist.gdshader")
	m.set_shader_parameter(&"color", color)
	m.set_shader_parameter(&"alpha", alpha)
	m.set_shader_parameter(&"grain", grain)
	m.set_shader_parameter(&"bands", bands)
	if drift >= 0.0:
		m.set_shader_parameter(&"drift", drift)
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
	fm.albedo = ABYSS_FOG_ALBEDO
	fm.emission = ABYSS_FOG_EMISSION
	fm.edge_fade = 0.4
	v.material = fm
	root.add_child(v)


## The abyss around a platform of half size `half`: mist in layers (of colour `mist`) over a deep glow, and dark cliffs
## under the platform's sides (from the floor down out of sight).
func abyss(half: Vector2, depth: float = 18.0, cliff := true, mist := MIST) -> void:
	var span := maxf(half.x, half.y) * 6.0
	for k in 4:
		var plane := MeshInstance3D.new()
		var pm := PlaneMesh.new()
		pm.size = Vector2(span, span)
		plane.mesh = pm
		var m := ShaderMaterial.new()
		m.shader = preload("res://assets/shaders/abyss_fog.gdshader")
		m.set_shader_parameter(&"color", mist * (1.0 + k * 0.15))
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
	var m := floor_material(ring_radius, ring_center, minf(size.x, size.y) * 0.32)
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


## A floor's material (the catacomb floor's shader unless told: the Chamber's floor shares its slabs), kept wet
## round the fire bowls (brazier). ring_radius: the medallion's (0: none); calm_radius: the calm middle's.
func floor_material(ring_radius := 0.0, ring_center := Vector2.ZERO, calm_radius := 9.0, shader: Shader = null) -> ShaderMaterial:
	var m := ShaderMaterial.new()
	m.shader = shader if shader else FLOOR_SHADER
	m.set_shader_parameter(&"ring_radius", ring_radius)
	m.set_shader_parameter(&"ring_glow", MEDALLION_GLOW)
	m.set_shader_parameter(&"ring_center", ring_center)
	m.set_shader_parameter(&"wet_zone", Vector4(wet_zone.position.x, wet_zone.position.y, wet_zone.end.x, wet_zone.end.y))
	# the rose's long points run across the screen, as in the picture
	m.set_shader_parameter(&"rose_turn", deg_to_rad(Feel.live().cam_yaw))
	m.set_shader_parameter(&"calm_radius", calm_radius)
	m.set_shader_parameter(&"rock_normal", Masonry.ROCK_NORMAL)
	m.set_shader_parameter(&"rock_height", Masonry.ROCK_HEIGHT)
	_floors.append(m)
	_wet(m)
	return m


func _wet(m: ShaderMaterial) -> void:
	var spots := _wet_spots.duplicate()
	spots.resize(WET_SPOTS)
	m.set_shader_parameter(&"wet_spots", spots)
	m.set_shader_parameter(&"wet_spot_count", _wet_spots.size())


func _stone(_m: Material) -> Material:
	return masonry.stone()


## The coals in a bowl: glowing at the heart, dark red toward the rim, out before it (added on the ash).
func _coals() -> StandardMaterial3D:
	if _coals_mat == null:
		var g := Gradient.new()
		g.offsets = PackedFloat32Array([0.0, 0.45, 1.0])
		g.colors = PackedColorArray([Color.WHITE, Color(0.55, 0.3, 0.2), Color.BLACK])
		var tex := GradientTexture2D.new()
		tex.gradient = g
		tex.fill = GradientTexture2D.FILL_RADIAL
		tex.fill_from = Vector2(0.5, 0.5)
		tex.fill_to = Vector2(1.0, 0.5)
		tex.width = 32
		tex.height = 32
		_coals_mat = StandardMaterial3D.new()
		_coals_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		_coals_mat.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
		_coals_mat.albedo_color = COALS
		_coals_mat.albedo_texture = tex
	return _coals_mat


## The bowl's rim: bronze lit warm from inside by the coals.
func _rim() -> StandardMaterial3D:
	if _rim_mat == null:
		_rim_mat = _plain(BRONZE * 1.2, 0.4)
		_rim_mat.metallic = 0.7
		_rim_mat.emission_enabled = true
		_rim_mat.emission = RIM_GLOW
		_rim_mat.emission_energy_multiplier = RIM_GLOW_ENERGY
	return _rim_mat


## A cold bowl's metal (brazier(..., lit = false)): dark iron, no glow on its rim.
func _cold_metal() -> StandardMaterial3D:
	if _cold_mat == null:
		_cold_mat = _plain(STY_IRON, STY_METAL.x)
		_cold_mat.metallic = STY_METAL.y
	return _cold_mat


var _cold_mat: StandardMaterial3D


## RS-C1: a lit brazier (built by brazier() at `at`) gone cold in the stylized look only (VisualProfile): its bowl and
## rim in the cold iron, its ash grey, its coals, fire, core and light hidden; the classic look keeps it lit. Its
## pedestal (merged stone) and its collision do not change. Call once the room is merged.
func quench(at: Vector2, reach := BRAZIER_RADIUS) -> void:
	if _cold_ash == null:
		_cold_ash = _plain(COLD_ASH, 0.95)
		_cold_ash.metallic = 0.0
	for n in root.get_children():
		var g := n as Node3D
		if g == null or Vector2(g.position.x, g.position.z).distance_to(at) > reach:
			continue
		if g is CPUParticles3D or (g is OmniLight3D and g.has_meta(BOWL)):
			VisualProfile.vary(g, {&"visible": false})
		elif g is MeshInstance3D:
			var mi := g as MeshInstance3D
			var mat := mi.material_override as StandardMaterial3D
			if mi.mesh == _core_mesh or (mat != null and mat == _coals_mat):
				VisualProfile.vary(mi, {&"visible": false})
			elif mat == null:
				continue
			elif mat == _bronze_mat or mat == _rim_mat:
				VisualProfile.vary(mi, {&"material_override": _cold_metal()})
			elif mat.shading_mode == BaseMaterial3D.SHADING_MODE_UNSHADED and mat.albedo_color == ASH:
				VisualProfile.vary(mi, {&"material_override": _cold_ash})


var _cold_ash: StandardMaterial3D


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


## The fountain's basin (AP-1, ART-01.6; Game.spawn_fountain puts it where the fountain springs): before, a disc of
## yellow light on the floor, a spray of white sparks and a warm light, nothing of stone. Now a low round basin of the
## hall's stone (a kerb in FOUNTAIN_SIDES blocks, outer radius, height, width: it covers the holy pool's disc under
## it), still water in it (fountain_water.gdshader), a short spout in the middle with a small bowl the spring rises from,
## the spring and the light in the Fonte's cold ivory-blue (art_direction 6.3) under the glow threshold. The basin is
## low (under the knee: one walks up to it and drinks) and blocks nothing; the touch is Game's (2 m round its middle).
const FOUNTAIN_BASIN := Vector3(1.95, 0.24, 0.3)
const FOUNTAIN_SIDES := 14
const FOUNTAIN_WATER_Y := 0.14
## The spout: shaft radius and height, the bowl on top (radius, depth).
const FOUNTAIN_SPOUT := Vector2(0.2, 0.62)
const FOUNTAIN_BOWL := Vector2(0.5, 0.16)
## The spring's drops (HDR colour under the glow threshold, size, how many, how fast they rise, how fast they fall
## back: a low spring over the bowl, not a spray of sparks 6 m high) and the light (colour; its energy is Game's).
const FOUNTAIN_SPRING := Color(0.78, 0.9, 1.0)
const FOUNTAIN_SPRING_SIZE := 0.14
const FOUNTAIN_SPRING_COUNT := 28
const FOUNTAIN_SPRING_SPEED := Vector2(1.4, 2.2)
const FOUNTAIN_SPRING_FALL := 4.5
const FOUNTAIN_LIGHT := Color(0.82, 0.9, 1.0)
## After he drinks: the water's glow goes out in this many seconds.
const FOUNTAIN_SPENT_TIME := 1.2
const FOUNTAIN_WATER_SHADER := preload("res://assets/shaders/fountain_water.gdshader")


static func fountain(parent: Node3D) -> void:
	var mason := Masonry.new(parent)
	var stone := mason.stone(0.0)
	var r := FOUNTAIN_BASIN.x - FOUNTAIN_BASIN.z * 0.5
	var seg := TAU * r / FOUNTAIN_SIDES
	for k in FOUNTAIN_SIDES:
		var a := TAU * (k + 0.5) / FOUNTAIN_SIDES
		var at := Vector3(cos(a), 0.0, sin(a)) * r
		mason.box(at + Vector3(0, FOUNTAIN_BASIN.y * 0.5, 0), Vector3(seg * 1.02, FOUNTAIN_BASIN.y, FOUNTAIN_BASIN.z), -a + PI * 0.5, stone)
	# the spout: a shaft with a ring at its foot, the bowl on top
	mason.shaft(Vector3(0, FOUNTAIN_WATER_Y - 0.05, 0), FOUNTAIN_SPOUT.x, FOUNTAIN_SPOUT.y, stone)
	var bowl := MeshInstance3D.new()
	var cyl := CylinderMesh.new()
	cyl.top_radius = FOUNTAIN_BOWL.x
	cyl.bottom_radius = FOUNTAIN_BOWL.x * 0.55
	cyl.height = FOUNTAIN_BOWL.y
	cyl.radial_segments = 16
	cyl.rings = 1
	bowl.mesh = cyl
	bowl.material_override = stone
	bowl.position = Vector3(0, FOUNTAIN_WATER_Y - 0.05 + FOUNTAIN_SPOUT.y + FOUNTAIN_BOWL.y * 0.5, 0)
	parent.add_child(bowl)
	var water := MeshInstance3D.new()
	water.name = "Water"
	var q := PlaneMesh.new()
	q.size = Vector2.ONE * (FOUNTAIN_BASIN.x - FOUNTAIN_BASIN.z * 0.6) * 2.0
	water.mesh = q
	var wm := ShaderMaterial.new()
	wm.shader = FOUNTAIN_WATER_SHADER
	wm.set_shader_parameter(&"radius", FOUNTAIN_BASIN.x - FOUNTAIN_BASIN.z * 0.6)
	water.material_override = wm
	water.position.y = FOUNTAIN_WATER_Y
	water.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(water)
	var top := MeshInstance3D.new()
	var disc := PlaneMesh.new()
	disc.size = Vector2.ONE * FOUNTAIN_BOWL.x * 1.8
	top.mesh = disc
	top.material_override = wm
	top.position.y = bowl.position.y + FOUNTAIN_BOWL.y * 0.5 - 0.02
	top.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(top)
	# the spring out of the bowl (Game._step_fountain stops it by its name)
	var spring := CPUParticles3D.new()
	spring.name = "Spring"
	spring.position.y = top.position.y
	spring.amount = FOUNTAIN_SPRING_COUNT
	spring.lifetime = 1.0
	spring.direction = Vector3.UP
	spring.spread = 12.0
	spring.initial_velocity_min = FOUNTAIN_SPRING_SPEED.x
	spring.initial_velocity_max = FOUNTAIN_SPRING_SPEED.y
	spring.gravity = Vector3(0, -FOUNTAIN_SPRING_FALL, 0)
	spring.emission_shape = CPUParticles3D.EMISSION_SHAPE_SPHERE
	spring.emission_sphere_radius = FOUNTAIN_BOWL.x * 0.3
	spring.mesh = Fx.quad(FOUNTAIN_SPRING_SIZE, FOUNTAIN_SPRING)
	spring.color_ramp = Fx.fade_ramp(Color.WHITE)
	parent.add_child(spring)
	mason.merge()
	# the stylized look's moss, candles and painted stone (room redesign lot A 3.4)
	CatacombHall.dress_fountain(parent)


## After he drinks (Game._step_fountain): the water's glow goes out.
static func fountain_spent(parent: Node3D) -> void:
	var water := parent.get_node_or_null("Water") as MeshInstance3D
	if water == null:
		return
	var wm := water.material_override as ShaderMaterial
	if water.is_inside_tree():
		water.create_tween().tween_method(func(v: float) -> void: wm.set_shader_parameter(&"spent", v), 0.0, 1.0, FOUNTAIN_SPENT_TIME)
	else:
		wm.set_shader_parameter(&"spent", 1.0)
