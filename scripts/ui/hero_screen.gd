class_name HeroScreen
extends Control
## "O Guerreiro" on the title: the Livro de Ahk (E2-06; art pack stage 2, boards 04, 05 and 09). An open book
## (BookSpread) with the hero's medallion, "O Guerreiro" and "Livro de Ahk" at the head of the left page and his Mastery
## (MasteryBar, with what the next level brings) and Devotion at the head of the right one, and its chapters behind
## the bookmarks above it:
## - Abertura: Ahk's words from the canon (his testimony) and the descent in three steps (the same signs and words as
##   Como Jogar), with a straight way down ("Descer às catacumbas": the descend signal, the title's Iniciar);
## - O Guerreiro: the playable hero (the only one: the cast comes from the data, HeroDef.warrior) painted on the left
##   page; on the right his weapon, his way of fighting and his abilities with the HUD's own marks (the four actions,
##   the ultimate the descent plays and the passive); from here, the Gifts or the way down;
## The Gifts are not in the book any more (PT-12): the hero page's "Dons" button opens the medallion (DonsScreen) over it.
## The bookmarks are tabs (focus shows the chapter, like the Compendium's). Esc or B goes back (the title closes the
## screen on ui_cancel, like its other panels).

signal closed
## The way down from the book (the title starts the descent as Iniciar does, Juramentos first after a victory).
signal descend

enum Chapter { OPENING, HERO, OFICIOS }

const CHAPTER_KEY: Array[StringName] = [&"book_chapter_opening", &"title_hero", &"chapter_oficios"]
const CHAPTER_NAME: Array[String] = ["chapter_opening", "chapter_hero", "chapter_oficios"]
## Screen margins round the book and the bookmarks' width, px at 720 lines.
## (12 px over the bookmarks at the top: UI review d2ff05d, P1-5.)
const OUTER := Vector2(22, 12)
## The spine: the left page (the tree, the painting) a little wider than the right (the words).
const SPINE := 0.55
const CREST := 46.0
const NAME_SIZE := 26
const DESC_SIZE := 18
const META_SIZE := 16
const STEP_GLYPH := 52.0
## The buttons in the foot of the right page.
const FOOT_WIDTH := 124.0
const MARK := 26.0
## The places beside the Warrior's in the book's head: how many are sealed, and their size.
const SEALED := 3
const SEAT := 40.0
## The Como Jogar row that names each action (howto_<id>).
const SKILL_ROW := {Boon.Slot.ATTACK: "light_attack", Boon.Slot.SPECIAL: "heavy_attack", Boon.Slot.CAST: "shout",
	Boon.Slot.DASH: "dodge"}
## The Warrior painted on the hero page (art pack board 04, made by AI, cut by hand; docs/steam-ia.md), its edges
## feathered into the paper.
const PORTRAIT: Texture2D = preload("res://assets/ui/hero/warrior_page.png")
const FEATHER := """
shader_type canvas_item;
uniform float feather = 0.1;
void fragment() {
	vec2 e = min(UV, 1.0 - UV) / feather;
	float a = smoothstep(0.0, 1.0, min(e.x, e.y));
	COLOR = vec4(COLOR.rgb, COLOR.a * a);
}
"""

var loadout: HeroLoadout
var chapter := Chapter.HERO
var chapters: Array[Button] = []
var _data: Dictionary
var _book: BookSpread
## Per chapter, its content on the left page and on the right one.
var _left: Array[Control] = []
var _right: Array[Control] = []
var _bar: MasteryBar
var _next: Label
var _devotion_count: Label
## The keys at the foot (benchmark P0-2): chapters on the left, the press and the way back on the right.
var bar: ActionBar
var _to_gifts: Button
var _dons: DonsScreen
var _down: Button
var _down_hero: Button
## Opened in the hub (the Livro de Ahk at its lectern): no way down from the book, the Portal is the way down (UI
## review d2ff05d, P1-4).
var in_hub := false
## The Compêndio opened from the book (null: none).
var _codex: CodexScreen
var _codex_button: Button
## What the panel tells now (a TalentDef, an UltDef or null for the centre).
## False until the first refresh: the book opens with its capitals already filled (nothing animates at the start).
## Abrir with Memória (Rejogabilidade, Fatia 1): the sealed Gift asked to open, waiting for the second press that
## confirms it on this page (no sheet over the book), for CONFIRM_TIME seconds; moving the focus forgets it.
const CONFIRM_TIME := 3.0
var arming: StringName = &""
var _arm_t := 0.0
## The Discernimento's buttons, one per grade (Fatia 3).
var discern_buttons: Array[Button] = []
const DISCERN_BUTTON := 200.0
## The materials held, in the head of the right page (MaterialCount.purse).
var _purse: HBoxContainer


