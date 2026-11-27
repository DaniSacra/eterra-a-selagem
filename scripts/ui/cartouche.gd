class_name Cartouche
extends Control
## HUD v3: the run's clock in a cartouche at the top: a dark plate with pointed ends in a gold rim, an hourglass at its left and
## the time in the Label that stands inside (Cartouche.label). The painted `cartouche` (HudArt) wears it when the kit has one.
## Pure display: the HUD sets label.text and places the cartouche.
##   var c := Cartouche.new().setup(Vector2(150, 34))
##   c.label.text = "12:48"

const POINT := 0.45
const FONT := 22
## How much of the width the hourglass keeps at the left; the label stands in the rest.
const ICON_SHARE := 0.28

var label: Label


func setup(size_px: Vector2) -> Cartouche:
	name = "Cartouche"
	custom_minimum_size = size_px
	size = size_px
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	label = UiKit.shadow(UiKit.label("0:00", UiKit.PALE, FONT, UiKit.number_font()))
	label.name = "clock"
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.position = Vector2(size_px.x * ICON_SHARE, 0.0)
	label.size = Vector2(size_px.x * (1.0 - ICON_SHARE) - size_px.y * POINT * 0.5, size_px.y)
	add_child(label)
	return self


func _draw() -> void:
	var t := HudArt.tex(&"cartouche")
	if t != null:
		draw_texture_rect(t, Rect2(Vector2.ZERO, size), false)
	else:
		var p := size.y * POINT
		var body := PackedVector2Array([Vector2(p, 0), Vector2(size.x - p, 0), Vector2(size.x, size.y * 0.5), Vector2(size.x - p, size.y),
			Vector2(p, size.y), Vector2(0, size.y * 0.5)])
		draw_colored_polygon(body, Color(UiKit.INK, 0.86))
		var edge := PackedVector2Array(body)
		edge.append(body[0])
		draw_polyline(edge, UiKit.OLD_GOLD, UiKit.FRAME, true)
		var inner := PackedVector2Array()
		for q in body:
			inner.append(size * 0.5 + (q - size * 0.5) * Vector2(0.95, 0.78))
		inner.append(inner[0])
		draw_polyline(inner, Color(UiKit.OLD_GOLD, 0.35), 1.0, true)
	HudArt.hourglass(self, Vector2(size.x * ICON_SHARE * 0.62, size.y * 0.5), size.y * 0.27, UiKit.GOLD)
