class_name BoonChoice
extends Control
## The gift screen ("Um dom chega até você"): three gifts as tall cards (BoonCard) over the darkened fight. Mouse,
## keys and gamepad all work (focus follows the mouse). When every gift is already at its top level, a single card
## offers rest instead.

signal chosen(b: Boon)
## open_cards (E4-03): the card picked, whatever it offers (a Blessing, an Elo, a trade or a Psalm).
signal card_chosen(card: BoonState.Card)

const REST_HEAL := 10.0
## A button still held from the fight must not pick a card: presses this soon after the screen opens are ignored.
const GUARD_MS := 350
## The lead line under the title (_page, the events' screens).
const LEAD_SIZE := 20
## BC-1: the angel's figure at the left, in px at 720 lines, and the list's width.
## PT-7 (2026-11-23): larger, the angel a presence beside its Blessings.
const FIGURE := Vector2(300.0, 450.0)
const LIST_W := 240.0
## The tall angel (Daniel 2026-11-25: "o anjo maior, do tamanho da tela, a altura toda"): the share of the screen's width
## its box takes from the left, and how far left it starts (px), the figure kept in aspect and centred in it.
const TALL_WIDTH := 0.42
const TALL_LEFT := -60.0
## BC-4: seconds the angel's words stay before the options come by themselves.
const INTRO_TIME := 2.5
## The angel's seal over its cards (by_angel): it stands for the angel while the angels have no figure (ciclo
## visual 2026-11-20, item 3).
const ANGEL_SEAL := 64.0
## UI-HB4: the angel's seal in the left column, px at 720 lines (about 330 at 1080).
const ANGEL_FIGURE := 220.0
## The painted portrait's height in that column (AN-1).
const ANGEL_ART_HEIGHT := 280.0
## The glossary beside the row (UI-HB1, P1-2) and the room between it and the cards.
const GLOSSARY := 220.0
const GLOSSARY_GAP := 22
## SW-B1: the cards come apart (assets/shaders/card_dissolve.gdshader) for this long before the pick is told to the game.
const DISSOLVE_TIME := 0.45
const DISSOLVE_SHADER := preload("res://assets/shaders/card_dissolve.gdshader")
## The angel's colour over the whole screen (alpha), under the cards.
const TINT_ALPHA := 0.4

var _cards: Array[BoonCard] = []
## SW-B1: Blessings never seen before (the Compêndio has none of them): "Novo!" on their medallions. Set before open.
var fresh: Array[StringName] = []
var _state: BoonState
var _dissolving := false
## The tests run without a screen and take a pick at once; this one asks for the dissolve anyway.
var dissolve_headless := false
var _opened_at := 0
var _rarities: Dictionary = {}
var _upgrades: Dictionary = {}
## The draw open_cards shows, in the cards' order (empty with open).
var _drawn: Array[BoonState.Card] = []
## The cards an angel brought (Rejogabilidade, Fatia 1; by_angel): its seal over them, and B or Esc goes back to the
## pair (back).
var angel: AngelDef
var back := Callable()
var _head: VBoxContainer
## BC-1: the Blessing screen is a list (a line for each card, the six buttons beside it, the one the focus changes lit).
var list: AbilityList
## What the angel's intro hides until it is over (BC-4): the lines and the column of words beside them.
var _body: Array[Control] = []
var _intro: Control
var _title: Label
var _intro_done := Callable()
var _hint: Label
## The words of rule of the card in focus (P1-2; null on the events' screens) and the row of actions at the foot (P0-2).
var glossary: Glossary
var bar: ActionBar
## The bar's "Sortear de novo" (Discernimento I; null: the run does not let these cards be drawn again).
var reroll_item: ActionBar.Item


## rarities: each card's offer by gift id (offer_of): a Boon.Rarity, or a Dictionary {rarity, upgrade} for an
## exchange one rarity up (E3-01). upgrades: gift ids offered as exchanges (the same thing, when the run keeps the
## rarities plain).
func open(offers: Array[Boon], state: BoonState, rarities: Dictionary = {}, upgrades: Dictionary = {}) -> void:
	_rarities = rarities
	_upgrades = upgrades
	_state = state
	var row := _page()
	if offers.is_empty():
		row.add_child(_card(null, state))
	for b in offers:
		row.add_child(_card(b, state))
	_ready_cards()


