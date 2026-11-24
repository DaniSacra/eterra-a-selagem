class_name HeroScreen
extends Control
## The Livro de Ahk (docs/art/book_spec.md; art pack stage 2, boards 04, 05 and 09): an open book on a table, two equal
## pages (BookSpread), three silk ribbons (Abertura, the picked hero, Ofícios) and a page turn of 0.35 s between the
## chapters (BookTurn: LB and RB, PageUp and PageDown, the wheel, a dog-ear, a ribbon, the d-pad at the edge). It is read,
## nothing is bought in it. At the head of every page: the chapter's name on the left, the hero's Mastery on the right.
## - Abertura: Ahk's words from the canon (his testimony) and the descent in three steps (the same signs and words as
##   Como Jogar), with the way down ("Descer às catacumbas": the descend signal, the title's Iniciar);
## - the hero (SaveData.picked_hero: the Warrior or the Maga): painted on the left page; on the right his weapon, his
##   way of fighting, his abilities with the HUD's own marks, the Gifts he has equipped (read only) and the buttons to
##   the Gifts medallion (DonsScreen) and the Compêndio;
## - Ofícios: what was noted (the Pedra Funda, the Picareta, the orders, the Obras) and the Discernimento, read only
##   (it is bought at the Vendedor's counter).
## Esc or B goes back (the title closes the screen on ui_cancel, like its other panels).

signal closed
## The way down from the book (the title starts the descent as Iniciar does, Juramentos first after a victory).
signal descend

enum Chapter { OPENING, HERO, OFICIOS }

const CHAPTER_KEY: Array[StringName] = [&"book_chapter_opening", &"title_hero", &"chapter_oficios"]
const CHAPTER_NAME: Array[String] = ["chapter_opening", "chapter_hero", "chapter_oficios"]
## The page numbers at the foot of each chapter's two pages.
const FOLIO: Array[Array] = [["i", "ii"], ["1", "2"], ["3", "4"]]
## Screen margins round the book, px at 720 lines (12 px over the ribbons at the top: UI review d2ff05d, P1-5).
const OUTER := Vector2(22, 12)
## The two pages are equal (the spine in the middle).
const SPINE := 0.5
const STEP_GLYPH := 52.0
## The seconds of one turn, and of each when a ribbon far away passes several chapters.
const TURN := 0.35
const TURN_FAR := 0.25
## The buttons in the foot of the right page, and the room left to the page's dog-ear.
const FOOT_WIDTH := 150.0
const MARK := 26.0
const EAR_ROOM := 36.0
## Left of the right page's head, under the ribbon that hangs over it.
const RIBBON_ROOM := 56.0
## The Dons equipped: glyph side and names a line.
const GIFT_MARK := 20.0
const GIFT_COLUMNS := 3
const EPIGRAPH_WIDTH := 430.0
const EPIGRAPH_SIZE := 20
const NAME_SIZE := 30
const CAP_SIZE := 38
const FOLIO_SIZE := 14
const FOLIO_ROOM := 10.0
## The Como Jogar row that names each action (howto_<id>).
const SKILL_ROW := {Boon.Slot.ATTACK: "light_attack", Boon.Slot.SPECIAL: "heavy_attack", Boon.Slot.CAST: "shout",
	Boon.Slot.DASH: "dodge"}
## The action the Maga's marks on the HUD (Hud.MAGA_GLYPHS) stand for, by slot.
const MAGA_ACTION := {Boon.Slot.ATTACK: &"light_attack", Boon.Slot.SPECIAL: &"heavy_attack", Boon.Slot.CAST: &"shout"}
## The hero painted on the hero page (art pack board 04, made by AI, cut by hand; docs/steam-ia.md), its edges feathered
## into the paper. The final art, when it comes: assets/ui/book/warrior_ink.png and maga_ink.png.
const PORTRAIT: Texture2D = preload("res://assets/ui/hero/warrior_page.png")
const MAGA_PORTRAIT := "res://assets/models/meshy/hero_maga_img/hero_maga_img.png"
const BOOK_ART := "res://assets/ui/book/"
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
var _name_cap: Label
var _name_rest: Label
var _folios: Array[Label] = []
var _ears: Array[Button] = []
var _foot: Control
var _turn: BookTurn
var _frame: MarginContainer
## Bumped by every chapter change, so a trip across several chapters stops when another begins.
var _trip := 0
## The keys at the foot (benchmark P0-2): the turn and the press on the left, the way back on the right.
var bar: ActionBar
## The coins at the foot, the same three as the other screens (CoinCorner.wallet).
var _wallet: HBoxContainer
var _to_gifts: Button
var _dons: DonsScreen
var _down: Button
## Opened in the hub (the Livro de Ahk at its lectern): no way down from the book, the Portal is the way down (UI
## review d2ff05d, P1-4).
var in_hub := false
## The Compêndio opened from the book (null: none).
var _codex: CodexScreen
var _codex_button: Button


