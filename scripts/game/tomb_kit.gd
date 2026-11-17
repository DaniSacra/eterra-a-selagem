class_name TombKit
extends RefCounted
## The funerary pieces every crypt shares (cycle C12, spec docs/art/cycle12_arenas_spec.md 1.2 and 1.3): the
## sarcophagus with its lid, frieze and the raised sword in low relief, the iron lantern, the gothic pinnacle with the
## sword panel, the raised sword itself (all four taken out of the Seal Chamber, with its numbers: BossChamber calls
## them and looks the same), and the new ones of the arenas: the column (whole or broken, with the spring of an arch),
## the low broken wall, the great tomb on its steps, the funerary niche with shelves, the iron grille of a closed door
## and the plain slab of a grave in the floor. Built of Masonry (one material per kind of stone, never one per piece).
## Each piece stands exactly on its footprint: what blocks is the layout's ArenaObstacle, never this.

## The old gold of the ironwork and the edges (inlaid metal, never bright yellow), and the iron.
const GOLD := Color(0.478, 0.384, 0.22)
const IRON := Color(0.06, 0.065, 0.07)
## The raised sword (Eterra's, spec 5.4 of the chamber): the guard's width and the blade's length (shares of the
## sword's), the widths of blade at the guard, grip, guard's bar and pommel (shares of its length), the blade's taper
## in steps from the guard to the point. Proportions of a sword, never of a cross (O-1 of the C11 QA).
const GUARD_SHARE := 0.2
const SWORD_BLADE := 0.74
const SWORD_WIDTH := Vector4(0.1, 0.03, 0.035, 0.07)
const SWORD_TAPER: Array[float] = [1.0, 0.85, 0.68, 0.5, 0.32, 0.14]
## A sarcophagus: its lid (height, how far it stands out), the frieze round the chest (height, how far out, its middle
## as a share of the chest's height) and the gold thread under it, the gold edge round the lid's top.
const SARC_LID := Vector2(0.2, 0.1)
const SARC_FRIEZE := Vector3(0.16, 0.07, 0.7)
const SARC_FRIEZE_GOLD := 0.05
const SARC_GOLD := 0.03
## A lantern: its stone post (size), the iron cage (width, height), its pointed roof, the flame's size.
const LANTERN_POST := Vector3(0.6, 1.0, 0.6)
const LANTERN_CAGE := Vector2(0.45, 0.75)
const LANTERN_ROOF := 0.3
const LANTERN_FLAME_SIZE := 0.12
## A gothic pinnacle (base width, body's top, spire) and its panel with the raised sword (width, height, its foot over
## the ground) and the gold thread round it.
const PINNACLE := Vector3(0.9, 2.8, 0.6)
const PANEL := Vector3(0.5, 1.1, 1.5)
const PANEL_GOLD := 0.03
## A column (spec 1.3): the round base's height and the plinth under it, the shaft's radius as a share of the base's
## (the collision's), the capital (height, how far it stands out) and the spring of an arch above it, turned to the
## back of the room (bearing BACK_BEARING, away from the camera): its rise and reach.
const COLUMN_PLINTH := 0.18
const COLUMN_BASE := 0.32
const COLUMN_SHAFT := 0.77
const COLUMN_CAPITAL := Vector2(0.45, 0.16)
const COLUMN_SPRING := Vector2(0.6, 1.1)
const BACK_BEARING := 325.0
## A broken column's fracture: how many jagged blocks crown it and how far they lean.
const FRACTURE_TEETH := 4
const FRACTURE_TILT := 0.35
## A low broken wall: courses of blocks (length range), its top uneven between these heights (shares of its top).
const WALL_BLOCK := Vector2(0.5, 0.95)
const WALL_TOP_LOW := 0.78
## The great tomb's two steps (each this tall; they are part of its footprint).
const TOMB_STEP := 0.15
## A niche's shelves: how many, their thickness and how far they stand out of the niche's back.
const SHELVES := 3
const SHELF := Vector2(0.08, 0.32)
## A grave slab in the floor: the moulding round it (width), how far it stands up, its worn diamond (share of width).
const SLAB_FRAME := 0.06
const SLAB_LIFT := 0.012
const SLAB_DIAMOND := 0.32
## The iron grille that closes a door not used: its height, bars apart, a bar's thickness.
const GRILLE := Vector3(0.9, 0.22, 0.05)
## A stone bench (E5 spec 0.3, the "broken benches" of the old church's nave): its seat (height, thickness, how far it
## stands out over the feet), its back (thickness, top), its two feet (width as a share of its depth, how far in from
## each end); broken: the share of the back left, and the piece fallen at its foot (size).
const BENCH_SEAT := Vector3(0.45, 0.1, 0.04)
const BENCH_BACK := Vector2(0.12, 0.9)
const BENCH_FOOT := Vector2(0.75, 0.25)
const BENCH_BROKEN := 0.5
const BENCH_FALLEN := Vector3(0.7, 0.14, 0.32)


