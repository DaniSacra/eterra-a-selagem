class_name HubLevels
extends RefCounted
## The hub's levels (refine round 2, 2026-11-26): the floor is flat in the simulation, but the upper terrace (the
## galleries, the Forja, the Aposento, the Biblioteca) stands HubPlan.TIER_H over the lower one, joined by two flights
## (HubPlan.STAIRS). Everything is built flat, as ever, in the hub's frame; when the build is done `raise_steps` lifts what
## stands on the upper terrace and bends what stands on a flight by the plan's smooth field (HubPlan.ramp_at): the
## vertices of every mesh (the merged stone, the floor, the cliffs, the rails), the instances of every MultiMesh, the
## origin of every light, particle and person. One pass over the finished room, so nothing is audited piece by piece.
## `stairs` then draws the treads on the flights (absolute heights, after the lift). The hero's feet follow
## HubPlan.height_at (Player._ground, Arena.ground_at); colliders never move (the plane).
##   steps := HubLevels.raise_steps(look)    # BuildSteps; HubLook appends it to its build
## HubPlan.TIER_H = 0 turns all of it off.

## Meshes whose vertices stay where they were built (the garden's soil: its basin edge is the gallery's retaining wall).
const KEEP_NAMES: Array[StringName] = [&"Garden"]
## Vertices a build step lifts.
const BUDGET := 60000
## The treads: the stone, a lighter nosing, the dark band on the riser (HubScenery's yards use the same).
const TREAD_THICK := 0.12
const NOSING := Vector2(0.06, 0.1)
const RISER_SHADOW := 0.4
## The parapet over STAIR_CUT (the slit between the flight and the Mercador's plaza): its width, its height over a
## tread and its coping.
const PARAPET_WIDE := 0.9
const PARAPET_TALL := 0.85
const COPING := Vector3(0.14, 0.1, 0.06)
## A tread's block goes this far under the lower floor (so none floats over the slope).
const FOOT := 0.15

static var _low_v := -1.0


## The lowest v at which the field is not 0 (the first flight's foot).
static func low_v() -> float:
	if _low_v < 0.0:
		_low_v = INF
		for z in HubPlan.STAIRS:
			_low_v = minf(_low_v, z.y)
		_low_v = minf(_low_v, HubPlan.TIER_V)
	return _low_v


## The lift of the field at a world point (x, z), the cosine and sine of the frame's yaw given (hot loop).
static func _lift(x: float, z: float, cs: float, sn: float) -> float:
	var v := -sn * x - cs * z
	if v < low_v():
		return 0.0
	return HubPlan.ramp_at(Vector2(cs * x - sn * z, v))


## The steps of the lift over everything under `root` (see the class).
static func raise_steps(root: Node3D) -> Array[Callable]:
	var steps: Array[Callable] = []
	if HubPlan.TIER_H <= 0.0 or not root.is_inside_tree():
		return steps
	var users := {}
	var meshes: Array[MeshInstance3D] = []
	var multis: Array[MultiMeshInstance3D] = []
	var leaves: Array[Node3D] = []
	_walk(root, users, meshes, multis, leaves)
	var a := deg_to_rad(Feel.live().cam_yaw)
	var cs := cos(a)
	var sn := sin(a)
	var batch: Array[Callable] = []
	var weight := 0
	for mi in meshes:
		var shared: bool = users[mi.mesh] > 1
		var w := _vertices(mi.mesh)
		batch.append(_raise_mesh.bind(mi, shared, cs, sn))
		weight += w
		if weight >= BUDGET:
			steps.append(_run.bind(batch))
			batch = []
			weight = 0
	for mm in multis:
		batch.append(_raise_multi.bind(mm, cs, sn))
	for n in leaves:
		batch.append(_raise_node.bind(n, cs, sn))
	if not batch.is_empty():
		steps.append(_run.bind(batch))
	return steps


static func _run(jobs: Array[Callable]) -> void:
	for j in jobs:
		j.call()


static func _walk(n: Node, users: Dictionary, meshes: Array[MeshInstance3D], multis: Array[MultiMeshInstance3D], leaves: Array[Node3D]) -> void:
	if n is HubNpc:
		leaves.append(n as Node3D)
		return
	if n is MeshInstance3D:
		var mi := n as MeshInstance3D
		if mi.mesh != null and not KEEP_NAMES.has(StringName(mi.name)) and not mi.has_meta(&"hub_level_keep"):
			meshes.append(mi)
			users[mi.mesh] = int(users.get(mi.mesh, 0)) + 1
	elif n is MultiMeshInstance3D:
		if (n as MultiMeshInstance3D).multimesh != null:
			multis.append(n as MultiMeshInstance3D)
	elif n is Light3D or n is GPUParticles3D or n is Label3D or n is Sprite3D or n is Decal:
		leaves.append(n as Node3D)
	for c in n.get_children():
		_walk(c, users, meshes, multis, leaves)


static func _vertices(mesh: Mesh) -> int:
	if mesh is ArrayMesh:
		var k := 0
		for i in mesh.get_surface_count():
			k += mesh.surface_get_array_len(i)
		return k
	return 24


