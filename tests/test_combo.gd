extends GutTest
## The heart of the game: the combo tree is data, and ComboRunner walks it with an input buffer.

const L := ComboNode.In.LIGHT
const H := ComboNode.In.HEAVY
const C := ComboNode.In.CHARGE

var tree: ComboTree
var runner: ComboRunner
var started: Array[StringName]
var hits: Array[StringName]
var drops: int


func before_each() -> void:
	tree = load("res://data/combos/paladin.tres")
	runner = ComboRunner.new(tree)
	started = []
	hits = []
	drops = 0
	runner.move_started.connect(func(n: ComboNode) -> void: started.append(n.id))
	runner.move_hit.connect(func(n: ComboNode) -> void: hits.append(n.id))
	runner.combo_dropped.connect(func() -> void: drops += 1)


## Advances time in small steps, like frames.
func run(seconds: float) -> void:
	var t := 0.0
	while t < seconds:
		runner.step(1.0 / 120.0)
		t += 1.0 / 120.0


## Presses an input and plays the move it starts to the end.
func play(input: ComboNode.In) -> void:
	runner.press(input)
	runner.step(0.0)
	if runner.node != null:
		run(runner.node.duration() + 0.01)


func play_all(inputs: Array) -> void:
	for input: ComboNode.In in inputs:
		play(input)


func test_the_named_moves_exist() -> void:
	var names := {}
	for m in tree.named_moves():
		names[m.node.id] = ComboTree.notation(m.path, m.from_dodge, {"dodge": "Esquiva", "charge": "D segurado", "charge_light": "E segurado"})
	assert_eq(names.get(&"lance"), "E segurado")
	assert_eq(names.get(&"cut3"), "E E E")
	assert_eq(names.get(&"bolt"), "D")
	assert_eq(names.get(&"burst"), "D segurado")
	assert_eq(names.get(&"dash_cut"), "Esquiva + E")
	assert_eq(names.size(), 5)


## The attack is three swings (as the first weapon of Hades II): 20, 25, then 60 all around.
func test_three_attacks_end_in_the_spin() -> void:
	play_all([L, L, L])
	assert_eq(started, [&"cut1", &"cut2", &"cut3"] as Array[StringName])
	assert_eq(hits.size(), 3)
	assert_eq(runner.node.shape, ComboNode.Shape.CIRCLE)


func test_attack_damage_and_timing_follow_hades() -> void:
	var cut1 := ComboTree.find(tree.neutral, L)
	var cut2 := cut1.following()[0]
	var cut3 := cut2.following()[0]
	assert_eq([cut1.damage, cut2.damage, cut3.damage], [20.0, 25.0, 60.0])
	assert_almost_eq(cut1.windup, 0.06, 0.001)
	assert_almost_eq(cut2.windup, 0.11, 0.001)
	assert_almost_eq(cut3.windup, 0.28, 0.001)  # Hades: 0.36; quicker at Daniel's ask (2026-11-14)
	assert_almost_eq(cut3.chain_window, 0.6, 0.001)


func test_the_special_strikes_only_with_its_bolt() -> void:
	play(H)
	assert_eq(started, [&"bolt"] as Array[StringName])
	assert_eq(runner.node.damage, 0.0)
	assert_eq(runner.node.effect, ComboNode.Effect.WAVE)
	assert_eq(runner.node.effect_power, 40.0)


func test_the_special_can_follow_any_swing() -> void:
	play_all([L, H])
	assert_eq(started, [&"cut1", &"bolt"] as Array[StringName])


func test_charge_input_bursts() -> void:
	assert_true(runner.charge_available(), "standing still, the special can be charged")
	play(C)
	assert_eq(started, [&"burst"] as Array[StringName])
	assert_almost_eq(runner.node.charge_time, 0.65, 0.001)


