class_name CodexScreen
extends Control
## The Compendium: four tabs. "Dons" (E2-11: the Warrior's Gifts in the order they unlock: name and what it does once
## reached, "???" and the Mastery level before), "Bênçãos" and "Elos" (E3-03: every Blessing and Elo of the game, the
## ones already met with their name, family or recipe and how many times, the rest as "???"; counts from the save's
## codex.boons "seen" and codex.elos "formed") and "Golpes" (the combos found so far, the old moves list; not yet
## landed: question marks). E4-05: "Salmos" (found: medallion, name and what it does; not found: a closed seal and the
## hint of what it asks, hint_key), "Inimigos" (each kind with its part in a fight and how many fell, elites apart;
## never defeated: "???"), "Morvath" (the four phases, named once reached) and "Arenas" (the rooms entered). Counts
## from the save's codex (psalms seen and taken, enemies, arenas). Opened from Como Jogar and the pause. Art pack stage
## 2 (board 04): the Compendium is a page of the Livro de Ahk (BookSpread, Book): the left page is the index, one entry
## per chapter with its ink mark (CodexMark) and how much of it was found (progress); the right page the chapter's name
## and its list in ink, the legend under it and Voltar. Up and down walk the index and the focused entry shows; right
## reaches Voltar. Only game text (D-62 a: no lore).

signal closed

## In the order of the buttons (the index of each tab is its button's).
enum Tab { GIFTS, BOONS, ELOS, PSALMS, ENEMIES, MORVATH, ARENAS, ANGELS, MOVES }

const TAB_KEY: Array[StringName] = [&"codex_tab_gifts", &"codex_tab_boons", &"codex_tab_elos", &"codex_tab_psalms",
	&"codex_tab_enemies", &"codex_tab_morvath", &"codex_tab_arenas", &"codex_tab_angels", &"codex_tab_moves"]
const TAB_NAME: Array[String] = ["tab_gifts", "tab_boons", "tab_elos", "tab_psalms", "tab_enemies", "tab_morvath",
	"tab_arenas", "tab_angels", "tab_moves"]
## The spine: the index page narrower than the list's.
const SPINE := 0.3
const OUTER := Vector2(22, 10)
## The index entries' width and their marks.
const TAB_WIDTH := 270.0
const MARK := 24.0
## The enemies of the region in the order a descent meets them, the guardians last (Morvath has his own tab).
const ENEMIES: Array[StringName] = [&"skeleton", &"runner", &"mage", &"archer", &"guard", &"priest", &"knight", &"priest_elder"]
const ENEMY_DIR := "res://data/enemies/"
const STAGE := "res://data/stages/catacombs.tres"
const BOSS := &"morvath"
const PHASES := 4
const PSALM_ICON := 34.0
const PSALM_ROW := 50.0
const PSALM_NAME_WIDTH := 220.0
const ENEMY_NAME_WIDTH := 206.0
const ROLE_WIDTH := 300.0
const ROW_SIZE := 17
const NAME_WIDTH := 170.0
## The Gifts' rows carry the tree's own node (TalentGlyph.mark), this wide.
const GIFT_MARK := 22.0
## The Inimigos' and Dons' rows (UI review d2ff05d, P2-5): at least this tall, a mark first (RoleMark, TalentGlyph).
const LIST_ROW := 34.0
const ROLE_MARK := 22.0
const KEYS_WIDTH := 240.0
## The HUD marks of a move's inputs (Golpes).
const MOVE_MARK := 28.0
## Blessings: two columns of one line each (icon, name, family, count), so the 26 fit a 720 screen.
const BOON_COLUMNS := 2
const BOON_ICON := 24.0
const BOON_NAME_WIDTH := 190.0
const CELL_GAP := 28
## Elos: the drawn chain (Elo and its two sources) once formed, a closed diamond before.
const ELO_BIG := 30.0
const ELO_SMALL := 20.0
const ELO_GAP := 8.0
## Angels: the seal beside the words, and the row's height.
const ANGEL_SEAL := 44.0
const ANGEL_ROW := 58.0
const ELO_NAME_WIDTH := 170.0
const UNKNOWN := "???"
## The detail's figure on the index page, and the Gift's mark there.
const FIGURE := Vector2(130, 170)
const DETAIL_MARK := 96.0
const DETAIL_TEXT := 15
## The selected row's ink wash.
const ROW_LIT := Color(0.42, 0.3, 0.16, 0.16)

var tab := Tab.GIFTS
var tabs: Array[Button] = []
var _list: VBoxContainer
## The list scrolls when it is taller than the page (QW-114: every line whole, no "..." cut, at 720 too): the wheel,
## or right from the index and then up and down (left goes back to the index, down past the end to Voltar).
var _scroll: ScrollContainer
var _back: Button
var _legend: Label
## The right page's heading (the chapter on show).
var _chapter: VBoxContainer
## The save data read (Save.data in the game; tests give their own).
var _data: Dictionary
## Every gift of the game (Blessings and Elos), loaded once when a tab needs it.
var _catalog: BoonState
## The selected entry's detail on the index page (ciclo visual 2026-11-20, item 3): the enemy's own figure
## (FigureView) or the Gift's mark large, its name and line. Only the chapters with a figure (Inimigos, Dons).
var detail: VBoxContainer
var figure: FigureView
var _detail_mark: Control
var _detail_name: Label
var _detail_line: Label
## The entry selected now (its row's name: the enemy's or Gift's id).
var selected := &""


