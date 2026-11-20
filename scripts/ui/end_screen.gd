class_name EndScreen
extends Control
## Defeat or victory (art pack boards 06 and 10).
## Victory (after the sealing): the sealing first, alone on screen: the seal (SealEmblem) closes its ring round the lion
## and lights it while "Morvath foi selado" and "O poder de Morvath foi contido." come in; then the summary rises under
## it: what the descent gathered (the gifts carried, the time, the foes, the longest sequence, the gold), the Mastery
## the run gave (MasteryReport, only when it is kept) and the ways on (_ways).
## A press during the sealing shows everything at once.
## Defeat: a framed panel: the title, the result (what struck the last blow, "Derrotado por: Tempestade das Seis
## Almas", in warm gold; where it fell, "Sala 3 de 7, Cripta dos Esquecidos"), the gifts carried, the progress (the
## Mastery, when kept), the numbers of the run in one row with the best time, and the ways on. Both endings put the
## ways in the same places (back to the hub left, down again right; _ways) and hide the HUD. Keys, mouse and gamepad
## reach every button.

signal retry
signal menu

## The sealing: the screen fades in, the ring closes after SEAL_DELAY in SEAL_CLOSE seconds, the summary rises at
## SUMMARY_AT in SUMMARY_RISE seconds.
const VICTORY_RISE := 0.5
const SEAL_DELAY := 0.15
const SEAL_CLOSE := 1.1
const SUMMARY_AT := 2.0
const SUMMARY_RISE := 0.5
const SEAL_SIZE := 92.0
## The seal alone in the middle of the screen while it closes, and the extra shade under it.
const SEAL_BIG := 168.0
const SEAL_SHADE := 0.3
const VICTORY_WIDTH := 600.0
## The inner margin of the summary's panel.
const SUMMARY_MARGIN := 14
const TITLE_SIZE := 48
const SUB_SIZE := 21
const HEAD_SIZE := 15
const STAT_KEY_SIZE := 17
const STAT_VALUE_SIZE := 22
## The row of numbers: each cell's least width and the gap between cells; the ways' buttons.
const STAT_CELL := 96.0
const STAT_GAP := 14
const WAY_WIDTH := 230.0
const GIFT_ICON := 38.0
## Gifts shown at most (the rest are summed in "+N").
const GIFTS_MAX := 10
## "Derrotado por": its size and colour (warm, under the defeat's title).
const KILLER_SIZE := 24
const KILLER_COLOR := Color(1.0, 0.82, 0.6)
## The defeat's title colour (a warm rose: the light did not go out, it is not a death screen).
const DEFEAT_COLOR := Color(1.0, 0.62, 0.5)
## The defeat's panel (the line under the title fits on one line).
const DEFEAT_WIDTH := 560.0
## "Sala N de M, arena": its size (pale, under the warm killer line).
const WHERE_SIZE := 21

## The sealing is still playing (victory).
## The materials brought home, first on both endings: larger than the numbers.
const BROUGHT_SIZE := 24
const BROUGHT_MARK := 28.0
var intro := false
var _summary: Control
## The sealing alone (the big seal, the title, the line), and the column with the summary that takes its place.
var _sealing: Control
var _body: Control
var _seal: SealEmblem
var _mastery_report: MasteryReport
var _tween: Tween


