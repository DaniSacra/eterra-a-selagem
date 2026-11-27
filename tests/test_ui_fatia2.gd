extends GutTest
## Rejogabilidade, Fatia 2, the interface (sistemas.md 5.3 "Fatia 2"): the Encanto's cards in the gift screen's page,
## the marks of the Encanto, the Salmo and the Esmeralda, the angel on a Blessing's door, the Forja with Temperar III and
## the Refinar (one choice on each action, the tool), the Esmeralda in the purse and in "Trazidos".


func _data(silver := 0, tool := false) -> Dictionary:
	var d := SaveData.defaults()
	MaterialPurse.give(d, MaterialPurse.SILVER, silver)
	if tool:
		Forge.add_tool(d, Forge.TOOL_REFINE)
	return d


func _labels(n: Node) -> PackedStringArray:
	var out := PackedStringArray()
	for c in n.find_children("*", "Label", true, false):
		out.append((c as Label).text)
	for c in n.find_children("*", "RichTextLabel", true, false):
		out.append((c as RichTextLabel).get_parsed_text())
	return out


# ---------- the marks ----------

func test_the_new_rewards_and_the_emerald_have_marks() -> void:
	assert_eq(DoorGlyph.of_reward(RunMap.Reward.ENCHANT), DoorGlyph.Kind.ENCHANT)
	assert_eq(DoorGlyph.of_reward(RunMap.Reward.PSALM), DoorGlyph.Kind.PSALM)
	assert_eq(DoorGlyph.of_material(MaterialPurse.EMERALD), DoorGlyph.Kind.EMERALD)
	for k in [DoorGlyph.Kind.ENCHANT, DoorGlyph.Kind.PSALM, DoorGlyph.Kind.EMERALD]:
		var g: DoorGlyph = autofree(DoorGlyph.new().setup(k, 24.0))
		add_child(g)
	await wait_process_frames(2)


# ---------- the Encanto's choice ----------

func test_the_encanto_cards_say_what_changes_and_no_rarity() -> void:
	var s := EnchantChoice.new()
	add_child_autofree(s)
	var all := Enchants.load_catalog()
	s.open_enchants(all)
	await wait_process_frames(2)
	assert_eq(s.cards().size(), all.size())
	for i in all.size():
		var c := s.cards()[i]
		var texts := _labels(c)
		assert_true(texts.has(T.t(all[i].name_key)), "its name")
		assert_true(texts.has(T.t(&"enchant_changes", {"action": T.t(Boon.SLOT_KEY[all[i].slot])})), "the action it changes")
		assert_true(texts.has(T.t(&"enchant_lasts")))
		assert_not_null(c.find_child("EnchantTab", false, false), "the tab Encanto")
		for r in Boon.RARITY_KEY:
			assert_false(texts.has(T.t(r)), "no rarity on an Encanto")
		var desc := c.find_child("Desc", true, false) as RichTextLabel
		assert_true(desc.text.contains("[b]"), "its numbers marked")
	assert_true(s.cards()[0].has_focus(), "the first in focus")


func test_the_game_opens_the_encanto_cards_and_takes_one() -> void:
	var game: Game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	game.rooms.start_at(RunMap.Kind.COMBAT)
	game.horde.clear_crowd()
	await wait_process_frames(2)
	game.open_enchant_choice()
	var s := game._screen as EnchantChoice
	assert_not_null(s, "the Encanto's cards, not the provisional list")
	assert_eq(s.cards().size(), game.enchant_options.size())
	var first := game.enchant_options[0]
	s._opened_at -= BoonChoice.GUARD_MS
	s.cards()[0].pressed.emit()
	assert_eq(game.boons.enchants, [first] as Array[EnchantDef])
	assert_eq(game.mode, Game.Mode.PLAY)


# ---------- the angel on the door ----------

