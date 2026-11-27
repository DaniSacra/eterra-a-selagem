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
	# GP-1: the left button's hold is the Esmagador (E segurado), the right's tap the Corte Circular (D) and its hold the Lança (D segurado)
	assert_eq(names.get(&"smash"), "E segurado")
	assert_eq(names.get(&"cut3"), "E E E")
	assert_eq(names.get(&"sweep"), "D")
	assert_eq(names.get(&"lance"), "D segurado")
	assert_false(names.has(&"bolt") or names.has(&"dash_cut") or names.has(&"shout"), "the burst, the Investida and the Brado left the buttons")
	assert_eq(names.size(), 4)


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
	assert_eq([cut1.damage, cut2.damage, cut3.damage], [20.0, 20.0, 40.0])  # SWORN sword: 20, 20, 40
	# E1c: Hades II's staff (docs/design/hades2_feel_study.md): windup + glint, attack lock, legs held
	assert_almost_eq(cut1.lead(), 0.08, 0.001)
	assert_almost_eq(cut2.lead(), 0.13, 0.001)
	assert_almost_eq(cut3.lead(), 0.36, 0.001)
	assert_almost_eq(cut1.recovery, 8.0 / 60.0, 0.001)
	assert_almost_eq(cut2.recovery, 13.0 / 60.0, 0.001)
	assert_almost_eq(cut3.recovery, 18.0 / 60.0, 0.001)
	assert_almost_eq(cut1.move_hold, 11.0 / 60.0, 0.001)
	assert_almost_eq(cut2.move_hold, 19.0 / 60.0, 0.001)
	assert_almost_eq(cut3.move_hold, 30.0 / 60.0, 0.001)
	assert_almost_eq(cut3.chain_window, 0.6, 0.001)


func test_the_right_tap_is_the_corte_circular() -> void:
	play(H)
	assert_eq(started, [&"sweep"] as Array[StringName])
	assert_eq(runner.node.damage, 40.0)
	assert_eq(runner.node.shape, ComboNode.Shape.CIRCLE)
	assert_eq(runner.node.effect, ComboNode.Effect.NONE, "it is no Brado: no buff")


func test_the_corte_circular_can_follow_any_swing() -> void:
	play_all([L, H])
	assert_eq(started, [&"cut1", &"sweep"] as Array[StringName])


func test_both_buttons_have_a_held_blow() -> void:
	assert_true(runner.charge_available(), "the right's hold is the Lança")
	assert_true(runner.charge_available(ComboNode.In.CHARGE_LIGHT), "the left's the Esmagador")


func test_the_lance_strikes_both_ways() -> void:
	var lance := ComboTree.find(tree.neutral, ComboNode.In.CHARGE)
	assert_true(lance.both_ways)
	assert_eq(lance.damage, 375.0)
	assert_almost_eq(lance.charge_time, 0.8, 0.001)
	assert_eq(lance.magick_cost, 20.0)
	var smash := ComboTree.find(tree.neutral, ComboNode.In.CHARGE_LIGHT)
	assert_eq([smash.damage, smash.magick_cost, smash.charge_time], [200.0, 12.0, 0.6])


## A charge pressed while a swing ends is honoured (the paladin fires the Omega when the charge fills).
func test_a_buffered_omega_starts_after_the_swing() -> void:
	runner.press(L)
	runner.step(0.0)
	run(0.05)
	runner.press(ComboNode.In.CHARGE_LIGHT)
	run(1.0)
	assert_eq(started, [&"cut1", &"smash"] as Array[StringName])


func test_the_dodge_opens_no_move_of_its_own() -> void:
	runner.on_dodge()
	run(0.2)
	runner.on_dodge_end()
	play(L)
	assert_eq(started, [&"cut1"] as Array[StringName], "no Corte Veloz out of the dodge since 2026-11-21: the Investida is the E button")


func test_input_during_the_roll_is_buffered_until_it_ends() -> void:
	runner.on_dodge()
	run(0.1)
	runner.press(L)
	run(0.05)
	assert_eq(started.size(), 0, "nothing starts while rolling")
	runner.on_dodge_end()
	runner.step(0.0)
	assert_eq(started, [&"cut1"] as Array[StringName])


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


