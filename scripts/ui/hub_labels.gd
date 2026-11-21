class_name HubLabels
extends CanvasLayer
## The hub's way of finding things (UI review d2ff05d, P1-8): the place's name for PLACE_TIME seconds on arriving, as an
## arena's name shows in a run (Hud.show_place), and a short faint name over every station on screen, so the five are
## found from afar (the full sign, StationSign, takes over at 2.2 m: the name of the station in focus hides). Nothing
## shows while a screen is open or the hero is leaving.
## Rejogabilidade, Fatia 1: the purse in the top right corner (Prata and Memória held, MaterialCount.purse) on a veil of
## ink, read again every frame (the Forja spends from it), hidden under the screens (the Forja and the Livro show their
## own).
##   add_child(HubLabels.new().setup(hub))

## Over the world, with the station's sign (DoorSign.LAYER), under the HUD and the screens.
const PLACE_TIME := 2.0
const PLACE_FADE := 0.4
const PLACE_SIZE := 22
const PLACE_Y := 18.0
## A station's faint name: its size, its colour and how far above the anchor it stands (px at 720 lines).
const NAME_SIZE := 14
const NAME_COLOR := Color(UiKit.PALE, 0.55)
const NAME_LIFT := 6.0
## How far inside the screen's edge a name has to be to show.
const EDGE := 24.0
## The purse's corner: from the right and the top (px at 720 lines).
const PURSE_MARGIN := Vector2(16, 12)

var hub: Hub
var place: Label
var names := {}
## The purse in the corner (its panel) and the row of counts inside.
var purse: PanelContainer
var _counts: HBoxContainer
var _t := 0.0


func setup(p_hub: Hub) -> HubLabels:
	hub = p_hub
	name = "HubLabels"
	layer = DoorSign.LAYER
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.theme = UiKit.theme()
	add_child(root)
	for id: StringName in HubPlan.STATIONS:
		var l := UiKit.shadow(UiKit.label(T.t("hub_" + id), NAME_COLOR, NAME_SIZE, UiKit.BOLD_FONT))
		l.name = String(id)
		l.visible = false
		root.add_child(l)
		names[id] = l
	place = UiKit.shadow(UiKit.title(T.t(&"hub_name"), PLACE_SIZE, UiKit.GOLD))
	place.name = "place"
	place.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	place.grow_horizontal = Control.GROW_DIRECTION_BOTH
	place.position.y = PLACE_Y
	place.modulate.a = 0.0
	root.add_child(place)
	purse = PanelContainer.new()
	purse.name = "purse"
	var veil := UiKit.box(Color(HudVeil.COLOR, 0.62), Color(UiKit.OLD_GOLD, 0.35), 1, 0, 0)
	veil.corner_detail = 1
	veil.set_corner_radius_all(int(HudVeil.CUT))
	veil.content_margin_left = 12
	veil.content_margin_right = 12
	veil.content_margin_top = 5
	veil.content_margin_bottom = 5
	purse.add_theme_stylebox_override(&"panel", veil)
	purse.mouse_filter = Control.MOUSE_FILTER_IGNORE
	purse.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	purse.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	purse.position = Vector2(-PURSE_MARGIN.x, PURSE_MARGIN.y)
	_counts = MaterialCount.purse(Save.data, UiKit.PALE, 18, 20.0)
	purse.add_child(_counts)
	root.add_child(purse)
	return self


func _process(delta: float) -> void:
	_t += delta
	var quiet := hub == null or hub.host.is_open() or hub.leaving
	purse.visible = not quiet
	if purse.visible:
		MaterialCount.refresh(_counts, Save.data)
		purse.size = purse.get_combined_minimum_size()
		purse.position = Vector2(purse.get_parent_area_size().x - purse.size.x - PURSE_MARGIN.x, PURSE_MARGIN.y)
	place.modulate.a = 0.0 if quiet else clampf((PLACE_TIME - _t) / PLACE_FADE, 0.0, 1.0) * clampf(_t / 0.2, 0.0, 1.0)
	var cam := hub.get_viewport().get_camera_3d() if hub else null
	var view := hub.get_viewport().get_visible_rect().grow(-EDGE) if hub else Rect2()
	# HV-D: a faint name never over the hero (the Santuário da Vigília puts stations round him as he walks the ring)
	var hero := Rect2()
	if cam != null and hub.player != null:
		var feet := Vector3(hub.player.pos.x, 0.0, hub.player.pos.y)
		hero = StationSign.hero_box(cam.unproject_position(feet + Vector3(0, StationSign.HERO_HEIGHT, 0)),
				cam.unproject_position(feet))
	for id: StringName in names:
		var l := names[id] as Label
		var at := HubPlan.anchor(id)
		var show := not quiet and cam != null and id != hub.focus.current and not cam.is_position_behind(at)
		if show:
			var sp := cam.unproject_position(at)
			show = view.has_point(sp)
			if show:
				var s := l.get_combined_minimum_size()
				l.size = s
				# QA A8 P2-1: the anchor is on screen but a long name ran past the edge ("Livro de Ah"): pull it inside
				var p := sp - Vector2(s.x * 0.5, s.y + NAME_LIFT)
				p.x = clampf(p.x, view.position.x, maxf(view.position.x, view.end.x - s.x))
				p.y = maxf(p.y, view.position.y)
				l.position = p.round()
				show = not Rect2(l.position, s).intersects(hero) and not Rect2(l.position, s).intersects(purse.get_global_rect())
		l.visible = show


## The station names showing now (the tests read it).
func shown() -> Array[StringName]:
	var out: Array[StringName] = []
	for id: StringName in names:
		if (names[id] as Label).visible:
			out.append(id)
	return out
