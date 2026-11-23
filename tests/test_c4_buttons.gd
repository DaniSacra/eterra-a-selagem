extends GutTest
## Lote C4 (BO-1, BO-2): the base of the 42 Blessings, one a button, with the 12 of Sarael (Chama) and Nivael (Geada): each
## lights one button and none acts alone; another of the same button swaps; the reserve is out of the draw; the Shift's waits
## for the ultimate; three cards at every meeting; the same seed, the same cards.

const SARAEL: Array[StringName] = [&"golpe_brasa", &"pesado_brasa", &"circulo_brasa", &"redemoinho", &"ultimo_brasa", &"passo_brasa"]
const NIVAEL: Array[StringName] = [&"golpe_geada", &"toque_geada", &"circulo_geada", &"passo_geada", &"ultimo_geada", &"floco_errante"]
## The buttons in the order of the six slots of each angel's list above.
const BUTTONS: Array[StringName] = [&"light_attack", &"heavy_attack", &"shout", &"rush", &"ultimate", &"dodge"]
## Sarael's and Nivael's Blessings that left the draw (Chama and Geada, kept).
const RESERVE: Array[StringName] = [&"brasas", &"lamina_ardente", &"omega_brasa", &"chuva_brasas", &"estilhaco", &"peso_inverno",
	&"geada_final", &"omega_geada"]
const DT := 1.0 / 60.0

var state: BoonState
var game: Game


func before_each() -> void:
	state = BoonState.new(BoonState.load_catalog())


func _tags(list: Array) -> Array[StringName]:
	var out: Array[StringName] = []
	out.assign(list)
	return out


# ---------- the base: six buttons, one Blessing each ----------

func test_each_of_the_twelve_lights_one_button_and_none_acts_alone() -> void:
	for list in [SARAEL, NIVAEL]:
		for i in list.size():
			var b := state.find(list[i])
			assert_not_null(b, String(list[i]))
			assert_eq(b.button(), BUTTONS[i], "%s changes the %s" % [b.id, BUTTONS[i]])
			assert_ne(b.slot, Boon.Slot.NONE, "%s rides on a button" % b.id)
			assert_false(b.acts_alone(), "%s never acts alone" % b.id)
			assert_false(b.reserve, String(b.id))
	for b in state.catalog:
		if (b.family == Boon.Family.CHAMA or b.family == Boon.Family.GEADA) and not b.reserve:
			assert_false(b.acts_alone(), "%s of Chama or Geada is a button's" % b.id)


func test_the_skills_of_the_twelve_wait_for_their_button() -> void:
	var want := {&"pesado_brasa": SkillDef.Trigger.SPECIAL, &"redemoinho": SkillDef.Trigger.RUSH, &"ultimo_brasa": SkillDef.Trigger.ULT,
		&"passo_geada": SkillDef.Trigger.RUSH, &"ultimo_geada": SkillDef.Trigger.ULT, &"floco_errante": SkillDef.Trigger.DODGE}
	for id: StringName in want:
		var b := state.find(id)
		assert_eq(b.skill.trigger, want[id], String(id))
		assert_gt(b.skill.get_gap(1) + b.skill.get_duration(1) + float(id.begins_with(&"ultimo")), 0.0)
	for id in [&"redemoinho", &"floco_errante"]:
		assert_gt(state.find(id).skill.get_duration(1), 0.0, "%s turns for a while" % id)
	assert_eq(state.find(&"floco_errante").skill.status, &"slow", "the flakes slow, they do not freeze (decision 7)")
	assert_eq(state.find(&"ultimo_geada").skill.kind, SkillDef.Kind.METEOR)


func test_the_investida_and_the_dodge_are_two_buttons() -> void:
	assert_eq(state.find(&"passo_radiante").button(), &"rush", "the other angels' Investida moved to its own slot")
	assert_eq(state.find(&"passo_brasa").button(), &"dodge")
	assert_ne(Boon.Slot.RUSH, Boon.Slot.DASH)
	for b in state.catalog:
		if b.slot != Boon.Slot.NONE:
			assert_ne(b.button(), &"", String(b.id))