func open(start: Tab = Tab.GIFTS, data: Dictionary = {}) -> void:
	_data = data if not data.is_empty() else Save.data
	theme = Book.theme()
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var shade := ColorRect.new()
	shade.color = Color(0.01, 0.0, 0.02, 0.86)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(shade)
	var frame := MarginContainer.new()
	frame.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	frame.add_theme_constant_override(&"margin_left", int(OUTER.x))
	frame.add_theme_constant_override(&"margin_right", int(OUTER.x))
	frame.add_theme_constant_override(&"margin_top", int(OUTER.y))
	frame.add_theme_constant_override(&"margin_bottom", int(ActionBar.RESERVE))
	add_child(frame)
	var book := BookSpread.new().setup(SPINE)
	frame.add_child(book)
	var index := VBoxContainer.new()
	index.name = "index"
	index.add_theme_constant_override(&"separation", 4)
	book.left.add_child(index)
	var head := Book.heading(T.t(&"codex_title"), 30, 220)
	index.add_child(head)
	var gap := Control.new()
	gap.custom_minimum_size.y = 6
	index.add_child(gap)
	for t: int in Tab.values():
		var mark := CodexMark.new()
		mark.kind = t
		mark.custom_minimum_size = Vector2(MARK, MARK)
		var p := progress(t)
		var b := Book.index_entry(T.t(TAB_KEY[t]), mark, T.t(&"codex_count", {"n": p.x, "total": p.y}), TAB_WIDTH)
		b.name = TAB_NAME[t]
		b.text = T.t(TAB_KEY[t])
		b.focus_entered.connect(_show.bind(t))
		b.pressed.connect(_show.bind(t))
		tabs.append(b)
		index.add_child(b)
	index.add_child(_detail_block())
	var page := VBoxContainer.new()
	page.add_theme_constant_override(&"separation", 8)
	book.right.add_child(page)
	_chapter = Book.heading("", 28, 300)
	page.add_child(_chapter)
	_list = VBoxContainer.new()
	_list.name = "list"
	_list.add_theme_constant_override(&"separation", 3)
	_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_scroll = ScrollContainer.new()
	_scroll.name = "scroll"
	_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_scroll.follow_focus = true
	_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_scroll.focus_mode = Control.FOCUS_ALL
	_scroll.add_theme_stylebox_override(&"panel", StyleBoxEmpty.new())
	_scroll.add_theme_stylebox_override(&"focus", UiKit.box(Color(0, 0, 0, 0), Book.GILT, 1, 4))
	_scroll.focus_entered.connect(_scroll_focused)
	_scroll.gui_input.connect(_scroll_keys)
	_scroll.add_child(_list)
	UiKit.scroll_fade(_scroll, Book.PAPER)
	page.add_child(_scroll)
	_legend = Book.text("", Book.FADED, 16)
	page.add_child(_legend)
	var foot := HBoxContainer.new()
	foot.alignment = BoxContainer.ALIGNMENT_END
	page.add_child(foot)
	var back := Book.button(T.t(&"back"), func() -> void: closed.emit(), 200)
	back.name = "back"
	foot.add_child(back)
	_back = back
	for b in tabs:
		b.focus_neighbor_right = b.get_path_to(_scroll)
	back.focus_neighbor_left = back.get_path_to(tabs[0])
	back.focus_neighbor_top = back.get_path_to(tabs[0])
	_show(start)
	tabs[start].grab_focus.call_deferred()
	# the keys at the foot (benchmark P0-2): the chapters on the left, the way back on the right
	ActionBar.attach(self, [
		ActionBar.entry(&"tab_prev", T.t(&"bar_prev"), func() -> void: _turn(-1), true),
		ActionBar.entry(&"tab_next", T.t(&"bar_next"), func() -> void: _turn(1), true),
		ActionBar.entry(&"ui_cancel", T.t(&"bar_back"), func() -> void: closed.emit())])


## The chapter before (-1) or after (1) in the index, as LB and RB.
func _turn(step: int) -> void:
	var t := clampi(tab + step, 0, tabs.size() - 1)
	if t != tab:
		tabs[t].grab_focus()
		_show(t as Tab)


## LB and RB (PageUp, PageDown) walk the index (DT-103).
func _unhandled_input(event: InputEvent) -> void:
	if UiKit.step_tabs(event, tabs, tab):
		get_viewport().set_input_as_handled()


## Whether the list on show is taller than its page.
func scrolls() -> bool:
	var bar := _scroll.get_v_scroll_bar()
	return bar.max_value > bar.page + 0.5


