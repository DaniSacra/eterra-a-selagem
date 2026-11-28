class_name HubBlockout
extends RefCounted
## The Santuário da Vigília's blockout (SV-R, 2026-11-25): the masses of the buildings, the Portão da Aventura and the
## doors, drawn in HubLook's frame on the footprints of HubPlan (BUILDINGS, GATE, DOORS), with the stone the look
## already has (limestone, the warm light from the north-west). Plain on purpose: the environment-artist dresses it
## (materials, props, light, the cascades and the water of the basins). A door is closed when the layout has its
## obstacle (HubPlan.layout(yaw, closed)), open otherwise: a doorway of two jambs and a lintel.
##   HubBlockout.new(look).build(layout)

const PLINTH := Vector2(0.18, 0.35)  # how far it stands out, how high
const CORNICE := Vector2(0.3, 0.28)
const ROOF_LIP := 0.1
const JAMB := Vector3(0.3, 0.3, 0.45)  # width, height over the door, depth
## Round 4: the Portao faces the camera. A low terrace fills the footprint (the layout's solid box is unchanged; only what is
## drawn on it is lower) and on it stands the facade: a wall with a pointed arch of voussoirs (GATE_W wide, springing at
## GATE_SPRING, its ring GATE_RING) over a sheet of light and the violet view, a cornice and a lion over the keystone; the
## banners and the lions are HubFacades'. GATE_FRONT is the facade's south face (v), GATE_DEPTH its thickness, GATE_WALL_U
## its extent in u, GATE_TOP its crest. Hub art 2026-11-27: it stands at the top of the main axis, up the red carpet's flight.
const GATE_RING := 0.38
const GATE_W := 2.4
const GATE_SPRING := 1.5
const GATE_TERRACE := HubPlan.GATE_TERRACE
const GATE_FRONT := HubPlan.GATE_FACE_V
const GATE_DEPTH := 1.4
const GATE_WALL_U := Vector2(-7.5, 5.5)
const GATE_TOP := 5.7
const GATE_CORNICE := 0.3
const GATE_LIGHT_TINT := Color(1.0, 0.76, 0.34)
## Round 5: the sheet (additive) and its lights at this share of the open portal's, so the violet view (mountains, road) shows
## through the opening and the gold stays on the rim.
const GATE_SHEET_DIM := 0.3
## Round 6: its lights (they gild the floor under the arch) at this share, so the floor does not blow out to white.
const GATE_LIGHT_DIM := 0.4
const GATE_DARK := Color(0.02, 0.05, 0.035)
const DOOR_WOOD := Color(0.36, 0.21, 0.11)
## PT28-11: the future rooms' gates are heavy dark leaves of iron-banded stone-grey timber under a stone arch, no padlock (they read as chests).
const GATE_LEAF := Color(0.2, 0.19, 0.2)
const DOOR_IRON := Color(0.09, 0.09, 0.1)
## Hub refine round 1: an open door shows the warm light of the room inside (the art's doors are lit), and the future
## rooms' gates are dark iron-banded leaves (no padlock, PT28-11).
const DOOR_GLOW := Color(1.0, 0.56, 0.22)
const DOOR_GLOW_ENERGY := 0.45  # final pass 2026-11-26: the box face samples only a slice of the gradient, so the doorway read as a flat orange plate; dimmer
## Round 2: the doorway is dark inside with the warm light coming up from the foot (HubLook.lit_opening), the open
## Videira's door is no door at all (its pergola shows through), and the future rooms' doors are stone arches with a
## wooden leaf (a pointed panel) set into the wall. Round 4: the leaf's winding faced away from the camera (culled: the doorway
## showed the black behind it), now fixed in HubFacades.ogive_mesh.
const DOOR_TOP := 0.03
const DOOR_MID := 0.22  # round 5: the gradient's middle (see HubLook.lit_opening)
const DOOR_HEAD := 0.45  # round 6: the dark band under the lintel (height)
const DOOR_REVEAL := 0.14  # the dark reveal strips each side of an open doorway (width)
const ARCH_SPRING := 0.8  # round 4: lower, so the arches in front of the camera do not hide the court
const ARCH_RING := 0.38
const ARCH_ARC := 0.52
var _glow: StandardMaterial3D

