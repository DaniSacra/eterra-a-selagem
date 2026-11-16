class_name StoneTree
extends RefCounted
## The petrified tree of the Jardim das Raízes Mortas (cycle C12, decision D-30: stone made in code, no model; plan in
## docs/art/cycle12_arenas_spec.md 4.4). An old twisted tree turned to stone: a broad trunk of twisted cords leaning
## away from the camera, buttresses where its roots leave it, a fork at 4.5 m into three limbs that split twice or
## three times down to thin twigs (never lower than 4.5 m away from the trunk, never out toward the camera), three
## limbs broken off clean, low roots that cover exactly the collision of the layout's roots (and go on as fine roots
## with no collision), a few clusters of cold crystal at its foot (inside its collision) and veins of the same colour
## up a few grooves. Every piece is a swept section (a ring of points carried along a curved spine), one mesh of
## stone (stone_tree.gdshader, stippled open round the paladin) and one of crystal. No name, no meaning.
## Bearings are in degrees from the north (-z), clockwise (east 90), as in the spec; the camera stands at 145.

const SHADER := preload("res://assets/shaders/stone_tree.gdshader")
## The tree's own visual layer (besides 1): the garden's soft fill from the camera's side lights only it (GardenLook
## TREE_FILL), so its trunk reads a step lighter than the floor round it without lighting the floor.
const LAYER := 32

# ---------- the trunk ----------
## The spine leans this many degrees toward LEAN_BEARING (away from the camera).
const LEAN := 8.0
const LEAN_BEARING := 300.0
## The cords of the bark, the points each one takes round a ring, and how far they turn from the foot to the fork (more
## than a quarter turn: at 40 the twist did not read, ART_REVIEW J-2).
const LOBES := 9
const LOBE_SIDES := 8
const TWIST := 100.0
## How unequal the cords are: a fixed warp of the angle round the trunk (radians; its slope makes some cords up to
## about 35% wider or narrower than others), so they never read as the flutes of a column or the folds of a cloth.
const LOBE_UNEVEN := 0.06
## The trunk's radius at each height (m): 3.5 at the floor (the collision's circle), 2.6 at 1 m, 2.0 at 2.5, 1.7 at the
## fork. The ring under the floor keeps the floor's radius (no gap at the joint).
const TRUNK_PROFILE: Array[Vector2] = [Vector2(-0.3, 3.5), Vector2(0.0, 3.5), Vector2(0.08, 3.36), Vector2(0.2, 3.2),
	Vector2(0.38, 3.03), Vector2(0.6, 2.86), Vector2(0.85, 2.71), Vector2(1.15, 2.56), Vector2(1.5, 2.4), Vector2(1.95, 2.2),
	Vector2(2.5, 2.0), Vector2(3.0, 1.88), Vector2(3.5, 1.8), Vector2(4.0, 1.74), Vector2(4.5, 1.55), Vector2(4.9, 1.05), Vector2(5.2, 0.55)]
## How deep the grooves cut (a share of the radius) at the floor (shallow: the foot stays on its circle) and from
## LOBE_FULL m up.
const FOOT_GROOVE := 0.03
const GROOVE := 0.3
const LOBE_FULL := 0.9
## The fork's height.
const FORK := 4.5
## A buttress where each root leaves: how far it stands out at the floor (m), how wide (degrees), how high it climbs.
const BUTTRESS := 0.55
const BUTTRESS_SPREAD := 6.0
const BUTTRESS_HEIGHT := 2.4
## Knots and burls on the trunk (a share of its radius) and how much its cords wander round (radians).
const TRUNK_KNOTS := 0.13
const TRUNK_WANDER := 0.32
## Cords that carry a vein of crystal (indices), up to this height.
const VEIN_LOBES: Array[int] = [1, 4, 6]
const VEIN_TOP := 2.5

# ---------- the crown ----------
## The three limbs: bearing, how far from the axis their own end reaches, its height, their radius at the fork.
## A to the west-south-west (the screen's left), B to the north-north-east (back right), C up and back.
const LIMBS: Array[Vector4] = [Vector4(245.0, 3.5, 6.0, 1.08), Vector4(20.0, 3.0, 6.6, 1.04), Vector4(320.0, 1.4, 7.4, 1.18)]
## How much wider a limb is where it leaves the trunk (it swells into it).
const LIMB_COLLAR := 0.35
## A limb's end radius (a share of its start).
const LIMB_END := 0.6
## Each level after the limbs: fewest and most children at a fork, their length (m), how far they spread (degrees).
const LEVELS: Array[Vector4] = [Vector4(2, 3, 2.3, 34.0), Vector4(2, 3, 1.8, 36.0), Vector4(1, 2, 1.25, 32.0)]
## A child's start radius (a share of its parent's end) and its end (a share of its start); the thinnest twig.
const CHILD_START := 0.84
const CHILD_END := 0.52
const TIP := 0.08
## How crooked each level is (random turn per step), how much each climbs and spreads outward per step, the step.
const WIGGLE: Array[float] = [0.1, 0.3, 0.38, 0.45]
const CLIMB: Array[float] = [0.0, 0.08, 0.05, 0.02]
const SPREAD: Array[float] = [0.0, 0.3, 0.26, 0.2]
const STEP: Array[float] = [0.4, 0.4, 0.38, 0.33]
## Knots on the thicker branches and their cords' wandering.
const BRANCH_KNOTS := 0.09
const BRANCH_WANDER := 0.15
## The branches broken off clean (their number in the order they are grown) and how much of their length is left.
const BROKEN: Array[int] = [5, 13, 22]
const BROKEN_LEFT := 0.55
## Old limbs broken off low on the trunk, turned to the camera so their light fracture shows (ART_REVIEW J-2): bearing,
## height on the axis (m), length (m), radius at the trunk (m). They stay within NEAR_TRUNK of the axis and off the
## camera's side (the crown's rule), climbing STUB_CLIMB degrees.
const STUBS: Array[Vector4] = [Vector4(208.0, 3.1, 1.95, 0.42), Vector4(82.0, 3.7, 1.85, 0.38)]
const STUB_CLIMB := 45.0
const STUB_FROM := 1.15
## Where a lantern may hang under a limb: how far out from the trunk (m) and how high its spine is there (m).
const HANG_OUT := Vector2(3.5, 5.5)
const HANG_HEIGHT := Vector2(6.4, 8.5)
## The crown's rule: no branch lower than LOW but within 1 m of the trunk (NEAR_TRUNK from its leaning axis: its radius
## at the fork and 1 m); none farther than CAMERA_CLEAR from the axis toward the camera (bearings CAMERA_SIDE).
const LOW := 4.5
const NEAR_TRUNK := 2.7
const CAMERA_SIDE := Vector2(95.0, 195.0)
const CAMERA_CLEAR := 2.0
## What the growth keeps clear of the rule (a margin).
const RULE_MARGIN := Vector2(8.0, 0.25)

