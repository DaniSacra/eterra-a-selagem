class_name ForgeScreen
extends Control
## The Forja da Emeth at the Forjador (Rejogabilidade, Fatia 1; sistemas.md 1.5 and 5.3), a spread of the Livro
## (BookSpread, Book) as the Compêndio is: the left page the forge's index (the Temperar ranks as entries, each with its
## cost, the owned ones marked) over the purse (MaterialCount.purse); the right page the rank in focus with the Livro's
## own heads: Efeito, Custo, Estado and Próximo passo, then Forjar (the main action, only when the rules let it: Forge
## problem OK) and Voltar. Forjar spends the Prata (Forge.buy), writes the save and says so (forged); everything on the
## pages reads the save again. Nothing is bought by moving the focus: the index only shows, Enter on it goes to
## Forjar. Esc and B close it (ScreenHost).
## Fatia 2 (sistemas.md 1.5, 3.6 and 5.3 "Fatia 2"): the index is a grid of three columns that fits 720 lines, the
## Temperar (I to III) and the Refinar's two actions (Ataque, Especial: three choices each, one on each action), every
## entry with a mark of its state (Mark: the Prata's ingot and the cost while it waits, a diamond of old gold forged and
## kept, an emerald diamond on the blade, a hollow one while the Forjador's tool is lost). Over the Refinar the tool's
## state ("Ferramenta: Encontrada" or still lost). The main button says what it does: Forjar (buy; the first Refinar
## bought on an action goes on it), Usar (a Refinar forged and kept goes on its action, free: Forge.put_on) or, the
## one on the blade, Em uso (off).
## Ofícios, Roteiro A (10_ux.md 10.5): once a vein was noted the spread has two bookmarks over the cover, Emeth (all
## of the above) and Oficina: the left page the Picareta drawn as it stands (lost, its head found, restored), the
## right page the tools' index (the Picareta) and the same heads, Restaurar spending its Prata (Oficios.restore) and
## saying so (restored). LB and RB turn the bookmarks.
##   host.open(ForgeScreen.new(), [Save.data])          # forged(rank) after each purchase and each change
##   host.open(ForgeScreen.new(), [Save.data, ForgeScreen.Tab.WORKSHOP])

signal closed
signal forged(rank: StringName)
## The Picareta restored at the Oficina.
signal restored

enum Tab { EMETH, WORKSHOP }

const SPINE := 0.46
const OUTER := Vector2(22, 10)
const ENTRY_WIDTH := 176.0
const ENTRY_HEIGHT := 34.0
const ENTRY_FONT := 16
const ENTRY_PAD := 34
const ENTRY_COUNT := 30.0
const COLUMN_GAP := 10
const MARK := 18.0
const TEXT_SIZE := 18
const BUTTON_WIDTH := 190.0
## The Emeth's place on the left page and the size of the cost and the purse by the button.
const EMETH := Vector2(300, 330)
const DEAL_SIZE := 22
## The bookmarks' width and the Picareta's drawing on the Oficina's left page.
const TAB_WIDTH := 170.0
const PICK := 220.0

var forge: Forge
## Every entry's rank, as entries: the Temperar first (rank order), then the Refinar's (attack, then special).
var ranks: Array[ForgeRank] = []
var temper_ranks: Array[ForgeRank] = []
var entries: Array[Button] = []
## The rank on show on the right page.
var shown: ForgeRank
var buy_button: Button
var back_button: Button
var _data: Dictionary
var _purse: HBoxContainer
var _title: VBoxContainer
var _effect: Label
var _cost: MaterialCount
var _state: Label
var _step: Label
var _done: Label
## The Emeth on the left page, the rank it has now under it, and over the rank in focus whether it is the next one.
var emeth: EmethView
var _now: Label
var _kind: Label
var _tool: Label
var _deal: Control
## The bookmark open, the bookmarks (none until a vein was noted), and the Oficina's parts.
var tab := Tab.EMETH
var tabs: Array[Button] = []
var pick_entry: Button
var showing_pick := false
var pick_view: PickMark
var _oficios: OficiosDef
var _emeth_left: Control
var _work_left: Control
var _emeth_index: Control
var _work_index: Control
var _pick_now: Label
var _head_line: Label


