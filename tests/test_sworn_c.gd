extends GutTest
## SW-C (Plano SWORN, fase 1, 2026-11-25): cancel windows in data (C1), the finisher worth double and the only push (C2),
## the pause of a blow by what it reached (C3), the dodge measured against SWORN's (C6).

const L := ComboNode.In.LIGHT
const H := ComboNode.In.HEAVY
const SH := ComboNode.In.SHOUT
const RU := ComboNode.In.RUSH

var tree: ComboTree
var runner: ComboRunner
var started: Array[StringName]
var hits: Array[StringName]


func before_each() -> void:
	tree = load("res://data/combos/paladin.tres")
	runner = ComboRunner.new(tree)
	started = []
	hits = []
	runner.move_started.connect(func(n: ComboNode) -> void: started.append(n.id))
	runner.move_hit.connect(func(n: ComboNode) -> void: hits.append(n.id))


## (the tree is a cached resource: the tests that open a window close it again)
func after_each() -> void:
	var cut1 := ComboTree.find(tree.neutral, L)
	cut1.cancel_special_from = 0.0
	cut1.cancel_light_from = -1.0


func _run(seconds: float) -> void:
	var t := 0.0
	while t < seconds:
		runner.step(1.0 / 120.0)
		t += 1.0 / 120.0


## Plays the lights up to the blow (1, 2 or 3), left in its windup.
func _to_blow(n: int) -> void:
	for i in n:
		runner.press(L)
		runner.step(0.0)
		if i < n - 1:
			_run(runner.node.duration() + 0.01)


# ---------- C1 ----------

func test_every_blow_of_the_warrior_may_be_cut_by_the_dodge_from_frame_zero() -> void:
	for node in tree.all_nodes():
		assert_eq(node.cancel_dodge_from, 0.0, String(node.id))
	for blow in [1, 2, 3]:
		setup_each()
		_to_blow(blow)
		assert_eq(runner.phase, ComboRunner.Phase.WINDUP)
		assert_true(runner.can_cancel(), "blow %d: its windup is cut, spin included" % blow)
		_run(runner.node.lead() + 0.01)
		assert_eq(runner.phase, ComboRunner.Phase.RECOVERY)
		assert_true(runner.can_cancel(), "blow %d: its recovery is cut" % blow)


func setup_each() -> void:
	before_each()


func test_a_dodge_in_the_spin_windup_drops_it_and_it_never_lands() -> void:
	_to_blow(3)
	assert_eq(runner.node.id, &"cut3")
	runner.on_dodge()
	_run(0.6)
	assert_false(hits.has(&"cut3"))


func test_the_other_moves_are_cut_by_the_dodge_too() -> void:
	for input in [H]:  # (GP-1: the Brado and the Investida left the tree)
		setup_each()
		runner.press(input)
		runner.step(0.0)
		assert_true(runner.is_attacking())
		assert_true(runner.can_cancel())


func test_the_special_cuts_a_windup_and_the_blow_never_lands() -> void:
	runner.press(L)
	runner.step(0.0)
	runner.press(H)
	runner.step(1.0 / 120.0)
	assert_eq(started, [&"cut1", &"sweep"] as Array[StringName])
	_run(0.5)
	assert_false(hits.has(&"cut1"), "the cut windup never lands")
	assert_true(hits.has(&"sweep"))


func test_the_corte_circular_cuts_a_recovery_early() -> void:
	_to_blow(2)
	_run(runner.node.lead() + 0.01)
	assert_eq(runner.phase, ComboRunner.Phase.RECOVERY, "blow 2 landed")
	runner.press(H)
	runner.step(1.0 / 120.0)
	assert_eq(started.size(), 3)
	assert_eq(started[2], &"sweep")
	assert_eq(runner.phase, ComboRunner.Phase.WINDUP)


func test_a_special_on_cooldown_does_not_cut_the_blow() -> void:
	# (GP-1: nothing of the Warrior recharges; the Corte Circular is given 5 s here to test the rule)
	tree = tree.duplicate(true)
	ComboTree.find(tree.neutral, H).cooldown = 5.0
	runner = ComboRunner.new(tree)
	runner.press(H)
	runner.step(0.0)
	_run(runner.node.duration() + 0.05)
	runner.press(L)
	runner.step(0.0)
	assert_eq(runner.node.id, &"cut1")
	runner.press(H)
	runner.step(0.01)
	assert_eq(runner.node.id, &"cut1", "the Corte recharges: the blow goes on")
	assert_eq(runner.phase, ComboRunner.Phase.WINDUP)


func test_a_special_waits_for_its_window_when_the_blow_sets_one() -> void:
	var cut1 := ComboTree.find(tree.neutral, L)
	cut1.cancel_special_from = 0.1
	runner.press(L)
	runner.step(0.0)
	runner.press(H)
	runner.step(0.02)
	assert_eq(runner.node.id, &"cut1", "before its window")
	_run(0.1)
	assert_true(started.has(&"sweep"), "from its window on the special cuts it")
	cut1.cancel_special_from = 0.0