var look: HubLook


func _init(owner_look: HubLook) -> void:
	look = owner_look


func build(layout: RoomLayout) -> void:
	for b in HubPlan.BUILDINGS:
		var r: Vector4 = b[&"rect"]
		_building(r, b[&"h"])
	_gate()
	for id: StringName in HubPlan.DOORS:
		_door(id, _is_closed(layout, id))


## True when the layout holds this door's obstacle (the same place).
static func _is_closed(layout: RoomLayout, id: StringName) -> bool:
	var d: Vector4 = HubPlan.DOORS[id]
	for o in layout.obstacles:
		if o.piece == &"hub_door" and HubPlan.to_local(o.center).distance_to(Vector2(d.x, d.y)) < 0.05:
			return true
	return false


## A building's mass: plinth, walls, cornice and a flat roof's lip (u0, v0, u1, v1 and height).
func _building(r: Vector4, h: float) -> void:
	var c := Vector2(r.x + r.z, r.y + r.w) * 0.5
	var size := Vector2(r.z - r.x, r.w - r.y)
	var mat: Material = look.facade_stone()
	look.fm.block(HubLook.at(c.x, 0.0, c.y), Vector3(size.x, h, size.y), 0.0, mat, false)
	look.fm.block(HubLook.at(c.x, 0.0, c.y), Vector3(size.x + PLINTH.x * 2.0, PLINTH.y, size.y + PLINTH.x * 2.0), 0.0, mat, false)
	look.fm.block(HubLook.at(c.x, h - CORNICE.y, c.y), Vector3(size.x + CORNICE.x * 2.0, CORNICE.y, size.y + CORNICE.x * 2.0), 0.0, mat, false)
	look.fm.block(HubLook.at(c.x, h, c.y), Vector3(size.x + CORNICE.x * 2.0 - ROOF_LIP * 2.0, 0.12, size.y + CORNICE.x * 2.0 - ROOF_LIP * 2.0), 0.0, look.stone(), false)


## The opening's apex above its foot (the portal's own proportions, scaled to GATE_W).
static func gate_apex() -> float:
	return GATE_SPRING + (HubLook.PORTAL_H - HubLook.PORTAL_SPRING) * GATE_W / HubLook.PORTAL_W


## The sheet's pointed head: the radius as a share of the width (the same curve as ogive_mesh and voussoir_arch take).
static func gate_arc() -> float:
	var rise := gate_apex() - GATE_SPRING
	return (rise * rise + GATE_W * GATE_W * 0.25) / GATE_W / GATE_W