## data: the save data to read and edit (Save.data in the game; tests give their own); start: the chapter open first.
## hub: opened in the hub, where only the Portal goes down (no "Descer às catacumbas" in the book).
func open(data: Dictionary = {}, start: Chapter = Chapter.HERO, hub: bool = false) -> void:
	in_hub = hub
	_data = data if not data.is_empty() else Save.data
	# the hero picked at the Portal (the Maga once Morvath was sealed); the Gifts chapter draws her triangle
	# (--hero=maga forces her, for captures)
	var id := Dev.arg("hero") if Dev.has("hero") else SaveData.picked_hero(_data)
	loadout = HeroLoadout.new(HeroDef.maga() if id == "maga" else HeroDef.warrior(), _data)
	theme = Book.theme()
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var shade := ColorRect.new()
	shade.color = Color(0.01, 0.0, 0.02, 0.88)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(shade)
	var frame := MarginContainer.new()
	frame.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	frame.add_theme_constant_override(&"margin_left", int(OUTER.x))
	frame.add_theme_constant_override(&"margin_right", int(OUTER.x))
	frame.add_theme_constant_override(&"margin_top", int(OUTER.y))
	frame.add_theme_constant_override(&"margin_bottom", int(ActionBar.RESERVE))
	add_child(frame)
	var col := VBoxContainer.new()
	col.add_theme_constant_override(&"separation", -int(Book.MARK_HIDDEN))
	frame.add_child(col)
	# the chapters are leather bookmarks standing out of the top of the cover (P1-5), not the menus' tabs
	var marks := HBoxContainer.new()
	marks.name = "chapters"
	marks.alignment = BoxContainer.ALIGNMENT_CENTER
	marks.add_theme_constant_override(&"separation", 6)
	marks.custom_minimum_size.y = Book.MARK_HEIGHT + Book.MARK_RISE
	col.add_child(marks)
	for c: int in Chapter.values():
		# the hero's chapter carries the picked hero's name ("A Maga" for her)
		var key: StringName = &"hero_maga" if c == 1 and loadout.hero.id == &"maga" else CHAPTER_KEY[c]
		var b := Book.mark(T.t(key))
		b.name = CHAPTER_NAME[c]
		b.focus_entered.connect(_show.bind(c))
		b.pressed.connect(_show.bind(c))
		chapters.append(b)
		marks.add_child(b)
	_book = BookSpread.new().setup(SPINE)
	_book.size_flags_vertical = Control.SIZE_EXPAND_FILL
	col.add_child(_book)
	var left := _page_column(_book.left, _head_left())
	var right := _page_column(_book.right, _head_right())
	_left = [_opening_left(), _hero_left(), _oficios_left()]
	_right = [_opening_right(), _hero_right(), _oficios_right()]
	# every chapter's content in the page's column, one shown (a column skips what is hidden)
	for i in _left.size():
		_left[i].size_flags_vertical = Control.SIZE_EXPAND_FILL
		_right[i].size_flags_vertical = Control.SIZE_EXPAND_FILL
		left.add_child(_left[i])
		right.add_child(_right[i])
	right.add_child(_footer())
	bar = ActionBar.attach(self, [
		ActionBar.entry(&"tab_prev", T.t(&"bar_prev"), func() -> void: _turn(-1), true),
		ActionBar.entry(&"tab_next", T.t(&"bar_next"), func() -> void: _turn(1), true),
		ActionBar.entry(&"ui_accept", T.t(&"bar_confirm"), _press_focus),
		ActionBar.entry(&"ui_cancel", T.t(&"bar_back"), func() -> void: closed.emit())])
	_refresh()
	_show(start)
	_first_focus().grab_focus.call_deferred()
	# the book opens: a breath of the pages coming up
	_book.modulate.a = 0.0
	create_tween().tween_property(_book, ^"modulate:a", 1.0, 0.22)


