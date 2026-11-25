class_name Milestones
extends RefCounted
## SW-O5: the Santuário opens one thing per milestone (D-O1 a: one station per milestone, the Ultimate after 6 descents).
## Pure, read from the save. The table is data (MilestoneDef, data/milestones/); defaults() is the same table for when the
## folder is not at hand. Nothing here closes what a save already has: HubGate keeps open what was presented or used, and
## grandfather() marks what an older save had under the old rules.
##   Milestones.reached(data) -> the ids reached, in order        Milestones.open(data, id) -> bool
##   Milestones.ult_open(data) -> the Ultimate may be played      Milestones.next_to_present(data) -> &"" or one id to show
##   Milestones.opens_of(id) -> the station (or &"ult") a milestone opens, for_station(opens) -> its milestone

const DIR := "res://data/milestones/"
const NEEDS: Array[StringName] = [&"first", &"guardian", &"win", &"stone", &"mastery2"]
## What the Ultimate opens as in `hub.presented` (it is not a station).
const ULT := &"ult"
## The Mastery level the Ultimate asks for (D-O1 a).
const ULT_MASTERY := 2

static var _catalog: Array[MilestoneDef] = []


static func load_catalog(dir: String = DIR) -> Array[MilestoneDef]:
	var out: Array[MilestoneDef] = []
	if DirAccess.dir_exists_absolute(dir):
		var files := DirAccess.get_files_at(dir)
		files.sort()
		for file in files:
			var path := file.trim_suffix(".remap")
			if path.ends_with(".tres"):
				out.append(load(dir + path))
	if out.is_empty():
		out = defaults()
	out.sort_custom(func(a: MilestoneDef, b: MilestoneDef) -> bool: return a.order < b.order)
	return out


static func catalog() -> Array[MilestoneDef]:
	if _catalog.is_empty():
		_catalog = load_catalog()
	return _catalog


static func _def(order: int, id: StringName, opens: StringName, runs_min: int, needs: Array[StringName], any_of := false) -> MilestoneDef:
	var d := MilestoneDef.new()
	d.order = order
	d.id = id
	d.opens = opens
	d.runs_min = runs_min
	d.needs = needs
	d.any_of = any_of
	return d


## The table of the design document, as data: what tools/make_data.gd `milestones` writes.
static func defaults() -> Array[MilestoneDef]:
	return [
		_def(0, &"tree", HubPlan.TREE, 0, [&"first"]),
		_def(1, &"forge", HubPlan.SMITH, 3, [&"guardian"], true),
		_def(2, &"book", HubPlan.BOOK, 3, []),
		_def(3, &"account", HubPlan.VINE, 4, []),
		_def(4, &"vendor", HubPlan.VENDOR, 5, [&"stone"], true),
		_def(5, &"ult", ULT, 6, [&"mastery2"]),
		_def(6, &"maga", HubPlan.HEROES, 0, [&"win"]),
	]


## Whether the save meets one thing a milestone asks for.
static func met(data: Dictionary, need: StringName) -> bool:
	match need:
		&"first":
			# the first descent done or skipped (first 1 or 2); a save that already played one (runs > 0) counts it done
			return int(data.get("first", 0)) >= 1 or int(data.get("runs", 0)) >= 1
		&"guardian":
			# firsts.guardian is not written by the first descent (it must not open the Forja); guardian_run is the
			# one of a descent that counts
			var firsts := SaveData.hero(data, SaveData.FIRST_HERO).get("firsts", {}) as Dictionary
			return int(firsts.get("guardian", 0)) > 0 or int(firsts.get("guardian_run", 0)) > 0
		&"win":
			return Juramentos.unlocked(data)
		&"stone":
			return HubGate.used(data, HubPlan.VENDOR)  # the first Pedra Funda, an order or a recipe
		&"mastery2":
			return mastery_level(data) >= ULT_MASTERY
	return false


static func reached_def(data: Dictionary, d: MilestoneDef) -> bool:
	var checks: Array[bool] = []
	if d.runs_min > 0:
		checks.append(int(data.get("runs", 0)) >= d.runs_min)
	for n in d.needs:
		checks.append(met(data, n))
	if checks.is_empty():
		return true
	return checks.any(func(b: bool) -> bool: return b) if d.any_of else checks.all(func(b: bool) -> bool: return b)


## The ids of the milestones this save reached, in order.
static func reached(data: Dictionary, defs: Array[MilestoneDef] = catalog()) -> Array[StringName]:
	var out: Array[StringName] = []
	for d in defs:
		if reached_def(data, d):
			out.append(d.id)
	return out


static func open(data: Dictionary, id: StringName, defs: Array[MilestoneDef] = catalog()) -> bool:
	for d in defs:
		if d.id == id:
			return reached_def(data, d)
	return false


## The milestone that opens this station (or &"ult"), null when none does.
static func for_opens(opens: StringName, defs: Array[MilestoneDef] = catalog()) -> MilestoneDef:
	for d in defs:
		if d.opens == opens:
			return d
	return null


## Whether the station (or the Ultimate) was earned by milestone (not by use, not by being shown before).
static func earned(data: Dictionary, opens: StringName, defs: Array[MilestoneDef] = catalog()) -> bool:
	var d := for_opens(opens, defs)
	return d != null and reached_def(data, d)


## The Ultimate may be played: HeroLoadout and the HUD's fifth diamond ask this. Read from the save alone.
static func ult_open(data: Dictionary) -> bool:
	return earned(data, ULT) or HubGate.presented(data).has(String(ULT))


## At most one new thing per visit: the lowest milestone reached whose opening was not shown yet, or &"" when none.
static func next_to_present(data: Dictionary, defs: Array[MilestoneDef] = catalog()) -> StringName:
	var done := HubGate.presented(data)
	for d in defs:
		if reached_def(data, d) and not done.has(String(d.opens)):
			return d.opens
	return &""


## An older save keeps what it had under the old rules: the Ultimate of a Mastery 2 hero (it was open) and the openings
## its milestones reach now, as shown (their guides too). SaveData.merged calls it for a file older than the version that
## brought the milestones.
static func grandfather(data: Dictionary, defs: Array[MilestoneDef] = catalog()) -> void:
	if mastery_level(data) >= ULT_MASTERY:
		HubGate.mark_presented(data, [ULT])
		HubGuide.mark_shown(data, [&"ult"])
	for d in defs:
		if d.opens != ULT and reached_def(data, d):
			HubGate.mark_presented(data, [d.opens])


static func mastery_level(data: Dictionary) -> int:
	return HeroDef.warrior().mastery.level_of(int(SaveData.hero(data, SaveData.FIRST_HERO).get("mastery_xp", 0)))
