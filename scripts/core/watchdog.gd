class_name Watchdog
extends RefCounted
## The watch over a run (C17, BUG-110: an exe run by the robot stood still 2.2 s into its first room, with no cause in
## the game's code). With --watchdog the game samples itself every EVERY real seconds: frames drawn so far and frames a
## second since the last sample, its mode, the world's rate (Fx.rate: slow motion times the hit stop),
## Engine.time_scale and the run's clock. A sample goes to the console (a WATCH line) and into the run's log (watch):
## frames standing still means the engine or the system; frames running with the mode out of PLAY or the rate near 0
## means the game.

const EVERY := 5.0
## The most samples kept for the log (an hour of them).
const KEEP := 720

var samples: Array[Dictionary] = []
var _last_real := -1.0
var _last_frames := 0


## Called every frame with the real seconds since start (Time), the frames drawn so far and the game's state. Returns
## the sample taken now (empty most frames).
func tick(real_s: float, frames: int, mode: String, rate: float, time_scale: float, clock: float) -> Dictionary:
	if _last_real < 0.0:
		_last_real = real_s
		_last_frames = frames
		return {}
	if real_s - _last_real < EVERY:
		return {}
	var fps := (frames - _last_frames) / maxf(real_s - _last_real, 0.001)
	var s := {"real_s": snappedf(real_s, 0.1), "frames": frames, "fps": snappedf(fps, 0.1), "mode": mode,
		"rate": snappedf(rate, 0.001), "time_scale": snappedf(time_scale, 0.001), "time": snappedf(clock, 0.01)}
	_last_real = real_s
	_last_frames = frames
	if samples.size() < KEEP:
		samples.append(s)
	return s


static func line(sample: Dictionary) -> String:
	return "WATCH " + JSON.stringify(sample)
