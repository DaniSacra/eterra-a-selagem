extends SceneTree
## The paladin behind the garden's tree (cycle C12, spec 4.4: he must be seen in every place behind the crown): the
## real game in the garden (--arena=garden, --variant=n), the paladin set on a grid every STEP m over the floor north
## and west of the trunk (the part the crown and the trunk hide from the camera), the game's camera following him, and
## a tile round him from each frame laid in one contact sheet. Each tile is labelled by its place in the sheet's rows
## (x along, z down, from FROM).
##   tools/gpu.sh run --rendering-driver vulkan --resolution 1920x1080 -s tools/garden_grid.gd -- C:/sheet.png --arena=garden --nosave

const FROM := Vector2(-16.0, -13.0)
const TO := Vector2(0.0, 1.0)
const STEP := 2.0
const TILE := 240
const SETTLE := 0.6

var game: Node


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var out := "grid.png"
	for a in OS.get_cmdline_user_args():
		if not a.begins_with("--"):
			out = a
	game = (load("res://scenes/game.tscn") as PackedScene).instantiate()
	root.add_child(game)
	await _wait(2.5)
	var spots: Array[Vector2] = []
	var cols := 0
	var z := FROM.y
	while z <= TO.y + 0.01:
		var x := FROM.x
		var c := 0
		while x <= TO.x + 0.01:
			spots.append(Vector2(x, z))
			x += STEP
			c += 1
		cols = c
		z += STEP
	var rows := ceili(float(spots.size()) / cols)
	var sheet := Image.create(cols * TILE, rows * TILE, false, Image.FORMAT_RGB8)
	sheet.fill(Color(0.1, 0.1, 0.1))
	var used := 0
	for i in spots.size():
		var p := spots[i]
		if not game.arena.free_at(p, 0.4):
			continue
		game.horde.alive_cap = 0
		game.horde.clear_crowd()
		game.player.place(p)
		game.get(&"cam").set(&"target", Vector3(p.x, 0, p.y))
		await _wait(SETTLE)
		var img := root.get_viewport().get_texture().get_image()
		var at: Vector2 = game.camera.unproject_position(Vector3(p.x, 1.3, p.y)) * Vector2(img.get_size()) / root.get_visible_rect().size
		var r := Rect2i(Vector2i(at) - Vector2i(TILE / 2, TILE / 2), Vector2i(TILE, TILE))
		r = r.intersection(Rect2i(Vector2i.ZERO, img.get_size()))
		sheet.blit_rect(img, r, Vector2i((i % cols) * TILE, (i / cols) * TILE))
		used += 1
	sheet.save_png(out)
	print("GRID %d places, %d x %d, saved %s" % [used, cols, rows, out])
	quit()


func _wait(s: float) -> void:
	var start := Time.get_ticks_msec()
	while (Time.get_ticks_msec() - start) / 1000.0 < s:
		await process_frame
