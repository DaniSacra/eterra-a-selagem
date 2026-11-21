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
	RoomMood.own(we, _moon)


func _layout(id: StringName, variant := 0) -> RoomLayout:
	var stage: StageDef = load(STAGE)
	if id == &"trial":
		return stage.trial_layout
	if id == &"altar":
		return stage.altar_layout
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


# ---------- RS-C1: one funerary piece rules each crypt (docs/art/rs_c1_crypt_spec.md) ----------

## Lights that light (visible in the tree, energy over 0) and of those the shadowed ones.
func _lit(a: Arena) -> Vector2i:
	var n := Vector2i.ZERO
	for l in a.find_children("*", "Light3D", true, false):
		var light := l as Light3D
		if light.is_visible_in_tree() and light.light_energy > 0.0:
			n.x += 1
			n.y += 1 if light.shadow_enabled else 0
	return n


func test_rs_c1_lights() -> void:
	# before RS-C1: 18 lit (6 shadowed) in the classic crypt A, 17 (6) in B; 18 (1) in the stylized A and B
	assert_eq(_lit(_arena(&"crypt", 0)), Vector2i(18, 6), "crypt A classic: as before")
	assert_eq(_lit(_arena(&"crypt", 1)), Vector2i(17, 6), "crypt B classic: as before")
	VisualProfile.set_look(VisualProfile.Look.STYLIZED)
	# R-1 (Sworn P1 review): every other candle group of A out, two of them with a light
	assert_eq(_lit(_arena(&"crypt", 0)), Vector2i(16, 1), "crypt A stylized: the crown's light in, the west step's and two groups' out")
	# cycle 2026-11-20 item 4: B adds the cold wash on the ossuary's niches (no shadow)
	assert_eq(_lit(_arena(&"crypt", 1)), Vector2i(17, 1), "crypt B stylized: the lantern and the ossuary's wash in, two bowls and the statue's candles out")


func test_rs_c1_pieces_only_in_the_stylized_look() -> void:
	for v in 2:
		var a := _arena(&"crypt", v)
		var styled := a.find_child("Styled", true, false) as Node3D
		assert_false(styled.visible, "crypt %d: the stylized pieces hidden in the classic look" % v)
		var crown := 0
		var lantern := 0
		for n in styled.find_children("*", "", true, false):
			if n is MultiMeshInstance3D and (n as MultiMeshInstance3D).multimesh.mesh is QuadMesh:
				crown += (n as MultiMeshInstance3D).multimesh.instance_count
			if n is OmniLight3D and n.has_meta(ArenaKit.NOT_FIRE):
				lantern += 1 if (n as OmniLight3D).light_color.b > (n as OmniLight3D).light_color.r else 0
		if v == 0:
			assert_eq(crown, (CryptLook.CROWN_CANDLES - CryptLook.CROWN_OUT.size()) * 3, "A: the crown's flame, core and halo for each lit candle")
		else:
			assert_eq(lantern, 1, "B: the veiled figure's cold lantern")
		_flip(a)
		assert_true(styled.visible, "crypt %d: shown in the stylized look" % v)
		_flip(a)


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


# ---------- lot D: the runes, the trial and the altar (docs/art/room_redesign_lotD_spec.md) ----------

func test_runes_a_comes_back() -> void:
	_round_trip(&"runes", 0)


func test_runes_b_comes_back() -> void:
	_round_trip(&"runes", 1)


func test_trial_comes_back() -> void:
	_round_trip(&"trial", 0)


func test_altar_comes_back() -> void:
	_round_trip(&"altar", 0)


func test_the_runes_wear_their_own_stylized_air() -> void:
	_wears_own_air(&"runes", RunesLook.STYLE)


func test_the_trial_wears_its_own_stylized_air() -> void:
	_wears_own_air(&"trial", TrialLook.STYLE)


func test_the_altar_wears_its_own_stylized_air() -> void:
	_wears_own_air(&"altar", AltarLook.STYLE)


