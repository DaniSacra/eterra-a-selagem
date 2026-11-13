class_name UiKit
extends RefCounted
## One look for every screen: the grid font, palette colours, flat one-pixel borders. No gradients, no rounding.

const FONT: Font = preload("res://art/fonts/eterra.fnt")
const SIZE := 11
const BIG := 22

static var _theme: Theme


static func theme() -> Theme:
	if _theme != null:
		return _theme
	var t := Theme.new()
	t.default_font = FONT
	t.default_font_size = SIZE
	var night := Palette.c(&"noite", 4)
	t.set_stylebox(&"normal", &"Button", box(night, Palette.c(&"noite", 2)))
	t.set_stylebox(&"hover", &"Button", box(Palette.c(&"noite", 3), Palette.c(&"luz", 2)))
	t.set_stylebox(&"pressed", &"Button", box(Palette.c(&"noite", 3), Palette.c(&"luz", 0)))
	t.set_stylebox(&"disabled", &"Button", box(night, Palette.c(&"noite", 3)))
	var focus := box(Color.TRANSPARENT, Palette.c(&"luz", 0))
	focus.draw_center = false
	t.set_stylebox(&"focus", &"Button", focus)
	t.set_color(&"font_color", &"Button", Palette.c(&"neve", 1))
	t.set_color(&"font_hover_color", &"Button", Palette.c(&"luz", 0))
	t.set_color(&"font_focus_color", &"Button", Palette.c(&"luz", 0))
	t.set_color(&"font_pressed_color", &"Button", Palette.c(&"luz", 0))
	t.set_color(&"font_disabled_color", &"Button", Palette.c(&"neve", 4))
	t.set_stylebox(&"panel", &"PanelContainer", box(Color(Color.html("#141018"), 0.95), Palette.c(&"luz", 3), 1, 6))
	t.set_color(&"font_color", &"Label", Palette.c(&"neve", 0))
	t.set_constant(&"line_spacing", &"Label", 0)
	t.set_constant(&"separation", &"VBoxContainer", 3)
	t.set_constant(&"separation", &"HBoxContainer", 4)
	_theme = t
	return t


static func box(bg: Color, border: Color, width: int = 1, margin: int = 3) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = bg
	s.border_color = border
	s.set_border_width_all(width)
	s.set_content_margin_all(margin)
	s.anti_aliasing = false
	return s


static func label(text: String, color: Color = Palette.c(&"neve", 0), size: int = SIZE) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_color_override(&"font_color", color)
	l.add_theme_font_size_override(&"font_size", size)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l


## A button that takes focus when the mouse touches it, so mouse, keys and gamepad always agree.
static func button(text: String, on_press: Callable = Callable()) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(0, 17)
	b.mouse_entered.connect(func() -> void:
		if not b.disabled:
			b.grab_focus())
	b.focus_entered.connect(func() -> void: Audio.play(&"ui_move"))
	if on_press.is_valid():
		b.pressed.connect(func() -> void:
			Audio.play(&"ui_ok")
			on_press.call())
	return b


## Dark veil behind a screen.
static func veil(alpha: float = 0.62) -> ColorRect:
	var r := ColorRect.new()
	r.color = Color(Color.html("#060408"), alpha)
	r.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	return r


## Root for a full-screen menu: themed, covering the view, with a veil.
static func screen(alpha: float = 0.62) -> Control:
	var c := Control.new()
	c.theme = theme()
	c.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	c.add_child(veil(alpha))
	return c


## A panel centred on the screen holding a column of things.
static func column(parent: Control, min_width: float = 120.0) -> VBoxContainer:
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	parent.add_child(center)
	var panel := PanelContainer.new()
	center.add_child(panel)
	var v := VBoxContainer.new()
	v.custom_minimum_size.x = min_width
	panel.add_child(v)
	return v


static func icon(frame: int) -> TextureRect:
	var at := AtlasTexture.new()
	at.atlas = Art.tex(&"icons")
	var s := Art.size(&"icons")
	at.region = Rect2(frame * s.x, 0, s.x, s.y)
	var r := TextureRect.new()
	r.texture = at
	r.stretch_mode = TextureRect.STRETCH_KEEP
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return r


## Description of a gift at a level, with its numbers written the Brazilian way.
static func boon_desc(b: Boon, level: int) -> String:
	var args := {}
	var keys := ["a", "b", "c"]
	for i in mini(b.mods.size(), keys.size()):
		args[keys[i]] = BoonMod.format(b.mods[i].stat, b.mods[i].value(level))
	return T.t("boon_%s_desc" % b.id, args)
