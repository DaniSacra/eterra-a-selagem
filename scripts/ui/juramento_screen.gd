class_name JuramentoScreen
extends Control
## The Juramentos (E6, D-63; rules in Juramentos, docs/design/e6_juramentos.md): one row per Juramento with its name,
## its rank in old-gold diamonds, what it does at that rank and its Peso; the total Peso, the best won and the Mastery a
## victory would give at the top. Up and down walk the rows; left and right (the pad's too) change the rank; Enter, A
## or a click raise it (past the top back to off), a right click lowers it. Saved at once (Save.data.juramentos.ranks).
## Before the first victory it only says how to open them. Opened from the title before Iniciar (descend: true, with
## "Descer") and by --title --screen=juramentos.

signal closed
signal descend

const WIDTH := 1060.0
const ROW_HEIGHT := 40.0
const NAME_WIDTH := 230.0
const PIPS_WIDTH := 92.0
const WEIGHT_WIDTH := 86.0
const PIP := 9.0
const PIP_STEP := 24.0
const ON := UiKit.GOLD
const OFF_LINE := UiKit.OLD_GOLD
const DESC_SIZE := 19

var vows: Juramentos
var locked := false
var _rows: Dictionary = {}
var _total: Label
var _xp: Label
## The keys at the foot (benchmark P0-2, UI-HB6).
var bar: ActionBar


## Ranks of a Juramento in diamonds: filled up to the rank chosen, outlined after.
class Pips:
	extends Control
	var top := 1
	var rank := 0

	func _draw() -> void:
		var mid := size.y * 0.5
		for i in top:
			var c := Vector2(PIP + i * PIP_STEP, mid)
			var pts := PackedVector2Array([c + Vector2(0, -PIP), c + Vector2(PIP, 0), c + Vector2(0, PIP), c + Vector2(-PIP, 0), c + Vector2(0, -PIP)])
			if i < rank:
				draw_colored_polygon(pts.slice(0, 4), ON)
			else:
				draw_colored_polygon(pts.slice(0, 4), Color(UiKit.INK, 0.8))
			draw_polyline(pts, ON if i < rank else OFF_LINE, UiKit.FRAME, true)


## Where the cursor was when the screen opened: a row under it takes the focus only once the mouse really moved
## (QA T5, Q-T5-3: the title's Iniciar sits over a row, and Enter then raised a Juramento instead of descending).
var _open_mouse := Vector2.INF
const HOVER_AFTER_PX := 12.0


func open(with_descend: bool = false) -> void:
	_open_mouse = get_viewport().get_mouse_position() if get_viewport() != null else Vector2.INF
	theme = UiKit.theme()
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	locked = not Juramentos.unlocked(Save.data)
	vows = Juramentos.new(Juramentos.load_catalog(), Juramentos.block(Save.data).get("ranks", {}))
	# the menus' framed page (QW-113: the same panel, title and rule as Configurações; the title art stays behind it)
	var page := UiKit.page(self, T.t(&"jur_title"), WIDTH, 0.82, 36)
	page.add_theme_constant_override(&"separation", 6)
	if locked:
		var why := UiKit.shadow(UiKit.label(T.t(&"jur_locked"), UiKit.PALE, 24))
		why.name = "locked"
		why.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		page.add_child(why)
		var back := UiKit.button(T.t(&"back"), func() -> void: closed.emit(), 220)
		back.name = "back"
		back.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		page.add_child(back)
		back.grab_focus.call_deferred()
		bar = ActionBar.attach(self, [ActionBar.entry(&"ui_cancel", T.t(&"bar_back"), func() -> void: closed.emit())])
		return
	var intro := UiKit.shadow(UiKit.label(T.t(&"jur_intro"), UiKit.DIM, 19))
	intro.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	page.add_child(intro)
	var head := HBoxContainer.new()
	head.alignment = BoxContainer.ALIGNMENT_CENTER
	head.add_theme_constant_override(&"separation", 36)
	page.add_child(head)
	_total = UiKit.shadow(UiKit.label("", UiKit.GOLD, 26, UiKit.BOLD_FONT))
	_total.name = "weight"
	head.add_child(_total)
	head.add_child(UiKit.shadow(UiKit.label(T.t(&"jur_best", {"n": int(Juramentos.block(Save.data).get("best", 0))}), UiKit.PALE, 20)))
	_xp = UiKit.shadow(UiKit.label("", UiKit.DIM, 20))
	head.add_child(_xp)
	var list := VBoxContainer.new()
	list.add_theme_constant_override(&"separation", 0)
	page.add_child(list)
	var first: Control = null
	for d in vows.catalog:
		if first != null:
			list.add_child(_thread())
		var row := _row(d)
		list.add_child(row)
		if first == null:
			first = row
	var bottom := HBoxContainer.new()
	bottom.alignment = BoxContainer.ALIGNMENT_CENTER
	page.add_child(bottom)
	var clear := UiKit.button(T.t(&"jur_clear"), func() -> void:
		vows.set_all({})
		_changed(), 240)
	clear.name = "clear"
	bottom.add_child(clear)
	if with_descend:
		var go := UiKit.button(T.t(&"jur_descend"), func() -> void: descend.emit(), 240)
		go.name = "descend"
		bottom.add_child(go)
	var back := UiKit.button(T.t(&"back"), func() -> void: closed.emit(), 200)
	back.name = "back"
	bottom.add_child(back)
	bar = ActionBar.attach(self, [ActionBar.entry(ActionBar.STEP, T.t(&"bar_rank"), Callable(), true),
		ActionBar.entry(&"ui_accept", T.t(&"bar_confirm"), ActionBar.press_focus.bind(self)),
		ActionBar.entry(&"ui_cancel", T.t(&"bar_back"), func() -> void: closed.emit())])
	_refresh()
	# "Descer" first when going down (Enter twice and he is on his way), else the first Juramento
	var start: Control = page.find_child("descend", true, false) as Control if with_descend else first
	if start:
		start.grab_focus.call_deferred()