## The classic rooms keep their shadowed lights; nothing built for the stylized look casts a shadow; in the stylized
## altar the candles' light keeps its shadow, the shaft loses its own (spec 3.2: the candles' is the only one).
func test_lot_d_shadowed_lights() -> void:
	for id: StringName in [&"runes", &"trial", &"altar"]:
		for v in (2 if id == &"runes" else 1):
			var classic := _arena(id, v).look.shadowed
			var a := _arena(id, v)
			assert_eq(a.look.shadowed, classic, "%s %d: shadowed lights" % [id, v])
			for l in a.find_child("Styled", true, false).find_children("*", "Light3D", true, false):
				assert_false((l as Light3D).shadow_enabled, "%s %d: a stylized light without shadow" % [id, v])
	var altar := _arena(&"altar")
	var look := altar.look as AltarLook
	_flip(altar)
	look.kindle(0.0)
	var shadowed: Array[Light3D] = []
	for l in altar.find_children("*", "Light3D", true, false):
		if (l as Light3D).visible and (l as Light3D).shadow_enabled:
			shadowed.append(l)
	assert_eq(shadowed.size(), 1, "stylized altar lit: one light with shadow")
	assert_eq(shadowed[0].light_color, ArenaRoom.CANDLE_COLOR, "the candles' light")
	_flip(altar)


func test_lot_d_style_only_pieces_are_off_the_floor_or_low() -> void:
	VisualProfile.set_look(VisualProfile.Look.STYLIZED)
	for id: StringName in [&"runes", &"trial", &"altar"]:
		for v in (2 if id == &"runes" else 1):
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


## RS-D1: the painted rune floor is the same material on its twin shader: every uniform of the classic one is read by
## the painted one, set_tile writes the same state texture in both looks, and F7 with a tile lit neither clears nor
## doubles the state.
func test_the_painted_rune_floor_keeps_the_tiles_state() -> void:
	var classic_names := {}
	for u: Dictionary in ArenaKit.RUNE_FLOOR.get_shader_uniform_list():
		classic_names[u.name] = true
	var paint_names := {}
	for u: Dictionary in ArenaKit.RUNE_FLOOR_PAINT.get_shader_uniform_list():
		paint_names[u.name] = true
	for k: String in classic_names:
		assert_true(paint_names.has(k), "the painted rune floor reads %s" % k)
	_world()
	var a := _arena(&"runes")
	var look := a.look as RunesLook
	var mat := look.floor_mat
	var tex: Variant = mat.get_shader_parameter(&"rune_state")
	look.set_tile(Vector2i(3, 2), 0.8, 0.0, 0.0)
	look.set_chevrons(Vector2(0, 1))
	look.apply()
	var before := look.state_image().get_data()
	_flip(a)
	assert_eq(look.floor_mat, mat, "the same material")
	assert_eq(mat.shader, ArenaKit.RUNE_FLOOR_PAINT, "painted in the stylized look")
	assert_eq(mat.get_shader_parameter(&"rune_state"), tex, "the same state texture")
	assert_eq(look.state_image().get_data(), before, "F7 keeps the lit tile, nothing more")
	assert_eq(mat.get_shader_parameter(&"chevron_dir"), Vector2(0, 1), "and the chevrons")
	look.set_tile(Vector2i(4, 2), 0.5, 0.0, 0.0)
	look.apply()
	assert_almost_eq(look.state_image().get_pixel(4, 2).r, 0.5, 0.01, "set_tile writes the same state stylized")
	assert_eq(mat.get_shader_parameter(&"rune_state"), tex, "on the same texture")
	_flip(a)
	assert_eq(mat.shader, ArenaKit.RUNE_FLOOR, "classic again")
	assert_almost_eq(look.state_image().get_pixel(4, 2).r, 0.5, 0.01, "and keeps it")
	var lit := 0
	for y in look.grid().y:
		for x in look.grid().x:
			if look.state_image().get_pixel(x, y).r > 0.01:
				lit += 1
	assert_eq(lit, 2, "two tiles lit, none doubled")