## data: the save data to read and edit (Save.data in the game; tests give their own); start: the chapter open first.
## hub: opened in the hub, where only the Portal goes down (no "Descer às catacumbas" in the book).
func open(data: Dictionary = {}, start: Chapter = Chapter.HERO, hub: bool = false) -> void:
	in_hub = hub
	_data = data if not data.is_empty() else Save.data
	# the hero picked at the Portal (the Maga once Morvath was sealed); --hero=maga forces her, for captures
	var id := Dev.arg("hero") if Dev.has("hero") else SaveData.picked_hero(_data)
	loadout = HeroLoadout.new(HeroDef.maga() if id == "maga" else HeroDef.warrior(), _data)
	theme = Book.theme()
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(BookDesk.new())
	var frame := MarginContainer.new()
	frame.name = "frame"
	frame.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_frame = frame
	resized.connect(_fit)
	_fit()
	frame.add_theme_constant_override(&"margin_top", int(OUTER.y))
	frame.add_theme_constant_override(&"margin_bottom", int(ActionBar.RESERVE))
	add_child(frame)
	var col := VBoxContainer.new()
	col.add_theme_constant_override(&"separation", -int(Book.MARK_HIDDEN))
	frame.add_child(col)
	# the chapters are silk ribbons standing out of the top of the cover, one a chapter
	var marks := HBoxContainer.new()
	marks.name = "chapters"
	marks.alignment = BoxContainer.ALIGNMENT_CENTER
	marks.add_theme_constant_override(&"separation", int(BookRibbon.WIDTH * 0.8))
	marks.custom_minimum_size.y = BookRibbon.HEIGHT + Book.MARK_RISE
	col.add_child(marks)
	for c: int in Chapter.values():
		var b := _ribbon(c)
		b.name = CHAPTER_NAME[c]
		b.focus_entered.connect(go.bind(c))
		b.pressed.connect(go.bind(c))
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
	_foot = _footer()
	right.add_child(_foot)
	# room for the folio under the buttons
	right.add_child(_gap(FOLIO_ROOM))
	_decorate()
	_turn = BookTurn.new()
	_turn.name = "turn"
	_turn.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_turn.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_turn)
	bar = ActionBar.attach(self, [
		ActionBar.entry(&"tab_prev", T.t(&"bar_prev"), func() -> void: _turn_page(-1), true),
		ActionBar.entry(&"tab_next", T.t(&"bar_next"), func() -> void: _turn_page(1), true),
		ActionBar.entry(&"ui_accept", T.t(&"bar_open_page"), _press_focus),
		ActionBar.entry(&"ui_cancel", T.t(&"bar_back"), func() -> void: closed.emit())])
	_wallet = CoinCorner.wallet(_data, 17, 20.0)
	_wallet.name = "coins"
	bar.set_center(_wallet)
	_refresh()
	_show(start)
	_first_focus().grab_focus.call_deferred()
	# the book opens: a breath of the pages coming up
	_book.modulate.a = 0.0
	create_tween().tween_property(_book, ^"modulate:a", 1.0, 0.3)


## The silk ribbon of chapter c (the hero's in his ink: the Warrior's petrol, the Maga's amber).
func _ribbon(c: int) -> Button:
	var maga := GiftArt.is_maga(loadout.hero)
	match c:
		Chapter.OPENING:
			return BookRibbon.make(T.t(CHAPTER_KEY[c]), BookRibbon.OPENING_TINT, BookRibbon.Mark.FEATHER)
		Chapter.HERO:
			return BookRibbon.make(T.t(&"hero_maga" if maga else CHAPTER_KEY[c]), BookRibbon.MAGA_TINT if maga else Book.RIBBON,
				BookRibbon.Mark.HERO, loadout.hero)
	return BookRibbon.make(T.t(CHAPTER_KEY[c]), BookRibbon.OFICIOS_TINT, BookRibbon.Mark.HAMMER)


