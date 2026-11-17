extends GutTest
## E4-01 and E4-02 (docs/design/e4_psalms.md): the Psalms. The rules (Psalms, pure): three groups of a Blessing, an
## Elo or a Gift, the chance of a card (10%, 5% at the guardian) over 10 thousand draws, one per theme, two a run.
## Each of the four effects in a real run (PsalmPlay): the Sentinela's circle, the Abrigo's shelter, the Pastor's
## flock and the Rocha's stone. And the text: named by theme, no number of a psalm, no verse quoted.

const APPROVED: Array[StringName] = [&"sentinela", &"abrigo", &"pastor", &"rocha"]

var game: Game


func before_each() -> void:
	Dev.has("seed")
	Dev._args["seed"] = "1"


func after_each() -> void:
	Dev._args.erase("seed")


func _catalog() -> Array[PsalmDef]:
	return Psalms.load_catalog()


func _psalm(id: StringName) -> PsalmDef:
	return Psalms.new(_catalog()).find(id)


## A made-up Psalm for the rules (theme, groups).
func _made(id: StringName, theme: StringName, groups: Array) -> PsalmDef:
	var p := PsalmDef.new()
	p.id = id
	p.theme = theme
	for g: Array in groups:
		p.requires.append(PackedStringArray(g))
	return p


## A BoonState holding these Blessings (and Elos).
func _held(ids: Array) -> BoonState:
	var b := BoonState.new(BoonState.load_catalog())
	for id: String in ids:
		b.levels[StringName(id)] = 1
	return b


## A run in the fountain room (nobody else), the paladin at the middle, with this Psalm taken.
func _run(id: StringName) -> void:
	game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	game.rooms.start_at(RunMap.Kind.FOUNTAIN)
	game.horde.clear_crowd()
	game.player.pos = Vector2.ZERO
	if id != &"":
		assert_true(game.take_psalm(game.psalms.find(id)), "took %s" % id)


func _enemy(id: StringName, at: Vector2) -> Enemy:
	var e := game.horde.spawn(game.horde.def(id), game.arena.resolve(at, 0.6), false)
	e.cooldown = 99.0
	return e


func _move(id: StringName) -> ComboNode:
	for n in game.player.tree.all_nodes():
		if n.id == id:
			return n
	return null


# ---------- the data ----------

func test_the_four_approved_psalms_are_data_with_three_groups_of_things_that_exist() -> void:
	var cat := _catalog()
	var ids: Array[StringName] = []
	var themes := {}
	var boons := BoonState.new(BoonState.load_catalog())
	var gifts := HeroDef.warrior().talents()
	for p in cat:
		ids.append(p.id)
		themes[p.theme] = true
		assert_eq(p.requires.size(), 3, "%s: three groups" % p.id)
		for group in p.requires:
			assert_false(group.is_empty(), "%s: a group is never empty" % p.id)
			for entry in group:
				if PsalmDef.is_gift(entry):
					assert_not_null(gifts.find(PsalmDef.entry_id(entry)), "%s: Gift %s exists" % [p.id, entry])
				else:
					assert_not_null(boons.find(StringName(entry)), "%s: Blessing or Elo %s exists" % [p.id, entry])
		assert_ne(p.slot, Boon.Slot.NONE, "%s transforms an action" % p.id)
	assert_eq(ids, APPROVED, "D-60: Sentinela (the first), Abrigo, Pastor, Rocha")
	assert_eq(themes.size(), 4, "one theme each")


# ---------- conditions ----------

func test_a_psalm_needs_one_held_thing_of_each_group() -> void:
	var p := _psalm(&"sentinela")
	assert_false(Psalms.met(p, Psalms.held_of(_held([]), [])), "nothing held")
	assert_false(Psalms.met(p, Psalms.held_of(_held(["circulo_brasa", "escudo"]), [])), "two of three")
	assert_true(Psalms.met(p, Psalms.held_of(_held(["circulo_brasa", "escudo", "bastiao"]), [])), "a Blessing, a Blessing, an Elo")
	assert_true(Psalms.met(p, Psalms.held_of(_held(["circulo_geada", "passos"]), [&"reserva"])), "a Gift equipped counts")
	assert_false(Psalms.met(p, Psalms.held_of(_held(["circulo_geada", "passos", "reserva"]), [])),
		"a Gift is only a Gift equipped (never a Blessing of the same name)")