## GF-04 (C12d): the buffer counts from the moment the blow could start (Hades II's trigger lock), so a press at the
## very start of a swing still chains, even with no window after it.
func test_buffer_keeps_a_press_from_the_start_of_the_swing() -> void:
	tree = tree.duplicate(true)
	tree.neutral[0].chain_window = 0.0
	runner.tree = tree
	runner.press(L)
	runner.step(0.0)
	run(0.01)
	runner.press(L)
	run(tree.neutral[0].duration() + 0.1)
	assert_eq(started, [&"cut1", &"cut2"] as Array[StringName], "pressed in the windup: it waits for the swing to end")


## A press that cannot start yet in the open (a move on its cooldown: the Maga's, here the Corte Circular given 5 s) is dropped after buffer_time.
func test_buffer_drops_a_press_that_waits_in_the_open() -> void:
	tree = tree.duplicate(true)
	ComboTree.find(tree.neutral, H).cooldown = 5.0
	runner.tree = tree
	play(H)
	run(ComboTree.find(tree.neutral, H).chain_window + 0.01)
	assert_gt(runner.cooldown_left(&"sweep"), tree.buffer_time + 0.02, "still on its cooldown")
	runner.press(H)
	run(runner.cooldown_left(&"sweep") + 0.1)
	assert_eq(started, [&"sweep"] as Array[StringName], "the press waited only buffer_time")


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


## GF-02 (C12d): a dodge cuts any move, its windup too (Hades II cuts the charge); a cut windup never lands.
func test_a_dodge_cuts_the_windup_and_the_blow_never_lands() -> void:
	runner.press(L)
	runner.step(0.0)
	assert_true(runner.can_cancel(), "the windup can be cut")
	runner.on_dodge()
	assert_false(runner.is_attacking())
	run(0.5)
	assert_eq(hits.size(), 0, "the blow it cut never lands")


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
		assert_between(node.hit_stop_ms, 0.0, 110.0, String(node.id))  # CF2-02: the spin 100 ms
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
		if n.has_tag(&"finisher") or n.has_tag(&"smash"):
			assert_between(n.glint, 0.06, 0.12, "%s is a finisher (or the Esmagador): it glints 0.06 to 0.12 s" % n.id)
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


## The held (Omega) moves cost Magia; a tap never does (the Corte Circular is free since 2026-11-27).
func test_only_omega_moves_cost_magick() -> void:
	for n in tree.all_nodes():
		if n.has_tag(&"omega"):
			assert_gt(n.magick_cost, 0.0, String(n.id))
			assert_true(n.input == ComboNode.In.CHARGE or n.input == ComboNode.In.CHARGE_LIGHT, String(n.id))
		else:
			assert_eq(n.magick_cost, 0.0, String(n.id))


func test_holding_light_offers_the_omega_attack() -> void:
	assert_eq(runner.charge_move(ComboNode.In.CHARGE_LIGHT).id, &"smash")
	assert_eq(runner.charge_move(ComboNode.In.CHARGE).id, &"lance")


func test_sweep_follows_the_arm() -> void:
	var n := ComboNode.new()
	assert_true(n.sweep_flip(true), "no sweep set: alternate")
	assert_false(n.sweep_flip(false), "no sweep set: alternate")
	n.sweep = 1
	assert_false(n.sweep_flip(true), "right to left is the slash's own way")
	n.sweep = 2
	assert_true(n.sweep_flip(false), "left to right flips it")


func test_feet_planted_from_the_press_to_the_end_of_the_leg_hold() -> void:
	# E1c (Daniel: "tem que atacar parado"; Hades II's MoveHold): planted in the windup and move_hold after the blow,
	# past the attack lock (the next blow may start before the legs are free)
	var feel := Feel.new()
	feel.move_scale_light = 0.0
	runner.press(L)
	runner.step(0.0)
	var n := runner.node
	assert_gt(n.move_hold, n.recovery, "the legs are held longer than the attack is")
	assert_true(runner.is_swinging())
	assert_true(runner.planted())
	assert_eq(runner.move_scale(feel), 0.0, "planted during the windup")
	run(n.windup + 0.01)
	assert_false(runner.is_swinging())
	assert_true(runner.planted(), "held after the blow")
	assert_eq(runner.move_scale(feel), 0.0, "no walking in the hold")
	run(n.recovery)
	assert_false(runner.is_attacking(), "the next blow may start")
	assert_true(runner.planted(), "but the legs are still held")
	run(n.move_hold - n.recovery)
	assert_false(runner.planted(), "free once the hold ends")
	assert_eq(runner.move_scale(feel), 1.0)