## RS-D1: a real fight's rune floor in each look: the same tiles' state frame by frame, the same chevrons, the same
## damage to the paladin and to an enemy on it.
func test_the_runes_strike_the_same_in_both_looks() -> void:
	var runs: Array = []
	for look in [VisualProfile.Look.CLASSIC, VisualProfile.Look.STYLIZED]:
		VisualProfile.set_look(look)
		var game: Game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
		add_child_autofree(game)
		game.rebuild_room(_layout(&"runes"), 2, 1406)
		game.horde.clear_crowd()
		var rng := RandomNumberGenerator.new()
		rng.seed = 77
		var rf := RuneFloor.new(game, _layout(&"runes").hazard, rng)
		assert_not_null(rf.look, "the room draws its own tiles")
		var e := game.horde.spawn(game.horde.def(&"skeleton"), Vector2(-4.5, -4.5), false)
		game.player.place(Vector2(4.5, 1.5))
		var frames := PackedStringArray()
		for i in 600:
			game.player.invuln = 0.0
			rf.step(1.0 / 60.0)
			game.ground.step(1.0 / 60.0)
			frames.append("%s %s %.2f %.2f" % [hash(rf.look.state_image().get_data()),
				rf.look.floor_mat.get_shader_parameter(&"chevron_dir"), game.player.hp, e.hp])
		runs.append([frames, rf.enemy_damage])
		rf.stop()
		ArenaRoom.leave_air()
	VisualProfile.set_look(VisualProfile.Look.CLASSIC)
	assert_eq(runs[0][0], runs[1][0], "the same tiles, chevrons and damage every frame")
	assert_eq(runs[0][1], runs[1][1], "the same damage to the enemies")
	var states := {}
	for f: String in runs[0][0]:
		states[f.get_slice(" ", 0)] = true
	assert_gt(states.size(), 3, "the floor armed and struck in the run")


# ---------- lot E: the Seal Chamber, background and air only (docs/art/room_redesign_lotE_spec.md) ----------

func _chamber() -> Arena:
	var stage: StageDef = load(STAGE)
	var a := Arena.new()
	add_child_autofree(a)
	a.build(stage.boss_layout, 0, 1406)
	return a


func test_the_chamber_comes_back() -> void:
	_world()
	var a := _chamber()
	# the chamber dresses the world's air a frame after it is built
	await wait_process_frames(2)
	assert_eq(_env.background_color, BossChamber.SKY, "classic: the chamber's sky")
	var before := _snapshot(a)
	var shape := a.shape()
	var circles := (a.chamber as BossChamber).circles.duplicate()
	_flip(a)
	var styled := _snapshot(a)
	assert_ne(styled, before, "the stylized look changes the chamber")
	assert_eq(_env.ambient_light_color, BossChamber.AMBIENT, "stylized: the chamber's own ambient, not the world's")
	assert_almost_eq(_env.background_color.b, BossChamber.SKY.b * BossChamber.STY_SKY, 0.0001, "stylized: the sky deeper")
	assert_almost_eq(_moon.light_energy, BossChamber.MOON_ENERGY, 0.0001, "the chamber's moon in either look")
	_flip(a)
	assert_eq(_differ(_snapshot(a), before, "chamber"), 0, "chamber: classic again as built")
	_flip(a)
	assert_eq(_differ(_snapshot(a), styled, "chamber stylized"), 0, "chamber: stylized again the same")
	_flip(a)
	assert_eq(_differ(_snapshot(a), before, "chamber"), 0, "chamber: and back")
	assert_eq(a.shape(), shape, "the same floor")
	assert_eq((a.chamber as BossChamber).circles, circles, "the same footprints")