func test_one_thing_never_answers_two_groups() -> void:
	var p := _made(&"x", &"x", [["escudo", "passos"], ["escudo"], ["dom:reserva", "vapor"]])
	assert_false(Psalms.met(p, Psalms.held_of(_held(["escudo", "vapor"]), [])), "the shield cannot fill two groups")
	assert_true(Psalms.met(p, Psalms.held_of(_held(["escudo", "passos", "vapor"]), [])), "the steps take the first group")


func test_the_draw_reads_the_held_blessings_elos_and_gifts() -> void:
	var rules := Psalms.new(_catalog())
	var held := _held(["golpe_firme", "escudo", "vapor"])
	var ids := rules.eligible(held, []).map(func(p: PsalmDef) -> StringName: return p.id)
	assert_eq(ids, [&"rocha"], "the attack's Blessing, a firm one and an Elo: the Rocha")
	ids = rules.eligible(_held(["golpe_firme", "escudo"]), [&"quarto_corte"]).map(func(p: PsalmDef) -> StringName: return p.id)
	assert_eq(ids, [&"rocha"], "or an equipped Gift in the third group")


# ---------- chances ----------

func _rate(chance: float, draws: int) -> float:
	var rules := Psalms.new(_catalog())
	var held := _held(["golpe_firme", "escudo", "vapor"])
	var rng := RandomNumberGenerator.new()
	rng.seed = 5
	var got := 0
	for i in draws:
		var cards: Array[BoonState.Card] = [BoonState.Card.new(held.find(&"brasas"))]
		rules.fill(cards, rng, chance, held, [], 1)
		if cards[0].psalm != null:
			got += 1
	return float(got) / draws


func test_a_card_is_a_psalm_one_time_in_ten_and_one_in_twenty_at_the_guardian() -> void:
	var stage: StageDef = load("res://data/stages/catacombs.tres")
	assert_almost_eq(stage.psalm_chance, 0.1, 0.0001, "10% a card")
	assert_almost_eq(stage.guardian_psalm_chance, 0.05, 0.0001, "5% at the guardian")
	assert_almost_eq(_rate(stage.psalm_chance, 10000), 0.1, 0.01, "10 thousand cards")
	assert_almost_eq(_rate(stage.guardian_psalm_chance, 10000), 0.05, 0.008, "10 thousand guardian cards")


func test_never_a_psalm_card_when_none_can_be_offered_and_the_dice_are_not_read() -> void:
	var rules := Psalms.new(_catalog())
	var rng := RandomNumberGenerator.new()
	rng.seed = 9
	var state := rng.state
	var cards: Array[BoonState.Card] = []
	for i in 1000:
		rules.fill(cards, rng, 1.0, _held(["escudo"]), [])
	assert_true(cards.is_empty(), "no Psalm without its three groups")
	assert_eq(rng.state, state, "the run's draws stay the same as before the Psalms")


func test_a_draw_of_three_shows_each_psalm_once() -> void:
	var rules := Psalms.new(_catalog())
	var held := _held(["golpe_firme", "escudo", "vapor"])
	var rng := RandomNumberGenerator.new()
	var cards := held.draw(rng, 3)
	rules.fill(cards, rng, 1.0, held, [])
	assert_eq(cards.size(), 3)
	assert_eq(cards.filter(func(c: BoonState.Card) -> bool: return c.psalm != null).size(), 1, "one Psalm can, one card")


# ---------- one per theme, two a run ----------

func test_one_psalm_per_theme() -> void:
	var a := _made(&"a", &"watch", [["escudo"]])
	var b := _made(&"b", &"watch", [["passos"]])
	var c := _made(&"c", &"rock", [["firmeza"]])
	var rules := Psalms.new([a, b, c] as Array[PsalmDef])
	var held := _held(["escudo", "passos", "firmeza"])
	assert_eq(rules.eligible(held, []).size(), 3)
	assert_true(rules.take(a))
	assert_eq(rules.eligible(held, []), [c] as Array[PsalmDef], "the other of the theme is gone, the taken one too")
	assert_false(rules.take(b), "never two of one theme")
	assert_false(rules.take(a), "never twice")


