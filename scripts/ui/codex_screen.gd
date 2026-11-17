class_name CodexScreen
extends Control
## The small Compendium (E2-11): two tabs, "Dons" (the Warrior's Gifts in the order they unlock: name and what it does
## once reached, "???" and the Mastery level before) and "Golpes" (the combos found so far, the old moves list; not yet
## landed: question marks). Opened from Como Jogar and the pause. The tabs are buttons in a row: left and right walk
## them and the focused one shows; down reaches Voltar. Only game text (no lore).

signal closed

enum Tab { GIFTS, MOVES }

const WIDTH := 900.0
const ROW_SIZE := 17
const NAME_WIDTH := 210.0
const KEYS_WIDTH := 220.0

var tab := Tab.GIFTS
var tabs: Array[Button] = []
var _list: VBoxContainer
var _legend: Label
## The save data read (Save.data in the game; tests give their own).
var _data: Dictionary


func open(start: Tab = Tab.GIFTS, data: Dictionary = {}) -> void:
	_data = data if not data.is_empty() else Save.data
	theme = UiKit.theme()
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var v := UiKit.column(self, WIDTH, 0.82)
	v.add_child(UiKit.title(T.t(&"codex_title"), 38))
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override(&"separation", 12)
	v.add_child(row)
	for t: Tab in [Tab.GIFTS, Tab.MOVES]:
		var b := UiKit.button(T.t(&"codex_tab_gifts" if t == Tab.GIFTS else &"codex_tab_moves"), Callable(), 180)
		b.name = "tab_gifts" if t == Tab.GIFTS else "tab_moves"
		b.toggle_mode = true
		b.focus_entered.connect(_show.bind(t))
		b.pressed.connect(_show.bind(t))
		tabs.append(b)
		row.add_child(b)
	var panel := PanelContainer.new()
	v.add_child(panel)
	_list = VBoxContainer.new()
	_list.add_theme_constant_override(&"separation", 3)
	panel.add_child(_list)
	_legend = UiKit.label("", UiKit.DIM, 17)
	_legend.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_legend.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	v.add_child(_legend)
	var back := UiKit.button(T.t(&"back"), func() -> void: closed.emit(), 220)
	back.name = "back"
	var c := CenterContainer.new()
	c.add_child(back)
	v.add_child(c)
	for b in tabs:
		b.focus_neighbor_bottom = b.get_path_to(back)
	back.focus_neighbor_top = back.get_path_to(tabs[0])
	_show(start)
	tabs[start].grab_focus.call_deferred()


func _show(t: Tab) -> void:
	tab = t
	for i in tabs.size():
		tabs[i].set_pressed_no_signal(i == t)
	for child in _list.get_children():
		child.free()
	if t == Tab.GIFTS:
		_gifts()
		_legend.text = T.t(&"codex_gifts_legend")
	else:
		_moves()
		_legend.text = T.t(&"moves_legend")


## Every Gift of the Warrior in the order it unlocks.
func _gifts() -> void:
	var hero := HeroDef.warrior()
	var level := hero.mastery.level_of(int(SaveData.hero(_data, String(hero.id)).mastery_xp))
	for t in hero.talents().unlocked(hero.mastery.max_level):
		var open := t.unlock_level <= level
		var row := HBoxContainer.new()
		row.name = String(t.id)
		var name := UiKit.label(T.t(t.name_key) if open else "???", TalentNode.BRANCH_COLOR[t.branch].lightened(0.2) if open else UiKit.DIM, ROW_SIZE, UiKit.BOLD_FONT)
		name.custom_minimum_size.x = NAME_WIDTH
		row.add_child(name)
		var desc := UiKit.label(T.t(t.desc_key) if open else T.t(&"codex_locked", {"n": t.unlock_level}), UiKit.PALE if open else UiKit.DIM, ROW_SIZE - 1)
		desc.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		desc.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		desc.clip_text = true
		row.add_child(desc)
		_list.add_child(row)


## The combos found so far (the old Golpes screen).
func _moves() -> void:
	var tree: ComboTree = load(HeroDef.warrior().combos)
	var words := {"dodge": T.t(&"moves_dodge"), "charge": T.t(&"moves_charge"), "charge_light": T.t(&"moves_charge_light")}
	var known: Array = _data.get("moves", [])
	for m in tree.named_moves():
		var node: ComboNode = m.node
		var found := known.has(String(node.id))
		var row := HBoxContainer.new()
		var keys := UiKit.label(ComboTree.notation(m.path, m.from_dodge, words), UiKit.GOLD if found else UiKit.DIM, 21, UiKit.BOLD_FONT)
		keys.custom_minimum_size.x = KEYS_WIDTH
		row.add_child(keys)
		row.add_child(UiKit.label(T.t(node.title) if found else "???", UiKit.PALE if found else UiKit.DIM, 21))
		_list.add_child(row)
