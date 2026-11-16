class_name NavGrid
extends RefCounted
## Where bodies can walk in an arena, as a grid of CELL meters (cycle C12): made once per room from its FloorShape
## (the holes left out), its extra floors and what blocks the way (ArenaObstacle), then shrunk by a body's
## clearance. It answers whether one point is reached from another (islands), whether the straight way between two
## points is clear, and FlowField walks it toward a goal. Our own grid and not the engine's navigation: the same
## answer with the same seed, testable without a scene, and the same for the enemies and the bot. Pure (no nodes).

const CELL := 0.5
## The body every cell must fit (meters from a cell's middle to anything blocked): a little over the paladin's 0.5.
const CLEARANCE := 0.55

var origin := Vector2.ZERO
var cell := CELL
var width := 0
var height := 0
## 1 where a body fits.
var free := PackedByteArray()
## Which island of free cells each cell belongs to (-1: blocked).
var island := PackedInt32Array()
var islands := 0


## The grid over `bounds` for this floor (and the extra rectangles of floor, each `walk_margin` in from its sides),
## less what blocks the way, every free cell `clearance` from anything blocked.
static func build(bounds: Rect2, floor: FloorShape, walk: Array[Rect2] = [], walk_margin := 0.0, blockers: Array[ArenaObstacle] = [],
		clearance := CLEARANCE, size := CELL) -> NavGrid:
	var g := NavGrid.new()
	g.cell = size
	g.origin = bounds.position
	g.width = maxi(1, ceili(bounds.size.x / size))
	g.height = maxi(1, ceili(bounds.size.y / size))
	var raw := PackedByteArray()
	raw.resize(g.width * g.height)
	raw.fill(0)
	g._floor(raw, floor)
	for r in walk:
		g._fill_rect(raw, r.grow(-walk_margin), 1)
	for o in blockers:
		if o.blocks_move:
			g._block(raw, o)
	g._shrink(raw, clearance)
	g._find_islands()
	return g


func index_of(x: int, y: int) -> int:
	return y * width + x if x >= 0 and y >= 0 and x < width and y < height else -1


## The cell under a point (-1: off the grid).
func cell_at(p: Vector2) -> int:
	return index_of(floori((p.x - origin.x) / cell), floori((p.y - origin.y) / cell))


## The middle of a cell.
func center(i: int) -> Vector2:
	return origin + Vector2((i % width) + 0.5, (i / width) + 0.5) * cell


func walkable(p: Vector2) -> bool:
	var i := cell_at(p)
	return i >= 0 and free[i] == 1


## The free cell nearest to p within `rings` cells around it (-1: none).
func nearest_free(p: Vector2, rings := 4) -> int:
	var i := cell_at(p)
	if i >= 0 and free[i] == 1:
		return i
	var cx := floori((p.x - origin.x) / cell)
	var cy := floori((p.y - origin.y) / cell)
	var best := -1
	var best_d := INF
	for r in range(1, rings + 1):
		for dy in range(-r, r + 1):
			for dx in range(-r, r + 1):
				if maxi(absi(dx), absi(dy)) != r:
					continue
				var j := index_of(cx + dx, cy + dy)
				if j >= 0 and free[j] == 1:
					var d := center(j).distance_squared_to(p)
					if d < best_d:
						best_d = d
						best = j
		if best >= 0:
			return best
	return best


## True when b is reached from a by walking (the same island; each taken at its nearest free cell).
func reachable(a: Vector2, b: Vector2) -> bool:
	var i := nearest_free(a)
	var j := nearest_free(b)
	return i >= 0 and j >= 0 and island[i] == island[j]


## True when every cell the straight way from a to b crosses is free (a body walks it without turning).
func clear_line(a: Vector2, b: Vector2) -> bool:
	var x := floori((a.x - origin.x) / cell)
	var y := floori((a.y - origin.y) / cell)
	var x1 := floori((b.x - origin.x) / cell)
	var y1 := floori((b.y - origin.y) / cell)
	var d := b - a
	var sx := 1 if d.x > 0.0 else -1
	var sy := 1 if d.y > 0.0 else -1
	# the cells a segment passes through, in order (Amanatides and Woo)
	var tdx := absf(cell / d.x) if absf(d.x) > 0.000001 else INF
	var tdy := absf(cell / d.y) if absf(d.y) > 0.000001 else INF
	var gx := origin.x + (x + (1 if sx > 0 else 0)) * cell
	var gy := origin.y + (y + (1 if sy > 0 else 0)) * cell
	var tx := absf((gx - a.x) / d.x) if absf(d.x) > 0.000001 else INF
	var ty := absf((gy - a.y) / d.y) if absf(d.y) > 0.000001 else INF
	var steps := absi(x1 - x) + absi(y1 - y) + 1
	for k in steps:
		var i := index_of(x, y)
		if i < 0 or free[i] == 0:
			return false
		if tx < ty:
			x += sx
			tx += tdx
		else:
			y += sy
			ty += tdy
	return true