func test_another_blessing_of_the_same_button_swaps_it() -> void:
	for i in 6:
		var a := state.find(SARAEL[i])
		var b := state.find(NIVAEL[i])
		state.take(a)
		assert_eq(state.replaced_by(b), a, "%s and %s share the %s" % [a.id, b.id, BUTTONS[i]])
		state.take(b)
		assert_eq(state.level(a.id), 0, "%s went" % a.id)
		assert_eq(state.level(b.id), 1)
	# one a button: a full build holds six at most, the other angel's are all in trades now
	assert_eq(state.owned().size(), 6)
	for i in 6:
		state.take(state.find(SARAEL[i]))
	assert_eq(state.owned().size(), 6, "build full is six")


# ---------- the draw ----------

func test_the_reserve_never_comes_but_stays_in_the_catalog() -> void:
	for id in RESERVE:
		var b := state.find(id)
		assert_not_null(b, "%s is kept" % id)
		assert_true(b.reserve, String(id))
		assert_false(state.offerable(b))
	state.ult_open = true
	var rng := RandomNumberGenerator.new()
	rng.seed = 3
	for i in 400:
		for c in state.draw(rng, 3, Boon.RARITY_CHANCE, 0.3, 0.3):
			assert_false(c.boon.reserve, "%s is in the reserve" % c.boon.id)
	# an old save or a test may still hold one: it takes and grows as before
	assert_eq(state.take(state.find(&"brasas")), 1)


func test_the_shift_blessing_waits_for_the_ultimate() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 9
	for open in [false, true]:
		state.ult_open = open
		var seen := false
		for i in 300:
			for c in state.draw(rng, 3):
				if c.boon.slot == Boon.Slot.ULT:
					seen = true
		assert_eq(seen, open, "ultimate open %s" % open)
	state.ult_open = false
	var book := Encounter.new(Encounter.load_catalog())
	var sarael := book.find(&"sarael")
	assert_eq(Encounter.supply(state, sarael), 5, "a novice sees five of Sarael")
	state.ult_open = true
	assert_eq(Encounter.supply(state, sarael), 6)


func test_legendary_is_one_percent_and_three_at_the_guardian() -> void:
	assert_almost_eq(BoonState.rarity_odds(Boon.RARITY_CHANCE)[Boon.Rarity.LEGENDARY], 0.01, 0.0001)
	assert_almost_eq(BoonState.rarity_odds(Boon.RARITY_CHANCE_GUARDIAN)[Boon.Rarity.LEGENDARY], 0.03, 0.0001)


func test_the_same_seed_gives_the_same_cards() -> void:
	state.ult_open = true
	var book := Encounter.new(Encounter.load_catalog())
	for angel in [&"sarael", &"nivael"]:
		var runs: Array = []
		for k in 2:
			var s := BoonState.new(BoonState.load_catalog())
			s.ult_open = true
			var cards := Encounter.cards(s, book.find(angel), Encounter.cards_dice(5, 3, 2, angel), 3, Boon.RARITY_CHANCE_GUARDIAN)
			runs.append(cards.map(func(c: BoonState.Card) -> String: return "%s:%d:%d" % [c.boon.id, c.rarity, c.level]))
		assert_eq(runs[0], runs[1], "%s: same dice, same cards" % angel)


func test_three_cards_at_every_meeting_even_the_second_with_the_same_angel() -> void:
	state.ult_open = true
	var book := Encounter.new(Encounter.load_catalog())
	var sarael := book.find(&"sarael")
	var rng := RandomNumberGenerator.new()
	rng.seed = 21
	for meeting in 8:
		if not Encounter.eligible(state, sarael):
			break
		var cards := Encounter.cards(state, sarael, rng, 3, Boon.RARITY_CHANCE, 0.0, 0.0)
		assert_eq(cards.size(), 3, "meeting %d" % meeting)
		for c in cards:
			assert_true(Encounter.belongs(state, c.boon, sarael.family))
			assert_false(c.boon.reserve)
		# takes the first card each time: the hand grows, then the cards turn into a level more
		state.take_card(cards[0])
	assert_gt(state.owned().size(), 2)