## An entry's mark, by its state.
class Mark extends Control:
	enum Look { BUY, OWNED, ON, LOCKED }
	var look := Look.BUY:
		set(v):
			look = v
			queue_redraw()

	func _draw() -> void:
		var c := size * 0.5
		var r := minf(size.x, size.y) * 0.42
		var d := PackedVector2Array([c + Vector2(0, -r), c + Vector2(r, 0), c + Vector2(0, r), c + Vector2(-r, 0)])
		match look:
			Look.BUY:
				DoorGlyph.material(self, DoorGlyph.Kind.SILVER, c, size.y)
			Look.OWNED:
				draw_colored_polygon(d, Color(Book.INK, 0.12))
				d.append(d[0])
				draw_polyline(d, Book.GILT, 2.0, true)
			Look.ON:
				draw_colored_polygon(d, DoorGlyph.EMERALD_FILL)
				d.append(d[0])
				draw_polyline(d, UiKit.OLD_GOLD, 2.0, true)
			Look.LOCKED:
				d.append(d[0])
				draw_polyline(d, Color(Book.FADED, 0.6), 1.5, true)


## data: the save data (Save.data in the game; tests give their own); start: the bookmark open first (the Oficina only
## once a vein was noted).
func open(data: Dictionary = {}, start: Tab = Tab.EMETH) -> void:
	_data = data if not data.is_empty() else Save.data
	_oficios = OficiosDef.live()
	forge = Forge.new(Forge.load_catalog())
	temper_ranks = forge.track(Forge.TEMPER)
	name = "forge_screen"
	theme = Book.theme()
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var shade := ColorRect.new()
	shade.color = Color(0.01, 0.0, 0.02, 0.84)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(shade)
	var frame := MarginContainer.new()
	frame.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side: String in ["left", "right"]:
		frame.add_theme_constant_override("margin_" + side, int(OUTER.x))
	frame.add_theme_constant_override(&"margin_top", int(OUTER.y))
	frame.add_theme_constant_override(&"margin_bottom", int(ActionBar.RESERVE))
	add_child(frame)
	var col := VBoxContainer.new()
	col.add_theme_constant_override(&"separation", 0)
	frame.add_child(col)
	if workshop_open():
		# the bookmarks out of the top of the cover, as the Livro's chapters (Book.mark)
		var marks := HBoxContainer.new()
		marks.name = "tabs"
		marks.alignment = BoxContainer.ALIGNMENT_CENTER
		marks.add_theme_constant_override(&"separation", 6)
		marks.custom_minimum_size.y = Book.MARK_HEIGHT + Book.MARK_RISE
		col.add_child(marks)
		for t: int in Tab.values():
			var b := Book.mark(T.t(&"forge_tab_emeth" if t == Tab.EMETH else &"forge_tab_workshop"), TAB_WIDTH)
			b.name = "tab_emeth" if t == Tab.EMETH else "tab_workshop"
			b.pressed.connect(_show_tab.bind(t, true))
			tabs.append(b)
			marks.add_child(b)
	var book := BookSpread.new().setup(SPINE)
	book.size_flags_vertical = Control.SIZE_EXPAND_FILL
	col.add_child(book)
	_left_page(book.left)
	_right_page(book.right)
	buy_button.focus_neighbor_left = buy_button.get_path_to(entries[0] if not entries.is_empty() else buy_button)
	back_button.focus_neighbor_left = back_button.get_path_to(buy_button)
	var keys := [ActionBar.entry(&"ui_accept", T.t(&"bar_choose"), _press_focus),
		ActionBar.entry(&"ui_cancel", T.t(&"bar_back"), func() -> void: closed.emit())]
	if not tabs.is_empty():
		keys.push_front(ActionBar.entry(&"tab_next", T.t(&"bar_next"), func() -> void: _turn(1), true))
		keys.push_front(ActionBar.entry(&"tab_prev", T.t(&"bar_prev"), func() -> void: _turn(-1), true))
	ActionBar.attach(self, keys)
	emeth.show_rank(Forge.temper(_data))
	_show_tab(start if workshop_open() else Tab.EMETH, false)
	_first_focus().grab_focus.call_deferred()


## Whether the Oficina has its bookmark: a vein was noted (the Forjador's order) or the Picareta is restored.
func workshop_open() -> bool:
	return Oficios.noted(_data) or Oficios.has_tool(_data, _oficios)


