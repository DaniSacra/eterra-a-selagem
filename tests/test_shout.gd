extends GutTest
## 2026-11-21, the Warrior's buttons (docs/design/heroes/guerreiro.md): Q is the Brado de Guerra (it was E, then the
## circle's), E the Investida, Shift the ultimate, F interacts, the circle has no key (it left the kit), R is only the
## menu's reroll. The Brado is a move of data (ComboNode.In.SHOUT, Effect.SHOUT): 15 damage in 4 m, everyone pushed 1.5 m
## and stunned by none, a 5 s buff (blows 20% faster, 15% less damage taken, one charge of Ímpeto), 12 s to recharge.
## The HUD shows the diamonds: left button, right button, Q, E, Shift, then Space.

const F := 1.0 / 60.0

var game: Game
var pad: Controls.VirtualPad


func after_each() -> void:
	Controls.virtual = null
	Controls.flush()
	Save.set_option("bindings", {})
	Controls.apply_bindings()


# ---------- the buttons ----------

func test_the_defaults() -> void:
	assert_false(Controls.DEFAULT_KEYS.has(&"cast"), "the circle has no key")
	assert_false(Controls.REMAPPABLE.has(&"cast"))
	assert_eq(Controls.DEFAULT_KEYS[&"shout"], [KEY_Q])
	assert_eq(Controls.DEFAULT_KEYS[&"rush"], [KEY_E])
	assert_eq(Controls.DEFAULT_KEYS[&"ultimate"], [KEY_SHIFT])
	assert_eq(Controls.DEFAULT_KEYS[&"interact"], [KEY_F])
	assert_eq(Controls.MENU_KEYS[&"menu_reroll"][1], KEY_R, "R is only the reroll now")
	for action: StringName in [&"shout", &"rush", &"ultimate", &"interact", &"light_attack", &"heavy_attack", &"dodge"]:
		assert_true(Controls.REMAPPABLE.has(action), "%s is remappable" % action)
	assert_true(Controls.PAD_REMAPPABLE.has(&"shout"))
	# nothing shares a key by default (the mouse's buttons aside)
	var seen := {}
	for action: StringName in Controls.DEFAULT_KEYS:
		for key: Key in Controls.DEFAULT_KEYS[action]:
			assert_false(seen.has(key), "%s shares a key with %s" % [action, seen.get(key)])
			seen[key] = action
	var buttons := {}
	for action: StringName in Controls.DEFAULT_PAD:
		var b: int = Controls.DEFAULT_PAD[action]
		assert_false(buttons.has(b), "%s shares a button with %s" % [action, buttons.get(b)])
		buttons[b] = action
	assert_eq(Controls.DEFAULT_PAD[&"ultimate"], JOY_BUTTON_LEFT_SHOULDER, "the gamepad keeps what it had")
	assert_eq(Controls.DEFAULT_PAD[&"interact"], JOY_BUTTON_A)


func test_the_input_map_has_the_new_keys() -> void:
	Controls.apply_bindings()
	assert_eq(Controls.label(&"shout"), "Q")
	assert_eq(Controls.label(&"rush"), "E")
	assert_eq(Controls.label(&"ultimate"), "Shift")
	assert_eq(Controls.label(&"interact"), "F")
	assert_eq(InputMap.action_get_events(&"cast").filter(func(ev: InputEvent) -> bool: return ev is InputEventKey).size(), 0, "no key on the circle")


func test_an_old_save_with_nothing_remapped_reads_the_new_defaults() -> void:
	Save.set_option("bindings", {})
	Controls.apply_bindings()
	assert_eq(Controls.label(&"ultimate"), "Shift")
	assert_eq(Controls.label(&"interact"), "F")


