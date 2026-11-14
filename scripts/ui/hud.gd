class_name Hud
extends Control
## What stays on screen during the run: Magia, life, dodges and the circle of light (bottom left), experience and level (top), the clock and the
## kills (top), the boss's life (top centre), the combo counter and the move name (right), the gifts (bottom centre).

const MAGICK_COLOR := Color(0.35, 0.55, 1.0)
const CAST_READY := Color(1.0, 0.92, 0.7)
const CAST_WAIT := Color(0.2, 0.18, 0.22, 0.8)

var game: Game
var _hp_fill: ColorRect
var _hp_back: ColorRect
var _hp_text: Label
var _dodges: HBoxContainer
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
	# experience: a thin gold line across the top
	var xp_back := _rect(Color(0.05, 0.03, 0.06, 0.85), Control.PRESET_TOP_WIDE)
	xp_back.offset_bottom = 8
	_xp_fill = _rect(Color(1.0, 0.8, 0.35), Control.PRESET_TOP_LEFT)
	_xp_fill.size = Vector2(0, 8)
	_level = _label("", UiKit.GOLD, 26, UiKit.TITLE_FONT, Control.PRESET_TOP_LEFT, Vector2(24, 16))
	_clock = _label("0:00", UiKit.PALE, 38, UiKit.TITLE_FONT, Control.PRESET_CENTER_TOP, Vector2(0, 12))
	_clock.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_kills = _label("", UiKit.PALE, 24, UiKit.BOLD_FONT, Control.PRESET_TOP_RIGHT, Vector2(-24, 18))
	_kills.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	# life, bottom left
	_hp_back = _rect(Color(0.04, 0.02, 0.04, 0.9), Control.PRESET_BOTTOM_LEFT)
	_place(_hp_back, Control.PRESET_BOTTOM_LEFT, Vector2(24, -46), Vector2(340, 26))
	var hp_lag := ColorRect.new()
	hp_lag.color = Color(1.0, 0.85, 0.7, 0.5)
	hp_lag.name = "Lag"
	_hp_back.add_child(hp_lag)
	_hp_fill = ColorRect.new()
	_hp_fill.color = Color(0.78, 0.14, 0.12)
	_hp_back.add_child(_hp_fill)
	var shine := ColorRect.new()
	shine.color = Color(1, 1, 1, 0.12)
	shine.size = Vector2(340, 8)
	_hp_back.add_child(shine)
	_hp_text = UiKit.label("", UiKit.PALE, 20, UiKit.BOLD_FONT)
	_hp_text.size = Vector2(340, 26)
	_hp_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_hp_text.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_hp_back.add_child(_hp_text)
	# Magia: a thin blue bar above the life
	var magick_back := _rect(Color(0.04, 0.03, 0.08, 0.9), Control.PRESET_BOTTOM_LEFT)
	_place(magick_back, Control.PRESET_BOTTOM_LEFT, Vector2(24, -78), Vector2(340, 8))
	_magick_fill = ColorRect.new()
	_magick_fill.color = MAGICK_COLOR
	_magick_fill.size = Vector2(340, 8)
	magick_back.add_child(_magick_fill)
	# the circle of light: a diamond right of the dodges, lit when ready
	_cast = _rect(CAST_READY, Control.PRESET_BOTTOM_LEFT)
	_place(_cast, Control.PRESET_BOTTOM_LEFT, Vector2(380, -44), Vector2(16, 16))
	_cast.rotation = PI / 4.0
	_dodges = HBoxContainer.new()
	add_child(_dodges)
	_place(_dodges, Control.PRESET_BOTTOM_LEFT, Vector2(24, -24), Vector2(200, 8))
	# boss
	_boss_box = VBoxContainer.new()
	_boss_box.custom_minimum_size = Vector2(640, 0)
	_boss_box.visible = false
	add_child(_boss_box)
	_place(_boss_box, Control.PRESET_CENTER_TOP, Vector2(0, 62), Vector2(640, 50))
	_boss_name = UiKit.title("", 24, Color(0.9, 0.75, 1.0))
	_boss_box.add_child(_boss_name)
	_boss_back = ColorRect.new()
	_boss_back.color = Color(0.04, 0.02, 0.06, 0.9)
	_boss_back.custom_minimum_size = Vector2(640, 14)
	_boss_box.add_child(_boss_back)
	_boss_fill = ColorRect.new()
	_boss_fill.color = Color(0.62, 0.22, 0.85)
	_boss_back.add_child(_boss_fill)
	_boss_armor = ColorRect.new()
	_boss_armor.color = Horde.ARMOR_COLOR
	_boss_back.add_child(_boss_armor)
	# combo, right side
	_combo = _label("", UiKit.GOLD, 64, UiKit.TITLE_FONT, Control.PRESET_CENTER_RIGHT, Vector2(-40, -120))
	_combo.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_combo_word = _label(T.t(&"hud_combo"), UiKit.PALE, 22, UiKit.BOLD_FONT, Control.PRESET_CENTER_RIGHT, Vector2(-40, -44))
	_combo_word.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_move = _label("", Color(1.0, 0.92, 0.7), 30, UiKit.TITLE_FONT, Control.PRESET_CENTER_RIGHT, Vector2(-40, -10))
	_move.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_combo.visible = false
	_combo_word.visible = false
	_notice = _label("", UiKit.PALE, 30, UiKit.TITLE_FONT, Control.PRESET_CENTER_TOP, Vector2(0, 130))
	_notice.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_notice.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_icons = HBoxContainer.new()
	_icons.add_theme_constant_override(&"separation", 8)
	_icons.alignment = BoxContainer.ALIGNMENT_CENTER
	add_child(_icons)
	_place(_icons, Control.PRESET_CENTER_BOTTOM, Vector2(0, -16), Vector2(900, 64))
	_arrow = _label("", Color(1.0, 0.9, 0.6), 22, UiKit.BOLD_FONT, Control.PRESET_TOP_LEFT, Vector2.ZERO)


