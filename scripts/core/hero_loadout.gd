class_name HeroLoadout
extends RefCounted
## What the hero screen edits, pure (E2-06): a hero's block of the save (SaveData.hero: mastery_xp, equipped, ultimate)
## read through the HeroDef. The Gifts' rules are Talents' (check, can_add, sanitized); this only asks them, says why a
## Gift cannot go on (a text key and its arguments, for the screen) and writes the block. Nothing here touches the disk
## (the screen calls Save.write after a change).

## A Gift's place on the screen: not reached yet, free to put on, on, or reached but refused by a rule now.
## SEALED (Rejogabilidade, Fatia 1): revealed by the Mastery, not opened with Memória yet (open: the "Abrir" step).
##
## API for the UI's "Abrir" (sistemas.md 1.4): state(t) == SEALED; open_cost(t) (its TalentDef.memory_cost);
## memory() (the save's Fragmentos de Memória); can_open(t) -> Talents.Problem (OK, OPENED, SHORT, LOCKED); open(id)
## -> bool (spends and keeps it opened; the screen writes the save). The hero screen asks a confirmation on its own page
## before open (HeroScreen._pick); toggle never opens a sealed Gift (its problem is SEALED).
enum State { LOCKED, OPEN, EQUIPPED, BLOCKED, SEALED }

## Text keys of the actions a Gift may take (Boon.Slot).
const ACTION_KEY := {
	Boon.Slot.ATTACK: &"hero_action_attack", Boon.Slot.SPECIAL: &"hero_action_special",
	Boon.Slot.CAST: &"hero_action_cast", Boon.Slot.DASH: &"hero_action_dash", Boon.Slot.RUSH: &"hero_action_rush",
}


## The text key of the action a Gift of this slot takes, in this hero's words (the Maga's buttons have other names).
static func action_key(hero: HeroDef, slot: Boon.Slot) -> StringName:
	var key: StringName = ACTION_KEY[slot]
	return StringName("%s_maga" % key) if hero != null and hero.arcane != null else key
