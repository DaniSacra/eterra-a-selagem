class_name Forge
extends RefCounted
## The rules of the Forja da Emeth, pure (Rejogabilidade, Fatia 1; sistemas.md 1.5): the ranks (ForgeRank) bought with
## Prata in the hub, in order on their track (Temperar II needs Temperar I), kept in the hero's block of the save
## (heroes.<id>.forge.temper: the highest temper rank bought). A descent sums the ranks owned (ranks) into
## BoonState.stat (BoonState.equip_forge, Game._equip_forge).
##
## API for the UI (the Forjador's page; the provisional one is Hub._open_forge):
##   var forge := Forge.new(Forge.load_catalog())
##   forge.track(&"temper") -> Array[ForgeRank]: the track's ranks in order.
##   forge.state(data, rank) -> State: OWNED, NEXT (the one to buy now), LOCKED (an earlier rank first).
##   forge.problem(data, rank) -> Problem: OK (can buy now), OWNED, NEEDS (an earlier rank first), SHORT (not enough
##     of its material: MaterialPurse.amount(data, rank.material) < rank.cost).
##   forge.buy(data, rank.id) -> bool: spends and keeps it (false: problem() was not OK; nothing changed). The caller
##     writes the save (Save.write).
##   forge.owned(data) -> Array[ForgeRank]; Forge.temper(data) -> int.
##   Fatia 2, Refinar (track refine: choices, one on each action, free to change, sistemas.md 1.5):
##   forge.track(Forge.REFINE) -> all the choices; forge.refine_options(&"attack") -> those of an action.
##   forge.problem(data, r): NO_TOOL until the Forjador's first tool was found (Forge.has_tool(data, Forge.TOOL_REFINE));
##     OWNED once bought (state OWNED; then forge.is_on(data, r) says whether it is the one on its action).
##   forge.buy(data, id) spends and, when its action has none on, puts it on; forge.put_on(data, id) changes the one on
##     an action (free, only one bought); forge.take_off(data, slot). forge.ranks_for(data) is what a descent carries.
##   Fatia 3: forge.track(Forge.AWAKEN) (Despertar, Esmeralda, one awake: forge.awake(data), put_on, take_off(data,
##     Forge.AWAKEN)) and forge.track(Forge.INSCRIBE) (an Encanto learned: the rank's id is the Encanto's, kept in
##     forge.inscribed); problem() NO_TOOL until Forge.TOOL_AWAKEN / TOOL_INSCRIBE were found.
##   Tools (achados): Forge.has_tool(data, id), Forge.TOOLS (ids in the order they are found), text keys tool_<id>.

enum State { OWNED, NEXT, LOCKED }
enum Problem { OK, OWNED, NEEDS, SHORT, UNKNOWN, NO_TOOL }

const DIR := "res://data/forge/emeth/"
const TEMPER := &"temper"
const REFINE := &"refine"
## The Forjador's lost tools (Q-RJ9 a: found at a first time): the first, at the first guardian won, opens the Refinar
## (Fatia 2); the others (the first phase 3 of Morvath, the first Provação won) open Despertar and Inscrever (Fatia 3).
const TOOL_REFINE := &"tool_refine"
## Fatia 3 (sistemas.md 1.5): Despertar, one new property of the blade at a time, bought with Esmeralda and opened by
## the second tool (the first phase 3 of Morvath reached); Inscrever, an Encanto learned (it may come in the descents
## from then on, Enchants.learned), 20 Prata each, opened by the third (the first Provação won). Working names.
const AWAKEN := &"awaken"
const INSCRIBE := &"inscribe"
const TOOL_AWAKEN := &"tool_awaken"
const TOOL_INSCRIBE := &"tool_inscribe"
const TOOLS: Array[StringName] = [TOOL_REFINE, TOOL_AWAKEN, TOOL_INSCRIBE]
## The tracks of choices (bought one by one, each kept in its list of the forge block), and the list of each.
const CHOICE_TRACKS: Array[StringName] = [REFINE, AWAKEN, INSCRIBE]
const LIST_KEY := {&"refine": "refined", &"awaken": "awakened", &"inscribe": "inscribed"}

var catalog: Array[ForgeRank] = []


func _init(ranks: Array[ForgeRank] = []) -> void:
	catalog = ranks


