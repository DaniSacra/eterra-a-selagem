extends GutTest
## Cycle C12c, interface: the defeat tells where the run ended and what it carried (UI-02), and the door signs read
## at 1080 lines (UI-01, DoorSign).

var _saving := true


func before_each() -> void:
	_saving = Save.enabled
	Save.enabled = false


func after_each() -> void:
	Save.enabled = _saving


func _two_gifts() -> Array:
	var out := []
	for path: String in ["res://data/boons/00_brasas.tres", "res://data/boons/03_toque_geada.tres"]:
		out.append({"boon": load(path) as Boon, "level": 2})
	return out


func _defeat(extra: Dictionary) -> EndScreen:
	var stats := {"time": 312.0, "level": 0, "kills": 41, "best_combo": 12, "boons": 2, "defeated_by": &"enemy_skeleton"}
	stats.merge(extra, true)
	var end := EndScreen.new()
	add_child_autofree(end)
	end.open(false, stats, false)
	return end


# ---------- UI-02: the defeat ----------

func test_defeat_in_the_crypt_room_3_shows_the_room_the_arena_and_two_gifts() -> void:
	var end := _defeat({"room": 3, "rooms_total": 7, "arena": &"arena_crypt", "gifts": _two_gifts()})
	var where := end.find_child("where", true, false) as Label
	assert_not_null(where, "the line of where it fell")
	assert_eq(where.text, "Sala 3 de 7, Cripta dos Esquecidos")
	assert_true(where.text.contains(T.t(&"end_room", {"n": 3, "of": 7})))
	assert_true(where.text.contains(T.t(&"arena_crypt")))
	var gifts := end.find_child("gifts", true, false) as HBoxContainer
	assert_not_null(gifts, "the gifts carried")
	assert_eq(gifts.get_child_count(), 2)
	for icon in gifts.get_children():
		assert_true(icon is BoonIcon)
		assert_eq((icon as BoonIcon).level, 2)
	var texts := _texts(end)
	assert_true(texts.has(T.t(&"end_gifts")), "the gifts have their heading")
	assert_false(texts.has(T.t(&"end_boons")), "no count row under the medallions")
	for t: String in texts:
		assert_false(t.contains("—") or t.contains("–"), "no dash: %s" % t)


func test_defeat_still_names_what_struck_the_last_blow() -> void:
	var end := _defeat({"room": 3, "rooms_total": 7, "arena": &"arena_crypt", "gifts": _two_gifts()})
	var by := end.find_child("defeated_by", true, false) as Label
	assert_not_null(by)
	assert_eq(by.text, T.t(&"defeated_by", {"name": T.t(&"enemy_skeleton")}))


func test_defeat_without_gifts_has_no_empty_row() -> void:
	var end := _defeat({"room": 1, "rooms_total": 7, "arena": &"arena_hall"})
	assert_null(end.find_child("gifts", true, false))
	assert_false(_texts(end).has(T.t(&"end_gifts")))
	assert_true(_texts(end).has(T.t(&"end_boons")), "the count stays when there is nothing to show")
	assert_eq((end.find_child("where", true, false) as Label).text, "Sala 1 de 7, Salão das Catacumbas")


func test_defeat_outside_a_room_run_shows_no_place() -> void:
	# the old horde mode has no rooms
	var end := _defeat({})
	assert_null(end.find_child("where", true, false))


func test_new_texts_live_in_the_table_without_dashes() -> void:
	for key: StringName in [&"end_room", &"end_where", &"end_gifts"]:
		var t := T.t(key)
		assert_ne(t, String(key), "%s is in text_pt.tres" % key)
		assert_false(t.contains("—") or t.contains("–"))


func _texts(n: Node) -> Array[String]:
	var out: Array[String] = []
	if n is Label:
		out.append((n as Label).text)
	for c in n.get_children():
		out.append_array(_texts(c))
	return out


# ---------- UI-01: the door signs ----------

func test_door_sign_shows_the_reward_in_gold_and_the_detail_in_pale() -> void:
	var sign := DoorSign.make(T.t(&"reward_gold"), "120 ouro")
	add_child_autofree(sign)
	assert_eq(sign.title.text, T.t(&"reward_gold"))
	assert_eq(sign.title.get_theme_color(&"font_color"), DoorSign.TITLE_COLOR)
	assert_eq(sign.title.get_theme_font(&"font"), UiKit.BOLD_FONT)
	assert_eq(sign.title.get_theme_color(&"font_outline_color"), DoorSign.OUTLINE_COLOR)
	assert_gt(sign.title.get_theme_constant(&"outline_size"), 0, "a dark outline")
	assert_eq(sign.title.get_theme_font_size(&"font_size"), DoorSign.FONT_SIZE)
	assert_not_null(sign.detail)
	assert_eq(sign.detail.text, "120 ouro")
	assert_eq(sign.detail.get_theme_color(&"font_color"), DoorSign.DETAIL_COLOR)
	var layer := sign.title.get_parent().get_parent() as CanvasLayer
	assert_not_null(layer, "drawn as interface text, out of the fog and the glow")
	assert_lt(layer.layer, 5, "under the HUD and the menus")


func test_door_sign_without_detail_has_one_line() -> void:
	var sign := DoorSign.make(T.t(&"room_shop"))
	add_child_autofree(sign)
	assert_null(sign.detail)
	assert_eq(sign.title.get_parent().get_child_count(), 1)


func test_door_sign_capitals_stand_16_px_at_1080_and_scale_with_the_screen() -> void:
	assert_eq(float(ProjectSettings.get_setting("display/window/size/viewport_height")), DoorSign.BASE_LINES)
	assert_eq(ProjectSettings.get_setting("display/window/stretch/mode"), "canvas_items")
	var cap := DoorSign.cap_px(DoorSign.FONT_SIZE, 1080.0)
	assert_gte(cap, 16.0)
	assert_almost_eq(cap, DoorSign.CAP_PX, 0.5)
	assert_gte(DoorSign.cap_px(DoorSign.DETAIL_SIZE, 1080.0), 14.0, "the price too")
	assert_almost_eq(DoorSign.cap_px(DoorSign.FONT_SIZE, 720.0), cap * 720.0 / 1080.0, 0.01)


func test_door_sign_follows_its_point_on_the_screen() -> void:
	var cam := Camera3D.new()
	add_child_autofree(cam)
	cam.position = Vector3(0, 10, 10)
	cam.look_at(Vector3.ZERO)
	cam.make_current()
	var sign := DoorSign.make("Dom")
	add_child_autofree(sign)
	sign._process(0.0)
	var box := sign.title.get_parent() as Control
	assert_true(box.visible)
	var foot := box.position + Vector2(box.size.x * 0.5, box.size.y)
	assert_almost_eq(foot.distance_to(cam.unproject_position(Vector3.ZERO)), 0.0, 1.0, "bottom centre on the point")
	sign.position = Vector3(0, 20, 30)
	sign._process(0.0)
	assert_false(box.visible, "hidden behind the camera")


func test_door_sign_colours_keep_4_5_to_1_against_the_outline() -> void:
	assert_gte(DoorSign.contrast(DoorSign.TITLE_COLOR, DoorSign.OUTLINE_COLOR), DoorSign.MIN_CONTRAST)
	assert_gte(DoorSign.contrast(DoorSign.DETAIL_COLOR, DoorSign.OUTLINE_COLOR), DoorSign.MIN_CONTRAST)
	assert_almost_eq(DoorSign.contrast(Color.WHITE, Color.BLACK), 21.0, 0.01)
	assert_almost_eq(DoorSign.contrast(Color.GRAY, Color.GRAY), 1.0, 0.001)