# ---------- the roots ----------
## A root's width over its collision (the layout's capsules are 1 m wide), how far it reaches under the floor, its top
## along its length (share, height): two humps, low at the tip; and how far past its last point it goes (the capsule's
## round end).
const ROOT_WIDTH := 1.0
const ROOT_SINK := 0.15
const ROOT_TOP: Array[Vector2] = [Vector2(-0.25, 1.25), Vector2(0.0, 0.85), Vector2(0.13, 0.55), Vector2(0.29, 0.86),
	Vector2(0.46, 0.3), Vector2(0.64, 0.76), Vector2(0.8, 0.28), Vector2(0.92, 0.12), Vector2(1.0, -0.04)]
## Its width toward the tip (share along, share of ROOT_WIDTH): it dives into the floor there, a little narrower.
const ROOT_TIP_WIDTH := Vector2(0.86, 0.8)
const ROOT_PAST := 0.45
const ROOT_LOBES := 5
const ROOT_GROOVE := 0.2
## How light a root's cords are between its hollows (top ROOT_SHADE_TOP.x and lower) and its humps (ROOT_SHADE_TOP.y
## and higher), so its two humps read from the camera (ART_REVIEW J-3).
const ROOT_SHADE := Vector2(0.55, 1.0)
const ROOT_SHADE_TOP := Vector2(0.32, 0.78)
## The section a little wider than the collision, so its grooves still meet the capsule's sides.
const ROOT_FULL := 1.1
## Knots on the roots and their cords' wandering (the foot stays within the spec's tolerance of its capsule).
const ROOT_KNOTS := 0.08
const ROOT_WANDER := 0.4
## Where a root starts, inside the trunk (m from its middle).
const ROOT_FROM := 2.3
## A fine root (no collision, class A): its radius and top at its start, its length; it sinks into the floor's joints.
const FINE := Vector3(0.16, 0.11, 2.4)
## Each big root ends in a fan of TIP_ROOTS fine roots (fewest, most) spread TIP_SPREAD degrees, never a single point
## (ART_REVIEW J-3: tubes tapering to one point read as tentacles).
const TIP_ROOTS := Vector2i(2, 3)
const TIP_SPREAD := 34.0
## Rootlets from each big root's sides.
const ROOTLETS := 2
## How light the fine roots' cords are (darker, grimy).
const FINE_SHADE := 0.6
## Fine roots from the trunk's foot between the big ones, at least this far (degrees) from them.
const FINE_COUNT := 7
const FINE_CLEAR := 22.0

# ---------- the crystals ----------
## Clusters at the trunk's foot between the buttresses (bearings from 100 to 300), each of 5 to 9 six-sided prisms
## with a pointed tip, leaning out of the trunk; they never reach past CRYSTAL_REACH from the middle (inside the
## trunk's collision of 3.5, within its tolerance).
const CRYSTAL_BEARINGS: Array[float] = [118.0, 182.0, 262.0]
const CRYSTAL_ARC := Vector2(100.0, 300.0)
const CRYSTAL_ROOT_CLEAR := 22.0
const CRYSTAL_FROM := 2.95
const CRYSTAL_REACH := 3.58
const CRYSTAL_COUNT := Vector2i(5, 9)
const CRYSTAL_RADIUS := Vector2(0.15, 0.35)
const CRYSTAL_HEIGHT := Vector2(0.4, 1.4)
const CRYSTAL_TILT := Vector2(10.0, 35.0)
## Corrupted emerald, dark (Boss.CORRUPT's hue, about 165): far from Emeth's bright crystal green (Combat.EMETH, hue
## about 135) and never summing to white with its own light (ART_REVIEW J-1: the largest channel on screen up to 160).
const CRYSTAL_ALBEDO := Color(0.04, 0.12, 0.1)
const CRYSTAL_GLOW := Color(0.315, 0.7, 0.604)
## A dull, glassy face: rough enough that the cold beam leaves no white highlight on it.
const CRYSTAL_ROUGHNESS := 0.45
const CRYSTAL_SPECULAR := 0.3

enum End { NONE, POINT, FRACTURE }

## A piece to sweep: rings of `sides` points round `spine`, half widths rx (side) and ry (up) at each ring.
class Tube:
	var spine := PackedVector3Array()
	var rx := PackedFloat32Array()
	var ry := PackedFloat32Array()
	## Groove depth (share of the radius) and lichen at each ring.
	var groove := PackedFloat32Array()
	var lichen := PackedFloat32Array()
	var sides := 8
	var lobes := 0
	## The cords' turn from the first ring to the last (radians), and where they start.
	var twist := 0.0
	var phase := 0.0
	## Frames keep their up toward the world's (roots lying on the floor) instead of being carried along (limbs).
	var flat := false
	var end := End.POINT
	## The trunk only: the bearings of its buttresses and its veins.
	var buttress: Array[float] = []
	var veins := false
	## Part of what stands on the floor and must lie on its collision (the trunk and the big roots).
	var solid := false
	## Knots and burls: how far the surface swells and sinks (a share of the radius), gone at the floor (`bulge_from` m
	## over its foot) so the foot keeps to its collision; how much the cords wander round (radians).
	var bulge := 0.0
	var bulge_from := 0.0
	var wander := 0.0
	## A point's length (a share of the last radius).
	var tip := 1.6
	## How light its cords are (1: as the material says; the fine roots are darker, half in the floor's grime), and at
	## each ring if not empty (a root's humps lighter than the hollows between them).
	var shade := 1.0
	var ring_shade := PackedFloat32Array()

