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
	var layout := 0

	func _init(k: Kind, r: Reward, d: int, l: int = 0) -> void:
		kind = k
		reward = r
		depth = d
		layout = l


var stage: StageDef
var depth := 0
var miniboss_depth := 0
var fountain_seen := false
var _rng: RandomNumberGenerator


func _init(stage_def: StageDef, rng: RandomNumberGenerator) -> void:
	stage = stage_def
	_rng = rng
	miniboss_depth = _rng.randi_range(stage.miniboss_depth_min, stage.miniboss_depth_max)


## The opening room: a fight that always ends in a gift.
func first() -> Room:
	return Room.new(Kind.COMBAT, Reward.BOON, 1, _layout())


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
		out.append(Room.new(Kind.MINIBOSS, Reward.BOON, next, _layout()))
		return out
	var doors := 3 if _rng.randf() < stage.three_doors_chance else 2
	if not fountain_seen and next >= stage.fountain_depth_min and next <= stage.fountain_depth_max \
			and (next == stage.fountain_depth_max or _rng.randf() < stage.fountain_chance):
		out.append(Room.new(Kind.FOUNTAIN, Reward.NONE, next, _layout()))
	var used: Array[Reward] = []
	while out.size() < doors:
		var r := _reward(used, can_pom)
		used.append(r)
		out.append(Room.new(Kind.COMBAT, r, next, _layout()))
	return out


## The paladin goes through a door into this room.
func enter(room: Room) -> void:
	depth = room.depth
	if room.kind == Kind.FOUNTAIN:
		fountain_seen = true


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


func _layout() -> int:
	return _rng.randi() % maxi(1, stage.layouts.size())
