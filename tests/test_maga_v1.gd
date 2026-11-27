extends GutTest
## GP-5, the Maga's V1 (docs/design/heroes/maga_v1_2026-11-26.md): her four blows on the two buttons (tap and hold), the Magia that comes
## back by itself, the reactions and their rules (4.1), the Convergência by phases, the charge of the Supremo, the twelve Dons and the
## save's step to 18. The pure rules (ElementBook, ConvergePlan) are tested bare; the rest in a run.

const DT := 1.0 / 60.0
const F := ElementBook.FIRE
const I := ElementBook.ICE
const V := ElementBook.VOLT

var game: Game
var pad := Controls.VirtualPad.new()
var strikes: Array[StringName] = []


func after_each() -> void:
	Controls.virtual = null
	Controls.clear_presses()
	Dev.drop("hero")
	strikes.clear()


## A run in the fountain room with nobody in it, the Maga at the middle and these Dons.
func _start(ids: Array[StringName] = []) -> void:
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
	game.equip_talents(ids)
	game.player.magick.value = 50.0
	game.ults.equip(HeroDef.maga().ultimates[0])
	game.player.struck.connect(func(node: ComboNode, _o: Vector2, _d: Vector2) -> void: strikes.append(node.id))
	_step(2)


func _step(n := 1) -> void:
	for i in n:
		game._step(DT)
		pad.end_frame()
		for a: StringName in pad.held.keys():
			pad.release(a)
		pad.released.clear()


## The button down for `frames` frames, then let go and a second of play.
func _hold(action: StringName, frames: int) -> void:
	for i in frames:
		pad.press(action)
		game._step(DT)
		pad.end_frame()
	pad.release(action)
	pad.released.clear()
	_step(60)


func _tap(action: StringName) -> void:
	pad.press(action)
	_step(2)
	_step(40)


func _dummy(at: Vector2, id := &"skeleton") -> Enemy:
	var e := game.horde.spawn(game.horde.def(id), at, false)
	e.hp = 5000.0
	e.max_hp = 5000.0
	e.cooldown = 999.0
	e.stun_t = 1000.0
	return e


func _shot(tags: Array[StringName]) -> Projectiles.Shot:
	var s := Projectiles.Shot.new()
	s.tags = tags
	s.damage = 6.0
	return s


const SHARD: Array[StringName] = [&"shout", &"cast", &"bolt", &"arcane", &"ice"]
const SPARK: Array[StringName] = [&"light", &"bolt", &"arcane", &"fire"]


func _node(input: ComboNode.In) -> ComboNode:
	return ComboTree.find((load(HeroDef.maga().combos) as ComboTree).neutral, input)


# ---------- the data ----------

func test_her_body_and_magia_numbers() -> void:
	var h := HeroDef.maga()
	assert_eq([h.max_hp, h.magick_max, h.dodge_charges, h.dodge_recharge], [30.0, 50.0, 2, 1.0])
	assert_eq(h.arcane.blink_distance, 4.5)
	assert_eq([h.magick_regen, h.charge_move_light, h.charge_move_heavy, h.charge_turn_light], [2.0, 0.5, 0.5, 90.0])
	assert_eq([h.magick_on_finisher, h.magick_on_break, h.cd_floor], [0.0, 0.0, 0.0], "no Magia from a finisher or a Quebra")
	assert_true(h.passive_tags.is_empty())
	assert_eq(h.arcane.shot_magick, 0.0, "the Centelha gives no Magia")
	assert_eq(h.ultimates.size(), 1)
	assert_eq(HeroDef.warrior().magick_regen, 0.0, "the Warrior's Magia does not come back by itself")


func test_four_blows_two_buttons_no_recharge() -> void:
	var tree := load(HeroDef.maga().combos) as ComboTree
	assert_eq(tree.neutral.size(), 4, "no Combustão, no Suspensão, nothing on Q or E")
	var N := ComboNode.In
	var want := {N.LIGHT: [&"spark", 0.0], N.CHARGE_LIGHT: [&"arc", 10.0], N.HEAVY: [&"shard", 5.0], N.CHARGE: [&"frost", 20.0]}
	for input: ComboNode.In in want:
		var n := _node(input)
		assert_eq([n.id, n.magick_cost, n.cooldown], [want[input][0], want[input][1], 0.0], "%s" % want[input][0])
	var k := HeroDef.maga().arcane
	assert_eq([k.arc_damage, k.arc_targets, k.shard_damage, k.frost_dps, k.frost_time, k.frost_radius], [12.0, 3, 6.0, 5.0, 4.0, 2.5])
	assert_eq([_node(N.CHARGE_LIGHT).charge_time, _node(N.CHARGE).charge_time], [0.6, 0.6])


