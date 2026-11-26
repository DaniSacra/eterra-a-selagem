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
## sealed, then the run); the Árvore de Dons opens the Gifts medallion (DonsScreen) and the Livro de Ahk the Livro (HeroScreen) on the
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
## PT-5: how close the camera comes to a station that is being explained (share of its own distance), the seconds it
## waits after the arrival look, and how fast the close-up eases in and out.
const GUIDE_ZOOM := 0.9
const GUIDE_DELAY := 0.4
const GUIDE_EASE := 2.2

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
## PT-5: the unlock guide on show (null: none), the share of its close-up on the camera (eased) and the guides of this
## visit that wait for the arrival look to end.
var guide: HubGuideOverlay
var _guide_k := 0.0
var _guide_wait: Array[HubGuideDef] = []


func _ready() -> void:
	HubGate.begin_visit(Save.data)  # SW-O5: the one new thing of this visit, fixed before anything asks what is open
	# the press that brought him here (Iniciar, Voltar ao Santuário) is no interact
	Controls.clear_presses()
	Controls.virtual = null
	Engine.time_scale = 1.0
	air = WorldAir.build(self)
	arena = Arena.new()
	add_child(arena)
	arena.build(HubPlan.layout(Feel.live().cam_yaw, closed_doors()))
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
		evolve()  # (the Livro may have opened a Gift, the Vendedor made an Obra)
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
		if is_open(id):
			points[id] = HubPlan.use_point(id)
	focus = HubFocus.new(points)
	evolve()  # (the closed stations out of the focus and dark)
	# the place's name on arriving and a faint name over every station (UI review d2ff05d, P1-8)
	add_child(HubLabels.new().setup(self))
	_guide_wait = HubGuide.to_show(Save.data)
	_announce()
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
	if Dev.has("smoke"):
		_smoke.call_deferred()


## The graphics quality's screen effects (as Game.apply_options; the viewport's part is App.apply_options).
func apply_options() -> void:
	air.apply_quality()
	PaintPass.attach(camera, GraphicsQuality.current(int(Save.option("quality"))))


func _process(delta: float) -> void:
	var dt := minf(delta, 0.05)
	if arrived >= 0.0:
		arrived += dt
	_arrival_look()
	_guide_tick(dt)
	var free := not host.is_open() and not leaving and guide == null
	player.step(dt, move() if free else Vector2.ZERO, Vector2.ZERO)
	if focus.step(player.pos):
		_show_focus()
	if is_instance_valid(station_sign):
		station_sign.visible = free
		station_sign.hero_at = Vector3(player.pos.x, player.position.y, player.pos.y)
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
	cam.lean_free = guide != null and guide.current != null
	cam.follow(delta, Vector3.ZERO)
	Controls.flush()


func _exit_tree() -> void:
	HubGate.end_visit()
	Controls.virtual = null


## HV-B: for HubPlan.ARRIVAL_LOOK seconds after he comes up the Retorno both cameras look from
## HubPlan.ARRIVAL_DISTANCE and keep him HubPlan.ARRIVAL_SAFE inside the screen (the portal's arch whole from the
## south-east seal), then ease back in HubPlan.ARRIVAL_EASE to their own distance and the 18% (CamRig.wide, safe).
func _arrival_look() -> void:
	var k := HubPlan.arrival_share(arrived)
	cam.wide = k
	cam.wide_distance = HubPlan.ARRIVAL_DISTANCE
	cam.safe = lerpf(CamFrame.SAFE, HubPlan.ARRIVAL_SAFE, k)
	if k <= 0.0 and _guide_k > 0.0:
		# PT-5: the close-up of a station being explained
		cam.wide = _guide_k
		cam.wide_distance = CamRig.distance() * GUIDE_ZOOM


