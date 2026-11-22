class_name BattleMarks
extends Node3D
## What a fight leaves on the floor (Daniel, 2026-11-21: no blood; bone dust and cracks instead): a pale patch and two or
## three slivers of bone where an undead fell, a crack where a heavy blow landed on the floor (an enemy's circle of
## CRACK_FROM m or more: the guardians, Morvath) and where an elite or a guardian fell. Game makes one under the arena,
## so they go with the room. Decoration only: no collision, its own dice (the run's are never moved), at most MAX_* of
## each (the oldest gives its place), three draw calls, all under the floor's warnings.

const MAX_DUST := 32
const MAX_SLIVERS := 72
const MAX_CRACKS := 12
## The dust: colour as seen (sRGB), strength, the patch's width (m; an elite's is half as wide again).
const DUST := Color(0.36, 0.34, 0.3)
const DUST_ALPHA := 0.5
const DUST_SIZE := Vector2(0.8, 1.4)
const ELITE_WIDER := 1.5
const SLIVERS := Vector2i(2, 3)
const SLIVER_SPREAD := 0.6
## A circle this wide (m) cracks the floor; the crack's share of it and how dark it is.
const CRACK_FROM := 1.8
const CRACK_SHARE := 0.7
const CRACK_FELL := 1.3
const CRACK_COLOR := Color(0.02, 0.02, 0.025, 0.55)
const CRACK_ARMS := 6
const DUST_Y := 0.016
const CRACK_Y := 0.018
const SLIVER_Y := 0.03
const SEED := 9173
## The floor's room for a mark (m from its edge).
const MARGIN := 0.4

var game: Game
var dust: MultiMesh
var slivers: MultiMesh
var cracks: MultiMesh
var _rng := RandomNumberGenerator.new()
## The next place of each (ring buffers).
var _next := {}


static func make(g: Game) -> BattleMarks:
	var m := BattleMarks.new()
	m.name = "BattleMarks"
	m.game = g
	g.arena.add_child(m)
	return m


func _ready() -> void:
	_rng.seed = SEED
	var patch := ShaderMaterial.new()
	patch.shader = FloorScatter.PATCH_SHADER
	patch.render_priority = FloorScatter.PATCH_PRIORITY
	patch.set_shader_parameter(&"radial", 1.0)
	dust = _multi(PlaneMesh.new(), patch, MAX_DUST, true)
	var sliver := CapsuleMesh.new()
	sliver.radius = 0.022
	sliver.height = 0.22
	sliver.radial_segments = 5
	sliver.rings = 1
	var bone := StandardMaterial3D.new()
	bone.albedo_color = FloorScatter.BONE
	bone.roughness = 0.9
	slivers = _multi(sliver, bone, MAX_SLIVERS, false)
	var dark := StandardMaterial3D.new()
	dark.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	dark.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	dark.cull_mode = BaseMaterial3D.CULL_DISABLED
	dark.albedo_color = CRACK_COLOR
	dark.render_priority = FloorScatter.PATCH_PRIORITY
	cracks = _multi(_crack_mesh(), dark, MAX_CRACKS, false)
	game.horde.killed.connect(_on_killed)
	game.ground.zone_landed.connect(_on_landed)


func _on_killed(e: Enemy) -> void:
	if not _on_floor(e.pos):
		return
	if e.def.undead:
		var w := _rng.randf_range(DUST_SIZE.x, DUST_SIZE.y) * (ELITE_WIDER if e.def.elite else 1.0)
		var b := Basis(Vector3.UP, _rng.randf() * TAU).scaled(Vector3(w, 1.0, w * _rng.randf_range(0.6, 0.9)))
		# (PlaneMesh is 2 m a side: w is about half the patch, its soft border the rest)
		b = b.scaled(Vector3(0.6, 1.0, 0.6))
		var i := _put(dust, MAX_DUST, Transform3D(b, Vector3(e.pos.x, DUST_Y, e.pos.y)))
		dust.set_instance_color(i, Color(DUST.srgb_to_linear(), DUST_ALPHA))
		for k in _rng.randi_range(SLIVERS.x, SLIVERS.y):
			var q := e.pos + Vector2.from_angle(_rng.randf() * TAU) * _rng.randf_range(0.15, SLIVER_SPREAD)
			if _on_floor(q):
				var lie := Basis(Vector3.UP, _rng.randf() * TAU) * Basis(Vector3.FORWARD, PI * 0.5)
				_put(slivers, MAX_SLIVERS, Transform3D(lie, Vector3(q.x, SLIVER_Y, q.y)))
	if e.def.elite:
		_crack(e.pos, CRACK_FELL)


func _on_landed(z: Ground.Zone) -> void:
	if z.shape != Ground.Shape.CIRCLE or z.hazard > 0.0 or z.floor_own or z.power <= 0.0 or z.radius < CRACK_FROM:
		return
	_crack(z.pos, z.radius * CRACK_SHARE)


func _crack(at: Vector2, r: float) -> void:
	if _on_floor(at):
		var b := Basis(Vector3.UP, _rng.randf() * TAU).scaled(Vector3(r, 1.0, r))
		_put(cracks, MAX_CRACKS, Transform3D(b, Vector3(at.x, CRACK_Y, at.y)))


func _on_floor(p: Vector2) -> bool:
	return game.arena != null and game.arena.shape().contains(p, MARGIN)


func _put(mm: MultiMesh, most: int, xf: Transform3D) -> int:
	var i: int = _next.get(mm, 0)
	_next[mm] = (i + 1) % most
	mm.set_instance_transform(i, xf)
	mm.visible_instance_count = maxi(mm.visible_instance_count, i + 1)
	return i


func _multi(mesh: Mesh, mat: Material, most: int, colours: bool) -> MultiMesh:
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.use_colors = colours
	mm.mesh = mesh
	mm.instance_count = most
	mm.visible_instance_count = 0
	var mmi := MultiMeshInstance3D.new()
	mmi.multimesh = mm
	mmi.material_override = mat
	mmi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mmi.custom_aabb = AABB(Vector3(-80, -1, -80), Vector3(160, 4, 160))
	add_child(mmi)
	return mm


## Jagged arms from the middle, 1 m long, thinning to nothing (one mesh for every crack; each is turned and scaled).
func _crack_mesh() -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_normal(Vector3.UP)
	for k in CRACK_ARMS:
		var a := TAU * k / CRACK_ARMS + _rng.randf_range(-0.35, 0.35)
		var long := _rng.randf_range(0.6, 1.0)
		var p := Vector2.ZERO
		var w := 0.035
		for s in 3:
			var turn := a + _rng.randf_range(-0.45, 0.45)
			var q := p + Vector2.from_angle(turn) * long / 3.0
			var side := (q - p).normalized().orthogonal()
			var w1 := 0.035 * (1.0 - (s + 1) / 3.0)
			for v: Vector2 in [p - side * w, p + side * w, q + side * w1, p - side * w, q + side * w1, q - side * w1]:
				st.add_vertex(Vector3(v.x, 0, v.y))
			p = q
			w = w1
	return st.commit()
