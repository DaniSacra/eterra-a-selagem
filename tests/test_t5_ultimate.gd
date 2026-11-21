extends GutTest
## T5 (P0, "a ultimate não funciona"; docs/design/t5_ultimate.md): the whole chain on the real game scene. A new save
## has none and the HUD says the Mastery it needs; at Mastery 2 a save that never chose one plays the first unlocked;
## the real R key lets it go; it charges with the damage dealt and the life lost as well as the Magia of the Omegas
## (a player who never holds an Omega gets it in a normal descent); a press that cannot let it go says why.

const DT := 1.0 / 60.0

var game: Game
var _saved: Dictionary


func before_each() -> void:
	_saved = Save.data.duplicate(true)
	Controls.virtual = null
	Controls.clear_presses()


func after_each() -> void:
	Save.data = _saved
	Controls.virtual = null
	Controls.clear_presses()
	Engine.time_scale = 1.0


## A run on the fountain (nobody around) with this Mastery XP and this ultimate in the save (as a person's run: no bot).
func _start(xp: int, chosen := "") -> void:
	var block := SaveData.hero(Save.data, "warrior")
	block.mastery_xp = xp
	block.ultimate = chosen
	block.equipped = []
	game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	game.rooms.start_at(RunMap.Kind.FOUNTAIN)
	for e in game.horde.list:
		e.alive = false
	game.horde.list.clear()
	game.horde.clear_crowd()
	await get_tree().process_frame
	await get_tree().process_frame


func _xp_for(level: int) -> int:
	return game.hero.mastery.total_to(level) if game else HeroDef.warrior().mastery.total_to(level)


func _key(code: Key, down: bool) -> void:
	var ev := InputEventKey.new()
	ev.physical_keycode = code
	ev.pressed = down
	Input.parse_input_event(ev)


func _tap_r() -> void:
	_key(KEY_R, true)
	for i in 3:
		await get_tree().process_frame
	_key(KEY_R, false)
	await get_tree().process_frame


# ---------- which ultimate a descent plays ----------

func test_the_ultimate_of_a_level() -> void:
	var hero := HeroDef.warrior()
	# B-2 (balance.md B.5): the cleave at Mastery 6, the vortex at 10
	assert_null(hero.ult_for(&"", 5), "Mastery 5: none")
	assert_eq(hero.ult_for(&"", 6).id, &"cleave", "Mastery 6, never chosen: the first unlocked")
	assert_eq(hero.ult_for(&"vortex", 7).id, &"cleave", "chosen but locked: the first unlocked")
	assert_eq(hero.ult_for(&"vortex", 10).id, &"vortex", "chosen and unlocked: that one")
	assert_eq(hero.ult_for(&"cleave", 13).id, &"cleave")
	assert_eq(hero.first_ult_level(), 6)


func test_the_hero_screen_shows_the_one_the_descent_plays() -> void:
	var hero := HeroDef.warrior()
	var data := SaveData.defaults()
	SaveData.hero(data, "warrior").mastery_xp = hero.mastery.total_to(6)
	assert_eq(HeroLoadout.new(hero, data).ultimate(), &"cleave", "never chosen: the first unlocked is the chosen one")
	SaveData.hero(data, "warrior").mastery_xp = 0
	assert_eq(HeroLoadout.new(hero, data).ultimate(), &"", "Mastery 1: none")


func test_a_new_save_has_none_and_the_hud_says_the_mastery_it_needs() -> void:
	await _start(0)
	assert_eq(game.ultimate, "")
	assert_null(game.ults.def)
	var slot: ActionSlot = game.hud._ult_slot
	assert_true(slot.visible, "the diamond is there, sealed")
	assert_true(slot.sealed)
	assert_eq(slot.caption, "Maestria 6")
	var refused := [0]
	game.player.ult_refused.connect(func() -> void: refused[0] += 1)
	await _tap_r()
	assert_eq(refused[0], 1, "the press is heard and refused")
	assert_eq(game.player.state, Player.State.MOVE)
	assert_eq(game.hud._notice.text, "A ultimate abre na Maestria 6")


