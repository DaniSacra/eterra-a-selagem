class_name CodexScreen
extends Control
## The Compendium: four tabs. "Dons" (E2-11: the Warrior's Gifts in the order they unlock: name and what it does once
## reached, "???" and the Mastery level before), "Bênçãos" and "Elos" (E3-03: every Blessing and Elo of the game, the
## ones already met with their name, family or recipe and how many times, the rest as "???"; counts from the save's
## codex.boons "seen" and codex.elos "formed") and "Golpes" (the combos found so far, the old moves list; not yet
## landed: question marks). Opened from Como Jogar and the pause. The tabs are buttons in a row: left and right walk
## them and the focused one shows; down reaches Voltar. Only game text (no lore).

signal closed

## In the order of the buttons (the index of each tab is its button's).
enum Tab { GIFTS, BOONS, ELOS, MOVES }

const TAB_KEY: Array[StringName] = [&"codex_tab_gifts", &"codex_tab_boons", &"codex_tab_elos", &"codex_tab_moves"]
const TAB_NAME: Array[String] = ["tab_gifts", "tab_boons", "tab_elos", "tab_moves"]
const WIDTH := 900.0
const TAB_WIDTH := 170.0
const ROW_SIZE := 17
const NAME_WIDTH := 210.0
const KEYS_WIDTH := 220.0
## Blessings: two columns of one line each (icon, name, family, count), so the 26 fit a 720 screen.
const BOON_COLUMNS := 2
const BOON_ICON := 24.0
const BOON_NAME_WIDTH := 190.0
const CELL_GAP := 28
## Elos: the drawn chain (Elo and its two sources) once formed, a closed diamond before.
const ELO_BIG := 30.0
const ELO_SMALL := 20.0
const ELO_GAP := 8.0
const ELO_NAME_WIDTH := 170.0
const UNKNOWN := "???"

var tab := Tab.GIFTS
var tabs: Array[Button] = []
var _list: VBoxContainer
var _legend: Label
## The save data read (Save.data in the game; tests give their own).
var _data: Dictionary
## Every gift of the game (Blessings and Elos), loaded once when a tab needs it.
var _catalog: BoonState


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
	for t: int in Tab.values():
		var b := UiKit.button(T.t(TAB_KEY[t]), Callable(), TAB_WIDTH)
		b.name = TAB_NAME[t]
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
	match t:
		Tab.GIFTS:
			_gifts()
			_legend.text = T.t(&"codex_gifts_legend")
		Tab.BOONS:
			var met := _boons()
			_legend.text = T.t(&"codex_boons_legend", {"n": met.x, "total": met.y})
		Tab.ELOS:
			var met := _elos()
			_legend.text = T.t(&"codex_elos_legend", {"n": met.x, "total": met.y})
		_:
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
		var name := UiKit.label(T.t(t.name_key) if open else UNKNOWN, TalentNode.BRANCH_COLOR[t.branch].lightened(0.2) if open else UiKit.DIM, ROW_SIZE, UiKit.BOLD_FONT)
		name.custom_minimum_size.x = NAME_WIDTH
		row.add_child(name)
		var desc := UiKit.label(T.t(t.desc_key) if open else T.t(&"codex_locked", {"n": t.unlock_level}), UiKit.PALE if open else UiKit.DIM, ROW_SIZE - 1)
		desc.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		desc.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		desc.clip_text = true
		row.add_child(desc)
		_list.add_child(row)


## The game's gifts (Elos or not), by family and then by name, as they are in data/boons.
func catalog(elos: bool) -> Array[Boon]:
	if _catalog == null:
		_catalog = BoonState.new(BoonState.load_catalog())
	var out: Array[Boon] = []
	for b in _catalog.catalog:
		if b.is_duo() == elos:
			out.append(b)
	out.sort_custom(func(a: Boon, b: Boon) -> bool:
		if a.family != b.family:
			return a.family < b.family
		return T.t("boon_" + String(a.id)) < T.t("boon_" + String(b.id)))
	return out


## How many times the save counted what for an id in a Codex section (0: never).
func count(section: String, id: StringName, what: String) -> int:
	var entries: Dictionary = _data.get("codex", {}).get(section, {})
	var entry: Variant = entries.get(String(id), {})
	return int((entry as Dictionary).get(what, 0)) if entry is Dictionary else 0


