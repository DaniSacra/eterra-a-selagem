extends GutTest
## BattleMarks (2026-11-21): bone dust where an undead falls, a crack where a heavy circle lands, bounded, only on the
## floor, and the run's dice untouched; FloorScatter's moss darker than it was.

var game: Game


func before_each() -> void:
	game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	game.rooms.start_at(RunMap.Kind.FOUNTAIN)


## A free spot in the middle of the room.
func _spot() -> Vector2:
	return game.arena.resolve(game.arena.middle, 1.0)


func _fallen(at: Vector2) -> Enemy:
	var e := Enemy.new()
	e.def = load("res://data/enemies/skeleton.tres")
	e.pos = at
	return e


func test_dust_is_bounded_and_on_the_floor() -> void:
	var m := game.marks
	assert_not_null(m)
	m._on_killed(_fallen(_spot()))
	assert_eq(m.dust.visible_instance_count, 1)
	assert_gt(m.slivers.visible_instance_count, 0)
	m._on_killed(_fallen(Vector2(500, 500)))
	assert_eq(m.dust.visible_instance_count, 1, "nothing off the floor")
	for k in BattleMarks.MAX_DUST * 2:
		m._on_killed(_fallen(_spot()))
	assert_eq(m.dust.visible_instance_count, BattleMarks.MAX_DUST)
	assert_eq(m.cracks.visible_instance_count, 0, "a common enemy leaves no crack")


func test_a_heavy_circle_cracks_the_floor() -> void:
	var z := Ground.Zone.new()
	z.shape = Ground.Shape.CIRCLE
	z.pos = _spot()
	z.power = 10.0
	z.radius = BattleMarks.CRACK_FROM - 0.1
	game.marks._on_landed(z)
	assert_eq(game.marks.cracks.visible_instance_count, 0)
	z.radius = BattleMarks.CRACK_FROM
	game.marks._on_landed(z)
	assert_eq(game.marks.cracks.visible_instance_count, 1)
	z.floor_own = true
	game.marks._on_landed(z)
	assert_eq(game.marks.cracks.visible_instance_count, 1, "a floor that strikes keeps its own look")


func test_the_marks_go_with_the_room() -> void:
	assert_eq(game.marks.get_parent(), game.arena)
