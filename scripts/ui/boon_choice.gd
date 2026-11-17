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

var _cards: Array[BoonCard] = []
var _opened_at := 0
var _rarities: Dictionary = {}
var _upgrades: Dictionary = {}
## The draw open_cards shows, in the cards' order (empty with open).
var _drawn: Array[BoonState.Card] = []


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


## The title, the row the cards go in, the hint under it (the gift screen's words unless given: EventChoice).
func _page(title_text: String = "", hint_text: String = "") -> HBoxContainer:
	theme = UiKit.theme()
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_opened_at = Time.get_ticks_msec()
	var page := UiKit.column(self, 1100.0, 0.74)
	page.add_theme_constant_override(&"separation", 20)
	page.add_child(UiKit.shadow(UiKit.title(title_text if title_text != "" else T.t(&"choice_title"), 40)))
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override(&"separation", 30)
	page.add_child(row)
	var hint := UiKit.shadow(UiKit.label(hint_text if hint_text != "" else T.t(&"choice_hint"), UiKit.DIM, 20))
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	page.add_child(hint)
	return row


func _ready_cards() -> void:
	Audio.play(&"level_up")
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
			card.setup(b, rarity, kept, state.sources(b), replaces, describe(b, kept, Boon.RARITY_MULT[rarity]), true,
					state.rarity(replaces.id))
		else:
			card.setup(b, rarity, lv, state.sources(b), replaces, describe(b, lv + 1, Boon.RARITY_MULT[rarity]),
					card_upgrade(b), state.rarity(b.id))
	else:
		card.setup(null, rarity, 0, [], null, T.t(&"boon_rest_desc", {"a": int(REST_HEAL)}))
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
## mult: the rarity's multiplier (only on the numbers that scale with rarity).
static func describe(b: Boon, level: int, mult: float = 1.0) -> String:
	var args := {}
	var letters := ["a", "b", "c"]
	for i in mini(b.mods.size(), letters.size()):
		var m := b.mods[i]
		args[letters[i]] = BoonMod.format(m.stat, m.at(level, mult))
	if b.skill:
		args["dmg"] = UiKit.format_number(b.skill.damage_at(level, mult))
		args["count"] = b.skill.get_count(level)
		args["cd"] = UiKit.format_number(b.skill.get_cooldown(level))
		args["radius"] = UiKit.format_number(b.skill.get_radius(level))
	return T.t("boon_%s_desc" % b.id, args)
