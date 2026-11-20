class_name EdgeKit
extends RefCounted
## TA-HB2 (docs/art/benchmark_hades2_style.md 4.2): the edge and foreground pieces the environment-artist's ENV-HB3 to
## HB5 frame a room with, as the Hades II rooms are framed (a broken pillar or arch cutting the near corner, roots and
## ivy hanging into the top of the frame, a chain with its weight, a heap of fallen blocks): built in code on a room's
## ArenaKit (its Masonry for the stone, its chains), no model, nothing that collides (the look puts them off the floor,
## or adds the ArenaObstacle itself). Every piece opens in a stipple round the paladin and Morvath behind it
## (see_through), so a piece in front never hides a fight. One material per family: the stone is the room's ashlar
## with see_through (one twin per base height; the stylized look paints it with the rest of the room's stone,
## ArenaKit.paint_look), roots, ivy and iron one material each (edge_piece.gdshader, the stylized twin
## edge_piece_paint.gdshader through VisualProfile). Pieces stay separate meshes until the look calls Masonry.merge,
## which joins them with the room's stone; measures per piece in docs/art/asset_inventory.md (tools/edge_lab.gd).
## Use: var edge := EdgeKit.new(kit); edge.broken_pillar(Vector3(-15, 0, 12)); ...

const SHADER := preload("res://assets/shaders/edge_piece.gdshader")
const SHADER_PAINT := preload("res://assets/shaders/edge_piece_paint.gdshader")
## The families' colours (linear): bark of the dead roots, the ivy's two greens (old and new leaves), the iron.
const BARK := Color(0.2, 0.16, 0.12)
const IVY := Color(0.16, 0.2, 0.11)
const IVY_YOUNG := Color(0.26, 0.3, 0.14)
const IRON := Color(0.16, 0.16, 0.17)
## The stylized twins' colours (a step lighter: the painted light is darker than the classic's).
const STY_GAIN := 1.25
## A root's radius at its top and at its tip (m); a leaf's length (m); a strand's sideways wander (m a meter).
const ROOT_RADIUS := Vector2(0.07, 0.008)
const LEAF := 0.16
const WANDER := 0.22
## Sides of a root's section (5 reads round at the game's camera).
const SIDES := 5

var kit: ArenaKit
var stone: Masonry
var _see := {}
var _mats := {}


func _init(arena_kit: ArenaKit) -> void:
	kit = arena_kit
	stone = arena_kit.masonry


## The room's ashlar standing at `base_y`, opening round the paladin behind it (masonry.gdshader see_through).
func stone_see(base_y := 0.0) -> ShaderMaterial:
	var key := snappedf(base_y, 0.5)
	if not _see.has(key):
		var m := stone.ashlar(key).duplicate() as ShaderMaterial
		m.set_shader_parameter(&"see_through", 1.0)
		_see[key] = m
	return _see[key]


## One material of a family (edge_piece.gdshader), its stylized twin by the visual profile.
func material(family: StringName) -> ShaderMaterial:
	if _mats.has(family):
		return _mats[family]
	var c: Color = {&"bark": BARK, &"ivy": Color.WHITE, &"iron": IRON}[family]
	var m := ShaderMaterial.new()
	m.shader = SHADER
	m.set_shader_parameter(&"color", c)
	if family == &"iron":
		m.set_shader_parameter(&"roughness", 0.55)
		m.set_shader_parameter(&"metal", 0.6)
		m.set_shader_parameter(&"grain", 0.05)
	VisualProfile.vary(m, {&"shader": SHADER_PAINT, &"shader_parameter/color": c * STY_GAIN})
	_mats[family] = m
	return m


## A column broken off at `height` (m) on its plinth, the break jagged (three chunks still on it, askew) and two of
## its drums fallen beside it toward `fall` (a floor direction). foot: the middle of its base on the ground.
func broken_pillar(foot: Vector3, radius := 0.5, height := 3.0, fall := Vector2(1, 0), seed_ := 0) -> void:
	var r := _rng(foot, seed_)
	var m := stone_see(foot.y)
	stone.block(foot, Vector3(radius * 2.6, 0.32, radius * 2.6), r.randf() * TAU, m, false)
	var shaft := height - 0.32 - radius * 0.5
	stone.fluted(foot + Vector3(0, 0.32, 0), radius, shaft, 16, 0.035, m)
	var top := foot + Vector3(0, 0.32 + shaft, 0)
	for i in 3:
		var a := r.randf() * TAU
		var at := top + Vector3(cos(a), 0, sin(a)) * radius * r.randf_range(0.1, 0.45)
		var mi := stone.box(at + Vector3(0, radius * 0.22, 0), Vector3(radius * r.randf_range(0.7, 1.1), radius * r.randf_range(0.35, 0.7), radius * 0.8), a, m, false)
		mi.basis = mi.basis * Basis.from_euler(Vector3(r.randf_range(-0.35, 0.35), 0, r.randf_range(-0.35, 0.35)))
	var dir := fall.normalized() if fall.length() > 0.01 else Vector2(1, 0)
	for i in 2:
		var length := radius * r.randf_range(1.1, 1.6)
		var drum := stone.fluted(Vector3.ZERO, radius, length, 16, 0.035, m)
		var along := dir.rotated(r.randf_range(-0.5, 0.5))
		var place := Vector2(foot.x, foot.z) + dir * (radius * 2.2 + i * radius * 2.4) + dir.orthogonal() * r.randf_range(-0.6, 0.6)
		# lying on its side, its axis across the fall a little turned, sunk a hand in the floor
		var lie := Basis(Vector3.UP, atan2(along.x, along.y)) * Basis(Vector3.RIGHT, PI * 0.5)
		drum.transform = Transform3D(lie, Vector3(place.x, foot.y + radius * 0.85, place.y))