func _page_column(page: MarginContainer, head: Control) -> VBoxContainer:
	var v := VBoxContainer.new()
	v.add_theme_constant_override(&"separation", 8)
	page.add_child(v)
	v.add_child(head)
	return v


func _head_left() -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override(&"separation", 12)
	var crest := HeroCrest.new().setup(CREST).set_hero(loadout.hero.id)
	crest.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(crest)
	var names := VBoxContainer.new()
	names.add_theme_constant_override(&"separation", -2)
	names.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var line := HBoxContainer.new()
	line.add_theme_constant_override(&"separation", 12)
	names.add_child(line)
	line.add_child(Book.label(T.t(loadout.hero.name_key), GiftArt.title_ink(loadout.hero), 30, UiKit.TITLE_FONT))
	var bar := ColorRect.new()
	bar.color = Color(Book.GILT, 0.7)
	bar.custom_minimum_size = Vector2(1, 24)
	bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	line.add_child(bar)
	var book := Book.label(T.t(&"book_title").to_upper(), Book.GILT, 15, UiKit.TITLE_FONT)
	book.name = "book_title"
	book.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	line.add_child(book)
	_next = Book.label("", Book.FADED, 15)
	_next.name = "next"
	names.add_child(_next)
	row.add_child(names)
	row.add_child(_sealed_seats())
	return row


## The Warrior's crest is the first of four places; the other three are sealed silhouettes (HUB-C, D-H3): no name, no
## text, nothing to choose (no focus, no click), pushed to the page's outer edge.
func _sealed_seats() -> Control:
	var seats := HBoxContainer.new()
	seats.name = "sealed"
	seats.alignment = BoxContainer.ALIGNMENT_END
	seats.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	seats.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	seats.mouse_filter = Control.MOUSE_FILTER_IGNORE
	seats.add_theme_constant_override(&"separation", 6)
	for i in SEALED:
		seats.add_child(SealedMark.new().setup(SEAT, true))
	return seats


func _head_right() -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override(&"separation", 18)
	_bar = MasteryBar.new().setup(loadout.hero.mastery, loadout.xp(), 250.0)
	_bar.name = "mastery"
	_bar.paper = true
	_bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(_bar)
	var dev := VBoxContainer.new()
	dev.add_theme_constant_override(&"separation", 2)
	dev.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	dev.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var top := HBoxContainer.new()
	top.add_child(Book.label(T.t(&"hero_devotion"), Book.INK, 16, UiKit.BOLD_FONT))
	_devotion_count = Book.label("", Book.FADED, 16, UiKit.number_font())
	_devotion_count.name = "devotion"
	_devotion_count.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_devotion_count.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	top.add_child(_devotion_count)
	dev.add_child(top)
	row.add_child(dev)
	# the purse: Prata and Memória held (the Memória opens the sealed Gifts), under the Devotion's pips (beside them
	# it pushed the page's buttons out at 720 lines)
	_purse = MaterialCount.purse(_data, Book.INK, 15, 16.0)
	_purse.alignment = BoxContainer.ALIGNMENT_END
	_purse.add_theme_constant_override(&"separation", 12)
	dev.add_child(_purse)
	return row


# ---- Abertura ----

const EPIGRAPH_WIDTH := 347.0


