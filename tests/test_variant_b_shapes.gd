extends GutTest
## 2026-11-27 (room review): each B variant changes how the room is fought, as data: Cripta B a pit in the south half,
## Jardim B a terrace wall with two stairs, Santuario B a chasm that runs to the south edge (the nave is cut in two).

var stage: StageDef


func before_all() -> void:
	stage = load("res://data/stages/catacombs.tres")


func _layout(id: StringName) -> RoomLayout:
	for l in stage.layouts:
		if l.id == id:
			return l
	return null


func test_crypt_b_has_a_pit_off_the_way_in() -> void:
	var l := _layout(&"crypt")
	var b := l.variant(1)
	assert_eq(b.floor.holes.size(), 1, "a pit")
	assert_true(l.floor.holes.is_empty(), "A has none")
	assert_false(b.floor.contains(Vector2(0, 1.5)), "the pit's middle is no floor")
	assert_true(b.floor.contains(l.hero_spawn, 0.5), "the way in is on floor")
	assert_true(b.floor.contains(Vector2(-7, 1.5), 0.6) and b.floor.contains(Vector2(7, 1.5), 0.6), "a lane each side")


func test_garden_b_terrace_has_two_stairs() -> void:
	var b := _layout(&"garden").variant(1)
	var walls := 0
	for o in b.obstacles:
		if o.piece == &"block" and absf(o.center.x - 8.0) < 0.1 and not o.blocks_shots:
			walls += 1
	assert_eq(walls, 3, "three runs of retaining wall along x 8, so two stairs between them")


func test_sanctuary_b_chasm_reaches_the_south_edge() -> void:
	var l := _layout(&"sanctuary")
	var b := l.variant(1)
	assert_false(b.floor.contains(Vector2(5, 12.5), 0.0), "no floor in the south aisle under the chasm")
	assert_true(b.floor.contains(Vector2(5, 14.4), 0.0) or not l.floor.contains(Vector2(5, 14.4), 0.0), "(the rim is thinner than a body)")
	assert_false(b.floor.contains(Vector2(5, 13.5), 0.3), "nobody stands on the rim")
	assert_true(b.floor.contains(Vector2(5, -8), 0.5), "the north aisle is the way across")
