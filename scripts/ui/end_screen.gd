class_name EndScreen
extends Control
## Defeat or victory. Defeat: the title, what struck the last blow ("Derrotado por: Tempestade das Seis Almas", under
## the title, the name in warm gold: what to learn for the next try), the numbers of the run, the best time, "Tentar
## de novo". Victory (after the sealing):
## in the title screen's voice (Cinzel and Alegreya, old gold, short), the king sealed, what the descent gathered
## (the gifts carried, the time, the foes, the longest sequence, the gold) and "Continuar" (to the title) or a new
## descent. It rises in VICTORY_RISE seconds; keys, mouse and gamepad all reach the buttons (Continuar has the focus).

signal retry
signal menu

const VICTORY_RISE := 0.6
const VICTORY_WIDTH := 560.0
const TITLE_SIZE := 50
const SUB_SIZE := 21
const HEAD_SIZE := 15
const STAT_KEY_SIZE := 17
const STAT_VALUE_SIZE := 22
const GIFT_ICON := 38.0
## Gifts shown at most (the rest are summed in "+N").
const GIFTS_MAX := 10
## "Derrotado por": its size and colour (warm, under the defeat's red title).
const KILLER_SIZE := 24
const KILLER_COLOR := Color(1.0, 0.82, 0.6)
## The defeat's column (the line under the title fits on one line).
const DEFEAT_WIDTH := 520.0

var _rise := 0.0
var _ornaments: Array[Ornament] = []


## stats may carry "defeated_by", the text key of what struck the last blow (Game.defeated_by()); a defeat shows it.
## new_best only counts with a save (Save.enabled; --nosave keeps no record, BUG-008).
func open(victory: bool, stats: Dictionary, new_best: bool) -> void:
	theme = UiKit.theme()
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	new_best = new_best and Save.enabled
	if victory:
		_open_victory(stats, new_best)
		return
	var v := UiKit.column(self, DEFEAT_WIDTH, 0.75)
	v.add_child(UiKit.shadow(UiKit.title(T.t(&"end_defeat"), 48, Color(1.0, 0.55, 0.45))))
	var killer: StringName = stats.get("defeated_by", &"")
	if killer != &"":
		var by := UiKit.shadow(UiKit.label(T.t(&"defeated_by", {"name": T.t(killer)}), KILLER_COLOR, KILLER_SIZE, UiKit.BOLD_FONT))
		by.name = "defeated_by"
		by.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		v.add_child(by)
	var sub := UiKit.label(T.t(&"end_defeat_sub"), UiKit.DIM, 22)
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	sub.custom_minimum_size.x = DEFEAT_WIDTH
	v.add_child(sub)
	var panel := PanelContainer.new()
	v.add_child(panel)
	var rows := VBoxContainer.new()
	panel.add_child(rows)
	_row(rows, T.t(&"end_time"), SaveData.format_time(stats.time))
	if int(stats.get("level", 0)) > 0: # the old horde mode has levels; the room run does not
		_row(rows, T.t(&"end_level"), str(stats.level))
	_row(rows, T.t(&"end_kills"), str(stats.kills))
	_row(rows, T.t(&"end_combo"), str(stats.best_combo))
	_row(rows, T.t(&"end_boons"), str(stats.boons))
	var best: Array = Save.data.best_times
	if not best.is_empty():
		_row(rows, T.t(&"end_best"), SaveData.format_time(best[0]), UiKit.GOLD)
	if new_best:
		var nb := UiKit.label(T.t(&"end_new_best"), UiKit.GOLD, 24, UiKit.BOLD_FONT)
		nb.name = "new_best"
		nb.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		v.add_child(nb)
	var buttons := HBoxContainer.new()
	buttons.alignment = BoxContainer.ALIGNMENT_CENTER
	v.add_child(buttons)
	var again := UiKit.button(T.t(&"end_retry"), func() -> void: retry.emit(), 220)
	buttons.add_child(again)
	buttons.add_child(UiKit.button(T.t(&"end_menu"), func() -> void: menu.emit(), 160))
	again.grab_focus.call_deferred()