func test_mastery_6_without_a_choice_plays_the_cleave_and_the_r_key_lets_it_go() -> void:
	await _start(HeroDef.warrior().mastery.total_to(6))
	assert_eq(game.ultimate, "cleave", "the first unlocked, though never chosen on the hero screen")
	assert_eq(game.ults.def.id, &"cleave")
	var slot: ActionSlot = game.hud._ult_slot
	assert_false(slot.sealed)
	game.ults.charge.fill()
	await get_tree().process_frame
	assert_true(game.player.ult_ready)
	assert_true(slot.pulse, "full: the diamond pulses")
	assert_true(slot.ready_ring(), "stage 1A: and wears the closed ring of light")
	assert_eq(slot.caption, "Pronta")
	await _tap_r()
	assert_eq(game.ults.uses, 1, "the real R key (InputMap action ultimate) lets it go")
	assert_eq(game.ults.charge.value, 0.0)
	await get_tree().process_frame
	assert_false(slot.ready_ring(), "spent: the ring goes with the charge")


func test_a_locked_choice_falls_back_to_the_unlocked_one() -> void:
	await _start(HeroDef.warrior().mastery.total_to(7), "vortex")
	assert_eq(game.ultimate, "cleave")


func test_a_refused_press_says_how_much_is_charged() -> void:
	await _start(HeroDef.warrior().mastery.total_to(6))
	game.ults.charge.value = 24.0
	await get_tree().process_frame
	assert_eq(game.hud._ult_slot.caption, "", "nothing over it while charging quietly")
	await _tap_r()
	assert_eq(game.ults.uses, 0)
	assert_eq(game.hud._ult_slot.caption, "Carga 40%")
	assert_eq(game.hud._notice.text, "A ultimate enche com Ômegas e com o dano que você causa e sofre")


func test_the_captions() -> void:
	assert_eq(Hud.ult_caption(false, false, 0.0, 6, false), "Maestria 6")
	assert_eq(Hud.ult_caption(true, false, 0.5, 2, false), "")
	assert_eq(Hud.ult_caption(true, false, 0.5, 2, true), "Carga 50%")
	assert_eq(Hud.ult_caption(true, true, 1.0, 2, true), "Pronta")


# ---------- the charge ----------

func test_damage_dealt_and_life_lost_charge_it_but_not_its_own_hits() -> void:
	await _start(HeroDef.warrior().mastery.total_to(6))
	var u := game.ults.def
	assert_gt(u.damage_charge, 0.0, "the data charges it by damage (make_data.gd ULT_DAMAGE_CHARGE)")
	assert_gt(u.hurt_charge, 0.0)
	game.horde.dealt.add(&"attack", 1200.0)
	game.ults.step(DT)
	assert_almost_eq(game.ults.charge.value, 1200.0 * u.damage_charge, 0.01, "damage dealt")
	game.horde.dealt.add(&"ultimate", 5000.0)
	game.ults.step(DT)
	assert_almost_eq(game.ults.charge.value, 1200.0 * u.damage_charge, 0.01, "the ultimate's own hits never charge it")
	var before := game.ults.charge.value
	game.player.hurt(5.0, game.player.pos + Vector2(1, 0))
	assert_almost_eq(game.ults.charge.value, before + 5.0 * u.hurt_charge, 0.01, "life lost")
	var st: Dictionary = game.ults.stats()
	assert_eq(st.charged.damage, roundi(1200.0 * u.damage_charge))
	assert_eq(st.charged.hurt, roundi(5.0 * u.hurt_charge))


func test_a_descent_without_omegas_fills_it_every_few_rooms() -> void:
	# a person's runs before T5 (the PO's run log): about 1350 of damage a fight room and some 5 of life lost, no
	# Omega at all; before, the charge never moved
	var u := HeroDef.warrior().ultimate(&"cleave")
	var c := UltCharge.new(u.charge)
	var dealt := 0.0
	var uses := 0
	for room in 10:
		dealt += 1350.0
		c.feed_from(&"damage", dealt, u.damage_charge)
		c.add(5.0 * u.hurt_charge)
		if c.use():
			uses += 1
	assert_between(uses, 3, 6, "a cleave every two or three fight rooms")
	var v := HeroDef.warrior().ultimate(&"vortex")
	assert_lt(2000.0 * v.damage_charge, v.charge, "never one per room from damage alone")
