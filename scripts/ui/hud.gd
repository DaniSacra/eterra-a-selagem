class_name Hud
extends Control
## What stays on screen during the run: Magia, life, dodges and the circle of light (bottom left), experience and level (top), the clock and the
## kills (top), the boss's life (top centre), the combo counter and the move name (right), the gifts (bottom centre).

const MAGICK_COLOR := Color(0.35, 0.55, 1.0)
const CAST_READY := Color(1.0, 0.92, 0.7)
const CAST_WAIT := Color(0.2, 0.18, 0.22, 0.8)
## Sizes in pixels at 720 lines: a quiet HUD in the corners, as in Hades II (the first test found it too big).
const BAR_W := 240.0
const HP_H := 14.0
const MAGICK_H := 5.0
const BOSS_W := 480.0
const BOSS_H := 9.0
const PIP := Vector2(26, 5)
const CAST_SIZE := 11.0
const ICON_SIZE := 38
const MARGIN := 20.0
const FONT_SMALL := 15
const FONT_TEXT := 18
const FONT_CLOCK := 26
const FONT_COMBO := 40

var game: Game
var _hp_fill: ColorRect
var _hp_back: ColorRect
var _hp_text: Label
var _dodges: HBoxContainer
var _xp_back: ColorRect
var _xp_fill: ColorRect
var _level: Label
var _clock: Label
var _kills: Label
var _boss_box: VBoxContainer
var _boss_name: Label
var _boss_fill: ColorRect
var _boss_back: ColorRect
var _boss_armor: ColorRect
var _magick_fill: ColorRect
var _cast: ColorRect
var _combo: Label
var _combo_word: Label
var _move: Label
var _notice: Label
var _icons: HBoxContainer
var _arrow: Label
var _hp_shown := 1.0
var _combo_pop := 0.0
var _move_t := 0.0
var _notice_t := 0.0
var _icon_count := -1


