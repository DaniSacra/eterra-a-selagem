class_name Hud
extends Control
## What stays on screen during the run. Bottom left: the paladin's medallion with life and Magia. Bottom centre: the
## four actions as diamonds (the gift on each, the key, the recharge, the dodges) and the gifts that act alone.
## Top: the room (or the level), the clock, the gold (or the kills); the boss's life under the clock. Right: the
## hit count and the move's name. Everything sits on the edges so the middle of the screen stays for the fight: the
## actions turn translucent while someone stands behind them, and small chevrons on the edge point at the elites,
## the guardian or the boss out of view (the diamonds keep their glyph, recharge and key whole, ActionSlot.veil). One gold for the frames (UiKit.OLD_GOLD, UiKit.FRAME wide), one shadow
## under every text (UiKit.shadow).
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
const SLOT_GAP := 8
const FONT_SMALL := 15
const FONT_TEXT := 19
const FONT_CLOCK := 24
const FONT_COMBO := 46
## The move's name: how long it shows, and how fast it goes (a short cut, no long ghost).
const MOVE_TIME := 1.2
const MOVE_FADE := 0.25
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
const EDGE_INSET := Vector4(30.0, 96.0, 30.0, 116.0)
## The four actions in the order of the diamonds, with the gift slot that changes each.
const ACTIONS: Array[StringName] = [&"light_attack", &"heavy_attack", &"cast", &"dodge"]
const SLOTS: Array[Boon.Slot] = [Boon.Slot.ATTACK, Boon.Slot.SPECIAL, Boon.Slot.CAST, Boon.Slot.DASH]

var game: Game
var _crest: HeroCrest
var _life: HudBar
var _magick: HudBar
var _room: Label
var _clock: Label
var _purse: HBoxContainer
var _coin: HudMark
var _gold: Label
var _xp_back: ColorRect
var _xp_fill: ColorRect
var _boss_box: VBoxContainer
var _boss_name: Label
var _boss_bar: HudBar
var _shield_t := 0.0
var _combo: Label
var _combo_word: Label
var _combo_stroke: HudMark
var _move: Label
var _notice: Label
var _slots: Array[ActionSlot] = []
var _passives: HBoxContainer
var _arrow: Label
var _arrow_mark: HudMark
var _pointers: Array[HudMark] = []
var _action_row: HBoxContainer
var _veil_t := 0.0
var _veiled := false
## Magia each action's held version costs (by slot).
var _omega_cost := {}
## The dodge's recharge, followed by the run's clock (Player keeps its own timer to itself).
var _dash_charges := -1
var _dash_from := 0.0
var _last_hp := -1.0
var _combo_pop := 0.0
var _move_t := 0.0
var _notice_t := 0.0
var _passive_count := -1
var _elo_banner: EloBanner
## Elos already greeted (the ones owned when the run starts are not).
var _elos_seen := {}
var _elos_ready := false


func _ready() -> void:
	theme = UiKit.theme()
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
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


