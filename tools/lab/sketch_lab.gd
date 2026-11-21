extends Node
## Body of tools/sketch_lab.gd.

const IDS := ["skeleton", "runner", "mage", "archer", "guard", "priest", "knight", "priest_elder", "morvath",
	"skeleton_elite", "guard_elite", "mage_elite"]


func _ready() -> void:
	var args := OS.get_cmdline_user_args()
	var out := ""
	var ids: Array = []
	var px := 240.0
	var t := 0.4
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
		var view := _view(d, Vector2(px, px * 1.2), t)
		box.add_child(view)
		box.add_child(Book.label(id, Book.FADED, 14))
		grid.add_child(box)
	for i in 8:
		await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(out)
	print("saved ", out)
	get_tree().quit()


func _view(d: EnemyDef, size: Vector2, t: float) -> SubViewportContainer:
	var c := SubViewportContainer.new()
	c.custom_minimum_size = size
	c.stretch = true
	var vp := SubViewport.new()
	vp.own_world_3d = true
	vp.transparent_bg = true
	vp.msaa_3d = Viewport.MSAA_4X
	c.add_child(vp)
	var cam := Camera3D.new()
	cam.projection = Camera3D.PROJECTION_ORTHOGONAL
	cam.rotation_degrees.x = -12.0
	vp.add_child(cam)
	var r := CrowdRenderer.new()
	vp.add_child(r)
	r.register(d)
	FigureSketch.apply(r, d, Book.INK, size.y * 1080.0 / 900.0 * 2.0)
	var k := r.kind(d)
	var h := k.model.height * d.size
	cam.size = h * 1.18
	cam.position = Vector3(0, h * 0.5 + 10.0 * tan(deg_to_rad(12.0)), 10.0)
	cam.current = true
	r.begin()
	r.add_kind(k, d, &"idle", t, Vector3.ZERO, deg_to_rad(30.0), Color(0, 0, 0, 0))
	r.commit()
	return c
