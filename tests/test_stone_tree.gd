extends GutTest
## The petrified tree of the garden (StoneTree, cycle C12, D-30; docs/art/cycle12_arenas_spec.md 4.4), grown on each
## variant's layout: what stands on the floor lies on the collision (the trunk's circle and the roots' capsules), the
## crown keeps its rule (no branch low away from the trunk nor out toward the camera), the crystals stay inside the
## trunk's collision, the budget holds and there are lanterns' points.

const STAGE := "res://data/stages/catacombs.tres"
## The spec's tolerance between the drawn foot and the collision.
const TOLERANCE := 0.12

var trees: Array[StoneTree] = []
var layouts: Array[RoomLayout] = []
var holder: Node3D


func before_all() -> void:
	holder = Node3D.new()
	add_child(holder)
	var stage: StageDef = load(STAGE)
	for l in stage.layouts:
		if l.id == &"garden":
			for v in 1 + l.variants.size():
				layouts.append(l.variant(v))
	for l in layouts:
		var trunk := _trunk(l)
		var t := StoneTree.new()
		t.bounds = GardenLook.CROWN_BOUNDS
		t.build(holder, trunk.center, GardenLook.root_paths(l, trunk), 0.8)
		trees.append(t)
		var reach := {}
		var top := 0.0
		for p in t.crown:
			var h := Vector2(p.x - t.at.x, p.z - t.at.z)
			var sector := int(StoneTree.bearing(h) / 45.0) * 45
			reach[sector] = maxf(reach.get(sector, 0.0), h.length())
			top = maxf(top, p.y)
		gut.p("tree: %d triangles, %d branches, %d hangs, top %.1f m, reach by bearing %s" % [t.triangles, t.branches, t.hangs.size(), top, reach])


func after_all() -> void:
	holder.free()


func _trunk(l: RoomLayout) -> ArenaObstacle:
	for o in l.obstacles:
		if o.piece == &"trunk":
			return o
	return null


func test_both_variants_have_the_tree() -> void:
	assert_eq(trees.size(), 2)
	for l in layouts:
		assert_not_null(_trunk(l))
		assert_gt(GardenLook.root_paths(l, _trunk(l)).size(), 2, "its roots are read back from the capsules")


func test_foot_lies_on_the_collision() -> void:
	for k in trees.size():
		var l := layouts[k]
		var bad := 0
		for p in trees[k].footprint:
			var q := Vector2(p.x, p.z)
			var on := false
			for o in l.obstacles:
				if (o.piece == &"trunk" or o.piece == &"root") and o.depth(q, 0.0) > -TOLERANCE:
					on = true
					break
			if not on:
				bad += 1
		assert_eq(bad, 0, "variant %d: %d of %d foot points outside the collision" % [k, bad, trees[k].footprint.size()])


func test_collision_is_covered() -> void:
	# every capsule's middle line and the trunk's circle have stone over them (no invisible wall)
	for k in trees.size():
		var l := layouts[k]
		var foot := trees[k].footprint
		for o in l.obstacles:
			if o.piece != &"root":
				continue
			var ax := Vector2.from_angle(o.yaw) * (o.half.x - o.half.y)
			for s in 5:
				var q := o.center + ax * lerpf(-1.0, 1.0, s / 4.0)
				var near := INF
				for p in foot:
					near = minf(near, Vector2(p.x, p.z).distance_to(q))
				assert_lt(near, o.half.y + TOLERANCE, "variant %d: root over %s" % [k, q])


func test_crown_keeps_its_rule() -> void:
	for t in trees:
		var low := 0
		for p in t.crown:
			if t.breaks_rule(p):
				low += 1
		assert_eq(low, 0, "no branch under 4.5 m away from the trunk nor toward the camera")
		assert_between(t.branches, 40, 60, "40 to 60 branches")


func test_budget() -> void:
	for t in trees:
		assert_lt(t.triangles, 25000, "at most 25 thousand triangles")


func test_crystals_stay_in_the_trunk() -> void:
	for k in trees.size():
		var t := trees[k]
		var found := false
		for n in holder.find_children("StoneTreeCrystals*", "MeshInstance3D", true, false):
			found = true
			var verts: PackedVector3Array = (n as MeshInstance3D).mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX]
			for v in verts:
				if v.y > 0.0:
					assert_lt(Vector2(v.x - t.at.x, v.z - t.at.z).length(), 3.5 + TOLERANCE, "crystal inside the trunk")
		assert_true(found)
		assert_eq(t.crystal_spots.size(), 3)


func test_lanterns_hang_away_from_the_camera() -> void:
	for t in trees:
		assert_eq(t.hangs.size(), 2, "a point under limb A and one under limb B")
		for h in t.hangs:
			var b := StoneTree.bearing(Vector2(h.x - t.at.x, h.z - t.at.z))
			assert_false(b > 95.0 and b < 195.0, "not on the camera's side (%.0f)" % b)
			assert_gt(h.y, 5.5)