## What a lantern burns: glass, flame, light colour, energy, range, attenuation (the chamber's violet, the crypts'
## warm). shadow: its light casts shadows (counted against the arena's 8).
class Lamp:
	var glass := Color.WHITE
	var flame := Color.WHITE
	var light := Color.WHITE
	var energy := 1.5
	var range_ := 4.5
	var attenuation := 1.3

	func _init(g: Color, f: Color, l: Color, e := 1.5, r := 4.5, a := 1.3) -> void:
		glass = g
		flame = f
		light = l
		energy = e
		range_ = r
		attenuation = a


## The warm iron lanterns of the arenas' doors and bridges (the chamber builds its violet one from its own numbers).
static var WARM := Lamp.new(Color(1.0, 0.62, 0.3), Color(1.9, 1.0, 0.35), Color(1.0, 0.66, 0.38))

var root: Node3D
var m: Masonry
var _gold_mat: StandardMaterial3D
var _iron_mat: StandardMaterial3D
var _unlit_mats := {}


func _init(masonry: Masonry) -> void:
	m = masonry
	root = masonry.root


# ---------- out of the Seal Chamber ----------

## A sarcophagus standing at `base` (the middle of its foot), turned `yaw`: a chamfered chest `size` (length, depth,
## height) with a frieze, a lid (lid: its height and overhang) with a gold edge and the raised sword `sword` long in low
## relief (in `sword_mat`; null: gold), a sunk panel on its +z face. stone, light (lid and frieze) and hollow (the panel)
## are its stones.
func sarcophagus(base: Vector3, yaw: float, size: Vector3, stone: Material, light: Material, hollow: Material, sword: float,
		sword_mat: Material = null, lid_size := SARC_LID) -> Vector3:
	var basis := Basis(Vector3.UP, yaw)
	m.block(base, Vector3(size.x, size.z, size.y), yaw, stone, false)
	m.block(base, Vector3(size.x + 0.1, 0.12, size.y + 0.1), yaw, stone, false)
	var frieze := base + Vector3(0, size.z * SARC_FRIEZE.z, 0)
	m.box(frieze, Vector3(size.x + SARC_FRIEZE.y * 2.0, SARC_FRIEZE.x, size.y + SARC_FRIEZE.y * 2.0), yaw, light, false)
	bar(frieze - Vector3(0, SARC_FRIEZE.x * 0.5 + SARC_FRIEZE_GOLD * 0.5, 0),
		Vector3(size.x + SARC_FRIEZE.y * 2.0, SARC_FRIEZE_GOLD, size.y + SARC_FRIEZE.y * 2.0), yaw, gold())
	var lid := base + Vector3(0, size.z, 0)
	m.block(lid, Vector3(size.x + lid_size.y * 2.0, lid_size.x, size.y + lid_size.y * 2.0), yaw, light, false)
	var top := lid + Vector3(0, lid_size.x, 0)
	var face := basis * Vector3(0, 0, size.y * 0.5 + 0.005)
	m.box(base + Vector3(0, size.z * 0.45, 0) + face, Vector3(size.x * 0.7, size.z * 0.45, 0.02), yaw, hollow, false)
	var g := gold()
	var w := size.x + lid_size.y * 2.0 - 0.06
	var d := size.y + lid_size.y * 2.0 - 0.06
	for sd: float in [-1.0, 1.0]:
		bar(top + basis * Vector3(0, 0.005, sd * d * 0.5), Vector3(w, 0.012, SARC_GOLD), yaw, g)
		bar(top + basis * Vector3(sd * w * 0.5, 0.005, 0), Vector3(SARC_GOLD, 0.012, d), yaw, g)
	sword_relief(top, basis, Vector3(1, 0, 0), Vector3(0, 0, 1), sword, sword_mat if sword_mat != null else g, 0.03)
	return top


