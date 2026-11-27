extends GutTest
## Doors (Daniel 2026-11-25 together, reversed 2026-11-27): far apart with a piece between them.

const STAGE := "res://data/stages/catacombs.tres"


func _layouts() -> Array[RoomLayout]:
	var stage: StageDef = load(STAGE)
	var out: Array[RoomLayout] = []
	for l in stage.layouts:
		if l.platform:
			continue
		for v in l.variant_count():
			out.append(l.variant(v))
	out.append(stage.trial_layout)
	out.append(stage.altar_layout)
	return out


## Daniel 2026-11-27: the doors stand far apart (5.5 m or more between the first two) and a piece stands between them: a
## statue, a fire bowl, a brazier, a wall, a sarcophagus, a crystal... (an obstacle of the layout, or one the look draws
## between them: the Jardim's niche statue and the Sanctuary's niche statue).
const PIECE_NEAR_WALL := 4.0
const APART_MIN := 5.5
const LOOK_PIECES := {&"garden": 10.0, &"sanctuary": -1.0, &"trial": 0.25}


func test_first_two_doors_far_apart_with_a_piece_between() -> void:
	for l in _layouts():
		if l.id == &"hall":
			continue
		assert_gte(l.exits.size(), 2, l.id)
		var e0 := l.exits[0]
		var e1 := l.exits[1]
		var d := e0.at.distance_to(e1.at)
		assert_gte(d, APART_MIN, "%s: the two doors %.1f m apart" % [l.id, d])
		assert_lte(d, 13.0, "%s: not so far that the choice needs a walk" % l.id)
		# the pieces between: on the line from one to the other (their mouths' gap), near the wall the doors are in
		var lo := minf(e0.edge().x, e1.edge().x)
		var hi := maxf(e0.edge().x, e1.edge().x)
		var vertical := absf(e0.edge().x - e1.edge().x) < 0.5  # doors in a side wall: the line runs along z
		if vertical:
			lo = minf(e0.edge().y, e1.edge().y)
			hi = maxf(e0.edge().y, e1.edge().y)
		var found := false
		for o in l.obstacles:
			var along := o.center.y if vertical else o.center.x
			var depth := absf(o.center.x - e0.edge().x) if vertical else absf(o.center.y - e0.edge().y)
			if along > lo and along < hi and depth <= PIECE_NEAR_WALL and o.piece != &"quiet":
				found = true
		if not found and LOOK_PIECES.has(l.look if l.look != &"" else l.id):
			var x: float = LOOK_PIECES[l.look if l.look != &"" else l.id]
			found = x > lo and x < hi
		assert_true(found, "%s: a piece between the two doors" % l.id)
		# neither mouth holds an obstacle that blocks bodies
		for e in [e0, e1]:
			for o in l.obstacles:
				if o.blocks_move:
					assert_false(o.rect().intersects(e.mouth) if o.shape == ArenaObstacle.Shape.BOX else Geometry2D.is_point_in_circle(e.mouth.get_center(), o.center, o.radius + 0.1), "%s: nothing in a door's mouth" % l.id)


## Daniel 2026-11-27 (Runas B): no solid piece stands in a door's approach, the strip of floor in front of its mouth as wide as the
## mouth and APPROACH_DEPTH deep (a pillar there read as standing in the door's mouth from the camera). Every door of every layout.
const APPROACH_DEPTH := 4.0


func test_no_solid_piece_in_a_doors_approach() -> void:
	for l in _layouts():
		if l.id == &"hall":
			continue
		for i in l.exits.size():
			var e := l.exits[i]
			var side := Vector2(-e.inward.y, e.inward.x)
			var half := absf(e.mouth.size.dot(side)) * 0.5
			var c := e.edge()
			var strip := Rect2(c - side * half, Vector2.ZERO).expand(c + side * half).expand(c + e.inward * APPROACH_DEPTH - side * half).expand(c + e.inward * APPROACH_DEPTH + side * half)
			for o in l.obstacles:
				if not o.blocks_move or o.piece == &"trap_block":
					continue
				var hit := o.rect().intersects(strip) if o.shape == ArenaObstacle.Shape.BOX else Geometry2D.is_point_in_circle(strip.get_center(), o.center, o.radius + strip.size.length() * 0.5) and strip.grow(o.radius).has_point(o.center)
				assert_false(hit, "%s: door %d: %s at %s stands in its approach" % [l.id, i, o.piece, o.center])


## The hall of room 1 (built in code, layout "platform"): its portal and its east stairs are the first two doors and stand
## together in the north-east corner, with nothing of the room's collision on either spot.
func test_hall_first_two_doors_together_in_the_north_east() -> void:
	var stage: StageDef = load(STAGE)
	for n in [2, 3]:
		var a := Arena.new()
		add_child_autofree(a)
		a.build(stage.layouts[0], n, 1406)
		assert_eq(a.exits.size(), n)
		assert_eq(a.exit_zones.size(), n)
		assert_eq(a.exit_inward.size(), n)
		for i in 2:
			assert_gt(a.exits[i].x, 0.0, "hall door %d east of the middle" % i)
			assert_lt(a.exits[i].y, 0.0, "hall door %d in the north half" % i)
			assert_true(a.exit_zones[i].has_point(a.exits[i]), "hall door %d: its spot is in its zone" % i)
			assert_eq(a.resolve(a.exits[i], 0.4), a.exits[i], "hall door %d: nothing in front of it" % i)
		assert_between(a.exits[0].distance_to(a.exits[1]), 5.5, 8.0, "hall: the two doors 5.5 to 8 m apart, a statue between (Daniel 2026-11-27)")
		assert_lt(absf(a.door_pos.x - a.exits[0].x), 3.5, "the portal's light stands over the door pair (the statue between them)")
