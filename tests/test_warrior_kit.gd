extends GutTest
## 2026-11-21, the Warrior's kit: Space = only the dodge (no blow out of it), the circle of light left the kit. GP-1 (2026-11-26) took
## the burst, the Investida and the Brado off the buttons: the blows of the two buttons are tested in test_warrior_v1.

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
