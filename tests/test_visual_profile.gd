extends GutTest
## The visual profile of the stylized proof (STY-03, VisualProfile): CLASSIC by default, a look is a list of values
## next to each piece, the classic one is the piece as built (nothing in a material changes), and the switch (F7)
## puts the stylized values and takes them back exactly.

const STAGE := "res://data/stages/catacombs.tres"


func before_each() -> void:
	VisualProfile.set_look(VisualProfile.Look.CLASSIC)
	Dev.put("painted", "off")  # GP-8: these check the stone look the painted rooms replace (test_painted_hall has the painting)


func after_all() -> void:
	VisualProfile.set_look(VisualProfile.Look.CLASSIC)
	Dev.drop("painted")


func test_names_and_default() -> void:
	assert_eq(VisualProfile.parse("stylized"), VisualProfile.Look.STYLIZED)
	assert_eq(VisualProfile.parse("Stylized"), VisualProfile.Look.STYLIZED)
	assert_eq(VisualProfile.parse("classic"), VisualProfile.Look.CLASSIC)
	assert_eq(VisualProfile.parse("whatever"), VisualProfile.Look.CLASSIC)
	assert_eq(VisualProfile.current(), VisualProfile.Look.CLASSIC)
	assert_false(VisualProfile.stylized())


func test_global_follows_the_look() -> void:
	VisualProfile.set_look(VisualProfile.Look.STYLIZED)
	assert_eq(VisualProfile.art_style(), 1.0)
	assert_true(VisualProfile.stylized())
	VisualProfile.toggle()
	assert_eq(VisualProfile.art_style(), 0.0)
	assert_false(VisualProfile.stylized())


func test_vary_puts_and_takes_back() -> void:
	var m := ShaderMaterial.new()
	m.shader = Masonry.SHADER
	m.set_shader_parameter(&"rock_value", 0.35)
	var other := Shader.new()
	VisualProfile.vary(m, {&"shader": other, &"shader_parameter/rock_value": 0.12})
	assert_eq(m.shader, Masonry.SHADER, "classic: as built")
	VisualProfile.toggle()
	assert_eq(m.shader, other)
	assert_almost_eq(float(m.get_shader_parameter(&"rock_value")), 0.12, 0.0001)
	VisualProfile.toggle()
	assert_eq(m.shader, Masonry.SHADER)
	assert_almost_eq(float(m.get_shader_parameter(&"rock_value")), 0.35, 0.0001)
	# registered while stylized: its present values are still its classic ones
	var n := Node3D.new()
	add_child_autofree(n)
	VisualProfile.set_look(VisualProfile.Look.STYLIZED)
	VisualProfile.vary(n, {&"visible": false})
	assert_false(n.visible)
	VisualProfile.set_look(VisualProfile.Look.CLASSIC)
	assert_true(n.visible)
	VisualProfile.release(m)
	VisualProfile.release(n)


func test_freed_objects_are_dropped() -> void:
	var before := VisualProfile.count()
	var n := Node3D.new()
	VisualProfile.vary(n, {&"visible": false})
	assert_eq(VisualProfile.count(), before + 1)
	n.free()
	VisualProfile.toggle()
	VisualProfile.toggle()
	assert_eq(VisualProfile.count(), before)


func _hall() -> Arena:
	var stage: StageDef = load(STAGE)
	for l in stage.layouts:
		if l.id == &"hall":
			var a := Arena.new()
			add_child_autofree(a)
			a.build(l, 3, 1406)
			return a
	return null


## Every material, light and visibility of the hall as one text: shaders, their parameters, the material overrides,
## the lights' range, falloff and energy, which nodes are shown.
func _snapshot(root: Node) -> PackedStringArray:
	var out := PackedStringArray()
	for n in root.find_children("*", "Node3D", true, false):
		var line := "%s v%s" % [root.get_path_to(n), n.visible]
		if n is GeometryInstance3D:
			var g := n as GeometryInstance3D
			var mats: Array = [g.material_override]
			if g is MeshInstance3D and (g as MeshInstance3D).mesh != null:
				var mesh := (g as MeshInstance3D).mesh
				for i in mesh.get_surface_count():
					mats.append(mesh.surface_get_material(i))
			for m: Material in mats:
				line += " | " + _material(m)
		elif n is Light3D:
			var l := n as Light3D
			line += " %s %s %s" % [l.light_energy, l.light_color, l.get_param(Light3D.PARAM_RANGE)]
			if l is OmniLight3D:
				line += " %s" % (l as OmniLight3D).omni_attenuation
		out.append(line)
	return out