## Shows a bookmark's pages; by_hand moves the focus to its first entry.
func _show_tab(t: Tab, by_hand: bool = false) -> void:
	tab = t
	for i in tabs.size():
		Book.mark_open(tabs[i], i == t)
	var work := t == Tab.WORKSHOP
	_emeth_left.visible = not work
	_emeth_index.visible = not work
	if _work_left != null:
		_work_left.visible = work
		_work_index.visible = work
	if work:
		_show_pick()
		buy_button.focus_neighbor_left = buy_button.get_path_to(pick_entry)
	else:
		_show(_first())
		buy_button.focus_neighbor_left = buy_button.get_path_to(entries[0] if not entries.is_empty() else buy_button)
	if by_hand:
		Audio.play(&"ui_ok")
		_first_focus().grab_focus()


func _first_focus() -> Control:
	if tab == Tab.WORKSHOP and pick_entry != null:
		return pick_entry
	return _entry_of(shown) if shown != null else back_button


## The bookmark before (-1) or after (1), as LB and RB.
func _turn(step: int) -> void:
	if tabs.is_empty():
		return
	var t := clampi(tab + step, 0, tabs.size() - 1)
	if t != tab:
		_show_tab(t as Tab, true)


func _unhandled_input(event: InputEvent) -> void:
	if not tabs.is_empty() and (event.is_action_pressed(&"tab_next") or event.is_action_pressed(&"tab_prev")) \
			and not event.is_echo():
		get_viewport().set_input_as_handled()
		_turn(1 if event.is_action_pressed(&"tab_next") else -1)


## The left page: the Emeth itself, the forge's piece (ciclo visual 2026-11-20, item 3; UI-HB4), with its rank of
## Temperar on the blade, the title over it and the rank it has now under it.
func _left_page(page: MarginContainer) -> void:
	var v := VBoxContainer.new()
	v.name = "index"
	v.add_theme_constant_override(&"separation", 4)
	page.add_child(v)
	_emeth_left = v
	if workshop_open():
		page.add_child(_workshop_left())
	v.add_child(Book.heading(T.t(&"forge_title"), 30, 260))
	v.add_child(Book.text(T.t(&"forge_lead"), Book.FADED, 15))
	emeth = EmethView.new().setup(EMETH)
	emeth.size_flags_vertical = Control.SIZE_EXPAND_FILL
	emeth.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	v.add_child(emeth)
	var now := HBoxContainer.new()
	now.name = "now"
	now.alignment = BoxContainer.ALIGNMENT_CENTER
	now.add_theme_constant_override(&"separation", 10)
	v.add_child(now)
	now.add_child(Book.label(T.t(&"forge_current").to_upper(), Book.RUBRIC, 14, UiKit.TITLE_FONT))
	_now = Book.label("", Book.INK, 20, UiKit.BOLD_FONT)
	_now.name = "rank_now"
	now.add_child(_now)


## The Oficina's left page: its title, a line, the Picareta drawn as it stands and its state under it.
func _workshop_left() -> Control:
	var v := VBoxContainer.new()
	v.name = "workshop"
	v.visible = false
	v.add_theme_constant_override(&"separation", 4)
	_work_left = v
	v.add_child(Book.heading(T.t(&"forge_workshop_title"), 30, 260))
	v.add_child(Book.text(T.t(&"forge_workshop_lead"), Book.FADED, 15))
	pick_view = PickMark.new().setup(PickMark.Look.LOST, PICK)
	pick_view.name = "pick"
	pick_view.size_flags_vertical = Control.SIZE_EXPAND_FILL
	pick_view.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	v.add_child(pick_view)
	var now := HBoxContainer.new()
	now.alignment = BoxContainer.ALIGNMENT_CENTER
	now.add_theme_constant_override(&"separation", 10)
	v.add_child(now)
	now.add_child(Book.label(T.t(&"oficio_pick").to_upper(), Book.RUBRIC, 14, UiKit.TITLE_FONT))
	_pick_now = Book.label("", Book.INK, 20, UiKit.BOLD_FONT)
	_pick_now.name = "pick_now"
	now.add_child(_pick_now)
	return v


