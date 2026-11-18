class_name RunMap
extends RefCounted
## The way down through one region, room by room, as in the first region of Hades II: an opening fight, rooms whose
## doors show the reward behind them, a guardian halfway, one fountain, the shop, then the boss. Pure logic.

## E5: TRIAL is the Provação's chamber (no door leads there: its slab, Rooms; the depth stays), ALTAR the Altar
## Esquecido (a door, once in a run, no fight).
enum Kind { COMBAT, MINIBOSS, FOUNTAIN, SHOP, BOSS, TRIAL, ALTAR }
## What a room gives when it is cleared (or what the shop sells).
## BOON: a gift (three to choose). POM: one more level for a gift already owned. HEART: more life.
## MAGICK: more Magia. GOLD: gold for the shop. HEAL: life back (shop only). POM_SLICE: one level more for a gift
## drawn among those held, no choice (shop only; Hades II's pom slice).
enum Reward { NONE, BOON, POM, HEART, MAGICK, GOLD, HEAL, POM_SLICE }

const REWARD_KEY: Array[StringName] = [&"", &"reward_boon", &"reward_pom", &"reward_heart", &"reward_magick", &"reward_gold", &"reward_heal", &"reward_pom_slice"]
const KIND_KEY: Array[StringName] = [&"room_combat", &"room_miniboss", &"room_fountain", &"room_shop", &"room_boss", &"room_trial", &"room_altar"]


class Room:
	var kind := Kind.COMBAT
	var reward := Reward.NONE
	var depth := 1
	## Index of its arena in StageDef.layouts (the boss and the shop have their own), and how it is dressed
	## (RoomLayout.variant).
	var layout := 0
	var variant := 0
	## E5, the doors that show the way: its fight drawn before its door opens (Rooms.prepare; null: none, or not yet).
	var fight: EncounterGen.Fight

	## What the door's sign may tell (E5-D8; docs/art/e5_spec.md 7.1): kind and reward (their enums), hard (a fight
	## with an elite), guardian, tier (StageDef.Tier of its fight, -1: no fight), elites (ids), depth. The arena is
	## not on the sign (the surprise stays); the look of the doorway reads it from Rooms.door_info.
	func sign() -> Dictionary:
		var elites: Array[String] = []
		var tier := -1
		if fight != null:
			tier = fight.tier
			for id in fight.kinds:
				if String(id).ends_with("_elite"):
					elites.append(String(id))
		return {"kind": kind, "reward": reward, "depth": depth, "tier": tier, "guardian": kind == Kind.MINIBOSS,
			"hard": kind == Kind.COMBAT and not elites.is_empty(), "elites": elites}

	func _init(k: Kind, r: Reward, d: int, l: int = 0, v: int = 0) -> void:
		kind = k
		reward = r
		depth = d
		layout = l
		variant = v


## A high-difficulty arena (RoomLayout.difficulty 2) is never drawn before this share of the descent.
const HARD_FROM := 0.4


var stage: StageDef
var depth := 0
var miniboss_depth := 0
var fountain_seen := false
var altar_seen := false
## The arena of the room the paladin stands in (-1: none yet), and every arena fought in so far.
var current_layout := -1
var seen_layouts: Array[int] = []
## How many rooms each arena held so far (index in StageDef.layouts; the shop's and the fountain's count too).
var uses: Dictionary = {}
## The doors' rewards come off this deck (C13-02).
var deck: RewardDeck
## Dev (--arena): the opening room is this arena (-1: drawn as any).
var forced_layout := -1
var _rng: RandomNumberGenerator


func _init(stage_def: StageDef, rng: RandomNumberGenerator) -> void:
	stage = stage_def
	_rng = rng
	miniboss_depth = _rng.randi_range(stage.miniboss_depth_min, stage.miniboss_depth_max)
	deck = RewardDeck.new(stage.reward_deck)


## The opening room: a fight that always ends in a gift.
func first() -> Room:
	return _room(Kind.COMBAT, Reward.BOON, 1)


## The rooms behind the doors of the room just cleared. can_pom: some gift owned can still grow.
func options(can_pom: bool) -> Array[Room]:
	var next := depth + 1
	var out: Array[Room] = []
	if next > stage.rooms:
		out.append(Room.new(Kind.BOSS, Reward.NONE, next))
		return out
	if next == stage.rooms:
		out.append(Room.new(Kind.SHOP, Reward.NONE, next, stage.layouts.find(stage.shop_layout)))
		return out
	if next == miniboss_depth:
		out.append(_room(Kind.MINIBOSS, Reward.BOON, next))
		return out
	var doors := 3 if _rng.randf() < stage.three_doors_chance else 2
	if not fountain_seen and next >= stage.fountain_depth_min and next <= stage.fountain_depth_max \
			and (next == stage.fountain_depth_max or _rng.randf() < stage.fountain_chance):
		out.append(_room(Kind.FOUNTAIN, Reward.NONE, next))
	if not altar_seen and out.size() < doors and next >= stage.altar_depth_min and next <= stage.altar_depth_max \
			and stage.altar_layout != null and _rng.randf() < stage.altar_chance:
		altar_seen = true
		out.append(Room.new(Kind.ALTAR, Reward.NONE, next, -1))
	var used: Array[Reward] = []
	while out.size() < doors:
		var r := _reward(used, can_pom)
		used.append(r)
		out.append(_room(Kind.COMBAT, r, next))
	return out


