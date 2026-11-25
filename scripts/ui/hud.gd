class_name Hud
extends Control
## What stays on screen during the run (Lote 2 of the SWORN reference, 2026-11-21: layout approved by the Daniel).
## Bottom left: the paladin's medallion and, beside it, the bars stacked: Magia above, life under it (numbers on both),
## the ultimate's charge thin at the foot. Bottom centre: the actions as diamonds (the gift on each, the key, the
## recharge, the dodges, the rajada's Magia cost and "Sem Magia"), the Brado's buff running over its diamond. Right edge:
## the build column (BuildColumn, one Blessing per button). Bottom right: the coins and what was just picked up
## (CoinCorner), the gifts that act alone above them. When life runs low the borders darken (LifeVignette).
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
## SW-O2: the objective line stands under "Sala N de M"; how often the context is read, and the seconds of standing still
## in the Antessala before the line blinks once.
const OBJ_TOP := 42.0
const OBJ_EVERY := 0.2
const OBJ_IDLE := 25.0
## Metres: the hero this near the slabs has crossed them once he is this far past their middle.
const PLATES_PAST := 1.5
const MILESTONES := "res://scripts/core/milestones.gd"
const CREST := 76.0
const LIFE := Vector2(244, 19)
const MAGICK := Vector2(196, 15)
## Magia's bar as wide as life's (the stack reads as one block, Magia on top).
const MAGICK_WIDE := Vector2(244, 15)
## U-3: the Warrior's Magia is a thin, quiet bar under the life (the sword does the work); it lights for HOT_TIME seconds
## when it rises, is spent or its buttons are held, and only then says its number.
const MAGICK_THIN := Vector2(196, 8)
const MAGICK_IDLE_ALPHA := 0.5
const HOT_TIME := 1.6
## Lining figures (UiKit.number_font): at these sizes the numbers stand 9 px tall or more at 720 lines.
const LIFE_FONT := 16
const MAGICK_FONT := 15
const BOSS := Vector2(480, 12)
const PASSIVE_ICON := 30
const PASSIVE_GAP := 4
## The row of gifts that act alone ends at this share of the screen's width; past it the last place says "+N" (BUG-105).
## Those with a recharge go first: their timer is what is worth a glance in a fight.
const PASSIVE_EDGE := 0.96
## The row (P1-4 of the Hades II UI benchmark, 2026-11-21 centred as in Ravenswatch): the six diamonds (ROW_DIAMOND,
## about 54 px at 1080) centred at the foot of the screen on a band of ink (HudVeil) so the crowd does not run between
## them, their bodies veiled only by the hero standing behind (never by the crowd). The hit count stands on the row's
## line, right of the last diamond, the move's name under it; the curse's badge and the Provação's seal (conditions, not
## always there) stand over the medallion and the bars.
const ROW_DIAMOND := 36.0
const ROW_GAP := 6
## The keys hang under the diamonds' point (ActionSlot.key_drop): the little mouse is 22 px tall.
const ROW_KEY_DROP := 7.0
const ROW_CAPTION := 20.0
## The bars beside the medallion (Magia over life, the ultimate's charge thin under them): the gap from the medallion,
## the thin bar's size and the gap between two frames (they share one line of ink).
const BARS_GAP := 12.0
const CHARGE := Vector2(196, 6)
const BAR_GAP := 2.0 * UiKit.FRAME + 1.0
## The bars beside the medallion, life over Magia over the ultimate's charge. thin: the Warrior's quiet Magia (U-3); the
## Maga, whose staff lives on it, keeps it wide with its number and the drop.
func _layout_bars(thin: bool) -> void:
	_magick_thin = thin
	var mag := MAGICK_THIN if thin else MAGICK_WIDE
	var x := MARGIN + CREST + BARS_GAP
	var stack := CHARGE.y + LIFE.y + mag.y + 2.0 * BAR_GAP
	var low := MARGIN + (CREST - stack) * 0.5
	_place(_charge, Control.PRESET_BOTTOM_LEFT, Vector2(x, -low), CHARGE)
	_place(_life, Control.PRESET_BOTTOM_LEFT, Vector2(x, -(low + CHARGE.y + mag.y + 2.0 * BAR_GAP)), LIFE)
	_magick.custom_minimum_size = mag
	_magick.icon = HudBar.Mark.NONE if thin else HudBar.Mark.DROP
	_place(_magick, Control.PRESET_BOTTOM_LEFT, Vector2(x, -(low + CHARGE.y + BAR_GAP)), mag)
	_magick.queue_redraw()


## The build column on the right edge: where its middle stands (share of the height) and the room it keeps (the edge
## chevrons stay out of it). The coins' corner and the gifts over it.
const COLUMN_MID := 0.46
const EDGE_RIGHT := BuildColumn.WIDTH + 22.0
const PASSIVE_LIFT := 40.0
## The Brado's buff beside the life bar: the gap right of it.
const BUFF_GAP := 12.0
## The vignette stands from this share of life down (the medallion's ring warns from the same).
const DANGER_FROM := 0.3## The hit count right of the last diamond, and the bottom of the edge chevrons' frame over the whole block.
const ROW_COUNT_GAP := 12.0
const ROW_EDGE_BOTTOM := 128.0
const FONT_SMALL := 15
const FONT_TEXT := 19
const FONT_CLOCK := 22
## The clock's box, where it stands (top middle) and, while a boss's bar is up, in the top right corner; the
## boss's bar under the clock, or at the top alone while the clock is in the corner.
const CLOCK_BOX := Vector2(120, 30)
const CLOCK_Y := 7.0
const CLOCK_BOSS_Y := 7.0
const BOSS_TOP := 42.0
const BOSS_TOP_ALONE := 12.0
## The hit count (VX-12): its digits stay under 48 px tall at 1080 lines even at the top of the pop, and the move's
## name under it is dimmed, so neither competes with the fight.
const FONT_COMBO := 24
const COMBO_POP := 0.15
## The word "Golpes" and the move's name beside the count and the count's height.
const COMBO_WORD := 14
const COMBO_H := 28.0
## PT-3 (Daniel, 2026-11-23): the hit count is not shown; the move's name stays.
const SHOW_HITS := false
## Room between the count's line and the move's name under it (row layout).
const MOVE_GAP := 4.0
const MOVE_ALPHA := 0.9
const MOVE_W := 220.0
## The diamond each kind of move comes from (the move's name stands over it).
const MOVE_ACTION := {ComboNode.In.LIGHT: &"light_attack", ComboNode.In.CHARGE_LIGHT: &"light_attack", ComboNode.In.HEAVY: &"heavy_attack",
	ComboNode.In.CHARGE: &"heavy_attack", ComboNode.In.SHOUT: &"shout", ComboNode.In.RUSH: &"rush"}