var root: Node3D
## The middle of the trunk's foot.
var at := Vector3.ZERO
var rng := RandomNumberGenerator.new()
## The crown stays over this part of the floor (x, z; the room's walls): none if empty.
var bounds := Rect2()
## What was built, for the arena and the tests: where lanterns may hang (a point under a limb, its bearing), the
## crystal clusters' middles, every point of the crown's spines, the points of the trunk and roots on the floor.
var hangs: Array[Vector3] = []
var crystal_spots: Array[Vector3] = []
var crown := PackedVector3Array()
var footprint := PackedVector3Array()
var triangles := 0
var branches := 0
var stone_material: ShaderMaterial
var crystal_material: StandardMaterial3D

var _v := PackedVector3Array()
var _n := PackedVector3Array()
var _t := PackedFloat32Array()
var _uv := PackedVector2Array()
var _c := PackedColorArray()
var _i := PackedInt32Array()
var _grown := 0
var _crown_radius := PackedFloat32Array()
var _crown_limb := PackedInt32Array()


## Grows the tree at `foot` (x, z) under `parent`. roots: each root's points (x, z) from where it leaves the trunk out
## to its tip (the layout's capsules); glow: the crystals' largest channel (0.8 in variant A, 0.9 in B).
func build(parent: Node3D, foot: Vector2, roots: Array[PackedVector2Array], glow := 0.8, seed_ := 7) -> void:
	root = parent
	at = Vector3(foot.x, 0.0, foot.y)
	rng.seed = seed_
	var bearings: Array[float] = []
	for r in roots:
		bearings.append(bearing(r[0] - foot))
	_trunk(bearings)
	for r in roots:
		_root(r)
	_fine_roots(bearings)
	# the crown is the same whatever the roots (the tree is the place's landmark in every variant)
	rng.seed = seed_ * 31 + 5
	for i in LIMBS.size():
		_limb(i)
	_stubs()
	_find_hangs()
	_commit()
	_crystals(bearings, glow)


# ---------- bearings ----------

## The way a bearing points on the floor (x, z).
static func toward(deg: float) -> Vector2:
	return Vector2(sin(deg_to_rad(deg)), -cos(deg_to_rad(deg)))


## The bearing of a way on the floor (x, z), 0 to 360.
static func bearing(v: Vector2) -> float:
	return fposmod(rad_to_deg(atan2(v.x, -v.y)), 360.0)


## True when a point of the crown breaks the rule (too low away from the trunk, or out toward the camera); margin
## tightens it (the growth keeps clear of it by RULE_MARGIN).
func breaks_rule(p: Vector3, margin := Vector2.ZERO) -> bool:
	var h := Vector2(p.x - at.x, p.z - at.z)
	var d := h.length()
	var ax := axis(minf(p.y, FORK))
	if p.y < LOW + margin.y and Vector2(p.x - ax.x, p.z - ax.z).length() > NEAR_TRUNK:
		return true
	if bounds.has_area() and not bounds.grow(-margin.y).has_point(Vector2(p.x, p.z)):
		return true
	var b := bearing(h)
	return d > CAMERA_CLEAR - margin.y and b > CAMERA_SIDE.x - margin.x and b < CAMERA_SIDE.y + margin.x


## The trunk's axis at a height (it leans away from the camera).
func axis(y: float) -> Vector3:
	var lean := toward(LEAN_BEARING) * tan(deg_to_rad(LEAN)) * maxf(y, 0.0)
	return at + Vector3(lean.x, y, lean.y)


# ---------- the trunk ----------

func _trunk(root_bearings: Array[float]) -> void:
	var t := Tube.new()
	t.sides = LOBES * LOBE_SIDES
	t.lobes = LOBES
	t.twist = deg_to_rad(TWIST) * (TRUNK_PROFILE[-1].x / FORK)
	t.phase = 0.3
	t.buttress = root_bearings
	t.veins = true
	t.solid = true
	t.end = End.POINT
	t.tip = 0.2
	t.bulge = TRUNK_KNOTS
	t.bulge_from = 0.05
	t.wander = TRUNK_WANDER
	for p in TRUNK_PROFILE:
		# a slow bend along the spine (not a straight post)
		var bend := Vector3(sin(p.x * 0.9) * 0.12, 0.0, cos(p.x * 0.7 + 1.0) * 0.1) * smoothstep(0.5, 2.5, p.x)
		t.spine.append(axis(p.x) + bend)
		t.rx.append(p.y)
		t.ry.append(p.y)
		t.groove.append(lerpf(FOOT_GROOVE, GROOVE, smoothstep(0.0, LOBE_FULL, p.x)))
		t.lichen.append(1.0 - smoothstep(1.4, 3.0, p.x))
	_sweep(t)


# ---------- the roots ----------

