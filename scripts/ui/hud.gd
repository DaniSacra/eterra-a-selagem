class_name Hud
extends Control
## What stays on screen during the run. Bottom left: the paladin's medallion with life and Magia. Bottom centre: the
## four actions as diamonds (the gift on each, the key, the recharge, the dodges) and the gifts that act alone.
## Top: the room (or the level), the clock, the gold (or the kills); the boss's life under the clock. Right: the
## hit count and the move's name. Everything sits on the edges so the middle of the screen stays for the fight.
## Sizes are in pixels at 720 lines; the window stretches the whole canvas (project.godot), so the layout holds at
## any resolution.

const MAGICK_COLOR := Color(0.3, 0.52, 1.0)
const LIFE_COLOR := Color(0.78, 0.14, 0.12)
const BOSS_COLOR := Color(0.62, 0.22, 0.85)
const MARGIN := 22.0
const CREST := 76.0
const LIFE := Vector2(244, 19)
const MAGICK := Vector2(196, 15)
const BOSS := Vector2(480, 12)
const PASSIVE_ICON := 30
const SLOT_GAP := 8
const FONT_SMALL := 15
const FONT_TEXT := 19
const FONT_CLOCK := 24
const FONT_COMBO := 46
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
var _combo: Label
var _combo_word: Label
var _combo_stroke: HudMark
var _move: Label
var _notice: Label
var _slots: Array[ActionSlot] = []
var _passives: HBoxContainer
var _arrow: Label
var _last_hp := -1.0
var _combo_pop := 0.0
var _move_t := 0.0
var _notice_t := 0.0
var _passive_count := -1


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
	_arrow = _label("", Color(1.0, 0.9, 0.6), FONT_SMALL + 1, UiKit.BOLD_FONT, Control.PRESET_TOP_LEFT, Vector2.ZERO)


## Top: experience (horde mode only, a thin gold line across the top), room or level, clock, gold or kills, boss.
func _build_top() -> void:
	_xp_back = _rect(Color(0.05, 0.03, 0.06, 0.85), Control.PRESET_TOP_WIDE)
	_xp_back.offset_bottom = 4
	_xp_fill = _rect(Color(1.0, 0.8, 0.35), Control.PRESET_TOP_LEFT)
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
	_gold = UiKit.label("", UiKit.PALE, FONT_TEXT, UiKit.TITLE_FONT)
	_purse.add_child(_gold)
	_boss_box = VBoxContainer.new()
	_boss_box.add_theme_constant_override(&"separation", 2)
	_boss_box.visible = false
	_boss_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_boss_box)
	_place(_boss_box, Control.PRESET_CENTER_TOP, Vector2(0, 42), Vector2(BOSS.x, 40))
	_boss_name = UiKit.title("", FONT_TEXT, Color(0.9, 0.75, 1.0))
	_boss_name.add_theme_constant_override(&"outline_size", 5)
	_boss_box.add_child(_boss_name)
	_boss_bar = HudBar.new().setup(BOSS_COLOR, BOSS, 11, true)
	_boss_bar.over_color = Horde.ARMOR_COLOR
	_boss_box.add_child(_boss_bar)


## Bottom left: the medallion, with life and Magia coming out from behind it.
func _build_life() -> void:
	var mid := MARGIN + CREST * 0.5
	_life = HudBar.new().setup(LIFE_COLOR, LIFE, 13)
	add_child(_life)
	_place(_life, Control.PRESET_BOTTOM_LEFT, Vector2(MARGIN + CREST - 10, -mid - 1), LIFE)
	_magick = HudBar.new().setup(MAGICK_COLOR, MAGICK, 12)
	add_child(_magick)
	_place(_magick, Control.PRESET_BOTTOM_LEFT, Vector2(MARGIN + CREST - 10, -mid + 3 + MAGICK.y), MAGICK)
	_crest = HeroCrest.new().setup(CREST)
	add_child(_crest)
	_place(_crest, Control.PRESET_BOTTOM_LEFT, Vector2(MARGIN, -MARGIN), Vector2(CREST, CREST))


## Bottom centre: the four action diamonds; the gifts that act alone sit in a row to their right.
func _build_actions() -> void:
	var row := HBoxContainer.new()
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
	_move = _label("", Color(1.0, 0.92, 0.7), FONT_TEXT + 1, UiKit.TITLE_FONT, Control.PRESET_CENTER_RIGHT, Vector2(-MARGIN - 6, -30))
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


func _label(text: String, color: Color, size: int, font: Font, preset: Control.LayoutPreset, offset: Vector2) -> Label:
	var l := UiKit.label(text, color, size, font)
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
	_update_boss()
	_combo_pop = maxf(0.0, _combo_pop - delta * 4.0)
	_combo.scale = Vector2.ONE * (1.0 + _combo_pop * 0.35)
	_combo.pivot_offset = _combo.size * Vector2(1.0, 0.5)
	_move_t -= delta
	_move.modulate.a = clampf(_move_t / 0.4, 0.0, 1.0)
	_notice_t -= delta
	_notice.modulate.a = clampf(_notice_t / 0.6, 0.0, 1.0)
	_update_arrow()


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
		match s.slot:
			Boon.Slot.CAST:
				s.refresh(b, 1.0 if p.cast_active else p.cast_cooldown / Player.CAST_COOLDOWN)
			Boon.Slot.DASH:
				s.refresh(b, 1.0 if p.dodge_charges <= 0 else 0.0, p.dodge_charges, p.dodge_max)
			_:
				s.refresh(b, 0.0)


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


func _update_boss() -> void:
	var b := game.boss_enemy()
	_boss_box.visible = b != null
	if b:
		_boss_name.text = T.t(b.def.name_key)
		_boss_bar.show_value(b.hp / b.max_hp, "", b.armor / b.max_armor if b.max_armor > 0.0 else 0.0)


## Where the light fountain is, when it is off screen.
func _update_arrow() -> void:
	var at: Variant = game.fountain_target()
	if at == null:
		_arrow.visible = false
		return
	var world := Vector3((at as Vector2).x, 1.0, (at as Vector2).y)
	var sp := game.camera.unproject_position(world)
	var rect := get_viewport_rect().grow(-60)
	if rect.has_point(sp):
		_arrow.visible = false
		return
	_arrow.visible = true
	var c := rect.get_center()
	var d := (sp - c)
	var k := minf(absf(rect.size.x * 0.5 / d.x) if d.x != 0.0 else INF, absf(rect.size.y * 0.5 / d.y) if d.y != 0.0 else INF)
	# the label sits on the edge of the screen in the fountain's direction
	_arrow.text = "« %s »" % T.t(&"hud_fountain")
	_arrow.position = c + d * k - _arrow.size * 0.5


func on_combo(count: int) -> void:
	for c: CanvasItem in [_combo, _combo_word, _combo_stroke]:
		c.visible = count >= 3
	_combo.text = str(count)
	_combo_pop = 1.0


func show_move(node: ComboNode, color: Color) -> void:
	_move.text = T.t(node.title)
	_move.add_theme_color_override(&"font_color", color.lightened(0.35))
	_move_t = 1.4


func show_notice(text: String, time: float = 2.5) -> void:
	_notice.text = text
	_notice.size = Vector2.ZERO
	_notice.position.x = (get_viewport_rect().size.x - _notice.get_combined_minimum_size().x) * 0.5
	_notice_t = time