## The move's name: how long it shows, and how fast it goes (a short cut, no long ghost).
const MOVE_TIME := 1.2
const MOVE_FADE := 0.25
## The phase's name under the boss's bar: seconds it shows, its fade, font sizes.
const PHASE_TIME := 3.0
## An arena's name on walking in (cycle C12, decision D-33): in the place and look of a phase's name, this long.
const PLACE_TIME := 2.5
## Morvath's entrance (AP-2, ART-05.5): the chamber's name, his name and his epithet low in the middle of the screen (a
## title over the balustrade, under the hero and Morvath on the seal; nothing of the HUD stands there) while he rises
## (the 2.4 s of his entrance, Boss State.ENTER), on a veil; the notice and the greetings wait meanwhile. px at 720.
const ENTRANCE_TIME := 2.3
const ENTRANCE_IN := 0.3
const ENTRANCE_OUT := 0.45
const ENTRANCE_BOTTOM := 120.0
const ENTRANCE_NAME_SIZE := 34
const ENTRANCE_LINE_SIZE := 17
const PHASE_FADE := 0.4
const PHASE_NAME_SIZE := 18
## The arena's name card (N1 2.4): ivory over two gold filets, no box; its size, the filets' size, the gap under a boss's bar
## and where it stands with no bar (under the clock).
const PLACE_NAME_SIZE := 24
const PLACE_RULE := Vector2(300, 9)
const PHASE_GAP := 8.0
const PLACE_TOP := 46.0
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
## U-5: shooters about to fire from out of view, at most this many arrows, from this many seconds before the shot.
const SHOOTER_ARROWS := 2
const SHOOTER_WARN := 1.0
const SHOOTER_COLOR := Color(1.0, 0.78, 0.4)
const POINTER_SIZE := 18.0
const VIEW_INSET := 16.0
## (The bottom clears the caption over the ultimate's diamond, "Maestria 2", BUG-111.)
const EDGE_INSET := Vector4(30.0, 96.0, EDGE_RIGHT, 128.0)
## The actions in the order of the diamonds (left button, right button, Q the Brado, E the Investida, then the ultimate's
## diamond on Shift, then the dodge on Space: docs/design/heroes/guerreiro.md 3), with the gift slot that changes each.
## The Brado takes the circle's Blessing slot (CAST); the Investida has none (Boon.Slot.NONE). A diamond of a move the
## hero's tree lacks is hidden.
const ACTIONS: Array[StringName] = [&"light_attack", &"heavy_attack", &"shout", &"rush", &"dodge"]
const SLOTS: Array[Boon.Slot] = [Boon.Slot.ATTACK, Boon.Slot.SPECIAL, Boon.Slot.CAST, Boon.Slot.NONE, Boon.Slot.DASH]
## The Maga's marks over the diamonds that carry no Blessing (M1b); Q and E always wear theirs.
const MAGA_GLYPHS := {&"light_attack": BoonIcon.BOLT_GLYPH, &"heavy_attack": BoonIcon.BLAST_GLYPH, &"shout": BoonIcon.ACTION_GLYPH + Boon.Slot.CAST,
	&"rush": BoonIcon.DOME_GLYPH}
## Where the ultimate's diamond stands among them: before the dodge.
const ULT_AT := 4
## Between the room's number and what lies beyond the doors.
const AHEAD_GAP := 14
## Seconds the ultimate's caption shows after a refused press or when it fills (T5).
const ULT_HINT_TIME := 1.8
## UI 10: with the charge full and life below this share the ready ring pulses harder.
const ULT_HURT := 0.5

