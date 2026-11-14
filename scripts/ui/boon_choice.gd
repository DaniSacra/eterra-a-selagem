class_name BoonChoice
extends Control
## Level up: three gifts to choose from, as tall cards. Mouse, keys and gamepad all work (focus follows the mouse).
## When every gift is already at its top level, a single card offers rest instead.

signal chosen(b: Boon)

const REST_HEAL := 10.0
const CARD := Vector2(320, 430)

var _cards: Array[Button] = []
var _opened_at := 0
var _rarities: Dictionary = {}


## rarities: Boon.Rarity of each card by gift id (common when missing).
func open(offers: Array[Boon], state: BoonState, rarities: Dictionary = {}) -> void:
	_rarities = rarities
	theme = UiKit.theme()
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_opened_at = Time.get_ticks_msec()
	var page := UiKit.column(self, 1100.0, 0.72)
	page.add_theme_constant_override(&"separation", 22)
	page.add_child(UiKit.title(T.t(&"choice_title"), 40))
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override(&"separation", 28)
	page.add_child(row)
	if offers.is_empty():
		row.add_child(_card(null, state))
	for b in offers:
		row.add_child(_card(b, state))
	var hint := UiKit.label(T.t(&"choice_hint"), UiKit.DIM, 20)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	page.add_child(hint)
	Audio.play(&"level_up")
	_cards[0].grab_focus.call_deferred()


func _card(b: Boon, state: BoonState) -> Button:
	var card := Button.new()
	card.custom_minimum_size = CARD
	var color := b.color() if b else UiKit.GOLD
	var rarity: Boon.Rarity = _rarities.get(b.id, Boon.Rarity.COMMON) if b else Boon.Rarity.COMMON
	# the card keeps the best rarity the gift already has
	if b:
		rarity = maxi(rarity, state.rarity(b.id)) as Boon.Rarity
	card.add_theme_stylebox_override(&"normal", _style(color, false, rarity))
	card.add_theme_stylebox_override(&"hover", _style(color, true, rarity))
	card.add_theme_stylebox_override(&"focus", _style(color, true, rarity))
	card.add_theme_stylebox_override(&"pressed", _style(color, true, rarity))
	card.mouse_entered.connect(func() -> void: card.grab_focus())
	card.focus_entered.connect(func() -> void:
		Audio.play(&"ui_move")
		card.pivot_offset = CARD * 0.5
		card.scale = Vector2.ONE * 1.04)
	card.focus_exited.connect(func() -> void: card.scale = Vector2.ONE)
	card.pressed.connect(func() -> void:
		# a short guard so a button still held from the fight does not pick a card by accident
		if Time.get_ticks_msec() - _opened_at < 350:
			return
		Audio.play(&"boon")
		chosen.emit(b))
	var box := VBoxContainer.new()
	box.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	box.offset_left = 22
	box.offset_right = -22
	box.offset_top = 22
	box.offset_bottom = -22
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_theme_constant_override(&"separation", 10)
	card.add_child(box)
	var icon_row := CenterContainer.new()
	icon_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(icon_row)
	if b:
		var icon := BoonIcon.new().setup(b, 110)
		var lv := state.level(b.id)
		icon.level = lv + 1
		icon.max_level = b.max_level
		icon_row.add_child(icon)
		var name_l := UiKit.title(T.t("boon_" + String(b.id)), 26, Color(1.0, 0.95, 0.85))
		name_l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		box.add_child(name_l)
		var fam := UiKit.label(T.t(Boon.FAMILY_KEY[b.family]), color.lightened(0.25), 19, UiKit.BOLD_FONT)
		fam.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		fam.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		box.add_child(fam)
		var lvl := UiKit.label(T.t(&"choice_new") if lv == 0 else T.t(&"choice_level", {"n": lv + 1, "max": b.max_level}), UiKit.GOLD, 18)
		lvl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		box.add_child(lvl)
		var tag := T.t(Boon.RARITY_KEY[rarity])
		if b.slot != Boon.Slot.NONE:
			tag = T.t(Boon.SLOT_KEY[b.slot]) + "  ·  " + tag
		var rar := UiKit.label(tag, Boon.RARITY_COLOR[rarity], 18, UiKit.BOLD_FONT)
		rar.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		box.add_child(rar)
		var desc := UiKit.label(describe(b, lv + 1, Boon.RARITY_MULT[rarity]), UiKit.PALE, 20)
		desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		desc.custom_minimum_size.x = CARD.x - 44
		box.add_child(desc)
		var old := state.replaced_by(b)
		if old != null:
			var warn := UiKit.label(T.t(&"choice_replaces", {"name": T.t("boon_" + String(old.id))}), Color(1.0, 0.55, 0.45), 18)
			warn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			warn.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			warn.custom_minimum_size.x = CARD.x - 44
			box.add_child(warn)
	else:
		box.add_child(UiKit.title(T.t(&"boon_rest"), 28))
		var desc := UiKit.label(T.t(&"boon_rest_desc", {"a": int(REST_HEAL)}), UiKit.PALE, 20)
		desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		desc.custom_minimum_size.x = CARD.x - 44
		box.add_child(desc)
	_cards.append(card)
	return card


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


## The edge takes the rarity's colour (white common, blue rare, purple epic, red heroic).
func _style(color: Color, lit: bool, rarity: Boon.Rarity = Boon.Rarity.COMMON) -> StyleBoxFlat:
	var edge := Boon.RARITY_COLOR[rarity] if rarity != Boon.Rarity.COMMON else (color.lerp(UiKit.GOLD, 0.5) if lit else UiKit.EDGE)
	var s := UiKit.box(Color(0.07, 0.05, 0.09, 0.97) if not lit else Color(0.12, 0.08, 0.1, 0.98), edge, (4 if lit else 3) if rarity != Boon.Rarity.COMMON else (3 if lit else 2), 0, 10)
	s.shadow_color = Color(color.r, color.g, color.b, 0.45 if lit else 0.15)
	s.shadow_size = 18 if lit else 6
	return s
