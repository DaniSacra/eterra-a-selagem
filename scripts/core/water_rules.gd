class_name WaterRules
extends RefCounted
## Chapter II, A-5 (Pulso do Bosque): shallow water (RoomLayout.water, rectangles of walkable floor). Whoever stands in it, the
## paladin or an enemy, walks SLOW less fast (-15%, a first figure to calibrate); never damage, never a hole. Every room keeps a
## dry route from the way in to a door (dry_route). Pure.

const SLOW := 0.15


## 1 on dry floor, 1 - SLOW in the water.
static func speed_scale(water: Array[Rect2], p: Vector2) -> float:
	for r in water:
		if r.has_point(p):
			return 1.0 - SLOW
	return 1.0


## True when `from` reaches `to` over floor that is not water (cells of `cell` m, 4 neighbours; `to` within one cell counts).
static func dry_route(floor: FloorShape, water: Array[Rect2], from: Vector2, to: Vector2, cell := 1.0) -> bool:
	var seen := {}
	var start := Vector2i((from / cell).floor())
	var queue: Array[Vector2i] = [start]
	seen[start] = true
	while not queue.is_empty():
		var c: Vector2i = queue.pop_back()
		var p := (Vector2(c) + Vector2.ONE * 0.5) * cell
		if p.distance_to(to) <= cell * 1.5:
			return true
		for d: Vector2i in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
			var n := c + d
			if seen.has(n):
				continue
			var q := (Vector2(n) + Vector2.ONE * 0.5) * cell
			if not floor.covers(q) or speed_scale(water, q) < 1.0:
				continue
			seen[n] = true
			queue.append(n)
	return false
