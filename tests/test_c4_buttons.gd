extends GutTest
## Lote C4 (BO-1, BO-2), followed to Blessings V1 (docs/design/bencaos_v1): the base of Sarael (Chama) and Nivael (Geada): one
## Blessing a button (attack, special, Brado, dodge, ultimate; E has none), no principal acts alone; a held button is out of
## the draw and nothing is replaced; the reserve is out of the draw; the ultimate's waits for the ultimate; up to three cards
## at a meeting; the same seed, the same cards. What each Blessing does in the blow is test_blessings_v1_combat.

const SARAEL: Array[StringName] = [&"golpe_brasa", &"pesado_brasa", &"circulo_brasa", &"passo_brasa", &"chuva_brasas"]
const NIVAEL: Array[StringName] = [&"golpe_geada", &"toque_geada", &"circulo_geada", &"floco_errante", &"peso_inverno"]
## The buttons in the order of the five slots of each angel's list above.
const BUTTONS: Array[StringName] = [&"light_attack", &"heavy_attack", &"heavy_attack", &"dodge", &"ultimate"]
## Sarael's and Nivael's old Blessings that left the draw (Chama and Geada, kept for an old save).
const RESERVE: Array[StringName] = [&"brasas", &"lamina_ardente", &"omega_brasa", &"redemoinho", &"ultimo_brasa", &"passo_geada",
	&"ultimo_geada", &"geada_final", &"omega_geada"]
const DT := 1.0 / 60.0

var state: BoonState
var game: Game


func before_each() -> void:
	state = BoonState.new(BoonState.load_catalog())


func after_each() -> void:
	Dev.put("seed", "1")


func _tags(list: Array) -> Array[StringName]:
	var out: Array[StringName] = []
	out.assign(list)
	return out


# ---------- the base: five buttons, one Blessing each ----------

func test_each_of_the_ten_lights_one_button_and_no_principal_acts_alone() -> void:
	for list in [SARAEL, NIVAEL]:
		for i in list.size():
			var b := state.find(list[i])
			assert_not_null(b, String(list[i]))
			assert_eq(b.button(), BUTTONS[i], "%s changes the %s" % [b.id, BUTTONS[i]])
			assert_ne(b.slot, Boon.Slot.NONE, "%s rides on a button" % b.id)
			assert_false(b.acts_alone(), "%s never acts alone" % b.id)
			assert_false(b.reserve, String(b.id))
	for b in state.catalog:
		if (b.family == Boon.Family.CHAMA or b.family == Boon.Family.GEADA) and not b.reserve and b.slot != Boon.Slot.NONE:
			assert_false(b.acts_alone(), "%s of Chama or Geada is a button's" % b.id)


func test_the_skills_wait_for_their_button() -> void:
	var want := {&"circulo_brasa": SkillDef.Trigger.SHOUT, &"chuva_brasas": SkillDef.Trigger.ULT, &"circulo_geada": SkillDef.Trigger.SHOUT,
		&"peso_inverno": SkillDef.Trigger.ULT, &"floco_errante": SkillDef.Trigger.DODGE}
	for id: StringName in want:
		var b := state.find(id)
		assert_eq(b.skill.trigger, want[id], String(id))
		assert_gt(b.skill.get_gap(1) + b.skill.get_duration(1) + float(b.slot == Boon.Slot.ULT), 0.0)
	assert_gt(state.find(&"floco_errante").skill.get_duration(1), 0.0, "the flakes turn for a while")
	assert_eq(state.find(&"floco_errante").skill.status, &"cold", "the flakes put Frio, they do not freeze by themselves")
	assert_eq(state.find(&"peso_inverno").skill.kind, SkillDef.Kind.METEOR)


func test_the_investida_has_no_blessing_and_the_dodge_has_one() -> void:
	assert_ne(Boon.Slot.RUSH, Boon.Slot.DASH)
	for b in state.catalog:
		if b.slot == Boon.Slot.RUSH:
			assert_true(b.reserve, "%s rides on E, out of the draw" % b.id)
		if b.slot != Boon.Slot.NONE:
			assert_ne(b.button(), &"", String(b.id))
	assert_eq(state.find(&"passo_brasa").button(), &"dodge")


func test_a_held_button_is_not_offered_again_and_nothing_is_swapped() -> void:
	for i in 5:
		var a := state.find(SARAEL[i])
		var b := state.find(NIVAEL[i])
		state.take(a)
		assert_false(state.still_free(b), "%s's button is taken by %s" % [b.id, a.id])
		assert_eq(state.level(a.id), 1, "%s stays" % a.id)
		assert_eq(state.level(b.id), 0)
	assert_eq(state.owned().size(), 5, "a full build holds five principals")


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
	assert_eq(Encounter.supply(state, sarael), 4, "a novice sees four of Sarael (the complements wait for what they ask)")
	state.ult_open = true
	assert_eq(Encounter.supply(state, sarael), 5)


func test_legendary_is_two_percent_and_three_at_the_guardian() -> void:
	# SW-B2 (2026-11-25): the curve went 16/6/2 (SWORN's), the guardian's stays 90/7/3
	assert_almost_eq(BoonState.rarity_odds(Boon.RARITY_CHANCE)[Boon.Rarity.LEGENDARY], 0.02, 0.0001)
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


