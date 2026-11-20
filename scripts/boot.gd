extends Node
## Title screen: Daniel's cinematic art (TitleBackdrop: the painting contained, mist, motes) with the real menu over
## the painted one (TitleMenu). Iniciar goes to the hub (HUB-01, D-H5; scenes/hub.tscn, where the Portal starts the
## descent, with the Juramentos first once Morvath was sealed); O Guerreiro (HeroScreen), Como Jogar and Configurações
## open their panels over the art, hosted by a ScreenHost (shared with the hub).
## Test switches that ask for a run (--bot, --shot, --smoke, --start, --stress, --play) skip straight to it, past the
## title and the hub; --hub goes straight to the hub (with --shot too).
## --title --screen=options|music|moves|howto|hero|gifts|book|codex|juramentos|map opens a panel at once (hero, gifts and
## book: the Livro de Ahk on the Warrior, the Gifts or the opening). --hero-xp=N and --hero-equip=a,b set the
## Warrior's Mastery and Gifts for captures, in Save.data (Save.gd).
## Save slots (the Daniel, 2026-11-19): the first screen of a session is the choice of save (SaveSlotScreen) over the
## dimmed title art; the title's menu comes after it. "Save N · Trocar de save" in the lower left corner (or Esc and B
## on the title) opens it again. Never with --nosave, --slot=N or --title (captures), unless --screen=slots.

const GAME := SceneGo.GAME
const HUB := SceneGo.HUB
## Seconds to black before the run starts, and before quitting.
const START_FADE := 0.45
const QUIT_FADE := 0.25
const MENU_FADE := 0.2

var _backdrop: TitleBackdrop
var _menu: TitleMenu
var _host: ScreenHost
## The panel on show (null: none; the ScreenHost's).
var _sub: Control:
	get:
		return _host.screen if _host != null and _host.is_open() else null
## The button that opened the panel on screen, to give the focus back to it.
var _opener: TitleButton
var _leaving := false
## "Save N · Trocar de save" in the lower left corner of the title.
var _switch: Button


func _ready() -> void:
	App.apply_options()
	var skip := route()
	if skip != "":
		(func() -> void: SceneGo.to(get_tree(), skip)).call_deferred()
		return
	_build()
	if wants_slots():
		_open_slots(false)
	match Dev.arg("screen"):
		"slots":
			_open_slots(Save.chosen)
		"options":
			_open(OptionsScreen.new(), TitleButton.Kind.SETTINGS)
		"music":
			_open(MusicRoomScreen.new(), TitleButton.Kind.SETTINGS)
		"moves":
			_open(CodexScreen.new(), TitleButton.Kind.HOWTO, [CodexScreen.Tab.MOVES])
		"codex":
			_open(CodexScreen.new(), TitleButton.Kind.HOWTO)
		"hero":
			_open_hero(HeroScreen.Chapter.HERO)
		"gifts":
			_open_hero(HeroScreen.Chapter.GIFTS)
		"book":
			_open_hero(HeroScreen.Chapter.OPENING)
		"howto":
			_open(HowToScreen.new(), TitleButton.Kind.HOWTO)
		"juramentos":
			_open_juramentos(Juramentos.unlocked(Save.data))
		"map":
			# the descent's map over a fixed sample descent (MapSample; --map-at=start|middle|doors)
			_open(MapScreen.new(), TitleButton.Kind.HOWTO, [DescentMap.from_dict(MapSample.at(Dev.arg("map-at", "doors")))])
	if Dev.has("shot"):
		_shot.call_deferred()


## Where the command line sends the game past the title ("": the title): a run for the test switches (--bot,
## --smoke, --start, --stress, --play, and --shot without --title), past the hub too; the hub for --hub.
static func route() -> String:
	for key: String in ["bot", "smoke", "start", "stress", "play"]:
		if Dev.has(key):
			return GAME
	if Dev.has("title"):
		return ""
	if Dev.has("hub"):
		return HUB
	return GAME if Dev.has("shot") else ""


## Whether the title opens on the choice of save: the first time in a session, with a save (not --nosave, --slot=N nor
## the captures' --title).
static func wants_slots() -> bool:
	return Save.enabled and not Save.chosen and not Dev.has("title")


func _build() -> void:
	# the host first: a panel's own pages (later in the tree) see Esc before it does
	_host = ScreenHost.new()
	add_child(_host)
	var layer := CanvasLayer.new()
	add_child(layer)
	_host.layer = layer
	_host.closed.connect(func(_s: Control) -> void: _closed_sub())
	_backdrop = TitleBackdrop.new()
	layer.add_child(_backdrop)
	_menu = TitleMenu.new()
	_menu.theme = UiKit.theme()
	layer.add_child(_menu)
	_menu.setup(_backdrop)
	# a browser tab or a phone app cannot be closed from inside: no Sair there
	_menu.set_quit_visible(not OS.has_feature("web") and not OS.has_feature("mobile"))
	_menu.start_pressed.connect(_start)
	_menu.hero_pressed.connect(_open_hero.bind(HeroScreen.Chapter.HERO))
	_menu.howto_pressed.connect(func() -> void: _open(HowToScreen.new(), TitleButton.Kind.HOWTO))
	_menu.settings_pressed.connect(func() -> void: _open(OptionsScreen.new(), TitleButton.Kind.SETTINGS))
	_menu.quit_pressed.connect(_quit)
	_switch = UiKit.link("", func() -> void: _open_slots(true))
	_switch.name = "switch_save"
	_switch.focus_mode = Control.FOCUS_NONE
	# over the painting: a dark edge round the letters, as every text over the art
	_switch.add_theme_constant_override(&"outline_size", 5)
	_switch.add_theme_color_override(&"font_outline_color", Color(UiKit.INK, 0.9))
	_switch.add_theme_color_override(&"font_color", UiKit.PALE.darkened(0.1))
	var corner := Control.new()
	corner.name = "corner"
	corner.mouse_filter = Control.MOUSE_FILTER_IGNORE
	corner.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	corner.theme = UiKit.theme()
	layer.add_child(corner)
	corner.add_child(_switch)
	_switch.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	_switch.grow_vertical = Control.GROW_DIRECTION_BEGIN
	_switch.offset_left = 16
	_switch.offset_bottom = -12
	_switch.offset_top = -12 - 38
	Controls.device_changed.connect(func(_pad: bool) -> void: _name_switch())
	_name_switch()
	# the title's piece as chosen in Músicas (T5; our rooms' walk by default, which the first room goes on with)
	Music.play(&"title")
	if Dev.has("shot"):
		# captures show the screen settled, not halfway through its entrance
		_menu.focus_first()
		return
	_backdrop.fade_in()
	_menu.focus_first()
	_menu.set_enabled(false)
	_menu.intro()
	get_tree().create_timer(0.6).timeout.connect(func() -> void:
		if not _leaving:
			_menu.set_enabled(true))