var game: Game
var door_tip: DoorTip
var tip_toast: TipToast
## SW-O1: the arrival's one line at the foot (the ArrivalScene calls arrival_caption.show_line).
var arrival_caption: ArrivalCaption
## SW-O2: the objective at the top left, under the room's count; fed every OBJ_EVERY seconds by _update_objective.
var objective: ObjectiveLine
var _obj_t := 0.0
var _obj_still := 0.0
var _obj_last_pos := Vector2.ZERO
## The side of the Antessala's slabs the hero came from (0 until he is near them): crossing them flips it.
var _plate_side := 0
var _plates_crossed := false
## The room whose "two doors" line was shown (the next room ends the "first choice"), and whether it was told.
var _door_told_in: RunMap.Room
var _door_told := false
var _crest: HeroCrest
## The hero whose face the crest shows (the Maga has her own portrait).
var _crest_hero: StringName = &""
var _life: HudBar
var _magick: HudBar
var _magick_thin := true
var _magick_hot := 0.0
var _magick_last := -1.0
## The ultimate's charge, thin under the life bar.
var _charge: HudBar
var _charge_shown := false
var _room: Label
## What lies beyond the open doors, beside the room's number (Rooms.ahead_text: Discernimento II, the Prévia dos anjos).
var ahead: Label
var _clock: Label
var _clock_veil: HudVeil
var _clock_at_boss := false
## The materials greeted so far, by "material/source" (Rejogabilidade, Fatia 1: _greet_materials).
var _found_seen := {}
## The Ofícios greeted so far (_greet_oficios): "head", "noted", "stones".
var _oficios_seen := {}
## H3: the coins' corner, H1: the build column, H6: the low-life vignette, and the Brado's buff over its diamond.
var _coins: CoinCorner
var _column: BuildColumn
var _column_hidden := false
var _vignette: LifeVignette
var _buff: BuffMark
var _build_key := ""
var _xp_back: ColorRect
var _xp_fill: ColorRect
var _boss_box: VBoxContainer
var _boss_name: Label
var _boss_bar: HudBar
var _phase_rule_top: GoldRule
var _phase_rule_bottom: GoldRule
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
var _move: Label
var _move_action: StringName = &"light_attack"
var _notice: Label
var _slots: Array[ActionSlot] = []
## The ultimate's diamond, between the Brado's and the dodge's: its gold level rises with the charge; sealed with "Maestria N" over it
## before the Mastery unlocks one (hidden only for the robot, who has none); a press that cannot let it go says why
## (T5, ult_caption).
var _ult_slot: ActionSlot
## Seconds the ultimate's caption still shows a refused press's reason or "Pronta"; whether the charge was full.
var _ult_hint_t := 0.0
var _ult_was_ready := false
## The how-to-charge notice shows once a run, on the first refused press.
var _ult_told := false
var _ult_heard := false
var _shout_tip_t := 0.0
var _shout_told := 0
var _shout_room: RunMap.Room
var _passives: HBoxContainer
var _arrow: Label
var _arrow_mark: HudMark
var _pointers: Array[HudMark] = []
var _shooter_marks: Array[HudMark] = []
## Morvath's entrance card (show_entrance) and its seconds left.
var _entrance: VBoxContainer
var _entrance_veil: HudVeil
var _entrance_t := 0.0
var _boss_met := false
var _action_row: HBoxContainer
var _veil_t := 0.0
var _veiled := false
var _passives_veiled := false
var _column_veiled := false
var _column_alpha := 0.0
## The diamonds' body opacity (they fade only their bodies, ActionSlot.veil).
var _slot_alpha := 1.0
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
	# under everything: the low-life vignette
	_vignette = LifeVignette.new()
	add_child(_vignette)
	_build_top()
	_build_life()
	_build_actions()
	_build_combo()
	_build_column()
	_notice = _label("", UiKit.PALE, FONT_TEXT + 3, UiKit.TITLE_FONT, Control.PRESET_CENTER_TOP, Vector2(0, 110))
	_notice.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_notice.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_arrow = _label(T.t(&"hud_fountain"), UiKit.PALE, FONT_SMALL + 1, UiKit.BOLD_FONT, Control.PRESET_TOP_LEFT, Vector2.ZERO)
	_arrow.visible = false
	_arrow_mark = _pointer()
	for i in POINTERS:
		_pointers.append(_pointer())
	for i in SHOOTER_ARROWS:
		var m := _pointer()
		m.color = SHOOTER_COLOR
		_shooter_marks.append(m)
	# the moment an Elo forms: in the notices' place under the clock, well above the paladin
	# the open doors' seals and, near one, what it holds (DoorTip)
	door_tip = DoorTip.new()
	door_tip.game = game
	add_child(door_tip)
	# GP-9: the first descents' four tips, once per save (TipToast)
	tip_toast = TipToast.new()
	tip_toast.game = game
	add_child(tip_toast)
	arrival_caption = ArrivalCaption.new()
	add_child(arrival_caption)
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
	top_left.add_theme_constant_override(&"separation", AHEAD_GAP)
	top_left.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(top_left)
	_place(top_left, Control.PRESET_TOP_LEFT, Vector2(MARGIN, 8), Vector2(300, 32))
	# every number of the HUD in lining figures (UiKit.number_font): Cinzel's 1 is a bare stroke, "Sala 1 de 11" read
	# "SALA I DE II" (UI review d2ff05d, P0-1)
	_room = UiKit.shadow(UiKit.label("", UiKit.PALE, FONT_TEXT, UiKit.number_font()))
	_room.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	top_left.add_child(_room)
	ahead = UiKit.shadow(UiKit.label("", UiKit.PALE, FONT_SMALL, UiKit.number_font()))
	ahead.name = "ahead"
	ahead.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	top_left.add_child(ahead)
	objective = ObjectiveLine.new()
	add_child(objective)
	_place(objective, Control.PRESET_TOP_LEFT, Vector2(MARGIN, OBJ_TOP), Vector2(380, ObjectiveLine.HEIGHT))
	_clock = _label("0:00", UiKit.PALE, FONT_CLOCK, UiKit.number_font(), Control.PRESET_CENTER_TOP, Vector2.ZERO)
	_clock.name = "clock"
	_clock.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_clock_veil = _veil([_clock])
	_coins = CoinCorner.new().setup()
	add_child(_coins)
	_place(_coins, Control.PRESET_BOTTOM_RIGHT, Vector2(-MARGIN, -MARGIN), Vector2(220, 60))
	_coins.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	_coins.grow_vertical = Control.GROW_DIRECTION_BEGIN
	_boss_box = VBoxContainer.new()
	_boss_box.add_theme_constant_override(&"separation", 2)
	_boss_box.visible = false
	_boss_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_boss_box)
	_place(_boss_box, Control.PRESET_CENTER_TOP, Vector2(0, BOSS_TOP), Vector2(BOSS.x, 40))
	_boss_name = UiKit.shadow(UiKit.title("", FONT_TEXT, UiKit.PALE))
	_boss_name.add_theme_constant_override(&"outline_size", 5)
	# UX2-02: an ink plate behind the title, so a bright orb or a number flying behind it never washes the letters
	var plate := StyleBoxFlat.new()
	plate.bg_color = Color(UiKit.INK, 0.6)
	plate.set_corner_radius_all(4)
	plate.content_margin_left = 14.0
	plate.content_margin_right = 14.0
	_boss_name.add_theme_stylebox_override(&"normal", plate)
	_boss_name.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
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
	_phase_rule_top = _place_rule()
	_phase_box.add_child(_phase_rule_top)
	_phase_box.add_child(_phase_name)
	_phase_tip = UiKit.shadow(UiKit.label("", UiKit.PALE, PHASE_TIP_SIZE))
	_phase_tip.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_phase_box.add_child(_phase_tip)
	_phase_rule_bottom = _place_rule()
	_phase_box.add_child(_phase_rule_bottom)
	_style_phase(false)
	_place_clock(false)
	_build_entrance()


func _place_rule() -> GoldRule:
	var r := GoldRule.new()
	r.custom_minimum_size = PLACE_RULE
	r.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	return r


## The name under the bar is a boss's phase (gold, small) or an arena's card (ivory, larger, between two filets).
func _style_phase(card: bool) -> void:
	_phase_name.add_theme_color_override(&"font_color", UiKit.PALE if card else UiKit.GOLD)
	_phase_name.add_theme_font_size_override(&"font_size", PLACE_NAME_SIZE if card else PHASE_NAME_SIZE)
	_phase_rule_top.visible = card
	_phase_rule_bottom.visible = card


## Under the boss's bar by its real height (name and bar), so the two never touch; with no bar, under the clock.
func _place_phase_box() -> void:
	var y := PLACE_TOP
	if _boss_box.visible:
		y = _boss_box.position.y + _boss_box.get_combined_minimum_size().y + PHASE_GAP
	_phase_box.position.y = y


## Morvath's entrance: the chamber's name small in old gold, his name in Cinzel, his epithet under it, on a veil.
func _build_entrance() -> void:
	_entrance = VBoxContainer.new()
	_entrance.name = "entrance"
	_entrance.add_theme_constant_override(&"separation", -2)
	_entrance.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_entrance.visible = false
	add_child(_entrance)
	_place(_entrance, Control.PRESET_CENTER_BOTTOM, Vector2(0, -ENTRANCE_BOTTOM), Vector2(BOSS.x + 160, 96))
	for spec: Array in [["place", ENTRANCE_LINE_SIZE, UiKit.OLD_GOLD.lightened(0.35), UiKit.BOLD_FONT],
			["name", ENTRANCE_NAME_SIZE, UiKit.GOLD, UiKit.TITLE_FONT], ["epithet", ENTRANCE_LINE_SIZE + 1, UiKit.PALE, null]]:
		var l := UiKit.shadow(UiKit.label("", spec[2], spec[1], spec[3]))
		l.name = spec[0]
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		l.add_theme_constant_override(&"outline_size", 5 if spec[0] == "name" else 3)
		_entrance.add_child(l)
	_entrance_veil = HudVeil.new()
	for l in _entrance.get_children():
		_entrance_veil.covers.append(l as Control)
	add_child(_entrance_veil)
	move_child(_entrance_veil, _entrance.get_index())


## AP-2 (ART-05.5): Morvath's entrance under his bar, for the seconds he rises from the seal: the room's name, his own
## ("Morvath, o rei que traiu a luz" split at its comma: the name, then the epithet) on a veil.
func show_entrance(place: String) -> void:
	var full := T.t(&"enemy_morvath")
	var cut := full.find(", ")
	var epithet := full.substr(cut + 2) if cut >= 0 else ""
	(_entrance.get_node(^"place") as Label).text = place
	(_entrance.get_node(^"name") as Label).text = full.substr(0, cut) if cut >= 0 else full
	(_entrance.get_node(^"epithet") as Label).text = epithet.left(1).to_upper() + epithet.substr(1)
	(_entrance.get_node(^"epithet") as Label).visible = epithet != ""
	_entrance_t = ENTRANCE_TIME
	_entrance.visible = true
	_entrance.modulate.a = 0.0


