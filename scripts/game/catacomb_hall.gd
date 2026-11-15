class_name CatacombHall
extends RefCounted
## The catacomb hall of Daniel's reference image ("Arena das Catacumbas", 2026-11-14; analysis in
## docs/art/arena_reference.md), rebuilt piece by piece where the picture has them. The positions come from the
## picture itself: its landmarks were cast onto the floor through the game's camera (fov 24, turned 35, 30 above the
## floor), so seen through that camera each piece lands where the painting has it. Seen from the south-east, the room
## is the diamond of the picture:
## - north: a raised dais with a wide flight of steps, the green portal in a gothic facade on the right half of the
##   steps, hooded statues beside it, red banners on its buttresses, pots and crates at the foot of the steps;
## - north-west corner: a pier out in the abyss with a fire bowl and a hooded statue behind it;
## - west: a long balustrade with candles and clay pots, and out in the abyss a giant hooded statue on its tower with
##   a fire bowl at its feet; an arcade and chains in the depths behind;
## - south: a standing stone in the middle of the south edge; west of it a landing, the way in (steps down);
## - east: a standing stone with a fire bowl, and a flight of stairs going down out of the hall (a way on), a fire
##   bowl on a pier north of it;
## - the engraved medallion, a little west of the middle.
## Meters, x east, z south, from the middle of the room. Doors: 0 the portal, 1 the east stairs, 2 the south stairs.

## Half the room (the fight happens inside it, less the Arena margin).
const HALF := Vector2(16.0, 15.0)
const MEDALLION_AT := Vector2(-2.5, 1.0)
const MEDALLION := 7.5
## The dais: its height; the flight of steps up to it (x range on the north edge), its steps and their run.
const DAIS_Y := 1.0
const FLIGHT := Vector2(-3.8, 5.6)
const DAIS_STEPS := 4
const STEP_RUN := 0.6
## The facade: its x range, its front (z), its height; the portal's middle (x) and opening.
const FACADE_X := Vector2(-6.5, 20.0)
const FACADE_Z := -20.0
const FACADE_HEIGHT := 10.5
const PORTAL_X := 2.8
const PORTAL_SIZE := Vector2(3.4, 4.8)
## How deep in the doorway the sheet of light hangs, behind the facade's front.
const PORTAL_DEPTH := 0.7
## The landing west of the south standing stone (the way in): its x range and how far south it reaches; the gap of
## its steps down (x range).
const LANDING := Vector2(-16.0, -3.6)
const LANDING_END := 20.5
const WAY_IN := Vector2(-13.6, -9.6)
const SOUTH_STONE := Vector2(-2.6, 15.3)
## The east standing stone, and the stairs down north of it (door 1: z range of the gap).
const EAST_STONE := Vector2(16.3, 2.1)
const EAST_GAP := Vector2(-5.8, 0.6)
## The south stairs down (door 2, only with three doors): x range of the gap.
const SOUTH_GAP := Vector2(6.4, 10.8)
## The north-west pier (fire bowl, statue) and the giant's pier and tower out to the west.
const NW_PIER := Vector2(-12.4, -18.3)
const GIANT_BOWL := Vector2(-23.0, -4.4)
const GIANT := Vector3(-26.0, -4.4, 7.0)
## Height of the giant's feet (its tower and plinth end just under it): the hood's top lands near the picture's top.
const GIANT_FOOT := -0.4
## The fire bowl's light up the giant's robe (warm only on its hem and hands, the rest stays dark stone).
const GIANT_UPLIGHT := 2.5
const DEPTH := 26.0
## Where the fixed showcase camera looks: the floor point at the middle of the reference image.
const SHOWCASE := Vector3(-2.0, 0, 0)
## Candles: their height and radius ranges (m), the warm halo over a cluster, one warm light per cluster.
const CANDLE_HEIGHT := Vector2(0.3, 0.9)
const CANDLE_RADIUS := Vector2(0.07, 0.11)
const CANDLE_HALO := 0.9
const CANDLE_LIGHT := 1.5
const CANDLE_RANGE := 3.5
const ABYSS_LIGHT := Color(0.55, 0.25, 1.0)
const ABYSS_LIGHT_ENERGY := 5.0
## Width of the two standing stones (thick and blunt, as in the picture).
const OBELISK_SOUTH := 2.2
const OBELISK_EAST := 2.3
## The floor in front of the portal's steps, always wet (x, z rect).
const WET := Rect2(-1.0, -15.0, 9.0, 5.0)
## The portal's rectangle of light: the lintel over it (height), the pointed orders round it (how many; each this much
## wider on each side and higher than the one inside).
const PORTAL_LINTEL := 0.6
## Height of the hooded statues beside the portal.
const PORTAL_STATUE := 5.0
const PORTAL_ORDERS := 2
const PORTAL_ORDER_STEP := Vector2(0.45, 0.3)
const PORTAL_ORDER_STONE := 0.8
## The orders' stone is a little lighter than the wall, so their edges catch the light as in the picture.
const PORTAL_ORDER_TINT := Color(1.35, 1.4, 1.4)
## The lit diamond window over the portal: its size (m, width and height), its middle's height over the opening's
## top, its glow.
const PORTAL_WINDOW := Vector2(1.0, 1.2)
const PORTAL_WINDOW_ABOVE := 1.4
const PORTAL_WINDOW_GLOW := 1.6
## The key light over the hall (the picture's middle of the room is a greyed mauve, its edges dark teal).
const KEY_LIGHT := Color(0.95, 0.82, 0.88)
const KEY_ENERGY := 6.0
const KEY_HEIGHT := 9.0
const KEY_RANGE := 18.0
## Tint of the stone in the depths and of the walls under the platform (dark against the lighter mist).
const FAR_TINT := 0.35
const CLIFF_TINT := 0.9
## Rows of silhouettes in the abyss, across the showcase camera's view: each row's distance from the camera (m), the
## height of its piers' tops (every third one a step higher), their width, meters between two piers; rows reach from
## this share of their distance left of the view's middle to this share right of it. Near rows are low, so their
## capitals and arches read against the mist; far ones are tall and fade into it.
const ROW_DIST: Array[float] = [68.0, 82.0, 98.0]
const ROW_TOPS: Array[float] = [1.0, 0.0, 16.0]
const ROW_WIDTHS: Array[float] = [2.4, 2.0, 1.7]
const ROW_SPANS: Array[float] = [8.5, 7.5, 6.5]
const ROW_STEP := 3.0
const ROW_REACH := Vector2(0.52, 0.14)
## The violet glow cards to the west: their distance from the showcase camera (between the near and middle rows),
## the height of their foot, and where they stand across the view (shares of that distance, left of its middle).
const GLOW_DIST := 76.0
const GLOW_FOOT := -14.0
const GLOW_LATS: Array[float] = [-0.46, -0.32, -0.18]
const GLOW_WEST := 1.5
const GLOW_EAST := 2.6
## The far tower the chains hang from (behind the giant, in the middle of the picture's top).
const TOWER := Vector3(-35.0, 0, -23.0)
const TOWER_TOP := 12.0
const TOWER_WIDTH := 2.6
## The lit window under the near arcade (the picture's lantern): its size and height, its warm glass.
const LANTERN := Vector2(0.8, 1.4)
const LANTERN_Y := -2.4
## Where the wall with the window stands in the near row (share of that row's distance, left of the view's middle).
const LANTERN_LAT := -0.33
const LANTERN_GLASS := Color(1.5, 0.8, 0.28)

