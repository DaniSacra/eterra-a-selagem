class_name ArenaRoom
extends Node3D
## The look of an arena of cycle C12 (the crypt, the rift hall, the garden), drawn from its RoomLayout: the floor
## (the catacomb floor's shader, its slabs and colours the arena's: floor_look) with its holes, every edge of it
## (edge: by default the broken edge over the abyss, spec 1.3), the abyss's mist and violet glow, each obstacle drawn
## on its own footprint (ArenaObstacle.piece: the collision and the look come from the same data; the funerary pieces
## are TombKit's), the doors (stairs going down, the arch of a door in a wall, the grille of a door not used, the
## lantern of a door used), the arena's air (air: dressed when it is built, given back when it leaves) and its light.
## Each arena's script (CryptLook, RiftLook, GardenLook) overrides what is its own, following
## docs/art/cycle12_arenas_spec.md. Collision never comes from here (Arena._build_arena reads the layout).

## The looks an arena may have (RoomLayout.look) and the script of each.
const LOOKS: Array[StringName] = [&"crypt", &"rift", &"garden", &"sanctuary", &"bridge", &"runes", &"trial", &"altar", &"hub"]
## How deep the cliffs under the floor's edges drop, and the abyss under them.
const DEPTH := 22.0
## A render layer only an arena's floor is on (with 1), for a fill light of the floor alone (floor_layers; M-1, the
## crypt). Not used by anything else (2 the crowd, 4 the depths, 8 the facade, 16 the statues, 32 the stone tree).
const FLOOR_LAYER := 64
## A lip of stone along every edge: its height under the floor and how far it stands out.
const LIP := Vector2(0.35, 0.18)
## Points along the floor's edges for its triangles (meters apart), and inside it; the floor is cut in squares this
## big (each only takes the lights near it, which the browser's renderer needs).
const EDGE_STEP := 0.5
const FILL_STEP := 2.0
const FLOOR_CELL := 8.0
## The floor's vertices carry their distance to the floor's edge in their colour's red, over this many m (the painted
## floor's biome patches grow toward the edge, SW-G1; FLOOR_EDGE_NORM in floor_biome.gdshaderinc). The classic floor
## never reads it.
const FLOOR_EDGE_NORM := 8.0
## The violet light under each hole (the abyss's).
const ABYSS_LIGHT_ENERGY := 4.0
const ABYSS_LIGHT_Y := -9.0
## A door's light when dim (Arena.light_exit lights it when it opens).
const DOOR_DIM := 0.6
## The broken edge (spec 1.3): a tooth of stone every TOOTH_STEP meters (range), its length along the edge, how far
## it stands out, how tall; its top under the floor by TOOTH_DROP; one in TOOTH_GAP is a gap instead (missing
## stones); the slabs of the brink sunk SAG under the floor in a band SAG_BAND wide; loose shards falling in the first
## meters (SHARDS per meter, their size).
const TOOTH_STEP := Vector2(0.8, 2.0)
const TOOTH_LENGTH := Vector2(0.4, 1.2)
const TOOTH_OUT := Vector2(0.15, 0.55)
const TOOTH_TALL := Vector2(0.6, 2.2)
const TOOTH_DROP := Vector2(0.06, 0.4)
const TOOTH_GAP := 0.25
const SAG := Vector2(0.05, 0.25)
const SAG_BAND := 0.3
const SHARDS := 0.35
const SHARD := Vector2(0.15, 0.4)
## A balustrade over the abyss stands this far out of the edge (its posts never on the floor); broken: runs of
## BALUSTRADE_RUN meters (range) with gaps of BALUSTRADE_GAP between them.
const BALUSTRADE_OUT := 0.55
const BALUSTRADE_RUN := Vector2(2.0, 4.0)
const BALUSTRADE_GAP := Vector2(1.0, 2.0)
## A broken balustrade's runs start and end this far in from its edge's ends (its offset out and half a post).
const BALUSTRADE_END := BALUSTRADE_OUT + Masonry.POST.x * 0.5
## The thread of old gold inlaid along a bare edge (spec 3.1): its width and how far in from the drop.
const FILET := Vector2(0.05, 0.22)
## The stairs of a door going down out of the room: steps, rise and run of each; the low cheeks beside them.
const EXIT_STEPS := 7
const EXIT_RISE := 0.24
const EXIT_RUN := 0.42
const EXIT_CHEEK := Vector2(0.55, 0.9)
## How far out of the edge and of the mouth's side the pillars beside a door's mouth stand (their middle: half a post
## and its plinth's lip), so neither the floor nor the mouth has stone over it.
const DOOR_POST_OUT := Masonry.POST.x * 0.5 + 0.06
## A door in a wall: the pointed arch over its mouth (opening a little wider than the mouth, height).
const WALL_DOOR := Vector2(4.0, 5.2)
const JAMB := 0.3
## A sarcophagus of the arenas (spec 1.2): plinth, lid (height, overhang), the sword on its lid, its stone (times the
## arena's) and the lid's; a box at least TOMB_FROM long is the great tomb (spec 1.3).
const SARC_PLINTH := 0.15
const SARC_LID := Vector2(0.15, 0.05)
const SARC_SWORD := 1.5
const SARC_TINT := 1.25
const SARC_LID_LIGHT := 1.5
const TOMB_FROM := 3.5
## A column at least this tall is whole (with its capital and the spring of an arch); lower ones are broken.
const WHOLE_COLUMN := 4.5
## A wall-like block (a ruined wall, a dividing wall): its top broken in steps this big (range, meters down).
const RUIN_STEP := Vector2(0.2, 0.6)
## Candles (on top of pieces, never loose on the floor, spec 0.3): heights and radii (range), how many at most, the
## light of a lit group (energy, range) and the warm halo over it.
const CANDLE_HEIGHT := Vector2(0.12, 0.35)
const CANDLE_RADIUS := Vector2(0.05, 0.09)
const CANDLE_MAX := 5
const CANDLE_LIGHT := 1.2
const CANDLE_RANGE := 2.8
const CANDLE_COLOR := Color(1.0, 0.7, 0.4)
const CANDLE_HALO := 0.45
const CANDLE_HALO_ALPHA := 0.3
## A bridge: its deck's thickness under the floor (the cornice) and how far it stands out of the walkable 5 m on each
## side (the parapet stands on it), the arch under it (its crown this far under the deck, the ring's width), the piers
## going down into the mist. The arch, its haunches and the piers are the depths' dark stone (no light of their own).
const DECK := 0.6
const DECK_OUT := 0.65
const ARCH_CROWN := 2.5
const ARCH_RING := 0.7
const ARCH_RADIUS := 0.8
## The deck's own paving over the floor (F-2, so a bridge never reads as a strip of the floor): slabs running along the
## span (length range, rows across between the kerbs, the joint, their top over the floor, their stone times the
## arena's), a kerb of lighter stone along both sides of the walkable 5 m (width, top, stone), a dark seam where the
## deck meets the platform (width), the joints' and seams' stone (the depths' dark).
const DECK_SLAB := Vector2(1.1, 2.1)
const DECK_ROWS := 4
const DECK_JOINT := 0.06
const DECK_TOP := 0.016
const DECK_TINT := Color(0.8, 0.8, 0.8)
const KERB := Vector3(0.3, 0.022, 1.1)
const SEAM := 0.08
const SEAM_TOP := 0.008
## The open parapet outside the walkable 5 m (spec 1.3: low, 0.5 m wide; never see-through): its height, its depth, its
## middle's distance out of the walkable edge; the curb and the rail (height, depth); balusters (side, spacing, the
## belly's side and height); a post every PARAPET_POST meters (side).
const PARAPET := Vector3(0.9, 0.4, 0.32)
const PARAPET_CURB := Vector2(0.18, 0.4)
const PARAPET_RAIL := Vector2(0.16, 0.38)
const BALUSTER := Vector4(0.13, 0.42, 0.2, 0.16)
const PARAPET_POST := 3.0
const PARAPET_POST_SIDE := 0.36
## A pillar at each of the four heads (F-2: 1.4 m; side, cap) and under each the abutment (F-3, "pegão") the bridge
## springs from: a block of cut stone against the rift's wall beside the deck (along the wall out of the walkable edge,
## into the rift, its cut stone this deep, then the depths' stone down to ABUTMENT_FOOT).
const HEAD := Vector3(0.55, 1.4, 0.2)
const HEAD_LANTERN := Vector3(0.5, 1.0, 0.5)
const ABUTMENT := Vector3(1.35, 1.1, 1.3)
const ABUTMENT_FOOT := -5.0
## Its lanterns (one at each end, diagonally): warm, a little stronger.
const BRIDGE_LAMP_ENERGY := 1.5
const BRIDGE_LAMP_RANGE := 4.5
## The rift's broken lips (spec 1.3, F-3): chunks of the brink's slabs standing out past the drop (length along the
## lip, how far out at each end, their top sunk under the floor: art pack 2026-11-17, a step down of 0.2 m and more, so
## the walkable floor ends at the drop and no chunk reads as floor one can stand on; they were 3 to 16 cm, the same
## paving at nearly the floor's height past the edge, tools/fit_probe.gd's "ledge"), a stretch with none between them (a missing stone),
## each chunk's cut stone under its paving and the depths' stone hanging lower (heights); the ledge under the west
## lip's balustrade (out of the drop); stones hanging in a gap (share, size, depth).
const LIP_TOOTH := Vector2(0.4, 1.2)
const LIP_OUT := Vector2(0.3, 1.0)
const LIP_SINK := Vector2(0.2, 0.42)
const LIP_GAP := Vector2(0.3, 0.9)
const LIP_STONE := 0.45
const LIP_HANG := Vector2(1.2, 2.6)
const LIP_LEDGE := 1.05
const LIP_FALLEN_SHARE := 0.45
const LIP_FALLEN := Vector2(0.35, 0.7)
const LIP_FALLEN_DEPTH := Vector2(0.3, 1.1)

## A whole column's head (the crypt's; E5: every arena's whole column that wants it) (ART_REVIEW C-2, spec 1.3: no askew cubes over it): the round capital (necking ring height,
## bell height, how far the bell flares and the abacus reaches as shares of the shaft's radius, abacus height).
const CAPITAL := Vector4(0.09, 0.3, 1.38, 1.55)
const ABACUS := 0.12
## C18: the impost block over the abacus of the second silhouette (its width as a share of the abacus', its height),
## the annulet round its shaft (where along the shaft, radius as a share of the shaft's, height), and where a broken
## column snaps (share of its height). The round pieces' sides (smoother than a plain shaft).
const IMPOST := Vector2(0.86, 0.42)
const ANNULET := Vector3(0.55, 1.12, 0.1)
const COLUMN_BROKEN := 0.66
const CAPITAL_SIDES := 18
## The blind window's tracery: mullion width, how deep the panel is set back, the dark of the panel, the broken share.
const WINDOW_MULLION := 0.14
const WINDOW_PANEL_SET := 0.25
const WINDOW_PANEL := Color(0.16, 0.16, 0.18)
## E5: a closed room's wall runs this far past each end of its edge (the corners meet).
const CLOSE_REACH := 0.9
## E5: a wall of a closed room (ArenaRoom.wall): how far its face stands behind the floor's edge, its thickness, the
## cornice on top (height, how far out); a wall cut low at the front (cut_wall): its top, thickness, how far its outer
## face drops into the dark, the dark fill seen on its cut, fallen blocks outside it (per meter).
const FACE_SET := 0.3
const FACE_THICK := 1.4
const WALL_CORNICE := Vector2(0.3, 0.18)
const CUT_WALL := Vector3(0.9, 0.8, 3.0)
const CUT_FILL := 0.55
const CUT_FALLEN := 0.25
## E5: a shaft of light from a hole in the vault (moon_shaft; the sanctuary's moon, the altar's crack, the trial's
## square opening): how far off the plumb it leans (toward the back of the room); no fall-off with distance.
const SHAFT_LEAN := Vector2(-2.0, -2.5)
## E5 spec 7.2: the breath of the next room in the mouth of a door used (breath): a card of light this big (width,
## height), this far beyond the mouth, its foot this far under the floor, its alpha and the brightest channel of its
## colour; the colour of each arena's air (its ambient, pushed to read at a glance) and, for some, a thread of another
## colour through it (the runes' amber).
const BREATH_SIZE := Vector2(4.0, 3.0)
const BREATH_BEYOND := 2.0
const BREATH_FOOT := -1.4
const BREATH_ALPHA := 0.35
const BREATH_PEAK := 0.6
const BREATH: Dictionary = {
	&"hall": Color(0.16, 0.5, 0.5), &"crypt": Color(0.6, 0.42, 0.28), &"rift": Color(0.4, 0.22, 0.6),
	&"garden": Color(0.46, 0.5, 0.56), &"bridge": Color(0.34, 0.44, 0.6), &"sanctuary": Color(0.56, 0.57, 0.6),
	&"runes": Color(0.1, 0.1, 0.14), &"trial": Color(0.52, 0.36, 0.78), &"altar": Color(0.6, 0.5, 0.38),
	&"chamber": Color(0.22, 0.2, 0.55),
}
const BREATH_THREAD: Dictionary = {&"runes": Color(1.0, 0.62, 0.25)}
const BREATH_SHADER := preload("res://assets/shaders/door_breath.gdshader")

## The kinds of edge (edge()): over the abyss, round a hole, the side of a door's mouth.
enum Edge { OUTER, HOLE, MOUTH }

var arena: Arena
var layout: RoomLayout
var kit: ArenaKit
var m: Masonry
var tomb: TombKit
## How many of the doors are used (the others are closed by a grille).
var exits_used := 0
## Lights with shadows placed (spec 0.5: at most 8 an arena).
var shadowed := 0
var _see: ShaderMaterial
var _rng := RandomNumberGenerator.new()
## The walkable floor's material (one for all its cells), once built.
var floor_mat: ShaderMaterial


static func make(look: StringName) -> ArenaRoom:
	match look:
		&"crypt":
			return CryptLook.new()
		&"rift":
			return RiftLook.new()
		&"garden":
			return GardenLook.new()
		&"sanctuary":
			return SanctuaryLook.new()
		&"bridge":
			return BridgeLook.new()
		&"runes":
			return RunesLook.new()
		&"trial":
			return TrialLook.new()
		&"altar":
			return AltarLook.new()
		&"hub":
			return HubLook.new()
	return ArenaRoom.new()


func build(a: Arena, l: RoomLayout, exit_count: int, seed_: int) -> void:
	arena = a
	layout = l
	exits_used = mini(exit_count, l.exits.size())
	_rng.seed = seed_
	kit = ArenaKit.new(self, seed_)
	m = kit.masonry
	tomb = TombKit.new(m)
	_see = stone().duplicate() as ShaderMaterial
	_see.set_shader_parameter(&"see_through", 1.0)
	_floor()
	_edges()
	_abyss()
	for o in layout.obstacles:
		piece(o)
	_doors()
	_light()
	dress()
	m.merge()
	_dress_air()
	_stylize()
	shadowed = _count_shadows()


## Each arena's own pieces and light (the environment artist's: CryptLook, RiftLook, GardenLook). Nothing here may
## block: what blocks is an ArenaObstacle in the layout.
func dress() -> void:
	pass


