class_name EncounterScreen
extends Control
## The meeting with two angels (Rejogabilidade, Fatia 1; sistemas.md 1.6, 3.1 and 5.3; UI review d2ff05d, "Fatia 1"
## 5): a screen of the fight, so in the choice screen's language (BoonChoice: a title in Cinzel over the darkened run,
## the hint under it), not the Livro's. Each angel is a tall card of ink (AngelCard): its seal large (AngelSeal: the
## house's seal with its family's mark, never sun, cross, lion, shield nor eye), its name, its family, its line of
## temperament and how many Blessings of that family the hero carries (the one fact the choice turns on). The focus
## starts on the first (A10: one press to choose); Enter, A or a click take it, and its three cards open on the choice
## screen with its seal small over them. There, B or Esc goes back to the pair (BoonChoice.by_angel): the same pair,
## the same cards each time (Encounters.cards_of has its own dice). It replaces the provisional AngelChoice: attach
## listens to the run's meetings (Encounters.opened), so the provisional one never opens.
##   EncounterScreen.attach(game)          # once, when the run is ready (Hud does it)

signal chosen(angel: AngelDef)

const SEAL := 128.0
const CARD := Vector2(300, 392)
const NAME_SIZE := 30
const LINE_SIZE := 17

var angels: Array[AngelDef] = []
var buttons: Array[Button] = []
var _opened_at := 0


## Listens to a run's meetings with the angels: the screen opens on each, and after the cards, B or Esc comes back.
static func attach(game: Game) -> void:
	if game == null or game.encounters == null or game.encounters.has_meta(&"encounter_screen"):
		return
	game.encounters.set_meta(&"encounter_screen", true)
	game.encounters.opened.connect(_meet.bind(game))


static func _meet(pair: Array, game: Game, focus := 0) -> void:
	var s := EncounterScreen.new()
	game.open_screen(s)
	var typed: Array[AngelDef] = []
	typed.assign(pair)
	s.open(typed, game.boons, focus)
	s.chosen.connect(func(a: AngelDef) -> void:
		game.close_screen()
		game.encounters.choose(a)
		var choice := _choice_of(game)
		if choice != null:
			choice.by_angel(a, func() -> void:
				# back to the pair: the same two, the focus on the one just seen
				game.close_screen()
				game.encounters.angels_now.assign(typed)
				_meet(typed, game, typed.find(a))))


## The choice screen the run has open now (null: none, as for the rest card taken at once).
static func _choice_of(game: Game) -> BoonChoice:
	for c in game.ui.get_children():
		if c is BoonChoice and not c.is_queued_for_deletion():
			return c
	return null


## state: the hero's Blessings now (the count of each angel's family); focus: the card in focus first.
func open(p_angels: Array[AngelDef], state: BoonState = null, focus := 0) -> void:
	angels = p_angels
	name = "encounter_screen"
	theme = UiKit.theme()
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_opened_at = Time.get_ticks_msec()
	var page := UiKit.column(self, 1100.0, 0.74)
	page.add_theme_constant_override(&"separation", 20)
	var title := UiKit.shadow(UiKit.title(T.t(&"encounter_title" if angels.size() > 1 else &"encounter_alone"), 40))
	title.name = "title"
	page.add_child(title)
	var row := HBoxContainer.new()
	row.name = "angels"
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override(&"separation", 40)
	page.add_child(row)
	for a in angels:
		var card := AngelCard.new().setup(a, held_of(state, a))
		card.pressed.connect(_pick.bind(a))
		buttons.append(card)
		row.add_child(card)
	var hint := UiKit.shadow(UiKit.label(T.t(&"encounter_hint"), UiKit.DIM, 20))
	hint.name = "hint"
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	page.add_child(hint)
	Audio.play(&"level_up")
	if not buttons.is_empty():
		buttons[clampi(focus, 0, buttons.size() - 1)].grab_focus.call_deferred()


