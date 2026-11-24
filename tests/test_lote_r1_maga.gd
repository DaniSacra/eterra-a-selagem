extends GutTest
## Lote R1 (CF-07): the reaction burst of the Maga. (Setup copied from test_maga_kit.)
## The elemental Maga (redesign 2026-11-24, 04_PLANO C): her 12 provisional Gifts, the kit in the combo tree, the three elements
## and their reactions in play (Arcane over ElementBook), the Convergência and the clearing of every state. The pure rules are
## test_element_book and test_converge.

const DT := 1.0 / 60.0

var game: Game
var pad := Controls.VirtualPad.new()


func after_each() -> void:
	Controls.virtual = null
	Controls.clear_presses()
	Dev.drop("hero")


func _start() -> void:
	Dev.put("hero", "maga")
	game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	game.rooms.start_at(RunMap.Kind.FOUNTAIN)
	game.horde.clear_crowd()
	for e in game.horde.list.duplicate():
		e.alive = false
	game.horde.list.clear()
	Controls.virtual = pad
	pad.aim = Vector2.RIGHT
	game.player.pos = Vector2.ZERO
	game.player.facing = Vector2.RIGHT
	game.player.magick.value = 50.0
	_step()


func _step(n := 1) -> void:
	for i in n:
		game._step(DT)
		pad.end_frame()
		for a: StringName in pad.held.keys():
			pad.release(a)
		pad.released.clear()


func _dummy(at: Vector2, id := &"skeleton") -> Enemy:
	var e := game.horde.spawn(game.horde.def(id), at, false)
	e.hp = 5000.0
	e.max_hp = 5000.0
	e.cooldown = 999.0
	e.stun_t = 1000.0
	return e


func test_a_reaction_makes_one_burst_with_its_own_sound_and_color() -> void:
	_start()
	for k in [&"react_thermal", &"react_overload", &"react_crystal"]:
		assert_true(CombatSounds.all_names().has(k), "%s has a sound" % k)
		assert_true(Audio.SOUNDS.has(CombatSounds.EVENTS[k]), String(k))
	assert_lt(Arcane.REACT_TIME, 0.2501, "0.25 s at most")
	var colors := [ElementLook.REACT_THERMAL, ElementLook.REACT_OVERLOAD, ElementLook.REACT_CRYSTAL]
	assert_ne(colors[0], colors[1])
	assert_ne(colors[1], colors[2])
	assert_ne(colors[0], colors[2])
	var e := _dummy(Vector2(4, 0))
	game.arcane.apply_element(e, ElementBook.FIRE)
	game.arcane.apply_element(e, ElementBook.ICE)
	assert_eq(game.arcane.tally.reactions, 1, "one reaction, one burst")
	game.arcane.apply_element(e, ElementBook.FIRE)
	assert_eq(game.arcane.tally.reactions, 1, "no second one inside react_gap")


func test_the_convergence_puts_no_element_on_the_boss() -> void:
	_start()
	var def := HeroDef.maga().ultimates[0]
	game.ults.equip(def)
	var e := _dummy(Vector2(4, 0))
	e.def = e.def.duplicate()
	e.def.behavior = EnemyDef.Behavior.BOSS
	game.ults._open_vortex(Vector2(4.5, 0))
	_step(int(4.7 / DT))
	assert_false(game.arcane.book.has_fire(e))
	assert_eq(game.arcane.tally.reactions, 0, "his body stays readable: no state, no reaction on him")