## One big root along its points (from the trunk out), sweeping a low flat section over its whole collision, then a
## fine root on past its tip.
func _root(pts: PackedVector2Array) -> void:
	var foot := Vector2(at.x, at.z)
	var way := (pts[0] - foot).normalized()
	var path := PackedVector2Array([foot + way * ROOT_FROM])
	path.append_array(pts)
	var tip_way := (pts[pts.size() - 1] - pts[pts.size() - 2]).normalized() if pts.size() > 1 else way
	path.append(pts[pts.size() - 1] + tip_way * ROOT_PAST)
	var line := _smooth(path, 0.22)
	# the share along it measured from the trunk's surface (3.5) to the end
	var total := 0.0
	var at_s := PackedFloat32Array([0.0])
	for i in range(1, line.size()):
		total += line[i].distance_to(line[i - 1])
		at_s.append(total)
	var surface := 3.5 - ROOT_FROM
	var t := Tube.new()
	t.flat = true
	t.lobes = ROOT_LOBES
	t.sides = ROOT_LOBES * 6
	t.twist = rng.randf_range(1.0, 1.8) * (1.0 if rng.randf() < 0.5 else -1.0)
	t.phase = rng.randf() * TAU
	t.solid = true
	t.end = End.POINT
	t.tip = 1.4
	t.bulge = ROOT_KNOTS
	t.bulge_from = -0.7
	t.wander = ROOT_WANDER
	for i in line.size():
		var share := (at_s[i] - surface) / maxf(total - surface, 0.01)
		var top := _along(ROOT_TOP, share)
		# the upper half of an ellipse whose middle is under the floor: as wide as the collision where it meets it
		var hh := top + ROOT_SINK
		t.spine.append(Vector3(line[i].x, -ROOT_SINK, line[i].y))
		var w := ROOT_WIDTH * 0.5 * ROOT_FULL * lerpf(1.0, ROOT_TIP_WIDTH.y, smoothstep(ROOT_TIP_WIDTH.x, 1.0, share))
		# deeper inside the trunk the root is the buttress: wider
		w *= 1.0 + 0.5 * (1.0 - smoothstep(-0.3, 0.0, share))
		t.rx.append(w)
		t.ry.append(hh)
		t.groove.append(ROOT_GROOVE)
		t.lichen.append(0.7)
		t.ring_shade.append(lerpf(ROOT_SHADE.x, ROOT_SHADE.y, smoothstep(ROOT_SHADE_TOP.x, ROOT_SHADE_TOP.y, top)))
	_sweep(t)
	# its tip opens into a fan of fine roots gripping the floor's joints
	var fan := rng.randi_range(TIP_ROOTS.x, TIP_ROOTS.y)
	var tip_at := pts[pts.size() - 1] + tip_way * (ROOT_PAST - 0.3)
	for k in fan:
		var turn := deg_to_rad(TIP_SPREAD) * (float(k) / (fan - 1) - 0.5) + rng.randf_range(-0.12, 0.12)
		var way_k := tip_way.rotated(turn)
		var side := Vector2(-tip_way.y, tip_way.x) * (float(k) / (fan - 1) - 0.5) * 0.3
		_fine_root(tip_at + side, way_k, FINE.z * rng.randf_range(0.7, 1.1), rng.randf_range(0.85, 1.0))
	# rootlets leaving its sides along the way, gripping the floor
	for k in ROOTLETS:
		var at_i := clampi(int(line.size() * rng.randf_range(0.3, 0.85)), 1, line.size() - 2)
		var along := (line[at_i + 1] - line[at_i - 1]).normalized()
		var sd := 1.0 if rng.randf() < 0.5 else -1.0
		var off := Vector2(-along.y, along.x) * sd
		var way2 := (off + along * rng.randf_range(0.1, 0.9)).normalized()
		_fine_root(line[at_i] + off * 0.42, way2, rng.randf_range(1.0, 2.0), rng.randf_range(0.6, 0.85))


## A thin root lying on the floor and sinking into it (no collision; at most FINE.y high).
func _fine_root(from: Vector2, way: Vector2, length: float, size: float) -> void:
	var pts := PackedVector2Array([from])
	var d := way
	var n := maxi(4, ceili(length / 0.3))
	var p := from
	for i in n:
		d = d.rotated(rng.randf_range(-0.35, 0.35)).normalized()
		p += d * (length / n)
		pts.append(p)
	var t := Tube.new()
	t.flat = true
	t.sides = 6
	t.end = End.POINT
	t.tip = 0.8
	t.shade = FINE_SHADE
	for i in pts.size():
		var share := float(i) / (pts.size() - 1)
		var r := FINE.x * size * lerpf(1.0, 0.25, share)
		var top := FINE.y * size * lerpf(1.0, 0.0, share * share) - 0.02 * share
		t.spine.append(Vector3(pts[i].x, top - r * 0.35, pts[i].y))
		t.rx.append(r)
		t.ry.append(r * 0.35)
		t.groove.append(0.0)
		t.lichen.append(0.5)
	_sweep(t)


## Fine roots from the trunk's foot between the big ones.
func _fine_roots(big: Array[float]) -> void:
	var made := 0
	var tries := 0
	while made < FINE_COUNT and tries < 60:
		tries += 1
		var b := rng.randf() * 360.0
		var clear := true
		for r in big:
			if absf(angle_difference(deg_to_rad(b), deg_to_rad(r))) < deg_to_rad(FINE_CLEAR):
				clear = false
		if not clear:
			continue
		var way := toward(b)
		_fine_root(Vector2(at.x, at.z) + way * 3.3, way.rotated(rng.randf_range(-0.3, 0.3)), rng.randf_range(1.6, 2.8), rng.randf_range(0.7, 1.0))
		made += 1


# ---------- the crown ----------

## The old limbs broken off low on the trunk (STUBS): a short thick tube out of the trunk, its end a clean light
## fracture with chips.
func _stubs() -> void:
	for st in STUBS:
		var way := toward(st.x)
		var w3 := Vector3(way.x, 0.0, way.y)
		var start := axis(st.y) + w3 * STUB_FROM
		var dir := (w3 * cos(deg_to_rad(STUB_CLIMB)) + Vector3.UP * sin(deg_to_rad(STUB_CLIMB))).normalized()
		var spine := PackedVector3Array()
		var radii := PackedFloat32Array()
		var n := 4
		for k in n + 1:
			var s := float(k) / n
			spine.append(start + dir * st.z * s + Vector3.UP * sin(s * PI) * 0.06)
			# a collar where it swells into the trunk
			radii.append(st.w * lerpf(1.0, 0.82, s) * (1.0 + LIMB_COLLAR * maxf(0.0, 1.0 - s * 2.5)))
		var t := _branch_tube(spine, radii, 1)
		t.end = End.FRACTURE
		_add_crown(spine, radii, 0)
		_sweep(t)
		_chips(spine[n], dir, radii[n])