## Right from the index: into the first row that can be picked, else into the list when it scrolls, else to Voltar.
func _scroll_focused() -> void:
	var first := _first_row()
	if first != null:
		first.grab_focus.call_deferred()
	elif not scrolls():
		_back.grab_focus.call_deferred()


const SCROLL_STEP := 60


func _scroll_keys(event: InputEvent) -> void:
	var bar := _scroll.get_v_scroll_bar()
	if event.is_action_pressed(&"ui_down"):
		if _scroll.scroll_vertical >= int(bar.max_value - bar.page) - 1:
			_back.grab_focus()
		else:
			_scroll.scroll_vertical += SCROLL_STEP
	elif event.is_action_pressed(&"ui_up"):
		_scroll.scroll_vertical -= SCROLL_STEP
	elif event.is_action_pressed(&"ui_left"):
		tabs[tab].grab_focus()
	elif event.is_action_pressed(&"ui_right"):
		_back.grab_focus()
	else:
		return
	_scroll.accept_event()


func _show(t: Tab) -> void:
	tab = t
	for i in tabs.size():
		tabs[i].set_pressed_no_signal(i == t)
		var on := i == t
		(tabs[i].find_child("count", false, false) as Label).add_theme_color_override(&"font_color", UiKit.GOLD if on else Book.GILT)
		var mark := tabs[i].get_child(0) as CodexMark
		mark.color = UiKit.PALE if on else Book.INK
		mark.queue_redraw()
	var back := find_child("back", true, false) as Button
	if back:
		back.focus_neighbor_left = back.get_path_to(tabs[t])
		back.focus_neighbor_top = back.get_path_to(tabs[t])
	(_chapter.get_node("text") as Label).text = T.t(TAB_KEY[t])
	for child in _list.get_children():
		child.free()
	if _scroll:
		_scroll.scroll_vertical = 0
	var p := progress(t)
	var counts := {"n": p.x, "total": p.y}
	match t:
		Tab.GIFTS:
			_gifts()
			_legend.text = T.t(&"codex_gifts_legend")
		Tab.BOONS:
			_boons()
			_legend.text = T.t(&"codex_boons_legend", counts)
		Tab.ELOS:
			_elos()
			_legend.text = T.t(&"codex_elos_legend", counts)
		Tab.PSALMS:
			_psalms()
			_legend.text = T.t(&"codex_psalms_legend", counts)
		Tab.ENEMIES:
			_enemies()
			_legend.text = T.t(&"codex_enemies_legend", counts)
		Tab.MORVATH:
			_morvath()
			_legend.text = T.t(&"codex_morvath_legend")
		Tab.ARENAS:
			_arenas()
			_legend.text = T.t(&"codex_arenas_legend", counts)
		Tab.ANGELS:
			_angels()
			_legend.text = T.t(&"codex_angels_legend")
		_:
			_moves()
			_legend.text = T.t(&"moves_legend")
	_pickable()


## The detail block under the index: a rule, then the figure (or the Gift's mark) beside its name and line.
func _detail_block() -> Control:
	detail = VBoxContainer.new()
	detail.name = "detail"
	detail.size_flags_vertical = Control.SIZE_EXPAND_FILL
	detail.alignment = BoxContainer.ALIGNMENT_END
	detail.add_theme_constant_override(&"separation", 4)
	detail.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var rule := GoldRule.new()
	rule.tint = Book.GILT
	rule.custom_minimum_size = Vector2(200, 10)
	detail.add_child(rule)
	var row := HBoxContainer.new()
	row.add_theme_constant_override(&"separation", 12)
	detail.add_child(row)
	var art := CenterContainer.new()
	art.name = "art"
	art.custom_minimum_size = FIGURE
	row.add_child(art)
	figure = FigureView.new().setup(FIGURE)
	art.add_child(figure)
	var words := VBoxContainer.new()
	words.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	words.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_child(words)
	_detail_name = Book.label("", Book.INK, 20, UiKit.TITLE_FONT)
	_detail_name.name = "detail_name"
	_detail_name.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	words.add_child(_detail_name)
	_detail_line = Book.text("", Book.FADED, DETAIL_TEXT)
	_detail_line.name = "detail_line"
	words.add_child(_detail_line)
	detail.visible = false
	return detail