## The book keeps its shape on a wide screen: the table shows each side (BookDesk), the candles on it.
func _fit() -> void:
	var side := OUTER.x + BookDesk.side_room(size)
	_frame.add_theme_constant_override(&"margin_left", int(side))
	_frame.add_theme_constant_override(&"margin_right", int(side))


static func _gap(h: float) -> Control:
	var c := Control.new()
	c.custom_minimum_size.y = h
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return c


func _page_column(page: MarginContainer, head: Control) -> VBoxContainer:
	var v := VBoxContainer.new()
	v.add_theme_constant_override(&"separation", 8)
	page.add_child(v)
	v.add_child(head)
	return v


## The folios and the dog-ears, in the margin at the foot of the pages (placed when the book has its size).
func _decorate() -> void:
	for side in 2:
		var f := Book.label("", Book.FADED, FOLIO_SIZE, UiKit.TITLE_FONT)
		f.name = "folio_%d" % side
		f.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		f.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_book.add_child(f)
		_folios.append(f)
		var ear := BookRibbon.ear(side == 0)
		ear.name = "ear_%s" % ("back" if side == 0 else "forward")
		ear.pressed.connect(_turn_page.bind(-1 if side == 0 else 1))
		_book.add_child(ear)
		_ears.append(ear)
	_book.resized.connect(_place_decor)
	_place_decor.call_deferred()


func _place_decor() -> void:
	var r := _book.paper_rect()
	var half := r.size.x * SPINE
	for side in 2:
		var x := r.position.x + half * side
		var f := _folios[side]
		f.position = Vector2(x, r.end.y - FOLIO_SIZE - 10.0)
		f.size = Vector2(half, FOLIO_SIZE + 6.0)
		var ear := _ears[side]
		ear.position = Vector2(x if side == 0 else x + half - BookRibbon.EAR, r.end.y - BookRibbon.EAR)


## The head of the left page: the chapter's name with its capital in the rubric, and whose book it is.
func _head_left() -> Control:
	var v := VBoxContainer.new()
	v.name = "head_left"
	v.add_theme_constant_override(&"separation", -4)
	var line := HBoxContainer.new()
	line.add_theme_constant_override(&"separation", 1)
	_name_cap = Book.label("", Book.RUBRIC, CAP_SIZE, UiKit.TITLE_FONT)
	_name_cap.name = "name_cap"
	_name_rest = Book.label("", Book.INK, NAME_SIZE, UiKit.TITLE_FONT)
	_name_rest.name = "name_rest"
	_name_rest.size_flags_vertical = Control.SIZE_SHRINK_END
	line.add_child(_name_cap)
	line.add_child(_name_rest)
	v.add_child(line)
	var book := Book.label(T.t(&"book_title").to_upper(), Book.GILT, 14, UiKit.TITLE_FONT)
	book.name = "book_title"
	v.add_child(book)
	return v


## The head of the right page: the hero's Mastery (a level and what the next one shows). No Devotion, no purse.
func _head_right() -> Control:
	var row := HBoxContainer.new()
	row.name = "head_right"
	var room := Control.new()
	room.custom_minimum_size.x = RIBBON_ROOM
	room.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(room)
	var v := VBoxContainer.new()
	v.add_theme_constant_override(&"separation", 0)
	_bar = MasteryBar.new().setup(loadout.hero.mastery, loadout.xp(), 250.0)
	_bar.name = "mastery"
	_bar.paper = true
	v.add_child(_bar)
	_next = Book.label("", Book.GILT.darkened(0.2), 18)
	_next.name = "next"
	v.add_child(_next)
	row.add_child(v)
	return row


# ---- Abertura ----

