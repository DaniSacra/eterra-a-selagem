extends GutTest
## The doors out (RP-19; docs/design/rooms_progression.md): in every fight room and variant the doors are at the back
## of the room, not by the way in: each door's mouth 8 m or more from where he comes in, off every spawn zone (nobody
## rises on a door), and the doors 3 m or more apart (two doors never read as one; PT-6b 2026-11-25: the pair stands together in the north-east, 4.2 m).

const STAGE := "res://data/stages/catacombs.tres"
## Doors closer to the way in than this, and to each other.
const FROM_WAY_IN := 8.0
const APART := 3.0


func test_the_doors_are_at_the_back() -> void:
	var stage: StageDef = load(STAGE)
	for base in stage.layouts:
		if base.id == &"hall":
			continue
		for v in base.variant_count():
			var l := base.variant(v)
			var name := "%s %d" % [base.id, v]
			for i in l.exits.size():
				var m := l.exits[i].mouth
				var c := m.get_center()
				assert_gte(_gap(m, l.hero_spawn), FROM_WAY_IN, "%s: door %d (%s) 8 m from the way in" % [name, i, c])
				for s in l.spawns:
					assert_false(s.intersects(m), "%s: door %d off the spawn %s" % [name, i, s])
				for j in range(i + 1, l.exits.size()):
					var c2 := l.exits[j].mouth.get_center()
					assert_gte(c.distance_to(c2), APART, "%s: doors %d and %d apart" % [name, i, j])


static func _gap(r: Rect2, p: Vector2) -> float:
	var q := Vector2(clampf(p.x, r.position.x, r.end.x), clampf(p.y, r.position.y, r.end.y))
	return q.distance_to(p)