## The rows of the chapter on show that can be picked (Inimigos, Dons): focus and the mouse select them, the first one
## at the start; left goes back to the index, right to Voltar.
func _pickable() -> void:
	if detail == null:
		return
	var rows := _list.get_children().filter(func(r: Node) -> bool: return tab in [Tab.ENEMIES, Tab.GIFTS])
	detail.visible = not rows.is_empty()
	for i in rows.size():
		var r := rows[i] as Control
		r.focus_mode = Control.FOCUS_ALL
		r.mouse_filter = Control.MOUSE_FILTER_STOP
		var id := StringName(r.name)
		r.focus_entered.connect(_select.bind(id))
		r.focus_entered.connect(r.queue_redraw)
		r.focus_exited.connect(r.queue_redraw)
		r.mouse_entered.connect(r.grab_focus)
		r.draw.connect(func() -> void:
			if selected == id:
				r.draw_rect(Rect2(Vector2(-6, 0), r.size + Vector2(12, 0)), ROW_LIT)
				r.draw_line(Vector2(-6, 0), Vector2(-6, r.size.y), Book.GILT, 2.0))
		r.focus_neighbor_left = r.get_path_to(tabs[tab])
		r.focus_neighbor_right = r.get_path_to(_back)
		if i == rows.size() - 1:
			r.focus_neighbor_bottom = r.get_path_to(_back)
	if not rows.is_empty():
		_select(StringName(rows[0].name))


func _first_row() -> Control:
	for r in _list.get_children():
		if (r as Control).focus_mode == Control.FOCUS_ALL:
			return r
	return null


## Shows an entry's detail: an enemy's figure (a silhouette before it falls once), a Gift's mark large.
func _select(id: StringName) -> void:
	selected = id
	for r in _list.get_children():
		(r as Control).queue_redraw()
	if _detail_mark != null:
		_detail_mark.queue_free()
		_detail_mark = null
	if tab == Tab.ENEMIES:
		var def: EnemyDef = load(ENEMY_DIR + String(id) + ".tres")
		var known := count("enemies", id, "defeated") > 0
		figure.visible = true
		figure.show_enemy(def, known)
		_detail_name.text = enemy_name(def) if known else UNKNOWN
		_detail_line.text = T.t(role_key(def)) if known else T.t(&"codex_unknown_enemy")
	elif tab == Tab.GIFTS:
		var hero := HeroDef.warrior()
		var level := hero.mastery.level_of(int(SaveData.hero(_data, String(hero.id)).mastery_xp))
		var t: TalentDef = null
		for x in hero.talents().catalog:
			if x.id == id:
				t = x
		if t == null:
			return
		var open := t.unlock_level <= level
		figure.visible = false
		_detail_mark = TalentGlyph.mark(t, DETAIL_MARK, open)
		figure.get_parent().add_child(_detail_mark)
		_detail_name.text = T.t(t.name_key) if open else UNKNOWN
		_detail_line.text = T.t(t.desc_key) if open else T.t(&"codex_locked", {"n": t.unlock_level})


## How much of a chapter was found: (found, total). Gifts: reached by the Mastery; Blessings: met; Elos: formed;
## Psalms: found; enemies: defeated; Morvath: phases reached; arenas: entered; moves: landed.
func progress(t: Tab) -> Vector2i:
	match t:
		Tab.GIFTS:
			var hero := HeroDef.warrior()
			var level := hero.mastery.level_of(int(SaveData.hero(_data, String(hero.id)).mastery_xp))
			var all := hero.talents().unlocked(hero.mastery.max_level)
			return Vector2i(all.filter(func(x: TalentDef) -> bool: return x.unlock_level <= level).size(), all.size())
		Tab.BOONS:
			var all := catalog(false)
			return Vector2i(all.filter(func(b: Boon) -> bool: return count("boons", b.id, "seen") > 0).size(), all.size())
		Tab.ELOS:
			var all := catalog(true)
			return Vector2i(all.filter(func(b: Boon) -> bool: return count("elos", b.id, "formed") > 0).size(), all.size())
		Tab.PSALMS:
			var all := Psalms.load_catalog()
			return Vector2i(all.filter(func(p: PsalmDef) -> bool: return _psalm_found(p)).size(), all.size())
		Tab.ENEMIES:
			return Vector2i(ENEMIES.filter(func(id: StringName) -> bool: return count("enemies", id, "defeated") > 0).size(), ENEMIES.size())
		Tab.MORVATH:
			return Vector2i(mini(count("enemies", BOSS, "phase"), PHASES), PHASES)
		Tab.ARENAS:
			var ids := arena_ids()
			return Vector2i(ids.filter(func(id: StringName) -> bool: return count("arenas", id, "entered") > 0).size(), ids.size())
		Tab.ANGELS:
			var c := AngelCodex.count(_data)
			return Vector2i(c[0], c[1])
	var tree: ComboTree = load(HeroDef.warrior().combos)
	var known: Array = _data.get("moves", [])
	var named := tree.named_moves()
	return Vector2i(named.filter(func(m: Variant) -> bool: return known.has(String((m.node as ComboNode).id))).size(), named.size())


func _psalm_found(p: PsalmDef) -> bool:
	return count("psalms", p.id, "seen") > 0 or count("psalms", p.id, "taken") > 0