func test_the_tags_put_each_blow_in_its_slot() -> void:
	var N := ComboNode.In
	assert_eq(DealtBy.source(_node(N.LIGHT).tags), &"attack")
	assert_eq(DealtBy.source(_node(N.CHARGE_LIGHT).tags), &"omega_attack")
	assert_eq(DealtBy.source(_node(N.HEAVY).tags), &"shout", "the Estilhaço is the Poder")
	assert_eq(DealtBy.source(_node(N.CHARGE).tags), &"omega_special")
	assert_eq(CelRules.slot_of(_node(N.LIGHT).tags), Boon.Slot.ATTACK)
	assert_eq(CelRules.slot_of(_node(N.CHARGE_LIGHT).tags), Boon.Slot.ATTACK)
	assert_eq(CelRules.slot_of(_node(N.HEAVY).tags), Boon.Slot.CAST)
	assert_eq(CelRules.slot_of(_node(N.CHARGE).tags), Boon.Slot.SPECIAL)
	assert_eq(CelRules.slot_of([&"cast", &"arcane", &"ice"] as Array[StringName]), Boon.Slot.NONE, "a tick of the Geada is no direct blow")
	assert_eq(CelRules.slot_of([&"dealing", &"elemental"] as Array[StringName]), Boon.Slot.NONE)
	assert_eq(Skills.trigger_of(_node(N.HEAVY)), SkillDef.Trigger.SHOUT)
	assert_eq(Skills.trigger_of(_node(N.CHARGE_LIGHT)), SkillDef.Trigger.OMEGA)


func test_the_twelve_dons_by_position() -> void:
	var B := TalentDef.Branch
	var Tr := TalentDef.Tier
	# id, branch, tier, Vagas, Maestria, Memória, needs
	var want := [
		[&"afinidade", B.ELEMENTALISMO, Tr.ENTRY, 2, 1, 0, &""], [&"catalisador", B.ELEMENTALISMO, Tr.MIDDLE, 2, 5, 1, &"afinidade"],
		[&"propagacao", B.ELEMENTALISMO, Tr.MIDDLE, 3, 10, 3, &"afinidade"], [&"trindade", B.ELEMENTALISMO, Tr.APEX, 4, 17, 4, &"catalisador"],
		[&"permanencia", B.CONJURACAO, Tr.ENTRY, 2, 2, 1, &""], [&"expansao", B.CONJURACAO, Tr.MIDDLE, 2, 7, 2, &"permanencia"],
		[&"manifestacao", B.CONJURACAO, Tr.MIDDLE, 3, 12, 3, &"permanencia"], [&"confluencia", B.CONJURACAO, Tr.APEX, 4, 18, 4, &"manifestacao"],
		[&"fluxo_arcano", B.FEITICARIA, Tr.ENTRY, 2, 3, 1, &""], [&"agilidade_arcana", B.FEITICARIA, Tr.MIDDLE, 2, 8, 2, &"fluxo_arcano"],
		[&"reciprocidade", B.FEITICARIA, Tr.MIDDLE, 3, 13, 3, &"fluxo_arcano"], [&"transcendencia", B.FEITICARIA, Tr.APEX, 4, 19, 4, &"reciprocidade"],
	]
	var cat := HeroDef.maga().talents().catalog
	assert_eq(cat.size(), 12)
	var vagas := 0
	for i in 12:
		var t: TalentDef = cat[i]
		var w: Array = want[i]
		assert_eq([t.id, t.branch, t.tier, t.cost, t.unlock_level, t.memory_cost, t.needs], w, "Dom %d" % i)
		assert_ne(T.t(t.name_key), String(t.name_key), "%s has a name" % t.id)
		assert_ne(T.t(t.desc_key), String(t.desc_key), "%s has a description" % t.id)
		assert_false(SaveData.LEGACY_DONS.maga.has(String(t.id)) or SaveData.GP5_REMOVED_DONS.maga.has(String(t.id)), "no old id reused")
		assert_eq(t.slot, Boon.Slot.NONE, "no Dom takes a button")
		vagas += t.cost
	assert_eq(vagas, 33)
	for old: String in SaveData.GP5_REMOVED_DONS.maga:
		assert_null(HeroDef.maga().talents().find(StringName(old)), "%s is gone" % old)