## E4-03: the rules' own draw (Game._open_choice with a Psalm among them): Blessing cards as open shows them, a Psalm's
## card with its frame, the action it changes and the three held things that opened it. Picking emits card_chosen.
## game (null in tests) gives the hero's equipped Gifts and their names.
func open_cards(drawn: Array[BoonState.Card], state: BoonState, game: Game) -> void:
	_drawn = drawn.duplicate()
	_state = state
	_rarities = offers_of(drawn)
	_upgrades = {}
	var row := _page()
	var gifts: Array[StringName] = game.talents if game != null else ([] as Array[StringName])
	var held := Psalms.held_of(state, gifts)
	var known: Dictionary = (Save.data.get("codex", {}) as Dictionary).get("psalms", {})
	for c in drawn:
		var card: BoonCard
		if c.psalm != null:
			card = BoonCard.new()
			card.listed = list != null
			card.setup_psalm(c.psalm, opened_by(c.psalm, held, game), not known.has(String(c.psalm.id)))
			_cards.append(card)
		else:
			card = _card(c.boon, state)
			card.pressed.disconnect(_pick.bind(c.boon))
		card.pressed.connect(_pick_card.bind(c))
		row.add_child(card)
	_ready_cards()


## The names of the held things that open a Psalm, one per group (a Blessing's or an Elo's name, a Gift's name).
static func opened_by(p: PsalmDef, held: Dictionary, game: Game = null) -> PackedStringArray:
	var out := PackedStringArray()
	var book := game.hero.talents() if game != null else HeroDef.warrior().talents()
	for entry in Psalms.matching(p, held):
		if PsalmDef.is_gift(entry):
			var t := book.find(PsalmDef.entry_id(entry))
			out.append(T.t(t.name_key) if t != null else entry)
		else:
			out.append(T.t("boon_" + entry))
	return out


## The draw open_cards shows (the tests read it).
func drawn() -> Array[BoonState.Card]:
	return _drawn


## The title, the row the cards go in, the hint under it (the gift screen's words unless given: EventChoice). lead: one
## line right under the title saying what the screen is about (T5, the events; empty: none).
func _page(title_text: String = "", hint_text: String = "", lead_text: String = "") -> BoxContainer:
	theme = UiKit.theme()
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_opened_at = Time.get_ticks_msec()
	var page := UiKit.column(self, 1100.0, 0.74)
	page.add_theme_constant_override(&"separation", 20 if hint_text != "" else 8)
	var head := VBoxContainer.new()
	head.name = "head"
	_head = head
	head.add_theme_constant_override(&"separation", 2)
	_title = UiKit.shadow(UiKit.title(title_text if title_text != "" else T.t(&"choice_title"), 40))
	head.add_child(_title)
	if lead_text != "":
		var lead := UiKit.shadow(UiKit.label(lead_text, UiKit.PALE, LEAD_SIZE))
		lead.name = &"Lead"
		lead.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		head.add_child(lead)
	page.add_child(head)
	var row: BoxContainer = VBoxContainer.new() if hint_text == "" else HBoxContainer.new()
	row.name = "cards"
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override(&"separation", 10 if hint_text == "" else 22)
	var hint := UiKit.shadow(UiKit.label(hint_text if hint_text != "" else T.t(&"choice_hint"), UiKit.DIM, 18))
	hint.name = "hint"
	_hint = hint
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	if hint_text == "":
		# the Blessings' screen: the glossary of the card in focus beside the row (the events have none)
		var line := HBoxContainer.new()
		line.name = "line"
		line.alignment = BoxContainer.ALIGNMENT_CENTER
		line.add_theme_constant_override(&"separation", GLOSSARY_GAP)
		row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		line.add_child(row)
		# the six buttons, the one in focus lit, and under them the words of rule (BC-1)
		var side := VBoxContainer.new()
		side.name = "side"
		side.alignment = BoxContainer.ALIGNMENT_CENTER
		side.add_theme_constant_override(&"separation", 12)
		list = AbilityList.new().setup(LIST_W)
		side.add_child(list)
		glossary = Glossary.new().setup(LIST_W)
		side.add_child(glossary)
		line.add_child(side)
		page.add_child(line)
	else:
		page.add_child(row)
	# air between the last card and the footer (art review 2026-11-25 sweep: 19 px at 720 lines)
	var air := Control.new()
	air.custom_minimum_size.y = 12.0
	air.mouse_filter = Control.MOUSE_FILTER_IGNORE
	page.add_child(air)
	page.add_child(hint)
	bar = ActionBar.attach(self, [ActionBar.entry(&"ui_accept", T.t(&"bar_choose"), _press_focus)])
	if hint_text == "":
		_offer_reroll.call_deferred()
	return row


