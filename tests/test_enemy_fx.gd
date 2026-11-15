extends GutTest
## Cycle 7, the part each enemy plays read at a glance (docs/art/cycle7_spec.md, 4 and 2.7): the lights of the
## wind-ups (EnemyFx), the state the crowd's shader reads, the armor's answer to a blow, the thinner bars of a full
## floor. All of it is only drawn: the simulation's dice and the enemies' places are never touched.

const DIR := "res://data/enemies/"
const SHEET: Array[StringName] = [&"skeleton", &"runner", &"mage", &"archer", &"guard", &"priest", &"knight", &"priest_elder", &"morvath"]


func _def(id: StringName) -> EnemyDef:
	return load(DIR + "%s.tres" % id)


func _enemy(id: StringName, at := Vector2.ZERO) -> Enemy:
	var e := Enemy.new()
	e.def = _def(id)
	e.pos = at
	e.dir = Vector2.DOWN
	e.aim = Vector2.DOWN
	return e


func _fx() -> EnemyFx:
	var fx := EnemyFx.new()
	add_child_autofree(fx)
	return fx


func _horde() -> Horde:
	var horde := Horde.new()
	add_child_autofree(horde)
	return horde


## Red on the floor and in the air is danger (the warnings of Ground): no wind-up light may read as red.
func _is_red(c: Color) -> bool:
	return c.r > 1.5 * c.g and c.r > 1.5 * c.b


func test_each_part_has_its_wind_up() -> void:
	var T := EnemyDef.Tell
	var want := {&"skeleton": T.GLINT, &"runner": T.TREMBLE, &"mage": T.ORB, &"archer": T.BOLT, &"guard": T.SHIELD,
		&"priest": T.RITUAL, &"knight": T.SHIELD, &"priest_elder": T.ORB, &"morvath": T.NONE}
	for id: StringName in want:
		var d := _def(id)
		assert_eq(d.tell, want[id], "%s winds up in its own way" % id)
		if d.elite_version != &"":
			var elite := _def(d.elite_version)
			assert_eq(elite.tell, d.tell, "the elite of %s winds up the same way" % id)
			assert_eq(elite.tell_at, d.tell_at)


func test_a_wind_up_draws_its_lights_and_none_is_red() -> void:
	var fx := _fx()
	for id in SHEET:
		var d := _def(id)
		if d.tell == EnemyDef.Tell.NONE:
			continue
		var most := 0
		for k: float in [0.1, 0.5, 0.75, 0.95]:
			fx.begin()
			fx.tell(_enemy(id), k)
			most = maxi(most, fx.count)
			for quad: Array in fx.put():
				assert_false(_is_red(quad[2]), "%s at %.2f: %s is red" % [id, k, quad[2]])
		assert_gt(most, 0, "%s shows its wind-up" % id)
	# nothing for the one that has none
	fx.begin()
	fx.tell(_enemy(&"morvath"), 0.9)
	assert_eq(fx.count, 0)


func test_the_blade_gleams_only_in_the_second_half_and_is_gone_at_the_blow() -> void:
	var fx := _fx()
	var e := _enemy(&"skeleton")
	fx.begin()
	fx.tell(e, 0.3)
	assert_eq(fx.count, 0, "nothing before half of the wind-up")
	fx.begin()
	fx.tell(e, 0.75)
	assert_gt(fx.count, 0, "the gleam at its fullest")
	fx.begin()
	fx.tell(e, 1.0)
	assert_eq(fx.count, 0, "gone when the blade comes down")


func test_the_ritual_ring_is_faint_and_lies_around_the_priest() -> void:
	var fx := _fx()
	var e := _enemy(&"priest", Vector2(3, -2))
	fx.begin()
	fx.tell(e, 0.9)
	var rings := fx.put().filter(func(q: Array) -> bool: return q[0] == EnemyFx.Shape.RING)
	assert_eq(rings.size(), 1)
	assert_almost_eq((rings[0][1] as Vector3).x, 3.0, 0.001)
	assert_almost_eq((rings[0][1] as Vector3).z, -2.0, 0.001)
	assert_lt((rings[0][1] as Vector3).y, 0.2, "on the floor")
	assert_lte((rings[0][2] as Color).a, 0.3 + 0.001, "never as strong as a warning")
	assert_eq(fx.put().size() - 1, EnemyFx.RITUAL_MOTES, "and the motes between its hands")