func test_an_old_save_with_remapped_keys_keeps_them_and_no_key_is_shared() -> void:
	# the old game: the ultimate on R (rebound to T), E on a blow, F on the dodge, Shift on the map (gone with DM-1: it holds no key)
	var old := {
		"ultimate": {"type": "key", "code": float(KEY_T)},
		"light_attack": {"type": "key", "code": float(KEY_E)},
		"dodge": {"type": "key", "code": float(KEY_F)},
		"map": {"type": "key", "code": float(KEY_SHIFT)},
		"pad:cast": {"type": "pad", "code": JOY_BUTTON_X},
	}
	Save.set_option("bindings", old)
	Controls.apply_bindings()
	assert_eq(Controls.label(&"ultimate"), "T", "what the player chose stays")
	assert_eq(Controls.label(&"light_attack"), "E")
	assert_eq(Controls.label(&"dodge"), "F")
	# the new defaults that would clash go to a spare key, never to two actions at once
	assert_eq(Controls.label(&"rush"), "Z", "E is taken: the Investida takes a spare")
	assert_eq(Controls.label(&"interact"), "G", "F is taken: interact takes a spare")
	var keys := {}
	for action in Controls.REMAPPABLE:
		for ev in InputMap.action_get_events(action):
			if ev is InputEventKey:
				var k := int((ev as InputEventKey).physical_keycode)
				assert_false(keys.has(k), "key %d shared by %s and %s" % [k, keys.get(k), action])
				keys[k] = action
	assert_eq(Controls.pad_button_for(&"cast", old), JOY_BUTTON_X, "a gamepad binding is read as before")


func test_the_ultimate_default_goes_to_a_spare_when_shift_was_taken() -> void:
	assert_eq(Controls.keys_for(&"ultimate", {}), [KEY_SHIFT])
	assert_eq(Controls.keys_for(&"ultimate", {"dodge": {"type": "key", "code": KEY_SHIFT}}), [KEY_X])
	assert_eq(Controls.keys_for(&"rush", {"dodge": {"type": "key", "code": KEY_E}}), [KEY_Z])
	assert_eq(Controls.keys_for(&"shout", {}), [KEY_Q])


func test_a_stale_binding_of_an_action_that_is_gone_breaks_nothing() -> void:
	Save.set_option("bindings", {"gone_action": {"type": "key", "code": KEY_E}, "shout": {"type": "mouse", "code": MOUSE_BUTTON_MIDDLE}})
	Controls.apply_bindings()
	assert_eq(Controls.label(&"ultimate"), "Shift")
	assert_eq(UiKit.action_mouse_button(&"shout"), MOUSE_BUTTON_MIDDLE)


func test_rebinding_the_brado_swaps_with_the_key_it_takes() -> void:
	var shift := InputEventKey.new()
	shift.physical_keycode = KEY_SHIFT
	assert_true(Controls.rebind(&"shout", shift))
	assert_eq(Controls.label(&"shout"), "Shift")
	assert_eq(Controls.label(&"ultimate"), "Q", "the ultimate takes the Brado's old key")


# ---------- the move (data) ----------

func _brado(tree: ComboTree) -> ComboNode:
	return ComboTree.find(tree.neutral, ComboNode.In.SHOUT)


func test_the_brado_is_a_move_of_data_in_both_trees() -> void:
	for path in [HeroDef.warrior().combos, "res://data/combos/paladin_fifth.tres"]:
		var n := _brado(load(path))
		assert_not_null(n, path)
		assert_eq(n.id, &"shout")
		assert_eq(n.shape, ComboNode.Shape.CIRCLE)
		assert_eq(n.effect, ComboNode.Effect.SHOUT)
		assert_eq(n.damage, 35.0)
		assert_eq(n.reach, 4.0)
		assert_eq(n.knockback, 10.5, "1.5 m at the horde's decay")
		assert_eq(n.effect_time, 5.0, "a 5 s buff")
		assert_eq(n.buff_speed, 0.15)
		assert_eq(n.buff_guard, 0.15)
		assert_eq(n.effect_power, 1.0, "one charge a cry")
		assert_eq(n.cooldown, 12.0)
		assert_true(n.has_tag(&"cast"), "the Brado slot's Blessings count on it")
		assert_eq(n.windup, 0.25)
		assert_eq(n.recovery, 0.25)
		assert_eq(n.lunge, 0.0, "planted")
		assert_eq(n.move_scale, 0.0)
		assert_eq(T.t(n.title), "Brado de Guerra")
	assert_false(T.t(&"howto_shout_desc").contains("—"), "no dash")
	assert_false(T.t(&"title_controls").contains("—"))


