class_name ChainPlan
extends RefCounted
## The route of the Tempestade Celestial (Maga Redesign V1, docs/design/heroes/maga_redesign_v1_pack/01_KIT.md): a bolt that goes to the
## nearest body in reach of her, then jumps to the nearest body it has not crossed within `jump`, up to `targets` distinct bodies, each
## jump taking `falloff` of the damage off (never under MIN_SHARE). It never goes back to a body (no loops). When it found one body only
## (an isolated boss) it strikes that body `solo` times in all, each strike weaker, so a lone target is worth the Supremo too.
## Pure: bodies are points; the answer is the order of their indices and the damage share of each strike.

const MIN_SHARE := 0.25

var targets := 6
var jump := 5.0
var reach := 9.0
var falloff := 0.1
var solo := 3


## The strikes from `origin` over `points`: [{index: the point's place in `points`, share: the damage share, repeat: a second strike on the
## same body}]. The first body is the one nearest to `aim` among those within `reach` of `origin`; empty when none is.
func route(origin: Vector2, aim: Vector2, points: Array[Vector2]) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	var used := {}
	var first := -1
	var best := INF
	for i in points.size():
		if points[i].distance_to(origin) > reach:
			continue
		var d := points[i].distance_squared_to(aim)
		if d < best:
			best = d
			first = i
	if first < 0 or targets <= 0:
		return out
	var at := first
	while at >= 0 and out.size() < targets:
		used[at] = true
		out.append({"index": at, "share": share_of(out.size()), "repeat": false})
		var next := -1
		var nearest := INF
		for i in points.size():
			if used.has(i):
				continue
			var d := points[i].distance_squared_to(points[at])
			if d <= jump * jump and d < nearest:
				nearest = d
				next = i
		at = next
	if out.size() == 1:
		for k in range(1, solo):
			out.append({"index": first, "share": share_of(k), "repeat": true})
	return out


## The share of the damage the strike number `n` (0: the first) deals.
func share_of(n: int) -> float:
	return maxf(MIN_SHARE, 1.0 - falloff * float(n))