## Ahk's testimony (the canon's own words, as the Cronologia opens) and who wrote it.
func _opening_left() -> Control:
	var v := VBoxContainer.new()
	v.name = "opening_left"
	v.alignment = BoxContainer.ALIGNMENT_CENTER
	v.add_theme_constant_override(&"separation", 14)
	var vignette := AhkVignette.new()
	vignette.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	v.add_child(vignette)
	var rule := GoldRule.new()
	rule.tint = Book.GILT
	rule.custom_minimum_size = Vector2(320, 14)
	rule.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	v.add_child(rule)
	# the epigraph on a left aligned column with the illuminated capital (AP-4 1.4); the signature to its right
	var words := DropCap.paragraph(T.t(&"book_epigraph"), Book.INK, EPIGRAPH_SIZE, EPIGRAPH_WIDTH)
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


# ---- Discernimento (Fatia 3; Discern): only read here since 2026-11-23, it is bought at the Vendedor's counter ----

## The Discernimento's grades as the book reads them: each its name and what it does, open (in green ink) or still to
## open at the Vendedor. Nothing is bought in the book (docs/art/book_spec.md 6).
func _discern_part(v: VBoxContainer) -> void:
	v.add_child(Book.section(T.t(&"discern_title")))
	v.add_child(Book.text(T.t(&"discern_at_vendor"), Book.FADED, 15))
	for n in range(1, Discern.COSTS.size() + 1):
		var open := Discern.level(_data) >= n
		var row := HBoxContainer.new()
		row.name = "discern_row_%d" % n
		row.add_theme_constant_override(&"separation", 10)
		var words := VBoxContainer.new()
		words.add_theme_constant_override(&"separation", 0)
		words.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		words.add_child(Book.label(T.t("discern_%d" % n), Book.INK, 18, UiKit.BOLD_FONT))
		words.add_child(Book.text(T.t("discern_%d_desc" % n), Book.FADED, 15))
		row.add_child(words)
		var state := Book.label(T.t(&"discern_owned" if open else &"discern_closed"), Book.OK if open else Book.FADED, 15,
			UiKit.BOLD_FONT)
		state.name = "state"
		state.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		row.add_child(state)
		v.add_child(row)


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
	# the Enter chip says Descer while the way down has the focus (UI review 2026-11-24b, B1)
	b.focus_entered.connect(func() -> void: if bar != null: bar.item(&"ui_accept").set_verb(T.t(&"bar_descend")))
	b.focus_exited.connect(func() -> void: if bar != null: bar.item(&"ui_accept").set_verb(T.t(&"bar_open_page")))
	return b


# ---- the hero ----

## The hero's own text (the Maga's keys end in _maga; the Warrior's are the plain ones).
func _hk(key: String) -> String:
	return key + "_maga" if GiftArt.is_maga(loadout.hero) else key


## The hero painted on his page (the final ink painting when it exists in assets/ui/book/).
func _hero_left() -> Control:
	var art := TextureRect.new()
	art.name = "portrait"
	art.texture = _portrait()
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


func _portrait() -> Texture2D:
	var maga := GiftArt.is_maga(loadout.hero)
	var path := BOOK_ART + ("maga_ink.png" if maga else "warrior_ink.png")
	if ResourceLoader.exists(path):
		return load(path)
	return load(MAGA_PORTRAIT) if maga else PORTRAIT


## His weapon, his way of fighting, his abilities and the Gifts he has equipped, and the ways on from here.
func _hero_right() -> Control:
	var v := VBoxContainer.new()
	v.name = "hero_right"
	v.add_theme_constant_override(&"separation", 3)
	v.add_child(Book.section(T.t(&"hero_weapon")))
	v.add_child(Book.label(T.t(_hk("hero_weapon_name")), Book.INK, 20, UiKit.TITLE_FONT))
	v.add_child(Book.text(T.t(_hk("hero_weapon_desc")), Book.INK, 16))
	v.add_child(Book.section(T.t(&"hero_style")))
	v.add_child(Book.text(T.t(_hk("hero_style_desc")), Book.INK, 16))
	v.add_child(Book.section(T.t(&"hero_skills")))
	var grid := GridContainer.new()
	grid.name = "skills"
	grid.columns = 2
	grid.add_theme_constant_override(&"h_separation", 10)
	grid.add_theme_constant_override(&"v_separation", 4)
	v.add_child(grid)
	_skills(grid)
	v.add_child(_rule())
	v.add_child(Book.section(T.t(&"hero_gifts_equipped")))
	v.add_child(_gifts_equipped())
	var gap := Control.new()
	gap.size_flags_vertical = Control.SIZE_EXPAND_FILL
	v.add_child(gap)
	return v


