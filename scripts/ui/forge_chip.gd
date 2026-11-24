class_name ForgeChip
extends ForgeTouch
## One choice of the Forja's strip (docs/art/forge_spec.md 3): an iron chip 176 x 56 with the choice's name over its
## price or its state word. The six states read by drawing AND by word: ember rim and the price (can be forged), grey rim
## and the price in dim red (the material is missing), a dashed rim and "Depois de: X" (an earlier rank first), old gold
## and a filled diamond ("Guardado"), gold rim on an ember wash ("Na lâmina"), a grey cloth with a lock ("Falta a
## ferramenta"). The one in focus has a pale ring outside.
##   var chip := ForgeChip.new().setup(info)

const SIZE := Vector2(176, 56)
const EMBER := Color("e07a2a")
const SOOT := Color("2a2620")
const ASH := Color("6a625a")
const RED_DIM := Color("c05040")
const CLOTH_GREY := Color("3a3733")

var info: ForgeInfo
## The chip the plate is reading (the focus is on the weapon): a thin pale ring.
var current := false:
	set(v):
		current = v
		queue_redraw()
var focused := false:
	set(v):
		focused = v
		queue_redraw()


func setup(p_info: ForgeInfo) -> ForgeChip:
	info = p_info
	custom_minimum_size = SIZE
	size = SIZE
	return self


func _draw() -> void:
	if info == null:
		return
	var r := Rect2(Vector2.ZERO, SIZE)
	var look := info.look
	var fill := SOOT
	var rim := ASH
	var width := 2.0
	match look:
		ForgeInfo.Look.READY:
			rim = EMBER
		ForgeInfo.Look.STORED:
			rim = UiKit.OLD_GOLD
		ForgeInfo.Look.ON:
			rim = UiKit.GOLD
			fill = SOOT.lerp(EMBER, 0.25)
		ForgeInfo.Look.NO_TOOL:
			fill = CLOTH_GREY
		ForgeInfo.Look.NEEDS:
			fill = Color(SOOT, 0.55)
	draw_style_box(UiKit.box(fill, Color(0, 0, 0, 0), 0, 0, 5), r)
	if look == ForgeInfo.Look.NEEDS:
		_dashed(r.grow(-1.0), ASH, width)
	else:
		draw_style_box(UiKit.box(Color(0, 0, 0, 0), rim, int(width), 0, 5), r)
	if focused:
		draw_style_box(UiKit.box(Color(0, 0, 0, 0), UiKit.PALE, 2, 0, 8), r.grow(4.0))
	elif current:
		draw_style_box(UiKit.box(Color(0, 0, 0, 0), Color(UiKit.PALE, 0.45), 1, 0, 7), r.grow(3.0))
	var dim := look == ForgeInfo.Look.NEEDS or look == ForgeInfo.Look.NO_TOOL
	var name_color := UiKit.DIM if dim else UiKit.STRONG
	var f := UiKit.TITLE_FONT
	draw_string(f, Vector2(0, 22), info.name, HORIZONTAL_ALIGNMENT_CENTER, SIZE.x, 16, name_color)
	if look == ForgeInfo.Look.READY or look == ForgeInfo.Look.SHORT:
		_price(look == ForgeInfo.Look.SHORT)
	else:
		if look == ForgeInfo.Look.STORED:
			_diamond(Vector2(14, 41), 6.0, UiKit.OLD_GOLD)
		if look == ForgeInfo.Look.NO_TOOL:
			_lock(Vector2(18, 39))
		var word_color := UiKit.GOLD if look == ForgeInfo.Look.ON else (UiKit.OLD_GOLD.lightened(0.25) if look == ForgeInfo.Look.STORED else UiKit.DIM)
		draw_string(UiKit.BOLD_FONT, Vector2(0, 46), info.chip_word, HORIZONTAL_ALIGNMENT_CENTER, SIZE.x, 14, word_color)


## The price: the material's mark and the number, centred.
func _price(short: bool) -> void:
	var text := str(info.cost)
	var font := UiKit.number_font()
	var w := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, 16).x
	var x := (SIZE.x - (w + 22.0)) * 0.5
	DoorGlyph.material(self, DoorGlyph.of_material(info.material), Vector2(x + 8, 40), 16.0)
	draw_string(font, Vector2(x + 22, 46), text, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, RED_DIM if short else UiKit.PALE)


func _diamond(c: Vector2, r: float, col: Color) -> void:
	draw_colored_polygon(PackedVector2Array([c + Vector2(0, -r), c + Vector2(r, 0), c + Vector2(0, r), c + Vector2(-r, 0)]), col)


func _lock(c: Vector2) -> void:
	draw_rect(Rect2(c + Vector2(-6, -2), Vector2(12, 9)), UiKit.DIM)
	draw_arc(c + Vector2(0, -2), 4.0, PI, TAU, 10, UiKit.DIM, 2.0)


func _dashed(r: Rect2, col: Color, w: float) -> void:
	var pts := [r.position, Vector2(r.end.x, r.position.y), r.end, Vector2(r.position.x, r.end.y), r.position]
	for i in 4:
		var a: Vector2 = pts[i]
		var b: Vector2 = pts[i + 1]
		var n := int(a.distance_to(b) / 10.0)
		for k in n:
			if k % 2 == 0:
				draw_line(a.lerp(b, float(k) / n), a.lerp(b, float(k + 1) / n), col, w)