func test_the_lights_follow_the_figure() -> void:
	# ahead of it is where it faces, scaled by its size
	var at := EnemyFx.anchor(Vector2(10, 5), 0.0, 0.0, 2.0, Vector3(0, 1, 0.5))
	assert_almost_eq(at, Vector3(10, 2, 6), Vector3.ONE * 0.001)
	var turned := EnemyFx.anchor(Vector2(10, 5), 0.0, PI * 0.5, 2.0, Vector3(0, 1, 0.5))
	assert_almost_eq(turned, Vector3(11, 2, 5), Vector3.ONE * 0.001)
	# an enemy's yaw is the one the crowd is drawn with: its front is where it looks
	var e := _enemy(&"archer")
	e.dir = Vector2.RIGHT
	var tip := EnemyFx.anchor(e.pos, 0.0, e.yaw(), 1.0, Vector3(0, 0, 1))
	assert_almost_eq(tip, Vector3(1, 0, 0), Vector3.ONE * 0.001)


func test_the_reserve_is_fixed() -> void:
	var fx := _fx()
	fx.begin()
	for i in 200:
		fx.tell(_enemy(&"mage", Vector2(i, 0)), 0.8)
	assert_eq(fx.count, EnemyFx.POOL, "past the reserve nothing more is drawn")
	fx.commit()
	assert_eq(fx._mmi.multimesh.instance_count, EnemyFx.POOL, "and nothing is allocated")


func test_a_lunge_trails_pale_streaks_and_leaves_dust_where_it_started() -> void:
	var fx := _fx()
	var e := _enemy(&"skeleton", Vector2(0, 4))
	fx.begin()
	fx.loosed(e, 0.1)
	var streaks := fx.put().filter(func(q: Array) -> bool: return q[0] == EnemyFx.Shape.STREAK)
	assert_eq(streaks.size(), 2)
	for s: Array in streaks:
		assert_lt((s[1] as Vector3).z, 4.0, "behind it (it lunges toward +z)")
	fx.begin()
	fx.loosed(e, e.def.lunge_time + 0.01)
	assert_eq(fx.count, 0, "gone when the lunge ends")


func test_armor_sparks_are_old_gold_and_short() -> void:
	var fx := _fx()
	fx.armor_hit(Vector3(0, 1, 0), Vector2.RIGHT)
	assert_between(fx._sparks.size(), 3, 4)
	fx.armor_break(Vector3(0, 1, 0), 1.5)
	assert_between(fx._sparks.size() - EnemyFx.ABSORB_SPARKS, 10, 14)
	fx.begin()
	fx.commit()
	for quad: Array in fx.put():
		var c: Color = quad[2]
		assert_true(c.r > c.g and c.g > c.b and not _is_red(c), "old gold: %s" % c)
	fx._process(0.36)
	assert_eq(fx._sparks.size(), 0, "all gone in 0.35 s")
	assert_lte(EnemyFx.BREAK_TIME, 0.6)


func test_the_state_survives_its_packing() -> void:
	for frozen: bool in [false, true]:
		for burning: bool in [false, true]:
			for broken: bool in [false, true]:
				for absorbed: bool in [false, true]:
					for tell: float in [0.0, 0.4, 1.0]:
						var s := CrowdRenderer.state(0.6, frozen, burning, 0.0, absorbed, tell, broken)
						var back := CrowdRenderer.unpack(s)
						assert_almost_eq(back[0], 0.0 if absorbed else 0.6, 0.001, "white flash")
						assert_almost_eq(back[1], 0.6 if absorbed else 0.0, 0.001, "armor's gleam")
						assert_eq(back[2], 1.0 if frozen else 0.0, "frost")
						assert_almost_eq(back[3], 0.0 if broken else 1.0, 0.001, "armor standing")
						assert_eq(back[4], 1.0 if burning else 0.0, "burning")
						assert_almost_eq(back[5], tell, 0.001, "wind-up")
	# nothing set: as the lab and the dying draw (the armored edge stays lit)
	assert_eq(CrowdRenderer.unpack(Color(0, 0, 0, 0)), [0.0, 0.0, 0.0, 1.0, 0.0, 0.0] as Array[float])


