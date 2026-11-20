class_name Hud
extends Control
## What stays on screen during the run. Bottom left: the paladin's medallion with life and Magia. Bottom centre: the
## four actions as diamonds (the gift on each, the key, the recharge, the dodges) and the gifts that act alone.
## Top: the room (or the level), the clock, the gold (or the kills); the boss's life under the clock. Right: the
## hit count and the move's name. Everything sits on the edges so the middle of the screen stays for the fight: the
## actions turn translucent while someone stands behind them, and small chevrons on the edge point at the elites,
## the guardian or the boss out of view (the diamonds keep their glyph, recharge and key whole, ActionSlot.veil). One gold for the frames (UiKit.OLD_GOLD, UiKit.FRAME wide), one shadow
## under every text (UiKit.shadow).
## A boss's curse: a seal beside the medallion with a ring that empties and two short lines (what it is, what it
## does), the medallion's ring tinted violet, the special's diamond locked until a ring of light says it is back.
## A boss's phase: the mark reached on his bar lights and the phase's name shows under the bar for PHASE_TIME (the
## boss's notice for it goes there instead of the middle of the screen). While his ritual's shield stands, the bar
## carries a seal for each of its dead (HudBar.show_ritual) and, once the phase's name is gone, "Derrube os mortos"
## stays under it.
## E5, the Provação: while its curse is carried, a grey-lilac cracked diamond above the medallion with the fights left
## inside and the curse's name beside it (TrialSeal; nothing on the hero, E5-D7); when it turns, the crack fills with
## gold and "Provação vencida" greets from the top (EloBanner.show_trial).
## Sizes are in pixels at 720 lines; the window stretches the whole canvas (project.godot), so the layout holds at
## any resolution.

## Fills of the bars, top and bottom of the gradient: life red, Magia a light petrol blue (apart from Emeth's green
## and, by its value, from the scarf's petrol).
const LIFE_COLOR := Color("c0302a")
const LIFE_BOTTOM := Color("6a1410")
const MAGICK_COLOR := Color("2a8fb8")
const MAGICK_BOTTOM := Color("14506a")
const BOSS_COLOR := Color(0.62, 0.22, 0.85)
const MARGIN := 22.0
const CREST := 76.0
const LIFE := Vector2(244, 19)
const MAGICK := Vector2(196, 15)
## Lining figures (UiKit.number_font): at these sizes the numbers stand 9 px tall or more at 720 lines.
const LIFE_FONT := 16
const MAGICK_FONT := 15
const BOSS := Vector2(480, 12)
const PASSIVE_ICON := 30
const PASSIVE_GAP := 4
## The row of gifts that act alone ends at this share of the screen's width; past it the last place says "+N" (BUG-105).
## Those with a recharge go first: their timer is what is worth a glance in a fight.
const PASSIVE_EDGE := 0.96
const SLOT_GAP := 8
## P1-4 of the Hades II UI benchmark, the default since the art-director's review (ART_REVIEW.md 3.1, A to C;
## --hud=classic keeps the bottom-centre row to compare): the five diamonds smaller (ROW_DIAMOND, about 54 px at 1080)
## in a row over the bars, from the medallion's shoulder, ROW_ABOVE px over the life bar's frame, on a band of ink
## (HudVeil) so the crowd does not run between them, their bodies veiled only by the hero standing behind (never by the
## crowd); nothing stands between 30% and 70% of the width at the bottom. The hit count stands on the row's line, right
## of the last diamond, the move's name under it; the curse's badge and the Provação's seal (conditions, not always
## there) climb over the row and the room of its captions (ROW_CAPTION); the gifts that act alone go to the bottom
## right corner. The block (captions, row, bars, medallion) stays under 200 px tall at 1080.
const ROW_DIAMOND := 36.0
const ROW_GAP := 6
const ROW_ABOVE := 4.0
## The keys hang under the diamonds' point (ActionSlot.key_drop): the little mouse is 22 px tall.
const ROW_KEY_DROP := 7.0
const ROW_CAPTION := 20.0
## The hit count right of the last diamond, and the bottom of the edge chevrons' frame over the whole block.
const ROW_COUNT_GAP := 12.0
const ROW_EDGE_BOTTOM := 168.0
const FONT_SMALL := 15
const FONT_TEXT := 19
const FONT_CLOCK := 22
## The clock's box, where it stands (top middle) and, while a boss's bar is up, under the gold on the right; the
## boss's bar under the clock, or at the top alone while the clock is in the corner.
const CLOCK_BOX := Vector2(120, 30)
const CLOCK_Y := 7.0
const CLOCK_BOSS_Y := 40.0
const BOSS_TOP := 42.0
const BOSS_TOP_ALONE := 12.0
## The hit count (VX-12): its digits stay under 48 px tall at 1080 lines even at the top of the pop, and the move's
## name under it is dimmed, so neither competes with the fight.
const FONT_COMBO := 24
const COMBO_POP := 0.15
## The word "Golpes" and the move's name beside the count, the row's height and where it stands: over the life bar,
## COMBO_INSET px into it from the medallion's edge, COMBO_RISE px above the bar's top (benchmark P0-3).
const COMBO_WORD := 14
const COMBO_H := 28.0
## (14 and 9 since the horde capture of 2026-11-20: at 4 and 6 the move's name touched the medallion's ring and sat on
## the bar's frame.)
const COMBO_INSET := 14.0
const COMBO_RISE := 9.0
const MOVE_ALPHA := 0.7
## The move's name: how long it shows, and how fast it goes (a short cut, no long ghost).
const MOVE_TIME := 1.2
const MOVE_FADE := 0.25
## The phase's name under the boss's bar: seconds it shows, its fade, font sizes.
const PHASE_TIME := 3.0
## An arena's name on walking in (cycle C12, decision D-33): in the place and look of a phase's name, this long.
const PLACE_TIME := 2.0
const PHASE_FADE := 0.4
const PHASE_NAME_SIZE := 18
const PHASE_TIP_SIZE := 15
## The Provação's seal: its diamond (33 px at 1080 lines, spec 5.3 asks about 30) and how far above the medallion.
const TRIAL_SEAL := 22.0
const TRIAL_SEAL_GAP := 6.0
## The curse's colour on the HUD (the same violet as the runes around the paladin) and on the medallion's ring.
const CURSE_COLOR := CurseAura.COLOR
const CURSE_TINT := 0.85
## The actions while someone stands behind them, how fast they change and how often the crowd is checked (seconds).
const VEIL_ALPHA := 0.5
const VEIL_SPEED := 5.0
const VEIL_EVERY := 0.1
## Half the width of a body on screen, pixels, and its height in metres, for that check.
const BODY_HALF := 14.0
const BODY_HEIGHT := 2.4
## Chevrons on the edge of the screen for the elites, the guardian and the boss out of view: how many at most, their
## size, how far inside the screen something counts as in view, and the frame they sit on (left, top, right, bottom:
## clear of the texts at the top, the boss's bar and the bottom row).
const POINTERS := 3
const POINTER_SIZE := 18.0
const VIEW_INSET := 16.0
## (The bottom clears the caption over the ultimate's diamond, "Maestria 2", BUG-111.)
const EDGE_INSET := Vector4(30.0, 96.0, 30.0, 128.0)
## The four actions in the order of the diamonds, with the gift slot that changes each.
const ACTIONS: Array[StringName] = [&"light_attack", &"heavy_attack", &"cast", &"dodge"]
const SLOTS: Array[Boon.Slot] = [Boon.Slot.ATTACK, Boon.Slot.SPECIAL, Boon.Slot.CAST, Boon.Slot.DASH]
## The map's button beside the room's number: its gap, height and how bright its words are (quiet until hovered).
const MAP_GAP := 10
const MAP_BUTTON_HEIGHT := 26.0
const MAP_ALPHA := 0.78
## Seconds the ultimate's caption shows after a refused press or when it fills (T5).
const ULT_HINT_TIME := 1.8

