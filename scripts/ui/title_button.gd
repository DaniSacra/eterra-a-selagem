class_name TitleButton
extends BaseButton
## One button of the title menu, drawn in vectors exactly over the painted one it replaces.
## Every measure is in pixels of the title art (docs/art/title_screen_spec.md); `place` gives the art's origin and scale.

enum Kind { START, HERO, HOWTO, SETTINGS, QUIT }

## Frame of each button in the art, and the horizontal run of its slanted ends. The painting had three small buttons
## 71 px apart; with "O Guerreiro" (E2-06) there are four, 52 px tall and 62 px apart, from just under Iniciar, so the
## column still ends on the dark band of the clean art (docs/art/title_screen_spec.md).
const SMALL_TOP := 506.0
const SMALL_HEIGHT := 52.0
const SMALL_STEP := 62.0
const FRAMES: Dictionary[Kind, Rect2] = {
	Kind.START: Rect2(926, 401, 449, 89),
	Kind.HERO: Rect2(1008, SMALL_TOP, 286, SMALL_HEIGHT),
	Kind.HOWTO: Rect2(1008, SMALL_TOP + SMALL_STEP, 286, SMALL_HEIGHT),
	Kind.SETTINGS: Rect2(1008, SMALL_TOP + SMALL_STEP * 2.0, 286, SMALL_HEIGHT),
	Kind.QUIT: Rect2(1008, SMALL_TOP + SMALL_STEP * 3.0, 286, SMALL_HEIGHT),
}
const CUT_START := 51.0
const CUT_SMALL := 25.0
const TEXT_KEYS: Dictionary[Kind, StringName] = {
	Kind.START: &"title_start", Kind.HERO: &"title_hero", Kind.HOWTO: &"title_howto", Kind.SETTINGS: &"title_settings",
	Kind.QUIT: &"title_quit",
}
## Left edge of the ink and baseline of each label, and the font size, in the art (the small ones: TEXT_X, and the
## baseline TEXT_DROP under the frame's top).
const TEXT_AT: Dictionary[Kind, Vector2] = {
	Kind.START: Vector2(1117, 462),
}
const TEXT_X := 1115.0
const TEXT_DROP := 35.5
const FONT_START := 51.0
const FONT_SMALL := 26.0
## Centre of each icon (the small ones: ICON_X, in the middle of the frame).
const ICON_AT: Dictionary[Kind, Vector2] = {
	Kind.START: Vector2(1072, 447),
}
const ICON_X := 1070.5

# Iniciar
const GOLD := Color("ffca46")
const GOLD_LIGHT := Color("fdf9c9")
const GOLD_DEEP := Color("fcaf11")
const GOLD_SHADE := Color("cf6e0b")
const CORE := Color("331e0e")
const CORE_TOP := Color("572f0d")
const GLARE := Color("c86702")
const EMBER := Color("ff9a1f")
const START_TEXT := Color("f0e8ce")
const START_SHADOW := Color("2a1405")
const PLAY := Color("fbde97")
const PLAY_LIGHT := Color("f9eed0")
const GEM := Color("b0ccbf")
const GEM_LIT := Color("e8fff4")
const START_OFF_FRAME := Color("6b5a3a")
const START_OFF_TEXT := Color("8a8478")
# the three small ones
const LINE := Color("675b4c")
const LINE_OFF := Color("3a3530")
const FILL := Color(0.075, 0.075, 0.094, 0.94)
const FILL_HOT := Color(0.118, 0.082, 0.047, 0.96)
const FILL_DOWN := Color(0.165, 0.102, 0.039, 0.96)
const ICON := Color("b8a488")
const OFF := Color("6f6a70")
const RING := Color(1.0, 0.949, 0.722, 0.9)

## Pulse of the amber glow of Iniciar: (low, high, period in seconds), at rest and with focus.
const PULSE_REST := Vector3(0.76, 1.0, 2.4)
const PULSE_HOT := Vector3(0.9, 1.15, 1.6)
const HOVER_TIME := 0.12
const PRESS_TIME := 0.08
const GLOW_MARGIN := 22.0
## Iniciar's dark heart: height of the warm band under the top frame and of the amber glare over the bottom one.
const CORE_BAND := 16.0
const GLARE_BAND := 15.0