## Discernimento I (Fatia 3): while the run lets these cards be drawn again (Game.can_reroll), the bar's left holds
## "Sortear de novo (N)" (Y, R on the keyboard, or a click); Game.reroll_choice closes this screen and opens the new draw.
func _offer_reroll() -> void:
	var game := _game()
	if game == null or not game.can_reroll() or bar == null:
		return
	reroll_item = bar.add(ActionBar.entry(&"menu_reroll", T.t(&"bar_reroll", {"n": game.rerolls_left}), reroll, true))


## Draws the cards again (Game.reroll_choice). False when the run does not let it.
func reroll() -> bool:
	var game := _game()
	if game == null or not game.can_reroll():
		return false
	Audio.play(&"ui_ok")
	return game.reroll_choice()


func _game() -> Game:
	var n := get_parent()
	while n != null and not n is Game:
		n = n.get_parent()
	return n as Game


## The cards came by an angel (EncounterScreen): its seal small over the title with its name, and a line in the hint
## for going back to the pair; B or Esc (ui_cancel) calls on_back.
## held: BC-4, how many Blessings of its family the hero carries; 0 or more shows the angel's words first (name, family,
## its line and that count) and the options only after a press or INTRO_TIME seconds; -1 (the default): straight to the
## options. Asked again for the same angel (the pair's Esc, a new draw) it only takes the way back.
func by_angel(a: AngelDef, on_back: Callable = Callable(), held := -1) -> void:
	if angel == a:
		back = on_back if on_back.is_valid() else back
		_offer_back()
		return
	angel = a
	back = on_back
	_tint_screen(AngelSeal.tint(a.family))
	if _head != null:
		# SW-B1: the angel's name and its line over the screen, "Escolha uma Bênção" smaller under them
		var n := UiKit.shadow(UiKit.title(T.t(a.name_key), 38, AngelSeal.tint(a.family).lightened(0.4)))
		n.name = "angel"
		n.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_head.add_child(n)
		_head.move_child(n, 0)
		var phrase := UiKit.shadow(UiKit.label(T.t(a.line_key), UiKit.PALE, 20))
		phrase.name = "angel_line"
		phrase.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_head.add_child(phrase)
		_head.move_child(phrase, 1)
		_title.add_theme_font_size_override(&"font_size", 22)
		# PT-25-1: three cards is the rule; an angel that truly has fewer says so instead of leaving a bare screen
		if not _cards.is_empty() and _cards.size() < Encounter.CARDS:
			var few := UiKit.shadow(UiKit.label(T.t(&"angel_few", {"name": T.t(a.name_key), "n": _cards.size()}), UiKit.DIM, 18))
			few.name = "angel_few"
			few.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			_head.add_child(few)
	var line := find_child("line", true, false) as HBoxContainer
	if line != null:
		# BC-1: the angel in a column to the left of the lines, its whole painting fading into the dark (the seal when it
		# has none yet)
		var col := VBoxContainer.new()
		col.name = "angel_column"
		col.alignment = BoxContainer.ALIGNMENT_CENTER
		col.add_theme_constant_override(&"separation", 8)
		col.custom_minimum_size.x = FIGURE.x
		line.add_child(col)
		line.move_child(col, 0)
		var tint := AngelSeal.tint(a.family)
		# AN-1: the angel's painted portrait when it has one (AngelArt), else its seal over a soft light
		var art: Control = null
		if list != null:
			# Daniel 2026-11-25: the angel the whole height of the screen, behind its Blessings (the column keeps its place)
			art = AngelArt.figure(a, Vector2.ZERO)
			if art != null:
				art.name = "angel_tall"
				art.set_anchors_preset(Control.PRESET_LEFT_WIDE)
				art.anchor_right = TALL_WIDTH
				art.offset_left = TALL_LEFT
				art.offset_right = 0
				add_child(art)
				move_child(art, mini(3, get_child_count() - 1))
				var spacer := Control.new()
				spacer.name = "angel_art"
				spacer.custom_minimum_size = FIGURE
				spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
				col.add_child(spacer)
		else:
			art = AngelArt.portrait(a, Vector2(ANGEL_FIGURE, ANGEL_ART_HEIGHT))
			if art != null:
				col.add_child(art)
		if art == null:
			var holder := Control.new()
			holder.name = "angel_seal"
			holder.custom_minimum_size = Vector2(ANGEL_FIGURE, ANGEL_FIGURE)
			holder.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
			holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
			holder.draw.connect(func() -> void:
				var c := holder.size * 0.5
				for k in 8:
					var t := float(k) / 8.0
					holder.draw_circle(c, ANGEL_FIGURE * 0.62 * (1.0 - t * 0.55), Color(tint, 0.05 * (0.4 + t))))
			var seal := AngelSeal.new().setup(a.family, ANGEL_FIGURE * 0.82)
			seal.position = Vector2(ANGEL_FIGURE, ANGEL_FIGURE) * 0.09
			holder.add_child(seal)
			col.add_child(holder)
		if glossary != null and list == null:
			glossary.get_parent().remove_child(glossary)
			col.add_child(glossary)
	_offer_back()
	if held >= 0 and line != null:
		_show_intro(a, held, line)