var arena: Arena
var kit: ArenaKit
var m: Masonry
var _rng := RandomNumberGenerator.new()


func _init(a: Arena, seed_: int) -> void:
	arena = a
	kit = ArenaKit.new(a, seed_)
	m = kit.masonry
	_rng.seed = seed_


## Builds the hall with this many ways on (0 to 3) and tells the arena where its doors, floor and way in are.
func build(exit_count: int) -> void:
	var a := arena
	a.half = HALF
	a.pillars = []
	a.shafts = []
	# the landing's floor reaches well into the room, so their walkable parts overlap (a body is kept 1.2 m plus its
	# radius from each rectangle's edge)
	a.walk = [Rect2(LANDING.x, HALF.y - 6.0, LANDING.y - LANDING.x, LANDING_END - HALF.y + 6.0)]
	a.start = Vector2((WAY_IN.x + WAY_IN.y) * 0.5, LANDING_END - 2.4)
	a.start_facing = Vector2(1, -1).normalized()
	a.door_pos = Vector2((FLIGHT.x + FLIGHT.y) * 0.5, -HALF.y - 1.5)
	a.showcase = SHOWCASE
	_floor()
	_dais()
	_north_west()
	_west()
	_landing()
	_south(exit_count >= 3)
	_east(exit_count >= 2)
	_depths()
	_doors(exit_count)
	a.pillars.append_array(kit.circles)
	a.boxes.append_array(kit.boxes)


# ---------- the floor, its lip and the cliffs under it ----------

func _floor() -> void:
	kit.wet_zone = WET
	kit.floor_plate(Vector3.ZERO, HALF * 2.0 + Vector2(0.6, 0.6), MEDALLION, MEDALLION_AT)
	kit.abyss(HALF, DEPTH, false)
	_cliff(Rect2(-HALF, HALF * 2.0))
	var key := OmniLight3D.new()
	key.position = Vector3(MEDALLION_AT.x, KEY_HEIGHT, MEDALLION_AT.y)
	key.light_color = KEY_LIGHT
	key.light_energy = KEY_ENERGY
	key.omni_range = KEY_RANGE
	key.omni_attenuation = 1.0
	key.light_cull_mask = ArenaKit.WARM_MASK
	arena.add_child(key)
	# buttresses under the lip on the open sides, so the drop reads as built stone
	for i in 8:
		var t := -HALF.y + 2.0 + i * 3.8
		m.box(Vector3(-HALF.x - 0.7, -3.5, t), Vector3(1.0, 6.0, 1.4))
		m.box(Vector3(HALF.x + 0.7, -3.5, t), Vector3(1.0, 6.0, 1.4))
		var s := -HALF.x + 2.0 + i * 4.0
		if s > LANDING.y:
			m.box(Vector3(s, -3.5, HALF.y + 0.7), Vector3(1.4, 6.0, 1.0))


