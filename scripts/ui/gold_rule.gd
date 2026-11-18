class_name GoldRule
extends Control
## A thin line of old gold that fades at both ends, with a diamond in the middle; drawn out from the middle (drawn 0..1).
## Under every screen's title (UiKit.header) and between the parts of the end screen. Was EndScreen.Ornament.
##   var r := GoldRule.new()   # size it with custom_minimum_size; r.drawn = 0.4 draws 40% of it

## The line's colour (old gold over the dark menus; Book.GILT on the parchment of the Livro de Ahk).
var tint := UiKit.OLD_GOLD.lightened(0.15)
var drawn := 1.0:
	set(v):
		drawn = v
		queue_redraw()


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _draw() -> void:
	var c := size * 0.5
	var half := size.x * 0.5 * drawn
	var steps := 12
	for side: float in [-1.0, 1.0]:
		for i in steps:
			var a := c + Vector2(side * (9.0 + (half - 9.0) * i / steps), 0)
			var b := c + Vector2(side * (9.0 + (half - 9.0) * (i + 1) / steps), 0)
			draw_line(a, b, Color(tint, 1.0 - float(i) / steps), 1.5, true)
	var d := 5.0
	draw_colored_polygon(PackedVector2Array([c + Vector2(0, -d - 1.5), c + Vector2(d + 1.5, 0), c + Vector2(0, d + 1.5), c + Vector2(-d - 1.5, 0)]), UiKit.INK)
	draw_colored_polygon(PackedVector2Array([c + Vector2(0, -d), c + Vector2(d, 0), c + Vector2(0, d), c + Vector2(-d, 0)]), UiKit.GOLD)