## Top: experience (horde mode only, a thin gold line across the top), room or level, clock, gold or kills, boss.
func _build_top() -> void:
	_xp_back = _rect(Color(0.05, 0.03, 0.06, 0.85), Control.PRESET_TOP_WIDE)
	_xp_back.offset_bottom = 4
	_xp_fill = _rect(UiKit.GOLD, Control.PRESET_TOP_LEFT)
	_xp_fill.size = Vector2(0, 4)
	_room = _label("", UiKit.PALE, FONT_TEXT, UiKit.TITLE_FONT, Control.PRESET_TOP_LEFT, Vector2(MARGIN, 12))
	_clock = _label("0:00", UiKit.PALE, FONT_CLOCK, UiKit.TITLE_FONT, Control.PRESET_CENTER_TOP, Vector2(0, 8))
	_clock.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_clock.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_purse = HBoxContainer.new()
	_purse.add_theme_constant_override(&"separation", 6)
	_purse.alignment = BoxContainer.ALIGNMENT_END
	_purse.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_purse)
	_place(_purse, Control.PRESET_TOP_RIGHT, Vector2(-MARGIN, 10), Vector2(260, 30))
	_coin = HudMark.new().setup(HudMark.Kind.COIN, Vector2(17, 17))
	_coin.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_purse.add_child(_coin)
	_gold = UiKit.shadow(UiKit.label("", UiKit.PALE, FONT_TEXT, UiKit.TITLE_FONT))
	_purse.add_child(_gold)
	_boss_box = VBoxContainer.new()
	_boss_box.add_theme_constant_override(&"separation", 2)
	_boss_box.visible = false
	_boss_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_boss_box)
	_place(_boss_box, Control.PRESET_CENTER_TOP, Vector2(0, 42), Vector2(BOSS.x, 40))
	_boss_name = UiKit.shadow(UiKit.title("", FONT_TEXT, UiKit.PALE))
	_boss_name.add_theme_constant_override(&"outline_size", 5)
	_boss_box.add_child(_boss_name)
	_boss_bar = HudBar.new().setup(BOSS_COLOR, BOSS, 11, true)
	_boss_bar.over_color = Horde.ARMOR_COLOR
	_boss_box.add_child(_boss_bar)


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


## Bottom centre: the four action diamonds; the gifts that act alone sit in a row to their right.
func _build_actions() -> void:
	var row := HBoxContainer.new()
	_action_row = row
	row.add_theme_constant_override(&"separation", SLOT_GAP)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(row)
	for i in ACTIONS.size():
		var s := ActionSlot.new().setup(ACTIONS[i], SLOTS[i])
		row.add_child(s)
		_slots.append(s)
	var width := row.get_combined_minimum_size().x
	var height := ActionSlot.DIAMOND + ActionSlot.KEY_H * 0.5
	_place(row, Control.PRESET_CENTER_BOTTOM, Vector2(0, -MARGIN + 6), Vector2(width, height))
	_passives = HBoxContainer.new()
	_passives.add_theme_constant_override(&"separation", 4)
	_passives.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_passives)
	var room := 300.0
	_place(_passives, Control.PRESET_CENTER_BOTTOM, Vector2(width * 0.5 + 18 + room * 0.5, -MARGIN - 4), Vector2(room, PASSIVE_ICON + 6))


## Right: the hit count with a brush stroke, and the move's name under it.
func _build_combo() -> void:
	_combo = _label("", UiKit.GOLD, FONT_COMBO, UiKit.TITLE_FONT, Control.PRESET_CENTER_RIGHT, Vector2(-MARGIN - 10, -118))
	_combo.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_combo.add_theme_constant_override(&"outline_size", 8)
	_combo_word = _label(T.t(&"hud_hits"), UiKit.PALE, FONT_TEXT - 1, UiKit.TITLE_FONT, Control.PRESET_CENTER_RIGHT, Vector2(-MARGIN - 6, -72))
	_combo_word.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_combo_stroke = HudMark.new().setup(HudMark.Kind.STROKE, Vector2(100, 16))
	add_child(_combo_stroke)
	_place(_combo_stroke, Control.PRESET_CENTER_RIGHT, Vector2(-MARGIN + 8, -48), Vector2(100, 16))
	_move = _label("", UiKit.PALE, FONT_TEXT + 1, UiKit.TITLE_FONT, Control.PRESET_CENTER_RIGHT, Vector2(-MARGIN - 6, -30))
	_move.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	for c: CanvasItem in [_combo, _combo_word, _combo_stroke]:
		c.visible = false


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
	var p := game.player
	_clock.text = SaveData.format_time(game.time)
	_coin.visible = game.rooms != null
	if game.rooms:
		# the descent: which room, and the gold for the shop (no experience here, so no bar over the scene)
		_xp_back.visible = false
		_xp_fill.size.x = 0.0
		_room.text = T.t(&"hud_room", {"n": game.rooms.depth(), "of": game.rooms.stage.rooms + 1})
		_gold.text = T.t(&"hud_gold_count", {"n": game.rooms.gold})
		_crest.seal = ""
	else:
		_xp_fill.size.x = get_viewport_rect().size.x * game.xp_ratio()
		_room.text = T.t(&"hud_level", {"n": game.level})
		_gold.text = "%s  %d" % [T.t(&"hud_kills"), game.kills]
		_crest.seal = str(game.level)
	_update_life(p)
	_update_slots(p)
	_update_passives()
	_update_elos()
	# the boss (or the guardian) once a frame: finding a guardian walks the whole crowd
	var chief := game.boss_enemy()
	_update_boss(chief)
	_combo_pop = maxf(0.0, _combo_pop - delta * 4.0)
	_combo.scale = Vector2.ONE * (1.0 + _combo_pop * 0.35)
	_combo.pivot_offset = _combo.size * Vector2(1.0, 0.5)
	_move_t -= delta
	_move.modulate.a = clampf(_move_t / MOVE_FADE, 0.0, 1.0)
	_notice_t -= delta
	_notice.modulate.a = clampf(_notice_t / 0.6, 0.0, 1.0)
	_update_pointers(chief)
	_update_veil(delta)