var game: Game
var _crest: HeroCrest
var _life: HudBar
var _magick: HudBar
var _room: Label
## DV-1, MAP-03: "Mapa [M]" beside the room's number (the real key or button), clicked or the map key opens the
## descent's map (MapScreen) over the stopped run. Never takes the focus (Space and Enter stay the dodge).
var map_button: Button
var _clock: Label
var _clock_veil: HudVeil
var _clock_at_boss := false
## The materials greeted so far, by "material/source" (Rejogabilidade, Fatia 1: _greet_materials).
var _found_seen := {}
var _purse: HBoxContainer
var _coin: HudMark
var _gold: Label
var _xp_back: ColorRect
var _xp_fill: ColorRect
var _boss_box: VBoxContainer
var _boss_name: Label
var _boss_bar: HudBar
var _phase_box: VBoxContainer
var _phase_name: Label
var _phase_tip: Label
var _phase_t := 0.0
## Seconds the name under the bar shows this time (a phase's PHASE_TIME, an arena's PLACE_TIME), and whether it is an
## arena's name (shown with no boss bar).
var _phase_len := PHASE_TIME
var _place_shown := false
var _curse_badge: ConditionBadge
## E5: the Provação's seal above the medallion.
var _trial_seal: TrialSeal
var _shield_t := 0.0
## The ritual's shield stands: its hint stays under the bar once the phase's name has gone.
var _ritual_hint := false
var _combo: Label
var _combo_word: Label
var _combo_row: HBoxContainer
var _combo_top := 0.0
var _move: Label
var _notice: Label
var _slots: Array[ActionSlot] = []
## The ultimate's diamond, after the four: its gold level rises with the charge; sealed with "Maestria N" over it
## before the Mastery unlocks one (hidden only for the robot, who has none); a press that cannot let it go says why
## (T5, ult_caption).
var _ult_slot: ActionSlot
## Seconds the ultimate's caption still shows a refused press's reason or "Pronta"; whether the charge was full.
var _ult_hint_t := 0.0
var _ult_was_ready := false
## The how-to-charge notice shows once a run, on the first refused press.
var _ult_told := false
var _ult_heard := false
var _passives: HBoxContainer
var _arrow: Label
var _arrow_mark: HudMark
var _pointers: Array[HudMark] = []
var _action_row: HBoxContainer
var _veil_t := 0.0
var _veiled := false
var _passives_veiled := false
## The diamonds' body opacity (they fade only their bodies, ActionSlot.veil).
var _slot_alpha := 1.0
## The row layout (P1-4, the default; --hud=classic the bottom-centre one) and how much higher what stood over the bars stands in it.
var _row_mode := false
var _row_lift := 0.0
## The band of ink behind the row (B of the review).
var _row_band: HudVeil
## Magia each action's held version costs (by slot).
var _omega_cost := {}
## The dodge's recharge, followed by the run's clock (Player keeps its own timer to itself).
var _dash_charges := -1
var _dash_from := 0.0
var _last_hp := -1.0
var _combo_pop := 0.0
## The hit count shown (on_combo); the count and the move's name hide under a screen.
var _combo_count := 0
var _move_t := 0.0
var _notice_t := 0.0
var _passive_count := -1
## How many medallions the row had room for when it was last laid out (a new window size lays it out again).
var _passive_fit := -1
var _elo_banner: EloBanner
## Elos and new Blessings already greeted (the ones owned when the run starts are not).
var _elos_seen := {}
var _elos_ready := false
## E4-04: Psalms to greet once the choice screen closes (id: {psalm, discovered, taken}), in order.
var _psalms_due := {}


func _ready() -> void:
	theme = UiKit.theme()
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_row_mode = Dev.arg("hud") != "classic"
	_row_lift = ROW_ABOVE + ROW_DIAMOND + ActionSlot.KEY_H * 0.5 + ROW_KEY_DROP + ROW_CAPTION if _row_mode else 0.0
	_build_top()
	_build_life()
	_build_actions()
	_build_combo()
	_notice = _label("", UiKit.PALE, FONT_TEXT + 3, UiKit.TITLE_FONT, Control.PRESET_CENTER_TOP, Vector2(0, 110))
	_notice.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_notice.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_arrow = _label(T.t(&"hud_fountain"), UiKit.PALE, FONT_SMALL + 1, UiKit.BOLD_FONT, Control.PRESET_TOP_LEFT, Vector2.ZERO)
	_arrow.visible = false
	_arrow_mark = _pointer()
	for i in POINTERS:
		_pointers.append(_pointer())
	# the moment an Elo forms: in the notices' place under the clock, well above the paladin
	_elo_banner = EloBanner.new()
	add_child(_elo_banner)
	_place(_elo_banner, Control.PRESET_CENTER_TOP, Vector2(0, 92), Vector2(420, 100))
	if game != null:
		game.psalm_offered.connect(_on_psalm.bind(false))
		game.psalm_taken.connect(_on_psalm.bind(true))
		# Rejogabilidade, Fatia 1: the meetings with the angels open the Encontro (the run's encounters exist once it is
		# ready), and the materials found are greeted
		game.ready.connect(func() -> void: EncounterScreen.attach(game), CONNECT_ONE_SHOT)


