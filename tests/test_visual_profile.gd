extends GutTest
## The visual profile of the stylized proof (STY-03, VisualProfile): CLASSIC by default, a look is a list of values
## next to each piece, the classic one is the piece as built (nothing in a material changes), and the switch (F7)
## puts the stylized values and takes them back exactly.

const STAGE := "res://data/stages/catacombs.tres"


func before_each() -> void:
	VisualProfile.set_look(VisualProfile.Look.CLASSIC)


func after_all() -> void:
	VisualProfile.set_look(VisualProfile.Look.CLASSIC)


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
