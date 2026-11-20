extends SceneTree
## TA-HB2: the edge and foreground pieces of EdgeKit on a bare floor at the game's camera (yaw 35, pitch 30, fov 24,
## 54 m), one by one: prints each piece's triangles and the draw calls it adds, then saves the board.
##   tools/gpu.sh run --rendering-driver vulkan --resolution 1920x1080 -s tools/edge_lab.gd -- C:/x/edge [--look=stylized] [--hero=x,z]
## Writes <prefix>_<look>.png. --hero puts the paladin's place there (hero_pos), to see a piece open round him.
## The tool itself is tools/lab/edge_lab.gd, loaded at run time (the classes it draws with reach the autoloads).


func _initialize() -> void:
	root.add_child.call_deferred((load("res://tools/lab/edge_lab.gd") as GDScript).new())
