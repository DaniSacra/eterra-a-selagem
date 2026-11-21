extends GutTest
## 2026-11-21, the Warrior's new kit (docs/design/heroes/guerreiro.md): right button = the sword's burst (60 in 6 m, through
## the crowd, 8 Magia, 0.5 s between throws, a tap only), E = the Investida (35 along 4 m that carries the body, 5 s,
## 3 Magia for each enemy it reaches), Space = only the dodge (no blow out of it), the circle of light left the kit.

const F := 1.0 / 60.0

var game: Game
var pad: Controls.VirtualPad


func after_each() -> void:
	Controls.virtual = null
	Controls.flush()


func _run() -> void:
	game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	game.rooms.start_at(RunMap.Kind.FOUNTAIN)
	game.horde.clear_crowd()
	game.player.pos = Vector2.ZERO
	game.equip_talents([] as Array[StringName])
	pad = Controls.VirtualPad.new()
	Controls.virtual = pad
	var p := game.player
	p.state = Player.State.MOVE
	p.invuln = 0.0
	p.runner.reset()
	p.magick.value = p.magick.max_value


func _enemy(id: StringName, at: Vector2) -> Enemy:
	var e := game.horde.spawn(game.horde.def(id), game.arena.resolve(at, 0.6), false)
	e.cooldown = 99.0
	return e


func _frame(p: Player, taps: Array = [], aim: Vector2 = Vector2.RIGHT) -> void:
	for a: StringName in taps:
		pad.press(a)
	p.step(F, Vector2.ZERO, aim)
	game.combat.step(F)
	game.projectiles.step(F)
	pad.end_frame()
	for a: StringName in pad.held.keys():
		pad.release(a)
	pad.released.clear()


func _frames(p: Player, n: int) -> void:
	for i in n:
		_frame(p)


# ---------- the data ----------

func test_the_tree_of_data() -> void:
	for path in [HeroDef.warrior().combos, "res://data/combos/paladin_fourth.tres"]:
		var tree: ComboTree = load(path)
		var bolt := ComboTree.find(tree.neutral, ComboNode.In.HEAVY)
		assert_eq(bolt.effect_power, 35.0, "35 damage")
		assert_eq(bolt.effect_radius, 6.0, "6 m")
		assert_eq(bolt.magick_cost, 12.0, "12 Magia")
		assert_eq(bolt.cooldown, 0.5, "0.5 s between throws")
		assert_null(ComboTree.find(tree.neutral, ComboNode.In.CHARGE), "no held special")
		assert_not_null(ComboTree.find(tree.neutral, ComboNode.In.CHARGE_LIGHT), "the attack's Omega stays")
		var rush := ComboTree.find(tree.neutral, ComboNode.In.RUSH)
		assert_eq(rush.damage, 35.0)
		assert_eq(rush.shape, ComboNode.Shape.LINE)
		assert_eq(rush.reach, 4.0)
		assert_eq(rush.lunge, 4.0, "carries the body")
		assert_eq(rush.cooldown, 5.0)
		assert_eq(rush.magick_per_hit, 2.0)
		assert_true(rush.has_tag(&"dash"), "a finisher of the passive, and the Passo's Blessings count on it")
		assert_true(tree.dodge.is_empty(), "no blow out of the dodge")
		assert_eq(tree.dodge_window, 0.0)


func test_the_hero_has_no_circle() -> void:
	assert_false(HeroDef.warrior().circle)
	assert_false(Controls.ACTIONS.is_empty())
	var psalms := Psalms.new(Psalms.load_catalog())
	psalms.circle = false
	var held := {}
	for p in psalms.catalog:
		for group in p.requires:
			held[group[0]] = true
	var sentinela := psalms.catalog.filter(func(p: PsalmDef) -> bool: return p.effect == PsalmDef.Effect.SENTINEL)
	assert_eq(sentinela.size(), 1)
	for p in psalms.eligible(null, []):
		assert_ne(p.effect, PsalmDef.Effect.SENTINEL)


func test_the_circle_button_reads_nothing() -> void:
	_run()
	var p := game.player
	var released := [false]
	p.cast_released.connect(func(_a: Vector2, _o: bool) -> void: released[0] = true)
	for i in 40:
		_frame(p, [&"cast"])
	assert_false(released[0], "the circle left the Warrior's kit")


# ---------- the right button ----------

func test_the_tap_throws_the_burst_for_8_magia() -> void:
	_run()
	var p := game.player
	var e := _enemy(&"skeleton", Vector2(4.0, 0))
	var far := _enemy(&"skeleton", Vector2(5.2, 0.2))
	var hp := e.hp
	var played: Array[StringName] = []
	p.runner.move_started.connect(func(n: ComboNode) -> void: played.append(n.id))
	var before := p.magick.value
	_frame(p, [&"heavy_attack"])
	assert_eq(played, [&"bolt"] as Array[StringName])
	assert_eq(p.magick.value, before - 12.0, "12 Magia")
	_frames(p, 40)
	assert_lt(e.hp, hp, "the burst reached it")
	assert_lt(far.hp, far.def.hp, "and went through to the one behind")
	assert_false(p.charging, "no charge: a tap only")


