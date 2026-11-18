extends SceneTree
## Measures the game's models for the asset audit (docs/qa/asset_report.md), without changing anything:
## ~/tools/godot/godot --headless --path . -s tools/asset_probe.gd [-- baked|scenes|all]
## baked: every assets/baked/*.res (BakedModel): vertices, triangles, poses per clip, pose images, painted texture
## (size, format, mipmaps), height, feet on the floor in the first idle pose (lowest vertex), parts.
## scenes: the glTF models the game loads itself (hero, Emeth) and the KayKit dungeon pieces: triangles, bones,
## textures (size, format) and the height of the bounding box.
## vram (needs a real renderer, not --headless): the video memory each texture the game loads takes, read from the
## engine's own monitor (RENDER_TEXTURE_MEM_USED) before and after loading it, one line "VRAM ...", and the KayKit
## dungeon pieces the full run loads, together. On WSL: MESA_D3D12_DEFAULT_ADAPTER_NAME=NVIDIA GALLIUM_DRIVER=d3d12
## LD_LIBRARY_PATH=/usr/lib/wsl/lib ~/tools/godot/godot --rendering-driver opengl3 --path . -s tools/asset_probe.gd -- vram
## Prints one line per model, "BAKED ..." or "SCENE ...", so the report can quote them.

const BAKED_DIR := "res://assets/baked/"
const SCENES := [
	"res://assets/models/meshy/hero_explorer/hero_explorer-rigged.glb",
	"res://assets/models/meshy/emeth/emeth.glb",
]
const KIT_DIRS := ["res://assets/models/dungeon/", "res://assets/models/dungeon_r/"]
## What the vram mode loads one by one: the textures of the hero, the Emeth, the rock relief and the title.
const VRAM_TEXTURES := [
	"res://assets/models/meshy/hero_explorer/hero_explorer-rigged_Image_0.jpg",
	"res://assets/models/meshy/emeth/emeth_0.jpg",
	"res://assets/textures/rock_surface/rock_surface_nor_gl_1k.jpg",
	"res://assets/textures/rock_surface/rock_surface_disp_1k.jpg",
	"res://assets/ui/title/title_bg.png",
	"res://assets/ui/boons/aurora.png",
]
## The KayKit pieces a whole descent loads (traced with --verbose over every arena, variant and event room).
const KIT_LOADED := ["dungeon/banner_patternA_white", "dungeon/banner_thin_yellow", "dungeon/barrel_large",
	"dungeon/candle_lit", "dungeon/candle_triple", "dungeon/floor_tile_large", "dungeon/pillar", "dungeon/pillar_decorated",
	"dungeon/rubble_half", "dungeon/rubble_large", "dungeon/stairs_wide", "dungeon/sword_shield_broken",
	"dungeon/torch_mounted", "dungeon/wall", "dungeon/wall_arched", "dungeon/wall_broken", "dungeon/wall_corner",
	"dungeon/wall_cracked", "dungeon_r/box_small", "dungeon_r/rubble_half", "dungeon_r/rubble_large"]

var _keep: Array[Resource] = []


func _init() -> void:
	var what := "all"
	var args := OS.get_cmdline_user_args()
	if not args.is_empty():
		what = args[0]
	if what == "vram":
		_vram.call_deferred()
		return
	if what in ["baked", "all"]:
		_baked()
	if what in ["scenes", "all"]:
		for path: String in SCENES:
			_scene(path)
		for dir: String in KIT_DIRS:
			for f in DirAccess.get_files_at(dir):
				if f.ends_with(".glb"):
					_scene(dir + f)
	quit()


func _vram() -> void:
	await process_frame
	for path: String in VRAM_TEXTURES:
		var before := _tex_mem()
		_keep.append(load(path))
		await process_frame
		print("VRAM %s %.2f MB" % [path.trim_prefix("res://"), (_tex_mem() - before) / 1048576.0])
	var before_kit := _tex_mem()
	for piece: String in KIT_LOADED:
		_keep.append(load("res://assets/models/%s.glb" % piece))
	await process_frame
	print("VRAM kaykit_pieces=%d %.2f MB" % [KIT_LOADED.size(), (_tex_mem() - before_kit) / 1048576.0])
	var before_baked := _tex_mem()
	for f in DirAccess.get_files_at(BAKED_DIR):
		if f.ends_with(".res"):
			var m := load(BAKED_DIR + f) as BakedModel
			_keep.append(m)
			_keep.append_array(m.pose_textures())
	await process_frame
	print("VRAM baked (albedo and pose images) %.2f MB" % [(_tex_mem() - before_baked) / 1048576.0])
	quit()


