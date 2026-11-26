extends GutTest
## Varredura 2026-11-26b: what the room tests left open, over every stage layout and variant (and the Provação and the
## Altar): the relic and the vein stand where the paladin walks to, no hazard sits on the way in or on a door, and an
## enemy's spawn zone is never wholly on a dash-only patch.

const STAGE := "res://data/stages/catacombs.tres"
## The way in and the doors keep this far from any hazard piece (the first seconds of a room are quiet; start_delay).
const START_CLEAR := 2.0
const DOOR_CLEAR := 1.0

const ARENAS := preload("res://tests/test_arenas.gd")

var stage: StageDef


func before_all() -> void:
	stage = load(STAGE)


func _views() -> Array:
	var out: Array = []
	for l: RoomLayout in stage.layouts:
		for v in l.variant_count():
			out.append(["%s %d" % [l.id, v], l.variant(v)])
	out.append(["trial", stage.trial_layout])
	out.append(["altar", stage.altar_layout])
	return out


func _arena(l: RoomLayout, doors: int) -> Arena:
	var a := Arena.new()
	add_child_autofree(a)
	a.build(l, doors, 1406)
	return a


func _in_gap(l: RoomLayout, p: Vector2) -> bool:
	for g in l.gaps:
		if g.grow(0.3).has_point(p):
			return true
	return false


func test_relic_and_vein_are_walked_to() -> void:
	for view: Array in _views():
		var l: RoomLayout = view[1]
		var a := _arena(l, 3)
		var spots := PackedVector2Array()
		spots.append_array(l.relic_spots)
		spots.append_array(l.gather_spots)
		for s in spots:
			var at := a.resolve(s, 0.6)
			assert_true(a.nav.walkable(at), "%s: %s on free floor" % [view[0], s])
			assert_true(a.nav.reachable(a.start, at), "%s: %s reached on foot" % [view[0], s])
			assert_false(_in_gap(l, at), "%s: %s not on a dash patch" % [view[0], s])


## A hazard of the chain that can hurt him (the rift's breath only pushes: RP-08, 0 damage).
func _hurts(h: HazardDef) -> HazardDef:
	if h == null:
		return null
	var own := h.also
	h = h.duplicate()
	h.also = _hurts(own)
	if h.hero_damage <= 0.0 and h.plate_hero_damage.is_empty():
		return h.also
	return h


func test_no_hazard_on_the_way_in_or_a_door() -> void:
	for view: Array in _views():
		var l: RoomLayout = view[1]
		var hz := _hurts(l.hazard)
		if hz == null:
			continue
		for doors in [1, 3]:
			var a := _arena(l, doors)
			assert_gte(hz.start_delay, 3.0, "%s: quiet at the start" % view[0])
			assert_gte(ARENAS._hazard_gap(hz, a.start), START_CLEAR, "%s: off the way in" % view[0])
			for z in a.exit_zones:
				assert_gte(ARENAS._hazard_gap(hz, z.get_center()), DOOR_CLEAR, "%s: off door %s" % [view[0], z])


func test_the_walk_in_spawn_zones_are_not_all_patch() -> void:
	for view: Array in _views():
		var l: RoomLayout = view[1]
		if l.gaps.is_empty() or l.spawns.is_empty():
			continue
		var a := _arena(l, 3)
		var good := 0
		for z in l.spawns:
			if a.nav.walkable(z.get_center()) and a.nav.reachable(a.start, z.get_center()):
				good += 1
		assert_gt(good, 0, "%s: some spawn zone is walkable from the way in" % view[0])