func test_the_chamber_built_while_stylized_is_the_same_classic() -> void:
	_world()
	var classic := _unnamed(_snapshot(_chamber()))
	VisualProfile.set_look(VisualProfile.Look.STYLIZED)
	var a := _chamber()
	_flip(a)
	assert_eq(_differ(_unnamed(_snapshot(a)), classic, "chamber built stylized"), 0, "the classic chamber whatever the look it was built in")


## A snapshot without the nodes' paths nor the objects' ids (two builds give their unnamed nodes other names and make
## their own textures).
func _unnamed(lines: PackedStringArray) -> PackedStringArray:
	var ids := RegEx.create_from_string("#-?[0-9]+")
	var out := PackedStringArray()
	for line in lines:
		out.append(ids.sub(line.substr(line.find(" ")), "#", true))
	return out


func test_the_chamber_stylized_pieces_stay_far() -> void:
	VisualProfile.set_look(VisualProfile.Look.STYLIZED)
	var a := _chamber()
	var c := a.chamber as BossChamber
	var styled := c.find_child("Styled", false, false) as Node3D
	assert_not_null(styled, "the chamber has stylized-only pieces")
	assert_false(VisualProfile.classic_of(styled, &"visible", true), "hidden in the classic look")
	var meshes := 0
	for n in styled.find_children("*", "MeshInstance3D", true, false):
		var mi := n as MeshInstance3D
		meshes += 1
		var near := INF
		for s in mi.mesh.get_surface_count():
			for v: Vector3 in mi.mesh.surface_get_arrays(s)[Mesh.ARRAY_VERTEX]:
				var g := mi.global_transform * v
				near = minf(near, Vector2(g.x, g.z).length())
		assert_gt(near, BossChamber.STY_CLEAR, "%s: past the floor and 6 m (%.1f m)" % [mi.name, near])
	assert_gt(meshes, 0, "arches and blocks built")
	# the chains: off the platform (from its wall under the floor or the tower out), never over Morvath on the screen
	var feel := Feel.live()
	var target := Vector3(c.cam_target.x, 0, c.cam_target.y)
	var eye := target + Feel.cam_offset_of(feel.cam_distance, feel.cam_pitch, feel.cam_yaw)
	var boss := Vector3(c.boss_spawn.x, 2.0, c.boss_spawn.y)
	assert_eq(styled.find_children("*", "MultiMeshInstance3D", true, false).size(), BossChamber.STY_CHAINS.size() + BossChamber.STY_ARCH_HANGS.size()
		+ BossChamber.STY_CAGES.size(), "the chains are there (the cages' own too)")
	# (the headless renderer keeps no MultiMesh transforms: the chains' curve as ArenaKit.chain lays it)
	for ch: Array in BossChamber.STY_CHAINS:
		for k in 41:
			var t := k / 40.0
			var p: Vector3 = (ch[0] as Vector3).lerp(ch[1], t) + Vector3.DOWN * float(ch[2]) * 4.0 * t * (1.0 - t)
			assert_gt(Vector2(p.x, p.z).length(), BossChamber.LIP_RADIUS, "a chain off the platform")
			var off := rad_to_deg((p - eye).angle_to(boss - eye))
			assert_gt(off, 8.0, "a chain clear of Morvath on the screen (%.1f degrees)" % off)


