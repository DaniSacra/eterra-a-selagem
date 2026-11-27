class_name MouseGlyphArt
extends RefCounted
## The pixels of MouseGlyph (no autoloads, so tools/make_mouse_icons.gd can run it as a plain script).

const W := 18.0
const H := 26.0
## The icon is saved at SCALE times its size in the UI, each pixel sampled SAMPLES x SAMPLES times.
const SCALE := 3
const SAMPLES := 4
## The bound button: a strong gold, so left and right read apart at 28 px (the rest of the body stays dark).
const LIT := Color(1.0, 0.8, 0.18)
## HUD v3 (2026-11-27): the rim of the slots' mice is pale and the lit button says the gesture: white = a click (tap), gold = a hold.
## DEFAULT is the gold-rimmed icon of the cards, tips and menus.
enum Style { DEFAULT, TAP, HOLD }
const TAP_LIT := Color(1.0, 0.99, 0.94)
const PALE_RIM := Color(0.93, 0.9, 0.82)
const OLD_RIM := Color("8e7444")


## The drawing: ink body under an old gold rim, the bound button in ivory, the seams in old gold.
static func rasterize(button: int, style: Style = Style.DEFAULT) -> Image:
	var img := Image.create(int(W) * SCALE, int(H) * SCALE, false, Image.FORMAT_RGBA8)
	for y in img.get_height():
		for x in img.get_width():
			var sum := Color(0, 0, 0, 0)
			for sy in SAMPLES:
				for sx in SAMPLES:
					var p := Vector2(x + (sx + 0.5) / SAMPLES, y + (sy + 0.5) / SAMPLES) / SCALE
					var c := _shade(p, button, style)
					sum += Color(c.r * c.a, c.g * c.a, c.b * c.a, c.a)
			var a := sum.a / (SAMPLES * SAMPLES)
			img.set_pixel(x, y, Color(sum.r / (SAMPLES * SAMPLES) / a, sum.g / (SAMPLES * SAMPLES) / a,
					sum.b / (SAMPLES * SAMPLES) / a, a) if a > 0.0 else Color(0, 0, 0, 0))
	return img


## The colour of the point p (in the W x H box) for the lit button.
static func _shade(p: Vector2, button: int, style: Style = Style.DEFAULT) -> Color:
	var rim := 2.2
	var line := OLD_RIM if style == Style.DEFAULT else PALE_RIM
	var d := _rounded_box(p - Vector2(W, H) * 0.5, Vector2(W, H) * 0.5, 8.0)
	if d > 0.0:
		return Color(0, 0, 0, 0)
	if d > -rim:
		return line
	var split := rim + 10.0
	var mid := W * 0.5
	var lit := false
	match button:
		MOUSE_BUTTON_LEFT:
			lit = p.y < split and p.x < mid - 0.5
		MOUSE_BUTTON_RIGHT:
			lit = p.y < split and p.x > mid + 0.5
		MOUSE_BUTTON_MIDDLE:
			lit = absf(p.x - mid) < 2.0 and p.y > rim + 1.5 and p.y < rim + 8.0
	if lit:
		return TAP_LIT if style == Style.TAP else LIT
	if (absf(p.x - mid) < 0.5 and p.y < split) or absf(p.y - split) < 0.5:
		return line
	return Color(0.03, 0.025, 0.04, 0.97)


## Signed distance to a box (half size `half`) with rounded corners of radius r: negative inside.
static func _rounded_box(p: Vector2, half: Vector2, r: float) -> float:
	var q := p.abs() - half + Vector2(r, r)
	return Vector2(maxf(q.x, 0.0), maxf(q.y, 0.0)).length() + minf(maxf(q.x, q.y), 0.0) - r
