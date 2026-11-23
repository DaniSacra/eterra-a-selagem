extends GutTest
## The knight's thrown shield: hidden from his model while it is away and back when it returns, and drawn as his own shield.

func _baked(id: String) -> BakedModel:
	return load("res://assets/baked/%s.res" % id) as BakedModel


func test_state_away_flag_only_when_asked() -> void:
	assert_eq(CrowdRenderer.state(0.2, false, false).a, 0.0)
	assert_eq(CrowdRenderer.state(0.2, false, false, 0.0, false, 0.0, 0.0, true).a, -1.0)
	assert_eq(CrowdRenderer.state(0.2, false, false, 0.5).a, 0.5, "the dissolve is untouched")
	# the rest of the state reads the same either way
	var a := CrowdRenderer.unpack(CrowdRenderer.state(0.4, true, true, 0.0, true, 0.6, 0.5))
	var b := CrowdRenderer.unpack(CrowdRenderer.state(0.4, true, true, 0.0, true, 0.6, 0.5, true))
	assert_eq(a, b)


func test_knight_shield_is_one_run_and_the_shaders_hide_it() -> void:
	var run := CrowdRenderer.throwable_run(_baked("knight"))
	assert_gt(run.y, run.x, "the knight's shield is one run of vertices")
	assert_eq(run.y, _baked("knight").vertices, "held pieces end the mesh")
	var r := CrowdRenderer.new()
	add_child_autofree(r)
	var d := load("res://data/enemies/knight.tres") as EnemyDef
	r.register(d)
	var mat := r.kind(d).material as ShaderMaterial
	assert_eq(int(mat.get_shader_parameter(&"hide_from")), run.x)
	assert_eq(int(mat.get_shader_parameter(&"hide_to")), run.y)
	assert_string_contains((mat.shader as Shader).code + load("res://assets/shaders/crowd_pose.gdshaderinc").code, "crowd_away")


func test_while_away_the_state_hides_it_and_pickup_restores_it() -> void:
	var h := Horde.new()
	var k := Enemy.new()
	k.def = load("res://data/enemies/knight.tres") as EnemyDef
	k.away_t = 99.0
	assert_true(h.shield_away(k) and k.def.throw_flight > 0.0, "thrown: the render passes away = true")
	k.away_t = 0.0
	assert_false(h.shield_away(k), "back in hand: drawn again")
	h.free()


func test_guard_never_throws_so_nothing_hides() -> void:
	var g := load("res://data/enemies/guard.tres") as EnemyDef
	assert_eq(g.throw_flight, 0.0)


func test_thrown_shield_mesh_is_cut_from_the_model() -> void:
	var m := ThrownShield.build(_baked("knight"))
	assert_not_null(m)
	var tris: int = m.surface_get_arrays(0)[Mesh.ARRAY_INDEX].size() / 3
	assert_between(tris, 500, 1200, "the shield's own triangles (about 750)")
	var s := m.get_aabb().size
	assert_lt(s.y, minf(s.x, s.z), "lying flat: the thin axis is up")
	assert_almost_eq(ThrownShield.flight_basis(1.0, 1.0).y.y, 1.0, 0.001, "flat when it lands")
	assert_eq(ThrownShield.arc(0.0, 5.0), 0.0)
	assert_almost_eq(ThrownShield.arc(0.5, 5.0), 5.0, 0.001)
