extends GutTest
## DT-RS1: the world's air has one owner (RoomMood): every room in both looks, the look flipped and back, the Seal
## Chamber's last phase flipped and back, and the hall after the chamber give the same air as built fresh.
## DT-RS2: the visual style kept in the save's options ("look", stylized by default).

const KEYS: Array[StringName] = [&"background_mode", &"background_color", &"ambient_light_source", &"ambient_light_color",
	&"ambient_light_energy", &"fog_enabled", &"fog_mode", &"fog_light_color", &"fog_depth_begin", &"fog_depth_end",
	&"fog_height_density", &"volumetric_fog_density", &"adjustment_saturation", &"adjustment_enabled"]
const MOON: Array[StringName] = [&"rotation_degrees", &"light_color", &"light_energy", &"shadow_enabled", &"shadow_blur"]


func after_each() -> void:
	VisualProfile.set_look(VisualProfile.Look.CLASSIC)


func _snap(air: WorldAir, energies := true) -> Dictionary:
	var d := {}
	for k in KEYS:
		if energies or k != &"ambient_light_energy":
			d[k] = str(air.env.environment.get(k))
	for k in MOON:
		if energies or k != &"light_energy":
			d["moon/" + String(k)] = str(air.moon.get(k))
	return d


func _layouts() -> Array[RoomLayout]:
	var stage: StageDef = load("res://data/stages/catacombs.tres")
	var out: Array[RoomLayout] = []
	out.assign(stage.layouts)
	out.append_array([stage.trial_layout, stage.altar_layout, HubPlan.layout(), stage.boss_layout])
	return out


func _flip(arena: Arena) -> void:
	VisualProfile.toggle()
	arena.restyle()


## Builds each room in a world of `look`, flips the look twice in it; returns {id: [entered, flipped, back]}.
func _walk(look: VisualProfile.Look) -> Dictionary:
	VisualProfile.set_look(look)
	var holder := Node3D.new()
	add_child_autofree(holder)
	var air := WorldAir.build(holder)
	var seen := {}
	var arena: Arena = null
	for l in _layouts():
		if arena != null:
			arena.queue_free()
		arena = Arena.new()
		holder.add_child(arena)
		arena.build(l, 2, 1406)
		await get_tree().process_frame
		await get_tree().process_frame
		var entered := _snap(air)
		_flip(arena)
		var flipped := _snap(air)
		_flip(arena)
		seen[l.id] = [entered, flipped, _snap(air)]
	# the chamber's last phase, flipped and back; then sealed; then the hall again
	var chamber := _snap(air)
	arena.final_phase(true)
	await get_tree().create_timer(2.4).timeout
	var p4 := _snap(air, false)
	_flip(arena)
	_flip(arena)
	seen[&"phase4"] = [p4, _snap(air, false)]
	arena.seal_portal(0.1)
	await get_tree().create_timer(0.4).timeout
	seen[&"sealed"] = [chamber, _snap(air)]
	arena.queue_free()
	arena = Arena.new()
	holder.add_child(arena)
	arena.build(_layouts()[0], 2, 1406)
	await get_tree().process_frame
	await get_tree().process_frame
	seen[&"hall_again"] = [(seen[_layouts()[0].id] as Array)[0], _snap(air)]
	assert_eq(air.mood, RoomMood.of(arena), "the world's air has one owner, under its WorldEnvironment")
	return seen


func test_every_room_keeps_its_air_through_the_look_and_back() -> void:
	var classic := await _walk(VisualProfile.Look.CLASSIC)
	var styled := await _walk(VisualProfile.Look.STYLIZED)
	for id: StringName in classic:
		if classic[id].size() == 3:
			assert_eq(classic[id][0], classic[id][2], "%s: classic, flipped twice, as built" % id)
			assert_eq(styled[id][0], styled[id][2], "%s: stylized, flipped twice, as built" % id)
			assert_eq(classic[id][1], styled[id][0], "%s: flipped to stylized is the stylized air" % id)
			assert_eq(styled[id][1], classic[id][0], "%s: flipped to classic is the classic air" % id)
		else:
			assert_eq(classic[id][0], classic[id][1], "%s, classic" % id)
			assert_eq(styled[id][0], styled[id][1], "%s, stylized" % id)
	assert_ne(classic[&"phase4"][0], classic[&"sealed"][0], "the last phase turns the air")


func test_only_the_owner_writes_the_air_of_a_room() -> void:
	var holder := Node3D.new()
	add_child_autofree(holder)
	var air := WorldAir.build(holder)
	var arena := Arena.new()
	holder.add_child(arena)
	arena.build(_layouts()[1], 2, 1406)
	assert_eq(air.mood.dresser(), arena.look, "the arena dressed the air through the owner")
	var mood := arena.mood()
	assert_eq(mood, air.mood, "the room's mood is the owner")
	assert_eq(mood.scenery, arena, "handed the room's scenery")


func test_a_save_without_look_opens_stylized() -> void:
	var old := {"version": 7, "options": {"master": 0.5}}
	var merged := SaveData.merged(old)
	assert_eq(String(merged.options.look), "stylized", "a save from before opens in the stylized look")
	assert_eq(VisualProfile.of_options(merged.options), VisualProfile.Look.STYLIZED)
	assert_eq(VisualProfile.of_options({"look": "classic"}), VisualProfile.Look.CLASSIC)
	assert_eq(String(SaveSlots.options_of({"master": 0.5}).look), "stylized", "the shared options too")
	assert_eq(String(SaveData.defaults().options.look), "stylized")


func test_choose_look_puts_and_keeps_it() -> void:
	var was: Variant = Save.data.options.get("look")
	Save.choose_look(VisualProfile.Look.STYLIZED)
	assert_true(VisualProfile.stylized())
	assert_eq(String(Save.option("look")), "stylized")
	Save.choose_look(VisualProfile.Look.CLASSIC)
	assert_false(VisualProfile.stylized())
	assert_eq(String(Save.option("look")), "classic")
	Save.data.options["look"] = was
	assert_eq(VisualProfile.default_look(), VisualProfile.Look.CLASSIC, "the editor keeps the classic frame")