## One of the three limbs from the fork, then its children.
func _limb(i: int) -> void:
	var l := LIMBS[i]
	var way := toward(l.x)
	var start := axis(FORK - 1.2) + Vector3(way.x, 0.0, way.y) * 0.6
	var end := Vector3(at.x + way.x * l.y, l.z, at.z + way.y * l.y)
	var control := start + Vector3(0.0, (end.y - start.y) * 0.6, 0.0) + Vector3(way.x, 0.0, way.y) * l.y * 0.35
	var n := 10
	var spine := PackedVector3Array()
	var side := Vector3(-way.y, 0.0, way.x)
	for k in n + 1:
		var s := float(k) / n
		var p := start.lerp(control, s).lerp(control.lerp(end, s), s)
		# crooked, never straight
		p += side * sin(s * PI * 2.0 + i) * 0.22 * sin(s * PI) + Vector3.UP * sin(s * PI * 3.0 + i * 2.0) * 0.12 * sin(s * PI)
		spine.append(p)
	var radii := PackedFloat32Array()
	for k in n + 1:
		# a collar where it leaves the trunk, then tapering
		radii.append(lerpf(l.w, l.w * LIMB_END, pow(float(k) / n, 0.8)) * (1.0 + LIMB_COLLAR * maxf(0.0, 1.0 - k / 2.5)))
	var t := _branch_tube(spine, radii, 0)
	t.end = End.NONE
	_add_crown(spine, radii, i)
	_sweep(t)
	_children(spine[n], (spine[n] - spine[n - 1]).normalized(), l.w * LIMB_END, 1, i)


## The children at the end of a branch of `level - 1`.
func _children(from: Vector3, dir: Vector3, r: float, level: int, limb: int) -> void:
	if level > LEVELS.size():
		return
	var lv := LEVELS[level - 1]
	var count := rng.randi_range(int(lv.x), int(lv.y))
	var u := dir.cross(Vector3.UP)
	if u.length() < 0.1:
		u = dir.cross(Vector3.RIGHT)
	u = u.normalized()
	var v := dir.cross(u).normalized()
	var turn := rng.randf() * TAU
	for c in count:
		var az := turn + TAU * c / count + rng.randf_range(-0.4, 0.4)
		var tilt := deg_to_rad(lv.w * rng.randf_range(0.7, 1.3))
		var d := (dir * cos(tilt) + (u * cos(az) + v * sin(az)) * sin(tilt)).normalized()
		var r0 := r * CHILD_START * (1.0 if count < 3 else 0.9)
		_grow(from - dir * r * 0.4, d, lv.z * rng.randf_range(0.8, 1.2), r0, level, limb)


## One branch of `level` (1 and up): crooked steps, kept to the crown's rule, then its own children.
func _grow(from: Vector3, dir: Vector3, length: float, r0: float, level: int, limb: int) -> void:
	_grown += 1
	var broken := BROKEN.has(_grown)
	if broken:
		length *= BROKEN_LEFT
	var last := level >= LEVELS.size()
	var r1 := TIP if last else maxf(r0 * CHILD_END, TIP)
	if broken:
		r1 = r0 * 0.75
	var step := STEP[level]
	var n := maxi(2, ceili(length / step))
	var spine := PackedVector3Array([from])
	var p := from
	var d := dir
	for k in n:
		var out := Vector3(p.x - at.x, 0.0, p.z - at.z)
		out = out.normalized() if out.length() > 0.01 else Vector3.ZERO
		d = (d + _rand_unit() * WIGGLE[level] + Vector3.UP * CLIMB[level] + out * SPREAD[level]).normalized()
		d = _keep_rule(p, d, length / n)
		p += d * (length / n)
		spine.append(p)
	var radii := PackedFloat32Array()
	for k in n + 1:
		radii.append(lerpf(r0, r1, pow(float(k) / n, 0.9)))
	var t := _branch_tube(spine, radii, level)
	t.end = End.FRACTURE if broken else (End.POINT if last else End.NONE)
	_add_crown(spine, radii, limb)
	_sweep(t)
	branches += 1
	if broken:
		_chips(spine[n], d, r1)
	elif not last:
		_children(spine[n], d, r1, level + 1, limb)


## Turns a step that would break the crown's rule round the up axis (toward the nearer allowed side), or up.
func _keep_rule(p: Vector3, d: Vector3, step: float) -> Vector3:
	if not breaks_rule(p + d * step, RULE_MARGIN):
		return d
	var h := Vector2(p.x - at.x, p.z - at.z)
	var b := bearing(h)
	# turn away from the camera's side: the bearings under its middle turn down (toward 95), the others up
	var sign_ := -1.0 if b < (CAMERA_SIDE.x + CAMERA_SIDE.y) * 0.5 else 1.0
	var flat := Vector2(d.x, d.z)
	for k in 12:
		var turned := flat.rotated(sign_ * deg_to_rad(15.0) * (k + 1))
		var c := Vector3(turned.x, maxf(d.y, 0.15), turned.y).normalized()
		if not breaks_rule(p + c * step, RULE_MARGIN):
			return c
	return Vector3(0.0, 1.0, 0.0).lerp(d, 0.2).normalized()


