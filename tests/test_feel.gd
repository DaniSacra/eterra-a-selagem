extends GutTest
## data/feel.tres: it loads, every number has a range for the F1 panel and sits inside it.


func test_feel_loads_from_data() -> void:
	var f := load(Feel.PATH) as Feel
	assert_not_null(f)
	assert_gt(f.speed, 0.0)
	assert_gt(f.dodge_charges, 0)


func test_every_number_has_a_range_and_sits_in_it() -> void:
	var f := load(Feel.PATH) as Feel
	var seen := 0
	for p in f.get_property_list():
		if not (p.usage & PROPERTY_USAGE_SCRIPT_VARIABLE) or (p.type != TYPE_FLOAT and p.type != TYPE_INT):
			continue
		seen += 1
		assert_eq(p.hint, PROPERTY_HINT_RANGE, "%s needs @export_range for the panel" % p.name)
		var r: PackedStringArray = (p.hint_string as String).split(",")
		assert_between(float(f.get(p.name)), float(r[0]), float(r[1]), p.name)
	assert_gt(seen, 15)


func test_camera_offset_follows_distance_and_pitch() -> void:
	var o := Feel.cam_offset_of(10.0, 30.0)
	assert_almost_eq(o.length(), 10.0, 0.001)
	assert_almost_eq(rad_to_deg(atan2(o.y, o.z)), 30.0, 0.001)
	assert_eq(o.x, 0.0)


func test_move_scale_by_kind_of_move() -> void:
	var f := Feel.new()
	f.move_scale_light = 0.6
	f.move_scale_heavy = 0.35
	f.move_scale_finisher = 0.15
	assert_eq(f.move_scale_for([&"light"] as Array[StringName]), 0.6)
	assert_eq(f.move_scale_for([&"heavy"] as Array[StringName]), 0.35)
	assert_eq(f.move_scale_for([&"heavy", &"finisher"] as Array[StringName]), 0.15)
