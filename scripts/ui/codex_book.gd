class_name CodexBook
extends Control
## The Gifts chapter of the Livro de Ahk as a codex of parchment (meta_screens_identity.md 1.1), where the node trees
## were: on the left page a row of ribbons (one per branch, the last "Poder maior" for the ultimates) hanging from the
## top, and under the open one its page: the branch's name in its ink, a miniature (painted by id when it exists, else
## drawn), and the entries in reading order, Entrada, Meio, Ápice (GiftEntry); the last page is the ultimates
## (UltCard). Pontes and Sustento are chapters of their own. The hero's hand shows in the corners of the page (the lion
## for the Warrior, the eight-pointed star for the Maga). Pure presentation over a HeroLoadout: the screen decides
## what a press does (picked, ult_chosen) and tells the focused Gift (focused).
## Keys: up and down walk the entries, left and right turn to the ribbon beside it (the entry in the same row), a
## ribbon's down goes into its page. The mouse takes the focus with it.

signal picked(def: TalentDef)
signal ult_chosen(def: UltDef)
## The focus is on a Gift (TalentDef) or an ultimate (UltDef).
signal focused(what: Variant)

const MINIATURE_MAX := 110.0
## From this many entries on a page, the entries are compact (a bridge's note goes beside its name).
const COMPACT_FROM := 5
const TURN_TIME := 0.15

var loadout: HeroLoadout
var ribbons: Array[GiftRibbon] = []
var ults: Array[UltCard] = []
## Every entry by Gift id.
var entries: Dictionary = {}
## The entries of each chapter, in reading order (the last chapter, the ultimates, has none).
var by_chapter: Array = []
var branches: Array[int] = []
var chapter := 0
var _pages: Array[Control] = []
var _foot: Label
var _first := true


func setup(p_loadout: HeroLoadout) -> CodexBook:
	loadout = p_loadout
	name = "codex_book"
	branches = GiftArt.chapters(loadout.hero)
	var col := VBoxContainer.new()
	col.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	col.add_theme_constant_override(&"separation", 6)
	add_child(col)
	var row := HBoxContainer.new()
	row.name = "ribbons"
	row.add_theme_constant_override(&"separation", 4)
	col.add_child(row)
	var holder := Control.new()
	holder.name = "pages"
	holder.size_flags_vertical = Control.SIZE_EXPAND_FILL
	holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_child(holder)
	for i in branches.size():
		var b := branches[i]
		var ribbon := GiftRibbon.new().setup(b, title_of(b), GiftArt.ink(b))
		ribbons.append(ribbon)
		row.add_child(ribbon)
		var page := _branch_page(b)
		_pages.append(page)
		holder.add_child(page)
	var last := GiftRibbon.new().setup(GiftArt.ULT_BRANCH, T.t(&"codex_ribbon_ult"), GiftArt.ULT_INK)
	ribbons.append(last)
	row.add_child(last)
	var up := _ult_page()
	_pages.append(up)
	holder.add_child(up)
	for i in ribbons.size():
		ribbons[i].focus_entered.connect(show_chapter.bind(i))
		ribbons[i].pressed.connect(_enter_page.bind(i))
	_foot = Book.label("", Book.RUBRIC, 15)
	_foot.name = "foot_note"
	_foot.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_foot.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	col.add_child(_foot)
	var corners := Corners.new()
	corners.hero = loadout.hero
	corners.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	corners.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(corners)
	show_chapter(0)
	return self


func _ready() -> void:
	_link_focus()


## "O nível N revela: X", in rubric at the foot of the page.
func set_foot(text: String) -> void:
	_foot.text = text


## A chapter's name ("Pontes" for the bridges, where a Gift's own place says "Ponte de X e Y").
static func title_of(b: int) -> String:
	if b == TalentDef.Branch.BRIDGE:
		return T.t(&"codex_chapter_bridge")
	return T.t(HeroLoadout.BRANCH_KEY[b])


func entry(id: StringName) -> GiftEntry:
	return entries.get(id)