## Every Gift of the Warrior in the order it unlocks.
func _gifts() -> void:
	var hero := HeroDef.warrior()
	var level := hero.mastery.level_of(int(SaveData.hero(_data, String(hero.id)).mastery_xp))
	for t in hero.talents().unlocked(hero.mastery.max_level):
		var open := t.unlock_level <= level
		var row := HBoxContainer.new()
		row.name = String(t.id)
		row.custom_minimum_size.y = LIST_ROW
		row.add_theme_constant_override(&"separation", 10)
		row.add_child(TalentGlyph.mark(t, GIFT_MARK, open))
		var name := UiKit.label(T.t(t.name_key) if open else UNKNOWN, Book.ink(TalentNode.BRANCH_COLOR[t.branch]) if open else Book.FADED, ROW_SIZE, UiKit.BOLD_FONT)
		name.name = &"Name"
		name.custom_minimum_size.x = NAME_WIDTH
		row.add_child(name)
		var desc := UiKit.label(T.t(t.desc_key) if open else T.t(&"codex_locked", {"n": t.unlock_level}), Book.INK if open else Book.FADED, ROW_SIZE - 1)
		desc.name = &"Desc"
		desc.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
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
## (offered at least once), "???" before; how many times.
func _boons() -> void:
	var cols := HBoxContainer.new()
	cols.add_theme_constant_override(&"separation", CELL_GAP)
	_list.add_child(cols)
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
		var row := HBoxContainer.new()
		row.name = String(b.id)
		row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_theme_constant_override(&"separation", 8)
		row.add_child(_medallion(b if n > 0 else null, BOON_ICON))
		var name := UiKit.label(T.t("boon_" + String(b.id)) if n > 0 else UNKNOWN, Book.ink(b.color()) if n > 0 else Book.FADED, ROW_SIZE, UiKit.BOLD_FONT)
		name.name = &"Name"
		name.custom_minimum_size.x = BOON_NAME_WIDTH
		name.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		row.add_child(name)
		var fam := UiKit.label(T.t(Boon.FAMILY_KEY[b.family]) if n > 0 else "", Book.FADED, ROW_SIZE - 2)
		fam.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		fam.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		row.add_child(fam)
		row.add_child(_times(n))
		cols.get_child(cols.get_child_count() - 1).add_child(row)


## Every Elo, one line each: the chain with its two Blessings and its name once formed; before, "???" and the recipe
## only when both Blessings were already met (a hint, never the Elo's name).
func _elos() -> void:
	var all := catalog(true)
	for b in all:
		var n := count("elos", b.id, "formed")
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
		var name := UiKit.label(T.t("boon_" + String(b.id)) if n > 0 else UNKNOWN, Book.INK if n > 0 else Book.FADED, ROW_SIZE, UiKit.BOLD_FONT)
		name.name = &"Name"
		name.custom_minimum_size.x = ELO_NAME_WIDTH
		row.add_child(name)
		var known := from.size() == 2 and from.all(func(s: Boon) -> bool: return count("boons", s.id, "seen") > 0)
		var recipe := UiKit.label(EloLink.caption(from) if n > 0 or known else UNKNOWN, Book.INK if n > 0 else Book.FADED, ROW_SIZE - 1)
		recipe.name = &"Recipe"
		recipe.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		recipe.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		row.add_child(recipe)
		row.add_child(_times(n))
		_list.add_child(row)


## Every Psalm: found (seen on a card once) its medallion, name, what it does and how many times it was taken; not
## found a closed seal, "???" and the hint of what it asks (hint_key).
func _psalms() -> void:
	var all := Psalms.load_catalog()
	for p in all:
		var found := count("psalms", p.id, "seen") > 0 or count("psalms", p.id, "taken") > 0
		var row := HBoxContainer.new()
		row.name = String(p.id)
		row.add_theme_constant_override(&"separation", 12)
		row.custom_minimum_size.y = PSALM_ROW
		var icon := PsalmIcon.new().setup(p if found else null, PSALM_ICON)
		icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		row.add_child(icon)
		var text := VBoxContainer.new()
		text.add_theme_constant_override(&"separation", 0)
		text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(text)
		var name := UiKit.label(T.t(p.name_key) if found else UNKNOWN, Book.ink(PsalmIcon.tint(p)) if found else Book.FADED, ROW_SIZE, UiKit.BOLD_FONT)
		name.name = &"Name"
		text.add_child(name)
		var desc := UiKit.label(T.t(p.desc_key, p.text_args()) if found else T.t(&"codex_psalm_hint", {"hint": T.t(p.hint_key)}), Book.INK if found else Book.FADED, ROW_SIZE - 2)
		desc.name = &"Desc"
		desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		text.add_child(desc)
		row.add_child(_times(count("psalms", p.id, "taken")))
		_list.add_child(row)


