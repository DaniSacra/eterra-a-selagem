class_name ObjectiveLine
extends Control
## SW-O2: the objective, one line at the top left under "Sala N de M": a small old-gold diamond and the words in
## Alegreya, ivory with a shadow, no box. A new key takes the old line out in OUT seconds, the new one in IN seconds and
## a thread of gold runs under it once (RULE). Display only; the HUD feeds it (Objective.pick) and hides it over screens.
##   line.set_key(&"obj_win")   # &"" fades it out
##   line.pulse()               # one blink (the hero stood still too long)

const OUT := 0.2
const IN := 0.3
const RULE := 0.5
const TEXT_PX := 18
const DIAMOND := 5.0
const TEXT_LEFT := 20.0
const HEIGHT := 28.0
const PULSE := 0.6

var key := &""
var _label: RichTextLabel
## 0..1: how much of the thread under the words is drawn; its fade at the end.
var _rule := 0.0
var _rule_alpha := 0.0
var _pulse := 0.0
var _tween: Tween


func _ready() -> void:
	name = "ObjectiveLine"
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	custom_minimum_size = Vector2(380.0, HEIGHT)
	_label = UiKit.keyed_line(UiKit.PALE, TEXT_PX)
	_label.position = Vector2(TEXT_LEFT, 0.0)
	_label.modulate.a = 0.0
	add_child(_label)
	modulate.a = 0.0


## Shows the line of this key (&"": none). The same key only refreshes its words (a rebound key reads right).
func set_key(new_key: StringName) -> void:
	var words := Objective.text(new_key)
	if new_key == key:
		if _label != null and words != "" and _label.text != MouseGlyph.keyed(words):
			_label.text = MouseGlyph.keyed(words)
			queue_redraw()
		return
	var had := key != &""
	key = new_key
	if _tween != null:
		_tween.kill()
	_tween = create_tween().set_ignore_time_scale(true)
	if had:
		_tween.tween_property(_label, "modulate:a", 0.0, OUT)
	_tween.tween_callback(_swap.bind(words))
	if words != "":
		_tween.tween_property(_label, "modulate:a", 1.0, IN)
		_tween.parallel().tween_property(self, "modulate:a", 1.0, IN)
		_tween.parallel().tween_property(self, "_rule", 1.0, RULE)
		_tween.parallel().tween_property(self, "_rule_alpha", 1.0, 0.1)
		_tween.tween_property(self, "_rule_alpha", 0.0, 0.3)
	else:
		_tween.parallel().tween_property(self, "modulate:a", 0.0, OUT)


func _swap(words: String) -> void:
	_label.text = MouseGlyph.keyed(words)
	_rule = 0.0
	_rule_alpha = 0.0
	if words != "":
		_label.reset_size()
	queue_redraw()


## One blink of the diamond and the words: the Antessala asks the player, without a word, to look at the line.
func pulse() -> void:
	if key == &"":
		return
	_pulse = 1.0
	create_tween().set_ignore_time_scale(true).tween_property(self, "_pulse", 0.0, PULSE)


func _process(_delta: float) -> void:
	if modulate.a > 0.0 or _pulse > 0.0:
		queue_redraw()


func _draw() -> void:
	if key == &"":
		return
	var c := Vector2(DIAMOND + 1.0, HEIGHT * 0.5)
	var d := DIAMOND + _pulse * 2.0
	var gold := UiKit.GOLD.lerp(UiKit.PALE, _pulse)
	draw_colored_polygon(PackedVector2Array([c + Vector2(0, -d - 1.5), c + Vector2(d + 1.5, 0), c + Vector2(0, d + 1.5),
			c + Vector2(-d - 1.5, 0)]), UiKit.INK)
	draw_colored_polygon(PackedVector2Array([c + Vector2(0, -d), c + Vector2(d, 0), c + Vector2(0, d), c + Vector2(-d, 0)]),
			gold)
	if _rule_alpha > 0.0:
		var w := _label.size.x * _rule
		var y := HEIGHT - 1.0
		draw_line(Vector2(TEXT_LEFT, y), Vector2(TEXT_LEFT + w, y), Color(UiKit.OLD_GOLD.lightened(0.15), _rule_alpha), 1.5, true)