## The title's corner: which save is in use and how to change it (hidden without a save).
func _name_switch() -> void:
	if not is_instance_valid(_switch):
		return
	# (--save-dir: captures of saves made for them, read only with --nosave)
	_switch.visible = (Save.enabled or Dev.has("save-dir")) and Save.slot > 0 and _menu.visible
	_switch.text = T.t(&"slot_switch", {"n": Save.slot, "key": "B" if Controls.using_pad else "Esc"})


## The choice of save (SaveSlotScreen) over the title art; choosing one puts it in use (Save.use) and gives the title
## back. can_back: Esc and B close it (a save is already in use).
func _open_slots(can_back: bool) -> void:
	if _sub:
		return
	var screen := SaveSlotScreen.new()
	_open(screen, TitleButton.Kind.START, [can_back])
	_switch.visible = false
	screen.chosen.connect(func(n: int) -> void:
		Save.use(n)
		App.apply_options()
		_close_sub())


## Iniciar: to the hub (HUB-01, D-H5), where the Portal starts the descent.
func _start() -> void:
	_leave_to(HUB)


func _leave_to(scene: String) -> void:
	if _leaving:
		return
	_leaving = true
	_menu.set_enabled(false)
	create_tween().tween_property(_menu, ^"modulate:a", 0.0, START_FADE)
	await _backdrop.fade_out(START_FADE)
	SceneGo.to(get_tree(), scene)


## The Juramentos over the title (only --title --screen=juramentos since HUB-B1: the hub's Portal opens them before a
## descent): "Descer" goes into the run, Voltar (or Esc) back to the title.
func _open_juramentos(with_descend: bool) -> void:
	var screen := JuramentoScreen.new()
	_open(screen, TitleButton.Kind.START, [with_descend])
	screen.descend.connect(func() -> void:
		_close_sub()
		_leave_to(GAME))


## The Livro de Ahk (O Guerreiro), open on a chapter; its way down goes where Iniciar goes (the hub).
func _open_hero(chapter: HeroScreen.Chapter) -> void:
	var screen := HeroScreen.new()
	_open(screen, TitleButton.Kind.HERO, [{}, chapter])
	screen.descend.connect(func() -> void:
		_close_sub()
		_start())


func _quit() -> void:
	if _leaving:
		return
	_leaving = true
	_menu.set_enabled(false)
	create_tween().tween_property(_menu, ^"modulate:a", 0.0, QUIT_FADE)
	await _backdrop.fade_out(QUIT_FADE)
	get_tree().quit()


func _open(screen: Control, opener: TitleButton.Kind, args: Array = []) -> void:
	if _sub:
		screen.queue_free()
		return
	_menu.finish_intro()
	_menu.set_enabled(true)
	_opener = _menu.button(opener)
	_menu.visible = false
	_backdrop.dim(true)
	_host.open(screen, args)


## Closes the panel on show (the host gives the menu back: _closed_sub).
func _close_sub() -> void:
	_host.close()


func _closed_sub() -> void:
	_backdrop.dim(false)
	_menu.visible = true
	_name_switch()
	if _opener:
		_opener.grab_focus()
	else:
		_menu.focus_first()


func _unhandled_input(event: InputEvent) -> void:
	if _menu == null:
		# a test switch is on its way to the run: there is no menu
		return
	if not _sub and not _leaving and event.is_action_pressed(&"ui_cancel") and _switch.visible:
		# Esc or B on the title: the choice of save again
		get_viewport().set_input_as_handled()
		_open_slots(true)
		return
	if not _sub and not _leaving and event.is_pressed() and not event.is_echo():
		# any key during the entrance finishes it
		_menu.finish_intro()
		_menu.set_enabled(true)


func _shot() -> void:
	if Dev.has("hover"):
		# --hover=N: the mouse rests on button N (0 Iniciar to 4 Sair), for captures of the hover look
		await get_tree().create_timer(0.3).timeout
		var motion := InputEventMouseMotion.new()
		motion.position = _menu.button(int(Dev.num("hover", 0))).get_global_rect().get_center()
		motion.global_position = motion.position
		get_viewport().push_input(motion)
	await get_tree().create_timer(Dev.num("shot-at", 1.0)).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(Dev.arg("shot"))
	get_tree().quit()