const GLOW_CODE := "shader_type canvas_item;
render_mode blend_add, unshaded;
uniform vec2 half_size = vec2(100.0, 20.0);
uniform float cut = 25.0;
uniform float margin = 22.0;
uniform float reach = 3.7;
uniform vec3 tint : source_color = vec3(1.0, 0.6, 0.12);
uniform float power = 1.0;
void fragment() {
	vec2 p = abs((UV - 0.5) * 2.0 * (half_size + margin));
	vec2 n = normalize(vec2(half_size.y, cut));
	float d = max(p.y - half_size.y, dot(vec2(p.x - half_size.x, p.y), n));
	float g = exp(-max(d, 0.0) / reach) * smoothstep(margin, margin * 0.45, d) * smoothstep(-3.0, -1.0, d);
	COLOR = vec4(tint * g * power, 1.0);
}"

static var _glow_shader: Shader

var kind := Kind.START
## Keyboard and gamepad ring: the menu turns it on after the first navigation command.
var show_ring := false:
	set(v):
		show_ring = v
		queue_redraw()
## A disabled button keeps its look (locked during a transition) unless this is on (the grey state of the spec).
var greyed := false:
	set(v):
		greyed = v
		queue_redraw()
## Entrance: 0 = hidden and `rise` units below its place, 1 = in place.
var appear := 1.0:
	set(v):
		appear = v
		modulate.a = clampf(v, 0.0, 1.0)
		queue_redraw()
var rise := 6.0

var _scale := 1.0
var _hex: PackedVector2Array
var _insets: Dictionary[float, PackedVector2Array] = {}
var _core_top: PackedVector2Array
var _core: PackedVector2Array
var _glare: PackedVector2Array
var _glow: ColorRect
var _glow_mat: ShaderMaterial
var _hot := 0.0
var _press := 0.0
var _time := 0.0
var _text := ""


func _init(p_kind: Kind = Kind.START) -> void:
	kind = p_kind
	focus_mode = Control.FOCUS_ALL
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_hex = hexagon(frame(), cut())
	if kind == Kind.START:
		var inner := inset(7.0)
		_core = inner
		_core_top = _clip(inner, Rect2(frame().position, Vector2(frame().size.x, 7.0 + CORE_BAND)))
		_glare = _clip(inner, Rect2(frame().position.x, frame().end.y - 7.0 - GLARE_BAND, frame().size.x, 7.0 + GLARE_BAND))


func _ready() -> void:
	_text = T.t(TEXT_KEYS[kind])
	if _glow_shader == null:
		_glow_shader = Shader.new()
		_glow_shader.code = GLOW_CODE
	_glow_mat = ShaderMaterial.new()
	_glow_mat.shader = _glow_shader
	_glow_mat.set_shader_parameter(&"half_size", frame().size * 0.5)
	_glow_mat.set_shader_parameter(&"cut", cut())
	_glow_mat.set_shader_parameter(&"margin", GLOW_MARGIN)
	_glow_mat.set_shader_parameter(&"reach", 3.7 if kind == Kind.START else 2.6)
	_glow_mat.set_shader_parameter(&"tint", EMBER)
	_glow = ColorRect.new()
	_glow.material = _glow_mat
	_glow.show_behind_parent = true
	_glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_glow)
	mouse_entered.connect(func() -> void:
		if not disabled and not has_focus():
			grab_focus())
	pressed.connect(func() -> void: _press = PRESS_TIME)
	focus_entered.connect(queue_redraw)
	focus_exited.connect(queue_redraw)
	_update_glow()


func frame() -> Rect2:
	return FRAMES[kind]


func text_at() -> Vector2:
	return TEXT_AT[kind] if TEXT_AT.has(kind) else Vector2(TEXT_X, frame().position.y + TEXT_DROP)


func icon_at() -> Vector2:
	return ICON_AT[kind] if ICON_AT.has(kind) else Vector2(ICON_X, frame().get_center().y)


func cut() -> float:
	return CUT_START if kind == Kind.START else CUT_SMALL


## Puts the button over its painted place: `origin` is where the art's corner sits in the parent, `art_scale` its scale.
func place(origin: Vector2, art_scale: float) -> void:
	_scale = maxf(art_scale, 0.01)
	position = origin + frame().position * _scale
	size = frame().size * _scale
	if _glow:
		_glow.position = -Vector2.ONE * GLOW_MARGIN * _scale
		_glow.size = (frame().size + Vector2.ONE * GLOW_MARGIN * 2.0) * _scale
	queue_redraw()


