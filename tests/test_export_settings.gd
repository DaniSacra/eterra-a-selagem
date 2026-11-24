extends GutTest
## The exported build must read the data as the editor does (2026-11-19, P0 of the evidence package): with Godot's
## default text-to-binary conversion on export the stage's reward_deck (a PackedInt32Array) came out empty in the
## exe, so every door offered a Blessing and the shop stayed empty. The project keeps the text resources as they are.


func test_text_resources_are_not_converted_on_export() -> void:
	assert_false(bool(ProjectSettings.get_setting("editor/export/convert_text_resources_to_binary", true)),
		"editor/export/convert_text_resources_to_binary must stay false (the exe lost the reward deck)")


## 2026-11-23: the Maga's staff (res://assets/models/meshy/w_maga_staff/) sat under a `w_*` exclusion and was loaded at run
## time, so the exe would have crashed building her body. Every res:// asset path written in a script must survive every
## preset's exclude_filter (a path inside a guarded `exists` check is listed in OPTIONAL).
const OPTIONAL: Array[String] = []


func _filters() -> Array:
	var cfg := ConfigFile.new()
	assert_eq(cfg.load("res://export_presets.cfg"), OK)
	var out: Array = []
	for section in cfg.get_sections():
		if cfg.has_section_key(section, "exclude_filter"):
			var parts: Array = []
			for f in str(cfg.get_value(section, "exclude_filter")).split(","):
				if f.strip_edges() != "":
					parts.append(f.strip_edges())
			out.append([section, parts])
	return out


func _script_paths(dir: String, acc: Array) -> void:
	for f in DirAccess.get_files_at(dir):
		if f.ends_with(".gd"):
			var text := FileAccess.get_file_as_string(dir.path_join(f))
			var rx := RegEx.create_from_string("\"(res://assets/[^\"\\s%]+)\"")
			for m in rx.search_all(text):
				acc.append([m.get_string(1), dir.path_join(f)])
	for d in DirAccess.get_directories_at(dir):
		_script_paths(dir.path_join(d), acc)


func test_assets_loaded_by_scripts_are_not_excluded_from_the_export() -> void:
	var paths: Array = []
	_script_paths("res://scripts", paths)
	assert_gt(paths.size(), 0)
	var filters := _filters()
	assert_gt(filters.size(), 0)
	for pair: Array in paths:
		var path: String = pair[0]
		if path in OPTIONAL:
			continue
		var rel := path.trim_prefix("res://")
		for preset: Array in filters:
			for pattern: String in preset[1]:
				assert_false(rel.match(pattern), "%s (%s) is excluded by %s in %s" % [path, pair[1], pattern, preset[0]])
