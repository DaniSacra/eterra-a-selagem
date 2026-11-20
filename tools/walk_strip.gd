extends SceneTree
## Strips of the enemies walking as the game draws them (CrowdRenderer, their EnemyDef), each one alone crossing a
## checkered floor (0.5 m squares) at its own speed, its walk at Horde.walk_rate, seen from the game's 30 degree
## pitch from its side, the camera following: a planted foot that slides moves over the squares. 24 frames at 30 FPS
## per figure, in one sheet of 8 x 3 (frame 0 top left), plus one PNG per frame.
## tools/gpu.sh run --rendering-driver vulkan --resolution 640x640 -s tools/walk_strip.gd -- C:/out_dir [ids...]
## (or xvfb-run -a ~/tools/godot/godot --path . ... on the CPU). Writes <out_dir>/<id>_walk.png and <id>_walk_NN.png. An id
## "<id>@<model>" draws that enemy with another baked model (runner_elite@runner_elite before its EnemyDef names it).
## The tool itself is tools/lab/walk_strip.gd, loaded at run time: the classes it draws with reach the autoloads (T, Audio),
## which a -s script cannot name when it is compiled.


func _initialize() -> void:
	root.add_child.call_deferred((load("res://tools/lab/walk_strip.gd") as GDScript).new())