## A mesh node: its vertices lifted when it is its own ArrayMesh; a shared or primitive mesh (a bar, a baked statue) by its
## origin.
static func _raise_mesh(mi: MeshInstance3D, shared: bool, cs: float, sn: float) -> void:
	if not is_instance_valid(mi) or not mi.is_inside_tree():
		return
	var xf := mi.global_transform
	var box := xf * mi.get_aabb()
	var top_v := -INF
	for k in 8:
		var c := box.get_endpoint(k)
		top_v = maxf(top_v, -sn * c.x - cs * c.z)
	if top_v < low_v():
		return
	if shared or not (mi.mesh is ArrayMesh):
		var lift := _lift(xf.origin.x, xf.origin.z, cs, sn)
		if lift != 0.0:
			mi.global_position.y += lift
		return
	var mesh := mi.mesh as ArrayMesh
	var inv := xf.affine_inverse()
	var out := ArrayMesh.new()
	var moved := false
	for si in mesh.get_surface_count():
		var arrays := mesh.surface_get_arrays(si)
		var vs: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
		for i in vs.size():
			var w := xf * vs[i]
			var lift := _lift(w.x, w.z, cs, sn)
			if lift != 0.0:
				moved = true
				w.y += lift
				vs[i] = inv * w
		arrays[Mesh.ARRAY_VERTEX] = vs
		out.add_surface_from_arrays(mesh.surface_get_primitive_type(si), arrays, [], {}, mesh.surface_get_format(si))
		out.surface_set_material(si, mesh.surface_get_material(si))
	if moved:
		mi.mesh = out


static func _raise_multi(mmi: MultiMeshInstance3D, cs: float, sn: float) -> void:
	if not is_instance_valid(mmi) or not mmi.is_inside_tree():
		return
	var mm := mmi.multimesh
	if mm.transform_format != MultiMesh.TRANSFORM_3D:
		return
	var gt := mmi.global_transform
	var inv := gt.affine_inverse()
	for i in mm.instance_count:
		var t := mm.get_instance_transform(i)
		var o := gt * t.origin
		var lift := _lift(o.x, o.z, cs, sn)
		if lift != 0.0:
			t.origin = inv * (o + Vector3(0.0, lift, 0.0))
			mm.set_instance_transform(i, t)


static func _raise_node(n: Node3D, cs: float, sn: float) -> void:
	if not is_instance_valid(n) or not n.is_inside_tree():
		return
	var o := n.global_position
	var lift := _lift(o.x, o.z, cs, sn)
	if lift != 0.0:
		n.global_position.y += lift


# ---------- the treads ----------

## The treads of every flight, in the hub's frame, at absolute heights (after the lift): a block per tread from just
## under the lower floor up to its top, a nosing, the dark band of the riser; and over STAIR_CUT a stepped parapet (the
## flanks beside the floor's edges are the edges' own cliffs and rails, lifted with the slope). Cream stone with a darker tread.
static func stairs(look: HubLook) -> void:
	if HubPlan.TIER_H <= 0.0:
		return
	var n := HubPlan.STAIR_STEPS
	var stone := look.facade_stone()
	var tread := look._plain(HubScenery.STEP_TREAD, 0.9)
	var nosing := look._plain(HubScenery.STEP_NOSING, 0.8)
	var shade := look._plain(HubScenery.STEP_SHADOW, 1.0)
	for z in HubPlan.STAIRS:
		var wide := z.z - z.x
		var uc := (z.x + z.z) * 0.5
		var run := (z.w - z.y) / n
		var rise := HubPlan.TIER_H / n
		for k in n:
			var top := rise * (k + 1)
			var v0 := z.y + run * k
			var vc := v0 + run * 0.5
			look._bar(HubLook.at(uc, (top - FOOT) * 0.5, vc), Vector3(wide, top + FOOT, run), tread)
			look._bar(HubLook.at(uc, top + TREAD_THICK * 0.5 - 0.02, vc), Vector3(wide, TREAD_THICK, run), stone)
			look._bar(HubLook.at(uc, top + 0.01, v0 + NOSING.y * 0.5), Vector3(wide + 0.04, NOSING.x, NOSING.y), nosing)
			look._bar(HubLook.at(uc, top - rise * RISER_SHADOW * 0.5 - 0.02, v0 - 0.015), Vector3(wide, rise * RISER_SHADOW, 0.03), shade)

	# the parapet over the slit beside the main axis' flight: a stepped wall, coped, from the lower floor
	var b := HubPlan.STAIR_B
	var cut := HubPlan.STAIR_CUT
	var cu := (cut[0].x + cut[1].x) * 0.5
	var run_b := (b.w - b.y) / n
	var rise_b := HubPlan.TIER_H / n
	for k in n:
		var v0 := b.y + run_b * k
		var top := rise_b * (k + 1) + PARAPET_TALL
		var vc := v0 + run_b * 0.5
		look._bar(HubLook.at(cu, (top + 0.3) * 0.5 - 0.3, vc), Vector3(PARAPET_WIDE, top + 0.3, run_b + 0.02), stone)
		look._bar(HubLook.at(cu, top + COPING.y * 0.5, vc), Vector3(PARAPET_WIDE + COPING.x, COPING.y, run_b + COPING.z), nosing)
	# its upper end closes against the gallery's edge
	var cap_top := HubPlan.TIER_H + PARAPET_TALL
	look._bar(HubLook.at(cu, cap_top * 0.5, cut[2].y + 0.2), Vector3(PARAPET_WIDE, cap_top, 0.5), stone)
	look._bar(HubLook.at(cu, cap_top + COPING.y * 0.5, cut[2].y + 0.2), Vector3(PARAPET_WIDE + COPING.x, COPING.y, 0.5 + COPING.z), nosing)