## Whether hovering may move the focus: not until the cursor left where it was when the screen opened.
func hover_takes_focus(at: Vector2) -> bool:
	return _open_mouse == Vector2.INF or at.distance_to(_open_mouse) >= HOVER_AFTER_PX


## The thin line between two Juramentos (UI review d2ff05d, P2-2: no box round each row, a thread between them).
static func _thread() -> Control:
	var t := ColorRect.new()
	t.color = Color(UiKit.OLD_GOLD, 0.22)
	t.custom_minimum_size.y = 1
	t.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return t


## One Juramento: a button the size of the row (focus, click), with its name, diamonds, line and Peso inside.
func _row(d: JuramentoDef) -> Button:
	var b := Button.new()
	b.name = String(d.id)
	b.custom_minimum_size = Vector2(0, ROW_HEIGHT)
	b.focus_mode = Control.FOCUS_ALL
	# no box: the row is plain until in focus, then a faint lit band with the gold line (UiKit.focus_row's)
	var empty := StyleBoxEmpty.new()
	for st: StringName in [&"normal", &"hover", &"pressed", &"hover_pressed", &"disabled"]:
		b.add_theme_stylebox_override(st, empty)
	b.add_theme_stylebox_override(&"focus", UiKit.box(Color(0.12, 0.08, 0.1, 0.7), UiKit.GOLD, 2, 0, 4))
	b.mouse_entered.connect(func() -> void:
		if not b.has_focus() and hover_takes_focus(get_viewport().get_mouse_position()):
			_open_mouse = Vector2.INF
			b.grab_focus())
	b.focus_entered.connect(func() -> void: Audio.play(&"ui_move"))
	b.pressed.connect(func() -> void: _step(d.id, 1))
	b.gui_input.connect(func(e: InputEvent) -> void:
		if e.is_action_pressed(&"ui_left"):
			_step(d.id, -1, false)
			b.accept_event()
		elif e.is_action_pressed(&"ui_right"):
			_step(d.id, 1, false)
			b.accept_event()
		elif e is InputEventMouseButton and e.pressed and (e as InputEventMouseButton).button_index == MOUSE_BUTTON_RIGHT:
			_step(d.id, -1)
			b.accept_event())
	var line := HBoxContainer.new()
	line.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	line.offset_left = 14
	line.offset_right = -14
	line.add_theme_constant_override(&"separation", 14)
	line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	b.add_child(line)
	var title := UiKit.label(T.t(d.name_key), UiKit.PALE, 22, UiKit.BOLD_FONT)
	title.custom_minimum_size.x = NAME_WIDTH
	var pips := Pips.new()
	pips.top = d.max_rank()
	pips.custom_minimum_size = Vector2(PIPS_WIDTH, ROW_HEIGHT)
	var desc := UiKit.label("", UiKit.PALE, DESC_SIZE)
	desc.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var cost := UiKit.label("", UiKit.GOLD, 20, UiKit.BOLD_FONT)
	cost.custom_minimum_size.x = WEIGHT_WIDTH
	cost.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	for l: Control in [title, pips, desc, cost]:
		l.mouse_filter = Control.MOUSE_FILTER_IGNORE
		if l is Label:
			(l as Label).vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			(l as Label).custom_minimum_size.y = ROW_HEIGHT
		line.add_child(l)
	_rows[d.id] = {"def": d, "title": title, "pips": pips, "desc": desc, "cost": cost}
	return b


## Rank up or down: wrapping (Enter, click) or held at the ends (left, right).
func _step(id: StringName, dir: int, wrap: bool = true) -> void:
	var before := vows.rank(id)
	if wrap:
		vows.cycle(id, dir)
	else:
		vows.set_rank(id, before + dir)
	if vows.rank(id) != before:
		Audio.play(&"ui_ok")
		_changed()


func _changed() -> void:
	Juramentos.block(Save.data)["ranks"] = vows.to_dict()
	Save.write()
	_refresh()


func _refresh() -> void:
	for id: StringName in _rows:
		var r: Dictionary = _rows[id]
		var d: JuramentoDef = r.def
		var rank := vows.rank(id)
		(r.pips as Pips).rank = rank
		(r.pips as Pips).queue_redraw()
		# off, the line tells the first rank, dimmed
		(r.desc as Label).text = T.t(d.desc_key, {"v": d.shown_value(maxi(rank, 1))})
		(r.desc as Label).modulate = Color.WHITE if rank > 0 else Color(1, 1, 1, 0.55)
		(r.title as Label).add_theme_color_override(&"font_color", UiKit.GOLD if rank > 0 else UiKit.PALE)
		# the state on the right only when sworn (off, the dimmed line already says so)
		(r.cost as Label).text = T.t(&"jur_rank_weight", {"n": d.weight(rank)}) if rank > 0 else ""
		(r.cost as Label).add_theme_color_override(&"font_color", UiKit.GOLD if rank > 0 else UiKit.DIM)
	var w := vows.weight()
	_total.text = T.t(&"jur_weight", {"n": w})
	_xp.text = T.t(&"jur_xp", {"n": HeroDef.warrior().mastery.weight_xp * w})
	_xp.visible = w > 0