## Lit: under the mouse or holding the focus (the same look, so mouse, keys and gamepad agree).
func is_hot() -> bool:
	return not disabled and (has_focus() or is_hovered())


func is_down() -> bool:
	return not disabled and (_press > 0.0 or get_draw_mode() == DRAW_PRESSED or get_draw_mode() == DRAW_HOVER_PRESSED)


## Jumps the hover animation to its end (captures, and a menu shown without the entrance).
func settle() -> void:
	_hot = 1.0 if is_hot() else 0.0
	_update_glow()
	queue_redraw()


## Elongated hexagon inside `r`: the tips in the middle of the short sides, `p_cut` in from each corner.
static func hexagon(r: Rect2, p_cut: float) -> PackedVector2Array:
	var cy := r.get_center().y
	return PackedVector2Array([
		Vector2(r.position.x, cy), Vector2(r.position.x + p_cut, r.position.y), Vector2(r.end.x - p_cut, r.position.y),
		Vector2(r.end.x, cy), Vector2(r.end.x - p_cut, r.end.y), Vector2(r.position.x + p_cut, r.end.y)])


## The frame's hexagon moved `d` art pixels inwards (outwards when negative), sides kept parallel.
func inset(d: float) -> PackedVector2Array:
	if not _insets.has(d):
		var out := Geometry2D.offset_polygon(_hex, -d, Geometry2D.JOIN_MITER)
		_insets[d] = out[0] if not out.is_empty() else _hex
	return _insets[d]


func _has_point(point: Vector2) -> bool:
	return Geometry2D.is_point_in_polygon(point / _scale + frame().position, _hex)


func _process(delta: float) -> void:
	_time += delta
	var was := _hot
	var was_down := _press > 0.0
	_hot = move_toward(_hot, 1.0 if is_hot() else 0.0, delta / HOVER_TIME)
	_press = maxf(_press - delta, 0.0)
	if kind == Kind.START or was != _hot or was_down:
		_update_glow()
		queue_redraw()


## Strength of the amber light of Iniciar now (glow outside, glare inside).
func _pulse() -> float:
	if disabled and greyed:
		return 0.0
	var p := PULSE_REST.lerp(PULSE_HOT, _hot)
	var k := lerpf(p.x, p.y, 0.5 + 0.5 * sin(_time * TAU / p.z))
	return k * (0.6 if is_down() else 1.0)


func _update_glow() -> void:
	if _glow_mat == null:
		return
	var power := 1.6 * _pulse() if kind == Kind.START else 0.75 * _hot * (0.0 if disabled else 1.0)
	_glow_mat.set_shader_parameter(&"power", power * clampf(appear, 0.0, 1.0))
	_glow.visible = power > 0.001


func _draw() -> void:
	var shift := Vector2(0.0, (1.0 if is_down() else 0.0) + rise * (1.0 - clampf(appear, 0.0, 1.0)))
	draw_set_transform(shift - frame().position * _scale, 0.0, Vector2(_scale, _scale))
	if kind == Kind.START:
		_draw_start()
	else:
		_draw_small()
	if show_ring and has_focus() and not disabled:
		var ring := inset(-(3.0 + 1.0) / _scale)
		draw_polyline(_closed(ring), RING, 2.0 / _scale, true)
	_draw_label(shift)


