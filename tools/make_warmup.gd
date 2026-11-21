extends SceneTree
## Harvests every material a run draws into the warm-up set (P1-1 of docs/qa/latest_report.md, DT-RS3): plays the game
## headless as boot would (the game's own switches after --), waits --harvest-at frames, then walks the whole tree and
## keeps one copy of each material by what makes the renderer compile a new shader (a ShaderMaterial's code, a
## StandardMaterial3D's flags and which textures it has), with how it is drawn (mesh, multimesh, canvas, fog, sky).
## The copies are light: no texture (a ShaderMaterial's samplers left empty, a BaseMaterial3D's a 2 x 2 stand-in).
## Each run adds to the set (--fresh starts it again); tools/make_warmup.sh runs every arena, both looks, both renderers.
## Warmup (scripts/render/warmup.gd) draws one frame of each at the start, behind the title or a black screen.
##   ~/tools/godot/godot --headless --path . -s tools/make_warmup.gd -- --nosave --bot --fast=3 --arena=crypt [--fresh]
## Nothing here names a class with an autoload (this script is compiled before them): the game is read by nodes only.

const OUT := "res://assets/warmup/warmup_set.res"
const KINDS := ["mesh", "multi", "canvas", "fog", "sky", "label", "sprite"]

## Properties that never change the compiled shader.
const SAME_SHADER := ["next_pass", "render_priority", "resource_local_to_scene", "resource_name"]

var _frames := 0
var _at := 150
var _keys := {}
var _items: Array = []
var _stand_in: ImageTexture


func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--harvest-at="):
			_at = int(a.get_slice("=", 1))
	if not OS.get_cmdline_user_args().has("--fresh") and ResourceLoader.exists(OUT):
		var old := ResourceLoader.load(OUT, "", ResourceLoader.CACHE_MODE_IGNORE)
		for item in old.get_meta(&"items", []):
			_keys[item[1]] = true
			_items.append(item)
	var img := Image.create(2, 2, false, Image.FORMAT_RGBA8)
	img.fill(Color.WHITE)
	_stand_in = ImageTexture.create_from_image(img)
	change_scene_to_file.call_deferred("res://scenes/boot.tscn")


func _process(_delta: float) -> bool:
	_frames += 1
	if _frames == _at:
		var before := _items.size()
		_walk(root)
		_save()
		print("WARMUP %d new, %d in the set (%s)" % [_items.size() - before, _items.size(), " ".join(OS.get_cmdline_user_args())])
		quit()
	return false


func _walk(n: Node) -> void:
	if n is GeometryInstance3D:
		var multi := n is MultiMeshInstance3D or n is CPUParticles3D
		var kind := "multi" if multi else "mesh"
		if n is Label3D:
			_add_node("label", n)
		elif n is SpriteBase3D:
			_add_node("sprite", n)
		_add(kind, n.material_override)
		_add(kind, n.material_overlay)
		var mesh: Mesh = null
		if n is MeshInstance3D:
			mesh = n.mesh
			for i in n.get_surface_override_material_count():
				_add(kind, n.get_surface_override_material(i))
		elif n is MultiMeshInstance3D and n.multimesh != null:
			mesh = n.multimesh.mesh
		elif n is CPUParticles3D:
			mesh = n.mesh
		elif n is GPUParticles3D:
			for i in n.draw_passes:
				var pass_mesh: Mesh = n.get_draw_pass_mesh(i)
				if pass_mesh != null:
					for s in pass_mesh.get_surface_count():
						_add("multi", pass_mesh.surface_get_material(s))
		if mesh != null:
			for s in mesh.get_surface_count():
				_add(kind, mesh.surface_get_material(s))
	elif n is FogVolume:
		_add("fog", n.material)
	elif n is WorldEnvironment and n.environment != null and n.environment.sky != null:
		_add("sky", n.environment.sky.sky_material)
	elif n is CanvasItem and n.material is ShaderMaterial:
		_add("canvas", n.material)
	for c in n.get_children():
		_walk(c)


