extends GutTest
## W-1 (decision D-69): the special reads as the Emeth's blade wave instead of a dart. Only its look changed: its
## rule, numbers, speed, reach, hit and timing are the ones of the cycle C12d special (Hades II's), checked here.

const TREE := "res://data/combos/paladin.tres"

var horde: Horde
var fx: Fx
var projectiles: Projectiles


func before_each() -> void:
	var camera := Camera3D.new()
	camera.position = Vector3(0, 30, 30)
	add_child_autofree(camera)
	camera.look_at(Vector3.ZERO)
	var overlay := Control.new()
	add_child_autofree(overlay)
	fx = Fx.new()
	add_child_autofree(fx)
	fx.setup(camera, overlay)
	horde = Horde.new()
	add_child_autofree(horde)
	horde.fx = fx
	projectiles = Projectiles.new()
	add_child_autofree(projectiles)
	projectiles.horde = horde
	projectiles.fx = fx
	projectiles.player = Player.new()
	autofree(projectiles.player)


func _move(id: StringName) -> ComboNode:
	for node in (load(TREE) as ComboTree).all_nodes():
		if node.id == id:
			return node
	return null


func test_the_special_keeps_its_numbers() -> void:
	var bolt := _move(&"bolt")
	assert_not_null(bolt, "the special")
	assert_eq(bolt.effect, ComboNode.Effect.WAVE)
	assert_true(bolt.wave_bolt, "flies as the special's shot (SPARK)")
	assert_eq(bolt.effect_power, 35.0, "damage 35 (the rajada, weak start 2026-11-21)")
	assert_almost_eq(bolt.effect_radius, 6.0, 0.001, "reach 6 m")
	assert_eq(bolt.magick_cost, 12.0, "12 Magia")
	assert_almost_eq(bolt.effect_size, 1.4, 0.001, "1.4 m across")
	assert_almost_eq(bolt.cooldown, 0.5, 0.001)
	assert_almost_eq(bolt.move_hold, 0.71, 0.001, "legs held 0.71 s, only the dodge cuts it (D-44)")
	assert_almost_eq(bolt.recovery, 18.0 / 60.0, 0.001)
	assert_almost_eq(Projectiles.SPARK_SPEED, 62.5, 0.001, "Hades II's ProjectileStaffBall")
	assert_null(_move(&"burst"), "the held special left the Warrior's tree")


func test_the_wave_flies_and_hits_as_the_dart_did() -> void:
	var tags: Array[StringName] = [&"wave"]
	var s := projectiles.fire_wave(Projectiles.Kind.SPARK, Vector2.ZERO, Vector2.RIGHT, 40.0, 11.0, 1.4, Combat.EMETH, tags)
	assert_almost_eq(s.vel.length(), 62.5, 0.001, "speed")
	assert_almost_eq(s.radius, 0.7, 0.001, "hit circle")
	assert_almost_eq(s.life, 11.0 / 62.5, 0.0001, "flies 11 m")
	assert_eq(s.knockback, 10.0)
	var held := projectiles.fire_wave(Projectiles.Kind.WAVE, Vector2.ZERO, Vector2.UP, 80.0, 11.0, 8.25, Combat.EMETH, tags)
	assert_almost_eq(held.vel.length(), 22.0, 0.001, "the held one's speed")
	assert_almost_eq(held.radius, 4.125, 0.001, "the held one's hit circle")
	# the wave is drawn as wide as the held one hits
	var mat: ShaderMaterial = (held.node as MeshInstance3D).material_override
	assert_almost_eq(float(mat.get_shader_parameter(&"span_m")), 8.25, 0.001)


func test_the_wave_hits_each_enemy_on_its_line_once() -> void:
	var hit: Array = []
	projectiles.shot_hit.connect(func(e: Enemy, _s: Projectiles.Shot) -> void: hit.append(e))
	var near := horde.spawn(horde.def(&"skeleton"), Vector2(4.0, 0.3), false)
	var far := horde.spawn(horde.def(&"skeleton"), Vector2(9.0, -0.3), false)
	var aside := horde.spawn(horde.def(&"skeleton"), Vector2(5.0, 2.5), false)
	var past := horde.spawn(horde.def(&"skeleton"), Vector2(14.0, 0.0), false)
	var tags: Array[StringName] = [&"wave"]
	projectiles.fire_wave(Projectiles.Kind.SPARK, Vector2.ZERO, Vector2.RIGHT, 40.0, 11.0, 1.4, Combat.EMETH, tags)
	for i in 30:
		projectiles.step(1.0 / 120.0)
	assert_true(hit.has(near) and hit.has(far), "both on its line")
	assert_false(hit.has(aside), "nothing out of its 0.7 m")
	assert_false(hit.has(past), "nothing past its 11 m")
	assert_eq(hit.count(near), 1, "once each")
	assert_true(projectiles.shots.is_empty(), "gone after its flight")


func test_the_wave_stays_under_the_glow() -> void:
	assert_lt(Projectiles.WAVE_PEAK, Game.GLOW_THRESHOLD)
	assert_lt(Projectiles.WAVE_PEAK * Projectiles.WAVE_GOLD_LIGHT, Game.GLOW_THRESHOLD)


func test_the_edge_stays_under_the_screen_cap() -> void:
	for c: Color in [Combat.EMETH, Color(1.0, 0.45, 0.15), Color(0.5, 0.8, 1.0)]:
		var edge := c.lerp(Color.WHITE, Projectiles.WAVE_EDGE_PALE)
		var peak := Projectiles.wave_peak(c)
		assert_lte(peak, Projectiles.WAVE_PEAK)
		var lin := Color(edge.srgb_to_linear().r, edge.srgb_to_linear().g, edge.srgb_to_linear().b)
		var top := maxf(lin.r, maxf(lin.g, lin.b))
		assert_lte(ScreenTone.peak8(Color(lin.r / top * peak, lin.g / top * peak, lin.b / top * peak), false), ScreenTone.SAFE + 1)
