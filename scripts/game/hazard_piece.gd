class_name HazardPiece
extends Node3D
## A hazard of the room drawn as a piece of the room (SW-G7, docs/art/sw_g7_hazard_grammar.md): the chevron cut in dark
## old gold (the one word of the grammar: "this strikes you") and the fissure holding a low amber ember (awake), opening
## and lighting through the windup, full of pale dust while it sleeps. Only drawing: nothing here collides, warns or
## strikes; the floor's warning (the amber rim and fill) stays Ground's. The room's look builds every piece from the
## layout (ArenaRoom.hazard_piece), the hazard's own node (PlateFloor, BandFloor, ColumnFloor: room-designer) drives it:
##   plates, slit, chain: set_state(PlateHazard.state(i) or the band's, asleep, spent) every frame it changes;
##   column: crack() on the first blow, ArenaRoom.toppled(o, way) when it lands.
## Same piece in both looks (a hazard is play): the stone it is cut in is the room's (painted by paint_look).

enum Kind { PLATE, PUSH, ARMS, SLIT, CHAIN, COLUMN, ROOT, CRYSTAL, URN, DROP, BREATH, PLANT, NICHE, SAG, GRATE }

const MARK := preload("res://assets/shaders/hazard_mark.gdshader")
const FISSURE := preload("res://assets/shaders/hazard_fissure.gdshader")

## The ember (rules 3 and 6): 0.08 of its light awake at rest, breathing EMBER_BREATH over EMBER_PERIOD s; up to
## EMBER_WINDUP through the windup's first 70% and EMBER_PEAK in its last 30%; EMBER_STRIKE in the strike.
const EMBER_REST := 0.08
const EMBER_BREATH := 0.03
const EMBER_PERIOD := 3.0
const EMBER_WINDUP := 0.2
const EMBER_PEAK := 0.6
const EMBER_LATE := 0.7
## The slab (3.1): the dark joint (m), sunk SINK_TIME s into the windup (the 4 cm read by the joint and the shading:
## the floor is one mesh), half sunk (2 cm) while spent, back in the recharge's last SPENT_BACK s.
const JOINT := 0.06
const SINK_TIME := 0.15
const SPENT_SINK := 0.5
const SPENT_BACK := 0.5
const MARK_Y := 0.012
const CRACK_Y := 0.016
const CRACK_WIDTH := 0.12
const CRACK_REST := 0.25
## The slab's two cracks (corner to side, never crossing, never through the middle) and the branches the strike adds,
## in shares of the slab's half size: [from, bend, to].
const CRACKS := [[Vector2(-0.8, -0.82), Vector2(-0.55, -0.1), Vector2(-0.18, 0.86)],
	[Vector2(0.84, -0.7), Vector2(0.42, 0.05), Vector2(0.58, 0.84)]]
const BRANCHES := [[Vector2(-0.55, -0.1), Vector2(-0.82, 0.22)], [Vector2(-0.4, 0.35), Vector2(-0.05, 0.42)],
	[Vector2(0.42, 0.05), Vector2(0.78, 0.12)], [Vector2(0.5, 0.45), Vector2(0.25, 0.62)]]
## Chevrons of a slab pushing (RP-13) or arming a slit (RP-16): three nested, CHEV_OFF m from the middle toward the way.
const CHEV_OFF := 0.7
## The arrow slit (3.2): the block cut in the room's stone over the obstacle's footprint, SLIT_HEIGHT m; its mouth
## (MOUTH: width, height, foot) dark with the iron frame (FRAME bar); three chevrons over it pointing down (out).
const SLIT_HEIGHT := 1.4
const SLIT_PROUD := 0.06
const MOUTH := Vector3(0.18, 0.45, 0.42)
const FRAME := 0.035
const IRON := Color(0.16, 0.16, 0.17)
## The wall trap's block (SR-G, lote 4): a cap slab (CAP: overhang, height) on top carved with three arrows pointing the way
## the blades fly, two dark eye sockets (EYE: size, spacing, height) over the mouth; the blade (BLADE: across, long, thick;
## BLADE_Y m up) flying the whole band over the strike, its trail (up to TRAIL m) lit with the warning red.
const CAP := Vector2(0.1, 0.14)
const EYE := Vector3(0.11, 0.22, 1.12)
const BLADE := Vector3(0.62, 0.05, 0.2)
const BLADE_Y := 0.42
const TRAIL := 1.6
const BLADE_STEEL := Color(0.78, 0.8, 0.84)
const BLADE_GLOW := Color(1.0, 0.45, 0.3)
## The bridge's chain (3.3, the post's shape a proposal): the iron post off the deck on the side away from the camera
## POST_OUT m beyond the band, POST_HEIGHT m, its arm ARM m toward the deck; the pendulum PENDULUM m to the weight's
## middle. Rest: hanging off the deck, REST_SWAY degrees; windup: drawn back out BACK degrees in BACK_TIME s, held with
## HOLD_SHAKE; strike: swinging through to THROUGH degrees over the deck, low; after: damped to rest in about 2 s.
const POST_OUT := 1.2
const POST_HEIGHT := 3.6
const POST_RADIUS := 0.11
const ARM := 0.6
const PENDULUM := 3.35
const REST_SWAY := 2.0
const BACK := 35.0
const BACK_TIME := 0.3
const HOLD_SHAKE := 1.0
const THROUGH := 62.0
const SETTLE_PERIOD := 1.4
const SETTLE_DECAY := 2.2
const WEIGHT := Vector2(0.3, 0.7)
const LINK := 0.13
const LINK_PITCH := 0.27
## The toppling column (3.6, the hero's tool: a fissure and no chevron): the crack COLUMN_CRACK (from, rest top, cracked
## top) m up the side facing the camera; the drums on the floor at most DRUM_TOP m high, the room's stone,
## sinking DRUM_SINK m over DRUM_SINK_TIME s; the stump's teeth.
const COLUMN_CRACK := Vector3(0.15, 1.35, 2.6)
const COLUMN_CRACK_LIGHT := 0.4
const DRUM_TOP := 0.45
const DRUM_SINK := 0.2
const DRUM_SINK_TIME := 4.0
const STUMP_TEETH := Vector2i(3, 5)

var kind := Kind.PLATE
## The hazard's windup in seconds (PlateHazard.def.warn), to time the slab's sinking and the weight's drawing back.
var warn := 1.0
var _marks: Array[ShaderMaterial] = []
var _cracks: Array[ShaderMaterial] = []
var _branches: Array[MeshInstance3D] = []
var _ember := EMBER_REST
var _asleep := false
var _arm := 0.0
var _strike := 0.0
var _after := 0.0
var _time := 0.0
var _pivot: Node3D
var _swing_axis := Vector3.RIGHT
var _swing := 0.0
var _struck_at := -100.0
## The wall trap's blade (SR-G): its mesh, trail, flight length and where it leaves (the block's face).
var _blade: MeshInstance3D
var _trail: MeshInstance3D
var _flight := 0.0
var _blade_from := 0.0


## A slab of the floor (3.1) over rect r. kind PLATE: four chevrons pointing in; PUSH (the edge that crumbles, RP-13)
## and ARMS (the slab arming a slit, RP-16): three nested pointing `way` (the push, or toward the slit).
static func plate(parent: Node3D, r: Rect2, windup: float, k := Kind.PLATE, way := Vector2.ZERO) -> HazardPiece:
	var hp := HazardPiece.new()
	hp.name = "HazardPlate"
	hp.kind = k
	hp.warn = windup
	parent.add_child(hp)
	hp.position = Vector3(r.get_center().x, 0.0, r.get_center().y)
	var params := {&"joint": JOINT}
	if k == Kind.PLATE:
		params[&"chev_four"] = 1.0
	elif k == Kind.SAG:
		pass  # SR-P2: the slab that gives has no arrows, only the cracks and the dust of its sinking
	else:
		params[&"chev_count"] = 3
		params[&"chev_dir"] = way.normalized()
		params[&"chev_at"] = way.normalized() * CHEV_OFF
	hp._marks.append(hp._flat_mark(r.size, params))
	var h := r.size * 0.5
	var s := 0.0
	for c: Array in CRACKS:
		for j in 2:
			hp._cracks.append(hp._crack((c[j] as Vector2) * h, (c[j + 1] as Vector2) * h, s))
			s += 1.7
	for b: Array in BRANCHES:
		var m := hp._crack((b[0] as Vector2) * h, (b[1] as Vector2) * h, s)
		hp._cracks.append(m)
		hp._branches.append(hp.get_child(hp.get_child_count() - 1) as MeshInstance3D)
		s += 2.3
	for mi in hp._branches:
		mi.visible = false
	hp._show()
	return hp