## The render layers of the floor's cells: an arena that lights its floor alone (a fill light whose light_cull_mask is
## only FLOOR_LAYER, never the walls) adds FLOOR_LAYER.
func floor_layers() -> int:
	return 1


## The floor's shader (null: the catacomb floor's; the runes' chamber its own, rune_floor.gdshader).
func floor_shader() -> Shader:
	return null


## The floor's shader parameters of the arena (catacomb_floor.gdshaderinc uniforms; spec 2.5, 3.5, 4.6).
func floor_look() -> Dictionary:
	return {}


## The arena's stone (times the kit's).
func stone_tint() -> Color:
	return Color.WHITE


## The arena's air (dressed when it is built, given back when it leaves; empty: the world's as it is). Keys: sky,
## fog (colours), fog_depth (begin, end), ambient (colour), ambient_gain (times the world's energy), moon (colour),
## moon_energy, moon_shadow.
func air() -> Dictionary:
	return {}


## The room's biome in the stylized look (room redesign, docs/art/room_redesign_lotA_spec.md 1.1; empty: the room as
## it is, the stylized look only reaching what passes through it anyway). Keys, all optional: stone, shadow,
## floor_stone, joint_cold, olive_share, slab_hue, edge_value (ArenaKit.paint_look), fire (ArenaKit.stylize_fires),
## air (the keys of air(), the stylized air; those it lacks are air()'s), off (lights hidden in the stylized look),
## backdrop ({mist, stone, edge}: backdrop() shown only in the stylized look), metal (true: ArenaKit.stylize_metal).
## Called once, after dress() (it may name the lights dress() made).
func style() -> Dictionary:
	return {}


## How far a slab only drawn (ArenaKit.framed_slab) keeps from the slabs that strike (RP-06, HazardDef.PLATES), in m:
## a frame or a grave slab next to one would read as one more trap (Sworn P1 review, S-1).
const PLATE_CLEAR := 0.6


## True when a drawn slab of this middle and size (m) keeps PLATE_CLEAR from every slab that strikes in this room.
func clear_of_plates(at: Vector2, size: Vector2) -> bool:
	if layout == null or layout.hazard == null or layout.hazard.kind != HazardDef.Kind.PLATES:
		return true
	var mine := Rect2(at - size * 0.5, size).grow(PLATE_CLEAR)
	for p: Rect2 in layout.hazard.plates:
		if mine.intersects(p):
			return false
	return true


var _style := {}


## The stylized look of the room (style()): its own pieces (dressed in dress() on kit.styled()), the backdrop, the
## painted stone, floor and kit, the fires, the metals; all through VisualProfile, so the classic look is as built.
func _stylize() -> void:
	var under := under_look()
	if not under.is_empty():
		_under_arcades(under)
	_style = style()
	if _style.is_empty():
		return
	if _style.has(&"backdrop"):
		var b: Dictionary = _style[&"backdrop"]
		var before := kit.root.get_child_count()
		backdrop(b[&"mist"], b[&"stone"], b[&"edge"])
		for i in range(before, kit.root.get_child_count()):
			var n := kit.root.get_child(i) as Node3D
			if n != null:
				ArenaKit.style_only(n)
	_break_rails()
	kit.stylize(_style, self, tomb)
	_style_ruins()
	if _style.has(&"air"):
		_dress_air()


## ENV-HB4: the far ruins' cards (abyss_ruins.gdshader) in the stylized look without the tall pale bands between their
## towers (seen from above, the towers ran from the top of the picture to the bottom and the sky showed between them,
## the card being cut out): the farthest card paints its own mist where no stone stands (its `backdrop` mode, with no
## lighter patches), that mist STY_RUIN_MIST of the way to its stone, fewer slender shafts and every gap between two
## towers bridged (an arch or a deck across it).
const STY_RUIN_SHAFTS := 0.1
const STY_RUIN_BRIDGED := 1.0
const STY_RUIN_MIST := 0.7
const STY_RUIN_NO_PATCH := Vector4(1e4, 1e4, 1.0, 1.0)


func _style_ruins() -> void:
	var cards: Array[ShaderMaterial] = []
	for n in find_children("*", "GeometryInstance3D", true, false):
		var sm := (n as GeometryInstance3D).material_override as ShaderMaterial
		if sm != null and sm.shader == RUIN_SHADER and not cards.has(sm):
			cards.append(sm)
	var far: ShaderMaterial = null
	for sm in cards:
		# the room may have varied them already: start from their stylized values
		var mist: Color = VisualProfile.styled(sm, &"shader_parameter/mist_color", sm.get_shader_parameter(&"mist_color"))
		var stone_c: Color = VisualProfile.styled(sm, &"shader_parameter/stone_color", sm.get_shader_parameter(&"stone_color"))
		VisualProfile.vary(sm, {&"shader_parameter/shafts": STY_RUIN_SHAFTS, &"shader_parameter/bridged": STY_RUIN_BRIDGED,
			&"shader_parameter/mist_color": mist.lerp(stone_c, STY_RUIN_MIST)})
		if far == null or _param(sm, &"haze", 0.35) > _param(far, &"haze", 0.35):
			far = sm
	if far != null and _param(far, &"backdrop", 0.0) < 0.5:
		VisualProfile.vary(far, {&"shader_parameter/backdrop": 1.0, &"shader_parameter/patch_a": STY_RUIN_NO_PATCH,
			&"shader_parameter/patch_b": STY_RUIN_NO_PATCH})


## A float uniform of a material, or its default when never set.
static func _param(sm: ShaderMaterial, name_: StringName, fallback: float) -> float:
	var v: Variant = sm.get_shader_parameter(name_)
	return fallback if v == null else float(v)


const RUIN_SHADER := preload("res://assets/shaders/abyss_ruins.gdshader")


## Room redesign lot C: the nodes added under the room since child `from` (the abyss's planes, lights and wisps), to
## turn in style() (collect them as they are built: merge() moves children afterwards).
func added_since(from: int) -> Array[Node]:
	var out: Array[Node] = []
	for i in range(from, get_child_count()):
		out.append(get_child(i))
	return out


## The abyss of the stylized look (lot C) over what kit.abyss and _abyss built (`nodes`): each mist plane's colour
## from the classic `was` to `mist` (keeping its own lift over it), the depths' lights `light`, the violet wisps gone.
func style_abyss(nodes: Array[Node], was: Color, mist: Color, light: Color) -> void:
	var base := maxf(was.r + was.g + was.b, 1e-4)
	for n in nodes:
		if n is CPUParticles3D:
			VisualProfile.vary(n, {&"visible": false})
		elif n is OmniLight3D and (n as OmniLight3D).light_cull_mask == ArenaKit.DEPTH_LAYER:
			VisualProfile.vary(n, {&"light_color": light})
		elif n is GeometryInstance3D and (n as GeometryInstance3D).material_override is ShaderMaterial:
			var sm := (n as GeometryInstance3D).material_override as ShaderMaterial
			var c: Variant = sm.get_shader_parameter(&"color")
			if c is Color:
				var lift := ((c as Color).r + (c as Color).g + (c as Color).b) / base
				VisualProfile.vary(sm, {&"shader_parameter/color": mist * lift})


## Spurs of rock rising out of the mist past a room's edge (the cycle of 2026-11-20, depth past the edge): each
## Vector4 is x, z, its top's height, its width; from `foot` up, leaning a little, a block askew on top, all in `mat`
## (the depths' unlit stone), seeded by `seed_` (never the room's random numbers).
const SPUR_TILT := 0.12
const SPUR_CAP := Vector3(0.6, 0.5, 0.5)


func depth_spurs(sm: Masonry, rocks: Array[Vector4], foot: float, mat: Material, seed_: int) -> void:
	var r := RandomNumberGenerator.new()
	r.seed = seed_
	for rock: Vector4 in rocks:
		var h := rock.z - foot
		var spur := sm.box(Vector3(rock.x, foot + h * 0.5, rock.y), Vector3(rock.w, h, rock.w * 0.8), r.randf() * TAU, mat, false)
		spur.rotate_object_local(Vector3.RIGHT, r.randf_range(-SPUR_TILT, SPUR_TILT))
		sm.box(Vector3(rock.x, rock.z, rock.y), rock.w * SPUR_CAP, r.randf() * TAU, mat, false)


## The depths' stone of the stylized look (lot C): every depth_stone material under the room (the cliffs, the arches
## and piers under the floor) takes `values` (its uniforms: stone_color, edge_color, mist_color, glow_color...).
func style_depths(values: Dictionary) -> void:
	var seen := {}
	var set_ := {}
	for k: StringName in values:
		set_[StringName("shader_parameter/" + k)] = values[k]
	for n in find_children("*", "GeometryInstance3D", true, false):
		var sm := (n as GeometryInstance3D).material_override as ShaderMaterial
		if sm != null and sm.shader == Masonry.DEPTH_SHADER and not seen.has(sm):
			seen[sm] = true
			VisualProfile.vary(sm, set_)


## An iron lantern hanging by a chain from `from`, its ring at `ring_y` (the garden's tree; room redesign lot C: the
## bridge's landing in the stylized look): cap, four posts, the warm glass of TombKit.WARM, a foot, its light (energy,
## reach; no shadow). styled: built only for the stylized look (on kit.styled()). lamp: another glass and light colour
## (RS-C1: the crypt's veiled figure holds a cold one).
func hanging_lantern(from: Vector3, ring_y: float, size: Vector3, light: Vector2, styled := false, lamp: TombKit.Lamp = null) -> OmniLight3D:
	if lamp == null:
		lamp = TombKit.WARM
	var at := Vector3(from.x, ring_y, from.z)
	if styled:
		kit.styled_build(func() -> void: kit.chain(from, at, 0.0, 0.7))
	else:
		kit.chain(from, at, 0.0, 0.7)
	var mason := kit.styled() if styled else m
	var mid := at - Vector3(0, size.y * 0.5 + 0.06, 0)
	var ir := tomb.iron()
	var glass := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = Vector3(size.x * 0.78, size.y * 0.72, size.z * 0.78)
	glass.mesh = bm
	glass.material_override = tomb.unlit(lamp.glass)
	glass.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	glass.position = mid
	mason.root.add_child(glass)
	for cx: float in [-1.0, 1.0]:
		for cz: float in [-1.0, 1.0]:
			mason.box(mid + Vector3(cx * size.x * 0.45, 0, cz * size.z * 0.45), Vector3(0.04, size.y * 0.8, 0.04), 0.0, ir, false)
	mason.box(mid + Vector3(0, -size.y * 0.42, 0), Vector3(size.x, 0.06, size.z), 0.0, ir, false)
	mason.point(mid + Vector3(0, size.y * 0.38, 0), size.x * 1.05, size.y * 0.35, 0.0, 0.0, ir)
	var l := OmniLight3D.new()
	l.position = mid
	l.light_color = lamp.light
	l.light_energy = light.x
	l.omni_range = light.y
	l.light_cull_mask = ~Arena.CROWD_LAYER
	mason.root.add_child(l)
	return l


## Room redesign lot D: every light of the room that is no fire (its red not over its blue by RoomMood.FIRE_FROM; the
## directional moon left out) lit diffuse in the stylized look (light_specular 0: paint.gdshaderinc's paint_diffuse, no
## drawn ring nor disc on the floor, decision P-4), and the ones in `no_shadow` without their shadow there. Call in
## style(), before the colours change.
func diffuse_lights(no_shadow: Array = []) -> void:
	for n in find_children("*", "Light3D", true, false):
		var l := n as Light3D
		if l is DirectionalLight3D or l.light_color.r - l.light_color.b >= RoomMood.FIRE_FROM:
			continue
		var values := {&"light_specular": 0.0}
		if no_shadow.has(l):
			values[&"shadow_enabled"] = false
		VisualProfile.vary(l, values)


## Lot D: the stylized look of a backdrop() built by the room (its nodes, ArenaRoom.added_since): the ruin cards' mist,
## stone and edge, and the bank of mist (twice the mist, as backdrop() makes it).
func style_backdrop(nodes: Array[Node], mist: Color, stone_c: Color, edge_c: Color) -> void:
	for n in nodes:
		var g := n as GeometryInstance3D
		if g == null or not g.material_override is ShaderMaterial:
			continue
		var sm := g.material_override as ShaderMaterial
		if sm.get_shader_parameter(&"stone_color") != null:
			VisualProfile.vary(sm, {&"shader_parameter/mist_color": mist, &"shader_parameter/stone_color": stone_c,
				&"shader_parameter/edge_color": edge_c})
		elif sm.get_shader_parameter(&"color") != null:
			VisualProfile.vary(sm, {&"shader_parameter/color": mist * 2.0})


## The faded banners (the altar's, lot D the trial's): every cloth and lion among `nodes` (a banner's meshes, ArenaKit
## .banner) on a twin of its material `fade` of its light, a little toward grey; one twin a material for the room.
func fade_banners(nodes: Array[Node], fade: float) -> void:
	for n in nodes:
		var mi := n as MeshInstance3D
		if mi == null or mi.material_override == null:
			continue
		var was := mi.material_override
		if not _faded.has(was):
			var f := was.duplicate() as Material
			if f is StandardMaterial3D:
				var sf := f as StandardMaterial3D
				sf.albedo_color = sf.albedo_color.darkened(1.0 - fade).lerp(BANNER_FADE_GREY, 0.3)
				if sf.emission_enabled:
					sf.emission_energy_multiplier *= fade
			elif f is ShaderMaterial:
				var sm := f as ShaderMaterial
				var g: Variant = sm.get_shader_parameter(&"gold")
				var gold: Color = g if g is Color else BANNER_LION_GOLD
				sm.set_shader_parameter(&"gold", gold.darkened(1.0 - fade))
				sm.set_shader_parameter(&"glow", BANNER_LION_GLOW * fade)
			_faded[was] = f
		mi.material_override = _faded[was]


## The grey a faded banner's cloth goes toward, the lion's gold when its material does not say (banner_lion.gdshader's
## default) and its glow.
const BANNER_FADE_GREY := Color(0.3, 0.28, 0.27)
const BANNER_LION_GOLD := Color(0.65, 0.47, 0.18)
const BANNER_LION_GLOW := 0.35
var _faded := {}


## Moss and ivy hanging on a wall (the sanctuary's S5, lot D the altar's A2): a card of `card` m on the wall's face for
## each top middle in `tops` (x, y, z: a hair in front of the face), facing along `yaw`, in `moss` (floor_decal kind 2),
## on the stylized Masonry `sm`.
func wall_moss(sm: Masonry, tops: Array[Vector3], card: Vector2, moss: Color, yaw := 0.0) -> void:
	var mat := ShaderMaterial.new()
	mat.shader = CatacombHall.DECAL_SHADER
	mat.set_shader_parameter(&"kind", 2)
	mat.set_shader_parameter(&"rug_size", card)
	mat.set_shader_parameter(&"moss", moss)
	for t in tops:
		var mi := MeshInstance3D.new()
		var q := QuadMesh.new()
		q.size = card
		mi.mesh = q
		mi.material_override = mat
		mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		mi.transform = Transform3D(Basis(Vector3.UP, yaw), t - Vector3(0, card.y * 0.5, 0))
		sm.root.add_child(mi)