func test_the_next_light_comes_from_its_window_in_data() -> void:
	var cut1 := ComboTree.find(tree.neutral, L)
	assert_eq(cut1.cancel_light_from, -1.0, "as today: when the recovery ends")
	cut1.cancel_light_from = cut1.lead() + 0.02
	runner.press(L)
	runner.step(0.0)
	_run(cut1.lead() + 0.005)
	assert_eq(runner.phase, ComboRunner.Phase.RECOVERY)
	runner.press(L)
	runner.step(1.0 / 120.0)
	assert_eq(runner.node.id, &"cut1", "too early")
	_run(0.03)
	assert_eq(started.back(), &"cut2", "the window opened before the recovery ended")
	assert_lt(cut1.cancel_light_from, cut1.duration())
	cut1.cancel_light_from = -1.0


func test_the_chain_cadence_is_kept_1_below_2_below_3() -> void:
	var cut1 := ComboTree.find(tree.neutral, L)
	var cut2 := cut1.following()[0]
	var cut3 := cut2.following()[0]
	assert_lt(cut1.duration(), cut2.duration())
	assert_lt(cut2.duration(), cut3.duration())
	for n: ComboNode in [cut1, cut2, cut3]:
		assert_eq(n.lunge, 0.0, "planted")


# ---------- C2 ----------

func test_the_third_blow_is_worth_double_and_the_only_one_that_pushes() -> void:
	var cut1 := ComboTree.find(tree.neutral, L)
	var cut2 := cut1.following()[0]
	var cut3 := cut2.following()[0]
	assert_eq([cut1.damage, cut2.damage, cut3.damage], [20.0, 20.0, 40.0])  # SWORN sword: 20, 20, 40
	assert_eq(cut3.damage, cut1.damage * 2.0)
	# (the horde's decay is 7: the push in meters is about a seventh of the speed)
	assert_lt(cut1.knockback / Horde.KNOCKBACK_DECAY, 0.15, "blow 1 pushes next to nothing")
	assert_lt(cut2.knockback / Horde.KNOCKBACK_DECAY, 0.15, "blow 2 pushes next to nothing")
	assert_gt(cut3.knockback / Horde.KNOCKBACK_DECAY, 2.0, "the spin throws")


# ---------- C3 ----------

func test_the_pause_of_a_blow_depends_on_what_it_reached() -> void:
	var cut1 := ComboTree.find(tree.neutral, L)
	var cut3 := cut1.following()[0].following()[0]
	assert_eq(Combat.pause_ms(cut1, 1), Combat.PAUSE_ONE_MS)
	assert_eq(Combat.pause_ms(cut3, 1), Combat.PAUSE_ONE_FINISHER_MS)
	assert_eq(Combat.pause_ms(cut1, 2), Combat.PAUSE_TWO_MS)
	assert_eq(Combat.pause_ms(cut1, 3), Combat.PAUSE_CROWD_MS)
	assert_eq(Combat.pause_ms(cut3, 7), Combat.PAUSE_CROWD_MS)
	assert_gt(Combat.PAUSE_ONE_FINISHER_MS, Combat.PAUSE_ONE_MS)
	assert_gt(Combat.PAUSE_ONE_MS, Combat.PAUSE_TWO_MS)
	assert_gt(Combat.PAUSE_TWO_MS, Combat.PAUSE_CROWD_MS)
	assert_eq(Combat.pause_ms(ComboTree.find(tree.neutral, H), 1), 0.0, "the Corte Circular keeps its own")
	assert_eq(Combat.pause_ms(ComboTree.find(tree.neutral, ComboNode.In.CHARGE_LIGHT), 1), 0.0, "the Esmagador keeps its own")


# ---------- C6 ----------

func test_the_dodge_matches_sworns_or_beats_it() -> void:
	var f := load("res://data/feel.tres") as Feel
	var hero := HeroDef.warrior()
	var distance := f.dodge_speed * f.dodge_time * 0.75  # (the roll slows to half by its end)
	assert_almost_eq(f.dodge_time, 0.2, 0.001, "SWORN: 0.2 s")
	assert_gte(distance, 2.5, "SWORN: 2.5 m")
	assert_gte(f.dodge_iframes, f.dodge_time, "safe the whole roll, as in SWORN")
	assert_lte(hero.dodge_recharge, 0.8, "SWORN: 0.8 s to come back")
	assert_gte(hero.dodge_charges, 1)


func test_a_move_never_cuts_itself() -> void:
	runner.press(H)
	runner.step(0.0)
	runner.press(H)
	runner.step(0.02)
	assert_eq(started, [&"sweep"] as Array[StringName], "a second press in the windup does not start it again")