## SW-K1: the empty cages hang from the chains over the abyss, in the stylized look only, far from Morvath on the screen,
## no light of their own; F7 there and back is test_the_chamber_comes_back (the cages are under the Styled node).
func test_the_chamber_cages() -> void:
	VisualProfile.set_look(VisualProfile.Look.STYLIZED)
	var a := _chamber()
	var c := a.chamber as BossChamber
	var styled := c.find_child("Styled", false, false) as Node3D
	var n := BossChamber.STY_CAGES.size()
	assert_between(n, 2, 4, "two to four cages")
	var feel := Feel.live()
	var target := Vector3(c.cam_target.x, 0, c.cam_target.y)
	var eye := target + Feel.cam_offset_of(feel.cam_distance, feel.cam_pitch, feel.cam_yaw)
	var boss := Vector3(c.boss_spawn.x, 2.0, c.boss_spawn.y)
	var opened := 0
	for k in n:
		var cage := styled.find_child("Cage%d" % k, true, false) as Node3D
		assert_not_null(cage, "cage %d built under the stylized-only node" % k)
		if cage == null:
			continue
		assert_eq(cage.find_children("*", "Light3D", true, false).size(), 0, "no light of its own")
		assert_almost_eq(cage.position.distance_to(BossChamber.cage_hook(k)), 0.0, 0.001, "hung from its chain")
		for mi: MeshInstance3D in cage.find_children("*", "MeshInstance3D", true, false):
			assert_eq(mi.cast_shadow, GeometryInstance3D.SHADOW_CASTING_SETTING_OFF, "no shadow")
			for v: Vector3 in mi.mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX]:
				var g := mi.global_transform * v
				assert_gt(Vector2(g.x, g.z).length(), BossChamber.STY_CLEAR, "cage %d past the floor and 6 m" % k)
				var off := rad_to_deg((g - eye).angle_to(boss - eye))
				if off < 10.0:
					assert_gt(off, 10.0, "cage %d clear of Morvath on the screen (%.1f degrees)" % [k, off])
					break
		if float(BossChamber.STY_CAGES[k][4]) > 0.0 or int(BossChamber.STY_CAGES[k][5]) >= 0:
			opened += 1
	assert_between(opened, 1, 2, "one or two with the door open or a bar bent")
	# they swing
	var before := (styled.find_child("Cage0", true, false) as Node3D).transform
	await wait_process_frames(10)
	assert_ne((styled.find_child("Cage0", true, false) as Node3D).transform, before, "swinging slowly")
	VisualProfile.set_look(VisualProfile.Look.CLASSIC)


# ---------- Sworn P1: framed and grave slabs (SW-G3, SW-C1), the fallen column (SW-F1) ----------

## The painted floor's framed slabs of a room built in the stylized look (ArenaKit.framed): [rects, infos], read from
## its floor materials (the same on every one), or [] when it has none.
func _framed_of(a: Arena) -> Array:
	for n in a.find_children("*", "GeometryInstance3D", true, false):
		var g := n as GeometryInstance3D
		var mats: Array[Material] = [g.material_override]
		if g is MeshInstance3D and (g as MeshInstance3D).mesh != null:
			for i in (g as MeshInstance3D).mesh.get_surface_count():
				mats.append((g as MeshInstance3D).get_active_material(i))
		for m in mats:
			var sm := m as ShaderMaterial
			if sm == null or sm.shader != ArenaKit.FLOOR_PAINT:
				continue
			var count: Variant = sm.get_shader_parameter(&"framed_count")
			if count != null and int(count) > 0:
				var rects: Array = sm.get_shader_parameter(&"framed_rects")
				var infos: Array = sm.get_shader_parameter(&"framed_info")
				return [rects.slice(0, int(count)), infos.slice(0, int(count))]
	return []