# ---------- the cry in a fight ----------

func _run(ids: Array[StringName] = []) -> void:
	game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	game.rooms.start_at(RunMap.Kind.FOUNTAIN)
	game.horde.clear_crowd()
	game.player.pos = Vector2.ZERO
	game.equip_talents(ids)
	pad = Controls.VirtualPad.new()
	Controls.virtual = pad
	var p := game.player
	p.state = Player.State.MOVE
	p.invuln = 0.0
	p.runner.reset()


func _enemy(id: StringName, at: Vector2) -> Enemy:
	var e := game.horde.spawn(game.horde.def(id), game.arena.resolve(at, 0.6), false)
	e.cooldown = 99.0
	return e


func _cry() -> void:
	game.combat.strike(_brado(game.player.tree), game.player.pos, Vector2.RIGHT)


func test_it_hurts_and_pushes_and_stuns_no_one() -> void:
	_run()
	var a := _enemy(&"skeleton", Vector2(1.5, 0))
	var b := _enemy(&"skeleton_elite", Vector2(0, 2.0))
	var far := _enemy(&"skeleton", Vector2(7.0, 0))
	var hp_a := a.hp
	var hp_far := far.hp
	_cry()
	assert_eq(a.hp, hp_a - 35.0, "35 damage")
	assert_eq(far.hp, hp_far, "nothing beyond 4 m")
	assert_eq(a.stun_t, 0.0, "no stun, not even a common one")
	assert_eq(b.stun_t, 0.0)
	assert_gt(a.push.length(), 0.0, "pushed")
	assert_almost_eq(a.push.length(), 10.5, 0.01, "1.5 m of push at the horde's decay of 7")


func test_it_gives_the_buff() -> void:
	_run()
	_enemy(&"skeleton", Vector2(1.5, 0))
	var s := game.hero_gifts.state
	assert_false(s.rallied())
	_cry()
	assert_true(s.rallied())
	assert_eq(s.rally_left, 5.0)
	assert_almost_eq(s.attack_speed(), 1.0 + 0.15, 0.001, "15% faster blows (the Fúria is gone)")
	assert_eq(s.guard(), 0.15)


func test_it_works_on_an_empty_floor_too() -> void:
	_run()
	_cry()
	assert_true(game.hero_gifts.state.rallied(), "the buff comes with the cry, whoever it reaches")
	game.hero_gifts.state.step(5.1)
	assert_false(game.hero_gifts.state.rallied())
	assert_eq(game.hero_gifts.state.guard(), 0.0)
	assert_eq(game.hero_gifts.state.attack_speed(), 1.0)


func test_the_buff_comes_with_no_gift() -> void:
	_run([])
	_cry()
	assert_true(game.hero_gifts.state.rallied())
	assert_eq(game.hero_gifts.state.attack_speed(), 1.15)


func test_the_buff_takes_15_percent_off_a_blow_taken() -> void:
	_run([])
	var p := game.player
	p.hurt_scale = 1.0
	p.max_hp = 60.0  # (the new Warrior has 18: the 20 would fell him)
	p.hp = p.max_hp
	p.hurt(20.0, Vector2(3, 0))
	var plain := p.max_hp - p.hp
	p.hp = p.max_hp
	p.invuln = 0.0
	p.state = Player.State.MOVE
	game.hero_gifts.state.rally(5.0, 0.2, 0.15)
	p.hurt(20.0, Vector2(3, 0))
	assert_eq(plain, 20.0)
	assert_eq(p.max_hp - p.hp, 17.0, "15% off 20")


# ---------- the button, the recharge ----------

func _frame(p: Player, taps: Array = []) -> void:
	for a: StringName in taps:
		pad.press(a)
	p.step(F, Vector2.ZERO, Vector2.RIGHT)
	game.combat.step(F)
	pad.end_frame()
	for a: StringName in pad.held.keys():
		pad.release(a)
	pad.released.clear()


