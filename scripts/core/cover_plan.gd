class_name CoverPlan
extends RefCounted
## Where a paladin can stand so that an obstacle that stops shots lies between him and the shooters (the test bot's
## use of cover). Pure: obstacles are ArenaObstacle (only those with blocks_shots count), positions are (x, z) meters.


## True when the segment a to b crosses the footprint of o (grown by `grow` meters).
static func crosses(a: Vector2, b: Vector2, o: ArenaObstacle, grow := 0.0) -> bool:
	if not o.blocks_shots:
		return false
	if o.shape == ArenaObstacle.Shape.CIRCLE:
		var ab := b - a
		var len2 := ab.length_squared()
		var t := clampf((o.center - a).dot(ab) / len2, 0.0, 1.0) if len2 > 0.0001 else 0.0
		return (a + ab * t).distance_to(o.center) < o.radius + grow
	var la := (a - o.center).rotated(-o.yaw)
	var lb := (b - o.center).rotated(-o.yaw)
	var h := o.half + Vector2(grow, grow)
	var d := lb - la
	var t0 := 0.0
	var t1 := 1.0
	for axis in 2:
		if absf(d[axis]) < 0.0001:
			if absf(la[axis]) > h[axis]:
				return false
		else:
			var u := (-h[axis] - la[axis]) / d[axis]
			var v := (h[axis] - la[axis]) / d[axis]
			t0 = maxf(t0, minf(u, v))
			t1 = minf(t1, maxf(u, v))
			if t0 > t1:
				return false
	return true


## True when something of `obstacles` stops a shot flying from `from` to `at`.
static func hidden(from: Vector2, at: Vector2, obstacles: Array[ArenaObstacle], grow := 0.0) -> bool:
	for o in obstacles:
		if crosses(from, at, o, grow):
			return true
	return false


## The nearest spot within `reach` m of `hero` (one the `walkable` callable accepts, when given) from which every
## shooter in `shooters` is hidden behind an obstacle, standing `margin` m off its edge on the side away from the
## shooters. Falls back to the spot that hides the most of them. null: no cover near.
static func pick(hero: Vector2, shooters: Array[Vector2], obstacles: Array[ArenaObstacle], reach: float, hero_r: float,
		walkable := Callable()) -> Variant:
	if shooters.is_empty():
		return null
	var mid := Vector2.ZERO
	for s in shooters:
		mid += s
	mid /= shooters.size()
	var best: Variant = null
	var best_hidden := 0
	var best_cost := INF
	for o in obstacles:
		if not o.blocks_shots:
			continue
		var size := o.radius if o.shape == ArenaObstacle.Shape.CIRCLE else o.half.length()
		if hero.distance_to(o.center) > reach + size:
			continue
		var away := o.center - mid
		var dir := away.normalized() if away.length() > 0.01 else Vector2.RIGHT
		var spot := o.center + dir * (size + hero_r + 0.35)
		if walkable.is_valid() and not walkable.call(spot):
			continue
		var count := 0
		for s in shooters:
			if hidden(s, spot, obstacles):
				count += 1
		if count == 0:
			continue
		var cost := hero.distance_to(spot)
		if cost > reach:
			continue
		if count > best_hidden or count == best_hidden and cost < best_cost:
			best_hidden = count
			best_cost = cost
			best = spot
	return best