func test_up_to_three_cards_at_every_meeting_as_many_as_there_are() -> void:
	state.ult_open = true
	var book := Encounter.new(Encounter.load_catalog())
	var sarael := book.find(&"sarael")
	var rng := RandomNumberGenerator.new()
	rng.seed = 21
	for meeting in 8:
		if not Encounter.eligible(state, sarael):
			break
		var cards := Encounter.cards(state, sarael, rng, 3, Boon.RARITY_CHANCE, 0.0, 0.0)
		assert_eq(cards.size(), mini(3, _offerable(state)), "meeting %d" % meeting)
		var own := 0
		for c in cards:
			if Encounter.belongs(state, c.boon, sarael.family):
				own += 1
			assert_false(c.boon.reserve)
		assert_eq(own, mini(3, Encounter.supply(state, sarael)), "Sarael's own cards first, a short family filled from others")
		# takes the first card each time: the hand grows, a taken button leaves the draw
		state.take_card(cards[0])
	assert_gt(state.owned().size(), 2)


func test_a_pair_of_angels_has_as_many_cards_as_each_has_and_none_without_any() -> void:
	var book := Encounter.new(Encounter.load_catalog())
	var rng := RandomNumberGenerator.new()
	rng.seed = 5
	for run in 40:
		var s := BoonState.new(BoonState.load_catalog())
		s.ult_open = run % 2 == 0
		for room in 6:
			var pair := book.pair(s, Encounter.dice(run, room, room))
			for a in pair:
				var cards := Encounter.cards(s, a, rng, 3)
				assert_eq(cards.size(), mini(3, _offerable(s)), "%s in room %d: three while the catalog has them" % [a.id, room])
				assert_gt(cards.size(), 0, "an angel without a card does not come")
			if not pair.is_empty():
				s.take_card(Encounter.cards(s, pair[0], rng, 3)[0])


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
	assert_eq(got[&"smash"], SkillDef.Trigger.OMEGA, "the Esmagador, held on the left")
	assert_eq(got[&"lance"], SkillDef.Trigger.SPECIAL, "GP-1: the Lança is the Especial's")
	assert_eq(got[&"sweep"], SkillDef.Trigger.SHOUT, "the Corte Circular is the Poder's (CAST)")
	assert_false(got.has(&"bolt") or got.has(&"dash_cut"), "no rajada, no Investida")


func _arena() -> void:
	Dev.has("seed")
	Dev._args["seed"] = "1"
	game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	game.rooms.start_at(RunMap.Kind.FOUNTAIN)
	game.horde.clear_crowd()
	game.player.pos = Vector2.ZERO
	game.horde.target = Vector2.ZERO


func _spawn_near() -> void:
	for k in 4:
		game.horde.spawn(game.horde.def(&"skeleton"), Vector2(3.0 + k, 1.0), false)


func test_the_poder_em_brasa_leaves_ground_only_when_the_brado_is_cast_and_not_inside_its_gap() -> void:
	_arena()
	game._take(game.boons.find(&"circulo_brasa"))
	var zones := game.ground.zones.size()
	for i in 600:
		game.skills.step(DT)
	assert_eq(game.ground.zones.size(), zones, "ten seconds and no ground: it waits for the Brado")
	game.skills.trigger(SkillDef.Trigger.SHOUT)
	assert_eq(game.ground.zones.size(), zones + 1, "the Brado leaves embers on the floor")
	game.skills.trigger(SkillDef.Trigger.SHOUT)
	assert_eq(game.ground.zones.size(), zones + 1, "not again inside its gap")
	for i in int(4.2 / DT):
		game.skills.step(DT)
	game.skills.trigger(SkillDef.Trigger.SHOUT)
	assert_eq(game.ground.zones.size(), zones + 2, "the gap is over")


func test_a_button_sets_off_only_its_own_skill() -> void:
	_arena()
	game._take(game.boons.find(&"floco_errante"))
	game.skills.trigger(SkillDef.Trigger.RUSH)
	game.skills.trigger(SkillDef.Trigger.SPECIAL)
	assert_eq(game.skills._orbit_left, 0.0, "the dodge's flakes are not the Investida's")
	game.skills.trigger(SkillDef.Trigger.DODGE)
	assert_gt(game.skills._orbit_left, 0.0, "the flakes turn")
	for i in int(5.0 / DT):
		game.skills.step(DT)
	assert_null(game.skills._orbit_boon, "and stop")


func test_the_ultimate_blessing_waits_for_nobody_in_range_without_spending_its_gap() -> void:
	_arena()
	game._take(game.boons.find(&"chuva_brasas"))
	game.skills.trigger(SkillDef.Trigger.ULT)
	assert_true(game.skills._pending.is_empty(), "nobody near: nothing falls")
	_spawn_near()
	game.skills.trigger(SkillDef.Trigger.ULT)
	assert_gt(game.skills._pending.size(), 0, "brasas fall on the ones near")


## every Blessing that could still be offered, of any angel (a short family is filled from these, 2026-11-26)
func _offerable(s: BoonState) -> int:
	var n := 0
	for b in s.catalog:
		if s.level(b.id) <= 0 and s.offerable(b):
			n += 1
	return n