## A block of platform: its walls dropping into the abyss under a floor (x, z rect), and a thick lip under its edge.
func _cliff(r: Rect2) -> void:
	var c := r.get_center()
	m.layers = ArenaKit.DEPTH_LAYER
	m.box(Vector3(c.x, -DEPTH * 0.5 - 0.05, c.y), Vector3(r.size.x + 0.4, DEPTH, r.size.y + 0.4), 0.0, m.stone(-DEPTH, Color.WHITE * CLIFF_TINT))
	m.layers = 1
	m.box(Vector3(c.x, -0.4, c.y), Vector3(r.size.x + 1.0, 0.7, r.size.y + 1.0))


# ---------- north: the dais and the portal ----------

func _dais() -> void:
	var steps_z := -HALF.y - STEP_RUN * DAIS_STEPS
	var mid := (FLIGHT.x + FLIGHT.y) * 0.5
	# the dais block (its top at DAIS_Y), from the top of the steps back behind the facade
	var back := FACADE_Z - 6.0
	m.block(Vector3((FACADE_X.x + FACADE_X.y) * 0.5, -DEPTH, (steps_z + back) * 0.5), Vector3(FACADE_X.y - FACADE_X.x, DEPTH + DAIS_Y, steps_z - back))
	kit.floor_plate(Vector3((FACADE_X.x + FACADE_X.y) * 0.5, DAIS_Y + 0.01, (steps_z + FACADE_Z) * 0.5), Vector2(FACADE_X.y - FACADE_X.x, steps_z - FACADE_Z))
	# the steps, and the stone cheeks beside them up to the dais' height
	m.stairs(Vector3(mid, 0, -HALF.y), Vector2(0, -1), FLIGHT.y - FLIGHT.x, DAIS_STEPS, DAIS_Y / DAIS_STEPS, STEP_RUN)
	var cheek_z := -HALF.y - STEP_RUN * DAIS_STEPS * 0.5
	m.block(Vector3((FACADE_X.x + FLIGHT.x) * 0.5, -0.4, cheek_z), Vector3(FLIGHT.x - FACADE_X.x, DAIS_Y + 0.4, STEP_RUN * DAIS_STEPS))
	m.block(Vector3((FLIGHT.y + FACADE_X.y) * 0.5, -0.4, cheek_z), Vector3(FACADE_X.y - FLIGHT.y, DAIS_Y + 0.4, STEP_RUN * DAIS_STEPS))
	_facade()
	# the hooded statues beside the portal, lit green by it; small plinths with candles at the top of the steps
	kit.statue(Vector2(PORTAL_X - 4.2, FACADE_Z + 1.2), 0.25, PORTAL_STATUE, DAIS_Y, Color(0.22, 0.3, 0.27), false)
	kit.statue(Vector2(PORTAL_X + 4.4, FACADE_Z + 1.2), -0.25, PORTAL_STATUE, DAIS_Y, Color(0.22, 0.3, 0.27), false)
	for px: float in [PORTAL_X - 2.2, PORTAL_X + 2.5]:
		m.block(Vector3(px, DAIS_Y, steps_z - 0.8), Vector3(0.8, 0.9, 0.8))
		_candles(Vector3(px, DAIS_Y + 0.9, steps_z - 0.8), 2, false)
	# pots, crates and candles at the east foot of the steps
	var foot := Vector3(FLIGHT.y + 1.6, 0, -HALF.y + 1.0)
	kit.piece("box_small", foot, 0.3, Vector3.ONE * 0.9)
	kit.piece("box_small", foot + Vector3(0.1, 0.75, 0), 0.1, Vector3.ONE * 0.7)
	kit.piece("box_small", foot + Vector3(1.1, 0, 0.2), -0.2, Vector3.ONE * 0.8)
	m.pot(foot + Vector3(-1.0, 0, -0.1), 1.0)
	m.pot(foot + Vector3(-0.5, 0, 0.6), 0.8)
	_candles(foot + Vector3(-1.7, 0, 0.3), 3)
	arena.boxes.append(Rect2(foot.x - 1.4, -HALF.y - 0.5, 3.4, 2.2))