## The entrance card showing now (tests).
func entrance_shown() -> bool:
	return _entrance.visible and _entrance_t > 0.0


func _update_entrance(delta: float) -> void:
	if not _entrance.visible:
		_entrance_veil.visible = false
		return
	_entrance_t -= delta
	_notice_t = minf(_notice_t, 0.0)  # the entrance is the only words over the chamber meanwhile
	_entrance.modulate.a = minf(clampf((ENTRANCE_TIME - _entrance_t) / ENTRANCE_IN, 0.0, 1.0),
			clampf(_entrance_t / ENTRANCE_OUT, 0.0, 1.0))
	_entrance.visible = _entrance_t > 0.0
	_entrance_veil.follow()
	_entrance_veil.modulate.a *= _entrance.modulate.a


## Bottom left: the medallion and, beside it, Magia over life over the ultimate's thin charge, centred on its height.
func _build_life() -> void:
	_charge = HudBar.new().setup(UiKit.OLD_GOLD.lightened(0.15), CHARGE, 1, false, UiKit.OLD_GOLD.darkened(0.45))
	_charge.name = "charge"
	add_child(_charge)
	_life = HudBar.new().setup(LIFE_COLOR, LIFE, LIFE_FONT, false, LIFE_BOTTOM)
	add_child(_life)
	_life.icon = HudBar.Mark.HEART
	_magick = HudBar.new().setup(MAGICK_COLOR, MAGICK_THIN, MAGICK_FONT, false, MAGICK_BOTTOM)
	add_child(_magick)
	_layout_bars(true)
	var x := MARGIN + CREST + BARS_GAP
	var stack := CHARGE.y + LIFE.y + MAGICK_WIDE.y + 2.0 * BAR_GAP
	var low := MARGIN + (CREST - stack) * 0.5
	_crest = HeroCrest.new().setup(CREST)
	add_child(_crest)
	_place(_crest, Control.PRESET_BOTTOM_LEFT, Vector2(MARGIN, -MARGIN), Vector2(CREST, CREST))
	# a condition (the boss's curse): over the bars, from their left end
	_curse_badge = ConditionBadge.new().setup(CURSE_COLOR, T.t(&"hud_cursed"), T.t(&"hud_cursed_effects"))
	add_child(_curse_badge)
	_place(_curse_badge, Control.PRESET_BOTTOM_LEFT, Vector2(x, -(low + stack + 2.0 * UiKit.FRAME + 6.0)), _curse_badge.size)
	# the Provação's seal: above the medallion, clear of Morvath's curse badge (which sits over the bars)
	_trial_seal = TrialSeal.new().setup(TRIAL_SEAL, true)
	add_child(_trial_seal)
	_place(_trial_seal, Control.PRESET_BOTTOM_LEFT, Vector2(MARGIN + (CREST - TRIAL_SEAL) * 0.5, -MARGIN - CREST - TRIAL_SEAL_GAP), Vector2(TRIAL_SEAL, TRIAL_SEAL))


## The build column on the right edge (BuildColumn), its middle at COLUMN_MID of the height.
func _build_column() -> void:
	_column = BuildColumn.new().setup()
	add_child(_column)
	_column.set_anchors_preset(Control.PRESET_CENTER_RIGHT)
	_column.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	_column.grow_vertical = Control.GROW_DIRECTION_BOTH
	# a fixed middle (the foot rows grow it both ways: the top moves a little, the Blessings never)
	_column.anchor_top = COLUMN_MID
	_column.anchor_bottom = COLUMN_MID
	_column.offset_right = 0.0
	_column.offset_left = -BuildColumn.WIDTH
	_column.offset_top = -BuildColumn.height_for(0) * 0.5
	_column.offset_bottom = BuildColumn.height_for(0) * 0.5


## Bottom centre: the action diamonds, centred; the gifts that act alone sit in the bottom right corner over the coins.
func _build_actions() -> void:
	var row := HBoxContainer.new()
	_action_row = row
	row.add_theme_constant_override(&"separation", ROW_GAP)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(row)
	for i in ACTIONS.size():
		if i == ULT_AT:
			_ult_slot = ActionSlot.new().setup(&"ultimate", Boon.Slot.NONE, ROW_DIAMOND, ROW_KEY_DROP)
			row.add_child(_ult_slot)
		var s := ActionSlot.new().setup(ACTIONS[i], SLOTS[i], ROW_DIAMOND, ROW_KEY_DROP)
		if ACTIONS[i] == &"shout":
			s.glyph = BoonIcon.SHOUT_GLYPH
		elif ACTIONS[i] == &"rush":
			s.glyph = BoonIcon.RUSH_GLYPH
		row.add_child(s)
		_slots.append(s)
	# centred on the screen's middle whatever the number of diamonds (the row's own box is as wide as the six)
	var height := ROW_DIAMOND + ActionSlot.KEY_H * 0.5 + ROW_KEY_DROP
	var width := row.get_combined_minimum_size().x
	_place(row, Control.PRESET_CENTER_BOTTOM, Vector2(0.0, -MARGIN), Vector2(width, height))
	row.grow_horizontal = Control.GROW_DIRECTION_BOTH
	# U-4: no dark box behind the diamonds (only the move's name keeps its small veil, see _build_combo)
	_row_band = HudVeil.new()
	add_child(_row_band)
	move_child(_row_band, row.get_index())
	_buff = BuffMark.new().setup(BoonIcon.SHOUT_GLYPH)
	add_child(_buff)
	_passives = HBoxContainer.new()
	_passives.name = &"Passives"
	_passives.add_theme_constant_override(&"separation", PASSIVE_GAP)
	_passives.alignment = BoxContainer.ALIGNMENT_END
	_passives.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_passives)
	# its right end at PASSIVE_EDGE of the width (BUG-105), over the coins' corner
	_passives.anchor_left = PASSIVE_EDGE
	_passives.anchor_right = PASSIVE_EDGE
	_passives.anchor_top = 1.0
	_passives.anchor_bottom = 1.0
	_passives.offset_left = -300.0
	_passives.offset_right = 0.0
	_passives.offset_bottom = -MARGIN - PASSIVE_LIFT
	_passives.offset_top = -MARGIN - PASSIVE_LIFT - PASSIVE_ICON - 6.0