func test_two_psalms_a_run_at_most() -> void:
	var rules := Psalms.new(_catalog())
	var held := _held(["golpe_firme", "circulo_brasa", "passos", "pesado_brasa", "escudo", "firmeza", "consolo", "onda_maior",
		"vapor", "bastiao", "rastro", "aurora"])
	assert_eq(rules.eligible(held, []).size(), 4, "all four can come")
	assert_true(rules.take(rules.find(&"sentinela")))
	assert_true(rules.take(rules.find(&"rocha")))
	assert_eq(rules.eligible(held, []).size(), 0, "no third")
	assert_false(rules.take(rules.find(&"pastor")))
	assert_eq(rules.ids(), ["sentinela", "rocha"])


# ---------- the game ----------

func test_the_robot_takes_a_psalm_when_one_comes_and_the_run_logs_it() -> void:
	_run(&"")
	Dev._args["autopick"] = "1"  # the robot's way: a Psalm card is taken at once
	game.psalm_cards = true
	for id in [&"golpe_firme", &"escudo", &"vapor"]:
		game.boons.levels[id] = 1
	var offered: Array = []
	game.psalm_offered.connect(func(p: PsalmDef, first: bool) -> void: offered.append([p.id, first]))
	game.open_boon_choice(Boon.RARITY_CHANCE, 1.0)
	assert_eq(game.psalms.ids(), ["rocha"], "taken")
	assert_eq(offered, [[&"rocha", true]], "seen, and new to the Codex")
	assert_eq(game.mode, Game.Mode.PLAY, "back to the fight")
	assert_eq(game.result().psalms, ["rocha"], "RESULT psalms")
	var data := SaveData.defaults()
	assert_eq(int(game.mastery_gain("quit", data).first_psalms), HeroDef.warrior().mastery.first_psalm_xp, "a Psalm found gives its XP")
	game.award_mastery(game.mastery_gain("quit", data), "quit", data)
	assert_eq(data.codex.psalms.rocha, {"seen": 1, "taken": 1}, "the Codex")
	assert_eq(int(game.mastery_gain("quit", data).first_psalms), 0, "once")
	Dev._args.erase("autopick")


func test_a_person_gets_no_psalm_card_until_the_screen_shows_them() -> void:
	_run(&"")
	assert_eq(game.psalm_cards, Game.screen_shows_psalms(), "a person: as the screen can")
	if game.psalm_cards:
		pass_test("the screen shows Psalm cards (E4-03 is in)")
		return
	for id in [&"golpe_firme", &"escudo", &"vapor"]:
		game.boons.levels[id] = 1
	game.open_boon_choice(Boon.RARITY_CHANCE, 1.0)
	assert_true(game.offer_cards.all(func(c: BoonState.Card) -> bool: return c.psalm == null), "Blessings only")


func test_psalm_option_takes_them_from_the_start() -> void:
	Dev._args["psalm"] = "abrigo,pastor"
	_run(&"")
	Dev._args.erase("psalm")
	assert_eq(game.psalms.ids(), ["abrigo", "pastor"])


# ---------- the four effects ----------

func test_sentinela_the_circle_walks_with_him_and_strikes_each_one_coming_in_once() -> void:
	_run(&"sentinela")
	var p := game.player
	var e := _enemy(&"skeleton", Vector2(9.0, 0.0))
	p.cast_released.emit(p.pos, false)
	var circle: Ground.Zone = null
	for z in game.ground.zones:
		if z.kind == Ground.Kind.BIND:
			circle = z
	assert_not_null(circle)
	assert_true(circle.follow)
	game.ground.step(0.01)
	assert_eq(e.hp, e.max_hp, "outside: untouched")
	p.pos = Vector2(6.0, 0.0)
	game.ground.step(Ground.TICK)
	assert_eq(circle.pos, p.pos, "the circle is where he is")
	assert_almost_eq(e.max_hp - e.hp, 30.0, 0.5, "a blow of 30 as it comes in")
	assert_gt(e.stun_t, 0.0, "held (and flinched)")
	var hp := e.hp
	for k in 4:
		game.ground.step(Ground.TICK)
	assert_eq(e.hp, hp, "once a circle")


