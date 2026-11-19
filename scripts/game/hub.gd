class_name Hub
extends Node3D
## The hub (HUB-01, HUB-B1; plan in docs/design/hub_spec.md, space in hub_spec_art.md, the code audit in
## hub_audit.md): the safe place between descents, its name provisional ({HUB}, the text hub_name, D-H4). The hero
## walks and runs at peace (Player.peaceful: no blow, special, circle, ultimate nor roll is ever read here), the camera
## holds on the plan's point (CamRig with RoomLayout.cam_target, CamFrame.hold, reach HubPlan.CAM_REACH; Near follows the hero), and one of the five
## stations comes into focus by distance (HubFocus) and shows its one sign (StationSign, HUB-B3: name, a short line,
## the real key that follows the device, never over the hero; hidden while a screen is open). interact (E, A), or a
## click on the sign, uses it: the Portal asks a short confirmation on a leaf of the Livro (HubPanel: "Descer às
## catacumbas?", Descer, Ficar) and goes down as the title's Iniciar used to (the Juramentos first once Morvath was
## sealed, then the run); the Árvore de Dons and the Livro de Ahk open the Livro (HeroScreen) on the Gifts and on the
## Warrior (its Compêndio from there); the Vendedor and the Forjador say honestly, on their own leaf, that they are
## still to be defined (nothing to buy or forge). Esc (pause) opens the hub's menu (PauseMenu.hub: Como Jogar,
## Compêndio, Configurações, Voltar ao título). Its music is its own place in Músicas (MusicCatalog.HUB).
## Every screen is hosted by a ScreenHost (shared with the title), and nothing pressed to close one reaches the hub.
## No HUD of the fight. Nothing here writes the save (the Livro saves its own Gifts, as on the title).
## Run straight into it: ~/tools/godot/godot --path . -- --hub [--hero-at=x,z|<station>] [--hub-use=portal|vendor|tree|smith|book]
## [--hub-menu] [--pad] [--shot=f.png --shot-at=s]

## The station in focus changed (&"": none) and a station was used.
signal focus_changed(id: StringName)
signal used(id: StringName)

## Seconds to black before the run starts.
const FADE := 0.45
## The mark over a station's page (px at 720 lines).
const MARK := 56.0

var air: WorldAir
var arena: Arena
var player: Player
var camera: Camera3D
var cam: CamRig
var ui: CanvasLayer
var host: ScreenHost
var focus: HubFocus
## The sign over the station in focus (null: none).
var station_sign: StationSign
var leaving := false
## The Juramentos were seen on the way down this time (Descer goes on from there).
var _sworn := false
var _fade: ColorRect


func _ready() -> void:
	# the press that brought him here (Iniciar, Voltar ao Santuário) is no interact
	Controls.clear_presses()
	Controls.virtual = null
	Engine.time_scale = 1.0
	air = WorldAir.build(self)
	arena = Arena.new()
	add_child(arena)
	arena.build(HubPlan.layout())
	player = Player.new()
	player.arena = arena
	player.peaceful = true
	player.pos = arena.start
	player.facing = arena.start_facing
	if Dev.has("hero-at"):
		# --hero-at=x,z: where he stands (captures of each station)
		# or --hero-at=<station>: on its use point, wherever the plan puts it
		var at := Dev.arg("hero-at")
		var xz := at.split(",")
		var where := HubPlan.use_point(StringName(at)) if HubPlan.STATIONS.has(StringName(at)) \
			else Vector2(float(xz[0]), float(xz[1]))
		player.pos = arena.resolve(where, Player.RADIUS)
	add_child(player)
	camera = Camera3D.new()
	add_child(camera)
	camera.make_current()
	cam = CamRig.new(camera, arena, player)
	cam.snap()
	cam.place(Vector3.ZERO, 1.0)
	# the host first: a screen's own pages (later in the tree) see Esc before it does
	host = ScreenHost.new()
	add_child(host)
	ui = CanvasLayer.new()
	ui.layer = 5
	add_child(ui)
	host.layer = ui
	# a screen closed (the menu's Configurações may have changed the quality)
	host.closed.connect(func(_s: Control) -> void:
		apply_options()
		# the Configurações may have remapped interact
		if is_instance_valid(station_sign):
			station_sign.refresh())
	_fade = ColorRect.new()
	_fade.color = Color(0, 0, 0, 0)
	_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var fade_layer := CanvasLayer.new()
	fade_layer.layer = 10
	add_child(fade_layer)
	fade_layer.add_child(_fade)
	var points := {}
	for id in HubPlan.STATIONS:
		points[id] = HubPlan.use_point(id)
	focus = HubFocus.new(points)
	apply_options()
	# its own place in Músicas (the title's piece by default: from the title it goes on without a seam)
	Music.play(MusicCatalog.HUB)
	# captures: --hub-use=<station> opens its page, --hub-menu the Esc menu, --pad names the gamepad's buttons
	if Dev.has("pad"):
		Controls.using_pad = true
	if Dev.has("hub-use"):
		use.call_deferred(StringName(Dev.arg("hub-use")))
	elif Dev.has("hub-menu"):
		open_menu.call_deferred()
	if Dev.has("shot"):
		_shot.call_deferred()


