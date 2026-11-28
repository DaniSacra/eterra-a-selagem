extends GutTest
## PT28-11 (PaintedHall for the Santuario): the hub's entry waits for its painting (nothing changes until hub.png exists);
## the room's keep and hide names decide what the plate dresses.


func before_each() -> void:
	VisualProfile.set_look(VisualProfile.Look.STYLIZED)


func after_each() -> void:
	VisualProfile.set_look(VisualProfile.Look.CLASSIC)


func _wears(g: Node) -> bool:
	var m: Material = (g as GeometryInstance3D).material_override
	return m is ShaderMaterial and (m as ShaderMaterial).shader.resource_path.ends_with("painted.gdshader")


func test_the_hub_entry_waits_for_its_painting() -> void:
	assert_true(PaintedHall.ROOMS.has(&"hub"), "the hub has its entry")
	assert_true(&"hub" in PaintedHall.AWAITING)
	var l := HubPlan.layout()
	var has_file := ResourceLoader.exists(PaintedHall.ROOMS[&"hub"][&"painting"])
	assert_eq(PaintedHall.key_of(l) == &"hub", has_file, "painted only once hub.png is there")
	var a := Arena.new()
	add_child_autofree(a)
	a.layout = l
	assert_eq(PaintedHall.wanted(a), has_file)
	var p := PaintedHall.pose_of(&"hub")
	assert_eq([p[&"yaw"], p[&"pitch"], p[&"fov"], p[&"dist"]], [35.0, 30.0, 24.0, 105.0], "the plan's base capture")
	var soon := {&"hub": {&"painting": "res://assets/rooms/painted/sala01.png"}}
	assert_true(PaintedHall.delivered(&"hub", soon), "a painting that exists counts")
	assert_false(PaintedHall.delivered(&"hub", {&"hub": {&"painting": "res://nope.png"}}), "one that is missing does not")


func test_keep_and_hide_names_decide_what_the_plate_dresses() -> void:
	var entry := {&"painting": "res://assets/rooms/painted/sala01.png", &"yaw": 35.0, &"pitch": 30.0, &"fov": 24.0, &"dist": 68.0,
		&"at": Vector2.ZERO, &"v_span": 1.0}
	entry[&"keep"] = ["KeepMe"]
	entry[&"hide"] = ["HideMe"]
	var root := Node3D.new()
	add_child_autofree(root)
	var made := {}
	for nm: String in ["Stone", "KeepMe_bed", "HideMe_cards"]:
		var mi := MeshInstance3D.new()
		mi.name = nm
		mi.mesh = BoxMesh.new()
		mi.material_override = StandardMaterial3D.new()
		root.add_child(mi)
		made[nm] = mi
	var node := PaintedHall.new()
	node.table = {&"t": entry}
	node.room = &"t"
	add_child_autofree(node)
	node._mat = node._material(node._pose(), 0.0)
	node._walk(root, null)
	assert_true(_wears(made["Stone"]), "plain stone takes the plate")
	assert_false(_wears(made["KeepMe_bed"]), "a kept piece stays the game's own 3D")
	assert_true((made["KeepMe_bed"] as MeshInstance3D).visible)
	assert_false((made["HideMe_cards"] as MeshInstance3D).visible, "what the plate paints is hidden")
	assert_false(PaintedHall.named(root, ["Zzz"]))


func test_hub_lists_are_data_in_the_entry() -> void:
	var p := PaintedHall.pose_of(&"hub")
	assert_true("Garden" in p[&"keep"] and "Lanterns" in p[&"keep"], "the Videira's bed and the lanterns stay 3D")
	assert_true("Cypresses" in p[&"hide"], "the foliage cards are the plate's")