## The Portão da Aventura, facing the camera: the terrace over the footprint, the facade wall on it, the ring of voussoirs
## round the opening, the cornice, and the sheet of light and its lights (the station's light).
func _gate() -> void:
	var g := HubPlan.GATE
	var mat: Material = look.facade_stone()
	var t := GATE_TERRACE
	var cu := (GATE_WALL_U.x + GATE_WALL_U.y) * 0.5
	var wall_w := GATE_WALL_U.y - GATE_WALL_U.x
	var vc := GATE_FRONT + GATE_DEPTH * 0.5
	look.fm.block(HubLook.at((g.x + g.z) * 0.5, 0.0, (g.y + g.w) * 0.5), Vector3(g.z - g.x, t, g.w - g.y), 0.0, look.stone(), false)
	look.fm.block(HubLook.at((g.x + g.z) * 0.5, t - 0.14, (g.y + g.w) * 0.5), Vector3(g.z - g.x + 0.24, 0.14, g.w - g.y + 0.24), 0.0, mat, false)
	look.fm.block(HubLook.at(cu, t, vc), Vector3(wall_w, GATE_TOP - t, GATE_DEPTH), 0.0, mat, false)
	look.fm.block(HubLook.at(cu, GATE_TOP - GATE_CORNICE, vc), Vector3(wall_w + 0.5, GATE_CORNICE, GATE_DEPTH + 0.4), 0.0, mat, false)
	look.fm.block(HubLook.at(cu, GATE_TOP, vc), Vector3(wall_w + 0.2, 0.14, GATE_DEPTH + 0.1), 0.0, look.stone(), false)
	var inner := look.m.stone(0.0, look.stone_tint() * HubLook.INNER_TINT)
	var half := GATE_W * 0.5
	var foot := HubLook.at(cu, t, GATE_FRONT - 0.1)
	for sd: float in [-1.0, 1.0]:
		look.fm.block(HubLook.at(cu + sd * (half + GATE_RING * 0.5), t, GATE_FRONT - 0.1), Vector3(GATE_RING, GATE_SPRING, 0.35), 0.0, inner, false)
	look.fm.voussoir_arch(foot, Vector2(0.0, 1.0), GATE_W, GATE_SPRING, GATE_RING, 0.35, inner, gate_arc())
	look.fm.block(HubLook.at(cu, t, GATE_FRONT - 0.3), Vector3(GATE_W + 0.9, 0.1, 0.6), 0.0, mat, false)
	var apex := gate_apex()
	look.fk.portal_glow(HubLook.at(cu, t + apex * 0.5, GATE_FRONT - 0.07), 0.0, Vector2(GATE_W, apex), Vector3(GATE_SPRING, GATE_W, gate_arc() * GATE_W))
	look.fk.light_portal(look.fk.portals.size() - 1, true, GATE_LIGHT_TINT)  # Elun's warm gold, never the catacombs' green
	var lights: Array = look.fk.portals[look.fk.portals.size() - 1]
	var sheet := lights[0] as ShaderMaterial
	sheet.set_shader_parameter(&"power", float(sheet.get_shader_parameter(&"power")) * GATE_SHEET_DIM)
	for k in range(1, lights.size()):
		(lights[k] as OmniLight3D).light_energy *= GATE_LIGHT_DIM
	look.station_lights[HubPlan.PORTAL] = lights[1]