func test_without_the_sentinela_the_circle_stays_where_it_was_cast() -> void:
	_run(&"")
	var p := game.player
	p.cast_released.emit(p.pos, false)
	p.pos = Vector2(4.0, 0.0)
	game.ground.step(0.1)
	for z in game.ground.zones:
		if z.kind == Ground.Kind.BIND:
			assert_eq(z.pos, Vector2.ZERO)
			assert_false(z.follow)


func _dodge_ends() -> void:
	game.player.state = Player.State.DODGE
	game.psalm_play.step(0.01)
	game.player.state = Player.State.MOVE
	game.psalm_play.step(0.01)


func _shot_dies(kind: Projectiles.Kind) -> bool:
	var s := game.projectiles.fire(kind, Vector2(8.0, 0.0), Vector2.LEFT, 10.0, 3.0)
	for i in 60:
		game.player.invuln = 10.0
		game.projectiles.step(1.0 / 60.0)
		if not game.projectiles.shots.has(s):
			return s.pos.x > 2.0
	return false


func test_abrigo_the_dodge_leaves_a_shelter_that_undoes_enemy_shots() -> void:
	_run(&"abrigo")
	var psalm := game.psalms.find(&"abrigo")
	_dodge_ends()
	assert_eq(game.psalms.shelters.size(), 1, "a shelter where the dodge ended")
	assert_eq(game.ground.zones.filter(func(z: Ground.Zone) -> bool: return z.kind == Ground.Kind.SHELTER).size(), 1, "drawn")
	var blocked := game.projectiles.blocked
	assert_true(_shot_dies(Projectiles.Kind.BOLT), "a bolt is undone at its edge")
	assert_true(_shot_dies(Projectiles.Kind.ORB), "an orb too")
	assert_eq(game.projectiles.blocked, blocked + 2)
	assert_false(_shot_dies(Projectiles.Kind.SOUL), "never Morvath's crescent (the stone does not stop it either)")
	for k in 3:
		_dodge_ends()
	assert_eq(game.psalms.shelters.size(), psalm.count, "two at most")
	game.psalm_play.step(psalm.duration + 0.1)
	assert_eq(game.psalms.shelters.size(), 0, "they last %s s" % psalm.duration)


func test_without_the_abrigo_the_dodge_leaves_nothing() -> void:
	_run(&"")
	_dodge_ends()
	assert_eq(game.psalms.shelters.size(), 0)
	assert_false(_shot_dies(Projectiles.Kind.BOLT))


func _waves() -> int:
	return game.projectiles.shots.filter(func(s: Projectiles.Shot) -> bool: return not Projectiles.hostile(s)).size()


func test_pastor_kills_gather_lights_the_special_throws_as_more_waves() -> void:
	_run(&"pastor")
	var psalm := game.psalms.find(&"pastor")
	for k in 5:
		var e := _enemy(&"skeleton", Vector2(-6.0, k * 1.5))
		game.horde.damage(e, 9999.0, Vector2.LEFT, 0.0)
	assert_eq(game.psalms.lights, psalm.count, "five kills, three lights at most")
	var bolt := _move(&"bolt")
	game.player.struck.emit(bolt, game.player.pos, Vector2.RIGHT)
	assert_eq(_waves(), 1 + psalm.count, "the special's wave and one more for each light")
	assert_eq(game.psalms.lights, 0, "the lights went with them")
	var dirs: Array = game.projectiles.shots.map(func(s: Projectiles.Shot) -> float: return rad_to_deg(s.vel.angle()))
	dirs.sort()
	assert_almost_eq(dirs[0], -psalm.spread, 0.5, "fanned")
	assert_almost_eq(dirs[dirs.size() - 1], psalm.spread * 2.0 if psalm.count > 2 else psalm.spread, 0.5)
	game.projectiles.clear_hostile()
	for s in game.projectiles.shots.duplicate():
		game.projectiles._release(s)
	game.projectiles.shots.clear()
	game.player.struck.emit(bolt, game.player.pos, Vector2.RIGHT)
	assert_eq(_waves(), 1, "no light: the special of before")
	assert_eq(Psalms.fan(Vector2.RIGHT, 0, 14.0).size(), 0)