func test_the_omega_attack_strikes_both_ways() -> void:
	var lance := ComboTree.find(tree.neutral, ComboNode.In.CHARGE_LIGHT)
	assert_true(lance.both_ways)
	assert_eq(lance.damage, 160.0)
	assert_almost_eq(lance.charge_time, 0.8, 0.001)
	assert_eq(lance.magick_cost, 20.0)


## A charge pressed while a swing ends is honoured (the paladin fires the Omega when the charge fills).
func test_a_buffered_omega_starts_after_the_swing() -> void:
	runner.press(L)
	runner.step(0.0)
	run(0.05)
	runner.press(ComboNode.In.CHARGE_LIGHT)
	run(1.0)
	assert_eq(started, [&"cut1", &"lance"] as Array[StringName])


func test_dodge_opens_the_dodge_moves() -> void:
	runner.on_dodge()
	run(0.2)
	runner.on_dodge_end()
	play(L)
	assert_eq(started, [&"dash_cut"] as Array[StringName])


func test_input_during_the_roll_is_buffered_until_it_ends() -> void:
	runner.on_dodge()
	run(0.1)
	runner.press(L)
	run(0.05)
	assert_eq(started.size(), 0, "nothing starts while rolling")
	runner.on_dodge_end()
	runner.step(0.0)
	assert_eq(started, [&"dash_cut"] as Array[StringName])


func test_dodge_window_closes() -> void:
	runner.on_dodge()
	runner.on_dodge_end()
	run(tree.dodge_window + 0.05)
	play(L)
	assert_eq(started, [&"cut1"] as Array[StringName])


func test_buffer_keeps_an_early_press_for_150_ms() -> void:
	runner.press(L)
	runner.step(0.0)
	var cut1 := runner.node
	run(cut1.duration() - 0.1)
	runner.press(L)
	run(0.2)
	assert_eq(started, [&"cut1", &"cut2"] as Array[StringName], "pressed 100 ms before the end: honoured")


func test_buffer_drops_a_press_that_came_too_early() -> void:
	tree = tree.duplicate(true)
	tree.neutral[0].chain_window = 0.0
	runner.tree = tree
	runner.press(L)
	runner.step(0.0)
	run(0.01)
	runner.press(L)
	run(tree.neutral[0].duration() + 0.1)
	assert_eq(started.size(), 1, "pressed more than 150 ms before the end, and no window after it")


func test_chain_window_is_per_node() -> void:
	play(L)
	run(tree.neutral[0].chain_window - 0.05)
	play(L)
	assert_eq(started[1], &"cut2", "inside the window the chain continues")


func test_chain_drops_after_the_window() -> void:
	play(L)
	run(tree.neutral[0].chain_window + 0.05)
	assert_eq(drops, 1)
	play(L)
	assert_eq(started[1], &"cut1", "after the window the chain starts over")


func test_a_fourth_attack_starts_the_chain_again() -> void:
	play_all([L, L, L, L])
	assert_eq(started[3], &"cut1")


func test_only_the_end_of_a_move_can_be_cancelled() -> void:
	runner.press(L)
	runner.step(0.0)
	assert_false(runner.can_cancel(), "not during the windup")
	run(runner.node.windup + 0.01)
	assert_eq(hits.size(), 1)
	assert_true(runner.can_cancel(), "the recovery can be cut by a dodge")
	runner.on_dodge()
	assert_false(runner.is_attacking())


func test_reset_drops_the_chain_and_the_buffer() -> void:
	play(L)
	runner.press(L)
	runner.reset()
	run(0.3)
	assert_eq(started.size(), 1)
	assert_eq(drops, 1)


