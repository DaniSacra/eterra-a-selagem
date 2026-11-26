class_name FlowField
extends RefCounted
## The way to one goal from every cell of a NavGrid (cycle C12): a breadth-first count of cells from the goal, so
## from anywhere the next cell is the neighbour with the lower count. Made again only when the goal moves to another
## cell, at most once every REFRESH seconds, and spread over frames (BUDGET cells a step) so a big room never costs a
## frame its whole making; the last finished field is used meanwhile. Pure (no nodes).

## Seconds between two fields at most (4 a second).
const REFRESH := 0.25
## Cells counted per step while a field is being made.
const BUDGET := 1500
## How many cells ahead along the field next_step looks for the farthest one in a straight clear line.
const LOOK := 8

var grid: NavGrid
## Cells from the goal of the finished field (-1: never reached).
var dist := PackedInt32Array()
## Fields finished so far.
var made := 0
var _goal := -1
var _work := PackedInt32Array()
var _queue := PackedInt32Array()
var _head := 0
var _tail := 0
var _building := -1
var _since := INF
var _nb := PackedInt32Array([0, 0, 0, 0])


func _init(g: NavGrid) -> void:
	grid = g
	dist.resize(g.free.size())
	dist.fill(-1)
	_work.resize(g.free.size())
	_queue.resize(g.free.size())


## Follows a goal: starts a new field when it stands in another cell and REFRESH seconds have passed, then makes
## BUDGET cells of it (all of it with budget <= 0). dt: seconds since the last call.
func aim(goal: Vector2, dt: float, budget := BUDGET) -> void:
	_since += dt
	var c := goal_cell(goal)
	if c >= 0 and c != _goal and _building < 0 and _since >= REFRESH:
		_start(c)
	if _building >= 0:
		_grow(budget)


## The cell a way to `goal` ends at: its nearest free cell, or, when that cell is a pocket cut off from the room's
## floor (the paladin squeezed between the trunk and a root: no walker could ever reach it), the nearest cell of the floor.
func goal_cell(goal: Vector2) -> int:
	var c := grid.nearest_free(goal)
	if c >= 0 and grid.island[c] != grid.main_island():
		var m := grid.nearest_main(goal)
		if m >= 0:
			return m
	return c


## True once a field toward the goal has been finished.
func ready() -> bool:
	return made > 0


## The way to walk from `from` (unit), toward the farthest of the next LOOK cells of the field that the straight
## line reaches clear; ZERO when there is no field or the goal is not reached from there.
func next_step(from: Vector2) -> Vector2:
	if made == 0:
		return Vector2.ZERO
	var c := grid.nearest_free(from)
	if c < 0 or dist[c] < 0:
		return Vector2.ZERO
	if dist[c] == 0:
		var to_goal := grid.center(c) - from
		return to_goal.normalized() if to_goal.length_squared() > 0.0001 else Vector2.ZERO
	var target := grid.center(c)
	var cur := c
	var first := true
	for k in LOOK:
		var nxt := _down(cur)
		if nxt < 0:
			break
		cur = nxt
		var p := grid.center(cur)
		if first or grid.clear_line(from, p):
			target = p
			first = false
		else:
			break
	var way := target - from
	return way.normalized() if way.length_squared() > 0.0001 else Vector2.ZERO


## Cells from `from` to the goal by the field (-1: no field or not reached).
func steps_from(from: Vector2) -> int:
	var c := grid.nearest_free(from)
	return dist[c] if c >= 0 and made > 0 else -1


## The neighbour of cell i nearer the goal (-1: none). Diagonals only between two free sides.
func _down(i: int) -> int:
	var best := -1
	var best_d := dist[i]
	grid._neighbours(i, _nb)
	for k in 4:
		var j := _nb[k]
		if j >= 0 and dist[j] >= 0 and dist[j] < best_d:
			best_d = dist[j]
			best = j
	# a diagonal two counts lower, when both cells beside it are free
	var x := i % grid.width
	for dy: int in [-1, 1]:
		for dx: int in [-1, 1]:
			var j := grid.index_of(x + dx, i / grid.width + dy)
			if j < 0 or dist[j] < 0 or dist[j] > dist[i] - 2:
				continue
			var a := i + dx
			var b := i + dy * grid.width
			if grid.free[a] == 1 and grid.free[b] == 1 and dist[j] < best_d:
				best_d = dist[j]
				best = j
	return best


func _start(c: int) -> void:
	_building = c
	_since = 0.0
	_work.fill(-1)
	_work[c] = 0
	_queue[0] = c
	_head = 0
	_tail = 1


func _grow(budget: int) -> void:
	var left := budget if budget > 0 else _work.size()
	var free := grid.free
	while _head < _tail and left > 0:
		var c := _queue[_head]
		_head += 1
		left -= 1
		var d := _work[c] + 1
		grid._neighbours(c, _nb)
		for k in 4:
			var j := _nb[k]
			if j >= 0 and free[j] == 1 and _work[j] < 0:
				_work[j] = d
				_queue[_tail] = j
				_tail += 1
	if _head >= _tail:
		var t := dist
		dist = _work
		_work = t
		_goal = _building
		_building = -1
		made += 1