## The hit count and the move's name, right of the row's last diamond (benchmark_hades2_ui.md P0-3, UI-HB5): small,
## in Alegreya Sans (Cinzel only from 24 px): "12 Golpes", the move's name under it.
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
	# on the row's line, right of the last diamond; the move's name under the count, smaller (C of the review)
	_combo_row.remove_child(_move)
	add_child(_move)
	var x := 0.0  # (follow_row puts them right of the last diamond each frame)
	for c: Control in [_combo_row, _move]:
		c.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
		c.offset_left = x
		c.offset_right = x + LIFE.x
	_combo_row.offset_top = _action_row.offset_top - 2.0
	_combo_row.offset_bottom = _combo_row.offset_top + COMBO_H
	# art review 2026-11-21 (10): the name on its own line under the count, never touching it, and both on the
	# row's band of ink with the diamonds (no grey text loose over the floor)
	_move.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_row_band.covers.append_array([_combo, _combo_word, _move] as Array[Control])
	for c: CanvasItem in [_combo, _combo_word]:
		c.visible = false


## A material found greets in the coins' corner (CoinCorner.pickup, H3), but not an elite's drop: it is a word where the elite
## fell, as the gold is (Rooms.found), and a greeting for each would crowd the top of the fight.
func _greet_materials() -> void:
	_greet_oficios()
	var found: Dictionary = game.materials.found
	for m: StringName in found:
		for source: StringName in found[m]:
			var key := "%s/%s" % [m, source]
			var n := int(found[m][source])
			var was := int(_found_seen.get(key, 0))
			if n > was:
				_found_seen[key] = n
				if source != &"elite":
					_coins.pickup(m, n - was)


## Ofícios (10_ux.md 10.2), read from the run's part every frame: the pick's head found ("Achado"), the vein noted
## and each Pedra Funda extracted (the material's greeting with the stone's mark).
func _greet_oficios() -> void:
	var of: Variant = game.get(&"oficios")
	if not of is OficiosRun:
		return
	var run := of as OficiosRun
	if run.head_found and not _oficios_seen.get("head", false):
		_oficios_seen["head"] = true
		_elo_banner.show_find(StringName(run.head_id) if run.head_id != "" else &"pick_head")
	if run.noted and not _oficios_seen.get("noted", false):
		_oficios_seen["noted"] = true
		_elo_banner.show_noted()
	var was := int(_oficios_seen.get("stones", 0))
	if run.stones > was:
		_oficios_seen["stones"] = run.stones
		_coins.pickup(DoorGlyph.STONE_ID, run.stones - was)


## The notices the Ofícios' greetings say instead (Rooms still asks for them: never twice on screen).
static func oficio_notice(text: String) -> bool:
	return text == T.t(&"oficio_noted") or text == T.t(&"oficio_found", {"name": T.t(&"oficio_pick_head")})


## A veil of ink under labels that stand over the scene (HudVeil), drawn under them.
func _veil(over: Array[Control]) -> HudVeil:
	var v := HudVeil.new()
	v.covers = over
	add_child(v)
	move_child(v, over[0].get_index())
	return v


## The clock: at the top in the middle, or, while a boss's bar is up, in the top right corner, so the
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
	_place_phase_box()


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
	if game.hero != null and game.hero.id != _crest_hero:
		_crest_hero = game.hero.id
		_crest.set_hero(_crest_hero)
	# a screen over the run (cards, pause, an event): the gifts' row and the greetings wait under it (BUG-107)
	var over := game.mode != Game.Mode.PLAY
	_passives.visible = not over
	# the pause's panel stands on the left: the medallion and the bars go under it (UI review d2ff05d, P2-7)
	var paused := game.mode == Game.Mode.PAUSE
	for c: CanvasItem in [_crest, _life, _magick]:
		c.visible = not paused
	for c: CanvasItem in [_combo, _combo_word]:
		c.visible = SHOW_HITS and _combo_count >= 3 and not over
	_move.visible = not over
	# the curse's badge stands on the life bar's line: the count climbs over it meanwhile
	_elo_banner.held = over or entrance_shown() or door_tip.hero_by_doors()
	_clock.text = SaveData.format_time(game.time)
	_coins.tick(delta)
	# the footer of the Blessing and angel screens stands where the gold does: it waits meanwhile
	_coins.visible = game.mode != Game.Mode.CHOICE or game._screen is EventChoice  # (the altar asks for gold)
	if game.rooms:
		# the descent: which room, and the gold for the shop (no experience here, so no bar over the scene)
		_xp_back.visible = false
		_xp_fill.size.x = 0.0
		_room.text = T.t(&"hud_room", {"n": game.rooms.depth(), "of": game.rooms.stage.rooms + 1})
		ahead.text = game.rooms.ahead_text()
		ahead.visible = not over and ahead.text != ""
		_coins.show_counts(T.t(&"hud_gold_count", {"n": game.rooms.gold}), game.materials.total(MaterialPurse.SILVER),
				game.materials.total(MaterialPurse.MEMORY))
		_crest.seal = ""
	else:
		_xp_fill.size.x = get_viewport_rect().size.x * game.xp_ratio()
		_room.text = T.t(&"hud_level", {"n": game.level})
		ahead.visible = false
		_coins.show_counts("%s  %d" % [T.t(&"hud_kills"), game.kills], 0, 0, false)
		_crest.seal = str(game.level)
	_update_life(p)
	if game.rooms and game.rooms.trials:
		_trial_seal.carry(game.rooms.trials.active, game.rooms.trials.left)
		_trial_seal.hide_name = _curse_badge.shown() > 0.0
	_update_slots(p)
	_update_objective(delta)
	_update_column()
	# art review 2026-11-23 (10): the angels' meeting is a stage of its own: no clock, room count or Blessing column over it
	var meeting := game._screen is EncounterScreen
	_clock.visible = not meeting
	_room.visible = not meeting
	if meeting:
		_column.visible = false
		_column_hidden = true
	elif _column_hidden:
		_column_hidden = false
		_build_key = ""
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
	_place_phase_box()
	if _phase_t <= 0.0 and _boss_box.visible and _shield_t > 0.0 and _ritual_hint:
		_phase_name.visible = false
		_style_phase(false)
		_phase_tip.text = T.t(&"ritual_hint")
		_phase_tip.visible = true
		_phase_box.visible = true
		_phase_box.modulate.a = _shield_t
	_update_pointers(chief)
	if game.boss != null and not _boss_met:
		# Morvath rises from the seal: his entrance under his bar (nobody else names the chamber)
		_boss_met = true
		show_entrance(T.t(&"room_boss"))
	_update_entrance(delta)
	_update_veil(delta)


## SW-O2: the objective line. Every OBJ_EVERY seconds the room's state is read into a context (Objective.pick); over a
## screen, the pause or for the robot the line is hidden and keeps its words for when it comes back.
func _update_objective(delta: float) -> void:
	_obj_t -= delta
	if _obj_t > 0.0:
		return
	_obj_t = OBJ_EVERY
	var r := game.rooms
	var on := r != null and r.room != null and game.bot == null and game.mode == Game.Mode.PLAY \
			and Objective.enabled(Save.data, Objective.tutorial())
	objective.visible = on
	if not on:
		return
	var ctx := objective_context(r)
	var key := Objective.pick(ctx)
	if key == &"obj_door" and _door_told_in == null:
		_door_told_in = r.room
	elif _door_told_in != null and _door_told_in != r.room:
		_door_told = true
	objective.set_key(key)
	_idle_pulse(ctx, OBJ_EVERY)