func test_sworn_framed_slabs_lie_on_free_floor() -> void:
	VisualProfile.set_look(VisualProfile.Look.STYLIZED)
	for room: Array in [[&"hall", 0], [&"crypt", 0], [&"crypt", 1], [&"sanctuary", 0], [&"sanctuary", 1]]:
		var a := _arena(room[0], room[1])
		var what := "%s %d" % room
		var framed := _framed_of(a)
		assert_eq(framed.size(), 2, "%s: framed slabs on the painted floor" % what)
		if framed.size() < 2:
			continue
		var rects: Array = framed[0]
		var infos: Array = framed[1]
		assert_between(rects.size(), 2, ArenaKit.FRAMED_MAX, what + ": a handful")
		var raised := 0
		var graves := 0
		var lions := 0
		for i in rects.size():
			var r: Vector4 = rects[i]
			var info: Vector4 = infos[i]
			if int(info.x) == ArenaKit.Framed.RAISED:
				raised += 1
				assert_between(maxf(r.z, r.w) * 2.0, 1.8, 3.0, what + ": a frame of 2 to 3 m")
			else:
				graves += 1
				lions += 1 if info.y > 0.5 else 0
			# never on or by a slab that strikes (RP-06)
			assert_true(a.look.clear_of_plates(Vector2(r.x, r.y), Vector2(r.z, r.w) * 2.0) if a.look != null else true,
				"%s: slab %d clear of the striking slabs" % [what, i])
			# all of it on the floor, clear of every piece and of the other slabs
			for u: float in [-1.0, 0.0, 1.0]:
				for v: float in [-1.0, 0.0, 1.0]:
					var p := Vector2(r.x + u * r.z, r.y + v * r.w)
					assert_true(a.shape().contains(p, 0.2), "%s: slab %d on the floor at %s" % [what, i, p])
					assert_false(a.overlaps(p, 0.0), "%s: slab %d clear of the pieces at %s" % [what, i, p])
			for j in range(i + 1, rects.size()):
				var o: Vector4 = rects[j]
				var apart := absf(r.x - o.x) >= r.z + o.z or absf(r.y - o.y) >= r.w + o.w
				assert_true(apart, "%s: slabs %d and %d apart" % [what, i, j])
		match room[0]:
			&"hall":
				# S-1: four slabs either side of the flight's axis, never four equal frames (pressure plates)
				assert_eq(rects.size(), 4, "SW-H1: two pairs either side of the flight's axis")
				assert_eq(graves, 1, "S-1: one of them a grave slab with the lion")
				var sizes := {}
				for i in rects.size():
					sizes[Vector2((rects[i] as Vector4).z, (rects[i] as Vector4).w)] = true
					assert_lte((infos[i] as Vector4).z, 1.0, "S-1: never lighter than the floor")
				assert_gt(sizes.size(), 2, "S-1: of different sizes")
				for r: Vector4 in rects:
					var ring := Vector2(r.x, r.y).distance_to(CatacombHall.MEDALLION_AT)
					assert_gt(ring - Vector2(r.z, r.w).length(), CatacombHall.MEDALLION, "clear of the medallion")
			&"crypt":
				assert_eq(raised, 2, "SW-G3: a pair in the crypt")
				# off the striking slabs (RP-06) and the pieces standing on the rows (AT-Q's oil urn in A)
				assert_gt(graves, 6, "SW-C1: rows of grave slabs (off the striking slabs and the pieces)")
				# one in five with the lion, the old slabs (CryptLook.SLAB_ROWS, plain) counted
				var all := graves + CryptLook.SLAB_ROWS.size()
				assert_between(float(lions) / all, 0.15, 0.25, "about one grave in five with the lion")
			&"sanctuary":
				assert_eq(raised, 3, "SW-S3: a row in front of the grille")
	VisualProfile.set_look(VisualProfile.Look.CLASSIC)
	var classic := _arena(&"crypt", 0)
	assert_eq(_framed_of(classic).size(), 0, "the classic floor draws none")


