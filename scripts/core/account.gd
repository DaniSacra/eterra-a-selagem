class_name Account
extends RefCounted
## The account's tree "O Preparo" (Daniel 2026-11-21), pure: small permanent improvements for every hero, bought with the
## materials already in the game (Prata Antiga, Fragmento de Memória), kept in the save (data.account.bought: ids).
## A descent sums the owned nodes into BoonState.stat (Game._equip_account); nothing else reads the save.
##   var tree := Account.new(Account.load_catalog())
##   tree.problem(data, id) -> Problem; tree.buy(data, id) -> bool (spends, keeps; the caller writes the save)
##   tree.owned(data) -> Array[AccountNode]; Account.open(data) -> bool (the station branch shows)
##   tree.first(n) -> the ids of the first n nodes the robot buys (--account=N), in price order, requirements kept.

enum Problem { OK, OWNED, NEEDS, SHORT, UNKNOWN }

const DIR := "res://data/account/"
## The Forja's door opens the Fonte: the first guardian beaten, a Temperar bought or any node already owned.
const REVIVE_HP := 0.4
const BRANCHES: Array[StringName] = [&"vida", &"cura", &"ouro", &"bencao", &"forca"]

var catalog: Array[AccountNode] = []


func _init(nodes: Array[AccountNode] = []) -> void:
	catalog = nodes


static func load_catalog(dir: String = DIR) -> Array[AccountNode]:
	var out: Array[AccountNode] = []
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


## The account block of the save (made when missing).
static func block(data: Dictionary) -> Dictionary:
	if not data.get("account") is Dictionary:
		data["account"] = defaults()
	var b: Dictionary = data["account"]
	if not b.get("bought") is Array:
		b["bought"] = []
	return b


static func bought(data: Dictionary) -> Array:
	return block(data)["bought"]


## Whether the Fonte shows at the Forjador: after the Forja (first guardian or a Temperar) or once anything was bought.
static func open(data: Dictionary) -> bool:
	if not bought(data).is_empty() or Forge.temper(data) > 0:
		return true
	return int((SaveData.hero(data, SaveData.FIRST_HERO).get("firsts", {}) as Dictionary).get("guardian", 0)) > 0


func find(id: StringName) -> AccountNode:
	for n in catalog:
		if n.id == id:
			return n
	return null


func owns(data: Dictionary, id: StringName) -> bool:
	return bought(data).has(String(id))


func owned(data: Dictionary) -> Array[AccountNode]:
	var out: Array[AccountNode] = []
	for n in catalog:
		if owns(data, n.id):
			out.append(n)
	return out


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


func buy(data: Dictionary, id: StringName) -> bool:
	if problem(data, id) != Problem.OK:
		return false
	var n := find(id)
	if not MaterialPurse.spend(data, n.material, n.cost):
		return false
	bought(data).append(String(id))
	return true


## Every mod of the owned nodes (BoonState.grant).
func mods_of(ids: Array) -> Array[BoonMod]:
	var out: Array[BoonMod] = []
	for n in catalog:
		if ids.has(String(n.id)) or ids.has(n.id):
			out.append_array(n.mods)
	return out


## The first n nodes a robot "has bought" (--account=N): the catalog's order (cheap first, requirements before).
func first(n: int) -> Array[StringName]:
	var out: Array[StringName] = []
	for node in catalog:
		if out.size() >= n:
			break
		out.append(node.id)
	return out


## The rarity chances with the account's bonus (Coração Atento): the first step of the draw gains all of it and the second half.
static func better(chances: Array[float], bonus: float) -> Array[float]:
	if bonus <= 0.0:
		return chances
	var out: Array[float] = chances.duplicate()
	out[0] = minf(1.0, out[0] + bonus)
	if out.size() > 1:
		out[1] = minf(1.0, out[1] + bonus * 0.5)
	return out