## Top: experience (horde mode only, a thin gold line across the top), room or level, clock, gold or kills, boss.
func _build_top() -> void:
	_xp_back = _rect(Color(0.05, 0.03, 0.06, 0.85), Control.PRESET_TOP_WIDE)
	_xp_back.offset_bottom = 4
	_xp_fill = _rect(UiKit.GOLD, Control.PRESET_TOP_LEFT)
	_xp_fill.size = Vector2(0, 4)
	var top_left := HBoxContainer.new()
	top_left.name = "top_left"
	top_left.add_theme_constant_override(&"separation", MAP_GAP)
	top_left.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(top_left)
	_place(top_left, Control.PRESET_TOP_LEFT, Vector2(MARGIN, 8), Vector2(300, 32))
	# every number of the HUD in lining figures (UiKit.number_font): Cinzel's 1 is a bare stroke, "Sala 1 de 11" read
	# "SALA I DE II" (UI review d2ff05d, P0-1)
	_room = UiKit.shadow(UiKit.label("", UiKit.PALE, FONT_TEXT, UiKit.number_font()))
	_room.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	top_left.add_child(_room)
	# the look of the menus' quiet links (UiKit.link), but never focused: hovering it takes nothing from the fight
	map_button = Button.new()
	map_button.name = "map_button"
	map_button.focus_mode = Control.FOCUS_NONE
	map_button.pressed.connect(func() -> void:
		Audio.play(&"ui_ok")
		open_map())
	map_button.add_theme_stylebox_override(&"normal", UiKit.box(Color(0, 0, 0, 0), Color(UiKit.OLD_GOLD, 0.45), 1, 8))
	map_button.add_theme_stylebox_override(&"hover", UiKit.box(Color(0.12, 0.09, 0.06, 0.6), UiKit.OLD_GOLD, 1, 8))
	map_button.add_theme_stylebox_override(&"pressed", UiKit.box(Color(0.16, 0.11, 0.07, 0.8), UiKit.GOLD, 1, 8))
	map_button.add_theme_color_override(&"font_hover_color", UiKit.GOLD)
	map_button.add_theme_constant_override(&"outline_size", 4)
	map_button.add_theme_color_override(&"font_outline_color", UiKit.SHADOW)
	# opens on the press, before the run steps: the click (also the attack) never swings
	map_button.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
	map_button.custom_minimum_size = Vector2(0, MAP_BUTTON_HEIGHT)
	map_button.add_theme_font_size_override(&"font_size", FONT_SMALL)
	map_button.add_theme_color_override(&"font_color", Color(UiKit.PALE, MAP_ALPHA))
	map_button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	map_button.visible = false
	top_left.add_child(map_button)
	_clock = _label("0:00", UiKit.PALE, FONT_CLOCK, UiKit.number_font(), Control.PRESET_CENTER_TOP, Vector2.ZERO)
	_clock.name = "clock"
	_clock.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_clock_veil = _veil([_clock])
	_purse = HBoxContainer.new()
	_purse.add_theme_constant_override(&"separation", 6)
	_purse.alignment = BoxContainer.ALIGNMENT_END
	_purse.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_purse)
	_place(_purse, Control.PRESET_TOP_RIGHT, Vector2(-MARGIN, 10), Vector2(260, 30))
	_coin = HudMark.new().setup(HudMark.Kind.COIN, Vector2(17, 17))
	_coin.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_purse.add_child(_coin)
	_gold = UiKit.shadow(UiKit.label("", UiKit.PALE, FONT_TEXT, UiKit.number_font()))
	_purse.add_child(_gold)
	_boss_box = VBoxContainer.new()
	_boss_box.add_theme_constant_override(&"separation", 2)
	_boss_box.visible = false
	_boss_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_boss_box)
	_place(_boss_box, Control.PRESET_CENTER_TOP, Vector2(0, BOSS_TOP), Vector2(BOSS.x, 40))
	_boss_name = UiKit.shadow(UiKit.title("", FONT_TEXT, UiKit.PALE))
	_boss_name.add_theme_constant_override(&"outline_size", 5)
	_boss_box.add_child(_boss_name)
	_boss_bar = HudBar.new().setup(BOSS_COLOR, BOSS, 11, true)
	_boss_bar.over_color = Horde.ARMOR_COLOR
	_boss_box.add_child(_boss_bar)
	# the phase's name and its hint, under the bar for a moment
	_phase_box = VBoxContainer.new()
	_phase_box.add_theme_constant_override(&"separation", 0)
	_phase_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_phase_box.modulate.a = 0.0
	add_child(_phase_box)
	_place(_phase_box, Control.PRESET_CENTER_TOP, Vector2(0, BOSS_TOP + 40 + 2), Vector2(BOSS.x + 160, 44))
	_phase_name = UiKit.shadow(UiKit.title("", PHASE_NAME_SIZE, UiKit.GOLD))
	_phase_name.add_theme_constant_override(&"outline_size", 5)
	_phase_box.add_child(_phase_name)
	_phase_tip = UiKit.shadow(UiKit.label("", UiKit.PALE, PHASE_TIP_SIZE))
	_phase_tip.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_phase_box.add_child(_phase_tip)
	_place_clock(false)


## Bottom left: the medallion, with life and Magia coming out from behind it.
func _build_life() -> void:
	var mid := MARGIN + CREST * 0.5
	_life = HudBar.new().setup(LIFE_COLOR, LIFE, LIFE_FONT, false, LIFE_BOTTOM)
	add_child(_life)
	_place(_life, Control.PRESET_BOTTOM_LEFT, Vector2(MARGIN + CREST - 10, -mid - 1), LIFE)
	_magick = HudBar.new().setup(MAGICK_COLOR, MAGICK, MAGICK_FONT, false, MAGICK_BOTTOM)
	add_child(_magick)
	# the two frames (UiKit.FRAME each) share one line of ink between them
	_place(_magick, Control.PRESET_BOTTOM_LEFT, Vector2(MARGIN + CREST - 10, -mid + 2.0 * UiKit.FRAME + MAGICK.y), MAGICK)
	_crest = HeroCrest.new().setup(CREST)
	add_child(_crest)
	_place(_crest, Control.PRESET_BOTTOM_LEFT, Vector2(MARGIN, -MARGIN), Vector2(CREST, CREST))
	# a condition (the boss's curse): over the left end of the life bar, against the medallion's shoulder
	_curse_badge = ConditionBadge.new().setup(CURSE_COLOR, T.t(&"hud_cursed"), T.t(&"hud_cursed_effects"))
	add_child(_curse_badge)
	_place(_curse_badge, Control.PRESET_BOTTOM_LEFT, Vector2(MARGIN + CREST - 4, -mid - LIFE.y - 2.0 * UiKit.FRAME - 6 - _row_lift), _curse_badge.size)
	# the Provação's seal: above the medallion, clear of Morvath's curse badge (which sits on the life bar's end)
	_trial_seal = TrialSeal.new().setup(TRIAL_SEAL, true)
	add_child(_trial_seal)
	_place(_trial_seal, Control.PRESET_BOTTOM_LEFT, Vector2(MARGIN + (CREST - TRIAL_SEAL) * 0.5, -MARGIN - CREST - TRIAL_SEAL_GAP - _row_lift), Vector2(TRIAL_SEAL, TRIAL_SEAL))


