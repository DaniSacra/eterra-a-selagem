class_name RunLean
extends RefCounted
## GF-15: the run's start and stop drawn without clips of their own (the UAL has none; Hades II has MelinoeStart and
## MelinoeStop): the body leans into the first steps and rocks back on the stop, a pulse over TIME seconds, never a
## change of what he does (drawing only, the answer to the stick is the frame of the press as before).

## Degrees forward at the top of the pulse when he sets off, and back when he stops.
const START_DEG := 7.0
const STOP_DEG := 5.0
## Seconds of the pulse (its top at a third of it) and the clip's mix between the guard and the run, both ways.
const TIME := 0.3
const PEAK_AT := 1.0 / 3.0
const BLEND := 0.1

var moving := false
var _kick := 0.0
var _t := TIME


## One frame: moving says whether he walks or runs on his own legs now (null keeps what was, the dodge and the blows).
## Gives the lean in radians, forward positive.
func step(now: Variant, dt: float) -> float:
	if now is bool and now != moving:
		moving = now
		_kick = START_DEG if moving else -STOP_DEG
		_t = 0.0
	else:
		_t += dt
	return deg_to_rad(_kick) * shape(_t / TIME)


## The pulse: 0 at its ends, 1 at PEAK_AT, eased both ways.
static func shape(x: float) -> float:
	if x <= 0.0 or x >= 1.0:
		return 0.0
	if x < PEAK_AT:
		return smoothstep(0.0, PEAK_AT, x)
	return 1.0 - smoothstep(PEAK_AT, 1.0, x)