## Lot D: a stone shelf on a wall's foot, off the floor (between the floor's edge at a to b, out along `out`, and the
## wall's face FACE_SET behind it), its top `height` up, for the stylized look's offerings (on `sm`). Returns where
## along it things stand: the shelf's middle line on its top (from, to).
func wall_ledge(sm: Masonry, a: Vector2, b: Vector2, out: Vector2, height: float, mat: Material) -> Array[Vector3]:
	var mid := (a + b) * 0.5 + out * (LEDGE_GAP + FACE_SET) * 0.5
	var along := (b - a).normalized()
	var deep := FACE_SET - LEDGE_GAP
	sm.box(Vector3(mid.x, height - LEDGE_SLAB * 0.5, mid.y), Vector3(a.distance_to(b), LEDGE_SLAB, deep), atan2(-along.y, along.x), mat, false)
	# corbels under it
	for t: float in [0.15, 0.85]:
		var c := a.lerp(b, t) + out * (LEDGE_GAP + FACE_SET) * 0.5
		sm.box(Vector3(c.x, height - LEDGE_SLAB - LEDGE_CORBEL * 0.5, c.y), Vector3(0.18, LEDGE_CORBEL, deep * 0.8),
			atan2(-along.y, along.x), mat, false)
	var line := out * (LEDGE_GAP + FACE_SET) * 0.5
	return [Vector3(a.x + line.x, height, a.y + line.y), Vector3(b.x + line.x, height, b.y + line.y)]


## The shelf (wall_ledge): how far it stays off the floor's edge, its slab's and its corbels' height.
const LEDGE_GAP := 0.04
const LEDGE_SLAB := 0.1
const LEDGE_CORBEL := 0.22


## The cliffs' stone (depth_stone.gdshader uniforms: stone_color, edge_color...), if not the hall's teal.
func cliff_look() -> Dictionary:
	return {}


## The colour of the abyss's mist under the arena (the cliffs fade into it).
func mist() -> Color:
	return ArenaKit.MIST


func stone(base_y := 0.0) -> ShaderMaterial:
	return m.stone(base_y, stone_tint())


func ashlar(base_y := 0.0) -> ShaderMaterial:
	return m.ashlar(base_y, stone_tint())


## The same stone opening round the paladin behind it (see_through), one twin per material.
func see(mat: ShaderMaterial) -> ShaderMaterial:
	if not _see_twins.has(mat):
		var t := mat.duplicate() as ShaderMaterial
		t.set_shader_parameter(&"see_through", 1.0)
		_see_twins[mat] = t
	return _see_twins[mat]


var _see_twins := {}


# ---------- the floor ----------

## The floor's top, in triangles: points along every edge and on a grid inside, joined (Delaunay), the triangles
## whose middle is on the floor kept, one mesh per FLOOR_CELL square.
func _floor() -> void:
	var f := arena.shape()
	var pts := PackedVector2Array()
	var e := f.edges()
	for i in range(0, e.size(), 2):
		var n := maxi(1, ceili(e[i].distance_to(e[i + 1]) / EDGE_STEP))
		for k in n:
			pts.append(e[i].lerp(e[i + 1], float(k) / n))
	var b := f.bounds()
	var y := b.position.y + FILL_STEP * 0.5
	while y < b.end.y:
		var x := b.position.x + FILL_STEP * 0.5
		while x < b.end.x:
			if f.contains(Vector2(x, y), EDGE_STEP):
				pts.append(Vector2(x, y))
			x += FILL_STEP
		y += FILL_STEP
	var tris := Geometry2D.triangulate_delaunay(pts)
	var to_edge := PackedFloat32Array()
	to_edge.resize(pts.size())
	for i in pts.size():
		to_edge[i] = clampf(f.edge_distance(pts[i]) / FLOOR_EDGE_NORM, 0.0, 1.0)
	var cells := {}
	for i in range(0, tris.size(), 3):
		var i0 := tris[i]
		var i1 := tris[i + 1]
		var i2 := tris[i + 2]
		var mid := (pts[i0] + pts[i1] + pts[i2]) / 3.0
		if not f.covers(mid):
			continue
		# wound so the face looks up (Godot's front faces turn clockwise as seen; seen from above, x right and z down,
		# that is a positive cross on the floor plane)
		if (pts[i1] - pts[i0]).cross(pts[i2] - pts[i0]) < 0.0:
			var t := i1
			i1 = i2
			i2 = t
		var key := Vector2i(floori(mid.x / FLOOR_CELL), floori(mid.y / FLOOR_CELL))
		if not cells.has(key):
			var st := SurfaceTool.new()
			st.begin(Mesh.PRIMITIVE_TRIANGLES)
			st.set_normal(Vector3.UP)
			cells[key] = st
		var s: SurfaceTool = cells[key]
		for k in [i0, i1, i2]:
			var p := pts[k]
			s.set_color(Color(to_edge[k], 0.0, 0.0))
			s.set_uv(p)
			s.add_vertex(Vector3(p.x, 0.0, p.y))
	var mat := kit.floor_material(0.0, Vector2.ZERO, minf(b.size.x, b.size.y) * 0.3, floor_shader())
	var look := floor_look()
	for k in look:
		mat.set_shader_parameter(k, look[k])
	floor_mat = mat
	for key in cells:
		var mi := MeshInstance3D.new()
		mi.mesh = (cells[key] as SurfaceTool).commit()
		mi.material_override = mat
		mi.layers = floor_layers()
		add_child(mi)


# ---------- the edges ----------

## Every edge of the floor, by its kind (edge).
func _edges() -> void:
	var f := arena.shape()
	var e := f.edges()
	var faces := SurfaceTool.new()
	faces.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in range(0, e.size(), 2):
		var a := e[i]
		var b := e[i + 1]
		var out := -f.edge_inward(i / 2)
		var probe := (a + b) * 0.5 + out * 0.3
		var kind := Edge.OUTER
		for h in layout.floor.holes:
			if Geometry2D.is_point_in_polygon(probe, h):
				kind = Edge.HOLE
		for k in exits_used:
			if layout.exits[k].mouth.grow(0.05).has_point((a + b) * 0.5):
				kind = Edge.MOUTH
		edge(a, b, out, kind, faces)
		_runs.append([a, b, out, kind])
	faces.generate_normals()
	var mi := MeshInstance3D.new()
	mi.mesh = faces.commit()
	var deep := m.depth_stone(mist())
	var look := cliff_look()
	if not look.is_empty():
		deep = deep.duplicate() as ShaderMaterial
		for k in look:
			deep.set_shader_parameter(k, look[k])
	mi.material_override = deep
	mi.layers = 1 | ArenaKit.DEPTH_LAYER
	add_child(mi)


## One edge of the floor from a to b, the abyss (or the outside) toward `out`. By default the broken edge over the
## abyss; the side of a door's mouth a plain cut (its cheek is the door's). faces: the cliffs' one mesh.
func edge(a: Vector2, b: Vector2, out: Vector2, kind: Edge, faces: SurfaceTool) -> void:
	if kind == Edge.MOUTH:
		cliff(a, b, out, faces, EXIT_STEPS * EXIT_RISE + 0.6)
		return
	broken_edge(a, b, out, faces)


## A plain wall of stone under the edge a to b, from just under the floor down `drop` meters, facing `out`.
func cliff(a: Vector2, b: Vector2, out: Vector2, faces: SurfaceTool, drop := DEPTH) -> void:
	var q: Array[Vector3] = [Vector3(a.x, -LIP.x, a.y), Vector3(b.x, -LIP.x, b.y), Vector3(b.x, -drop, b.y), Vector3(a.x, -drop, a.y)]
	# facing out of the floor (clockwise as seen from outside)
	if (b - a).cross(out) < 0.0:
		q = [q[1], q[0], q[3], q[2]]
	for k: int in [0, 1, 2, 0, 2, 3]:
		faces.add_vertex(q[k])
	var o := out * LIP.y
	m.box(Vector3((a.x + b.x) * 0.5 + o.x * 0.5, -LIP.x * 0.5, (a.y + b.y) * 0.5 + o.y * 0.5),
		Vector3(a.distance_to(b) + LIP.y, LIP.x, LIP.y * 2.0), atan2(-(b - a).y, (b - a).x), stone())


## The broken edge of a floor over the abyss (spec 1.3, the hall's cliff for any polygon): the wall of stone down into
## the abyss, along it teeth of stone standing out or missing every TOOTH_STEP, the brink's slabs sunk a little in a
## narrow band outside the edge, loose shards falling below. Everything outside the walkable floor.
func broken_edge(a: Vector2, b: Vector2, out: Vector2, faces: SurfaceTool) -> void:
	cliff(a, b, out, faces)
	var length := a.distance_to(b)
	var along := (b - a) / maxf(length, 0.001)
	var yaw := atan2(-along.y, along.x)
	var r := RandomNumberGenerator.new()
	r.seed = hash(Vector2i((a + b) * 10.0))
	var s := r.randf_range(0.0, TOOTH_STEP.x)
	var mat := stone()
	while s < length - 0.2:
		var l := minf(r.randf_range(TOOTH_LENGTH.x, TOOTH_LENGTH.y), length - s)
		var c := a + along * (s + l * 0.5)
		if r.randf() > TOOTH_GAP:
			var o := r.randf_range(TOOTH_OUT.x, TOOTH_OUT.y)
			var tall := r.randf_range(TOOTH_TALL.x, TOOTH_TALL.y)
			var top := -r.randf_range(TOOTH_DROP.x, TOOTH_DROP.y)
			var p := c + out * (o * 0.5 + LIP.y * 0.5)
			m.box(Vector3(p.x, top - tall * 0.5, p.y), Vector3(l * 0.92, tall, o + LIP.y), yaw, mat)
		# a sunk slab of the brink
		if r.randf() < 0.5:
			var sag := r.randf_range(SAG.x, SAG.y)
			var p2 := c + out * SAG_BAND * 0.5
			var slab := m.box(Vector3(p2.x, -sag - 0.06, p2.y), Vector3(l * 0.8, 0.12, SAG_BAND), yaw, mat)
			slab.rotate_object_local(Vector3.RIGHT, r.randf_range(-0.12, 0.05))
		s += l + r.randf_range(0.0, TOOTH_STEP.y - TOOTH_LENGTH.y)
	# shards falling just below
	for k in floori(length * SHARDS):
		var t := r.randf()
		var p3 := a.lerp(b, t) + out * r.randf_range(0.5, 2.0)
		var size := r.randf_range(SHARD.x, SHARD.y)
		var sh := m.box(Vector3(p3.x, -r.randf_range(0.8, 3.0), p3.y), Vector3(size, size * 0.8, size * 0.9), r.randf() * TAU, mat)
		sh.rotate_object_local(Vector3.RIGHT, r.randf_range(-0.8, 0.8))


## A balustrade standing BALUSTRADE_OUT outside the edge a to b; broken: in runs with gaps and a fallen stump. On an
## edge the camera looks across (its outside toward the camera) it opens round the paladin behind it (see_through).
func balustrade_edge(a: Vector2, b: Vector2, out: Vector2, broken := false, mat: Material = null) -> void:
	if mat == null:
		var yaw := deg_to_rad(Feel.live().cam_yaw)
		mat = see(stone()) if out.dot(Vector2(sin(yaw), cos(yaw))) > 0.2 else stone()
	var length := a.distance_to(b)
	var along := (b - a) / maxf(length, 0.001)
	var off := out * BALUSTRADE_OUT
	if not broken:
		m.balustrade(Vector3(a.x + off.x, 0.0, a.y + off.y), Vector3(b.x + off.x, 0.0, b.y + off.y), true, mat)
		_rails.append([a + off, b + off, out])
		return
	var r := RandomNumberGenerator.new()
	r.seed = hash(Vector2i((a - b) * 10.0))
	# a broken one (a lip's) keeps clear of its ends: past a bend of the lip (where a bridge's deck meets it) its
	# offset run went on over the walkable floor (art pack 2026-11-17, tools/fit_probe.gd)
	var s := BALUSTRADE_END
	var stop := length - BALUSTRADE_END
	while s < stop - 0.5:
		var run := minf(r.randf_range(BALUSTRADE_RUN.x, BALUSTRADE_RUN.y), stop - s)
		var p0 := a + along * s + off
		var p1 := a + along * (s + run) + off
		m.balustrade(Vector3(p0.x, 0.0, p0.y), Vector3(p1.x, 0.0, p1.y), true, mat)
		_rails.append([p0, p1, out])
		s += run
		var gap := minf(r.randf_range(BALUSTRADE_GAP.x, BALUSTRADE_GAP.y), stop - s)
		if gap > 0.6:
			# the stump of a broken post in the gap, and the curb running on under it
			var g := a + along * (s + gap * 0.5) + off
			m.box(Vector3(g.x, Masonry.CURB * 0.5, g.y), Vector3(gap, Masonry.CURB, Masonry.RAIL.y + 0.1), atan2(-along.y, along.x), mat)
			var stub := m.box(Vector3(g.x, 0.3, g.y), Vector3(Masonry.POST.x * 0.8, 0.6, Masonry.POST.z * 0.8), r.randf() * 0.4, mat)
			stub.rotate_object_local(Vector3.BACK, r.randf_range(-0.15, 0.15))
		s += gap


## The thread of old gold inlaid in the floor FILET.y in from the bare edge a to b (the limit drawn on the floor).
func filet(a: Vector2, b: Vector2, out: Vector2) -> void:
	var c := (a + b) * 0.5 - out * FILET.y
	var d := b - a
	tomb.bar(Vector3(c.x, 0.004, c.y), Vector3(d.length(), 0.008, FILET.x), atan2(-d.y, d.x), tomb.gold())


## The abyss's mist far below, and a violet light under each hole and along the outer edge.
func _abyss() -> void:
	var b := arena.shape().bounds()
	kit.abyss(b.size * 0.5 + Vector2(6, 6), DEPTH, false, mist())
	var spots: Array[Vector2] = []
	for h in arena.shape().holes:
		var c := Vector2.ZERO
		for v in h:
			c += v
		spots.append(c / maxf(1.0, h.size()))
	for s: Vector2 in [Vector2(b.position.x - 6.0, b.get_center().y), Vector2(b.end.x + 6.0, b.get_center().y)]:
		spots.append(s)
	for s in spots:
		var l := OmniLight3D.new()
		l.position = Vector3(s.x, ABYSS_LIGHT_Y, s.y)
		l.light_color = CatacombHall.ABYSS_LIGHT
		l.light_energy = ABYSS_LIGHT_ENERGY
		l.omni_range = 18.0
		l.light_cull_mask = ArenaKit.DEPTH_LAYER
		add_child(l)


# ---------- what stands on it ----------

