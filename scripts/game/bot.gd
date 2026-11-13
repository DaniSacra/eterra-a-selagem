class_name Bot
extends RefCounted
## A stand-in player for screenshots and smoke runs. Feeds Controls through a virtual pad.

var pad := Controls.VirtualPad.new()
var _t := 0.0


func step(dt: float, _game: Node) -> void:
	pad.end_frame()
	_t += dt
	pad.move = Vector2(cos(_t * 1.3), sin(_t * 0.9))
	pad.aim = Vector2(cos(_t * 2.0), sin(_t * 2.0))
	pad.release(&"dodge")
	if fmod(_t, 1.6) < dt:
		pad.press(&"dodge")
