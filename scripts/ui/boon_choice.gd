class_name BoonChoice
extends Control
## The gift screen ("Um dom chega até você"): three gifts as tall cards (BoonCard) over the darkened fight. Mouse,
## keys and gamepad all work (focus follows the mouse). When every gift is already at its top level, a single card
## offers rest instead.

signal chosen(b: Boon)

const REST_HEAL := 10.0
## A button still held from the fight must not pick a card: presses this soon after the screen opens are ignored.
const GUARD_MS := 350

var _cards: Array[BoonCard] = []
var _opened_at := 0
var _rarities: Dictionary = {}
var _upgrades: Dictionary = {}


## rarities: each card's offer by gift id (offer_of): a Boon.Rarity, or a Dictionary {rarity, upgrade} for an
## exchange one rarity up (E3-01). upgrades: gift ids offered as exchanges (the same thing, when the run keeps the
## rarities plain).
func open(offers: Array[Boon], state: BoonState, rarities: Dictionary = {}, upgrades: Dictionary = {}) -> void:
	_rarities = rarities
	_upgrades = upgrades
	theme = UiKit.theme()
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_opened_at = Time.get_ticks_msec()
	var page := UiKit.column(self, 1100.0, 0.74)
	page.add_theme_constant_override(&"separation", 20)
	page.add_child(UiKit.shadow(UiKit.title(T.t(&"choice_title"), 40)))
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override(&"separation", 30)
	page.add_child(row)
	if offers.is_empty():
		row.add_child(_card(null, state))
	for b in offers:
		row.add_child(_card(b, state))
	var hint := UiKit.shadow(UiKit.label(T.t(&"choice_hint"), UiKit.DIM, 20))
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	page.add_child(hint)
	Audio.play(&"level_up")
	_cards[0].grab_focus.call_deferred()


## The cards, in order (the tests read them).
func cards() -> Array[BoonCard]:
	return _cards


## An offer read defensively: an int is the rarity; a Dictionary may carry "rarity" and "upgrade" (missing: common, no
## exchange). Always {rarity: Boon.Rarity, upgrade: bool}.
static func offer_of(entry: Variant) -> Dictionary:
	if entry is Dictionary:
		var d: Dictionary = entry
		return {"rarity": clampi(int(d.get("rarity", Boon.Rarity.COMMON)), 0, Boon.Rarity.HEROIC), "upgrade": bool(d.get("upgrade", false))}
	if entry is int or entry is float:
		return {"rarity": clampi(int(entry), 0, Boon.Rarity.HEROIC), "upgrade": false}
	return {"rarity": Boon.Rarity.COMMON, "upgrade": false}


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