## Bottom centre: the four action diamonds; the gifts that act alone sit in a row to their right.
func _build_actions() -> void:
	var row := HBoxContainer.new()
	_action_row = row
	row.add_theme_constant_override(&"separation", ROW_GAP if _row_mode else SLOT_GAP)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(row)
	var side := ROW_DIAMOND if _row_mode else ActionSlot.DIAMOND
	var drop := ROW_KEY_DROP if _row_mode else 0.0
	for i in ACTIONS.size():
		var s := ActionSlot.new().setup(ACTIONS[i], SLOTS[i], side, drop)
		row.add_child(s)
		_slots.append(s)
	_ult_slot = ActionSlot.new().setup(&"ultimate", Boon.Slot.NONE, side, drop)
	row.add_child(_ult_slot)
	if _row_mode:
		_build_row(row)
		return
	# (the row is laid out for five; without an ultimate the four stay in the middle)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	var width := row.get_combined_minimum_size().x
	var height := ActionSlot.DIAMOND + ActionSlot.KEY_H * 0.5
	_place(row, Control.PRESET_CENTER_BOTTOM, Vector2(0, -MARGIN + 6), Vector2(width, height))
	_passives = HBoxContainer.new()
	_passives.name = &"Passives"
	_passives.add_theme_constant_override(&"separation", PASSIVE_GAP)
	_passives.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_passives)
	var room := 300.0
	_place(_passives, Control.PRESET_CENTER_BOTTOM, Vector2(width * 0.5 + 18 + room * 0.5, -MARGIN - 4), Vector2(room, PASSIVE_ICON + 6))


## The row layout (P1-4, the default): the diamonds over the bars from the medallion's shoulder on a band of ink, the
## gifts that act alone in the bottom right corner, right-aligned.
func _build_row(row: HBoxContainer) -> void:
	row.alignment = BoxContainer.ALIGNMENT_BEGIN
	var height := ROW_DIAMOND + ActionSlot.KEY_H * 0.5 + ROW_KEY_DROP
	var life_top := MARGIN + CREST * 0.5 + 1.0 + LIFE.y
	_place(row, Control.PRESET_BOTTOM_LEFT, Vector2(MARGIN + CREST - 6, -life_top - ROW_ABOVE), Vector2(row.get_combined_minimum_size().x, height))
	var under: Array[Control] = []
	under.assign(_slots + [_ult_slot])
	_row_band = HudVeil.new()
	_row_band.covers = under
	add_child(_row_band)
	move_child(_row_band, row.get_index())
	_passives = HBoxContainer.new()
	_passives.name = &"Passives"
	_passives.add_theme_constant_override(&"separation", PASSIVE_GAP)
	_passives.alignment = BoxContainer.ALIGNMENT_END
	_passives.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_passives)
	# its right end at PASSIVE_EDGE of the width, as the bottom-centre row's last medallion (BUG-105)
	_passives.anchor_left = PASSIVE_EDGE
	_passives.anchor_right = PASSIVE_EDGE
	_passives.anchor_top = 1.0
	_passives.anchor_bottom = 1.0
	_passives.offset_left = -300.0
	_passives.offset_right = 0.0
	_passives.offset_bottom = -MARGIN
	_passives.offset_top = -MARGIN - PASSIVE_ICON - 6.0


## The hit count and the move's name, by the bars at the bottom left (benchmark_hades2_ui.md P0-3, UI-HB5): out of
## the field, small, without a veil or a stroke, in Alegreya Sans (Cinzel only from 24 px), on one line over the life
## bar's right part: "12 Golpes  Giro da Alvorada". Over the curse badge's line it climbs a line while the badge shows.
func _build_combo() -> void:
	_combo_row = HBoxContainer.new()
	_combo_row.name = &"Combo"
	_combo_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_combo_row.add_theme_constant_override(&"separation", 6)
	add_child(_combo_row)
	_combo = UiKit.shadow(UiKit.label("", UiKit.GOLD, FONT_COMBO, UiKit.number_font()))
	_combo.name = &"Count"
	_combo.add_theme_constant_override(&"outline_size", 5)
	_combo_row.add_child(_combo)
	_combo_word = UiKit.shadow(UiKit.label(T.t(&"hud_hits"), UiKit.PALE, COMBO_WORD, UiKit.BOLD_FONT))
	_combo_word.name = &"Word"
	_combo_word.size_flags_vertical = Control.SIZE_SHRINK_END
	_combo_row.add_child(_combo_word)
	_move = UiKit.shadow(UiKit.label("", UiKit.PALE, COMBO_WORD, UiKit.BOLD_FONT))
	_move.name = &"Move"
	_move.size_flags_vertical = Control.SIZE_SHRINK_END
	_combo_row.add_child(_move)
	if _row_mode:
		# on the row's line, right of the last diamond; the move's name under the count, smaller (C of the review)
		_combo_row.remove_child(_move)
		add_child(_move)
		var x := _action_row.offset_left + _action_row.size.x + ROW_COUNT_GAP
		for c: Control in [_combo_row, _move]:
			c.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
			c.offset_left = x
			c.offset_right = x + LIFE.x
		_combo_row.offset_top = _action_row.offset_top - 2.0
		_combo_row.offset_bottom = _combo_row.offset_top + COMBO_H
		_move.offset_top = _combo_row.offset_bottom - 2.0
		_move.offset_bottom = _move.offset_top + COMBO_WORD + 6.0
	else:
		_place(_combo_row, Control.PRESET_BOTTOM_LEFT, Vector2(MARGIN + CREST + COMBO_INSET, -MARGIN - CREST * 0.5 - LIFE.y - COMBO_RISE), Vector2(LIFE.x, COMBO_H))
	_combo_top = _combo_row.offset_top
	for c: CanvasItem in [_combo, _combo_word]:
		c.visible = false


## A material found greets in the banner (EloBanner.show_material), but not an elite's drop: it is a word where the elite
## fell, as the gold is (Rooms.found), and a greeting for each would crowd the top of the fight.
func _greet_materials() -> void:
	var found: Dictionary = game.materials.found
	for m: StringName in found:
		for source: StringName in found[m]:
			var key := "%s/%s" % [m, source]
			var n := int(found[m][source])
			var was := int(_found_seen.get(key, 0))
			if n > was:
				_found_seen[key] = n
				if source != &"elite":
					_elo_banner.show_material(m, n - was)


## A veil of ink under labels that stand over the scene (HudVeil), drawn under them.
func _veil(over: Array[Control]) -> HudVeil:
	var v := HudVeil.new()
	v.covers = over
	add_child(v)
	move_child(v, over[0].get_index())
	return v