## The arrow slit (3.2) over obstacle o (piece bolt_slit), its face toward `out` (the floor's side): the block in
## `stone`, the dark mouth lighting from the bottom up, the iron frame, three chevrons over the mouth.
static func slit(parent: Node3D, o: ArenaObstacle, stone: Material, out: Vector2, flight := 0.0) -> HazardPiece:
	var hp := HazardPiece.new()
	hp.name = "HazardSlit"
	hp.kind = Kind.SLIT
	parent.add_child(hp)
	var n := Vector3(out.x, 0.0, out.y).normalized()
	hp.position = Vector3(o.center.x, 0.0, o.center.y)
	hp.basis = Basis(Vector3.UP, atan2(n.x, n.z))
	var w := o.half.x * 2.0 if absf(out.y) > absf(out.x) else o.half.y * 2.0
	var d := o.half.y * 2.0 if absf(out.y) > absf(out.x) else o.half.x * 2.0
	var block := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(w + SLIT_PROUD, SLIT_HEIGHT, d + SLIT_PROUD)
	block.mesh = box
	block.material_override = stone
	block.position = Vector3(0.0, SLIT_HEIGHT * 0.5, 0.0)
	hp.add_child(block)
	var face := d * 0.5 + SLIT_PROUD * 0.5 + 0.004
	# the mouth: a straight dark slot lighting from its foot up
	hp._cracks.append(hp._strip(Vector3(0, MOUTH.z, face), Vector3(0, MOUTH.z + MOUTH.y, face), Vector3(0, 0, 1),
		MOUTH.x, 0.0, {&"ragged": 0.0, &"rest_width": 1.0}))
	var iron := StandardMaterial3D.new()
	iron.albedo_color = IRON
	iron.roughness = 0.55
	iron.metallic = 0.5
	for bar: Array in [[Vector3(0, MOUTH.z - FRAME * 0.5, face), Vector3(MOUTH.x + FRAME * 2.0, FRAME, FRAME)],
			[Vector3(0, MOUTH.z + MOUTH.y + FRAME * 0.5, face), Vector3(MOUTH.x + FRAME * 2.0, FRAME, FRAME)],
			[Vector3(-(MOUTH.x + FRAME) * 0.5, MOUTH.z + MOUTH.y * 0.5, face), Vector3(FRAME, MOUTH.y, FRAME)],
			[Vector3((MOUTH.x + FRAME) * 0.5, MOUTH.z + MOUTH.y * 0.5, face), Vector3(FRAME, MOUTH.y, FRAME)]]:
		var mi := MeshInstance3D.new()
		var b := BoxMesh.new()
		b.size = bar[1]
		mi.mesh = b
		mi.material_override = iron
		mi.position = bar[0]
		hp.add_child(mi)
	# three nested chevrons over the mouth, pointing down and out (where it fires)
	var top := MOUTH.z + MOUTH.y + FRAME
	var mark_h := SLIT_HEIGHT - top - 0.04
	hp._marks.append(hp._face_mark(Vector2(w, mark_h), Vector3(0, top + mark_h * 0.5, face + 0.002), Vector3(0, 0, 1),
		{&"chev_count": 3, &"chev_dir": Vector2(0, 1), &"chev_open": minf(0.4, w * 0.8), &"chev_gap": 0.13}))
	if flight > 0.0:
		hp._trap_dress(w, d, face, stone, flight)
	hp._show()
	return hp


## The wall trap's extras on its slit (SR-G): see CAP, EYE, BLADE. `flight` m is how far the blade flies from the face.
func _trap_dress(w: float, d: float, face: float, stone: Material, flight: float) -> void:
	_flight = flight
	var cap := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(w + CAP.x * 2.0, CAP.y, d + CAP.x * 2.0)
	cap.mesh = box
	var dark := StandardMaterial3D.new()
	dark.albedo_color = Color(0.1, 0.095, 0.1)
	dark.roughness = 1.0
	cap.material_override = stone
	cap.position = Vector3(0, SLIT_HEIGHT + CAP.y * 0.5, 0)
	cap.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(cap)
	# the arrows cut in the cap's top, pointing the blades' way (+z of the piece)
	var m := _flat_mark(Vector2(w, d), {&"joint": 0.0, &"chev_count": 3, &"chev_dir": Vector2(0, 1),
		&"chev_open": minf(0.4, w * 0.7), &"chev_gap": 0.2})
	(get_child(get_child_count() - 1) as Node3D).position = Vector3(0, SLIT_HEIGHT + CAP.y + 0.004, 0)
	_marks.append(m)
	# two eye sockets over the mouth (a skull: the mouth, the eyes)
	for sx in [-1.0, 1.0]:
		var eye := MeshInstance3D.new()
		var b := BoxMesh.new()
		b.size = Vector3(EYE.x, EYE.y, 0.02)
		eye.mesh = b
		eye.material_override = dark
		eye.position = Vector3(sx * EYE.x * 1.0, MOUTH.z + MOUTH.y + EYE.y * 0.9, face + 0.002)
		add_child(eye)
	var steel := StandardMaterial3D.new()
	steel.albedo_color = BLADE_STEEL
	steel.metallic = 0.9
	steel.roughness = 0.25
	steel.emission_enabled = true
	steel.emission = BLADE_GLOW
	steel.emission_energy_multiplier = 0.5
	_blade = MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = BLADE
	_blade.mesh = bm
	_blade.material_override = steel
	_blade.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_blade.visible = false
	add_child(_blade)
	var tr := StandardMaterial3D.new()
	tr.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	tr.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	tr.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	tr.albedo_color = Color(BLADE_GLOW, 0.35)
	_trail = MeshInstance3D.new()
	var tm := BoxMesh.new()
	tm.size = Vector3(BLADE.x * 0.9, 0.02, 1.0)
	_trail.mesh = tm
	_trail.material_override = tr
	_trail.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_blade.add_child(_trail)
	_blade_from = face


## The bridge's chain (3.3) for band r pushing `push`: the post off the floor on the side away from the camera, the
## pendulum hanging off the deck at rest. Nothing collides; the band and its push are BandHazard's.
static func chain(parent: Node3D, r: Rect2, push: Vector2, windup: float, shape: FloorShape) -> HazardPiece:
	var hp := HazardPiece.new()
	hp.name = "HazardChain"
	hp.kind = Kind.CHAIN
	hp.warn = windup
	parent.add_child(hp)
	# across the band, away from the camera (the camera looks from +x+z): the side of the band farther from it
	var along := push.normalized() if push != Vector2.ZERO else Vector2.RIGHT
	var across := Vector2(-along.y, along.x)
	if across.dot(ArenaRoom.toward_camera()) > 0.0:
		across = -across
	var half_across := absf(across.x) * r.size.x * 0.5 + absf(across.y) * r.size.y * 0.5
	var c := r.get_center()
	var post := c + across * (half_across + POST_OUT)
	while shape.contains(post, -0.4):
		post += across * 0.2
	hp.position = Vector3(post.x, 0.0, post.y)
	var iron := StandardMaterial3D.new()
	iron.albedo_color = IRON
	iron.roughness = 0.55
	iron.metallic = 0.5
	hp._cyl(Vector3(0, POST_HEIGHT * 0.5, 0), POST_RADIUS, POST_HEIGHT, Basis(), iron)
	hp._cyl(Vector3(0, 0.12, 0), POST_RADIUS * 2.2, 0.24, Basis(), iron)
	var toward := Vector3(-across.x, 0.0, -across.y)
	hp._cyl(Vector3(0, POST_HEIGHT - 0.05, 0) + toward * ARM * 0.5, POST_RADIUS * 0.7, ARM,
		Basis(toward.cross(Vector3.UP).normalized(), PI * 0.5), iron)
	hp._pivot = Node3D.new()
	hp.add_child(hp._pivot)
	hp._pivot.position = Vector3(0, POST_HEIGHT - 0.1, 0) + toward * ARM
	hp._swing_axis = Vector3(along.x, 0.0, along.y).normalized()
	# the chain's links, every other one turned a quarter, and the weight with its chevrons toward the platform
	var count := int((PENDULUM - WEIGHT.y * 0.5) / LINK_PITCH)
	var torus := TorusMesh.new()
	torus.outer_radius = LINK
	torus.inner_radius = LINK - 0.04
	torus.rings = 8
	torus.ring_segments = 4
	for k in count:
		var mi := MeshInstance3D.new()
		mi.mesh = torus
		mi.material_override = iron
		var b := Basis(Vector3.FORWARD, PI * 0.5).scaled(Vector3(1.0, 1.55, 1.0))
		if k % 2 == 1:
			b = Basis(Vector3.UP, PI * 0.5) * b
		mi.transform = Transform3D(b, Vector3(0, -LINK_PITCH * (k + 0.5), 0))
		mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		hp._pivot.add_child(mi)
	var wy := -PENDULUM
	var weight := MeshInstance3D.new()
	var wc := CylinderMesh.new()
	wc.top_radius = WEIGHT.x * 0.82
	wc.bottom_radius = WEIGHT.x
	wc.height = WEIGHT.y
	wc.radial_segments = 8
	weight.mesh = wc
	weight.material_override = iron
	weight.position = Vector3(0, wy, 0)
	hp._pivot.add_child(weight)
	# the band of the weight holds the ember; the chevrons on both faces along the push
	hp._cracks.append(hp._strip(Vector3(0, wy + 0.05, WEIGHT.x * 0.93), Vector3(0, wy + 0.05, -WEIGHT.x * 0.93),
		Vector3.UP, 0.1, 0.4, {}, hp._pivot))
	var push3 := Vector3(push.x, 0.0, push.y).normalized()
	for side: float in [1.0, -1.0]:
		var nrm := Vector3(across.x, 0.0, across.y) * side
		var fx := Vector3.UP.cross(nrm).normalized()
		hp._marks.append(hp._face_mark(Vector2(WEIGHT.x * 1.6, WEIGHT.y * 0.6), Vector3(0, wy - 0.08, 0) + nrm * (WEIGHT.x * 0.92),
			nrm, {&"chev_count": 3, &"chev_dir": Vector2(signf(push3.dot(fx)), 0.0), &"chev_open": 0.24,
			&"chev_stroke": 0.05, &"chev_gap": 0.1}, hp._pivot))
	hp._show()
	return hp