func _ready() -> void:
	theme = UiKit.theme()
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	# experience (horde mode only): a thin gold line across the top
	_xp_back = _rect(Color(0.05, 0.03, 0.06, 0.85), Control.PRESET_TOP_WIDE)
	_xp_back.offset_bottom = 5
	_xp_fill = _rect(Color(1.0, 0.8, 0.35), Control.PRESET_TOP_LEFT)
	_xp_fill.size = Vector2(0, 5)
	_level = _label("", UiKit.GOLD, FONT_TEXT, UiKit.TITLE_FONT, Control.PRESET_TOP_LEFT, Vector2(MARGIN, 14))
	_clock = _label("0:00", UiKit.PALE, FONT_CLOCK, UiKit.TITLE_FONT, Control.PRESET_CENTER_TOP, Vector2(0, 10))
	_clock.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_kills = _label("", UiKit.PALE, FONT_TEXT, UiKit.BOLD_FONT, Control.PRESET_TOP_RIGHT, Vector2(-MARGIN, 14))
	_kills.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	# life, bottom left
	_hp_back = _rect(Color(0.04, 0.02, 0.04, 0.9), Control.PRESET_BOTTOM_LEFT)
	_place(_hp_back, Control.PRESET_BOTTOM_LEFT, Vector2(MARGIN, -MARGIN - 12), Vector2(BAR_W, HP_H))
	var hp_lag := ColorRect.new()
	hp_lag.color = Color(1.0, 0.85, 0.7, 0.5)
	hp_lag.name = "Lag"
	_hp_back.add_child(hp_lag)
	_hp_fill = ColorRect.new()
	_hp_fill.color = Color(0.78, 0.14, 0.12)
	_hp_back.add_child(_hp_fill)
	var shine := ColorRect.new()
	shine.color = Color(1, 1, 1, 0.12)
	shine.size = Vector2(BAR_W, HP_H * 0.3)
	_hp_back.add_child(shine)
	_hp_text = UiKit.label("", UiKit.PALE, FONT_SMALL - 2, UiKit.BOLD_FONT)
	_hp_text.size = Vector2(BAR_W, HP_H)
	_hp_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_hp_text.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_hp_back.add_child(_hp_text)
	# Magia: a thin blue bar above the life
	var magick_back := _rect(Color(0.04, 0.03, 0.08, 0.9), Control.PRESET_BOTTOM_LEFT)
	_place(magick_back, Control.PRESET_BOTTOM_LEFT, Vector2(MARGIN, -MARGIN - 12 - HP_H - 4), Vector2(BAR_W, MAGICK_H))
	_magick_fill = ColorRect.new()
	_magick_fill.color = MAGICK_COLOR
	_magick_fill.size = Vector2(BAR_W, MAGICK_H)
	magick_back.add_child(_magick_fill)
	# the circle of light: a diamond right of the dodges, lit when ready
	_cast = _rect(CAST_READY, Control.PRESET_BOTTOM_LEFT)
	_place(_cast, Control.PRESET_BOTTOM_LEFT, Vector2(MARGIN + BAR_W + 14, -MARGIN - 12 - HP_H * 0.5 + CAST_SIZE * 0.5), Vector2(CAST_SIZE, CAST_SIZE))
	_cast.rotation = PI / 4.0
	_dodges = HBoxContainer.new()
	add_child(_dodges)
	_place(_dodges, Control.PRESET_BOTTOM_LEFT, Vector2(MARGIN, -MARGIN), Vector2(200, PIP.y))
	# boss
	_boss_box = VBoxContainer.new()
	_boss_box.custom_minimum_size = Vector2(BOSS_W, 0)
	_boss_box.visible = false
	add_child(_boss_box)
	_place(_boss_box, Control.PRESET_CENTER_TOP, Vector2(0, 44), Vector2(BOSS_W, 36))
	_boss_name = UiKit.title("", FONT_TEXT, Color(0.9, 0.75, 1.0))
	_boss_box.add_child(_boss_name)
	_boss_back = ColorRect.new()
	_boss_back.color = Color(0.04, 0.02, 0.06, 0.9)
	_boss_back.custom_minimum_size = Vector2(BOSS_W, BOSS_H)
	_boss_box.add_child(_boss_back)
	_boss_fill = ColorRect.new()
	_boss_fill.color = Color(0.62, 0.22, 0.85)
	_boss_back.add_child(_boss_fill)
	_boss_armor = ColorRect.new()
	_boss_armor.color = Horde.ARMOR_COLOR
	_boss_back.add_child(_boss_armor)
	# combo, right side
	_combo = _label("", UiKit.GOLD, FONT_COMBO, UiKit.TITLE_FONT, Control.PRESET_CENTER_RIGHT, Vector2(-MARGIN - 8, -86))
	_combo.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_combo_word = _label(T.t(&"hud_combo"), UiKit.PALE, FONT_SMALL, UiKit.BOLD_FONT, Control.PRESET_CENTER_RIGHT, Vector2(-MARGIN - 8, -38))
	_combo_word.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_move = _label("", Color(1.0, 0.92, 0.7), FONT_TEXT + 2, UiKit.TITLE_FONT, Control.PRESET_CENTER_RIGHT, Vector2(-MARGIN - 8, -14))
	_move.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_combo.visible = false
	_combo_word.visible = false
	_notice = _label("", UiKit.PALE, FONT_TEXT + 4, UiKit.TITLE_FONT, Control.PRESET_CENTER_TOP, Vector2(0, 110))
	_notice.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_notice.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_icons = HBoxContainer.new()
	_icons.add_theme_constant_override(&"separation", 6)
	_icons.alignment = BoxContainer.ALIGNMENT_CENTER
	add_child(_icons)
	_place(_icons, Control.PRESET_CENTER_BOTTOM, Vector2(0, -12), Vector2(900, ICON_SIZE + 10))
	_arrow = _label("", Color(1.0, 0.9, 0.6), FONT_SMALL + 1, UiKit.BOLD_FONT, Control.PRESET_TOP_LEFT, Vector2.ZERO)


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
	var w := get_viewport_rect().size.x
	_clock.text = SaveData.format_time(game.time)
	if game.rooms:
		# the descent: which room, and the gold for the shop (no experience here, so no bar over the scene)
		_xp_back.visible = false
		_xp_fill.size.x = 0.0
		_level.text = T.t(&"hud_room", {"n": game.rooms.depth(), "of": game.rooms.stage.rooms + 1})
		_kills.text = "%s  %d" % [T.t(&"hud_gold"), game.rooms.gold]
	else:
		_xp_fill.size.x = w * game.xp_ratio()
		_level.text = T.t(&"hud_level", {"n": game.level})
		_kills.text = "%s  %d" % [T.t(&"hud_kills"), game.kills]
	var ratio := clampf(p.hp / p.max_hp, 0.0, 1.0)
	_hp_shown = move_toward(_hp_shown, ratio, delta * 0.5) if _hp_shown > ratio else ratio
	_hp_fill.size = Vector2(BAR_W * ratio, HP_H)
	(_hp_back.get_node("Lag") as ColorRect).size = Vector2(BAR_W * _hp_shown, HP_H)
	_hp_text.text = "%d / %d" % [ceili(p.hp), roundi(p.max_hp)]
	_update_dodges(p)
	_magick_fill.size = Vector2(BAR_W * p.magick.ratio(), MAGICK_H)
	_cast.color = CAST_READY if p.cast_cooldown <= 0.0 else CAST_WAIT
	var b := game.boss_enemy()
	_boss_box.visible = b != null
	if b:
		_boss_name.text = T.t(b.def.name_key)
		_boss_fill.size = Vector2(BOSS_W * clampf(b.hp / b.max_hp, 0.0, 1.0), BOSS_H)
		_boss_armor.size = Vector2(BOSS_W * (b.armor / b.max_armor if b.max_armor > 0.0 else 0.0), BOSS_H * 0.4)
	_combo_pop = maxf(0.0, _combo_pop - delta * 4.0)
	_combo.scale = Vector2.ONE * (1.0 + _combo_pop * 0.35)
	_combo.pivot_offset = _combo.size * Vector2(1.0, 0.5)
	_move_t -= delta
	_move.modulate.a = clampf(_move_t / 0.4, 0.0, 1.0)
	_notice_t -= delta
	_notice.modulate.a = clampf(_notice_t / 0.6, 0.0, 1.0)
	_update_icons()
	_update_arrow()


