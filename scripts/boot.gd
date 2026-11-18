extends Node
## Title screen: Daniel's cinematic art (TitleBackdrop: the painting contained, mist, motes) with the real menu over
## the painted one (TitleMenu). Iniciar starts the run; O Guerreiro (HeroScreen), Como Jogar and Configurações open
## their panels over the art.
## Test switches that ask for a run (--bot, --shot, --smoke, --start, --stress) skip straight to it;
## Once Morvath was sealed once, Iniciar first shows the Juramentos (JuramentoScreen, E6) with "Descer".
## --title --screen=options|music|moves|howto|hero|gifts|book|codex|juramentos|map opens a panel at once (hero, gifts and
## book: the Livro de Ahk on the Warrior, the Gifts or the opening). --hero-xp=N and --hero-equip=a,b set the
## Warrior's Mastery and Gifts for captures, in Save.data (Save.gd).

const GAME := "res://scenes/game.tscn"
## Seconds to black before the run starts, and before quitting.
const START_FADE := 0.45
const QUIT_FADE := 0.25
const MENU_FADE := 0.2

var _backdrop: TitleBackdrop
var _menu: TitleMenu
var _sub: Control
## The button that opened the panel on screen, to give the focus back to it.
var _opener: TitleButton
var _leaving := false
## The Juramentos were seen on the way down (Iniciar goes on from there).
var _sworn := false


func _ready() -> void:
	App.apply_options()
	for key: String in ["bot", "smoke", "start", "stress", "play"]:
		if Dev.has(key):
			get_tree().change_scene_to_file.call_deferred(GAME)
			return
	if Dev.has("shot") and not Dev.has("title"):
		get_tree().change_scene_to_file.call_deferred(GAME)
		return
	_build()
	match Dev.arg("screen"):
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


func _build() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
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


func _start() -> void:
	if _leaving:
		return
	if not _sworn and Juramentos.unlocked(Save.data):
		_open_juramentos(true)
		return
	_leaving = true
	_menu.set_enabled(false)
	create_tween().tween_property(_menu, ^"modulate:a", 0.0, START_FADE)
	await _backdrop.fade_out(START_FADE)
	get_tree().change_scene_to_file(GAME)


## The Juramentos before going down (E6): "Descer" goes on into the run, Voltar (or Esc) back to the title.
func _open_juramentos(with_descend: bool) -> void:
	var screen := JuramentoScreen.new()
	_open(screen, TitleButton.Kind.START, [with_descend])
	screen.descend.connect(func() -> void:
		_sworn = true
		_close_sub()
		_start())


## The Livro de Ahk (O Guerreiro), open on a chapter; its way down starts the descent as Iniciar does.
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
		return
	_menu.finish_intro()
	_menu.set_enabled(true)
	_opener = _menu.button(opener)
	_menu.visible = false
	_backdrop.dim(true)
	_sub = screen
	_menu.get_parent().add_child(screen)
	screen.callv(&"open", args)
	screen.connect(&"closed", _close_sub)


func _close_sub() -> void:
	if _sub:
		_sub.queue_free()
		_sub = null
	_backdrop.dim(false)
	_menu.visible = true
	if _opener:
		_opener.grab_focus()
	else:
		_menu.focus_first()


func _unhandled_input(event: InputEvent) -> void:
	if _menu == null:
		# a test switch is on its way to the run: there is no menu
		return
	if _sub and event.is_action_pressed(&"ui_cancel"):
		get_viewport().set_input_as_handled()
		_close_sub()
	elif not _sub and not _leaving and event.is_pressed() and not event.is_echo():
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