## stats may carry "defeated_by", the text key of what struck the last blow (Game.defeated_by()); a defeat shows it.
## Where the run ended and what it carried come from stats when it has them (tests, other callers), else from the Game
## above this screen: "room" (depth), "rooms_total", "arena" (the arena's name key), "gifts" (Array of
## {"boon": Boon, "level": int}).
## new_best only counts with a save (Save.enabled; --nosave keeps no record, BUG-008).
func open(victory: bool, stats: Dictionary, new_best: bool) -> void:
	theme = UiKit.theme()
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	new_best = new_best and Save.enabled
	if victory:
		_open_victory(stats, new_best)
		return
	var v := UiKit.page(self, T.t(&"end_defeat"), DEFEAT_WIDTH, 0.75, 40)
	v.add_theme_constant_override(&"separation", 8)
	var title := v.get_node(^"header").get_child(0) as Label
	title.add_theme_color_override(&"font_color", DEFEAT_COLOR)
	var killer: StringName = stats.get("defeated_by", &"")
	if killer != &"":
		var by := UiKit.shadow(UiKit.label(T.t(&"defeated_by", {"name": T.t(killer)}), KILLER_COLOR, KILLER_SIZE, UiKit.BOLD_FONT))
		by.name = "defeated_by"
		by.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		v.add_child(by)
	var where := where_text(stats)
	if where != "":
		var w := UiKit.shadow(UiKit.label(where, UiKit.PALE, WHERE_SIZE))
		w.name = "where"
		w.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		v.add_child(w)
	var sub := UiKit.label(T.t(&"end_defeat_sub"), UiKit.DIM.lightened(0.1), 19)
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	sub.custom_minimum_size.x = DEFEAT_WIDTH - 60.0
	v.add_child(sub)
	# first what he keeps (ciclo visual 2026-11-20: what was brought and the next action first): the materials home
	# and the Mastery, then the Blessings the descent carried, then the numbers
	_brought(v, stats)
	_mastery(v, stats)
	var gifts := _gifts(stats)
	var shows_gifts := gifts.get_child_count() > 0
	if shows_gifts:
		v.add_child(_head(T.t(&"end_gifts")))
		v.add_child(gifts)
	else:
		gifts.free()
	var grid := _grid(v)
	_stat(grid, T.t(&"end_time"), SaveData.format_time(stats.time), UiKit.GOLD if new_best else UiKit.PALE)
	if int(stats.get("level", 0)) > 0: # the old horde mode has levels; the room run does not
		_stat(grid, T.t(&"end_level"), str(stats.level))
	_stat(grid, T.t(&"end_kills"), str(stats.kills))
	_stat(grid, T.t(&"end_combo"), str(stats.best_combo))
	if not shows_gifts: # the medallions above already count them
		_stat(grid, T.t(&"end_boons"), str(stats.boons))
	var best: Array = Save.data.best_times
	if not best.is_empty():
		_stat(grid, T.t(&"end_best"), SaveData.format_time(best[0]), UiKit.GOLD)
	if new_best:
		var nb := UiKit.label(T.t(&"end_new_best"), UiKit.GOLD, 22, UiKit.BOLD_FONT)
		nb.name = "new_best"
		nb.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		v.add_child(nb)
	_hide_hud()
	_ways(v, false)


## The victory: the sealing (the seal, the title, a line on what was done), then the spoils of the descent and the
## way on.
func _open_victory(stats: Dictionary, new_best: bool) -> void:
	var v := UiKit.column(self, VICTORY_WIDTH, 0.62)
	v.add_theme_constant_override(&"separation", 8)
	_body = v
	_sealed_head(v, SEAL_SIZE)
	# the summary, under the sealing
	# in a framed panel like every menu page: the chamber behind (bars, numbers, the seal's light) never reads through
	var panel := PanelContainer.new()
	panel.name = "summary_panel"
	panel.add_theme_stylebox_override(&"panel", UiKit.frame_box(SUMMARY_MARGIN))
	UiKit.crown(panel)
	# room for the crown over the panel's top edge (UiKit.crown), clear of the line above
	var air := Control.new()
	air.custom_minimum_size.y = 8
	air.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.add_child(air)
	v.add_child(panel)
	var s := VBoxContainer.new()
	s.name = "summary"
	s.add_theme_constant_override(&"separation", 6)
	panel.add_child(s)
	_summary = s
	# what he keeps first: the materials home and the Mastery, then the Blessings and the numbers
	_brought(s, stats)
	_mastery(s, stats)
	s.add_child(_head(T.t(&"end_spoils")))
	var gifts := _gifts(stats)
	if gifts.get_child_count() > 0:
		s.add_child(gifts)
	else:
		gifts.free()
	var grid := _grid(s)
	_stat(grid, T.t(&"end_time"), SaveData.format_time(stats.time), UiKit.GOLD if new_best else UiKit.PALE)
	_stat(grid, T.t(&"end_kills"), str(stats.kills))
	_stat(grid, T.t(&"end_combo"), str(stats.best_combo))
	var game := _game()
	_hide_hud()
	if game and game.rooms:
		_stat(grid, T.t(&"hud_gold"), str(game.rooms.gold))
	else:
		_stat(grid, T.t(&"end_boons"), str(stats.boons))
	if new_best:
		var nb := UiKit.shadow(UiKit.label(T.t(&"end_new_best"), UiKit.GOLD, 19, UiKit.BOLD_FONT))
		nb.name = "new_best"
		nb.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		s.add_child(nb)
	_ways(s, true)
	# the sealing alone first, over the summary's place
	_sealing = Control.new()
	_sealing.name = "sealing"
	_sealing.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_sealing.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_sealing)
	var shade := ColorRect.new()
	shade.color = Color(0.01, 0.0, 0.02, SEAL_SHADE)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_sealing.add_child(shade)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_sealing.add_child(center)
	var alone := VBoxContainer.new()
	alone.add_theme_constant_override(&"separation", 12)
	alone.custom_minimum_size.x = VICTORY_WIDTH
	center.add_child(alone)
	_seal = _sealed_head(alone, SEAL_BIG)
	_play_sealing()