## The floor point the camera leans to while a station is in focus (HubPlan.frame_for; INF: none, the far camera's
## own point): from where it would look without one, as little as it takes to bring the station's SHOW point inside
## the screen. The near camera always leans: on him, never south of HubPlan.NEAR_SOUTH (art review H-P0-2), and for
## its first HubPlan.ARRIVAL_LOOK seconds on the far camera's point (the portal in the frame, P1-A2).
func lean() -> Vector2:
	if guide != null and guide.current != null:
		# PT-5: the camera looks at the station the guide explains (what SHOW says of it), not at the hero
		# the middle of its height in the middle of the screen: a point h over the floor shows where the floor point
		# h / tan(pitch) farther up the screen does (the floor point under the tree's crown left the crown at the top)
		var s: Vector3 = HubPlan.SHOW[guide.current.station]
		s.z += HubPlan.ramp_at(Vector2(s.x, s.y))
		var up := Feel.screen_to_floor(Vector2.UP, CamRig.yaw())
		var pitch := deg_to_rad(Dev.num("cam-pitch", Feel.live().cam_pitch))
		return HubPlan.to_world(Vector2(s.x, s.y)) + up * (s.z * 0.5) / maxf(tan(pitch), 0.2)
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
	if not _tour.is_empty() and Dev.has("bot"):
		return _tour_dir()
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
	# (round 2: at the foot of the thing used, on the level it stands on)
	var foot := HubPlan.anchor(id)
	station_sign.position = Vector3(foot.x, HubPlan.ramp_at(Vector2(HubPlan.ANCHOR[id].x, HubPlan.ANCHOR[id].y)), foot.z)
	station_sign.under = true
	station_sign.hero_at = Vector3(player.pos.x, player.position.y, player.pos.y)
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
	if host.is_open() or leaving or not is_open(id):
		return
	used.emit(id)
	match id:
		HubPlan.PORTAL:
			_open_portal()
		HubPlan.TREE:
			host.open(DonsScreen.new())
		HubPlan.BOOK:
			_open_book(HeroScreen.Chapter.HERO)
		HubPlan.SMITH:
			_use_smith()
		HubPlan.VENDOR:
			_use_vendor()
		HubPlan.VINE:
			_open_vine()
		HubPlan.HEROES:
			_open_heroes()


## The Portal's page: Descer or Ficar, with the line of the hero picked (PT-9: the pick itself is at the Estandarte dos
## Heróis, HeroPickScreen).
func _open_portal() -> void:
	var picked := SaveData.picked_hero(Save.data)
	var p := HubPanel.new()
	host.open(p, [T.t(&"hub_descend_title"), T.t(&"hub_descend_line_" + picked),
		[[&"go", T.t(&"hub_descend_go")], [&"stay", T.t(&"hub_descend_stay")]], HowToScreen.step_glyph(0, MARK)])
	p.chosen.connect(func(choice: StringName) -> void:
		if choice == &"go":
			descend.call_deferred())


## PT-9: the hero's station beside the Vendedor: the pick of the next descent (HeroPickScreen; the Maga locked until
## Morvath was sealed once).
func _open_heroes() -> void:
	var s := HeroPickScreen.new()
	if host.open(s, [Save.data]):
		s.picked.connect(func(_id: String) -> void: labels_changed())


## Ofícios, Roteiro A: the Forjador opens the Forja only (A Videira has its own station since V2); once a vein was noted
## it has the Oficina's bookmark (the ui-ux-designer's ForgeScreen), open first while the Picareta waits to be restored.
func _use_smith() -> void:
	_open_forge()


## V2: A Videira at its own station (VineScreen); a purchase is written and the hub reads the save again (the planting
## grows, VineStation.grown).
func _open_vine() -> void:
	var v := VineScreen.new()
	if host.open(v, [Save.data]):
		v.bought.connect(func(_id: StringName) -> void: labels_changed())


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
	evolve()


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
	player.set_temper(Forge.temper(Save.data))
	evolve()


## HV-E: the hub as the save has grown it (HubEvolution: the forge, the stall, the Gift plates, the Livro's spines and
## shelf, the Alquimista's bench), painted by HubLook.
## The save the Videira grows from: --vine=N (captures, as in a run) shows the first N roots bought.
func _vine_view() -> Dictionary:
	if not Dev.has("vine"):
		return Save.data
	var view := Save.data.duplicate(true)
	var ids: Array = []
	for id in Vine.new(Vine.load_catalog()).first(int(Dev.num("vine", 0))):
		ids.append(String(id))
	view["vine"] = {"bought": ids}
	return view


func evolve() -> void:
	if focus != null:
		for id in HubPlan.STATIONS:
			if is_open(id):
				focus.points[id] = HubPlan.use_point(id)
	if arena != null and arena.look != null:
		HubEvolution.apply(arena.look, HubEvolution.of(Save.data, codex_chapters(Save.data)))
		if arena.look.has_method(&"grow_vine"):
			arena.look.call(&"grow_vine", Vine.growth(_vine_view()))
		if arena.look.has_method(&"show_heroes"):
			arena.look.call(&"show_heroes", Save.data)
		if arena.look.has_method(&"set_closed"):
			for id in HubGate.GATED:
				arena.look.call(&"set_closed", id, not is_open(id))


## The doors that stand shut this visit (SV-R): the future rooms', the Alquimista's while HubGate.FLAGS says so, and the
## stations HubGate has not opened. The layout makes each a solid door, HubBlockout draws it.
func closed_doors() -> Array[StringName]:
	var out: Array[StringName] = [HubPlan.FUTURE_A, HubPlan.FUTURE_B]
	if not HubGate.FLAGS.get(HubPlan.ALCHEMIST_ID, false):
		out.append(HubPlan.ALCHEMIST_ID)
	for id in HubGate.GATED:
		if not is_open(id):
			out.append(id)
	return out