## The clock: at the top in the middle, or, while a boss's bar is up, under the gold in the top right corner, so the
## boss's name stands alone over his bar (UI review d2ff05d, P1-2). The boss's bar and the phase's name go up with it.
func _place_clock(boss: bool) -> void:
	_clock_at_boss = boss
	if boss:
		_place(_clock, Control.PRESET_TOP_RIGHT, Vector2(-MARGIN, CLOCK_BOSS_Y), CLOCK_BOX)
		_clock.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	else:
		_place(_clock, Control.PRESET_CENTER_TOP, Vector2(0, CLOCK_Y), CLOCK_BOX)
		_clock.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var top := BOSS_TOP_ALONE if boss else BOSS_TOP
	_boss_box.position.y = top
	_phase_box.position.y = top + 40 + 2


## Puts a control of a given size at a corner or edge of the screen, moved by offset from there.
## (Bottom presets: offset.y is how far the control's bottom edge sits above the screen's.)
func _place(c: Control, preset: Control.LayoutPreset, offset: Vector2, size_px: Vector2) -> void:
	c.size = size_px
	c.set_anchors_and_offsets_preset(preset, Control.PRESET_MODE_KEEP_SIZE)
	c.position += offset


func _rect(color: Color, preset: Control.LayoutPreset) -> ColorRect:
	var r := ColorRect.new()
	r.color = color
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(r)
	r.set_anchors_and_offsets_preset(preset)
	return r


func _pointer() -> HudMark:
	var m := HudMark.new().setup(HudMark.Kind.CHEVRON, Vector2(POINTER_SIZE, POINTER_SIZE))
	m.visible = false
	add_child(m)
	return m


func _label(text: String, color: Color, size: int, font: Font, preset: Control.LayoutPreset, offset: Vector2) -> Label:
	var l := UiKit.shadow(UiKit.label(text, color, size, font))
	add_child(l)
	l.set_anchors_and_offsets_preset(preset)
	l.position += offset
	if preset in [Control.PRESET_TOP_RIGHT, Control.PRESET_CENTER_RIGHT, Control.PRESET_BOTTOM_RIGHT]:
		l.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	return l


func _process(delta: float) -> void:
	if game == null or game.player == null:
		return
	# the HUD's own fades run in real time: slow motion and the hit stop scale delta (Engine.time_scale)
	delta = game.fx.real_dt if game.fx and game.fx.real_dt > 0.0 else delta
	var p := game.player
	# a screen over the run (cards, pause, an event): the gifts' row and the greetings wait under it (BUG-107)
	var over := game.mode != Game.Mode.PLAY
	_passives.visible = not over
	# the pause's panel stands on the left: the medallion and the bars go under it (UI review d2ff05d, P2-7)
	var paused := game.mode == Game.Mode.PAUSE
	for c: CanvasItem in [_crest, _life, _magick]:
		c.visible = not paused
	for c: CanvasItem in [_combo, _combo_word]:
		c.visible = _combo_count >= 3 and not over
	_move.visible = not over
	# the curse's badge stands on the life bar's line: the count climbs over it meanwhile
	var lift := ConditionBadge.SIZE + 4.0 if _curse_badge.shown() > 0.0 and not _row_mode else 0.0
	_combo_row.offset_top = _combo_top - lift
	_combo_row.offset_bottom = _combo_top - lift + COMBO_H
	_elo_banner.held = over
	_clock.text = SaveData.format_time(game.time)
	_coin.visible = game.rooms != null
	if game.rooms:
		# the descent: which room, and the gold for the shop (no experience here, so no bar over the scene)
		_xp_back.visible = false
		_xp_fill.size.x = 0.0
		_room.text = T.t(&"hud_room", {"n": game.rooms.depth(), "of": game.rooms.stage.rooms + 1})
		map_button.visible = not over
		map_button.text = T.t(&"hud_map", {"key": "[%s]" % UiKit.action_label(&"map")})
		_gold.text = T.t(&"hud_gold_count", {"n": game.rooms.gold})
		_crest.seal = ""
	else:
		_xp_fill.size.x = get_viewport_rect().size.x * game.xp_ratio()
		_room.text = T.t(&"hud_level", {"n": game.level})
		map_button.visible = false
		_gold.text = "%s  %d" % [T.t(&"hud_kills"), game.kills]
		_crest.seal = str(game.level)
	_update_life(p)
	if game.rooms and game.rooms.trials:
		_trial_seal.carry(game.rooms.trials.active, game.rooms.trials.left)
		_trial_seal.hide_name = _curse_badge.shown() > 0.0
	_update_slots(p)
	_update_passives()
	_update_elos()
	_update_psalms()
	_greet_materials()
	# the boss (or the guardian) once a frame: finding a guardian walks the whole crowd
	var chief := game.boss_enemy()
	_update_boss(chief)
	if _boss_box.visible != _clock_at_boss:
		_place_clock(_boss_box.visible)
	_clock_veil.follow()
	if _row_band:
		_row_band.follow()
		_follow_row()
	_combo_pop = maxf(0.0, _combo_pop - delta * 4.0)
	_combo.scale = Vector2.ONE * (1.0 + _combo_pop * COMBO_POP)
	_combo.pivot_offset = _combo.size * Vector2(0.0, 0.5)
	_move_t -= delta
	_move.modulate.a = MOVE_ALPHA * clampf(_move_t / MOVE_FADE, 0.0, 1.0)
	_notice_t -= delta
	_notice.modulate.a = clampf(_notice_t / 0.6, 0.0, 1.0)
	_phase_t -= delta
	_phase_box.modulate.a = minf(clampf(_phase_t / PHASE_FADE, 0.0, 1.0), clampf((_phase_len - _phase_t) / 0.15, 0.0, 1.0))
	_phase_box.visible = _phase_t > 0.0 and (_boss_box.visible or _place_shown)
	if _phase_t <= 0.0 and _boss_box.visible and _shield_t > 0.0 and _ritual_hint:
		_phase_name.visible = false
		_phase_tip.text = T.t(&"ritual_hint")
		_phase_tip.visible = true
		_phase_box.visible = true
		_phase_box.modulate.a = _shield_t
	_update_pointers(chief)
	_update_veil(delta)


func _update_life(p: Player) -> void:
	_life.show_value(p.hp / p.max_hp, "%d / %d" % [ceili(p.hp), roundi(p.max_hp)])
	_magick.show_value(p.magick.ratio(), "%d / %d" % [floori(p.magick.value), roundi(p.magick.max_value)])
	if _last_hp >= 0.0 and p.hp < _last_hp - 0.01:
		_crest.flash = 1.0
	_last_hp = p.hp
	_crest.danger = 1.0 - clampf(p.hp / p.max_hp / 0.3, 0.0, 1.0)
	_curse_badge.ratio = p.curse.ratio()
	_crest.tint = Color(CURSE_COLOR, CURSE_TINT * _curse_badge.shown())


