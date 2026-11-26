class_name EncounterScreen
extends Control
## The meeting with the angels (Rejogabilidade, Fatia 1; BC-3 and BC-4, Daniel 2026-11-23): a stage, not a list of
## cards. One angel stands at each side of the screen, the whole height (AngelStage: its painting fading into the dark
## and its family's effect, AngelFx), the run dimmed between them. The angel in focus is lit and a little nearer, the
## other dim and back (~0.2 s); the speech box at the foot, in the centre, names the one in focus and says its line of
## temperament, its family and how many of its Blessings the hero carries (the one fact the choice turns on), with
## "Ouvir {name}" and the real key. Left and right (keys, stick, or the mouse over a side) change the focus; Enter, A or
## a click take it and its cards open on the choice screen (BoonChoice.by_angel). There, B or Esc goes back to the pair
## (the same two, the same cards: Encounters.cards_of has its own dice). One angel only (the door that showed one): no
## screen at all, straight to its cards (PT-26-2). The robot and --autopick never open it.
## It replaces the provisional AngelChoice: attach listens to the run's meetings (Encounters.opened).
##   EncounterScreen.attach(game)          # once, when the run is ready (Hud does it)
##   --encounter=sarael,nivael             # dev: opens this meeting at once (one id: the lone angel)

signal chosen(angel: AngelDef)

const FADE_S := 0.18
const BOX_MIN := 460.0
const BOX_MAX := 680.0
const NAME_SIZE := 30
const LINE_SIZE := 19

var angels: Array[AngelDef] = []
## One transparent button a side (the whole side is the hit area); each holds its AngelStage.
var buttons: Array[Button] = []
var stages: Array[AngelStage] = []
var focus := 0
var _opened_at := 0
var _held: Array[int] = []
var _box: PanelContainer
var _content: Control
var _style: StyleBoxFlat
var _seal: AngelSeal
var _name: Label
var _family: Label
var _line: Label
var _have: Label
var _hear: Label


## Listens to a run's meetings with the angels: the screen opens on each, and after the cards, B or Esc comes back.
static func attach(game: Game) -> void:
	if game == null or game.encounters == null or game.encounters.has_meta(&"encounter_screen"):
		return
	game.encounters.set_meta(&"encounter_screen", true)
	game.encounters.opened.connect(_meet.bind(game))


static func _meet(pair: Array, game: Game, focus_at := 0) -> void:
	var typed: Array[AngelDef] = []
	typed.assign(pair)
	# PT-26-2: a lone angel has nothing to choose: straight to its cards (its painted portrait stays over them)
	if typed.size() == 1:
		_take(game, typed, typed[0])
		return
	var s := EncounterScreen.new()
	game.open_screen(s)
	s.open(typed, game.boons, focus_at)
	s.chosen.connect(func(a: AngelDef) -> void:
		game.close_screen()
		_take(game, typed, a))


## The angel taken: its cards open on the choice screen. Esc there goes back to the pair, the same two with the focus on
## the one just seen (a lone angel has no pair).
static func _take(game: Game, typed: Array[AngelDef], a: AngelDef) -> void:
	game.choice_back = Callable() if typed.size() < 2 else func() -> void:
		game.close_screen()
		game.encounters.angels_now.assign(typed)
		_meet(typed, game, typed.find(a))
	game.encounters.choose(a)
	var choice := _choice_of(game)
	if choice != null:
		choice.by_angel(a, game.choice_back)


## The choice screen the run has open now (null: none, as for the rest card taken at once).
static func _choice_of(game: Game) -> BoonChoice:
	for c in game.ui.get_children():
		if c is BoonChoice and not c.is_queued_for_deletion():
			return c
	return null


