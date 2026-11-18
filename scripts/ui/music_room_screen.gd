class_name MusicRoomScreen
extends Control
## "Músicas" (T5, the PO's review): every piece the game has (MusicCatalog), to hear and to choose. On the left, where
## each plays (Título, Masmorra, Morvath): "< piece >" steps through the pieces that serve there and saves at once
## (Music.choose). On the right, the list: each piece with Ouvir/Parar (Music.listen, on the Music bus with its layers
## as in the game) and, for a piece with layers, which one: the walk or the fight, Morvath's phase or all of them in
## turn (TOUR seconds each). Leaving goes back to the game's music where it was (Music.resume): the title's new choice
## plays when the title comes back. Opened from Configurações (OptionsScreen); keys, mouse and gamepad.

signal closed

## Seconds of each phase when "Todas as fases" plays.
const TOUR := 20.0
## Level 0 of a piece with phases: all of them in turn.
const ALL := 0
const ROW := 42.0
const LEFT_WIDTH := 340.0
const RIGHT_WIDTH := 780.0
## The name of a piece in the list (one line; the longest, the rooms' recorded pair, is about 410 px at 19).
const NAME_WIDTH := 450.0
const NAME_SIZE := 19
## Room above each place on the left, so each label reads with its own choice.
const PLACE_GAP := 10.0

## Each piece's chosen level in this screen (id -> level; 0 = all phases).
var levels: Dictionary = {}
var _focus_key := ""
var _listen: Dictionary = {}  # id -> its Ouvir/Parar button
var _tour_t := 0.0
var _tour_level := 1


func open() -> void:
	theme = UiKit.theme()
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for id: StringName in MusicCatalog.PIECES:
		levels[id] = ALL if MusicCatalog.layers(id) == 4 else 1
	_focus_key = "place_%s_1" % MusicCatalog.TITLE
	_build()


func _build() -> void:
	for c in get_children():
		remove_child(c)
		c.queue_free()
	_listen.clear()
	var page := UiKit.column(self, LEFT_WIDTH + RIGHT_WIDTH + 40.0, 0.85)
	page.add_theme_constant_override(&"separation", 8)
	page.add_child(UiKit.title(T.t(&"music_room_title"), 40))
	var hint := UiKit.label(T.t(&"music_room_hint"), UiKit.DIM, 18)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	page.add_child(hint)
	var cols := HBoxContainer.new()
	cols.add_theme_constant_override(&"separation", 40)
	cols.alignment = BoxContainer.ALIGNMENT_CENTER
	page.add_child(cols)
	var left := VBoxContainer.new()
	left.custom_minimum_size.x = LEFT_WIDTH
	left.add_theme_constant_override(&"separation", 6)
	cols.add_child(left)
	left.add_child(UiKit.label(T.t(&"music_room_places"), UiKit.GOLD, 24, UiKit.BOLD_FONT))
	for place in MusicCatalog.PLACES:
		var gap := Control.new()
		gap.custom_minimum_size.y = PLACE_GAP
		left.add_child(gap)
		left.add_child(UiKit.label(T.t("music_place_" + place), UiKit.PALE, 20))
		var piece := Music.piece_for(place)
		left.add_child(_stepper("place_" + place, T.t(MusicCatalog.spec(piece).name), LEFT_WIDTH - 2.0 * ROW - 8.0, func(dir: int) -> void:
			Music.choose(place, MusicCatalog.step(place, Music.piece_for(place), dir))))
	var right := VBoxContainer.new()
	right.custom_minimum_size.x = RIGHT_WIDTH
	right.add_theme_constant_override(&"separation", 2)
	cols.add_child(right)
	right.add_child(UiKit.label(T.t(&"music_room_list"), UiKit.GOLD, 24, UiKit.BOLD_FONT))
	for id: StringName in MusicCatalog.PIECES:
		right.add_child(_piece_row(id))
	var back := UiKit.button(T.t(&"back"), func() -> void: closed.emit(), 220)
	back.name = "back"
	back.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	page.add_child(back)
	_refresh()
	_restore_focus.call_deferred()


