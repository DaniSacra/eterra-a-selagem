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
## The warnings' red (vfx_pass_spec.md 3, rule 5: the warning is hue 349 to 4), with a margin: a wind-up's light never
## reads as a warning on the floor. The dead's magenta (320 to 330, V-11) is not it.
func _is_red(c: Color) -> bool:
	var hue := c.h * 360.0
	return c.s > 0.4 and (hue >= 340.0 or hue <= 15.0)


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
	# LC-3: the flame over its hands, the motes round it and the thread down to the ring (no model: no palms)
	assert_eq(fx.put().size() - 1, EnemyFx.RITUAL_MOTES + 2, "and the motes, the flame and the thread")


## LC-1 to LC-3 (docs/backlog.md 9): each one's wind-up light sits where the drawn pose holds its crossbow, its orb or
## its hands (BakedModel.point: the mean of the part in the blend of two poses), turned and scaled with the figure.
func test_the_wind_up_lights_sit_on_the_part_drawn() -> void:
	var fx := _fx()
	var cases := {&"archer": [&"aim", "crossbow"], &"mage": [&"cast_hold", "orb"], &"priest": [&"cast", "hands"], &"priest_elder": [&"cast_hold", "orb"]}
	for id: StringName in cases:
		var m: BakedModel = load("res://assets/baked/%s.res" % _def(id).model)
		var anim: StringName = cases[id][0]
		var part: String = cases[id][1]
		assert_true(m.has_point(part), "%s has its %s" % [id, part])
		# the point is the mean of the part's vertices in the pose shown
		var vs: PackedInt32Array = m.parts.get(part, m.marks.get(part, PackedInt32Array()))
		var sum := Vector3.ZERO
		for v in vs:
			sum += m.position(anim, 1, v)
		var t := 1.0 / m.pose_rate(anim)
		assert_almost_eq(m.point(part, anim, t), sum / vs.size(), Vector3.ONE * 0.002, "%s: pose 1 of %s" % [id, anim])
		var e := _enemy(id, Vector2(4, -3))
		e.dir = Vector2.RIGHT
		var want := EnemyFx.anchor(e.pos, 0.0, e.yaw(), e.def.size, m.point(part, anim, t))
		assert_almost_eq(EnemyFx.spot(e, m, anim, t), want, Vector3.ONE * 0.001)
		fx.begin()
		fx.tell(e, 0.8, m, anim, t)
		var near := 0
		for q: Array in fx.put():
			if (q[1] as Vector3).distance_to(want) < 0.6 * e.def.size:
				near += 1
		assert_gt(near, 0, "%s: its lights on its %s" % [id, part])