## SW-B1: the whole screen in the angel's colour, over the dimmed fight and under everything else.
func _tint_screen(tint: Color) -> void:
	var veil := get_node_or_null("AngelTint") as ColorRect
	if veil == null:
		veil = ColorRect.new()
		veil.name = "AngelTint"
		veil.mouse_filter = Control.MOUSE_FILTER_IGNORE
		veil.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		add_child(veil)
		move_child(veil, 1)
	veil.color = Color(tint.darkened(0.4), TINT_ALPHA)
	# a glow of the colour behind the angel, at the left (the figure's place)
	var glow := get_node_or_null("AngelGlow") as TextureRect
	if glow == null:
		var grad := Gradient.new()
		grad.colors = PackedColorArray([Color(1, 1, 1, 1), Color(1, 1, 1, 0)])
		var tex := GradientTexture2D.new()
		tex.gradient = grad
		tex.fill = GradientTexture2D.FILL_RADIAL
		tex.fill_from = Vector2(0.5, 0.5)
		tex.fill_to = Vector2(1.0, 0.5)
		tex.width = 256
		tex.height = 256
		glow = TextureRect.new()
		glow.name = "AngelGlow"
		glow.texture = tex
		glow.stretch_mode = TextureRect.STRETCH_SCALE
		glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
		glow.set_anchors_preset(Control.PRESET_FULL_RECT)
		glow.anchor_right = 0.55
		glow.offset_left = 0
		glow.offset_right = 0
		glow.offset_top = 0
		glow.offset_bottom = 0
		add_child(glow)
		move_child(glow, 2)
	glow.modulate = Color(tint.lightened(0.15), 0.5)


## The bar's "Voltar aos anjos" once there is a way back.
func _offer_back() -> void:
	if bar != null and back.is_valid() and bar.item(&"ui_cancel") == null:
		bar.add(ActionBar.entry(&"ui_cancel", T.t(&"bar_back_angels"), func() -> void: _go_back()))