## A pointed arch broken in its crown between two piers: foot is the middle of its opening on the ground, facing the
## way it looks, span its width, spring the springing line's height; `gap` (m across the opening from its middle) is
## the stones gone (Masonry.broken_arch).
func broken_arch(foot: Vector3, facing := Vector2(0, 1), span := 4.0, spring := 3.2, gap := Vector2(-0.3, 1.4)) -> void:
	var m := stone_see(foot.y)
	var right := Basis(Vector3.UP, atan2(facing.x, facing.y)) * Vector3.RIGHT
	for side: float in [-1.0, 1.0]:
		stone.block(foot + right * side * (span * 0.5 + 0.4), Vector3(0.8, spring, 0.9), atan2(facing.x, facing.y), m, false)
		stone.block(foot + right * side * (span * 0.5 + 0.4) + Vector3(0, spring, 0), Vector3(0.95, 0.18, 1.0), atan2(facing.x, facing.y), m, false)
	stone.broken_arch(foot + Vector3(0, 0.18, 0), facing, span, spring, 0.55, 0.85, m, gap)


## A heap of fallen blocks `size` (m) across at `at` on the ground: five to seven bevelled stones askew, the big ones
## below.
func rubble(at: Vector3, size := 1.6, seed_ := 0) -> void:
	var r := _rng(at, seed_)
	var m := stone_see(at.y)
	var n := r.randi_range(5, 7)
	for i in n:
		var big := 1.0 - float(i) / n * 0.55
		var dims := Vector3(r.randf_range(0.5, 0.9), r.randf_range(0.3, 0.55), r.randf_range(0.4, 0.75)) * size * 0.6 * big
		var off := Vector2(r.randf_range(-0.5, 0.5), r.randf_range(-0.5, 0.5)) * size * (0.3 + 0.7 * big)
		var y := dims.y * 0.45 + (1.0 - big) * size * 0.32
		var mi := stone.box(at + Vector3(off.x, y, off.y), dims, r.randf() * TAU, m, false)
		mi.basis = mi.basis * Basis.from_euler(Vector3(r.randf_range(-0.3, 0.3), 0, r.randf_range(-0.3, 0.3)))


## A curtain of dead roots hanging from `top` (the middle of a ledge, a vault, a broken floor's edge), `width` m along
## `along` (a floor direction), up to `length` m down: thin tapering roots that wander and split, one mesh.
func root_curtain(top: Vector3, width := 3.0, length := 3.0, along := Vector2(1, 0), seed_ := 0) -> MeshInstance3D:
	var r := _rng(top, seed_)
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var side := Vector3(along.x, 0, along.y).normalized()
	var n := maxi(4, roundi(width * 4.0))
	for i in n:
		var start := top + side * (float(i) / maxf(n - 1, 1) - 0.5) * width + side.cross(Vector3.UP) * r.randf_range(-0.15, 0.15)
		var l := length * r.randf_range(0.35, 1.0)
		var spine := _strand(start, l, side, r)
		_tube(st, spine, ROOT_RADIUS.x * r.randf_range(0.6, 1.0), ROOT_RADIUS.y, r.randf_range(0.75, 1.0))
		# a branch from part way down
		if r.randf() < 0.5 and spine.size() > 4:
			var k := r.randi_range(1, spine.size() / 2)
			var twig := _strand(spine[k], l * r.randf_range(0.25, 0.45), side, r)
			_tube(st, twig, ROOT_RADIUS.x * 0.4, ROOT_RADIUS.y, r.randf_range(0.7, 0.95))
	return _put(st, &"bark")


## Ivy hanging from `top` `width` m along `along` and up to `length` m down, leaves on its strands turned toward
## `facing` (a floor direction, where it is seen from), one mesh, two greens by leaf.
func ivy(top: Vector3, width := 2.0, length := 2.4, along := Vector2(1, 0), facing := Vector2(0, 1), seed_ := 0) -> MeshInstance3D:
	var r := _rng(top, seed_)
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var side := Vector3(along.x, 0, along.y).normalized()
	var out := Vector3(facing.x, 0, facing.y).normalized()
	var n := maxi(3, roundi(width * 3.0))
	for i in n:
		var start := top + side * (float(i) / maxf(n - 1, 1) - 0.5) * width
		var spine := _strand(start, length * r.randf_range(0.4, 1.0), side, r)
		_tube(st, spine, 0.014, 0.006, 0.9, IVY * 1.6)
		for p in spine.size():
			for k in 2:
				if r.randf() < 0.25:
					continue
				var size := LEAF * r.randf_range(0.6, 1.15) * (1.0 - 0.4 * float(p) / spine.size())
				var tone := IVY.lerp(IVY_YOUNG, r.randf()) * r.randf_range(0.85, 1.15)
				var lean := side.rotated(out, r.randf_range(-1.2, 1.2)) * (1.0 if k == 0 else -1.0)
				_leaf(st, spine[p] + out * 0.02, lean, out.rotated(side, r.randf_range(-0.6, 0.6)), size, tone)
	return _put(st, &"ivy")


