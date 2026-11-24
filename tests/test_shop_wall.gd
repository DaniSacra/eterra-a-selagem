extends GutTest
## PT-11: the shop's items line the walls (Rooms.SHOP_SLOTS) and the middle of the hall stays free.

var stage: StageDef = load("res://data/stages/catacombs.tres")


func test_slots_are_on_free_floor_far_from_the_way_in_and_the_doors() -> void:
	var a := Arena.new()
	add_child_autofree(a)
	a.build(stage.shop_layout, 2, 1406)
	assert_eq(Rooms.SHOP_SLOTS.size(), 5, "the last shop shows five items")
	for k in Rooms.SHOP_SLOTS.size():
		var at := Rooms.SHOP_SLOTS[k]
		assert_true(a.nav.walkable(at), "slot %d on free floor" % k)
		assert_gte(at.distance_to(a.start), 6.0, "slot %d off the way in" % k)
		for e in a.exits:
			assert_gte(at.distance_to(e), 5.0, "slot %d off the door" % k)
		assert_true(a.nav.reachable(a.start, at), "slot %d reached" % k)
		for j in k:
			assert_gte(at.distance_to(Rooms.SHOP_SLOTS[j]), 5.0, "slots %d and %d apart (the signs do not meet)" % [j, k])


func test_the_middle_stays_free_but_for_the_highlight() -> void:
	for k in range(1, Rooms.SHOP_SLOTS.size()):
		var at := Rooms.SHOP_SLOTS[k]
		var wall := minf(minf(at.y + 13.0, 14.0 - absf(at.x)), 99.0)
		assert_lte(wall, 3.5, "slot %d stands by a wall" % k)
