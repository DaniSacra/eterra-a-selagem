extends GutTest
## AP-2 "Combate que se lê", the technical-artist's part (docs/backlog.md A6): Morvath's red only late in the wind-up
## (ART-05.2), the scythe opening round the paladin (ART-05.4), the runner elite's first burst inside the next ring
## (P2-C19a) and the Retorno do Corte's thread on the blade (V-08). Only the look: shapes, times and damage unchanged.


## A uniform's default as written in the shader's (or an include's) source.
func _default(path: String, name: String) -> Variant:
	var re := RegEx.create_from_string("uniform\\s+\\w+\\s+" + name + "\\s*(?::[^=;]*)?=\\s*([^;]+);")
	var found := re.search(FileAccess.get_file_as_string(path))
	assert_not_null(found, name + " in " + path)
	return str_to_var(found.get_string(1).replace("vec2(", "Vector2(")) if found != null else null


func test_eruption_red_is_faint_until_the_last_of_the_warning() -> void:
	var rune := "res://assets/shaders/ritual_rune.gdshader"
	assert_almost_eq(float(_default(rune, "fill_early")), 0.25, 0.001, "a quarter of the red while the blow is far off")
	assert_almost_eq(float(_default(rune, "fill_late")), 0.3, 0.001, "all of it only over the last 30%, as the plain warnings")
	assert_lt(float(_default(rune, "red_after")), 0.5, "the red leaves soon after it lands")
	assert_almost_eq(float(_default(rune, "danger_alpha")), 0.24, 0.001, "its ceiling did not change")


func test_his_signed_fill_follows_the_same_regime() -> void:
	var ground := "res://assets/shaders/ground.gdshaderinc"
	assert_almost_eq(float(_default(ground, "sign_early")), 0.3, 0.001)
	assert_almost_eq(float(_default(ground, "sign_fill")), 0.35, 0.001, "his full fill as before at the blow")
	for pass_path in ["res://assets/shaders/ground.gdshader", "res://assets/shaders/ground_fill.gdshader"]:
		assert_true(FileAccess.get_file_as_string(pass_path).contains("ground.gdshaderinc"), "both passes read the same body")
	var body := FileAccess.get_file_as_string(ground)
	assert_eq(body.count("sign_fill * sign_level()"), 2, "the line, the arc and the circle all ramp")


func test_the_scythe_opens_round_the_paladin_only() -> void:
	var scythe := "res://assets/shaders/boss_scythe.gdshader"
	var hole: Vector2 = _default(scythe, "hero_hole")
	assert_gt(hole.y, hole.x)
	assert_lt(float(_default(scythe, "hero_keep")), 1.0)
	assert_true(FileAccess.get_file_as_string(scythe).contains("rim * rim_light + blade"), "the rim and the blade line never open")


func test_a_thin_landing_stays_inside_the_next_ring() -> void:
	var smoke := "res://assets/shaders/smoke_ring.gdshader"
	var reach := float(_default(smoke, "thin_reach"))
	# Ground lays the ring at 1.1 of the warning's radius and its band is band * 0.35 wide
	var band := float(_default(smoke, "band")) * 0.35
	assert_lt((reach + band) * 1.1, 0.95, "the first burst never reaches the second warning's rim")


func _holder() -> Node:
	var combat := GDScript.new()
	combat.source_code = "extends RefCounted\nvar _return_t := 0.0\n"
	combat.reload()
	var game := GDScript.new()
	game.source_code = "extends Node3D\nvar combat: Object\n"
	game.reload()
	var g: Node3D = game.new()
	g.set(&"combat", combat.new())
	add_child_autofree(g)
	g.add_child(EmethSword.make())
	return g


func test_the_return_thread_follows_the_window() -> void:
	var g := _holder()
	var fx := Fx.new()
	g.add_child(fx)
	var blade := EmethSword.blade_of(g)
	var combat: Object = g.get(&"combat")
	# never set: the shader's default, 0
	var thread := func() -> float:
		var v: Variant = blade.get_shader_parameter(&"return_thread")
		return 0.0 if v == null else float(v)
	fx._animate_return()
	assert_eq(thread.call(), 0.0, "nothing without the Encanto's window")
	combat.set(&"_return_t", 1.0)
	fx._animate_return()
	assert_almost_eq(thread.call(), 1.0, 0.001, "whole as the window opens")
	combat.set(&"_return_t", 0.4)
	fx._animate_return()
	assert_almost_eq(thread.call(), 0.4, 0.001, "it fades with the window")
	combat.set(&"_return_t", 0.9)
	fx._animate_return()
	assert_almost_eq(thread.call(), 1.0, 0.001, "a new Corte Veloz opens a new window")
	combat.set(&"_return_t", 0.0)
	fx._animate_return()
	assert_eq(thread.call(), 0.0, "gone with the blow that takes it")


func test_no_ghosts_without_a_screen() -> void:
	var fx := Fx.new()
	add_child_autofree(fx)
	assert_true(fx._ghost_off, "headless: no mesh to bake, nothing to see")
	fx._animate_ghosts(0.016)
	assert_eq(fx._ghosts.size(), 0)
