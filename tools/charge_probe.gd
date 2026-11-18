extends "res://tools/bake.gd"
## T5 (A-T5-1): how a shield bearer carries its shield through a clip, baked as tools/bake.gd does (nothing saved).
## ~/tools/godot/godot --headless --path . -s tools/charge_probe.gd -- <id> [anim ...] [--scan=from:to:poses]
## Per pose of each anim (default brace and charge): BakedModel.guard_pose (shield ahead of the chest, trunk lean,
## head behind the shield's top edge, top of the figure). --scan replaces the charge's from, to and poses (to find the
## part of a clip that keeps the shield in front).


func _process(_delta: float) -> bool:
	if _done:
		return true
	_done = true
	var args := Array(OS.get_cmdline_user_args())
	var id: String = args.pop_front()
	var spec: Dictionary = (MODELS[id] as Dictionary).duplicate(true)
	var anims: Array = []
	for a: String in args:
		if a.begins_with("--scan="):
			var s := a.trim_prefix("--scan=").split(":")
			var clip: Array = (spec.anims.charge as Array).duplicate(true)
			var opts: Dictionary = clip[4]
			opts["from"] = float(s[0])
			opts["to"] = float(s[1])
			clip[2] = int(s[2])
			spec.anims["charge"] = clip
		else:
			anims.append(a)
	if anims.is_empty():
		anims = ["brace", "charge"]
	only_anims = ["idle"] + anims
	var m := _bake_meshy(spec)
	for anim: String in ["idle"] + anims:
		print("== %s %s" % [id, anim])
		for f in m.frame_count(StringName(anim)):
			var g := m.guard_pose(StringName(anim), f)
			print("  %02d shield ahead %+.2f m, lean %+.0f deg, head behind the shield's top %+.2f m, top %.2f" % [f, g.ahead, g.lean, g.head_behind, g.top])
	quit()
	return true
