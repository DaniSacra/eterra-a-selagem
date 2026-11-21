extends SceneTree
## AT-SA2 (backlog P.1): is the first warning of an enemy's attack whole on the screen when it shows? Plays the first
## room (the Salão's opening fight unless --arena= says another) with the bot and prints, at the frame the first
## warning of an enemy is laid, where its outline falls on the screen (0 to 1 across and down) through the camera in
## use (Perto by default, --cam=far for Longe), then quits:
## ~/tools/godot/godot --headless --path . -s tools/first_warning.gd -- --bot --autopick --nosave --seed=5 [--cam=far]
## Prints FIRST_WARNING {"seed", "t", "by", "shape", "min", "max", "whole"}; "whole" true when every point of the
## outline is inside the screen. The tool itself is tools/lab/first_warning.gd, loaded at run time (the game's classes
## reach the autoloads, which a -s script cannot name when it is compiled).


func _initialize() -> void:
	root.add_child.call_deferred((load("res://tools/lab/first_warning.gd") as GDScript).new())