static func load_catalog(dir: String = DIR) -> Array[ForgeRank]:
	var out: Array[ForgeRank] = []
	if not DirAccess.dir_exists_absolute(dir):
		return out
	var files := DirAccess.get_files_at(dir)
	files.sort()
	for file in files:
		var path := file.trim_suffix(".remap")
		if path.ends_with(".tres"):
			out.append(load(dir.path_join(path)))
	return out


func find(id: StringName) -> ForgeRank:
	for r in catalog:
		if r.id == id:
			return r
	return null


## A track's ranks in order (rank 1 first).
func track(name: StringName) -> Array[ForgeRank]:
	var out: Array[ForgeRank] = []
	out.assign(catalog.filter(func(r: ForgeRank) -> bool: return r.track == name))
	out.sort_custom(func(a: ForgeRank, b: ForgeRank) -> bool: return a.rank < b.rank)
	return out


## The hero's forge block (made when missing): {temper, refine, awaken, inscribed}.
static func block(data: Dictionary, hero_id := SaveData.FIRST_HERO) -> Dictionary:
	var hero := SaveData.hero(data, hero_id)
	if not hero.get("forge") is Dictionary:
		hero["forge"] = SaveData.forge_defaults()
	return hero.forge


## The highest rank of a track the save holds (0: none). (The refine track holds choices: its rank is the count bought.)
static func rank_of(data: Dictionary, name: StringName, hero_id := SaveData.FIRST_HERO) -> int:
	if CHOICE_TRACKS.has(name):
		return (block(data, hero_id).get(LIST_KEY[name], []) as Array).size()
	return int(block(data, hero_id).get(String(name), 0))


## True when the hero found that tool (heroes.<id>.tools).
static func has_tool(data: Dictionary, tool: StringName, hero_id := SaveData.FIRST_HERO) -> bool:
	return (SaveData.hero(data, hero_id).get("tools", []) as Array).has(String(tool))


## Keeps a tool found (once). True when it was new.
static func add_tool(data: Dictionary, tool: StringName, hero_id := SaveData.FIRST_HERO) -> bool:
	var hero := SaveData.hero(data, hero_id)
	if not hero.get("tools") is Array:
		hero["tools"] = []
	if (hero.tools as Array).has(String(tool)):
		return false
	(hero.tools as Array).append(String(tool))
	return true


static func temper(data: Dictionary, hero_id := SaveData.FIRST_HERO) -> int:
	return rank_of(data, TEMPER, hero_id)


## The ranks of the temper track up to n (what a descent with Temperar n carries).
func up_to(n: int) -> Array[ForgeRank]:
	var out: Array[ForgeRank] = []
	out.assign(track(TEMPER).filter(func(r: ForgeRank) -> bool: return r.rank <= n))
	return out


func owned(data: Dictionary, hero_id := SaveData.FIRST_HERO) -> Array[ForgeRank]:
	var out: Array[ForgeRank] = []
	out.assign(catalog.filter(func(r: ForgeRank) -> bool:
		return _bought(data, r, hero_id) if CHOICE_TRACKS.has(r.track) else r.rank <= rank_of(data, r.track, hero_id)))
	return out


## The Refinar choices of an action (Fatia 2), in the order of the data.
func refine_options(slot: StringName) -> Array[ForgeRank]:
	var out: Array[ForgeRank] = []
	out.assign(catalog.filter(func(r: ForgeRank) -> bool: return r.track == REFINE and r.slot == slot))
	return out


## The actions the Refinar has choices for.
func refine_slots() -> Array[StringName]:
	var out: Array[StringName] = []
	for r in track(REFINE):
		if not out.has(r.slot):
			out.append(r.slot)
	return out


func _bought(data: Dictionary, r: ForgeRank, hero_id := SaveData.FIRST_HERO) -> bool:
	return CHOICE_TRACKS.has(r.track) and (block(data, hero_id).get(LIST_KEY[r.track], []) as Array).has(String(r.id))


## True when this Refinar is the one on its action (a Despertar: the one awake; an inscribed Encanto: always).
func is_on(data: Dictionary, r: ForgeRank, hero_id := SaveData.FIRST_HERO) -> bool:
	if r == null:
		return false
	if r.track == AWAKEN:
		return String(block(data, hero_id).get("awaken", "")) == String(r.id)
	if r.track == INSCRIBE:
		return _bought(data, r, hero_id)
	return String((block(data, hero_id).get("refine", {}) as Dictionary).get(String(r.slot), "")) == String(r.id)