func test_a_door_names_its_angel_with_its_seal() -> void:
	var a := Encounter.new(Encounter.load_catalog()).catalog[0]
	var name_text := T.t(StringName("angel_" + String(a.id)))
	var sign := DoorSign.make(T.t(&"reward_boon"), name_text + "\n" + T.t(&"door_hard"), DoorGlyph.Kind.HARD, DoorGlyph.Kind.BLESSING)
	add_child_autofree(sign)
	sign.show_angel(name_text, a)
	assert_eq(sign.detail.text, T.t(&"door_hard"), "the angel out of the detail")
	assert_not_null(sign.angel_row.find_children("*", "AngelSeal", true, false).front(), "its seal")
	assert_eq(sign._box.get_child(1), sign.angel_row, "right under the reward")
	assert_eq((sign.angel_row.find_child("angel_name", false, false) as Label).text, T.t(&"door_angel_sign", {"name": name_text}), "PT-27a: 'Anjo ...'")
	var two := DoorSign.make(T.t(&"reward_boon"), T.t(&"door_angels_two"), DoorGlyph.Kind.NONE, DoorGlyph.Kind.BLESSING)
	add_child_autofree(two)
	two.show_angel(T.t(&"door_angels_two"), null)
	assert_not_null(two.angel_row.find_child("two", false, false), "two seals for a meeting")
	assert_false(two.detail.visible, "nothing left in the detail")


func test_the_rooms_put_the_angel_on_blessing_doors() -> void:
	var game: Game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	add_child_autofree(game)
	game.rooms.start_at(RunMap.Kind.COMBAT)
	game.horde.clear_crowd()
	game.rooms._open_doors()
	await wait_process_frames(2)
	var with_angel := 0
	for i in game.rooms.next_rooms.size():
		var r := game.rooms.next_rooms[i]
		var sign := game.rooms._door_labels[i].find_child("DoorSign", false, false) as DoorSign
		if sign == null:
			continue
		var wants := r.reward == RunMap.Reward.BOON and (r.meeting or r.angel != &"")
		assert_eq(sign.angel_row != null, wants, "door %d" % i)
		if wants:
			with_angel += 1
	gut.p("doors with an angel: %d" % with_angel)


# ---------- the Forja ----------

func _forge(d: Dictionary) -> ForgeScreen:
	var f := ForgeScreen.new()
	add_child_autofree(f)
	f.open(d)
	return f


## Three presses: the three strikes of the hammer.
func _hammer(f: ForgeScreen) -> void:
	for k in 3:
		f.press()
		f.release()


func test_the_forge_offers_temper_three_and_the_refine_choices() -> void:
	var f := _forge(_data(100, true))
	f.focus_mark(&"temper")
	assert_eq(f.infos.size(), 3, "Temperar I to III")
	assert_eq(f.infos[2].id, &"temper_3")
	f.focus_mark(&"attack")
	assert_eq(f.infos.size(), 3, "three choices on the Ataque")
	f.focus_mark(&"special")
	assert_eq(f.infos.size(), 3, "and three on the Especial")


func test_without_the_tool_the_refine_waits() -> void:
	var f := _forge(_data(100))
	f.focus_mark(&"attack")
	var fio := f.forge.find(&"refine_fio")
	assert_eq(f.shown, fio)
	assert_eq(f.info.look, ForgeInfo.Look.NO_TOOL)
	assert_eq(f.info.action, ForgeInfo.Action.NONE)
	assert_eq((f.find_child("state", true, false) as Label).text, T.t(&"forge_state_no_tool"))
	assert_eq((f.find_child("step", true, false) as Label).text, T.t(&"forge_no_tool"))
	assert_true(f.bench.sealed[&"attack"], "the cloth with the lock over the guard")
	var silver := MaterialPurse.amount(f._data, MaterialPurse.SILVER)
	_hammer(f)
	assert_eq(MaterialPurse.amount(f._data, MaterialPurse.SILVER), silver, "nothing to hammer")


func test_refine_buys_puts_on_and_changes_for_free() -> void:
	var d := _data(200, true)
	var f := _forge(d)
	var fio := f.forge.find(&"refine_fio")
	var peso := f.forge.find(&"refine_peso")
	f.focus_mark(&"attack")
	f.focus_chip(0)
	assert_eq(f.shown, fio)
	assert_eq(f.info.action, ForgeInfo.Action.HAMMER)
	_hammer(f)
	assert_true(f.forge.is_on(d, fio), "the first on its action goes on")
	assert_eq(f.info.look, ForgeInfo.Look.ON)
	assert_eq(f.info.action, ForgeInfo.Action.NONE)
	assert_eq(f.bench.rings[&"attack"], "F", "the ring of the guard carries its letter")
	f.focus_chip(1)
	_hammer(f)
	assert_true(f.forge.is_on(d, fio), "the second is kept, the first stays on")
	assert_eq(f.info.look, ForgeInfo.Look.STORED)
	assert_eq(f.info.action, ForgeInfo.Action.USE)
	assert_eq(f.info.detail, T.t(&"forge_instead", {"name": T.t(fio.name_key)}))
	var silver := MaterialPurse.amount(d, MaterialPurse.SILVER)
	f.press()
	f.release()
	assert_true(f.forge.is_on(d, peso), "Usar puts it on in one press")
	assert_false(f.forge.is_on(d, fio))
	assert_eq(MaterialPurse.amount(d, MaterialPurse.SILVER), silver, "for free")


