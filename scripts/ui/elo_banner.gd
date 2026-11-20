class_name EloBanner
extends VBoxContainer
## A short greeting at the top of the screen under the clock (in the notices' place), away from the paladin; it never
## stops the game. Two kinds: the moment an Elo forms ("Elo formado", the chain closing between its two gifts, and the
## Elo's name) and a Blessing taken for the first time ever (E3-04: "Bênção nova", its medallion, its name and "No
## Compêndio"). A greeting asked for while another shows waits its turn (queue).
## E4-04, a Psalm: "Salmo descoberto" (the first time it is ever seen) or "Salmo" over its medallion and name, then its
## short line when it is taken or "Anotado no Compêndio" when it was only seen.
## E5, the Provação turned (show_trial): "Provação vencida" over the gold seal (TrialSeal) and the blessing's name, then
## what it gives for the rest of the run.
## C17 (BUG-107): while a screen is over the run (the cards, the pause, an event's choice: held) nothing shows and the
## clock of the greeting stands still; it goes on, and the ones waiting follow, once the run is back. Over the fight
## a soft dark veil sits behind the words, so they read over a lit floor and over enemies at the top of the room.
## Rejogabilidade, Fatia 1 (show_material): a material found, one short row (its mark and "+3 Prata Antiga"), shorter
## than the others (MATERIAL_TIME); more of the same while it shows, or while it waits, adds to it.

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
const MATERIAL_TIME := 1.8
const MATERIAL_SIZE := 20
## The veil behind the words: how far it reaches past them (px at 720 lines) and how dark its middle is.
const VEIL_REACH := Vector2(70, 18)
const VEIL_ALPHA := 0.62

var _t := 0.0
var _link: EloLink
var _icon: Control
var _queue: Array[Callable] = []
## A material's greeting: the one showing (id and amount, its row) and the amounts waiting by id.
var _material := &""
var _material_n := 0
var _material_row: MaterialCount
var _material_waiting := {}
var _time := TIME
## What shows now: &"elo", &"boon", &"psalm", &"trial" or &"" (the tests read it).
var showing := &""
## A screen is over the run: nothing shows and the greeting waits (Hud sets it every frame).
var held := false:
	set(v):
		if v == held:
			return
		held = v
		if held:
			visible = false
		elif showing != &"":
			visible = true
		elif not _queue.is_empty():
			_queue.pop_front().call()
static var _veil: GradientTexture2D


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	draw.connect(_draw_veil)
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


## E4-04: a Psalm seen on a card or taken. discovered: never seen before (the title says so); taken: its short line
## under the name, else the note that the Compendium has it.
## A Psalm is rare: it goes first in the queue and is never dropped by QUEUE_MAX.
func show_psalm(p: PsalmDef, discovered: bool, taken: bool) -> void:
	if _busy():
		_queue.push_front(_open_psalm.bind(p, discovered, taken))
		return
	_open_psalm(p, discovered, taken)


## E5: the Provação's curse turned into its blessing (Rooms.trial_turned). Never dropped by QUEUE_MAX either.
func show_trial(card: Trials.Card) -> void:
	if _busy():
		_queue.push_front(_open_trial.bind(card))
		return
	_open_trial(card)


## A material found (MaterialPurse.SILVER, MEMORY): n more of it.
func show_material(id: StringName, n: int) -> void:
	if n <= 0:
		return
	if showing == &"material" and _material == id:
		_material_n += n
		_material_row.set_amount(_material_n)
		_t = minf(_t, FADE_IN)
		return
	if _material_waiting.has(id):
		_material_waiting[id] = int(_material_waiting[id]) + n
		return
	_material_waiting[id] = n
	_enqueue(_open_material.bind(id))


## How many greetings wait behind the one showing.
func waiting() -> int:
	return _queue.size()


## Something shows, or a screen holds the greetings back.
func _busy() -> bool:
	return showing != &"" or held


func _enqueue(open_it: Callable) -> void:
	if _busy():
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


func _open_psalm(p: PsalmDef, discovered: bool, taken: bool) -> void:
	_clear()
	var title := UiKit.shadow(UiKit.title(T.t(&"psalm_discovered" if discovered else &"psalm_card"), TITLE_SIZE, PsalmIcon.IVORY))
	title.name = &"Title"
	add_child(title)
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_theme_constant_override(&"separation", 8)
	_icon = PsalmIcon.new().setup(p, MEDALLION + 4.0)
	row.add_child(_icon)
	row.add_child(_named(T.t(p.name_key), PsalmIcon.tint(p).lightened(0.25)))
	add_child(row)
	var note := UiKit.shadow(UiKit.label(T.t(p.line_key if taken else &"psalm_noted"), UiKit.PALE if taken else UiKit.DIM, NOTE_SIZE))
	note.name = &"Note"
	note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(note)
	_start(&"psalm")


