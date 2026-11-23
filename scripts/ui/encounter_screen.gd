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

## The seal stands for the angel while the angels have no figure (ciclo visual 2026-11-20, item 3: "dê presença ao
## selo"): large, over a soft glow of its colour (GLOW_*: under the glow threshold, a light of the card's own).
const SEAL := 176.0
const CARD := Vector2(300, 412)
## BC-3: with a painting the angel stands at its side of the screen, the arena between: the figure, the line and the
## "Ouvir" under it; the one in focus lit, the other dimmed.
## PT-7 (Daniel, 2026-11-23: "os anjos devem aparecer maiores"): the figure stands beside the words, on the screen's
## outer side, as tall as the card (the painting is 2:3, so its height sets its size; it was 180 x 270 over the words).
const FIGURE := Vector2(300.0, 450.0)
const WORDS_W := 230.0
const PAINTED_CARD := Vector2(FIGURE.x + WORDS_W, 470.0)
const PAGE_W := 1180.0
const SEAL_SMALL := 48.0
const DIM := 0.5
const GLOW_REACH := 1.25
const GLOW_ALPHA := 0.28
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
		# Esc on the cards: back to the pair, the same two, the focus on the one just seen
		game.choice_back = func() -> void:
			game.close_screen()
			game.encounters.angels_now.assign(typed)
			_meet(typed, game, typed.find(a))
		game.encounters.choose(a)
		var choice := _choice_of(game)
		if choice != null:
			choice.by_angel(a, game.choice_back))


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
	var page := UiKit.column(self, PAGE_W, 0.5)
	page.add_theme_constant_override(&"separation", 20)
	var title := UiKit.shadow(UiKit.title(T.t(&"encounter_title" if angels.size() > 1 else &"encounter_alone"), 40))
	title.name = "title"
	page.add_child(title)
	var row := HBoxContainer.new()
	row.name = "angels"
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override(&"separation", 40)
	var hint := UiKit.shadow(UiKit.label(T.t(&"encounter_hint"), UiKit.DIM, 18))
	hint.name = "hint"
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	page.add_child(hint)  # under the title, clear of the HUD's foot
	page.add_child(row)
	for i in angels.size():
		var a := angels[i]
		var card := AngelCard.new().setup(a, held_of(state, a), i == 1)
		card.pressed.connect(_pick.bind(a))
		buttons.append(card)
		row.add_child(card)
		if i == 0 and angels.size() > 1:
			# the arena shows between the two
			var gap := Control.new()
			gap.name = "arena"
			gap.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			gap.mouse_filter = Control.MOUSE_FILTER_IGNORE
			row.add_child(gap)
	row.custom_minimum_size.x = PAGE_W if angels.size() > 1 else 0.0
	ActionBar.attach(self, [ActionBar.entry(&"ui_accept", T.t(&"bar_choose"), _press_focus)])
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


