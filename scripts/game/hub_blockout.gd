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
const GATE_RING := 0.45
const GATE_SPRING := 2.2
const GATE_W := 3.6
const GATE_H := 5.0
## The walls beside the gate stand low so the block does not fill the screen; only the arch's head (this much wider
## than the opening on each side) rises to HubPlan.GATE_HEIGHT.
const GATE_LIGHT_TINT := Color(1.0, 0.76, 0.34)
const GATE_WALL_H := 3.2
const GATE_HEAD_SIDE := 1.4
const GATE_DARK := Color(0.02, 0.05, 0.035)
const DOOR_WOOD := Color(0.2, 0.12, 0.07)
const DOOR_IRON := Color(0.09, 0.09, 0.1)

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
	var mat := look.ashlar()
	look.fm.block(HubLook.at(c.x, 0.0, c.y), Vector3(size.x, h, size.y), 0.0, mat, false)
	look.fm.block(HubLook.at(c.x, 0.0, c.y), Vector3(size.x + PLINTH.x * 2.0, PLINTH.y, size.y + PLINTH.x * 2.0), 0.0, mat, false)
	look.fm.block(HubLook.at(c.x, h - CORNICE.y, c.y), Vector3(size.x + CORNICE.x * 2.0, CORNICE.y, size.y + CORNICE.x * 2.0), 0.0, mat, false)
	look.fm.block(HubLook.at(c.x, h, c.y), Vector3(size.x + CORNICE.x * 2.0 - ROOF_LIP * 2.0, 0.12, size.y + CORNICE.x * 2.0 - ROOF_LIP * 2.0), 0.0, look.stone(), false)


## The Portão da Aventura: a mass with the opening on its west face (the road comes from the west), the pointed ring of
## voussoirs over the sheet of light, the dark behind, the sheet and its light (the station's light).
func _gate() -> void:
	var g := HubPlan.GATE
	var face := HubPlan.GATE_FACE_U
	var mid := HubPlan.GATE_MID_V
	var mat := look.ashlar()
	var half := GATE_W * 0.5
	# the wall south and north of the opening, the lintel over it, the stone behind
	var head := half + GATE_HEAD_SIDE
	_slab(face, g.z, g.y, mid - head, 0.0, GATE_WALL_H, mat)
	_slab(face, g.z, mid + head, g.w, 0.0, GATE_WALL_H, mat)
	_slab(face, g.z, mid - head, mid - half, 0.0, HubPlan.GATE_HEIGHT, mat)
	_slab(face, g.z, mid + half, mid + head, 0.0, HubPlan.GATE_HEIGHT, mat)
	_slab(face, g.z, mid - half, mid + half, GATE_H, HubPlan.GATE_HEIGHT, mat)
	var inner := look.m.stone(0.0, look.stone_tint() * HubLook.INNER_TINT)
	var facing := Vector2(-1.0, 0.0)
	for sd: float in [-1.0, 1.0]:
		look.fm.block(HubLook.at(face - 0.1, 0.0, mid + sd * (half + GATE_RING * 0.5)), Vector3(0.45, GATE_SPRING, GATE_RING), 0.0, inner, false)
	look.fm.voussoir_arch(HubLook.at(face - 0.1, 0.0, mid), facing, GATE_W, GATE_SPRING, GATE_RING, 0.45, inner, HubLook._portal_arc())
	look.fm.block(HubLook.at(g.x + 4.2, 0.0, mid), Vector3(0.3, GATE_H + 0.3, GATE_W + 0.6), 0.0, look._plain(GATE_DARK, 1.0), false)
	look.fm.block(HubLook.at(face, -0.02, mid), Vector3(4.4, 0.04, GATE_W + 0.2), 0.0, inner, false)
	var r := HubLook._portal_arc() * GATE_W
	look.fk.portal_glow(HubLook.at(g.x + 4.0, GATE_H * 0.5, mid), -PI * 0.5, Vector2(GATE_W, GATE_H), Vector3(GATE_SPRING, GATE_W, r))
	look.fk.light_portal(look.fk.portals.size() - 1, true, GATE_LIGHT_TINT)  # Elun's warm gold, never the catacombs' green
	var lights: Array = look.fk.portals[look.fk.portals.size() - 1]
	look.station_lights[HubPlan.PORTAL] = lights[1]


## A wall block across u (face to back) between v s0 and s1, y0 to y1.
func _slab(face: float, back: float, s0: float, s1: float, y0: float, y1: float, mat: Material) -> void:
	if s1 - s0 < 0.02:
		return
	look.fm.block(HubLook.at((face + back) * 0.5, y0, (s0 + s1) * 0.5), Vector3(absf(back - face), y1 - y0, s1 - s0), 0.0, mat, false)


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
		look.fm.block(HubLook.at(c.x, 0.0, c.y), gap, 0.0, look._plain(GATE_DARK, 1.0), false)
