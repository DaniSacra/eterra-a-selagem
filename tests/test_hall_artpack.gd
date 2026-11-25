extends GutTest
## The hall lab of the art pack 2026-11-23: the medallion is a square band with a framed lion slab in it, never a disc
## (round floor marks are Morvath's alone), and the middle stays free of any collision.

const STAGE := "res://data/stages/catacombs.tres"
const FLOOR_INC := "res://assets/shaders/catacomb_floor.gdshaderinc"


func _hall() -> Arena:
	var stage: StageDef = load(STAGE)
	for l in stage.layouts:
		if l.id == &"hall":
			var a := Arena.new()
			add_child_autofree(a)
			a.build(l, 3, 1406)
			return a
	return null


func test_the_medallion_is_square_not_round() -> void:
	var src := FileAccess.get_file_as_string(FLOOR_INC)
	assert_true(src.contains("SQUARE_FIT"), "the band is measured as a square")
	assert_false(src.contains("float d = length(q);"), "no round distance in the medallion")
	assert_false(src.contains("rosette of eight petals"), "no round rosette in the middle")
	assert_false(src.contains("the eight points"), "no compass points")


## SL-01: the allies' lion is not for the enemy's ground: no medallion, no framed slab, no emblem on the floor of the hall.
func test_the_floor_carries_no_medallion_frame_or_lion() -> void:
	VisualProfile.set_look(VisualProfile.Look.STYLIZED)
	var a := _hall()
	var plates := 0
	for n in a.find_children("*", "GeometryInstance3D", true, false):
		var m := (n as GeometryInstance3D).material_override as ShaderMaterial
		if m == null or m.shader == null:
			continue
		var ring: Variant = m.get_shader_parameter(&"ring_radius")
		if ring != null:
			plates += 1
			assert_eq(float(ring), 0.0, "no medallion ring on the floor")
		var count: Variant = m.get_shader_parameter(&"framed_count")
		if count != null:
			assert_eq(int(count), 0, "no framed slab and no emblem on the painted floor")
	assert_gt(plates, 0, "the floor plates were found")