## How many free cells each island has (index: island).
func island_sizes() -> PackedInt32Array:
	var out := PackedInt32Array()
	out.resize(islands)
	out.fill(0)
	for i in island.size():
		if island[i] >= 0:
			out[island[i]] += 1
	return out


## The 4 neighbours of cell i that are on the grid (-1 where there is none), in a packed array of 4.
func _neighbours(i: int, out: PackedInt32Array) -> void:
	var x := i % width
	out[0] = i - 1 if x > 0 else -1
	out[1] = i + 1 if x < width - 1 else -1
	out[2] = i - width if i >= width else -1
	out[3] = i + width if i < width * (height - 1) else -1


# ---------- making it ----------

func _floor(raw: PackedByteArray, floor: FloorShape) -> void:
	if floor.kind != FloorShape.Kind.POLY:
		for i in raw.size():
			if floor.contains(center(i)):
				raw[i] = 1
		return
	for q in floor.polys:
		_scan(raw, q, 1)
	for q in floor.holes:
		_scan(raw, q, 0)


## Sets every cell whose middle is inside the polygon (row by row, between the crossings of its sides).
func _scan(raw: PackedByteArray, q: PackedVector2Array, value: int) -> void:
	var xs: Array[float] = []
	for y in height:
		var py := origin.y + (y + 0.5) * cell
		xs.clear()
		for k in q.size():
			var a := q[k]
			var b := q[(k + 1) % q.size()]
			if (a.y <= py) != (b.y <= py):
				xs.append(a.x + (py - a.y) / (b.y - a.y) * (b.x - a.x))
		xs.sort()
		for k in range(0, xs.size() - 1, 2):
			var x0 := maxi(0, ceili((xs[k] - origin.x) / cell - 0.5))
			var x1 := mini(width - 1, floori((xs[k + 1] - origin.x) / cell - 0.5))
			for x in range(x0, x1 + 1):
				raw[y * width + x] = value


func _fill_rect(raw: PackedByteArray, r: Rect2, value: int) -> void:
	if r.size.x <= 0.0 or r.size.y <= 0.0:
		return
	var x0 := maxi(0, ceili((r.position.x - origin.x) / cell - 0.5))
	var x1 := mini(width - 1, floori((r.end.x - origin.x) / cell - 0.5))
	var y0 := maxi(0, ceili((r.position.y - origin.y) / cell - 0.5))
	var y1 := mini(height - 1, floori((r.end.y - origin.y) / cell - 0.5))
	for y in range(y0, y1 + 1):
		for x in range(x0, x1 + 1):
			raw[y * width + x] = value


## Blocks every cell the obstacle touches.
func _block(raw: PackedByteArray, o: ArenaObstacle) -> void:
	var box := Rect2(o.center, Vector2.ZERO)
	for v in o.outline():
		box = box.expand(v)
	box = box.grow(cell)
	var x0 := maxi(0, floori((box.position.x - origin.x) / cell))
	var x1 := mini(width - 1, floori((box.end.x - origin.x) / cell))
	var y0 := maxi(0, floori((box.position.y - origin.y) / cell))
	var y1 := mini(height - 1, floori((box.end.y - origin.y) / cell))
	for y in range(y0, y1 + 1):
		for x in range(x0, x1 + 1):
			var i := y * width + x
			if o.depth(center(i), cell * 0.5) > 0.0:
				raw[i] = 0


## Keeps the cells with nothing blocked within `clearance` of their middle (the cells around them, by distance).
func _shrink(raw: PackedByteArray, clearance: float) -> void:
	free.resize(raw.size())
	var reach := ceili(clearance / cell - 0.5)
	var around: Array[Vector2i] = []
	for dy in range(-reach, reach + 1):
		for dx in range(-reach, reach + 1):
			# a blocked cell's near side is (distance - half a cell) away
			if maxf(Vector2(dx, dy).length() - 0.5, 0.0) * cell < clearance:
				around.append(Vector2i(dx, dy))
	for y in height:
		for x in width:
			var i := y * width + x
			if raw[i] == 0:
				free[i] = 0
				continue
			var ok := 1
			for o in around:
				var j := index_of(x + o.x, y + o.y)
				if j < 0 or raw[j] == 0:
					ok = 0
					break
			free[i] = ok


func _find_islands() -> void:
	island.resize(free.size())
	island.fill(-1)
	islands = 0
	var queue := PackedInt32Array()
	queue.resize(free.size())
	var nb := PackedInt32Array([0, 0, 0, 0])
	for s in free.size():
		if free[s] == 0 or island[s] >= 0:
			continue
		var head := 0
		var tail := 1
		queue[0] = s
		island[s] = islands
		while head < tail:
			var c := queue[head]
			head += 1
			_neighbours(c, nb)
			for k in 4:
				var j := nb[k]
				if j >= 0 and free[j] == 1 and island[j] < 0:
					island[j] = islands
					queue[tail] = j
					tail += 1
		islands += 1