func _open_trial(card: Trials.Card) -> void:
	_clear()
	var title := UiKit.shadow(UiKit.title(T.t(&"notice_trial_won"), TITLE_SIZE, UiKit.GOLD))
	title.name = &"Title"
	add_child(title)
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_theme_constant_override(&"separation", 8)
	_icon = TrialSeal.new().setup(MEDALLION * 0.8, false, 1.0)
	row.add_child(_icon)
	row.add_child(_named(T.t(card.blessing.name_key), UiKit.PALE))
	add_child(row)
	var note := UiKit.shadow(UiKit.label(TrialSeal.blessing_text(card), UiKit.PALE, NOTE_SIZE))
	note.name = &"Note"
	note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(note)
	_start(&"trial")


func _open_material(id: StringName) -> void:
	_clear()
	_material = id
	_material_n = int(_material_waiting.get(id, 0))
	_material_waiting.erase(id)
	_material_row = MaterialCount.new()
	_material_row.plus = true
	_material_row.setup(id, _material_n, UiKit.PALE, MATERIAL_SIZE, 24.0, true)
	_material_row.alignment = BoxContainer.ALIGNMENT_CENTER
	_material_row.number.add_theme_font_size_override(&"font_size", MATERIAL_SIZE)
	UiKit.shadow(_material_row.number)
	add_child(_material_row)
	_start(&"material")


func _name(b: Boon) -> Label:
	return _named(T.t("boon_" + String(b.id)), UiKit.PALE)


func _named(text: String, col: Color) -> Label:
	var l := UiKit.shadow(UiKit.title(text, NAME_SIZE, col))
	l.add_theme_constant_override(&"outline_size", 6)
	return l


func _start(kind: StringName) -> void:
	showing = kind
	_time = MATERIAL_TIME if kind == &"material" else TIME
	_t = 0.0
	modulate.a = 0.0
	visible = not held
	set_process(true)
	queue_redraw()


## The band of the screen the greeting takes while it shows (its box, with the veil's reach above and below).
func band() -> Rect2:
	return get_global_rect().grow_individual(0.0, VEIL_REACH.y * 0.5, 0.0, VEIL_REACH.y * 0.5)


func _exit_tree() -> void:
	DoorSign.keep_out = Rect2()


## The soft dark veil behind the words: an ellipse fading out from the middle, wider than the words.
func _draw_veil() -> void:
	if _veil == null:
		var g := Gradient.new()
		g.set_color(0, Color(0.01, 0.0, 0.02, VEIL_ALPHA))
		g.set_color(1, Color(0.01, 0.0, 0.02, 0.0))
		g.add_point(0.55, Color(0.01, 0.0, 0.02, VEIL_ALPHA * 0.75))
		_veil = GradientTexture2D.new()
		_veil.gradient = g
		_veil.fill = GradientTexture2D.FILL_RADIAL
		_veil.fill_from = Vector2(0.5, 0.5)
		_veil.fill_to = Vector2(1.0, 0.5)
		_veil.width = 128
		_veil.height = 64
	var words := get_combined_minimum_size()
	var w := maxf(words.x, 120.0) + VEIL_REACH.x * 2.0
	var h := words.y + VEIL_REACH.y * 2.0
	draw_texture_rect(_veil, Rect2(Vector2((size.x - w) * 0.5, (size.y - h) * 0.5), Vector2(w, h)), false)


func _process(delta: float) -> void:
	if held:
		DoorSign.keep_out = Rect2()
		return
	_t += delta
	modulate.a = minf(clampf(_t / FADE_IN, 0.0, 1.0), clampf((_time - _t) / FADE_OUT, 0.0, 1.0))
	# the signs of the world keep out of the band the greeting stands in, its veil's reach included (P1-1)
	DoorSign.keep_out = band()
	if _link:
		_link.progress = ease(clampf((_t - FADE_IN * 0.5) / CLOSE, 0.0, 1.0), 0.5)
	if _icon:
		_icon.scale = Vector2.ONE * lerpf(0.7, 1.0, ease(clampf(_t / (FADE_IN * 2.0), 0.0, 1.0), 0.4))
		_icon.pivot_offset = _icon.size * 0.5
	if _t >= _time:
		visible = false
		showing = &""
		DoorSign.keep_out = Rect2()
		set_process(false)
		if not _queue.is_empty():
			_queue.pop_front().call()
