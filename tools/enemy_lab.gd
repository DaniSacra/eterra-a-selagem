extends SceneTree
## A board of the first region's enemies as the game draws them (CrowdRenderer, their EnemyDef: model, palette,
## size), the hero beside them for scale, to set next to Daniel's sheet (docs/art/ref/inimigos_fase1.png):
## tools/gpu.sh run --rendering-driver vulkan --resolution 1672x941 -s tools/enemy_lab.gd -- C:/out_prefix [anim] [seconds] [ids...]
## (or xvfb-run -a ~/tools/godot/godot --path . ... on the CPU). Writes <out_prefix>_game.png (the game's camera
## angle), _front.png, _back.png and _side.png (the right side). With ids (EnemyDef ids), only those, in one row and closer; seconds as "a:b"
## spreads that row over the clip (the same id many times shows the clip as a strip); "clip" spreads it over the whole clip.
## Options anywhere after the prefix: --zoom=2 (the camera that much closer), --tell=0.8 (every figure as if that far
## into its wind-up: the swollen orb and the lights of EnemyFx), --loosed=0.03 (as if its attack was loosed that many
## seconds ago), --absorbed (a blow just landed on its armor), --broken (its armor is gone), --look=stylized,
## --spin (the game's view with the row turning round: the same id many times, seen from every side).
## Cycle 8: --bars (each one's life bar as the game draws it: 60% life with a pale trail to 85%, an elite with 70% of
## its armor, or none with --broken) and --warn=0.6 (the warning of its attack on the floor, that far filled, aimed
## down and to the right of the screen).
## The tool itself is tools/lab/enemy_lab.gd, loaded at run time: the classes it draws with reach the autoloads (T, Audio),
## which a -s script cannot name when it is compiled.


func _initialize() -> void:
	root.add_child.call_deferred((load("res://tools/lab/enemy_lab.gd") as GDScript).new())