## SW-F1: the fallen column lies across the rift's south hole, all of it under the floor (its top 0.6 m down at the
## lips, the base's torus a little higher), in A and B, only in the stylized look; its east half turned (F-2: no straight
## beam from lip to lip).
func test_sworn_fallen_column_under_the_floor() -> void:
	VisualProfile.set_look(VisualProfile.Look.STYLIZED)
	for v in 2:
		var a := _arena(&"rift", v)
		var styled := a.find_child("Styled", true, false) as Node3D
		var top := -INF
		var span := Vector2(INF, -INF)
		var east_z := Vector2(INF, -INF)
		for n in styled.find_children("*", "MeshInstance3D", true, false):
			var mi := n as MeshInstance3D
			if mi.mesh == null:
				continue
			for sf in mi.mesh.get_surface_count():
				for vert: Vector3 in mi.mesh.surface_get_arrays(sf)[Mesh.ARRAY_VERTEX]:
					var w := mi.global_transform * vert
					if absf(w.z - RiftLook.FALLEN_COLUMN.x) > 2.2:
						continue
					if w.x < RiftLook.FALLEN_COLUMN_SPAN.x - 0.5 or w.x > RiftLook.FALLEN_COLUMN_SPAN.y + 0.5 or w.y < -3.0:
						continue
					top = maxf(top, w.y)
					span = Vector2(minf(span.x, w.x), maxf(span.y, w.x))
					if w.x > RiftLook.FALLEN_COLUMN_BREAK.x + 1.0:
						east_z = Vector2(minf(east_z.x, w.z), maxf(east_z.y, w.z))
		assert_lt(top, RiftLook.FALLEN_COLUMN.y + 0.15, "rift %d: the column's top under the floor" % v)
		assert_gt(top, RiftLook.FALLEN_COLUMN.y - 0.3, "rift %d: and near it, seen" % v)
		assert_gt(east_z.y - east_z.x, RiftLook.FALLEN_COLUMN.z * 2.0 + 0.8, "rift %d: the east half turned, not a straight beam" % v)
		assert_lt(span.x, -6.5, "rift %d: from under the west lip" % v)
		assert_gt(span.y, 1.5, "rift %d: to under the east lip" % v)


## Sworn P2 SW-G5: a gate in every used door's mouth, shut through the fight, opened (once) when the doors open
## (ArenaRoom.breath), only in the stylized look; every gate off the floor and the mouth, shut and open.
func test_sworn_gates_open_with_the_doors() -> void:
	VisualProfile.set_look(VisualProfile.Look.STYLIZED)
	for id: StringName in [&"crypt", &"sanctuary", &"rift", &"bridge", &"altar"]:
		var a := _arena(id)
		var look := a.look
		var gates := a.find_children("Gate*", "Node3D", true, false)
		assert_eq(gates.size(), look.exits_used, "%s: a gate in each used door" % id)
		for i in look.exits_used:
			assert_true(look.gate_shut(i), "%s: door %d shut through the fight" % [id, i])
		look.breath(0, &"hall")
		assert_false(look.gate_shut(0), "%s: the first door's gate opens with the doors" % id)
		look.breath(0, &"hall")
		assert_false(look.gate_shut(0), "%s: and again does nothing" % id)
		for g: Node in gates:
			assert_true(g.get_parent() != null and not (g as Node3D).is_visible_in_tree() == false,
				"%s: the gate shows in the stylized look" % id)
		_flip(a)
		for g: Node in gates:
			assert_false((g as Node3D).is_visible_in_tree(), "%s: no gate in the classic look" % id)
		_flip(a)


## Sworn P2 SW-G4 and the rooms' items: the offerings (warm clay) stand in the rooms that turn them on; the crypt's
## femurs (SW-C2) and urns by the niches (SW-C3), the runes' tablets (SW-R1), the altar's basins (SW-A-1), the
## sanctuary's finials (SW-S2) are there; all off the floor (the lots' tests), none in the classic look.
func test_sworn_p2_pieces_stand() -> void:
	VisualProfile.set_look(VisualProfile.Look.STYLIZED)
	for id: StringName in [&"sanctuary", &"runes", &"trial", &"altar", &"crypt"]:
		var a := _arena(id)
		assert_false(a.look._clay.is_empty(), "%s: offerings of warm clay" % id)
	var altar := _arena(&"altar")
	var basins := 0
	for n in altar.find_children("*", "SpotLight3D", true, false):
		if (n as Light3D).light_color.is_equal_approx(AltarLook.BASIN_SPOT_COLOR):
			basins += 1
			assert_false((n as Light3D).shadow_enabled, "altar: the basin's light casts no shadow")
	assert_eq(basins, 2, "altar: two basins, each in its cold light")