## state: the hero's Blessings now (the count of each angel's family); focus_at: the angel in focus first.
func open(p_angels: Array[AngelDef], state: BoonState = null, focus_at := 0) -> void:
	angels = p_angels
	name = "encounter_screen"
	theme = UiKit.theme()
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_opened_at = Time.get_ticks_msec()
	var pair := angels.size() > 1
	for i in angels.size():
		var a := angels[i]
		_held.append(held_of(state, a))
		var b := Button.new()
		b.name = String(a.id)
		b.focus_mode = Control.FOCUS_ALL
		var empty := StyleBoxEmpty.new()
		for st: StringName in [&"normal", &"hover", &"pressed", &"hover_pressed", &"focus", &"disabled"]:
			b.add_theme_stylebox_override(st, empty)
		if pair:
			b.anchor_left = 0.5 * i
			b.anchor_right = 0.5 * (i + 1)
		else:
			b.anchor_right = 1.0
		b.anchor_bottom = 1.0
		add_child(b)
		var stage := AngelStage.new().setup(a, i == 1)
		stage.anchor_right = 1.0 if pair else 0.62
		stage.anchor_left = 0.0 if pair else 0.05
		stage.anchor_bottom = 1.0
		b.add_child(stage)
		stages.append(stage)
		buttons.append(b)
		b.mouse_entered.connect(func() -> void:
			if not b.has_focus():
				b.grab_focus())
		b.focus_entered.connect(_focus_on.bind(i))
		b.pressed.connect(_pick.bind(a))
	if pair:
		# left and right swap sides: explicit neighbours, the outer edges stay put
		var p0 := buttons[0].get_path()
		var p1 := buttons[1].get_path()
		buttons[0].focus_neighbor_right = p1
		buttons[0].focus_neighbor_left = p0
		buttons[1].focus_neighbor_left = p0
		buttons[1].focus_neighbor_right = p1
	_build_head(pair)
	_build_box()
	var entries: Array = []
	if pair:
		entries.append(ActionBar.entry(ActionBar.STEP, T.t(&"encounter_swap")))
	entries.append(ActionBar.entry(&"ui_accept", T.t(&"bar_choose"), _press_focus))
	ActionBar.attach(self, entries)
	Audio.play(&"level_up")
	focus = clampi(focus_at, 0, buttons.size() - 1)
	for i in stages.size():
		stages[i].lit = 1.0 if i == focus else 0.0
	_show(focus)
	buttons[focus].grab_focus.call_deferred()


func _build_head(pair: bool) -> void:
	var col := VBoxContainer.new()
	col.name = "head"
	col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.set_anchors_preset(Control.PRESET_CENTER_TOP)
	col.grow_horizontal = Control.GROW_DIRECTION_BOTH
	col.offset_top = 22
	col.add_theme_constant_override(&"separation", 4)
	add_child(col)
	var title := UiKit.shadow(UiKit.title(T.t(&"encounter_title" if pair else &"encounter_alone"), 36))
	title.name = "title"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(title)
	var hint := UiKit.shadow(UiKit.label(T.t(&"encounter_hint" if pair else &"encounter_hint_alone"), UiKit.DIM, 17))
	hint.name = "hint"
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(hint)