## The crack up the toppling column o (3.6), on the side facing the camera; the room adds this to ArenaRoom.toppling
## (it leans with the column).
static func column(parent: Node3D, o: ArenaObstacle) -> HazardPiece:
	var hp := HazardPiece.new()
	hp.name = "HazardColumn"
	hp.kind = Kind.COLUMN
	parent.add_child(hp)
	var tc := ArenaRoom.toward_camera()
	var n := Vector3(tc.x, 0.0, tc.y)
	hp.position = Vector3(o.center.x, 0.0, o.center.y) + n * (o.radius + 0.012)
	var length := COLUMN_CRACK.z - COLUMN_CRACK.x
	hp._cracks.append(hp._strip(Vector3(0, COLUMN_CRACK.x, 0), Vector3(0, COLUMN_CRACK.z, 0), n, CRACK_WIDTH, 5.1,
		{&"reach": (COLUMN_CRACK.y - COLUMN_CRACK.x) / length}))
	hp._show()
	return hp


## The fight's first blow on the column: the crack opens and climbs, lit at COLUMN_CRACK_LIGHT, and stays so.
func crack() -> void:
	for m in _cracks:
		m.set_shader_parameter(&"reach", 1.0)
		m.set_shader_parameter(&"open", 1.0)
		m.set_shader_parameter(&"ember", COLUMN_CRACK_LIGHT)


## The hazard's state each frame it changes (PlateHazard.state(i), the band's the same way): s.x the windup 0..1, s.y
## the strike 1..0, s.z the ember 1..0 (ArenaHazard.EMBER); asleep: before HazardDef.from_progress (dust, no ember);
## spent: the seconds of the recharge left after a strike (0 rested): the slab half sunk with the strike's new cracks
## marked, coming back up over the last SPENT_BACK s.
func set_state(s: Vector3, asleep := false, spent := 0.0) -> void:
	if s.y > 0.0 and _strike <= 0.0:
		_struck_at = _time
	_arm = s.x
	_strike = s.y
	_after = spent
	_asleep = asleep
	var hot := 0.0
	if s.x > 0.0:
		hot = lerpf(EMBER_REST, EMBER_WINDUP, minf(1.0, s.x / EMBER_LATE))
		if s.x > EMBER_LATE:
			hot = lerpf(EMBER_WINDUP, EMBER_PEAK, (s.x - EMBER_LATE) / (1.0 - EMBER_LATE))
	elif s.y > 0.0:
		hot = EMBER_PEAK
	elif s.z > 0.0:
		hot = lerpf(EMBER_REST, EMBER_PEAK, s.z)
	if kind == Kind.SLIT:
		hot = GroundLook.piece_light(GroundLook.PIECE_BLADE if _blade != null else GroundLook.PIECE_SLIT, s)
	_ember = hot
	var open := s.x if s.x > 0.0 else 1.0 if s.y > 0.0 else s.z
	for m in _cracks:
		m.set_shader_parameter(&"open", open)
		m.set_shader_parameter(&"dust", 1.0 if asleep else 0.0)
		if kind == Kind.SLIT:
			m.set_shader_parameter(&"lit_to", 1.0 if s.x <= 0.0 else s.x)
	for mi in _branches:
		mi.visible = s.y > 0.0 or spent > SPENT_BACK * 0.5
	var sink := 0.0
	if kind in [Kind.PLATE, Kind.PUSH, Kind.ARMS, Kind.SAG]:
		if s.x > 0.0:
			sink = minf(1.0, s.x * warn / SINK_TIME)
		elif s.y > 0.0:
			sink = 1.0
		elif spent > 0.0:
			sink = SPENT_SINK * clampf(spent / SPENT_BACK, 0.0, 1.0)
	elif kind in [Kind.PLANT, Kind.NICHE] and s.x > 0.0:
		sink = minf(1.0, s.x * warn / SINK_TIME) * 0.5
	for m in _marks:
		m.set_shader_parameter(&"sink", sink)
		m.set_shader_parameter(&"dust", 1.0 if asleep else 0.0)
	_show()
	_on_state(s, spent)


func _process(dt: float) -> void:
	_time += dt
	if not _asleep and _arm <= 0.0 and _strike <= 0.0:
		var breath := EMBER_BREATH * sin(_time * TAU / EMBER_PERIOD) if _ember <= EMBER_REST + 0.001 else 0.0
		for m in _cracks:
			m.set_shader_parameter(&"ember", _ember + breath)
	_animate(dt)
	if _pivot == null:
		return
	var deg := REST_SWAY * sin(_time * TAU / EMBER_PERIOD)
	if _arm > 0.0:
		var t := minf(1.0, _arm * warn / BACK_TIME)
		deg = -BACK * (1.0 - pow(1.0 - t, 3.0))
		if t >= 1.0:
			deg += HOLD_SHAKE * sin(_time * 70.0)
	elif _strike > 0.0:
		deg = lerpf(-BACK, THROUGH, 1.0 - _strike)
	elif _time - _struck_at < 3.0:
		var since := _time - _struck_at
		deg = THROUGH * cos(since * TAU / SETTLE_PERIOD) * exp(-since * SETTLE_DECAY)
	_pivot.basis = Basis(_swing_axis, deg_to_rad(deg))


func _show() -> void:
	for m in _cracks:
		m.set_shader_parameter(&"ember", 0.0 if _asleep else _ember)


## A mark quad flat on the floor over `size`, its material (one per piece).
func _flat_mark(size: Vector2, params: Dictionary, at := Vector2.ZERO, yaw := 0.0) -> ShaderMaterial:
	var mi := MeshInstance3D.new()
	var q := QuadMesh.new()
	q.size = size
	mi.mesh = q
	mi.transform = Transform3D(Basis(Vector3.UP, yaw) * Basis(Vector3.RIGHT, -PI * 0.5), Vector3(at.x, MARK_Y, at.y))
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var m := ShaderMaterial.new()
	m.shader = MARK
	m.set_shader_parameter(&"size", size)
	for k: StringName in params:
		m.set_shader_parameter(k, params[k])
	mi.material_override = m
	add_child(mi)
	return m


## A mark quad on a face (normal n, centre at), size (width, height), under `under` (this piece by default).
func _face_mark(size: Vector2, at: Vector3, n: Vector3, params: Dictionary, under: Node3D = null) -> ShaderMaterial:
	var mi := MeshInstance3D.new()
	var q := QuadMesh.new()
	q.size = size
	mi.mesh = q
	var x := Vector3.UP.cross(n).normalized()
	mi.transform = Transform3D(Basis(x, n.cross(x), n), at)
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var m := ShaderMaterial.new()
	m.shader = MARK
	m.set_shader_parameter(&"size", size)
	for k: StringName in params:
		m.set_shader_parameter(k, params[k])
	mi.material_override = m
	(under if under != null else self).add_child(mi)
	return m


## A crack lying on the floor from a to b (piece-local x, z).
func _crack(a: Vector2, b: Vector2, seed_: float) -> ShaderMaterial:
	return _strip(Vector3(a.x, CRACK_Y, a.y), Vector3(b.x, CRACK_Y, b.y), Vector3.UP, CRACK_WIDTH, seed_, {})


## A fissure strip from a to b, `width` across, facing n, under `under` (this piece by default).
func _strip(a: Vector3, b: Vector3, n: Vector3, width: float, seed_: float, params: Dictionary,
		under: Node3D = null) -> ShaderMaterial:
	var mi := MeshInstance3D.new()
	var q := QuadMesh.new()
	mi.mesh = q
	var x := b - a
	var y := n.cross(x).normalized() * width
	mi.transform = Transform3D(Basis(x, y, n.normalized()), (a + b) * 0.5)
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var m := ShaderMaterial.new()
	m.shader = FISSURE
	m.set_shader_parameter(&"seed", seed_)
	m.set_shader_parameter(&"rest_width", CRACK_REST)
	for k: StringName in params:
		m.set_shader_parameter(k, params[k])
	mi.material_override = m
	(under if under != null else self).add_child(mi)
	return m