## Text keys of the branches (TalentDef.Branch).
const BRANCH_KEY := {
	TalentDef.Branch.COMBO: &"hero_branch_combo", TalentDef.Branch.FURIA: &"hero_branch_furia",
	TalentDef.Branch.EMETH: &"hero_branch_emeth", TalentDef.Branch.MAGIA: &"hero_branch_magia",
	TalentDef.Branch.BRIDGE: &"hero_branch_bridge", TalentDef.Branch.SUSTAIN: &"hero_branch_sustain",
	TalentDef.Branch.PIRO: &"hero_branch_piro", TalentDef.Branch.ARCA: &"hero_branch_arca", TalentDef.Branch.CTRL: &"hero_branch_ctrl",
	TalentDef.Branch.IMPETO: &"hero_branch_impeto", TalentDef.Branch.DOMINIO: &"hero_branch_dominio",
	TalentDef.Branch.ELEMENTALISMO: &"hero_branch_elementalismo", TalentDef.Branch.CONJURACAO: &"hero_branch_conjuracao",
	TalentDef.Branch.FEITICARIA: &"hero_branch_feiticaria",
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
## The whole save data (the materials live at its root).
var data: Dictionary


func _init(p_hero: HeroDef, data_: Dictionary) -> void:
	hero = p_hero
	book = hero.talents()
	data = data_
	block = SaveData.hero(data, String(hero.id))
	# what an older or edited file holds is kept only where it is still valid
	block.equipped = ids_as_strings(book.sanitized(block.equipped, level(), devotion(), opened()))


## The Gifts opened with Memória (ids in the save).
func opened() -> Array:
	return Talents.opened_of(block)


func is_open(t: TalentDef) -> bool:
	return Talents.is_open(t, opened())


func memory() -> int:
	return MaterialPurse.amount(data, MaterialPurse.MEMORY)


func open_cost(t: TalentDef) -> int:
	return t.memory_cost


func can_open(t: TalentDef) -> Talents.Problem:
	return book.open_problem(t.id, level(), opened(), memory())


## Opens a sealed Gift with Memória. False when can_open is not OK.
func open(id: StringName) -> bool:
	return book.open_in(data, String(hero.id), id, level())


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
	if not is_open(t):
		return State.SEALED
	return State.OPEN if problem(t) == Talents.Problem.OK else State.BLOCKED


func problem(t: TalentDef) -> Talents.Problem:
	return book.can_add(block.equipped, t.id, level(), devotion(), opened())


## Puts the Gift on or takes it off. Taking one off also takes off what needed it (Talents.sanitized). False when
## nothing changed (a rule refused it).
func toggle(id: StringName) -> bool:
	if is_equipped(id):
		var rest: Array = (block.equipped as Array).duplicate()
		rest.erase(String(id))
		block.equipped = ids_as_strings(book.sanitized(rest, level(), devotion(), opened()))
		return true
	var t := book.find(id)
	if t == null or problem(t) != Talents.Problem.OK:
		return false
	(block.equipped as Array).append(String(id))
	return true


## The ultimate the next descent plays: the fixed one of the hero's weapon (redesign A.3), none below its Mastery level.
func ultimate() -> StringName:
	var u := hero.ult_for_weapon(level())
	return u.id if u != null else &""


func ult_open(u: UltDef) -> bool:
	return u.mastery_level <= level()


## Compatibility shim until the UI drops the choice (UI-2): there is nothing to choose now, the ultimate is the weapon's.
## True only when id is that fixed ultimate; nothing is written to the save (block.ultimate is no longer read).
func choose_ult(id: StringName) -> bool:
	return id != &"" and ultimate() == id


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
		Talents.Problem.SEALED:
			return {"key": &"hero_why_sealed", "args": {"cost": t.memory_cost}}
	return {}


## The short reason of a BLOCKED Gift, for the codex entry's second line ("Pede: X", "Já há um Dom no botão Y: X",
## "Faltam 2 velas"), as {key, args} for T.t ({} when it is not refused for these reasons).
func short_why(t: TalentDef) -> Dictionary:
	match problem(t):
		Talents.Problem.DEVOTION:
			var n := t.cost - (devotion() - used())
			return {"key": &"codex_block_candle" if n == 1 else &"codex_block_candles", "args": {"n": n}}
		Talents.Problem.SLOT_TAKEN:
			return {"key": &"codex_block_slot", "args": {"action": T.t(action_key(hero, t.slot)), "name": _name(_slot_holder(t.slot))}}
		Talents.Problem.NEEDS:
			if t.needs != &"":
				return {"key": &"codex_block_needs", "args": {"what": _name(book.find(t.needs))}}
			match t.tier:
				TalentDef.Tier.APEX:
					return {"key": &"codex_block_apex", "args": {"middle": _name(of(t.branch, TalentDef.Tier.MIDDLE)),
						"branch": T.t(BRANCH_KEY[t.partner])}}
				TalentDef.Tier.BRIDGE:
					return {"key": &"codex_block_bridge", "args": {"a": _name(of(t.joins[0], TalentDef.Tier.ENTRY)),
						"b": _name(of(t.joins[1], TalentDef.Tier.ENTRY))}}
			return {"key": &"codex_block_needs", "args": {"what": _name(of(t.branch, TalentDef.Tier.ENTRY))}}
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
		State.SEALED:
			return {"key": &"hero_step_open", "args": {"cost": t.memory_cost, "have": memory()}}
	return {}


## The XP still missing to reach a Mastery level (0 when reached).
func xp_missing(n: int) -> int:
	return maxi(hero.mastery.total_to(n) - xp(), 0)


## What a Gift needs by its place in the tree ({} for an entry or a sustain Gift).
func needs(t: TalentDef) -> Dictionary:
	if t.needs != &"":  # the redesign: the Gift it names, whatever its place
		return {"key": &"hero_why_needs", "args": {"what": _name(book.find(t.needs))}}
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


## Every Gift of this branch and tier, in catalog order (a place may hold more than one).
func all_of(branch: TalentDef.Branch, tier: TalentDef.Tier) -> Array[TalentDef]:
	var out: Array[TalentDef] = []
	for t in book.catalog:
		if t.branch == branch and t.tier == tier:
			out.append(t)
	return out


## True when two Gifts share a place in the tree: same branch and tier, and for a bridge the same two branches.
static func same_place(a: TalentDef, b: TalentDef) -> bool:
	if a.tier != b.tier or a.branch != b.branch:
		return false
	return a.tier != TalentDef.Tier.BRIDGE or (a.joins == b.joins)


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
