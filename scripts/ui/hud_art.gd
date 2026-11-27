class_name HudArt
extends RefCounted
## HUD v3 (2026-11-27): the painted kit of the run's HUD lives in assets/ui/hud_v3/<name>.png (icon_attack, icon_smash, icon_power,
## icon_lance, icon_dodge, icon_supreme, frame_slot, frame_supreme, frame_portrait, bar_frame, bar_icon_life, bar_icon_magic,
## bar_icon_supreme, cartouche, divider, portrait_warrior). Every piece is optional: tex() gives null while the file is missing and
## the HUD draws its own (a dark panel in a gold rim, the glyphs below), so it works before the art lands and with any subset.
## The glyphs are drawn on any CanvasItem during its _draw: centre c, radius r, colour w. No sun, no many-pointed star.
##   HudArt.draw_icon(self, &"icon_smash", c, r)      # the picture, or the drawn one
##   HudArt.tex(&"cartouche")                          # Texture2D or null

const DIR := "res://assets/ui/hud_v3/"
## The names of the pieces (tests read the list).
const NAMES: Array[StringName] = [&"icon_attack", &"icon_smash", &"icon_power", &"icon_lance", &"icon_dodge", &"icon_supreme",
	&"frame_slot", &"frame_supreme", &"frame_portrait", &"bar_frame", &"bar_icon_life", &"bar_icon_magic", &"bar_icon_supreme",
	&"cartouche", &"divider", &"portrait_warrior"]
const EMETH := Color(0.45, 0.95, 0.7)
const MAGIC_BLUE := Color("2a8fb8")
const ICON_COLORS := {&"icon_attack": Color(1.0, 0.8, 0.4), &"icon_smash": Color(1.0, 0.72, 0.3), &"icon_power": Color(1.0, 0.76, 0.34),
	&"icon_lance": Color(0.5, 0.95, 0.68), &"icon_dodge": Color(0.94, 0.9, 0.82), &"icon_supreme": Color(1.0, 0.82, 0.4)}

static var _cache := {}


## The picture of a piece, null while its file is not there (loaded once).
static func tex(piece: StringName) -> Texture2D:
	if not _cache.has(piece):
		var path := DIR + String(piece) + ".png"
		_cache[piece] = load(path) if ResourceLoader.exists(path) else null
	return _cache[piece]


## Forgets what was looked up (tests, and a kit that lands while the game runs).
static func reload() -> void:
	_cache.clear()


## A picture centred at c filling a square of half size r.
static func draw_tex(ci: CanvasItem, t: Texture2D, c: Vector2, r: float) -> void:
	ci.draw_texture_rect(t, Rect2(c - Vector2(r, r), Vector2(r, r) * 2.0), false)


## The icon of a piece: its picture when the file exists, else the drawn glyph in the piece's colour.
static func draw_icon(ci: CanvasItem, piece: StringName, c: Vector2, r: float, tint: Color = Color.WHITE) -> void:
	var t := tex(piece)
	if t != null:
		ci.draw_texture_rect(t, Rect2(c - Vector2(r, r), Vector2(r, r) * 2.0), false, tint)
		return
	var col: Color = ICON_COLORS.get(piece, UiKit.PALE)
	col *= tint
	match piece:
		&"icon_attack":
			slash(ci, c, r, col)
		&"icon_smash":
			burst(ci, c, r, col)
		&"icon_power":
			swirl(ci, c, r, col)
		&"icon_lance":
			lance(ci, c, r, col)
		&"icon_dodge":
			BoonIcon.glyph(ci, BoonIcon.ACTION_GLYPH + Boon.Slot.DASH, c, r * 0.95, col, UiKit.INK)
		&"icon_supreme":
			lion(ci, c, r, col)
		_:
			ci.draw_circle(c, r * 0.4, col)


## Three tapered cuts running down to the left.
static func slash(ci: CanvasItem, c: Vector2, r: float, w: Color) -> void:
	for k in 3:
		var o := Vector2(0.3, 0.3).normalized() * (k - 1) * r * 0.5
		var a := c + o + Vector2(r * 0.72, -r * 0.72) * (1.0 - absf(k - 1) * 0.12)
		var b := c + o - Vector2(r * 0.72, -r * 0.72) * (1.0 - absf(k - 1) * 0.12)
		var n := Vector2(0.7, 0.7) * r * (0.1 if k == 1 else 0.07)
		ci.draw_colored_polygon(PackedVector2Array([a, b + n, b - n * 0.2, b, c + o + n * 0.4]), w)
		ci.draw_polyline(PackedVector2Array([a, c + o, b]), w, maxf(1.5, r * 0.09), true)