func _update_life(p: Player) -> void:
	_life.show_value(p.hp / p.max_hp, "%d / %d" % [ceili(p.hp), roundi(p.max_hp)])
	_magick.show_value(p.magick.ratio(), "%d / %d" % [floori(p.magick.value), roundi(p.magick.max_value)])
	if _last_hp >= 0.0 and p.hp < _last_hp - 0.01:
		_crest.flash = 1.0
	_last_hp = p.hp
	_crest.danger = 1.0 - clampf(p.hp / p.max_hp / 0.3, 0.0, 1.0)


func _update_slots(p: Player) -> void:
	var by_slot := {}
	for b in game.boons.owned():
		by_slot[b.slot] = b
	for s in _slots:
		var b: Boon = by_slot.get(s.slot)
		var starved := not p.magick.can_pay(_omega(p, s.slot))
		match s.slot:
			Boon.Slot.CAST:
				s.refresh(b, 1.0 if p.cast_active else p.cast_cooldown / Player.CAST_COOLDOWN, 0, 0, starved)
			Boon.Slot.DASH:
				s.refresh(b, _dash_wait(p), p.dodge_charges, p.dodge_max)
			Boon.Slot.SPECIAL:
				# a boss's curse locks the special: the diamond shows it recharging as the curse runs out
				s.refresh(b, p.curse.ratio(), 0, 0, starved or p.curse.active())
			_:
				s.refresh(b, 0.0, 0, 0, starved)


## Magia the held (Omega) version of a slot's action costs; 0 when it has none.
func _omega(p: Player, slot: Boon.Slot) -> float:
	if not _omega_cost.has(slot):
		var cost := 0.0
		match slot:
			Boon.Slot.ATTACK, Boon.Slot.SPECIAL:
				var node := ComboTree.find(p.tree.neutral, ComboNode.In.CHARGE_LIGHT if slot == Boon.Slot.ATTACK else ComboNode.In.CHARGE)
				cost = node.magick_cost if node else 0.0
			Boon.Slot.CAST:
				cost = Player.CAST_OMEGA_COST
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
	return 1.0 - clampf((game.time - _dash_from) / maxf(Feel.live().dodge_recharge, 0.01), 0.0, 1.0)


## The gifts with no action of their own: small medallions with their recharge.
func _update_passives() -> void:
	var owned: Array[Boon] = []
	owned.assign(game.boons.owned().filter(func(b: Boon) -> bool: return b.slot == Boon.Slot.NONE))
	if owned.size() != _passive_count:
		_passive_count = owned.size()
		for c in _passives.get_children():
			c.queue_free()
		for b in owned:
			_passives.add_child(BoonIcon.new().setup(b, PASSIVE_ICON))
	for c in _passives.get_children():
		if c.is_queued_for_deletion():
			continue
		var icon := c as BoonIcon
		icon.level = game.boons.level(icon.boon.id)
		icon.max_level = icon.boon.max_level
		if icon.boon.skill and icon.boon.skill.kind != SkillDef.Kind.ORBIT:
			var t := game.skills.timer(icon.boon)
			icon.cooldown = clampf(t.x / maxf(t.y, 0.01), 0.0, 1.0)
		icon.queue_redraw()


