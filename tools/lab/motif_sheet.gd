extends Node
## Body of tools/motif_sheet.gd.

const NODE_PAPER := Color(0.74, 0.65, 0.5)
const STATES := [HeroLoadout.State.OPEN, HeroLoadout.State.EQUIPPED, HeroLoadout.State.SEALED, HeroLoadout.State.BLOCKED,
	HeroLoadout.State.LOCKED]


func _ready() -> void:
	var png := ""
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--png="):
			png = a.get_slice("=", 1)
		elif a == "--big":
			_big = true
	_table()
	if png == "" or DisplayServer.get_name() == "headless":
		get_tree().quit()
		return
	var board := Control.new()
	board.set_anchors_preset(Control.PRESET_FULL_RECT)
	board.draw.connect(_board.bind(board))
	add_child(board)
	for i in 4:
		await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(png)
	print("saved ", png)
	get_tree().quit()


var _big := false


func _board(ci: Control) -> void:
	ci.draw_rect(Rect2(Vector2.ZERO, ci.size), Book.PAPER)
	if _big:
		# --big: every motif at radius 80 in a grid, to see the paint
		for i in TalentGlyph.IDS.size():
			var c := Vector2(110 + (i % 7) * 260, 140 + (i / 7) * 300) * ci.size.y / 1080.0
			var h := 80.0 * 1.45 * ci.size.y / 1080.0
			ci.draw_colored_polygon(PackedVector2Array([c + Vector2(0, -h), c + Vector2(h, 0), c + Vector2(0, h), c + Vector2(-h, 0)]), NODE_PAPER)
			TalentMotif.draw(ci, TalentGlyph.IDS[i], c, 80.0 * ci.size.y / 1080.0)
		return
	var scale := ci.size.y / 1080.0
	var font := UiKit.number_font()
	for i in TalentGlyph.IDS.size():
		var id: StringName = TalentGlyph.IDS[i]
		var col := i % 2
		var row := i / 2
		var at := Vector2(30 + col * 950, 30 + row * 104) * scale
		ci.draw_string(font, at + Vector2(0, 14 * scale), "%02d %s" % [i, id], HORIZONTAL_ALIGNMENT_LEFT, -1, int(13 * scale), Book.INK)
		for k in STATES.size():
			for big in 2:
				var r := (16.0 if big == 0 else 32.0) * scale
				var c := at + Vector2(40 + k * 150 + big * 52, 60) * scale
				var h := r * 1.45
				ci.draw_colored_polygon(PackedVector2Array([c + Vector2(0, -h), c + Vector2(h, 0), c + Vector2(0, h), c + Vector2(-h, 0)]), NODE_PAPER)
				TalentMotif.draw(ci, id, c, r, STATES[k])
		var g := at + Vector2(820, 60) * scale
		TalentMotif.draw(ci, id, g, 12.0 * scale, HeroLoadout.State.OPEN)


## The silhouette at radius 16 on a 36 x 36 grid (every shape, filled).
func _mask(id: StringName, r: float) -> PackedByteArray:
	var n := int(r * 2.2)
	var out := PackedByteArray()
	out.resize(n * n)
	var parts := TalentMotif.shapes(id)
	for y in n:
		for x in n:
			var p := (Vector2(x + 0.5, y + 0.5) - Vector2(n, n) * 0.5) / r
			for part: Dictionary in parts:
				if Geometry2D.is_point_in_polygon(p, part.p):
					out[y * n + x] = 1
					break
	return out


func _table() -> void:
	var ids := TalentGlyph.IDS
	var masks := {}
	for id in ids:
		masks[id] = _mask(id, 16.0)
	print("PAIRS (intersection over union at radius 16, from 0.7)")
	var worst := 0.0
	for i in ids.size():
		for j in range(i + 1, ids.size()):
			var a: PackedByteArray = masks[ids[i]]
			var b: PackedByteArray = masks[ids[j]]
			var both := 0
			var any := 0
			for k in a.size():
				both += a[k] & b[k]
				any += a[k] | b[k]
			var iou := float(both) / maxf(1.0, float(any))
			worst = maxf(worst, iou)
			if iou >= 0.7:
				print("  %s %s %.2f %s" % [ids[i], ids[j], iou, "FAIL" if iou >= 0.8 else "LOOK"])
	print("PAIRS worst %.2f (under 0.8)" % worst)
	print("COLOUR id | branch | max channel | sat p50 | hue p50 | branch hue | off")
	for id in ids:
		var hues: Array = []
		var sats: Array = []
		var top := 0.0
		var r := 32.0
		var n := 70
		var parts := TalentMotif.shapes(id)
		for y in n:
			for x in n:
				var p := (Vector2(x + 0.5, y + 0.5) - Vector2(n, n) * 0.5) / r
				var hit: Dictionary = {}
				for part: Dictionary in parts:
					if not part.get("hollow", false) and Geometry2D.is_point_in_polygon(p, part.p):
						hit = part
				if hit.is_empty():
					continue
				var c := TalentMotif.tone(hit.k)
				var box := Rect2(hit.p[0], Vector2.ZERO)
				for q in hit.p:
					box = box.expand(q)
				var side := (p - box.get_center()).dot(Vector2(1, 1).normalized()) / maxf(box.size.length() * 0.5, 0.001)
				if side > 0.05:
					c = Color(c.r * TalentMotif.SHADE, c.g * TalentMotif.SHADE, c.b * TalentMotif.SHADE)
				elif side < -0.4:
					c = Color(minf(c.r * TalentMotif.LIGHT, 0.9), minf(c.g * TalentMotif.LIGHT, 0.9), minf(c.b * TalentMotif.LIGHT, 0.9))
				top = maxf(top, maxf(c.r, maxf(c.g, c.b)))
				sats.append(c.s)
				if c.s > 0.1:
					hues.append(c.h * 360.0)
		sats.sort()
		var branch := TalentMotif.branch_of(id)
		var bh := TalentNode.BRANCH_COLOR[branch].h * 360.0 if branch >= 0 else -1.0
		# the median of each coloured pixel's hue taken round the branch's hue (a mean of red and green is yellow)
		var offs: Array = []
		for h: float in hues:
			offs.append(fposmod(h - bh + 180.0, 360.0) - 180.0)
		offs.sort()
		var mid_off: float = offs[offs.size() / 2] if offs.size() > 0 else 180.0
		var hue := fposmod(bh + mid_off, 360.0)
		var off := absf(mid_off)
		print("  %s | %d | %.2f | %.2f | %.0f | %.0f | %.0f%s" % [id, branch, top, sats[sats.size() / 2] if sats.size() > 0 else 0.0,
			hue, bh, off, "" if off <= 20.0 or branch >= TalentDef.Branch.BRIDGE else " OFF"])
	var paper := NODE_PAPER.get_luminance()
	var ink := Book.INK.get_luminance()
	print("CONTRAST outline on the node %.1f:1 (3:1 or more)" % ((paper + 0.05) / (ink + 0.05)))
	var locked := NODE_PAPER.lerp(Book.INK, TalentMotif.LOCKED_ALPHA)
	print("LOCKED outline luma step %.0f (25 or more)" % ((NODE_PAPER.get_luminance() - locked.get_luminance()) * 255.0))