func _draw_start() -> void:
	var off := disabled and greyed
	var gold := START_OFF_FRAME if off else GOLD
	var shade := START_OFF_FRAME.darkened(0.35) if off else GOLD_SHADE
	var dark := 0.85 if is_down() else 1.0
	_fill(_hex, shade)
	_fill(inset(1.0), gold)
	if not off:
		draw_polyline(_closed(inset(2.2)), GOLD_LIGHT, 1.4, true)
		draw_polyline(_closed(inset(5.4)), GOLD_DEEP, 2.2, true)
	# dark heart: warmer under the top band, darkest in the middle
	var top := Color(CORE_TOP.r * dark, CORE_TOP.g * dark, CORE_TOP.b * dark)
	var core := Color(CORE.r * dark, CORE.g * dark, CORE.b * dark)
	if off:
		top = Color("2a2622")
		core = Color("1c1a18")
	draw_colored_polygon(_core, core)
	_fill_v(_core_top, top, core, frame().position.y + 7.0, frame().position.y + 7.0 + CORE_BAND)
	var glare := GLARE
	glare.a = clampf(0.85 * _pulse(), 0.0, 1.0)
	if glare.a > 0.0:
		_fill_v(_glare, Color(glare, 0.0), glare, frame().end.y - 7.0 - GLARE_BAND, frame().end.y - 7.0)
	draw_polyline(_closed(inset(7.0)), shade, 1.2, true)
	draw_polyline(_closed(inset(12.0)), Color(gold, 0.55), 1.0, true)
	# the diamonds of the tips, each with its gem
	var gem := START_OFF_TEXT if off else GEM.lerp(GEM_LIT, _hot)
	for x: float in [952.0, 1349.0]:
		var c := Vector2(x, 446.0)
		_fill(_star(c, 24.0, 11.0), shade)
		_fill(_star(c, 22.8, 10.3), gold)
		if not off:
			draw_polyline(_closed(_star(c, 21.0, 9.4)), GOLD_LIGHT, 1.2, true)
		_fill(_star(c, 15.5, 7.2), shade)
		_fill(_star(c, 14.0, 6.4), core)
		_fill(_star(c, 9.0, 3.0), gem)
		_fill(_star(c, 4.5, 1.4), gem.lightened(0.25))
	# play triangle, the upper facet lighter
	var a := Vector2(1056, 428)
	var b := Vector2(1056, 466)
	var tip := Vector2(1088, 447)
	var play := START_OFF_TEXT if off else PLAY
	_fill(PackedVector2Array([a, tip, b]), play)
	if not off:
		_fill(PackedVector2Array([a, tip, Vector2(1066, 447)]), PLAY_LIGHT)


func _draw_small() -> void:
	var off := disabled and greyed
	var fade := 0.6 if off else 1.0
	var fill := FILL.lerp(FILL_HOT, _hot)
	if is_down():
		fill = FILL_DOWN
	var line := LINE_OFF if off else LINE.lerp(GOLD, _hot)
	var icon := OFF if off else ICON.lerp(GOLD, _hot)
	# the fill never fades: it has to keep hiding whatever is left of the painted button
	line.a *= fade
	icon.a *= fade
	draw_colored_polygon(_hex, fill)
	draw_polyline(_closed(inset(0.9)), line, 1.8, true)
	draw_polyline(_closed(inset(5.5)), Color(line, line.a * 0.28), 1.0, true)
	var cy := frame().get_center().y
	for x: float in [frame().position.x + 12.5, frame().end.x - 12.5]:
		_fill(_star(Vector2(x, cy), 3.8, 1.2), Color(line, line.a * 0.8))
	var c := icon_at()
	var paper := Color(fill, 1.0)
	match kind:
		Kind.HERO:
			_draw_sword(c, icon)
		Kind.HOWTO:
			_draw_book(c, icon, paper)
		Kind.SETTINGS:
			_draw_gear(c, icon)
		Kind.QUIT:
			_draw_power(c, icon)


## An upright sword, 18 x 36: a blade with its point and middle line, the guard, the grip and the pommel.
func _draw_sword(c: Vector2, color: Color) -> void:
	_fill(PackedVector2Array([c + Vector2(0.0, -18.0), c + Vector2(3.6, -12.0), c + Vector2(3.0, 7.0),
		c + Vector2(-3.0, 7.0), c + Vector2(-3.6, -12.0)]), color)
	draw_line(c + Vector2(0.0, -13.0), c + Vector2(0.0, 5.0), Color(0, 0, 0, 0.35), 1.0, true)
	_fill(PackedVector2Array([c + Vector2(-9.5, 7.0), c + Vector2(9.5, 7.0), c + Vector2(8.0, 10.2),
		c + Vector2(-8.0, 10.2)]), color)
	draw_rect(Rect2(c + Vector2(-1.8, 10.2), Vector2(3.6, 6.4)), color)
	_fill(_star(c + Vector2(0.0, 18.2), 2.8, 1.4), color)


## Open book, 37 x 28: two pages with three lines each, the cover showing under them.
func _draw_book(c: Vector2, color: Color, paper: Color) -> void:
	for side: float in [-1.0, 1.0]:
		var m := Vector2(side, 1.0)
		_fill(PackedVector2Array([
			c + Vector2(1.3, -10.0) * m, c + Vector2(4.5, -12.2) * m, c + Vector2(10.0, -13.2) * m,
			c + Vector2(16.0, -12.6) * m, c + Vector2(16.0, 8.0) * m, c + Vector2(10.0, 7.4) * m,
			c + Vector2(4.5, 8.4) * m, c + Vector2(1.3, 10.4) * m]), color)
		for y: float in [-6.6, -1.6, 3.4]:
			draw_line(c + Vector2(5.0, y) * m, c + Vector2(12.6, y - 0.6) * m, paper, 1.8, true)
	draw_polyline(PackedVector2Array([
		c + Vector2(-18.0, -10.0), c + Vector2(-18.0, 11.0), c + Vector2(-3.5, 11.0), c + Vector2(0.0, 13.4),
		c + Vector2(3.5, 11.0), c + Vector2(18.0, 11.0), c + Vector2(18.0, -10.0)]), color, 1.8, true)