# ---------- the Magia that comes back ----------

func _gain_in(seconds: float) -> float:
	game.player.magick.value = 10.0
	_step(int(seconds / DT))
	return game.player.magick.value - 10.0


func test_two_a_second_standing_walking_and_rolling() -> void:
	_start()
	assert_almost_eq(_gain_in(5.0), 10.0, 0.3, "standing")
	pad.move = Vector2.RIGHT
	assert_almost_eq(_gain_in(5.0), 10.0, 0.3, "walking")
	pad.move = Vector2.ZERO
	game.player.magick.value = 10.0
	for i in 5:
		pad.press(&"dodge")
		_step(60)
	assert_almost_eq(game.player.magick.value - 10.0, 10.0, 0.4, "teleporting every second")


func test_the_regeneration_stops_at_the_bar_and_for_the_dead() -> void:
	_start()
	game.player.magick.value = 49.0
	_step(120)
	assert_eq(game.player.magick.value, 50.0)
	game.player.magick.value = 10.0
	game.player.state = Player.State.DEAD
	_step(120)
	assert_eq(game.player.magick.value, 10.0, "the dead do not regenerate")


func test_the_regeneration_is_no_charge_for_the_supremo_and_no_spending() -> void:
	_start()
	game.player.magick.value = 0.0
	_step(300)
	assert_gt(game.player.magick.value, 9.0)
	assert_eq(game.player.magick.spent, 0.0)
	assert_eq(game.ults.charge.value, 0.0, "only the Magia spent counts")


func test_fluxo_arcano_makes_it_three_a_second() -> void:
	_start([&"fluxo_arcano"])
	assert_almost_eq(_gain_in(5.0), 15.0, 0.4)


func test_the_centelha_and_a_quebra_give_no_magia() -> void:
	_start()
	var e := _dummy(Vector2(4, 0))
	game.player.magick.value = 20.0
	game.arcane.shot_landed(e, _shot(SPARK))
	game.horde.poise_broken.emit(e, &"attack")
	assert_eq(game.player.magick.value, 20.0)


# ---------- the buttons ----------

func test_q_and_e_do_nothing_in_her_hands() -> void:
	_start()
	_dummy(Vector2(4, 0))
	pad.press(&"shout")
	_step(30)
	pad.press(&"rush")
	_step(30)
	assert_true(strikes.is_empty(), "no Arco on Q, no Suspensão on E")
	assert_eq(game.player.magick.value, 50.0)


func test_a_tap_on_the_left_is_the_centelha_and_costs_nothing() -> void:
	_start()
	_dummy(Vector2(4, 0))
	_tap(&"light_attack")
	assert_eq(strikes, [&"spark"])
	assert_eq(game.player.magick.spent, 0.0)


func test_a_tap_on_the_right_is_the_estilhaco_for_five() -> void:
	_start()
	_dummy(Vector2(4, 0))
	_tap(&"heavy_attack")
	assert_eq(strikes, [&"shard"])
	assert_almost_eq(game.player.magick.spent, 5.0, 0.001)


func test_a_hold_on_the_left_is_the_arco_for_ten_and_never_the_tap_too() -> void:
	_start()
	_dummy(Vector2(4, 0))
	_hold(&"light_attack", 70)
	assert_eq(strikes, [&"arc"], "the Arco only, not the Centelha")
	assert_almost_eq(game.player.magick.spent, 10.0, 0.001)


func test_a_hold_on_the_right_is_the_geada_for_twenty() -> void:
	_start()
	_dummy(Vector2(4, 0))
	_hold(&"heavy_attack", 70)
	assert_eq(strikes, [&"frost"])
	assert_almost_eq(game.player.magick.spent, 20.0, 0.001)
	assert_not_null(game.arcane.frost)


