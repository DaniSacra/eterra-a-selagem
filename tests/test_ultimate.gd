extends GutTest
## E2-08 and E2-10 (D-54; warrior_spec.md 3.2, ultimate_u2_proposals.md section 1 and proposal A): the two ultimates.
## The charge fills with the Magia spent on Omegas; the action "ultimate" lets it go in a protected gesture of 0.3 s
## that cuts the blow under way as the dodge does and keeps the presses made in it; the cleave hits the 12 x 4 m band
## (300 on its middle strip, 200 on the rest, twice on armor, commons stunned 1 s); the Voragem pulls in a spiral
## without crossing stone, ticks and implodes. Its hits never feed the combo nor give Magia back (no passive). Nothing
## comes out of a menu nor through the victory. On the real game scene, stepped by hand.

const DT := 1.0 / 60.0

var game: Game
var pad := Controls.VirtualPad.new()
var hits := 0


func after_each() -> void:
	Audio.listen(false)
	Controls.virtual = null
	Controls.clear_presses()
	Engine.time_scale = 1.0


## A quiet room (the fountain), nobody else, the paladin at the origin facing east with this ultimate, full or not.
func _start(id: StringName, full := true) -> void:
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
	game.ults.equip(game.hero.ultimate(id))
	if full:
		game.ults.charge.fill()
	hits = 0
	game.player.runner.move_hit.connect(func(_n: ComboNode) -> void: hits += 1)
	_step()


func _step(n := 1) -> void:
	for i in n:
		game._step(DT)
		pad.end_frame()
		for a: StringName in pad.held.keys():
			pad.release(a)
		pad.released.clear()


func _press(action: StringName) -> void:
	pad.press(action)
	_step()


## A dummy of this kind at a point, with plenty of life and no attack of its own.
func _dummy(at: Vector2, id := &"skeleton", hp := 5000.0) -> Enemy:
	var e := game.horde.spawn(game.horde.def(id), at, false)
	e.hp = hp
	e.max_hp = hp
	e.cooldown = 999.0
	return e


func _gesture_steps() -> int:
	return ceili(game.player.ult.gesture / DT) + 1


# ---------- the charge ----------

func test_the_charge_fills_with_magia_spent_and_empties_when_used() -> void:
	var c := UltCharge.new(60.0)
	assert_false(c.ready())
	c.feed(0.0)
	c.feed(20.0)
	c.feed(40.0)
	assert_almost_eq(c.ratio(), 40.0 / 60.0, 0.001, "what was spent since the first look")
	assert_false(c.use(), "not full: nothing")
	c.feed(60.0)
	assert_true(c.ready())
	c.feed(100.0)
	assert_eq(c.value, 60.0, "never past full")
	assert_true(c.use())
	assert_eq(c.value, 0.0)
	c.feed(110.0, 0.25)
	assert_almost_eq(c.value, 12.5, 0.001, "ult_charge_pct: 25% faster")
	c.feed(5.0)
	assert_almost_eq(c.value, 12.5, 0.001, "a total that went back starts over (a new Magick)")


func test_omegas_charge_it_in_play() -> void:
	await _start(&"cleave", false)
	assert_false(game.player.ult_ready)
	for i in 3:
		game.player.magick.gain(30.0)
		game.player.magick.spend(30.0)
		_step()
	assert_true(game.player.ult_ready, "three spends of 30 fill the cleave (90, since 2026-11-21)")
	game.ults.equip(game.hero.ultimate(&"vortex"))
	for i in 3:
		game.player.magick.gain(30.0)
		game.player.magick.spend(30.0)
		_step()
	assert_false(game.player.ult_ready, "the Voragem needs 105")
	game.player.magick.gain(15.0)
	game.player.magick.spend(15.0)
	_step()
	assert_true(game.player.ult_ready)


## Lote E / combat review 2026-11-24b N3: the "ready" bell plays once for each time the charge fills (it fills at 75), not
## every frame it stays full, and again only after the charge was spent and filled anew.
func test_ult_ready_sounds_once_per_fill() -> void:
	var frames := [0]
	Audio.listen(true, func() -> int: return frames[0] * 1000 / 60)
	await _start(&"cleave", false)
	var rings := func() -> int:
		return Audio.heard.filter(func(h: Array) -> bool: return h[0] == &"ult_ready").size()
	for i in 60:
		frames[0] += 1
		_step()
	assert_eq(rings.call(), 0, "not full, no bell")
	game.ults.charge.fill()
	for i in 240:
		frames[0] += 1
		_step()
	assert_true(game.player.ult_ready)
	assert_eq(rings.call(), 1, "full for 4 s: one bell")
	assert_true(game.ults.charge.use())
	for i in 240:
		frames[0] += 1
		_step()
	assert_false(game.player.ult_ready)
	game.ults.charge.fill()
	for i in 240:
		frames[0] += 1
		_step()
	assert_eq(rings.call(), 2, "filled anew: a second bell, once")


