class_name PauseMenu
extends Control
## Pause (art pack board 06): the run stays frozen behind, darkened only on the left, where a compact panel stands:
## "Pausa" over a gold rule, Continuar as the main action, then Bênçãos (the panel of the gifts held, BoonsScreen),
## Compêndio (CodexScreen) and Configurações (OptionsScreen, with Músicas), the gifts of the descent in small
## medallions, and the ways out at the foot in quiet links: Sair para o menu and, on the desktop, Sair do jogo.
## The focus walks that order with up and down and wraps at both ends; a page opened from here gives the focus back to
## the button that opened it.
## HUB-B1: Sair para o menu goes to the hub (scenes/hub.tscn); in the hub (hub true) the same panel is its Esc menu,
## titled with the place's name, without the descent's Bênçãos and medallions, with Como Jogar (the title's, as
## the hub stands between descents), its way out Voltar ao título. In the hub it is a leaf of the Livro (UI review
## d2ff05d, P2-8: everything else in the Santuário is paper): BookSpread single, the paper's buttons, the title in rubric.

signal resumed

## The panel's width and its distance from the left edge, in pixels at 720 lines.
const WIDTH := 300.0
const LEFT := 56.0
## The gifts held: medallion size and how many before "+N".
const ICON := 26.0
const ICONS_MAX := 15
## The shade over the frozen run: darkest behind the panel, light on the right so the fight still reads.
const SHADE_LEFT := 0.8
const SHADE_MID := 0.42
const SHADE_RIGHT := 0.14

## The keys at the foot (benchmark P0-2).
var bar: ActionBar
var _main: Control
var _sub: Control
## The button that opened the page on show (the focus goes back to it).
var _from: Control
## The panel's buttons in focus order.
var buttons: Array[Button] = []
## The hub's Esc menu (set before open).
var hub := false


func open() -> void:
	theme = Book.theme() if hub else UiKit.theme()
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_main = Control.new()
	_main.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_main)
	_main.add_child(_shade())
	var rail := VBoxContainer.new()
	rail.anchor_bottom = 1.0
	rail.offset_left = LEFT
	rail.offset_right = LEFT + WIDTH
	rail.alignment = BoxContainer.ALIGNMENT_CENTER
	_main.add_child(rail)
	var v := VBoxContainer.new()
	v.add_theme_constant_override(&"separation", 9)
	if hub:
		var leaf := BookSpread.new().setup(0.62, true)
		leaf.name = "panel"
		rail.add_child(leaf)
		v.custom_minimum_size.x = WIDTH - 40.0
		leaf.left.add_child(v)
		var head := Book.heading(T.t(&"hub_name"), 34, WIDTH * 0.72)
		(head.get_node("text") as Label).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		(head.get_child(1) as Control).size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		v.add_child(head)
	else:
		var panel := PanelContainer.new()
		panel.name = "panel"
		panel.add_theme_stylebox_override(&"panel", UiKit.frame_box(20))
		UiKit.crown(panel)
		rail.add_child(panel)
		panel.add_child(v)
		v.add_child(UiKit.header(T.t(&"pause_title"), 40, WIDTH * 0.72))
	var go_on := _button(v, "continue", T.t(&"pause_continue"), func() -> void: resumed.emit())
	# the keys at the foot (benchmark P0-2), on the menu's own layer: a page opened over it hides it (_main)
	bar = ActionBar.attach(_main, [ActionBar.entry(&"ui_accept", T.t(&"bar_confirm"), _press_focus),
		ActionBar.entry(&"ui_cancel", T.t(&"bar_continue"), func() -> void: resumed.emit())])
	if hub:
		Book.primary(go_on)
	else:
		UiKit.primary(go_on)
	go_on.add_theme_font_size_override(&"font_size", 24)
	if not hub:
		var boons := _button(v, "boons", T.t(&"pause_boons"), Callable())
		boons.pressed.connect(func() -> void: _show(_boons_screen(), boons))
	else:
		# the hub took the title's place between descents: its Como Jogar too (HUB-C)
		var howto := _button(v, "howto", T.t(&"title_howto"), Callable())
		howto.pressed.connect(func() -> void: _show(HowToScreen.new(), howto))
	var codex := _button(v, "codex", T.t(&"pause_moves"), Callable())
	codex.pressed.connect(func() -> void: _show(CodexScreen.new(), codex))
	var options := _button(v, "options", T.t(&"pause_options"), Callable())
	options.pressed.connect(func() -> void: _show(OptionsScreen.new(), options))
	_carried(v)
	var rule := GoldRule.new()
	if hub:
		rule.tint = Book.GILT
	rule.custom_minimum_size = Vector2(WIDTH * 0.6, 12)
	rule.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	v.add_child(rule)
	var foot := UiKit.foot(6)
	v.add_child(foot)
	# SW-O4 (D-O2 b): in the guided first descent a player who knows the game can skip it (asks first)
	if not hub and Objective.tutorial():
		var skip := _link(T.t(&"pause_skip_first"), _ask_skip)
		skip.name = "skip_first"
		foot.add_child(skip)
		buttons.append(skip)
	var quit := _link(T.t(&"hub_to_title" if hub else &"pause_quit"), func() -> void:
		SceneGo.to(get_tree(), SceneGo.TITLE if hub else SceneGo.HUB))
	quit.name = "quit"
	foot.add_child(quit)
	buttons.append(quit)
	# leave the game from the pause too (desktop only: phones and the browser close by themselves)
	if not OS.has_feature("mobile") and not OS.has_feature("web"):
		var leave := _link(T.t(&"pause_exit_game"), func() -> void: get_tree().quit())
		leave.name = "exit_game"
		foot.add_child(leave)
		buttons.append(leave)
	_chain()
	go_on.grab_focus.call_deferred()