func test_tree_data_is_sane() -> void:
	var player: AnimationPlayer = AnimationPlayer.new()
	player.add_animation_library(&"", load(HeroBody.ANIMS))
	var ids := {}
	for node in tree.all_nodes():
		assert_false(ids.has(node.id), "duplicate id %s" % node.id)
		ids[node.id] = true
		assert_true(node.damage > 0.0 or node.effect == ComboNode.Effect.WAVE, "%s strikes somehow" % node.id)
		assert_gt(node.windup, 0.0, String(node.id))
		assert_between(node.hit_stop_ms, 0.0, 80.0, String(node.id))
		assert_true(player.has_animation(node.anim), "missing animation %s" % node.anim)
		assert_gt(node.anim_speed, 0.0, String(node.id))
		if node.title != &"":
			assert_ne(T.t(node.title), String(node.title), "missing name for %s" % node.id)
		var inputs := {}
		for child in node.following():
			assert_false(inputs.has(child.input), "%s has two moves on the same input" % node.id)
			inputs[child.input] = true
	assert_almost_eq(tree.buffer_time, 0.15, 0.001)
	player.free()

func test_a_new_combo_needs_only_data() -> void:
	var extra := ComboNode.new()
	extra.id = &"test_extra"
	extra.input = H
	extra.title = &"move_spin"
	tree = tree.duplicate(true)
	ComboTree.find(tree.neutral, L).following()[0].next.append(extra)
	runner.tree = tree
	play_all([L, L, H])
	assert_eq(started[2], &"test_extra")


func test_move_scale_follows_the_kind_of_move() -> void:
	var feel := Feel.new()
	assert_eq(runner.move_scale(feel), 1.0, "free to walk between moves")
	runner.press(ComboNode.In.LIGHT)
	runner.step(0.0)
	assert_eq(runner.node.id, &"cut1")
	assert_eq(runner.move_scale(feel), 0.0, "the feet stay planted while the blade swings (Ember & Blade)")
	play_all([L, L])
	runner.press(L)
	runner.step(0.0)
	assert_eq(runner.node.id, &"cut3")


func test_a_move_can_set_its_own_move_scale() -> void:
	var feel := Feel.new()
	var n := ComboNode.new()
	n.tags = [&"heavy"]
	assert_eq(n.move_scale_with(feel), feel.move_scale_heavy)
	n.move_scale = 0.9
	assert_eq(n.move_scale_with(feel), 0.9)


func test_the_drawn_arc_is_exactly_what_the_blow_reaches() -> void:
	for node in tree.all_nodes():
		for bonus: float in [0.0, 0.25]:
			var s := Combat.swing_shape(node, bonus)
			assert_almost_eq(float(s.draw_reach), float(s.hit_reach), 0.0001, "%s reach" % node.id)
			assert_almost_eq(float(s.hit_reach), node.reach * (1.0 + bonus), 0.0001, "%s reach bonus" % node.id)
			if node.shape == ComboNode.Shape.ARC:
				assert_eq(float(s.draw_width), float(s.hit_width), "%s width" % node.id)
			if node.shape == ComboNode.Shape.CIRCLE:
				assert_eq(float(s.draw_width), 360.0, "%s goes all around" % node.id)


## Every finisher holds a short glint before it lands (0.06 to 0.1 s, backlog BUG-003); the plain swings never hold.
func test_only_finishers_glint() -> void:
	var glinting := 0
	for n in tree.all_nodes():
		if n.has_tag(&"finisher"):
			assert_between(n.glint, 0.06, 0.1, "%s is a finisher: it glints 0.06 to 0.1 s" % n.id)
			glinting += 1
		else:
			assert_eq(n.glint, 0.0, "%s glints but is not a finisher" % n.id)
	assert_gt(glinting, 0, "at least one move glints")


func _enemy(id: StringName) -> Enemy:
	var e := Enemy.new()
	e.def = load("res://data/enemies/%s.tres" % id)
	return e


