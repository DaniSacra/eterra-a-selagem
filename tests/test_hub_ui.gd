extends GutTest
## HUB-B3 and the interface of HUB-C (docs/design/hub_spec.md, hub_spec_art.md 2.4): the station's one sign (name, a
## short line, the real key that follows the device and a remapping, never over the hero, inside the screen, hidden
## while a screen is open, a click uses the station), the Portal's confirmation and the Vendedor's and Forjador's
## honest pages on a leaf of the Livro, the Livro's three sealed places beside the Warrior (no name, no text, nothing
## to choose) and its Compêndio, the hub's menu with Como Jogar, and the hub's own place in Músicas.

const DT := 1.0 / 60.0

var hub: Hub
var went: Array[String] = []
var _hub_music: Variant


func before_each() -> void:
	went.clear()
	SceneGo.catch = func(path: String) -> void: went.append(path)
	Controls.virtual = null
	Controls.using_pad = false
	Controls.clear_presses()
	_hub_music = Save.data.options.get("music_hub")


func after_each() -> void:
	SceneGo.catch = Callable()
	Controls.using_pad = false
	Controls.reset_bindings()
	Controls.clear_presses()
	if _hub_music == null:
		Save.data.options.erase("music_hub")
	else:
		Save.data.options.music_hub = _hub_music


func _hub() -> Hub:
	hub = (load(SceneGo.HUB) as PackedScene).instantiate()
	add_child_autofree(hub)
	return hub


func _frames(n: int) -> void:
	for i in n:
		await get_tree().process_frame


func _at(id: StringName) -> void:
	hub.player.pos = HubPlan.use_point(id)
	# the camera follows him (HUB-B2): a teleport across the hub starts framed on him, as a walk would end
	hub.cam.snap()
	await _frames(3)


# ---------- the sign ----------

func test_one_sign_per_station_with_its_name_line_and_key() -> void:
	_hub()
	for id in HubPlan.STATIONS:
		await _at(id)
		var signs := hub.find_children("*", "StationSign", true, false).filter(func(n: Node) -> bool: return not n.is_queued_for_deletion())
		assert_eq(signs.size(), 1, "%s: one sign" % id)
		assert_eq(hub.station_sign.station, id)
		assert_eq(hub.station_sign.title.text, T.t("hub_" + id))
		assert_eq(hub.station_sign.detail.text, T.t(Hub.station_line(id)))
		# the station's own verb, never the generic "Interagir" (UI review d2ff05d, P1-9)
		assert_eq(hub.station_sign.prompt.text, T.t("hub_use_" + id))
		assert_ne(hub.station_sign.prompt.text, T.t(&"hub_use"))
		assert_eq(hub.station_sign.key_text(), "F")
		assert_true(hub.station_sign.plate.visible, "%s: on show" % id)
	hub.player.pos = hub.arena.start
	await _frames(3)
	assert_null(hub.station_sign, "nothing in focus: no sign")


func test_the_key_follows_the_device_and_a_remapping() -> void:
	_hub()
	await _at(HubPlan.BOOK)
	Controls.using_pad = true
	assert_eq(hub.station_sign.key_text(), T.t(&"pad_0"), "the gamepad's A, live")
	assert_true(hub.station_sign.key.rounded, "a face button is round")
	Controls.using_pad = false
	assert_eq(hub.station_sign.key_text(), "F", "back to the keyboard")
	assert_false(hub.station_sign.key.rounded)
	var g := InputEventKey.new()
	g.physical_keycode = KEY_G
	Controls.rebind(&"interact", g)
	hub.station_sign.refresh()
	assert_eq(hub.station_sign.key_text(), "G", "the remapped key")


func test_the_sign_hides_under_a_screen_and_comes_back() -> void:
	_hub()
	await _at(HubPlan.SMITH)
	hub.use(HubPlan.SMITH)
	await _frames(2)
	assert_false(hub.station_sign.plate.visible, "no sign over a page")
	hub.host.close()
	await _frames(2)
	assert_true(hub.station_sign.plate.visible, "back with the station still in focus")


