class_name RunMap
extends RefCounted
## The way down through one region, room by room, as in the first region of Hades II: an opening fight, rooms whose
## doors show the reward behind them, a guardian halfway, one fountain, the shop, then the boss. Pure logic.

enum Kind { COMBAT, MINIBOSS, FOUNTAIN, SHOP, BOSS }
## What a room gives when it is cleared (or what the shop sells).
## BOON: a gift (three to choose). POM: one more level for a gift already owned. HEART: more life.
## MAGICK: more Magia. GOLD: gold for the shop. HEAL: life back (shop only).
enum Reward { NONE, BOON, POM, HEART, MAGICK, GOLD, HEAL }

const REWARD_KEY: Array[StringName] = [&"", &"reward_boon", &"reward_pom", &"reward_heart", &"reward_magick", &"reward_gold", &"reward_heal"]
const KIND_KEY: Array[StringName] = [&"room_combat", &"room_miniboss", &"room_fountain", &"room_shop", &"room_boss"]


class Room:
	var kind := Kind.COMBAT
	var reward := Reward.NONE
	var depth := 1
	## Index of its arena in StageDef.layouts (the boss and the shop have their own), and how it is dressed
	## (RoomLayout.variant).
	var layout := 0
	var variant := 0

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
## The arena of the room the paladin stands in (-1: none yet), and every arena fought in so far.
var current_layout := -1
var seen_layouts: Array[int] = []
## Dev (--arena): the opening room is this arena (-1: drawn as any).
var forced_layout := -1
var _rng: RandomNumberGenerator


func _init(stage_def: StageDef, rng: RandomNumberGenerator) -> void:
	stage = stage_def
	_rng = rng
	miniboss_depth = _rng.randi_range(stage.miniboss_depth_min, stage.miniboss_depth_max)


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
		out.append(Room.new(Kind.SHOP, Reward.NONE, next))
		return out
	if next == miniboss_depth:
		out.append(_room(Kind.MINIBOSS, Reward.BOON, next))
		return out
	var doors := 3 if _rng.randf() < stage.three_doors_chance else 2
	if not fountain_seen and next >= stage.fountain_depth_min and next <= stage.fountain_depth_max \
			and (next == stage.fountain_depth_max or _rng.randf() < stage.fountain_chance):
		out.append(_room(Kind.FOUNTAIN, Reward.NONE, next))
	var used: Array[Reward] = []
	while out.size() < doors:
		var r := _reward(used, can_pom)
		used.append(r)
		out.append(_room(Kind.COMBAT, r, next))
	return out


## The paladin goes through a door into this room.
func enter(room: Room) -> void:
	depth = room.depth
	if room.kind == Kind.FOUNTAIN:
		fountain_seen = true
	if room.kind == Kind.SHOP or room.kind == Kind.BOSS:
		current_layout = -1
		return
	current_layout = room.layout
	if not seen_layouts.has(room.layout):
		seen_layouts.append(room.layout)


## A reward no other door of this room shows (unless every kind is taken already).
func _reward(used: Array[Reward], can_pom: bool) -> Reward:
	var kinds: Array[Reward] = []
	var weights := PackedFloat32Array()
	for i in stage.rewards.size():
		var r := stage.rewards[i] as Reward
		if used.has(r) or (r == Reward.POM and not can_pom):
			continue
		kinds.append(r)
		weights.append(stage.reward_weights[i] if i < stage.reward_weights.size() else 1.0)
	if kinds.is_empty():
		return Reward.BOON
	return kinds[_rng.rand_weighted(weights)]


## A room of this kind at this depth, in an arena drawn for it (_layout) and one of its variants.
func _room(kind: Kind, reward: Reward, at_depth: int) -> Room:
	var l := _layout(kind, at_depth)
	var count := stage.layouts[l].variant_count() if l < stage.layouts.size() else 1
	return Room.new(kind, reward, at_depth, l, _rng.randi() % count)


## The arena of a room (cycle C12): one whose place in the descent (RoomLayout.depth) holds this depth, that may hold
## this kind of room (guardian, fountain), never a high one before HARD_FROM, never the arena of the fight just left
## (a fountain may follow its own), the ones not fought in yet first.
func _layout(kind: Kind, at_depth: int) -> int:
	if stage.layouts.is_empty():
		return 0
	if forced_layout >= 0 and at_depth == 1:
		return forced_layout
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
	if found.is_empty():
		# nothing fits (a stage of one room shape): anything but the arena just left
		for i in stage.layouts.size():
			if i != current_layout or stage.layouts.size() == 1:
				found.append(i)
	var fresh := found.filter(func(i: int) -> bool: return not seen_layouts.has(i))
	var pool: Array = fresh if not fresh.is_empty() else found
	return pool[_rng.randi() % pool.size()]