func test_armor_answers_a_blow_without_the_white_of_a_wound() -> void:
	var horde := _horde()
	var e := horde.spawn(_def(&"guard_elite"), Vector2(4, 0), false)
	horde.damage(e, 10.0, Vector2.RIGHT, 5.0, Color.WHITE, false)
	assert_true(e.absorbed, "the armor took it")
	assert_gt(e.armor, 0.0)
	var broke := [false]
	horde.armor_broken.connect(func(_who: Enemy) -> void: broke[0] = true)
	horde.damage(e, 10000.0, Vector2.RIGHT, 5.0, Color.WHITE, false)
	assert_true(broke[0])
	assert_between(horde.tells._sparks.size(), 10, 14, "the shards of the armor, once")
	horde.damage(e, 1.0, Vector2.RIGHT, 5.0, Color.WHITE, false)
	assert_false(e.absorbed, "a blow on the body is a wound again")


func test_drawing_never_rolls_the_simulation_dice_nor_moves_anyone() -> void:
	var horde := _horde()
	var ids: Array[StringName] = [&"skeleton", &"runner", &"mage", &"archer", &"guard", &"priest", &"knight", &"priest_elder", &"skeleton_elite"]
	var states := [Enemy.State.WALK, Enemy.State.WINDUP, Enemy.State.ATTACK]
	var i := 0
	for id in ids:
		for s: Enemy.State in states:
			var e := horde.spawn(_def(id), Vector2(i * 2.0, 0), false)
			e.state = s
			e.state_t = 0.05 if s == Enemy.State.ATTACK else 0.6
			e.anim = &"attack" if s == Enemy.State.ATTACK else (&"walk" if s == Enemy.State.WALK else &"windup")
			e.anim_t = 0.37
			i += 1
	var dice := horde._rng.state
	var places: Array[Vector2] = []
	for e in horde.list:
		places.append(e.pos)
	horde.render()
	assert_gt(horde.tells.count, 0, "the wind-ups are drawn")
	var armored := horde.list[horde.list.size() - 1]
	horde.damage(armored, 5.0, Vector2.RIGHT, 0.0, Color.WHITE, false)
	horde.damage(armored, 10000.0, Vector2.RIGHT, 0.0, Color.WHITE, false)
	horde.render()
	assert_eq(horde._rng.state, dice, "the horde's generator was not touched")
	for k in horde.list.size():
		assert_eq(horde.list[k].pos, places[k], "nobody moved")


func test_each_enemy_gets_a_number_of_its_own_for_what_is_only_drawn() -> void:
	var horde := _horde()
	var seen := {}
	for i in 20:
		var e := horde.spawn(_def(&"runner"), Vector2(i, 0), false)
		assert_between(e.look, 0.0, 1.0)
		assert_false(seen.has(snappedf(e.look, 0.001)), "no two the same")
		seen[snappedf(e.look, 0.001)] = true
	var again := _horde()
	assert_eq(again.spawn(_def(&"runner"), Vector2.ZERO, false).look, horde.list[0].look, "by the order of spawning, not by chance")


func test_the_runner_is_unsteady_and_the_soldier_is_the_base_line() -> void:
	var runner := _def(&"runner")
	assert_between(runner.sway, 6.0, 8.0, "its trunk sways 6 to 8 degrees")
	assert_almost_eq(runner.windup_shake, 0.04, 0.001)
	assert_between(Horde.SWAY_HZ, 8.0, 10.0)
	assert_between(Horde.SHAKE_HZ, 13.0, 15.0)
	assert_true(runner.tint.r > runner.tint.g and runner.tint.g > runner.tint.b, "warmer, dirtier bone")
	var skeleton := _def(&"skeleton")
	assert_eq(skeleton.sway, 0.0)
	assert_lt(skeleton.vivid, 0.0, "the soldier is the greyest of the crowd")
	assert_gt(_def(&"priest").vivid, _def(&"archer").vivid, "the priest's purple is a little more alive than the crossbowman's")


