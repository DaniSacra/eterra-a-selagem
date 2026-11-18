class_name HeroLoadout
extends RefCounted
## What the hero screen edits, pure (E2-06): a hero's block of the save (SaveData.hero: mastery_xp, equipped, ultimate)
## read through the HeroDef. The Gifts' rules are Talents' (check, can_add, sanitized); this only asks them, says why a
## Gift cannot go on (a text key and its arguments, for the screen) and writes the block. Nothing here touches the disk
## (the screen calls Save.write after a change).

## A Gift's place on the screen: not reached yet, free to put on, on, or reached but refused by a rule now.
enum State { LOCKED, OPEN, EQUIPPED, BLOCKED }

## Text keys of the actions a Gift may take (Boon.Slot).
const ACTION_KEY := {
	Boon.Slot.ATTACK: &"hero_action_attack", Boon.Slot.SPECIAL: &"hero_action_special",
	Boon.Slot.CAST: &"hero_action_cast", Boon.Slot.DASH: &"hero_action_dash",
}
## Text keys of the branches (TalentDef.Branch).
const BRANCH_KEY := {
	TalentDef.Branch.COMBO: &"hero_branch_combo", TalentDef.Branch.FURIA: &"hero_branch_furia",
	TalentDef.Branch.EMETH: &"hero_branch_emeth", TalentDef.Branch.MAGIA: &"hero_branch_magia",
	TalentDef.Branch.BRIDGE: &"hero_branch_bridge", TalentDef.Branch.SUSTAIN: &"hero_branch_sustain",
}
const TIER_KEY := {
	TalentDef.Tier.ENTRY: &"hero_tier_entry", TalentDef.Tier.MIDDLE: &"hero_tier_middle",
	TalentDef.Tier.APEX: &"hero_tier_apex", TalentDef.Tier.BRIDGE: &"hero_tier_bridge",
	TalentDef.Tier.SUSTAIN: &"hero_tier_sustain",
}

var hero: HeroDef
var book: Talents
## The hero's block inside the save data (edited in place).
var block: Dictionary


func _init(p_hero: HeroDef, data: Dictionary) -> void:
	hero = p_hero
	book = hero.talents()
	block = SaveData.hero(data, String(hero.id))
	# what an older or edited file holds is kept only where it is still valid
	block.equipped = ids_as_strings(book.sanitized(block.equipped, level(), devotion()))


func xp() -> int:
	return int(block.mastery_xp)


func level() -> int:
	return hero.mastery.level_of(xp())


func devotion() -> int:
	return hero.mastery.devotion(level())


func equipped() -> Array:
	return block.equipped


func used() -> int:
	return book.cost(block.equipped)


func is_equipped(id: StringName) -> bool:
	return (block.equipped as Array).has(String(id))


func state(t: TalentDef) -> State:
	if is_equipped(t.id):
		return State.EQUIPPED
	if t.unlock_level > level():
		return State.LOCKED
	return State.OPEN if problem(t) == Talents.Problem.OK else State.BLOCKED


func problem(t: TalentDef) -> Talents.Problem:
	return book.can_add(block.equipped, t.id, level(), devotion())


## Puts the Gift on or takes it off. Taking one off also takes off what needed it (Talents.sanitized). False when
## nothing changed (a rule refused it).
func toggle(id: StringName) -> bool:
	if is_equipped(id):
		var rest: Array = (block.equipped as Array).duplicate()
		rest.erase(String(id))
		block.equipped = ids_as_strings(book.sanitized(rest, level(), devotion()))
		return true
	var t := book.find(id)
	if t == null or problem(t) != Talents.Problem.OK:
		return false
	(block.equipped as Array).append(String(id))
	return true


## The ultimate the next descent plays: the one chosen, or the first unlocked when none is (HeroDef.ult_for, T5).
func ultimate() -> StringName:
	var u := hero.ult_for(StringName(block.ultimate), level())
	return u.id if u != null else &""


func ult_open(u: UltDef) -> bool:
	return u.mastery_level <= level()


## Chooses an ultimate (only one unlocked; choosing the one already chosen keeps it). False when it is locked.
func choose_ult(id: StringName) -> bool:
	var u := hero.ultimate(id)
	if u == null or not ult_open(u):
		return false
	block.ultimate = String(id)
	return true