func _cyl(at: Vector3, r: float, h: float, b: Basis, mat: Material) -> void:
	var mi := MeshInstance3D.new()
	var c := CylinderMesh.new()
	c.top_radius = r
	c.bottom_radius = r
	c.height = h
	c.radial_segments = 8
	mi.mesh = c
	mi.material_override = mat
	mi.transform = Transform3D(b, at)
	add_child(mi)


## The column that toppled (3.6): its 3 or 4 drums lying along the fall (`way`, `length` m from the foot), sunk to at
## most DRUM_TOP m and a shade darker, settling DRUM_SINK m lower over DRUM_SINK_TIME s; never colliding.
static func drums(parent: Node3D, o: ArenaObstacle, way: Vector2, length: float, mat: Material, seed_: int) -> Node3D:
	var root := Node3D.new()
	root.name = "FallenDrums"
	parent.add_child(root)
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_
	var n := rng.randi_range(3, 4)
	var w := way.normalized()
	var r := minf(o.radius, DRUM_TOP * 0.9)
	var step_ := (length - o.radius) / n
	for k in n:
		var mi := MeshInstance3D.new()
		var c := CylinderMesh.new()
		c.top_radius = r
		c.bottom_radius = r * rng.randf_range(0.92, 1.0)
		c.height = step_ - rng.randf_range(0.1, 0.3)
		c.radial_segments = 10
		mi.mesh = c
		mi.material_override = mat
		var d := o.radius + step_ * (k + 0.5)
		var at := o.center + w * d + Vector2(-w.y, w.x) * rng.randf_range(-0.2, 0.2)
		var axis := Vector3(w.x, 0, w.y).rotated(Vector3.UP, rng.randf_range(-0.25, 0.25))
		var b := Basis(axis.cross(Vector3.UP).normalized(), PI * 0.5).rotated(axis, rng.randf() * TAU)
		mi.transform = Transform3D(b, Vector3(at.x, DRUM_TOP - r, at.y))
		mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		root.add_child(mi)
	var tw := root.create_tween()
	tw.tween_property(root, "position:y", -DRUM_SINK, DRUM_SINK_TIME).set_trans(Tween.TRANS_SINE)
	return root


## The stump the toppled column leaves (3.6): the foot `height` m with 3 to 5 teeth on its broken top and chips round
## it within 1 m. The same footprint as the column's obstacle (ColumnFloor keeps its collision).
static func stump(parent: Node3D, o: ArenaObstacle, height: float, mat: Material, seed_: int) -> Node3D:
	var root := Node3D.new()
	root.name = "ColumnStump"
	parent.add_child(root)
	root.position = Vector3(o.center.x, 0.0, o.center.y)
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_
	var foot := MeshInstance3D.new()
	var c := CylinderMesh.new()
	c.top_radius = o.radius * 0.96
	c.bottom_radius = o.radius
	c.height = height
	c.radial_segments = 12
	foot.mesh = c
	foot.material_override = mat
	foot.position = Vector3(0, height * 0.5, 0)
	root.add_child(foot)
	var teeth := rng.randi_range(STUMP_TEETH.x, STUMP_TEETH.y)
	for k in teeth:
		var a := TAU * (k + rng.randf_range(-0.2, 0.2)) / teeth
		var tooth := MeshInstance3D.new()
		var b := BoxMesh.new()
		var th := rng.randf_range(0.12, 0.38)
		b.size = Vector3(o.radius * 0.7, th, o.radius * 0.45)
		tooth.mesh = b
		tooth.material_override = mat
		tooth.transform = Transform3D(Basis(Vector3.UP, -a).rotated(Vector3(cos(a), 0, sin(a)), rng.randf_range(-0.2, 0.2)),
			Vector3(cos(a), 0, sin(a)) * o.radius * 0.6 + Vector3(0, height + th * 0.5, 0))
		root.add_child(tooth)
	for k in 6:
		var a := rng.randf() * TAU
		var chip := MeshInstance3D.new()
		var b := BoxMesh.new()
		b.size = Vector3.ONE * rng.randf_range(0.08, 0.18)
		chip.mesh = b
		chip.material_override = mat
		chip.transform = Transform3D(Basis(Vector3(rng.randf(), rng.randf(), rng.randf()).normalized(), rng.randf() * TAU),
			Vector3(cos(a), 0, sin(a)) * (o.radius + rng.randf_range(0.15, 1.0)) + Vector3(0, 0.05, 0))
		root.add_child(chip)
	return root


# --- the rest of the grammar (3.4, 3.5, 3.7 to 3.11) ------------------------------------------------------------------

## The dead root (3.4) along strip a to b (from the trunk's face to the tip): the root itself is the StoneTree's (one
## mesh with the tree), so its living mark lies on the floor along it: ROOT_CRACKS fissures in the earth beside its two
## flanks, ROOT_SIDE m out of its line, holding the ember, and a chevron either side near the tip pointing out of the
## line (the push_out). Its windup: the cracks open and light, dust from the flanks; the lash: dust along the strip.
const ROOT_CRACKS := 4
const ROOT_SIDE := 0.62
const ROOT_CRACK_LEN := Vector2(0.8, 1.5)
const ROOT_CHEV_AT := 0.82
## The crystal that discharges (3.9): a prism CRYSTAL_SIZE (bottom radius, height) of dark slate with a dull ivory edge
## on an iron base CRYSTAL_BASE (side, height); three chevrons on the base toward its column of tiles, three notches
## counting the paladin's blows (amber at NOTCH_LIGHT); full, its edge goes amber from the foot up in FULL_RISE s.
const CRYSTAL_SIZE := Vector2(0.34, 2.4)
const CRYSTAL_BASE := Vector2(0.95, 0.34)
## How far the base reaches out of its middle toward the floor (the piece stands with its middle on the wall's face).
const CRYSTAL_DEEP := 0.3
const CRYSTAL_SLATE := Color(0.18, 0.2, 0.24)
const CRYSTAL_EDGE := Color(0.5, 0.48, 0.42)
const CRYSTAL_HOT := Color(1.0, 0.55, 0.2)
const NOTCH_LIGHT := 0.5
const FULL_RISE := 0.3
## The oil urn (3.10): URN_HEIGHT m of darkened bronze with an iron band and one chevron toward its channel, the wick
## twisted on its lid; the windup lights the wick (a small amber flame WICK_FLAME m, under the glow) running down; the
## blast opens it in URN_SHARDS curved pieces that fly out and settle; the oil (set_oil) a dark glossy strip.
const URN_HEIGHT := 0.8
const URN_BRONZE := Color(0.3, 0.22, 0.14)
const WICK_FLAME := 0.15
const URN_SHARDS := 7
const OIL_COLOR := Color(0.15, 0.1, 0.05)
const OIL_WIDTH := 1.1
## The stones of the vault (3.8): a rough block DROP_STONE of the square's side falling from DROP_HEIGHT over the
## warning's last DROP_FALL s (it touches the floor on the strike's frame), the dust column falling from the rent the
## whole warning; after, rubble at most DROP_RUBBLE m high, gone in its last DROP_FADE s.
const DROP_STONE := 0.65
const DROP_HEIGHT := 9.0
const DROP_FALL := 0.15
const DROP_RUBBLE := 0.6
const DROP_FADE := 0.6
const DUST := Color(0.62, 0.6, 0.57)
const DUST_SIZE := 0.14
const DUST_ALPHA := 0.45
## The rift that breathes (3.7): three chevrons cut in the floor BREATH_IN m in from the brink side of each stretch,
## pointing away from it; BREATH_SHEETS sheets of grey-indigo haze along the brink rising to BREATH_HIGH m in the windup
## and torn up to BREATH_GUST m in the gust; no fill, no amber here (it pushes, never hurts).
const BREATH_IN := 0.6
const BREATH_SHEETS := 3
const BREATH_HIGH := 2.0
const BREATH_GUST := 3.0
## The hostile plant (3.5): a cracked slab PLANT_SLAB m with its joint and one chevron toward the strip, a stiff dark
## fan of PLANT_LEAVES blades PLANT_HIGH m on a root bulb; bronze-olive with rust edges; the windup closes the fan in
## PLANT_CLOSE s and holds it shaking; the lash a root running the strip low and back in PLANT_BACK s.
const PLANT_SLAB := 1.3
const PLANT_LEAVES := 6
const PLANT_HIGH := Vector2(0.9, 1.3)
const PLANT_OPEN := 0.6
const PLANT_BLADE := 0.24
## How far round its root the plant's leaves spread (m): it stands that far off the walkable floor.
const PLANT_FOOT := 0.75
const PLANT_SHUT := 0.08
const PLANT_CLOSE := 0.3
const PLANT_BACK := 0.4
const PLANT_LEAF := Color(0.26, 0.26, 0.17)
const PLANT_RUST := Color(0.38, 0.22, 0.12)
## The niche's skeleton (3.11; the figure in it is the technical artist's): the niche NICHE (width, height, depth) in
## the wall at the strip's start, its stone surround, a sill with three chevrons pointing in, the slab of the reach with
## its joint before it, and the bone hand on the sill (bone at BONE value); the windup brings the arm out to the elbow
## (NICHE_OUT m), the grab runs it NICHE_GRAB m low along the floor and closes it, back over NICHE_BACK s.
const NICHE := Vector3(1.2, 2.2, 0.5)
const NICHE_SILL := 0.28
const NICHE_OUT := 0.45
const NICHE_GRAB := 1.5
const NICHE_BACK := 0.8
const BONE := Color(0.43, 0.41, 0.38)