## The raised sword laid at `at` (its middle), its length along `along`, its width along `across` (both in the basis'
## frame), `size` long: the blade far wider than the grip narrowing to the point, a short slim guard with its tips
## falling, the thin grip, a knob of a pommel; in `mat`, standing `relief` meters out. A sword, never a cross.
func sword_relief(at: Vector3, basis: Basis, along: Vector3, across: Vector3, size: float, mat: Material, relief: float) -> void:
	var o := across.cross(along).normalized() * relief * 0.5
	var foot := -size * 0.5
	var blade := size * SWORD_BLADE
	var guard := size * GUARD_SHARE
	var bw := size * SWORD_WIDTH.x
	var b0 := foot + size - blade
	var steps := SWORD_TAPER.size()
	for i in steps:
		var t0 := float(i) / steps
		var t1 := float(i + 1) / steps
		rel(at, basis, along * (b0 + blade * (t0 + t1) * 0.5) + o, along, across,
			Vector3(blade / steps + 0.01, bw * SWORD_TAPER[i], relief), mat)
	rel(at, basis, along * (b0 - size * 0.015) + o, along, across, Vector3(size * SWORD_WIDTH.z, guard, relief), mat)
	for sd: float in [-1.0, 1.0]:
		rel(at, basis, along * (b0 - size * 0.04) + across * sd * guard * 0.48 + o, along, across,
			Vector3(size * 0.05, size * SWORD_WIDTH.z, relief), mat)
	var pommel := size * SWORD_WIDTH.w
	var grip := b0 - size * 0.03 - foot - pommel
	rel(at, basis, along * (foot + pommel + grip * 0.5) + o, along, across, Vector3(grip, size * SWORD_WIDTH.y, relief), mat)
	rel(at, basis, along * (foot + pommel * 0.5) + o, along, across, Vector3(pommel, pommel, relief * 1.3), mat)


## A small block of a relief: its middle at `at` + basis * offset, its size along, across and out.
func rel(at: Vector3, basis: Basis, offset: Vector3, along: Vector3, across: Vector3, size: Vector3, mat: Material) -> void:
	var mi := m.box(at + basis * offset, size, 0.0, mat, false)
	mi.basis = basis * Basis(along, across, along.cross(across))


## A thin bar (gold edges and threads), not merged.
func bar(center: Vector3, size: Vector3, yaw: float, mat: Material) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = size
	mi.mesh = bm
	mi.transform = Transform3D(Basis(Vector3.UP, yaw), center)
	mi.material_override = mat
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	root.add_child(mi)
	return mi


func gold() -> StandardMaterial3D:
	if _gold_mat == null:
		_gold_mat = StandardMaterial3D.new()
		_gold_mat.albedo_color = GOLD
		_gold_mat.metallic = 0.7
		_gold_mat.roughness = 0.4
	return _gold_mat


func iron() -> StandardMaterial3D:
	if _iron_mat == null:
		_iron_mat = StandardMaterial3D.new()
		_iron_mat.albedo_color = IRON
		_iron_mat.metallic = 0.6
		_iron_mat.roughness = 0.5
		_iron_mat.rim_enabled = true
		_iron_mat.rim = 0.2
	return _iron_mat


func unlit(c: Color) -> StandardMaterial3D:
	if not _unlit_mats.has(c):
		var u := StandardMaterial3D.new()
		u.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		u.albedo_color = c
		u.disable_receive_shadows = true
		_unlit_mats[c] = u
	return _unlit_mats[c]