## LC-1: the crossbow is drawn in light over the crossbowman's own body (aiming away it hid it); LC-3b: the priest's
## rite too (its back to the camera hid its arms); nothing else is.
func test_only_the_crossbow_is_drawn_over() -> void:
	var fx := _fx()
	for id: StringName in SHEET:
		if _def(id).tell == EnemyDef.Tell.NONE:
			continue
		fx.begin()
		fx.tell(_enemy(id), 0.8)
		var over := fx._over.slice(0, fx.count).count(1)
		if id == &"archer":
			assert_gte(over, 3, "the bow, the bolt, the tip and the sight")
		elif id == &"priest":
			assert_gte(over, 1, "the flame of the rite")
		else:
			assert_eq(over, 0, "%s: under what is in front" % id)
	fx.begin()
	fx.tell(_enemy(&"archer"), 0.8)
	fx.tell(_enemy(&"mage", Vector2(3, 0)), 0.8)
	fx.commit()
	assert_true(fx._over_mmi.visible and fx._mmi.visible)
	assert_eq(fx._over_mmi.multimesh.visible_instance_count + fx._mmi.multimesh.visible_instance_count, fx.count)
	# the priest's palms: one light at each raised hand (LC-3b: the V opened on the screen when seen from the side)
	var priest: BakedModel = load("res://assets/baked/priest.res")
	var e := _enemy(&"priest")
	var t := priest.duration(&"cast")
	fx.begin()
	fx.tell(e, 0.8, priest, &"cast", t)
	for hand: String in ["hand_l", "hand_r"]:
		var palm := EnemyFx.anchor(e.pos, 0.0, e.yaw(), e.def.size, priest.point(hand, &"cast", t))
		assert_true(fx.put().any(func(q: Array) -> bool: return q[0] == EnemyFx.Shape.DOT and (q[1] as Vector3).distance_to(palm) < EnemyFx.RITUAL_SPREAD * e.def.size), "a light at %s" % hand)
		assert_gt(palm.y, 0.7 * priest.height * e.def.size, "%s raised to the head" % hand)
	# the V of its arms: two strokes outlined in ink, drawn over, whichever way it faces
	for yaw_dir: Vector2 in [Vector2.RIGHT, Vector2.UP, Vector2.DOWN, Vector2.LEFT]:
		e.dir = yaw_dir
		fx.begin()
		fx.tell(e, 0.8, priest, &"cast", t)
		var arms := fx.put().filter(func(q: Array) -> bool: return q[0] == EnemyFx.Shape.BAR)
		assert_eq(arms.size(), 2, "two arms facing %s" % yaw_dir)
		assert_eq(fx.put().filter(func(q: Array) -> bool: return q[0] == EnemyFx.Shape.INK).size(), 2, "outlined facing %s" % yaw_dir)


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
			for wear: float in [0.0, 0.25, 0.55, 0.8, 1.0]:
				for absorbed: bool in [false, true]:
					for tell: float in [0.0, 0.4, 1.0]:
						var s := CrowdRenderer.state(0.6, frozen, burning, 0.0, absorbed, tell, wear)
						var back := CrowdRenderer.unpack(s)
						assert_almost_eq(back[0], 0.0 if absorbed else 0.6, 0.001, "white flash")
						assert_almost_eq(back[1], 0.6 if absorbed else 0.0, 0.001, "armor's gleam")
						assert_eq(back[2], 1.0 if frozen else 0.0, "frost")
						assert_almost_eq(back[3], 1.0 - wear, 0.001, "armor standing, worn in steps")
						assert_eq(back[4], 1.0 if burning else 0.0, "burning")
						assert_almost_eq(back[5], tell, 0.001, "wind-up")
	# nothing set: as the lab and the dying draw (the armored edge stays lit)
	assert_eq(CrowdRenderer.unpack(Color(0, 0, 0, 0)), [0.0, 0.0, 0.0, 1.0, 0.0, 0.0] as Array[float])


func test_armor_answers_a_blow_without_the_white_of_a_wound() -> void:
	var horde := _horde()
	var e := horde.spawn(_def(&"guard_elite"), Vector2(4, 0), false)
	e.max_armor = 330.0  # (no enemy has armor since 2026-11-27: the drawing of the bar is kept, so it is given by hand)
	e.armor = 330.0
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
	armored.max_armor = 80.0
	armored.armor = 80.0
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
	assert_true(magic.y > magic.x and magic.x > magic.z, "sickly green (sweep 2026-11-25, was magenta)")
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