## Whether a station stands open (HubGate; --hub-open=all opens every one, for captures and the robot).
func is_open(id: StringName) -> bool:
	return HubGate.is_open(Save.data, id, Dev.arg("hub-open") == "all")


## PT-5: after the arrival look (and a screen closed) the guides of this visit come one by one: written in the save the
## moment they start (forced ones with --guide are not), the camera eases in and, after the last, back to the hero.
func _guide_tick(dt: float) -> void:
	var on := guide != null and guide.current != null
	_guide_k = move_toward(_guide_k, 1.0 if on else 0.0, dt * GUIDE_EASE)
	if guide == null and not _guide_wait.is_empty() and not host.is_open() and not leaving \
			and (arrived < 0.0 or arrived >= HubPlan.ARRIVAL_LOOK + HubPlan.ARRIVAL_EASE + GUIDE_DELAY):
		if not Dev.has("guide"):
			HubGuide.mark_shown(Save.data, _guide_wait.map(func(d: HubGuideDef) -> StringName: return d.id))
			Save.write()
		guide = HubGuideOverlay.new().setup(_guide_wait)
		_guide_wait = []
		ui.add_child(guide)
		if is_instance_valid(station_sign):
			station_sign.queue_free()
			station_sign = null
		guide.done.connect(func() -> void:
			guide.queue_free()
			guide = null
			Controls.clear_presses()
			_show_focus())


## The openings of this return said once: one line each over the place's name, written in the save (HubGate.presented).
func _announce() -> void:
	if Dev.arg("hub-open") == "all" or Dev.has("hero-at"):
		return
	var ids := HubGate.to_present(Save.data)
	if ids.is_empty():
		return
	var lines: Array[String] = []
	for id in ids:
		# a station with a guide this visit is explained by it, not said twice
		if not _guide_wait.any(func(d: HubGuideDef) -> bool: return d.station == id or d.id == id):
			lines.append(T.t(HubGate.TEXT[id]))
	HubGate.mark_presented(Save.data, ids)
	Save.write()
	if lines.is_empty():
		return
	for l in get_children():
		if l is HubLabels:
			(l as HubLabels).announce(lines)


## The Compêndio's chapters for the Livro's spines (HubEvolution.of): a Vector2i(found, total) each, read the way the
## Compêndio counts them (CodexScreen.progress); Morvath found only once sealed.
static func codex_chapters(data: Dictionary) -> Array[Vector2i]:
	var c := CodexScreen.new()
	c._data = data
	var out: Array[Vector2i] = []
	for tab in [CodexScreen.Tab.BOONS, CodexScreen.Tab.ELOS, CodexScreen.Tab.PSALMS, CodexScreen.Tab.ENEMIES,
			CodexScreen.Tab.ARENAS, CodexScreen.Tab.ANGELS]:
		out.append(c.progress(tab))
	out.append(Vector2i(1 if c.count("enemies", CodexScreen.BOSS, "defeated") > 0 else 0, 1))
	c.free()
	return out


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


## BG-4, --hub --smoke=N: N seconds in the Santuário without a screen (with --bot the robot walks the use points of the
## open stations in turn, with no interact), then the RESULT line and out.
var _tour: Array[Vector2] = [] as Array[Vector2]
var _tour_i := 0
var smoke_walked := 0.0


func _tour_dir() -> Vector2:
	if _tour.is_empty():
		return Vector2.ZERO
	var d := _tour[_tour_i] - player.pos
	if d.length() < 1.0:
		_tour_i = (_tour_i + 1) % _tour.size()
		return Vector2.ZERO
	return d.normalized()


func _smoke() -> void:
	if Dev.has("bot"):
		for id in HubPlan.STATIONS:
			if is_open(id):
				_tour.append(HubPlan.use_point(id))
	var limit := Dev.num("smoke", 60.0)
	var t := 0.0
	var last := player.pos
	while t < limit:
		await get_tree().process_frame
		t += 1.0 / 60.0
		smoke_walked += player.pos.distance_to(last)
		last = player.pos
	print("RESULT hub secs=%.0f stations=%d walked=%.1f at=(%.1f,%.1f) focus=%s" % [limit, _tour.size(), smoke_walked, player.pos.x, player.pos.y, focus.current])
	get_tree().quit()


## --shot=file.png: saves what the player sees after --shot-at seconds, then quits.
func _shot() -> void:
	await get_tree().create_timer(Dev.num("shot-at", 1.0)).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(Dev.arg("shot"))
	get_tree().quit()