## The right page: the track's ranks as an index, the rank in focus (the next improvement, or one forged) with its
## effect, state and next step, and, by the buttons, the cost and the purse side by side (ciclo visual 2026-11-20:
## "custo e saldo perto da ação de forjar").
func _right_page(page: MarginContainer) -> void:
	var v := VBoxContainer.new()
	v.name = "rank"
	v.add_theme_constant_override(&"separation", 4)
	page.add_child(v)
	# the heads: Temperar over its column, Refinar over the two of the actions with the tool's state at its end
	var index := VBoxContainer.new()
	index.name = "emeth_index"
	index.add_theme_constant_override(&"separation", 4)
	v.add_child(index)
	_emeth_index = index
	if workshop_open():
		v.add_child(_workshop_index())
	var heads := HBoxContainer.new()
	heads.add_theme_constant_override(&"separation", COLUMN_GAP)
	index.add_child(heads)
	var temper_head := Book.section(T.t(&"forge_track_temper"))
	temper_head.custom_minimum_size.x = ENTRY_WIDTH
	heads.add_child(temper_head)
	var refine_head := Book.section(T.t(&"forge_track_refine"))
	refine_head.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	heads.add_child(refine_head)
	_tool = Book.label("", Book.FADED, 14, UiKit.BOLD_FONT)
	_tool.name = "tool"
	refine_head.add_child(_tool)
	var grid := HBoxContainer.new()
	grid.name = "grid"
	grid.add_theme_constant_override(&"separation", COLUMN_GAP)
	index.add_child(grid)
	grid.add_child(_column("", temper_ranks))
	for slot in forge.refine_slots():
		grid.add_child(_column(T.t(StringName("forge_refine_slot_" + String(slot))), forge.refine_options(slot)))
	v.add_child(_gap(6))
	_kind = Book.label("", Book.RUBRIC, 14, UiKit.TITLE_FONT)
	_kind.name = "kind"
	v.add_child(_kind)
	_title = Book.heading("", 28, 300)
	v.add_child(_title)
	v.add_child(Book.section(T.t(&"hero_effect")))
	_effect = Book.text("", Book.INK, TEXT_SIZE)
	_effect.name = "effect"
	v.add_child(_effect)
	v.add_child(_gap(4))
	v.add_child(Book.section(T.t(&"hero_state_head")))
	_state = Book.text("", Book.INK, TEXT_SIZE)
	_state.name = "state"
	_state.add_theme_font_override(&"font", UiKit.BOLD_FONT)
	v.add_child(_state)
	v.add_child(_gap(4))
	v.add_child(Book.section(T.t(&"forge_step_head")))
	_step = Book.text("", Book.FADED, TEXT_SIZE - 1)
	_step.name = "step"
	v.add_child(_step)
	_done = Book.text(T.t(&"forge_done"), Book.OK, TEXT_SIZE - 1)
	_done.name = "done"
	v.add_child(_done)
	var fill := Control.new()
	fill.size_flags_vertical = Control.SIZE_EXPAND_FILL
	v.add_child(fill)
	# the deal by the button: cost on the left, the purse on the right, label over value (benchmark 2.3)
	var deal := HBoxContainer.new()
	deal.name = "deal"
	_deal = deal
	deal.add_theme_constant_override(&"separation", 40)
	v.add_child(deal)
	var cost := VBoxContainer.new()
	cost.add_theme_constant_override(&"separation", 2)
	cost.add_child(Book.section(T.t(&"hero_cost_head")))
	_cost = MaterialCount.new().setup(MaterialPurse.SILVER, 0, Book.INK, DEAL_SIZE, 24.0, true)
	_cost.name = "cost"
	cost.add_child(_cost)
	_head_line = Book.label("", Book.INK, 15, UiKit.BOLD_FONT)
	_head_line.name = "head_line"
	_head_line.visible = false
	cost.add_child(_head_line)
	deal.add_child(cost)
	var have := VBoxContainer.new()
	have.add_theme_constant_override(&"separation", 2)
	have.add_child(Book.section(T.t(&"forge_balance")))
	_purse = MaterialCount.purse(_data, Book.INK, DEAL_SIZE, 24.0)
	have.add_child(_purse)
	deal.add_child(have)
	v.add_child(_gap(8))
	var foot := HBoxContainer.new()
	foot.name = "foot"
	foot.alignment = BoxContainer.ALIGNMENT_END
	foot.add_theme_constant_override(&"separation", 12)
	v.add_child(foot)
	buy_button = Book.primary(Book.button(T.t(&"forge_do"), _buy, BUTTON_WIDTH))
	buy_button.name = "buy"
	foot.add_child(buy_button)
	back_button = Book.button(T.t(&"back"), func() -> void: closed.emit(), BUTTON_WIDTH)
	back_button.name = "back"
	foot.add_child(back_button)


