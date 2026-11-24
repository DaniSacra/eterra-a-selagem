class_name DoorSeal
extends Control
## The small seal of a modifier, drawn in code in the house's seal (SealMedal: ink, ring of old gold): what a room has
## besides its reward. It sits at the lower right of a door's medallion (DoorTip) and, beside each line of the tip,
## says which modifier the line is about. Ids: &"hard" (a bigger enemy: a skull), &"guardian" (the skull with the
## guardian's crown of three points), &"trial" (the Provação's cracked diamond), &"angel" (the angel's own mark) and
## &"find" (the Ofícios' find, a gem).
##   var s := DoorSeal.new().setup(&"hard", 24.0)

const IVORY := SealMedal.IVORY
const BONE := Color(0.92, 0.88, 0.78)

var id := &""
var family := Boon.Family.LUZ


func setup(p_id: StringName, size_px: float, p_family := Boon.Family.LUZ) -> DoorSeal:
	id = p_id
	family = p_family
	custom_minimum_size = Vector2(size_px, size_px)
	size = custom_minimum_size
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	return self


func _draw() -> void:
	var c := size * 0.5
	var r := minf(size.x, size.y) * 0.46
	var w := SealMedal.draw_seal(self, c, r)
	match id:
		&"hard", &"guardian":
			_skull(c + Vector2(0, r * 0.06), r * 0.5, id == &"guardian")
		&"trial":
			var h := r * 0.9
			var pts := PackedVector2Array([c + Vector2(0, -h * 0.5), c + Vector2(h * 0.38, 0), c + Vector2(0, h * 0.5), c + Vector2(-h * 0.38, 0), c + Vector2(0, -h * 0.5)])
			draw_polyline(pts, DoorGlyph.PSALM_LIGHT, maxf(1.2, w), true)
			draw_line(c + Vector2(-h * 0.12, -h * 0.18), c + Vector2(h * 0.1, h * 0.2), IVORY, maxf(1.0, w * 0.8), true)
		&"angel":
			AngelSeal.mark(self, family, c, r * AngelSeal.MARK, maxf(1.2, w * 0.9), AngelSeal.tint(family), IVORY)
		&"find":
			var g := r * 0.5
			draw_colored_polygon(PackedVector2Array([c + Vector2(0, -g), c + Vector2(g * 0.8, 0), c + Vector2(0, g), c + Vector2(-g * 0.8, 0)]), DoorGlyph.EMERALD_FILL)
			draw_line(c + Vector2(0, -g), c + Vector2(0, g), DoorGlyph.EMERALD_LIT, maxf(1.0, w * 0.7), true)


func _skull(c: Vector2, u: float, crowned: bool) -> void:
	draw_circle(c + Vector2(0, -u * 0.15), u * 0.9, BONE)
	draw_rect(Rect2(c + Vector2(-u * 0.5, u * 0.35), Vector2(u, u * 0.7)), BONE)
	var dark := SealMedal.INK
	draw_circle(c + Vector2(-u * 0.36, -u * 0.12), u * 0.24, dark)
	draw_circle(c + Vector2(u * 0.36, -u * 0.12), u * 0.24, dark)
	draw_line(c + Vector2(-u * 0.18, u * 0.55), c + Vector2(-u * 0.18, u * 1.0), dark, maxf(1.0, u * 0.12))
	draw_line(c + Vector2(u * 0.18, u * 0.55), c + Vector2(u * 0.18, u * 1.0), dark, maxf(1.0, u * 0.12))
	if crowned:
		var y := c.y - u * 0.95
		draw_colored_polygon(PackedVector2Array([Vector2(c.x - u * 0.8, y), Vector2(c.x - u * 0.55, y - u * 0.7), Vector2(c.x - u * 0.2, y - u * 0.1),
			Vector2(c.x, y - u * 0.85), Vector2(c.x + u * 0.2, y - u * 0.1), Vector2(c.x + u * 0.55, y - u * 0.7), Vector2(c.x + u * 0.8, y)]), DoorGlyph.CHEVRON_GOLD)