## Ahk's testimony (the canon's own words, as the Cronologia opens) and who wrote it.
func _opening_left() -> Control:
	var v := VBoxContainer.new()
	v.name = "opening_left"
	v.alignment = BoxContainer.ALIGNMENT_CENTER
	v.add_theme_constant_override(&"separation", 14)
	var vignette := AhkVignette.new()
	vignette.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	v.add_child(vignette)
	var title := Book.label(T.t(&"book_title"), Book.RUBRIC, 40, UiKit.TITLE_FONT)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(title)
	var rule := GoldRule.new()
	rule.tint = Book.GILT
	rule.custom_minimum_size = Vector2(320, 14)
	rule.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	v.add_child(rule)
	# the epigraph on a left aligned column with the illuminated capital (AP-4 1.4); the signature to its right
	var words := DropCap.paragraph(T.t(&"book_epigraph"), Book.INK, 22, EPIGRAPH_WIDTH)
	words.name = "epigraph"
	words.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	v.add_child(words)
	var by := Book.label(T.t(&"book_epigraph_by"), Book.GILT, 18, UiKit.TITLE_FONT)
	by.name = "epigraph_by"
	by.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	by.custom_minimum_size.x = EPIGRAPH_WIDTH
	by.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	v.add_child(by)
	return v


## The descent in three steps (Como Jogar's signs and words) and the way down.
func _opening_right() -> Control:
	var v := VBoxContainer.new()
	v.name = "opening_right"
	v.add_theme_constant_override(&"separation", 12)
	v.add_child(Book.heading(T.t(&"howto_tab_descent"), 28, 260))
	for i in HowToScreen.STEPS.size():
		var id := HowToScreen.STEPS[i]
		var row := HBoxContainer.new()
		row.name = "step_" + id
		row.add_theme_constant_override(&"separation", 14)
		var g := HowToScreen.step_glyph(i, STEP_GLYPH)
		g.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		row.add_child(g)
		var words := VBoxContainer.new()
		words.add_theme_constant_override(&"separation", 0)
		words.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		words.add_child(Book.label(T.t("howto_step_" + id), Book.RUBRIC, 20, UiKit.TITLE_FONT))
		words.add_child(Book.text(T.t("howto_step_%s_desc" % id), Book.INK, 17))
		row.add_child(words)
		v.add_child(row)
	var gap := Control.new()
	gap.size_flags_vertical = Control.SIZE_EXPAND_FILL
	v.add_child(gap)
	if not in_hub:
		_down = _descend_button("descend")
		v.add_child(_down)
	return v


# ---- the Ofícios (Roteiro A; 10_ux.md 11): what was noted and what can be made, in Ahk's plain hand ----

## The left page: the resources (the Pedra Funda) and the tools (the Picareta), each "???" with a hint until noted.
func _oficios_left() -> Control:
	var d := OficiosDef.live()
	var v := VBoxContainer.new()
	v.name = "oficios_left"
	v.add_theme_constant_override(&"separation", 8)
	v.add_child(Book.heading(T.t(&"chapter_oficios"), 28, 260))
	var noted := Oficios.noted(_data)
	var ever := int((Oficios.block(_data).items_total as Dictionary).get(String(d.stone), 0)) > 0
	if not noted and not ever and not Oficios.has_tool(_data, d):
		v.add_child(Book.text(T.t(&"oficios_nothing"), Book.FADED, 17))
	v.add_child(Book.section(T.t(&"oficios_resources")))
	if noted or ever:
		v.add_child(_oficio_row("stone", DoorGlyph.new().setup(DoorGlyph.Kind.STONE, MARK), T.t(&"oficio_stone"),
			T.t(&"oficios_stone_count", {"n": Oficios.count(_data, d.stone), "cap": d.stone_cap}), T.t(&"oficios_stone_where")))
	else:
		v.add_child(_oficio_row("stone", _unknown_mark(), T.t(&"oficios_unknown"), "", T.t(&"oficios_stone_hint")))
	v.add_child(Book.section(T.t(&"oficios_tools")))
	var look := PickMark.Look.LOST
	var line := T.t(&"oficios_pick_lost")
	if Oficios.has_tool(_data, d):
		look = PickMark.Look.WHOLE
		line = T.t(&"oficios_pick_done")
	elif Oficios.has_find(_data, d.head):
		look = PickMark.Look.HEAD
		line = T.t(&"oficios_pick_head", {"n": int(d.restore_cost.get(OficiosDef.SILVER, 0))})
	elif noted:
		line = T.t(&"oficios_pick_wanted")
	var name_ := T.t(&"oficio_pick") if noted or Oficios.has_tool(_data, d) else T.t(&"oficios_unknown")
	v.add_child(_oficio_row("pick", PickMark.new().setup(look, MARK + 6.0), name_, "", line))
	return v


