extends GutTest
## E3 interface: the card's frame for each rarity (E3-06, heroic in old gold), the Elo without rarity or level
## (BUG-017 on the card), the exchange one rarity up read defensively from the offer (E3-01), the "Bênção nova"
## greeting that never stops the game (E3-04, EloBanner), the Compendium's Bênçãos and Elos tabs (E3-03) and the shop
## signs for the three groups and the healing (C13-04).

var state: BoonState


func before_each() -> void:
	state = BoonState.new(BoonState.load_catalog())


func _open(ids: Array[StringName], rarities: Dictionary = {}, upgrades: Dictionary = {}) -> BoonChoice:
	var offers: Array[Boon] = []
	for id in ids:
		offers.append(state.find(id))
	var choice := BoonChoice.new()
	add_child_autofree(choice)
	choice.open(offers, state, rarities, upgrades)
	return choice


# ---------- E3-06: a frame for each rarity ----------

func test_each_rarity_has_its_own_frame() -> void:
	var seen := {}
	for r in [Boon.Rarity.COMMON, Boon.Rarity.RARE, Boon.Rarity.EPIC, Boon.Rarity.HEROIC]:
		var card := BoonCard.new()
		add_child_autofree(card)
		card.setup(state.find(&"brasas"), r, 0, [], null, "x")
		var key := "%s/%d" % [card.edge_color().to_html(), card.edge_lines()]
		assert_false(seen.has(key), "rarity %d looks like another" % r)
		seen[key] = true
	assert_eq(BoonCard.RARITY_LINES[Boon.Rarity.COMMON], 1)
	assert_eq(BoonCard.RARITY_LINES[Boon.Rarity.HEROIC], 2, "heroic is doubled")


func test_heroic_is_old_gold_never_bright_yellow() -> void:
	var c := BoonCard.rarity_color(Boon.Rarity.HEROIC)
	assert_between(c.h * 360.0, 30.0, 48.0, "a gold hue")
	assert_lt(c.s, 0.6, "old: not saturated")
	assert_lt(c.v, 0.9, "old: not bright")
	# the game's heroic colour is red; the card never shows it
	assert_ne(c, Boon.RARITY_COLOR[Boon.Rarity.HEROIC])


func test_the_rarity_word_takes_the_card_colour() -> void:
	var cards := _open([&"brasas"], {&"brasas": Boon.Rarity.HEROIC}).cards()
	var rar := cards[0].find_child("Rarity", true, false) as Label
	assert_eq(rar.text, T.t(&"rarity_heroic"))
	assert_eq(rar.get_theme_color(&"font_color"), BoonCard.rarity_color(Boon.Rarity.HEROIC).lightened(0.12))


# ---------- BUG-017 on the card: an Elo has neither rarity nor level ----------

func test_an_elo_shows_no_rarity_and_no_level() -> void:
	var choice := _open([&"vapor", &"aurora", &"brasas"], {&"vapor": Boon.Rarity.EPIC, &"aurora": Boon.Rarity.HEROIC})
	for card in choice.cards():
		var is_elo := card.boon.is_duo()
		assert_eq(card.elo, is_elo, String(card.boon.id))
		assert_eq(card.find_child("Rarity", true, false) == null, is_elo, "rarity on %s" % card.boon.id)
		assert_eq(card.find_child("Level", true, false) == null, is_elo, "level on %s" % card.boon.id)
		if is_elo:
			assert_eq(card.rarity, Boon.Rarity.COMMON)
			assert_eq(card.edge_color(), BoonCard.ELO_EDGE, "the chain's metal, not a rarity")
			assert_eq(choice.card_rarity(card.boon, state), Boon.Rarity.COMMON)


func test_an_elo_is_never_an_exchange() -> void:
	var choice := _open([&"vapor"], {&"vapor": {"rarity": Boon.Rarity.EPIC, "upgrade": true}})
	assert_false(choice.cards()[0].upgrade)
	assert_null(choice.cards()[0].find_child("UpgradeTab", true, false))


# ---------- E3-01: the exchange one rarity up ----------

func test_offer_is_read_defensively() -> void:
	assert_eq(BoonChoice.offer_of(null), {"rarity": Boon.Rarity.COMMON, "upgrade": false})
	assert_eq(BoonChoice.offer_of(2), {"rarity": Boon.Rarity.EPIC, "upgrade": false})
	assert_eq(BoonChoice.offer_of({"rarity": 3}), {"rarity": Boon.Rarity.HEROIC, "upgrade": false})
	assert_eq(BoonChoice.offer_of({"upgrade": true}), {"rarity": Boon.Rarity.COMMON, "upgrade": true})
	assert_eq(BoonChoice.offer_of({"rarity": 9, "upgrade": 1}).rarity, Boon.Rarity.HEROIC, "clamped")