## The region's enemies (ENEMIES): name, part in a fight and how many fell (elites apart) once one was defeated;
## "???" before.
func _enemies() -> void:
	for id in ENEMIES:
		var def: EnemyDef = load(ENEMY_DIR + String(id) + ".tres")
		var n := count("enemies", id, "defeated")
		var row := HBoxContainer.new()
		row.name = String(id)
		row.custom_minimum_size.y = LIST_ROW
		row.add_theme_constant_override(&"separation", 12)
		var mark := RoleMark.new().setup(def.role if def.role != &"" else &"guardian", ROLE_MARK, n <= 0)
		mark.name = &"Mark"
		row.add_child(mark)
		var name := UiKit.label(enemy_name(def) if n > 0 else UNKNOWN, Book.INK if n > 0 else Book.FADED, ROW_SIZE, UiKit.BOLD_FONT)
		name.name = &"Name"
		name.custom_minimum_size.x = ENEMY_NAME_WIDTH
		row.add_child(name)
		var role := UiKit.label(T.t(role_key(def)) if n > 0 else "", Book.FADED, ROW_SIZE - 1)
		role.name = &"Role"
		role.custom_minimum_size.x = ROLE_WIDTH
		row.add_child(role)
		var elite := count("enemies", id, "elite")
		var tally := UiKit.label(T.t(&"codex_defeated" if n != 1 else &"codex_defeated_one", {"n": n}) if n > 0 else "", Book.FADED, ROW_SIZE - 2, UiKit.number_font())
		tally.name = &"Times"
		tally.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		tally.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		if elite > 0:
			tally.text += " · " + T.t(&"codex_defeated_elite", {"n": elite})
		row.add_child(tally)
		_list.add_child(row)


## An enemy's name in the Codex: its own key when the game shares one between two kinds (the elder priest).
static func enemy_name(def: EnemyDef) -> String:
	var own := StringName("codex_enemy_" + String(def.id))
	var text := T.t(own)
	return T.t(def.name_key) if text == String(own) else text


## The key of an enemy's part in a fight (EnemyDef.role); the guardians have none.
static func role_key(def: EnemyDef) -> StringName:
	return StringName("codex_role_" + (String(def.role) if def.role != &"" else "guardian"))


## Morvath: his name and how many times he was faced and sealed once met, then his four phases, named (and the line
## of each) once reached; "???" before.
func _morvath() -> void:
	var met := count("enemies", BOSS, "met")
	var reached := count("enemies", BOSS, "phase")
	var head := HBoxContainer.new()
	head.name = &"head"
	head.add_theme_constant_override(&"separation", 12)
	var name := UiKit.label(T.t(&"enemy_morvath") if met > 0 else UNKNOWN, Book.INK if met > 0 else Book.FADED, ROW_SIZE + 2, UiKit.BOLD_FONT)
	name.name = &"Name"
	name.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(name)
	if met > 0:
		var won := count("enemies", BOSS, "defeated")
		var tally := UiKit.label(T.t(&"codex_morvath_count" if won > 0 else &"codex_morvath_met", {"met": met, "won": won}), Book.GILT, ROW_SIZE - 1)
		tally.name = &"Times"
		head.add_child(tally)
	_list.add_child(head)
	for i in PHASES:
		var open := i < reached
		var row := HBoxContainer.new()
		row.name = "phase_%d" % (i + 1)
		row.add_theme_constant_override(&"separation", 12)
		var tag := UiKit.label(T.t(&"codex_phase", {"n": i + 1}), Book.GILT if open else Book.FADED, ROW_SIZE - 1, UiKit.BOLD_FONT)
		tag.custom_minimum_size.x = 80.0
		row.add_child(tag)
		var parts := phase_text(i + 1)
		var title := UiKit.label(parts[0] if open else UNKNOWN, Book.INK if open else Book.FADED, ROW_SIZE, UiKit.BOLD_FONT)
		title.name = &"Name"
		title.custom_minimum_size.x = 300.0
		row.add_child(title)
		var tip := UiKit.label(parts[1] if open else "", Book.FADED, ROW_SIZE - 1)
		tip.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		tip.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		row.add_child(tip)
		_list.add_child(row)


## A phase's name and its line, as the fight shows them (Hud.show_phase): the name up to the first full stop.
static func phase_text(n: int) -> PackedStringArray:
	var text := T.t("boss_phase_%d" % n)
	var dot := text.find(". ")
	if dot < 0:
		return PackedStringArray([text.trim_suffix("."), ""])
	return PackedStringArray([text.substr(0, dot), text.substr(dot + 2)])


## The rooms of the region (the stage's arenas and the Seal Chamber): name and what happens there once entered, how
## many times.
func _arenas() -> void:
	var ids := arena_ids()
	var names := arena_names()
	for i in ids.size():
		var n := count("arenas", ids[i], "entered")
		var row := HBoxContainer.new()
		row.name = String(ids[i])
		row.add_theme_constant_override(&"separation", 12)
		var name := UiKit.label(T.t(names[i]) if n > 0 else UNKNOWN, Book.INK if n > 0 else Book.FADED, ROW_SIZE, UiKit.BOLD_FONT)
		name.name = &"Name"
		name.custom_minimum_size.x = 300.0
		row.add_child(name)
		var what := UiKit.label(T.t("codex_arena_" + String(ids[i])) if n > 0 else "", Book.FADED, ROW_SIZE - 1)
		what.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(what)
		row.add_child(_times(n))
		_list.add_child(row)