## The right page: the orders (the Forjador's, the Vendedor's) and the Obras made.
func _oficios_right() -> Control:
	var d := OficiosDef.live()
	var v := VBoxContainer.new()
	v.name = "oficios_right"
	v.add_theme_constant_override(&"separation", 8)
	v.add_child(Book.section(T.t(&"oficios_orders")))
	var smith := T.t(&"oficios_smith_none")
	if Oficios.has_tool(_data, d):
		smith = T.t(&"oficios_order_done")
	elif Oficios.noted(_data):
		smith = T.t(&"oficios_smith_open", {"n": int(d.restore_cost.get(OficiosDef.SILVER, 0))})
	v.add_child(_oficio_row("smith_order", null, T.t(&"oficios_smith_order"), "", smith))
	var vendor := T.t(&"oficios_order_locked")
	match Oficios.order_state(_data, d):
		Oficios.Order.OPEN:
			vendor = T.t(&"oficios_order_open", {"stone": int(d.order_wants.get(d.stone, 0)),
				"silver": int(d.order_wants.get(OficiosDef.SILVER, 0))})
		Oficios.Order.DONE:
			vendor = T.t(&"oficios_order_done")
	v.add_child(_oficio_row("vendor_order", null, T.t(&"oficios_vendor_order"), "", vendor))
	v.add_child(Book.section(T.t(&"oficios_works")))
	var made := Oficios.has_recipe(_data, d.order_gives)
	v.add_child(_oficio_row("preview", null, T.t(&"oficios_preview") if made else T.t(&"oficios_unknown"), "",
		T.t(&"oficios_preview_desc") if made else T.t(&"oficios_work_sealed")))
	_discern_part(v)
	return v


# ---- Discernimento (Fatia 3; Discern): bought with Memória on the Ofícios' page, in order, two presses ----

## The Discernimento's grades: each its name and what it does, and a paper button that opens the next one.
func _discern_part(v: VBoxContainer) -> void:
	v.add_child(Book.section(T.t(&"discern_title")))
	v.add_child(Book.text(T.t(&"discern_lead"), Book.FADED, 15))
	for n in range(1, Discern.COSTS.size() + 1):
		var row := HBoxContainer.new()
		row.name = "discern_row_%d" % n
		row.add_theme_constant_override(&"separation", 10)
		var words := VBoxContainer.new()
		words.add_theme_constant_override(&"separation", 0)
		words.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		words.add_child(Book.label(T.t("discern_%d" % n), Book.INK, 18, UiKit.BOLD_FONT))
		words.add_child(Book.text(T.t("discern_%d_desc" % n), Book.FADED, 15))
		row.add_child(words)
		var b := Book.button("", _press_discern.bind(n), DISCERN_BUTTON)
		b.name = "discern_%d" % n
		b.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		row.add_child(b)
		discern_buttons.append(b)
		v.add_child(row)
	_refresh_discern()


