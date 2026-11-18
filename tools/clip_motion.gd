extends SceneTree
## T5 (docs/design/combat_cadence.md 6.1): how much each baked clip moves, the measures of the acceptance.
## ~/tools/godot/godot --headless --path . -s tools/clip_motion.gd -- [ids...] [--clips=a,b] [--poses]
## Per figure and clip (assets/baked, size 1): poses, seconds, the peak of the mean speed of its vertices from one pose
## to the next (m/s; an idle 0.03 to 0.19, a blow 6 to 10), how far its last pose is from the guard (the mean distance
## of its vertices to idle's first pose, m), the top of the figure at its last pose and the lowest the middle of its
## body goes against the guard (m, a crouch). --poses prints every pose. A walk: poses with both feet off the floor
## (the lowest vertex over 3 cm), the rise and fall of the body and the lean of the trunk (T5-11, walk_metrics).

const STEP := 3


func _initialize() -> void:
	var ids := PackedStringArray()
	var clips := PackedStringArray()
	var every := false
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--clips="):
			clips = a.trim_prefix("--clips=").split(",")
		elif a == "--poses":
			every = true
		else:
			ids.append(a)
	if ids.is_empty():
		ids = PackedStringArray(["skeleton", "runner", "mage", "archer", "guard", "priest", "knight", "priest_elder", "morvath"])
	for id in ids:
		var m := load("res://assets/baked/%s.res" % id) as BakedModel
		print("=== %s (%d vertices)" % [id, m.vertices])
		var guard := m.pose(&"idle", 0)
		var g_mid := _middle(guard)
		var anims: Array = m.frames.keys()
		anims.sort()
		for anim: StringName in anims:
			if not clips.is_empty() and not String(anim) in clips:
				continue
			var n := m.frame_count(anim)
			var rate := m.pose_rate(anim)
			var peak := 0.0
			var low := 0.0
			var prev := PackedVector3Array()
			var rows := PackedStringArray()
			for f in n:
				var p := m.pose(anim, f)
				var v := 0.0
				if not prev.is_empty():
					v = _mean_gap(p, prev) * rate
					peak = maxf(peak, v)
				low = minf(low, _middle(p) - g_mid)
				if every:
					rows.append("    %02d %.2f s top %.2f middle %+.3f from guard %.3f speed %.2f" % [f, f / rate, _top(p), _middle(p) - g_mid, _mean_gap(p, guard), v])
				prev = p
			var last := m.pose(anim, n - 1)
			print("  %-14s %2d poses %.2f s %s peak %.2f m/s, armed %.2f m from the guard, top %.2f, lowest middle %+.3f" % [anim, n,
				m.duration(anim), "loop" if m.loops.get(anim, false) else "once", peak, _mean_gap(last, guard), _top(last), low])
			for r in rows:
				print(r)
			if anim == &"walk":
				_walk(m)
	quit()


func _mean_gap(a: PackedVector3Array, b: PackedVector3Array) -> float:
	var sum := 0.0
	var n := 0
	for v in range(0, a.size(), STEP):
		sum += a[v].distance_to(b[v])
		n += 1
	return sum / maxi(n, 1)


func _middle(p: PackedVector3Array) -> float:
	var sum := 0.0
	var n := 0
	for v in range(0, p.size(), STEP):
		sum += p[v].y
		n += 1
	return sum / maxi(n, 1)


func _top(p: PackedVector3Array) -> float:
	var top := -INF
	for v in range(0, p.size(), STEP):
		top = maxf(top, p[v].y)
	return top


## Both feet off the floor, rise and fall, lean (as docs/gallery/t5/motion/before/data/walk_metrics.gd.txt).
func _walk(m: BakedModel) -> void:
	var n := m.frame_count(&"walk")
	var air := 0
	var mids: Array[float] = []
	var leans: Array[float] = []
	var lift := 0.0
	var head := INF
	var lows: Array[float] = []
	for f in n:
		var p := m.pose(&"walk", f)
		var low := INF
		var top := -INF
		for v in range(0, p.size(), 2):
			low = minf(low, p[v].y)
			top = maxf(top, p[v].y)
		var hz := 0.0
		var hn := 0
		var lz := 0.0
		var ln := 0
		for v in range(0, p.size(), 2):
			var q := p[v]
			if q.y > top - 0.25:
				hz += q.z
				hn += 1
			elif q.y > top * 0.45 and q.y < top * 0.55:
				lz += q.z
				ln += 1
		if low > 0.03:
			air += 1
		lows.append(snappedf(low, 0.01))
		leans.append(rad_to_deg(atan2(hz / maxi(hn, 1) - lz / maxi(ln, 1), top * 0.45)))
		mids.append(_middle(p))
		lift = maxf(lift, _back_foot(p))
		head = minf(head, m.body_top(p))
	print("    walk: both feet off the floor in %d of %d poses, rise and fall %.3f m, lean %.0f to %.0f degrees, lifted foot up to %.2f m, head down to %.2f m (%.0f%% of idle); lowest %s" % [
		air, n, mids.max() - mids.min(), leans.min(), leans.max(), lift, head, 100.0 * head / m.body_top(m.pose(&"idle", 0)), str(lows)])


## How high the lifted foot goes: of the two legs (vertices under 0.6 m near the middle, split by side) the lowest
## point of the higher one (the sword hanging by the hip is outside the legs).
func _back_foot(p: PackedVector3Array) -> float:
	var left := INF
	var right := INF
	for v in range(0, p.size(), 2):
		var q := p[v]
		if q.y < 0.6 and absf(q.x) < 0.3:
			if q.x < 0.0:
				left = minf(left, q.y)
			else:
				right = minf(right, q.y)
	if left == INF or right == INF:
		return 0.0
	return maxf(left, right)
