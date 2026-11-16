extends SceneTree
## Starts the game feel probe (tools/feel_probe.gd) once the autoloads exist (a -s script compiles before them).
## ~/tools/godot/godot --headless --path . --fixed-fps 60 -s tools/feel_probe_run.gd -- --nosave --start=fountain


func _initialize() -> void:
	create_timer(300.0).timeout.connect(quit)
	(func() -> void: root.add_child(load("res://tools/feel_probe.gd").new())).call_deferred()