## The crowd's drawing looks each kind up once (CrowdRenderer.Kind, Clip): one batch a clip, each figure drawn
## between the two poses BakedModel.blend_at says (its instance colour: pose rows in the model's images and the share of
## the next, E1a), a missing animation still falls back to walking, and only the batches with someone in them are shown
## (the ones emptied since the last frame are hidden).
func test_the_crowd_draws_the_poses_the_model_says() -> void:
	var renderer := CrowdRenderer.new()
	add_child_autofree(renderer)
	var d := _def(&"skeleton")
	renderer.register(d)
	var m := renderer.model_of(d)
	var kind := renderer.kind(d)
	assert_eq(kind.model, m)
	assert_almost_eq(kind.attack_time, m.duration(&"attack"), 0.0001)
	assert_eq(kind.has_brace, m.frame_count(&"brace") > 0)
	for anim: StringName in [&"walk", &"attack", &"death", &"idle"]:
		for t: float in [0.0, 0.07, 0.4, 1.3, 9.0]:
			renderer.begin()
			renderer.add(d, anim, t, Vector3.ZERO, 0.0, Color(0.3, 0, 0, 0))
			renderer.commit()
			var shown: Array[MultiMesh] = []
			for c in renderer.get_children():
				var mmi := c as MultiMeshInstance3D
				if mmi and mmi.visible and mmi.multimesh.use_colors and mmi.material_override is ShaderMaterial \
						and (mmi.material_override as ShaderMaterial).shader == CrowdRenderer.SHADER:
					shown.append(mmi.multimesh)
			assert_eq(shown.size(), 1, "%s at %.2f s: one batch" % [anim, t])
			var clip: CrowdRenderer.Clip = renderer._clip(kind, anim)
			var data := clip.batch.data
			var want := m.blend_at(anim, t)
			var first := float(m.first[anim])
			assert_almost_eq(data[12], first + want.x, 0.0001, "%s at %.2f s: pose %d" % [anim, t, want.x])
			assert_almost_eq(data[13], first + want.y, 0.0001, "and the next")
			assert_almost_eq(data[14], want.z, 0.0001, "and how far between")
			assert_almost_eq(data[16], 0.3, 0.0001, "the state follows the poses")
	if m.frame_count(&"brace") == 0:
		assert_eq(renderer._clip(kind, &"brace"), renderer._clip(kind, &"walk"), "a pose the figure lacks: it walks")
	renderer.begin()
	renderer.add(d, &"walk", 0.0, Vector3.ZERO, 0.0, Color())
	renderer.commit()
	renderer.begin()
	renderer.add(d, &"idle", 0.0, Vector3.ZERO, 0.0, Color())
	renderer.commit()
	var walking: CrowdRenderer.Clip = renderer._clip(kind, &"walk")
	assert_false(walking.batch.mmi.visible, "nobody walks now: hidden")


func test_a_character_is_placed_as_its_transform_says() -> void:
	var renderer := CrowdRenderer.new()
	add_child_autofree(renderer)
	var d := _def(&"runner")
	renderer.register(d)
	renderer.begin()
	var at := Vector3(3.0, 0.5, -2.0)
	var squash := Vector3(1.2, 0.8, 1.2)
	renderer.add(d, &"walk", 0.0, at, 0.7, Color(0.1, 0.2, 0.3, 0.0), squash, 0.3, 0.2)
	var b: CrowdRenderer.Batch = renderer._clip(renderer.kind(d), &"walk").batch
	var basis := (Basis(Vector3.UP, 0.7) * Basis(Vector3.RIGHT, 0.3) * Basis(Vector3.BACK, 0.2)).scaled(squash * d.size)
	var first := float(renderer.model_of(d).first[&"walk"])
	# the transform, the poses (first of the walk, the next, none of it yet, 1) and the state
	var want := [basis.x.x, basis.y.x, basis.z.x, at.x, basis.x.y, basis.y.y, basis.z.y, at.y, basis.x.z, basis.y.z, basis.z.z, at.z,
		first, first + 1.0, 0.0, 1.0, 0.1, 0.2, 0.3, 0.0]
	for i in want.size():
		assert_almost_eq(b.data[i], float(want[i]), 0.00001, "float %d" % i)
	var r := d.radius * 2.6 / maxf(1.0 + at.y * 0.3, 1.0)
	assert_almost_eq(renderer._shadow.data[0], r, 0.00001, "its shadow under it")
	assert_almost_eq(renderer._shadow.data[10], r, 0.00001)
	assert_almost_eq(renderer._shadow.data[7], 0.03, 0.00001)