## The five actions, the ultimate the descent plays and the passive, with the HUD's marks.
func _skills(grid: GridContainer) -> void:
	var maga := GiftArt.is_maga(loadout.hero)
	for slot: Boon.Slot in [Boon.Slot.ATTACK, Boon.Slot.SPECIAL, Boon.Slot.CAST, Boon.Slot.DASH]:
		var key := String(Boon.Slot.keys()[slot]).to_lower()
		var mark: Control = ActionSlot.mark(slot, MARK)
		if maga and MAGA_ACTION.has(slot):
			mark = ActionSlot.glyph_mark(int(Hud.MAGA_GLYPHS[MAGA_ACTION[slot]]), MARK)
		var title := T.t(_hk("hero_skill_name_" + key)) if maga else T.t("howto_" + String(SKILL_ROW[slot]))
		_skill(grid, mark, title, T.t(_hk("hero_skill_" + key)))
		if slot == Boon.Slot.CAST:
			# the Investida (E) has no Blessing slot: its row follows the Brado's (the Maga's Suspensão)
			var rush: int = int(Hud.MAGA_GLYPHS[&"rush"]) if maga else BoonIcon.RUSH_GLYPH
			_skill(grid, ActionSlot.glyph_mark(rush, MARK), T.t(&"hero_skill_name_rush_maga" if maga else &"howto_rush"),
				T.t(_hk("hero_skill_rush")))
	var u := loadout.hero.ultimate(loadout.ultimate())
	if u != null:
		_skill(grid, ActionSlot.glyph_mark(BoonIcon.ULT_GLYPH + u.kind, MARK), T.t(u.name_key), T.t(&"hero_skill_ultimate"))
	else:
		var first := loadout.hero.ultimates[0] if not loadout.hero.ultimates.is_empty() else null
		if first != null:
			_skill(grid, ActionSlot.glyph_mark(BoonIcon.ULT_GLYPH + first.kind, MARK), T.t(&"howto_ultimate"),
				T.t(&"hero_ult_locked", {"n": first.mastery_level}))
	_skill(grid, TalentGlyph.mark(null, MARK), T.t(_hk("hero_passive")), T.t(_hk("hero_passive_desc")))


func _skill(grid: GridContainer, mark: Control, title: String, line: String) -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override(&"separation", 8)
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(mark)
	var words := VBoxContainer.new()
	words.add_theme_constant_override(&"separation", -3)
	words.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	words.add_child(Book.label(title, Book.INK, 16, UiKit.BOLD_FONT))
	words.add_child(Book.text(line, Book.INK, 15))
	row.add_child(words)
	grid.add_child(row)


## The Dons equipped, to read: a glyph in the branch's ink and the name, three to a line; or that there is none.
func _gifts_equipped() -> Control:
	var ids := loadout.equipped()
	if ids.is_empty():
		var none := Book.label(T.t(&"hero_gifts_none"), Book.FADED, 16)
		none.name = "gifts_none"
		return none
	var grid := GridContainer.new()
	grid.name = "gifts_equipped"
	grid.columns = GIFT_COLUMNS
	grid.add_theme_constant_override(&"h_separation", 10)
	grid.add_theme_constant_override(&"v_separation", 2)
	for id: Variant in ids:
		var t := loadout.book.find(StringName(id))
		if t == null:
			continue
		var row := HBoxContainer.new()
		row.name = String(t.id)
		row.add_theme_constant_override(&"separation", 5)
		row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(TalentGlyph.mark(t, GIFT_MARK))
		var name_ := Book.label(T.t(t.name_key), Book.INK, 16)
		name_.clip_text = true
		name_.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(name_)
		grid.add_child(row)
	return grid


## A thin rule between the sections.
func _rule() -> Control:
	var r := ColorRect.new()
	r.color = Color(Book.GILT, 0.45)
	r.custom_minimum_size.y = 1.0
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return r


# ---- the foot: the ways on (Ver os Dons, Compêndio) ----

