extends GutTest
## The gift screen ("Um dom chega até você"): painted medallions by gift id in any position, an Elo with its two
## source medallions, a gift without a painting on its drawn icon, the rarity edge apart from the focus line, the rest
## card and the guard against a press held from the fight.

var state: BoonState


func before_each() -> void:
	state = BoonState.new(BoonState.load_catalog())


func _open(ids: Array[StringName], rarities: Dictionary = {}) -> BoonChoice:
	var offers: Array[Boon] = []
	for id in ids:
		offers.append(state.find(id))
	var choice := BoonChoice.new()
	add_child_autofree(choice)
	choice.open(offers, state, rarities)
	return choice


## The painted texture a card shows (on its own or in the middle of an Elo's chain), or null.
func _art(card: BoonCard) -> Texture2D:
	if card.crest is TextureRect:
		return (card.crest as TextureRect).texture
	if card.crest is EloLink and (card.crest as EloLink).main_art():
		return (card.crest as EloLink).main_art().texture
	return null


func test_the_three_painted_gifts_have_their_medallion() -> void:
	for id in [&"vapor", &"aurora", &"redemoinho"]:
		var tex := BoonArt.medallion(id)
		assert_not_null(tex, String(id))
		assert_eq(tex.get_width(), tex.get_height(), "square")
		assert_gte(tex.get_width(), 256, "sharp at 1080 lines")


func test_the_medallion_follows_the_gift_in_any_position() -> void:
	var orders: Array = [[&"vapor", &"aurora", &"redemoinho"], [&"redemoinho", &"vapor", &"aurora"], [&"aurora", &"redemoinho", &"vapor"]]
	for order in orders:
		var ids: Array[StringName] = []
		ids.assign(order)
		var cards := _open(ids).cards()
		for i in cards.size():
			assert_eq(cards[i].boon.id, ids[i])
			assert_eq(_art(cards[i]), BoonArt.medallion(ids[i]), "%s at %d" % [ids[i], i])


func test_an_elo_hangs_between_its_two_sources() -> void:
	var cards := _open([&"vapor", &"aurora", &"redemoinho"]).cards()
	var expect := {&"vapor": [&"brasas", &"toque_geada"], &"aurora": [&"onda_maior", &"toque_geada"]}
	for card in cards:
		if not expect.has(card.boon.id):
			assert_true(card.crest is TextureRect, "Redemoinho: the medallion alone")
			continue
		assert_true(card.crest is EloLink, String(card.boon.id))
		var link := card.crest as EloLink
		assert_null(link.main_icon(), "the painted rim is the only rim (no drawn medallion with its own chain)")
		var src := link.source_icons()
		assert_eq(src.size(), 2)
		assert_eq(src[0].boon.id, expect[card.boon.id][0])
		assert_eq(src[1].boon.id, expect[card.boon.id][1])


func test_a_gift_without_a_painting_keeps_its_drawn_icon() -> void:
	assert_null(BoonArt.medallion(&"brasas"))
	var cards := _open([&"brasas", &"chama_viva", &"golpe_brasa"]).cards()
	assert_true(cards[0].crest is BoonIcon)
	assert_eq((cards[0].crest as BoonIcon).boon.id, &"brasas")
	assert_true(cards[1].crest is EloLink, "an Elo without a painting: the drawn Elo")
	assert_not_null((cards[1].crest as EloLink).main_icon())
	assert_eq((cards[1].crest as EloLink).source_icons().size(), 2)
	assert_true(cards[2].crest is BoonIcon)


func test_the_rarity_edge_does_not_change_with_focus() -> void:
	var choice := _open([&"vapor", &"aurora", &"redemoinho"], {&"vapor": Boon.Rarity.EPIC, &"redemoinho": Boon.Rarity.RARE})
	var cards := choice.cards()
	var before: Array[Color] = []
	for c in cards:
		before.append(c.edge_color())
	assert_eq(before[0], Boon.RARITY_COLOR[Boon.Rarity.EPIC])
	assert_eq(before[1], BoonCard.COMMON_EDGE, "common keeps the old metal")
	assert_eq(before[2], Boon.RARITY_COLOR[Boon.Rarity.RARE])
	for i in cards.size():
		cards[i].grab_focus()
		for k in cards.size():
			assert_eq(cards[k].edge_color(), before[k], "edge of %d with %d in focus" % [k, i])
			assert_eq(cards[k].focus_lit(), k == i)
	assert_ne(BoonCard.FOCUS_COLOR, Boon.RARITY_COLOR[Boon.Rarity.COMMON], "the focus line is its own colour")


func test_long_text_and_replacement_fit_the_card() -> void:
	state.take(state.find(&"toque_geada"))
	var cards := _open([&"estilhaco", &"firmeza", &"pesado_firme"]).cards()
	await wait_physics_frames(2)
	var warn := cards[2].find_child("Replaces", true, false) as Label
	assert_not_null(warn, "the replaced gift is named")
	assert_true(warn.text.contains(T.t(&"boon_toque_geada")))
	for c in cards:
		assert_lte(c.size.y, BoonCard.SIZE.y + 1.0, "%s grows past the card" % c.boon.id)


func test_rest_card_heals_with_null() -> void:
	var choice := _open([])
	assert_eq(choice.cards().size(), 1)
	assert_null(choice.cards()[0].boon)
	watch_signals(choice)
	choice._opened_at -= BoonChoice.GUARD_MS + 100
	choice.cards()[0].pressed.emit()
	assert_signal_emitted_with_parameters(choice, "chosen", [null])


func test_a_press_right_after_opening_picks_nothing() -> void:
	var choice := _open([&"vapor", &"aurora", &"redemoinho"])
	watch_signals(choice)
	choice.cards()[1].pressed.emit()
	assert_signal_not_emitted(choice, "chosen", "a button held from the fight")
	choice._opened_at -= BoonChoice.GUARD_MS + 100
	choice.cards()[1].pressed.emit()
	assert_signal_emitted_with_parameters(choice, "chosen", [state.find(&"aurora")])
