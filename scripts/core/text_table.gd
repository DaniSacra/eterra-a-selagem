class_name TextTable
extends Resource
## Every player-facing string, in Brazilian Portuguese. PALADIN_1..4 are placeholders Daniel fills in.

@export var entries: Dictionary = {}


func text(key: StringName, args: Dictionary = {}) -> String:
	if not entries.has(String(key)):
		return String(key)
	var out: String = entries[String(key)]
	for i in range(1, 5):
		out = out.replace("{P%d}" % i, entries.get("PALADIN_%d" % i, "PALADIN_%d" % i))
	for k: String in args:
		out = out.replace("{%s}" % k, str(args[k]))
	return out