var _parts: Array[Node3D] = []
var _rest: Array[Transform3D] = []
var _flame: MeshInstance3D
var _glow: ShaderMaterial
var _notches: Array[StandardMaterial3D] = []
var _haze: Array[ShaderMaterial] = []
var _oil: MeshInstance3D
var _dust: CPUParticles3D
var _span := Vector2.ZERO
var _way := Vector2.RIGHT
var _blown := false
var _shut := 0.0


## Roots (3.4) along strip a to b.
static func root(parent: Node3D, a: Vector2, b: Vector2, windup: float, seed_: int) -> HazardPiece:
	var hp := HazardPiece.new()
	hp.name = "HazardRoot"
	hp.kind = Kind.ROOT
	hp.warn = windup
	parent.add_child(hp)
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_
	var d := (b - a).normalized()
	var n := Vector2(-d.y, d.x)
	var length := a.distance_to(b)
	for k in ROOT_CRACKS:
		var side := 1.0 if k % 2 == 0 else -1.0
		var l := rng.randf_range(ROOT_CRACK_LEN.x, ROOT_CRACK_LEN.y)
		var t := length * (0.2 + 0.6 * float(k) / ROOT_CRACKS)
		var p := a + d * t + n * side * ROOT_SIDE
		var q := p + d.rotated(rng.randf_range(-0.2, 0.2)) * l
		hp._cracks.append(hp._crack(p, q, rng.randf() * 9.0))
	var tip := a + d * length * ROOT_CHEV_AT
	for side: float in [1.0, -1.0]:
		hp._marks.append(hp._flat_mark(Vector2(1.0, 1.0), {&"chev_count": 1, &"chev_dir": n * side,
			&"chev_at": Vector2.ZERO}, tip + n * side * ROOT_SIDE * 1.4))
	hp._span = Vector2(length, 3.0)
	hp._way = d
	hp._dust = hp._dusting(Vector3(tip.x, 0.1, tip.y), Vector3(length * 0.5, 0.05, 0.6), false)
	hp._show()
	return hp


## The crystal (3.9) with its middle at p on the wall's face, CRYSTAL_DEEP m off the floor's edge, its chevrons toward
## `toward` (the floor, its column of tiles).
static func crystal(parent: Node3D, p: Vector2, toward: Vector2) -> HazardPiece:
	var hp := HazardPiece.new()
	hp.name = "HazardCrystal"
	hp.kind = Kind.CRYSTAL
	parent.add_child(hp)
	hp.position = Vector3(p.x, 0.0, p.y)
	var iron := _iron()
	var t := Vector3(toward.x, 0, toward.y).normalized()
	hp.basis = Basis(Vector3.UP.cross(t).normalized(), Vector3.UP, t)
	# (local: +z toward the floor, the base's front on the floor's edge, its back into the wall)
	var base := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = Vector3(CRYSTAL_BASE.x, CRYSTAL_BASE.y, CRYSTAL_DEEP * 2.0)
	base.mesh = bm
	base.material_override = iron
	base.position = Vector3(0, CRYSTAL_BASE.y * 0.5, 0)
	hp.add_child(base)
	var prism := MeshInstance3D.new()
	var c := CylinderMesh.new()
	c.top_radius = 0.04
	c.bottom_radius = CRYSTAL_SIZE.x
	c.height = CRYSTAL_SIZE.y
	c.radial_segments = 6
	c.rings = 1
	prism.mesh = c
	var m := ShaderMaterial.new()
	m.shader = preload("res://assets/shaders/crystal_edge.gdshader")
	m.set_shader_parameter(&"albedo", CRYSTAL_SLATE)
	m.set_shader_parameter(&"glow", CRYSTAL_EDGE)
	m.set_shader_parameter(&"peak", 0.25)
	prism.material_override = m
	prism.position = Vector3(0, CRYSTAL_BASE.y + CRYSTAL_SIZE.y * 0.5, CRYSTAL_DEEP - CRYSTAL_SIZE.x - 0.02)
	prism.rotation.y = 0.3
	hp.add_child(prism)
	hp._glow = m
	t = Vector3(0, 0, 1)
	var face := t * (CRYSTAL_DEEP + 0.004)
	hp._marks.append(hp._face_mark(Vector2(CRYSTAL_BASE.x * 0.6, CRYSTAL_BASE.y * 0.9), face + Vector3(0, CRYSTAL_BASE.y * 0.5, 0), t,
		{&"chev_count": 3, &"chev_dir": Vector2(0, 1), &"chev_open": 0.16, &"chev_stroke": 0.04, &"chev_gap": 0.07}))
	var side := Vector3.UP.cross(t).normalized()
	for k in 3:
		var notch := MeshInstance3D.new()
		var nb := BoxMesh.new()
		nb.size = Vector3(0.05, 0.03, 0.12)
		notch.mesh = nb
		var nm := StandardMaterial3D.new()
		nm.albedo_color = Color(0.05, 0.045, 0.04)
		nm.emission_enabled = true
		nm.emission = CRYSTAL_HOT
		nm.emission_energy_multiplier = 0.0
		notch.material_override = nm
		notch.position = side * (float(k) - 1.0) * 0.28 + t * (CRYSTAL_DEEP - 0.08) + Vector3(0, CRYSTAL_BASE.y + 0.005, 0)
		hp.add_child(notch)
		hp._notches.append(nm)
	hp._cracks.append(hp._strip(Vector3(0, 0.08, 0) + face - side * 0.35, Vector3(0, 0.1, 0) + face + side * 0.35, t, 0.06, 3.3, {}))
	hp._show()
	return hp


## The crystal's charges (CrystalHazard.charge[i]): one notch lit a blow; full, the edge goes amber from the foot.
func set_charge(n: int, full := false) -> void:
	for k in _notches.size():
		_notches[k].emission_energy_multiplier = NOTCH_LIGHT if k < n else 0.0
	_shut = 1.0 if full else 0.0
	_glow.set_shader_parameter(&"glow", CRYSTAL_HOT if full else CRYSTAL_EDGE)


## The oil urn (3.10) at p, its channel's way `flow` (zero: none).
static func urn(parent: Node3D, p: Vector2, flow: Vector2, windup: float) -> HazardPiece:
	var hp := HazardPiece.new()
	hp.name = "HazardUrn"
	hp.kind = Kind.URN
	hp.warn = windup
	parent.add_child(hp)
	hp.position = Vector3(p.x, 0.0, p.y)
	var bronze := StandardMaterial3D.new()
	bronze.albedo_color = URN_BRONZE
	bronze.metallic = 0.55
	bronze.roughness = 0.5
	var body := MeshInstance3D.new()
	body.mesh = _lathe([Vector2(0.18, 0.0), Vector2(0.3, 0.12), Vector2(0.4, 0.4), Vector2(0.36, 0.6), Vector2(0.2, 0.72),
		Vector2(0.22, 0.78), Vector2(0.0, 0.8)], URN_HEIGHT / 0.8)
	body.material_override = bronze
	hp.add_child(body)
	hp._parts.append(body)
	var band := MeshInstance3D.new()
	var bc := CylinderMesh.new()
	bc.top_radius = 0.385
	bc.bottom_radius = 0.405
	bc.height = 0.07
	bc.radial_segments = 16
	band.mesh = bc
	band.material_override = _iron()
	band.position = Vector3(0, 0.46 * URN_HEIGHT / 0.8, 0)
	hp.add_child(band)
	hp._parts.append(band)
	var w := flow.normalized() if flow != Vector2.ZERO else ArenaRoom.toward_camera()
	var w3 := Vector3(w.x, 0, w.y)
	hp._marks.append(hp._face_mark(Vector2(0.22, 0.2), band.position + w3 * 0.41, w3,
		{&"chev_count": 1, &"chev_dir": Vector2(0, 1), &"chev_open": 0.14, &"chev_stroke": 0.04}))
	hp._parts.append(hp.get_child(hp.get_child_count() - 1))
	var wick := MeshInstance3D.new()
	var wc := CylinderMesh.new()
	wc.top_radius = 0.015
	wc.bottom_radius = 0.025
	wc.height = 0.12
	wick.mesh = wc
	var wm := StandardMaterial3D.new()
	wm.albedo_color = Color(0.08, 0.07, 0.06)
	wick.material_override = wm
	wick.position = Vector3(0, URN_HEIGHT + 0.06, 0)
	hp.add_child(wick)
	hp._parts.append(wick)
	hp._flame = MeshInstance3D.new()
	var fc := CylinderMesh.new()
	fc.top_radius = 0.0
	fc.bottom_radius = 0.04
	fc.height = WICK_FLAME
	hp._flame.mesh = fc
	var fm := StandardMaterial3D.new()
	fm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	fm.albedo_color = Color(0.95, 0.58, 0.22)
	hp._flame.material_override = fm
	hp._flame.visible = false
	hp.add_child(hp._flame)
	hp._way = w
	hp._oil = MeshInstance3D.new()
	var oq := QuadMesh.new()
	oq.size = Vector2(1.0, OIL_WIDTH)
	hp._oil.mesh = oq
	var om := StandardMaterial3D.new()
	om.albedo_color = OIL_COLOR
	om.roughness = 0.15
	om.metallic_specular = 0.8
	hp._oil.material_override = om
	hp._oil.visible = false
	hp._oil.top_level = true
	hp.add_child(hp._oil)
	hp._show()
	return hp


