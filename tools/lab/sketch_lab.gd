extends Node
## Body of tools/sketch_lab.gd.

const IDS := ["skeleton", "runner", "mage", "archer", "guard", "priest", "knight", "priest_elder", "morvath",
	"skeleton_elite", "guard_elite", "mage_elite"]


func _ready() -> void:
	var args := OS.get_cmdline_user_args()
	var out := ""
	var ids: Array = []
	# six columns and two rows that fit the window (--px= sets the width of a view)
	var win := Vector2(get_viewport().get_visible_rect().size)
	var px := floorf(minf((win.x - 40.0) / 6.0 - 4.0, ((win.y - 40.0) / 2.0 - 24.0) / 1.2))
	var t := -1.0
	for a in args:
		if a.begins_with("--px="):
			px = float(a.get_slice("=", 1))
		elif a.begins_with("--t="):
			t = float(a.get_slice("=", 1))
		elif out == "":
			out = a
		else:
			ids.append(a)
	if ids.is_empty():
		ids = IDS
	var page := ColorRect.new()
	page.color = Book.PAPER
	page.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(page)
	var grid := GridContainer.new()
	grid.columns = 6
	grid.position = Vector2(20, 20)
	add_child(grid)
	for id: String in ids:
		var d := load("res://data/enemies/%s.tres" % id) as EnemyDef
		var box := VBoxContainer.new()
		grid.add_child(box)
		_view(box, d, Vector2(px, px * 1.2), t)
		box.add_child(Book.label(id, Book.FADED, 14))
	for i in 8:
		await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(out)
	print("saved ", out)
	get_tree().quit()


func _view(box: Node, d: EnemyDef, size: Vector2, t: float) -> void:
	var c := SubViewportContainer.new()
	box.add_child(c)
	c.custom_minimum_size = size
	c.stretch = true
	var vp := SubViewport.new()
	vp.own_world_3d = true
	vp.transparent_bg = true
	vp.msaa_3d = Viewport.MSAA_4X
	c.add_child(vp)
	var cam := Camera3D.new()
	vp.add_child(cam)
	var r := CrowdRenderer.new()
	vp.add_child(r)
	r.register(d)
	FigureSketch.apply(r, d, Book.INK, size.y)
	var k := r.kind(d)
	FigureSketch.fit(cam, d, k.model, &"idle", size.x / size.y)
	cam.current = true
	var at := FigureSketch.pose_time(k.model, &"idle") if t < 0.0 else t
	r.begin()
	r.add_kind(k, d, &"idle", at, Vector3.ZERO, FigureSketch.yaw(k.model), Color(0, 0, 0, 0))
	r.commit()
