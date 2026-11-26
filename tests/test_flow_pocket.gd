extends GutTest
## The soft-lock of 2026-11-26 (seed 1, the Jardim): the paladin stood in a pocket between the trunk and a root, a spot
## no body can reach; the flow was made toward that cell, reached nobody, and the raised skeletons stood still for 8
## minutes so the room never closed. The goal now ends on the room's floor, and a walker still stuck is put back on it.

var stage: StageDef = load("res://data/stages/catacombs.tres")


func _garden() -> Arena:
	var a := Arena.new()
	add_child_autofree(a)
	for l: RoomLayout in stage.layouts:
		if l.id == &"garden":
			a.build(l, 3, 1406)
	return a


func test_a_goal_in_a_pocket_ends_on_the_floor_and_every_walker_has_a_way() -> void:
	var a := _garden()
	var pocket := Vector2(-3.75, -3.15)
	var c := a.nav.nearest_free(pocket)
	assert_ne(a.nav.island[c], a.nav.main_island(), "the pocket is a cut-off island (else the test proves nothing)")
	a.flow.aim(pocket, 1.0, 0)
	assert_true(a.flow.ready())
	var way := a.flow.next_step(Vector2(0.0, -3.0))
	assert_gt(way.length(), 0.5, "the walker by the trunk has a way toward the paladin")
	assert_gte(a.flow.steps_from(Vector2(0.0, -3.0)), 0)


func test_nearest_main_never_returns_a_pocket_cell() -> void:
	var a := _garden()
	var m := a.nav.nearest_main(Vector2(-4.04, -2.48))
	assert_gte(m, 0)
	assert_eq(a.nav.island[m], a.nav.main_island())



func test_a_walker_born_in_the_pocket_is_put_on_the_floor() -> void:
	var h := Horde.new()
	add_child_autofree(h)
	var a := _garden()
	h.arena = a
	var at := h.on_floor(Vector2(-4.04, -2.48))
	var c := a.nav.nearest_free(at)
	assert_eq(a.nav.island[c], a.nav.main_island())
	assert_eq(h.on_floor(Vector2(0.0, -3.0)), Vector2(0.0, -3.0), "a spot on the floor stays")