## Draws one obstacle on its own footprint, by its piece.
func piece(o: ArenaObstacle) -> void:
	var at := Vector3(o.center.x, 0.0, o.center.y)
	var mat: Material = _see if o.see_through else null
	match o.piece:
		&"column":
			tomb.column(o.center, o.radius, o.height, see(stone()) if o.see_through else stone(), o.height < WHOLE_COLUMN)
		&"trunk":
			m.block(at, Vector3(o.radius * 2.4, 0.3, o.radius * 2.4), 0.0, mat)
			m.shaft(at + Vector3(0, 0.3, 0), o.radius, o.height - 0.3, mat)
		&"sarcophagus":
			sarcophagus(o)
		&"statue":
			kit.statue(o.center, o.yaw, o.height, 0.0, ArenaKit.STATUE_VALUE, false)
		&"brazier":
			kit.brazier(o.center, 0.0, false)
		&"bench", &"bench_broken":
			var long_x := o.half.x >= o.half.y
			tomb.bench(o.center, o.half if long_x else Vector2(o.half.y, o.half.x), -o.yaw + (0.0 if long_x else PI * 0.5),
				stone(), o.piece == &"bench_broken")
		&"column_base":
			# the stump of a fallen column: its plinth, base and a short broken shaft
			tomb.column(o.center, o.radius, maxf(o.height, TombKit.COLUMN_BASE + 0.4), stone(), true)
		&"drums":
			drums(o)
		&"quiet":
			pass
		&"block":
			if o.height <= 1.0 and o.shape == ArenaObstacle.Shape.BOX:
				var ax := Vector2(cos(o.yaw), sin(o.yaw)) * (o.half.x - o.half.y)
				tomb.low_wall(o.center - ax, o.center + ax, o.half.y * 2.0, o.height, stone())
			elif o.shape == ArenaObstacle.Shape.BOX:
				ruin_wall(o)
			else:
				m.shaft(at, o.radius, o.height, mat)
		_:
			if o.shape == ArenaObstacle.Shape.CIRCLE:
				m.shaft(at, o.radius, o.height, mat)
			else:
				m.block(at, Vector3(o.half.x * 2.0, o.height, o.half.y * 2.0), -o.yaw, mat)


## A sarcophagus on its footprint (spec 1.2): a plinth the footprint's size, the chest on it with its lid, the sword
## in stone on the lid (no gold, no lion); a long one is the great tomb on its two steps (TombKit.tomb).
func sarcophagus(o: ArenaObstacle) -> Vector3:
	var long_x := o.half.x >= o.half.y
	var yaw := -o.yaw + (0.0 if long_x else PI * 0.5)
	var half := o.half if long_x else Vector2(o.half.y, o.half.x)
	var st := stone()
	var light := m.stone(0.0, stone_tint() * SARC_LID_LIGHT)
	var hollow := m.stone(0.0, stone_tint() * 0.6)
	if o.see_through:
		st = see(st)
		light = see(light)
		hollow = see(hollow)
	if half.x * 2.0 >= TOMB_FROM:
		return tomb.tomb(o.center, half, yaw, o.height, st, light, hollow)
	var foot := Vector3(o.center.x, 0.0, o.center.y)
	m.block(foot, Vector3(half.x * 2.0, SARC_PLINTH, half.y * 2.0), yaw, st, false)
	var body := Vector3(half.x * 2.0 - 0.2, half.y * 2.0 - 0.2, o.height - SARC_PLINTH - SARC_LID.x)
	return tomb.sarcophagus(foot + Vector3(0, SARC_PLINTH, 0), yaw, body, m.stone(0.0, stone_tint() * SARC_TINT), light, hollow,
		SARC_SWORD, light, SARC_LID)


## A ruined wall on a box footprint: cut stone up to its top, the top broken in steps, opening round the paladin
## behind it if it is tall (see_through).
func ruin_wall(o: ArenaObstacle) -> void:
	var mat := see(ashlar()) if o.see_through else ashlar()
	var long_x := o.half.x >= o.half.y
	var yaw := -o.yaw + (0.0 if long_x else PI * 0.5)
	var half := o.half if long_x else Vector2(o.half.y, o.half.x)
	var basis := Basis(Vector3.UP, yaw)
	var foot := Vector3(o.center.x, 0.0, o.center.y)
	var low := o.height * 0.7
	m.block(foot, Vector3(half.x * 2.0, low, half.y * 2.0), yaw, mat, false)
	var r := RandomNumberGenerator.new()
	r.seed = hash(Vector2i(o.center * 10.0))
	var x := -half.x
	while x < half.x - 0.1:
		var w := minf(r.randf_range(0.5, 1.1), half.x - x)
		var h := o.height - low - r.randf_range(RUIN_STEP.x, RUIN_STEP.y) * (0.0 if r.randf() < 0.3 else 1.0)
		if h > 0.1:
			m.block(foot + basis * Vector3(x + w * 0.5, low, 0), Vector3(w - 0.04, h, half.y * 2.0 - 0.06), yaw, mat)
		x += w


## A group of candles standing on top of something at `at` (never loose on the floor): count candles, tallest in the
## middle; lit (a flame, a halo) or burnt out; light: a warm light over them (shadow: it casts shadows).
func candles(at: Vector3, count: int, lit := true, light := false, shadow := false, energy := CANDLE_LIGHT) -> OmniLight3D:
	var n := clampi(count, 1, CANDLE_MAX)
	var turn := _rng.randf() * TAU
	for i in n:
		var t := 1.0 if i == 0 else _rng.randf_range(0.0, 0.7)
		var r := lerpf(CANDLE_RADIUS.x, CANDLE_RADIUS.y, t)
		var p := at
		if i > 0:
			var a := turn + TAU * float(i) / float(maxi(1, n - 1)) + _rng.randf_range(-0.3, 0.3)
			p += Vector3(cos(a), 0, sin(a)) * (CANDLE_RADIUS.y + r + _rng.randf_range(0.03, 0.12))
		var h := lerpf(CANDLE_HEIGHT.x, CANDLE_HEIGHT.y, t)
		if lit:
			m.candle(p, h, r)
		else:
			# a burnt-out stub: the wax and its pool, a dark wick, no flame
			m.shaft(p, r, h * 0.7, _wax_out())
			m.box(p + Vector3(0, h * 0.7 + 0.02, 0), Vector3(0.012, 0.04, 0.012), 0.0, tomb.iron(), false)
	if not lit:
		return null
	var glow := MeshInstance3D.new()
	glow.mesh = Fx.quad(CANDLE_HALO, Color(0.8, 0.45, 0.18) * CANDLE_HALO_ALPHA)
	glow.position = at + Vector3(0, CANDLE_HEIGHT.y * 0.9, 0)
	glow.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(glow)
	if not light:
		return null
	var l := OmniLight3D.new()
	l.position = at + Vector3(0, 0.7, 0)
	l.light_color = CANDLE_COLOR
	l.light_energy = energy
	l.omni_range = CANDLE_RANGE
	l.shadow_enabled = shadow
	l.light_cull_mask = ~Arena.CROWD_LAYER
	add_child(l)
	return l


## Candles in a row from a to b (on a ledge, a step, the rim of a base): n of them, uneven heights; lit or burnt out.
func candle_line(a: Vector3, b: Vector3, n: int, lit := true) -> void:
	for i in n:
		var t := (i + 0.5) / n
		var k := _rng.randf()
		var p := a.lerp(b, t) + Vector3(_rng.randf_range(-0.03, 0.03), 0.0, _rng.randf_range(-0.03, 0.03))
		var h := lerpf(CANDLE_HEIGHT.x, CANDLE_HEIGHT.y, k)
		var r := lerpf(CANDLE_RADIUS.x, CANDLE_RADIUS.y, k * 0.7)
		if lit:
			m.candle(p, h, r)
		else:
			m.shaft(p, r, h * 0.7, _wax_out())


## A warm light over candles at `at` (shadow: it casts shadows, counted against the arena's 8).
func warm_light(at: Vector3, energy := CANDLE_LIGHT, shadow := false, reach := CANDLE_RANGE) -> OmniLight3D:
	var l := OmniLight3D.new()
	l.position = at
	l.light_color = CANDLE_COLOR
	l.light_energy = energy
	l.omni_range = reach
	l.shadow_enabled = shadow
	l.light_cull_mask = ~Arena.CROWD_LAYER
	add_child(l)
	return l


var _wax_dark: StandardMaterial3D


func _wax_out() -> StandardMaterial3D:
	if _wax_dark == null:
		_wax_dark = StandardMaterial3D.new()
		_wax_dark.albedo_color = Masonry.WAX * 0.55
		_wax_dark.roughness = 0.7
	return _wax_dark


# ---------- bridges and lips (out of the Salão das Fendas, RiftLook; E5: every arena's) ----------

## A lip of the rift or of a hole (spec 1.3, F-3): the wall going down into the dark (the cliffs' one mesh), and along
## it chunks of the brink's slabs standing out past the drop at uneven lengths (paved with the floor's slabs, sunk a
## little, cut stone under the paving, the depths' stone hanging lower), stretches with none between them (a stone
## missing; sometimes one fallen in the gap), loose shards below. ledge: a shelf this far out under a balustrade, the
## chunks past it. Nothing on the walkable floor.
func broken_lip(a: Vector2, b: Vector2, out: Vector2, faces: SurfaceTool, ledge := 0.0) -> void:
	lip_wall(a, b, out, faces)
	var length := a.distance_to(b)
	var along := (b - a) / maxf(length, 0.001)
	var r := RandomNumberGenerator.new()
	r.seed = hash(Vector2i((a + b) * 10.0))
	var cut := stone()
	if ledge > 0.0:
		chunk(PackedVector2Array([a, b, b + out * ledge, a + out * ledge]), -LIP_SINK.x, LIP_HANG.x)
	var s := r.randf_range(0.0, LIP_GAP.x)
	while s < length - LIP_TOOTH.x * 0.5:
		var l := minf(r.randf_range(LIP_TOOTH.x, LIP_TOOTH.y), length - s)
		var p0 := a + along * s + out * ledge
		var p1 := a + along * (s + l) + out * ledge
		var o0 := r.randf_range(LIP_OUT.x, LIP_OUT.y)
		var o1 := r.randf_range(LIP_OUT.x, LIP_OUT.y)
		var tip := (p0 + p1) * 0.5 + out * maxf(o0, o1) * r.randf_range(0.7, 1.15) + along * l * r.randf_range(-0.15, 0.15)
		chunk(PackedVector2Array([p0, p1, p1 + out * o1, tip, p0 + out * o0]), -r.randf_range(LIP_SINK.x, LIP_SINK.y),
			r.randf_range(LIP_HANG.x, LIP_HANG.y))
		s += l
		var gap := r.randf_range(LIP_GAP.x, LIP_GAP.y)
		if r.randf() < LIP_FALLEN_SHARE and s + gap < length:
			var g := a + along * (s + gap * 0.5) + out * (ledge + r.randf_range(0.2, 0.6))
			var size := r.randf_range(LIP_FALLEN.x, LIP_FALLEN.y)
			var fallen := m.box(Vector3(g.x, -r.randf_range(LIP_FALLEN_DEPTH.x, LIP_FALLEN_DEPTH.y), g.y), Vector3(size, size * 0.6, size * 0.8), r.randf() * TAU, cut)
			fallen.rotate_object_local(Vector3.RIGHT, r.randf_range(-0.6, 0.6))
		s += gap
	# shards falling just below
	for k in floori(length * SHARDS):
		var p3 := a.lerp(b, r.randf()) + out * (ledge + r.randf_range(0.6, 2.0))
		var size := r.randf_range(SHARD.x, SHARD.y)
		var sh := m.box(Vector3(p3.x, -r.randf_range(0.8, 2.5), p3.y), Vector3(size, size * 0.8, size * 0.9), r.randf() * TAU, cut)
		sh.rotate_object_local(Vector3.RIGHT, r.randf_range(-0.8, 0.8))


## The plain wall under a lip from the floor down into the abyss (the cliffs' mesh, the depths' dark stone; no
## straight kerb along it: the chunks are the brink).
func lip_wall(a: Vector2, b: Vector2, out: Vector2, faces: SurfaceTool) -> void:
	var q: Array[Vector3] = [Vector3(a.x, 0.0, a.y), Vector3(b.x, 0.0, b.y), Vector3(b.x, -DEPTH, b.y), Vector3(a.x, -DEPTH, a.y)]
	# facing out of the floor (clockwise as seen from outside)
	if (b - a).cross(out) < 0.0:
		q = [q[1], q[0], q[3], q[2]]
	for k: int in [0, 1, 2, 0, 2, 3]:
		faces.add_vertex(q[k])


## One chunk of the brink on the footprint poly: the floor's paving on top at `top`, cut stone under it, the depths'
## dark stone hanging `hang` meters lower, a little inset. On the depths' layer too (the violet from below).
func chunk(poly: PackedVector2Array, top: float, hang: float) -> void:
	m.layers = 1 | ArenaKit.DEPTH_LAYER
	m.prism(poly, top - 0.04, top, paving())
	m.prism(poly, top - LIP_STONE, top - 0.04, stone())
	var c := Vector2.ZERO
	for p in poly:
		c += p
	c /= poly.size()
	var inset := PackedVector2Array()
	for p in poly:
		inset.append(p + (c - p).limit_length(0.06))
	m.prism(inset, top - LIP_STONE - hang, top - LIP_STONE, deep())
	m.layers = 1



var _deep_mat: ShaderMaterial
var _paving_mat: ShaderMaterial


## The depths' dark stone of this hall (the cliffs' look): arches, piers, the lips' hanging stone, joints.
func deep() -> ShaderMaterial:
	if _deep_mat == null:
		_deep_mat = m.depth_stone(mist()).duplicate() as ShaderMaterial
		var look := cliff_look()
		for k in look:
			_deep_mat.set_shader_parameter(k, look[k])
	return _deep_mat


## The floor's slabs (the same look as the floor) for the chunks of the brink.
func paving() -> ShaderMaterial:
	if _paving_mat == null:
		var b := arena.shape().bounds()
		_paving_mat = kit.floor_material(0.0, Vector2.ZERO, minf(b.size.x, b.size.y) * 0.3)
		var look := floor_look()
		for k in look:
			_paving_mat.set_shader_parameter(k, look[k])
	return _paving_mat