## The Oficina's index: the tools (the Picareta), in the Temperar's place.
func _workshop_index() -> Control:
	var v := VBoxContainer.new()
	v.name = "workshop_index"
	v.visible = false
	v.add_theme_constant_override(&"separation", 2)
	_work_index = v
	var head := Book.section(T.t(&"forge_tools_head"))
	head.custom_minimum_size.x = ENTRY_WIDTH
	v.add_child(head)
	var mark := Mark.new()
	mark.name = "mark"
	mark.custom_minimum_size = Vector2(MARK, MARK)
	mark.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pick_entry = Book.index_entry(T.t(&"oficio_pick"), mark, "", ENTRY_WIDTH, ENTRY_HEIGHT, ENTRY_FONT, ENTRY_PAD, ENTRY_COUNT)
	pick_entry.name = "pick_entry"
	pick_entry.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	pick_entry.focus_entered.connect(_show_pick)
	pick_entry.pressed.connect(func() -> void:
		_show_pick()
		if not buy_button.disabled:
			buy_button.grab_focus())
	v.add_child(pick_entry)
	# the two lines of entries the Emeth's index takes, kept: the heads below stand where they stood
	v.add_child(_gap(ENTRY_HEIGHT + 18.0))
	return v


## A column of the index: its action's name over its entries ("" keeps the line, for the Temperar's).
func _column(head: String, of: Array[ForgeRank]) -> VBoxContainer:
	var col := VBoxContainer.new()
	col.add_theme_constant_override(&"separation", 2)
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var h := Book.label(head, Book.RUBRIC, 14, UiKit.BOLD_FONT)
	h.custom_minimum_size.y = 18
	col.add_child(h)
	for r in of:
		var mark := Mark.new()
		mark.name = "mark"
		mark.custom_minimum_size = Vector2(MARK, MARK)
		mark.size = mark.custom_minimum_size
		mark.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var e := Book.index_entry(T.t(r.name_key), mark, "", ENTRY_WIDTH, ENTRY_HEIGHT, ENTRY_FONT, ENTRY_PAD, ENTRY_COUNT)
		e.name = String(r.id)
		e.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		e.focus_entered.connect(_show.bind(r))
		e.pressed.connect(func() -> void:
			_show(r)
			if not buy_button.disabled:
				buy_button.grab_focus())
		ranks.append(r)
		entries.append(e)
		col.add_child(e)
	return col


func _entry_of(r: ForgeRank) -> Button:
	return entries[ranks.find(r)]


static func _gap(h: float) -> Control:
	var c := Control.new()
	c.custom_minimum_size.y = h
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return c


## Where the focus starts: the Temperar to buy now, else a Refinar to forge with the tool found, else the last
## Temperar (all owned).
func _first() -> ForgeRank:
	for r in temper_ranks:
		if forge.state(_data, r) != Forge.State.OWNED:
			return r
	for r in ranks:
		if r.track == Forge.REFINE and forge.problem(_data, r) in [Forge.Problem.OK, Forge.Problem.SHORT]:
			return r
	return temper_ranks.back() if not temper_ranks.is_empty() else null


func _show(r: ForgeRank) -> void:
	shown = r
	showing_pick = false
	_refresh()


func _show_pick() -> void:
	showing_pick = true
	_refresh()


