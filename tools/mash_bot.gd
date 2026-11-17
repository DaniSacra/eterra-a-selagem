extends Bot
## The input of tools/mash_driver.gd: walks to the nearest enemy and taps the attack every `every` frames.

var every := 3
var _frame := 0


func step(_dt: float, game: Game) -> void:
	pad.end_frame()
	Controls.virtual = pad
	_frame += 1
	var p := game.player.pos
	var target := game.horde.nearest(p, 60.0)
	var to := (target.pos - p) if target else Vector2.ZERO
	pad.move = to.normalized() if to.length() > 2.2 else Vector2.ZERO
	pad.aim = to.normalized() if to.length() > 0.1 else Vector2.RIGHT
	if _frame % every == 0:
		pad.press(&"light_attack")
	else:
		pad.release(&"light_attack")
