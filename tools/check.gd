extends SceneTree
## Loads every script so parse errors show up at once: ~/tools/godot/godot --headless --path . -s tools/check.gd


func _initialize() -> void:
	var bad := 0
	for dir in ["res://scripts", "res://tools", "res://tests"]:
		bad += _walk(dir)
	print("CHECK ", "ok" if bad == 0 else "%d scripts failed" % bad)
	quit(1 if bad else 0)


func _walk(dir: String) -> int:
	var bad := 0
	for f in DirAccess.get_files_at(dir):
		if f.ends_with(".gd") and f != "check.gd":
			var s: Script = load(dir + "/" + f)
			if s == null or not s.can_instantiate():
				bad += 1
	for d in DirAccess.get_directories_at(dir):
		bad += _walk(dir + "/" + d)
	return bad
