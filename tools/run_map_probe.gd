extends SceneTree
## SW-R2: builds many descents and prints how often the graph needed another try
## (~/tools/godot/godot --headless --path . -s tools/run_map_probe.gd -- runs=300).

func _init() -> void:
	var n := 300
	for a in OS.get_cmdline_user_args():
		if a.begins_with("runs="):
			n = int(a.substr(5))
	var stage: StageDef = load("res://data/stages/catacombs.tres")
	var failed := 0
	var tries := 0
	for run in n:
		var m := RunMap.new(stage, 300 + run)
		tries += m.failures
		failed += 1 if m.failures >= RunMap.MAX_TRIES else 0
	print("descents %d, retries %d (%.2f a descent), never kept the rules %d" % [n, tries, float(tries) / n, failed])
	quit()
