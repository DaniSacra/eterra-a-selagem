extends GutTest
## P1-1 (DT-RS3): the shader warm-up set covers every shader file, and the warm-up draws each kind it holds.


func _items() -> Array:
	return (load(Warmup.SET) as Resource).get_meta(&"items", [])


func test_the_set_holds_every_shader_file() -> void:
	var seen := {}
	for item: Array in _items():
		var m := item[2] as ShaderMaterial
		if m != null and m.shader != null:
			seen[m.shader.resource_path] = true
	for f in DirAccess.get_files_at("res://assets/shaders"):
		if not f.ends_with(".gdshader"):
			continue
		var sh := load("res://assets/shaders/" + f) as Shader
		if sh.get_mode() in [Shader.MODE_SPATIAL, Shader.MODE_CANVAS_ITEM, Shader.MODE_FOG]:
			assert_true(seen.has(sh.resource_path), "%s in the warm-up set (tools/make_warmup.sh)" % f)


func test_the_set_has_both_looks_floor_and_crowd() -> void:
	var keys := PackedStringArray()
	for item: Array in _items():
		keys.append(item[1])
	var all := ",".join(keys)
	for want in ["catacomb_floor.gdshader", "catacomb_floor_paint.gdshader", "masonry_paint.gdshader",
			"multi:S:res://assets/shaders/crowd.gdshader", "StandardMaterial3D"]:
		assert_true(all.contains(want), want)
	assert_gt(keys.size(), 100)


func test_the_warmup_makes_a_node_for_every_item() -> void:
	var w := Warmup.new()
	w._quad = QuadMesh.new()
	w._multi_mesh = w._quad
	var made := 0
	for item: Array in _items():
		var n := w._make(item, made % 40)
		assert_not_null(n, "a node for %s" % item[1])
		if n != null:
			made += 1
			n.free()
	assert_eq(made, _items().size())
	w.free()


func test_no_warmup_without_a_screen() -> void:
	assert_false(Warmup.wanted(), "headless: nothing to compile")
	assert_null(Warmup.start(self))
