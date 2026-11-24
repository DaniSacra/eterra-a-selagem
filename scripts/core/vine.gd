class_name Vine
extends RefCounted
## A Videira (Daniel 2026-11-23; it replaced the account's tree "O Preparo"), pure: 3 branches of 3 nodes, no damage, small
## permanent improvements for every hero, bought with Prata Antiga (Vida, Perseverança) or Fragmento de Memória (Provisão).
## Kept in the save (data.vine.bought: ids). A descent sums the owned nodes into BoonState.stat (Game._equip_vine);
## the rooms read the stats (RunMap's merchant, the shop's stock, the purse's bonus). Pure logic.
##
## API for the screen (V2):
##   var vine := Vine.new(Vine.load_catalog())
##   vine.branches() -> Array[StringName]                 the branches in screen order (Vine.BRANCHES)
##   vine.nodes_of(branch) -> Array[VineNode]             the nodes of a branch in purchase order (step 1 to 3)
##   vine.state(data, id) -> Vine.State                   OWNED, AVAILABLE (can be bought now), SHORT (its turn, not enough
##                                                        material) or LOCKED (a node before it in the branch is not bought)
##   vine.balance(data, id) -> int                        what the save holds of the node's material
##   node.cost, node.material, node.name_key, node.desc_key (T.t), node.step
##   vine.buy(data, id) -> bool                           spends and keeps (the caller writes the save: Save.write());
##                                                        false when not AVAILABLE; emits `bought(id)` on success
##   vine.bought_count(data) -> int; vine.owned(data); Vine.open(data) -> bool (the station shows)
##   signal bought(id)
##   vine.first(n) -> the ids the robot "has bought" (--vine=N, also --account=N), step by step across the branches.

signal bought(id: StringName)

enum Problem { OK, OWNED, NEEDS, SHORT, UNKNOWN }
enum State { OWNED, AVAILABLE, SHORT, LOCKED }

const DIR := "res://data/vine/"
const BRANCHES: Array[StringName] = [&"vida", &"provisao", &"perseveranca"]

var catalog: Array[VineNode] = []


func _init(nodes: Array[VineNode] = []) -> void:
	catalog = nodes


static func load_catalog(dir: String = DIR) -> Array[VineNode]:
	var out: Array[VineNode] = []
	if not DirAccess.dir_exists_absolute(dir):
		return out
	var files := DirAccess.get_files_at(dir)
	files.sort()
	for file in files:
		var path := file.trim_suffix(".remap")
		if path.ends_with(".tres"):
			out.append(load(dir.path_join(path)))
	return out


static func defaults() -> Dictionary:
	return {"bought": []}


## The vine block of the save (made when missing).
static func block(data: Dictionary) -> Dictionary:
	if not data.get("vine") is Dictionary:
		data["vine"] = defaults()
	var b: Dictionary = data["vine"]
	if not b.get("bought") is Array:
		b["bought"] = []
	return b


static func bought_ids(data: Dictionary) -> Array:
	return block(data)["bought"]


## Whether the station (V2: its own, east of the Santuário) shows: after the Forja (first guardian or a Temperar) or once anything was bought.
static func open(data: Dictionary) -> bool:
	if not bought_ids(data).is_empty() or Forge.temper(data) > 0:
		return true
	return int((SaveData.hero(data, SaveData.FIRST_HERO).get("firsts", {}) as Dictionary).get("guardian", 0)) > 0


## V2: how many nodes of each branch are bought ({vida: 2, provisao: 0, perseveranca: 3}), what the station's planting
## shows (VineStation.grown, V3). Static: the hub asks it with the save alone.
static func growth(data: Dictionary) -> Dictionary:
	var v := Vine.new(load_catalog())
	var out := {}
	for branch in BRANCHES:
		out[branch] = v.nodes_of(branch).filter(func(n: VineNode) -> bool: return v.owns(data, n.id)).size()
	return out


func branches() -> Array[StringName]:
	return BRANCHES


func nodes_of(branch: StringName) -> Array[VineNode]:
	var out: Array[VineNode] = []
	for n in catalog:
		if n.branch == branch:
			out.append(n)
	out.sort_custom(func(a: VineNode, b: VineNode) -> bool: return a.step < b.step)
	return out


func find(id: StringName) -> VineNode:
	for n in catalog:
		if n.id == id:
			return n
	return null


func owns(data: Dictionary, id: StringName) -> bool:
	return bought_ids(data).has(String(id))


func owned(data: Dictionary) -> Array[VineNode]:
	var out: Array[VineNode] = []
	for n in catalog:
		if owns(data, n.id):
			out.append(n)
	return out


func bought_count(data: Dictionary) -> int:
	return owned(data).size()


func balance(data: Dictionary, id: StringName) -> int:
	var n := find(id)
	return 0 if n == null else MaterialPurse.amount(data, n.material)


func problem(data: Dictionary, id: StringName) -> Problem:
	var n := find(id)
	if n == null:
		return Problem.UNKNOWN
	if owns(data, id):
		return Problem.OWNED
	if n.requires != &"" and not owns(data, n.requires):
		return Problem.NEEDS
	if not MaterialPurse.can_pay(data, n.material, n.cost):
		return Problem.SHORT
	return Problem.OK


func state(data: Dictionary, id: StringName) -> State:
	match problem(data, id):
		Problem.OWNED:
			return State.OWNED
		Problem.OK:
			return State.AVAILABLE
		Problem.SHORT:
			return State.SHORT
	return State.LOCKED


func buy(data: Dictionary, id: StringName) -> bool:
	if problem(data, id) != Problem.OK:
		return false
	var n := find(id)
	if not MaterialPurse.spend(data, n.material, n.cost):
		return false
	bought_ids(data).append(String(id))
	bought.emit(id)
	return true


## The max life the branch gives up to and with this root (0 when it gives none): the screen's second line. Read from
## the mods, so a data change shows by itself.
## The maximum life this one node gives by itself.
static func own_life(n: VineNode) -> int:
	var total := 0.0
	for mod in n.mods:
		if mod.stat == &"max_hp":
			total += mod.base
	return int(total)


func life_total(id: StringName) -> int:
	var n := find(id)
	if n == null:
		return 0
	var total := 0.0
	for m in nodes_of(n.branch):
		if m.step <= n.step:
			for mod in m.mods:
				if mod.stat == &"max_hp":
					total += mod.base
	return int(total)


## What is still missing to pay the node (0 when nothing is).
func missing(data: Dictionary, id: StringName) -> int:
	var n := find(id)
	return 0 if n == null else maxi(n.cost - MaterialPurse.amount(data, n.material), 0)


## Every mod of the owned nodes (BoonState.grant).
func mods_of(ids: Array) -> Array[BoonMod]:
	var out: Array[BoonMod] = []
	for n in catalog:
		if ids.has(String(n.id)) or ids.has(n.id):
			out.append_array(n.mods)
	return out


## The first n nodes a robot "has bought" (--vine=N): step 1 of every branch, then step 2, then step 3 (requirements before).
func first(n: int) -> Array[StringName]:
	var out: Array[StringName] = []
	for step in range(1, 4):
		for branch in BRANCHES:
			for node in nodes_of(branch):
				if node.step == step and out.size() < n:
					out.append(node.id)
	return out
