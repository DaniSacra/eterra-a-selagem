extends SceneTree
## Does what an arena draws match what it lets you walk on? (art pack 2026-11-17, section 4: "the roots' and the edges'
## drawing coincides with the walkable floor"). Builds one arena's look like tools/arena_lab.gd, lays every mesh's
## triangles on a grid of CELL m seen from above (the highest point of the drawing up to CAP over each cell, and whether
## a floor surface lies there) and compares it with the floor (FloorShape) and the obstacles' collision:
##   phantom   open floor (inside the floor, outside every blocking piece, at least SLACK from both) where the drawing
##             stands over KNEE: it reads as a barrier and is not one
##   bare      inside a blocking piece (SLACK in from its outline) where nothing stands over LOW: a wall you cannot see
##   void      on the floor (SLACK in) with no floor surface drawn: looks like a hole and is walkable
##   ledge     off the floor (LEDGE_FROM out, away from the doors' mouths) with a floor surface at the floor's height and
##             nothing over it: looks walkable and is the abyss
## Each in m², the pieces' bare share, and the meshes the phantoms come from.
##   ~/tools/godot/godot --headless --path . -s tools/fit_probe.gd -- --arena=garden --variant=1 [--png=out.png]
## --look=classic|stylized builds the room in that visual profile.
## --png draws the four kinds over the floor seen from above (1 px a cell), for a look.

const STAGE := "res://data/stages/catacombs.tres"
const CELL := 0.1
## Knee height: a drawing over this on open floor reads as something that stops you.
const KNEE := 0.3
## Inside a piece, nothing over this is "no drawing".
const LOW := 0.15
## Overhead (the tree's crown, arches) is not a barrier on the floor.
const CAP := 2.6
## A band along every outline where the two may differ (the cords of a root, a balustrade's foot).
const SLACK := 0.2
## A floor surface lies within this of y 0.
const FLOOR_Y := 0.08
## A ledge counts from this far off the floor (a kerb under a balustrade, the lip of a cliff's coping, are narrower).
const LEDGE_FROM := 0.4
## ... and with nothing over the knee within this (a balustrade's curb, a bridge's kerb under its parapet, an
## abutment by its pillar belong to the barrier beside them).
const LEDGE_CLEAR := 0.6

var opts := {}


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--"):
			var kv := a.trim_prefix("--").split("=")
			opts[kv[0]] = kv[1] if kv.size() > 1 else "1"
	var stage: StageDef = load(STAGE)
	var want := StringName(str(opts.get("arena", "garden")))
	var layout: RoomLayout = null
	for l in stage.layouts:
		if l.id == want:
			layout = l
	# the event chambers (AP-1): --arena=trial|altar
	for l: RoomLayout in [stage.trial_layout, stage.altar_layout]:
		if l != null and l.id == want:
			layout = l
	if layout == null:
		push_error("no arena %s" % want)
		quit(1)
		return
	layout = layout.variant(int(opts.get("variant", "0")))
	# --look=classic|stylized: the visual profile the room is built in (room redesign lot D)
	if opts.has("look"):
		var vp: Variant = load("res://scripts/core/visual_profile.gd")
		vp.set_look(vp.parse(str(opts["look"])))
	var world := Node3D.new()
	root.add_child(world)
	var arena: Variant = load("res://scripts/game/arena.gd").new()
	world.add_child(arena)
	arena.build(layout, int(opts.get("doors", "3")), 1406)
	await process_frame
	var r := measure(arena, layout)
	print("FIT %s %d phantom %.2f m2, bare %.2f m2, void %.2f m2, ledge %.2f m2" % [want, int(opts.get("variant", "0")),
		r.phantom, r.bare, r.void, r.ledge])
	for k: String in r.pieces:
		print("  piece %s bare %.0f%%" % [k, r.pieces[k] * 100.0])
	for k: String in r.sources:
		print("  phantom from %s %.2f m2" % [k, r.sources[k]])
	for k: String in r.ledge_sources:
		print("  ledge near %s %.2f m2" % [k, r.ledge_sources[k]])
	if opts.has("png"):
		var img: Image = r.image
		img.resize(img.get_width() * 3, img.get_height() * 3, Image.INTERPOLATE_NEAREST)
		img.save_png(str(opts["png"]))
		print("saved %s" % opts["png"])
	quit()