## The gothic facade with the portal in it: a thick wall, a rectangular opening under a lintel with pointed orders
## round it and a lit diamond window between, buttresses with red banners, the green sheet of light deep in the doorway.
func _facade() -> void:
	var y := DAIS_Y
	var w := PORTAL_SIZE.x
	var h := PORTAL_SIZE.y
	var back := FACADE_Z - 1.6
	var mat := m.stone(y)
	# the wall, with the opening left free (left, right, above)
	var left := Vector2(FACADE_X.x, PORTAL_X - w * 0.5 - 1.2)
	var right := Vector2(PORTAL_X + w * 0.5 + 1.2, FACADE_X.y)
	m.block(Vector3((left.x + left.y) * 0.5, y, back), Vector3(left.y - left.x, FACADE_HEIGHT, 3.2), 0.0, mat)
	m.block(Vector3((right.x + right.y) * 0.5, y, back), Vector3(right.y - right.x, FACADE_HEIGHT, 3.2), 0.0, mat)
	m.block(Vector3(PORTAL_X, y + h, back), Vector3(right.x - left.y, FACADE_HEIGHT - h, 3.2), 0.0, mat)
	# the doorway's depth: dark stone behind the light
	var dark := StandardMaterial3D.new()
	dark.albedo_color = Color(0.02, 0.06, 0.04)
	m.block(Vector3(PORTAL_X, y, back - 1.2), Vector3(w + 2.6, h + 2.4, 0.4), 0.0, dark)
	# the opening is a rectangle of light between thick jambs under a lintel; round it, pointed orders of stones, each
	# wider and farther forward, their points high over the lintel with the lit window in the stone between
	var jamb := (right.x - left.y - w) * 0.5
	for sd: float in [-1.0, 1.0]:
		m.block(Vector3(PORTAL_X + sd * (w + jamb) * 0.5, y, FACADE_Z - 0.9), Vector3(jamb, h, 1.8), 0.0, mat)
	m.block(Vector3(PORTAL_X, y + h, FACADE_Z - 0.9), Vector3(w + jamb * 2.0, PORTAL_LINTEL, 1.8), 0.0, mat)
	var apex := 0.0
	var order := m.stone(y, PORTAL_ORDER_TINT)
	for k in PORTAL_ORDERS:
		var ow := w + PORTAL_ORDER_STEP.x * 2.0 * (k + 1)
		var oh := h + PORTAL_LINTEL + ow * 0.55 + PORTAL_ORDER_STEP.y * k
		apex = oh
		m.pointed_arch(Vector3(PORTAL_X, y, FACADE_Z + 0.4 + k * 0.35), Vector2(0, 1), ow, oh, PORTAL_ORDER_STONE, PORTAL_ORDER_STONE, order)
	m.block(Vector3(PORTAL_X, y + apex + 0.6, FACADE_Z + 0.2), Vector3(w + 4.2, 0.5, 0.8), 0.0, mat)
	kit.portal_glow(Vector3(PORTAL_X, y + h * 0.5, FACADE_Z - PORTAL_DEPTH), 0.0, Vector2(w + 0.4, h + 0.2))
	# the lit diamond window in the stone between the lintel and the points
	var win := MeshInstance3D.new()
	var wq := QuadMesh.new()
	wq.size = Vector2.ONE * PORTAL_WINDOW.x * 0.7071
	win.mesh = wq
	var wm := StandardMaterial3D.new()
	wm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	wm.albedo_color = ArenaKit.PORTAL_SHEET * PORTAL_WINDOW_GLOW
	win.material_override = wm
	var diamond := Basis.from_scale(Vector3(1.0, PORTAL_WINDOW.y / PORTAL_WINDOW.x, 1.0)) * Basis(Vector3.BACK, PI * 0.25)
	win.transform = Transform3D(diamond, Vector3(PORTAL_X, y + h + PORTAL_WINDOW_ABOVE, FACADE_Z + 0.3))
	arena.add_child(win)
	# its light spilling down the steps and over the wet floor in front of them
	var spill := SpotLight3D.new()
	arena.add_child(spill)
	spill.look_at_from_position(Vector3(PORTAL_X, y + h * 0.6, FACADE_Z - 0.5), Vector3(PORTAL_X - 0.5, 0, -HALF.y + 3.0))
	spill.light_color = ArenaKit.PORTAL
	spill.light_energy = 9.0
	spill.spot_range = 14.0
	spill.spot_angle = 40.0
	spill.light_cull_mask = ~Arena.CROWD_LAYER
	# buttresses: piers standing out of the wall with pointed tops, red banners on two of them
	for bx: float in [FACADE_X.x + 0.6, FLIGHT.x + 0.2, PORTAL_X + w * 0.5 + 3.0, 12.6, FACADE_X.y - 1.0]:
		m.block(Vector3(bx, y, FACADE_Z + 0.2), Vector3(1.3, FACADE_HEIGHT - 1.5, 1.4), 0.0, mat)
		m.block(Vector3(bx, y, FACADE_Z + 0.6), Vector3(1.5, 2.2, 1.0), 0.0, mat)
		m.point(Vector3(bx, y + FACADE_HEIGHT - 1.5, FACADE_Z + 0.2), 1.3, 1.2)
	for bx: float in [FLIGHT.x + 0.2, 12.6]:
		kit.piece("banner_thin_red", Vector3(bx, y + 3.4, FACADE_Z + 1.0), 0.0, Vector3(1.6, 2.1, 1.6))
	# pointed windows high on the wall, dark
	for wx: float in [FACADE_X.x + 3.0, 15.6]:
		m.pointed_arch(Vector3(wx, y + 4.2, FACADE_Z + 0.05), Vector2(0, 1), 1.2, 2.6, 0.3, 0.3, mat)


