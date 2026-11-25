extends GutTest
## Daniel 2026-11-25: doors off the screen are shown by an arrow at its edge, pointing their way.


func test_the_arrow_sits_on_the_edge_toward_the_doors() -> void:
	var screen := Vector2(1280, 720)
	var spot := DoorArrow.edge_spot(screen, Vector2(3000, 360), 40.0)
	assert_almost_eq((spot[0] as Vector2).x, 1240.0, 0.5, "far to the right: on the right edge, 40 px in")
	assert_almost_eq((spot[0] as Vector2).y, 360.0, 0.5)
	assert_almost_eq((spot[1] as Vector2).x, 1.0, 0.001, "pointing right")
	spot = DoorArrow.edge_spot(screen, Vector2(640, -2000), 40.0)
	assert_almost_eq((spot[0] as Vector2).y, 40.0, 0.5, "far above: on the top edge")


func test_a_door_on_the_screen_puts_the_arrow_on_it() -> void:
	var spot := DoorArrow.edge_spot(Vector2(1280, 720), Vector2(900, 300), 40.0)
	assert_almost_eq((spot[0] as Vector2).x, 900.0, 0.5, "inside the screen it never goes past the doors")