## Everything on both pages from the save as it is now.
func _refresh() -> void:
	MaterialCount.refresh(_purse, _data)
	var silver := MaterialPurse.amount(_data, MaterialPurse.SILVER)
	var tool := Forge.has_tool(_data, Forge.TOOL_REFINE)
	_tool.text = "%s: %s" % [T.t(&"forge_tool"), T.t(&"forge_tool_found" if tool else &"forge_tool_missing")]
	_tool.add_theme_color_override(&"font_color", Book.OK if tool else Book.FADED)
	for i in ranks.size():
		var r := ranks[i]
		var owned := forge.state(_data, r) == Forge.State.OWNED
		var count := entries[i].find_child("count", false, false) as Label
		count.text = "" if owned else str(r.cost)
		var mark := entries[i].find_child("mark", false, false) as Mark
		if forge.problem(_data, r) == Forge.Problem.NO_TOOL:
			mark.look = Mark.Look.LOCKED
		elif r.track == Forge.REFINE and forge.is_on(_data, r):
			mark.look = Mark.Look.ON
		else:
			mark.look = Mark.Look.OWNED if owned else Mark.Look.BUY
		entries[i].set_pressed_no_signal(r == shown)
		count.add_theme_color_override(&"font_color", UiKit.GOLD if r == shown else Book.GILT)
	_head_line.visible = false
	if pick_entry != null:
		_refresh_pick_entry()
	if showing_pick:
		_done.visible = false
		_refresh_pick()
		return
	_done.visible = forge.state(_data, temper_ranks.back()) == Forge.State.OWNED and (shown == null or shown.track == Forge.TEMPER)
	var rank := Forge.temper(_data)
	_now.text = T.t(temper_ranks[rank - 1].name_key) if rank > 0 and rank <= temper_ranks.size() else T.t(&"forge_current_none")
	if shown == null:
		buy_button.disabled = true
		return
	(_title.get_node("text") as Label).text = T.t(shown.name_key)
	var owned_now := forge.state(_data, shown) == Forge.State.OWNED
	if shown.track == Forge.REFINE:
		_kind.text = ("%s · %s" % [T.t(&"forge_track_refine"), T.t(StringName("forge_refine_slot_" + String(shown.slot)))]).to_upper()
	else:
		_kind.text = T.t(&"forge_owned" if owned_now else &"forge_next").to_upper()
	_effect.text = T.t(shown.desc_key)
	_cost.set_amount(shown.cost)
	_deal.visible = not owned_now
	var problem := forge.problem(_data, shown)
	var before := _before(shown)
	var verb := T.t(&"forge_do")
	var can := problem == Forge.Problem.OK
	match problem:
		Forge.Problem.OWNED:
			if shown.track == Forge.REFINE and forge.is_on(_data, shown):
				_set_state(T.t(&"forge_state_on"), Book.OK)
				_step.text = T.t(&"forge_step_on")
				verb = T.t(&"forge_refine_in_use")
			elif shown.track == Forge.REFINE:
				_set_state(T.t(&"forge_state_off"), Book.INK)
				var now_on := _on_of(shown.slot)
				_step.text = T.t(&"forge_step_use", {"name": T.t(now_on.name_key)}) if now_on else T.t(&"forge_step_use_free")
				verb = T.t(&"forge_refine_use")
				can = true
			else:
				_set_state(T.t(&"forge_state_owned"), Book.OK)
				_step.text = T.t(&"forge_step_owned")
		Forge.Problem.NO_TOOL:
			_set_state(T.t(&"forge_state_no_tool"), Book.FADED)
			_step.text = T.t(&"forge_no_tool")
		Forge.Problem.NEEDS:
			_set_state(T.t(&"forge_state_needs", {"name": T.t(before.name_key) if before else ""}), Book.FADED)
			_step.text = T.t(&"forge_step_needs", {"name": T.t(before.name_key) if before else ""})
		Forge.Problem.SHORT:
			_set_state(T.t(&"forge_short", {"n": shown.cost - silver, "name": T.t(shown.name_key)}), Book.WARN)
			_step.text = T.t(&"forge_step_short")
		_:
			_set_state(T.t(&"forge_state_ready"), Book.INK)
			_step.text = T.t(&"forge_step_buy", {"cost": shown.cost, "have": silver})
	buy_button.text = verb
	buy_button.disabled = not can
	buy_button.focus_mode = Control.FOCUS_ALL if not buy_button.disabled else Control.FOCUS_NONE


## The Picareta's entry: restored (a diamond of old gold), its head found (the Prata and the cost) or still lost.
func _refresh_pick_entry() -> void:
	var problem := Oficios.restore_problem(_data, _oficios)
	var mark := pick_entry.find_child("mark", false, false) as Mark
	var count := pick_entry.find_child("count", false, false) as Label
	mark.look = Mark.Look.OWNED if problem == Oficios.DONE else (Mark.Look.LOCKED if problem == Oficios.NO_HEAD else Mark.Look.BUY)
	count.text = str(_pick_cost()) if problem == &"" or problem == Oficios.SHORT else ""
	pick_entry.set_pressed_no_signal(showing_pick)
	count.add_theme_color_override(&"font_color", UiKit.GOLD if showing_pick else Book.GILT)


func _pick_cost() -> int:
	return int(_oficios.restore_cost.get(OficiosDef.SILVER, 0))


