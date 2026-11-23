class_name Encounter
extends RefCounted
## The meeting with two angels in a room of a Blessing (Rejogabilidade, Fatia 1; sistemas.md 1.6, the Sworn the PO
## asked for), pure. Two angels are drawn among those with three cards valid for the hand (eligible); the one
## chosen offers up to three Blessings of its family by BoonState.draw with today's rules (rarity in sequence, trade,
## an Elo that involves its family, the Psalm filled by Game as before). Fallbacks: one angel eligible, only it comes
## ("Só um anjo atende"); none, the rest card of today (Fôlego). An angel is met only with three cards for the hand (CARDS).
## Never an invalid card.
##
## Dice: every room draws its pair on dice of its own (Encounters.dice: the run's seed, SALT and the room's node), and
## the cards of each angel on dice of their own too (cards_dice: the same plus the angel's id), so the same seed gives
## the same pairs and the same cards whatever the run drew before, and looking at one angel never rerolls the other.
##
## API for the UI (the Encounter screen; game side in Encounters):
##   Encounter.new(Encounter.load_catalog()).pair(state, rng, forced) -> Array[AngelDef] (0, 1 or 2).
##   Encounter.belongs(state, boon, family) -> bool: the boon is the family's (an Elo when one of its lists is).
##   Encounter.affinity(state, angels) -> AngelDef: the one whose family the hand holds most (the robot's pick).

const DIR := "res://data/angels/"
## The angels met in a room.
const SIZE := 2
## The run's seed is salted with this for the pairs (as Rooms.MAP_SALT for the map).
const SALT := 9241

var catalog: Array[AngelDef] = []


func _init(angels: Array[AngelDef] = []) -> void:
	catalog = angels


static func load_catalog(dir: String = DIR) -> Array[AngelDef]:
	var out: Array[AngelDef] = []
	if not DirAccess.dir_exists_absolute(dir):
		return out
	var files := DirAccess.get_files_at(dir)
	files.sort()
	for file in files:
		var path := file.trim_suffix(".remap")
		if path.ends_with(".tres"):
			out.append(load(dir.path_join(path)))
	return out


func find(id: StringName) -> AngelDef:
	for a in catalog:
		if a.id == id:
			return a
	return null


## The dice of a room's pair: the run's seed, SALT and the room (its node; a room of no graph by its depth).
static func dice(run_seed: int, node: int, depth: int) -> RandomNumberGenerator:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash([run_seed, SALT, node, depth])
	return rng


## The dice of one angel's cards in that room.
static func cards_dice(run_seed: int, node: int, depth: int, angel: StringName) -> RandomNumberGenerator:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash([run_seed, SALT, node, depth, String(angel)])
	return rng


## True when a Blessing is the family's: its own family, or an Elo with one of its lists of that family.
static func belongs(state: BoonState, b: Boon, family: Boon.Family) -> bool:
	if not b.is_duo():
		return b.family == family
	for list in b.requires_sets:
		for id in list:
			var s := state.find(StringName(id))
			if s != null and s.family == family:
				return true
	return false


## BO-2: how many cards an angel must be able to put on the table to be met (six Blessings a family, one held for each
## button: the second meeting still shows three).
const CARDS := 3


## How many cards the angel could offer the hand: a Blessing not held and offerable (fresh, a trade or an Elo that can be
## formed now), and, to fill the hand, a Blessing of its family held that can still grow (one level more).
static func supply(state: BoonState, angel: AngelDef) -> int:
	var n := 0
	for b in state.catalog:
		if not belongs(state, b, angel.family):
			continue
		if state.level(b.id) <= 0:
			if state.offerable(b):
				n += 1
		elif state.can_offer(b) and not b.reserve:
			n += 1
	return n


## True when the angel has CARDS cards for the hand (supply).
static func eligible(state: BoonState, angel: AngelDef) -> bool:
	return supply(state, angel) >= CARDS


## The angels met: SIZE different ones drawn among the eligible (all shuffled on rng, the first eligible kept), the
## forced ones first (--angels; an ineligible forced one is skipped). Fewer when fewer are eligible.
func pair(state: BoonState, rng: RandomNumberGenerator, forced: Array = []) -> Array[AngelDef]:
	var order: Array[AngelDef] = catalog.duplicate()
	for i in range(order.size() - 1, 0, -1):
		var j := rng.randi() % (i + 1)
		var t := order[i]
		order[i] = order[j]
		order[j] = t
	var out: Array[AngelDef] = []
	for id: Variant in forced:
		var a := find(StringName(id))
		if a != null and not out.has(a) and eligible(state, a) and out.size() < SIZE:
			out.append(a)
	for a in order:
		if out.size() >= SIZE:
			break
		if not out.has(a) and eligible(state, a):
			out.append(a)
	return out


## The angel's cards: BoonState.draw over its family only, with the stage's chances; short of n, the rest are one level
## more of a Blessing of the family already held (BO-2: three cards always, as eligible promises).
static func cards(state: BoonState, angel: AngelDef, rng: RandomNumberGenerator, n: int = 3,
		chances: Array[float] = Boon.RARITY_CHANCE, elo_chance: float = Boon.ELO_CHANCE,
		trade_chance: float = Boon.TRADE_CHANCE) -> Array[BoonState.Card]:
	var out := state.draw(rng, n, chances, elo_chance, trade_chance,
		func(b: Boon) -> bool: return belongs(state, b, angel.family))
	if out.size() < n:
		var held: Array[Boon] = []
		for b in state.owned():
			if belongs(state, b, angel.family) and state.can_offer(b) and not b.reserve:
				held.append(b)
		while out.size() < n and not held.is_empty():
			var b: Boon = held.pop_at(rng.randi() % held.size())
			var c := BoonState.Card.new(b, state.rarity(b.id), state.level(b.id) + 1)
			c.grow = true
			out.append(c)
	return out


## The angel whose family the hand holds most (Blessings held of it, an Elo counting for both of its families); the
## first of the list on a tie. null for none.
static func affinity(state: BoonState, angels: Array) -> AngelDef:
	var best: AngelDef = null
	var most := -1
	for a: AngelDef in angels:
		var n := 0
		for b in state.owned():
			if belongs(state, b, a.family):
				n += 1
		if n > most:
			most = n
			best = a
	return best
