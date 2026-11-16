class_name StepTimer
extends RefCounted
## How long the game's step takes, measured only while there is something to step (pure; Game feeds it every
## frame). The old RESULT step_ms was a smoothed value read at the end of the run, when the room was already empty,
## and said nothing about the fight (QA B-3, BUG-012). Frames with nobody standing are left out of the average and
## the peak.

## Frames measured (with someone standing).
var frames := 0
## The slowest of those steps (ms).
var peak := 0.0
var _sum := 0.0


## One step took `ms`; `busy`: there were enemies standing during it.
func add(ms: float, busy: bool) -> void:
	if not busy:
		return
	frames += 1
	_sum += ms
	peak = maxf(peak, ms)


## The mean of the measured steps (ms; 0 before any).
func average() -> float:
	return _sum / frames if frames > 0 else 0.0