func test_a_click_on_the_sign_uses_the_station() -> void:
	_hub()
	await _at(HubPlan.VENDOR)
	var click := InputEventMouseButton.new()
	click.button_index = MOUSE_BUTTON_LEFT
	click.pressed = true
	hub.station_sign._on_input(click)
	assert_true(hub.host.screen is HubPanel, "the Vendedor's page")


func test_the_sign_stands_inside_the_screen_and_never_over_the_hero() -> void:
	var screen := Vector2(1280, 720)
	var s := Vector2(220, 70)
	# free: bottom centre on the anchor
	assert_eq(StationSign.place(Vector2(640, 200), s, screen), Vector2(530, 130))
	# the hero's head right under the anchor: it rises above him
	var head := Vector2(640, 190)
	var feet := Vector2(640, 300)
	var at := StationSign.place(Vector2(650, 230), s, screen, head, feet)
	assert_true(at.y + s.y <= head.y - StationSign.HERO_GAP + 0.5, "above his head")
	# at the edges: inside
	at = StationSign.place(Vector2(30, 40), s, screen)
	assert_gte(at.x, StationSign.EDGE)
	assert_gte(at.y, StationSign.EDGE)
	at = StationSign.place(Vector2(1275, 700), s, screen)
	assert_lte(at.x + s.x, screen.x - StationSign.EDGE)
	# the anchor above the screen (the Portal seen from its foot): under the hero, not over the station
	head = Vector2(640, 120)
	feet = Vector2(640, 180)
	at = StationSign.place(Vector2(640, -40), s, screen, head, feet)
	assert_gte(at.y, feet.y + StationSign.HERO_GAP - 0.5, "under his feet")
	assert_almost_eq(at.x + s.x * 0.5, 640.0, 1.0, "centred on him")
	# the anchor just under the top: the sign would press against the edge over the station, so under him too
	at = StationSign.place(Vector2(640, 85), s, screen, head, feet)
	assert_gte(at.y, feet.y + StationSign.HERO_GAP - 0.5, "under him when the station is at the top")
	# no room above the hero: under him too
	at = StationSign.place(Vector2(640, 110), s, screen, Vector2(640, 40), Vector2(640, 150))
	assert_gte(at.y, 150.0 + StationSign.HERO_GAP - 0.5, "under him when he stands at the top")


func test_the_sign_on_screen_is_clear_of_the_hero_at_every_station() -> void:
	_hub()
	var cam := hub.camera
	for id in HubPlan.STATIONS:
		await _at(id)
		await _frames(12)
		var p := hub.player.pos
		var head := cam.unproject_position(Vector3(p.x, StationSign.HERO_HEIGHT, p.y))
		var feet := cam.unproject_position(Vector3(p.x, 0, p.y))
		var half := (feet.y - head.y) * StationSign.HERO_HALF
		var hero := Rect2(head.x - half, head.y, half * 2.0, feet.y - head.y)
		var plate := hub.station_sign.plate
		assert_false(Rect2(plate.position, plate.size).intersects(hero), "%s: the sign clears the hero" % id)
		var view := hub.get_viewport().get_visible_rect()
		assert_true(view.encloses(Rect2(plate.position, plate.size)), "%s: inside the screen" % id)


# ---------- the pages ----------

func test_the_portal_asks_on_a_leaf_of_the_book() -> void:
	_hub()
	hub.use(HubPlan.PORTAL)
	var p := hub.host.screen as HubPanel
	assert_not_null(p)
	assert_true(p.leaf.single, "one leaf of the book")
	assert_eq((p.find_child("title", true, false) as Label).text, T.t(&"hub_descend_title"))
	assert_eq((p.find_child("line", true, false) as Label).text, T.t(&"hub_descend_line"))
	assert_not_null(p.find_child("mark", true, false), "the door's mark")
	assert_eq(p.buttons.map(func(b: Button) -> String: return b.name), ["go", "stay"])
	await _frames(2)
	assert_true(p.buttons[0].has_focus(), "Descer in focus")
	var view := hub.get_viewport().get_visible_rect().size
	await _frames(1)
	assert_lte(p.leaf.size.x, view.x)
	assert_lte(p.leaf.size.y, view.y)


