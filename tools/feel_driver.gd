extends SceneTree
## QA tool (game feel videos, outside the game's code): plays the real game (scenes/boot.tscn) and drives the paladin
## by a fixed script of inputs through Controls.VirtualPad, so a video shows one chosen action. Run it with the game's
## options after `--`, always with --bot (the game then hands its step to the driver below instead of the robot):
##   godot --path . -s res://tools/feel_driver.gd -- --bot --nosave --start=shop --feel=move
##   tools/movie.sh (PRE="-s res://tools/feel_driver.gd") records it with sound.
## --feel=move|combo|hits|abilities|bot. Moves are screen directions (x right, y down), turned to the floor by the
## camera's yaw like the keyboard. "fight" walks to the nearest enemy and plays the given combo (L light, H special,
## d dodge) on it, like the robot but without its dodging, so the swings and the enemies' reactions show plainly.

const SCRIPTS := {
	# movement and dodge in an empty room (--start=shop)
	"move": [[0.8, "move", Vector2(1, 0)], [1.8, "stop"], [2.2, "move", Vector2(-1, 0)], [2.6, "tap", "dodge"],
		[3.4, "stop"], [3.8, "move", Vector2(0, -1)], [4.2, "tap", "dodge"], [4.9, "move", Vector2(1, 1)],
		[5.3, "tap", "dodge"], [5.6, "move", Vector2(-1, 1)], [6.0, "stop"], [6.4, "move", Vector2(1, -0.3)],
		[6.5, "hold", "dodge", 1.8], [8.4, "move", Vector2(-1, 0.3)], [8.9, "move", Vector2(1, -0.3)],
		[9.4, "move", Vector2(-1, 0.3)], [9.9, "stop"], [10.4, "move", Vector2(0, 1)], [10.6, "tap", "dodge"],
		[10.95, "tap", "dodge"], [11.6, "stop"], [12.4, "move", Vector2(-1, -1)], [12.6, "tap", "dodge"],
		[13.4, "stop"]],
	# the whole light combo in the air, then on the enemies, finisher included
	"combo": [[1.0, "aim", Vector2(1, 0.2)], [1.0, "tap", "light_attack"], [1.25, "tap", "light_attack"],
		[1.5, "tap", "light_attack"], [2.6, "tap", "light_attack"], [2.85, "tap", "light_attack"],
		[3.1, "tap", "light_attack"], [4.2, "fight", "LLL"]],
	# close hits on a mixed group, short and full strings
	"hits": [[0.8, "fight", "LLLLLdLLL"]],
	# the special, the circle and the three Omegas (Magia 50: 20 + 10 + 20)
	"abilities": [[0.8, "chase", 4.0], [2.2, "tap", "heavy_attack"], [2.9, "tap", "heavy_attack"],
		[3.8, "chase", 2.5], [4.8, "tap", "cast"], [6.2, "chase", 2.5], [7.0, "hold", "light_attack", 1.0],
		[9.0, "chase", 4.0], [10.0, "hold", "heavy_attack", 0.8], [11.6, "chase", 2.5], [12.4, "hold", "cast", 0.9],
		[14.5, "fight", "LLL"]],
	# E1c (tools/movie.sh, docs/gallery/e1c/hero/): in an empty room (--start=shop), the aim up, A the 3-blow combo
	# mashed standing (1.0 s), B the same with the direction held right all the time (3.4 s), C the special with the
	# direction held left, then walking, twice (6.4 s and 8.6 s): every blow struck standing still, the run only after
	# the legs are free
	"planted": [[0.8, "aim", Vector2(0, -1)],
		[1.0, "tap", "light_attack"], [1.15, "tap", "light_attack"], [1.3, "tap", "light_attack"],
		[1.45, "tap", "light_attack"], [3.2, "move", Vector2(1, 0)], [3.4, "tap", "light_attack"],
		[3.55, "tap", "light_attack"], [3.7, "tap", "light_attack"], [3.85, "tap", "light_attack"],
		[5.8, "stop"], [6.2, "aim", Vector2(-1, 0)], [6.2, "move", Vector2(-1, 0)], [6.4, "tap", "heavy_attack"],
		[7.8, "stop"], [8.2, "aim", Vector2(1, 0)], [8.4, "move", Vector2(1, 0)], [8.6, "tap", "heavy_attack"],
		[10.0, "stop"]],
}


var _feel := "move"
var _driver: Node = null


func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--feel="):
			_feel = a.trim_prefix("--feel=")
	change_scene_to_file("res://scenes/boot.tscn")


func _process(_d: float) -> bool:
	if _driver != null:
		return false
	for n in root.find_children("*", "Node", true, false):
		if n.has_method(&"result") and "bot" in n and n.get(&"bot") != null:
			var d: Object = load("res://tools/feel_driver_bot.gd").new()
			d.set(&"reaction", n.get(&"bot").get(&"reaction"))
			d.set(&"robot", _feel == "bot")
			d.set(&"steps", SCRIPTS.get(_feel, []))
			n.set(&"bot", d)
			root.get_node("Controls").set(&"virtual", d.get(&"pad"))
			_driver = n
			print("FEEL driver on: ", _feel)
			break
	return false