func test_the_forge_fits_720_lines() -> void:
	var box := Control.new()
	box.size = Vector2(1280, 720)
	add_child_autofree(box)
	var f := ForgeScreen.new()
	box.add_child(f)
	f.open(_data(100, true))
	await wait_process_frames(3)
	var stage := Rect2(f._stage.global_position, ForgeScreen.STAGE)
	for c: Control in [f.plate, f.bench.emeth]:
		assert_true(stage.encloses(c.get_global_rect()), "%s inside the 1280 x 720 stage" % c.name)
	var bar := f.find_child("action_bar", true, false) as Control
	assert_lt(f.plate.get_global_rect().end.y, bar.get_global_rect().position.y + 1.0, "the plate over the action bar")
	assert_lt(f.chips.back().get_global_rect().end.y, f.plate.get_global_rect().position.y, "the strip over the plate")


# ---------- the Esmeralda ----------

func test_the_purse_shows_the_emerald_once_there_is_one() -> void:
	var d := _data(5)
	assert_eq(MaterialCount.shown(d).size(), 2, "Prata and Memória")
	MaterialPurse.give(d, MaterialPurse.EMERALD, 1)
	assert_true(MaterialCount.shown(d).has(MaterialPurse.EMERALD))
	var row: HBoxContainer = autofree(MaterialCount.purse(d))
	assert_eq(row.get_child_count(), 3)


func _hue_gap(a: float, b: float) -> float:
	var d := absf(fposmod(a, 360.0) - fposmod(b, 360.0))
	return minf(d, 360.0 - d)


func test_the_medallions_of_encanto_and_salmo_have_their_marks() -> void:
	var none := RunMap.Kind.COMBAT
	assert_eq(RewardGem.mark_of(RunMap.Reward.ENCHANT, none), RewardGem.Mark.ENCHANT)
	assert_eq(RewardGem.mark_of(RunMap.Reward.PSALM, none), RewardGem.Mark.PSALM)
	var mat := RewardGem.face_material(RunMap.Reward.PSALM, none)
	assert_eq(int(mat.get_shader_parameter(&"mark")), RewardGem.Mark.PSALM)
	# each its own enamel, under the cap, the Psalm's lilac apart from the Trial's and the Encanto's green from the Blessing's petrol
	var e := RewardGem.family(RunMap.Reward.ENCHANT, none)
	var p := RewardGem.family(RunMap.Reward.PSALM, none)
	assert_gt(_hue_gap(p.x, RewardGem.ENAMEL_TRIAL.x), 20.0)
	assert_gt(_hue_gap(e.x, RewardGem.ENAMEL_BLESSING.x), 20.0)
	for f: Vector3 in [e, p]:
		assert_true(f.y <= RewardGem.ENAMEL_MAX.x and f.z <= RewardGem.ENAMEL_MAX.y)


func test_the_screens_take_the_family_colours_from_the_boon() -> void:
	# Vigília in sage: far from the danger red, the Emeth's emerald and the hero's petrol, and the screens read it
	var vigil := Boon.FAMILY_COLOR[Boon.Family.VIGILIA]
	var h := vigil.h * 360.0
	assert_between(h, 60.0, 110.0)
	assert_gt(_hue_gap(h, 0.0), 20.0)
	assert_gt(_hue_gap(h, 150.0), 20.0)
	assert_gt(_hue_gap(h, 186.0), 20.0)
	var b: Boon = null
	for f in DirAccess.get_files_at("res://data/boons"):
		if f.ends_with(".tres"):
			var x := load("res://data/boons/" + f) as Boon
			if x.family == Boon.Family.VIGILIA:
				b = x
				break
	assert_not_null(b)
	assert_eq(b.color(), vigil)
	# the cards' glow, the HUD's gem, the icons and the Compêndio read Boon.color(); the angel's seal is the calmer sage
	var seal := AngelSeal.tint(Boon.Family.VIGILIA).h * 360.0
	assert_lt(_hue_gap(seal, h), 25.0)