## A door on its footprint (HubPlan.DOORS): closed, a leaf of dark wood with iron straps between stone jambs; open,
## the jambs and the lintel and the dark of the doorway.
func _door(id: StringName, closed: bool) -> void:
	var d: Vector4 = HubPlan.DOORS[id]
	var h := HubPlan.DOOR_HEIGHT
	var across_u := d.z >= d.w  # the leaf runs along u (it faces v)
	var long_half := maxf(d.z, d.w)
	var depth := minf(d.z, d.w) * 2.0
	var stone := look.stone()
	var along := Vector2(1.0, 0.0) if across_u else Vector2(0.0, 1.0)
	var c := Vector2(d.x, d.y)
	if id == HubPlan.VINE and not closed:
		return
	if id == HubPlan.FUTURE_A or id == HubPlan.FUTURE_B:
		_arched_door(c, long_half * 2.0)
		return
	for sd: float in [-1.0, 1.0]:
		var p := c + along * sd * (long_half + JAMB.x * 0.5)
		look.fm.block(HubLook.at(p.x, 0.0, p.y), Vector3(JAMB.x if across_u else JAMB.z, h + JAMB.y, JAMB.z if across_u else JAMB.x), 0.0, stone, false)
	var lintel := Vector3(long_half * 2.0 + JAMB.x * 2.0, JAMB.y, JAMB.z) if across_u else Vector3(JAMB.z, JAMB.y, long_half * 2.0 + JAMB.x * 2.0)
	look.fm.block(HubLook.at(c.x, h, c.y), lintel, 0.0, stone, false)
	if closed:
		var leaf := Vector3(long_half * 2.0, h, depth) if across_u else Vector3(depth, h, long_half * 2.0)
		look.fm.block(HubLook.at(c.x, 0.0, c.y), leaf, 0.0, look._plain(DOOR_WOOD, 0.85), false)
		for k in 2:
			var y := h * (0.3 + 0.4 * k)
			var strap := Vector3(long_half * 2.0, 0.1, depth + 0.04) if across_u else Vector3(depth + 0.04, 0.1, long_half * 2.0)
			look.fm.block(HubLook.at(c.x, y, c.y), strap, 0.0, look._plain(DOOR_IRON, 0.6), false)
	else:
		var gap := Vector3(long_half * 2.0, h, 0.04) if across_u else Vector3(0.04, h, long_half * 2.0)
		look._bar(HubLook.at(c.x, h * 0.5, c.y), gap, _door_glow())
		var reveal := look._plain(DOOR_IRON, 0.9)
		for sd: float in [-1.0, 1.0]:
			var rp := c + along * sd * (long_half - DOOR_REVEAL * 0.5)
			var rs := Vector3(DOOR_REVEAL, h, 0.12) if across_u else Vector3(0.12, h, DOOR_REVEAL)
			look._bar(HubLook.at(rp.x, h * 0.5, rp.y), rs, reveal)
		# round 6: the lintel's shadow over the head of the doorway (the opening is not a flat lit plate)
		var head := Vector3(long_half * 2.0 - DOOR_REVEAL * 2.0, DOOR_HEAD, 0.12) if across_u else Vector3(0.12, DOOR_HEAD, long_half * 2.0 - DOOR_REVEAL * 2.0)
		look._bar(HubLook.at(c.x, h - DOOR_HEAD * 0.5, c.y), head, reveal)
		var sill := Vector3(long_half * 2.0, 0.08, 0.5) if across_u else Vector3(0.5, 0.08, long_half * 2.0)
		look.fm.block(HubLook.at(c.x, 0.0, c.y), sill, 0.0, stone, false)


func _door_glow() -> StandardMaterial3D:
	if _glow == null:
		_glow = HubLook.lit_opening(DOOR_GLOW, DOOR_GLOW_ENERGY, DOOR_TOP, DOOR_MID)
		_glow.uv1_scale = Vector3(1.0, 2.0, 1.0)  # a BoxMesh face holds half the atlas height: twice over, each face runs the whole gradient
	return _glow


## A future room's door (closed): a ring of stone voussoirs round a pointed wooden leaf with iron straps, set into the wall
## facing the camera (south).
func _arched_door(c: Vector2, span: float) -> void:
	var h := HubPlan.DOOR_HEIGHT
	var foot := HubLook.at(c.x, 0.0, c.y - 0.1)
	look.fm.voussoir_arch(foot, Vector2(0.0, 1.0), span, ARCH_SPRING, ARCH_RING, 0.5, look.stone(), ARCH_ARC)
	var leaf := MeshInstance3D.new()
	leaf.mesh = HubFacades.ogive_mesh(span, ARCH_SPRING, ARCH_ARC, [], 8)
	leaf.material_override = look._plain(GATE_LEAF, 0.9)
	leaf.position = foot
	look.frame.add_child(leaf)
	for k in 2:
		look._bar(foot + Vector3(0, ARCH_SPRING * (0.4 + 0.45 * k), 0.03), Vector3(span * 0.96, 0.1, 0.04), look._plain(DOOR_IRON, 0.6))
	for sd: float in [-1.0, 1.0]:
		look.fm.block(HubLook.at(c.x + sd * (span * 0.5 + ARCH_RING * 0.5), 0.0, c.y - 0.1), Vector3(ARCH_RING, ARCH_SPRING + 0.1, 0.5), 0.0, look.stone(), false)