func test_the_tells_drawn_over_are_not_covered_by_the_life_bars() -> void:
	# In a crowd the bars of the ones in front covered the priest's V and the crossbow: the over pass draws after them.
	var fx := EnemyFx.new()
	add_child_autofree(fx)
	var mat := fx._over_mmi.material_override as ShaderMaterial
	assert_gt(mat.render_priority, CrowdRenderer.BAR_PRIORITY, "the over pass draws after the life bars")
	assert_lte(mat.render_priority, RenderingServer.MATERIAL_RENDER_PRIORITY_MAX)


# ---- Combate C1 (docs/art/combate_c1_leitura.md): the guard on the floor, the priest's thread ----

func test_the_guard_is_drawn_by_the_rule_and_never_red() -> void:
	var horde := _horde()
	var g := _enemy(&"guard", Vector2(0, 8))
	g.face = Vector2.DOWN
	assert_true(horde.guard_up(g), "a guard standing is up")
	g.open_t = 1.0
	assert_false(horde.guard_up(g), "an open guard is not")
	assert_false(horde.blocks_front(g, Vector2(0, 12)), "and the rule reads the same function")
	g.open_t = 0.0
	g.state = Enemy.State.RECOVER
	assert_false(horde.guard_up(g), "spent: down")
	g.state = Enemy.State.WALK
	assert_true(horde.blocks_front(g, Vector2(0, 12)), "in front")
	assert_false(horde.blocks_front(g, Vector2(0, 4)), "behind it nothing blocks")
	assert_true(horde.guard_up(g), "yet the guard stays up (the drawing's question has no angle)")
	assert_false(_is_red(EnemyFx.STEEL), "the guard's steel is no warning")
	var fx := _fx()
	fx.begin()
	fx.guard_marks(g, true, false, 0.0)
	assert_eq(fx.count, EnemyFx.GUARD_STREAKS, "five streaks")
	var far: Array = fx.put()
	var low: float = (far[0][2] as Color).a
	assert_almost_eq(low, EnemyFx.GUARD_FAR, 0.001)
	for q: Array in far:
		var arc: Vector2 = Vector2(q[1].x, q[1].z) - g.pos
		assert_almost_eq(arc.length(), g.def.radius + EnemyFx.GUARD_REACH, 0.5, "round the arc")
		assert_gt(arc.dot(Vector2.DOWN), 0.0, "in front of it, never behind")
	fx.begin()
	fx.guard_marks(g, true, true, 0.0)
	assert_almost_eq((fx.put()[0][2] as Color).a, EnemyFx.GUARD_NEAR, 0.001, "clearer with the paladin in front")
	fx.begin()
	fx.guard_marks(g, true, false, 1.0)
	assert_almost_eq((fx.put()[2][2] as Color).a, EnemyFx.GUARD_BLOCK_ALPHA, 0.001, "a shut blow lights the middle one")


func test_an_open_guard_shows_none_then_comes_back_one_by_one() -> void:
	var horde := _horde()
	var g := _enemy(&"guard", Vector2(0, 8))
	var fx := _fx()
	g.open_t = 2.0
	fx.begin()
	fx.guard_marks(g, horde.guard_up(g), false, 0.0)
	assert_eq(fx.count, 0, "none while it is open")
	g.open_t = 1.0
	fx.begin()
	fx.guard_marks(g, horde.guard_up(g), false, 0.0)
	assert_eq(fx.count, 1, "the last second: the first (a side) is back")
	g.open_t = 0.15
	fx.begin()
	fx.guard_marks(g, horde.guard_up(g), false, 0.0)
	assert_eq(fx.count, 5, "and all of them by the end")


