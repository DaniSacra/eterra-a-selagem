class_name HeroCrest
extends Control
## The paladin's portrait in the HUD: a round medallion with the HUD's ring of old gold and the Explorer's face as
## painted on the title screen (cut from that art, so the HUD and the title show the same man). The rim glows red
## when life is low and flashes when he is hit. A small seal can carry a number.

## The face from the approved title art (assets/ui/title/title_bg.png, 176 px square at 434, 316), 256 px.
const PORTRAIT: Texture2D = preload("res://assets/ui/hud/hero_portrait.png")
## Ink between the ring and the painting, and how dark the painting gets towards the ring (it sits in the frame).
const INK_WIDTH := 1.5
const VIGNETTE := 0.5

## 0..1: how close to death (the rim turns red and beats).
var danger := 0.0:
	set(v):
		if not is_equal_approx(v, danger):
			danger = v
			queue_redraw()
## 1 right after a hit, fades by itself.
var flash := 0.0
## A condition's colour on the ring (a boss's curse), its alpha how much (0 none).
var tint := Color(0, 0, 0, 0):
	set(v):
		if v != tint:
			tint = v
			queue_redraw()
## Text of the seal at the lower left ("" hides it).
var seal := "":
	set(v):
		if v != seal:
			seal = v
			queue_redraw()
var _beat := 0.0


func setup(diameter: float) -> HeroCrest:
	custom_minimum_size = Vector2(diameter, diameter)
	size = custom_minimum_size
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	return self


func _process(delta: float) -> void:
	if danger > 0.0 or flash > 0.0:
		_beat += delta * (3.0 + danger * 4.0)
		flash = maxf(0.0, flash - delta * 3.0)
		queue_redraw()


func _draw() -> void:
	var r := minf(size.x, size.y) * 0.5
	var c := Vector2(r, r)
	var inner := r - UiKit.FRAME - INK_WIDTH
	draw_circle(c, r, UiKit.INK)
	var disc := _ellipse(c, Vector2(inner, inner), 48)
	var uvs := PackedVector2Array()
	for p in disc:
		uvs.append((p - c) / (inner * 2.0) + Vector2(0.5, 0.5))
	draw_colored_polygon(disc, Color.WHITE, uvs, PORTRAIT)
	# a soft shadow towards the ring
	for i in 4:
		draw_arc(c, inner - 1.5 - i * 2.0, 0.0, TAU, 48, Color(UiKit.INK, VIGNETTE * (1.0 - i * 0.25)), 3.0, true)
	_draw_rim(c, r)
	if seal != "":
		_draw_seal(c + Vector2(-r * 0.72, r * 0.72), r * 0.3)


## The ring of old gold over ink: red and beating when life is low, white for a moment after a hit.
func _draw_rim(c: Vector2, r: float) -> void:
	var pulse := danger * (0.5 + 0.5 * sin(_beat))
	var rim := UiKit.OLD_GOLD.lerp(Color(tint, 1.0), tint.a).lerp(UiKit.RED, pulse).lerp(Color.WHITE, flash * 0.8)
	draw_arc(c, r - UiKit.FRAME * 0.5, 0.0, TAU, 56, rim, UiKit.FRAME, true)


func _draw_seal(at: Vector2, rs: float) -> void:
	draw_circle(at, rs + 1.5, UiKit.INK)
	draw_circle(at, rs, UiKit.OLD_GOLD)
	draw_circle(at, rs - 1.5, Color(0.08, 0.05, 0.06))
	var font := UiKit.TITLE_FONT
	var fs := int(rs * 1.15)
	var w := font.get_string_size(seal, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
	draw_string(font, at + Vector2(-w * 0.5, (font.get_ascent(fs) - font.get_descent(fs)) * 0.5), seal, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, UiKit.GOLD)


static func _ellipse(c: Vector2, radius: Vector2, steps: int = 28) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in steps:
		var a := TAU * i / steps
		pts.append(c + Vector2(cos(a) * radius.x, sin(a) * radius.y))
	return pts