## The four measures (m²) of an arena already built, with the bare share of each blocking piece, where the phantoms
## come from and an image of them.
static func measure(arena: Variant, layout: RoomLayout) -> Dictionary:
	var shape: FloorShape = arena.shape()
	var b: Rect2 = shape.bounds().grow(3.0)
	print("GRID from (%.1f, %.1f), %.2f m a cell" % [b.position.x, b.position.y, CELL])
	var w := ceili(b.size.x / CELL)
	var h := ceili(b.size.y / CELL)
	var top := PackedFloat32Array()
	top.resize(w * h)
	top.fill(-100.0)
	# the highest point over each cell with nothing left out (a trunk, a wall above CAP still hides what is under it)
	var over := PackedFloat32Array()
	over.resize(w * h)
	over.fill(-100.0)
	var floor_ := PackedByteArray()
	floor_.resize(w * h)
	var who: Array[String] = []
	who.resize(w * h)
	for n in arena.find_children("*", "MeshInstance3D", true, false):
		var mi := n as MeshInstance3D
		if mi.mesh == null or not mi.is_visible_in_tree():
			continue
		var xf := mi.global_transform
		var name_ := _source(mi, arena)
		for s in mi.mesh.get_surface_count():
			if mi.mesh is ArrayMesh and (mi.mesh as ArrayMesh).surface_get_primitive_type(s) != Mesh.PRIMITIVE_TRIANGLES:
				continue
			var arr := mi.mesh.surface_get_arrays(s)
			var verts: PackedVector3Array = arr[Mesh.ARRAY_VERTEX]
			var idx: PackedInt32Array = arr[Mesh.ARRAY_INDEX] if arr[Mesh.ARRAY_INDEX] != null else PackedInt32Array()
			var world_v := PackedVector3Array()
			world_v.resize(verts.size())
			for i in verts.size():
				world_v[i] = xf * verts[i]
			var count := idx.size() if not idx.is_empty() else verts.size()
			for t in range(0, count - 2, 3):
				var a := world_v[idx[t] if not idx.is_empty() else t]
				var c := world_v[idx[t + 1] if not idx.is_empty() else t + 1]
				var d := world_v[idx[t + 2] if not idx.is_empty() else t + 2]
				_raster(a, c, d, b, w, h, top, over, floor_, who, name_)
	var phantom := 0.0
	var bare := 0.0
	var void_ := 0.0
	var ledge := 0.0
	var sources := {}
	var ledge_sources := {}
	var inside := {}
	var shown := {}
	var img := Image.create(w, h, false, Image.FORMAT_RGB8)
	var blocking: Array[ArenaObstacle] = []
	for o in layout.obstacles:
		if o.blocks_move:
			blocking.append(o)
	var mouths: Array[Rect2] = []
	for e in layout.exits:
		mouths.append(e.mouth.grow(1.5))
	var area := CELL * CELL
	var tall := _near_tall(over, w, h, ceili(LEDGE_CLEAR / CELL))
	for y in h:
		for x in w:
			var p := b.position + Vector2(x + 0.5, y + 0.5) * CELL
			var i := y * w + x
			var on := shape.contains(p, 0.0)
			var deep_on := shape.contains(p, SLACK)
			var near_on := shape.contains(p, -LEDGE_FROM)
			var in_piece: ArenaObstacle = null
			var near_piece := false
			for o in blocking:
				if o.depth(p, 0.0) > 0.0:
					in_piece = o
				if o.depth(p, SLACK) > 0.0:
					near_piece = true
			var t := top[i]
			var col := Color(0.08, 0.08, 0.1)
			if on:
				col = Color(0.25, 0.27, 0.25)
			if in_piece != null:
				col = Color(0.4, 0.38, 0.33)
				var key := "%s@%.1f,%.1f" % [in_piece.piece, in_piece.center.x, in_piece.center.y]
				if in_piece.depth(p, -SLACK) > 0.0:
					inside[key] = inside.get(key, 0) + 1
					if t > LOW or over[i] > CAP:
						shown[key] = shown.get(key, 0) + 1
					else:
						bare += area
						col = Color(0.2, 0.5, 1.0)
			elif deep_on and not near_piece and not arena.overlaps(p, SLACK):
				# (the arena's own colliders too: the hall's pieces are the kit's circles and boxes, not the layout's)
				if t > KNEE:
					phantom += area
					sources[who[i]] = sources.get(who[i], 0.0) + area
					var spot := "phantom at (%d, %d)" % [roundi(p.x), roundi(p.y)]
					sources[spot] = sources.get(spot, 0.0) + area
					col = Color(1.0, 0.25, 0.2)
				elif floor_[i] == 0 and t < -FLOOR_Y:
					void_ += area
					col = Color(1.0, 0.0, 1.0)
			if not near_on and not _in(mouths, p) and floor_[i] == 1 and tall[i] == 0:
				ledge += area
				ledge_sources[who[i]] = ledge_sources.get(who[i], 0.0) + area
				col = Color(1.0, 0.85, 0.1)
			img.set_pixel(x, y, col)
	var pieces := {}
	for k: String in inside:
		pieces[k] = 1.0 - float(shown.get(k, 0)) / inside[k]
	return {"phantom": phantom, "bare": bare, "void": void_, "ledge": ledge, "pieces": pieces, "sources": sources,
		"ledge_sources": ledge_sources, "image": img}


