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
## The angel's seal over its cards (by_angel): it stands for the angel while the angels have no figure (ciclo
## visual 2026-11-20, item 3).
const ANGEL_SEAL := 64.0
## UI-HB4: the angel's seal in the left column, px at 720 lines (about 330 at 1080).
const ANGEL_FIGURE := 220.0
## The glossary beside the row (UI-HB1, P1-2) and the room between it and the cards.
const GLOSSARY := 220.0
const GLOSSARY_GAP := 22

var _cards: Array[BoonCard] = []
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
	_rarities = offers_of(drawn)
	_upgrades = {}
	var row := _page()
	var gifts: Array[StringName] = game.talents if game != null else ([] as Array[StringName])
	var held := Psalms.held_of(state, gifts)
	var known: Dictionary = (Save.data.get("codex", {}) as Dictionary).get("psalms", {})
	for c in drawn:
		var card: BoonCard
		if c.psalm != null:
			card = BoonCard.new().setup_psalm(c.psalm, opened_by(c.psalm, held, game), not known.has(String(c.psalm.id)))
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
func _page(title_text: String = "", hint_text: String = "", lead_text: String = "") -> HBoxContainer:
	theme = UiKit.theme()
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_opened_at = Time.get_ticks_msec()
	var page := UiKit.column(self, 1100.0, 0.74)
	page.add_theme_constant_override(&"separation", 20)
	var head := VBoxContainer.new()
	head.name = "head"
	_head = head
	head.add_theme_constant_override(&"separation", 2)
	head.add_child(UiKit.shadow(UiKit.title(title_text if title_text != "" else T.t(&"choice_title"), 40)))
	if lead_text != "":
		var lead := UiKit.shadow(UiKit.label(lead_text, UiKit.PALE, LEAD_SIZE))
		lead.name = &"Lead"
		lead.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		head.add_child(lead)
	page.add_child(head)
	var row := HBoxContainer.new()
	row.name = "cards"
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override(&"separation", 22)
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
		line.add_child(row)
		glossary = Glossary.new().setup(GLOSSARY)
		line.add_child(glossary)
		page.add_child(line)
	else:
		page.add_child(row)
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
func by_angel(a: AngelDef, on_back: Callable) -> void:
	angel = a
	back = on_back
	if _head != null:
		var n := UiKit.shadow(UiKit.title(T.t(&"choice_by_angel", {"name": T.t(a.name_key)}), 20, AngelSeal.tint(a.family).lightened(0.3)))
		n.name = "angel"
		n.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_head.add_child(n)
		_head.move_child(n, 0)
	var line := find_child("line", true, false) as HBoxContainer
	if line != null:
		# UI-HB4: the angel's seal large in a column to the left of the cards, as the god's portrait (the angels have no
		# figure yet: only the seal), over a soft light of its colour; the glossary under it
		var col := VBoxContainer.new()
		col.name = "angel_column"
		col.alignment = BoxContainer.ALIGNMENT_CENTER
		col.add_theme_constant_override(&"separation", 14)
		col.custom_minimum_size.x = GLOSSARY
		line.add_child(col)
		line.move_child(col, 0)
		var holder := Control.new()
		holder.name = "angel_seal"
		holder.custom_minimum_size = Vector2(ANGEL_FIGURE, ANGEL_FIGURE)
		holder.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var tint := AngelSeal.tint(a.family)
		holder.draw.connect(func() -> void:
			var c := holder.size * 0.5
			for k in 8:
				var t := float(k) / 8.0
				holder.draw_circle(c, ANGEL_FIGURE * 0.62 * (1.0 - t * 0.55), Color(tint, 0.05 * (0.4 + t))))
		var seal := AngelSeal.new().setup(a.family, ANGEL_FIGURE * 0.82)
		seal.position = Vector2(ANGEL_FIGURE, ANGEL_FIGURE) * 0.09
		holder.add_child(seal)
		col.add_child(holder)
		var name := UiKit.shadow(UiKit.title(T.t(a.name_key), 24, tint.lightened(0.35)))
		name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		col.add_child(name)
		if glossary != null:
			glossary.get_parent().remove_child(glossary)
			col.add_child(glossary)
	if bar != null:
		bar.add(ActionBar.entry(&"ui_cancel", T.t(&"bar_back_angels"), func() -> void: _go_back()))


## The card in focus taken, as its key would (the action bar's click).
func _press_focus() -> void:
	var f := get_viewport().gui_get_focus_owner() as BaseButton
	if f != null and is_ancestor_of(f) and not f.disabled:
		f.pressed.emit()


func _go_back() -> void:
	if back.is_valid():
		var go := back
		back = Callable()
		go.call()


func _unhandled_input(event: InputEvent) -> void:
	if reroll_item != null and event.is_action_pressed(&"menu_reroll") and not event.is_echo():
		get_viewport().set_input_as_handled()
		reroll()
		return
	if back.is_valid() and event.is_action_pressed(&"ui_cancel"):
		get_viewport().set_input_as_handled()
		_go_back()


func _ready_cards() -> void:
	Audio.play(&"level_up")
	if glossary != null:
		for c in _cards:
			c.focus_entered.connect(func() -> void: glossary.show_for(c.plain))
	# the first card that can be taken (an altar's trade out of reach cannot be focused)
	for c in _cards:
		if c.focus_mode != Control.FOCUS_NONE:
			c.grab_focus.call_deferred()
			return


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
	if Time.get_ticks_msec() - _opened_at < GUARD_MS:
		return
	Audio.play(&"boon")
	chosen.emit(b)


func _pick_card(c: BoonState.Card) -> void:
	if Time.get_ticks_msec() - _opened_at < GUARD_MS:
		return
	Audio.play(&"boon")
	card_chosen.emit(c)


## The gift's text with its numbers at a level: {a} {b} from its modifiers, {dmg} {count} {cd} {radius} from its skill.
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
	if marked:
		for k: String in args:
			args[k] = UiKit.strong(str(args[k]))
	return T.t("boon_%s_desc" % b.id, args)


## The stats whose value is a time, a damage each second, or a count added: how a fact reads its value.
const SECONDS: Array[StringName] = [&"freeze_time", &"steam_time", &"shield_cooldown"]
const PER_SECOND: Array[StringName] = [&"burn_dps", &"dodge_ember_dps", &"cast_dps"]
const ADDED: Array[StringName] = [&"max_hp", &"dodge_charges"]


## A gift's numbers at a level as the card's facts (UI-HB1, P1-1): [stat, label, value] for each, the skill's first
## (damage, every how many seconds, how many when more than one), then its modifiers that have a label (fact_<stat>).
static func facts(b: Boon, level: int, mult: float = 1.0) -> Array:
	var out: Array = []
	if b == null or level <= 0:
		return out
	if b.skill:
		out.append([&"dmg", T.t(&"fact_dmg"), UiKit.whole(b.skill.damage_at(level, mult))])
		out.append([&"cd", T.t(&"fact_cd"), T.t(&"fact_seconds", {"n": UiKit.format_number(b.skill.get_cooldown(level))})])
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
	if String(stat).ends_with("_pct") or stat in ADDED:
		return "+" + n
	if stat in SECONDS:
		return T.t(&"fact_seconds", {"n": n})
	if stat in PER_SECOND:
		return T.t(&"fact_per_second", {"n": n})
	return n