## A bridge of stone over a gap (the Salão das Fendas' of C12, F-2; E5: every arena's), its deck the floor's rect `r`
## spanning along x (the walkable width along z): its own paving over the floor (slabs along the span, kerbs, dark
## seams at the heads), the deck's cornice of cut stone under it, an open parapet outside the walkable width on each
## side, a pillar at each of the four heads on the abutment it springs from (two with a lantern, diagonally: north-west
## and south-east; two with candles), `arches` arches of voussoirs under it (their crown ARCH_CROWN under the deck), their
## haunches and the piers down into the mist in the depths' dark stone. shadow_nw, shadow_se: those lanterns cast
## shadows. open (from, to along x; zero: none): a landing across the deck there, the parapets leave it open.
func bridge(r: Rect2, shadow_nw: bool, shadow_se: bool, arches := 1, open: Vector2 = Vector2.ZERO) -> void:
	var mat := ashlar()
	var deep := deep()
	var cx := r.get_center().x
	var cz := r.get_center().y
	var span := r.size.x
	m.box(Vector3(cx, -DECK * 0.5 - 0.02, cz), Vector3(span + 1.0, DECK, r.size.y + DECK_OUT * 2.0), 0.0, mat, false)
	m.layers = 1 | ArenaKit.DEPTH_LAYER
	# each arch: its crown ARCH_CROWN under the deck, springing from the walls (or the piers), and the fill over its
	# haunches
	var n := maxi(1, arches)
	var bay := span / n
	var rr := bay * ARCH_RADIUS
	var hx := rr - bay * 0.5
	var rise := sqrt((rr + ARCH_RING) * (rr + ARCH_RING) - hx * hx)
	var spring := -ARCH_CROWN - rise
	for j in n:
		var ax := r.position.x + bay * (j + 0.5)
		m.voussoir_arch(Vector3(ax, spring, cz), Vector2(0, 1), bay, 0.0, ARCH_RING, r.size.y, deep, ARCH_RADIUS)
		var slices := 8
		for k in slices:
			var x0 := -bay * 0.5 + bay * k / slices
			var x1 := x0 + bay / slices
			var xm := absf((x0 + x1) * 0.5)
			# the arch's outer curve over this slice (the arc whose centre is on the other side)
			var y := spring + sqrt(maxf(0.0, (rr + ARCH_RING) * (rr + ARCH_RING) - (xm + hx) * (xm + hx)))
			if y < -DECK - 0.05:
				m.box(Vector3(ax + (x0 + x1) * 0.5, (y - DECK) * 0.5, cz), Vector3(x1 - x0 + 0.02, -DECK - y, r.size.y * 0.92), 0.0, deep, false)
	for j in n + 1:
		var px := r.position.x + bay * j + (-0.6 if j == 0 else (0.6 if j == n else 0.0))
		m.box(Vector3(px, (spring - DEPTH) * 0.5, cz), Vector3(1.6, DEPTH + spring, r.size.y * 0.9), 0.0, deep, false)
	m.layers = 1
	deck(r)
	for z: float in [r.position.y - PARAPET.z, r.end.y + PARAPET.z]:
		var side := Vector2(0.0, signf(z - cz))
		if open == Vector2.ZERO:
			parapet(Vector2(r.position.x + ABUTMENT.x * 0.5, z), Vector2(r.end.x - ABUTMENT.x * 0.5, z), side)
			continue
		# a landing breaks the parapet (open: from, to along x): it has its own
		parapet(Vector2(r.position.x + ABUTMENT.x * 0.5, z), Vector2(open.x - PARAPET.z, z), side)
		parapet(Vector2(open.y + PARAPET.z, z), Vector2(r.end.x - ABUTMENT.x * 0.5, z), side)
	# the four heads: north-west and south-east with lanterns (the first of the pair casting shadows), the others candles
	for k in 4:
		var west := k == 0 or k == 3
		var north := k == 0 or k == 2
		var lip := r.position.x if west else r.end.x
		var into := 1.0 if west else -1.0
		var side := r.position.y if north else r.end.y
		var away := -1.0 if north else 1.0
		abutment(Vector2(lip, side), into, away)
		var head := Vector2(lip + into * ABUTMENT.x * 0.5, side + away * PARAPET.z)
		if k < 2:
			var l := tomb.lantern(Vector3(head.x, 0.0, head.y), 0.0, stone(), TombKit.WARM, ~Arena.CROWD_LAYER, HEAD_LANTERN)
			l.light_energy = BRIDGE_LAMP_ENERGY
			l.omni_range = BRIDGE_LAMP_RANGE
			l.shadow_enabled = shadow_nw if k == 0 else shadow_se
		else:
			bridge_head(head)
			candles(Vector3(head.x, HEAD.y, head.y), 3)


## The abutment a bridge springs from at one corner (F-3): against the rift's wall at `corner` (where the lip meets the
## deck's side), reaching `into` the rift (x sign) and `away` from the deck (z sign): cut stone under the floor, then
## the depths' stone down into the haze.
func abutment(corner: Vector2, into: float, away: float) -> void:
	var c := corner + Vector2(into * ABUTMENT.x * 0.5, away * ABUTMENT.z * 0.5)
	m.box(Vector3(c.x, -0.03 - ABUTMENT.y * 0.5, c.y), Vector3(ABUTMENT.x, ABUTMENT.y, ABUTMENT.z), 0.0, ashlar(), false)
	m.layers = 1 | ArenaKit.DEPTH_LAYER
	var top := -0.03 - ABUTMENT.y
	m.box(Vector3(c.x, (top + ABUTMENT_FOOT) * 0.5, c.y), Vector3(ABUTMENT.x - 0.1, top - ABUTMENT_FOOT, ABUTMENT.z - 0.1), 0.0, deep(), false)
	m.layers = 1


## A head pillar of a bridge (F-2): plinth, shaft and cap, HEAD.y tall.
func bridge_head(at: Vector2) -> void:
	var mat := stone()
	m.block(Vector3(at.x, 0.0, at.y), Vector3(HEAD.x + 0.12, Masonry.CURB * 0.7, HEAD.x + 0.12), 0.0, mat)
	m.block(Vector3(at.x, 0.0, at.y), Vector3(HEAD.x, HEAD.y - HEAD.z, HEAD.x), 0.0, mat)
	m.block(Vector3(at.x, HEAD.y - HEAD.z, at.y), Vector3(HEAD.x + 0.14, HEAD.z, HEAD.x + 0.14), 0.0, mat)


## The deck's own paving over the floor (F-2): the depths' dark stone under it all (the joints, and the seams where it
## meets the platforms), a kerb of lighter stone in lengths along each side, slabs running along the span in
## DECK_ROWS staggered rows between the kerbs.
func deck(r: Rect2) -> void:
	var x0 := r.position.x + SEAM
	var x1 := r.end.x - SEAM
	m.prism(rect_poly(r.position.x, r.end.x, r.position.y, r.end.y), 0.0, SEAM_TOP, deep())
	var kerb := m.stone(0.0, stone_tint() * KERB.z)
	var slab := m.stone(0.0, stone_tint() * DECK_TINT)
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(Vector2i(r.position * 10.0))
	var rows: Array[Vector2] = [Vector2(r.position.y, r.position.y + KERB.x)]
	var inner := (r.size.y - KERB.x * 2.0) / DECK_ROWS
	for k in DECK_ROWS:
		var z := r.position.y + KERB.x + inner * k
		rows.append(Vector2(z, z + inner))
	rows.append(Vector2(r.end.y - KERB.x, r.end.y))
	for k in rows.size():
		var is_kerb := k == 0 or k == rows.size() - 1
		var x := x0
		var first := true
		while x < x1 - 0.05:
			var l := rng.randf_range(DECK_SLAB.x, DECK_SLAB.y) * (0.5 if first and k % 2 == 1 else 1.0)
			first = false
			if x1 - (x + l) < DECK_SLAB.x * 0.5:
				l = x1 - x
			var j := DECK_JOINT * 0.5
			m.prism(rect_poly(x + j, x + l - j, rows[k].x + j, rows[k].y - j), 0.0, KERB.y if is_kerb else DECK_TOP, kerb if is_kerb else slab)
			x += l


## True when an edge facing `out` (on the floor) is one the camera looks across (its outside toward the camera).
static func faces_camera(out: Vector2) -> bool:
	var yaw := deg_to_rad(Feel.live().cam_yaw)
	return out.dot(Vector2(sin(yaw), cos(yaw))) > 0.2


func rect_poly(x0: float, x1: float, z0: float, z1: float) -> PackedVector2Array:
	return PackedVector2Array([Vector2(x0, z0), Vector2(x1, z0), Vector2(x1, z1), Vector2(x0, z1)])


## The open parapet of a bridge from a to b (spec 1.3: 0.9 m): a curb, a rail, posts every PARAPET_POST meters and
## bellied balusters between them, the abyss seen through it. out: the side it faces (away from the deck); C18 (ENV
## P2-2): one on the side the camera looks across opens round the paladin behind it (see_through, as the balustrades:
## at 0.9 m it hid him from the waist down on the near kerb).
func parapet(a: Vector2, b: Vector2, out := Vector2.ZERO) -> void:
	var mat := see(stone()) if faces_camera(out) else stone()
	var length := a.distance_to(b)
	var along := (b - a) / maxf(length, 0.001)
	var yaw := atan2(-along.y, along.x)
	var mid := (a + b) * 0.5
	m.box(Vector3(mid.x, PARAPET_CURB.x * 0.5, mid.y), Vector3(length, PARAPET_CURB.x, PARAPET_CURB.y), yaw, mat, false)
	m.box(Vector3(mid.x, PARAPET.x - PARAPET_RAIL.x * 0.5, mid.y), Vector3(length, PARAPET_RAIL.x, PARAPET_RAIL.y), yaw, mat, false)
	var posts := maxi(1, roundi(length / PARAPET_POST))
	var bay := length / posts
	for i in posts + 1:
		var p := a + along * bay * i
		m.box(Vector3(p.x, PARAPET.x * 0.5 + 0.03, p.y), Vector3(PARAPET_POST_SIDE, PARAPET.x + 0.06, PARAPET.y), yaw, mat)
	var shaft := PARAPET.x - PARAPET_RAIL.x - PARAPET_CURB.x
	var n := floori(length / BALUSTER.y)
	for i in n:
		var s := (i + 0.5) * length / n
		var t := s / bay
		if absf(t - roundf(t)) * bay < PARAPET_POST_SIDE:
			continue
		var p := a + along * s
		m.box(Vector3(p.x, PARAPET_CURB.x + shaft * 0.5, p.y), Vector3(BALUSTER.x, shaft, BALUSTER.x), yaw, mat)
		m.box(Vector3(p.x, PARAPET_CURB.x + shaft * 0.35, p.y), Vector3(BALUSTER.z, BALUSTER.w, BALUSTER.z), yaw, mat)


## A whole column (TombKit.column's foot and shaft, which the Seal Chamber keeps): plinth, base, shaft, then a necking
## ring, a round bell (the echinus) and a square abacus. C18 (ART P1-5, ENV P1-6): the two arches springing from the
## abacus read as a fork ("Y") from the fight's camera, the same on every column; now each column is one of three
## silhouettes by where it stands (column_kind): the capital with its abacus, the capital with a tall impost block and
## a ring round the shaft, or (broken, where the room allows it) the shaft snapped at COLUMN_BROKEN of its height.
func round_column(o: ArenaObstacle, broken := false) -> void:
	var mat := see(stone()) if o.see_through else stone()
	var kind := column_kind(o.center, broken)
	if kind == ColumnKind.BROKEN:
		tomb.column(o.center, o.radius, o.height * COLUMN_BROKEN, mat, true)
		return
	var foot := Vector3(o.center.x, 0.0, o.center.y)
	var r := o.radius
	var shaft_r := r * TombKit.COLUMN_SHAFT
	m.block(foot, Vector3(r * 1.41, TombKit.COLUMN_PLINTH, r * 1.41), PI * 0.25, mat, false)
	m.shaft(foot + Vector3(0, TombKit.COLUMN_PLINTH, 0), r * 0.98, TombKit.COLUMN_BASE - TombKit.COLUMN_PLINTH, mat)
	m.shaft(foot + Vector3(0, TombKit.COLUMN_BASE, 0), shaft_r * 1.12, 0.12, mat)
	var impost := IMPOST.y if kind == ColumnKind.IMPOST else 0.0
	var head := CAPITAL.x + CAPITAL.y + ABACUS + impost
	var cap_y := o.height - head
	m.shaft(foot + Vector3(0, TombKit.COLUMN_BASE, 0), shaft_r, cap_y - TombKit.COLUMN_BASE, mat)
	var ring := m.shaft(foot + Vector3(0, cap_y, 0), shaft_r * 1.1, CAPITAL.x, mat)
	var bell := m.shaft(foot + Vector3(0, cap_y + CAPITAL.x, 0), shaft_r * CAPITAL.z, CAPITAL.y, mat)
	(bell.mesh as CylinderMesh).bottom_radius = shaft_r
	for piece_mi: MeshInstance3D in [ring, bell]:
		(piece_mi.mesh as CylinderMesh).radial_segments = CAPITAL_SIDES
	var top := cap_y + CAPITAL.x + CAPITAL.y
	# the square abacus, turned to the room's grid, a little wider than the bell
	var side := shaft_r * CAPITAL.w * 2.0
	m.block(foot + Vector3(0, top, 0), Vector3(side, ABACUS, side), 0.0, mat, false)
	if kind == ColumnKind.IMPOST:
		# a tall impost block on the abacus (where an arch would spring), and an annulet round the shaft's middle
		m.block(foot + Vector3(0, top + ABACUS, 0), Vector3(side * IMPOST.x, impost, side * IMPOST.x), 0.0, mat, false)
		var band := m.shaft(foot + Vector3(0, lerpf(TombKit.COLUMN_BASE, cap_y, ANNULET.x), 0), shaft_r * ANNULET.y, ANNULET.z, mat)
		(band.mesh as CylinderMesh).radial_segments = CAPITAL_SIDES


enum ColumnKind { CAPITAL, IMPOST, BROKEN }


## Which of the three silhouettes the column standing at `at` takes (the same at the same place); BROKEN only where
## `broken` is allowed.
static func column_kind(at: Vector2, broken := false) -> ColumnKind:
	var h := posmod(hash(Vector2i(at * 10.0)), 1000)
	var n := 3 if broken else 2
	return (h % n) as ColumnKind


# ---------- walls, benches, light from above (E5) ----------

## A wall along a to b (the floor's edge), its face FACE_SET behind it (out: away from the room), `height` tall and
## `thick` thick, with openings (x, y: from and to along it from a; z, w: from and to in height) through it, and a
## cornice. mat: its stone (the arena's ashlar by default). Nothing on the floor.
func wall(a: Vector2, b: Vector2, out: Vector2, height: float, openings: Array[Vector4] = [], mat: Material = null,
		thick := FACE_THICK) -> void:
	if mat == null:
		mat = ashlar()
	var length := a.distance_to(b)
	var t0 := FACE_SET
	var t1 := FACE_SET + thick
	var cuts := openings.duplicate()
	cuts.sort_custom(func(p: Vector4, q: Vector4) -> bool: return p.x < q.x)
	var s := 0.0
	for c: Vector4 in cuts:
		if c.x > s:
			wall_part(a, b, out, s, c.x, t0, t1, 0.0, height, mat)
		s = maxf(s, c.y)
		if c.z > 0.0:
			wall_part(a, b, out, c.x, c.y, t0, t1, 0.0, c.z, mat)
		if c.w < height:
			wall_part(a, b, out, c.x, c.y, t0, t1, c.w, height, mat)
	if s < length:
		wall_part(a, b, out, s, length, t0, t1, 0.0, height, mat)
	wall_part(a, b, out, 0.0, length, t0 - WALL_CORNICE.y, t1, height - WALL_CORNICE.x, height, mat)
	# under the face, from the floor's edge back: a low sill so no gap shows between the floor and the wall
	wall_part(a, b, out, 0.0, length, -0.02, t0, -0.6, 0.06, mat)


## One block of a wall: from s0 to s1 along a to b, from d0 to d1 out of the edge, from y0 to y1.
func wall_part(a: Vector2, b: Vector2, out: Vector2, s0: float, s1: float, d0: float, d1: float, y0: float, y1: float, mat: Material) -> void:
	if s1 - s0 < 0.02 or y1 - y0 < 0.02:
		return
	var along := (b - a).normalized()
	var c := a + along * (s0 + s1) * 0.5 + out * (d0 + d1) * 0.5
	m.box(Vector3(c.x, (y0 + y1) * 0.5, c.y), Vector3(s1 - s0, y1 - y0, d1 - d0), atan2(-along.y, along.x), mat, false)