## The seal, "Morvath foi selado" and the line under it.
func _sealed_head(parent: Control, seal_px: float) -> SealEmblem:
	var seal := SealEmblem.new().setup(seal_px)
	parent.add_child(seal)
	var title := UiKit.title(T.t(&"end_victory"), TITLE_SIZE, UiKit.GOLD)
	title.name = "title"
	parent.add_child(UiKit.shadow(title))
	var sub := UiKit.shadow(UiKit.label(T.t(&"end_victory_sub"), UiKit.PALE, SUB_SIZE))
	sub.name = "sub"
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	sub.custom_minimum_size.x = VICTORY_WIDTH
	parent.add_child(sub)
	return seal


## The sealing, then the summary (a press shows everything at once: finish_sealing).
func _play_sealing() -> void:
	intro = true
	modulate.a = 0.0
	_seal.closed = 0.0
	_seal.lit = 0.0
	_body.modulate.a = 0.0
	if _mastery_report:
		# the bar fills when it can be seen
		_mastery_report.process_mode = Node.PROCESS_MODE_DISABLED
	_tween = create_tween()
	_tween.tween_property(self, ^"modulate:a", 1.0, VICTORY_RISE)
	_tween.parallel().tween_property(_seal, ^"closed", 1.0, SEAL_CLOSE).set_delay(SEAL_DELAY) \
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_tween.parallel().tween_property(_seal, ^"lit", 1.0, 0.45).set_delay(SEAL_DELAY + SEAL_CLOSE * 0.85)
	_tween.parallel().tween_property(_body, ^"modulate:a", 1.0, SUMMARY_RISE).set_delay(SUMMARY_AT)
	_tween.parallel().tween_property(_sealing, ^"modulate:a", 0.0, SUMMARY_RISE).set_delay(SUMMARY_AT)
	_tween.parallel().tween_callback(_wake_mastery).set_delay(SUMMARY_AT)
	_tween.tween_callback(func() -> void:
		intro = false
		_sealing.visible = false)


func _wake_mastery() -> void:
	if is_instance_valid(_mastery_report):
		_mastery_report.process_mode = Node.PROCESS_MODE_INHERIT


## Ends the sealing at once: the seal closed and lit, the summary shown.
func finish_sealing() -> void:
	if _tween and _tween.is_valid():
		_tween.kill()
	intro = false
	modulate.a = 1.0
	if _seal:
		_seal.closed = 1.0
		_seal.lit = 1.0
	if _body:
		_body.modulate.a = 1.0
	if _sealing:
		_sealing.visible = false
	_wake_mastery()


func _input(event: InputEvent) -> void:
	if not intro:
		return
	var press := event.is_action_pressed(&"ui_accept") or event.is_action_pressed(&"ui_cancel") \
			or (event is InputEventMouseButton and event.is_pressed())
	if press:
		get_viewport().set_input_as_handled()
		finish_sealing()


## "Sala N de M, arena" for the run this screen closes ("" when it was not a room run).
func where_text(stats: Dictionary) -> String:
	var room := int(stats.get("room", 0))
	var total := int(stats.get("rooms_total", 0))
	var arena: StringName = stats.get("arena", &"")
	var game := _game()
	if game != null and game.rooms != null:
		if room <= 0:
			room = game.rooms.depth()
		if total <= 0:
			total = game.rooms.stage.rooms + 1
		if arena == &"":
			arena = arena_key(game)
	if room <= 0 or total <= 0:
		return ""
	var at := T.t(&"end_room", {"n": room, "of": total})
	return at if arena == &"" else T.t(&"end_where", {"room": at, "place": T.t(arena)})


## The text key of the arena the run stands in: its own name, the Seal Chamber in Morvath's room, else the hall.
static func arena_key(game: Game) -> StringName:
	if game.rooms.room != null and game.rooms.room.kind == RunMap.Kind.BOSS:
		return RunMap.KIND_KEY[RunMap.Kind.BOSS]
	if game.arena != null and game.arena.name_key != &"":
		return game.arena.name_key
	return &"arena_hall"


## The Mastery the run gave (E2-04, MasteryReport), when stats carry it ("mastery": Game.mastery_report, empty when
## nothing is kept: no save, the robot).
func _mastery(parent: Control, stats: Dictionary) -> void:
	var report: Dictionary = stats.get("mastery", {})
	if report.has("gain"):
		_mastery_report = MasteryReport.new().setup(report)
		parent.add_child(_mastery_report)