## The victory: title, a line on what was done, the spoils of the descent and the way on.
func _open_victory(stats: Dictionary, new_best: bool) -> void:
	var v := UiKit.column(self, VICTORY_WIDTH, 0.62)
	v.add_theme_constant_override(&"separation", 10)
	_ornaments.append(_ornament(v))
	var title := UiKit.title(T.t(&"end_victory"), TITLE_SIZE, UiKit.GOLD)
	v.add_child(UiKit.shadow(title))
	var sub := UiKit.shadow(UiKit.label(T.t(&"end_victory_sub"), UiKit.PALE, SUB_SIZE))
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	sub.custom_minimum_size.x = VICTORY_WIDTH
	v.add_child(sub)
	_ornaments.append(_ornament(v))
	# the spoils: the gifts carried to the end, then the numbers in two columns
	var head := UiKit.title(T.t(&"end_spoils"), HEAD_SIZE, UiKit.OLD_GOLD.lightened(0.25))
	head.add_theme_constant_override(&"outline_size", 4)
	v.add_child(head)
	var gifts := _gifts()
	if gifts.get_child_count() > 0:
		v.add_child(gifts)
	else:
		gifts.free()
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override(&"h_separation", 36)
	grid.add_theme_constant_override(&"v_separation", 2)
	grid.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	v.add_child(grid)
	_stat(grid, T.t(&"end_time"), SaveData.format_time(stats.time), UiKit.GOLD if new_best else UiKit.PALE)
	_stat(grid, T.t(&"end_kills"), str(stats.kills))
	_stat(grid, T.t(&"end_combo"), str(stats.best_combo))
	var game := _game()
	if game and game.hud:
		# the fight is over: the screen is the victory's alone
		game.hud.visible = false
	if game and game.rooms:
		_stat(grid, T.t(&"hud_gold"), str(game.rooms.gold))
	else:
		_stat(grid, T.t(&"end_boons"), str(stats.boons))
	if new_best:
		var nb := UiKit.shadow(UiKit.label(T.t(&"end_new_best"), UiKit.GOLD, 19, UiKit.BOLD_FONT))
		nb.name = "new_best"
		nb.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		v.add_child(nb)
	var gap := Control.new()
	gap.custom_minimum_size.y = 6
	v.add_child(gap)
	var buttons := HBoxContainer.new()
	buttons.alignment = BoxContainer.ALIGNMENT_CENTER
	buttons.add_theme_constant_override(&"separation", 16)
	v.add_child(buttons)
	var go_on := UiKit.button(T.t(&"end_continue"), func() -> void: menu.emit(), 220)
	buttons.add_child(go_on)
	buttons.add_child(UiKit.button(T.t(&"end_again"), func() -> void: retry.emit(), 220))
	go_on.grab_focus.call_deferred()
	modulate.a = 0.0
	_rise = 0.0
	set_process(true)


func _process(delta: float) -> void:
	if _ornaments.is_empty():
		set_process(false)
		return
	_rise = minf(1.0, _rise + delta / VICTORY_RISE)
	modulate.a = ease(_rise, 0.6)
	for o in _ornaments:
		o.drawn = ease(_rise, 0.4)
	if _rise >= 1.0:
		set_process(false)


## The gifts carried to the end, in a row of medallions.
func _gifts() -> HBoxContainer:
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override(&"separation", 6)
	var game := _game()
	if game == null or game.boons == null:
		return row
	var owned: Array[Boon] = game.boons.owned()
	for i in mini(owned.size(), GIFTS_MAX):
		var icon := BoonIcon.new().setup(owned[i], GIFT_ICON)
		icon.level = game.boons.level(owned[i].id)
		icon.max_level = owned[i].max_level
		row.add_child(icon)
	if owned.size() > GIFTS_MAX:
		row.add_child(UiKit.label("+%d" % (owned.size() - GIFTS_MAX), UiKit.PALE, STAT_VALUE_SIZE, UiKit.BOLD_FONT))
	return row


func _stat(grid: GridContainer, key: String, value: String, color: Color = UiKit.PALE) -> void:
	var h := HBoxContainer.new()
	h.custom_minimum_size.x = 230
	var k := UiKit.shadow(UiKit.label(key, UiKit.DIM.lightened(0.15), STAT_KEY_SIZE))
	k.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	h.add_child(k)
	h.add_child(UiKit.shadow(UiKit.label(value, color, STAT_VALUE_SIZE, UiKit.number_font())))
	grid.add_child(h)


func _ornament(parent: Control) -> Ornament:
	var o := Ornament.new()
	o.custom_minimum_size = Vector2(VICTORY_WIDTH * 0.7, 14)
	o.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	parent.add_child(o)
	return o


## The run this screen closes (the Game above it), or null.
func _game() -> Game:
	var n := get_parent()
	while n != null and not n is Game:
		n = n.get_parent()
	return n as Game


func _row(parent: Control, key: String, value: String, color: Color = UiKit.PALE) -> void:
	var h := HBoxContainer.new()
	var k := UiKit.label(key, UiKit.DIM, 22)
	k.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	h.add_child(k)
	h.add_child(UiKit.label(value, color, 24, UiKit.BOLD_FONT))
	parent.add_child(h)


## A thin line of old gold that fades at both ends, with a diamond in the middle; drawn out from the middle.
class Ornament:
	extends Control

	var drawn := 1.0:
		set(v):
			drawn = v
			queue_redraw()

	func _init() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func _draw() -> void:
		var c := size * 0.5
		var half := size.x * 0.5 * drawn
		var steps := 12
		for side: float in [-1.0, 1.0]:
			for i in steps:
				var a := c + Vector2(side * (9.0 + (half - 9.0) * i / steps), 0)
				var b := c + Vector2(side * (9.0 + (half - 9.0) * (i + 1) / steps), 0)
				draw_line(a, b, Color(UiKit.OLD_GOLD.lightened(0.15), 1.0 - float(i) / steps), 1.5, true)
		var d := 5.0
		draw_colored_polygon(PackedVector2Array([c + Vector2(0, -d - 1.5), c + Vector2(d + 1.5, 0), c + Vector2(0, d + 1.5), c + Vector2(-d - 1.5, 0)]), UiKit.INK)
		draw_colored_polygon(PackedVector2Array([c + Vector2(0, -d), c + Vector2(d, 0), c + Vector2(0, d), c + Vector2(-d, 0)]), UiKit.GOLD)
