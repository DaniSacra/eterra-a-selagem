class_name TextTable
extends Resource
## Every player-facing string, in Brazilian Portuguese. PALADIN_1..4 are placeholders Daniel fills in.
## A clause in square brackets that names a paladin ("Chama[, dom de {P2}]") is dropped while that paladin's name is
## still the placeholder, so no "PALADIN_n" ever reaches the screen; it comes back by itself once the name is set.

@export var entries: Dictionary = {}


func text(key: StringName, args: Dictionary = {}) -> String:
	if not entries.has(String(key)):
		return String(key)
	var out := _clauses(entries[String(key)])
	for i in range(1, 5):
		out = out.replace("{P%d}" % i, paladin(i))
	# the hub's name (HUB-01; provisional until Daniel names the place, D-H4): one key, every text that says it
	out = out.replace("{HUB}", entries.get("hub_name", "{HUB}"))
	for k: String in args:
		out = out.replace("{%s}" % k, str(args[k]))
	return glue_units(out)


static var _unit_rx: RegEx

## A number (or the {placeholder} that becomes one) and its unit keep together on a line: "0,8 s" never leaves "s."
## alone on the next one (the space between them becomes a no-break space).
static func glue_units(text: String) -> String:
	if _unit_rx == null:
		_unit_rx = RegEx.create_from_string("([0-9}]) (s|m|ms|%|x)(?![\\p{L}0-9])")
	return _unit_rx.sub(text, "$1\u00A0$2", true)


## The name of paladin i (1..4); the placeholder itself while Daniel has not named him.
func paladin(i: int) -> String:
	return entries.get("PALADIN_%d" % i, "PALADIN_%d" % i)


func is_named(i: int) -> bool:
	return not paladin(i).begins_with("PALADIN_")


## Keeps or drops each "[...]" clause (see the class note).
func _clauses(raw: String) -> String:
	var out := ""
	var at := 0
	while true:
		var open := raw.find("[", at)
		var close := raw.find("]", open + 1) if open >= 0 else -1
		if close < 0:
			return out + raw.substr(at)
		out += raw.substr(at, open - at)
		var clause := raw.substr(open + 1, close - open - 1)
		var keep := true
		for i in range(1, 5):
			if clause.contains("{P%d}" % i) and not is_named(i):
				keep = false
		if keep:
			out += clause
		at = close + 1
	return out
