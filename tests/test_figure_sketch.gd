extends GutTest
## AP-4, ART-07.4: the Compêndio's ink drawing of an enemy (FigureSketch) from its own baked model.


func test_three_passes_on_the_baked_poses() -> void:
	var d := load("res://data/enemies/skeleton.tres") as EnemyDef
	var r := CrowdRenderer.new()
	add_child_autofree(r)
	r.register(d)
	FigureSketch.apply(r, d)
	var m := r.kind(d).material as ShaderMaterial
	var passes: Array[ShaderMaterial] = [m, m.next_pass, m.next_pass.next_pass]
	assert_eq(passes[0].shader, FigureSketch.DEPTH)
	assert_eq(passes[1].shader, FigureSketch.EDGE)
	assert_eq(passes[2].shader, FigureSketch.LINES)
	assert_lt(passes[0].render_priority, passes[1].render_priority, "depth first, then the contour")
	assert_lt(passes[1].render_priority, passes[2].render_priority, "the lines last")
	for p in passes:
		assert_not_null(p.get_shader_parameter(&"pose_positions"), "every pass on the figure's poses")
	assert_not_null(passes[2].get_shader_parameter(&"albedo"), "the wash reads the model's own paint")
	assert_false(r.ground_shade, "no round shade under the feet on the paper")
	var ground := r.get_node_or_null(^"SketchGround") as MeshInstance3D
	assert_not_null(ground, "a few level strokes of ink under the feet")
	var g := ground.material_override as ShaderMaterial
	assert_between(int(g.get_shader_parameter(&"count")), 3, 5, "3 to 5 strokes")
	assert_lte(float(g.get_shader_parameter(&"alpha")), 0.5)
	assert_eq(float(passes[2].get_shader_parameter(&"gild")), 0.0, "a common figure without the gilt")


func test_an_elite_is_washed_in_gilt() -> void:
	var d := load("res://data/enemies/skeleton_elite.tres") as EnemyDef
	var r := CrowdRenderer.new()
	add_child_autofree(r)
	r.register(d)
	FigureSketch.apply(r, d)
	var lines := (r.kind(d).material as ShaderMaterial).next_pass.next_pass
	assert_eq(float(lines.get_shader_parameter(&"gild")), 1.0)


func test_three_quarter_view_frames_every_pose() -> void:
	for id in ["skeleton", "guard", "mage", "archer"]:
		var d := load("res://data/enemies/%s.tres" % id) as EnemyDef
		var model := load("res://assets/baked/%s.res" % d.model) as BakedModel
		var cam := Camera3D.new()
		add_child_autofree(cam)
		FigureSketch.fit(cam, d, model, &"idle", 1.0)
		var box := FigureSketch.clip_box(model, &"idle")
		var span := box.size * d.size
		assert_lte(maxf(span.y, span.x), cam.size * (1.0 - 2.0 * FigureSketch.MARGIN) + 0.001, "%s: every pose inside the margin" % id)
		var t := FigureSketch.pose_time(model, &"idle")
		assert_between(t, 0.0, 10.0, id)
	assert_between(FigureSketch.VIEW_YAW, 25.0, 35.0)
