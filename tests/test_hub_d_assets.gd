extends GutTest
## HUB-D and Fatia 1, the technical-artist's part: the hub's two people baked from the KayKit (tools/bake.gd -- npcs,
## HubNpc), the stone and floor laid along the hub's turned frame (the global frame_yaw, 0 everywhere else), the Emeth
## by rank of Temperar (emeth.gdshader temper, neutral at 0) and the four angels' seals (AngelSeal).

const NPCS: Array[StringName] = [&"npc_vendor", &"npc_smith"]
## docs/design/hub_spec_art.md 4.5: the two together, at most this many triangles.
const NPC_TRIANGLES := 12000
const HEIGHTS := {&"npc_vendor": 1.9, &"npc_smith": 1.95}
## The anvil's face (HubLook._anvil: the hub_anvil's height 0.9) and how far over it the hammer's head may land.
const ANVIL_TOP := 0.9


func _model(id: StringName) -> BakedModel:
	return load("res://assets/baked/%s.res" % id)


func test_the_people_are_baked_within_budget_on_their_feet() -> void:
	var tris := 0
	for id in NPCS:
		var m := _model(id)
		assert_not_null(m, String(id))
		tris += (m.mesh.surface_get_arrays(0)[Mesh.ARRAY_INDEX] as PackedInt32Array).size() / 3
		assert_almost_eq(m.height, float(HEIGHTS[id]), 0.02, "%s: height" % id)
		assert_gt(m.frame_count(&"idle"), 0, "%s: idle" % id)
		assert_gt(m.frame_count(&"gesture"), 0, "%s: gesture" % id)
		assert_true(m.loops.get(&"idle", false), "%s: the idle loops" % id)
		var low := INF
		for v in m.pose(&"idle", 0):
			low = minf(low, v.y)
		assert_almost_eq(low, 0.0, 0.01, "%s: the soles on the floor" % id)
	gut.p("hub people: %d triangles" % tris)
	assert_lt(tris, NPC_TRIANGLES)


func test_their_palette_ships_inside_the_baked_file() -> void:
	# assets/models/palettes/* is not exported (export_presets.cfg): the palette must be in the .res itself
	var presets := FileAccess.get_file_as_string("res://export_presets.cfg")
	assert_true(presets.contains("assets/models/palettes/*"), "the palettes stay out of the package")
	assert_false(presets.contains("assets/baked/npc"), "the people go in the package")
	for id in NPCS:
		var tex := _model(id).albedo
		assert_not_null(tex, String(id))
		assert_false(tex.resource_path.begins_with("res://assets/models/palettes"), "%s: palette embedded" % id)


func test_the_hammer_lands_on_the_anvils_face() -> void:
	var m := _model(&"npc_smith")
	assert_true(m.has_point("hammer"))
	var t := HubNpc.landing(m)
	var p := m.point("hammer", &"gesture", t)
	# the head's middle a hammer head's half over the face, never through the iron
	assert_between(p.y, ANVIL_TOP + 0.02, ANVIL_TOP + 0.12, "the head lands on the face (%.2f)" % p.y)
	assert_almost_eq(t, m.duration(&"gesture"), 0.08, "the baked swing ends where it lands")
	assert_eq(HubNpc.strike_point(), p)


func test_the_smith_strikes_in_bouts_with_sparks_under_the_glow() -> void:
	var smith := HubNpc.make(HubNpc.Who.SMITH)
	add_child_autofree(smith)
	await get_tree().process_frame
	assert_gt(smith.impact, 0.0)
	var sparks := smith.get_node("Sparks") as CPUParticles3D
	assert_not_null(sparks)
	assert_lte(maxf(HubNpc.SPARK_COLOR.r, maxf(HubNpc.SPARK_COLOR.g, HubNpc.SPARK_COLOR.b)), 1.0, "under the glow")
	smith.set_process(false)
	smith.gesture()
	var blows := 0
	var was := false
	for i in 600:
		smith._process(1.0 / 60.0)
		if smith._sparked and not was:
			blows += 1
			assert_true(sparks.emitting, "the burst on the blow")
		was = smith._sparked
		if smith._clip == &"idle":
			break
	assert_between(blows, HubNpc.SMITH_BLOWS.x, HubNpc.SMITH_BLOWS.y, "a bout of blows, a burst each")
	assert_eq(smith._clip, &"idle", "back to his idle after the bout")


func test_the_vendor_gestures_now_and_then_and_never_sparks() -> void:
	var vendor := HubNpc.make(HubNpc.Who.VENDOR)
	add_child_autofree(vendor)
	await get_tree().process_frame
	assert_null(vendor.get_node_or_null("Sparks"))
	vendor.set_process(false)
	var gestures := 0
	var last := vendor._clip
	for i in 60 * 30:
		vendor._process(1.0 / 60.0)
		if vendor._clip == &"gesture" and last != &"gesture":
			gestures += 1
		last = vendor._clip
	# 30 s, a gesture every 6 to 9 s plus its own 1.3 s
	assert_between(gestures, 3, 5)