func test_without_the_magia_a_hold_is_refused_and_nothing_strikes() -> void:
	_start()
	_dummy(Vector2(4, 0))
	game.player.magick.value = 0.0
	var refused := [0]
	game.player.magick_refused.connect(func() -> void: refused[0] += 1)
	game.player.magick.value = 0.0
	_hold(&"light_attack", 40)
	assert_gte(refused[0], 1, "the bar says why")
	assert_false(strikes.has(&"arc"))


func test_the_dodge_cuts_the_charge_and_spends_nothing() -> void:
	_start()
	_dummy(Vector2(4, 0))
	for i in 16:
		pad.press(&"light_attack")
		game._step(DT)
		pad.end_frame()
	assert_true(game.player.charging)
	pad.press(&"dodge")
	_step(60)
	assert_false(game.player.charging)
	assert_false(strikes.has(&"arc"))
	assert_eq(game.player.magick.spent, 0.0)


# ---------- the elements: the rules of 4.1 ----------

func _book() -> ElementBook:
	return ElementBook.new()


func test_a_third_state_stays_when_a_pair_reacts() -> void:
	var b := _book()
	var e := RefCounted.new()
	b.apply(e, F)
	b.apply(e, I)
	b.tick(0.6)
	b.apply(e, V)
	assert_true(b.has_volt(e), "the Eletrizado waits for the next")


func test_a_boss_or_armour_takes_quebra_and_does_not_freeze() -> void:
	var b := _book()
	var e := RefCounted.new()
	b.apply(e, I, true)
	var r := b.apply(e, V, true)[0]
	assert_eq([r.freeze, r.poise], [0.0, 25.0])
	b.react_pct = 0.3
	var o := RefCounted.new()
	b.apply(o, I, true)
	assert_almost_eq(b.apply(o, V, true)[0].poise, 32.5, 0.001, "Catalisador makes the Quebra x1.3")


func test_the_convergence_gives_these_reactions_at_these_ticks() -> void:
	var b := _book()
	var e := RefCounted.new()
	var plan := HeroDef.maga().arcane.converge_plan()
	var seen: Array = []
	for i in plan.count():
		for el in plan.elements_at(i):
			for r in b.apply(e, el):
				seen.append([i, r.kind])
		b.tick(HeroDef.maga().arcane.converge_tick)
	var K := Reaction.Kind
	assert_eq(seen, [[3, K.THERMAL], [6, K.OVERLOAD], [7, K.OVERLOAD], [8, K.CRYSTAL]], "the third phase is no waste")


func test_the_numbers_the_third_phase_depends_on_are_locked() -> void:
	var k := HeroDef.maga().arcane
	assert_eq([k.converge_phase, k.converge_tick, k.react_gap, k.burn_time], [1.5, 0.5, 0.5, 3.0])
	assert_gte(k.burn_time, k.converge_phase + k.converge_tick, "a shorter Queimadura would cost the phase its Sobrecarga")


func test_a_reaction_applies_no_state_and_leaves_no_celestial_one() -> void:
	_start()
	var e := _dummy(Vector2(4, 0))
	for i in 100:
		game.arcane.apply_element(e, F)
		game.arcane.apply_element(e, I if i % 2 == 0 else V)
		game.arcane.book.tick(0.6)
	assert_gt(game.arcane.tally.reactions, 40)
	assert_eq([e.burn_t, e.weak_t], [0.0, 0.0], "R-3: no state of the Blessings from her reactions")


func test_a_celestial_burn_is_no_fire_for_her_reactions() -> void:
	_start()
	var e := _dummy(Vector2(4, 0))
	e.burn_t = 3.0
	game.arcane.apply_element(e, ElementBook.ICE)
	assert_eq(game.arcane.tally.thermal, 0, "R-2: Sarael's Queimadura is not hers")
	assert_false(game.arcane.book.has_fire(e))


func test_a_ward_absorbs_the_bolt_and_no_element_comes_of_it() -> void:
	_start()
	var e := _dummy(Vector2(4, 0))
	e.invulnerable = true
	game.arcane.shot_landed(e, _shot(SHARD))
	assert_false(game.arcane.book.has_ice(e))
	assert_false(game.arcane.apply_element(e, ElementBook.FIRE))