## North-west: the balustrade on the abyss, and out beyond it a pier with a fire bowl and a hooded statue.
func _north_west() -> void:
	var z := -HALF.y + 0.1
	m.balustrade(Vector3(-HALF.x, 0, z), Vector3(FACADE_X.x, 0, z))
	m.block(Vector3(NW_PIER.x, -DEPTH, NW_PIER.y - 1.0), Vector3(3.6, DEPTH, 6.0))
	kit.brazier(NW_PIER, 0.0, false)
	m.block(Vector3(NW_PIER.x, 0, NW_PIER.y - 2.4), Vector3(1.8, 0.6, 1.8))
	kit.statue(Vector2(NW_PIER.x, NW_PIER.y - 2.4), 0.5, 3.8, 0.6, Color(0.2, 0.27, 0.26), false)
	_candles(Vector3(-9.0, 0, z + 0.9), 5)
	m.pot(Vector3(-11.6, 0, z + 0.8), 1.0)
	m.pot(Vector3(-10.9, 0, z + 1.2), 0.8)
	kit.piece("rubble_half", Vector3(FACADE_X.x + 0.8, 0, z + 0.8), 0.4, Vector3.ONE * 0.6)


# ---------- west: the long balustrade and the giant in the abyss ----------

func _west() -> void:
	var x := -HALF.x + 0.1
	m.balustrade(Vector3(x, 0, -HALF.y), Vector3(x, 0, LANDING_END))
	# the giant: a pier out to its fire bowl, a tower of stone out of the depths, the hooded figure on it looking
	# over the hall
	m.block(Vector3((GIANT_BOWL.x + x) * 0.5 - 0.6, -DEPTH, GIANT_BOWL.y), Vector3(x - GIANT_BOWL.x + 1.6, DEPTH, 3.0))
	kit.brazier(GIANT_BOWL, 0.0, false, 5.5)
	var tower_top := GIANT_FOOT - GIANT.z * ArenaKit.STATUE_PLINTH
	m.block(Vector3(GIANT.x, -DEPTH, GIANT.y), Vector3(4.6, DEPTH + tower_top - 0.6, 4.6))
	m.block(Vector3(GIANT.x, tower_top - 0.6, GIANT.y), Vector3(4.0, 0.6, 4.0))
	kit.statue(Vector2(GIANT.x, GIANT.y), PI * 0.5, GIANT.z, tower_top, Color(0.24, 0.24, 0.28), false)
	var up := SpotLight3D.new()
	arena.add_child(up)
	up.look_at_from_position(Vector3(GIANT_BOWL.x + 0.5, 2.0, GIANT_BOWL.y), Vector3(GIANT.x, GIANT_FOOT + GIANT.z * 0.6, GIANT.y))
	up.light_color = ArenaKit.FIRE
	up.light_energy = GIANT_UPLIGHT
	up.spot_range = 9.0
	up.spot_angle = 28.0
	up.light_cull_mask = ~Arena.CROWD_LAYER
	# candles and clay pots along the balustrade (the picture's groups), a small altar of a crate with candles and two
	# pots on it
	kit.piece("box_small", Vector3(x + 1.0, 0, -10.4), 0.2, Vector3(1.3, 0.8, 1.3))
	_candles(Vector3(x + 1.0, 0.8, -10.4), 4, false)
	m.pot(Vector3(x + 1.0, 0, -11.9), 1.0)
	m.pot(Vector3(x + 1.6, 0, -12.5), 0.8)
	_candles(Vector3(x + 1.2, 0, -6.3), 5)
	m.pot(Vector3(x + 0.9, 0, 0.6), 1.05)
	m.pot(Vector3(x + 1.5, 0, 1.3), 0.85)
	_candles(Vector3(x + 1.3, 0, 2.2), 4)
	_candles(Vector3(x + 1.2, 0, 7.1), 6)
	m.pot(Vector3(x + 0.9, 0, 9.4), 0.9)
	_candles(Vector3(x + 0.9, 0, 12.4), 3)


# ---------- south-west: the landing and the way in ----------

func _landing() -> void:
	var r := Rect2(LANDING.x, HALF.y, LANDING.y - LANDING.x, LANDING_END - HALF.y)
	kit.floor_plate(Vector3(r.get_center().x, 0, r.get_center().y + 0.3), r.size + Vector2(0.6, 0.6))
	_cliff(r)
	var z := LANDING_END - 0.1
	m.balustrade(Vector3(LANDING.x, 0, z), Vector3(WAY_IN.x, 0, z))
	m.balustrade(Vector3(WAY_IN.y, 0, z), Vector3(LANDING.y, 0, z))
	m.balustrade(Vector3(LANDING.y - 0.1, 0, HALF.y + 0.8), Vector3(LANDING.y - 0.1, 0, z), false)
	_stairs_down(Vector3((WAY_IN.x + WAY_IN.y) * 0.5, 0, LANDING_END), Vector2(0, 1), WAY_IN.y - WAY_IN.x)
	# the standing stone in the middle of the south edge, where the landing meets the hall
	m.obelisk(Vector3(SOUTH_STONE.x, 0, SOUTH_STONE.y), 5.2, OBELISK_SOUTH, Vector2(1, 1).normalized())
	kit.circles.append(Vector3(SOUTH_STONE.x, SOUTH_STONE.y, OBELISK_SOUTH * 0.68))
	_candles(Vector3(SOUTH_STONE.x + 2.4, 0, HALF.y - 2.0), 7, true, true)
	m.pot(Vector3(SOUTH_STONE.x + 3.6, 0, HALF.y - 0.8), 0.9)
	_candles(Vector3(LANDING.x + 2.4, 0, HALF.y + 0.4), 4)