## An impact: a diamond core with four shards thrown out of it (never a many-pointed star).
static func burst(ci: CanvasItem, c: Vector2, r: float, w: Color) -> void:
	for k in 4:
		var d := Vector2.from_angle(TAU * k / 4.0 + PI * 0.25)
		var n := d.orthogonal() * r * 0.16
		ci.draw_colored_polygon(PackedVector2Array([c + d * r * 0.3 + n, c + d * r * 0.95, c + d * r * 0.3 - n]), w)
	var h := r * 0.34
	ci.draw_colored_polygon(PackedVector2Array([c + Vector2(0, -h), c + Vector2(h, 0), c + Vector2(0, h), c + Vector2(-h, 0)]), w.lightened(0.45))
	ci.draw_arc(c, r * 0.62, 0.0, TAU, 24, Color(w, 0.55), maxf(1.5, r * 0.08), true)


## A spiral of light: the arc that opens as it turns, an arrow head on its end.
static func swirl(ci: CanvasItem, c: Vector2, r: float, w: Color) -> void:
	var pts := PackedVector2Array()
	for i in 21:
		var t := float(i) / 20.0
		pts.append(c + Vector2.from_angle(PI * 0.3 + t * TAU * 1.05) * r * (0.22 + 0.7 * t))
	ci.draw_polyline(pts, w, maxf(2.0, r * 0.2), true)
	var tip := pts[pts.size() - 1]
	var d := (tip - pts[pts.size() - 3]).normalized()
	ci.draw_colored_polygon(PackedVector2Array([tip + d * r * 0.22, tip + d.orthogonal() * r * 0.2, tip - d.orthogonal() * r * 0.2]), w)


## An arrow of Emeth driving up and to the right, a trail behind it.
static func lance(ci: CanvasItem, c: Vector2, r: float, w: Color) -> void:
	var d := Vector2(1, -1).normalized()
	var n := d.orthogonal()
	var tip := c + d * r * 0.98
	ci.draw_line(c - d * r * 0.85, tip - d * r * 0.2, w, maxf(2.0, r * 0.16), true)
	ci.draw_colored_polygon(PackedVector2Array([tip, tip - d * r * 0.6 + n * r * 0.3, tip - d * r * 0.6 - n * r * 0.3]), w.lightened(0.25))
	for k in [-1.0, 1.0]:
		ci.draw_line(c - d * r * 0.85 + n * k * r * 0.28, c - d * r * 0.3 + n * k * r * 0.28, Color(w, 0.55), maxf(1.5, r * 0.09), true)


## The lion of the Warrior, seen from the front: a mane of round tufts around a face with eyes and a nose.
static func lion(ci: CanvasItem, c: Vector2, r: float, w: Color) -> void:
	var dark := UiKit.INK
	for k in 12:
		ci.draw_circle(c + Vector2.from_angle(TAU * k / 12.0) * r * 0.62, r * 0.27, w.darkened(0.12))
	ci.draw_circle(c, r * 0.64, w)
	ci.draw_circle(c + Vector2(0, r * 0.1), r * 0.5, w.lightened(0.18))
	for s in [-1.0, 1.0]:
		ci.draw_circle(c + Vector2(r * 0.6 * s, -r * 0.5), r * 0.15, w.darkened(0.2))
		ci.draw_colored_polygon(PackedVector2Array([c + Vector2(r * 0.12 * s, -r * 0.12), c + Vector2(r * 0.34 * s, -r * 0.22),
			c + Vector2(r * 0.3 * s, -r * 0.04)]), dark)
	ci.draw_colored_polygon(PackedVector2Array([c + Vector2(-r * 0.14, r * 0.12), c + Vector2(r * 0.14, r * 0.12), c + Vector2(0, r * 0.3)]), dark)
	ci.draw_polyline(PackedVector2Array([c + Vector2(0, r * 0.3), c + Vector2(0, r * 0.42), c + Vector2(-r * 0.2, r * 0.5)]), dark, maxf(1.0, r * 0.07), true)
	ci.draw_polyline(PackedVector2Array([c + Vector2(0, r * 0.42), c + Vector2(r * 0.2, r * 0.5)]), dark, maxf(1.0, r * 0.07), true)