func test_the_dead_and_the_new_room_clear_the_residue_and_the_count() -> void:
	_start([&"afinidade", &"catalisador", &"trindade", &"fluxo_arcano", &"reciprocidade", &"transcendencia"])
	var e := _dummy(Vector2(4, 0))
	game.arcane.apply_element(e, F)
	game.arcane.apply_element(e, I)
	assert_gt(game.arcane.book.residue(e), 0.0, "a direct reaction leaves a residue")
	game.arcane.clear()
	assert_eq(game.arcane.book.tracked(), 0)
	assert_false(game.arcane.transcend_ready())
	assert_eq(game.arcane.transcend_progress(), 0)


# ---------- the charge of the Supremo ----------

func test_a_reaction_gives_five_of_charge() -> void:
	_start()
	var e := _dummy(Vector2(4, 0))
	game.arcane.apply_element(e, F)
	game.arcane.apply_element(e, I)
	assert_eq(game.arcane.react_charge, 5.0)
	_step()
	assert_almost_eq(float(game.ults.charged.react), 5.0, 0.01, "Ultimates feeds it")


func test_one_cast_gives_ten_at_most() -> void:
	_start()
	var near: Array[Enemy] = []
	for i in 3:
		var e := _dummy(Vector2(3 + i * 1.2, 0))
		game.arcane.apply_element(e, F)
		near.append(e)
	game.arcane.react_charge = 0.0
	game.arcane.cast(_node(ComboNode.In.CHARGE_LIGHT), game.player.pos, Vector2.RIGHT)
	assert_eq(game.arcane.tally.overload, 3, "the Arco set off the three")
	assert_eq(game.arcane.react_charge, 10.0, "two of the three count")


func test_an_area_gives_charge_once_a_cast() -> void:
	_start()
	for i in 3:
		game.arcane.apply_element(_dummy(Vector2(4 + i * 0.5, 0)), F)
	game.arcane.react_charge = 0.0
	game.arcane.cast(_node(ComboNode.In.CHARGE), game.player.pos, Vector2.RIGHT)
	_step(5)
	assert_gte(game.arcane.tally.thermal, 3)
	assert_eq(game.arcane.react_charge, 5.0, "the Geada gives one of five however many reacted")


func test_the_convergence_charges_no_next_supremo() -> void:
	_start()
	var e := _dummy(Vector2(4, 0))
	game.ults._open_vortex(Vector2(4.5, 0))
	_step(int(4.7 / DT))
	assert_gt(game.arcane.tally.reactions, 0)
	assert_eq(game.arcane.react_charge, 0.0)


# ---------- the Dons ----------

func test_afinidade_makes_the_states_last_four_and_a_half() -> void:
	_start([&"afinidade"])
	var b := game.arcane.book
	assert_eq([b.burn_time, b.cold_time, b.volt_time, b.burn_dps], [4.5, 4.5, 4.5, 4.0])


func test_catalisador_makes_the_reactions_hit_thirty_percent_more() -> void:
	_start([&"afinidade", &"catalisador"])
	var b := game.arcane.book
	var e := RefCounted.new()
	b.apply(e, F)
	assert_almost_eq(b.apply(e, I)[0].damage, 45.5, 0.001)
	var o := RefCounted.new()
	b.apply(o, F)
	assert_almost_eq(b.apply(o, V)[0].damage, 32.5, 0.001)


func test_propagacao_passes_the_element_to_the_nearest_once_a_cast() -> void:
	_start([&"afinidade", &"propagacao"])
	var a := _dummy(Vector2(4, 0))
	var b := _dummy(Vector2(6, 0))
	var c := _dummy(Vector2(7.5, 0))
	var far := _dummy(Vector2(20, 0))
	game.arcane.shot_landed(a, _shot(SHARD))
	assert_true(game.arcane.book.has_ice(a))
	assert_true(game.arcane.book.has_ice(b), "the nearest within 3 m")
	assert_false(game.arcane.book.has_ice(c), "what was passed does not pass again")
	assert_false(game.arcane.book.has_ice(far))
	game.arcane.shot_landed(far, _shot(SHARD))
	assert_true(game.arcane.book.has_ice(far))
	assert_false(game.arcane.book.has_ice(c), "nothing within 3 m of it")
	game.arcane.shot_landed(c, _shot(SHARD))
	assert_true(game.arcane.book.has_ice(c), "another cast, another turn")