func _branch_page(b: int) -> Control:
	var page := VBoxContainer.new()
	page.name = "page_%d" % b
	page.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	page.add_theme_constant_override(&"separation", 3)
	var head := Book.label(title_of(b), GiftArt.ink(b), 30, UiKit.TITLE_FONT)
	head.name = "chapter_name"
	page.add_child(head)
	var mini := Miniature.new()
	mini.setup(b, title_of(b).substr(0, 1))
	page.add_child(mini)
	var list: Array[GiftEntry] = []
	var defs: Array[TalentDef] = []
	for t in loadout.book.catalog:
		if t.branch == b:
			defs.append(t)
	defs.sort_custom(func(x: TalentDef, y: TalentDef) -> bool: return x.tier < y.tier)
	var gap := Control.new()
	gap.custom_minimum_size.y = 2.0
	page.add_child(gap)
	for t in defs:
		var e := GiftEntry.new().setup(t, loadout.hero)
		e.set_compact(defs.size() >= COMPACT_FROM)
		e.pressed.connect(func() -> void: picked.emit(t))
		e.focus_entered.connect(func() -> void: focused.emit(t))
		e.gui_input.connect(_entry_input.bind(e))
		entries[t.id] = e
		list.append(e)
		page.add_child(e)
	by_chapter.append(list)
	return page


func _ult_page() -> Control:
	var page := VBoxContainer.new()
	page.name = "page_ult"
	page.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	page.add_theme_constant_override(&"separation", 10)
	page.add_child(Book.label(T.t(&"codex_ribbon_ult"), GiftArt.ULT_INK.darkened(0.25), 30, UiKit.TITLE_FONT))
	for u in loadout.hero.ultimates:
		var card := UltCard.new().setup(u)
		card.size_flags_vertical = Control.SIZE_EXPAND_FILL
		card.pressed.connect(func() -> void: ult_chosen.emit(u))
		card.focus_entered.connect(func() -> void: focused.emit(u))
		card.gui_input.connect(_entry_input.bind(card))
		ults.append(card)
		page.add_child(card)
	by_chapter.append([])
	return page


## The focus links inside a page (up and down) and from a ribbon into its page and back.
func _link_focus() -> void:
	for i in _pages.size():
		var items: Array = ults if i == branches.size() else by_chapter[i]
		for k in items.size():
			var c := items[k] as Control
			if k > 0:
				c.focus_neighbor_top = c.get_path_to(items[k - 1])
			else:
				c.focus_neighbor_top = c.get_path_to(ribbons[i])
			if k < items.size() - 1:
				c.focus_neighbor_bottom = c.get_path_to(items[k + 1])
			c.focus_neighbor_left = c.get_path()
			c.focus_neighbor_right = c.get_path()
		if not items.is_empty():
			ribbons[i].focus_neighbor_bottom = ribbons[i].get_path_to(items[0])


func show_chapter(i: int) -> void:
	i = clampi(i, 0, _pages.size() - 1)
	var changed := i != chapter or _first
	chapter = i
	for k in _pages.size():
		_pages[k].visible = k == i
		ribbons[k].open = k == i
	if changed and not _first and is_inside_tree():
		_pages[i].modulate.a = 0.0
		create_tween().tween_property(_pages[i], ^"modulate:a", 1.0, TURN_TIME)
	_first = false


func _enter_page(i: int) -> void:
	var f := first_of(i)
	if f != null:
		f.grab_focus()


## The first control of a chapter's page (an entry, or an ultimate on the last).
func first_of(i: int) -> Control:
	var items: Array = ults if i == branches.size() else by_chapter[i]
	return items[0] if not items.is_empty() else null


## Left and right on an entry turn to the ribbon beside, landing on the entry of the same row.
func _entry_input(event: InputEvent, from: Control) -> void:
	var step := 0
	if event.is_action_pressed(&"ui_right"):
		step = 1
	elif event.is_action_pressed(&"ui_left"):
		step = -1
	if step == 0:
		return
	from.accept_event()
	var items: Array = ults if chapter == branches.size() else by_chapter[chapter]
	var row := items.find(from)
	var to := clampi(chapter + step, 0, _pages.size() - 1)
	if to == chapter:
		return
	show_chapter(to)
	var next: Array = ults if to == branches.size() else by_chapter[to]
	if not next.is_empty():
		(next[mini(maxi(row, 0), next.size() - 1)] as Control).grab_focus()