## The oil run `reach` m down its channel (0: none) and how charred it lies (0 fresh, 1 the scorch fading).
func set_oil(reach: float, charred := 0.0) -> void:
	_oil.visible = reach > 0.05
	if not _oil.visible:
		return
	var at := Vector2(position.x, position.z) + _way * reach * 0.5
	_oil.global_transform = Transform3D(Basis(Vector3.UP, -_way.angle()) * Basis(Vector3.RIGHT, -PI * 0.5).scaled(Vector3(reach, 1, 1)),
		Vector3(at.x, CRACK_Y + 0.004, at.y))
	(_oil.material_override as StandardMaterial3D).roughness = lerpf(0.15, 0.95, charred)
	(_oil.material_override as StandardMaterial3D).albedo_color = OIL_COLOR.darkened(0.5 * charred)


## A stone of the vault (3.8) over the square at p (side m), for DropFloor: set_state as a slab (the windup falling, the
## strike landing) and spent the rubble's seconds left (0 frees it).
static func drop(parent: Node3D, p: Vector2, side: float, windup: float, stone: Material, seed_: int) -> HazardPiece:
	var hp := HazardPiece.new()
	hp.name = "HazardDrop"
	hp.kind = Kind.DROP
	hp.warn = windup
	parent.add_child(hp)
	hp.position = Vector3(p.x, 0.0, p.y)
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_
	var holder := Node3D.new()
	hp.add_child(holder)
	for k in 3:
		var mi := MeshInstance3D.new()
		var b := BoxMesh.new()
		var s := side * DROP_STONE * rng.randf_range(0.55, 0.85)
		b.size = Vector3(s, s * rng.randf_range(0.5, 0.8), s * rng.randf_range(0.7, 1.0))
		mi.mesh = b
		mi.material_override = stone
		mi.transform = Transform3D(Basis(Vector3(rng.randf(), rng.randf(), rng.randf()).normalized(), rng.randf_range(-0.4, 0.4)),
			Vector3(rng.randf_range(-0.2, 0.2), b.size.y * 0.45, rng.randf_range(-0.2, 0.2)) * side * 0.5)
		holder.add_child(mi)
	hp._parts.append(holder)
	holder.position.y = DROP_HEIGHT
	holder.visible = false
	hp._dust = hp._dusting(Vector3(0, DROP_HEIGHT * 0.5, 0), Vector3(side * 0.25, DROP_HEIGHT * 0.5, side * 0.25), true)
	hp._show()
	return hp


## The rift's breath (3.7) for band r pushing `push`, the brink on the side opposite the push.
static func breath(parent: Node3D, r: Rect2, push: Vector2, windup: float, seed_: int) -> HazardPiece:
	var hp := HazardPiece.new()
	hp.name = "HazardBreath"
	hp.kind = Kind.BREATH
	hp.warn = windup
	parent.add_child(hp)
	var c := r.get_center()
	var d := push.normalized() if push != Vector2.ZERO else Vector2.UP
	var along := Vector2(-d.y, d.x)
	var depth := absf(d.x) * r.size.x + absf(d.y) * r.size.y
	var length := absf(along.x) * r.size.x + absf(along.y) * r.size.y
	var near := c - d * (depth * 0.5 - BREATH_IN)
	hp._marks.append(hp._flat_mark(Vector2(1.4, 1.4), {&"chev_count": 3, &"chev_dir": d, &"chev_at": Vector2.ZERO,
		&"chev_open": 0.4, &"chev_gap": 0.18}, near))
	var brink := c - d * (depth * 0.5 + 0.3)
	for k in BREATH_SHEETS:
		var mi := MeshInstance3D.new()
		var q := QuadMesh.new()
		q.size = Vector2(length / BREATH_SHEETS * 1.3, BREATH_GUST)
		mi.mesh = q
		var m := ShaderMaterial.new()
		m.shader = preload("res://assets/shaders/hazard_haze.gdshader")
		m.set_shader_parameter(&"seed", float(seed_ + k) * 3.7)
		mi.material_override = m
		var at := brink + along * length * ((float(k) + 0.5) / BREATH_SHEETS - 0.5) - d * 0.2 * k
		var x := Vector3(along.x, 0, along.y)
		mi.transform = Transform3D(Basis(x, Vector3.UP, x.cross(Vector3.UP)), Vector3(at.x, BREATH_GUST * 0.5 - 0.6, at.y))
		mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		hp.add_child(mi)
		hp._haze.append(m)
	hp._show()
	return hp


## SR-P3, the pit grate over rect r: a frame of iron round a dark pit crossed by bars, a grid of spikes standing in it
## (hidden until the grate warns, GRATE_PEEK of their height as it does, full for the strike).
const GRATE_SPIKES := 4
const GRATE_HEIGHT := 0.7
const GRATE_PEEK := 0.25
const GRATE_HOT := Color(0.6, 0.18, 0.08)
const GRATE_STEEL := Color(0.62, 0.64, 0.68)
## C-1 (AD2-12): the frame (width, height; stone a touch under the dark floor's value), the pit's stepped darks (outer to
## inner, never pure black) and how much each step shrinks it, the rusty bars (their square side).
const GRATE_FRAME := 0.2
const GRATE_FRAME_HEIGHT := 0.05
const GRATE_FRAME_STONE := Color(0.12, 0.125, 0.15)
const GRATE_PIT: Array[Color] = [Color(0.075, 0.07, 0.08), Color(0.05, 0.045, 0.055), Color(0.032, 0.03, 0.038)]
const GRATE_PIT_STEP := 0.22
const GRATE_RUST := Color(0.22, 0.11, 0.07)
const GRATE_BAR := 0.09
var _spikes: Array[Node3D] = []
var _grate_mat: StandardMaterial3D


static func grate(parent: Node3D, r: Rect2, windup: float) -> HazardPiece:
	var hp := HazardPiece.new()
	hp.name = "HazardGrate"
	hp.kind = Kind.GRATE
	hp.warn = windup
	parent.add_child(hp)
	hp.position = Vector3(r.get_center().x, 0.0, r.get_center().y)
	# C-1 (AD2-12): a pit that darkens toward its middle (stepped quads, never pure black), a frame of stone in the
	# floor's own value (no white), rusty iron bars with volume
	for k in GRATE_PIT.size():
		var pit := MeshInstance3D.new()
		var q := QuadMesh.new()
		q.size = r.size - Vector2.ONE * (GRATE_FRAME * 2.0 + float(k) * GRATE_PIT_STEP)
		pit.mesh = q
		pit.transform = Transform3D(Basis(Vector3.RIGHT, -PI * 0.5), Vector3(0, MARK_Y + 0.001 * k, 0))
		var dark := StandardMaterial3D.new()
		dark.albedo_color = GRATE_PIT[k]
		dark.roughness = 1.0
		dark.metallic_specular = 0.0
		pit.material_override = dark
		pit.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		hp.add_child(pit)
	var stone := StandardMaterial3D.new()
	stone.albedo_color = GRATE_FRAME_STONE
	stone.roughness = 1.0
	stone.metallic_specular = 0.0
	var iron := StandardMaterial3D.new()
	iron.albedo_color = GRATE_RUST
	iron.roughness = 0.9
	iron.metallic_specular = 0.2
	var f := GRATE_FRAME
	for sx in [-1, 1]:
		hp._grate_box(Vector3(f, GRATE_FRAME_HEIGHT, r.size.y), Vector3(sx * (r.size.x * 0.5 - f * 0.5), GRATE_FRAME_HEIGHT * 0.5, 0), stone)
	for sz in [-1, 1]:
		hp._grate_box(Vector3(r.size.x - f * 2.0, GRATE_FRAME_HEIGHT, f), Vector3(0, GRATE_FRAME_HEIGHT * 0.5, sz * (r.size.y * 0.5 - f * 0.5)), stone)
	for k in 3:
		var t := (float(k) + 1.0) / 4.0 - 0.5
		hp._grate_box(Vector3(GRATE_BAR, GRATE_BAR, r.size.y - f * 2.0), Vector3(t * r.size.x, GRATE_BAR * 0.5 + 0.01, 0), iron)
	hp._grate_mat = StandardMaterial3D.new()
	hp._grate_mat.albedo_color = GRATE_STEEL
	hp._grate_mat.roughness = 0.5
	hp._grate_mat.metallic = 0.5
	hp._grate_mat.emission_enabled = true
	hp._grate_mat.emission = Color.BLACK
	var cone := CylinderMesh.new()
	cone.top_radius = 0.0
	cone.bottom_radius = 0.11
	cone.height = GRATE_HEIGHT
	cone.radial_segments = 6
	cone.rings = 1
	for i in GRATE_SPIKES:
		for j in GRATE_SPIKES:
			var mi := MeshInstance3D.new()
			mi.mesh = cone
			mi.material_override = hp._grate_mat
			var step := (r.size - Vector2(0.9, 0.9)) / float(GRATE_SPIKES - 1)
			var at := Vector2(i, j) * step - (r.size - Vector2(0.9, 0.9)) * 0.5
			mi.position = Vector3(at.x, 0.0, at.y)
			mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			# the cone grows from its foot: the mesh is centred, so it hangs on a pivot at the foot and the pivot scales
			var pivot := Node3D.new()
			pivot.position = mi.position
			mi.position = Vector3(0, GRATE_HEIGHT * 0.5, 0)
			pivot.add_child(mi)
			pivot.visible = false
			hp.add_child(pivot)
			hp._spikes.append(pivot)
	return hp


