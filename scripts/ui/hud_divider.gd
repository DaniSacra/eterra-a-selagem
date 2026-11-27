class_name HudDivider
extends Control
## HUD v3: the thin vertical gold line between the four blows and the dodge and the Supremo (the painted `divider`, or a fading
## line with a small diamond in the middle).

const WIDTH := 14.0


func _init() -> void:
	name = "Divider"
	custom_minimum_size = Vector2(WIDTH, 0.0)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	size_flags_vertical = Control.SIZE_FILL


func _draw() -> void:
	var t := HudArt.tex(&"divider")
	var h := size.y * 0.72
	var top := (size.y - h) * 0.5 - 6.0
	var x := size.x * 0.5
	if t != null:
		# the picture is a horizontal line: turned a quarter, running down
		draw_set_transform(Vector2(x, top), PI * 0.5)
		draw_texture_rect(t, Rect2(0.0, -WIDTH * 0.5, h, WIDTH), false)
		draw_set_transform(Vector2.ZERO)
		return
	var steps := 10
	for i in steps:
		var k := 1.0 - absf(float(i) + 0.5 - steps * 0.5) / (steps * 0.5)
		draw_line(Vector2(x, top + h * i / steps), Vector2(x, top + h * (i + 1) / steps), Color(UiKit.OLD_GOLD.lightened(0.15), 0.2 + 0.8 * k), 1.5, true)
	HudArt.diamond(self, Vector2(x, top + h * 0.5), 3.5, UiKit.GOLD, true)