## Why a Gift cannot go on now, as {key, args} for T.t ({} when it can, or it is on).
func why(t: TalentDef) -> Dictionary:
	if is_equipped(t.id):
		return {}
	match problem(t):
		Talents.Problem.LOCKED:
			return {"key": &"hero_why_locked", "args": {"n": t.unlock_level}}
		Talents.Problem.DEVOTION:
			return {"key": &"hero_why_devotion", "args": {"cost": t.cost, "free": devotion() - used()}}
		Talents.Problem.SLOT_TAKEN:
			var holder := _slot_holder(t.slot)
			return {"key": &"hero_why_slot", "args": {"name": _name(holder)}}
		Talents.Problem.NEEDS:
			return needs(t)
	return {}


## What a Gift needs equipped before it, as {key, args} for T.t, whatever is on now (stage 2 of the art pack: the
## panel's "Pré-requisito"): nothing for an entry or a sustain Gift (hero_needs_none).
func needs_text(t: TalentDef) -> Dictionary:
	var n := needs(t)
	return n if not n.is_empty() else {"key": &"hero_needs_none", "args": {}}


## The next thing to do for a Gift that is not on, as {key, args} for T.t ({} when it is on or can go on now): reach
## its Mastery level (with the XP that is missing), or what a rule asks (why).
func next_step(t: TalentDef) -> Dictionary:
	match state(t):
		State.LOCKED:
			return {"key": &"hero_step_mastery", "args": {"n": t.unlock_level, "xp": xp_missing(t.unlock_level)}}
		State.BLOCKED:
			return why(t)
	return {}


## The XP still missing to reach a Mastery level (0 when reached).
func xp_missing(n: int) -> int:
	return maxi(hero.mastery.total_to(n) - xp(), 0)


## What a Gift needs by its place in the tree ({} for an entry or a sustain Gift).
func needs(t: TalentDef) -> Dictionary:
	match t.tier:
		TalentDef.Tier.MIDDLE:
			return {"key": &"hero_why_needs", "args": {"what": _name(of(t.branch, TalentDef.Tier.ENTRY))}}
		TalentDef.Tier.APEX:
			return {"key": &"hero_why_apex", "args": {"middle": _name(of(t.branch, TalentDef.Tier.MIDDLE)),
				"branch": T.t(BRANCH_KEY[t.partner])}}
		TalentDef.Tier.BRIDGE:
			return {"key": &"hero_why_bridge", "args": {"a": _name(of(t.joins[0], TalentDef.Tier.ENTRY)),
				"b": _name(of(t.joins[1], TalentDef.Tier.ENTRY))}}
	return {}


## The Gift of this branch and tier (the first one), or null.
func of(branch: TalentDef.Branch, tier: TalentDef.Tier) -> TalentDef:
	for t in book.catalog:
		if t.branch == branch and t.tier == tier:
			return t
	return null


func _slot_holder(slot: Boon.Slot) -> TalentDef:
	for t in book.defs(block.equipped):
		if t.slot == slot:
			return t
	return null


static func _name(t: TalentDef) -> String:
	return T.t(t.name_key) if t != null else "?"


## What the next level brings: the names of its Gifts and ultimates ([] at the top).
func next_unlocks() -> Array[String]:
	return unlocks_at(level() + 1)


func unlocks_at(n: int) -> Array[String]:
	var out: Array[String] = []
	if n > hero.mastery.max_level:
		return out
	for t in book.unlocked_at(n):
		out.append(T.t(t.name_key))
	for u in hero.ultimates:
		if u.mastery_level == n:
			out.append(T.t(u.name_key))
	return out


## "Combo, entrada" or "Ponte de Combo e Fúria": where a Gift sits.
func place_text(t: TalentDef) -> String:
	if t.tier == TalentDef.Tier.BRIDGE and t.joins.size() == 2:
		return T.t(TIER_KEY[t.tier], {"a": T.t(BRANCH_KEY[t.joins[0]]), "b": T.t(BRANCH_KEY[t.joins[1]])})
	if t.tier == TalentDef.Tier.SUSTAIN:
		return T.t(BRANCH_KEY[TalentDef.Branch.SUSTAIN])
	return T.t(BRANCH_KEY[t.branch]) + ", " + T.t(TIER_KEY[t.tier])


static func ids_as_strings(ids: Array) -> Array:
	return ids.map(func(id: Variant) -> String: return String(id))
