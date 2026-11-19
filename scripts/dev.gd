class_name Dev
extends RefCounted
## Command line switches for testing, after "--": --shot=file.png --shot-at=3 --bot --fast=10 --start=boss --nosave

static var _args: Dictionary = {}
static var _parsed := false


static func _parse() -> void:
	_parsed = true
	var raws := OS.get_cmdline_user_args()
	# In the browser there is no command line: the same switches come in the address, ?fast=5&start=boss
	if OS.has_feature("web"):
		var query := str(JavaScriptBridge.eval("window.location.search", true)).trim_prefix("?")
		for part in query.split("&", false):
			raws.append(part.uri_decode())
	for raw in raws:
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


## Sets a switch as if it came on the command line (the tests' hook seeds every run: tests/hooks/pre_run.gd).
static func put(key: String, value: String = "1") -> void:
	if not _parsed:
		_parse()
	_args[key] = value


## Takes a switch away again (a test that put one).
static func drop(key: String) -> void:
	if not _parsed:
		_parse()
	_args.erase(key)


static func num(key: String, fallback: float) -> float:
	return float(arg(key)) if has(key) else fallback


## Seeds a generator from --seed (plus a salt per system) so two runs play the same; random otherwise.
static func seed_rng(rng: RandomNumberGenerator, salt: int) -> void:
	if has("seed"):
		rng.seed = int(num("seed", 0)) * 1000 + salt
	else:
		rng.randomize()