func test_the_leg_hold_outlasts_the_chain_and_the_dodge_cuts_it() -> void:
	runner.press(H)
	run(0.2)
	assert_eq(runner.node.id, &"sweep")
	assert_true(runner.planted(), "the Corte Circular holds the legs 0.35 s after it lands")
	assert_almost_eq(runner.legs_left(), 0.35 - 0.02, 0.03)
	runner.on_dodge()
	assert_false(runner.planted(), "the dodge cuts it")


func test_no_blow_of_the_combo_walks_the_paladin_but_each_steps_as_it_lands() -> void:
	# PT-25-4 and PT-25-11 (it replaces "struck standing still"): no walking and no lunge before the blow; each blow of
	# the combo takes a short step as it lands, the finisher the longest
	var tree: ComboTree = load("res://data/combos/paladin.tres")
	for node: ComboNode in tree.all_nodes():
		if node.has_tag(&"dash"):
			continue  # the Investida carries him along its line
		assert_eq(node.lunge, 0.0, "%s has no lunge from the press" % node.id)
		assert_eq(node.move_scale, 0.0, "%s keeps no walking" % node.id)
		if node.has_tag(&"light") and node.input == ComboNode.In.LIGHT:
			assert_between(node.step, 0.2, 1.0, "%s steps a little as it lands" % node.id)
	var by := {}
	for node: ComboNode in tree.all_nodes():
		by[node.id] = node
	assert_almost_eq((by[&"cut1"] as ComboNode).step, 0.3, 0.001)
	assert_almost_eq((by[&"cut2"] as ComboNode).step, 0.3, 0.001)
	assert_almost_eq((by[&"cut3"] as ComboNode).step, 0.8, 0.001)
	assert_gt((by[&"cut3"] as ComboNode).step, (by[&"cut2"] as ComboNode).step, "the finisher's step is the longest")


func test_the_combo_slows_as_it_goes() -> void:
	# E1c (Daniel: "um mais rápido, o segundo um pouco mais lento e o último mais lento"): windup, recovery and the
	# whole blow grow from cut1 to the spin
	var tree: ComboTree = load("res://data/combos/paladin.tres")
	var cut1: ComboNode = ComboTree.find(tree.neutral, L)
	var cut2: ComboNode = cut1.following()[0]
	var cut3: ComboNode = cut2.following()[0]
	assert_lt(cut1.lead(), cut2.lead())
	assert_lt(cut2.lead(), cut3.lead())
	assert_lt(cut1.recovery, cut2.recovery)
	assert_lt(cut2.recovery, cut3.recovery)
	assert_lt(cut1.lead() + cut1.move_hold, cut2.lead() + cut2.move_hold)
	assert_lt(cut2.lead() + cut2.move_hold, cut3.lead() + cut3.move_hold)
	assert_lt(cut1.move_hold, cut2.move_hold)
	assert_lt(cut2.move_hold, cut3.move_hold)


func test_the_follow_through_fills_the_leg_hold() -> void:
	var n := ComboNode.new()
	n.recovery = 0.1
	n.move_hold = 0.2
	assert_almost_eq(n.follow_speed(0.2), 1.0, 0.001, "the clip's own speed when its tail fits")
	assert_almost_eq(n.follow_speed(0.15), 0.75, 0.001, "slowed to fill the recovery")
	assert_almost_eq(n.follow_speed(0.02), ComboNode.FOLLOW_MIN, 0.001, "never slower than FOLLOW_MIN, then held")
	assert_almost_eq(n.follow_speed(1.3), ComboNode.FOLLOW_MAX, 0.001, "a long tail at its own speed, never sped up")


func test_blade_lands_with_the_blow() -> void:
	# the clip reaches its swing peak (measured by tools/bake_hero.gd) exactly when the windup ends, never before
	var peaks: Dictionary = (load("res://tools/make_data.gd") as GDScript).get_script_constant_map()["PEAK"]
	var tree: ComboTree = load("res://data/combos/paladin.tres")
	for node: ComboNode in tree.all_nodes():
		if not peaks.has(node.anim):
			continue
		var at_windup_end := node.anim_from + node.windup * node.anim_speed
		assert_almost_eq(at_windup_end, float(peaks[node.anim]), 0.02, String(node.id))
