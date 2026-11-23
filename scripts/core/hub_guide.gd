class_name HubGuide
extends RefCounted
## PT-5: the guide of what is new in the Santuário, pure. The first time the player enters it with something just
## unlocked (a station opened, the Preparo, the Juramentos), the camera comes close to the place and says what to do
## (HubGuideOverlay); once per save: `data.hub.guided` keeps the ids shown (a save older than version 11 counts the
## due ones as shown, SaveData.merged). The list is data (data/hub_guide/*.tres, HubGuideDef).
##   HubGuide.pending(Save.data) -> the due guides not shown yet, in order
##   HubGuide.mark_shown(Save.data, ids)
## Nothing for the robot, a smoke run or --nosave; --guide=<id>|all forces them (captures; not written).

const DIR := "res://data/hub_guide/"
const CONDITIONS: Array[StringName] = [&"open", &"always", &"wins", &"account"]

static var _catalog: Array[HubGuideDef] = []


static func load_catalog(dir: String = DIR) -> Array[HubGuideDef]:
	var out: Array[HubGuideDef] = []
	if not DirAccess.dir_exists_absolute(dir):
		return out
	var files := DirAccess.get_files_at(dir)
	files.sort()
	for file in files:
		var path := file.trim_suffix(".remap")
		if path.ends_with(".tres"):
			out.append(load(dir + path))
	out.sort_custom(func(a: HubGuideDef, b: HubGuideDef) -> bool: return a.order < b.order)
	return out


static func catalog() -> Array[HubGuideDef]:
	if _catalog.is_empty():
		_catalog = load_catalog()
	return _catalog


## Whether a guide's condition holds in this save.
static func due(data: Dictionary, def: HubGuideDef) -> bool:
	match def.condition:
		&"open":
			return HubGate.is_open(data, def.station)
		&"always":
			return true
		&"wins":
			return Juramentos.unlocked(data)
		&"account":
			return Account.open(data)
	return false


static func shown(data: Dictionary) -> Array:
	if not data.get("hub") is Dictionary:
		data["hub"] = SaveData.hub_defaults()
	var h: Dictionary = data["hub"]
	if not h.get("guided") is Array:
		h["guided"] = []
	return h["guided"]


## The due guides not shown yet, in order.
static func pending(data: Dictionary, defs: Array[HubGuideDef] = catalog()) -> Array[HubGuideDef]:
	var out: Array[HubGuideDef] = []
	var done := shown(data)
	for d in defs:
		if due(data, d) and not done.has(String(d.id)):
			out.append(d)
	return out


static func mark_shown(data: Dictionary, ids: Array) -> void:
	var done := shown(data)
	for id: Variant in ids:
		if not done.has(String(id)):
			done.append(String(id))


## Whether the guide may open here: not for the robot, a smoke run, --nosave, a placed hero (--hero-at) or
## --hub-open=all, unless --guide asks for one.
static func enabled() -> bool:
	if Dev.has("guide"):
		return true
	for k in ["bot", "smoke", "nosave", "hero-at"]:
		if Dev.has(k):
			return false
	return Dev.arg("hub-open") != "all"


## What to show now: the forced one (--guide=<id>|all, not written) or the pending of the save; empty when off.
static func to_show(data: Dictionary) -> Array[HubGuideDef]:
	var out: Array[HubGuideDef] = []
	if Dev.has("guide"):
		for d in catalog():
			if Dev.arg("guide") == "all" or String(d.id) == Dev.arg("guide"):
				out.append(d)
		return out
	if enabled():
		out = pending(data)
	return out
