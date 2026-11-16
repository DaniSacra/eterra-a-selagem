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


## rarities: Boon.Rarity of each card by gift id (common when missing).
func open(offers: Array[Boon], state: BoonState, rarities: Dictionary = {}) -> void:
	_rarities = rarities
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


## The rarity a card shows: the one drawn for it, or the best the gift already has.
func card_rarity(b: Boon, state: BoonState) -> Boon.Rarity:
	if b == null:
		return Boon.Rarity.COMMON
	var r: Boon.Rarity = _rarities.get(b.id, Boon.Rarity.COMMON)
	return maxi(r, state.rarity(b.id)) as Boon.Rarity


func _card(b: Boon, state: BoonState) -> BoonCard:
	var card := BoonCard.new()
	var rarity := card_rarity(b, state)
	if b:
		var lv := state.level(b.id)
		card.setup(b, rarity, lv, state.sources(b), state.replaced_by(b), describe(b, lv + 1, Boon.RARITY_MULT[rarity]))
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
		args[letters[i]] = BoonMod.format(m.stat, m.value(level) * (mult if m.by_rarity else 1.0))
	if b.skill:
		args["dmg"] = UiKit.format_number(b.skill.get_damage(level) * mult)
		args["count"] = b.skill.get_count(level)
		args["cd"] = UiKit.format_number(b.skill.get_cooldown(level))
		args["radius"] = UiKit.format_number(b.skill.get_radius(level))
	return T.t("boon_%s_desc" % b.id, args)
