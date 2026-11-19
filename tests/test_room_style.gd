extends GutTest
## Room redesign, lot A (docs/art/room_redesign_lotA_spec.md 1.4): each room's biome in the stylized look
## (ArenaRoom.style, CatacombHall.STYLE) through VisualProfile. The look switched twice (F7: VisualProfile.toggle and
## Arena.restyle) gives back every material, light, visibility, the environment and the moon exactly as built in the
## classic look, with the same collision; inside the crypt the stylized air is the room's style().air, not the world's.

const STAGE := "res://data/stages/catacombs.tres"

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
	VisualProfile.dress_world(_env, _moon)


func _layout(id: StringName, variant := 0) -> RoomLayout:
	var stage: StageDef = load(STAGE)
	for l in stage.layouts:
		if l.id == id:
			return l.variant(variant) if variant > 0 else l
	return null


func _arena(id: StringName, variant := 0) -> Arena:
	var a := Arena.new()
	add_child_autofree(a)
	a.build(_layout(id, variant), 3, 1406)
	return a


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


func _round_trip(id: StringName, variant: int) -> Arena:
	_world()
	var a := _arena(id, variant)
	var before := _snapshot(a)
	var pillars := a.pillars.duplicate()
	var boxes := a.boxes.duplicate()
	var shape := a.shape()
	_flip(a)
	var styled := _snapshot(a)
	assert_ne(styled, before, "%s %d: the stylized look changes the room" % [id, variant])
	var painted := 0
	for line in styled:
		if line.contains("_paint.gdshader"):
			painted += 1
	assert_gt(painted, 10, "%s %d: stone, floor and pieces painted" % [id, variant])
	_flip(a)
	assert_eq(_differ(_snapshot(a), before, "%s %d" % [id, variant]), 0, "%s %d: classic again as built" % [id, variant])
	_flip(a)
	assert_eq(_differ(_snapshot(a), styled, "%s %d stylized" % [id, variant]), 0, "%s %d: stylized again the same" % [id, variant])
	_flip(a)
	assert_eq(_differ(_snapshot(a), before, "%s %d" % [id, variant]), 0, "%s %d: and back" % [id, variant])
	assert_eq(a.pillars, pillars, "%s %d: the same circles" % [id, variant])
	assert_eq(a.boxes, boxes, "%s %d: the same boxes" % [id, variant])
	assert_eq(a.shape(), shape, "%s %d: the same floor" % [id, variant])
	return a


func test_crypt_a_comes_back() -> void:
	_round_trip(&"crypt", 0)


func test_crypt_b_comes_back() -> void:
	_round_trip(&"crypt", 1)


func test_hall_comes_back() -> void:
	_round_trip(&"hall", 0)


func test_the_crypt_wears_its_own_stylized_air() -> void:
	_world()
	var a := _arena(&"crypt")
	var classic_ambient := _env.ambient_light_color
	assert_eq(classic_ambient, CryptLook.AIR[&"ambient"], "classic: the crypt's own air")
	_flip(a)
	var air: Dictionary = CryptLook.STYLE[&"air"]
	assert_eq(_env.ambient_light_color, air[&"ambient"], "stylized: the crypt's stylized ambient, not the world's")
	assert_eq(_env.background_color, air[&"sky"])
	assert_almost_eq(_moon.light_energy, float(air[&"moon_energy"]), 0.0001)
	assert_true(_moon.shadow_enabled, "the key from behind the camera casts the figures' shadows")
	assert_true(_moon.rotation_degrees.is_equal_approx(VisualProfile.KEY_ROTATION), "the stylized key's direction")
	_flip(a)
	assert_eq(_env.ambient_light_color, classic_ambient)
	assert_false(_moon.shadow_enabled)


func test_built_while_stylized_shows_the_same_pieces() -> void:
	_world()
	var classic := _snapshot(_arena(&"crypt", 1))
	ArenaRoom.leave_air()
	VisualProfile.set_look(VisualProfile.Look.STYLIZED)
	var a := _arena(&"crypt", 1)
	_flip(a)
	var back := _snapshot(a)
	assert_eq(back.size(), classic.size())
	var differ := 0
	for i in mini(back.size() - 1, classic.size() - 1):
		if back[i].get_slice(" ", 1) != classic[i].get_slice(" ", 1):
			differ += 1
	assert_eq(differ, 0, "the same visibility either way")


func test_leaving_the_room_gives_the_world_back_in_the_look_in_use() -> void:
	_world()
	var world_classic := _air()
	var a := _arena(&"crypt")
	_flip(a)
	_flip(a)
	ArenaRoom.leave_air()
	assert_eq(_air(), world_classic, "classic world air back")
	var b := _arena(&"crypt")
	_flip(b)
	ArenaRoom.leave_air()
	assert_eq(_env.ambient_light_color, VisualProfile.AMBIENT, "the stylized world's ambient after leaving stylized")


