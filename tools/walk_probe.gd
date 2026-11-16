extends "res://tools/bake.gd"
## Measures walk clips on the figures without writing anything: per figure and candidate clip, the stride in the
## game (steps a minute at the enemy's speed and size, Horde.walk_rate) and how far the planted foot slides a step
## in the game's meters (BakedModel.slide_per_step times EnemyDef.size; E1b-A1).
## ~/tools/godot/godot --headless --path . -s tools/walk_probe.gd -- [<id>[=<rig>:<clip>[:<stride>],...] ...]
## (no candidates: the walk in MODELS; no ids: every walking figure; a stride locks the feet at it, _foot_lock). The other options of the MODELS walk are kept.

const ENEMIES := "res://data/enemies/%s.tres"
const WALKERS := ["skeleton", "runner", "mage", "archer", "guard", "knight", "priest_elder", "morvath"]


func _process(_delta: float) -> bool:
	if _done:
		return true
	_done = true
	only_anims = ["walk", "idle"]
	var args := Array(OS.get_cmdline_user_args())
	if args.is_empty():
		args = WALKERS
	for arg: String in args:
		var id := arg.get_slice("=", 0)
		var spec: Dictionary = MODELS[id].duplicate(true)
		var walk: Array = spec.anims.walk
		var cands: Array = [walk]
		if arg.contains("="):
			cands = []
			for c in arg.get_slice("=", 1).split(","):
				var w := walk.duplicate(true)
				w[0] = StringName(c.get_slice(":", 0))
				w[1] = c.get_slice(":", 1)
				if c.get_slice_count(":") > 2:
					# a stride: the feet locked at that stride ("lock", "stride" in MODELS)
					var opts: Dictionary = (w[4] as Dictionary).duplicate() if w.size() > 4 else {}
					opts["lock"] = true
					opts["stride"] = float(c.get_slice(":", 2))
					if w.size() > 4:
						w[4] = opts
					else:
						w.append(opts)
				cands.append(w)
		var d: EnemyDef = load(ENEMIES % id)
		for w: Array in cands:
			spec.anims.walk = w
			var m := _bake_meshy(spec)
			print("PROBE %s %s:%s %s" % [id, w[0], w[1], report(m, d)])
	quit()
	return true


## The walk of a baked figure for an enemy: the floor's speed under it, the clip, the rate the horde plays it at,
## steps a minute and the slide of the planted foot a step, in the game's centimeters.
static func report(m: BakedModel, d: EnemyDef) -> String:
	var ground: float = m.ground_speed.walk
	var slide := BakedModel.slide_per_step(m.feet.walk, 1.0 / float(m.fps.walk), ground)
	# Horde.walk_rate (Horde needs the autoloads, which a -s script lacks)
	var rate := d.speed / (ground * d.size)
	return "ground %.2f m/s, clip %.2f s, rate %.2fx, %.0f steps/min, slide %.1f cm in game" % [ground, m.duration(&"walk"),
		rate, 120.0 * rate / m.duration(&"walk"), slide * d.size * 100.0]