## RS-C7: the Ponte's balustrades stop where their end post would stand on a bridge's deck or a door's mouth (both
## looks): nothing drawn between 0.3 and 2.6 m stands on the open walkable floor (0.2 m in from its edge) of A or B.
func test_rs_c7_bridge_rails_off_the_decks() -> void:
	for look: VisualProfile.Look in [VisualProfile.Look.CLASSIC, VisualProfile.Look.STYLIZED]:
		VisualProfile.set_look(look)
		for v in 2:
			var a := _arena(&"bridge", v)
			var bad := 0
			for n in a.find_children("*", "MeshInstance3D", true, false):
				var mi := n as MeshInstance3D
				if mi.mesh == null or not mi.is_visible_in_tree():
					continue
				for sf in mi.mesh.get_surface_count():
					for vert: Vector3 in mi.mesh.surface_get_arrays(sf)[Mesh.ARRAY_VERTEX]:
						var w := mi.global_transform * vert
						# a piece's own drawing may pass its outline by a hand (tools/fit_probe.gd's SLACK)
						if w.y > 0.3 and w.y < 2.6 and a.shape().contains(Vector2(w.x, w.z), 0.2) and not a.overlaps(Vector2(w.x, w.z), 0.2):
							bad += 1
			assert_eq(bad, 0, "bridge %d (%s): nothing drawn over the open floor" % [v, look])
	VisualProfile.set_look(VisualProfile.Look.CLASSIC)


## SW-G7: the hazards drawn as pieces (HazardPiece), built in both looks from the layout: a slab piece per plate, a
## chain post per band of the bridge (off the walkable floor), the slit's block, the crack up each toppling column
## (in ArenaRoom.toppling, so it leans with it); set_state and crack draw without touching collision.
func test_sw_g7_hazard_pieces() -> void:
	for look: VisualProfile.Look in [VisualProfile.Look.CLASSIC, VisualProfile.Look.STYLIZED]:
		VisualProfile.set_look(look)
		var crypt := _arena(&"crypt", 1)
		var hz := crypt.look.layout.hazard
		assert_not_null(crypt.look.hazard_piece(hz.plate_source, 0), "crypt B: the first slab's piece")
		assert_null(crypt.look.hazard_piece(hz.plate_source, hz.plates.size()), "and no more than the slabs")
		var slit := crypt.look.slit_at(Vector2(1.5, -10.5))
		assert_not_null(slit, "crypt B: the arrow slit's piece")
		var p := crypt.look.hazard_piece(hz.plate_source, 0)
		var cover := crypt.cover.size()
		for s: Vector3 in [Vector3(0.1, 0, 0), Vector3(0.9, 0, 0), Vector3(0, 0.5, 0), Vector3(0, 0, 0.5)]:
			p.set_state(s, false, 2.0)
			slit.set_state(s)
		p.set_state(Vector3.ZERO, true)
		assert_eq(crypt.cover.size(), cover, "drawing a hazard changes no collision")
		for o: ArenaObstacle in crypt.look.toppling:
			var c := crypt.look.hazard_piece(&"column", o)
			assert_not_null(c, "crypt B: the toppling column's crack")
			c.crack()
			assert_false((crypt.look.toppling[o] as Array).is_empty(), "the crack leans with the column")
		var bridge := _arena(&"bridge", 0)
		var bh := bridge.look.layout.hazard
		for i in bh.bands.size():
			var chain := bridge.look.hazard_piece(bh.band_source, i)
			assert_not_null(chain, "bridge: a chain post a band")
			assert_false(bridge.shape().contains(Vector2(chain.position.x, chain.position.z), 0.0),
				"bridge: the post stands off the walkable floor")
			chain.set_state(Vector3(0.5, 0, 0))
			chain.set_state(Vector3(0, 0.5, 0))
	VisualProfile.set_look(VisualProfile.Look.CLASSIC)