## Each grade's button as the save stands: Aberto, "Abrir · N" (and asking again while armed), or why not.
func _refresh_discern() -> void:
	for i in discern_buttons.size():
		var n := i + 1
		var b := discern_buttons[i]
		var problem := Discern.problem(_data, n)
		var can := problem == Discern.Problem.OK
		match problem:
			Discern.Problem.OWNED:
				b.text = T.t(&"discern_owned")
			Discern.Problem.NEEDS:
				b.text = T.t(&"discern_needs", {"name": T.t("discern_%d" % (n - 1))})
			Discern.Problem.SHORT:
				b.text = T.t(&"discern_short", {"n": Discern.cost(n) - MaterialPurse.amount(_data, MaterialPurse.MEMORY)})
			_:
				b.text = T.t(&"discern_confirm" if arming == StringName("discern_%d" % n) else &"discern_open_cost",
					{"n": Discern.cost(n)})
		b.disabled = not can
		b.focus_mode = Control.FOCUS_ALL if can else Control.FOCUS_NONE
		if can:
			Book.primary(b)


## The first press asks (the button says what it costs), the second within CONFIRM_TIME opens it and writes the save.
func _press_discern(n: int) -> void:
	var id := StringName("discern_%d" % n)
	if Discern.problem(_data, n) != Discern.Problem.OK:
		return
	if arming != id:
		arming = id
		_arm_t = CONFIRM_TIME
		Audio.play(&"ui_move")
		_refresh_discern()
		return
	arming = &""
	if Discern.buy(_data):
		Audio.play(&"ui_ok")
		_save()
	_refresh()
	_refresh_discern()
	var next := _discern_focus()
	(next if next != null else chapters[Chapter.OFICIOS]).grab_focus()


func _discern_focus() -> Control:
	for b in discern_buttons:
		if not b.disabled:
			return b
	return null


## A line of the Ofícios: an optional mark, the name in bold ink with a count at the right in lining figures, and a
## line of faded ink under it.
func _oficio_row(id: String, mark: Control, name_: String, count: String, line: String) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.name = id
	row.add_theme_constant_override(&"separation", 12)
	if mark != null:
		mark.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
		row.add_child(mark)
	var words := VBoxContainer.new()
	words.add_theme_constant_override(&"separation", 0)
	words.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var top := HBoxContainer.new()
	top.add_child(Book.label(name_, Book.INK, 19, UiKit.BOLD_FONT))
	if count != "":
		var c := Book.label(count, Book.INK, 17, UiKit.number_font())
		c.name = "count"
		c.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		c.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		top.add_child(c)
	words.add_child(top)
	if line != "":
		words.add_child(Book.text(line, Book.FADED, 16))
	row.add_child(words)
	return row


## A mark not yet known: a hollow diamond in faded ink.
func _unknown_mark() -> Control:
	var c := Control.new()
	c.custom_minimum_size = Vector2(MARK, MARK)
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	c.draw.connect(func() -> void:
		var m := c.size * 0.5
		var r := minf(c.size.x, c.size.y) * 0.4
		c.draw_polyline(PackedVector2Array([m + Vector2(0, -r), m + Vector2(r, 0), m + Vector2(0, r), m + Vector2(-r, 0),
			m + Vector2(0, -r)]), Color(Book.FADED, 0.6), 1.5, true))
	return c


func _descend_button(id: String) -> Button:
	var b := Book.primary(Book.button(T.t(&"menu_play"), func() -> void: descend.emit(), 280))
	b.name = id
	b.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	return b


# ---- O Guerreiro ----

## The Warrior painted on his page.
func _hero_left() -> Control:
	var art := TextureRect.new()
	art.name = "portrait"
	art.texture = PORTRAIT if loadout.hero == HeroDef.warrior() else null
	art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	art.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var s := Shader.new()
	s.code = FEATHER
	var m := ShaderMaterial.new()
	m.shader = s
	art.material = m
	return art


