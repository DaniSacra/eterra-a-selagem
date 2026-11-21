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
## A rank of the Forja was bought at the Forjador (Rejogabilidade, Fatia 1; ForgeRank.id): the forge and the Emeth may
## show it (environment-artist, technical-artist), the save is already written.
signal forged(rank: StringName)
## Ofícios: the pick restored (&"restore") or the Vendedor's order delivered (&"deliver").
signal oficio_done(what: StringName)

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
## Seconds since he came up the stairs (-1: placed by --hero-at; HubPlan.near_want_at).
var arrived := 0.0
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
		arrived = -1.0
	add_child(player)
	_show_forge()
	camera = Camera3D.new()
	add_child(camera)
	camera.make_current()
	cam = CamRig.new(camera, arena, player)
	cam.snap()
	_arrival_look()
	if not cam.holds() and arrived >= 0.0:
		# the near camera starts on the far one's point: the portal in the frame as he comes up (P1-A2)
		var p := HubPlan.near_want_at(player.pos, 0.0)
		cam.target = Vector3(p.x, 0, p.y)
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
	# the place's name on arriving and a faint name over every station (UI review d2ff05d, P1-8)
	add_child(HubLabels.new().setup(self))
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
	if arrived >= 0.0:
		arrived += dt
	_arrival_look()
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
		# F7 flips the visual style and keeps it in the options, as the options screen does (DT-RS2)
		Save.choose_look(VisualProfile.Look.CLASSIC if VisualProfile.stylized() else VisualProfile.Look.STYLIZED)
		arena.restyle()
	# at a station the camera leans to show it whole (the Portal's head, the forge), his safe frame first (HUB-D)
	cam.lean = lean()
	cam.follow(delta, Vector3.ZERO)
	Controls.flush()


func _exit_tree() -> void:
	Controls.virtual = null


## HV-B: for HubPlan.ARRIVAL_LOOK seconds after he comes up the Retorno both cameras look from
## HubPlan.ARRIVAL_DISTANCE and keep him HubPlan.ARRIVAL_SAFE inside the screen (the portal's arch whole from the
## south-east seal), then ease back in HubPlan.ARRIVAL_EASE to their own distance and the 18% (CamRig.wide, safe).
func _arrival_look() -> void:
	var k := HubPlan.arrival_share(arrived)
	cam.wide = k
	cam.wide_distance = HubPlan.ARRIVAL_DISTANCE
	cam.safe = lerpf(CamFrame.SAFE, HubPlan.ARRIVAL_SAFE, k)


## The floor point the camera leans to while a station is in focus (HubPlan.frame_for; INF: none, the far camera's
## own point): from where it would look without one, as little as it takes to bring the station's SHOW point inside
## the screen. The near camera always leans: on him, never south of HubPlan.NEAR_SOUTH (art review H-P0-2), and for
## its first HubPlan.ARRIVAL_LOOK seconds on the far camera's point (the portal in the frame, P1-A2).
func lean() -> Vector2:
	if focus.current == &"" and cam.holds():
		return Vector2.INF
	var view := get_viewport().get_visible_rect().size
	var d := cam.dist()
	# the near camera follows him, but never looks south of the hub's NEAR_SOUTH (art review H-P0-2)
	var from := cam.look_at(arena.cam_target if cam.holds() else HubPlan.near_want_at(player.pos, arrived), d, camera.fov)
	if focus.current == &"":
		return from
	return HubPlan.frame_for(focus.current, from, d, Dev.num("cam-pitch", Feel.live().cam_pitch), CamRig.yaw(), camera.fov,
		view.x / maxf(view.y, 1.0))


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
	# its light a step brighter and a thread of gold round its slab (HubLook.focus)
	if arena.look is HubLook:
		(arena.look as HubLook).focus(id)
	if id == &"":
		return
	station_sign = StationSign.make(id, T.t("hub_" + id), T.t(station_line(id)))
	# HV-D (hv_santuario_vigilia_art.md 6.3): no sign floating over the station; it hangs at the foot of the thing used
	# (the anchor brought down to the floor), as the rewards' and the doors' in a run (StationSign.under)
	station_sign.position = HubPlan.anchor(id) * Vector3(1.0, 0.0, 1.0)
	station_sign.under = true
	station_sign.hero_at = Vector3(player.pos.x, 0.0, player.pos.y)
	station_sign.pressed.connect(func() -> void:
		if focus.current == id:
			use(id))
	add_child(station_sign)