# ---------- south and east ----------

func _south(stairs_down: bool) -> void:
	var z := HALF.y - 0.1
	var a := Vector3(SOUTH_STONE.x + 1.0, 0, z)
	var b := Vector3(HALF.x, 0, z)
	if not stairs_down:
		m.balustrade(a, b)
		return
	m.balustrade(a, Vector3(SOUTH_GAP.x, 0, z))
	m.balustrade(Vector3(SOUTH_GAP.y, 0, z), b)
	_stairs_down(Vector3((SOUTH_GAP.x + SOUTH_GAP.y) * 0.5, 0, HALF.y), Vector2(0, 1), SOUTH_GAP.y - SOUTH_GAP.x)


func _east(stairs_down: bool) -> void:
	var x := HALF.x - 0.1
	# from the south-east corner up to the standing stone, its fire bowl and clutter on the inside
	m.balustrade(Vector3(x, 0, HALF.y), Vector3(x, 0, EAST_STONE.y + 1.2))
	m.obelisk(Vector3(EAST_STONE.x, 0, EAST_STONE.y), 5.6, OBELISK_EAST, Vector2(-1, 1).normalized())
	kit.circles.append(Vector3(EAST_STONE.x - 0.3, EAST_STONE.y, OBELISK_EAST * 0.62))
	kit.brazier(Vector2(x - 1.7, EAST_STONE.y + 0.6))
	kit.piece("box_small", Vector3(x - 1.9, 0, EAST_STONE.y + 2.6), 0.4, Vector3.ONE * 0.9, 0.7)
	_candles(Vector3(x - 2.4, 0, EAST_STONE.y + 1.8), 4)
	kit.piece("rubble_half", Vector3(x - 2.4, 0, EAST_STONE.y + 4.2), 1.1, Vector3.ONE * 0.55)
	kit.piece("rubble_large", Vector3(x - 1.3, 0, EAST_STONE.y + 4.8), 0.3, Vector3.ONE * 0.5)
	# north of the stone: the stairs down out of the hall (or a plain balustrade), a fire bowl on a pier past them
	if stairs_down:
		m.balustrade(Vector3(x, 0, EAST_STONE.y - 1.0), Vector3(x, 0, EAST_GAP.y))
		_stairs_down(Vector3(HALF.x, 0, (EAST_GAP.x + EAST_GAP.y) * 0.5), Vector2(1, 0), EAST_GAP.y - EAST_GAP.x)
	else:
		m.balustrade(Vector3(x, 0, EAST_STONE.y - 1.0), Vector3(x, 0, EAST_GAP.x))
	var pier := Vector2(HALF.x + 1.0, EAST_GAP.x - 1.2)
	m.block(Vector3(pier.x, -DEPTH, pier.y), Vector3(2.0, DEPTH + 0.5, 2.0))
	kit.brazier(pier, 0.5, false)
	m.balustrade(Vector3(x, 0, EAST_GAP.x - 2.4), Vector3(x, 0, -HALF.y))
	m.pot(Vector3(x - 0.9, 0, -11.0), 0.9)
	_candles(Vector3(x - 0.9, 0, -12.6), 3)


## A flight of stairs going down out of the hall from its edge at `edge`, along `out`, `width` wide, with posts at its
## sides and a landing at the bottom over the abyss.
func _stairs_down(edge: Vector3, out: Vector2, width: float) -> void:
	var o := Vector3(out.x, 0, out.y)
	var steps := 7
	var rise := 0.38
	var run := 0.55
	var bottom := edge + o * (steps * run) + Vector3(0, -steps * rise, 0)
	m.stairs(bottom, -out, width, steps, rise, run)
	var across := out.y != 0.0
	m.box(bottom + o * 2.0 + Vector3(0, -DEPTH * 0.5, 0), Vector3(width if across else 4.0, DEPTH, 4.0 if across else width))
	var side := Vector3(-out.y, 0, out.x)
	for s in [-1.0, 1.0]:
		m.post(edge + side * (width * 0.5 + 0.3) * s)
		m.post(bottom + side * (width * 0.5 + 0.3) * s)


# ---------- the depths ----------