## An iron lantern on a stone post at `base`, its face along yaw: an iron cage with a pointed roof, glass with a small
## flame, the lamp's light on the floor and the stone near it (cull: what it lights). Returns the light.
func lantern(base: Vector3, yaw: float, mat: Material, lamp: Lamp, cull := ArenaKit.WARM_MASK, post := LANTERN_POST) -> OmniLight3D:
	m.block(base, Vector3(post.x + 0.12, Masonry.CURB, post.z + 0.12), yaw, mat)
	m.block(base, post, yaw, mat)
	var y := base.y + post.y
	var c := LANTERN_CAGE
	var foot := Vector3(base.x, 0.0, base.z)
	var ir := iron()
	m.box(foot + Vector3(0, y + 0.03, 0), Vector3(c.x + 0.08, 0.06, c.x + 0.08), yaw, ir, false)
	m.box(foot + Vector3(0, y + c.y - 0.03, 0), Vector3(c.x + 0.1, 0.06, c.x + 0.1), yaw, ir, false)
	var basis := Basis(Vector3.UP, yaw)
	for sx: float in [-1.0, 1.0]:
		for sz: float in [-1.0, 1.0]:
			m.box(foot + basis * Vector3(sx * c.x * 0.5, y + c.y * 0.5, sz * c.x * 0.5), Vector3(0.04, c.y, 0.04), yaw, ir, false)
	m.point(foot + Vector3(0, y + c.y, 0), c.x + 0.12, LANTERN_ROOF, yaw, 0.0, ir)
	var glass := MeshInstance3D.new()
	var gb := BoxMesh.new()
	gb.size = Vector3(c.x - 0.04, c.y - 0.1, c.x - 0.04)
	glass.mesh = gb
	glass.material_override = unlit(lamp.glass)
	glass.transform = Transform3D(basis, foot + Vector3(0, y + c.y * 0.5, 0))
	glass.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	root.add_child(glass)
	var flame := MeshInstance3D.new()
	flame.mesh = ArenaKit.tongue(Vector2(LANTERN_FLAME_SIZE * 0.6, LANTERN_FLAME_SIZE * 1.4), lamp.flame)
	flame.position = foot + Vector3(0, y + c.y * 0.35, 0) + (basis * Vector3(0, 0, c.x * 0.5 + 0.02))
	flame.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	root.add_child(flame)
	var l := OmniLight3D.new()
	l.position = foot + Vector3(0, y + c.y * 0.5, 0) + basis * Vector3(0, 0, 0.4)
	l.light_color = lamp.light
	l.light_energy = lamp.energy
	l.omni_range = lamp.range_
	l.omni_attenuation = lamp.attenuation
	l.light_cull_mask = cull
	root.add_child(l)
	return l


## A gothic pinnacle at `base` facing yaw: a base, a tall body, a spire; on its face along yaw (and on the one most
## turned to the camera, if another) a pointed panel with the raised sword in relief and a thread of gold. size: as
## PINNACLE.
func pinnacle(base: Vector3, yaw: float, mat: Material, size := PINNACLE) -> void:
	var w := size.x
	m.block(base, Vector3(w + 0.16, 0.35, w + 0.16), yaw, mat)
	m.block(base + Vector3(0, 0.35, 0), Vector3(w, size.y - 0.35, w), yaw, mat)
	m.block(base + Vector3(0, size.y - 0.25, 0), Vector3(w + 0.14, 0.18, w + 0.14), yaw, mat)
	m.point(base + Vector3(0, size.y - 0.07, 0), w * 0.92, size.z, yaw, 0.0, mat)
	var faces: Array[float] = [yaw]
	var cam := deg_to_rad(Feel.live().cam_yaw)
	var to_cam := atan2(sin(cam), cos(cam))
	var best := yaw
	for k in 4:
		var f := yaw + PI * 0.5 * k
		if absf(angle_difference(f, to_cam)) < absf(angle_difference(best, to_cam)):
			best = f
	if absf(angle_difference(best, yaw)) > 0.1:
		faces.append(best)
	var hollow := m.stone(0.0, Color.WHITE * 0.55)
	for f in faces:
		var basis := Basis(Vector3.UP, f)
		var face := base + basis * Vector3(0, PANEL.z + PANEL.y * 0.5, w * 0.5 + 0.01)
		m.box(face, Vector3(PANEL.x, PANEL.y - PANEL.x * 0.3, 0.03), f, hollow, false)
		var tip := m.box(face + Vector3(0, PANEL.y * 0.5 - PANEL.x * 0.15, 0), Vector3(PANEL.x * 0.5, PANEL.x * 0.5, 0.03), f, hollow, false)
		tip.basis = basis * Basis(Vector3.BACK, PI * 0.25)
		m.pointed_arch(base + basis * Vector3(0, PANEL.z - 0.02, w * 0.5 + 0.02), Vector2(sin(f), cos(f)), PANEL.x, PANEL.y + 0.02, 0.06, 0.05, mat)
		sword_relief(face + basis * Vector3(0, 0, 0.03), basis, Vector3(0, 1, 0), Vector3(1, 0, 0), PANEL.y * 0.85, mat, 0.03)
		for sd: float in [-1.0, 1.0]:
			bar(face + basis * Vector3(sd * (PANEL.x * 0.5 + 0.02), -PANEL.x * 0.15, 0.02), Vector3(PANEL_GOLD, PANEL.y - PANEL.x * 0.3, 0.01), f, gold())
		bar(face + basis * Vector3(0, -PANEL.y * 0.5 + PANEL.x * 0.15 - 0.02, 0.02), Vector3(PANEL.x + 0.04, PANEL_GOLD, 0.01), f, gold())