## The graphics quality's screen effects (as Game.apply_options; the viewport's part is App.apply_options).
func apply_options() -> void:
	air.apply_quality()
	PaintPass.attach(camera, GraphicsQuality.current(int(Save.option("quality"))))


func _process(delta: float) -> void:
	var dt := minf(delta, 0.05)
	var free := not host.is_open() and not leaving
	player.step(dt, move() if free else Vector2.ZERO, Vector2.ZERO)
	if focus.step(player.pos):
		_show_focus()
	if is_instance_valid(station_sign):
		station_sign.visible = free
		station_sign.hero_at = Vector3(player.pos.x, 0.0, player.pos.y)
	if free:
		if Controls.pressed(&"pause"):
			open_menu()
		elif Controls.pressed(&"interact") and focus.current != &"":
			use(focus.current)
	if Controls.pressed(&"look_toggle"):
		VisualProfile.toggle()
		arena.restyle()
	cam.follow(delta, Vector3.ZERO)
	Controls.flush()


func _exit_tree() -> void:
	Controls.virtual = null


## Where the player pushes, on the floor (keys and sticks turn with the camera; the virtual pad gives floor ways).
func move() -> Vector2:
	var v := Controls.move()
	return v if Controls.virtual != null else Feel.screen_to_floor(v, CamRig.yaw())


## The sign over the station in focus (one at a time): its name, a short line and the real key of interact.
func _show_focus() -> void:
	if is_instance_valid(station_sign):
		station_sign.queue_free()
	station_sign = null
	var id := focus.current
	focus_changed.emit(id)
	if id == &"":
		return
	station_sign = StationSign.make(id, T.t("hub_" + id), T.t(station_line(id)))
	station_sign.position = HubPlan.anchor(id)
	station_sign.hero_at = Vector3(player.pos.x, 0.0, player.pos.y)
	station_sign.pressed.connect(func() -> void:
		if focus.current == id:
			use(id))
	add_child(station_sign)


## The text key of a station's short line (the Vendedor and the Forjador: still to be defined).
static func station_line(id: StringName) -> StringName:
	match id:
		HubPlan.VENDOR, HubPlan.SMITH:
			return &"hub_soon"
	return StringName("hub_%s_desc" % id)


## Uses a station (interact on it in focus).
func use(id: StringName) -> void:
	if host.is_open() or leaving:
		return
	used.emit(id)
	match id:
		HubPlan.PORTAL:
			var p := HubPanel.new()
			host.open(p, [T.t(&"hub_descend_title"), T.t(&"hub_descend_line"),
				[[&"go", T.t(&"hub_descend_go")], [&"stay", T.t(&"hub_descend_stay")]], HowToScreen.step_glyph(0, MARK)])
			p.chosen.connect(func(choice: StringName) -> void:
				if choice == &"go":
					descend.call_deferred())
		HubPlan.TREE:
			_open_book(HeroScreen.Chapter.GIFTS)
		HubPlan.BOOK:
			_open_book(HeroScreen.Chapter.HERO)
		HubPlan.VENDOR, HubPlan.SMITH:
			host.open(HubPanel.new(), [T.t("hub_" + id), T.t("hub_%s_soon" % id), [[&"back", T.t(&"back")]],
				SealedMark.new().setup(MARK), T.t(&"hub_soon")])


## The Livro de Ahk on a chapter; its way down goes through the Portal's (descend).
func _open_book(chapter: HeroScreen.Chapter) -> void:
	var screen := HeroScreen.new()
	host.open(screen, [{}, chapter])
	screen.descend.connect(func() -> void:
		host.close()
		descend())


## The hub's Esc menu (PauseMenu in its hub form).
func open_menu() -> void:
	var p := PauseMenu.new()
	p.hub = true
	host.open(p, [], &"resumed")


## Down to the catacombs, as the title's Iniciar used to (boot._start before HUB-B1): once Morvath was sealed the
## Juramentos first (their Descer goes on from here, Voltar or Esc back to the hub), then the run.
func descend() -> void:
	if leaving:
		return
	if not _sworn and Juramentos.unlocked(Save.data):
		var screen := JuramentoScreen.new()
		host.open(screen, [true])
		screen.descend.connect(func() -> void:
			_sworn = true
			host.close()
			descend())
		return
	leaving = true
	if is_instance_valid(station_sign):
		station_sign.queue_free()
	await create_tween().tween_property(_fade, ^"color:a", 1.0, FADE).finished
	SceneGo.to(get_tree(), SceneGo.GAME)


## --shot=file.png: saves what the player sees after --shot-at seconds, then quits.
func _shot() -> void:
	await get_tree().create_timer(Dev.num("shot-at", 1.0)).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(Dev.arg("shot"))
	get_tree().quit()