## The card in focus taken (the action bar's click).
func _press_focus() -> void:
	var f := get_viewport().gui_get_focus_owner() as AngelCard
	if f != null and is_ancestor_of(f):
		f.pressed.emit()


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

	var painted := false

	func setup(a: AngelDef, held: int, mirror := false) -> AngelCard:
		angel = a
		name = String(a.id)
		var art := AngelArt.figure(a, EncounterScreen.FIGURE, mirror)
		painted = art != null
		custom_minimum_size = EncounterScreen.PAINTED_CARD if painted else EncounterScreen.CARD
		focus_mode = Control.FOCUS_ALL
		mouse_entered.connect(func() -> void:
			if not has_focus():
				grab_focus())
		var tint := AngelSeal.tint(a.family)
		var empty := StyleBoxEmpty.new()
		for s: StringName in [&"normal", &"hover", &"pressed", &"hover_pressed", &"focus", &"disabled"]:
			add_theme_stylebox_override(s, empty)
		focus_entered.connect(_lit.bind(true))
		focus_exited.connect(_lit.bind(false))
		if painted:
			modulate.a = EncounterScreen.DIM
		var v := VBoxContainer.new()
		v.name = "body"
		v.mouse_filter = Control.MOUSE_FILTER_IGNORE
		v.add_theme_constant_override(&"separation", 6)
		if painted:
			# PT-7: figure and words side by side, the figure on the outer side looking in (the right one mirrored)
			var side := HBoxContainer.new()
			side.name = "side"
			side.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
			side.mouse_filter = Control.MOUSE_FILTER_IGNORE
			side.add_theme_constant_override(&"separation", 0)
			add_child(side)
			art.size_flags_vertical = Control.SIZE_SHRINK_CENTER
			v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			v.alignment = BoxContainer.ALIGNMENT_CENTER
			var pad := MarginContainer.new()
			pad.mouse_filter = Control.MOUSE_FILTER_IGNORE
			pad.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			for k: String in ["left", "right", "top", "bottom"]:
				pad.add_theme_constant_override("margin_" + k, 16)
			pad.add_child(v)
			side.add_child(pad if mirror else art)
			side.add_child(art if mirror else pad)
		else:
			v.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
			v.offset_left = 22
			v.offset_right = -22
			v.offset_top = 24
			v.offset_bottom = -20
			add_child(v)
		var seal := AngelSeal.new().setup(a.family, EncounterScreen.SEAL_SMALL if painted else EncounterScreen.SEAL)
		seal.name = "seal"
		seal.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		seal.item_rect_changed.connect(queue_redraw)
		var n := UiKit.shadow(UiKit.title(T.t(a.name_key), EncounterScreen.NAME_SIZE, tint.lightened(0.25)))
		n.name = "name"
		n.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT if painted else HORIZONTAL_ALIGNMENT_CENTER
		var fam := UiKit.label(T.t(&"encounter_family", {"family": T.t(Boon.FAMILY_KEY[a.family])}), UiKit.OLD_GOLD.lightened(0.3), 16, UiKit.TITLE_FONT)
		fam.name = "family"
		fam.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT if painted else HORIZONTAL_ALIGNMENT_CENTER
		if painted:
			# the small seal beside its name and family
			var head := HBoxContainer.new()
			head.name = "head"
			head.mouse_filter = Control.MOUSE_FILTER_IGNORE
			head.add_theme_constant_override(&"separation", 12)
			head.add_child(seal)
			var words := VBoxContainer.new()
			words.mouse_filter = Control.MOUSE_FILTER_IGNORE
			words.size_flags_vertical = Control.SIZE_SHRINK_CENTER
			words.add_child(n)
			words.add_child(fam)
			head.add_child(words)
			v.add_child(head)
		else:
			v.add_child(seal)
			v.add_child(n)
			v.add_child(fam)
			var rule := GoldRule.new()
			rule.custom_minimum_size = Vector2(200, 10)
			rule.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
			v.add_child(rule)
		var line := UiKit.label(T.t(a.line_key), UiKit.PALE, EncounterScreen.LINE_SIZE)
		line.name = "line"
		line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		line.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT if painted else HORIZONTAL_ALIGNMENT_CENTER
		line.custom_minimum_size.x = EncounterScreen.WORDS_W - 32.0 if painted else 200.0
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
		have.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT if painted else HORIZONTAL_ALIGNMENT_CENTER
		v.add_child(have)
		# "Ouvir {name}" with the key, under the angel (the key only on the one in focus)
		var hear := HBoxContainer.new()
		hear.name = "hear"
		hear.mouse_filter = Control.MOUSE_FILTER_IGNORE
		hear.alignment = BoxContainer.ALIGNMENT_BEGIN if painted else BoxContainer.ALIGNMENT_CENTER
		hear.add_theme_constant_override(&"separation", 10)
		_plaque = BoonCard.key_plaque(&"ui_accept")
		_plaque.modulate.a = 0.0
		var verb := UiKit.label(T.t(&"encounter_hear", {"name": T.t(a.name_key)}), ActionBar.VERB_COLOR, 18, UiKit.BOLD_FONT)
		verb.name = "Hear"
		hear.add_child(verb)
		hear.add_child(_plaque)
		v.add_child(hear)
		return self

	var _plaque: Control

	## The angel in focus is lit and shows the key that hears it; the other waits dimmed.
	func _lit(on: bool) -> void:
		if painted:
			modulate.a = 1.0 if on else EncounterScreen.DIM
		_plaque.modulate.a = 1.0 if on else 0.0
		queue_redraw()

	func _draw() -> void:
		var r := Rect2(Vector2.ZERO, size)
		var tint := AngelSeal.tint(angel.family)
		if painted:
			# a soft ink behind the words so they read over the fight
			var mirror := (find_child("side", false, false) as Control).get_child(0) is MarginContainer
			var fig_x := size.x - EncounterScreen.FIGURE.x if mirror else 0.0
			var words := Rect2(0.0 if mirror else EncounterScreen.FIGURE.x, 0.0, EncounterScreen.WORDS_W, size.y)
			draw_style_box(UiKit.box(Color(0.02, 0.015, 0.03, 0.66), Color(0, 0, 0, 0), 0, 0, 10), words)
			# a soft light of its colour behind the figure when in focus
			if has_focus():
				var c := Vector2(fig_x + EncounterScreen.FIGURE.x * 0.5, size.y * 0.5)
				for k in 8:
					var t := float(k) / 8.0
					draw_circle(c, EncounterScreen.FIGURE.y * 0.62 * (1.0 - t * 0.6), Color(tint, 0.05 * (0.4 + t)))
			return
		var bg := UiKit.box(BoonCard.INK_LIT if has_focus() else BoonCard.INK, Color(tint, 0.7), 2, 0, 8)
		bg.shadow_color = Color(tint, 0.3 if has_focus() else 0.15)
		bg.shadow_size = 14
		draw_style_box(bg, r)
		# the seal's own light behind it, in its colour, rings fading out
		var seal := find_child("seal", true, false) as Control
		if seal != null:
			var c := seal.get_global_rect().get_center() - get_global_rect().position
			var reach := EncounterScreen.SEAL * 0.5 * EncounterScreen.GLOW_REACH
			for k in 8:
				var t := float(k) / 8.0
				draw_circle(c, reach * (1.0 - t * 0.6), Color(tint, EncounterScreen.GLOW_ALPHA * 0.16 * (0.4 + t)))
		draw_rect(r.grow(-BoonCard.METAL_INSET), Color(UiKit.OLD_GOLD, 0.6), false, 1.0)
		if has_focus():
			BoonCard.draw_focus(self, r)
