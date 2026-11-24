class_name HoldGauge
extends RefCounted
## "Segure para abrir" (docs/art/dons_medallion_spec.md 7): a press that has to be held for `time` seconds. Letting go
## before the end cancels it and the bar drains back in `drain` seconds. Pure; the screen steps it with the frame's delta.

var time := 1.0
var drain := 0.2
var held := false
## 0..1
var progress := 0.0


func _init(p_time: float = 1.0, p_drain: float = 0.2) -> void:
	time = p_time
	drain = p_drain


func start() -> void:
	held = true


func cancel() -> void:
	held = false


## Advances by dt; true on the frame the bar fills (it then stops holding).
func step(dt: float) -> bool:
	if held:
		progress = minf(progress + dt / time, 1.0)
		if progress >= 1.0:
			held = false
			progress = 0.0
			return true
	elif progress > 0.0:
		progress = maxf(progress - dt / drain, 0.0)
	return false