## The impact frame (a flat black and white frame) is kept for the two biggest moments (D-08): an Omega that lands
## and the blow that ends a boss's phase, never while the last one is less than Feel.impact_frame_every old.
func test_impact_frame_only_for_omegas_and_phase_breaks() -> void:
	assert_false(Combat.wants_impact_frame(false, false, 0.0), "a common blow, even a finisher into a crowd")
	assert_true(Combat.wants_impact_frame(true, false, 0.0), "an Omega that lands")
	assert_true(Combat.wants_impact_frame(false, true, 0.0), "the blow that ends a phase")
	assert_false(Combat.wants_impact_frame(true, true, 0.5), "never inside the cooldown")
	var boss := _enemy(&"morvath")
	boss.max_hp = 100.0
	boss.hp_floor = 66.0
	boss.hp = 66.0
	assert_true(Combat.breaks_phase(boss, 70.0), "down to the floor of his phase")
	assert_false(Combat.breaks_phase(boss, 66.0), "already at the floor (his next phase not begun yet)")
	boss.hp = 68.0
	assert_false(Combat.breaks_phase(boss, 70.0), "still above it")
	boss.hp_floor = 0.0
	boss.hp = 0.0
	boss.alive = false
	assert_true(Combat.breaks_phase(boss, 5.0), "the blow that fells him")
	var knight := _enemy(&"knight")
	knight.hp = 0.0
	knight.alive = false
	assert_false(Combat.breaks_phase(knight, 5.0), "only a boss has phases")


## The held (Omega) moves cost Magia; a plain chain never does.
func test_only_omega_moves_cost_magick() -> void:
	for n in tree.all_nodes():
		if n.has_tag(&"omega"):
			assert_gt(n.magick_cost, 0.0, String(n.id))
			assert_true(n.input == ComboNode.In.CHARGE or n.input == ComboNode.In.CHARGE_LIGHT, String(n.id))
		else:
			assert_eq(n.magick_cost, 0.0, String(n.id))


func test_holding_light_offers_the_omega_attack() -> void:
	assert_eq(runner.charge_move(ComboNode.In.CHARGE_LIGHT).id, &"lance")


func test_sweep_follows_the_arm() -> void:
	var n := ComboNode.new()
	assert_true(n.sweep_flip(true), "no sweep set: alternate")
	assert_false(n.sweep_flip(false), "no sweep set: alternate")
	n.sweep = 1
	assert_false(n.sweep_flip(true), "right to left is the slash's own way")
	n.sweep = 2
	assert_true(n.sweep_flip(false), "left to right flips it")


func test_feet_planted_while_swinging_free_after_the_blow() -> void:
	var feel := Feel.new()
	feel.move_scale_light = 0.0
	runner.press(L)
	runner.step(0.0)
	assert_true(runner.is_swinging())
	assert_eq(runner.move_scale(feel), 0.0, "planted during the swing")
	run(runner.node.windup + 0.01)
	assert_false(runner.is_swinging())
	assert_true(runner.is_attacking(), "still in the follow-through")
	assert_eq(runner.move_scale(feel), 1.0, "walking cuts the follow-through")


func test_lunge_carries_to_the_enemy_ahead() -> void:
	var n := ComboNode.new()
	n.lunge = 1.0
	assert_eq(n.lunge_toward(INF), 1.0, "nobody ahead: the plain step")
	assert_eq(n.lunge_toward(2.0), 2.0, "an enemy a little away: the step stretches to reach it")
	assert_eq(n.lunge_toward(99.0), 1.0 + ComboNode.LUNGE_MAGNET, "but only so far")
	assert_eq(n.lunge_toward(-0.5), 0.15, "an enemy already in reach: barely a step, no running through it")
	n.lunge = 0.0
	assert_eq(n.lunge_toward(2.0), 0.0, "moves without a step stay put")


func test_blade_lands_with_the_blow() -> void:
	# the clip reaches its swing peak (measured by tools/bake_hero.gd) exactly when the windup ends, never before
	var peaks: Dictionary = (load("res://tools/make_data.gd") as GDScript).get_script_constant_map()["PEAK"]
	var tree: ComboTree = load("res://data/combos/paladin.tres")
	for node: ComboNode in tree.all_nodes():
		if not peaks.has(node.anim):
			continue
		var at_windup_end := node.anim_from + node.windup * node.anim_speed
		assert_almost_eq(at_windup_end, float(peaks[node.anim]), 0.02, String(node.id))