func test_a_pair_of_angels_always_has_three_cards_each() -> void:
	var book := Encounter.new(Encounter.load_catalog())
	var rng := RandomNumberGenerator.new()
	rng.seed = 5
	for run in 40:
		var s := BoonState.new(BoonState.load_catalog())
		s.ult_open = run % 2 == 0
		for room in 6:
			var pair := book.pair(s, Encounter.dice(run, room, room))
			assert_eq(pair.size(), 2, "two angels in room %d" % room)
			for a in pair:
				assert_eq(Encounter.cards(s, a, rng, 3).size(), 3, "%s in room %d" % [a.id, room])
			var cards := Encounter.cards(s, pair[0], rng, 3)
			s.take_card(cards[0])


# ---------- the hero's buttons and the skills ----------

func test_each_move_of_the_tree_sets_off_its_button() -> void:
	var tree := load("res://data/combos/paladin.tres") as ComboTree
	var got := {}
	var stack: Array[ComboNode] = []
	stack.assign(tree.neutral)
	while not stack.is_empty():
		var n: ComboNode = stack.pop_back()
		got[n.id] = Skills.trigger_of(n)
		stack.append_array(n.next)
	assert_eq(got[&"cut1"], -1)
	assert_eq(got[&"cut2"], -1)
	assert_eq(got[&"cut3"], SkillDef.Trigger.FINISHER)
	assert_eq(got[&"bolt"], SkillDef.Trigger.SPECIAL)
	assert_eq(got[&"lance"], SkillDef.Trigger.OMEGA)
	assert_eq(got[&"shout"], SkillDef.Trigger.SHOUT)
	assert_eq(got[&"dash_cut"], SkillDef.Trigger.RUSH)


func _arena() -> void:
	Dev.has("seed")
	Dev._args["seed"] = "1"
	game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	game.rooms.start_at(RunMap.Kind.FOUNTAIN)
	game.horde.clear_crowd()
	game.player.pos = Vector2.ZERO
	game.horde.target = Vector2.ZERO


func after_each() -> void:
	Dev.put("seed", "1")


func _hit(e: Enemy, base: float, tags: Array[StringName]) -> float:
	var before := e.hp + e.armor
	game.combat.hit_enemy(e, base, tags, Vector2.RIGHT, 0.0)
	return before - e.hp - e.armor


func test_nothing_happens_by_itself_and_the_button_sets_it_off_once_a_gap() -> void:
	_arena()
	game._take(game.boons.find(&"pesado_brasa"))
	var zones := game.ground.zones.size()
	for i in 600:
		game.skills.step(DT)
	assert_eq(game.ground.zones.size(), zones, "ten seconds and no ground: it waits for the special")
	game.skills.trigger(SkillDef.Trigger.SPECIAL)
	assert_eq(game.ground.zones.size(), zones + 1, "the wave leaves embers on the floor")
	game.skills.trigger(SkillDef.Trigger.SPECIAL)
	assert_eq(game.ground.zones.size(), zones + 1, "not again inside its gap")
	for i in int(3.2 / DT):
		game.skills.step(DT)
	game.skills.trigger(SkillDef.Trigger.SPECIAL)
	assert_eq(game.ground.zones.size(), zones + 2, "the gap is over")


func test_a_button_sets_off_only_its_own_skill() -> void:
	_arena()
	game._take(game.boons.find(&"redemoinho"))
	game.skills.trigger(SkillDef.Trigger.DODGE)
	game.skills.trigger(SkillDef.Trigger.SPECIAL)
	assert_eq(game.skills._orbit_left, 0.0, "the dodge is not the Investida")
	game.skills.trigger(SkillDef.Trigger.RUSH)
	assert_almost_eq(game.skills._orbit_left, 4.0, 0.001, "the flames turn 4 s")
	for i in int(4.1 / DT):
		game.skills.step(DT)
	assert_null(game.skills._orbit_boon, "and stop")


func test_the_flakes_come_from_the_dodge_and_slow() -> void:
	_arena()
	game._take(game.boons.find(&"floco_errante"))
	assert_eq(game.skills._orbit_left, 0.0)
	game.skills.trigger(SkillDef.Trigger.DODGE)
	assert_almost_eq(game.skills._orbit_left, 3.0, 0.001)
	var e := game.horde.spawn(game.horde.def(&"skeleton"), Vector2(3.0, 0.0), false)
	var tags := _tags([&"skill", &"geada", &"floco_errante"])
	game.combat.skill_hit(e, 3.0, tags, Vector2.RIGHT, 0.0, &"slow", 1.0)
	assert_gt(e.slow_t, 0.0)
	assert_eq(e.frozen_t, 0.0, "they delay, they do not freeze")