## Gear, 35 x 35: eight straight teeth, the hole 40% of the diameter.
func _draw_gear(c: Vector2, color: Color) -> void:
	draw_arc(c, 10.0, 0.0, TAU, 40, color, 6.0, true)
	for i in 8:
		var dir := Vector2.from_angle(i * TAU / 8.0 - PI * 0.5)
		var side := dir.orthogonal()
		_fill(PackedVector2Array([
			c + dir * 11.5 - side * 4.1, c + dir * 17.5 - side * 3.1, c + dir * 17.5 + side * 3.1,
			c + dir * 11.5 + side * 4.1]), color)


## Power sign, 31 x 34: an arc of 300 degrees open at the top and a stroke from the middle up through the gap.
func _draw_power(c: Vector2, color: Color) -> void:
	var o := c + Vector2(0.0, 1.6)
	draw_arc(o, 13.4, deg_to_rad(-90.0 + 30.0), deg_to_rad(270.0 - 30.0), 40, color, 4.2, true)
	draw_line(c + Vector2(0.0, -17.0), c + Vector2(0.0, 0.5), color, 4.2, true)


func _draw_label(shift: Vector2) -> void:
	# text at its real size (a scaled transform would blur the glyphs), left edge and baseline from the art
	draw_set_transform(shift, 0.0, Vector2.ONE)
	var font := UiKit.BOLD_FONT
	var start := kind == Kind.START
	var font_size := maxi(roundi((FONT_START if start else FONT_SMALL) * _scale), 1)
	var at := (text_at() - frame().position) * _scale
	# measured on captures: the first glyph's side bearing (the spec gives the left edge of the ink) and the
	# rounding of the baseline, in art pixels
	at += Vector2(-3.6 if start else -1.0, 1.2) * _scale
	var off := disabled and greyed
	var color := START_TEXT
	if start:
		if off:
			color = START_OFF_TEXT
		else:
			draw_string(font, at + Vector2(0.0, 2.0 * _scale), _text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, START_SHADOW)
	else:
		color = Color(OFF, 0.6) if off else UiKit.PARCHMENT.lerp(START_TEXT, _hot)
	draw_string(font, at, _text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, color)


## Four pointed star (a diamond with hollow sides): `tip` to each point, `waist` to the middle of each side.
static func _star(c: Vector2, tip: float, waist: float) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in 4:
		var dir := Vector2.from_angle(i * PI * 0.5)
		pts.append(c + dir * tip)
		pts.append(c + dir.rotated(PI * 0.25) * waist * sqrt(2.0))
	return pts


static func _closed(poly: PackedVector2Array) -> PackedVector2Array:
	var out := poly.duplicate()
	out.append(poly[0])
	return out


static func _clip(poly: PackedVector2Array, r: Rect2) -> PackedVector2Array:
	var box := PackedVector2Array([r.position, Vector2(r.end.x, r.position.y), r.end, Vector2(r.position.x, r.end.y)])
	var out := Geometry2D.intersect_polygons(poly, box)
	return out[0] if not out.is_empty() else PackedVector2Array()


## Filled shape with a smooth edge (polygons are not antialiased; a thin line of the same colour is).
func _fill(poly: PackedVector2Array, color: Color) -> void:
	if Geometry2D.triangulate_polygon(poly).is_empty():
		return
	draw_colored_polygon(poly, color)
	draw_polyline(_closed(poly), color, 0.8, true)


## Filled shape with a vertical gradient from `a` at `y0` to `b` at `y1`.
func _fill_v(poly: PackedVector2Array, a: Color, b: Color, y0: float, y1: float) -> void:
	if poly.size() < 3:
		return
	var colors := PackedColorArray()
	for p in poly:
		colors.append(a.lerp(b, clampf(inverse_lerp(y0, y1, p.y), 0.0, 1.0)))
	draw_polygon(poly, colors)
