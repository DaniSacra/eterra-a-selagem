extends SceneTree
## SW-R1: the room budget by depth, drawn many times: heads, cost, rating, the mix of modes and kinds
## (~/tools/godot/godot --headless --path . -s tools/budget_probe.gd -- [fights=40]).

func _init() -> void:
	var n := 40
	for a in OS.get_cmdline_user_args():
		if a.begins_with("fights="):
			n = int(a.substr(7))
	var stage: StageDef = load("res://data/stages/catacombs.tres")
	var defs := {}
	for id in stage.enemies:
		defs[id] = load("res://data/enemies/%s.tres" % id)
	print("depth budget | heads cost rating waves horde%% elites kinds")
	for depth in range(1, stage.rooms):
		if stage.miniboss_depth_min == depth or stage.miniboss2_depth_min == depth:
			continue
		var heads := 0.0
		var cost := 0.0
		var rating := 0.0
		var waves := 0.0
		var horde := 0
		var elites := 0.0
		var kinds := 0.0
		for i in n:
			var rng := RandomNumberGenerator.new()
			rng.seed = depth * 1000 + i
			var f := EncounterGen.generate(stage, depth, defs, rng)
			horde += 1 if f.mode == EncounterGen.Mode.HORDE else 0
			waves += f.waves.size()
			kinds += f.kinds.size()
			for w in f.waves:
				heads += w.size()
				cost += EncounterGen.cost_of(w, defs)
				for id: StringName in w:
					rating += (defs[id] as EnemyDef).rating
					elites += 1.0 if (defs[id] as EnemyDef).elite else 0.0
		print("%2d %5.0f | %5.1f %5.1f %6.1f %4.1f %3d%% %4.2f %3.1f" % [depth, EncounterGen.cost_budget(stage, depth), heads / n, cost / n, rating / n,
			waves / n, 100 * horde / n, elites / n, kinds / n])
	quit()