## The question before skipping the first descent: its own page over the panel, "Voltar" in focus; "Pular" marks the save
## (FirstTips.mark_skipped, written unless the run is a capture without a save) and goes to the Santuário.
func _ask_skip() -> void:
	if _sub != null:
		return
	var from := get_viewport().gui_get_focus_owner()
	var q := AskPage.new().setup(T.t(&"pause_skip_first"), T.t(&"pause_skip_confirm"), T.t(&"pause_skip_yes"), T.t(&"pause_skip_no"))
	_main.visible = false
	_sub = q
	add_child(q)
	q.answered.connect(func(yes: bool) -> void:
		if yes:
			skip_first()
			return
		q.queue_free()
		_sub = null
		_main.visible = true
		if from is Control and is_instance_valid(from):
			(from as Control).grab_focus())


## Skips the first descent for good: the save says so and the player goes to the Santuário.
func skip_first() -> void:
	FirstTips.mark_skipped(Save.data)
	if Save.enabled:
		Save.write()
	SceneGo.to(get_tree(), SceneGo.HUB)


## A quiet way out at the foot: a link on the ink panel, a small paper button on the hub's leaf.
func _link(text: String, on_press: Callable) -> Button:
	if not hub:
		return UiKit.link(text, on_press)
	var b := Book.button(text, on_press, 0.0)
	b.add_theme_font_size_override(&"font_size", 16)
	return b


## A button of the panel's column, as wide as the panel, in the focus order.
func _button(parent: Control, id: String, text: String, on_press: Callable) -> Button:
	var b := Book.button(text, on_press, 0.0) if hub else UiKit.button(text, on_press, 0.0)
	b.name = id
	b.custom_minimum_size.y = 46
	parent.add_child(b)
	buttons.append(b)
	return b


## Up and down walk the buttons in order and wrap; the Tab key too.
func _chain() -> void:
	var n := buttons.size()
	for i in n:
		var b := buttons[i]
		var next := buttons[(i + 1) % n]
		var prev := buttons[(i - 1 + n) % n]
		b.focus_neighbor_bottom = b.get_path_to(next)
		b.focus_neighbor_top = b.get_path_to(prev)
		b.focus_next = b.get_path_to(next)
		b.focus_previous = b.get_path_to(prev)
		if b.get_parent().name != &"foot":
			# the column's buttons stay in the column
			b.focus_neighbor_left = b.get_path_to(b)
			b.focus_neighbor_right = b.get_path_to(b)


## The gifts of the descent under the buttons (none held: nothing).
func _carried(parent: Control) -> void:
	if hub:
		return
	var game := _game()
	var carried := UiKit.carried_of(game.boons if game else null)
	if carried.is_empty():
		return
	parent.add_child(UiKit.section(T.t(&"pause_carried", {"n": carried.size()}), UiKit.OLD_GOLD.lightened(0.35), 14))
	var flow := HFlowContainer.new()
	flow.name = "carried"
	flow.add_theme_constant_override(&"h_separation", 4)
	flow.add_theme_constant_override(&"v_separation", 4)
	flow.alignment = FlowContainer.ALIGNMENT_CENTER
	flow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(flow)
	UiKit.gift_icons(flow, carried, ICON, ICONS_MAX)


func _shade() -> TextureRect:
	var g := Gradient.new()
	g.offsets = PackedFloat32Array([0.0, 0.42, 1.0])
	g.colors = PackedColorArray([Color(0.01, 0.0, 0.02, SHADE_LEFT), Color(0.01, 0.0, 0.02, SHADE_MID),
			Color(0.01, 0.0, 0.02, SHADE_RIGHT)])
	var tex := GradientTexture2D.new()
	tex.gradient = g
	tex.width = 256
	tex.height = 4
	var shade := TextureRect.new()
	shade.name = "shade"
	shade.texture = tex
	shade.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	shade.stretch_mode = TextureRect.STRETCH_SCALE
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	return shade


## The run this pause belongs to (the Game above it), or null.
func _game() -> Game:
	var n := get_parent()
	while n != null and not n is Game:
		n = n.get_parent()
	return n as Game


## The gifts panel, with the gifts of the run this pause belongs to.
func _boons_screen() -> BoonsScreen:
	var screen := BoonsScreen.new()
	var game := _game()
	if game != null:
		screen.state = game.boons
	return screen


## A page over the pause; from: the button to give the focus back to when it closes.
func _show(screen: Control, from: Control = null) -> void:
	_main.visible = false
	_sub = screen
	_from = from if from else buttons[1]
	add_child(screen)
	screen.call(&"open")
	screen.connect(&"closed", func() -> void:
		_sub.queue_free()
		_sub = null
		_main.visible = true
		if is_instance_valid(_from):
			_from.grab_focus())


## The button in focus pressed (the action bar's click).
func _press_focus() -> void:
	var f := get_viewport().gui_get_focus_owner() as BaseButton
	if f != null and is_ancestor_of(f) and not f.disabled:
		f.pressed.emit()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"pause") or event.is_action_pressed(&"ui_cancel"):
		get_viewport().set_input_as_handled()
		if _sub:
			_sub.emit_signal(&"closed")
		else:
			resumed.emit()
