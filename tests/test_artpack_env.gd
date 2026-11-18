extends GutTest
## The art pack of 2026-11-17, section 4 (docs/art/ref/direcao_2026-11-17, scenery): in the Jardim das Raízes Mortas and
## the Salão das Fendas the drawing stands where the collision stops you and nowhere else (no stone over the walkable
## floor but the layout's pieces, the roots drawn over the knee to their collision's end, the lips' chunks a step under
## the floor); in the Câmara do Selo Morvath's crescents are a cold violet with a pale core and the seal's crack goes
## quiet under his attacks. tools/fit_probe.gd measures the same on a grid (docs/gallery/artpack/stage4/INDEX.md).

const STAGE := "res://data/stages/catacombs.tres"
## Anything higher than this over the walkable floor stands on it; higher than OVERHEAD hangs over it.
const STANDING := 0.3
const OVERHEAD := 2.6
## The brink's own trim (a sill, a curb, a fire bowl's rim by a door) may reach this far over the edge; a piece's own
## dressing this far round it.
const EDGE_TRIM := 0.35
const PIECE_MARGIN := 0.45
## A door's cheeks and posts stand this far round its mouth.
const DOOR_SIDES := 1.2
## A root is drawn over this height up to this far from its collision's end.
const ROOT_SEEN := 0.15
const ROOT_END := 0.45


func _layout(id: StringName, variant: int) -> RoomLayout:
	var stage: StageDef = load(STAGE)
	for l in stage.layouts:
		if l.id == id:
			return l.variant(variant)
	return null


func _build(id: StringName, variant: int) -> Arena:
	var a := Arena.new()
	add_child_autofree(a)
	a.build(_layout(id, variant), 3, 1406)
	return a


func test_nothing_stands_on_the_walkable_floor_of_the_garden_and_the_rift() -> void:
	for id: StringName in [&"garden", &"rift"]:
		for v in 2:
			var a := _build(id, v)
			var l := a.layout
			var bad := 0
			var where := {}
			for n in a.look.find_children("*", "MeshInstance3D", true, false):
				var mi := n as MeshInstance3D
				# cards (mist banks, glows, halos) are air, not stone
				if mi.mesh == null or mi.mesh is QuadMesh:
					continue
				var xf := mi.global_transform
				for s in mi.mesh.get_surface_count():
					var verts: PackedVector3Array = mi.mesh.surface_get_arrays(s)[Mesh.ARRAY_VERTEX]
					for vert in verts:
						var p := xf * vert
						if p.y <= STANDING or p.y > OVERHEAD:
							continue
						var q := Vector2(p.x, p.z)
						if not l.floor.contains(q, EDGE_TRIM) or _near_piece(l, q) or _in_mouth(l, q):
							continue
						if not where.has(mi.name):
							where[mi.name] = p
						bad += 1
			assert_eq(bad, 0, "%s %d: nothing stands on the floor but its pieces (%s)" % [id, v, where])


func test_the_roots_are_drawn_over_the_knee_to_their_collisions_end() -> void:
	for v in 2:
		var a := _build(&"garden", v)
		var look := a.look as GardenLook
		var trunk: ArenaObstacle = null
		for o in a.layout.obstacles:
			if o.piece == &"trunk":
				trunk = o
		var tips: Array[Vector2] = []
		for path in GardenLook.root_paths(a.layout, trunk):
			var last := path[path.size() - 1]
			var before := path[path.size() - 2] if path.size() > 1 else trunk.center
			# the capsule's square end: half its width (0.5) past the last point
			tips.append(last + (last - before).normalized() * 0.5)
		var seen: Array[bool] = []
		seen.resize(tips.size())
		seen.fill(false)
		for n in look.find_children("StoneTree", "MeshInstance3D", true, false):
			var mi := n as MeshInstance3D
			var xf := mi.global_transform
			for s in mi.mesh.get_surface_count():
				for vert: Vector3 in mi.mesh.surface_get_arrays(s)[Mesh.ARRAY_VERTEX]:
					var p := xf * vert
					if p.y <= ROOT_SEEN:
						continue
					for i in tips.size():
						if Vector2(p.x, p.z).distance_to(tips[i]) < ROOT_END:
							seen[i] = true
		for i in tips.size():
			assert_true(seen[i], "garden %d: root %d is drawn over %.2f m by its collision's end %s" % [v, i, ROOT_SEEN, tips[i]])