# ---------- new in the arenas (spec 1.3) ----------

## A column on a footprint of radius r at `at` (the collision's circle): a square plinth inside the circle, a round
## base of radius r, the shaft, and, if whole, a capital at top - COLUMN_SPRING.x with the spring of an arch leaning
## to the back of the room up to `top`; if broken, its shaft ends at `top` in a fracture of jagged blocks.
func column(at: Vector2, r: float, top: float, mat: Material, broken: bool) -> void:
	var foot := Vector3(at.x, 0.0, at.y)
	var shaft_r := r * COLUMN_SHAFT
	m.block(foot, Vector3(r * 1.41, COLUMN_PLINTH, r * 1.41), PI * 0.25, mat, false)
	m.shaft(foot + Vector3(0, COLUMN_PLINTH, 0), r * 0.98, COLUMN_BASE - COLUMN_PLINTH, mat)
	m.shaft(foot + Vector3(0, COLUMN_BASE, 0), shaft_r * 1.12, 0.12, mat)
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(Vector2i(at * 10.0))
	if broken:
		var stub := top - 0.35
		m.shaft(foot + Vector3(0, COLUMN_BASE, 0), shaft_r, stub - COLUMN_BASE, mat)
		# the fracture: jagged blocks leaning out of the stump, the highest at `top`
		var turn := rng.randf() * TAU
		for i in FRACTURE_TEETH:
			var a := turn + TAU * i / FRACTURE_TEETH
			var h := 0.35 * (1.0 - float(i) / FRACTURE_TEETH) + 0.08
			var tooth := m.box(foot + Vector3(cos(a) * shaft_r * 0.45, stub + h * 0.5, sin(a) * shaft_r * 0.45),
				Vector3(shaft_r * 0.9, h, shaft_r * 0.8), -a, mat, false)
			tooth.rotate_object_local(Vector3.BACK, rng.randf_range(-FRACTURE_TILT, FRACTURE_TILT))
		return
	var cap_y := top - COLUMN_SPRING.x - COLUMN_CAPITAL.x
	m.shaft(foot + Vector3(0, COLUMN_BASE, 0), shaft_r, cap_y - COLUMN_BASE, mat)
	m.shaft(foot + Vector3(0, cap_y - 0.1, 0), shaft_r * 1.1, 0.1, mat)
	m.block(foot + Vector3(0, cap_y, 0), Vector3(shaft_r * 2.0 + COLUMN_CAPITAL.y * 2.0, COLUMN_CAPITAL.x, shaft_r * 2.0 + COLUMN_CAPITAL.y * 2.0), 0.0, mat, false)
	# the spring of an arch: three voussoirs climbing toward the back of the room
	var back := Vector2.from_angle(deg_to_rad(BACK_BEARING - 90.0))
	var y := cap_y + COLUMN_CAPITAL.x
	var yaw := atan2(back.y, -back.x)
	for k in 3:
		var t := (k + 0.5) / 3.0
		var reach := COLUMN_SPRING.y * t * t
		var vo := m.box(Vector3(at.x + back.x * reach, y + COLUMN_SPRING.x * t, at.y + back.y * reach),
			Vector3(shaft_r * 1.6, COLUMN_SPRING.x / 3.0 + 0.06, shaft_r * 1.5), yaw, mat, false)
		vo.rotate_object_local(Vector3.BACK, -0.5 * t)