## 1 where something stands over the knee within r cells (a square), else 0.
static func _near_tall(over: PackedFloat32Array, w: int, h: int, r: int) -> PackedByteArray:
	var row := PackedByteArray()
	row.resize(w * h)
	for y in h:
		var last := -100000
		for x in w:
			if over[y * w + x] > KNEE:
				last = x
			if x - last <= r:
				row[y * w + x] = 1
		last = 100000
		for x in range(w - 1, -1, -1):
			if over[y * w + x] > KNEE:
				last = x
			if last - x <= r:
				row[y * w + x] = 1
	var out := PackedByteArray()
	out.resize(w * h)
	for x in w:
		var last := -100000
		for y in h:
			if row[y * w + x] == 1:
				last = y
			if y - last <= r:
				out[y * w + x] = 1
		last = 100000
		for y in range(h - 1, -1, -1):
			if row[y * w + x] == 1:
				last = y
			if last - y <= r:
				out[y * w + x] = 1
	return out


static func _in(rects: Array[Rect2], p: Vector2) -> bool:
	for r in rects:
		if r.has_point(p):
			return true
	return false


## Which part of the arena a mesh is: its nearest named ancestor under the arena, with its own name.
static func _source(mi: MeshInstance3D, arena: Node) -> String:
	var n: Node = mi
	var parts: Array[String] = []
	while n != null and n != arena and parts.size() < 3:
		var s := String(n.name)
		if not s.begins_with("@"):
			parts.append(s)
		n = n.get_parent()
	var mat := mi.material_override
	var tag := ""
	if mat is ShaderMaterial and (mat as ShaderMaterial).shader != null:
		tag = (mat as ShaderMaterial).shader.resource_path.get_file()
	var at := mi.global_position
	return "%s %s (%.0f, %.0f)" % ["/".join(parts) if not parts.is_empty() else "mesh", tag, at.x, at.z]


## One triangle on the grid: every cell whose middle it covers takes its height there (the highest under CAP) and, when
## that height is the floor's and the triangle faces up, a floor surface.
static func _raster(a: Vector3, c: Vector3, d: Vector3, b: Rect2, w: int, h: int, top: PackedFloat32Array,
		over: PackedFloat32Array, floor_: PackedByteArray, who: Array[String], name_: String) -> void:
	var p0 := Vector2(a.x, a.z)
	var p1 := Vector2(c.x, c.z)
	var p2 := Vector2(d.x, d.z)
	var den := (p1.y - p2.y) * (p0.x - p2.x) + (p2.x - p1.x) * (p0.y - p2.y)
	if absf(den) < 1e-7:
		return
	var up := (c - a).cross(d - a).normalized()
	var flat_up := absf(up.y) > 0.7
	var lo := Vector2(minf(p0.x, minf(p1.x, p2.x)), minf(p0.y, minf(p1.y, p2.y)))
	var hi := Vector2(maxf(p0.x, maxf(p1.x, p2.x)), maxf(p0.y, maxf(p1.y, p2.y)))
	var x0 := maxi(0, floori((lo.x - b.position.x) / CELL - 0.5))
	var x1 := mini(w - 1, ceili((hi.x - b.position.x) / CELL - 0.5))
	var y0 := maxi(0, floori((lo.y - b.position.y) / CELL - 0.5))
	var y1 := mini(h - 1, ceili((hi.y - b.position.y) / CELL - 0.5))
	for gy in range(y0, y1 + 1):
		for gx in range(x0, x1 + 1):
			var p := b.position + Vector2(gx + 0.5, gy + 0.5) * CELL
			var l0 := ((p1.y - p2.y) * (p.x - p2.x) + (p2.x - p1.x) * (p.y - p2.y)) / den
			var l1 := ((p2.y - p0.y) * (p.x - p2.x) + (p0.x - p2.x) * (p.y - p2.y)) / den
			var l2 := 1.0 - l0 - l1
			if l0 < 0.0 or l1 < 0.0 or l2 < 0.0:
				continue
			var y := a.y * l0 + c.y * l1 + d.y * l2
			var i := gy * w + gx
			if y > over[i]:
				over[i] = y
			if y > CAP:
				continue
			if flat_up and absf(y) <= FLOOR_Y:
				floor_[i] = 1
			if y > top[i]:
				top[i] = y
				who[i] = name_
