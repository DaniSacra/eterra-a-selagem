class_name MasteryReport
extends VBoxContainer
## The Mastery a run gave, on the end screen (E2-04): "+N XP" and where it came from (rooms, guardians, Morvath's
## phases, the sealing, the first times: only the sources that gave something), the MasteryBar filling from the XP
## before the run to the XP after it (across level-ups), then "Nível N alcançado" and what that unlocked (a Gift, an
## ultimate). The lines that come in at the end take their room from the start, so nothing below moves. The numbers
## are Game.log_run's (mastery_gain); the rule is MasteryCurve's.

## The order the sources are told in (the keys of MasteryCurve.run_xp; text "mastery_src_<key>").
const SOURCES: Array[String] = ["rooms", "guardians", "phases", "victory", "juramentos", "first_boons", "first_elos", "first_psalms",
	"first_guardian", "first_victory"]
const WIDTH := 420.0
## Seconds before the bar starts, and its run.
const DELAY := 0.5
const FILL_TIME := 1.2

var bar: MasteryBar
var xp_before := 0
var xp_after := 0
var _level_line: Label
var _unlock_line: Label
var _tween: Tween


## report: {gain (by source and total), xp_before}. hero: whose curve and Gifts (the Warrior by default).
func setup(report: Dictionary, hero: HeroDef = null) -> MasteryReport:
	hero = hero if hero else HeroDef.warrior()
	name = "mastery"
	alignment = BoxContainer.ALIGNMENT_CENTER
	add_theme_constant_override(&"separation", 4)
	var gain: Dictionary = report.get("gain", {})
	xp_before = int(report.get("xp_before", 0))
	xp_after = xp_before + int(gain.get("total", 0))
	var gap := Control.new()
	gap.custom_minimum_size.y = 6
	add_child(gap)
	# "+N XP" beside the bar, where it came from under it
	var line := HBoxContainer.new()
	line.alignment = BoxContainer.ALIGNMENT_CENTER
	line.add_theme_constant_override(&"separation", 14)
	var plus := UiKit.shadow(UiKit.label(T.t(&"end_xp", {"n": int(gain.get("total", 0))}), UiKit.GOLD, 21, UiKit.number_font()))
	plus.name = "xp"
	plus.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	line.add_child(plus)
	bar = MasteryBar.new().setup(hero.mastery, xp_before, WIDTH)
	line.add_child(bar)
	add_child(line)
	var from := UiKit.shadow(UiKit.label(sources_text(gain), UiKit.DIM.lightened(0.15), 16))
	from.name = "sources"
	from.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	from.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	from.custom_minimum_size.x = WIDTH + 100.0
	from.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	add_child(from)
	var from_level := hero.mastery.level_of(xp_before)
	var to_level := hero.mastery.level_of(xp_after)
	_level_line = UiKit.shadow(UiKit.label(T.t(&"end_level_up", {"n": to_level}), UiKit.GOLD, 20, UiKit.BOLD_FONT))
	_level_line.name = "level_up"
	_level_line.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_unlock_line = UiKit.shadow(UiKit.label("\n".join(unlocks(hero, from_level, to_level)), UiKit.PALE, 17))
	_unlock_line.name = "unlocked"
	_unlock_line.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_unlock_line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_unlock_line.custom_minimum_size.x = WIDTH
	if to_level > from_level:
		_level_line.modulate.a = 0.0
		_unlock_line.modulate.a = 0.0
		add_child(_level_line)
		if _unlock_line.text != "":
			add_child(_unlock_line)
		else:
			_unlock_line.free()
	else:
		_level_line.free()
		_unlock_line.free()
		_level_line = null
		_unlock_line = null
	return self


func _ready() -> void:
	if xp_after == xp_before:
		finish()
		return
	_tween = create_tween()
	_tween.tween_interval(DELAY)
	_tween.tween_property(bar, ^"xp", float(xp_after), FILL_TIME).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_tween.tween_callback(_reveal)


## Jumps to the end (captures, tests, a key pressed).
func finish() -> void:
	if _tween and _tween.is_valid():
		_tween.kill()
	bar.xp = xp_after
	_reveal()


func _reveal() -> void:
	for l: Label in [_level_line, _unlock_line]:
		if is_instance_valid(l) and l.modulate.a < 1.0:
			create_tween().tween_property(l, ^"modulate:a", 1.0, 0.35)


## "Salas 40, Guardiões 25": the sources that gave something, in SOURCES order.
static func sources_text(gain: Dictionary) -> String:
	var parts: PackedStringArray = []
	for key in SOURCES:
		var n := int(gain.get(key, 0))
		if n > 0:
			parts.append("%s %d" % [T.t("mastery_src_" + key), n])
	return ", ".join(parts)


## What the levels after from up to to unlocked, one line for the Gifts and one for the ultimates, in the order
## they reveal (the Memória opens them, Fatia 1): "Dom revelado: X" or "Dons revelados: X, Y"; "Nova ultimate: Z" or "Novas ultimates: Z, W".
static func unlocks(hero: HeroDef, from: int, to: int) -> Array[String]:
	var gifts: PackedStringArray = []
	var ults: PackedStringArray = []
	var book := hero.talents()
	for n in range(from + 1, to + 1):
		for t in book.unlocked_at(n):
			gifts.append(T.t(t.name_key))
		for u in hero.ultimates:
			if u.mastery_level == n:
				ults.append(T.t(u.name_key))
	var out: Array[String] = []
	if not gifts.is_empty():
		out.append(T.t(&"end_unlocked" if gifts.size() == 1 else &"end_unlocked_many", {"name": ", ".join(gifts)}))
	if not ults.is_empty():
		out.append(T.t(&"end_unlocked_ult" if ults.size() == 1 else &"end_unlocked_ults", {"name": ", ".join(ults)}))
	return out