func test_morvath_keeps_his_colours_and_his_crown_is_cut_out() -> void:
	var renderer := CrowdRenderer.new()
	add_child_autofree(renderer)
	var morvath := _def(&"morvath")
	var skeleton := _def(&"skeleton")
	renderer.register(morvath)
	renderer.register(skeleton)
	var his: ShaderMaterial = renderer._materials[morvath.id]
	var plain: ShaderMaterial = renderer._materials[skeleton.id]
	assert_lt(float(his.get_shader_parameter(&"desaturate")), 0.0, "more colour than the painting, not the crowd's grey")
	assert_gt(float(plain.get_shader_parameter(&"desaturate")), CrowdRenderer.CROWD_GREY, "the soldier is greyer than the crowd")
	assert_gt(float(his.get_shader_parameter(&"crest")), 0.0)
	assert_eq(float(plain.get_shader_parameter(&"crest")), 0.0)
	assert_gt(float(his.get_shader_parameter(&"paint_glow")), float(plain.get_shader_parameter(&"paint_glow")), "gem and eyes shine more")
	assert_almost_eq(morvath.size, 2.53, 0.001, "nothing of him changes size")


func test_magic_lights_are_the_colour_of_the_magic_and_gold_stays_on_the_steel() -> void:
	var renderer := CrowdRenderer.new()
	add_child_autofree(renderer)
	var mage := _def(&"mage")
	var elite := _def(&"skeleton_elite")
	renderer.register(mage)
	renderer.register(elite)
	var magic: Vector3 = (renderer._materials[mage.id] as ShaderMaterial).get_shader_parameter(&"magic")
	assert_almost_eq(maxf(magic.x, maxf(magic.y, magic.z)), 1.0, 0.001, "its largest channel at 1")
	assert_true(magic.z > magic.x and magic.x > magic.y, "cold violet")
	assert_lt(CrowdRenderer.ORB_GLOW, CrowdRenderer.ORB_TELL)
	assert_lte(CrowdRenderer.ORB_TELL, 1.8, "the swollen orb is capped")
	var gilded: ShaderMaterial = renderer._materials[elite.id]
	assert_eq(float(gilded.get_shader_parameter(&"gild_rest")), 0.0, "skull, bones and cloth keep their colours")
	assert_eq((gilded.get_shader_parameter(&"magic") as Vector3), Vector3.ZERO, "no magic: the painting's lights as painted")


func test_bars_thin_out_on_a_full_floor() -> void:
	var renderer := CrowdRenderer.new()
	add_child_autofree(renderer)
	var d := _def(&"skeleton")
	renderer.register(d)
	renderer.begin()
	renderer.add_bar(d, Vector3.ZERO, 0.5, 0.0)
	renderer.add_bar(d, Vector3.ZERO, 0.5, 0.0, true)
	var data := renderer._bars.data
	var per := CrowdRenderer.FLOATS
	assert_almost_eq(data[5], CrowdRenderer.BAR_HEIGHT, 0.0001)
	assert_almost_eq(data[per + 5], CrowdRenderer.BAR_HEIGHT * 0.75, 0.0001, "75% of the height")
	assert_almost_eq(data[14], 1.0, 0.0001)
	assert_almost_eq(data[per + 14], 0.7, 0.0001, "70% of the opacity")


func test_a_full_floor_is_what_thins_them() -> void:
	var horde := _horde()
	for i in Horde.BARS_FOR_ALL:
		horde.spawn(_def(&"skeleton"), Vector2(i, 0), false)
	horde.render()
	assert_almost_eq(horde.renderer._bars.data[14], 1.0, 0.0001, "up to %d enemies the bars are whole" % Horde.BARS_FOR_ALL)
	var hurt := horde.spawn(_def(&"skeleton"), Vector2(-3, 0), false)
	hurt.hp *= 0.5
	horde.render()
	assert_eq(horde.renderer._bars.count, 1, "past it only the hurt show one")
	assert_almost_eq(horde.renderer._bars.data[14], CrowdRenderer.BAR_CROWD_FADE, 0.0001, "and fainter")