func test_trindade_makes_the_other_two_reactions_in_all_six_orders() -> void:
	var elements: Array[StringName] = [F, I, V]
	for a in elements:
		for b in elements:
			if a == b:
				continue
			var c: StringName = elements.filter(func(x: StringName) -> bool: return x != a and x != b)[0]
			var book := _book()
			book.trinity = true
			var e := RefCounted.new()
			book.apply(e, a)
			var first := book.apply(e, b)
			assert_eq(first.size(), 1, "%s then %s" % [a, b])
			assert_gt(book.residue(e), 0.0)
			assert_eq(book.apply(e, c).size(), 0, "react_gap holds the triple back")
			book.tick(0.6)
			var triple := book.apply(e, c)
			var kinds := triple.map(func(r: Reaction) -> int: return r.kind)
			kinds.sort()
			var want := [ElementBook.kind_of(a, c), ElementBook.kind_of(b, c)]
			want.sort()
			assert_eq(kinds, want, "%s, %s, then %s: the other two" % [a, b, c])
			assert_eq(book.residue(e), 0.0, "the residue goes")
			assert_false(book.has_fire(e) or book.has_ice(e) or book.has_volt(e))
			book.tick(0.6)
			assert_eq(book.apply(e, a).size(), 0, "the triple opened no residue")


func test_trindade_leaves_no_residue_for_an_area_and_none_without_the_dom() -> void:
	var book := _book()
	book.trinity = true
	var e := RefCounted.new()
	book.apply(e, F)
	book.apply(e, I, false, &"area")
	assert_eq(book.residue(e), 0.0)
	var plain := _book()
	var o := RefCounted.new()
	plain.apply(o, F)
	plain.apply(o, I)
	assert_eq(plain.residue(o), 0.0)
	var late := _book()
	late.trinity = true
	var l := RefCounted.new()
	late.apply(l, F)
	late.apply(l, I)
	late.tick(3.1)
	assert_eq(late.apply(l, V).size(), 0, "the residue lasts 3 s")


func test_permanencia_and_expansao_only_reach_the_geada_and_the_embers() -> void:
	_start([&"permanencia", &"expansao"])
	game.arcane.cast(_node(ComboNode.In.CHARGE), game.player.pos, Vector2.RIGHT)
	assert_almost_eq(game.arcane.frost.radius, 3.125, 0.001)
	assert_almost_eq(game.arcane.frost.life, 5.2, 0.001)
	assert_eq(game.arcane.book.overload_radius, 1.8, "the Sobrecarga is not an area to grow (D-15)")


func test_manifestacao_leaves_three_embers_at_most_and_none_from_an_area() -> void:
	_start([&"permanencia", &"manifestacao"])
	for i in 5:
		var e := _dummy(Vector2(3 + i * 4.0, 0))
		game.arcane.apply_element(e, F)
		game.arcane.apply_element(e, I)
		game.arcane.book.tick(0.6)
	assert_eq(game.arcane._embers.size(), 3, "the oldest go")
	assert_almost_eq(game.arcane._embers[0].radius, 2.0, 0.001)
	var area := _dummy(Vector2(-4, 0))
	game.arcane.apply_element(area, F, Arcane.AREA)
	game.arcane.apply_element(area, I, Arcane.AREA)
	assert_eq(game.arcane._embers.size(), 3)
	assert_eq(game.arcane.tally.thermal, 6)
	for i in 600:
		_step()
		assert_lte(game.arcane._embers.size(), 3, "no chain of embers")


func test_confluencia_shocks_who_stands_in_the_geada_and_an_ember_every_two_seconds() -> void:
	_start([&"permanencia", &"manifestacao", &"confluencia"])
	var e := _dummy(Vector2(4, 0))
	game.arcane.cast(_node(ComboNode.In.CHARGE), Vector2.ZERO, Vector2.RIGHT)
	game.arcane.frost.at = Vector2(4, 0)
	var hp := e.hp
	for i in 6:
		game.arcane._step_confluence(0.5)
		game.arcane.book.tick(0.5)
	assert_eq(game.arcane.tally.thermal, 0, "the Geada alone shocks no one")
	game.arcane._lay_embers(Vector2(4, 0))
	for i in 6:
		game.arcane._step_confluence(0.5)
		game.arcane.book.tick(0.5)
	assert_eq(game.arcane.tally.thermal, 2, "two shocks in three seconds")
	assert_lt(e.hp, hp - 60.0)
	assert_false(game.arcane.book.has_fire(e) and game.arcane.book.has_ice(e), "it consumed nothing")