## A wall of the front cut at CUT_WALL.x along a to b (the crypt's, spec 2.1 of C12, for any arena): cut stone on both
## faces, the dark fill between them on the cut, the outer face dropping CUT_WALL.z into the dark, gaps (from, to along
## it) left open, fallen blocks outside. Nothing on the floor.
func cut_wall(a: Vector2, b: Vector2, out: Vector2, gaps: Array[Vector2] = [], skin: Material = null, fill: Material = null) -> void:
	if skin == null:
		skin = ashlar()
	if fill == null:
		fill = m.stone(0.0, stone_tint() * 0.3)
	var along := (b - a).normalized()
	var length := a.distance_to(b)
	var runs := gaps.duplicate()
	runs.sort_custom(func(p: Vector2, q: Vector2) -> bool: return p.x < q.x)
	runs.append(Vector2(length, length))
	var s0 := 0.0
	var skin_w := CUT_WALL.y * (1.0 - CUT_FILL) * 0.5
	for g: Vector2 in runs:
		if g.x > s0 + 0.05:
			wall_part(a, b, out, s0, g.x, 0.0, skin_w, -CUT_WALL.z, CUT_WALL.x, skin)
			wall_part(a, b, out, s0, g.x, CUT_WALL.y - skin_w, CUT_WALL.y, -CUT_WALL.z, CUT_WALL.x - 0.06, skin)
			wall_part(a, b, out, s0, g.x, skin_w, CUT_WALL.y - skin_w, -CUT_WALL.z, CUT_WALL.x - 0.1, fill)
			var r := RandomNumberGenerator.new()
			r.seed = hash(Vector2i((a + along * s0) * 10.0))
			for k in floori((g.x - s0) * CUT_FALLEN):
				var p := a + along * r.randf_range(s0 + 0.3, g.x - 0.3) + out * (CUT_WALL.y + r.randf_range(0.3, 1.2))
				var size := r.randf_range(0.3, 0.7)
				var blk := m.box(Vector3(p.x, -r.randf_range(0.6, 2.2), p.y), Vector3(size, size * 0.7, size * 0.9), r.randf() * TAU, skin)
				blk.rotate_object_local(Vector3.RIGHT, r.randf_range(-0.6, 0.6))
		s0 = maxf(s0, g.y)


## The stretches the doors' mouths take out of the edge a to b (from, to along it, `cheek` wider on each side), for
## wall and cut_wall.
func door_gaps(a: Vector2, b: Vector2, out: Vector2, cheek := EXIT_CHEEK.x) -> Array[Vector2]:
	var along := (b - a).normalized()
	var length := a.distance_to(b)
	var gaps: Array[Vector2] = []
	for e in layout.exits:
		if e.inward.dot(-out) < 0.9:
			continue
		var mid := e.mouth.get_center() + e.inward * absf(e.mouth.size.dot(e.inward)) * 0.5
		var s := (mid - a).dot(along)
		if s < -1.0 or s > length + 1.0 or absf((mid - a).dot(out)) > 0.5:
			continue
		var w := absf(e.mouth.size.dot(along))
		gaps.append(Vector2(s - w * 0.5 - cheek, s + w * 0.5 + cheek))
	return gaps


## The drums of a fallen column lying along its footprint (a capsule box of the layout): a few drums with gaps, each a
## short shaft laid on its side, a little askew.
func drums(o: ArenaObstacle) -> void:
	var long_x := o.half.x >= o.half.y
	var half := o.half if long_x else Vector2(o.half.y, o.half.x)
	var dir := Vector2(cos(o.yaw), sin(o.yaw)) if long_x else Vector2(-sin(o.yaw), cos(o.yaw))
	var r := minf(half.y, o.height * 0.5)
	var length := half.x * 2.0 - r * 0.4
	var n := maxi(2, roundi(length / (r * 2.4)))
	var drum := length / n
	var mat := stone()
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(Vector2i(o.center * 10.0))
	var axis := Vector3(dir.x, 0.0, dir.y)
	var side := axis.cross(Vector3.UP).normalized()
	for k in n:
		var c := o.center + dir * (-length * 0.5 + drum * (k + 0.5)) + Vector2(side.x, side.z) * rng.randf_range(-0.08, 0.08)
		var mi := m.shaft(Vector3(c.x, 0.0, c.y), r * rng.randf_range(0.88, 1.0), drum - 0.1, mat)
		# laid on its side: its own up along dir, turned a little about the floor's up
		mi.basis = Basis(Vector3.UP, rng.randf_range(-0.15, 0.15)) * Basis(side, axis, side.cross(axis)).orthonormalized()
		mi.position = Vector3(c.x, r * 0.95, c.y)


## A blind pointed window on a wall's face (foot: the middle of its sill on the face; facing: into the room): a dark
## panel set back, its pointed frame, a mullion and broken tracery (no glass, no figure).
func blind_window(foot: Vector3, facing: Vector2, width: float, height: float, mat: Material) -> void:
	var yaw := atan2(facing.x, facing.y)
	var basis := Basis(Vector3.UP, yaw)
	var f := Vector3(facing.x, 0.0, facing.y)
	var dark := m.stone(0.0, WINDOW_PANEL)
	var straight := height - width * 0.55
	m.box(foot - f * WINDOW_PANEL_SET + Vector3(0, straight * 0.5, 0), Vector3(width, straight, 0.06), yaw, dark, false)
	var head := m.box(foot - f * WINDOW_PANEL_SET + Vector3(0, straight, 0), Vector3(width * 0.7071, width * 0.7071, 0.06), yaw, dark, false)
	head.basis = basis * Basis.from_scale(Vector3(1.0, 1.25, 1.0)) * Basis(Vector3.BACK, PI * 0.25)
	m.pointed_arch(foot + f * 0.05, facing, width, height, 0.24, 0.3, mat)
	m.box(foot + f * 0.1 + Vector3(0, -0.08, 0), Vector3(width + 0.5, 0.16, 0.3), yaw, mat)
	# the mullion, broken off two thirds up, and the stump of the tracery over it
	var r := RandomNumberGenerator.new()
	r.seed = hash(Vector3i(foot * 10.0))
	var up := straight * r.randf_range(0.55, 0.9)
	m.box(foot - f * 0.08 + Vector3(0, up * 0.5, 0), Vector3(WINDOW_MULLION, up, 0.2), yaw, mat)
	for sd: float in [-1.0, 1.0]:
		if r.randf() < 0.6:
			var sub := foot - f * 0.1 + basis * Vector3(sd * width * 0.25, straight - 0.2, 0)
			m.pointed_arch(sub, facing, width * 0.38, width * 0.5, WINDOW_MULLION, 0.16, mat)


## An outer edge of a closed room (E5: the Provação, the Altar Esquecido): the sides away from the camera (north, west
## and the cut between them) a wall `height` tall with the doors in it opened (in_wall), the others the low cut wall
## of the front (cut_wall) with the doors' gaps. Each run reaches CLOSE_REACH past its ends so the corners meet.
## A closed room's edge (the Provação's and the altar's): a tall wall on the sides away from the camera (north and
## west), the low cut wall in front. AP-1 (ART-04.2): the chamber no longer stands as a box in the dark. A tall wall's
## end that meets the low front is broken down in steps (no clean section of the wall facing the camera, RUIN_END);
## past the low front the floor goes on, broken, sinking into the dark (APRON), its slabs on rock that hangs down into
## the mist; the low front's face only drops FRONT_DROP before the rock takes over. Nothing on the walkable floor.
const RUIN_END := 2.2
const RUIN_STEPS: Array[Vector2] = [Vector2(0.4, 0.5), Vector2(0.2, 0.28), Vector2(0.06, 0.12)]
const RUIN_RUBBLE := 3
const APRON_REACH := Vector2(0.9, 2.6)
const APRON_RUN := Vector2(1.1, 2.6)
const APRON_GAP := Vector2(0.15, 0.7)
const APRON_SINK := Vector2(0.1, 0.55)
const APRON_HANG := Vector2(1.6, 4.0)
const APRON_DOOR := 1.2


func closed_edge(a: Vector2, b: Vector2, out: Vector2, height: float, mat: Material = null) -> void:
	var along := (b - a).normalized()
	var a2 := a - along * CLOSE_REACH
	var b2 := b + along * CLOSE_REACH
	if _tall(out):
		# a broken end where the next (or the last) edge is the low front
		var ruin_a := _low(_side_out(a, along))
		var ruin_b := _low(_side_out(b, -along))
		# (a short run, as a chamfer, breaks along most of its length)
		var run := a2.distance_to(b2)
		var end_len := minf(RUIN_END, run * (0.45 if ruin_a and ruin_b else 0.9))
		var s0 := end_len if ruin_a else 0.0
		var s1 := run - (end_len if ruin_b else 0.0)
		var openings: Array[Vector4] = []
		for g in door_gaps(a2, b2, out, JAMB):
			openings.append(Vector4(g.x - s0, g.y - s0, 0.0, WALL_DOOR.y + 0.4))
		if s1 - s0 > 0.05:
			wall(a2 + along * s0, a2 + along * s1, out, height, openings, mat)
		if ruin_a:
			_ruin_end(a2 + along * s0, -along, out, height, end_len, mat)
		if ruin_b:
			_ruin_end(a2 + along * s1, along, out, height, end_len, mat)
	else:
		cut_wall(a2, b2, out, door_gaps(a2, b2, out), mat)
		_apron(a2, b2, out)


## True for an edge whose wall stands tall (facing north or west: away from the camera).
static func _tall(out: Vector2) -> bool:
	return out.y < -0.5 or out.x < -0.5


## True for a corner's other edge that is the low front (ZERO: `p` is no corner of the floor, as where a door's mouth
## splits an edge, and nothing is broken there).
static func _low(out: Vector2) -> bool:
	return out != Vector2.ZERO and not _tall(out)


## The outward normal of the other edge of the floor at its corner `p` (not the one running from p along `own`).
func _side_out(p: Vector2, own: Vector2) -> Vector2:
	for poly in layout.floor.polys:
		var n := poly.size()
		for i in n:
			if poly[i].distance_to(p) > 0.05:
				continue
			for j: int in [(i + 1) % n, (i - 1 + n) % n]:
				var d := (poly[j] - p).normalized()
				if d.dot(own) > 0.9:
					continue
				var perp := Vector2(d.y, -d.x)
				var mid := (p + poly[j]) * 0.5
				return perp if not Geometry2D.is_point_in_polygon(mid + perp * 0.05, poly) else -perp
	return Vector2.ZERO


## The broken end of a tall wall: from `start` along `dir` the wall steps down (RUIN_STEPS, shares of its height,
## each a little uneven) over `length` to the corner and past it by CLOSE_REACH, a few fallen blocks on top and outside.
func _ruin_end(start: Vector2, dir: Vector2, out: Vector2, height: float, length: float, mat: Material) -> void:
	var r := RandomNumberGenerator.new()
	r.seed = hash(Vector2i(start * 10.0))
	var step := length / RUIN_STEPS.size()
	for k in RUIN_STEPS.size():
		var h := height * r.randf_range(RUIN_STEPS[k].x, RUIN_STEPS[k].y)
		var s0 := step * k
		var s1 := step * (k + 1)
		var p0 := start + dir * s0
		var p1 := start + dir * s1
		# the wall's own course, ragged on top: two blocks of a little different heights
		var mid := r.randf_range(0.35, 0.65)
		wall_part(p0, p1, out, 0.0, step * mid, FACE_SET, FACE_SET + FACE_THICK, -0.6, h, mat)
		wall_part(p0, p1, out, step * mid, step, FACE_SET, FACE_SET + FACE_THICK, -0.6, h * r.randf_range(0.82, 0.96), mat)
		for i in RUIN_RUBBLE if k > 0 else 1:
			var q := (p0 + p1) * 0.5 + dir * r.randf_range(-step * 0.4, step * 0.4) + out * (FACE_SET + FACE_THICK * r.randf_range(0.2, 0.8))
			var size := r.randf_range(0.25, 0.55)
			var blk := m.box(Vector3(q.x, h + size * 0.3, q.y), Vector3(size, size * 0.6, size * 0.8), r.randf() * TAU, mat)
			blk.rotate_object_local(Vector3.RIGHT, r.randf_range(-0.4, 0.4))


## The broken floor past a low front (a to b, out): runs of the floor's slabs on rock, reaching APRON_REACH out and
## sinking APRON_SINK, gaps between them, the door's stairs left clear.
func _apron(a: Vector2, b: Vector2, out: Vector2) -> void:
	var length := a.distance_to(b)
	var along := (b - a) / maxf(length, 0.001)
	var gaps := door_gaps(a, b, out, EXIT_CHEEK.y + APRON_DOOR)
	var r := RandomNumberGenerator.new()
	r.seed = hash(Vector2i((a + b) * 10.0))
	var base := CUT_WALL.y
	var s := r.randf_range(0.0, APRON_GAP.y)
	while s < length - 0.4:
		var l := minf(r.randf_range(APRON_RUN.x, APRON_RUN.y), length - s)
		var blocked := false
		for g in gaps:
			if s < g.y and s + l > g.x:
				blocked = true
				s = g.y
		if blocked:
			continue
		var p0 := a + along * s + out * base
		var p1 := a + along * (s + l) + out * base
		var o0 := r.randf_range(APRON_REACH.x, APRON_REACH.y)
		var o1 := r.randf_range(APRON_REACH.x, APRON_REACH.y)
		var tip := (p0 + p1) * 0.5 + out * maxf(o0, o1) * r.randf_range(0.8, 1.1) + along * l * r.randf_range(-0.2, 0.2)
		chunk(PackedVector2Array([p0, p1, p1 + out * o1, tip, p0 + out * o0]), -r.randf_range(APRON_SINK.x, APRON_SINK.y),
			r.randf_range(APRON_HANG.x, APRON_HANG.y))
		s += l + r.randf_range(APRON_GAP.x, APRON_GAP.y)


## C18 (ART P1-6, ENV P1-5): the event chambers floated as a box in an empty sky, their walls' cut ends against
## nothing. Behind them now: two cards of far ruins at two depths (BACKDROP_DIST from the camera, the nearer less hazed)
## fading into `mist`, and a bank of the same mist below the floor's lip, so the walls end in a place.
const BACKDROP_DIST: Array[float] = [88.0, 108.0]
const BACKDROP_HAZE: Array[float] = [0.55, 0.75]
const BACKDROP_COLUMN: Array[float] = [6.0, 4.5]
const BACKDROP_TOPS: Array[Vector2] = [Vector2(-1.0, 4.0), Vector2(-5.0, 5.0)]
const BACKDROP_SINK: Array[Vector2] = [Vector2(-6.0, -18.0), Vector2(-10.0, -24.0)]
const BACKDROP_SIZE := Vector2(220.0, 80.0)
const BACKDROP_TOP := 16.0
const BACKDROP_BANK := Vector3(-4.0, 8.0, 0.55)


