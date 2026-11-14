class_name Dev
extends RefCounted
## Command line switches for testing, after "--": --shot=file.png --shot-at=3 --bot --fast=10 --start=boss --nosave

static var _args: Dictionary = {}
static var _parsed := false


static func _parse() -> void:
	_parsed = true
	for raw in OS.get_cmdline_user_args():
		var a := raw.trim_prefix("--")
		var eq := a.find("=")
		if eq < 0:
			_args[a] = "1"
		else:
			_args[a.substr(0, eq)] = a.substr(eq + 1)


static func has(key: String) -> bool:
	if not _parsed:
		_parse()
	return _args.has(key)


static func arg(key: String, fallback: String = "") -> String:
	if not _parsed:
		_parse()
	return _args.get(key, fallback)


static func num(key: String, fallback: float) -> float:
	return float(arg(key)) if has(key) else fallback


## Seeds a generator from --seed (plus a salt per system) so two runs play the same; random otherwise.
static func seed_rng(rng: RandomNumberGenerator, salt: int) -> void:
	if has("seed"):
		rng.seed = int(num("seed", 0)) * 1000 + salt
	else:
		rng.randomize()
