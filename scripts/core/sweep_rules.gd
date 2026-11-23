class_name SweepRules
extends RefCounted
## The Varredor's turn (lote C5, CB-7): a bar of floor swung round its root. Pure: Horde steps it and draws it.

## Degrees before the paladin's line at which the bar starts, so it takes the paladin's first spot only after
## LEAD_DEGREES / (sweep_degrees / sweep_time) seconds: time to read it and walk with it, step out or dash.
const LEAD_DEGREES := 70.0
## Degrees ahead of the starting bar at which the thread that tells the way it will turn is laid in the wind-up.
const WAY_DEGREES := 32.0


## The direction the bar starts along: the paladin's line turned back against the way it will go round.
static func start_dir(toward: Vector2, way: float) -> Vector2:
	return toward.rotated(-way * deg_to_rad(LEAD_DEGREES)).normalized()


## The bar's direction t seconds into a turn of `degrees` over `time` seconds from `start`, turning `way` (1 or -1).
static func dir_at(start: Vector2, way: float, degrees: float, time: float, t: float) -> Vector2:
	return start.rotated(way * deg_to_rad(degrees) * clampf(t / maxf(time, 0.001), 0.0, 1.0))


## True when `p` stands in the bar from `from` along `dir` (reach m long, width m across), but never within `clear` m of
## the root: right at the Varredor's feet the bar does not hurt. margin widens the bar (what the paladin's body takes).
static func in_bar(from: Vector2, dir: Vector2, p: Vector2, reach: float, width: float, clear: float, margin: float = 0.0) -> bool:
	var d := p - from
	if d.length() <= clear:
		return false
	var along := d.dot(dir)
	return along >= 0.0 and along <= reach + margin and absf(d.cross(dir)) <= width * 0.5 + margin
