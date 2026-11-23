class_name BeamRules
extends RefCounted
## The Canalizador's beam (lote C1e C): a thin line held on the paladin in pulses, turning after him at a limited rate. Pure: Horde
## steps it and the floor's warning draws it.


## The beam's direction after `dt` s: `dir` turned toward `want` by at most `rate` degrees a second.
static func turned(dir: Vector2, want: Vector2, rate: float, dt: float) -> Vector2:
	if want.length_squared() < 0.0001:
		return dir
	var diff := dir.angle_to(want)
	var step := deg_to_rad(rate) * dt
	return dir.rotated(clampf(diff, -step, step)).normalized()


## Whether pulse number `fired` (0 based) is due `t` s into the beam: one every `interval`, the first at once.
static func pulse_due(t: float, interval: float, fired: int, ticks: int) -> bool:
	return fired < ticks and t >= float(fired) * interval


## Seconds the beam is held: every pulse has its `interval`.
static func hold_time(ticks: int, interval: float) -> float:
	return float(ticks) * interval


## True when `p` (the paladin's body, `margin` wide) is in the beam from `from` along `dir`, `reach` long and `width` across;
## never within `clear` m of its root.
static func hits(from: Vector2, dir: Vector2, p: Vector2, reach: float, width: float, clear: float, margin: float = 0.0) -> bool:
	return SweepRules.in_bar(from, dir, p, reach, width, clear, margin)
