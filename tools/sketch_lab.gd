extends SceneTree
## The Compêndio's ink drawings (AP-4, ART-07.4, FigureSketch) of every enemy on the Livro's paper, one sheet:
##   xvfb-run -a ~/tools/godot/godot --path . --resolution 1600x900 -s tools/sketch_lab.gd -- out.png [ids...] [--px=240] [--t=0.4]
## (or tools/gpu.sh run ... with a C:/ path). Each figure in a FigureView-like view (orthographic, turned 30 degrees, idle
## at --t seconds), the sketch passes over a paper-coloured page. The tool is tools/lab/sketch_lab.gd (autoloads).


func _initialize() -> void:
	root.add_child.call_deferred((load("res://tools/lab/sketch_lab.gd") as GDScript).new())
