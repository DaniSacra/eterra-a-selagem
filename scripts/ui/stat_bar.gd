class_name StatBar
extends Control
## HUD v3: one of the three bars beside the portrait (the Supremo's charge in gold, Magia in blue, life in red): a round medallion with
## its icon on the left, a bar with a pointed right end (HudBar: trail, glint, the costs' ticks) and the value written inside its right
## end. The painted pieces bar_frame and bar_icon_<kind> (HudArt) wear it when they exist; without them the HUD's own gold line and a
## drawn medallion. Pure display: the HUD calls show().
##   var bar := StatBar.new().setup(StatBar.Kind.LIFE, Vector2(210, 22))
##   bar.show_value(0.8, "32/40")

enum Kind { LIFE, MAGIC, SUPREME }
## Per kind: the medallion's piece, the fill's top and bottom.
const LOOK := {
	Kind.LIFE: [&"bar_icon_life", Color("c0302a"), Color("6a1410")],
	Kind.MAGIC: [&"bar_icon_magic", Color("3a7ee8"), Color("163a8a")],
	Kind.SUPREME: [&"bar_icon_supreme", Color("d9aa4a"), Color("7a5a1e")],
}
const FONT := 14
## The medallion's share of the height and the bar's, so the medallion stands a little proud of the bar.
const MEDAL := 1.0
const BAR_SHARE := 0.68

var kind := Kind.LIFE
var bar: HudBar
var _overlay: Control


func setup(k: Kind, size_px: Vector2) -> StatBar:
	kind = k
	name = "StatBar_%s" % Kind.keys()[k]
	custom_minimum_size = size_px
	size = size_px
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var look: Array = LOOK[k]
	var bar_h := size_px.y * BAR_SHARE
	var medal := size_px.y * MEDAL
	bar = HudBar.new().setup(look[1], Vector2(size_px.x - medal * 0.5, bar_h), FONT, false, look[2])
	bar.text_right = true
	bar.framed = HudArt.tex(&"bar_frame") == null
	bar.position = Vector2(medal * 0.5, (size_px.y - bar_h) * 0.5)
	add_child(bar)
	_overlay = Control.new()
	_overlay.name = "Overlay"
	_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_overlay.draw.connect(_draw_overlay)
	add_child(_overlay)
	return self


## ratio 0..1 and the value written at the bar's right end ("32/40", "65%").
func show_value(ratio: float, text: String) -> void:
	bar.show_value(ratio, text)


## The painted frame over the bar (when the kit has one) and the medallion over its left end.
func _draw_overlay() -> void:
	var look: Array = LOOK[kind]
	var frame := HudArt.tex(&"bar_frame")
	if frame != null:
		# the art is 29 px of line inside 36 px of picture: grow the rect so the line fits the bar
		var tall := bar.size.y * 36.0 / 29.0
		_overlay.draw_texture_rect(frame, Rect2(bar.position - Vector2(0.0, (tall - bar.size.y) * 0.5), Vector2(bar.size.x, tall)), false)
	HudArt.medallion(_overlay, look[0], Vector2(size.y * MEDAL * 0.5, size.y * 0.5), size.y * MEDAL * 0.5 - 2.0, look[1])