## What Objective.pick reads, from the room the hero stands in.
func objective_context(r: Rooms) -> Dictionary:
	var kind := StringName(String(RunMap.Kind.keys()[r.room.kind]).to_lower())
	var doors := r.next_rooms.size() if r.phase == Rooms.Phase.OPEN else 0
	var ctx := {"place": &"run", "kind": kind, "screen": &"", "fighting": r.phase == Rooms.Phase.FIGHT and kind != &"ante",
		"reward_waiting": r.phase == Rooms.Phase.REWARD, "doors_open": doors,
		"first_choice": doors >= 2 and not _door_told, "near_plates": false, "near_breakable": false,
		"crossed_plates": false, "broke_one": false}
	if kind != &"ante":
		return ctx
	var at := game.player.pos
	var plates: Array[Vector2] = []
	if r.plates != null:
		for n in r.plates.nodes:
			plates.append(Vector2(n.global_position.x, n.global_position.z))
	ctx.near_plates = _within(plates, at, Objective.DODGE_NEAR)
	if not plates.is_empty():
		_plates_seen(plates, at)
	ctx.crossed_plates = _plates_crossed
	if game.breaks != null and game.breaks.rules != null:
		var rules := game.breaks.rules
		ctx.broke_one = rules.broken_count() > 0
		var pieces: Array[Vector2] = []
		for i in rules.count():
			if not rules.broken(i):
				pieces.append(rules.pieces[i].at)
		ctx.near_breakable = _within(pieces, at, Objective.BREAK_NEAR)
	return ctx


static func _within(points: Array[Vector2], at: Vector2, metres: float) -> bool:
	for p in points:
		if p.distance_to(at) <= metres:
			return true
	return false


## Crossing the slabs: the side of their middle the hero was last near them on; the other side, PLATES_PAST past it, is crossed.
func _plates_seen(plates: Array[Vector2], at: Vector2) -> void:
	var mid := 0.0
	for p in plates:
		mid += p.y
	mid /= plates.size()
	var off := at.y - mid
	if _plate_side == 0:
		if _within(plates, at, Objective.DODGE_NEAR):
			_plate_side = 1 if off > 0.0 else -1
	elif absf(off) > PLATES_PAST and (1 if off > 0.0 else -1) != _plate_side:
		_plates_crossed = true


## The Antessala has no clock: a hero who stands still OBJ_IDLE seconds makes the line blink once.
func _idle_pulse(ctx: Dictionary, step: float) -> void:
	var at := game.player.pos
	if ctx.kind != &"ante" or at.distance_to(_obj_last_pos) > 0.3:
		_obj_still = 0.0
	else:
		_obj_still += step
		if _obj_still >= OBJ_IDLE:
			_obj_still = 0.0
			objective.pulse()
	_obj_last_pos = at


func _update_life(p: Player) -> void:
	_life.show_value(p.hp / p.max_hp, "%d / %d" % [ceili(p.hp), roundi(p.max_hp)])
	_update_magick(p)
	if _last_hp >= 0.0 and p.hp < _last_hp - 0.01:
		_crest.flash = 1.0
	_last_hp = p.hp
	_crest.danger = 1.0 - clampf(p.hp / p.max_hp / DANGER_FROM, 0.0, 1.0)
	_vignette.danger = _crest.danger if game.mode == Game.Mode.PLAY and p.hp > 0.0 else 0.0
	_curse_badge.ratio = p.curse.ratio()
	_crest.tint = Color(CURSE_COLOR, CURSE_TINT * _curse_badge.shown())


## U-3: the Magia as the hero's kit asks. The Maga: the full bar with its number. The Warrior: thin and dim, lit (with its
## number) while it rises or falls, or while the buttons that spend it are held.
func _update_magick(p: Player) -> void:
	var thin := game.hero == null or game.hero.arcane == null
	if thin != _magick_thin:
		_layout_bars(thin)
	var value := p.magick.value
	var text := "%d / %d" % [floori(value), roundi(p.magick.max_value)]
	if not thin:
		_magick.modulate.a = 1.0
		_magick.show_value(p.magick.ratio(), text)
		return
	var dt := get_process_delta_time()
	if magick_wakes(_magick_last, value, Controls.held(&"heavy_attack")):
		_magick_hot = HOT_TIME
	_magick_hot = maxf(0.0, _magick_hot - dt)
	_magick_last = value
	_magick.modulate.a = lerpf(MAGICK_IDLE_ALPHA, 1.0, clampf(_magick_hot / 0.4, 0.0, 1.0))
	_magick.show_value(p.magick.ratio(), text if _magick_hot > 0.0 else "")


## Whether the thin Magia lights: it changed by a point or more since last looked, or a button that spends it is held.
static func magick_wakes(last: float, now: float, held: bool) -> bool:
	return held or (last >= 0.0 and absf(now - last) >= 1.0)


func _update_slots(p: Player) -> void:
	var by_action := {}  # BC-2: by the button a Blessing really changes (the Investida's share the dash slot)
	for b in game.boons.owned():
		if b.slot != Boon.Slot.NONE and not b.is_duo():
			by_action[b.button()] = b
	var arcane := game.hero.arcane != null
	for s in _slots:
		if arcane:
			var mine: int = MAGA_GLYPHS.get(s.action, -1)
			s.glyph = mine if mine >= 0 and (by_action.get(s.action) == null or s.action == &"shout" or s.action == &"rush") else -1
		if s.action == &"shout":
			# the Brado (Q): its recharge and the Blessing of its slot, hidden for a hero without it
			s.visible = ComboTree.find(p.tree.neutral, ComboNode.In.SHOUT) != null
			s.refresh(by_action.get(&"shout"), p.shout_wait())
			continue
		if s.action == &"rush":
			# the Investida (E): its recharge
			s.visible = ComboTree.find(p.tree.neutral, ComboNode.In.RUSH) != null
			s.refresh(by_action.get(&"rush"), p.rush_wait())
			continue
		var b: Boon = by_action.get(s.action)
		var starved := not p.magick.can_pay(_omega(p, s.slot))
		match s.slot:
			Boon.Slot.DASH:
				s.refresh(b, _dash_wait(p), p.dodge_charges, p.dodge_max)
			Boon.Slot.SPECIAL:
				# a boss's curse locks the special: the diamond shows the lock running out, then a ring when it lifts
				s.refresh(b, 0.0, 0, 0, starved and not p.curse.active())
				# the rajada's price on the diamond and, without the Magia, the words (H2)
				s.cost = roundi(_omega(p, s.slot))
				# no permanent words: the starved diamond (its veil and bar) says it; the 1 s notice names it when tried
				s.caption = ""
				s.caption_color = ActionSlot.STARVED.lightened(0.45)
				s.locked = p.curse.ratio()
				# the Pastor (E4): the lights gathered, over the special's diamond
				var flock := game.psalms.holding(PsalmDef.Effect.FLOCK) if game.psalms else null
				s.show_lights(game.psalms.lights if flock else 0, flock.count if flock else 0, PsalmIcon.tint(flock).lightened(0.2) if flock else UiKit.OLD_GOLD)
			_:
				s.refresh(b, 0.0, 0, 0, starved)
	_update_ult(p)
	_update_buff(p)
	_update_shout_tip(p)