## Fatia 3, the angels (AngelCodex): each its seal (lit once met, its outline before), its name and line, and the
## times it came, was chosen and blessed the end of a descent; never met: "???" and "Ainda não encontrado.".
func _angels() -> void:
	for e in AngelCodex.entries(_data):
		var a: AngelDef = e.def
		var known := bool(e.known)
		var row := HBoxContainer.new()
		row.name = String(a.id)
		row.add_theme_constant_override(&"separation", 12)
		row.custom_minimum_size.y = ANGEL_ROW
		var seal := AngelSeal.new().setup(a.family, ANGEL_SEAL, known)
		seal.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		if not known:
			seal.modulate = Color(1, 1, 1, 0.35)
		row.add_child(seal)
		var words := VBoxContainer.new()
		words.add_theme_constant_override(&"separation", 0)
		words.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var name := UiKit.label(T.t(a.name_key) if known else UNKNOWN, Book.ink(AngelSeal.tint(a.family)) if known else Book.FADED,
			ROW_SIZE + 1, UiKit.BOLD_FONT)
		name.name = &"Name"
		words.add_child(name)
		words.add_child(UiKit.label(T.t(a.line_key) if known else T.t(&"codex_angel_unknown"), Book.FADED, ROW_SIZE - 1))
		if known:
			var nums := UiKit.label("  ·  ".join([T.t(&"codex_angel_met", {"n": e.met}), T.t(&"codex_angel_chosen", {"n": e.chosen}),
				T.t(&"codex_angel_blessed", {"n": e.blessed})]), Book.FADED, ROW_SIZE - 2, UiKit.number_font())
			nums.name = &"Counts"
			words.add_child(nums)
		row.add_child(words)
		_list.add_child(row)


## The rooms of the region in the Compendium: the stage's arenas and the Seal Chamber (ids).
func arena_ids() -> Array[StringName]:
	var stage: StageDef = load(STAGE)
	var ids: Array[StringName] = []
	for l in stage.layouts:
		ids.append(l.id)
	if stage.boss_layout != null:
		ids.append(stage.boss_layout.id)
	return ids


## Their names' keys, in the same order.
func arena_names() -> Array[StringName]:
	var stage: StageDef = load(STAGE)
	var names: Array[StringName] = []
	for l in stage.layouts:
		names.append(l.name_key)
	if stage.boss_layout != null:
		names.append(RunMap.KIND_KEY[RunMap.Kind.BOSS])
	return names


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
	var l := UiKit.label(T.t(&"codex_times", {"n": n}) if n > 0 else "", Book.GILT, ROW_SIZE - 2)
	l.name = &"Times"
	l.custom_minimum_size.x = 34.0
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	return l


## The combos found so far (the old Golpes screen): each move's inputs as the HUD's own marks (QW-110: never the
## letters E and D, which read as keys), "segurado" after a held one, the dodge's mark first for the Corte Veloz.
func _moves() -> void:
	var tree: ComboTree = load(HeroDef.warrior().combos)
	var known: Array = _data.get("moves", [])
	for m in tree.named_moves():
		var node: ComboNode = m.node
		var found := known.has(String(node.id))
		var row := HBoxContainer.new()
		row.name = String(node.id)
		row.add_theme_constant_override(&"separation", 12)
		var keys := move_marks(m.path, m.from_dodge, found)
		keys.custom_minimum_size.x = KEYS_WIDTH
		row.add_child(keys)
		var name := UiKit.label(T.t(node.title) if found else UNKNOWN, Book.INK if found else Book.FADED, ROW_SIZE + 2, UiKit.BOLD_FONT)
		name.name = &"Name"
		name.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		row.add_child(name)
		_list.add_child(row)


## A move's inputs as a row of the HUD's action marks (ActionSlot.mark): the attack's or the special's per press,
## "segurado" after a held one (the Omega), the dodge's and a "+" before a move that comes out of the dodge.
## Dimmed while the move was never landed.
static func move_marks(path: Array, from_dodge: bool, lit: bool = true) -> HBoxContainer:
	var h := HBoxContainer.new()
	h.name = &"Keys"
	h.add_theme_constant_override(&"separation", 4)
	var ink := Book.GILT if lit else Book.FADED
	if from_dodge:
		h.add_child(ActionSlot.mark(Boon.Slot.DASH, MOVE_MARK))
		h.add_child(_word("+", ink))
	for input: ComboNode.In in path:
		var light := input == ComboNode.In.LIGHT or input == ComboNode.In.CHARGE_LIGHT
		h.add_child(ActionSlot.mark(Boon.Slot.ATTACK if light else Boon.Slot.SPECIAL, MOVE_MARK))
		if input == ComboNode.In.CHARGE or input == ComboNode.In.CHARGE_LIGHT:
			h.add_child(_word(T.t(&"moves_hold"), ink))
	if not lit:
		h.modulate.a = 0.75
	return h


