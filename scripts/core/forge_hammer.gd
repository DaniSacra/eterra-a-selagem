class_name ForgeHammer
extends RefCounted
## The Forja's gesture (docs/art/forge_spec.md 5): spending a material takes three hammer strikes, and the strikes are
## the confirmation. A press is one strike; the piece stays hot for COOL_AFTER seconds between strikes and then cools
## (the count goes back to zero, nothing spent); cancel() cools it at once. Holding the press fills a HoldGauge in
## HOLD_TIME seconds and gives the strikes by itself (the second halfway, the third at the end), for those who cannot
## tap. Pure; the screen steps it with the frame's delta and spends on the third strike.
##   var h := ForgeHammer.new()
##   h.strike()        # 1, 2, then 3: the spend (the count then goes back to zero)
##   h.step(delta)     # the strike number the hold landed this frame (0 none); h.cooled: it went cold now

const COOL_AFTER := 1.2
const HOLD_TIME := 1.2
const STRIKES := 3

## Strikes landed on the hot piece (0 cold, 1 or 2 hot).
var strikes := 0
## The piece went cold on the last step (cleared by the next).
var cooled := false
var gauge := HoldGauge.new(HOLD_TIME, 0.2)
var _idle := 0.0
## The press is down and has not been released: the hold is on.
var _down := false


## One strike; the number it lands (STRIKES: the spend, and the count restarts).
func strike() -> int:
	_idle = 0.0
	strikes += 1
	if strikes >= STRIKES:
		strikes = 0
		gauge.cancel()
		gauge.progress = 0.0
		_down = false
		return STRIKES
	return strikes


## The press went down: the first strike, and the hold starts for the others (false: it already was the third).
func press() -> int:
	var n := strike()
	if n < STRIKES:
		_down = true
		gauge.start()
	return n


func release() -> void:
	_down = false
	gauge.cancel()


## Cools the piece without spending (B between the first strike and the third). True when it was hot.
func cancel() -> bool:
	var was := strikes > 0
	strikes = 0
	_idle = 0.0
	_down = false
	gauge.cancel()
	gauge.progress = 0.0
	return was


## Advances by dt. Returns the strike number the hold landed (2 or STRIKES), 0 when none.
func step(dt: float) -> int:
	cooled = false
	if _down:
		var before := gauge.progress
		var full := gauge.step(dt)
		_idle = 0.0
		if full:
			strikes = 0
			_down = false
			return STRIKES
		if before < 0.5 and gauge.progress >= 0.5 and strikes < 2:
			strikes = 2
			return 2
		return 0
	gauge.step(dt)
	if strikes > 0:
		_idle += dt
		if _idle >= COOL_AFTER:
			strikes = 0
			_idle = 0.0
			cooled = true
	return 0


## The fill of the hold, 0 to 1 (the dots and the button).
func hold_progress() -> float:
	return gauge.progress