func test_a_press_without_charge_does_nothing() -> void:
	await _start(&"cleave", false)
	_press(&"ultimate")
	assert_eq(game.player.state, Player.State.MOVE)
	assert_eq(game.ults.uses, 0)


# ---------- the gesture ----------

func test_it_starts_on_the_press_frame_protected_and_spends_the_charge() -> void:
	await _start(&"cleave")
	_press(&"ultimate")
	assert_eq(game.player.state, Player.State.ULT, "on the frame of the press")
	assert_true(game.player.invulnerable())
	assert_eq(game.ults.charge.value, 0.0, "spent as it begins")
	var hp := game.player.hp
	game.player.hurt(10.0, Vector2(3, 0))
	assert_eq(game.player.hp, hp, "nothing lands in the gesture")
	var p := game.player.pos
	pad.move = Vector2.UP
	_step(5)
	assert_eq(game.player.pos, p, "planted")
	pad.move = Vector2.ZERO
	_step(_gesture_steps())
	assert_eq(game.player.state, Player.State.MOVE, "free when the gesture ends")
	assert_false(game.player.invulnerable(), "no safety after it")


func test_it_cuts_a_blow_in_its_windup_and_keeps_the_presses_made_in_it() -> void:
	await _start(&"cleave")
	_press(&"light_attack")
	assert_true(game.player.runner.is_attacking(), "a blow under way")
	_step()
	_press(&"ultimate")
	assert_eq(game.player.state, Player.State.ULT)
	assert_false(game.player.runner.is_attacking(), "the blow is cut")
	_step(3)
	_press(&"light_attack")
	assert_false(game.player.runner.is_attacking(), "a press in the gesture waits")
	for i in _gesture_steps():
		if game.player.runner.is_attacking():
			break
		assert_eq(hits, 0, "the cut blow never lands")
		_step()
	assert_eq(hits, 0, "the cut blow never lands")
	assert_true(game.player.runner.is_attacking(), "the attack pressed in the gesture comes out at its end")


func test_a_press_in_the_dodge_waits_for_its_end() -> void:
	await _start(&"cleave")
	_press(&"dodge")
	assert_eq(game.player.state, Player.State.DODGE)
	_press(&"ultimate")
	assert_eq(game.player.state, Player.State.DODGE, "never in the roll (no safety on safety)")
	for i in 30:
		_step()
		if game.player.state == Player.State.ULT:
			break
	assert_eq(game.player.state, Player.State.ULT, "it comes out when the roll ends")


# ---------- U-1, the cleave ----------

func test_the_cleave_hits_its_band_and_only_it() -> void:
	await _start(&"cleave")
	var core := _dummy(Vector2(6.0, 0.0))
	var side := _dummy(Vector2(8.0, 1.6))
	var outside := _dummy(Vector2(5.0, 3.5))
	var behind := _dummy(Vector2(-3.0, 0.0))
	var far := _dummy(Vector2(13.5, 0.0))
	for e in [side, outside, behind, far]:
		e.stun_t = 10.0  # standing still where they were put (they would walk to him in the gesture)
	_press(&"ultimate")
	assert_eq(core.hp, 5000.0, "nothing lands before the gesture ends")
	_step(_gesture_steps())
	assert_eq(core.hp, 5000.0 - 180.0, "180 on the middle strip")
	assert_eq(side.hp, 5000.0 - 120.0, "120 on the rest of the band")
	assert_eq(outside.hp, 5000.0, "nothing past its width")
	assert_eq(behind.hp, 5000.0, "nothing behind him")
	assert_eq(far.hp, 5000.0, "nothing past its 12 m")
	assert_gte(core.stun_t, 0.9, "commons stunned 1 s")
	assert_eq(game.combat.combo, 0, "never a blow of the combo")
	assert_eq(game.ults.stats().damage, 300)


func test_the_band_in_numbers() -> void:
	var u := HeroDef.warrior().ultimate(&"cleave")
	var o := Vector2.ZERO
	var d := Vector2.RIGHT
	assert_eq(u.cleave_damage(o, d, Vector2(11.9, 0), 0.0), 180.0)
	assert_eq(u.cleave_damage(o, d, Vector2(4.0, 0.74), 0.0), 180.0)
	assert_eq(u.cleave_damage(o, d, Vector2(4.0, 0.9), 0.0), 120.0)
	assert_eq(u.cleave_damage(o, d, Vector2(4.0, 1.99), 0.0), 120.0)
	assert_eq(u.cleave_damage(o, d, Vector2(4.0, 2.1), 0.0), 0.0)
	assert_eq(u.cleave_damage(o, d, Vector2(4.0, 2.4), 0.5), 120.0, "a body touching the band")
	assert_eq(u.cleave_damage(o, d, Vector2(12.4, 0), 0.0), 0.0)
	assert_eq(u.cleave_damage(o, d, Vector2(-0.4, 0), 0.5), 180.0, "a body at his feet")