## The renderer compiles one shader per ShaderMaterial code and per StandardMaterial3D feature set: that is the key.
func _key(kind: String, m: Material) -> String:
	if m is ShaderMaterial:
		var sh: Shader = m.shader
		if sh == null:
			return ""
		var code := sh.resource_path if sh.resource_path != "" and not sh.resource_path.contains("::") else str(sh.code.hash())
		return kind + ":S:" + code
	var parts := PackedStringArray([kind, m.get_class()])
	for p in m.get_property_list():
		if p.usage & PROPERTY_USAGE_STORAGE == 0 or p.name in SAME_SHADER:
			continue
		var v: Variant = m.get(p.name)
		if p.type == TYPE_BOOL or p.type == TYPE_INT:
			parts.append("%s=%s" % [p.name, v])
		elif p.type == TYPE_OBJECT and p.hint == PROPERTY_HINT_RESOURCE_TYPE:
			parts.append("%s=%s" % [p.name, v != null])
	return ":".join(parts)


func _add(kind: String, m: Material) -> void:
	if m == null:
		return
	if m.next_pass != null:
		_add(kind, m.next_pass)
	if not (m is ShaderMaterial or m is BaseMaterial3D):
		return
	var key := _key(kind, m)
	if key == "" or _keys.has(key):
		return
	_keys[key] = true
	_items.append([kind, key, _light_copy(m)])


## Same shader, nothing heavy: no textures in a ShaderMaterial (an empty sampler compiles the same), a stand-in in a
## BaseMaterial3D (whether it has one changes its shader), no next pass (that is an item of its own).
func _light_copy(m: Material) -> Material:
	var c := m.duplicate(false) as Material
	c.next_pass = null
	if c is ShaderMaterial and c.shader != null:
		for u in c.shader.get_shader_uniform_list():
			if c.get_shader_parameter(u.name) is Texture:
				c.set_shader_parameter(u.name, null)
	elif c is BaseMaterial3D:
		for p in c.get_property_list():
			if p.usage & PROPERTY_USAGE_STORAGE != 0 and c.get(p.name) is Texture2D:
				c.set(p.name, _stand_in)
	return c


## Label3D and Sprite3D make their own material from their flags: keep the flags.
func _add_node(kind: String, n: GeometryInstance3D) -> void:
	var flags := {}
	for p in ["billboard", "shaded", "double_sided", "no_depth_test", "fixed_size", "alpha_cut", "texture_filter",
			"render_priority", "outline_render_priority", "transparent", "alpha_antialiasing_mode"]:
		if p in n:
			flags[p] = n.get(p)
	var key := kind + ":" + str(flags)
	if _keys.has(key):
		return
	_keys[key] = true
	var holder := Resource.new()
	holder.set_meta(&"flags", flags)
	_items.append([kind, key, holder])


## Every shader file the runs did not show (a reward's light, the dodge's ghosts, a trial's veins...): a material with
## the file and its defaults compiles the same shader.
func _every_file() -> void:
	for f in DirAccess.get_files_at("res://assets/shaders"):
		if not f.ends_with(".gdshader"):
			continue
		var path := "res://assets/shaders/" + f
		var sh := load(path) as Shader
		var kind := ""
		match sh.get_mode():
			Shader.MODE_SPATIAL:
				kind = "mesh"
			Shader.MODE_CANVAS_ITEM:
				kind = "canvas"
			Shader.MODE_FOG:
				kind = "fog"
		if kind == "" or _keys.has(kind + ":S:" + path) or (kind == "mesh" and _keys.has("multi:S:" + path)):
			continue
		var m := ShaderMaterial.new()
		m.shader = sh
		_keys[kind + ":S:" + path] = true
		_items.append([kind, kind + ":S:" + path, m])


func _save() -> void:
	_every_file()
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT.get_base_dir()))
	var set := Resource.new()
	set.set_meta(&"items", _items)
	var err := ResourceSaver.save(set, OUT, ResourceSaver.FLAG_COMPRESS)
	if err != OK:
		push_error("warm-up set not saved: %d" % err)
