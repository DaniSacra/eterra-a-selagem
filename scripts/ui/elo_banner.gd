class_name EloBanner
extends VBoxContainer
## The moment an Elo forms: "Elo formado", the chain closing between its two gifts, and the Elo's name. Short, at the
## top of the screen under the clock (in the notices' place), away from the paladin; it does not stop the game.

const TIME := 2.6
const FADE_IN := 0.15
const FADE_OUT := 0.6
## How long the chain takes to close from both gifts to the Elo.
const CLOSE := 0.4
const TITLE_SIZE := 24
const NAME_SIZE := 18

var _t := 0.0
var _link: EloLink


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	alignment = BoxContainer.ALIGNMENT_CENTER
	add_theme_constant_override(&"separation", 4)
	visible = false
	set_process(false)


func show_elo(b: Boon, from: Array[Boon]) -> void:
	for c in get_children():
		c.queue_free()
	add_child(UiKit.title(T.t(&"elo_formed"), TITLE_SIZE, UiKit.GOLD))
	_link = EloLink.new().setup(b, from, 44.0, 30.0, 26.0)
	_link.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_link.progress = 0.0
	add_child(_link)
	var name_l := UiKit.title(T.t("boon_" + String(b.id)), NAME_SIZE, UiKit.PALE)
	name_l.add_theme_constant_override(&"outline_size", 6)
	add_child(name_l)
	_t = 0.0
	modulate.a = 0.0
	visible = true
	set_process(true)


func _process(delta: float) -> void:
	_t += delta
	modulate.a = minf(clampf(_t / FADE_IN, 0.0, 1.0), clampf((TIME - _t) / FADE_OUT, 0.0, 1.0))
	if _link:
		_link.progress = ease(clampf((_t - FADE_IN * 0.5) / CLOSE, 0.0, 1.0), 0.5)
	if _t >= TIME:
		visible = false
		set_process(false)