## The control that should hold the focus when the chapter opens: the first Gift that can go on, else the first worn,
## else the first ribbon.
func first_focus() -> Control:
	for want: HeroLoadout.State in [HeroLoadout.State.OPEN, HeroLoadout.State.EQUIPPED]:
		for i in by_chapter.size():
			for e: GiftEntry in by_chapter[i]:
				if e.state == want:
					show_chapter(i)
					return e
	show_chapter(0)
	return ribbons[0]


## Writes every entry's state and words (animate: the capitals fill, the lacres break, as the player acts).
func refresh(animate: bool = true) -> void:
	var worn := loadout.book.defs(loadout.equipped())
	for i in branches.size():
		var list: Array = by_chapter[i]
		var count := 0
		for k in list.size():
			var e: GiftEntry = list[k]
			var t := e.def
			var st := loadout.state(t)
			if st == HeroLoadout.State.EQUIPPED:
				count += 1
			var text := T.t(t.desc_key)
			var reason := false
			match st:
				HeroLoadout.State.LOCKED:
					text = T.t(&"codex_gift_locked", {"n": t.unlock_level})
				HeroLoadout.State.BLOCKED:
					var why := loadout.short_why(t)
					if not why.is_empty():
						text = T.t(why.key, why.args)
						reason = true
			e.seal_cost = loadout.open_cost(t)
			e.note = ""
			e.note_tint = GiftArt.gift_ink(t)
			match t.tier:
				TalentDef.Tier.APEX:
					e.note = T.t(&"codex_note_apex", {"branch": T.t(HeroLoadout.BRANCH_KEY[t.partner])})
					e.note_tint = GiftArt.ink(t.partner)
				TalentDef.Tier.BRIDGE:
					e.note = T.t(&"codex_note_bridge", {"a": T.t(HeroLoadout.BRANCH_KEY[t.joins[0]]), "b": T.t(HeroLoadout.BRANCH_KEY[t.joins[1]])})
					e.note_tint = GiftArt.ink2(t)
			# the thread of the prerequisite runs down the three rungs of a branch only
			var chain := t.branch != TalentDef.Branch.BRIDGE and t.branch != TalentDef.Branch.SUSTAIN
			e.thread_in = GiftEntry.Cord.NONE
			if chain and t.tier != TalentDef.Tier.ENTRY:
				e.thread_in = GiftEntry.Cord.MET if Talents.needs_met(t, worn) else GiftEntry.Cord.MISSING
			e.or_above = k > 0 and t.slot != Boon.Slot.NONE and (list[k - 1] as GiftEntry).def.slot == t.slot
			e.set_state(st, text, reason, animate)
		for k in list.size():
			var e: GiftEntry = list[k]
			e.thread_out = GiftEntry.Cord.NONE
			if k < list.size() - 1 and (list[k + 1] as GiftEntry).thread_in != GiftEntry.Cord.NONE:
				e.thread_out = (list[k + 1] as GiftEntry).thread_in
			e.queue_redraw()
		ribbons[i].worn = count
	for c in ults:
		c.open = loadout.ult_open(c.def)
		c.chosen = loadout.ultimate() == c.def.id


## The branch's miniature on its page: the painted one by id (assets/ui/book/branch_<name>.png) or the placeholder.
class Miniature:
	extends Control

	var branch := 0
	var letter := ""

	func setup(p_branch: int, p_letter: String) -> void:
		branch = p_branch
		letter = p_letter
		size_flags_vertical = Control.SIZE_EXPAND_FILL
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		custom_minimum_size.y = 0.0

	func _draw() -> void:
		var h := minf(size.y - 4.0, CodexBook.MINIATURE_MAX)
		if h < 28.0:
			return
		GiftArt.paint(self, Rect2(Vector2(0, 2.0), Vector2(size.x, h)), GiftArt.BRANCH_ART[branch], GiftArt.ink(branch), letter)


## The hero's mark in the two lower corners of the page.
class Corners:
	extends Control

	var hero: HeroDef

	func _draw() -> void:
		var col := Color(Book.GILT, 0.55)
		GiftArt.corner(self, Vector2(12.0, size.y - 10.0), 10.0, hero, col)
		GiftArt.corner(self, Vector2(size.x - 12.0, size.y - 10.0), 10.0, hero, col)