## UI 11: "Q: Brado" over the Q diamond for a second when the Brado is ready and a pack stands close (Bot.shout_worth), a
## couple of times a room and only in the save's first descents (FirstTips.shout_due); never for the robot or --nosave.
func _update_shout_tip(p: Player) -> void:
	var q := _slots[ACTIONS.find(&"shout")]
	if game.rooms != null and game.rooms.room != _shout_room:
		_shout_room = game.rooms.room
		_shout_told = 0
	if _shout_tip_t > 0.0:
		_shout_tip_t -= get_process_delta_time()
		if _shout_tip_t <= 0.0:
			q.caption = ""
		return
	if not q.visible or game.bot != null or not FirstTips.enabled() or game.mode != Game.Mode.PLAY:
		return
	if FirstTips.shout_due(Save.data, _shout_told, Bot.shout_worth(game, p.pos)):
		_shout_told += 1
		_shout_tip_t = FirstTips.SHOUT_TIME
		q.caption = T.t(&"hud_shout_tip", {"key": UiKit.action_label(&"shout")})
		q.caption_color = UiKit.PALE


## The Brado's buff (its 5 s of faster blows and less damage taken) over the Q diamond while it runs.
func _update_buff(p: Player) -> void:
	var node := ComboTree.find(p.tree.neutral, ComboNode.In.SHOUT)
	var left := p.gifts.rally_left if p.gifts != null and node != null else 0.0
	_buff.show_left(left, node.effect_time if node != null else 1.0, p.gifts != null and p.gifts.ward > 0)
	if _buff.visible:
		# UI 11: beside the bars (right of the life bar), the Brado's icon with its seconds
		var bars := _life.get_global_rect()
		_buff.global_position = Vector2(bars.end.x + BUFF_GAP, bars.get_center().y - BuffMark.SIDE * 0.5)


## The build column reads the Blessings, the Elos and the Psalm again when one of them changed.
func _update_column() -> void:
	var psalm: PsalmDef = game.psalms.taken.back() if game.psalms != null and not game.psalms.taken.is_empty() else null
	var kind := game.ults.def.kind if game.ults != null and game.ults.def != null else -1
	var key := "%s|%s|%d" % [",".join(game.boons.owned().map(func(b: Boon) -> String: return "%s:%d:%d" % [b.id, game.boons.level(b.id), game.boons.rarity(b.id)])),
			psalm.id if psalm != null else "", kind]
	if key == _build_key:
		return
	_build_key = key
	_column.show_build(game.boons, BoonIcon.ULT_GLYPH + kind if kind >= 0 else -1, psalm)
	# UI 15: only the Blessings gained; the banner is as tall as they are, around the same middle
	var h := _column.custom_minimum_size.y
	_column.offset_top = -h * 0.5
	_column.offset_bottom = h * 0.5
	_column.visible = _column.has_content()


## The ultimate's diamond (T5): sealed with the Mastery level it needs, or its charge; a refused press shows why for
## a moment (and, the first time in a run, how it charges), a charge that fills shows "Pronta" and keeps pulsing.
func _update_ult(p: Player) -> void:
	if not _ult_heard:
		_ult_heard = true
		p.ult_refused.connect(_on_ult_refused)
		p.magick_refused.connect(_on_magick_refused)
	_ult_hint_t = maxf(0.0, _ult_hint_t - get_process_delta_time())
	var ult := game.ults.def if game.ults else null
	var first := game.hero.first_ult_level() if game.hero else 0
	# SW-O5: the fifth diamond only shows once the milestone of the Golpe Supremo is open
	var open := ult_open()
	_ult_slot.visible = open and (ult != null or (first > 0 and game.bot == null))
	_charge_shown = open and ult != null and game.bot == null
	_charge.visible = _charge_shown and game.mode != Game.Mode.PAUSE
	if ult != null:
		_charge.show_value(game.ults.ratio())
		var done := game.ults.charge.ready()
		_charge.fill_top = ActionSlot.READY_COLOR if done else UiKit.OLD_GOLD.lightened(0.15)
		_charge.fill_bottom = ActionSlot.READY_COLOR.darkened(0.4) if done else UiKit.OLD_GOLD.darkened(0.45)
		_charge.queue_redraw()
	if not _ult_slot.visible:
		return
	var full := ult != null and game.ults.charge.ready()
	if full and not _ult_was_ready:
		_ult_hint_t = ULT_HINT_TIME
	_ult_was_ready = full
	var shown := ult if ult != null else game.hero.ult_for_weapon(first)
	_ult_slot.glyph = BoonIcon.ULT_GLYPH + shown.kind
	_ult_slot.refresh(null, 1.0 - game.ults.ratio() if ult != null else 0.0)
	_ult_slot.sealed = ult == null
	_ult_slot.pulse = full
	_ult_slot.urgent = ult_urgent(full, p.hp / p.max_hp)
	_ult_slot.caption = ult_caption(ult != null, full, game.ults.ratio(), first, _ult_hint_t > 0.0)
	_ult_slot.caption_color = UiKit.PALE if _ult_hint_t > 0.0 else UiKit.DIM


## SW-O5: whether the Golpe Supremo's milestone is open in this save (Milestones.ult_open, the 3A2 lote). Open while the
## script is not there and without a save (captures, the robot), so nothing hides by accident.
static func ult_open() -> bool:
	if not Save.enabled or not ResourceLoader.exists(MILESTONES):
		return true
	return bool((load(MILESTONES) as GDScript).call(&"ult_open", Save.data))


## Charge full and the hero hurt: the ready ring pulses harder.
static func ult_urgent(full: bool, hp_ratio: float) -> bool:
	return full and hp_ratio < ULT_HURT


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


## The special pressed without its Magia (the rajada): a short word, no more.
func _on_magick_refused() -> void:
	show_notice(T.t(&"hud_no_magick"), 1.0)


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
				if slot == Boon.Slot.SPECIAL:
					# the tap itself costs Magia (the rajada, 2026-11-21)
					var tap := ComboTree.find(p.tree.neutral, ComboNode.In.HEAVY)
					cost = maxf(cost, tap.magick_cost if tap else 0.0)
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
	game.horde.top_bar_for = b
	if b:
		_boss_name.text = T.t(b.def.name_key)
		_boss_bar.show_value(b.hp / b.max_hp, "", b.armor / b.max_armor if b.max_armor > 0.0 else 0.0)
		var boss := game.boss if game.boss and game.boss.e == b else null
		if boss != null and boss.def.posture > 0.0:
			_boss_bar.show_value(b.hp / b.max_hp, "", boss.posture_ratio())
		# a boss's bar: notches where his next phases begin, veiled in his colour while the ritual's shield stands
		_shield_t = move_toward(_shield_t, 1.0 if boss and boss.shielded() else 0.0, get_process_delta_time() * 4.0)
		_boss_bar.show_boss(boss.def.thresholds if boss else PackedFloat32Array(), _shield_t)
		# the ritual's count: a seal per dead that breaks the shield, while the shield shows
		_ritual_hint = boss != null and boss.shielded()
		_boss_bar.show_ritual(boss.ritual_left() if boss else 0, boss.ritual_total() if boss and _shield_t > 0.0 else 0)


