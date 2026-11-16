extends SceneTree
## QA (E1a AFTER): prints, per baked enemy, every clip's poses, pose rate, seconds and loop, the walk's ground speed and
## the stride slide (BakedModel.slide_per_step on the baked soles, at the measured ground speed), and the vertices.
## godot --headless --path . -s docs/gallery/e1a/after/tools/qa_e1a_poses.gd
const IDS := ["skeleton", "runner", "mage", "archer", "guard", "priest", "knight", "priest_elder", "morvath"]


func _initialize() -> void:
	for id: String in IDS:
		var m = load("res://assets/baked/%s.res" % id)
		var parts := PackedStringArray()
		for anim in m.frames:
			var n: int = m.frames[anim]
			var f: float = m.fps.get(anim, 10.0)
			parts.append("%s=%d@%.1ffps(%.2fs%s)" % [anim, n, f, n / f, " loop" if m.loops.get(anim, false) else ""])
		var line := "BAKE %s: vertices=%d %s" % [id, m.vertices, " ".join(parts)]
		var g: float = m.ground_speed.get(&"walk", 0.0)
		line += " | walk ground=%.3f m/s" % g
		if m.feet.has(&"walk") or m.feet.has("walk"):
			var soles = m.feet.get(&"walk", m.feet.get("walk"))
			var dt: float = 1.0 / float(m.fps.get(&"walk", 10.0))
			line += " slide=%.3f m/step" % m.slide_per_step(soles, dt, g)
		print(line)
	quit()