## His weapon, his way of fighting and his abilities, and the ways on from here.
func _hero_right() -> Control:
	var v := VBoxContainer.new()
	v.name = "hero_right"
	v.add_theme_constant_override(&"separation", 5)
	v.add_child(Book.section(T.t(&"hero_weapon")))
	v.add_child(Book.label(T.t(&"hero_weapon_name"), Book.INK, 22, UiKit.TITLE_FONT))
	v.add_child(Book.text(T.t(&"hero_weapon_desc"), Book.INK, 17))
	v.add_child(_gap(4))
	v.add_child(Book.section(T.t(&"hero_style")))
	v.add_child(Book.text(T.t(&"hero_style_desc"), Book.INK, 17))
	v.add_child(_gap(4))
	v.add_child(Book.section(T.t(&"hero_skills")))
	var grid := GridContainer.new()
	grid.name = "skills"
	grid.columns = 2
	grid.add_theme_constant_override(&"h_separation", 10)
	grid.add_theme_constant_override(&"v_separation", 6)
	v.add_child(grid)
	for slot: Boon.Slot in [Boon.Slot.ATTACK, Boon.Slot.SPECIAL, Boon.Slot.CAST, Boon.Slot.DASH]:
		_skill(grid, ActionSlot.mark(slot, MARK), T.t("howto_" + String(SKILL_ROW[slot])),
			T.t("hero_skill_" + String(Boon.Slot.keys()[slot]).to_lower()))
		if slot == Boon.Slot.CAST:
			# the Investida (E) has no Blessing slot: its row follows the Brado's
			_skill(grid, ActionSlot.glyph_mark(BoonIcon.RUSH_GLYPH, MARK), T.t(&"howto_rush"), T.t(&"hero_skill_rush"))
	var u := loadout.hero.ultimate(loadout.ultimate())
	if u != null:
		_skill(grid, ActionSlot.glyph_mark(BoonIcon.ULT_GLYPH + u.kind, MARK), T.t(u.name_key), T.t(&"hero_skill_ultimate"))
	else:
		var first := loadout.hero.ultimates[0] if not loadout.hero.ultimates.is_empty() else null
		if first != null:
			_skill(grid, ActionSlot.glyph_mark(BoonIcon.ULT_GLYPH + first.kind, MARK), T.t(&"howto_ultimate"),
				T.t(&"hero_ult_locked", {"n": first.mastery_level}))
	_skill(grid, TalentGlyph.mark(null, MARK), T.t(&"hero_passive"), T.t(&"hero_passive_desc"))
	var gap := Control.new()
	gap.size_flags_vertical = Control.SIZE_EXPAND_FILL
	v.add_child(gap)
	# the way down on the title's book only; Dons sits in the foot with the Compêndio and Voltar (P1-4)
	if not in_hub:
		_down_hero = _descend_button("descend_hero")
		v.add_child(_down_hero)
	return v


func _skill(grid: GridContainer, mark: Control, title: String, line: String) -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override(&"separation", 8)
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(mark)
	var words := VBoxContainer.new()
	words.add_theme_constant_override(&"separation", -3)
	words.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	words.add_child(Book.label(title, Book.INK, 16, UiKit.BOLD_FONT))
	var l := Book.text(line, Book.INK, 15)
	words.add_child(l)
	row.add_child(words)
	grid.add_child(row)


static func _gap(h: float) -> Control:
	var c := Control.new()
	c.custom_minimum_size.y = h
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return c


# ---- Dons ----

func _footer() -> Control:
	var row := HBoxContainer.new()
	row.name = "foot"
	var fill := Control.new()
	fill.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(fill)
	# one row at the foot of the right page, to its right (P1-4): Dons (on the Warrior's chapter), Compêndio, Voltar
	row.add_theme_constant_override(&"separation", 10)
	_to_gifts = Book.button(T.t(&"hero_gifts"), _open_dons, FOOT_WIDTH)
	_to_gifts.name = "to_gifts"
	row.add_child(_to_gifts)
	_codex_button = Book.button(T.t(&"pause_moves"), _open_codex, FOOT_WIDTH + 24.0)
	_codex_button.name = "codex"
	row.add_child(_codex_button)
	var back := Book.button(T.t(&"back"), func() -> void: closed.emit(), FOOT_WIDTH)
	back.name = "back"
	row.add_child(back)
	return row


## The Compêndio over the book (HUB-C: the Livro de Ahk holds the Warrior and the Compêndio); closing it gives the
## focus back to its button.
func _open_codex() -> void:
	if is_instance_valid(_codex):
		return
	_codex = CodexScreen.new()
	_codex.name = "codex_page"
	# the book hides under it (nothing of it takes the focus meanwhile)
	for c in get_children():
		(c as CanvasItem).visible = false
	add_child(_codex)
	_codex.open()
	_codex.closed.connect(_close_codex)


