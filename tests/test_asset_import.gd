extends GutTest
## The 3D textures stay compressed for the video card however the project is imported (docs/qa/asset_report.md,
## "Feito" C1). The editor only switches a texture to VRAM when it sees it in a 3D material on screen
## (detect_3d/compress_to); this project is imported without a screen, so that never happened and the hero, the Emeth,
## the rock relief and every KayKit piece went to the card uncompressed (48 MB for the hero and the Emeth, 112 MB for
## 21 copies of the same KayKit palette). Each .import below says VRAM itself, with the detection off.

## Texture, then what its .import must say.
const VRAM := {
	"res://assets/models/kaykit_palette.png": {"compress/high_quality": true},
	"res://assets/models/meshy/hero_explorer/hero_explorer-rigged_Image_0.jpg": {"compress/high_quality": true},
	"res://assets/models/meshy/hero_warrior_gpt/hero_warrior_gpt-rigged_Image_0.jpg": {"compress/high_quality": true},
	"res://assets/models/meshy/hero_maga_gpt/hero_maga_gpt-rigged_Image_0.jpg": {"compress/high_quality": true},
	"res://assets/models/meshy/emeth/emeth_0.jpg": {"compress/high_quality": true, "process/size_limit": 1024},
	# the stone statue and lion are drawn by the rooms' stone material, their own painting is not used: 64 px
	"res://assets/models/meshy/statue_hooded/statue_hooded_0.jpg": {"compress/high_quality": true, "process/size_limit": 64},
	"res://assets/models/meshy/lion_seated/lion_seated_0.jpg": {"compress/high_quality": true, "process/size_limit": 64},
	"res://assets/textures/rock_surface/rock_surface_nor_gl_1k.jpg": {"compress/normal_map": 1},
	"res://assets/textures/rock_surface/rock_surface_disp_1k.jpg": {"compress/channel_pack": 1},
}
const KIT_DIRS := ["res://assets/models/dungeon_r/"]
const KIT_MATERIAL := "res://assets/models/kaykit_material.tres"


func _params(path: String) -> ConfigFile:
	var c := ConfigFile.new()
	assert_eq(c.load(path + ".import"), OK, path)
	return c


func test_3d_textures_are_vram_compressed_without_the_editor() -> void:
	for path: String in VRAM:
		var c := _params(path)
		assert_eq(c.get_value("params", "compress/mode"), 2, "%s: VRAM compressed" % path)
		assert_eq(c.get_value("params", "detect_3d/compress_to"), 0, "%s: nothing left to the editor" % path)
		assert_true(c.get_value("params", "mipmaps/generate"), "%s: mipmaps" % path)
		var want: Dictionary = VRAM[path]
		for key: String in want:
			assert_eq(c.get_value("params", key), want[key], "%s: %s" % [path, key])
		var formats: Array = c.get_value("remap", "metadata", {}).get("imported_formats", [])
		assert_true(formats.has("s3tc_bptc"), "%s: imported for the desktop and the browser (S3TC/BPTC)" % path)


func test_the_loaded_textures_are_block_compressed() -> void:
	var want := {
		"res://assets/models/meshy/hero_explorer/hero_explorer-rigged_Image_0.jpg": Image.FORMAT_BPTC_RGBA,
		"res://assets/models/meshy/hero_warrior_gpt/hero_warrior_gpt-rigged_Image_0.jpg": Image.FORMAT_BPTC_RGBA,
		"res://assets/models/meshy/emeth/emeth_0.jpg": Image.FORMAT_BPTC_RGBA,
		"res://assets/models/kaykit_palette.png": Image.FORMAT_BPTC_RGBA,
		"res://assets/textures/rock_surface/rock_surface_nor_gl_1k.jpg": Image.FORMAT_RGTC_RG,
		"res://assets/textures/rock_surface/rock_surface_disp_1k.jpg": Image.FORMAT_RGTC_R,
	}
	for path: String in want:
		var image := (load(path) as Texture2D).get_image()
		assert_eq(image.get_format(), want[path], path)
		assert_true(image.has_mipmaps(), "%s: mipmaps" % path)
	assert_eq((load("res://assets/models/meshy/emeth/emeth_0.jpg") as Texture2D).get_width(), 1024, "Emeth at 1024")


func test_every_kaykit_piece_shares_one_palette() -> void:
	var count := 0
	for dir: String in KIT_DIRS:
		for f in DirAccess.get_files_at(dir):
			assert_false(f.ends_with(".png"), "%s%s: a copy of the palette came back" % [dir, f])
			if not f.ends_with(".glb"):
				continue
			count += 1
			var c := _params(dir + f)
			var sub: Dictionary = c.get_value("params", "_subresources", {})
			var mat: Dictionary = sub.get("materials", {}).get("texture", {})
			assert_true(mat.get("use_external/enabled", false), dir + f)
			assert_eq(mat.get("use_external/path", ""), KIT_MATERIAL, dir + f)
			assert_eq(c.get_value("params", "gltf/embedded_image_handling"), 0, "%s: no texture of its own" % [dir + f])
	assert_gt(count, 30, "every piece checked")
	var scene: Node = (load(KIT_DIRS[0] + "wall.glb") as PackedScene).instantiate()
	var mesh := _first_mesh(scene)
	var m := mesh.mesh.surface_get_material(0) as StandardMaterial3D
	assert_eq(m.resource_path, KIT_MATERIAL, "the piece wears the shared material")
	assert_almost_eq(m.roughness, 0.45, 0.001, "the kit's own roughness")
	scene.free()


func _first_mesh(n: Node) -> MeshInstance3D:
	if n is MeshInstance3D:
		return n
	for c in n.get_children():
		var m := _first_mesh(c)
		if m:
			return m
	return null