## Far below and around, all in the unlit stone of the depths (dark against the teal mist, each row farther and
## paler): rows of gothic piers and pointed arches to the west, a tower in the north-west the chains hang from,
## arches to the north behind the facade, a lit window under the near arcade, violet light from under the platform.
func _depths() -> void:
	m.layers = ArenaKit.DEPTH_LAYER
	var far := m.depth_stone(Game.FOG)
	# the rows stand across the showcase camera's view (their arches face it), left of the hall and behind it
	var yaw := deg_to_rad(Feel.live().cam_yaw)
	var eye := SHOWCASE + Feel.cam_offset_of(Game.SHOWCASE_DISTANCE, Feel.live().cam_pitch, Feel.live().cam_yaw)
	var ahead := Vector3(-sin(yaw), 0, -cos(yaw))
	var right := Vector3(cos(yaw), 0, -sin(yaw))
	var facing := Vector2(-ahead.x, -ahead.z)
	for k in ROW_DIST.size():
		var d: float = ROW_DIST[k]
		var span: float = ROW_SPANS[k]
		var width: float = ROW_WIDTHS[k]
		var prev := Vector3.INF
		var i := 0
		var lat := -ROW_REACH.x * d
		while lat < ROW_REACH.y * d:
			var p := Vector3(eye.x, 0, eye.z) + ahead * d + right * lat
			lat += span
			i += 1
			# none inside the hall, its dais and the giant's tower
			if (p.x > -HALF.x - 3.0 and p.z > FACADE_Z - 9.0) or Vector2(p.x, p.z).distance_to(Vector2(GIANT.x, GIANT.y)) < 4.5:
				prev = Vector3.INF
				continue
			var top: float = ROW_TOPS[k] + (ROW_STEP * float(i % 3 == 1))
			p.y = top
			_pier(p, width, far, k == ROW_DIST.size() - 1 or i % 2 == 0)
			if prev != Vector3.INF:
				var mid := (prev + p) * 0.5
				var h := span * 0.8
				m.pointed_arch(Vector3(mid.x, minf(prev.y, p.y) - 1.4 - h, mid.z), facing, span - width, h, width * 0.45, width * 0.8, far)
			prev = p
	# a wall under the near arcade, with the lit window of the picture in it
	var wall := Vector3(eye.x, LANTERN_Y, eye.z) + ahead * (ROW_DIST[0] + 1.2) + right * (LANTERN_LAT * ROW_DIST[0])
	m.box(wall + Vector3(0, -6.0, 0), Vector3(2.6, 14.0, 0.8), yaw, far)
	var tower := TOWER
	_pier(tower + Vector3(0, TOWER_TOP, 0), TOWER_WIDTH, far, true)
	for i in 4:
		var x := -10.0 + i * 9.0
		m.box(Vector3(x, -10.0, -40.0), Vector3(2.4, 40.0, 2.4), 0.0, far)
		if i < 3:
			m.pointed_arch(Vector3(x + 4.5, 2.0, -40.0), Vector2(0, 1), 6.6, 8.0, 1.0, 1.8, far)
	m.layers = 1
	_lantern(wall - ahead * 0.45)
	var giant_top := Vector3(GIANT.x, GIANT_FOOT + GIANT.z * 0.95, GIANT.y)
	# the great chains of the picture's top: from the giant across to the far tower and on to the facade, and one
	# from the giant out over the abyss
	kit.chain(giant_top + Vector3(0, -1.0, 0), tower + Vector3(0, 10.0, 0), 2.5, 2.2)
	kit.chain(tower + Vector3(0, 9.0, 0), Vector3(FACADE_X.x + 0.6, DAIS_Y + FACADE_HEIGHT - 2.0, FACADE_Z), 3.0, 2.2)
	kit.chain(giant_top + Vector3(0, -2.0, 0), Vector3(-6.0, 9.0, -26.0), 3.5, 2.2)
	kit.chain(giant_top + Vector3(0, -1.5, 0), Vector3(-40.0, 8.0, 14.0), 4.0, 2.2)
	# violet from far below, only at the sides (west and east of the frame), lighting only the depths
	for p: Vector3 in [Vector3(-HALF.x - 6.0, -12.0, 2.0), Vector3(-HALF.x - 14.0, -12.0, -16.0), Vector3(-28.0, -12.0, 10.0),
			Vector3(HALF.x + 6.0, -12.0, 6.0), Vector3(HALF.x + 6.0, -12.0, -8.0)]:
		var l := OmniLight3D.new()
		l.position = p
		l.light_color = ABYSS_LIGHT
		l.light_energy = ABYSS_LIGHT_ENERGY
		l.omni_range = 22.0
		l.omni_attenuation = 1.1
		l.light_cull_mask = ArenaKit.DEPTH_LAYER
		arena.add_child(l)
	# the glow itself rising out of the mist at the foot of the piers, facing the camera's way, and on desktop a
	# violet fog filling the sides
	# violet behind the near row to the west, so its piers stand dark against it
	for lat: float in GLOW_LATS:
		var g := Vector3(eye.x, GLOW_FOOT, eye.z) + ahead * GLOW_DIST + right * (lat * GLOW_DIST)
		kit.abyss_glow(g, Vector2(18.0, 19.0), yaw, ArenaKit.ABYSS_GLOW_ENERGY * GLOW_WEST)
	for g: Vector3 in [Vector3(HALF.x + 3.0, -9.0, -12.0), Vector3(HALF.x + 4.0, -9.0, -22.0), Vector3(8.0, -8.0, HALF.y + 5.0)]:
		kit.abyss_glow(g, Vector2(16.0, 12.0), yaw, ArenaKit.ABYSS_GLOW_ENERGY * GLOW_EAST)
	kit.abyss_fog(Vector3(-HALF.x - 14.0, -8.0, 0.0), Vector3(24.0, 14.0, 50.0))
	kit.abyss_fog(Vector3(HALF.x + 10.0, -8.0, 0.0), Vector3(16.0, 14.0, 40.0))