func _footer() -> Control:
	var row := HBoxContainer.new()
	row.name = "foot"
	var fill := Control.new()
	fill.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(fill)
	row.add_theme_constant_override(&"separation", 10)
	_to_gifts = Book.button(T.t(&"hero_gifts"), _open_dons, FOOT_WIDTH)
	_to_gifts.name = "to_gifts"
	row.add_child(_to_gifts)
	_codex_button = Book.button(T.t(&"pause_moves"), _open_codex, FOOT_WIDTH)
	_codex_button.name = "codex"
	row.add_child(_codex_button)
	# the page's dog-ear is in this corner
	var ear := Control.new()
	ear.custom_minimum_size.x = EAR_ROOM
	ear.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(ear)
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
	_dons.closed.connect(_close_dons)
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


# ---- chapters and the turn ----

## LB and RB (PageUp, PageDown), the wheel and the d-pad off the edge of the page turn it.
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
	var step := page_step(event)
	if step != 0:
		get_viewport().set_input_as_handled()
		_turn_page(step)


## The way an input turns the book: -1 back, 1 forward, 0 none.
static func page_step(event: InputEvent) -> int:
	if event.is_echo():
		return 0
	if event.is_action_pressed(&"tab_next"):
		return 1
	if event.is_action_pressed(&"tab_prev"):
		return -1
	if event is InputEventMouseButton and (event as InputEventMouseButton).pressed:
		match (event as InputEventMouseButton).button_index:
			MOUSE_BUTTON_WHEEL_DOWN:
				return 1
			MOUSE_BUTTON_WHEEL_UP:
				return -1
	# the d-pad that found no neighbour: off the right edge of the right page, off the left edge of the left one
	if event.is_action_pressed(&"ui_right"):
		return 1
	if event.is_action_pressed(&"ui_left"):
		return -1
	return 0


## Shows chapter c at once: its pages, its ribbon, its name and its folios.
func _show(c: int) -> void:
	chapter = c as Chapter
	for i in chapters.size():
		BookRibbon.set_open(chapters[i], i == c)
		_left[i].visible = i == c
		_right[i].visible = i == c
	_foot.visible = chapter == Chapter.HERO
	var title: String = String(chapters[c].get_meta(&"title", ""))
	_name_cap.text = title.left(1)
	_name_rest.text = title.substr(1)
	_name_rest.add_theme_color_override(&"font_color", GiftArt.title_ink(loadout.hero) if chapter == Chapter.HERO else Book.INK)
	for side in _folios.size():
		_folios[side].text = FOLIO[c][side]


## Turns to chapter c with the page turn (one turn a chapter of distance); at once where there is no screen to draw it.
func go(c: int) -> void:
	if c == chapter:
		return
	_trip += 1
	var trip := _trip
	if not BookTurn.can_animate() or not _book.is_visible_in_tree() or _turn.busy:
		_turn.finish()
		_show(c)
		return
	var route := BookTurn.route(chapter, c)
	var secs := TURN if route.size() == 1 else TURN_FAR
	for step in route:
		if trip != _trip:
			return
		await _turn.flip(_book, step > chapter, _show.bind(step), secs)


## The chapter before (-1) or after (1), looping, with the focus on its first control.
func _turn_page(step: int) -> void:
	var c := BookTurn.next(chapter, step, chapters.size())
	go(c)
	_chapter_focus(c).grab_focus()


## Focus at the start: the chapter's own first control.
func _first_focus() -> Control:
	return _chapter_focus(chapter)


func _chapter_focus(c: Chapter) -> Control:
	match c:
		Chapter.OPENING:
			# in the hub the Opening has no way down: its ribbon holds the focus
			return _down if _down != null else chapters[Chapter.OPENING]
		Chapter.HERO:
			return _to_gifts
		Chapter.OFICIOS:
			return chapters[Chapter.OFICIOS]
	return chapters[c]


func _refresh() -> void:
	if is_instance_valid(_wallet):
		MaterialCount.refresh(_wallet, _data)
	var next := loadout.next_unlocks()
	_next.text = T.t(&"hero_next", {"n": loadout.level() + 1, "what": ", ".join(next)}) if not next.is_empty() else ""


## The control in focus pressed (the action bar's click).
func _press_focus() -> void:
	var f := get_viewport().gui_get_focus_owner() as BaseButton
	if f != null and is_ancestor_of(f) and not f.disabled:
		f.pressed.emit()