func _update_dodges(p: Player) -> void:
	while _dodges.get_child_count() < p.dodge_max:
		var pip := ColorRect.new()
		pip.custom_minimum_size = PIP
		_dodges.add_child(pip)
	while _dodges.get_child_count() > p.dodge_max:
		_dodges.get_child(_dodges.get_child_count() - 1).free()
	for i in _dodges.get_child_count():
		(_dodges.get_child(i) as ColorRect).color = Color(0.5, 0.85, 1.0) if i < p.dodge_charges else Color(0.15, 0.2, 0.28, 0.8)


func _update_icons() -> void:
	var owned := game.boons.owned()
	if owned.size() != _icon_count:
		_icon_count = owned.size()
		for c in _icons.get_children():
			c.queue_free()
		for b in owned:
			_icons.add_child(BoonIcon.new().setup(b, ICON_SIZE))
	var i := 0
	for c in _icons.get_children():
		if c.is_queued_for_deletion():
			continue
		var icon := c as BoonIcon
		icon.level = game.boons.level(icon.boon.id)
		icon.max_level = icon.boon.max_level
		if icon.boon.skill and icon.boon.skill.kind != SkillDef.Kind.ORBIT:
			var t := game.skills.timer(icon.boon)
			icon.cooldown = clampf(t.x / maxf(t.y, 0.01), 0.0, 1.0)
		icon.queue_redraw()
		i += 1


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
	_combo.visible = count >= 3
	_combo_word.visible = count >= 3
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
