extends SceneTree
## The title menu over the raw reference painting (painted buttons still there), to check that the real buttons cover
## them exactly, before and apart from the real backdrop.
## tools/gpu.sh run --rendering-driver vulkan --resolution 1280x720 -s tools/title_menu_lab.gd -- C:/x/menu.png 2 [options]
## Options: --focus=N (keyboard focus with the ring on button N, 0 to 3), --hover=N (mouse over button N),
## --press=N (held down), --grey (disabled look), --noquit, --nofocus (Iniciar at rest), --black (no painting: to measure the buttons alone),
## --noglow (frames alone, to measure), --bare (painting alone), --intro (plays the entrance; the capture time is counted from its start).

const ART := "res://assets/ui/title/title_screen_reference.png"
const MENU := "res://scripts/ui/title_menu.gd"


## Stand-in for TitleBackdrop: the same contract (contain, centred), nothing else.
class Stub:
	extends Control
	signal layout_changed
	const ART_SIZE := Vector2(1672, 941)
	var picture := TextureRect.new()

	func _init() -> void:
		set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		picture.stretch_mode = TextureRect.STRETCH_SCALE
		picture.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
		add_child(picture)
		resized.connect(_fit)

	func art_scale() -> float:
		return minf(size.x / ART_SIZE.x, size.y / ART_SIZE.y)

	func art_rect() -> Rect2:
		var s := (ART_SIZE * art_scale()).ceil()
		return Rect2(((size - s) * 0.5).floor(), s)

	func to_local_point(p_img: Vector2) -> Vector2:
		return art_rect().position + p_img * art_scale()

	func _fit() -> void:
		picture.position = art_rect().position
		picture.size = art_rect().size
		layout_changed.emit()


var _out := "menu.png"
var _wait := 2.0
var _opts: Dictionary[String, String] = {}


func _initialize() -> void:
	create_timer(40.0).timeout.connect(quit)
	var plain: Array[String] = []
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--"):
			var kv := a.trim_prefix("--").split("=")
			_opts[kv[0]] = kv[1] if kv.size() > 1 else ""
		else:
			plain.append(a)
	if plain.size() > 0:
		_out = plain[0]
	if plain.size() > 1:
		_wait = plain[1].to_float()
	_run.call_deferred()


func _run() -> void:
	var bg := ColorRect.new()
	bg.color = Color.BLACK if _opts.has("black") else Color("0b0d1c")
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(bg)
	var stub := Stub.new()
	if not _opts.has("black"):
		stub.picture.texture = load(ART)
	root.add_child(stub)
	stub._fit()
	# untyped on purpose: a -s script compiles before the autoloads exist, so it cannot name the game's classes
	var menu: Control = (load(MENU) as Script).new()
	root.add_child(menu)
	menu.call(&"setup", stub)
	menu.visible = not _opts.has("bare")
	if _opts.has("noquit"):
		menu.call(&"set_quit_visible", false)
	if not _opts.has("nofocus"):
		menu.call(&"focus_first")
	if _opts.has("intro"):
		menu.call(&"intro")
	await process_frame
	var buttons: Array = menu.get(&"buttons")
	if _opts.has("focus"):
		# real key presses: the ring only shows after navigation
		for i in _opts["focus"].to_int():
			_key(&"ui_down")
			await process_frame
		if _opts["focus"].to_int() == 0:
			_key(&"ui_up")
	if _opts.has("hover"):
		var b: Control = buttons[_opts["hover"].to_int()]
		var motion := InputEventMouseMotion.new()
		motion.position = b.get_global_rect().get_center()
		motion.global_position = motion.position
		root.push_input(motion)
	if _opts.has("press"):
		var held: BaseButton = buttons[_opts["press"].to_int()]
		held.toggle_mode = true
		held.set_pressed_no_signal(true)
	if _opts.has("noglow"):
		for b: Control in buttons:
			b.get_child(0).scale = Vector2.ZERO
	if _opts.has("grey"):
		menu.call(&"set_enabled", false, true)
	await create_timer(_wait).timeout
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(_out)
	var first: Control = buttons[0]
	print("LAB saved ", _out, " window ", root.size, " logical ", menu.size, " scale ", menu.call(&"art_scale"),
		" start at ", first.position, " size ", first.size)
	quit()


func _key(action: StringName) -> void:
	for down: bool in [true, false]:
		var ev := InputEventKey.new()
		ev.keycode = KEY_DOWN if action == &"ui_down" else KEY_UP
		ev.physical_keycode = ev.keycode
		ev.pressed = down
		Input.parse_input_event(ev)