func _branch_tube(spine: PackedVector3Array, radii: PackedFloat32Array, level: int) -> Tube:
	var t := Tube.new()
	t.spine = spine
	t.rx = radii
	t.ry = radii
	var r0 := radii[0]
	t.sides = 16 if r0 >= 0.7 else (11 if r0 >= 0.35 else (8 if r0 >= 0.15 else 6))
	if r0 >= 0.3:
		t.lobes = 5 if r0 >= 0.6 else 4
		t.sides = t.lobes * (4 if r0 >= 0.6 else 3)
	t.twist = rng.randf_range(0.4, 1.2) * (1.0 if level % 2 == 0 else -1.0)
	t.wander = BRANCH_WANDER
	t.bulge = BRANCH_KNOTS if r0 >= 0.12 else 0.0
	t.bulge_from = -10.0
	t.phase = rng.randf() * TAU
	for k in spine.size():
		t.groove.append(0.12 if t.lobes > 0 else 0.0)
		t.lichen.append(0.0)
	return t


func _add_crown(spine: PackedVector3Array, radii: PackedFloat32Array, limb: int) -> void:
	crown.append_array(spine)
	_crown_radius.append_array(radii)
	for k in spine.size():
		_crown_limb.append(limb)


## A few sharp chips round a clean fracture (they stay on it).
func _chips(at_: Vector3, dir: Vector3, r: float) -> void:
	var u := dir.cross(Vector3.UP)
	if u.length() < 0.1:
		u = Vector3.RIGHT
	u = u.normalized()
	var v := dir.cross(u).normalized()
	for k in 3:
		var a := TAU * k / 3.0 + rng.randf()
		var base := at_ + (u * cos(a) + v * sin(a)) * r * 0.6
		var t := Tube.new()
		t.sides = 3
		t.end = End.POINT
		t.spine = PackedVector3Array([base - dir * 0.05, base + dir * r * 0.5 + (u * cos(a) + v * sin(a)) * r * 0.2])
		t.rx = PackedFloat32Array([r * 0.28, r * 0.12])
		t.ry = t.rx
		t.groove = PackedFloat32Array([0.0, 0.0])
		t.lichen = PackedFloat32Array([0.0, 0.0])
		_sweep(t, 1.0)


func _rand_unit() -> Vector3:
	return Vector3(rng.randf_range(-1, 1), rng.randf_range(-1, 1), rng.randf_range(-1, 1)).limit_length(1.0)


## Points under the limbs where a lantern can hang (one per limb A and B, HANG_OUT out, HANG_HEIGHT high on the spine:
## the underside stays over the garden's lantern ring at 5.5 m).
func _find_hangs() -> void:
	for want: float in [LIMBS[0].x, LIMBS[1].x]:
		var best := -1
		var best_score := INF
		for k in crown.size():
			var p := crown[k]
			var h := Vector2(p.x - at.x, p.z - at.z)
			if h.length() < HANG_OUT.x or h.length() > HANG_OUT.y or p.y < HANG_HEIGHT.x or p.y > HANG_HEIGHT.y or _crown_radius[k] < 0.14:
				continue
			var score := absf(rad_to_deg(angle_difference(deg_to_rad(bearing(h)), deg_to_rad(want))))
			if score < best_score:
				best_score = score
				best = k
		if best >= 0:
			hangs.append(crown[best] - Vector3(0.0, _crown_radius[best] * 0.8, 0.0))


# ---------- sweeping ----------

## Adds a tube's rings and caps to the stone's arrays. fracture: the share of fracture colour on its sides (chips).
func _sweep(t: Tube, fracture := 0.0) -> void:
	var n := t.spine.size()
	if n < 2:
		return
	var sides := t.sides
	var grid: Array[PackedVector3Array] = []
	var cols: Array[PackedColorArray] = []
	var along := PackedFloat32Array()
	var tangents := PackedVector3Array()
	var length := 0.0
	var normal_prev := Vector3.ZERO
	for i in n:
		var way_ := (t.spine[mini(i + 1, n - 1)] - t.spine[maxi(i - 1, 0)]).normalized()
		tangents.append(way_)
		if i > 0:
			length += t.spine[i].distance_to(t.spine[i - 1])
		along.append(length)
		var side: Vector3
		var up: Vector3
		if t.flat:
			side = way_.cross(Vector3.UP)
			side = side.normalized() if side.length() > 0.05 else Vector3.RIGHT
			up = side.cross(way_).normalized()
			if up.y < 0.0:
				up = -up
				side = -side
		else:
			if normal_prev == Vector3.ZERO:
				normal_prev = way_.cross(Vector3.UP)
				if normal_prev.length() < 0.1:
					normal_prev = way_.cross(Vector3.RIGHT)
			side = (normal_prev - way_ * normal_prev.dot(way_)).normalized()
			normal_prev = side
			up = way_.cross(side).normalized()
		var share := float(i) / (n - 1)
		var ring := PackedVector3Array()
		var ring_c := PackedColorArray()
		var turn := t.phase + t.twist * share
		for j in sides + 1:
			var a := TAU * j / sides
			var f := 1.0
			var cord := 1.0
			var lobe := -1
			var along_m := float(i) / (n - 1) * 6.0
			if t.lobes > 0:
				# the cords wander round and swell unevenly (not the flutes of a column)
				var uneven := LOBE_UNEVEN * (sin(a * 3.0 + t.phase * 2.0) + 0.7 * sin(a * 5.0 - t.phase))
				var x := (a + uneven + turn + t.wander * sin(a * 2.0 + along_m * 0.8 + t.phase)) * t.lobes * 0.5
				var s := absf(sin(x))
				cord = sqrt(s)
				lobe = posmod(floori(x / PI), t.lobes)
				var amp := 0.45 + 0.5 * (1.0 + sin(lobe * 2.3 + lobe * lobe * 0.7 + share * 2.5))
				f = 1.0 - t.groove[i] * amp * (1.0 - cord)
			if t.bulge > 0.0:
				var knot := sin(a * 2.0 + along_m * 0.9 + t.phase * 3.0) * 0.5 + sin(a * 3.0 - along_m * 1.4 + t.phase) * 0.3 \
					+ sin(a * 5.0 + along_m * 2.3) * 0.2
				f *= 1.0 + t.bulge * knot * smoothstep(t.bulge_from, t.bulge_from + 0.6, t.spine[i].y - at.y + ROOT_SINK)
			var radial := side * cos(a) * t.rx[i] * f + up * sin(a) * t.ry[i] * f
			var p := t.spine[i] + radial
			if not t.buttress.is_empty():
				var flat := Vector2(radial.x, radial.z)
				var b := bearing(flat)
				var bump := 0.0
				for rb in t.buttress:
					var d := rad_to_deg(angle_difference(deg_to_rad(b), deg_to_rad(rb))) / BUTTRESS_SPREAD
					bump += BUTTRESS * exp(-d * d) * (1.0 - smoothstep(0.0, BUTTRESS_HEIGHT, maxf(t.spine[i].y - at.y, 0.0)))
				if flat.length() > 0.01:
					var out := flat.normalized() * bump
					p += Vector3(out.x, 0.0, out.y)
			ring.append(p)
			var vein := 0.0
			if t.veins and VEIN_LOBES.has(lobe):
				vein = 1.0 - smoothstep(VEIN_TOP * 0.75, VEIN_TOP, t.spine[i].y - at.y)
			var lit := t.shade * (t.ring_shade[i] if t.ring_shade.size() == n else 1.0)
			ring_c.append(Color(cord * lit, t.lichen[i], fracture, vein))
			if t.solid and p.y <= at.y + 0.05:
				footprint.append(p)
		grid.append(ring)
		cols.append(ring_c)
	var base := _v.size()
	for i in n:
		var circumference := TAU * (t.rx[i] + t.ry[i]) * 0.5
		for j in sides + 1:
			var jp := (j + 1) % sides if j < sides else 1
			var jm := (j - 1 + sides) % sides if j > 0 else sides - 1
			var around := grid[i][jp] - grid[i][jm]
			var ip := mini(i + 1, n - 1)
			var im := maxi(i - 1, 0)
			var length_way := grid[ip][j] - grid[im][j]
			if length_way.length() < 1e-5:
				length_way = tangents[i]
			var nrm := around.cross(length_way).normalized()
			if nrm.dot(grid[i][j] - t.spine[i]) < 0.0:
				nrm = -nrm
			if nrm == Vector3.ZERO:
				nrm = (grid[i][j] - t.spine[i]).normalized()
			_v.append(grid[i][j])
			_n.append(nrm)
			var tg := around.normalized()
			var w := 1.0 if nrm.cross(tg).dot(tangents[i]) >= 0.0 else -1.0
			_t.append_array([tg.x, tg.y, tg.z, w])
			_uv.append(Vector2(float(j) / sides * circumference, along[i]))
			_c.append(cols[i][j])
	for i in n - 1:
		for j in sides:
			var a := base + i * (sides + 1) + j
			var b := a + 1
			var c := a + sides + 1
			var d := c + 1
			_tri(a, c, b, (grid[i][j] - t.spine[i]))
			_tri(b, c, d, (grid[i][j + 1] - t.spine[i]))
	if t.end != End.NONE:
		_cap(t, grid[n - 1], cols[n - 1], tangents[n - 1], along[n - 1])