## BC-4: the angel alone with its words, the lines and the list hidden until it is over.
func _show_intro(a: AngelDef, held: int, line: HBoxContainer) -> void:
	var tint := AngelSeal.tint(a.family)
	var col := VBoxContainer.new()
	col.name = "angel_intro"
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col.add_theme_constant_override(&"separation", 10)
	col.mouse_filter = Control.MOUSE_FILTER_STOP
	col.draw.connect(func() -> void:
		col.draw_style_box(UiKit.box(Color(0.02, 0.015, 0.03, 0.62), Color(0, 0, 0, 0), 0, 0, 10), Rect2(Vector2.ZERO, col.size).grow(18.0)))
	col.gui_input.connect(func(ev: InputEvent) -> void:
		if ev is InputEventMouseButton and ev.pressed:
			end_intro())
	var n := UiKit.shadow(UiKit.title(T.t(a.name_key), 40, tint.lightened(0.35)))
	n.name = "IntroName"
	n.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	col.add_child(n)
	var family := T.t(Boon.FAMILY_KEY[a.family])
	var fam := UiKit.label(T.t(&"encounter_family", {"family": family}), UiKit.OLD_GOLD.lightened(0.3), 20, UiKit.TITLE_FONT)
	fam.name = "IntroFamily"
	fam.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	col.add_child(fam)
	var rule := GoldRule.new()
	rule.custom_minimum_size = Vector2(260, 10)
	rule.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	col.add_child(rule)
	var words := UiKit.label(T.t(a.line_key), UiKit.PALE, 24)
	words.name = "IntroLine"
	words.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	words.custom_minimum_size.x = 380
	col.add_child(words)
	var have := UiKit.label(T.t(&"encounter_held", {"n": held, "family": family}) if held > 0
			else T.t(&"encounter_held_none", {"family": family}), UiKit.DIM.lightened(0.2), 18, UiKit.number_font())
	have.name = "IntroHeld"
	have.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	have.custom_minimum_size.x = 380
	col.add_child(have)
	line.add_child(col)
	_intro = col
	# nothing to choose yet: neither the title nor the hint
	_title.visible = false
	_hint.visible = false
	_set_brought_line(false)
	_body.clear()
	for c in [find_child("cards", true, false), find_child("side", true, false)]:
		if c is Control:
			c.visible = false
			_body.append(c)
	if bar != null:
		var it := bar.item(&"ui_accept")
		if it != null:
			it.set_verb(T.t(&"bar_continue"))
	var t := Timer.new()
	t.one_shot = true
	t.wait_time = INTRO_TIME
	t.timeout.connect(end_intro)
	add_child(t)
	t.start()


## The "Trazidas por X" line over the title: hidden while the angel speaks (its name is in the words).
func _set_brought_line(on: bool) -> void:
	for id in ["angel", "angel_line"]:
		var n := _head.get_node_or_null(id) if _head != null else null
		if n is CanvasItem:
			n.visible = on


## Whether the angel's words are on show (BC-4).
func intro_open() -> bool:
	return _intro != null and is_instance_valid(_intro)


## BC-4: the words are over (a press, a click or the time): the options come and the first takes the focus.
func end_intro() -> void:
	if not intro_open() or not is_inside_tree():
		return
	_intro.queue_free()
	_intro = null
	_title.visible = true
	_hint.visible = true
	_set_brought_line(true)
	for c in _body:
		c.visible = true
	_body.clear()
	if bar != null:
		var it := bar.item(&"ui_accept")
		if it != null:
			it.set_verb(T.t(&"bar_choose"))
	for c in _cards:
		if c.focus_mode != Control.FOCUS_NONE:
			c.grab_focus.call_deferred()
			return


## The card in focus taken, as its key would (the action bar's click).
func _press_focus() -> void:
	if intro_open():
		if Time.get_ticks_msec() - _opened_at >= GUARD_MS:
			end_intro()
		return
	var f := get_viewport().gui_get_focus_owner() as BaseButton
	if f != null and is_ancestor_of(f) and not f.disabled:
		f.pressed.emit()