## A chain from `top` straight down `length` m with a stone weight (a block bound in iron) at its end; `size` scales
## the links (ArenaKit.chains) and the weight.
func chain_weight(top: Vector3, length := 3.0, size := 1.0) -> void:
	var foot := top - Vector3(0, length, 0)
	var before := kit.root.get_child_count()
	kit.chains([[top, foot]], 0.0, size)
	for i in range(before, kit.root.get_child_count()):
		var mm := kit.root.get_child(i) as MultiMeshInstance3D
		if mm:
			mm.material_override = material(&"iron")
	var w := 0.5 * size
	stone.box(foot - Vector3(0, w * 0.55, 0), Vector3(w, w * 1.1, w), 0.4, stone_see(foot.y - w), false)
	var band := MeshInstance3D.new()
	var b := BoxMesh.new()
	b.size = Vector3(w * 1.06, w * 0.14, w * 1.06)
	band.mesh = b
	band.transform = Transform3D(Basis(Vector3.UP, 0.4), foot - Vector3(0, w * 0.2, 0))
	band.material_override = material(&"iron")
	stone.root.add_child(band)


func _rng(at: Vector3, seed_: int) -> RandomNumberGenerator:
	var r := RandomNumberGenerator.new()
	r.seed = hash([Vector3i(at * 10.0), seed_])
	return r


## A hanging strand's points from `start` down `length` m, a point every 0.15 m, wandering along `side` and toward
## and away from the eye.
func _strand(start: Vector3, length: float, side: Vector3, r: RandomNumberGenerator) -> PackedVector3Array:
	var pts := PackedVector3Array()
	var steps := maxi(3, ceili(length / 0.15))
	var drift := Vector3.ZERO
	var deep := side.cross(Vector3.UP)
	for i in steps + 1:
		pts.append(start + Vector3(0, -length * i / steps, 0) + drift)
		drift += side * r.randf_range(-1.0, 1.0) * WANDER * 0.15 + deep * r.randf_range(-0.5, 0.5) * WANDER * 0.08
	return pts


## A tapering tube of SIDES sides along `spine`, `from` radius at the top to `to` at the tip, vertex colour `tint`
## times `tone`.
func _tube(st: SurfaceTool, spine: PackedVector3Array, from: float, to: float, tone: float, tint := Color.WHITE) -> void:
	var rings: Array = []
	for i in spine.size():
		var along := (spine[mini(i + 1, spine.size() - 1)] - spine[maxi(i - 1, 0)]).normalized()
		var a := along.cross(Vector3.FORWARD if absf(along.z) < 0.9 else Vector3.RIGHT).normalized()
		var b := along.cross(a)
		var rad := lerpf(from, to, float(i) / maxf(spine.size() - 1, 1))
		var ring: Array[Vector3] = []
		for s in SIDES:
			var t := TAU * s / SIDES
			ring.append(spine[i] + (a * cos(t) + b * sin(t)) * rad)
		rings.append(ring)
	st.set_color(Color(tint.r * tone, tint.g * tone, tint.b * tone))
	for i in rings.size() - 1:
		for s in SIDES:
			var p0: Vector3 = rings[i][s]
			var p1: Vector3 = rings[i][(s + 1) % SIDES]
			var q0: Vector3 = rings[i + 1][s]
			var q1: Vector3 = rings[i + 1][(s + 1) % SIDES]
			var n := (p1 - p0).cross(q0 - p0).normalized()
			st.set_normal(n)
			st.add_vertex(p0)
			st.add_vertex(q0)
			st.add_vertex(p1)
			st.add_vertex(p1)
			st.add_vertex(q0)
			st.add_vertex(q1)


## A pointed leaf (a flat diamond) at `at`, its length along `lean`, its face toward `face`.
func _leaf(st: SurfaceTool, at: Vector3, lean: Vector3, face: Vector3, size: float, tone: Color) -> void:
	var across := lean.cross(face).normalized() * size * 0.32
	var tip := at + lean.normalized() * size
	var mid := at + lean.normalized() * size * 0.45
	st.set_color(tone)
	st.set_normal(face)
	for tri: Array in [[at, mid - across, mid + across], [mid - across, tip, mid + across]]:
		for p: Vector3 in tri:
			st.add_vertex(p)


func _put(st: SurfaceTool, family: StringName) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.mesh = st.commit()
	mi.material_override = material(family)
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	stone.root.add_child(mi)
	return mi