func _update_slots(p: Player) -> void:
	var by_slot := {}
	for b in game.boons.owned():
		by_slot[b.slot] = b
	for s in _slots:
		var b: Boon = by_slot.get(s.slot)
		var starved := not p.magick.can_pay(_omega(p, s.slot))
		match s.slot:
			Boon.Slot.CAST:
				s.refresh(b, 1.0 if p.cast_active else p.cast_cooldown / p.hero.cast_cooldown, 0, 0, starved)
			Boon.Slot.DASH:
				s.refresh(b, _dash_wait(p), p.dodge_charges, p.dodge_max)
			Boon.Slot.SPECIAL:
				# a boss's curse locks the special: the diamond shows the lock running out, then a ring when it lifts
				s.refresh(b, 0.0, 0, 0, starved and not p.curse.active())
				s.locked = p.curse.ratio()
				# the Pastor (E4): the lights gathered, over the special's diamond
				var flock := game.psalms.holding(PsalmDef.Effect.FLOCK) if game.psalms else null
				s.show_lights(game.psalms.lights if flock else 0, flock.count if flock else 0, PsalmIcon.tint(flock).lightened(0.2) if flock else UiKit.OLD_GOLD)
			_:
				s.refresh(b, 0.0, 0, 0, starved)
	_update_ult(p)


## The ultimate's diamond (T5): sealed with the Mastery level it needs, or its charge; a refused press shows why for
## a moment (and, the first time in a run, how it charges), a charge that fills shows "Pronta" and keeps pulsing.
func _update_ult(p: Player) -> void:
	if not _ult_heard:
		_ult_heard = true
		p.ult_refused.connect(_on_ult_refused)
	_ult_hint_t = maxf(0.0, _ult_hint_t - get_process_delta_time())
	var ult := game.ults.def if game.ults else null
	var first := game.hero.first_ult_level() if game.hero else 0
	_ult_slot.visible = ult != null or (first > 0 and game.bot == null)
	if not _ult_slot.visible:
		return
	var full := ult != null and game.ults.charge.ready()
	if full and not _ult_was_ready:
		_ult_hint_t = ULT_HINT_TIME
	_ult_was_ready = full
	var shown := ult if ult != null else game.hero.ult_for(&"", first)
	_ult_slot.glyph = BoonIcon.ULT_GLYPH + shown.kind
	_ult_slot.refresh(null, 1.0 - game.ults.ratio() if ult != null else 0.0)
	_ult_slot.sealed = ult == null
	_ult_slot.pulse = full
	_ult_slot.caption = ult_caption(ult != null, full, game.ults.ratio(), first, _ult_hint_t > 0.0)
	_ult_slot.caption_color = UiKit.PALE if _ult_hint_t > 0.0 else UiKit.DIM


## The text over the ultimate's diamond: none (sealed) -> "Maestria N" always; full -> "Pronta" while hinting;
## charging -> "Carga N%" while hinting (a refused press); else nothing.
static func ult_caption(has_ult: bool, full: bool, ratio: float, first_level: int, hinting: bool) -> String:
	if not has_ult:
		return T.t(&"hud_ult_locked", {"n": first_level})
	if not hinting:
		return ""
	if full:
		return T.t(&"hud_ult_ready")
	return T.t(&"hud_ult_charging", {"n": floori(ratio * 100.0)})


func _on_ult_refused() -> void:
	_ult_hint_t = ULT_HINT_TIME
	if _ult_told:
		return
	_ult_told = true
	var ult := game.ults.def if game.ults else null
	if ult == null:
		show_notice(T.t(&"hud_ult_locked_tip", {"n": game.hero.first_ult_level()}))
	else:
		show_notice(T.t(&"hud_ult_charge_tip"))


## Magia the held (Omega) version of a slot's action costs; 0 when it has none.
func _omega(p: Player, slot: Boon.Slot) -> float:
	if not _omega_cost.has(slot):
		var cost := 0.0
		match slot:
			Boon.Slot.ATTACK, Boon.Slot.SPECIAL:
				var node := ComboTree.find(p.tree.neutral, ComboNode.In.CHARGE_LIGHT if slot == Boon.Slot.ATTACK else ComboNode.In.CHARGE)
				cost = node.magick_cost if node else 0.0
			Boon.Slot.CAST:
				cost = p.hero.cast_omega_cost
		_omega_cost[slot] = cost
	return _omega_cost[slot]


## The part of the next dodge still recharging (0 with every charge back), by the run's clock.
func _dash_wait(p: Player) -> float:
	if p.dodge_charges != _dash_charges:
		# the recharge starts with the first charge spent, and again each time one comes back
		if p.dodge_charges > _dash_charges or _dash_charges >= p.dodge_max:
			_dash_from = game.time
		_dash_charges = p.dodge_charges
	if p.dodge_charges >= p.dodge_max:
		return 0.0
	return 1.0 - clampf((game.time - _dash_from) / maxf(p.hero.dodge_recharge, 0.01), 0.0, 1.0)


## The gifts with no action of their own: small medallions with their recharge, as many as fit before PASSIVE_EDGE
## and then "+N" for the rest (BUG-105; the pause's Bênçãos list them all).
func _update_passives() -> void:
	var owned: Array[Boon] = []
	owned.assign(game.boons.owned().filter(func(b: Boon) -> bool: return b.slot == Boon.Slot.NONE))
	var fit := passive_fit(get_viewport_rect().size.x * PASSIVE_EDGE - _passives.position.x)
	if owned.size() != _passive_count or fit != _passive_fit:
		_passive_count = owned.size()
		_passive_fit = fit
		for c in _passives.get_children():
			_passives.remove_child(c)
			c.queue_free()
		var shown := passives_shown(owned, fit)
		for b in shown:
			_passives.add_child(BoonIcon.new().setup(b, PASSIVE_ICON))
		if shown.size() < owned.size():
			var more := UiKit.shadow(UiKit.label(T.t(&"hud_more", {"n": owned.size() - shown.size()}), UiKit.PALE, FONT_SMALL + 1, UiKit.BOLD_FONT))
			more.name = &"More"
			more.custom_minimum_size = Vector2(PASSIVE_ICON, PASSIVE_ICON)
			more.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			_passives.add_child(more)
	for c in _passives.get_children():
		var icon := c as BoonIcon
		if icon == null:
			continue
		icon.level = game.boons.level(icon.boon.id)
		icon.max_level = icon.boon.max_level
		if icon.boon.skill and icon.boon.skill.kind != SkillDef.Kind.ORBIT:
			var t := game.skills.timer(icon.boon)
			icon.cooldown = clampf(t.x / maxf(t.y, 0.01), 0.0, 1.0)
		icon.queue_redraw()