## A low broken wall along a to b, `width` across and up to `top` (the capsule of the layout, its round ends in): a
## row of blocks, its top uneven, a fallen block or two inside its ends. Shots fly over it.
func low_wall(a: Vector2, b: Vector2, width: float, top: float, mat: Material) -> void:
	var d := b - a
	var length := d.length()
	var dir := d / maxf(length, 0.001)
	var yaw := atan2(-dir.y, dir.x)
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(Vector2i((a + b) * 10.0))
	# a curb at the foot, the whole length
	m.block(Vector3((a.x + b.x) * 0.5, 0.0, (a.y + b.y) * 0.5), Vector3(length, 0.18, width), yaw, mat, false)
	var s := width * 0.5
	while s < length - width * 0.5 - 0.1:
		var l := minf(rng.randf_range(WALL_BLOCK.x, WALL_BLOCK.y), length - width * 0.5 - s)
		var h := top * rng.randf_range(WALL_TOP_LOW, 1.0)
		var c := a + dir * (s + l * 0.5)
		# the lower course full, the top course broken off here and there
		m.block(Vector3(c.x, 0.18, c.y), Vector3(l - 0.03, (h - 0.18) * 0.55, width * 0.94), yaw, mat)
		if rng.randf() > 0.2:
			var up := 0.18 + (h - 0.18) * 0.55
			m.block(Vector3(c.x, up, c.y), Vector3(l * rng.randf_range(0.7, 0.98), h - up, width * 0.88), yaw, mat)
		s += l
	# a fallen block inside each end
	for e: Vector2 in [a + dir * width * 0.3, b - dir * width * 0.3]:
		var blk := m.box(Vector3(e.x, 0.14, e.y), Vector3(width * 0.55, 0.26, width * 0.6), yaw + rng.randf_range(-0.5, 0.5), mat)
		blk.rotate_object_local(Vector3.BACK, rng.randf_range(-0.2, 0.2))


## The great tomb on a footprint `half` (half its size, x along its length) at `at`, turned yaw, `top` high: two
## steps (part of the footprint) and the sarcophagus on them, a step lighter, with a long sword in stone on its lid.
func tomb(at: Vector2, half: Vector2, yaw: float, top: float, stone: Material, light: Material, hollow: Material) -> Vector3:
	var foot := Vector3(at.x, 0.0, at.y)
	m.block(foot, Vector3(half.x * 2.0, TOMB_STEP, half.y * 2.0), yaw, stone, false)
	m.block(foot + Vector3(0, TOMB_STEP, 0), Vector3(half.x * 2.0 - 0.4, TOMB_STEP, half.y * 2.0 - 0.4), yaw, stone, false)
	var lid := Vector2(0.18, 0.08)
	var body := Vector3(half.x * 2.0 - 1.0, half.y * 2.0 - 0.9, top - TOMB_STEP * 2.0 - lid.x)
	return sarcophagus(foot + Vector3(0, TOMB_STEP * 2.0, 0), yaw, body, stone, light, hollow, body.x * 0.62, light, lid)