func test_agilidade_arcana_charges_the_held_spells_in_0_42() -> void:
	_start([&"fluxo_arcano", &"agilidade_arcana"])
	game.player._charge_held = ComboNode.In.CHARGE_LIGHT
	assert_almost_eq(game.player._charge_time(), 0.42, 0.001)


func test_reciprocidade_gives_two_once_a_cast() -> void:
	_start([&"fluxo_arcano", &"reciprocidade"])
	for i in 3:
		game.arcane.apply_element(_dummy(Vector2(4 + i * 0.5, 0)), F)
	game.player.magick.value = 10.0
	game.arcane.cast(_node(ComboNode.In.CHARGE), game.player.pos, Vector2.RIGHT)
	_step()
	assert_almost_eq(game.player.magick.value, 12.05, 0.1, "three reactions, 2 of Magia")
	_step(300)
	assert_lt(game.player.magick.value, 12.05 + 3.0 * 5.0 + 0.5, "the ticks of the Geada paid no more")


func test_transcendencia_makes_the_next_held_spell_free_and_quick_and_it_is_kept_when_cancelled() -> void:
	_start([&"fluxo_arcano", &"reciprocidade", &"transcendencia"])
	for i in 3:
		var e := _dummy(Vector2(4 + i * 4.0, 0))
		game.arcane.apply_element(e, F)
		game.arcane.shot_landed(e, _shot(SHARD))
	assert_true(game.arcane.transcend_ready(), "three reactions")
	var arc := _node(ComboNode.In.CHARGE_LIGHT)
	assert_eq(game.player.cost_of(arc, 0.0), 0.0)
	game.player._charge_held = ComboNode.In.CHARGE_LIGHT
	assert_almost_eq(game.player._charge_time(), Feel.live().hold_threshold, 0.001, "only the threshold")
	assert_eq(game.player.cost_of(_node(ComboNode.In.HEAVY), 0.0), 5.0, "a tap is not held: it pays")
	# let go before it filled: kept
	for i in 5:
		pad.press(&"light_attack")
		game._step(DT)
		pad.end_frame()
	pad.release(&"light_attack")
	_step(30)
	assert_true(game.arcane.transcend_ready(), "a cancel spends nothing")
	for k in 3:
		_dummy(Vector2(3 + k * 1.5, 0))
	game.player.magick.value = 0.0
	_hold(&"light_attack", 40)
	assert_true(strikes.has(&"arc"), "it strikes with no Magia")
	assert_false(game.arcane.transcend_ready(), "spent on the strike")
	assert_eq(game.player.magick.spent, 0.0, "no Magia spent, so no Supremo charge from it")


func test_the_free_spells_reactions_do_not_count_for_the_next() -> void:
	_start([&"fluxo_arcano", &"reciprocidade", &"transcendencia"])
	game.arcane._transcend = true
	game.arcane.take_transcend()
	for i in 3:
		game.arcane.apply_element(_dummy(Vector2(3 + i * 1.5, 0)), F)
	game.arcane.cast(_node(ComboNode.In.CHARGE_LIGHT), game.player.pos, Vector2.RIGHT)
	assert_eq(game.arcane.tally.overload, 3)
	assert_eq(game.arcane.transcend_progress(), 0)
	assert_false(game.arcane.transcend_ready())


# ---------- the save ----------

func _old_save(opened: Array, equipped: Array, version: int) -> Dictionary:
	var d := SaveData.defaults()
	var b: Dictionary = SaveData.hero_defaults()
	b["opened"] = opened.duplicate()
	b["unlocked"] = opened.duplicate()
	b["equipped"] = equipped
	b["ultimate"] = "converge"
	b["mastery_xp"] = 321
	d.heroes["maga"] = b
	d.version = version
	return d


