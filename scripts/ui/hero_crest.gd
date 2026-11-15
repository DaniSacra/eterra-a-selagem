class_name HeroCrest
extends Control
## The paladin's portrait in the HUD, drawn in code (there is no painted portrait yet): a round medallion with a double
## ring of old gold and the Explorer's bust in three-quarter view, in his own colours (copper hair in three tones,
## petrol scarf, dark leather), Emeth's emerald blade behind the shoulder. The rim glows red when life is low and
## flashes when he is hit. A small seal can carry a number.

## Hair: shadow, middle and light (the same hair as the hero, cycle 5 spec A2).
const HAIR_DARK := Color("5a1c0e")
const HAIR := Color("b8441c")
const HAIR_LIGHT := Color("e07a40")
const SKIN := Color("c68164")
const SKIN_SHADE := Color("8a5040")
const EYE := Color("1a1210")
const SCARF := Color("2c7478")
const SCARF_LIGHT := Color("3e9094")
const SCARF_DARK := Color("0f3036")
const VEST := Color("5e3a28")
const LEATHER := Color("2b211f")
const STRAP := Color("a86c3c")
const FIELD := Color("231c1c")
const FIELD_TOP := Color("3a2e2a")
const EMETH := Color("18d961")
const EMETH_CORE := Color("9dffc0")
## The head is drawn a little larger than the bust, so the face reads at 76 px.
const HEAD_SCALE := 1.18

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
	var inner := r - 5.0
	var disc := _ellipse(c, Vector2(inner, inner), 40)
	draw_circle(c, r, UiKit.INK)
	# the field: dark warm stone, a little lighter at the top, and Emeth's light behind the shoulder
	draw_colored_polygon(disc, FIELD)
	for i in 4:
		var t := 1.0 - i * 0.2
		_clip(_ellipse(c + Vector2(0, -inner * 0.35), Vector2(inner * t, inner * 0.8 * t)), Color(FIELD_TOP, 0.3), disc)
		_clip(_ellipse(c + Vector2(inner * 0.5, -inner * 0.2), Vector2(inner * 0.5 * t, inner * 0.6 * t)), Color(EMETH, 0.05), disc)
	_draw_blade(c, inner)
	_draw_bust(c, inner, disc)
	_draw_head(c + Vector2(0.0, -inner * 0.06), inner * HEAD_SCALE)
	_draw_rim(c, r)
	if seal != "":
		_draw_seal(c + Vector2(-r * 0.72, r * 0.72), r * 0.3)


## Emeth, blade up behind the right shoulder: a green body with a pale core, the old-gold guard and its emerald.
func _draw_blade(c: Vector2, k: float) -> void:
	var hilt := c + Vector2(k * 0.3, k * 0.62)
	var tip := c + Vector2(k * 0.68, -k * 0.62)
	draw_line(hilt, tip, Color(EMETH, 0.25), k * 0.2, true)
	draw_line(hilt, tip, EMETH.darkened(0.15), k * 0.09, true)
	draw_line(hilt.lerp(tip, 0.2), tip, EMETH_CORE, maxf(1.0, k * 0.03), true)
	var across := (tip - hilt).normalized().orthogonal() * k * 0.16
	var guard := hilt.lerp(tip, 0.18)
	draw_line(guard - across, guard + across, UiKit.OLD_GOLD, k * 0.07, true)
	draw_circle(guard, k * 0.045, EMETH)


## Shoulders in leather and the vest, a strap across the chest, the scarf around the neck with one end on the shoulder.
func _draw_bust(c: Vector2, k: float, disc: PackedVector2Array) -> void:
	_clip(_ellipse(c + Vector2(0, k * 1.02), Vector2(k * 0.8, k * 0.56)), LEATHER, disc)
	_clip(_ellipse(c + Vector2(k * 0.04, k * 1.08), Vector2(k * 0.46, k * 0.5)), VEST, disc)
	_clip(_poly(c, k, [Vector2(-0.5, 0.58), Vector2(-0.36, 0.52), Vector2(0.36, 1.1), Vector2(0.18, 1.1)]), STRAP.darkened(0.2), disc)
	draw_colored_polygon(_ellipse(c + Vector2(k * 0.03, k * 0.3), Vector2(k * 0.12, k * 0.16)), SKIN_SHADE)
	# the scarf: a dark fold under, the band, a lighter stripe and the end falling on the left shoulder
	_clip(_poly(c, k, [Vector2(-0.42, 0.5), Vector2(-0.22, 0.52), Vector2(-0.16, 0.95), Vector2(-0.36, 0.98)]), SCARF_DARK, disc)
	_clip(_poly(c, k, [Vector2(-0.38, 0.52), Vector2(-0.26, 0.54), Vector2(-0.22, 0.9), Vector2(-0.32, 0.92)]), SCARF, disc)
	draw_colored_polygon(_ellipse(c + Vector2(k * 0.02, k * 0.52), Vector2(k * 0.38, k * 0.17)), SCARF_DARK)
	draw_colored_polygon(_ellipse(c + Vector2(k * 0.02, k * 0.48), Vector2(k * 0.34, k * 0.13)), SCARF)
	draw_colored_polygon(_ellipse(c + Vector2(k * 0.04, k * 0.44), Vector2(k * 0.26, k * 0.05)), SCARF_LIGHT)


