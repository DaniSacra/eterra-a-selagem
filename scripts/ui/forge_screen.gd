class_name ForgeScreen
extends Control
## The Forja da Emeth at the Forjador (Rejogabilidade, Fatia 1; sistemas.md 1.5 and 5.3), a spread of the Livro
## (BookSpread, Book) as the Compêndio is: the left page the forge's index (the Temperar ranks as entries, each with its
## cost, the owned ones marked) over the purse (MaterialCount.purse); the right page the rank in focus with the Livro's
## own heads: Efeito, Custo, Estado and Próximo passo, then Forjar (the main action, only when the rules let it: Forge
## problem OK) and Voltar. Forjar spends the Prata (Forge.buy), writes the save and says so (forged); everything on the
## pages reads the save again. Nothing is bought by moving the focus: the index only shows, Enter on it goes to
## Forjar. Esc and B close it (ScreenHost).
##   host.open(ForgeScreen.new(), [Save.data])          # forged(rank) after each purchase

signal closed
signal forged(rank: StringName)

const SPINE := 0.46
const OUTER := Vector2(22, 10)
const ENTRY_WIDTH := 300.0
const MARK := 22.0
const TEXT_SIZE := 18
const BUTTON_WIDTH := 190.0
## The Emeth's place on the left page and the size of the cost and the purse by the button.
const EMETH := Vector2(300, 330)
const DEAL_SIZE := 22

var forge: Forge
var ranks: Array[ForgeRank] = []
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


## data: the save data (Save.data in the game; tests give their own).
func open(data: Dictionary = {}) -> void:
	_data = data if not data.is_empty() else Save.data
	forge = Forge.new(Forge.load_catalog())
	ranks = forge.track(Forge.TEMPER)
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
	var book := BookSpread.new().setup(SPINE)
	frame.add_child(book)
	_left_page(book.left)
	_right_page(book.right)
	for e in entries:
		e.focus_neighbor_right = e.get_path_to(buy_button)
	buy_button.focus_neighbor_left = buy_button.get_path_to(entries[0] if not entries.is_empty() else buy_button)
	back_button.focus_neighbor_left = back_button.get_path_to(buy_button)
	ActionBar.attach(self, [ActionBar.entry(&"ui_accept", T.t(&"bar_choose"), _press_focus),
		ActionBar.entry(&"ui_cancel", T.t(&"bar_back"), func() -> void: closed.emit())])
	emeth.show_rank(Forge.temper(_data))
	var start := _first()
	_show(start)
	if start != null:
		entries[ranks.find(start)].grab_focus.call_deferred()
	else:
		back_button.grab_focus.call_deferred()


## The left page: the Emeth itself, the forge's piece (ciclo visual 2026-11-20, item 3; UI-HB4), with its rank of
## Temperar on the blade, the title over it and the rank it has now under it.
func _left_page(page: MarginContainer) -> void:
	var v := VBoxContainer.new()
	v.name = "index"
	v.add_theme_constant_override(&"separation", 4)
	page.add_child(v)
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


## The right page: the track's ranks as an index, the rank in focus (the next improvement, or one forged) with its
## effect, state and next step, and, by the buttons, the cost and the purse side by side (ciclo visual 2026-11-20:
## "custo e saldo perto da ação de forjar").
func _right_page(page: MarginContainer) -> void:
	var v := VBoxContainer.new()
	v.name = "rank"
	v.add_theme_constant_override(&"separation", 4)
	page.add_child(v)
	v.add_child(Book.section(T.t(&"forge_track_temper")))
	for r in ranks:
		var mark := DoorGlyph.new().setup(DoorGlyph.Kind.SILVER, MARK)
		mark.custom_minimum_size = Vector2(MARK, MARK)
		var e := Book.index_entry(T.t(r.name_key), mark, "", ENTRY_WIDTH)
		e.name = String(r.id)
		e.focus_entered.connect(_show.bind(r))
		e.pressed.connect(func() -> void:
			_show(r)
			if not buy_button.disabled:
				buy_button.grab_focus())
		entries.append(e)
		v.add_child(e)
	v.add_child(_gap(10))
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
	deal.add_theme_constant_override(&"separation", 40)
	v.add_child(deal)
	var cost := VBoxContainer.new()
	cost.add_theme_constant_override(&"separation", 2)
	cost.add_child(Book.section(T.t(&"hero_cost_head")))
	_cost = MaterialCount.new().setup(MaterialPurse.SILVER, 0, Book.INK, DEAL_SIZE, 24.0, true)
	_cost.name = "cost"
	cost.add_child(_cost)
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