func backdrop(mist: Color, stone: Color, edge_color: Color) -> void:
	var feel := Feel.live()
	var yaw := deg_to_rad(feel.cam_yaw)
	var c := arena.shape().bounds().get_center()
	var eye := Vector3(c.x, 0, c.y) + Feel.cam_offset_of(feel.cam_distance, feel.cam_pitch, feel.cam_yaw)
	var ahead := Vector3(-sin(yaw), 0, -cos(yaw))
	for k in BACKDROP_DIST.size():
		var at := Vector3(eye.x, BACKDROP_TOP - BACKDROP_SIZE.y * 0.5, eye.z) + ahead * BACKDROP_DIST[k]
		kit.ruin_card(at, BACKDROP_SIZE, yaw, mist, BACKDROP_HAZE[k], BACKDROP_COLUMN[k], 5.0 + k * 13.0, BACKDROP_TOPS[k],
			BACKDROP_SINK[k])
		var cm := (kit.root.get_child(kit.root.get_child_count() - 1) as MeshInstance3D).material_override as ShaderMaterial
		cm.set_shader_parameter(&"stone_color", stone)
		cm.set_shader_parameter(&"edge_color", edge_color)
	var b := arena.shape().bounds()
	kit.mist_bank(Vector3(c.x, BACKDROP_BANK.x, c.y), b.size.length() * Vector2(1.6, 0.0) + Vector2(0.0, BACKDROP_BANK.y),
		mist * 2.0, BACKDROP_BANK.z, 0.3, 0.4)


## True on the browser's and the phone's renderer (Compatibility).
static func compat() -> bool:
	return RenderingServer.get_current_rendering_method() == "gl_compatibility"


## TA-HB2 (docs/gallery/hb/ART_REVIEW.md item 2): the edge and foreground pieces (EdgeKit) for the stylized look only:
## built on kit.styled() (hidden in the classic look, painted with the room's stone by paint_look), never on the
## walkable floor, roots and ivy always hanging from something that hides their top, no light of their own.
var _edge: EdgeKit


func edge_kit() -> EdgeKit:
	if _edge == null:
		_edge = EdgeKit.new(kit)
		_edge.stone = kit.styled()
	return _edge


## ART_REVIEW.md 4.5 P2-B1 (only in the stylized look): a soft pool of key light over a fight field (x, z, radius),
## diffuse (no painted bands, no hard edge), no shadow, never on the crowd; its middle KEY_POOL_SHIFT of the radius away
## from the camera, so the floor nearest the camera, below the hero on the screen, falls off and the fight reads as the
## lightest part (the near band under 0.80 of the middle). Height, the softness of its edge (spot_angle_attenuation;
## no fall-off with distance, its energy is what reaches the floor).
const KEY_POOL_SHIFT := 0.25
const KEY_POOL_HEIGHT := 16.0
const KEY_POOL_SOFT := 2.0


func key_pool(field: Vector3, color: Color, energy: float) -> SpotLight3D:
	var yaw := deg_to_rad(Feel.live().cam_yaw)
	var away := -Vector2(sin(yaw), cos(yaw)) * field.z * KEY_POOL_SHIFT
	var to := Vector3(field.x + away.x, 0.0, field.y + away.y)
	var spot := SpotLight3D.new()
	add_child(spot)
	spot.look_at_from_position(to + Vector3(0.01, KEY_POOL_HEIGHT, 0.0), to)
	spot.light_color = color
	spot.light_energy = energy
	spot.light_specular = 0.0
	spot.spot_angle = rad_to_deg(atan(field.z / KEY_POOL_HEIGHT))
	spot.spot_range = KEY_POOL_HEIGHT * 1.6
	spot.spot_attenuation = 0.0
	spot.spot_angle_attenuation = KEY_POOL_SOFT
	spot.shadow_enabled = false
	spot.light_cull_mask = ~Arena.CROWD_LAYER
	spot.set_meta(ArenaKit.NOT_FIRE, true)
	ArenaKit.style_only(spot)
	return spot


## ENV-HB4 (docs/art/benchmark_hades2_style.md 4.1, only in the stylized look, on kit.styled()): the plain coursed wall
## under the floor's edges the camera sees (a maquette's cut in the air) becomes a substructure going down into the
## mist: piers, pointed arches over dark openings, rock fallen against it, dead roots hanging from under some arches.
## A look turns it on with under_look(): `set` (m out of the floor's edge where the wall's face is), `top` (the arches'
## outer tops' height), optional `colors` (depth_stone uniforms for its own stone, if the room has no depths' stone),
## optional `skip` (Rect2s: an edge whose middle is in one is left, e.g. a bridge's deck). Edges whose outside faces the
## camera by UNDER_FACING or more and UNDER_MIN m long or more; never in front of a door's stairs (UNDER_DOOR round each
## exit's mouth). Nothing collides; nothing over the floor (everything is outside it).
const UNDER_FACING := 0.2
const UNDER_MIN := 4.0
## Pier to pier along the edge, its width and how far it stands out of the face, how far its foot goes down.
const UNDER_STEP := 4.6
const UNDER_PIER := Vector2(1.0, 0.8)
const UNDER_FOOT := -18.0
## A pier jittered along the edge by up to this; this share of them broken short (UNDER_BREAK m under the top, a block
## askew on it).
const UNDER_JITTER := 0.35
const UNDER_BROKEN := 0.3
const UNDER_BREAK := Vector2(0.9, 2.2)
## The arch's ring (width, depth) and its springing line as a share of the opening.
const UNDER_RING := Vector2(0.42, 0.55)
const UNDER_SPRING := 0.3
## The piers' and arches' stone a step lighter than the cliff behind (the depth stone's tint), the openings' darkness,
## sunk this far in front of the face.
const UNDER_TINT := 1.7
const UNDER_RECESS := 0.22
const UNDER_RECESS_OUT := 0.05
## Rock fallen against the wall: the chance per bay, its size range, how far below the top it sits (range).
const UNDER_ROCK := Vector3(0.45, 1.1, 2.3)
const UNDER_ROCK_DROP := Vector2(1.2, 5.0)
## Its stone: the depths' stone in bigger, rougher courses.
const UNDER_ROCK_COURSE := Vector2(2.6, 3.4)
## Dead roots from under an arch's crown: the chance per bay, width, length.
const UNDER_ROOTS := Vector3(0.34, 0.9, 1.9)
## Clear of a door's mouth by this (its stairs go down there).
const UNDER_DOOR := 0.5


func under_look() -> Dictionary:
	return {}


var _runs: Array = []
## The balustrades the room stood along its edges (balustrade_edge): [from, to, out] on the floor plane.
var _rails: Array = []


## ENV-HB5 (benchmark_hades2_style.md 4.1): in the stylized look a long balustrade no longer reads as the same module
## over and over: every RAIL_BREAK_EVERY spans (Masonry.POST_GAP apart) one piece breaks it, in turn ivy draped over
## the rail (RAIL_IVY: width, length down its outer face), a broken cap of fallen blocks on a post (RAIL_RUBBLE: across)
## and dead roots over the rail (RAIL_ROOTS); none near a door, all on or outside the rail (never over the floor). On a
## rail turned from the camera (its outer face unseen) the drapes hang down its inner face to the curb instead
## (RAIL_INNER m inside the rail's middle line, still outside the floor).
const RAIL_BREAK_EVERY := 3
const RAIL_BREAK_FIRST := 1
const RAIL_IVY := Vector2(1.8, 1.7)
const RAIL_RUBBLE := 0.8
const RAIL_ROOTS := Vector2(1.6, 2.2)
const RAIL_DRAPE_OUT := 0.12
const RAIL_FAR_OUT := 0.15
const RAIL_FAR := 0.95
const RAIL_STUMP := Vector2(0.3, 1.5)


## The rails with those that go on one from another along the same line joined (a polygon's edge is cut wherever
## a hole or a door meets it: the pieces are short, the balustrade one).
func _joined_rails() -> Array:
	var joined: Array = []
	for rail: Array in _rails:
		if not joined.is_empty():
			var last: Array = joined[-1]
			var dir_last: Vector2 = ((last[1] as Vector2) - (last[0] as Vector2)).normalized()
			var dir: Vector2 = ((rail[1] as Vector2) - (rail[0] as Vector2)).normalized()
			if (last[1] as Vector2).distance_to(rail[0]) < 0.05 and dir_last.dot(dir) > 0.999:
				joined[-1] = [last[0], rail[1], last[2]]
				continue
		joined.append(rail.duplicate())
	return joined


func _break_rails() -> void:
	var gap := Masonry.POST_GAP
	var kinds := 0
	var yaw := deg_to_rad(Feel.live().cam_yaw)
	var eye := Vector2(sin(yaw), cos(yaw))
	for rail: Array in _joined_rails():
		var a: Vector2 = rail[0]
		var b: Vector2 = rail[1]
		var out: Vector2 = rail[2]
		var length := a.distance_to(b)
		var spans := maxi(1, roundi(length / gap))
		if spans < RAIL_BREAK_EVERY:
			continue
		var along := (b - a) / maxf(length, 0.001)
		var k := RAIL_BREAK_FIRST
		while k < spans:
			var kind := kinds % 3
			# drapes hang in the middle of a span, the fallen cap sits on a post
			var t := (float(k) + (0.0 if kind == 1 else 0.5)) / float(spans)
			var p := a.lerp(b, t)
			k += RAIL_BREAK_EVERY
			if _near_door(p, out, RAIL_IVY.x):
				continue
			kinds += 1
			var seed_ := hash(Vector2i(p * 10.0))
			if out.dot(eye) <= 0.2:
				if kind == 1:
					edge_kit().broken_pillar(Vector3(p.x, Masonry.POST.y + Masonry.POST_CAP.y, p.y), RAIL_STUMP.x, RAIL_STUMP.y,
						out, seed_)
				else:
					var q := p + out * RAIL_FAR_OUT
					edge_kit().rubble(Vector3(q.x, Masonry.RAIL_TOP, q.y), RAIL_FAR, seed_)
				continue
			var top := Vector3(p.x + out.x * RAIL_DRAPE_OUT, Masonry.RAIL_TOP, p.y + out.y * RAIL_DRAPE_OUT)
			match kind:
				0:
					edge_kit().ivy(top, RAIL_IVY.x, RAIL_IVY.y, along, eye, seed_)
				1:
					edge_kit().rubble(Vector3(p.x, Masonry.POST.y + Masonry.POST_CAP.y, p.y), RAIL_RUBBLE, seed_)
				2:
					edge_kit().root_curtain(top, RAIL_ROOTS.x, RAIL_ROOTS.y, along, seed_)


func _under_arcades(u: Dictionary) -> void:
	var yaw := deg_to_rad(Feel.live().cam_yaw)
	var toward := Vector2(sin(yaw), cos(yaw))
	var mat := deep()
	if u.has(&"colors"):
		mat = mat.duplicate() as ShaderMaterial
		var colors: Dictionary = u[&"colors"]
		for k: StringName in colors:
			mat.set_shader_parameter(k, colors[k])
	var recess := mat.duplicate() as ShaderMaterial
	recess.set_shader_parameter(&"tint", UNDER_RECESS)
	mat = mat.duplicate() as ShaderMaterial
	mat.set_shader_parameter(&"tint", UNDER_TINT)
	var rock := mat.duplicate() as ShaderMaterial
	rock.set_shader_parameter(&"course", UNDER_ROCK_COURSE.x)
	rock.set_shader_parameter(&"block_len", UNDER_ROCK_COURSE.y)
	var skip: Array = u.get(&"skip", [])
	for run: Array in _runs:
		var a: Vector2 = run[0]
		var b: Vector2 = run[1]
		var out: Vector2 = run[2]
		if run[3] != Edge.OUTER or out.dot(toward) < UNDER_FACING or a.distance_to(b) < UNDER_MIN:
			continue
		var hidden := false
		for r: Rect2 in skip:
			if r.has_point((a + b) * 0.5):
				hidden = true
		if not hidden:
			_under_run(a, b, out, float(u[&"set"]), float(u[&"top"]), mat, recess, rock)


## One edge's arcade (see _under_arcades).
func _under_run(a: Vector2, b: Vector2, out: Vector2, set_: float, top: float, mat: ShaderMaterial,
		recess: ShaderMaterial, rock: ShaderMaterial) -> void:
	var sm := kit.styled()
	var length := a.distance_to(b)
	var along := (b - a) / length
	var yaw := atan2(-along.y, along.x)
	var r := RandomNumberGenerator.new()
	r.seed = hash(Vector2i((a + b) * 10.0)) + 4471
	var n := maxi(2, roundi(length / UNDER_STEP) + 1)
	var piers: Array[float] = []
	for i in n:
		var s := lerpf(UNDER_PIER.x * 0.5, length - UNDER_PIER.x * 0.5, float(i) / (n - 1))
		if i > 0 and i < n - 1:
			s += r.randf_range(-UNDER_JITTER, UNDER_JITTER)
		piers.append(s)
	var face := out * set_
	for i in n:
		var s := piers[i]
		if _near_door(a + along * s, out, UNDER_PIER.x):
			continue
		var t := top
		var broken := i > 0 and i < n - 1 and r.randf() < UNDER_BROKEN
		if broken:
			t -= r.randf_range(UNDER_BREAK.x, UNDER_BREAK.y)
		var p := a + along * s + face + out * UNDER_PIER.y * 0.5
		sm.box(Vector3(p.x, (t + UNDER_FOOT) * 0.5, p.y), Vector3(UNDER_PIER.x, t - UNDER_FOOT, UNDER_PIER.y), yaw, mat, false)
		if broken:
			var cap := sm.box(Vector3(p.x, t + 0.15, p.y), Vector3(UNDER_PIER.x * 0.8, 0.5, UNDER_PIER.y * 0.9), yaw + r.randf_range(-0.3, 0.3), rock, false)
			cap.rotate_object_local(Vector3.RIGHT, r.randf_range(-0.25, 0.25))
	for i in n - 1:
		var s0 := piers[i] + UNDER_PIER.x * 0.5
		var s1 := piers[i + 1] - UNDER_PIER.x * 0.5
		var span := s1 - s0
		var mid := a + along * (s0 + s1) * 0.5
		if span < 1.0 or _near_door(mid, out, span):
			continue
		# the arch's outer apex at `top`: voussoir_arch's geometry (radius 0.8 of the span)
		var rad := span * 0.8
		var cx := rad - span * 0.5
		var spring := span * UNDER_SPRING
		var apex := spring + sqrt((rad + UNDER_RING.x) * (rad + UNDER_RING.x) - cx * cx)
		var foot_y := top - apex
		var at := mid + face + out * UNDER_RING.y * 0.5
		sm.voussoir_arch(Vector3(at.x, foot_y, at.y), out, span, spring, UNDER_RING.x, UNDER_RING.y, mat)
		# the bay's wall behind (over whatever face was there) and its dark opening under the springing line
		var w := mid + face + out * 0.02
		sm.box(Vector3(w.x, (top + UNDER_FOOT) * 0.5, w.y), Vector3(span + 0.1, top - UNDER_FOOT, 0.04), yaw, mat, false)
		var o := mid + face + out * UNDER_RECESS_OUT
		var o_top := foot_y + spring + span * 0.12
		sm.box(Vector3(o.x, (o_top + UNDER_FOOT) * 0.5, o.y), Vector3(span * 0.96, o_top - UNDER_FOOT, 0.04), yaw, recess, false)
		if r.randf() < UNDER_ROCK.x:
			var size := r.randf_range(UNDER_ROCK.y, UNDER_ROCK.z)
			var q := mid + along * r.randf_range(-span * 0.3, span * 0.3) + face + out * (size * 0.4 + 0.1)
			var blk := sm.box(Vector3(q.x, top - r.randf_range(UNDER_ROCK_DROP.x, UNDER_ROCK_DROP.y), q.y),
				Vector3(size, size * 0.7, size * 0.8), r.randf() * TAU, rock, false)
			blk.rotate_object_local(Vector3.RIGHT, r.randf_range(-0.4, 0.4))
		elif r.randf() < UNDER_ROOTS.x:
			edge_kit().root_curtain(Vector3(at.x, top - UNDER_RING.x, at.y), UNDER_ROOTS.y, UNDER_ROOTS.z, along, i)