func test_frame_yaw_is_a_global_at_zero_and_both_shaders_use_it() -> void:
	assert_true(ProjectSettings.has_setting("shader_globals/frame_yaw"))
	assert_eq(float((ProjectSettings.get_setting("shader_globals/frame_yaw") as Dictionary).value), 0.0)
	var inc := FileAccess.get_file_as_string("res://assets/shaders/frame_yaw.gdshaderinc")
	# at 0 nothing is computed: every room but the hub draws exactly as before
	assert_true(inc.contains("if (frame_yaw == 0.0) {\n\t\treturn p;"))
	for f in ["masonry.gdshaderinc", "catacomb_floor.gdshaderinc"]:
		var s := FileAccess.get_file_as_string("res://assets/shaders/" + f)
		assert_true(s.contains("frame_yaw.gdshaderinc"), f)
		assert_true(s.contains("frame_in(") and s.contains("frame_out("), f)


func test_the_hub_turns_the_stone_and_gives_it_back() -> void:
	var hub: Node = (load(SceneGo.HUB) as PackedScene).instantiate()
	add_child(hub)
	await get_tree().process_frame
	# the headless renderer keeps no globals (reads null): then only the people are checked here, the turn on the GPU
	var yaw = RenderingServer.global_shader_parameter_get(&"frame_yaw")
	if yaw != null:
		assert_almost_eq(float(yaw), Feel.live().cam_yaw, 0.001)
	assert_eq(hub.find_children("Vendor", "HubNpc", true, false).size(), 1, "the Vendedor stands in the hub")
	assert_eq(hub.find_children("Smith", "HubNpc", true, false).size(), 1, "the Forjador stands in the hub")
	remove_child(hub)
	hub.free()
	yaw = RenderingServer.global_shader_parameter_get(&"frame_yaw")
	if yaw != null:
		assert_eq(float(yaw), 0.0, "back to 0 for the rooms")


func test_the_emeth_temper_is_neutral_by_default_and_clamped() -> void:
	var sword := EmethSword.make()
	add_child_autofree(sword)
	var blade := (sword.get_node("Blade") as MeshInstance3D).material_override as ShaderMaterial
	var v = blade.get_shader_parameter(&"temper")
	assert_true(v == null or float(v) == 0.0, "nothing drawn until the forge says so")
	EmethSword.set_temper(blade, 1.0)
	assert_eq(float(blade.get_shader_parameter(&"temper")), 1.0)
	EmethSword.set_temper(blade, 7.0)
	assert_eq(float(blade.get_shader_parameter(&"temper")), float(EmethSword.TEMPER_MAX))
	EmethSword.set_temper(blade, -1.0)
	assert_eq(float(blade.get_shader_parameter(&"temper")), 0.0)
	var src := (blade.shader as Shader).code
	assert_true(src.contains("uniform float temper = 0.0;"))
	assert_true(src.contains("if (temper > 0.0) {"), "the classic blade untouched at 0")


func test_the_temper_marks_stay_under_the_glow() -> void:
	var src := (load("res://assets/shaders/emeth.gdshader") as Shader).code
	for name in ["temper_gold", "temper_thread"]:
		var line := src.substr(src.find("uniform vec3 " + name))
		var c := line.substr(line.find("vec3(", 10) + 5, line.find(")", line.find("vec3(", 10)) - line.find("vec3(", 10) - 5).split(",")
		for x in c:
			assert_lte(String(x).to_float(), 1.0, "%s under the glow threshold" % name)


func test_the_nine_seals_draw_and_the_elo_has_none() -> void:
	assert_eq(AngelSeal.TINT.size(), 10, "indexed by Boon.Family, the Elo's place old gold")
	for f in [Boon.Family.CHAMA, Boon.Family.GEADA, Boon.Family.LUZ, Boon.Family.VIGILIA, Boon.Family.DUO, Boon.Family.VEU, Boon.Family.MARE, Boon.Family.MARCA, Boon.Family.PESTE, Boon.Family.TROVAO]:
		var seal := AngelSeal.new().setup(f, 96.0)
		add_child_autofree(seal)
		var dim := AngelSeal.new().setup(f, 48.0, false)
		add_child_autofree(dim)
	await get_tree().process_frame
	await get_tree().process_frame
	# muted, never the cards' bright glow, never past ivory
	for c in AngelSeal.TINT:
		assert_lt(c.s, 0.75)
		assert_lte(c.v, 0.95)
	assert_eq(AngelSeal.tint(Boon.Family.DUO), UiKit.OLD_GOLD)