func _grate_box(size: Vector3, at: Vector3, mat: Material) -> void:
	var mi := MeshInstance3D.new()
	var b := BoxMesh.new()
	b.size = size
	mi.mesh = b
	mi.position = at
	mi.material_override = mat
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(mi)


## The hostile plant (3.5) at strip a to b.
## `back`: how far behind the strip's start the plant itself stands (off the walkable floor: ArenaRoom slides it there),
## its slab staying at the start.
static func plant(parent: Node3D, a: Vector2, b: Vector2, windup: float, seed_: int, back := 0.0) -> HazardPiece:
	var hp := HazardPiece.new()
	hp.name = "HazardPlant"
	hp.kind = Kind.PLANT
	hp.warn = windup
	parent.add_child(hp)
	var d := (b - a).normalized()
	var root_at := a - d * back
	hp.position = Vector3(root_at.x, 0.0, root_at.y)
	hp._way = d
	hp._span = Vector2(root_at.distance_to(b), 0)
	var slab := d * (back + PLANT_SLAB * 0.5)
	hp._marks.append(hp._flat_mark(Vector2.ONE * PLANT_SLAB, {&"joint": JOINT, &"chev_count": 1, &"chev_dir": d,
		&"chev_at": d * PLANT_SLAB * 0.3, &"chev_open": 0.32}, slab))
	hp._cracks.append(hp._crack(slab + Vector2(-0.45, -0.4), slab + Vector2(0.15, 0.48), 4.4))
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_
	var leaf := StandardMaterial3D.new()
	leaf.albedo_color = PLANT_LEAF
	leaf.roughness = 0.8
	var rust := StandardMaterial3D.new()
	rust.albedo_color = PLANT_RUST
	rust.roughness = 0.85
	var bulb := MeshInstance3D.new()
	var sm := SphereMesh.new()
	sm.radius = 0.2
	sm.height = 0.3
	bulb.mesh = sm
	bulb.material_override = rust
	bulb.position = Vector3(0, 0.1, 0)
	hp.add_child(bulb)
	for k in PLANT_LEAVES:
		var pivot := Node3D.new()
		hp.add_child(pivot)
		pivot.position = Vector3(0, 0.12, 0)
		var blade := MeshInstance3D.new()
		var pm := PrismMesh.new()
		var h := rng.randf_range(PLANT_HIGH.x, PLANT_HIGH.y)
		pm.size = Vector3(PLANT_BLADE, h, 0.04)
		blade.mesh = pm
		blade.material_override = leaf if k % 2 == 0 else rust
		blade.position = Vector3(0, h * 0.5, 0)
		pivot.add_child(blade)
		pivot.rotation.y = TAU * k / PLANT_LEAVES + rng.randf_range(-0.2, 0.2)
		hp._parts.append(pivot)
	var lash := MeshInstance3D.new()
	var lc := CylinderMesh.new()
	lc.top_radius = 0.05
	lc.bottom_radius = 0.09
	lc.height = 1.0
	lash.mesh = lc
	lash.material_override = rust
	lash.visible = false
	hp.add_child(lash)
	hp._flame = lash
	hp._show()
	return hp


## The niche's skeleton (3.11) at strip a to b (a the niche in the wall, b the reach's end).
static func niche(parent: Node3D, a: Vector2, b: Vector2, windup: float, stone: Material) -> HazardPiece:
	var hp := HazardPiece.new()
	hp.name = "HazardNiche"
	hp.kind = Kind.NICHE
	hp.warn = windup
	parent.add_child(hp)
	hp.position = Vector3(a.x, 0.0, a.y)
	var d := (b - a).normalized()
	hp._way = d
	var d3 := Vector3(d.x, 0, d.y)
	var side := Vector3.UP.cross(d3).normalized()
	hp.basis = Basis(side, Vector3.UP, -d3).orthonormalized()
	# (local: -z toward the reach, x along the wall)
	var dark := StandardMaterial3D.new()
	dark.albedo_color = Color(0.02, 0.02, 0.025)
	dark.roughness = 1.0
	var back := MeshInstance3D.new()
	var bb := BoxMesh.new()
	bb.size = Vector3(NICHE.x, NICHE.y, 0.04)
	back.mesh = bb
	back.material_override = dark
	back.position = Vector3(0, NICHE.y * 0.5 + NICHE_SILL, 0.02)
	hp.add_child(back)
	for f: Array in [[Vector3(-(NICHE.x + 0.24) * 0.5, (NICHE.y + NICHE_SILL) * 0.5, 0.1), Vector3(0.24, NICHE.y + NICHE_SILL, 0.2)],
			[Vector3((NICHE.x + 0.24) * 0.5, (NICHE.y + NICHE_SILL) * 0.5, 0.1), Vector3(0.24, NICHE.y + NICHE_SILL, 0.2)],
			[Vector3(0, NICHE.y + NICHE_SILL + 0.12, 0.1), Vector3(NICHE.x + 0.48, 0.24, 0.2)],
			[Vector3(0, NICHE_SILL * 0.5, -0.12), Vector3(NICHE.x + 0.1, NICHE_SILL, 0.34)]]:
		var mi := MeshInstance3D.new()
		var fb := BoxMesh.new()
		fb.size = f[1]
		mi.mesh = fb
		mi.material_override = stone
		mi.position = f[0]
		hp.add_child(mi)
	hp._marks.append(hp._face_mark(Vector2(NICHE.x * 0.8, NICHE_SILL * 0.8), Vector3(0, NICHE_SILL * 0.5, -0.29),
		Vector3(0, 0, -1), {&"chev_count": 3, &"chev_dir": Vector2(0, -1), &"chev_open": 0.22, &"chev_stroke": 0.05,
		&"chev_gap": 0.09}))
	var reach := a.distance_to(b)
	var slab := MeshInstance3D.new()
	hp._marks.append(hp._flat_mark(Vector2(reach, reach), {&"joint": JOINT, &"chev_count": 3, &"chev_dir": Vector2(0, 1),
		&"chev_at": Vector2(0, 0.3)}, Vector2(0, -reach * 0.5 - 0.3)))
	slab.free()
	# the bone hand on the sill, its forearm in the dark
	var bone := StandardMaterial3D.new()
	bone.albedo_color = BONE
	bone.roughness = 0.9
	var arm := Node3D.new()
	hp.add_child(arm)
	arm.position = Vector3(0.12, NICHE_SILL + 0.04, -0.05)
	hp._cyl_into(arm, Vector3(0, 0, 0.25), 0.035, 0.5, Basis(Vector3.RIGHT, PI * 0.5), bone)
	var palm := MeshInstance3D.new()
	var pb := BoxMesh.new()
	pb.size = Vector3(0.12, 0.03, 0.1)
	palm.mesh = pb
	palm.material_override = bone
	palm.position = Vector3(0, 0, -0.04)
	arm.add_child(palm)
	for k in 4:
		hp._cyl_into(arm, Vector3(-0.045 + 0.03 * k, -0.03, -0.14), 0.012, 0.12, Basis(Vector3.RIGHT, PI * 0.5 + 0.5), bone)
	hp._parts.append(arm)
	hp._rest.append(arm.transform)
	hp._show()
	return hp


func _cyl_into(under: Node3D, at: Vector3, r: float, h: float, b: Basis, mat: Material) -> void:
	var mi := MeshInstance3D.new()
	var c := CylinderMesh.new()
	c.top_radius = r
	c.bottom_radius = r
	c.height = h
	c.radial_segments = 6
	mi.mesh = c
	mi.material_override = mat
	mi.transform = Transform3D(b, at)
	under.add_child(mi)