## Closes a tube's last ring: a short point (a twig's tip) or a flat, jagged fracture of lighter stone.
func _cap(t: Tube, ring: PackedVector3Array, ring_c: PackedColorArray, way_: Vector3, along: float) -> void:
	var sides := ring.size() - 1
	var mid := Vector3.ZERO
	for j in sides:
		mid += ring[j]
	mid /= sides
	var r := (t.rx[t.rx.size() - 1] + t.ry[t.ry.size() - 1]) * 0.5
	var fracture := t.end == End.FRACTURE
	var tip := mid + way_ * (r * (0.25 if fracture else t.tip)) + _rand_unit() * r * (0.35 if fracture else 0.0)
	var base := _v.size()
	for j in sides + 1:
		var p := ring[j]
		if fracture:
			# a jagged lip: each point a little forward or back along the limb
			p += way_ * rng.randf_range(-0.3, 0.3) * r
		_v.append(p)
		var out := (p - mid).normalized()
		_n.append((out * (0.3 if fracture else 0.7) + way_).normalized())
		_t.append_array([out.x, out.y, out.z, 1.0])
		_uv.append(Vector2(float(j) / sides * TAU * r, along))
		var c := ring_c[j]
		_c.append(Color(c.r, c.g, 1.0 if fracture else c.b, c.a))
	_v.append(tip)
	_n.append(way_)
	_t.append_array([1.0, 0.0, 0.0, 1.0])
	_uv.append(Vector2(0.0, along + r))
	_c.append(Color(1.0, 0.0, 1.0 if fracture else 0.0, 0.0))
	var top := _v.size() - 1
	for j in sides:
		_tri(base + j, base + j + 1, top, way_)


## One triangle, wound so it faces `out` (Godot's front faces turn clockwise as seen).
func _tri(a: int, b: int, c: int, out: Vector3) -> void:
	var n := (_v[b] - _v[a]).cross(_v[c] - _v[a])
	if n.dot(out) > 0.0:
		_i.append_array([a, c, b])
	else:
		_i.append_array([a, b, c])
	triangles += 1


## The stone in one mesh.
func _commit() -> void:
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = _v
	arrays[Mesh.ARRAY_NORMAL] = _n
	arrays[Mesh.ARRAY_TANGENT] = _t
	arrays[Mesh.ARRAY_TEX_UV] = _uv
	arrays[Mesh.ARRAY_COLOR] = _c
	arrays[Mesh.ARRAY_INDEX] = _i
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	stone_material = ShaderMaterial.new()
	stone_material.shader = SHADER
	stone_material.set_shader_parameter(&"rock_normal", Masonry.ROCK_NORMAL)
	stone_material.set_shader_parameter(&"rock_height", Masonry.ROCK_HEIGHT)
	var mi := MeshInstance3D.new()
	mi.name = "StoneTree"
	mi.layers = 1 | LAYER
	mi.mesh = mesh
	mi.material_override = stone_material
	root.add_child(mi)


# ---------- crystals ----------