## How many places of PASSIVE_ICON (with their gaps) a row this wide holds.
static func passive_fit(room: float) -> int:
	return maxi(1, floori((room + PASSIVE_GAP) / float(PASSIVE_ICON + PASSIVE_GAP)))


## The medallions the row shows out of owned when it holds fit places: all when they fit, else fit - 1 of them (the
## last place says "+N"), those with a recharge first, in the order they were taken.
static func passives_shown(owned: Array[Boon], fit: int) -> Array[Boon]:
	if owned.size() <= fit:
		return owned
	var timed: Array[Boon] = []
	var rest: Array[Boon] = []
	for b in owned:
		if b.skill and b.skill.kind != SkillDef.Kind.ORBIT:
			timed.append(b)
		else:
			rest.append(b)
	timed.append_array(rest)
	return timed.slice(0, maxi(0, fit - 1))


## Greets each Elo once, when it is taken, and each Blessing taken for the first time ever (E3-04: not yet in the
## save's Codex). What the run starts with is not greeted.
func _update_elos() -> void:
	for b in game.boons.new_elos(_elos_seen):
		_elos_seen[b.id] = true
		if _elos_ready:
			_elo_banner.show_elo(b, game.boons.sources(b))
			_notice_t = 0.0  # the Elo takes the notice's place
	var codex: Dictionary = Save.data.get("codex", {}).get("boons", {})
	for b in EloBanner.fresh_boons(game.boons.owned(), _elos_seen, codex):
		_elos_seen[b.id] = true
		if _elos_ready:
			_elo_banner.show_boon(b)
			_notice_t = 0.0
	_elos_ready = true


## A Psalm seen for the first time ever (offered, first) or taken: greeted once the choice screen is gone, so the
## greeting is read over the fight and never under the cards (E4-04).
func _on_psalm(p: PsalmDef, first: bool, taken: bool) -> void:
	var due: Dictionary = _psalms_due.get(p.id, {"psalm": p, "discovered": false, "taken": false})
	if taken:
		due.taken = true
	elif first:
		due.discovered = true
	else:
		return
	_psalms_due[p.id] = due


func _update_psalms() -> void:
	if _psalms_due.is_empty() or game.mode != Game.Mode.PLAY:
		return
	for due: Dictionary in _psalms_due.values():
		_elo_banner.show_psalm(due.psalm, due.discovered, due.taken)
	_psalms_due.clear()
	_notice_t = 0.0


## The greeting (the tests read it).
## E5: the Provação's curse turned (Rooms._fight_won): the seal fills with gold, the greeting from the top.
func show_trial_won(card: Trials.Card) -> void:
	_trial_seal.turn(card)
	_elo_banner.show_trial(card)


## The Provação's seal (the tests read it).
func trial_seal() -> TrialSeal:
	return _trial_seal


func banner() -> EloBanner:
	return _elo_banner


func _update_boss(b: Enemy) -> void:
	_boss_box.visible = b != null
	if b:
		_boss_name.text = T.t(b.def.name_key)
		_boss_bar.show_value(b.hp / b.max_hp, "", b.armor / b.max_armor if b.max_armor > 0.0 else 0.0)
		var boss := game.boss if game.boss and game.boss.e == b else null
		# a boss's bar: notches where his next phases begin, veiled in his colour while the ritual's shield stands
		_shield_t = move_toward(_shield_t, 1.0 if boss and boss.shielded() else 0.0, get_process_delta_time() * 4.0)
		_boss_bar.show_boss(boss.def.thresholds if boss else PackedFloat32Array(), _shield_t)
		# the ritual's count: a seal per dead that breaks the shield, while the shield shows
		_ritual_hint = boss != null and boss.shielded()
		_boss_bar.show_ritual(boss.ritual_left() if boss else 0, boss.ritual_total() if boss and _shield_t > 0.0 else 0)


## The count and the move's name stand right of the last diamond shown (the robot has no ultimate's).
func _follow_row() -> void:
	var last: Control = _ult_slot if _ult_slot.visible else _slots.back()
	var x := last.get_global_rect().end.x - get_global_rect().position.x + ROW_COUNT_GAP - ActionSlot.KEY_H * 0.5
	for c: Control in [_combo_row, _move]:
		if not is_equal_approx(c.offset_left, x):
			c.offset_left = x
			c.offset_right = x + LIFE.x


## How far over the bottom of the screen the edge chevrons' frame stands (it clears the captions over the diamonds).
func edge_bottom() -> float:
	return ROW_EDGE_BOTTOM if _row_mode else EDGE_INSET.w


## Chevrons on the edge of the screen: the light fountain (with its name) and the nearest elites, guardian or boss
## out of view. Nothing shows while they are all on screen.
func _update_pointers(chief: Enemy) -> void:
	var view := get_viewport_rect()
	var bottom := edge_bottom()
	var frame := Rect2(view.position + Vector2(EDGE_INSET.x, EDGE_INSET.y), view.size - Vector2(EDGE_INSET.x + EDGE_INSET.z, EDGE_INSET.y + bottom))
	var at: Variant = game.fountain_target()
	var edge: Variant = _edge(at as Vector2, view, frame) if at != null else null
	_arrow.visible = edge != null
	_point(_arrow_mark, edge, frame)
	if edge != null:
		# the name sits inside the chevron, towards the middle of the screen
		var dir := (frame.get_center() - (edge as Vector2)).normalized()
		var half := _arrow.size * 0.5
		_arrow.position = (edge as Vector2) + dir * (POINTER_SIZE * 0.5 + 6.0 + absf(dir.x) * half.x + absf(dir.y) * half.y) - half
	var foes: Array[Enemy] = []
	if chief:  # Morvath is not an elite by his data
		foes.append(chief)
	for e in game.horde.list:
		if e.alive and e.def.elite and e != chief:
			foes.append(e)
	if foes.size() > POINTERS:
		var from := game.player.pos
		foes.sort_custom(func(a: Enemy, b: Enemy) -> bool: return a.pos.distance_squared_to(from) < b.pos.distance_squared_to(from))
	var used := 0
	for e in foes:
		if used >= POINTERS:
			break
		edge = _edge(e.pos, view, frame)
		if edge != null:
			_point(_pointers[used], edge, frame)
			used += 1
	for i in range(used, POINTERS):
		_pointers[i].visible = false


## Where on the frame the chevron for a point of the floor goes; null while that point is on screen.
func _edge(floor_at: Vector2, view: Rect2, frame: Rect2) -> Variant:
	var world := Vector3(floor_at.x, 1.0, floor_at.y)
	var sp := game.camera.unproject_position(world)
	if game.camera.is_position_behind(world):
		sp = view.get_center() * 2.0 - sp
	return edge_point(sp, view.grow(-VIEW_INSET), frame)