## How many Blessings of an angel's family the hero carries (its Elos count when one of their lists is the family).
static func held_of(state: BoonState, a: AngelDef) -> int:
	if state == null:
		return 0
	var n := 0
	for b in state.owned():
		if Encounter.belongs(state, b, a.family):
			n += 1
	return n


func _pick(a: AngelDef) -> void:
	# a button still held from the fight never picks (BoonChoice.GUARD_MS)
	if Time.get_ticks_msec() - _opened_at < BoonChoice.GUARD_MS:
		return
	chosen.emit(a)


## An angel's card: ink with a line of its colour, its seal, name, family, temperament and the Blessings held; the
## focus the Blessing cards' own ivory brackets (BoonCard.draw_focus), never a change of the outer line.
class AngelCard:
	extends Button

	var angel: AngelDef

	func setup(a: AngelDef, held: int) -> AngelCard:
		angel = a
		name = String(a.id)
		custom_minimum_size = EncounterScreen.CARD
		focus_mode = Control.FOCUS_ALL
		mouse_entered.connect(func() -> void:
			if not has_focus():
				grab_focus())
		var tint := AngelSeal.tint(a.family)
		var empty := StyleBoxEmpty.new()
		for s: StringName in [&"normal", &"hover", &"pressed", &"hover_pressed", &"focus", &"disabled"]:
			add_theme_stylebox_override(s, empty)
		focus_entered.connect(queue_redraw)
		focus_exited.connect(queue_redraw)
		var v := VBoxContainer.new()
		v.name = "body"
		v.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		v.offset_left = 22
		v.offset_right = -22
		v.offset_top = 24
		v.offset_bottom = -20
		v.mouse_filter = Control.MOUSE_FILTER_IGNORE
		v.add_theme_constant_override(&"separation", 6)
		add_child(v)
		var seal := AngelSeal.new().setup(a.family, EncounterScreen.SEAL)
		seal.name = "seal"
		seal.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		v.add_child(seal)
		var n := UiKit.shadow(UiKit.title(T.t(a.name_key), EncounterScreen.NAME_SIZE, tint.lightened(0.25)))
		n.name = "name"
		n.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		v.add_child(n)
		var fam := UiKit.label(T.t(&"encounter_family", {"family": T.t(Boon.FAMILY_KEY[a.family])}), UiKit.OLD_GOLD.lightened(0.3), 16, UiKit.TITLE_FONT)
		fam.name = "family"
		fam.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		v.add_child(fam)
		var rule := GoldRule.new()
		rule.custom_minimum_size = Vector2(200, 10)
		rule.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		v.add_child(rule)
		var line := UiKit.label(T.t(a.line_key), UiKit.PALE, EncounterScreen.LINE_SIZE)
		line.name = "line"
		line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		line.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		line.custom_minimum_size.x = 200
		v.add_child(line)
		var fill := Control.new()
		fill.size_flags_vertical = Control.SIZE_EXPAND_FILL
		fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
		v.add_child(fill)
		var family := T.t(Boon.FAMILY_KEY[a.family])
		var have := UiKit.label(T.t(&"encounter_held", {"n": held, "family": family}) if held > 0
			else T.t(&"encounter_held_none", {"family": family}), UiKit.DIM.lightened(0.2), 15, UiKit.number_font())
		have.name = "held"
		have.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		have.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		v.add_child(have)
		return self

	func _draw() -> void:
		var r := Rect2(Vector2.ZERO, size)
		var tint := AngelSeal.tint(angel.family)
		var bg := UiKit.box(BoonCard.INK_LIT if has_focus() else BoonCard.INK, Color(tint, 0.7), 2, 0, 8)
		bg.shadow_color = Color(tint, 0.3 if has_focus() else 0.15)
		bg.shadow_size = 14
		draw_style_box(bg, r)
		draw_rect(r.grow(-BoonCard.METAL_INSET), Color(UiKit.OLD_GOLD, 0.6), false, 1.0)
		if has_focus():
			BoonCard.draw_focus(self, r)