func _go_back() -> void:
	if back.is_valid():
		var go := back
		back = Callable()
		go.call()


func _unhandled_input(event: InputEvent) -> void:
	if intro_open() and event.is_action_pressed(&"ui_accept") and not event.is_echo() and Time.get_ticks_msec() - _opened_at >= GUARD_MS:
		get_viewport().set_input_as_handled()
		end_intro()
		return
	if reroll_item != null and event.is_action_pressed(&"menu_reroll") and not event.is_echo():
		get_viewport().set_input_as_handled()
		reroll()
		return
	if back.is_valid() and event.is_action_pressed(&"ui_cancel"):
		get_viewport().set_input_as_handled()
		_go_back()


func _ready_cards() -> void:
	Audio.play(&"level_up")
	if list != null:
		list.show_held(_state)
	if glossary != null:
		for c in _cards:
			c.focus_entered.connect(func() -> void:
				glossary.show_for(c.plain)
				if list != null:
					list.show_for(c.button(), card_tint(c)))
			# SW-B1: the pointer on one word of rule: that word's box alone; off it, the card's words again
			c.term_hovered.connect(func(id: StringName) -> void:
				if id == &"":
					glossary.show_for(c.plain if c.has_focus() else "")
				else:
					glossary.show_terms([id] as Array[StringName]))
	# the first card that can be taken (an altar's trade out of reach cannot be focused)
	for c in _cards:
		if c.focus_mode != Control.FOCUS_NONE:
			c.grab_focus.call_deferred()
			return


## The colour a card lights its button with: its Blessing's family, the Psalm's own.
static func card_tint(c: BoonCard) -> Color:
	if c.boon != null:
		return c.boon.color()
	if c.psalm != null:
		return PsalmIcon.tint(c.psalm)
	return UiKit.OLD_GOLD


## The cards, in order (the tests read them).
func cards() -> Array[BoonCard]:
	return _cards


## An offer read defensively: an int is the rarity; a Dictionary may carry "rarity" and "upgrade" (missing: common, no
## exchange). Always {rarity: Boon.Rarity, upgrade: bool}.
static func offer_of(entry: Variant) -> Dictionary:
	if entry is Dictionary:
		var d: Dictionary = entry
		return {"rarity": clampi(int(d.get("rarity", Boon.Rarity.COMMON)), 0, Boon.Rarity.LEGENDARY), "upgrade": bool(d.get("upgrade", false))}
	if entry is int or entry is float:
		return {"rarity": clampi(int(entry), 0, Boon.Rarity.LEGENDARY), "upgrade": false}
	return {"rarity": Boon.Rarity.COMMON, "upgrade": false}


## The offers of a draw as open reads them (offer_of): {rarity, upgrade} by gift id, upgrade being a trade (E3-01).
static func offers_of(cards: Array[BoonState.Card]) -> Dictionary:
	var out := {}
	for c in cards:
		if c.boon == null:
			continue  # a Psalm card (E4) carries no Blessing
		out[c.boon.id] = {"rarity": c.rarity, "upgrade": c.trade}
	return out


## The rarity a card shows: the one drawn for it, or the best the gift already has. An Elo has none (common, BUG-017).
func card_rarity(b: Boon, state: BoonState) -> Boon.Rarity:
	if b == null or b.is_duo():
		return Boon.Rarity.COMMON
	var r: int = offer_of(_rarities.get(b.id)).rarity
	return maxi(r, state.rarity(b.id)) as Boon.Rarity


## Whether a card is an exchange one rarity up (E3-01): in its offer or in the upgrades given.
func card_upgrade(b: Boon) -> bool:
	if b == null or b.is_duo():
		return false
	return bool(offer_of(_rarities.get(b.id)).upgrade) or bool(_upgrades.get(b.id, false))


