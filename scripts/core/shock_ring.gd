class_name ShockRing
extends RefCounted
## The knight's shield wave: a thin band that spreads from where the shield landed, too fast to outrun. The only way
## through is the dodge, whose protection lasts its whole 0.2 s; a hit on it counts as a close dodge (DodgeClose).


## Radius of the band's middle `t` seconds after it was born (`delay` seconds held at `start`, then `speed` m/s).
static func radius_at(t: float, start: float, speed: float, delay: float) -> float:
	return start + maxf(0.0, t - delay) * speed


## Whether a body of `body` radius at `p` touches the band (its middle at `radius` from `center`, `thick` wide).
static func touches(center: Vector2, radius: float, thick: float, p: Vector2, body: float) -> bool:
	return absf(p.distance_to(center) - radius) <= thick * 0.5 + body


## Whether the band has gone past every corner `reach` meters from its birth.
static func spent(radius: float, reach: float) -> bool:
	return radius >= reach


## Seconds a body that starts running from the band at `run` m/s, `gap` meters ahead of it, is caught (INF: never).
static func caught_in(gap: float, speed: float, run: float) -> float:
	return gap / (speed - run) if speed > run else INF
