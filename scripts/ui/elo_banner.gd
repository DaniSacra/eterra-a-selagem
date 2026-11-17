class_name EloBanner
extends VBoxContainer
## A short greeting at the top of the screen under the clock (in the notices' place), away from the paladin; it never
## stops the game. Two kinds: the moment an Elo forms ("Elo formado", the chain closing between its two gifts, and the
## Elo's name) and a Blessing taken for the first time ever (E3-04: "Bênção nova", its medallion, its name and "No
## Compêndio"). A greeting asked for while another shows waits its turn (queue).

const TIME := 2.6
const FADE_IN := 0.15
const FADE_OUT := 0.6
## How long the chain takes to close from both gifts to the Elo.
const CLOSE := 0.4
const TITLE_SIZE := 24
const NAME_SIZE := 18
const NOTE_SIZE := 15
## The Blessing's medallion in its greeting, beside its name (one short row: the greeting stays above the fight).
const MEDALLION := 34.0
## At most this many greetings wait (a burst of Blessings from a dev option never piles up for long).
const QUEUE_MAX := 3

var _t := 0.0
var _link: EloLink
var _icon: BoonIcon
var _queue: Array[Callable] = []
## What shows now: &"elo", &"boon" or &"" (the tests read it).
var showing := &""


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	alignment = BoxContainer.ALIGNMENT_CENTER
	add_theme_constant_override(&"separation", 4)
	visible = false
	set_process(false)


## The Blessings among owned to greet as new: not Elos, not greeted yet (greeted: ids) and never in the Codex
## (codex: the save's codex.boons, keyed by id strings).
static func fresh_boons(owned: Array[Boon], greeted: Dictionary, codex: Dictionary) -> Array[Boon]:
	var out: Array[Boon] = []
	for b in owned:
		if not b.is_duo() and not greeted.has(b.id) and not codex.has(String(b.id)):
			out.append(b)
	return out


func show_elo(b: Boon, from: Array[Boon]) -> void:
	_enqueue(_open_elo.bind(b, from))


## E3-04: a Blessing taken for the first time ever.
func show_boon(b: Boon) -> void:
	_enqueue(_open_boon.bind(b))


## How many greetings wait behind the one showing.
func waiting() -> int:
	return _queue.size()


func _enqueue(open_it: Callable) -> void:
	if visible:
		if _queue.size() < QUEUE_MAX:
			_queue.append(open_it)
		return
	open_it.call()


func _clear() -> void:
	for c in get_children():
		remove_child(c)
		c.queue_free()
	_link = null
	_icon = null


func _open_elo(b: Boon, from: Array[Boon]) -> void:
	_clear()
	add_child(UiKit.shadow(UiKit.title(T.t(&"elo_formed"), TITLE_SIZE, UiKit.GOLD)))
	_link = EloLink.new().setup(b, from, 44.0, 30.0, 26.0)
	_link.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_link.progress = 0.0
	add_child(_link)
	add_child(_name(b))
	_start(&"elo")


func _open_boon(b: Boon) -> void:
	_clear()
	add_child(UiKit.shadow(UiKit.title(T.t(&"boon_new_title"), TITLE_SIZE, UiKit.GOLD)))
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_theme_constant_override(&"separation", 8)
	_icon = BoonIcon.new().setup(b, MEDALLION)
	row.add_child(_icon)
	row.add_child(_name(b))
	add_child(row)
	var note := UiKit.shadow(UiKit.label(T.t(&"boon_new_note"), UiKit.DIM, NOTE_SIZE))
	note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(note)
	_start(&"boon")


func _name(b: Boon) -> Label:
	var l := UiKit.shadow(UiKit.title(T.t("boon_" + String(b.id)), NAME_SIZE, UiKit.PALE))
	l.add_theme_constant_override(&"outline_size", 6)
	return l


func _start(kind: StringName) -> void:
	showing = kind
	_t = 0.0
	modulate.a = 0.0
	visible = true
	set_process(true)


func _process(delta: float) -> void:
	_t += delta
	modulate.a = minf(clampf(_t / FADE_IN, 0.0, 1.0), clampf((TIME - _t) / FADE_OUT, 0.0, 1.0))
	if _link:
		_link.progress = ease(clampf((_t - FADE_IN * 0.5) / CLOSE, 0.0, 1.0), 0.5)
	if _icon:
		_icon.scale = Vector2.ONE * lerpf(0.7, 1.0, ease(clampf(_t / (FADE_IN * 2.0), 0.0, 1.0), 0.4))
		_icon.pivot_offset = _icon.size * 0.5
	if _t >= TIME:
		visible = false
		showing = &""
		set_process(false)
		if not _queue.is_empty():
			_queue.pop_front().call()