func test_rocha_the_spin_plants_a_stone_that_stuns_the_common_ones() -> void:
	_run(&"rocha")
	var psalm := game.psalms.find(&"rocha")
	var spin := _move(&"cut3")
	var near := _enemy(&"skeleton", Vector2(3.8, 0.0))
	var elite := _enemy(&"skeleton_elite", Vector2(-3.8, 0.0))
	var far := _enemy(&"skeleton", Vector2(0.0, 6.0))
	assert_gt(near.pos.length(), spin.reach + 0.3, "past the spin's own reach")
	game.player.struck.emit(spin, game.player.pos, Vector2.RIGHT)
	assert_almost_eq(near.max_hp - near.hp, psalm.damage, 0.5, "the stone's blow")
	assert_gte(near.stun_t, psalm.stun - 0.01, "stunned")
	assert_eq(elite.stun_t, 0.0, "armor takes the blow, no stun")
	assert_lt(elite.armor, elite.def.armor, "the armor took it")
	assert_eq(far.hp, far.max_hp, "out of the stone's reach")
	var stones := func() -> int: return game.ground.zones.filter(func(z: Ground.Zone) -> bool: return z.kind == Ground.Kind.STONE).size()
	assert_eq(stones.call(), 1, "it stays on the floor")
	var hp := near.hp
	game.player.struck.emit(spin, game.player.pos, Vector2.RIGHT)
	assert_eq(stones.call(), 1, "no other stone while one stands")
	assert_eq(near.hp, hp, "and no second blow")
	game.psalm_play.step(psalm.duration + 0.05)
	game.player.struck.emit(spin, game.player.pos, Vector2.RIGHT)
	assert_lt(near.hp, hp, "a stone again once the first is gone")


func test_without_the_rocha_the_spin_is_the_one_of_before() -> void:
	_run(&"")
	var e := _enemy(&"skeleton", Vector2(3.8, 0.0))
	game.player.struck.emit(_move(&"cut3"), game.player.pos, Vector2.RIGHT)
	assert_eq(e.hp, e.max_hp)


# ---------- the text (D-59 (a)) ----------

## Phrases of the psalms behind the themes, in the usual Portuguese translations: none may be quoted.
const VERSES: Array[String] = ["meu pastor", "nada me faltará", "pastos verdejantes", "águas tranquilas", "vale da sombra",
	"não dormirá", "não dormitará", "levanto os meus olhos", "elevo os olhos", "o socorro", "rochedo", "minha rocha",
	"meu refúgio", "minha fortaleza", "esconderijo", "sombra do onipotente", "sob as suas asas", "seta que voa",
	"teu cajado", "tua vara", "unges", "cálice"]


func test_psalm_texts_name_a_theme_with_no_number_and_no_verse() -> void:
	var table: TextTable = load("res://data/text_pt.tres")
	var found := 0
	for key: String in table.entries:
		if not key.begins_with("psalm_"):
			continue
		found += 1
		var text := String(table.entries[key])
		var plain := text.to_lower()
		assert_false(RegEx.create_from_string("\\d").search(text) != null, "%s: no number (no psalm's number, numbers come from data)" % key)
		assert_false(text.contains("—") or text.contains("–"), "%s: no dash" % key)
		assert_false(text.contains("“") or text.contains("\""), "%s: nothing quoted" % key)
		for v in VERSES:
			assert_false(plain.contains(v), "%s quotes \"%s\"" % [key, v])
	assert_gt(found, 0)
	for p in _catalog():
		for k in [p.name_key, p.desc_key, p.hint_key, p.line_key]:
			assert_true(table.entries.has(String(k)), "%s has %s" % [p.id, k])
		var desc := T.t(p.desc_key, p.text_args())
		assert_false(desc.contains("{"), "%s: every number of its text is filled: %s" % [p.id, desc])
