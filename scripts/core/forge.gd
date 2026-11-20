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

enum State { OWNED, NEXT, LOCKED }
enum Problem { OK, OWNED, NEEDS, SHORT, UNKNOWN }

const DIR := "res://data/forge/emeth/"
const TEMPER := &"temper"

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


## The highest rank of a track the save holds (0: none).
static func rank_of(data: Dictionary, name: StringName, hero_id := SaveData.FIRST_HERO) -> int:
	return int(block(data, hero_id).get(String(name), 0))


static func temper(data: Dictionary, hero_id := SaveData.FIRST_HERO) -> int:
	return rank_of(data, TEMPER, hero_id)


## The ranks of the temper track up to n (what a descent with Temperar n carries).
func up_to(n: int) -> Array[ForgeRank]:
	var out: Array[ForgeRank] = []
	out.assign(track(TEMPER).filter(func(r: ForgeRank) -> bool: return r.rank <= n))
	return out


func owned(data: Dictionary, hero_id := SaveData.FIRST_HERO) -> Array[ForgeRank]:
	var out: Array[ForgeRank] = []
	out.assign(catalog.filter(func(r: ForgeRank) -> bool: return r.rank <= rank_of(data, r.track, hero_id)))
	return out


func state(data: Dictionary, r: ForgeRank, hero_id := SaveData.FIRST_HERO) -> State:
	var have := rank_of(data, r.track, hero_id)
	if r.rank <= have:
		return State.OWNED
	return State.NEXT if r.rank == have + 1 else State.LOCKED


func problem(data: Dictionary, r: ForgeRank, hero_id := SaveData.FIRST_HERO) -> Problem:
	if r == null:
		return Problem.UNKNOWN
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
	block(data, hero_id)[String(r.track)] = r.rank
	return true