func test_the_lips_chunks_lie_a_step_under_the_floor() -> void:
	assert_gte(ArenaRoom.LIP_SINK.x, 0.15, "a chunk past the drop is a step down, never floor one could stand on")
	assert_gte(ArenaRoom.LIP_SINK.y, ArenaRoom.LIP_SINK.x)


func test_morvaths_crescents_are_a_cold_violet_with_a_pale_core() -> void:
	var c := Boss.SOUL_VIOLET
	assert_true(c.h * 360.0 > 245.0 and c.h * 360.0 < 280.0, "violet (hue %.0f)" % (c.h * 360.0))
	assert_true(c.b > c.r and c.b > c.g, "cold: blue leads")
	assert_ne(c, Boss.SPECTRAL, "no longer the spectral green")
	# the core and the leading edge take the pale core colour (a lilac white), not a tint of the body
	var code: String = Projectiles.SOUL_SHADER.code
	var m := RegEx.create_from_string("uniform vec4 core_color[^=]*= vec4\\(([0-9.]+), ([0-9.]+), ([0-9.]+)").search(code)
	assert_not_null(m, "the crescent has a core colour")
	if m != null:
		var core := Color(float(m.get_string(1)), float(m.get_string(2)), float(m.get_string(3)))
		assert_gt(core.v, 0.9, "the core is pale")
		assert_lt(core.s, 0.15, "the core is nearly white")
	assert_true(code.contains("vec3 heart = core_color.rgb"), "its core line is the pale colour")


func test_the_seal_goes_quiet_under_his_attacks() -> void:
	var seal := SealLook.new()
	seal.enter(SealLook.State.FINAL)
	seal.step(3.0)
	var calm := seal.values()
	seal.hush_for(1.0)
	seal.step(0.5)
	var quiet := seal.values()
	assert_almost_eq(float(quiet[&"crack_core"]), float(calm[&"crack_core"]) * SealLook.HUSH, 0.01, "the crack dims under a wind-up")
	assert_lt(float(quiet[&"vein_light"]), float(calm[&"vein_light"]) * 0.7, "and the veins")
	# it holds through the blow's flight and comes back after
	seal.step(1.0 + SealLook.HUSH_HOLD - 0.5 + SealLook.HUSH_OUT + 0.1)
	assert_almost_eq(seal.hushed, 0.0, 0.001, "back to its light after the attack")
	# never in the victory
	seal.hush_for(2.0)
	seal.enter(SealLook.State.VICTORY)
	seal.step(0.3)
	assert_almost_eq(seal.hushed, 0.0, 0.001, "the victory keeps its own light")


func test_the_chamber_hushes_the_seal_on_each_attack_cue() -> void:
	var chamber := BossChamber.new()
	add_child_autofree(chamber)
	chamber.build()
	for cue: StringName in [&"scythe_raise", &"blades_gather", &"storm_wave", &"curse_gather", &"dash_aim", &"rune"]:
		chamber.seal.hushed = 0.0
		chamber.on_cue(cue, Vector2.ZERO, Vector2.UP, 6.0, 0.8)
		chamber.seal.step(0.3)
		assert_gt(chamber.seal.hushed, 0.9, "%s quiets the seal" % cue)
		chamber.seal.step(5.0)
	chamber.on_cue(&"phase_shift", Vector2.ZERO, Vector2.ZERO, 2.0, 1.0)
	chamber.seal.step(0.3)
	assert_almost_eq(chamber.seal.hushed, 0.0, 0.001, "a phase shift is not an attack")


func _near_piece(l: RoomLayout, q: Vector2) -> bool:
	for o in l.obstacles:
		if o.depth(q, PIECE_MARGIN) > 0.0:
			return true
	return false


func _in_mouth(l: RoomLayout, q: Vector2) -> bool:
	for e in l.exits:
		if e.mouth.grow(DOOR_SIDES).has_point(q):
			return true
	return false