func _card(b: Boon, state: BoonState) -> BoonCard:
	var card := BoonCard.new()
	card.listed = list != null
	card.fresh = b != null and fresh.has(b.id)
	card.guest_of_family = b != null and angel != null and not Encounter.belongs(state, b, angel.family)
	var rarity := card_rarity(b, state)
	if b:
		var lv := state.level(b.id)
		var replaces := state.replaced_by(b)
		if card_upgrade(b) and replaces != null:
			# the exchange keeps the level of the Blessing it replaces, one rarity up
			var kept := maxi(state.level(replaces.id), 1)
			card.setup(b, rarity, kept, state.sources(b), replaces, describe(b, kept, Boon.RARITY_MULT[rarity], true), true,
					state.rarity(replaces.id), state.level(replaces.id))
		else:
			card.setup(b, rarity, lv, state.sources(b), replaces, describe(b, lv + 1, Boon.RARITY_MULT[rarity], true),
					card_upgrade(b), state.rarity(replaces.id) if replaces != null else state.rarity(b.id),
					state.level(replaces.id) if replaces != null else 0)
	else:
		card.setup(null, rarity, 0, [], null, T.t(&"boon_rest_desc", {"a": UiKit.strong(str(int(REST_HEAL)))}))
	card.pressed.connect(_pick.bind(b))
	_cards.append(card)
	return card


func _pick(b: Boon) -> void:
	if _dissolving or Time.get_ticks_msec() - _opened_at < GUARD_MS:
		return
	Audio.play(&"boon")
	_dissolve_then(func() -> void: chosen.emit(b))


func _pick_card(c: BoonState.Card) -> void:
	if _dissolving or Time.get_ticks_msec() - _opened_at < GUARD_MS:
		return
	Audio.play(&"boon")
	_dissolve_then(func() -> void: card_chosen.emit(c))


## SW-B1: the cards come apart, then done runs (at once when the screen is not on show, or DISSOLVE_TIME is 0).
func _dissolve_then(done: Callable) -> void:
	_dissolving = true
	if not is_inside_tree() or not is_visible_in_tree() or DISSOLVE_TIME <= 0.0 or (DisplayServer.get_name() == "headless" and not dissolve_headless):
		done.call()
		return
	var mat := ShaderMaterial.new()
	mat.shader = DISSOLVE_SHADER
	mat.set_shader_parameter(&"progress", 0.0)
	mat.set_shader_parameter(&"edge", AngelSeal.tint(angel.family).lightened(0.4) if angel != null else UiKit.GOLD)
	for c in _cards:
		c.focus_mode = Control.FOCUS_NONE
		c.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_burn(c, mat)
	var tw := create_tween()
	tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tw.tween_property(mat, "shader_parameter/progress", 1.0, DISSOLVE_TIME)
	tw.finished.connect(done)


## The dissolve material on a card and every part of it.
static func _burn(n: Node, mat: Material) -> void:
	if n is CanvasItem:
		(n as CanvasItem).material = mat
	for c in n.get_children():
		_burn(c, mat)


## Whether the Compêndio has met this Blessing (a run's award writes it at the end of the descent).
static func known_to_codex(id: StringName) -> bool:
	var entries: Dictionary = (Save.data.get("codex", {}) as Dictionary).get("boons", {})
	var entry: Variant = entries.get(String(id), {})
	return entry is Dictionary and int((entry as Dictionary).get("seen", 0)) > 0