func _crystals(root_bearings: Array[float], glow: float) -> void:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var count := 0
	for want in CRYSTAL_BEARINGS:
		var b := _clear_of(want, root_bearings)
		var way := toward(b)
		var mid := at + Vector3(way.x, 0.0, way.y) * CRYSTAL_FROM
		crystal_spots.append(mid)
		var prisms := rng.randi_range(CRYSTAL_COUNT.x, CRYSTAL_COUNT.y)
		for k in prisms:
			var spot := mid + Vector3(rng.randf_range(-0.35, 0.35), 0.0, rng.randf_range(-0.35, 0.35))
			var out := Vector3(spot.x - at.x, 0.0, spot.z - at.z).normalized()
			var lean_way := (out + Vector3(rng.randf_range(-0.6, 0.6), 0.0, rng.randf_range(-0.6, 0.6))).normalized()
			var tilt := deg_to_rad(rng.randf_range(CRYSTAL_TILT.x, CRYSTAL_TILT.y))
			var dir := (Vector3.UP * cos(tilt) + lean_way * sin(tilt)).normalized()
			var r := rng.randf_range(CRYSTAL_RADIUS.x, CRYSTAL_RADIUS.y)
			var h := rng.randf_range(CRYSTAL_HEIGHT.x, CRYSTAL_HEIGHT.y)
			# never past the trunk's collision: shorten it until its tip and its sides stay inside
			var foot2 := Vector2(spot.x - at.x, spot.z - at.z)
			var reach := CRYSTAL_REACH - r
			while h > CRYSTAL_HEIGHT.x * 0.6 and (foot2 + Vector2(dir.x, dir.z) * h).length() > reach:
				h *= 0.9
			if (foot2 + Vector2(dir.x, dir.z) * h).length() > reach or foot2.length() > reach:
				continue
			_prism(st, spot + Vector3.DOWN * 0.2, dir, r, h + 0.2)
			count += 1
	if count == 0:
		return
	crystal_material = StandardMaterial3D.new()
	crystal_material.albedo_color = CRYSTAL_ALBEDO
	crystal_material.roughness = CRYSTAL_ROUGHNESS
	crystal_material.metallic_specular = CRYSTAL_SPECULAR
	crystal_material.emission_enabled = true
	crystal_material.emission = CRYSTAL_GLOW
	# the largest channel of the light, far under the glow's threshold (GardenLook.CRYSTAL_GLOW)
	crystal_material.emission_energy_multiplier = glow / maxf(CRYSTAL_GLOW.r, maxf(CRYSTAL_GLOW.g, CRYSTAL_GLOW.b))
	var mi := MeshInstance3D.new()
	mi.name = "StoneTreeCrystals"
	mi.mesh = st.commit()
	mi.material_override = crystal_material
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	root.add_child(mi)


## The bearing nearest `want` within CRYSTAL_ARC that keeps CRYSTAL_ROOT_CLEAR from every root.
func _clear_of(want: float, roots: Array[float]) -> float:
	for k in 13:
		for s: float in [1.0, -1.0]:
			var b := want + s * k * 5.0
			if b < CRYSTAL_ARC.x or b > CRYSTAL_ARC.y:
				continue
			var ok := true
			for r in roots:
				if absf(rad_to_deg(angle_difference(deg_to_rad(b), deg_to_rad(r)))) < CRYSTAL_ROOT_CLEAR:
					ok = false
			if ok:
				return b
	return want


## A six-sided prism with a pointed tip, flat-shaded.
func _prism(st: SurfaceTool, foot: Vector3, dir: Vector3, r: float, h: float) -> void:
	var u := dir.cross(Vector3.FORWARD)
	if u.length() < 0.1:
		u = dir.cross(Vector3.RIGHT)
	u = u.normalized()
	var v := dir.cross(u).normalized()
	var body := h * rng.randf_range(0.62, 0.78)
	var low := PackedVector3Array()
	var high := PackedVector3Array()
	var turn := rng.randf() * TAU
	for k in 6:
		var a := turn + TAU * k / 6.0
		var o := (u * cos(a) + v * sin(a)) * r
		low.append(foot + o)
		high.append(foot + o + dir * body)
	var tip := foot + dir * h
	for k in 6:
		var k2 := (k + 1) % 6
		_flat_tri(st, low[k], low[k2], high[k2], foot)
		_flat_tri(st, low[k], high[k2], high[k], foot)
		_flat_tri(st, high[k], high[k2], tip, foot + dir * body * 0.5)


func _flat_tri(st: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, inside: Vector3) -> void:
	var n := (b - a).cross(c - a)
	var mid := (a + b + c) / 3.0
	if n.dot(mid - inside) < 0.0:
		n = -n
	else:
		var t := b
		b = c
		c = t
	st.set_normal(n.normalized())
	st.add_vertex(a)
	st.add_vertex(b)
	st.add_vertex(c)
	triangles += 1


# ---------- helpers ----------

## A polyline made smooth (Catmull-Rom through its points), a point every `step` meters or so.
static func _smooth(pts: PackedVector2Array, step: float) -> PackedVector2Array:
	var out := PackedVector2Array()
	for i in pts.size() - 1:
		var p0 := pts[maxi(i - 1, 0)]
		var p1 := pts[i]
		var p2 := pts[i + 1]
		var p3 := pts[mini(i + 2, pts.size() - 1)]
		var n := maxi(1, ceili(p1.distance_to(p2) / step))
		for k in n:
			out.append(p1.cubic_interpolate(p2, p0, p3, float(k) / n))
	out.append(pts[pts.size() - 1])
	return out


## A value along a list of (share, value) points.
static func _along(curve: Array[Vector2], s: float) -> float:
	if s <= curve[0].x:
		return curve[0].y
	for i in range(1, curve.size()):
		if s <= curve[i].x:
			return remap(s, curve[i - 1].x, curve[i].x, curve[i - 1].y, curve[i].y)
	return curve[curve.size() - 1].y