## The Forjador's page is the Forja since the Rejogabilidade's Fatia 1 (test_rejogabilidade_game.gd); the Vendedor
## stays honest.
func test_the_vendor_is_honest() -> void:
	_hub()
	for id in [HubPlan.VENDOR]:
		hub.use(id)
		var p := hub.host.screen as HubPanel
		assert_eq((p.find_child("title", true, false) as Label).text, T.t("hub_" + id))
		assert_eq((p.find_child("line", true, false) as Label).text, T.t("hub_%s_soon" % id))
		assert_not_null(p.find_child("state", true, false), "A definir")
		assert_true(p.find_child("mark", true, false) is SealedMark)
		assert_eq(p.buttons.size(), 1, "only Voltar: nothing to buy or forge")
		assert_eq(p.buttons[0].name, &"back")
		p.buttons[0].pressed.emit()
		await _frames(1)
		assert_false(hub.host.is_open())


func test_the_book_shows_three_sealed_places_beside_the_warrior() -> void:
	var screen := HeroScreen.new()
	add_child_autofree(screen)
	screen.open(SaveData.defaults())
	var sealed := screen.find_child("sealed", true, false) as Control
	assert_not_null(sealed)
	var seats := sealed.get_children()
	assert_eq(seats.size(), HeroScreen.SEALED)
	for s: Node in seats:
		assert_true(s is SealedMark and (s as SealedMark).figure, "a silhouette")
		assert_eq((s as Control).focus_mode, Control.FOCUS_NONE, "nothing to choose")
		assert_eq((s as Control).mouse_filter, Control.MOUSE_FILTER_IGNORE)
	assert_eq(sealed.find_children("*", "Label", true, false).size(), 0, "no name, no text")


func test_the_book_opens_the_compendium_and_esc_comes_back() -> void:
	var screen := HeroScreen.new()
	add_child_autofree(screen)
	screen.open(SaveData.defaults())
	await _frames(1)
	(screen.find_child("codex", true, false) as Button).pressed.emit()
	assert_not_null(screen.find_child("codex_page", true, false), "the Compêndio")
	var esc := InputEventAction.new()
	esc.action = &"ui_cancel"
	esc.pressed = true
	screen._unhandled_input(esc)
	await _frames(2)
	assert_null(screen.find_child("codex_page", true, false), "Esc closes it")
	assert_true(screen._codex_button.has_focus(), "focus back on its button %s" % screen.get_viewport().gui_get_focus_owner())


func test_the_hub_menu_has_como_jogar() -> void:
	_hub()
	hub.open_menu()
	var howto := hub.host.screen.find_child("howto", true, false) as Button
	assert_not_null(howto)
	howto.pressed.emit()
	assert_not_null(hub.host.screen.find_children("*", "HowToScreen", true, false).front())


# ---------- the music ----------

func test_the_hub_is_a_place_of_its_own_with_the_titles_piece() -> void:
	assert_true(MusicCatalog.PLACES.has(MusicCatalog.HUB))
	assert_eq(MusicCatalog.DEFAULT[MusicCatalog.HUB], MusicCatalog.DEFAULT[MusicCatalog.TITLE], "the title's piece by default")
	assert_eq(MusicCatalog.choices(MusicCatalog.HUB), MusicCatalog.choices(MusicCatalog.TITLE), "any piece the title may play")
	assert_true(SaveData.defaults().options.has("music_hub"))
	assert_eq(T.t(&"music_place_hub"), T.t(&"hub_name"), "named by the place's one key")
	Save.data.options.music_hub = "tempting_secrets"
	assert_eq(Music.piece_for(MusicCatalog.HUB), &"tempting_secrets")
	Save.data.options.music_hub = "morvath_battle"
	assert_eq(Music.piece_for(MusicCatalog.HUB), MusicCatalog.DEFAULT[MusicCatalog.HUB], "Morvath's piece never plays there")