## A piece in the list: its name, which layer (when it has more than one) and Ouvir/Parar.
func _piece_row(id: StringName) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override(&"separation", 6)
	var l := UiKit.label(T.t(MusicCatalog.spec(id).name), UiKit.PALE, NAME_SIZE)
	l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	l.custom_minimum_size.x = NAME_WIDTH
	l.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	row.add_child(l)
	var n := MusicCatalog.layers(id)
	if n > 1:
		row.add_child(_stepper("level_" + id, level_text(n, int(levels[id])), 130.0, func(dir: int) -> void:
			var count := n + 1 if n == 4 else n
			levels[id] = posmod(int(levels[id]) + dir - (0 if n == 4 else 1), count) + (0 if n == 4 else 1)
			if Music.heard() == id:
				_tour_t = 0.0
				_tour_level = 1
				Music.listen_level(_level_now(id))))
	var b := UiKit.button(T.t(&"music_listen"), func() -> void:
		_focus_key = "listen_" + id
		if Music.heard() == id:
			Music.quiet()
		else:
			_tour_t = 0.0
			_tour_level = 1
			Music.listen(id, _level_now(id))
		_refresh(), 120.0)
	b.name = "listen_" + id
	b.custom_minimum_size.y = ROW
	_listen[id] = b
	row.add_child(b)
	return row


## The level heard now for a piece (all phases: the one the tour is on).
func _level_now(id: StringName) -> int:
	var level := int(levels.get(id, 1))
	return _tour_level if level == ALL else level


## The word for a level: the walk and the fight of the rooms, a phase of Morvath, all phases.
static func level_text(layers: int, level: int) -> String:
	if layers == 2:
		return T.t(&"music_level_walk" if level <= 1 else &"music_level_fight")
	if level == ALL:
		return T.t(&"music_level_all")
	return T.t(&"music_level_phase", {"n": level})


## "< value >": left and right change it (keys, mouse, gamepad), then the screen is built again with the focus kept.
func _stepper(key: String, value: String, width: float, change: Callable) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override(&"separation", 4)
	for dir: int in [-1, 1]:
		var b := UiKit.button("<" if dir < 0 else ">", func() -> void:
			_focus_key = "%s_%d" % [key, dir]
			change.call(dir)
			_build())
		b.name = "%s_%d" % [key, dir]
		b.custom_minimum_size = Vector2(ROW, ROW)
		row.add_child(b)
		if dir < 0:
			var v := UiKit.label(value, UiKit.GOLD, NAME_SIZE, UiKit.BOLD_FONT)
			v.name = key
			v.custom_minimum_size.x = width
			v.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			v.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			row.add_child(v)
	return row


func _restore_focus() -> void:
	var target := find_child(_focus_key, true, false) as Control
	if target == null:
		target = find_child("back", true, false) as Control
	if target:
		target.grab_focus()


## Ouvir or Parar on each piece, from what Music is playing (a theme or the victory ends by itself).
func _refresh() -> void:
	var now := Music.heard()
	for id: StringName in _listen:
		var b: Button = _listen[id]
		b.text = T.t(&"music_stop" if id == now else &"music_listen")


func _process(delta: float) -> void:
	if not is_inside_tree() or _listen.is_empty():
		return
	var now := Music.heard()
	if now != &"" and int(levels.get(now, 1)) == ALL and MusicCatalog.layers(now) == 4:
		_tour_t += delta
		if _tour_t >= TOUR:
			_tour_t = 0.0
			_tour_level = _tour_level % 4 + 1
			Music.listen_level(_tour_level)
	_refresh()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_cancel"):
		get_viewport().set_input_as_handled()
		closed.emit()


func _exit_tree() -> void:
	# back to the game's music (the title's choice, or the room or Morvath where the pause was)
	Music.resume()