## A funerary niche going `deep` meters back into a wall (the wall leaves its gap, `width` wide, up to the spring of
## its head): its dark back (hollow) with a pointed head, a pointed frame on the wall's face, SHELVES shelves of stone
## with pots and plain bones (simple grey volumes) on them, or none (shelves false: a statue stands in it). foot: the
## middle of its sill on the wall's face; facing: out of the wall. Returns the floor of the niche (its middle).
func niche(foot: Vector3, facing: Vector2, width: float, height: float, deep: float, mat: Material, hollow: Material,
		bone: Material, shelves := true) -> Vector3:
	var yaw := atan2(facing.x, facing.y)
	var basis := Basis(Vector3.UP, yaw)
	var out := Vector3(facing.x, 0.0, facing.y)
	var straight := height - width * 0.4
	var back := foot - out * deep
	m.box(back + Vector3(0, straight * 0.5, 0), Vector3(width, straight, 0.1), yaw, hollow, false)
	var head := m.box(back + Vector3(0, straight, 0), Vector3(width * 0.7071, width * 0.7071, 0.1), yaw, hollow, false)
	head.basis = basis * Basis.from_scale(Vector3(1.0, 1.1, 1.0)) * Basis(Vector3.BACK, PI * 0.25)
	# its floor, its sides and the blind head between the spring and the wall's face, all of the dark stone
	m.box(foot - out * deep * 0.5 + Vector3(0, 0.08, 0), Vector3(width, 0.16, deep), yaw, mat, false)
	for sd: float in [-1.0, 1.0]:
		m.box(foot - out * deep * 0.5 + basis * Vector3(sd * (width * 0.5 + 0.05), straight * 0.5, 0), Vector3(0.1, straight, deep), yaw, hollow, false)
	m.box(foot - out * deep * 0.5 + Vector3(0, straight + 0.06, 0), Vector3(width + 0.2, 0.12, deep), yaw, hollow, false)
	m.pointed_arch(foot + out * 0.06, facing, width, height, 0.18, 0.2, mat)
	m.box(foot + Vector3(0, 0.08, 0) + out * 0.08, Vector3(width + 0.5, 0.16, 0.24), yaw, mat)
	if not shelves:
		return foot - out * deep * 0.5 + Vector3(0, 0.16, 0)
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(Vector3i(foot * 10.0))
	var mid := foot - out * deep * 0.5
	for k in SHELVES:
		var y := straight * (k + 0.6) / (SHELVES + 0.4)
		m.box(mid + Vector3(0, y, 0), Vector3(width - 0.02, SHELF.x, deep), yaw, mat, false)
		var x := -width * 0.5 + 0.2
		while x < width * 0.5 - 0.2:
			var p := mid + basis * Vector3(x, y + SHELF.x * 0.5, 0.0)
			if rng.randf() < 0.35:
				m.pot(p, rng.randf_range(0.28, 0.4))
				x += 0.32
			else:
				# a bundle of long bones, and now and then a round knob of a skull
				var bl := minf(rng.randf_range(0.35, 0.55), width * 0.5 - 0.1 - x)
				if bl < 0.2:
					break
				var q := p + basis * Vector3(bl * 0.5, 0.0, 0.0)
				m.box(q + Vector3(0, 0.04, 0), Vector3(bl, 0.07, 0.07), yaw + rng.randf_range(-0.15, 0.15), bone, false)
				m.box(q + Vector3(0, 0.1, 0), Vector3(bl * 0.9, 0.06, 0.06), yaw + rng.randf_range(-0.15, 0.15), bone, false)
				if rng.randf() < 0.4 and x + bl + 0.2 < width * 0.5:
					m.shaft(p + basis * Vector3(bl + 0.1, 0.0, 0.0), 0.08, 0.15, bone)
				x += bl + 0.12
	return mid + Vector3(0, 0.16, 0)


## A plain grave slab in the floor (spec 1.3, class A: nothing written on it): a darker slab with a moulded frame
## and a worn diamond in its middle, `size` (width, length), turned yaw; flat prisms (no bevel), barely proud.
func slab(at: Vector2, size: Vector2, yaw: float, mat: Material, frame: Material) -> void:
	var ax := Vector2(cos(yaw), -sin(yaw))
	var az := Vector2(-ax.y, ax.x)
	var rect := func(c: Vector2, half: Vector2, turn := 0.0) -> PackedVector2Array:
		var u := ax.rotated(turn)
		var v := az.rotated(turn)
		return PackedVector2Array([c - u * half.x - v * half.y, c + u * half.x - v * half.y, c + u * half.x + v * half.y, c - u * half.x + v * half.y])
	m.prism(rect.call(at, size * 0.5), 0.0, SLAB_LIFT, mat)
	for sd: float in [-1.0, 1.0]:
		m.prism(rect.call(at + ax * sd * (size.x * 0.5 - SLAB_FRAME * 0.5), Vector2(SLAB_FRAME * 0.5, size.y * 0.5)), 0.0, SLAB_LIFT * 1.6, frame)
		m.prism(rect.call(at + az * sd * (size.y * 0.5 - SLAB_FRAME * 0.5), Vector2(size.x * 0.5 - SLAB_FRAME, SLAB_FRAME * 0.5)), 0.0, SLAB_LIFT * 1.6, frame)
	var d := size.x * SLAB_DIAMOND * 0.5
	m.prism(PackedVector2Array([at - az * d * 1.4, at + ax * d, at + az * d * 1.4, at - ax * d]), 0.0, SLAB_LIFT * 1.6, frame)