func test_the_priests_thread_is_old_gold_and_never_red() -> void:
	var fx := _fx()
	fx.begin()
	fx.ward_thread(Vector3(0, 1.3, 0), Vector3(3, 1.2, 0), false, 0.0, 0.0)
	assert_eq(fx.count, 2, "a thread and a bead")
	for q: Array in fx.put():
		var c: Color = q[2]
		assert_false(_is_red(Color(c.r, c.g, c.b).clamp()), "gold, not a warning")
		assert_lt(c.a, 1.0)
	assert_almost_eq((fx.put()[0][2] as Color).a, EnemyFx.WARD_ALPHA, 0.001)
	fx.begin()
	fx.ward_thread(Vector3(0, 1.3, 0), Vector3(3, 1.2, 0), true, 0.0, 0.0)
	assert_almost_eq((fx.put()[0][2] as Color).a, EnemyFx.WARD_ALPHA_CLOSE, 0.001, "the paladin close: the thread reads more")


func test_the_crossbowmans_colour_is_not_a_warning() -> void:
	assert_false(_is_red(EnemyFx.magic_of(_def(&"archer"))), "its bolt's light is orange")


func test_the_lock_ends_the_gleam_and_the_shield_light() -> void:
	var sk := _def(&"skeleton")
	assert_almost_eq(EnemyFx.lock_at(sk, 0.85), maxf(1.0 - sk.aim_lock / sk.attack_windup, EnemyFx.GLINT_FROM + 0.1), 0.001)
	assert_eq(EnemyFx.lock_at(_def(&"guard"), 0.85), 0.85, "nothing to lock: as it was")


func test_the_armor_wears_in_steps_at_75_50_and_25() -> void:
	assert_eq(EnemyFx.wear_level(100.0, 100.0), 0)
	assert_eq(EnemyFx.wear_level(75.0, 100.0), 0, "at 75 it still stands whole")
	assert_eq(EnemyFx.wear_level(74.0, 100.0), 1)
	assert_eq(EnemyFx.wear_level(49.0, 100.0), 2)
	assert_eq(EnemyFx.wear_level(24.0, 100.0), 3)
	assert_eq(EnemyFx.wear_level(0.0, 100.0), 4)
	assert_eq(EnemyFx.wear_level(0.0, 0.0), 0, "no armor to begin with: nothing worn")
	assert_eq(EnemyFx.wear(60.0, 100.0), 0.25)
	assert_eq(EnemyFx.wear(10.0, 100.0), 0.8)
	assert_eq(EnemyFx.wear(0.0, 100.0), 1.0)


func test_a_crack_throws_half_the_shards_of_a_break_slower() -> void:
	var fx := EnemyFx.new()
	add_child_autofree(fx)
	fx.armor_crack(Vector3(0, 1, 0), Vector2.RIGHT, 1.0)
	assert_eq(fx._sparks.size(), EnemyFx.CRACK_SHARDS)
	assert_eq(EnemyFx.CRACK_SHARDS * 2, EnemyFx.BREAK_SHARDS)
	fx._sparks.clear()
	fx.armor_crack(Vector3(0, 1, 0), Vector2.RIGHT, 1.0, true)
	assert_eq(fx._sparks.size(), EnemyFx.CRACK_SHARDS_GUARDIAN, "a guardian throws more")
	fx._sparks.clear()
	fx.armor_hit(Vector3(0, 1, 0), Vector2.RIGHT, EnemyFx.HEAVY_SPARKS)
	assert_eq(fx._sparks.size(), 10, "a heavy blow or an Omega: ten sparks")


func test_a_heavy_blow_on_armor_gives_the_body_a_little_and_cracks_once_per_step() -> void:
	var horde := _horde()
	var e := horde.spawn(_def(&"guard_elite"), Vector2(4, 0), false)
	e.max_armor = 330.0
	e.armor = 330.0
	horde.heavy_blow = true
	var before := e.max_armor
	horde.damage(e, e.max_armor * 0.3, Vector2.RIGHT, 0.0, Color.WHITE, false)
	assert_gt(e.crack_t, 0.0, "75 crossed")
	assert_almost_eq(e.recoil_peak, 0.04, 0.0001, "a guardian gives 4 cm")
	assert_gt(e.edge_t, 0.0)
	e.crack_t = 0.0
	horde.damage(e, e.max_armor * 0.05, Vector2.RIGHT, 0.0, Color.WHITE, false)
	assert_eq(e.crack_t, 0.0, "no new step: no crack")
	horde.damage(e, e.max_armor * 0.5, Vector2.RIGHT, 0.0, Color.WHITE, false)
	assert_gt(e.crack_t, 0.0, "two steps at once: one crack")
	assert_eq(e.max_armor, before)