func test_the_provisional_dons_give_their_memoria_back_once() -> void:
	var old := _old_save(["faisca_persistente", "fissao_termica", "tempestade_contida"], ["fissao_termica"], 17)
	var warrior: Dictionary = (old.heroes as Dictionary).get("warrior", {})
	warrior["opened"] = ["disciplina"]
	old.heroes["warrior"] = warrior
	var m0 := MaterialPurse.amount(old, MaterialPurse.MEMORY)
	var out := SaveData.merged(old)
	assert_eq(out.version, 19)
	assert_eq(MaterialPurse.amount(out, MaterialPurse.MEMORY) - m0, 8, "0, 4 and 4")
	assert_eq(out.heroes.maga.opened, [])
	assert_eq(out.heroes.maga.unlocked, [])
	assert_eq(out.heroes.maga.equipped, [], "the Vagas are free")
	assert_eq(out.heroes.maga.ultimate, "converge", "her only Supremo stays chosen")
	assert_eq(out.heroes.maga.mastery_xp, 321)
	assert_eq(out.heroes.warrior.opened, ["disciplina"], "the Warrior's Dons are untouched")
	var again := SaveData.merged(out)
	assert_eq(MaterialPurse.amount(again, MaterialPurse.MEMORY), MaterialPurse.amount(out, MaterialPurse.MEMORY), "a second load gives nothing")
	assert_eq(SaveData.migrate_removed_dons(again, SaveData.GP5_REMOVED_DONS, ["maga"]).maga, 0)


func test_an_empty_save_and_the_new_dons_pass_through() -> void:
	var out := SaveData.merged(_old_save([], [], 17))
	assert_eq(out.heroes.maga.opened.size(), out.heroes.maga.unlocked.size())
	var keep := _old_save(["afinidade"], ["afinidade"], 17)
	var kept := SaveData.merged(keep)
	assert_true((kept.heroes.maga.opened as Array).has("afinidade"), "a new id is not a removed one")


func test_the_table_sums_to_twenty_nine() -> void:
	var t := 0
	for id: String in SaveData.GP5_REMOVED_DONS.maga:
		t += int(SaveData.GP5_REMOVED_DONS.maga[id])
	assert_eq(t, 29)


func test_a_save_from_version_13_goes_through_every_step() -> void:
	var out := SaveData.merged(_old_save(["brasa_viva", "combustao"], ["combustao"], 13))
	assert_eq(out.version, SaveData.VERSION)
	assert_eq(out.heroes.maga.opened, [])


# ---------- the first tips and the lesson ----------

func test_the_antessala_teaches_the_maga_with_her_words() -> void:
	var l := AnteLesson.new(true)
	assert_eq(l.steps, AnteLesson.ORDER_MAGA, "the Warrior's order without the Golpe Esmagador")
	assert_eq(l.key(), &"lesson_attack_maga")
	l.feed(&"finisher")
	assert_eq(l.key(), &"lesson_power_maga")
	for key: StringName in [&"lesson_attack_maga", &"lesson_power_maga", &"lesson_special_maga"]:
		assert_ne(T.t(key), String(key), "%s is in the table" % key)
	assert_eq(AnteLesson.new(false).key(), &"lesson_attack", "the Warrior's tips are as they were")


func test_the_maga_tips_exist_and_come_once() -> void:
	for key: StringName in [&"tip_hold_maga", &"tip_maga_v1", &"tip_regen"]:
		assert_ne(T.t(key), String(key))
		assert_false(T.t(key).contains("—"))
	var data := SaveData.defaults()
	data["runs"] = 9
	var ctx := {"fighting": true, "fight_t": 2.0, "maga": true}
	assert_eq(FirstTips.pick(data, ctx), &"maga_v1", "an old save is told too")
	FirstTips.mark(data, &"maga_v1")
	assert_ne(FirstTips.pick(data, ctx), &"maga_v1")
	assert_eq(FirstTips.key_of(&"hold", true), &"tip_hold_maga")
	assert_eq(FirstTips.key_of(&"hold", false), &"tip_hold")
	ctx["fight_t"] = 0.0
	data["runs"] = 0
	ctx["magick_empty"] = true
	assert_eq(FirstTips.pick(data, ctx), &"regen")