## The iron grille of a door not used (spec 0.4): bars from a to b standing GRILLE.x high, a rail on top and at the foot.
func grille(a: Vector3, b: Vector3) -> void:
	var d := b - a
	var n := maxi(2, roundi(d.length() / GRILLE.y))
	var yaw := atan2(-d.z, d.x)
	var ir := iron()
	for i in n + 1:
		var p := a + d * float(i) / n
		m.box(p + Vector3(0, GRILLE.x * 0.5, 0), Vector3(GRILLE.z, GRILLE.x, GRILLE.z), 0.0, ir, false)
		m.point(p + Vector3(0, GRILLE.x, 0), GRILLE.z * 1.6, 0.1, 0.0, 0.0, ir)
	for y: float in [0.08, GRILLE.x - 0.12]:
		m.box((a + b) * 0.5 + Vector3(0, y, 0), Vector3(d.length(), 0.05, 0.04), yaw, ir, false)


## A stone bench on its footprint (E5 spec 0.3): two feet, the seat at BENCH_SEAT.x, its back along the -z side of its
## frame (`facing` the way one sits) up to BENCH_BACK.y; broken: half the back gone, that piece fallen at its foot inside
## the footprint, the seat cracked. `half`: half the footprint (x along its length), turned yaw (Masonry's turn).
func bench(at: Vector2, half: Vector2, yaw: float, mat: Material, broken := false) -> void:
	var basis := Basis(Vector3.UP, yaw)
	var foot := Vector3(at.x, 0.0, at.y)
	var deep := half.y * 2.0
	var long := half.x * 2.0
	for sd: float in [-1.0, 1.0]:
		m.block(foot + basis * Vector3(sd * (half.x - BENCH_FOOT.y), 0, 0), Vector3(0.22, BENCH_SEAT.x - BENCH_SEAT.y, deep * BENCH_FOOT.x), yaw, mat)
	var seat_y := BENCH_SEAT.x - BENCH_SEAT.y
	if broken:
		# the seat cracked in two, one half sagging a little
		for sd: float in [-1.0, 1.0]:
			var piece := m.box(foot + basis * Vector3(sd * long * 0.25, seat_y + BENCH_SEAT.y * 0.5, 0), Vector3(long * 0.5 - 0.03, BENCH_SEAT.y, deep), yaw, mat, false)
			if sd > 0.0:
				piece.rotate_object_local(Vector3.BACK, -0.05)
	else:
		m.box(foot + Vector3(0, seat_y + BENCH_SEAT.y * 0.5, 0), Vector3(long, BENCH_SEAT.y, deep), yaw, mat, false)
	var back_h := BENCH_BACK.y - BENCH_SEAT.x
	var back_z := -half.y + BENCH_BACK.x * 0.5
	var back_long := long * (BENCH_BROKEN if broken else 1.0)
	var back_x := -half.x + back_long * 0.5
	m.box(foot + basis * Vector3(back_x, BENCH_SEAT.x + back_h * 0.5, back_z), Vector3(back_long, back_h, BENCH_BACK.x), yaw, mat, false)
	if broken:
		# the back's other half fallen in front of the seat, still inside the footprint
		var fallen := m.box(foot + basis * Vector3(half.x * 0.45, BENCH_FALLEN.y * 0.5, half.y - BENCH_FALLEN.z * 0.5),
			Vector3(BENCH_FALLEN.x, BENCH_FALLEN.y, BENCH_FALLEN.z), yaw + 0.15, mat)
		fallen.rotate_object_local(Vector3.RIGHT, 0.12)

