extends GutTest
## QA (A8, HUB-E, P2-4): the hub through F7 and back (VisualProfile.toggle and Arena.restyle), as test_room_style
## does for the rooms: every material, light, visibility and the air as built, with the same collision.

var _env: Environment
var _moon: DirectionalLight3D


func before_each() -> void:
	VisualProfile.set_look(VisualProfile.Look.CLASSIC)


func after_each() -> void:
	ArenaRoom.leave_air()
	VisualProfile.set_look(VisualProfile.Look.CLASSIC)


## The world the game builds (Game._build_world, in short): an environment and a moon, the visual profile's air on them.
func _world() -> void:
	var we := WorldEnvironment.new()
	_env = Environment.new()
	_env.background_mode = Environment.BG_COLOR
	_env.background_color = Color(0.1, 0.12, 0.16)
	_env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	_env.ambient_light_color = Color(0.5, 0.5, 0.55)
	_env.ambient_light_energy = 0.8
	_env.fog_enabled = true
	_env.adjustment_enabled = true
	_env.adjustment_saturation = 1.3
	we.environment = _env
	add_child_autofree(we)
	_moon = DirectionalLight3D.new()
	_moon.light_color = Color(0.7, 0.75, 0.9)
	_moon.light_energy = 0.5
	_moon.rotation_degrees = Vector3(-50, 30, 0)
	add_child_autofree(_moon)
	RoomMood.own(we, _moon)


func _flip(a: Arena) -> void:
	VisualProfile.toggle()
	a.restyle()


## Every material, light and visibility under the room, then the air (environment and moon), as text.
func _snapshot(root: Node) -> PackedStringArray:
	var out := PackedStringArray()
	for n in root.find_children("*", "Node3D", true, false):
		var line := "%s v%s" % [root.get_path_to(n), n.visible]
		if n is GeometryInstance3D:
			var g := n as GeometryInstance3D
			var mats: Array = [g.material_override]
			if g is MeshInstance3D and (g as MeshInstance3D).mesh != null:
				var mi := g as MeshInstance3D
				for i in mi.mesh.get_surface_count():
					mats.append(mi.get_surface_override_material(i) if i < mi.get_surface_override_material_count() else null)
					mats.append(mi.mesh.surface_get_material(i))
			for m: Material in mats:
				line += " | " + _material(m)
		elif n is Light3D:
			var l := n as Light3D
			line += " %s %s %s %s" % [l.light_energy, l.light_color, l.get_param(Light3D.PARAM_RANGE), l.shadow_enabled]
			if l is OmniLight3D:
				line += " %s" % (l as OmniLight3D).omni_attenuation
		out.append(line)
	out.append(_air())
	return out


func _air() -> String:
	var e := _env
	return "env %s %s %s %s %s %s %s %s %s | moon %s %s %s %s" % [e.background_color, e.ambient_light_color,
		e.ambient_light_energy, e.fog_light_color, e.fog_depth_begin, e.fog_depth_end, e.volumetric_fog_density,
		e.adjustment_saturation, e.background_mode, _moon.rotation_degrees, _moon.light_color, _moon.light_energy,
		_moon.shadow_enabled]


func _material(m: Material) -> String:
	if m == null:
		return "-"
	if m is ShaderMaterial:
		var s := m as ShaderMaterial
		var t := str(s.shader.resource_path if s.shader != null else "")
		if s.shader != null:
			for u: Dictionary in s.shader.get_shader_uniform_list():
				t += " %s=%s" % [u.name, s.get_shader_parameter(u.name)]
		return t
	if m is StandardMaterial3D:
		var b := m as StandardMaterial3D
		return "std %s %s %s %s" % [b.albedo_color, b.emission, b.roughness, b.metallic]
	return str(m)


func _differ(a: PackedStringArray, b: PackedStringArray, what: String) -> int:
	var n := 0
	for i in mini(a.size(), b.size()):
		if a[i] != b[i]:
			n += 1
			if n < 4:
				gut.p("%s differs: %s\n  was: %s" % [what, a[i], b[i]])
	return n + absi(a.size() - b.size())


## QA (A8, HUB-E): the hub through F7 and back, as test_room_style does for the rooms.
func test_the_hub_comes_back_through_f7() -> void:
	_world()
	var a := Arena.new()
	add_child_autofree(a)
	a.build(HubPlan.layout())
	var before := _snapshot(a)
	var pillars := a.pillars.duplicate()
	var boxes := a.boxes.duplicate()
	_flip(a)
	var styled := _snapshot(a)
	assert_ne(styled, before, "hub: the stylized look changes it")
	_flip(a)
	assert_eq(_differ(_snapshot(a), before, "hub"), 0, "hub: classic again as built")
	_flip(a)
	assert_eq(_differ(_snapshot(a), styled, "hub stylized"), 0, "hub: stylized again the same")
	_flip(a)
	assert_eq(_differ(_snapshot(a), before, "hub"), 0, "hub: and back")
	assert_eq(a.pillars, pillars, "hub: the same circles")
	assert_eq(a.boxes, boxes, "hub: the same boxes")