static func _word(text: String, color: Color) -> Label:
	var l := UiKit.label(text, color, ROW_SIZE, UiKit.BOLD_FONT)
	l.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	return l


## The ink mark of a chapter in the index (board 04: small drawings in the margin): Dons a node of the tree, Bênçãos a
## ring with the cards' diamond, Elos two links, Salmos a pointed arch, Inimigos a skull, Morvath a crown, Arenas a
## doorway, Golpes three cuts. Ink on the page; ivory on the entry on show.
class CodexMark:
	extends Control

	var kind := 0
	var color := Book.INK

	func _init() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func _draw() -> void:
		var c := size * 0.5
		var r := minf(size.x, size.y) * 0.46
		var w := maxf(1.4, r * 0.13)
		match kind:
			Tab.GIFTS:
				draw_polyline(TalentNode._closed(TalentNode._diamond(c, r)), color, w, true)
				draw_colored_polygon(PackedVector2Array([c + Vector2(0, -r * 0.55), c + Vector2(r * 0.25, 0), c + Vector2(0, r * 0.55), c + Vector2(-r * 0.25, 0)]), color)
			Tab.BOONS:
				draw_arc(c, r * 0.85, 0.0, TAU, 28, color, w, true)
				draw_colored_polygon(TalentNode._diamond(c, r * 0.38), color)
			Tab.ELOS:
				for x: float in [-0.32, 0.32]:
					var pts := PackedVector2Array()
					for i in 25:
						var a := TAU * i / 24.0
						pts.append(c + Vector2(x * r + cos(a) * r * 0.48, sin(a) * r * 0.7))
					draw_polyline(pts, color, w, true)
			Tab.PSALMS:
				var arch := PackedVector2Array([c + Vector2(-r * 0.6, r * 0.9), c + Vector2(-r * 0.6, -r * 0.1)])
				for i in 9:
					var a := float(i) / 8.0
					arch.append(c + Vector2(-r * 0.6 + r * 0.6 * a, -r * 0.1 - r * 0.85 * sin(a * PI * 0.5)))
				for i in range(1, 9):
					var a := 1.0 - float(i) / 8.0
					arch.append(c + Vector2(r * 0.6 - r * 0.6 * a, -r * 0.1 - r * 0.85 * sin(a * PI * 0.5)))
				arch.append(c + Vector2(r * 0.6, r * 0.9))
				draw_polyline(arch, color, w, true)
				draw_line(c + Vector2(-r * 0.9, r * 0.9), c + Vector2(r * 0.9, r * 0.9), color, w, true)
			Tab.ENEMIES:
				draw_arc(c + Vector2(0, -r * 0.15), r * 0.7, PI * 0.85, PI * 2.15, 20, color, w, true)
				draw_polyline(PackedVector2Array([c + Vector2(-r * 0.62, r * 0.18), c + Vector2(-r * 0.4, r * 0.85), c + Vector2(r * 0.4, r * 0.85), c + Vector2(r * 0.62, r * 0.18)]), color, w, true)
				for x: float in [-0.3, 0.3]:
					draw_circle(c + Vector2(x * r, -r * 0.05), r * 0.17, color)
			Tab.MORVATH:
				draw_polyline(PackedVector2Array([c + Vector2(-r * 0.85, r * 0.6), c + Vector2(-r * 0.85, -r * 0.5), c + Vector2(-r * 0.42, r * 0.05),
					c + Vector2(0, -r * 0.75), c + Vector2(r * 0.42, r * 0.05), c + Vector2(r * 0.85, -r * 0.5), c + Vector2(r * 0.85, r * 0.6)]), color, w, true)
				draw_line(c + Vector2(-r * 0.95, r * 0.6), c + Vector2(r * 0.95, r * 0.6), color, w * 1.4, true)
			Tab.ANGELS:
				# a seal: a double ring and a small diamond (never rays)
				draw_arc(c, r * 0.9, 0.0, TAU, 28, color, w, true)
				draw_arc(c, r * 0.6, 0.0, TAU, 24, color, w * 0.7, true)
				draw_colored_polygon(TalentNode._diamond(c, r * 0.3), color)
			Tab.ARENAS:
				draw_line(c + Vector2(-r * 0.55, r * 0.9), c + Vector2(-r * 0.55, -r * 0.15), color, w, true)
				draw_line(c + Vector2(r * 0.55, r * 0.9), c + Vector2(r * 0.55, -r * 0.15), color, w, true)
				draw_arc(c + Vector2(0, -r * 0.15), r * 0.55, PI, TAU, 14, color, w, true)
				draw_line(c + Vector2(-r * 0.95, r * 0.9), c + Vector2(r * 0.95, r * 0.9), color, w, true)
			_:
				for k in 3:
					var o := Vector2(0.8, 0.6) * r * (k - 1) * 0.42
					draw_line(c + o + Vector2(-0.5, 0.7) * r, c + o + Vector2(0.5, -0.7) * r, color, w, true)