## Every Blessing in two columns read top to bottom (by family, then name): medallion, name and family once met
## (offered at least once), "???" before; how many times. Returns (met, total).
func _boons() -> Vector2i:
	var cols := HBoxContainer.new()
	cols.add_theme_constant_override(&"separation", CELL_GAP)
	_list.add_child(cols)
	var met := 0
	var all := catalog(false)
	var per := ceili(float(all.size()) / BOON_COLUMNS)
	for i in all.size():
		var b := all[i]
		if i % per == 0:
			var col := VBoxContainer.new()
			col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			col.add_theme_constant_override(&"separation", 2)
			cols.add_child(col)
		var n := count("boons", b.id, "seen")
		met += 1 if n > 0 else 0
		var row := HBoxContainer.new()
		row.name = String(b.id)
		row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_theme_constant_override(&"separation", 8)
		row.add_child(_medallion(b if n > 0 else null, BOON_ICON))
		var name := UiKit.label(T.t("boon_" + String(b.id)) if n > 0 else UNKNOWN, b.color().lightened(0.3) if n > 0 else UiKit.DIM, ROW_SIZE, UiKit.BOLD_FONT)
		name.name = &"Name"
		name.custom_minimum_size.x = BOON_NAME_WIDTH
		name.clip_text = true
		name.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		row.add_child(name)
		var fam := UiKit.label(T.t(Boon.FAMILY_KEY[b.family]) if n > 0 else "", UiKit.DIM, ROW_SIZE - 2)
		fam.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		fam.clip_text = true
		fam.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		row.add_child(fam)
		row.add_child(_times(n))
		cols.get_child(cols.get_child_count() - 1).add_child(row)
	return Vector2i(met, all.size())


## Every Elo, one line each: the chain with its two Blessings and its name once formed; before, "???" and the recipe
## only when both Blessings were already met (a hint, never the Elo's name). Returns (formed, total).
func _elos() -> Vector2i:
	var met := 0
	var all := catalog(true)
	for b in all:
		var n := count("elos", b.id, "formed")
		met += 1 if n > 0 else 0
		var from := _catalog.sources(b)
		var row := HBoxContainer.new()
		row.name = String(b.id)
		row.add_theme_constant_override(&"separation", 12)
		var art := Control.new()
		art.custom_minimum_size = Vector2(ELO_BIG + (ELO_SMALL + ELO_GAP) * 2.0, ELO_BIG)
		art.mouse_filter = Control.MOUSE_FILTER_IGNORE
		if n > 0:
			art.add_child(EloLink.new().setup(b, from, ELO_BIG, ELO_SMALL, ELO_GAP))
		else:
			var lock := _medallion(null, ELO_BIG)
			lock.position = Vector2(ELO_SMALL + ELO_GAP, 0.0)
			art.add_child(lock)
		row.add_child(art)
		var name := UiKit.label(T.t("boon_" + String(b.id)) if n > 0 else UNKNOWN, EloLink.METAL_LIT if n > 0 else UiKit.DIM, ROW_SIZE, UiKit.BOLD_FONT)
		name.name = &"Name"
		name.custom_minimum_size.x = ELO_NAME_WIDTH
		row.add_child(name)
		var known := from.size() == 2 and from.all(func(s: Boon) -> bool: return count("boons", s.id, "seen") > 0)
		var recipe := UiKit.label(EloLink.caption(from) if n > 0 or known else UNKNOWN, UiKit.PALE if n > 0 else UiKit.DIM, ROW_SIZE - 1)
		recipe.name = &"Recipe"
		recipe.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		recipe.clip_text = true
		recipe.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		row.add_child(recipe)
		row.add_child(_times(n))
		_list.add_child(row)
	return Vector2i(met, all.size())


## A gift's drawn medallion, or a closed one (a dim diamond on dark ground) for what was not met.
func _medallion(b: Boon, size_px: float) -> Control:
	if b != null:
		return BoonIcon.new().setup(b, size_px)
	var c := Control.new()
	c.custom_minimum_size = Vector2(size_px, size_px)
	c.size = c.custom_minimum_size
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	c.draw.connect(func() -> void:
		var m := c.size * 0.5
		var r := minf(c.size.x, c.size.y) * 0.46
		c.draw_circle(m, r, Color(0.08, 0.07, 0.09))
		c.draw_arc(m, r, 0.0, TAU, 24, Color(UiKit.OLD_GOLD, 0.6), 1.5, true)
		var d := r * 0.4
		c.draw_colored_polygon(PackedVector2Array([m + Vector2(0, -d), m + Vector2(d, 0), m + Vector2(0, d), m + Vector2(-d, 0)]), Color(UiKit.DIM, 0.5)))
	return c


## How many times, right aligned ("3x"); nothing before the first.
func _times(n: int) -> Label:
	var l := UiKit.label(T.t(&"codex_times", {"n": n}) if n > 0 else "", UiKit.GOLD, ROW_SIZE - 2)
	l.name = &"Times"
	l.custom_minimum_size.x = 34.0
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	return l


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
		row.add_child(UiKit.label(T.t(node.title) if found else UNKNOWN, UiKit.PALE if found else UiKit.DIM, 21))
		_list.add_child(row)
