extends Bot
## The input script of tools/feel_driver.gd (loaded by it once the game runs: a -s script cannot name the autoloads
## when it compiles, and Bot does). Plays the timeline `steps`, or the real robot when `robot` is on.

var steps: Array = []
var t := 0.0
var i := 0
var screen_move := Vector2.ZERO
var aim_screen := Vector2.ZERO
var holds: Dictionary = {}  # action -> seconds left
var chase_to := -1.0
var fight := ""
var fight_i := 0
var gap := 0.0
var robot := false

func step(dt: float, game: Game) -> void:
	if robot:
		super.step(dt, game)
		return
	pad.end_frame()
	Controls.virtual = pad
	t += dt
	for a in holds.keys():
		holds[a] -= dt
		if holds[a] <= 0.0:
			pad.release(a)
			holds.erase(a)
	for a in [&"light_attack", &"heavy_attack", &"cast", &"dodge"]:
		if not holds.has(a):
			pad.release(a)
	while i < steps.size() and t >= float(steps[i][0]):
		_do(steps[i], game)
		i += 1
	var p := game.player.pos
	var target := _nearest(game)
	var to := target - p
	if chase_to > 0.0 or fight != "":
		var reach := chase_to if chase_to > 0.0 else 2.4
		pad.move = to.normalized() if to.length() > reach else Vector2.ZERO
		if to.length() <= reach and chase_to > 0.0:
			chase_to = -1.0
	else:
		pad.move = Feel.screen_to_floor(screen_move, game.cam_yaw()) if screen_move != Vector2.ZERO else Vector2.ZERO
	pad.aim = Feel.screen_to_floor(aim_screen, game.cam_yaw()) if aim_screen != Vector2.ZERO \
		else (to.normalized() if to.length() > 0.01 else game.player.facing)
	if fight != "" and to.length() <= 2.6:
		gap -= dt
		if gap <= 0.0:
			var key := fight[fight_i % fight.length()]
			fight_i += 1
			var action: StringName = {"L": &"light_attack", "H": &"heavy_attack", "d": &"dodge"}[key]
			pad.press(action)
			# a string ends where the next letter repeats the start: rest a little after the third light
			gap = 0.7 if fight_i % 3 == 0 else 0.25

func _do(s: Array, _game: Game) -> void:
	match String(s[1]):
		"move":
			screen_move = s[2]
			chase_to = -1.0
		"stop":
			screen_move = Vector2.ZERO
		"aim":
			aim_screen = s[2]
		"tap":
			pad.press(StringName(s[2]))
		"hold":
			pad.press(StringName(s[2]))
			holds[StringName(s[2])] = float(s[3])
		"chase":
			aim_screen = Vector2.ZERO
			chase_to = float(s[2])
			fight = ""
		"fight":
			aim_screen = Vector2.ZERO
			fight = String(s[2])
			fight_i = 0
			gap = 0.0
