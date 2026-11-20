extends GutTest
## The low walls (RP-17; docs/design/rooms_progression.md): 0.9 m of stone that the body goes round and the shot goes
## over. Cripta A: one of 5.5 m south of the great tomb, parallel to it. Jardim A: two broken ones on an arc 6 m from the
## trunk, east and south, the roots that cross the arc the ways in. Each stops bodies and never shots, lies on the floor,
## off every other piece by a body's width, and leaves a way beside every root it meets (the way in is 4 m with
## the root's metre in its middle).

const STAGE := "res://data/stages/catacombs.tres"
## The widest body that walks these rooms (a guard), both sides, so no way between a wall and a piece shuts.
const CLEAR := 1.0

var stage: StageDef


func before_all() -> void:
	stage = load(STAGE)


func _layout(id: StringName) -> RoomLayout:
	for l in stage.layouts:
		if l.id == id:
			return l
	return null


## The low walls: boxes at 0.9 m that stop bodies, not shots, drawn as low walls (piece block under 1.0 m).
func _low(l: RoomLayout) -> Array[ArenaObstacle]:
	var out: Array[ArenaObstacle] = []
	for o in l.obstacles:
		if o.shape == ArenaObstacle.Shape.BOX and o.piece == &"block" and absf(o.height - 0.9) < 0.01 and o.half.y <= 0.26:
			out.append(o)
	return out


func _points(o: ArenaObstacle) -> PackedVector2Array:
	var pts := PackedVector2Array()
	var ax := Vector2(cos(o.yaw), sin(o.yaw))
	for k in 21:
		pts.append(o.center + ax * lerpf(-o.half.x, o.half.x, k / 20.0))
	return pts


func test_the_walls_are_where_the_plan_puts_them() -> void:
	assert_eq(_low(_layout(&"crypt")).size(), 1, "Cripta A: one")
	assert_eq(_low(_layout(&"garden")).size(), 3, "Jardim A: the east leg and the two of the south")
	assert_eq(_low(_layout(&"crypt").variant(1)).size(), 0, "not in the Ossuary")
	assert_eq(_low(_layout(&"garden").variant(1)).size(), 0, "not in Jardim B")
	for id: StringName in [&"crypt", &"garden"]:
		var l := _layout(id)
		var legs := _low(l)
		for o in legs:
			assert_true(o.blocks_move, "%s: the body goes round" % id)
			assert_false(o.blocks_shots, "%s: the shot goes over" % id)
			for p in _points(o):
				assert_true(l.floor.contains(p, CLEAR), "%s: on the floor at %s" % [id, p])
				for other in l.obstacles:
					if legs.has(other) or not other.blocks_move:
						continue
					assert_lt(other.depth(p, o.half.y + CLEAR), 0.0, "%s: a way between it and the %s at %s" % [id, other.piece, p])


func test_the_courtyard_keeps_its_ways_in() -> void:
	var l := _layout(&"garden")
	for o in _low(l):
		for p in _points(o):
			assert_almost_eq(p.distance_to(Vector2(-8.0, -5.0)), 6.0, 0.4, "on the arc 6 m from the trunk")
			for root in l.obstacles:
				if root.piece == &"root":
					assert_lt(root.depth(p, 1.2), 0.0, "a way of 1.2 m or more beside the root at %s" % p)