func test_the_ultimate_blessing_waits_for_nobody_in_range_without_spending_its_gap() -> void:
	_arena()
	game._take(game.boons.find(&"ultimo_brasa"))
	game.skills.trigger(SkillDef.Trigger.ULT)
	assert_true(game.skills._pending.is_empty(), "nobody near: nothing falls")
	_spawn_near()
	game.skills.trigger(SkillDef.Trigger.ULT)
	assert_gt(game.skills._pending.size(), 0, "brasas fall on the ones near")


func _spawn_near() -> void:
	for k in 4:
		game.horde.spawn(game.horde.def(&"skeleton"), Vector2(3.0 + k, 1.0), false)


# ---------- what the Blessings change in the blow ----------

func test_the_brado_detonates_the_burn_and_the_fire_goes_out() -> void:
	_arena()
	var e := game.horde.spawn(game.horde.def(&"skeleton"), Vector2(3.0, 0.0), false)
	var shout := _tags([&"shout", &"cast"])
	var plain := _hit(e, 15.0, shout)
	e.hp = e.def.hp
	game._take(game.boons.find(&"circulo_brasa"))
	var cold := _hit(e, 15.0, shout)
	assert_almost_eq(cold, plain, 0.01, "nothing burns: nothing to detonate")
	e.hp = e.def.hp
	e.burn_t = 3.0
	e.burn_dps = 2.0
	var burning := _hit(e, 15.0, shout)
	assert_gt(burning, plain + 10.0, "the burning one takes the detonation at once")
	assert_eq(e.burn_t, 0.0, "and stops burning: it does not burn again")


func test_the_wave_shatters_the_frozen_and_the_light_blow_does_not() -> void:
	_arena()
	game._take(game.boons.find(&"toque_geada"))
	var e := game.horde.spawn(game.horde.def(&"skeleton"), Vector2(3.0, 0.0), false)
	e.frozen_t = 2.0
	var light := _hit(e, 10.0, _tags([&"light"]))
	assert_almost_eq(light, 10.0, 0.01, "no shatter on the attack")
	assert_gt(e.frozen_t, 0.0)
	e.hp = e.def.hp
	var wave := _hit(e, 10.0, _tags([&"heavy", &"wave"]))
	assert_gt(wave, 10.0, "the wave breaks it for more")
	assert_eq(e.frozen_t, 0.0)


func test_only_the_spin_freezes() -> void:
	_arena()
	game._take(game.boons.find(&"golpe_geada"))
	var e := game.horde.spawn(game.horde.def(&"skeleton"), Vector2(3.0, 0.0), false)
	_hit(e, 5.0, _tags([&"light"]))
	assert_eq(e.frozen_t, 0.0, "a plain cut does not freeze")
	_hit(e, 5.0, _tags([&"light", &"spin", &"finisher"]))
	assert_gt(e.frozen_t, 0.0, "the spin does")


func test_the_ultimate_frost_freezes_through_its_tag() -> void:
	_arena()
	var rule := StunRule.live
	StunRule.live = StunRule.Mode.NONE  # how the exe runs
	var e := game.horde.spawn(game.horde.def(&"skeleton"), Vector2(3.0, 0.0), false)
	game.combat.skill_hit(e, 3.0, _tags([&"skill", &"geada", &"ultimo_geada", &"ultimate"]), Vector2.RIGHT, 0.0, &"freeze", 2.0)
	assert_gt(e.frozen_t, 0.0)
	var f := game.horde.spawn(game.horde.def(&"skeleton"), Vector2(5.0, 0.0), false)
	game.combat.skill_hit(f, 3.0, _tags([&"skill", &"geada", &"passo_geada"]), Vector2.RIGHT, 0.0, &"freeze", 0.8)
	assert_eq(f.frozen_t, 0.0, "the Investida's blades only slow while no blow of theirs may stop anyone (StunRule)")
	assert_gt(f.slow_t, 0.0)
	StunRule.live = rule