## The gift's text with its numbers at a level: {a} {b} from its modifiers, {dmg} {count} {cd} {radius} {duration} {gap}
## {status} (the seconds of its freeze or slow) from its skill.
## mult: the rarity's multiplier (only on the numbers that scale with rarity). marked: each number as UiKit.strong
## (bbcode for the cards, UI-HB2).
static func describe(b: Boon, level: int, mult: float = 1.0, marked := false) -> String:
	var args := {}
	var letters := ["a", "b", "c"]
	for i in mini(b.mods.size(), letters.size()):
		var m := b.mods[i]
		args[letters[i]] = BoonMod.format(m.stat, m.at(level, mult))
	if b.skill:
		args["dmg"] = UiKit.whole(b.skill.damage_at(level, mult))
		args["count"] = str(b.skill.get_count(level))
		args["cd"] = UiKit.format_number(b.skill.get_cooldown(level))
		args["radius"] = UiKit.format_number(b.skill.get_radius(level))
		args["duration"] = UiKit.format_number(b.skill.get_duration(level))
		args["gap"] = UiKit.format_number(b.skill.get_gap(level))
		args["status"] = UiKit.format_number(b.skill.get_status_power(level))
		args["status_pct"] = "%d%%" % roundi(b.skill.get_status_power(level) * 100.0)  # (a chance: Julgamento da Luz)
	args.merge(CelRules.text_args())
	if marked:
		for k: String in args:
			args[k] = UiKit.strong(str(args[k]))
	args["key"] = key_in_text(b.button(), marked)
	return T.t("boon_%s_desc" % b.id, args)


## PT-10: the real key of a button inside the sentence ("O ataque [Mouse esq.] incendeia..."): the key as the player has
## it now (the pad's, a remapped key), in strong ink when marked, with the space before it. Empty for a Blessing that
## acts alone.
static func key_in_text(action: StringName, marked := false) -> String:
	if action == &"":
		return ""
	var k := UiKit.action_label(action)
	if marked and UiKit.action_mouse_button(action) > 0 and MouseGlyph.button_of(k) > 0:
		return " " + MouseGlyph.bbcode(MouseGlyph.button_of(k), 18)
	return " " + (UiKit.strong("[lb]%s[rb]" % k) if marked else "[%s]" % k)


## The stats whose value is a time, a damage each second, or a count added: how a fact reads its value.
const SECONDS: Array[StringName] = [&"freeze_time", &"steam_time", &"shield_cooldown", &"weak_time", &"mark_time", &"cel_echo_time",
	&"cel_guard_time", &"cel_haste_time", &"cel_mark", &"cel_weak"]
const PER_SECOND: Array[StringName] = [&"burn_dps", &"dodge_ember_dps", &"cast_dps", &"cel_burn_dps"]
const ADDED: Array[StringName] = [&"max_hp", &"dodge_charges"]


## A gift's numbers at a level as the card's facts (UI-HB1, P1-1): [stat, label, value] for each, the skill's first
## (damage, every how many seconds, how many when more than one), then its modifiers that have a label (fact_<stat>).
static func facts(b: Boon, level: int, mult: float = 1.0) -> Array:
	var out: Array = []
	if b == null or level <= 0:
		return out
	if b.skill:
		out.append([&"dmg", T.t(&"fact_dmg"), UiKit.whole(b.skill.damage_at(level, mult))])
		if b.skill.alone():
			out.append([&"cd", T.t(&"fact_cd"), T.t(&"fact_seconds", {"n": UiKit.format_number(b.skill.get_cooldown(level))})])
		elif b.skill.get_gap(level) > 0.0:
			# a button's skill never fires "every N s" (its cooldown field is unused): the pause between two firings
			out.append([&"gap", T.t(&"fact_gap"), T.t(&"fact_seconds", {"n": UiKit.format_number(b.skill.get_gap(level))})])
		if b.skill.get_count(level) > 1:
			out.append([&"count", T.t(&"fact_count"), str(b.skill.get_count(level))])
	for m in b.mods:
		var key := "fact_%s" % m.stat
		if T.table.entries.has(key):
			out.append([m.stat, T.t(key), fact_value(m.stat, m.at(level, mult))])
	return out


## A modifier's value as a fact reads it: "+25%", "0,4 s", "3 por s", "+10".
static func fact_value(stat: StringName, v: float) -> String:
	var n := BoonMod.format(stat, v)
	if String(stat).ends_with("_pct") or stat in ADDED or stat in BoonMod.PERCENT:
		return "+" + n
	if stat in SECONDS:
		return T.t(&"fact_seconds", {"n": n})
	if stat in PER_SECOND:
		return T.t(&"fact_per_second", {"n": n})
	return n