## Greets each Elo once, when it is taken.
func _update_elos() -> void:
	for b in game.boons.new_elos(_elos_seen):
		_elos_seen[b.id] = true
		if _elos_ready:
			_elo_banner.show_elo(b, game.boons.sources(b))
			_notice_t = 0.0  # the Elo takes the notice's place
	_elos_ready = true


func _update_boss(b: Enemy) -> void:
	_boss_box.visible = b != null
	if b:
		_boss_name.text = T.t(b.def.name_key)
		_boss_bar.show_value(b.hp / b.max_hp, "", b.armor / b.max_armor if b.max_armor > 0.0 else 0.0)
		var boss := game.boss if game.boss and game.boss.e == b else null
		# a boss's bar: notches where his next phases begin, veiled in his colour while the ritual's shield stands
		_shield_t = move_toward(_shield_t, 1.0 if boss and boss.shielded() else 0.0, get_process_delta_time() * 4.0)
		_boss_bar.show_boss(boss.def.thresholds if boss else PackedFloat32Array(), _shield_t)


## Chevrons on the edge of the screen: the light fountain (with its name) and the nearest elites, guardian or boss
## out of view. Nothing shows while they are all on screen.
func _update_pointers(chief: Enemy) -> void:
	var view := get_viewport_rect()
	var frame := Rect2(view.position + Vector2(EDGE_INSET.x, EDGE_INSET.y), view.size - Vector2(EDGE_INSET.x + EDGE_INSET.z, EDGE_INSET.y + EDGE_INSET.w))
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
		_veiled = _someone_behind(_actions_rect())
	var a := move_toward(_passives.modulate.a, VEIL_ALPHA if _veiled else 1.0, delta * VEIL_SPEED)
	_passives.modulate.a = a
	# the diamonds fade only their bodies: what they say (glyph, recharge, key) stays whole
	for s in _slots:
		s.veil = (1.0 - a) / (1.0 - VEIL_ALPHA)


## The diamonds and the gifts beside them, on screen.
func _actions_rect() -> Rect2:
	var r := _action_row.get_global_rect()
	for c in _passives.get_children():
		r = r.merge((c as Control).get_global_rect())
	return r


func _someone_behind(rect: Rect2) -> bool:
	var p := game.player
	var feet := game.camera.unproject_position(Vector3(p.pos.x, 0.0, p.pos.y))
	# how tall a body stands on screen (the same for everyone, near enough, with this long lens)
	var tall := feet.y - game.camera.unproject_position(Vector3(p.pos.x, BODY_HEIGHT, p.pos.y)).y
	if body_rect(feet, tall).intersects(rect):
		return true
	for e in game.horde.list:
		if e.alive and body_rect(game.camera.unproject_position(Vector3(e.pos.x, 0.0, e.pos.y)), tall).intersects(rect):
			return true
	return false


## The box a standing body covers on screen, from where its feet are.
static func body_rect(feet: Vector2, tall: float) -> Rect2:
	return Rect2(feet.x - BODY_HALF, feet.y - tall, BODY_HALF * 2.0, tall)


func on_combo(count: int) -> void:
	for c: CanvasItem in [_combo, _combo_word, _combo_stroke]:
		c.visible = count >= 3
	_combo.text = str(count)
	_combo_pop = 1.0


## The move's name, in ivory whatever the move's colour (the colour is on the blade; here it has to read on any floor).
func show_move(node: ComboNode, _color: Color) -> void:
	_move.text = T.t(node.title)
	_move_t = MOVE_TIME


func show_notice(text: String, time: float = 2.5) -> void:
	_notice.text = text
	_notice.size = Vector2.ZERO
	_notice.position.x = (get_viewport_rect().size.x - _notice.get_combined_minimum_size().x) * 0.5
	_notice_t = time