## Puts a control of a given size at a corner or edge of the screen, moved by offset from there.
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
		# the descent: which room, and the gold for the shop (no experience here)
		_xp_fill.size.x = 0.0
		_level.text = T.t(&"hud_room", {"n": game.rooms.depth(), "of": game.rooms.stage.rooms + 1})
		_kills.text = "%s  %d" % [T.t(&"hud_gold"), game.rooms.gold]
	else:
		_xp_fill.size.x = w * game.xp_ratio()
		_level.text = T.t(&"hud_level", {"n": game.level})
		_kills.text = "%s  %d" % [T.t(&"hud_kills"), game.kills]
	var ratio := clampf(p.hp / p.max_hp, 0.0, 1.0)
	_hp_shown = move_toward(_hp_shown, ratio, delta * 0.5) if _hp_shown > ratio else ratio
	_hp_fill.size = Vector2(340 * ratio, 26)
	(_hp_back.get_node("Lag") as ColorRect).size = Vector2(340 * _hp_shown, 26)
	_hp_text.text = "%d / %d" % [ceili(p.hp), roundi(p.max_hp)]
	_update_dodges(p)
	_magick_fill.size = Vector2(340 * p.magick.ratio(), 8)
	_cast.color = CAST_READY if p.cast_cooldown <= 0.0 else CAST_WAIT
	var b := game.boss_enemy()
	_boss_box.visible = b != null
	if b:
		_boss_name.text = T.t(b.def.name_key)
		_boss_fill.size = Vector2(640 * clampf(b.hp / b.max_hp, 0.0, 1.0), 14)
		_boss_armor.size = Vector2(640 * (b.armor / b.max_armor if b.max_armor > 0.0 else 0.0), 6)
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
		pip.custom_minimum_size = Vector2(36, 8)
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
			_icons.add_child(BoonIcon.new().setup(b, 52))
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