## The Despertar awake (null: none).
func awake(data: Dictionary, hero_id := SaveData.FIRST_HERO) -> ForgeRank:
	var id := String(block(data, hero_id).get("awaken", ""))
	return find(StringName(id)) if id != "" else null


## Puts a Refinar bought on its action, or a Despertar bought awake (free; the one there before comes off). False when
## not bought.
func put_on(data: Dictionary, id: StringName, hero_id := SaveData.FIRST_HERO) -> bool:
	var r := find(id)
	if r == null or (r.track != REFINE and r.track != AWAKEN) or not _bought(data, r, hero_id):
		return false
	var b := block(data, hero_id)
	if r.track == AWAKEN:
		b["awaken"] = String(r.id)
		return true
	if not b.get("refine") is Dictionary:
		b["refine"] = {}
	(b.refine as Dictionary)[String(r.slot)] = String(r.id)
	return true


## Takes the Refinar off an action (Forge.AWAKEN: puts the Despertar to sleep).
func take_off(data: Dictionary, slot: StringName, hero_id := SaveData.FIRST_HERO) -> void:
	var b := block(data, hero_id)
	if slot == AWAKEN:
		b["awaken"] = ""
		return
	if b.get("refine") is Dictionary:
		(b.refine as Dictionary).erase(String(slot))


## The Refinar on each action (bought ones only).
func refines_on(data: Dictionary, hero_id := SaveData.FIRST_HERO) -> Array[ForgeRank]:
	var out: Array[ForgeRank] = []
	for r in track(REFINE):
		if _bought(data, r, hero_id) and is_on(data, r, hero_id):
			out.append(r)
	return out


## What a descent carries: the Temperar up to the one bought, the Refinar on and the Despertar awake.
func ranks_for(data: Dictionary, hero_id := SaveData.FIRST_HERO) -> Array[ForgeRank]:
	var out := up_to(temper(data, hero_id))
	out.append_array(refines_on(data, hero_id))
	var a := awake(data, hero_id)
	if a != null:
		out.append(a)
	return out


func state(data: Dictionary, r: ForgeRank, hero_id := SaveData.FIRST_HERO) -> State:
	if CHOICE_TRACKS.has(r.track):
		return State.OWNED if _bought(data, r, hero_id) else State.NEXT if has_tool(data, r.tool, hero_id) else State.LOCKED
	var have := rank_of(data, r.track, hero_id)
	if r.rank <= have:
		return State.OWNED
	return State.NEXT if r.rank == have + 1 else State.LOCKED


func problem(data: Dictionary, r: ForgeRank, hero_id := SaveData.FIRST_HERO) -> Problem:
	if r == null:
		return Problem.UNKNOWN
	if CHOICE_TRACKS.has(r.track):
		if _bought(data, r, hero_id):
			return Problem.OWNED
		if r.tool != &"" and not has_tool(data, r.tool, hero_id):
			return Problem.NO_TOOL
		return Problem.OK if MaterialPurse.can_pay(data, r.material, r.cost) else Problem.SHORT
	match state(data, r, hero_id):
		State.OWNED:
			return Problem.OWNED
		State.LOCKED:
			return Problem.NEEDS
	return Problem.OK if MaterialPurse.can_pay(data, r.material, r.cost) else Problem.SHORT


## Buys a rank: spends its material and keeps it. False when problem() is not OK (nothing changes).
func buy(data: Dictionary, id: StringName, hero_id := SaveData.FIRST_HERO) -> bool:
	var r := find(id)
	if problem(data, r, hero_id) != Problem.OK or not MaterialPurse.spend(data, r.material, r.cost):
		return false
	var b := block(data, hero_id)
	if CHOICE_TRACKS.has(r.track):
		var key: String = LIST_KEY[r.track]
		if not b.get(key) is Array:
			b[key] = []
		(b[key] as Array).append(String(r.id))
		if r.track == REFINE and (not b.get("refine") is Dictionary or not (b.refine as Dictionary).has(String(r.slot))):
			put_on(data, r.id, hero_id)
		elif r.track == AWAKEN and String(b.get("awaken", "")) == "":
			put_on(data, r.id, hero_id)
		return true
	b[String(r.track)] = r.rank
	return true