func test_it_holds_on_for_nothing() -> void:
	_run()
	var p := game.player
	pad.press(&"heavy_attack")
	for i in 90:
		p.step(F, Vector2.ZERO, Vector2.RIGHT)
		game.combat.step(F)
		assert_false(p.charging, "holding it charges nothing")
	pad.release(&"heavy_attack")


func test_without_magia_nothing_is_thrown_and_it_says_so() -> void:
	_run()
	var p := game.player
	p.magick.value = 7.0
	var played: Array[StringName] = []
	p.runner.move_started.connect(func(n: ComboNode) -> void: played.append(n.id))
	var refused := [0]
	p.magick_refused.connect(func() -> void: refused[0] += 1)
	_frame(p, [&"heavy_attack"])
	_frames(p, 30)
	assert_eq(played, [] as Array[StringName], "7 is not 8")
	assert_eq(refused[0], 1)
	assert_eq(p.magick.value, 7.0)


func test_half_a_second_between_throws() -> void:
	_run()
	var p := game.player
	var played: Array[StringName] = []
	p.runner.move_started.connect(func(n: ComboNode) -> void: played.append(n.id))
	_frame(p, [&"heavy_attack"])
	_frames(p, 20)
	_frame(p, [&"heavy_attack"])
	_frames(p, 60)
	assert_eq(played.size(), 1, "a press within its 0.5 s is lost (the buffer is 0.15 s)")
	_frame(p, [&"heavy_attack"])
	_frames(p, 10)
	assert_eq(played.size(), 2, "after the 0.5 s the next throw goes out")


# ---------- E, the Investida ----------

func test_the_investida_carries_him_strikes_and_gives_magia() -> void:
	_run()
	var p := game.player
	var a := _enemy(&"skeleton", Vector2(2.5, 0))
	var b := _enemy(&"skeleton", Vector2(3.5, 0.3))
	var far := _enemy(&"skeleton", Vector2(9.0, 0))
	p.magick.value = 10.0
	var hp := a.hp
	var played: Array[StringName] = []
	p.runner.move_started.connect(func(n: ComboNode) -> void: played.append(n.id))
	_frame(p, [&"rush"])
	assert_eq(played, [&"dash_cut"] as Array[StringName])
	_frames(p, 40)
	assert_gt(p.pos.x, 0.5, "it took the body forward")
	assert_lt(a.hp, hp, "it hurt")
	assert_eq(far.hp, far.def.hp, "nothing 9 m away")
	var hit := 0
	for e in [a, b]:
		if e.hp < e.def.hp:
			hit += 1
	assert_gt(hit, 0)
	# 2 Magia each, and the passive's 2 for the finisher that lands
	assert_almost_eq(p.magick.value, 10.0 + 2.0 * hit + 2.0, 0.01)


func test_the_investida_recharges_five_seconds() -> void:
	_run()
	var p := game.player
	assert_eq(p.rush_wait(), 0.0)
	_frame(p, [&"rush"])
	_frames(p, 30)
	assert_gt(p.rush_wait(), 0.9, "just struck")
	var played: Array[StringName] = []
	p.runner.move_started.connect(func(n: ComboNode) -> void: played.append(n.id))
	_frame(p, [&"rush"])
	_frames(p, 30)
	assert_eq(played, [] as Array[StringName], "a press while it recharges does nothing")
	for i in 300:
		p.runner.step(F)
	assert_eq(p.rush_wait(), 0.0, "ready after 5 s")


# ---------- Space ----------

func test_an_attack_after_the_dodge_is_the_plain_first_cut() -> void:
	_run()
	var p := game.player
	var played: Array[StringName] = []
	p.runner.move_started.connect(func(n: ComboNode) -> void: played.append(n.id))
	_frame(p, [&"dodge"])
	_frame(p, [&"light_attack"])
	_frames(p, 40)
	assert_eq(played, [&"cut1"] as Array[StringName], "no Corte Veloz out of the dodge")


# ---------- the robot ----------

func test_the_robot_rushes_to_close_in_and_when_the_rajada_is_out_of_magia() -> void:
	_run()
	assert_true(Bot.rush_worth(game, 6.0), "an enemy a few steps off")
	assert_false(Bot.rush_worth(game, 12.0), "too far")
	assert_false(Bot.rush_worth(game, 2.0), "right in front it throws the rajada while it has Magia")
	game.player.magick.value = 3.0
	assert_true(Bot.rush_worth(game, 2.0), "and rushes for the Magia when it has none")
	game.player.runner._cooldowns[&"dash_cut"] = 3.0
	assert_false(Bot.rush_worth(game, 6.0), "recharging")