## The speech box: ink and old gold, the name plaque and the line of the angel in focus, "Ouvir" and its key.
func _build_box() -> void:
	_box = PanelContainer.new()
	_box.name = "speech"
	_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_style = UiKit.box(Color(UiKit.INK, 0.93), Color(UiKit.OLD_GOLD, 0.8), 2, 0, 8)
	_style.content_margin_left = 24
	_style.content_margin_right = 24
	_style.content_margin_top = 16
	_style.content_margin_bottom = 14
	_style.shadow_color = Color(0, 0, 0, 0.5)
	_style.shadow_size = 12
	_box.add_theme_stylebox_override(&"panel", _style)
	_box.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	_box.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_box.grow_vertical = Control.GROW_DIRECTION_BEGIN
	_box.offset_bottom = -(ActionBar.RESERVE + 10.0)
	add_child(_box)
	var v := VBoxContainer.new()
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.add_theme_constant_override(&"separation", 8)
	_box.add_child(v)
	_content = v
	var head := HBoxContainer.new()
	head.mouse_filter = Control.MOUSE_FILTER_IGNORE
	head.add_theme_constant_override(&"separation", 14)
	v.add_child(head)
	_seal = AngelSeal.new().setup(angels[0].family, 52.0)
	_seal.name = "seal"
	head.add_child(_seal)
	var words := VBoxContainer.new()
	words.mouse_filter = Control.MOUSE_FILTER_IGNORE
	words.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	head.add_child(words)
	_name = UiKit.shadow(UiKit.title("", NAME_SIZE))
	_name.name = "name"
	words.add_child(_name)
	_family = UiKit.label("", UiKit.OLD_GOLD.lightened(0.3), 16, UiKit.TITLE_FONT)
	_family.name = "family"
	words.add_child(_family)
	var rule := GoldRule.new()
	rule.custom_minimum_size = Vector2(0, 10)
	v.add_child(rule)
	_line = UiKit.label("", UiKit.PALE, LINE_SIZE)
	_line.name = "line"
	_line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	v.add_child(_line)
	_have = UiKit.label("", UiKit.DIM.lightened(0.2), 15, UiKit.number_font())
	_have.name = "held"
	_have.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	v.add_child(_have)
	var hear := HBoxContainer.new()
	hear.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hear.alignment = BoxContainer.ALIGNMENT_CENTER
	hear.add_theme_constant_override(&"separation", 10)
	v.add_child(hear)
	_hear = UiKit.label("", ActionBar.VERB_COLOR, 18, UiKit.BOLD_FONT)
	_hear.name = "Hear"
	hear.add_child(_hear)
	hear.add_child(BoonCard.key_plaque(&"ui_accept"))
	_fit_box()
	resized.connect(_fit_box)


func _fit_box() -> void:
	if _box == null:
		return
	var w := clampf(size.x * 0.4, BOX_MIN, BOX_MAX)
	_box.custom_minimum_size.x = w
	_box.offset_left = -w * 0.5
	_box.offset_right = w * 0.5


## The words of the angel at i in the box (the box's line takes its colour).
func _show(i: int) -> void:
	var a := angels[i]
	var tint := AngelSeal.tint(a.family)
	var fam := T.t(Boon.FAMILY_KEY[a.family])
	_seal.family = a.family
	_seal.queue_redraw()
	_name.text = T.t(a.name_key)
	_name.add_theme_color_override(&"font_color", tint.lightened(0.25))
	_family.text = T.t(&"encounter_family", {"family": fam})
	_line.text = T.t(a.line_key)
	_have.text = T.t(&"encounter_held", {"n": _held[i], "family": fam}) if _held[i] > 0 else T.t(&"encounter_held_none", {"family": fam})
	_hear.text = T.t(&"encounter_hear", {"name": T.t(a.name_key)})
	_style.border_color = Color(tint, 0.75)
	_box.queue_redraw()


func _focus_on(i: int) -> void:
	if i == focus:
		return
	focus = i
	_show(i)
	_content.modulate.a = 0.0
	create_tween().tween_property(_content, "modulate:a", 1.0, FADE_S)


func _process(delta: float) -> void:
	for i in stages.size():
		stages[i].follow(1.0 if i == focus else 0.0, delta)


func _draw() -> void:
	# the run dimmed between the angels, a deeper foot for the box
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.02, 0.015, 0.03, 0.4))
	var foot := size.y * 0.4
	var ink := Color(0.02, 0.015, 0.03, 0.55)
	draw_polygon(PackedVector2Array([Vector2(0, size.y - foot), Vector2(size.x, size.y - foot), size, Vector2(0, size.y)]),
		PackedColorArray([Color(ink, 0.0), Color(ink, 0.0), ink, ink]))


## How many Blessings of an angel's family the hero carries (its Elos count when one of their lists is the family).
static func held_of(state: BoonState, a: AngelDef) -> int:
	if state == null:
		return 0
	var n := 0
	for b in state.owned():
		if Encounter.belongs(state, b, a.family):
			n += 1
	return n


## The angel in focus taken (the action bar's click).
func _press_focus() -> void:
	if focus < buttons.size():
		buttons[focus].pressed.emit()


func _pick(a: AngelDef) -> void:
	# a button still held from the fight never picks (BoonChoice.GUARD_MS)
	if Time.get_ticks_msec() - _opened_at < BoonChoice.GUARD_MS:
		return
	chosen.emit(a)
