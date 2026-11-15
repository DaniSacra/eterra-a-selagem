class_name HeroCrest
extends Control
## The paladin's portrait in the HUD, drawn in code (there is no painted portrait yet): a round medallion with a gold
## rim and the hero's bust in his own colours (copper hair, petrol scarf, dark leather), Emeth's green blade behind
## the shoulder. The rim glows red when life is low and flashes when he is hit. A small seal can carry a number.

const HAIR := Color("a9340d")
const HAIR_LIGHT := Color("e15e26")
const SKIN := Color("c68164")
const SCARF := Color("395c4a")
const SCARF_DARK := Color("173025")
const LEATHER := Color("402621")
const STEEL := Color("977e82")
const FIELD := Color("234648")
const EMETH := Color("20a462")
const BRASS := Color("d4973b")

## 0..1: how close to death (the rim turns red and beats).
var danger := 0.0:
	set(v):
		if not is_equal_approx(v, danger):
			danger = v
			queue_redraw()
## 1 right after a hit, fades by itself.
var flash := 0.0
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
	var inner := r - 4.0
	var disc := _ellipse(c, Vector2(inner, inner))
	draw_circle(c, r, Color(0.02, 0.01, 0.03, 0.95))
	# the field: dark petrol, lighter towards the top, and Emeth's green light behind the shoulder
	draw_colored_polygon(disc, SCARF_DARK.darkened(0.3))
	_clip(_ellipse(c + Vector2(0, -inner * 0.25), Vector2(inner * 0.95, inner * 0.8)), FIELD.darkened(0.25), disc)
	_clip(_ellipse(c + Vector2(inner * 0.45, -inner * 0.3), Vector2(inner * 0.5, inner * 0.5)), Color(EMETH, 0.22), disc)
	# Emeth, blade up behind the right shoulder
	var hilt := c + Vector2(inner * 0.2, inner * 0.55)
	var tip := c + Vector2(inner * 0.6, -inner * 0.66)
	draw_line(hilt, tip, Color(EMETH, 0.35), inner * 0.2, true)
	draw_line(hilt, tip, EMETH.lightened(0.35), inner * 0.08, true)
	var across := (tip - hilt).normalized().orthogonal() * inner * 0.17
	var guard := hilt.lerp(tip, 0.18)
	draw_line(guard - across, guard + across, BRASS, inner * 0.07, true)
	# the bust: shoulders, scarf, neck and head with the copper hair
	_clip(_ellipse(c + Vector2(0, inner * 1.0), Vector2(inner * 0.78, inner * 0.55)), LEATHER, disc)
	_clip(_ellipse(c + Vector2(-inner * 0.5, inner * 0.55), Vector2(inner * 0.26, inner * 0.16)), STEEL.darkened(0.25), disc)
	_clip(_ellipse(c + Vector2(inner * 0.5, inner * 0.55), Vector2(inner * 0.26, inner * 0.16)), STEEL.darkened(0.25), disc)
	_clip(_ellipse(c + Vector2(0, inner * 0.5), Vector2(inner * 0.36, inner * 0.17)), SCARF, disc)
	draw_colored_polygon(_ellipse(c + Vector2(0, inner * 0.3), Vector2(inner * 0.12, inner * 0.16)), SKIN.darkened(0.3))
	draw_colored_polygon(_ellipse(c + Vector2(inner * 0.02, -inner * 0.05), Vector2(inner * 0.24, inner * 0.3)), SKIN)
	draw_colored_polygon(_ellipse(c + Vector2(-inner * 0.06, -inner * 0.26), Vector2(inner * 0.3, inner * 0.22)), HAIR)
	draw_colored_polygon(_ellipse(c + Vector2(-inner * 0.22, -inner * 0.08), Vector2(inner * 0.12, inner * 0.24)), HAIR)
	draw_colored_polygon(_ellipse(c + Vector2(inner * 0.02, -inner * 0.33), Vector2(inner * 0.2, inner * 0.1)), HAIR_LIGHT)
	# the rim: gold, red and beating when life is low, white for a moment after a hit
	var pulse := danger * (0.5 + 0.5 * sin(_beat))
	var rim := UiKit.EDGE.lerp(UiKit.RED, pulse).lerp(Color.WHITE, flash * 0.8)
	draw_arc(c, r - 2.0, 0.0, TAU, 48, rim, 3.5, true)
	draw_arc(c, r - 4.5, 0.0, TAU, 48, Color(0.02, 0.01, 0.03, 0.8), 1.0, true)
	draw_arc(c, r - 0.6, -PI * 0.9, -PI * 0.35, 16, Color(UiKit.GOLD, 0.7), 1.0, true)
	if seal != "":
		_draw_seal(c + Vector2(-r * 0.72, r * 0.72), r * 0.3)


func _draw_seal(at: Vector2, rs: float) -> void:
	draw_circle(at, rs + 1.5, Color(0.02, 0.01, 0.03))
	draw_circle(at, rs, UiKit.EDGE)
	draw_circle(at, rs - 2.0, Color(0.08, 0.05, 0.06))
	var font := UiKit.TITLE_FONT
	var fs := int(rs * 1.15)
	var w := font.get_string_size(seal, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
	draw_string(font, at + Vector2(-w * 0.5, (font.get_ascent(fs) - font.get_descent(fs)) * 0.5), seal, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, UiKit.GOLD)


func _clip(poly: PackedVector2Array, color: Color, disc: PackedVector2Array) -> void:
	for part in Geometry2D.intersect_polygons(poly, disc):
		draw_colored_polygon(part, color)


static func _ellipse(c: Vector2, radius: Vector2, steps: int = 28) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in steps:
		var a := TAU * i / steps
		pts.append(c + Vector2(cos(a) * radius.x, sin(a) * radius.y))
	return pts