## A point of an edge (with `width` along it) within UNDER_DOOR of a door's mouth on that side.
func _near_door(p: Vector2, out: Vector2, width: float) -> bool:
	for e in layout.exits:
		var box := e.mouth.grow(UNDER_DOOR + width * 0.5)
		for k in 4:
			if box.has_point(p + out * (0.6 * k)):
				return true
	return false


## A shaft of light falling on `target` from a hole in the vault `height` m up (leaning SHAFT_LEAN toward the back): a
## spot of `cone` degrees, no fall-off with distance (its energy is what reaches the floor), with or without shadow
## (never in Compatibility), never on the crowd, and the dust drifting down through it (Arena._dust).
func moon_shaft(target: Vector2, color: Color, energy: float, cone: float, height: float, shadow := true, dust := true) -> SpotLight3D:
	var spot := SpotLight3D.new()
	add_child(spot)
	var to := Vector3(target.x, 0.0, target.y)
	spot.look_at_from_position(to + Vector3(SHAFT_LEAN.x, height, SHAFT_LEAN.y), to)
	spot.light_color = color
	spot.light_energy = energy
	spot.spot_angle = cone
	spot.spot_range = height * 2.0
	spot.spot_attenuation = 0.0
	# the browser's renderer draws the spot's shadow in stripes: none there
	spot.shadow_enabled = shadow and not compat()
	spot.light_cull_mask = ~Arena.CROWD_LAYER
	if dust:
		arena._dust(to)
	return spot


## E5 spec 7.2: the breath of the next room in the mouth of door i (used doors only): a card of light in the colour of
## the air of the arena `look` (BREATH; the hall's when unknown) rising out of its stairs, no light cast. Call it when
## the doors open (Rooms knows where each leads); again on the same door changes its colour. Returns the card (null when
## the door is not used).
func breath(i: int, look: StringName) -> MeshInstance3D:
	if i < 0 or i >= exits_used:
		return null
	var e := layout.exits[i]
	var u := e.inward
	var depth := absf(e.mouth.size.dot(u))
	var end := e.mouth.get_center() - u * depth * 0.5
	var c := end - u * BREATH_BEYOND
	var colour: Color = BREATH.get(look, BREATH[&"hall"])
	var peak := maxf(colour.r, maxf(colour.g, colour.b))
	if peak > BREATH_PEAK:
		colour = colour * (BREATH_PEAK / peak)
	var mat := ShaderMaterial.new()
	mat.shader = BREATH_SHADER
	mat.set_shader_parameter(&"color", colour)
	mat.set_shader_parameter(&"alpha", BREATH_ALPHA)
	mat.set_shader_parameter(&"thread", BREATH_THREAD.get(look, Color(0, 0, 0, 0)))
	var name_ := "Breath%d" % i
	var card := get_node_or_null(name_) as MeshInstance3D
	if card == null:
		card = MeshInstance3D.new()
		card.name = name_
		var q := QuadMesh.new()
		q.size = BREATH_SIZE
		card.mesh = q
		card.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		add_child(card)
	card.material_override = mat
	# upright across the door's way, facing into the room
	card.transform = Transform3D(Basis(Vector3.UP, atan2(u.x, u.y)), Vector3(c.x, BREATH_FOOT + BREATH_SIZE.y * 0.5, c.y))
	return card


# ---------- doors ----------

## What the lanterns of the doors burn (the arenas' warm iron lanterns; the trial's cold ivory).
func door_lamp() -> TombKit.Lamp:
	return TombKit.WARM


## True when door i opens in a wall of the room (an arch over its mouth, steps going down inside it), not over the
## abyss (stairs going down between low cheeks). The arena's script knows its walls.
func in_wall(_i: int) -> bool:
	return false


## Every door of the layout: its stairs going down out of the room from the end of its mouth; a door used gets its
## light (dim until it opens: Arena.light_exit) and, unless a fire bowl of the layout stands within 3 m, a warm
## lantern on the pillar beside it; a door not used keeps its stairs but its mouth is closed at the edge by a low iron
## grille (spec 0.4).
func _doors() -> void:
	for i in layout.exits.size():
		var e := layout.exits[i]
		var u := e.inward
		var side := Vector2(-u.y, u.x)
		var r := e.mouth
		# the edge's middle and the mouth's far end (r: the landing, 4 x 2.4 m beyond the edge)
		var depth := absf(r.size.dot(u))
		var width := absf(r.size.dot(side))
		var edge_mid := r.get_center() + u * depth * 0.5
		var end := r.get_center() - u * depth * 0.5
		var used := i < exits_used
		var mat := stone()
		if not used:
			# the landing is not floor: a slab of stone a little under the floor's level, the grille on the edge
			m.block(Vector3(r.get_center().x, -0.6, r.get_center().y), Vector3(r.size.x, 0.58, r.size.y), 0.0, mat, false)
			var g0 := edge_mid + side * width * 0.5
			var g1 := edge_mid - side * width * 0.5
			tomb.grille(Vector3(g0.x, 0.0, g0.y), Vector3(g1.x, 0.0, g1.y))
		var steps := EXIT_STEPS
		var foot := end - u * EXIT_RUN * steps
		m.stairs(Vector3(foot.x, -EXIT_RISE * steps, foot.y), u, width, steps, EXIT_RISE, EXIT_RUN)
		if in_wall(i):
			door_arch(edge_mid, u, width)
		else:
			for sd: float in [-1.0, 1.0]:
				var c := (edge_mid + end) * 0.5 - u * EXIT_RUN * steps * 0.5 + side * sd * (width * 0.5 + EXIT_CHEEK.x * 0.5)
				var along := depth + EXIT_RUN * steps
				var yaw := atan2(u.x, u.y)
				m.block(Vector3(c.x, -EXIT_RISE * steps, c.y), Vector3(EXIT_CHEEK.x, EXIT_CHEEK.y + EXIT_RISE * steps, along), yaw, mat)
			# the pillars beside the mouth stand off the floor, on the cheeks (art pack 2026-11-17: half of each stood
			# on the walkable floor, stone the paladin walked into; tools/fit_probe.gd)
			var off := edge_mid - u * DOOR_POST_OUT
			var post_side := off + side * (width * 0.5 + DOOR_POST_OUT)
			m.post(Vector3(post_side.x, 0.0, post_side.y), 0.0, 0.9, mat)
			var lamp_side := off - side * (width * 0.5 + DOOR_POST_OUT)
			if used and not _bowl_near(edge_mid, 3.0):
				tomb.lantern(Vector3(lamp_side.x, 0.0, lamp_side.y), atan2(u.x, u.y), mat, door_lamp(), ~Arena.CROWD_LAYER)
			else:
				m.post(Vector3(lamp_side.x, 0.0, lamp_side.y), 0.0, 0.9, mat)
		if not used:
			continue
		var l := OmniLight3D.new()
		l.position = Vector3(end.x, 2.6, end.y) + Vector3(u.x, 0.0, u.y) * 0.6
		l.light_color = Color(0.5, 0.45, 0.6)
		l.light_energy = DOOR_DIM
		l.omni_range = 7.0
		l.light_cull_mask = ~Arena.CROWD_LAYER
		add_child(l)
		arena._exit_lights.append(l)


## The pointed arch of a door in a wall over its opening (spec 0.4): voussoirs over two jambs, its foot `edge_mid` (the
## middle of the opening on the floor's edge), facing `inward`, the opening `width` wide (at least WALL_DOOR.x) and
## WALL_DOOR.y high; the jambs JAMB thick, set back `back` meters out of the room (in the wall's thickness).
func door_arch(edge_mid: Vector2, inward: Vector2, width: float, back := 0.5, height := WALL_DOOR.y) -> void:
	var mat := ashlar()
	var o := edge_mid - inward * back
	var foot := Vector3(o.x, 0.0, o.y)
	var w := maxf(WALL_DOOR.x, width + 0.4)
	var spring := height - w * 0.55
	for sd: float in [-1.0, 1.0]:
		var side := Vector2(-inward.y, inward.x) * sd * (w * 0.5 + JAMB * 0.5)
		m.block(foot + Vector3(side.x, 0.0, side.y), Vector3(JAMB, spring, 0.9), atan2(inward.x, inward.y), mat)
	m.voussoir_arch(foot, inward, w, spring, 0.5, 0.9, mat)


## True when a fire bowl of the layout stands within `reach` of p.
func _bowl_near(p: Vector2, reach: float) -> bool:
	for o in layout.obstacles:
		if o.piece == &"brazier" and o.center.distance_to(p) <= reach:
			return true
	return false


## The arena's own light (by default nothing more: its fires and lanterns light it).
func _light() -> void:
	pass


## A soft light high over the middle of the floor, no shadow (the hall's key, dimmer and of the arena's colour): it
## keeps the floor between the pools of fire at the value the fight reads on (spec 0.5).
func key_light(color: Color, energy: float, height := CatacombHall.KEY_HEIGHT) -> OmniLight3D:
	var b := arena.shape().bounds()
	var c := b.get_center()
	var key := OmniLight3D.new()
	key.position = Vector3(c.x, height, c.y)
	key.light_color = color
	key.light_energy = energy
	key.omni_range = maxf(CatacombHall.KEY_RANGE, b.size.length() * 0.6)
	key.omni_attenuation = 1.0
	key.light_cull_mask = ArenaKit.WARM_MASK
	add_child(key)
	return key


## C18 (ART P1-2, ENV P1-5): a soft fill from the camera's side, high and without shadow, so the far walls (north
## and west) read in the fight's frame instead of a black band: WALL_FILL.x of the room's diagonal out toward the camera,
## WALL_FILL.y up, its reach WALL_FILL.z diagonals. Never on the crowd.
const WALL_FILL := Vector3(0.45, 9.0, 1.1)


func wall_fill(color: Color, energy: float) -> OmniLight3D:
	var b := arena.shape().bounds()
	var yaw := deg_to_rad(Feel.live().cam_yaw)
	var out := Vector2(sin(yaw), cos(yaw)) * b.size.length() * WALL_FILL.x
	var l := OmniLight3D.new()
	l.position = Vector3(b.get_center().x + out.x, WALL_FILL.y, b.get_center().y + out.y)
	l.light_color = color
	l.light_energy = energy
	l.omni_range = b.size.length() * WALL_FILL.z
	l.omni_attenuation = 0.6
	l.shadow_enabled = false
	l.light_cull_mask = ~Arena.CROWD_LAYER
	add_child(l)
	return l


## How many lights cast shadows (spec 0.5: at most 8 an arena; arena_lab prints it).
func _count_shadows() -> int:
	var n := 0
	for l in find_children("*", "Light3D", true, false):
		if (l as Light3D).shadow_enabled:
			n += 1
	return n


# ---------- the air ----------

## The world's air as it was before an arena dressed it, the environment and the moon, and the room that dressed it
## last (only that one gives it back).
static var _saved: Dictionary = {}
static var _air_env: Environment
static var _air_moon: DirectionalLight3D
static var _dresser: ArenaRoom


## Puts the world's air back as it was if an arena dressed it (Arena.build calls it before any room is built: the
## old room leaves only after the new one stands).
static func leave_air() -> void:
	if _air_env != null and not _saved.is_empty():
		BossChamber.restore_air(_air_env, _air_moon if is_instance_valid(_air_moon) else null, _saved)
		# the air was saved in the look of that moment: what the visual profile holds goes back to the look in use
		VisualProfile.refresh()
	_saved = {}
	_dresser = null


func _dress_air() -> void:
	var want := air()
	if VisualProfile.stylized() and _style.has(&"air"):
		want = want.merged(_style[&"air"], true)
	if want.is_empty() or not is_inside_tree():
		return
	var e := get_world_3d().environment
	if e == null:
		for n in get_tree().root.find_children("*", "WorldEnvironment", true, false):
			e = (n as WorldEnvironment).environment
	if e == null:
		return
	var moon: DirectionalLight3D = null
	for n in get_tree().root.find_children("*", "DirectionalLight3D", true, false):
		moon = n as DirectionalLight3D
	if _saved.is_empty():
		_air_env = e
		_air_moon = moon
		_saved = BossChamber.air_of(e, moon)
	_dresser = self
	# the world's own energy, the classic one whatever the look it was taken in (VisualProfile scales it for the hall)
	var base_energy: float = VisualProfile.classic_of(e, &"ambient_light_energy", _saved[&"ambient_light_energy"])
	e.background_mode = Environment.BG_COLOR
	e.background_color = want.get(&"sky", e.background_color)
	e.fog_light_color = want.get(&"fog", e.fog_light_color)
	if want.has(&"fog_depth"):
		var fd: Vector2 = want[&"fog_depth"]
		e.fog_depth_begin = fd.x
		e.fog_depth_end = fd.y
	e.ambient_light_color = want.get(&"ambient", e.ambient_light_color)
	# a share of the world's energy (the browser's renderer compensates its own: Game.COMPAT_*)
	e.ambient_light_energy = base_energy * float(want.get(&"ambient_gain", 1.0))
	if moon != null:
		moon.light_color = want.get(&"moon", moon.light_color)
		moon.light_energy = want.get(&"moon_energy", moon.light_energy)
		moon.shadow_enabled = want.get(&"moon_shadow", moon.shadow_enabled)


## The room's air again for the look in use, after the look changed (F7: VisualProfile put the world's values of the
## new look on the environment and the moon; Arena.restyle). Only the room that dressed the air does it.
func redress_air() -> void:
	if _dresser == self:
		# what this room's air leaves alone comes back to the world's (the moon's energy of the look, its shadow)
		if _air_moon != null and is_instance_valid(_air_moon) and _saved.has(&"moon"):
			_air_moon.shadow_enabled = (_saved[&"moon"] as Array)[3]
		# and the world's sky and fog, which no look varies (lot D: the altar's classic air leaves its fog alone)
		if _air_env != null:
			for k: StringName in [&"background_color", &"fog_light_color", &"fog_depth_begin", &"fog_depth_end"]:
				_air_env.set(k, _saved[k])
		_dress_air()


func _exit_tree() -> void:
	if _dresser == self:
		leave_air()
