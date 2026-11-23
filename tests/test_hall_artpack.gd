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


func test_the_emblem_fits_inside_the_band_and_the_hall() -> void:
	var inner_half := CatacombHall.MEDALLION * 0.507 * 0.72
	assert_lt(CatacombHall.EMBLEM_SIDE * 0.5, inner_half, "the lion slab sits inside the band's inner edge")
	var outer_corner := CatacombHall.MEDALLION * 0.627 * 0.72 * sqrt(2.0)
	assert_lt(outer_corner, CatacombHall.MEDALLION, "the band's corners stay inside the medallion's reserved radius")


func test_the_lion_slab_is_laid_in_the_middle() -> void:
	VisualProfile.set_look(VisualProfile.Look.STYLIZED)
	var a := _hall()
	var found := 0
	for n in a.find_children("*", "GeometryInstance3D", true, false):
		var m := (n as GeometryInstance3D).material_override as ShaderMaterial
		if m == null or m.shader == null:
			continue
		var rects: Variant = m.get_shader_parameter(&"framed_rects")
		var infos: Variant = m.get_shader_parameter(&"framed_info")
		if rects == null or infos == null:
			continue
		var count := int(m.get_shader_parameter(&"framed_count"))
		if count == 0:
			continue
		var r: Vector4 = rects[0]
		var info: Vector4 = infos[0]
		assert_eq(Vector2(r.x, r.y), CatacombHall.MEDALLION_AT, "the emblem is the first slab, on the medallion")
		assert_almost_eq(r.z, r.w, 0.001, "square")
		assert_eq(int(info.x), ArenaKit.Framed.GRAVE)
		assert_gt(info.y, 0.5, "with the lion")
		found += 1
	assert_gt(found, 0, "the painted floor carries the lion slab")
