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


func test_the_eight_starting_combos_exist() -> void:
	var names := {}
	for m in tree.named_moves():
		names[m.node.id] = ComboTree.notation(m.path, m.from_dodge, {"dodge": "Esquiva", "charge": "D segurado"})
	assert_eq(names.get(&"spin"), "E E E E")
	assert_eq(names.get(&"thrust"), "E E E D")
	assert_eq(names.get(&"launch"), "E D")
	assert_eq(names.get(&"cross"), "E E D")
	assert_eq(names.get(&"wave"), "D D E")
	assert_eq(names.get(&"burst"), "D segurado")
	assert_eq(names.get(&"dash_cut"), "Esquiva + E")
	assert_eq(names.get(&"slam"), "Esquiva + D")
	assert_eq(names.size(), 8)


func test_four_lights_end_in_the_spin() -> void:
	play_all([L, L, L, L])
	assert_eq(started, [&"cut1", &"cut2", &"cut3", &"spin"] as Array[StringName])
	assert_eq(hits.size(), 4)


func test_three_lights_and_a_heavy_thrust() -> void:
	play_all([L, L, L, H])
	assert_eq(started[3], &"thrust")


func test_light_heavy_launches() -> void:
	play_all([L, H])
	assert_eq(started, [&"cut1", &"launch"] as Array[StringName])


func test_two_lights_and_a_heavy_leave_the_mark() -> void:
	play_all([L, L, H])
	assert_eq(started[2], &"cross")
	assert_eq(runner.node.effect, ComboNode.Effect.GROUND_MARK)


func test_two_heavies_and_a_light_send_the_wave() -> void:
	play_all([H, H, L])
	assert_eq(started, [&"heavy1", &"heavy2", &"wave"] as Array[StringName])


func test_charge_input_bursts() -> void:
	assert_true(runner.charge_available(), "standing still, heavy can be charged")
	play(C)
	assert_eq(started, [&"burst"] as Array[StringName])
	assert_eq(runner.node.effect, ComboNode.Effect.STUN)


func test_charge_is_not_offered_in_the_middle_of_a_chain() -> void:
	play(L)
	assert_false(runner.charge_available())


func test_dodge_opens_the_dodge_moves() -> void:
	runner.on_dodge()
	run(0.2)
	runner.on_dodge_end()
	play(L)
	assert_eq(started, [&"dash_cut"] as Array[StringName])


func test_dodge_then_heavy_slams() -> void:
	runner.on_dodge()
	runner.on_dodge_end()
	play(H)
	assert_eq(started, [&"slam"] as Array[StringName])


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


func test_wrong_input_at_the_end_of_a_chain_starts_a_new_one() -> void:
	play_all([L, L, L, L, L])
	assert_eq(started[4], &"cut1")


func test_only_the_end_of_a_move_can_be_cancelled() -> void:
	runner.press(H)
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
	var ids := {}
	for node in tree.all_nodes():
		assert_false(ids.has(node.id), "duplicate id %s" % node.id)
		ids[node.id] = true
		assert_gt(node.damage, 0.0, String(node.id))
		assert_gt(node.windup, 0.0, String(node.id))
		assert_between(node.hit_stop_ms, 40.0, 80.0, String(node.id))
		assert_true(Art.def(&"paladin").anims.has(String(node.anim)), "missing animation %s" % node.anim)
		if node.title != &"":
			assert_ne(T.t(node.title), String(node.title), "missing name for %s" % node.id)
		var inputs := {}
		for child in node.next:
			assert_false(inputs.has(child.input), "%s has two moves on the same input" % node.id)
			inputs[child.input] = true
	assert_almost_eq(tree.buffer_time, 0.15, 0.001)


func test_a_new_combo_needs_only_data() -> void:
	var extra := ComboNode.new()
	extra.id = &"test_extra"
	extra.input = H
	extra.title = &"move_spin"
	tree = tree.duplicate(true)
	ComboTree.find(tree.neutral, H).next[0].next.append(extra)
	runner.tree = tree
	play_all([H, H, H])
	assert_eq(started[2], &"test_extra")
