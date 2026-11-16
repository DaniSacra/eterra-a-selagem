class_name HitStop
extends RefCounted
## The hit stop as Hades II plays it (GF-01; game_feel_measures.md table 7): a blow lands and the world keeps its
## full speed for a wait (25 to 70 ms, ScreenPreWait), then drops to a small fraction of its speed (6%) for a moment
## (10 ms, 50 with a kill) and comes back over BACK seconds (20 ms). Never a freeze. Every second here is a real one.
## advance() gives the speed of the world for each frame: the speed at the middle of the frame, and the slow at
## least one whole frame (a 10 ms slow is shorter than a frame at 60 Hz, and must still be seen).

const BACK := 0.02
const FRACTION := 0.06

var _wait := 0.0
var _slow := 0.0
var _fraction := FRACTION
var _back := BACK
var _t := 0.0
var _on := false
var _slowed := false


## A blow lands: wait seconds at full speed, slow seconds at fraction, back seconds back to full speed. One already
## playing is only replaced by one that ends later.
func start(wait: float, slow: float, fraction: float = FRACTION, back: float = BACK) -> void:
	if slow <= 0.0 or (_on and wait + slow + back <= left()):
		return
	_wait = maxf(0.0, wait)
	_slow = slow
	_fraction = clampf(fraction, 0.0, 1.0)
	_back = maxf(back, 0.0)
	_t = 0.0
	_on = true
	_slowed = false


func active() -> bool:
	return _on


## Real seconds left of it (0 when none plays).
func left() -> float:
	return maxf(0.0, _wait + _slow + _back - _t) if _on else 0.0


func clear() -> void:
	_on = false


## Real seconds pass (one frame): the speed of the world for that frame (1 = full speed).
func advance(dt: float) -> float:
	if not _on:
		return 1.0
	var t0 := _t
	_t += dt
	var mid := t0 + dt * 0.5
	var slow_end := _wait + _slow
	var rate := 1.0
	if mid >= _wait and mid < slow_end:
		rate = _fraction
	elif mid >= slow_end and mid < slow_end + _back:
		rate = lerpf(_fraction, 1.0, (mid - slow_end) / maxf(_back, 0.0001))
	if rate <= _fraction:
		_slowed = true
	elif not _slowed and t0 < slow_end and _t > _wait:
		# the frame crosses the whole slow without its middle in it: it is the slow frame
		rate = _fraction
		_slowed = true
	if _t >= slow_end + _back:
		_on = false
	return rate
