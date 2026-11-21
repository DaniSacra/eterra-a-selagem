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

enum Kind { PLATE, PUSH, ARMS, SLIT, CHAIN, COLUMN }

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
## top) m up the side facing the camera; the drums on the floor at most DRUM_TOP m high, DRUM_VALUE of the stone,
## sinking DRUM_SINK m over DRUM_SINK_TIME s; the stump's teeth.
const COLUMN_CRACK := Vector3(0.15, 1.35, 2.6)
const COLUMN_CRACK_LIGHT := 0.4
const DRUM_TOP := 0.45
const DRUM_VALUE := 0.8
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
static func slit(parent: Node3D, o: ArenaObstacle, stone: Material, out: Vector2) -> HazardPiece:
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
	hp._show()
	return hp


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
	if kind in [Kind.PLATE, Kind.PUSH, Kind.ARMS]:
		if s.x > 0.0:
			sink = minf(1.0, s.x * warn / SINK_TIME)
		elif s.y > 0.0:
			sink = 1.0
		elif spent > 0.0:
			sink = SPENT_SINK * clampf(spent / SPENT_BACK, 0.0, 1.0)
	for m in _marks:
		m.set_shader_parameter(&"sink", sink)
		m.set_shader_parameter(&"dust", 1.0 if asleep else 0.0)
	_show()


func _process(dt: float) -> void:
	_time += dt
	if not _asleep and _arm <= 0.0 and _strike <= 0.0:
		var breath := EMBER_BREATH * sin(_time * TAU / EMBER_PERIOD) if _ember <= EMBER_REST + 0.001 else 0.0
		for m in _cracks:
			m.set_shader_parameter(&"ember", _ember + breath)
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
func _flat_mark(size: Vector2, params: Dictionary) -> ShaderMaterial:
	var mi := MeshInstance3D.new()
	var q := QuadMesh.new()
	q.size = size
	mi.mesh = q
	mi.transform = Transform3D(Basis(Vector3.RIGHT, -PI * 0.5), Vector3(0, MARK_Y, 0))
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