## Each kind's own movement on its state (set_state).
func _on_state(s: Vector3, spent: float) -> void:
	match kind:
		Kind.GRATE:
			# SR-P3: tips peeking while it warns, the spikes full up for the strike, sliding back after
			var up := GRATE_PEEK * s.x if s.x > 0.0 else minf(1.0, s.y * 3.0) if s.y > 0.0 else 0.0
			for sp in _spikes:
				sp.visible = up > 0.01
				sp.scale = Vector3(1.0, maxf(up, 0.01), 1.0)
			if _grate_mat != null:
				_grate_mat.emission = GRATE_HOT * (s.x if s.x > 0.0 else 1.0 if s.y > 0.0 else 0.0)
		Kind.ROOT:
			_dust.emitting = s.x > 0.0 or s.y > 0.0
		Kind.CRYSTAL:
			if s.x > 0.0 or s.y > 0.0:
				_glow.set_shader_parameter(&"glow", CRYSTAL_HOT)
			elif _shut <= 0.0:
				_glow.set_shader_parameter(&"glow", CRYSTAL_EDGE.lerp(CRYSTAL_HOT, s.z))
		Kind.URN:
			_flame.visible = s.x > 0.0 and not _blown
			if _flame.visible:
				_flame.position = Vector3(0, URN_HEIGHT + 0.12 - 0.1 * s.x, 0)
			if s.y > 0.0 and not _blown:
				_blow()
		Kind.DROP:
			var holder := _parts[0]
			_dust.emitting = s.x > 0.0
			if s.x > 0.0:
				var left := (1.0 - s.x) * warn
				holder.visible = left < DROP_FALL
				holder.position.y = DROP_HEIGHT * clampf(left / DROP_FALL, 0.0, 1.0)
			elif s.y > 0.0 or spent > 0.0:
				holder.visible = true
				holder.position.y = -0.1 if spent > 0.0 else 0.0
				var fade := clampf(spent / DROP_FADE, 0.0, 1.0) if spent > 0.0 else 1.0
				holder.scale = Vector3(1.0, DROP_RUBBLE / maxf(DROP_STONE, 0.01) * 0.9, 1.0) * maxf(fade, 0.05) \
					if spent > 0.0 else Vector3.ONE
			elif _struck_at > -100.0:
				queue_free()
		Kind.BREATH:
			var rise := 0.0
			var tear := 0.0
			if s.x > 0.0:
				rise = GroundLook.piece_light(GroundLook.PIECE_BREATH, s)
			elif s.y > 0.0:
				rise = GroundLook.piece_light(GroundLook.PIECE_BREATH, s)
				tear = 1.0 - s.y
			elif s.z > 0.0:
				rise = s.z * BREATH_HIGH / BREATH_GUST
			for m in _haze:
				m.set_shader_parameter(&"rise", rise)
				m.set_shader_parameter(&"tear", tear)
			for m in _marks:
				m.set_shader_parameter(&"sink", 0.0)


## The movement between states (_process).
func _animate(_dt: float) -> void:
	if _blade != null:
		_blade.visible = _strike > 0.0
		if _strike > 0.0:
			var run := _flight * (1.0 - _strike)
			var z := _blade_from + BLADE.z * 0.5 + run
			_blade.position = Vector3(0, BLADE_Y, z)
			var tail := minf(run, TRAIL)
			(_trail.mesh as BoxMesh).size.z = maxf(tail, 0.01)
			_trail.position = Vector3(0, 0, -(BLADE.z + tail) * 0.5)
	match kind:
		Kind.PLANT:
			var shut := 0.0
			if _arm > 0.0:
				shut = minf(1.0, _arm * warn / PLANT_CLOSE)
			elif _strike > 0.0:
				shut = 1.0
			elif _time - _struck_at < PLANT_BACK * 2.0:
				shut = 1.0 - clampf((_time - _struck_at) / (PLANT_BACK * 2.0), 0.0, 1.0)
			var tilt := lerpf(PLANT_OPEN, PLANT_SHUT, shut) + 0.05 * sin(_time * TAU / EMBER_PERIOD)
			if shut >= 1.0 and _arm > 0.0:
				tilt += 0.03 * sin(_time * 60.0)
			for p in _parts:
				p.rotation.x = tilt
			var lash := _flame
			var out := 0.0
			if _strike > 0.0:
				out = 1.0 - _strike
			elif _time - _struck_at < PLANT_BACK:
				out = 1.0 - (_time - _struck_at) / PLANT_BACK
			lash.visible = out > 0.01
			if lash.visible:
				var l := _span.x * out
				var w3 := Vector3(_way.x, 0, _way.y)
				lash.transform = Transform3D(Basis(w3.cross(Vector3.UP).normalized(), PI * 0.5).scaled(Vector3(1, l, 1)),
					w3 * l * 0.5 + Vector3(0, 0.08, 0))
		Kind.NICHE:
			var arm := _parts[0]
			var o := 0.0
			if _arm > 0.0:
				o = NICHE_OUT * minf(1.0, _arm * 2.0)
			elif _strike > 0.0:
				o = NICHE_OUT + (NICHE_GRAB - NICHE_OUT) * (1.0 - _strike)
			elif _time - _struck_at < NICHE_BACK:
				o = NICHE_GRAB * (1.0 - (_time - _struck_at) / NICHE_BACK)
			elif not _asleep:
				o = 0.0
			var low := 0.0 if o < NICHE_OUT + 0.01 else -(NICHE_SILL - 0.06) * clampf((o - NICHE_OUT) / 0.3, 0.0, 1.0)
			arm.transform = _rest[0].translated(Vector3(0, low, -o))
			arm.visible = not _asleep or o > 0.0
		Kind.CRYSTAL:
			pass


func _blow() -> void:
	_blown = true
	var shards := MeshInstance3D.new()
	shards.free()
	for p in _parts:
		p.visible = false
	var bronze := StandardMaterial3D.new()
	bronze.albedo_color = URN_BRONZE.darkened(0.3)
	bronze.metallic = 0.5
	bronze.roughness = 0.6
	for k in URN_SHARDS:
		var mi := MeshInstance3D.new()
		var b := BoxMesh.new()
		b.size = Vector3(0.22, 0.03, 0.16)
		mi.mesh = b
		mi.material_override = bronze
		var a := TAU * k / URN_SHARDS
		mi.position = Vector3(0, 0.4, 0)
		add_child(mi)
		var to := Vector3(cos(a), 0, sin(a)) * (0.8 + 0.25 * (k % 3)) + Vector3(0, 0.02, 0)
		var tw := mi.create_tween()
		tw.tween_property(mi, "position", to, 0.35).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		mi.rotation = Vector3(0.3 * k, a, 0.2)


## Dust (no light, grey): falling from above (a column) or rising off the floor.
func _dusting(at: Vector3, box: Vector3, falling: bool) -> CPUParticles3D:
	var p := CPUParticles3D.new()
	p.amount = 12
	p.lifetime = 0.9
	p.emitting = false
	p.emission_shape = CPUParticles3D.EMISSION_SHAPE_BOX
	p.emission_box_extents = box
	p.gravity = Vector3(0, -6.0 if falling else -0.5, 0)
	p.initial_velocity_min = 0.2
	p.initial_velocity_max = 0.6
	p.direction = Vector3.DOWN if falling else Vector3.UP
	p.scale_amount_min = 0.6
	p.scale_amount_max = 1.0
	var q := QuadMesh.new()
	q.size = Vector2.ONE * DUST_SIZE
	var m := StandardMaterial3D.new()
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.billboard_mode = BaseMaterial3D.BILLBOARD_PARTICLES
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	m.albedo_color = Color(DUST.r, DUST.g, DUST.b, DUST_ALPHA)
	var g := GradientTexture2D.new()
	g.fill = GradientTexture2D.FILL_RADIAL
	g.fill_from = Vector2(0.5, 0.5)
	g.fill_to = Vector2(1.0, 0.5)
	var gr := Gradient.new()
	gr.colors = PackedColorArray([Color.WHITE, Color(1, 1, 1, 0)])
	g.gradient = gr
	m.albedo_texture = g
	q.material = m
	p.mesh = q
	p.position = at
	p.top_level = false
	add_child(p)
	return p


static func _iron() -> StandardMaterial3D:
	var iron := StandardMaterial3D.new()
	iron.albedo_color = IRON
	iron.roughness = 0.55
	iron.metallic = 0.5
	return iron


## A turned body from `outline` (radius, height) scaled by `s`.
static func _lathe(outline: Array, s: float) -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var seg := 16
	for i in outline.size() - 1:
		var a: Vector2 = outline[i] * s
		var b: Vector2 = outline[i + 1] * s
		for k in seg:
			var t0 := TAU * k / seg
			var t1 := TAU * (k + 1) / seg
			var p0 := Vector3(cos(t0) * a.x, a.y, sin(t0) * a.x)
			var p1 := Vector3(cos(t1) * a.x, a.y, sin(t1) * a.x)
			var p2 := Vector3(cos(t1) * b.x, b.y, sin(t1) * b.x)
			var p3 := Vector3(cos(t0) * b.x, b.y, sin(t0) * b.x)
			st.add_vertex(p0)
			st.add_vertex(p1)
			st.add_vertex(p2)
			st.add_vertex(p0)
			st.add_vertex(p2)
			st.add_vertex(p3)
	st.generate_normals()
	return st.commit()