## The right page on the Picareta (Oficios.restore_problem): Efeito, Estado, Próximo passo, the cost and the head by
## the button, Restaurar only when both are there.
func _refresh_pick() -> void:
	var problem := Oficios.restore_problem(_data, _oficios)
	var cost := _pick_cost()
	var have_head := Oficios.has_find(_data, _oficios.head)
	_kind.text = T.t(&"forge_pick_kind").to_upper()
	(_title.get_node("text") as Label).text = T.t(&"oficio_pick")
	_effect.text = T.t(&"forge_pick_desc")
	_cost.set_amount(cost)
	_deal.visible = problem != Oficios.DONE
	_head_line.visible = problem != Oficios.DONE
	_head_line.text = T.t(&"forge_pick_head_have" if have_head else &"forge_pick_head_missing")
	_head_line.add_theme_color_override(&"font_color", Book.OK if have_head else Book.RUBRIC)
	match problem:
		Oficios.DONE:
			_set_state(T.t(&"forge_pick_state_restored"), Book.OK)
			_step.text = T.t(&"forge_pick_step_restored")
		Oficios.NO_HEAD:
			_set_state(T.t(&"forge_pick_state_no_head"), Book.FADED)
			_step.text = T.t(&"oficio_smith_where")
		Oficios.SHORT:
			_set_state(T.t(&"oficio_smith_short", {"n": Oficios.restore_short(_data, _oficios)}), Book.WARN)
			_step.text = T.t(&"forge_step_short")
		_:
			_set_state(T.t(&"forge_pick_state_ready"), Book.INK)
			_step.text = T.t(&"forge_pick_step_ready", {"cost": cost, "have": MaterialPurse.amount(_data, MaterialPurse.SILVER)})
	if pick_view != null:
		pick_view.look = PickMark.Look.WHOLE if problem == Oficios.DONE else (PickMark.Look.HEAD if have_head else PickMark.Look.LOST)
		_pick_now.text = T.t(&"forge_pick_state_restored" if problem == Oficios.DONE else
			(&"forge_pick_state_ready" if have_head else &"forge_pick_state_none"))
	buy_button.text = T.t(&"oficio_restore")
	buy_button.disabled = problem != &""
	buy_button.focus_mode = Control.FOCUS_ALL if not buy_button.disabled else Control.FOCUS_NONE


## Restores the Picareta (Restaurar): spends its Prata, the head goes, the tool comes; writes the save and says so.
func restore() -> bool:
	if not Oficios.restore(_data, _oficios):
		return false
	if is_same(_data, Save.data):
		Save.write()
	Audio.play(&"ui_ok")
	restored.emit()
	_refresh()
	if pick_entry != null:
		pick_entry.grab_focus()
	return true


## The Refinar on an action now (null: none).
func _on_of(slot: StringName) -> ForgeRank:
	for r in forge.refine_options(slot):
		if forge.is_on(_data, r):
			return r
	return null


## The control in focus pressed (the action bar's click).
func _press_focus() -> void:
	var f := get_viewport().gui_get_focus_owner() as BaseButton
	if f != null and is_ancestor_of(f) and not f.disabled:
		f.pressed.emit()


func _set_state(text: String, color: Color) -> void:
	_state.text = text
	_state.add_theme_color_override(&"font_color", color)


## The rank before r on its track (null for the first; the Refinar's choices have none).
func _before(r: ForgeRank) -> ForgeRank:
	var i := temper_ranks.find(r)
	return temper_ranks[i - 1] if i > 0 else null


## The main button: Forjar spends, writes the save (only the game's own data), tells the hub and the focus goes on to
## the next rank; on a Refinar forged and kept, Usar puts it on its action (free) and stays on it.
func _buy() -> void:
	if showing_pick:
		restore()
		return
	if shown == null:
		return
	var r := shown
	if r.track == Forge.REFINE and forge.state(_data, r) == Forge.State.OWNED:
		if forge.is_on(_data, r) or not forge.put_on(_data, r.id):
			return
	elif not forge.buy(_data, r.id):
		return
	if is_same(_data, Save.data):
		Save.write()
	Audio.play(&"ui_ok")
	forged.emit(r.id)
	if r.track == Forge.REFINE:
		_refresh()
		_entry_of(r).grab_focus()
		return
	emeth.show_rank(Forge.temper(_data), true)
	var next := _first()
	_show(next)
	if next != null and forge.state(_data, next) != Forge.State.OWNED:
		_entry_of(next).grab_focus()
	else:
		back_button.grab_focus()