func test_the_cleave_takes_twice_from_armor_and_hurts_morvaths_body() -> void:
	await _start(&"cleave")
	var elite := _dummy(Vector2(5.0, 1.8), &"skeleton_elite")
	elite.armor = 1000.0
	elite.max_armor = 1000.0
	elite.stun_t = 10.0
	_press(&"ultimate")
	_step(_gesture_steps())
	assert_eq(elite.armor, 1000.0 - 240.0, "120 twice on the armor")
	assert_eq(elite.hp, 5000.0, "the armor took it")


func test_its_hits_give_no_magia_back_and_never_a_finisher() -> void:
	await _start(&"cleave")
	_dummy(Vector2(6.0, 0.0))
	game.player.magick.value = 10.0
	var tags_seen: Array = []
	game.combat.enemy_struck.connect(func(_e: Enemy, tags: Array[StringName], _d: float) -> void: tags_seen.append(tags))
	_press(&"ultimate")
	_step(_gesture_steps())
	assert_eq(game.player.magick.value, 10.0, "no Magia back (the passive pays finishers only)")
	assert_eq(tags_seen.size(), 1)
	for tags: Array in tags_seen:
		assert_true(tags.has(&"ultimate"))
		assert_false(tags.has(&"finisher") or tags.has(&"omega"))


func test_the_rift_never_passes_the_screen_cap() -> void:
	var lip := Combat.EMETH.lerp(Color.WHITE, Ultimates.RIFT_PALE)
	var peak := Ultimates.rift_peak()
	assert_lte(peak, 1.0, "under the glow threshold")
	assert_lte(ScreenTone.peak8(Color(lip.r / maxf(lip.g, 0.001) * peak, peak, lip.b / maxf(lip.g, 0.001) * peak), false), ScreenTone.SCREEN_MAX)


## The Voragem's floor (ult_vortex.gdshader): veil, ivory arms and old gold rim each under the glow and the screen cap,
## the veil never more than 0.3 opaque, drawn before the enemies' warnings, closing on its middle before it implodes.
func test_the_voragem_floor_stays_under_the_glow_and_the_screen_cap() -> void:
	var peaks := Ultimates.vortex_peaks()
	var hues := {"veil": Combat.EMETH, "arm": Ultimates.VORTEX_IVORY, "rim": Ultimates.VORTEX_GOLD}
	for k: String in hues:
		var p: float = peaks[k]
		var c: Color = hues[k]
		var top := maxf(c.r, maxf(c.g, c.b))
		assert_lte(p, 1.0, "%s under the glow threshold" % k)
		assert_lte(ScreenTone.peak8(Color(c.r / top, c.g / top, c.b / top) * p, false), ScreenTone.SCREEN_MAX, k)
	assert_lte(Ultimates.VORTEX_VEIL, 0.3, "a faint veil")
	assert_lte(maxf(Ultimates.VORTEX_MOTE.r, maxf(Ultimates.VORTEX_MOTE.g, Ultimates.VORTEX_MOTE.b)) * Fx.MOTE_GLOW, 1.1, "motes under the glow")


func test_the_voragem_floor_draws_under_warnings_and_closes_before_it_implodes() -> void:
	await _start(&"vortex")
	game.ults.call(&"_open_vortex", Vector2(4.0, 0.0))
	var v: Ultimates.Vortex = game.ults.vortex
	var m := v.node.material_override as ShaderMaterial
	assert_lt(m.render_priority, 0, "the enemies' warnings (priority 0) draw over it")
	_step(30)
	assert_eq(float(m.get_shader_parameter(&"close")), 0.0, "open while it pulls")
	assert_gt(float(m.get_shader_parameter(&"turn")), 0.0, "its arms turn")
	_step(int((game.player.ult.duration - 0.5 - Ultimates.VORTEX_CLOSE * 0.5) * 60.0))
	assert_not_null(game.ults.vortex)
	assert_gt(float(m.get_shader_parameter(&"close")), 0.2, "the rim closes on the middle")


# ---------- U-2, the Voragem ----------