## The count and the move's name stand right of the last diamond shown (the robot has no ultimate's).
func _follow_row() -> void:
	var last: Control = _slots.back()  # (the dodge, Space: always there, after the ultimate's)
	var x := last.get_global_rect().end.x - get_global_rect().position.x + ROW_COUNT_GAP - ActionSlot.KEY_H * 0.5
	if not is_equal_approx(_combo_row.offset_left, x):
		_combo_row.offset_left = x
		_combo_row.offset_right = x + LIFE.x
	# UX2-01/UX2-10: the move's name has its own strip, always at the same spot: centred over the row, above the
	# diamonds' captions (so the two never share a line)
	var cx := _action_row.get_global_rect().get_center().x - get_global_rect().position.x
	_move.offset_left = cx - MOVE_W * 0.5
	_move.offset_right = cx + MOVE_W * 0.5
	var lift := ActionSlot.CAPTION_RISE + ActionSlot.CAPTION_FONT + 6.0
	_move.offset_bottom = _action_row.offset_top - lift
	_move.offset_top = _move.offset_bottom - COMBO_WORD - 6.0


## How far over the bottom of the screen the edge chevrons' frame stands (it clears the captions over the diamonds).
func edge_bottom() -> float:
	return ROW_EDGE_BOTTOM


## Chevrons on the edge of the screen: the light fountain (with its name) and the nearest elites, guardian or boss
## out of view. Nothing shows while they are all on screen.
func _update_pointers(chief: Enemy) -> void:
	var view := get_viewport_rect()
	var bottom := edge_bottom()
	var frame := Rect2(view.position + Vector2(EDGE_INSET.x, EDGE_INSET.y), view.size - Vector2(EDGE_INSET.x + EDGE_INSET.z, EDGE_INSET.y + bottom))
	var at: Variant = game.fountain_target()
	var edge: Variant = _edge(at as Vector2, view, frame) if at != null else null
	_named_pointer(_arrow, _arrow_mark, edge, frame)
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
	_update_shooters(view, frame)


## Whether an enemy is a shooter about to fire: winding up a ranged attack with SHOOTER_WARN seconds or fewer to go.
static func shooter_warning(e: Enemy) -> bool:
	if not e.alive or e.state != Enemy.State.WINDUP:
		return false
	match e.def.behavior:
		EnemyDef.Behavior.ARCHER, EnemyDef.Behavior.PRIEST, EnemyDef.Behavior.CASTER, EnemyDef.Behavior.BEAM:
			return e.def.attack_windup - e.state_t <= SHOOTER_WARN
	return false


## U-5: a thin arrow on the edge for each shooter (at most SHOOTER_ARROWS, the nearest) aiming from out of view.
func _update_shooters(view: Rect2, frame: Rect2) -> void:
	var used := 0
	if game.mode == Game.Mode.PLAY:
		var from := game.player.pos
		var found: Array[Enemy] = []
		for e in game.horde.list:
			if shooter_warning(e) and _edge(e.pos, view, frame) != null:
				found.append(e)
		if found.size() > SHOOTER_ARROWS:
			found.sort_custom(func(a: Enemy, b: Enemy) -> bool: return a.pos.distance_squared_to(from) < b.pos.distance_squared_to(from))
		for e in found:
			if used >= SHOOTER_ARROWS:
				break
			_point(_shooter_marks[used], _edge(e.pos, view, frame), frame)
			used += 1
	for i in range(used, SHOOTER_ARROWS):
		_shooter_marks[i].visible = false


## Where on the frame the chevron for a point of the floor goes; null while that point is on screen.
func _edge(floor_at: Vector2, view: Rect2, frame: Rect2) -> Variant:
	var world := Vector3(floor_at.x, 1.0, floor_at.y)
	var sp := game.camera.unproject_position(world)
	if game.camera.is_position_behind(world):
		sp = view.get_center() * 2.0 - sp
	return edge_point(sp, view.grow(-VIEW_INSET), frame)


## A chevron on the frame with a name inside it, towards the middle of the screen (the fountain's, the door's).
func _named_pointer(label: Label, mark: HudMark, edge: Variant, frame: Rect2) -> void:
	label.visible = edge != null
	_point(mark, edge, frame)
	if edge != null:
		var dir := (frame.get_center() - (edge as Vector2)).normalized()
		var half := label.size * 0.5
		label.position = (edge as Vector2) + dir * (POINTER_SIZE * 0.5 + 6.0 + absf(dir.x) * half.x + absf(dir.y) * half.y) - half


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
		# apart: the diamonds at the foot (the hero alone), the gifts in the right corner, the build column on the edge
		_veiled = _someone_behind(_action_row.get_global_rect(), true)
		_passives_veiled = _someone_behind(_passives_rect())
		_column_veiled = _someone_behind(_column.get_global_rect())
	_passives.modulate.a = move_toward(_passives.modulate.a, VEIL_ALPHA if _passives_veiled else 1.0, delta * VEIL_SPEED)
	_column_alpha = move_toward(_column_alpha, 1.0 if _column_veiled else 0.0, delta * VEIL_SPEED)
	_column.veil(_column_alpha)
	var a := move_toward(_slot_alpha, VEIL_ALPHA if _veiled else 1.0, delta * VEIL_SPEED)
	_slot_alpha = a
	# the diamonds fade only their bodies: what they say (glyph, recharge, key) stays whole
	for s in _slots:
		s.veil = (1.0 - a) / (1.0 - VEIL_ALPHA)
	_ult_slot.veil = (1.0 - a) / (1.0 - VEIL_ALPHA)


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
		c.visible = SHOW_HITS and count >= 3
	if count == 0:
		# the count ran out: the move's name goes with it (BUG-112), a short fade and never alone in the corner
		_move_t = minf(_move_t, MOVE_FADE)
	_combo.text = str(count)
	_combo_pop = 1.0


## The move's name, in ivory whatever the move's colour (the colour is on the blade; here it has to read on any floor).
func show_move(node: ComboNode, _color: Color) -> void:
	_move.text = T.t(node.title)
	_move_action = MOVE_ACTION.get(node.input, &"light_attack")
	_move_t = MOVE_TIME


func show_notice(text: String, time: float = 2.5) -> void:
	if game and game.boss and text == T.t(&"room_boss"):
		# Morvath's chamber: the room's name goes into his entrance (AP-2)
		_boss_met = true
		show_entrance(text)
		return
	if game and game.boss and text == T.t("boss_phase_%d" % game.boss.phase):
		show_phase(text)
		return
	if oficio_notice(text):
		return  # the greeting at the top says it (_greet_oficios)
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
	_style_phase(false)
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
	_style_phase(true)
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