## An hourglass, centred at c, k tall (half).
static func hourglass(ci: CanvasItem, c: Vector2, k: float, col: Color) -> void:
	var w := k * 0.62
	ci.draw_colored_polygon(PackedVector2Array([c + Vector2(-w, -k), c + Vector2(w, -k), c + Vector2(k * 0.08, 0), c + Vector2(w, k), c + Vector2(-w, k),
		c + Vector2(-k * 0.08, 0)]), Color(col, 0.22))
	ci.draw_polyline(PackedVector2Array([c + Vector2(-w, -k), c + Vector2(w, -k), c + Vector2(k * 0.08, 0), c + Vector2(w, k), c + Vector2(-w, k),
		c + Vector2(-k * 0.08, 0), c + Vector2(-w, -k)]), col, 1.6, true)
	ci.draw_colored_polygon(PackedVector2Array([c + Vector2(-w * 0.55, k * 0.95), c + Vector2(w * 0.55, k * 0.95), c + Vector2(0, k * 0.35)]), col)
	ci.draw_line(c + Vector2(-w - 2.0, -k), c + Vector2(w + 2.0, -k), col, 2.0, true)
	ci.draw_line(c + Vector2(-w - 2.0, k), c + Vector2(w + 2.0, k), col, 2.0, true)


## The heart and the drop of the bars (a pale shape over an ink one is the caller's: pass the colour).
static func heart(ci: CanvasItem, c: Vector2, k: float, col: Color) -> void:
	ci.draw_circle(c + Vector2(-k * 0.5, -k * 0.3), k * 0.55, col)
	ci.draw_circle(c + Vector2(k * 0.5, -k * 0.3), k * 0.55, col)
	ci.draw_colored_polygon(PackedVector2Array([c + Vector2(-k * 1.02, -k * 0.1), c + Vector2(k * 1.02, -k * 0.1), c + Vector2(0, k * 1.05)]), col)


static func drop(ci: CanvasItem, c: Vector2, k: float, col: Color) -> void:
	ci.draw_circle(c + Vector2(0, k * 0.35), k * 0.72, col)
	ci.draw_colored_polygon(PackedVector2Array([c + Vector2(-k * 0.66, k * 0.2), c + Vector2(k * 0.66, k * 0.2), c + Vector2(0, -k * 1.1)]), col)


## A small diamond of the room's mark and the objective's: ink under gold, hollow (a ring) when filled is false.
static func diamond(ci: CanvasItem, c: Vector2, d: float, col: Color, filled: bool = true) -> void:
	var pts := PackedVector2Array([c + Vector2(0, -d), c + Vector2(d, 0), c + Vector2(0, d), c + Vector2(-d, 0)])
	if filled:
		ci.draw_colored_polygon(pts, col)
	else:
		pts.append(pts[0])
		ci.draw_polyline(pts, col, 1.6, true)


## A round medallion of the bars: ink, a gold rim, a dark centre tinted by `tint`; the picture (bar_icon_*) when there is one.
static func medallion(ci: CanvasItem, piece: StringName, c: Vector2, r: float, tint: Color) -> void:
	var t := tex(piece)
	if t != null:
		draw_tex(ci, t, c, r + 2.0)
		return
	ci.draw_circle(c, r + 1.5, UiKit.INK)
	ci.draw_circle(c, r, UiKit.OLD_GOLD.lightened(0.1))
	ci.draw_circle(c, r - UiKit.FRAME, tint.darkened(0.82))
	ci.draw_arc(c, r - UiKit.FRAME - 0.5, 0.0, TAU, 24, Color(tint, 0.35), 1.0, true)
	match piece:
		&"bar_icon_life":
			heart(ci, c + Vector2(0, -r * 0.05), r * 0.38, UiKit.RED.lightened(0.15))
		&"bar_icon_magic":
			drop(ci, c, r * 0.4, MAGIC_BLUE.lightened(0.35))
		_:
			lion(ci, c, r * 0.72, UiKit.GOLD)


## The dark plate with a gold rim that stands wherever a painted frame is missing: a square of half size r (rounded corners).
static func plate(ci: CanvasItem, rect: Rect2, radius: int = 5, fill: Color = Color(UiKit.INK, 0.9)) -> void:
	ci.draw_style_box(UiKit.box(fill, UiKit.OLD_GOLD, int(UiKit.FRAME), 0, radius), rect)