func test_the_voragem_pulls_ticks_and_implodes() -> void:
	await _start(&"vortex")
	var u := game.player.ult
	var at := u.vortex_at(Vector2.ZERO, Vector2.RIGHT)
	var common := _dummy(at + Vector2(0, 5.0))
	var guard := _dummy(at + Vector2(0, -5.0), &"knight")
	guard.armor = 0.0
	var d0 := common.pos.distance_to(at)
	var g0 := guard.pos.distance_to(at)
	_press(&"ultimate")
	_step(_gesture_steps())
	assert_not_null(game.ults.vortex, "it lands")
	assert_almost_eq(game.ults.vortex.at.distance_to(at), 0.0, 0.6, "4 m ahead")
	_step(60)
	assert_lt(common.pos.distance_to(at), d0 - 1.5, "a common body is pulled in")
	assert_lt(guard.pos.distance_to(at), g0 - 0.2, "a guardian a little")
	assert_gt(guard.pos.distance_to(at), common.pos.distance_to(at), "less than a common one")
	assert_true(common.helpless(), "held inside")
	var before := common.hp
	_step(int(u.duration * 60.0))
	assert_null(game.ults.vortex, "gone after its 4 s")
	assert_lt(common.hp, before - u.implode_damage, "the ticks and the implosion")
	assert_eq(game.combat.combo, 0)


func test_the_voragem_never_pulls_through_stone() -> void:
	await _start(&"vortex")
	var pillars := game.arena.pillars
	assert_false(pillars.is_empty(), "the hall has pillars")
	var pillar: Vector3 = pillars[0]
	var c := Vector2(pillar.x, pillar.y)
	var e := _dummy(game.arena.resolve(c + Vector2(0, -pillar.z - 1.2), 0.5))
	var target := c + Vector2(0, pillar.z + 2.0)
	game.ults.call(&"_open_vortex", target)
	for i in 240:
		_step()
		assert_false(game.arena.overlaps(e.pos, e.def.radius * 0.9), "never inside the pillar (step %d)" % i)
		if not e.alive:
			break


func test_a_circle_of_light_holds_against_the_pull_and_morvath_is_only_slowed() -> void:
	await _start(&"vortex")
	var bound := _dummy(Vector2(8.0, 4.0))
	game.ground.add_zone(Ground.Kind.BIND, bound.pos, 2.0, 3.0, 0.0, Combat.CAST_TAGS)
	var p0 := bound.pos
	game.ults.call(&"_open_vortex", Vector2(4.0, 0.0))
	_step(30)
	assert_almost_eq(bound.pos.distance_to(p0), 0.0, 0.05, "the circle holds")
	var u := game.player.ult
	assert_eq(u.pull_share(true, false, false), 0.0, "Morvath is never pulled")
	assert_eq(u.pull_share(false, true, true), u.guardian_pull)
	assert_eq(u.pull_share(false, false, true), u.elite_pull)
	assert_eq(u.pull_share(false, false, false), 1.0)


func test_the_pull_in_numbers() -> void:
	var u := HeroDef.warrior().ultimate(&"vortex")
	var v := u.vortex_pull(Vector2(6.0, 0.0), Vector2.ZERO, 6.0)
	assert_almost_eq(v.dot(Vector2.LEFT), u.pull, 0.001, "pull at the edge")
	assert_almost_eq(absf(v.dot(Vector2.UP)), u.swirl, 0.001, "swirl at the edge")
	assert_eq(u.vortex_pull(Vector2(1.0, 0.0), Vector2.ZERO, 6.0), Vector2.ZERO, "nothing in the core")
	assert_eq(u.vortex_pull(Vector2(6.5, 0.0), Vector2.ZERO, 6.0), Vector2.ZERO, "nothing outside")
	assert_almost_eq(u.vortex_radius(0.55), 7.5, 0.001, "never past its cap")
	assert_eq(u.vortex_at(Vector2.ZERO, Vector2.RIGHT, Vector2(20, 0)), Vector2(8, 0), "the pointer up to 8 m")


# ---------- never through a menu nor the victory ----------

func test_nothing_comes_out_of_a_menu_or_through_the_victory() -> void:
	await _start(&"cleave")
	# the real keyboard (R): pressed while a gift is on the screen, let go after it closed
	Controls.virtual = null
	Controls.clear_presses()
	var offers: Array[Boon] = [game.boons.catalog[0]]
	game.call(&"_open_choice", offers)
	await get_tree().process_frame
	Input.action_press(&"ultimate")
	await get_tree().process_frame
	await get_tree().process_frame
	assert_eq(game.player.state, Player.State.MOVE, "a gift on the screen: the game does not step")
	game.call(&"_on_chosen", offers[0])
	for i in 4:
		await get_tree().process_frame
	Input.action_release(&"ultimate")
	for i in 4:
		await get_tree().process_frame
	assert_eq(game.mode, Game.Mode.PLAY)
	assert_eq(game.player.state, Player.State.MOVE, "the press made over the card is forgotten (Controls.clear_presses)")
	assert_true(game.ults.charge.ready(), "the charge stays")
	Controls.virtual = pad
	game.mode = Game.Mode.ENDING
	_press(&"ultimate")
	assert_ne(game.player.state, Player.State.ULT, "the victory's ending: he only looks on")
	assert_eq(game.ults.uses, 0)