func _point(mark: HudMark, edge: Variant, frame: Rect2) -> void:
	mark.visible = edge != null
	if edge != null:
		mark.position = (edge as Vector2) - mark.size * 0.5
		# about its middle (BUG-111: about its corner a chevron at the bottom hung 9 px lower, on the ult's caption)
		mark.pivot_offset = mark.size * 0.5
		mark.rotation = ((edge as Vector2) - frame.get_center()).angle()


## Where the ray from the frame's middle towards sp leaves the frame; null when sp is inside view.
static func edge_point(sp: Vector2, view: Rect2, frame: Rect2) -> Variant:
	if view.has_point(sp):
		return null
	var c := frame.get_center()
	var d := sp - c
	var k := minf(absf(frame.size.x * 0.5 / d.x) if d.x != 0.0 else INF, absf(frame.size.y * 0.5 / d.y) if d.y != 0.0 else INF)
	return c + d * minf(k, 1.0)


## The actions go translucent while the paladin or an enemy stands behind them (checked a few times a second).
func _update_veil(delta: float) -> void:
	_veil_t -= delta
	if _veil_t <= 0.0:
		_veil_t = VEIL_EVERY
		if _row_mode:
			# apart in the row layout: the diamonds on the left, the gifts in the right corner
			_veiled = _someone_behind(_action_row.get_global_rect(), true)
			_passives_veiled = _someone_behind(_passives_rect())
		else:
			_veiled = _someone_behind(_actions_rect())
			_passives_veiled = _veiled
	_passives.modulate.a = move_toward(_passives.modulate.a, VEIL_ALPHA if _passives_veiled else 1.0, delta * VEIL_SPEED)
	var a := move_toward(_slot_alpha, VEIL_ALPHA if _veiled else 1.0, delta * VEIL_SPEED)
	_slot_alpha = a
	# the diamonds fade only their bodies: what they say (glyph, recharge, key) stays whole
	for s in _slots:
		s.veil = (1.0 - a) / (1.0 - VEIL_ALPHA)
	_ult_slot.veil = (1.0 - a) / (1.0 - VEIL_ALPHA)


## The diamonds and the gifts beside them, on screen.
func _actions_rect() -> Rect2:
	return _action_row.get_global_rect().merge(_passives_rect()) if _passives.get_child_count() > 0 else _action_row.get_global_rect()


## The gifts' medallions on screen (an empty rect without any).
func _passives_rect() -> Rect2:
	var r := Rect2()
	for c in _passives.get_children():
		r = (c as Control).get_global_rect() if r.size == Vector2.ZERO else r.merge((c as Control).get_global_rect())
	return r


func _someone_behind(rect: Rect2, hero_only := false) -> bool:
	var p := game.player
	var feet := game.camera.unproject_position(Vector3(p.pos.x, 0.0, p.pos.y))
	# how tall a body stands on screen (the same for everyone, near enough, with this long lens)
	var tall := feet.y - game.camera.unproject_position(Vector3(p.pos.x, BODY_HEIGHT, p.pos.y)).y
	if body_rect(feet, tall).intersects(rect):
		return true
	if hero_only:
		return false
	for e in game.horde.list:
		if e.alive and body_rect(game.camera.unproject_position(Vector3(e.pos.x, 0.0, e.pos.y)), tall).intersects(rect):
			return true
	return false


## The box a standing body covers on screen, from where its feet are.
static func body_rect(feet: Vector2, tall: float) -> Rect2:
	return Rect2(feet.x - BODY_HALF, feet.y - tall, BODY_HALF * 2.0, tall)


func on_combo(count: int) -> void:
	_combo_count = count
	for c: CanvasItem in [_combo, _combo_word]:
		c.visible = count >= 3
	if count == 0:
		# the count ran out: the move's name goes with it (BUG-112), a short fade and never alone in the corner
		_move_t = minf(_move_t, MOVE_FADE)
	_combo.text = str(count)
	_combo_pop = 1.0


## The move's name, in ivory whatever the move's colour (the colour is on the blade; here it has to read on any floor).
func show_move(node: ComboNode, _color: Color) -> void:
	_move.text = T.t(node.title)
	_move_t = MOVE_TIME


## The map key (M, Back on the gamepad) opens the map during play; the map itself takes the key that closes it.
## Read from the event (as the pause reads its key): Game flushes the presses it stepped before the HUD's _process.
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"map") and open_map() != null:
		get_viewport().set_input_as_handled()


## Opens the descent's map over the run (DV-1, MAP-03): the run stops under it (Game.open_screen) and goes on when it
## closes, with the press that closed it swallowed (Game.close_screen, Controls.clear_presses). Only during play in a
## descent by rooms. Returns the screen (null when it could not open).
func open_map() -> MapScreen:
	if game == null or game.rooms == null or game.mode != Game.Mode.PLAY:
		return null
	var screen := MapScreen.new()
	game.open_screen(screen, false)
	screen.open()
	screen.closed.connect(game.close_screen)
	return screen


func show_notice(text: String, time: float = 2.5) -> void:
	if game and game.boss and text == T.t("boss_phase_%d" % game.boss.phase):
		show_phase(text)
		return
	_notice.text = text
	_notice.add_theme_font_override(&"font", UiKit.number_font() if UiKit.has_digit(text) else UiKit.TITLE_FONT)
	_notice.size = Vector2.ZERO
	_notice.position.x = (get_viewport_rect().size.x - _notice.get_combined_minimum_size().x) * 0.5
	_notice_t = time


## A boss's phase begins: its name (up to the first full stop) and its hint (the rest) under his bar, for a moment.
func show_phase(text: String) -> void:
	var parts := phase_parts(text)
	_phase_name.text = parts[0]
	_phase_name.visible = true
	_phase_tip.text = parts[1]
	_phase_tip.visible = parts[1] != ""
	_phase_t = PHASE_TIME
	_phase_len = PHASE_TIME
	_place_shown = false
	_notice_t = minf(_notice_t, 0.0)


## An arena's name on walking in (cycle C12, D-33): where and as a boss phase's name shows, PLACE_TIME seconds.
func show_place(text: String) -> void:
	_phase_name.text = text
	_phase_name.visible = true
	_phase_tip.visible = false
	_phase_t = PLACE_TIME
	_phase_len = PLACE_TIME
	_place_shown = true


## The arena's name showing now ("" when none).
func place_shown() -> String:
	return _phase_name.text if _place_shown and _phase_t > 0.0 else ""


## A phase's text split into its name and its hint ("O Ritual dos Mortos. Derrube..." -> the two; a name alone keeps
## an empty hint).
static func phase_parts(text: String) -> PackedStringArray:
	var cut := text.find(". ")
	if cut < 0:
		return PackedStringArray([text.trim_suffix("."), ""])
	return PackedStringArray([text.substr(0, cut), text.substr(cut + 2).strip_edges()])