func test_style_only_pieces_are_off_the_floor_or_low() -> void:
	VisualProfile.set_look(VisualProfile.Look.STYLIZED)
	for v in 2:
		var a := _arena(&"crypt", v)
		var styled := a.find_child("Styled", true, false) as Node3D
		assert_not_null(styled, "the crypt has stylized-only pieces")
		for n in styled.find_children("*", "MeshInstance3D", true, false):
			var mi := n as MeshInstance3D
			var box := mi.global_transform * mi.get_aabb()
			# a piece over the walkable floor stays under 0.3 m unless it stands on a blocking piece
			for c in [box.position, box.end, box.get_center()]:
				var p := Vector2(c.x, c.z)
				if a.shape().contains(p) and box.position.y < 0.3 and box.end.y > 0.3:
					assert_true(a.overlaps(p, 0.0), "crypt %d: %s over the floor at %s" % [v, mi.name, p])


# ---------- lot B: the sanctuary and the rift (docs/art/room_redesign_lotB_spec.md) ----------

func test_sanctuary_a_comes_back() -> void:
	_round_trip(&"sanctuary", 0)


func test_sanctuary_b_comes_back() -> void:
	_round_trip(&"sanctuary", 1)


func test_rift_a_comes_back() -> void:
	_round_trip(&"rift", 0)


func test_rift_b_comes_back() -> void:
	_round_trip(&"rift", 1)


func _wears_own_air(id: StringName, style: Dictionary) -> void:
	_world()
	var a := _arena(id)
	var classic_ambient := _env.ambient_light_color
	_flip(a)
	var air: Dictionary = style[&"air"]
	assert_eq(_env.ambient_light_color, air[&"ambient"], "%s: the stylized ambient is the room's" % id)
	assert_eq(_env.background_color, air[&"sky"], "%s: its sky" % id)
	assert_almost_eq(_moon.light_energy, float(air[&"moon_energy"]), 0.0001, "%s: its key" % id)
	_flip(a)
	assert_eq(_env.ambient_light_color, classic_ambient, "%s: classic again" % id)


func test_the_sanctuary_wears_its_own_stylized_air() -> void:
	_wears_own_air(&"sanctuary", SanctuaryLook.STYLE)


func test_the_rift_wears_its_own_stylized_air() -> void:
	_wears_own_air(&"rift", RiftLook.STYLE)


## The classic room keeps its shadowed lights (spec 1.3: 5 in A, 4 in B for the sanctuary): nothing built for the
## stylized look casts a shadow.
func test_lot_b_shadowed_lights_unchanged() -> void:
	for v in 2:
		var a := _arena(&"sanctuary", v)
		assert_eq(a.look.shadowed, 5 if v == 0 else 4, "sanctuary %d: shadowed lights" % v)
		var styled := a.find_child("Styled", true, false)
		for l in styled.find_children("*", "Light3D", true, false):
			assert_false((l as Light3D).shadow_enabled, "sanctuary %d: a stylized light without shadow" % v)
	for v in 2:
		var a := _arena(&"rift", v)
		for l in a.find_child("Styled", true, false).find_children("*", "Light3D", true, false):
			assert_false((l as Light3D).shadow_enabled, "rift %d: a stylized light without shadow" % v)


func test_lot_b_style_only_pieces_are_off_the_floor_or_low() -> void:
	VisualProfile.set_look(VisualProfile.Look.STYLIZED)
	for id: StringName in [&"sanctuary", &"rift"]:
		for v in 2:
			var a := _arena(id, v)
			var styled := a.find_child("Styled", true, false) as Node3D
			assert_not_null(styled, "%s %d has stylized-only pieces" % [id, v])
			var n_meshes := 0
			var bad := 0
			for n in styled.find_children("*", "MeshInstance3D", true, false):
				var mi := n as MeshInstance3D
				if mi.mesh == null:
					continue
				n_meshes += 1
				# every vertex over the walkable floor stays under 0.3 m or over 2.6 m unless it stands on a blocking piece
				var xf := mi.global_transform
				for sf in mi.mesh.get_surface_count():
					var verts: PackedVector3Array = mi.mesh.surface_get_arrays(sf)[Mesh.ARRAY_VERTEX]
					for vert in verts:
						var w := xf * vert
						var p := Vector2(w.x, w.z)
						if w.y > 0.3 and w.y < 2.6 and a.shape().contains(p, 0.05) and not a.overlaps(p, 0.0):
							bad += 1
							if bad < 4:
								gut.p("%s %d: %s %s under %s at %s" % [id, v, mi.name, mi.mesh, mi.get_parent().name, w])
			assert_eq(bad, 0, "%s %d: nothing new over the floor between 0.3 and 2.6 m" % [id, v])
			assert_gt(n_meshes, 5, "%s %d: its pieces" % [id, v])