func test_an_exchange_wears_the_tab_and_names_the_trade() -> void:
	state.take(state.find(&"golpe_brasa"), Boon.Rarity.RARE)
	var cards := _open([&"golpe_geada", &"brasas"], {&"golpe_geada": {"rarity": Boon.Rarity.EPIC, "upgrade": true}}).cards()
	var swap := cards[0]
	assert_true(swap.upgrade)
	assert_eq(swap.rarity, Boon.Rarity.EPIC)
	var tab := swap.find_child("UpgradeTab", true, false)
	assert_not_null(tab)
	assert_eq((tab.find_child("UpgradeLabel", true, false) as Label).text, T.t(&"choice_upgrade"))
	var line := swap.find_child("Replaces", true, false) as Label
	assert_eq(line.text, T.t(&"choice_upgrade_swap", {"name": T.t(&"boon_golpe_brasa"), "from": T.t(&"rarity_rare"), "to": T.t(&"rarity_epic")}))
	assert_eq((swap.find_child("Level", true, false) as Label).text, T.t(&"choice_level", {"n": 1, "max": swap.boon.max_level}), "keeps the level")
	assert_false(cards[1].upgrade)
	assert_null(cards[1].find_child("UpgradeTab", true, false))


func test_an_exchange_can_come_apart_from_the_rarities() -> void:
	state.take(state.find(&"golpe_brasa"))
	var cards := _open([&"golpe_geada"], {&"golpe_geada": Boon.Rarity.RARE}, {&"golpe_geada": true}).cards()
	assert_true(cards[0].upgrade)
	assert_eq(cards[0].rarity, Boon.Rarity.RARE)


func test_plain_rarities_still_work() -> void:
	var cards := _open([&"brasas"], {&"brasas": Boon.Rarity.RARE}).cards()
	assert_eq(cards[0].rarity, Boon.Rarity.RARE)
	assert_false(cards[0].upgrade)


func test_cards_with_tab_fit() -> void:
	state.take(state.find(&"golpe_brasa"), Boon.Rarity.EPIC)
	var cards := _open([&"golpe_geada", &"vapor", &"estilhaco"], {&"golpe_geada": {"rarity": Boon.Rarity.HEROIC, "upgrade": true}}).cards()
	await wait_physics_frames(2)
	for c in cards:
		assert_lte(c.size.y, BoonCard.SIZE.y + 1.0, "%s grows past the card" % c.boon.id)
		assert_lte(c.size.x, BoonCard.SIZE.x + 1.0)


# ---------- E3-04: "Bênção nova" ----------

func test_fresh_boons_skip_elos_greeted_and_known() -> void:
	var owned: Array[Boon] = [state.find(&"brasas"), state.find(&"toque_geada"), state.find(&"vapor"), state.find(&"escudo")]
	var fresh := EloBanner.fresh_boons(owned, {&"escudo": true}, {"toque_geada": {"seen": 2}})
	assert_eq(fresh.size(), 1)
	assert_eq(fresh[0].id, &"brasas")


func test_greetings_queue_and_never_pause() -> void:
	var banner := EloBanner.new()
	add_child_autofree(banner)
	banner.process_mode = Node.PROCESS_MODE_INHERIT
	banner.show_boon(state.find(&"brasas"))
	assert_true(banner.visible)
	assert_eq(banner.showing, &"boon")
	assert_eq((banner.get_child(0) as Label).text, T.t(&"boon_new_title"))
	var vapor := state.find(&"vapor")
	banner.show_elo(vapor, state.sources(vapor))
	assert_eq(banner.showing, &"boon", "the Elo waits its turn")
	assert_eq(banner.waiting(), 1)
	assert_false(get_tree().paused, "never stops the game")
	banner._process(EloBanner.TIME + 0.01)
	assert_eq(banner.showing, &"elo")
	assert_eq(banner.waiting(), 0)
	banner._process(EloBanner.TIME + 0.01)
	assert_false(banner.visible)


func test_greeting_queue_is_short() -> void:
	var banner := EloBanner.new()
	add_child_autofree(banner)
	for id in [&"brasas", &"toque_geada", &"escudo", &"passos", &"consolo", &"onda_maior"]:
		banner.show_boon(state.find(id))
	assert_eq(banner.waiting(), EloBanner.QUEUE_MAX)


# ---------- E3-03: the Compendium ----------

func _codex_data() -> Dictionary:
	var d := SaveData.defaults()
	d.codex.boons["brasas"] = {"seen": 3}
	d.codex.boons["toque_geada"] = {"seen": 1}
	d.codex.boons["onda_maior"] = {"seen": 1}
	d.codex.elos["vapor"] = {"formed": 2}
	return d


func _codex(t: CodexScreen.Tab) -> CodexScreen:
	var c := CodexScreen.new()
	add_child_autofree(c)
	c.open(t, _codex_data())
	return c


func test_codex_has_four_tabs_in_order() -> void:
	var c := _codex(CodexScreen.Tab.GIFTS)
	assert_eq(c.tabs.size(), 4)
	assert_eq(c.tabs[CodexScreen.Tab.BOONS].text, T.t(&"codex_tab_boons"))
	assert_eq(c.tabs[CodexScreen.Tab.ELOS].text, T.t(&"codex_tab_elos"))
	assert_eq(c.tabs[CodexScreen.Tab.MOVES].text, T.t(&"codex_tab_moves"))
	c.tabs[CodexScreen.Tab.ELOS].grab_focus()
	assert_eq(c.tab, CodexScreen.Tab.ELOS)