## "Trazidos" (Rejogabilidade, Fatia 1): the materials this descent brought home, mark and number each (MaterialCount),
## under the Blessings carried (UI review d2ff05d, "Fatia 1" 6). stats "materials" ({id: n}) or the run's
## materials_banked; without a save (nothing is kept) the run's own totals, so the screen still says what was found.
## Nothing when none came.
func _brought(parent: Control, stats: Dictionary) -> void:
	var got: Dictionary = stats.get("materials", {})
	var game := _game()
	if got.is_empty() and game != null:
		got = game.materials_banked if not game.materials_banked.is_empty() or Save.enabled else game.materials.totals()
	var row := HBoxContainer.new()
	row.name = "brought"
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override(&"separation", 22)
	for m: StringName in [MaterialPurse.SILVER, MaterialPurse.MEMORY]:
		var n := int(got.get(String(m), 0))
		if n > 0:
			row.add_child(MaterialCount.new().setup(m, n, UiKit.STRONG, BROUGHT_SIZE, BROUGHT_MARK, true))
	if row.get_child_count() == 0:
		row.free()
		return
	parent.add_child(_head(T.t(&"end_brought")))
	parent.add_child(row)


## A part's name, small, in old gold, centred.
func _head(text: String) -> Label:
	var head := UiKit.title(text, HEAD_SIZE, UiKit.OLD_GOLD.lightened(0.25))
	head.add_theme_constant_override(&"outline_size", 4)
	return head


## The gifts carried to the end, in a row of medallions (stats "gifts", else the Game's).
func _gifts(stats: Dictionary) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.name = "gifts"
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override(&"separation", 6)
	var carried: Array = stats.get("gifts", [])
	var game := _game()
	if carried.is_empty() and game != null:
		carried = UiKit.carried_of(game.boons)
	UiKit.gift_icons(row, carried, GIFT_ICON, GIFTS_MAX, false)
	return row


## The numbers of the run in one row (P1-10: a grid of two columns left an empty cell), a cell each: its name small on
## top, the number under it.
func _grid(parent: Control) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.name = "stats"
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override(&"separation", STAT_GAP)
	parent.add_child(row)
	return row


func _stat(row: HBoxContainer, key: String, value: String, color: Color = UiKit.PALE) -> void:
	var cell := VBoxContainer.new()
	cell.name = "stat"
	cell.add_theme_constant_override(&"separation", -2)
	cell.custom_minimum_size.x = STAT_CELL
	var k := UiKit.shadow(UiKit.label(key, UiKit.DIM.lightened(0.15), STAT_KEY_SIZE))
	k.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cell.add_child(k)
	var n := UiKit.shadow(UiKit.label(value, color, STAT_VALUE_SIZE, UiKit.number_font()))
	n.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cell.add_child(n)
	row.add_child(cell)


## The ways on, in the same places in both endings (UI review d2ff05d, P1-10): back to the hub on the left, down again
## on the right; the main one (bronze, with the focus) is the hub after a victory and the descent after a defeat.
## Named "continue" and "again" in a victory, "menu" and "retry" in a defeat.
func _ways(parent: Control, victory: bool) -> void:
	var buttons := UiKit.foot(16)
	buttons.name = "ways"
	parent.add_child(buttons)
	var to_menu := UiKit.button(T.t(&"end_menu"), func() -> void: menu.emit(), WAY_WIDTH)
	to_menu.name = "continue" if victory else "menu"
	buttons.add_child(to_menu)
	var again := UiKit.button(T.t(&"end_again"), func() -> void: retry.emit(), WAY_WIDTH)
	again.name = "again" if victory else "retry"
	buttons.add_child(again)
	var main := to_menu if victory else again
	UiKit.primary(main)
	main.grab_focus.call_deferred()
	# the keys at the foot (benchmark P0-2, UI-HB6)
	ActionBar.attach(self, [ActionBar.entry(&"ui_accept", T.t(&"bar_confirm"), ActionBar.press_focus.bind(self))])


## The fight is over: the HUD hides under any ending (the defeat showed the map, the hit count and the gifts' row
## through its shade).
func _hide_hud() -> void:
	var game := _game()
	if game and game.hud:
		game.hud.visible = false


## The run this screen closes (the Game above it), or null.
func _game() -> Game:
	var n := get_parent()
	while n != null and not n is Game:
		n = n.get_parent()
	return n as Game