# ---------- lot C: the garden and the bridge (docs/art/room_redesign_lotC_spec.md) ----------

func test_garden_a_comes_back() -> void:
	_round_trip(&"garden", 0)


func test_garden_b_comes_back() -> void:
	_round_trip(&"garden", 1)


func test_bridge_a_comes_back() -> void:
	_round_trip(&"bridge", 0)


func test_bridge_b_comes_back() -> void:
	_round_trip(&"bridge", 1)


func test_the_garden_wears_its_own_stylized_air() -> void:
	_wears_own_air(&"garden", GardenLook.STYLE)


func test_the_bridge_wears_its_own_stylized_air() -> void:
	_wears_own_air(&"bridge", BridgeLook.STYLE)


## Nothing built for the stylized look casts a shadow; the classic rooms keep their shadowed lights.
func test_lot_c_shadowed_lights_unchanged() -> void:
	for id: StringName in [&"garden", &"bridge"]:
		for v in 2:
			var classic := _arena(id, v).look.shadowed
			var a := _arena(id, v)
			assert_eq(a.look.shadowed, classic, "%s %d: shadowed lights" % [id, v])
			for l in a.find_child("Styled", true, false).find_children("*", "Light3D", true, false):
				assert_false((l as Light3D).shadow_enabled, "%s %d: a stylized light without shadow" % [id, v])


func test_lot_c_style_only_pieces_are_off_the_floor_or_low() -> void:
	VisualProfile.set_look(VisualProfile.Look.STYLIZED)
	for id: StringName in [&"garden", &"bridge"]:
		for v in 2:
			var a := _arena(id, v)
			var styled := a.find_child("Styled", true, false) as Node3D
			assert_not_null(styled, "%s %d has stylized-only pieces" % [id, v])
			var n_meshes := 0
			var bad := 0
			for n in styled.find_children("*", "GeometryInstance3D", true, false):
				var mi := n as MeshInstance3D
				if mi == null or mi.mesh == null:
					continue
				n_meshes += 1
				var xf := mi.global_transform
				for sf in mi.mesh.get_surface_count():
					var verts: PackedVector3Array = mi.mesh.surface_get_arrays(sf)[Mesh.ARRAY_VERTEX]
					for vert in verts:
						var w := xf * vert
						var p := Vector2(w.x, w.z)
						if w.y > 0.3 and w.y < 2.6 and a.shape().contains(p, 0.05) and not a.overlaps(p, 0.0):
							bad += 1
							if bad < 4:
								gut.p("%s %d: %s under %s at %s" % [id, v, mi.name, mi.get_parent().name, w])
			assert_eq(bad, 0, "%s %d: nothing new over the floor between 0.3 and 2.6 m" % [id, v])
			assert_gt(n_meshes, 5, "%s %d: its pieces" % [id, v])


## J5 (B): the stylized garden B hides the west wall for the lake; A keeps it; the water never lies on the floor.
func test_garden_b_trades_the_west_wall_for_a_lake() -> void:
	for v in 2:
		var a := _arena(&"garden", v)
		var west := a.find_child("WestWall", true, false) as Node3D
		assert_not_null(west, "garden %d: the west wall in a node of its own" % v)
		assert_true(west.visible, "garden %d: classic, the west wall stands" % v)
		_flip(a)
		assert_eq(west.visible, v == 0, "garden %d: stylized, the wall stands only in A" % v)
		var water := 0
		for n in a.find_child("Styled", true, false).find_children("*", "MeshInstance3D", true, false):
			var mi := n as MeshInstance3D
			var sm := mi.material_override as ShaderMaterial
			if sm == null or sm.shader != GardenLook.WATER_SHADER:
				continue
			water += 1
			var c := mi.global_position
			if int(sm.get_shader_parameter(&"form")) == 0:
				assert_lt(c.y, 0.0, "garden %d: water under the floor's height" % v)
				var box := mi.global_transform * mi.get_aabb()
				for k in 4:
					var p := Vector2(box.position.x + box.size.x * 0.5, box.position.z + box.size.z * 0.5)
					assert_false(a.shape().contains(p, 0.0), "garden %d: a pool's middle off the floor" % v)
		assert_gt(water, 2, "garden %d: falls and pools" % v)
		_flip(a)