static func _gap(h: float) -> Control:
	var c := Control.new()
	c.custom_minimum_size.y = h
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return c


## Where the focus starts: the rank to buy now, else the last one (all owned).
func _first() -> ForgeRank:
	for r in ranks:
		if forge.state(_data, r) != Forge.State.OWNED:
			return r
	return ranks.back() if not ranks.is_empty() else null


func _show(r: ForgeRank) -> void:
	shown = r
	_refresh()


## Everything on both pages from the save as it is now.
func _refresh() -> void:
	MaterialCount.refresh(_purse, _data)
	var silver := MaterialPurse.amount(_data, MaterialPurse.SILVER)
	for i in ranks.size():
		var r := ranks[i]
		var count := entries[i].find_child("count", false, false) as Label
		count.text = T.t(&"forge_owned") if forge.state(_data, r) == Forge.State.OWNED else str(r.cost)
		entries[i].set_pressed_no_signal(r == shown)
		count.add_theme_color_override(&"font_color", UiKit.GOLD if r == shown else Book.GILT)
	_done.visible = _first() != null and forge.state(_data, _first()) == Forge.State.OWNED
	var rank := Forge.temper(_data)
	_now.text = T.t(ranks[rank - 1].name_key) if rank > 0 and rank <= ranks.size() else T.t(&"forge_current_none")
	if shown == null:
		buy_button.disabled = true
		return
	(_title.get_node("text") as Label).text = T.t(shown.name_key)
	_kind.text = T.t(&"forge_owned" if forge.state(_data, shown) == Forge.State.OWNED else &"forge_next").to_upper()
	_effect.text = T.t(shown.desc_key)
	_cost.set_amount(shown.cost)
	var problem := forge.problem(_data, shown)
	var before := _before(shown)
	match problem:
		Forge.Problem.OWNED:
			_set_state(T.t(&"forge_state_owned"), Book.OK)
			_step.text = T.t(&"forge_step_owned")
		Forge.Problem.NEEDS:
			_set_state(T.t(&"forge_state_needs", {"name": T.t(before.name_key) if before else ""}), Book.FADED)
			_step.text = T.t(&"forge_step_needs", {"name": T.t(before.name_key) if before else ""})
		Forge.Problem.SHORT:
			_set_state(T.t(&"forge_short", {"n": shown.cost - silver, "name": T.t(shown.name_key)}), Book.WARN)
			_step.text = T.t(&"forge_step_short")
		_:
			_set_state(T.t(&"forge_state_ready"), Book.INK)
			_step.text = T.t(&"forge_step_buy", {"cost": shown.cost, "have": silver})
	buy_button.disabled = problem != Forge.Problem.OK
	buy_button.focus_mode = Control.FOCUS_ALL if not buy_button.disabled else Control.FOCUS_NONE


## The control in focus pressed (the action bar's click).
func _press_focus() -> void:
	var f := get_viewport().gui_get_focus_owner() as BaseButton
	if f != null and is_ancestor_of(f) and not f.disabled:
		f.pressed.emit()


func _set_state(text: String, color: Color) -> void:
	_state.text = text
	_state.add_theme_color_override(&"font_color", color)


## The rank before r on its track (null for the first).
func _before(r: ForgeRank) -> ForgeRank:
	var i := ranks.find(r)
	return ranks[i - 1] if i > 0 else null


## Forjar: spends, writes the save (only the game's own data), tells the hub; the focus goes on to the next rank.
func _buy() -> void:
	if shown == null or not forge.buy(_data, shown.id):
		return
	if is_same(_data, Save.data):
		Save.write()
	Audio.play(&"ui_ok")
	var bought := shown.id
	emeth.show_rank(Forge.temper(_data), true)
	forged.emit(bought)
	var next := _first()
	_show(next)
	if next != null and forge.state(_data, next) != Forge.State.OWNED:
		entries[ranks.find(next)].grab_focus()
	else:
		back_button.grab_focus()
