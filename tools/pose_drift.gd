extends SceneTree
## QA tool (E1c, bug 3): how far each baked pose of a figure stands from its place on the floor (BakedModel.pose_centre:
## the mean of its vertices in x and z, at size 1; times EnemyDef.size in the game), clip by clip. A clip whose body
## leaves the origin is drawn away from where the enemy stands: it seems to vanish and show up elsewhere when the clip
## begins or ends (Morvath's scythe carried 3.2 m, 8 m on him).
##   godot --headless --path . -s res://tools/pose_drift.gd -- [res://assets/baked/morvath.res] [--all]

func _initialize() -> void:
	var path := "res://assets/baked/morvath.res"
	var all := false
	for a in OS.get_cmdline_user_args():
		if a == "--all":
			all = true
		elif a.ends_with(".res"):
			path = a
	var m: BakedModel = load(path)
	for anim: String in m.frames:
		var line := ""
		if all:
			for f in m.frame_count(anim):
				var c := m.pose_centre(anim, f)
				line += " %d:(%.2f,%.2f)" % [f, c.x, c.y]
		print("%-12s poses=%2d worst=%.2f m%s" % [anim, m.frame_count(anim), m.drift(anim), line])
	quit()