func _material(m: Material) -> String:
	if m == null:
		return "-"
	if m is ShaderMaterial:
		var s := m as ShaderMaterial
		var t := str(s.shader.resource_path if s.shader != null else "")
		if s.shader != null:
			for u: Dictionary in s.shader.get_shader_uniform_list():
				t += " %s=%s" % [u.name, s.get_shader_parameter(u.name)]
		return t
	if m is StandardMaterial3D:
		var b := m as StandardMaterial3D
		return "std %s %s" % [b.albedo_color, b.emission]
	return str(m)


func test_the_hall_classic_changes_nothing_and_the_switch_comes_back() -> void:
	var a := _hall()
	var before := _snapshot(a)
	var pillars := a.pillars.duplicate()
	var boxes := a.boxes.duplicate()
	VisualProfile.set_look(VisualProfile.Look.STYLIZED)
	var styled := _snapshot(a)
	assert_ne(styled, before, "the stylized look changes the hall")
	var painted := 0
	for line in styled:
		if line.contains("_paint.gdshader"):
			painted += 1
	assert_gt(painted, 10, "stone, floor and kit painted")
	VisualProfile.set_look(VisualProfile.Look.CLASSIC)
	var back := _snapshot(a)
	assert_eq(back.size(), before.size())
	var differ := 0
	for i in mini(back.size(), before.size()):
		if back[i] != before[i]:
			differ += 1
			if differ < 4:
				gut.p("differs: %s\n  was: %s" % [back[i], before[i]])
	assert_eq(differ, 0, "classic is the hall as built")
	assert_eq(a.pillars, pillars, "the same circles")
	assert_eq(a.boxes, boxes, "the same boxes")


func test_the_hall_built_while_stylized_comes_back_to_classic() -> void:
	var classic := _snapshot(_hall())
	VisualProfile.set_look(VisualProfile.Look.STYLIZED)
	var a := _hall()
	VisualProfile.set_look(VisualProfile.Look.CLASSIC)
	var back := _snapshot(a)
	var differ := 0
	for i in mini(back.size(), classic.size()):
		if back[i].get_slice(" ", 1) != classic[i].get_slice(" ", 1):
			differ += 1
	assert_eq(back.size(), classic.size())
	assert_eq(differ, 0, "the same visibility either way")


func _elun_nodes(a: Arena) -> Array[Node]:
	var out: Array[Node] = []
	for n in a.find_children("*", "MeshInstance3D", true, false):
		var mi := n as MeshInstance3D
		if mi.material_override is ShaderMaterial and (mi.material_override as ShaderMaterial).shader.resource_path.ends_with("beam.gdshader"):
			out.append(mi)
	return out


func test_the_shaft_of_elun_and_the_coloured_shadow_are_stylized_only() -> void:
	VisualProfile.set_look(VisualProfile.Look.STYLIZED)
	var a := _hall()
	var shafts := _elun_nodes(a)
	assert_eq(shafts.size(), 1, "one shaft of Elun in the hall")
	assert_true((shafts[0] as Node3D).visible, "shown in the stylized look")
	VisualProfile.set_look(VisualProfile.Look.CLASSIC)
	assert_false((shafts[0] as Node3D).visible, "gone in the classic look (F7)")
	VisualProfile.set_look(VisualProfile.Look.STYLIZED)
	var floor_painted := 0
	for n in a.find_children("*", "GeometryInstance3D", true, false):
		var m := (n as GeometryInstance3D).material_override as ShaderMaterial
		if m != null and m.shader != null and m.shader.resource_path.ends_with("catacomb_floor_paint.gdshader"):
			assert_eq(m.get_shader_parameter(&"paint_vignette_set"), CatacombHall.STY_VIGNETTE)
			assert_eq(m.get_shader_parameter(&"paint_shadow_glow"), CatacombHall.STY_SHADOW_GLOW)
			floor_painted += 1
	assert_gt(floor_painted, 0, "the painted floor takes the coloured shadow and the vignette")


func test_the_fountain_shaft_is_ivory_gold_only_when_stylized() -> void:
	VisualProfile.set_look(VisualProfile.Look.CLASSIC)
	var cold := RewardShaft.fountain_tint()
	VisualProfile.set_look(VisualProfile.Look.STYLIZED)
	var warm := RewardShaft.fountain_tint()
	assert_gt(cold.h, 0.45, "classic: the cold blue")
	assert_almost_eq(warm.h * 360.0, 40.0, 3.0, "stylized: hue 40")