## The paladin goes through a door into this room.
func enter(room: Room) -> void:
	depth = room.depth
	if room.kind == Kind.TRIAL or room.kind == Kind.ALTAR:
		# an event's room: the arena fought in before it stays the one the next fight may not repeat
		return
	if room.kind == Kind.FOUNTAIN:
		fountain_seen = true
	if room.kind == Kind.BOSS:
		current_layout = -1
		return
	if room.layout >= 0:
		uses[room.layout] = int(uses.get(room.layout, 0)) + 1
	if room.kind == Kind.SHOP:
		current_layout = -1
		return
	current_layout = room.layout
	if not seen_layouts.has(room.layout):
		seen_layouts.append(room.layout)


## The fights still sure to come before the boss after a room of this depth (C17, BUG-101): the rooms up to the shop,
## less one for the fountain and one for the altar while either may still take a room (he may choose their doors, so
## they never count). A Provação carried from here never lasts more than this (Trials.offers).
func fights_left(at_depth: int = -1) -> int:
	var from := (depth if at_depth < 0 else at_depth) + 1
	var n := maxi(0, stage.rooms - from)
	if not fountain_seen and stage.fountain_depth_max >= from:
		n -= 1
	if not altar_seen and stage.altar_layout != null and stage.altar_depth_max >= from:
		n -= 1
	return maxi(0, n)


## The Provação's chamber, entered from a room of this depth by its slab: the depth stays (E5).
func trial(at_depth: int) -> Room:
	return Room.new(Kind.TRIAL, Reward.NONE, at_depth, -1)


## The next card of the deck that no other door of this room shows (a pomegranate only when a gift can grow); a
## gift when the deck has nothing that fits even full.
func _reward(used: Array[Reward], can_pom: bool) -> Reward:
	var r := deck.draw(_rng, func(card: int) -> bool:
		return not used.has(card) and (card != Reward.POM or can_pom))
	return Reward.BOON if r < 0 else r as Reward


## A room of this kind at this depth, in an arena drawn for it (_layout) and one of its variants.
func _room(kind: Kind, reward: Reward, at_depth: int) -> Room:
	var l := _layout(kind, at_depth)
	var count := stage.layouts[l].variant_count() if l < stage.layouts.size() else 1
	return Room.new(kind, reward, at_depth, l, _rng.randi() % count)


## The arena of a room (cycle C12): one whose place in the descent (RoomLayout.depth) holds this depth, that may hold
## this kind of room (guardian, fountain), never a high one before HARD_FROM, never the arena of the fight just left
## (a fountain may follow its own), never one already used StageDef.arena_max_uses times (C13-01), the least used
## first (the ones not fought in yet before all).
func _layout(kind: Kind, at_depth: int) -> int:
	if stage.layouts.is_empty():
		return 0
	if forced_layout >= 0 and at_depth == 1:
		return forced_layout
	if kind == Kind.MINIBOSS:
		# the guardian's own room, whatever the depth (E5: the Santuário), unless it was just fought in or used up
		for i in stage.layouts.size():
			if stage.layouts[i].guardian_home and i != current_layout and int(uses.get(i, 0)) < stage.arena_max_uses:
				return i
	var at := EncounterGen.progress(stage, at_depth)
	var found: Array[int] = []
	for i in stage.layouts.size():
		var l := stage.layouts[i]
		if kind == Kind.FOUNTAIN:
			if l.fountain:
				found.append(i)
			continue
		if i == current_layout or (kind == Kind.MINIBOSS and not l.guardian):
			continue
		if at < l.depth.x - 0.001 or at > l.depth.y + 0.001 or (l.difficulty >= 2 and at < HARD_FROM):
			continue
		found.append(i)
	var fits := found.filter(func(i: int) -> bool: return int(uses.get(i, 0)) < stage.arena_max_uses)
	if not fits.is_empty():
		found.assign(fits)
	if found.is_empty():
		# nothing fits (a stage of one room shape): anything but the arena just left
		for i in stage.layouts.size():
			if i != current_layout or stage.layouts.size() == 1:
				found.append(i)
	var least := 1 << 30
	for i in found:
		least = mini(least, int(uses.get(i, 0)))
	var pool := found.filter(func(i: int) -> bool: return int(uses.get(i, 0)) == least)
	return pool[_rng.randi() % pool.size()]
