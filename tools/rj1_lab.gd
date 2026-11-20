extends SceneTree
## Fatia 1 (RJ-1) evidence for the technical-artist's part: the four angels' seals (AngelSeal) and the Emeth at each
## rank of Temperar (emeth.gdshader temper, EmethSword.set_temper).
##   tools/gpu.sh run --rendering-driver vulkan --resolution 1600x900 -s tools/rj1_lab.gd -- --lab-out=C:/x/rj1 [--look=stylized]
## Writes <lab-out>_seals.png (the seals at 24, 46, 96 and 140 px on ink and on the book's paper, lit and unlit) and
## <lab-out>_emeth_<look>.png (the blade at temper 0, 1, 2, 1.5 in the world's air, the run's light). Nothing ships.
## The tool itself is tools/lab/rj1_lab.gd, loaded at run time: the classes it draws with reach the autoloads (T, Audio),
## which a -s script cannot name when it is compiled.


func _initialize() -> void:
	root.add_child.call_deferred((load("res://tools/lab/rj1_lab.gd") as GDScript).new())
