extends SceneTree
## The painted motifs of the 19 Gifts (TalentMotif, AP-4 spec 2.2) measured, and drawn as a board:
##   ~/tools/godot/godot --headless --path . -s tools/motif_sheet.gd                 # the table only, no screen
##   tools/gpu.sh run --resolution 1920x1080 -s tools/motif_sheet.gd -- --png=C:/out.png   # the board on the GPU
## The board: every motif in its five states (OPEN, EQUIPPED, SEALED, BLOCKED, LOCKED) at radius 16 (the tree at 720)
## and 32 on a node's toasted paper, then the glyph at 12 (the LOD); --big draws them all at radius 80. The table: each pair's overlap of silhouettes at
## radius 16 (intersection over union; FAIL from 0.8, LOOK from 0.7), each motif's colour (largest channel, HSV
## saturation p50, hue p50 against its branch's), the outline's contrast on the node and the locked outline's luma step.
## Body in tools/lab/motif_sheet.gd (it names classes that reach the autoloads).


func _initialize() -> void:
	root.add_child.call_deferred((load("res://tools/lab/motif_sheet.gd") as GDScript).new())