func _tex_mem() -> float:
	return Performance.get_monitor(Performance.RENDER_TEXTURE_MEM_USED)


func _baked() -> void:
	for f in DirAccess.get_files_at(BAKED_DIR):
		if not f.ends_with(".res"):
			continue
		var m := load(BAKED_DIR + f) as BakedModel
		if m == null:
			print("BAKED %s not a BakedModel" % f)
			continue
		var tris := 0
		for s in m.mesh.get_surface_count():
			var arrays := m.mesh.surface_get_arrays(s)
			var idx: PackedInt32Array = arrays[Mesh.ARRAY_INDEX]
			tris += (idx.size() if not idx.is_empty() else (arrays[Mesh.ARRAY_VERTEX] as PackedVector3Array).size()) / 3
		var clips: Array[String] = []
		var poses := 0
		for clip: StringName in m.frames:
			clips.append("%s:%d" % [clip, m.frames[clip]])
			poses += int(m.frames[clip])
		var tex := "none"
		if m.albedo != null:
			var img := m.albedo.get_image()
			tex = "%dx%d %s mips=%s" % [img.get_width(), img.get_height(), _format(img.get_format()), img.has_mipmaps()]
		var foot := INF
		if m.frames.has(&"idle"):
			for p in m.pose(&"idle", 0):
				foot = minf(foot, p.y)
		print("BAKED %s vertices=%d triangles=%d poses=%d pos_img=%dx%d %s nrm_img=%dx%d %s albedo=%s height=%.2f idle_floor=%.3f parts=%s clips=%s" % [
			f.get_basename(), m.vertices, tris, poses,
			m.positions.get_width(), m.positions.get_height(), _format(m.positions.get_format()),
			m.normals.get_width(), m.normals.get_height(), _format(m.normals.get_format()),
			tex, m.height, foot, m.parts.keys(), " ".join(clips)])


func _scene(path: String) -> void:
	var packed := load(path) as PackedScene
	if packed == null:
		print("SCENE %s not loadable" % path)
		return
	var root := packed.instantiate()
	var tris := 0
	var bones := 0
	var textures := {}
	var box := AABB()
	var first := true
	for n in _all(root):
		if n is Skeleton3D:
			bones = maxi(bones, (n as Skeleton3D).get_bone_count())
		if n is MeshInstance3D:
			var mi := n as MeshInstance3D
			if mi.mesh == null:
				continue
			for s in mi.mesh.get_surface_count():
				var arrays := mi.mesh.surface_get_arrays(s)
				var idx: PackedInt32Array = arrays[Mesh.ARRAY_INDEX]
				tris += (idx.size() if not idx.is_empty() else (arrays[Mesh.ARRAY_VERTEX] as PackedVector3Array).size()) / 3
				var mat := mi.get_active_material(s)
				if mat is BaseMaterial3D and (mat as BaseMaterial3D).albedo_texture != null:
					var t := (mat as BaseMaterial3D).albedo_texture
					var img := t.get_image()
					textures[t.resource_path.get_file()] = "%dx%d %s" % [img.get_width(), img.get_height(), _format(img.get_format())]
			var b := mi.global_transform * mi.mesh.get_aabb() if mi.is_inside_tree() else _world(mi) * mi.mesh.get_aabb()
			box = b if first else box.merge(b)
			first = false
	print("SCENE %s triangles=%d bones=%d height=%.2f textures=%s" % [path.trim_prefix("res://"), tris, bones, box.size.y, textures])
	root.free()


func _world(n: Node) -> Transform3D:
	var t := Transform3D.IDENTITY
	var cur := n
	while cur != null:
		if cur is Node3D:
			t = (cur as Node3D).transform * t
		cur = cur.get_parent()
	return t


func _all(n: Node) -> Array[Node]:
	var out: Array[Node] = [n]
	for c in n.get_children():
		out.append_array(_all(c))
	return out


func _format(f: int) -> String:
	match f:
		Image.FORMAT_RGB8: return "RGB8"
		Image.FORMAT_RGBA8: return "RGBA8"
		Image.FORMAT_RGBAH: return "RGBAH"
		Image.FORMAT_RG8: return "RG8"
		Image.FORMAT_DXT1: return "DXT1"
		Image.FORMAT_DXT5: return "DXT5"
		Image.FORMAT_BPTC_RGBA: return "BPTC"
		Image.FORMAT_L8: return "L8"
	return str(f)