## The head turned a little to the right: the back of the hair, the face with its shadow side, ear, eyes, brows, nose
## and mouth, then the fringe sweeping over the forehead.
func _draw_head(c: Vector2, k: float) -> void:
	draw_colored_polygon(_ellipse(c + Vector2(-k * 0.08, -k * 0.2), Vector2(k * 0.34, k * 0.28)), HAIR_DARK)
	draw_colored_polygon(_poly(c, k, [Vector2(-0.38, -0.16), Vector2(-0.18, -0.1), Vector2(-0.16, 0.24), Vector2(-0.3, 0.16)]), HAIR_DARK)
	var face := _poly(c, k, [Vector2(-0.18, -0.26), Vector2(0.24, -0.28), Vector2(0.28, -0.04), Vector2(0.22, 0.13),
			Vector2(0.08, 0.27), Vector2(-0.04, 0.24), Vector2(-0.16, 0.12), Vector2(-0.2, -0.06)])
	draw_colored_polygon(face, SKIN)
	draw_colored_polygon(_poly(c, k, [Vector2(-0.18, -0.26), Vector2(-0.08, -0.24), Vector2(-0.1, 0.04), Vector2(-0.04, 0.24), Vector2(-0.16, 0.12), Vector2(-0.2, -0.06)]), SKIN.lerp(SKIN_SHADE, 0.55))
	draw_colored_polygon(_ellipse(c + Vector2(-k * 0.15, k * 0.0), Vector2(k * 0.04, k * 0.065), 12), SKIN_SHADE)
	for eye: Vector2 in [Vector2(0.02, -0.05), Vector2(0.17, -0.05)]:
		draw_colored_polygon(_ellipse(c + eye * k, Vector2(k * 0.045, k * 0.025), 10), EYE)
		draw_line(c + (eye + Vector2(-0.06, -0.075)) * k, c + (eye + Vector2(0.05, -0.085)) * k, HAIR_DARK, maxf(1.0, k * 0.035), true)
	draw_line(c + Vector2(0.12, 0.0) * k, c + Vector2(0.17, 0.09) * k, SKIN_SHADE, maxf(1.0, k * 0.03), true)
	draw_line(c + Vector2(0.06, 0.16) * k, c + Vector2(0.15, 0.15) * k, SKIN_SHADE.darkened(0.2), maxf(1.0, k * 0.03), true)
	# the hair: the middle tone over the crown, the fringe in locks towards the right, the light on top
	draw_colored_polygon(_ellipse(c + Vector2(-k * 0.02, -k * 0.3), Vector2(k * 0.3, k * 0.15)), HAIR)
	draw_colored_polygon(_poly(c, k, [Vector2(-0.3, -0.3), Vector2(0.28, -0.36), Vector2(0.3, -0.18), Vector2(0.18, -0.2),
			Vector2(0.1, -0.12), Vector2(0.02, -0.19), Vector2(-0.1, -0.12), Vector2(-0.2, -0.04), Vector2(-0.3, -0.12)]), HAIR)
	for lock: PackedVector2Array in [[Vector2(-0.04, -0.3), Vector2(0.02, -0.19)], [Vector2(0.1, -0.3), Vector2(0.18, -0.2)], [Vector2(-0.18, -0.26), Vector2(-0.2, -0.06)]]:
		draw_polyline(_poly(c, k, lock), HAIR_DARK, maxf(1.0, k * 0.03), true)
	draw_polyline(_poly(c, k, [Vector2(-0.22, -0.32), Vector2(0.0, -0.4), Vector2(0.22, -0.36)]), HAIR_LIGHT, maxf(1.5, k * 0.06), true)
	draw_polyline(_poly(c, k, [Vector2(-0.1, -0.26), Vector2(0.08, -0.28), Vector2(0.2, -0.22)]), HAIR_LIGHT.darkened(0.15), maxf(1.0, k * 0.04), true)


## The double ring of old gold over ink: red and beating when life is low, white for a moment after a hit.
func _draw_rim(c: Vector2, r: float) -> void:
	var pulse := danger * (0.5 + 0.5 * sin(_beat))
	var rim := UiKit.OLD_GOLD.lerp(UiKit.RED, pulse).lerp(Color.WHITE, flash * 0.8)
	draw_arc(c, r - 1.75, 0.0, TAU, 56, rim, 2.0, true)
	draw_arc(c, r - 4.5, 0.0, TAU, 56, rim.darkened(0.15), 1.0, true)
	draw_arc(c, r - 1.4, -PI * 0.9, -PI * 0.35, 16, Color(rim.lightened(0.45), 0.7), 1.0, true)


func _draw_seal(at: Vector2, rs: float) -> void:
	draw_circle(at, rs + 1.5, UiKit.INK)
	draw_circle(at, rs, UiKit.OLD_GOLD)
	draw_circle(at, rs - 1.5, Color(0.08, 0.05, 0.06))
	var font := UiKit.TITLE_FONT
	var fs := int(rs * 1.15)
	var w := font.get_string_size(seal, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
	draw_string(font, at + Vector2(-w * 0.5, (font.get_ascent(fs) - font.get_descent(fs)) * 0.5), seal, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, UiKit.GOLD)


func _clip(poly: PackedVector2Array, color: Color, disc: PackedVector2Array) -> void:
	for part in Geometry2D.intersect_polygons(poly, disc):
		draw_colored_polygon(part, color)


## Points given in units of the inner radius, around the centre.
static func _poly(c: Vector2, k: float, pts: PackedVector2Array) -> PackedVector2Array:
	var out := PackedVector2Array()
	for p in pts:
		out.append(c + p * k)
	return out


static func _ellipse(c: Vector2, radius: Vector2, steps: int = 28) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in steps:
		var a := TAU * i / steps
		pts.append(c + Vector2(cos(a) * radius.x, sin(a) * radius.y))
	return pts