func test_the_press_plays_it_planted_and_it_recharges_twelve_seconds() -> void:
	_run()
	var p := game.player
	var played: Array[StringName] = []
	p.runner.move_started.connect(func(n: ComboNode) -> void: played.append(n.id))
	assert_eq(p.shout_wait(), 0.0, "ready")
	var at := p.pos
	_frame(p, [&"shout"])
	assert_eq(played, [&"shout"] as Array[StringName])
	for i in 60:
		_frame(p)
		assert_eq(p.pos, at, "planted")
	assert_gt(p.shout_wait(), 0.9, "just struck: recharging")
	played.clear()
	_frame(p, [&"shout"])
	for i in 30:
		_frame(p)
	assert_eq(played, [] as Array[StringName], "a press while it recharges does nothing")
	for i in 720:
		p.runner.step(F)
	assert_eq(p.shout_wait(), 0.0, "ready again after 12 s")


func test_the_dodge_cuts_it_in_its_windup() -> void:
	_run()
	var p := game.player
	var e := _enemy(&"skeleton", Vector2(1.5, 0))
	var hp := e.hp
	_frame(p, [&"shout"])
	_frame(p)
	_frame(p, [&"dodge"])
	for i in 40:
		_frame(p)
	assert_eq(e.hp, hp, "a cry cut in its windup never lands")


func test_the_ultimate_button_is_the_action_ultimate() -> void:
	# the player reads the action, never the key: Shift (or what is bound) is what Controls turns into it
	assert_eq(InputMap.action_get_events(&"ultimate").filter(func(ev: InputEvent) -> bool: return ev is InputEventKey)[0].physical_keycode, KEY_SHIFT)


# ---------- the HUD ----------

func test_the_hud_row_has_the_five_diamonds_then_the_dodge() -> void:
	_run()
	var hud: Hud = game.hud
	var row: HBoxContainer = hud._action_row
	var order: Array[StringName] = []
	for c in row.get_children():
		if c is ActionSlot:
			order.append((c as ActionSlot).action)
	assert_eq(order, [&"light_attack", &"heavy_attack", &"shout", &"rush", &"ultimate", &"dodge"] as Array[StringName])
	for s: ActionSlot in hud._slots:
		if s.action == &"shout":
			assert_true(s.visible)
			assert_eq(s.glyph, BoonIcon.SHOUT_GLYPH)


func test_the_hud_shows_the_brado_recharging() -> void:
	_run()
	var hud: Hud = game.hud
	var slot: ActionSlot
	for s: ActionSlot in hud._slots:
		if s.action == &"shout":
			slot = s
	hud._update_slots(game.player)
	assert_eq(slot.wait, 0.0)
	_cry()
	game.player.runner._cooldowns[&"shout"] = 7.0
	hud._update_slots(game.player)
	assert_almost_eq(slot.wait, 7.0 / 12.0, 0.011, "7 of the 12 s to go")
	assert_true(slot.busy())


func test_how_to_lists_the_brado_and_the_new_keys() -> void:
	var ids: Array[String] = []
	for row in HowToScreen.ROWS:
		ids.append(row.id)
	assert_true(ids.has("shout"))
	assert_true(ids.has("rush"))
	assert_false(ids.has("cast"))
	assert_eq(HowToScreen.keys_label([&"shout"]), "Q")
	assert_eq(HowToScreen.keys_label([&"rush"]), "E")
	assert_eq(HowToScreen.keys_label([&"ultimate"]), "Shift")
	assert_eq(HowToScreen.keys_label([&"interact"]), "F")
	assert_ne(HowToScreen.pad_label([&"shout"]), HowToScreen.pad_label([&"rush"]))
	assert_ne(T.t(&"howto_shout"), "howto_shout")
	assert_ne(T.t(&"action_shout"), "action_shout")
	assert_ne(T.t(&"howto_rush"), "howto_rush")
	assert_ne(T.t(&"action_rush"), "action_rush")