func _close_codex() -> void:
	if not is_instance_valid(_codex):
		return
	_codex.queue_free()
	_codex = null
	for c in get_children():
		if not c.is_queued_for_deletion():
			(c as CanvasItem).visible = true
	_codex_button.grab_focus.call_deferred()


## The Gifts medallion over the book (the Gifts left the book, PT-12): Esc and B close it and give the focus back.
func _open_dons() -> void:
	if is_instance_valid(_dons):
		return
	_dons = DonsScreen.new()
	for c in get_children():
		(c as CanvasItem).visible = false
	add_child(_dons)
	_dons.open(_data)


func _close_dons() -> void:
	if not is_instance_valid(_dons):
		return
	_dons.queue_free()
	_dons = null
	for c in get_children():
		if not c.is_queued_for_deletion():
			(c as CanvasItem).visible = true
	_to_gifts.grab_focus.call_deferred()


# ---- chapters and focus ----

## LB and RB (PageUp, PageDown) turn to the chapter before or after (DT-103).
func _unhandled_input(event: InputEvent) -> void:
	if is_instance_valid(_dons):
		if event.is_action_pressed(&"ui_cancel"):
			get_viewport().set_input_as_handled()
			_close_dons()
		return
	if is_instance_valid(_codex):
		# the Compêndio is on show: Esc and B close it (its own tabs read LB and RB)
		if event.is_action_pressed(&"ui_cancel"):
			get_viewport().set_input_as_handled()
			_close_codex()
		return
	if UiKit.step_tabs(event, chapters, chapter):
		get_viewport().set_input_as_handled()


func _show(c: int) -> void:
	chapter = c as Chapter
	for i in chapters.size():
		Book.mark_open(chapters[i], i == c)
		_left[i].visible = i == c
		_right[i].visible = i == c
	_to_gifts.visible = chapter == Chapter.HERO


## Opens a chapter from inside the book (a button), with the focus on its first control.
func _open_chapter(c: Chapter) -> void:
	Audio.play(&"ui_ok")
	_show(c)
	_chapter_focus(c).grab_focus()


## Focus at the start: the chapter's own first control.
func _first_focus() -> Control:
	return _chapter_focus(chapter)


func _chapter_focus(c: Chapter) -> Control:
	match c:
		Chapter.OPENING:
			# in the hub the Opening has no way down: its bookmark holds the focus
			return _down if _down != null else chapters[Chapter.OPENING]
		Chapter.HERO:
			return _to_gifts
		Chapter.OFICIOS:
			# the Discernimento's next grade, else its bookmark holds the focus
			var d := _discern_focus()
			return d if d != null else chapters[Chapter.OFICIOS]
	return chapters[c]


func _process(delta: float) -> void:
	if arming == &"":
		return
	_arm_t -= delta
	if _arm_t <= 0.0:
		arming = &""
		_refresh_discern()


func _save() -> void:
	if is_same(_data, Save.data):
		Save.write()


func _refresh() -> void:
	MaterialCount.refresh(_purse, _data)
	_devotion_count.text = T.t(&"hero_devotion_count", {"used": loadout.used(), "max": loadout.devotion()})
	var next := loadout.next_unlocks()
	_next.text = T.t(&"hero_next", {"n": loadout.level() + 1, "what": ", ".join(next)}) if not next.is_empty() else ""


## The control in focus pressed (the action bar's click).
func _press_focus() -> void:
	var f := get_viewport().gui_get_focus_owner() as BaseButton
	if f != null and is_ancestor_of(f) and not f.disabled:
		f.pressed.emit()


## The chapter before (-1) or after (1), as LB and RB.
func _turn(step: int) -> void:
	var c := clampi(chapter + step, 0, chapters.size() - 1)
	if c != chapter:
		_show(c)
		chapters[c].grab_focus()