## A gothic pier of the depths: its top at `top`, a shaft out of the mist, a wide capital, and a short spire on some.
func _pier(top: Vector3, width: float, mat: Material, spire: bool) -> void:
	m.box(Vector3(top.x, top.y - 20.0, top.z), Vector3(width, 40.0, width), 0.0, mat)
	m.box(Vector3(top.x, top.y - 1.6, top.z), Vector3(width + 0.7, 0.6, width + 0.7), 0.0, mat)
	m.box(Vector3(top.x, top.y + 0.2, top.z), Vector3(width + 0.4, 0.4, width + 0.4), 0.0, mat)
	if spire:
		m.point(Vector3(top.x, top.y + 0.4, top.z), width * 0.9, width * 1.6, 0.0, 0.0, mat)


## The lit window of the abyss (the picture's, under the near arcade): a pointed opening of warm glass and its light.
func _lantern(at: Vector3) -> void:
	var yaw := deg_to_rad(Feel.live().cam_yaw)
	var glass := StandardMaterial3D.new()
	glass.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	glass.albedo_color = LANTERN_GLASS
	var pane := MeshInstance3D.new()
	var q := QuadMesh.new()
	q.size = Vector2(LANTERN.x, LANTERN.y - LANTERN.x * 0.5)
	pane.mesh = q
	pane.material_override = glass
	pane.transform = Transform3D(Basis(Vector3.UP, yaw), at + Vector3(0, q.size.y * 0.5, 0))
	arena.add_child(pane)
	# the pointed head: a square turned on its corner over the pane
	var head := MeshInstance3D.new()
	var hq := QuadMesh.new()
	hq.size = Vector2.ONE * LANTERN.x * 0.7071
	head.mesh = hq
	head.material_override = glass
	head.transform = Transform3D(Basis(Vector3.UP, yaw) * Basis(Vector3.BACK, PI * 0.25), at + Vector3(0, q.size.y, 0))
	arena.add_child(head)
	var l := OmniLight3D.new()
	l.position = at + Basis(Vector3.UP, yaw) * Vector3(0, 0.8, 1.0)
	l.light_color = ArenaKit.FIRE
	l.light_energy = 1.0
	l.omni_range = 4.0
	l.light_cull_mask = ArenaKit.DEPTH_LAYER
	arena.add_child(l)


# ---------- doors ----------

## Where each way on is: the spot in front of it on the floor (Arena.exits), the way into the room from it, and the
## zone that leaves the room when stepped in.
func _doors(count: int) -> void:
	var a := arena
	var inner := HALF - Vector2(1.2, 1.2)
	var mid := (FLIGHT.x + FLIGHT.y) * 0.5
	var spots: Array[Vector2] = [Vector2(mid, -inner.y + 0.6), Vector2(inner.x - 0.6, (EAST_GAP.x + EAST_GAP.y) * 0.5),
		Vector2((SOUTH_GAP.x + SOUTH_GAP.y) * 0.5, inner.y - 0.6)]
	var inward: Array[Vector2] = [Vector2(0, 1), Vector2(-1, 0), Vector2(0, -1)]
	var zones: Array[Rect2] = [Rect2(FLIGHT.x + 0.6, -HALF.y - 2.0, FLIGHT.y - FLIGHT.x - 1.2, 4.4),
		Rect2(inner.x - 1.0, EAST_GAP.x + 0.4, 4.0, EAST_GAP.y - EAST_GAP.x - 0.8),
		Rect2(SOUTH_GAP.x + 0.4, inner.y - 1.0, SOUTH_GAP.y - SOUTH_GAP.x - 0.8, 4.0)]
	for i in mini(count, 3):
		a.exits.append(spots[i])
		a.exit_inward.append(inward[i])
		a.exit_zones.append(zones[i])


# ---------- candles ----------

## A cluster of thick candles of varied heights on the floor (or on top of something at `at`), a warm halo over them
## and one warm light unless light is false. tall: the cluster's candles are the taller ones (the south stone's).
func _candles(at: Vector3, count: int, light := true, tall := false) -> void:
	var spread := 0.35 + count * 0.07
	for i in count:
		var p := at + Vector3(_rng.randf_range(-spread, spread), 0, _rng.randf_range(-spread, spread))
		var h := _rng.randf_range(CANDLE_HEIGHT.x if not tall else (CANDLE_HEIGHT.x + CANDLE_HEIGHT.y) * 0.5, CANDLE_HEIGHT.y)
		m.candle(p, h, _rng.randf_range(CANDLE_RADIUS.x, CANDLE_RADIUS.y))
	var glow := MeshInstance3D.new()
	glow.mesh = Fx.quad(CANDLE_HALO, Color(0.8, 0.45, 0.18))
	glow.position = at + Vector3(0, CANDLE_HEIGHT.y * 0.8, 0)
	glow.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	arena.add_child(glow)
	if not light:
		return
	var l := OmniLight3D.new()
	l.position = at + Vector3(0, 0.9, 0)
	l.light_color = Color(1.0, 0.7, 0.4)
	l.light_energy = CANDLE_LIGHT
	l.omni_range = CANDLE_RANGE
	l.light_cull_mask = ~Arena.CROWD_LAYER
	arena.add_child(l)