func test_codex_blessings_met_and_unknown() -> void:
	var c := _codex(CodexScreen.Tab.BOONS)
	var met := c.find_child("brasas", true, false)
	assert_eq((met.find_child("Name", true, false) as Label).text, T.t(&"boon_brasas"))
	assert_eq((met.find_child("Times", true, false) as Label).text, T.t(&"codex_times", {"n": 3}))
	var unknown := c.find_child("estilhaco", true, false)
	assert_eq((unknown.find_child("Name", true, false) as Label).text, "???")
	assert_eq((unknown.find_child("Times", true, false) as Label).text, "")
	assert_null(c.find_child("vapor", true, false), "no Elo among the Blessings")
	var total := c.catalog(false).size()
	assert_eq(c._legend.text, T.t(&"codex_boons_legend", {"n": 3, "total": total}))


func test_codex_elos_formed_hinted_and_unknown() -> void:
	var c := _codex(CodexScreen.Tab.ELOS)
	var formed := c.find_child("vapor", true, false)
	assert_eq((formed.find_child("Name", true, false) as Label).text, T.t(&"boon_vapor"))
	# Aurora Gelada: both its Blessings were met, so the recipe shows, never the name
	var hinted := c.find_child("aurora", true, false)
	assert_eq((hinted.find_child("Name", true, false) as Label).text, "???")
	assert_eq((hinted.find_child("Recipe", true, false) as Label).text, EloLink.caption(state.sources(state.find(&"aurora"))))
	for b in c.catalog(true):
		assert_true(b.is_duo())
		if b.id in [&"vapor", &"aurora"]:
			continue
		var row := c.find_child(String(b.id), true, false)
		var srcs := state.sources(b)
		var both := srcs.all(func(s: Boon) -> bool: return _codex_data().codex.boons.has(String(s.id)))
		if not both:
			assert_eq((row.find_child("Recipe", true, false) as Label).text, "???", String(b.id))
	assert_eq(c._legend.text, T.t(&"codex_elos_legend", {"n": 1, "total": c.catalog(true).size()}))


func test_codex_fits_720_lines() -> void:
	for t in [CodexScreen.Tab.BOONS, CodexScreen.Tab.ELOS]:
		var c := _codex(t)
		await wait_physics_frames(2)
		var v := c.get_child(c.get_child_count() - 1) as Control
		assert_lte(v.get_combined_minimum_size().y, 720.0, "tab %d taller than the screen" % t)


# ---------- C13-04: the shop signs ----------

func test_shop_sign_has_group_name_and_price() -> void:
	var s := DoorSign.shop(T.t(&"reward_heal"), 50, T.t(&"shop_group_care"))
	add_child_autofree(s)
	assert_eq(s.group.text, T.t(&"shop_group_care"))
	assert_eq(s.title.text, T.t(&"reward_heal"))
	assert_eq(s.detail.text, T.t(&"shop_price", {"n": 50}))
	assert_eq(s._box.get_child(0), s.group, "the group over the name")
	s.set_gold(80)
	assert_true(s.affordable())
	assert_eq(s.detail.get_theme_color(&"font_color"), DoorSign.DETAIL_COLOR, "ivory")
	s.set_gold(20)
	assert_false(s.affordable())
	assert_eq(s.missing, 30)
	assert_eq(s.detail.text, T.t(&"shop_price_short", {"n": 50, "missing": 30}), "says what is missing, not only a colour")


func test_shop_sign_colours_keep_contrast() -> void:
	for c in [DoorSign.GROUP_COLOR, DoorSign.SHORT_COLOR, DoorSign.DETAIL_COLOR, DoorSign.TITLE_COLOR]:
		assert_gte(DoorSign.contrast(c, DoorSign.OUTLINE_COLOR), DoorSign.MIN_CONTRAST, c.to_html())


func test_a_plain_sign_has_no_group() -> void:
	var s := DoorSign.make("Ouro")
	add_child_autofree(s)
	assert_null(s.group)
	s.set_gold(0)
	assert_true(s.affordable(), "no price, nothing missing")


# ---------- text ----------

func test_new_texts_in_portuguese_without_dash() -> void:
	for key in [&"codex_tab_boons", &"codex_tab_elos", &"codex_boons_legend", &"codex_elos_legend", &"codex_times",
			&"boon_new_title", &"boon_new_note", &"choice_upgrade", &"choice_upgrade_swap", &"shop_price",
			&"shop_price_short", &"shop_group_boon", &"shop_group_care", &"shop_group_growth"]:
		var text := String(T.table.entries.get(String(key), ""))
		assert_ne(text, "", String(key))
		assert_false(text.contains("—") or text.contains("–"), String(key))