## The text key of a station's short line (the Vendedor and the Forjador: still to be defined).
static func station_line(id: StringName) -> StringName:
	# Ofícios: the Vendedor's order open, or the Forjador's pick asked for, say so on the sign
	if id == HubPlan.VENDOR and Oficios.order_state(Save.data, OficiosDef.live()) == Oficios.Order.OPEN:
		return &"oficio_has_order"
	if id == HubPlan.SMITH and Oficios.noted(Save.data) and not Oficios.has_tool(Save.data, OficiosDef.live()):
		return &"oficio_has_order"
	match id:
		HubPlan.VENDOR:
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
		HubPlan.SMITH:
			_use_smith()
		HubPlan.VENDOR:
			_use_vendor()


## Ofícios, Roteiro A: the Forjador opens the Forja; once a vein was noted it has the Oficina's bookmark (the
## ui-ux-designer's ForgeScreen), open first while the Picareta waits to be restored.
func _use_smith() -> void:
	_open_forge()


## The Vendedor: closed until the first Pedra Funda; then its order (2 Pedra Funda and 30 Prata); delivered, the first
## Obra (the angels' preview).
func _use_vendor() -> void:
	var d := OficiosDef.live()
	var state := Oficios.order_state(Save.data, d)
	if state == Oficios.Order.LOCKED:
		host.open(HubPanel.new(), [T.t("hub_vendor"), T.t(&"hub_vendor_soon"), [[&"back", T.t(&"back")]],
			SealedMark.new().setup(MARK), T.t(&"hub_soon")])
		return
	if state == Oficios.Order.DONE:
		# Fatia 3: the order delivered opens the stall (ui-ux-designer, VendorScreen: the Obras and the trades)
		var v := VendorScreen.new()
		if host.open(v, [Save.data]):
			v.built.connect(func(_id: StringName) -> void: labels_changed())
			v.traded.connect(func(_i: int) -> void: labels_changed())
		return
	# the order's sheet (ui-ux-designer, OficioSheets: what it asks for with marks and numbers, Entregar only when all
	# is there), the same leaf once delivered
	var p := HubPanel.new()
	host.open(p, OficioSheets.order(Save.data, d))
	p.chosen.connect(func(choice: StringName) -> void:
		if choice == &"deliver" and Oficios.deliver(Save.data, d):
			Save.write()
			oficio_done.emit(&"deliver")
			labels_changed())


## The station signs and the purse read the save again (after an Ofício changed it).
func labels_changed() -> void:
	_show_focus()


## The Forja da Emeth at the Forjador (ForgeScreen, a spread of the Livro): each purchase is written and said
## (forged).
func _open_forge() -> void:
	var f := ForgeScreen.new()
	var d := OficiosDef.live()
	var start := ForgeScreen.Tab.WORKSHOP if Oficios.noted(Save.data) and not Oficios.has_tool(Save.data, d) \
			else ForgeScreen.Tab.EMETH
	if host.open(f, [Save.data, start]):
		f.forged.connect(func(rank: StringName) -> void:
			_show_forge()
			forged.emit(rank))
		f.restored.connect(func() -> void:
			oficio_done.emit(&"restore")
			labels_changed())


## G-2: the Forja's rank on the forge (HubLook.set_forge_rank) and on the Emeth in his hand.
func _show_forge() -> void:
	var rank := Forge.temper(Save.data)
	player.set_temper(rank)
	if arena.look is HubLook:
		(arena.look as HubLook).set_forge_rank(rank)


## The Livro de Ahk on a chapter, in its hub form: no way down from the book, the Portal is the way down (UI review
## d2ff05d, P1-4).
func _open_book(chapter: HeroScreen.Chapter) -> void:
	host.open(HeroScreen.new(), [{}, chapter, true])


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