func test_the_looks_of_the_guard_the_guardians_and_morvath_are_set() -> void:
	var r := CrowdRenderer.new()
	add_child_autofree(r)
	for id: StringName in [&"guard", &"guard_elite", &"knight", &"priest_elder", &"morvath"]:
		r.register(_def(id))
	var guard: ShaderMaterial = r._materials[&"guard"]
	assert_eq(guard.get_shader_parameter(&"paint_gamma"), 0.52, "GR-5: the curve lifts the black")
	assert_eq(guard.get_shader_parameter(&"style_rim_top"), 1.0)
	var elite: ShaderMaterial = r._materials[&"guard_elite"]
	assert_ne(elite.get_shader_parameter(&"paint_gamma"), 0.52, "the gilded one keeps its own")
	var edge := (r._materials[&"priest_elder"] as ShaderMaterial).next_pass as ShaderMaterial
	assert_eq(edge.get_shader_parameter(&"style_elite_width"), 0.035, "GR-6: the thin dark shell")
	assert_eq(edge.get_shader_parameter(&"style_push"), 0.60)
	var m: ShaderMaterial = r._materials[&"morvath"]
	assert_eq(m.get_shader_parameter(&"crest"), 0.8, "GR-7: the head, the light value")
	assert_eq(m.get_shader_parameter(&"foot_shade"), 0.40, "the skirt, the dark one")
	assert_almost_eq(float(m.get_shader_parameter(&"crest_from")), 2.02 * 0.86, 0.001)


func test_morvaths_eyes_are_violet_go_out_when_stunned_and_rise_in_the_wind_up() -> void:
	var m: BakedModel = load("res://assets/baked/morvath.res")
	assert_true(m.has_point("head"), "the bake marks his head")
	var fx := EnemyFx.new()
	add_child_autofree(fx)
	fx.begin()
	fx.eyes(Vector3(0, 2, 0), 0.0, 2.5, false, false)
	assert_eq(fx.put().size(), 2, "two points")
	fx.begin()
	fx.eyes(Vector3(0, 2, 0), 0.0, 2.5, false, true)
	assert_eq(fx.put().size(), 0, "stunned: out")
	assert_false(_is_red(EnemyFx.EYE_COLOR * EnemyFx.EYE_WINDUP), "never red")
	assert_lt(maxf(EnemyFx.EYE_COLOR.b, EnemyFx.EYE_COLOR.r) * EnemyFx.EYE_WINDUP, 1.3, "under the glow's threshold")


func test_the_priests_thread_parts_from_the_middle_when_it_falls() -> void:
	var fx := EnemyFx.new()
	add_child_autofree(fx)
	fx.ward_cut(Vector3.ZERO, Vector3(2, 1, 0))
	fx.begin()
	fx.commit()
	assert_eq(fx.count, 2, "two halves of light")
	fx._process(EnemyFx.WARD_CUT_TIME + 0.01)
	fx.begin()
	fx.commit()
	assert_eq(fx.count, 0, "gone in 0.18 s")


## N2: a broken poise draws a ring parted in six arcs (no text needed); a broken armor does not.
func test_poise_break_draws_six_arcs() -> void:
	var fx := _fx()
	fx.armor_break(Vector3(0, 1, 0), 1.0, EnemyFx.POISE_BREAK)
	fx.begin()
	fx.commit()
	var with_arcs := fx.count
	var plain := _fx()
	plain.armor_break(Vector3(0, 1, 0), 1.0)
	plain.begin()
	plain.commit()
	assert_eq(with_arcs - plain.count, EnemyFx.POISE_ARCS, "six arcs on top of the shards")
