extends SceneTree
## The Compêndio's ink drawings (AP-4, ART-07.4, FigureSketch) of every enemy on the Livro's paper, one sheet:
##   xvfb-run -a ~/tools/godot/godot --path . --resolution 1920x1080 -s tools/sketch_lab.gd -- out.png [ids...] [--px=240] [--t=s]
## (or tools/gpu.sh run ... with a C:/ path). Each figure as FigureSketch frames it (three-quarter view, every idle pose in
## the frame, the pose that shows its weapon, or --t seconds) over a paper-coloured page. Body: tools/lab/sketch_lab.gd.


func _initialize() -> void:
	root.add_child.call_deferred((load("res://tools/lab/sketch_lab.gd") as GDScript).new())
