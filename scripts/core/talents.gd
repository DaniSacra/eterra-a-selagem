class_name Talents
extends RefCounted
## The rules of a hero's Gifts (TalentDef), pure: what a Mastery level unlocks, the Devotion a loadout takes and
## whether a loadout (the ids equipped before the descent) is valid. docs/design/warrior_spec.md 4.1:
## - an entry needs only the centre (always on); a middle needs the entry of its branch; an apex needs the middle of
##   its branch and a Gift of its neighbouring partner branch; a bridge needs the entries of the two branches it joins;
##   sustain needs only the centre;
## - a requirement counts only when EQUIPPED, not just unlocked;
## - one Gift per action (TalentDef.slot); the loadout fits the Devotion (5 + Mastery level).
## Rejogabilidade, Fatia 1 (sistemas.md 1.4): the Mastery level reveals a Gift, the Memória opens it (once, its
## memory_cost; free when 0), the Devotion equips it. A Gift revealed but not opened is SEALED. The opened ids live in
## the hero's block (heroes.<id>.opened). Every rule takes `opened` (Array of ids, or null for "every Gift is open":
## --talents and the tests that predate the Fatia).
##
## API for the UI (the "Abrir" step on the tree and the Gift's panel; HeroLoadout wraps it for the hero screen):
##   Talents.is_open(t, opened) -> bool; book.open_problem(id, level, opened, memory) -> Problem (OK, UNKNOWN, LOCKED,
##     OPENED, SHORT); book.open_in(data, hero_id, id, level) -> bool (spends the Memória and keeps it opened; the
##     caller writes the save); Talents.opened_of(block) -> Array (the saved ids).

## OPENED: already open (the answer of open_problem); SHORT: not enough Memória to open it; SEALED: revealed, not opened.
enum Problem { OK, UNKNOWN, TWICE, LOCKED, DEVOTION, SLOT_TAKEN, NEEDS, SEALED, OPENED, SHORT }

var catalog: Array[TalentDef] = []


func _init(defs: Array[TalentDef] = []) -> void:
	catalog = defs


static func load_catalog(dir: String) -> Array[TalentDef]:
	var out: Array[TalentDef] = []
	var files := DirAccess.get_files_at(dir)
	files.sort()
	for file in files:
		var path := file.trim_suffix(".remap")
		if path.ends_with(".tres"):
			out.append(load(dir.path_join(path)))
	return out


func find(id: StringName) -> TalentDef:
	for t in catalog:
		if t.id == id:
			return t
	return null


## The Gifts unlocked at this Mastery level, in the order they unlock.
func unlocked(level: int) -> Array[TalentDef]:
	var out: Array[TalentDef] = []
	for t in catalog:
		if t.unlock_level <= level:
			out.append(t)
	out.sort_custom(func(a: TalentDef, b: TalentDef) -> bool: return a.unlock_level < b.unlock_level or (a.unlock_level == b.unlock_level and String(a.id) < String(b.id)))
	return out


## The Gifts a level unlocks (exactly that level).
func unlocked_at(level: int) -> Array[TalentDef]:
	return unlocked(level).filter(func(t: TalentDef) -> bool: return t.unlock_level == level)


func defs(ids: Array) -> Array[TalentDef]:
	var out: Array[TalentDef] = []
	for id: Variant in ids:
		var t := find(StringName(id))
		if t != null:
			out.append(t)
	return out


func cost(ids: Array) -> int:
	var total := 0
	for t in defs(ids):
		total += t.cost
	return total


## True when the Gifts in equipped (TalentDefs) give t what its place in the tree asks for.
static func needs_met(t: TalentDef, equipped: Array[TalentDef]) -> bool:
	if t.needs != &"":
		for o in equipped:
			if o.id == t.needs:
				return true
		return false
	match t.tier:
		TalentDef.Tier.MIDDLE:
			return _has(equipped, t.branch, TalentDef.Tier.ENTRY)
		TalentDef.Tier.APEX:
			if not _has(equipped, t.branch, TalentDef.Tier.MIDDLE) or not TalentDef.neighbours(t.branch, t.partner):
				return false
			for o in equipped:
				if o.branch == t.partner:
					return true
			return false
		TalentDef.Tier.BRIDGE:
			if t.joins.size() != 2:
				return false
			return _has(equipped, t.joins[0], TalentDef.Tier.ENTRY) and _has(equipped, t.joins[1], TalentDef.Tier.ENTRY)
	return true


static func _has(equipped: Array[TalentDef], branch: TalentDef.Branch, tier: TalentDef.Tier) -> bool:
	for o in equipped:
		if o.branch == branch and o.tier == tier:
			return true
	return false


## True when a Gift is open: free (memory_cost 0), opened in the save (opened holds its id), or opened is null.
static func is_open(t: TalentDef, opened: Variant) -> bool:
	if opened == null or t.memory_cost <= 0:
		return true
	return (opened as Array).has(String(t.id)) or (opened as Array).has(t.id)


## The ids opened in a hero's block (strings).
static func opened_of(block: Dictionary) -> Array:
	return (block.get("opened", []) as Array).filter(func(v: Variant) -> bool: return v is String)


## The Gifts revealed at this level that are open (free ones and those opened).
func open_ones(level: int, opened: Variant) -> Array[TalentDef]:
	var out: Array[TalentDef] = []
	for t in unlocked(level):
		if is_open(t, opened):
			out.append(t)
	return out


## Whether a Gift can be opened now with this much Memória: OK, UNKNOWN, LOCKED (not revealed), OPENED (already open)
## or SHORT (not enough Memória).
func open_problem(id: StringName, level: int, opened: Array, memory: int) -> Problem:
	var t := find(id)
	if t == null:
		return Problem.UNKNOWN
	if t.unlock_level > level:
		return Problem.LOCKED
	if is_open(t, opened):
		return Problem.OPENED
	return Problem.OK if memory >= t.memory_cost else Problem.SHORT


## Opens a Gift in save data: spends its Memória (MaterialPurse) and adds it to heroes.<hero_id>.opened. False when
## open_problem is not OK (nothing changes).
func open_in(data: Dictionary, hero_id: String, id: StringName, level: int) -> bool:
	var block := SaveData.hero(data, hero_id)
	var opened := opened_of(block)
	if open_problem(id, level, opened, MaterialPurse.amount(data, MaterialPurse.MEMORY)) != Problem.OK:
		return false
	if not MaterialPurse.spend(data, MaterialPurse.MEMORY, find(id).memory_cost):
		return false
	opened.append(String(id))
	block["opened"] = opened
	return true


## Whether a whole loadout is valid at this Mastery level with this much Devotion: {problem, id} (the first Gift
## that breaks a rule; problem OK and id &"" when it is valid). opened: the Gifts opened (null: all are).
func check(ids: Array, level: int, devotion: int, opened: Variant = null) -> Dictionary:
	var seen := {}
	var slots := {}
	for id: Variant in ids:
		var t := find(StringName(id))
		if t == null:
			return _fail(Problem.UNKNOWN, StringName(id))
		if seen.has(t.id):
			return _fail(Problem.TWICE, t.id)
		seen[t.id] = true
		if t.unlock_level > level:
			return _fail(Problem.LOCKED, t.id)
		if not is_open(t, opened):
			return _fail(Problem.SEALED, t.id)
		if t.slot != Boon.Slot.NONE:
			if slots.has(t.slot):
				return _fail(Problem.SLOT_TAKEN, t.id)
			slots[t.slot] = t.id
	var equipped := defs(ids)
	for t in equipped:
		if not needs_met(t, equipped):
			return _fail(Problem.NEEDS, t.id)
	if cost(ids) > devotion:
		return _fail(Problem.DEVOTION, StringName(ids[-1]) if not ids.is_empty() else &"")
	return _fail(Problem.OK, &"")


## Whether one more Gift can be equipped on top of ids (the screen's question for each card).
func can_add(ids: Array, id: StringName, level: int, devotion: int, opened: Variant = null) -> Problem:
	var more := ids.duplicate()
	more.append(id)
	return check(more, level, devotion, opened).problem


## The valid part of a loadout read from a save (an older or edited file, a Gift that no longer exists): Gifts are
## kept in order while the loadout stays valid; then any Gift whose needs left with a dropped one goes too.
func sanitized(ids: Array, level: int, devotion: int, opened: Variant = null) -> Array[StringName]:
	var out: Array[StringName] = []
	for id: Variant in ids:
		var t := find(StringName(id))
		if t == null or out.has(t.id) or t.unlock_level > level or not is_open(t, opened):
			continue
		var more: Array[StringName] = out.duplicate()
		more.append(t.id)
		var p: Problem = check(more, level, devotion, opened).problem
		if (p == Problem.OK or p == Problem.NEEDS) and cost(more) <= devotion:
			out = more
	# needs are kept only when what they need stayed
	var changed := true
	while changed:
		changed = false
		var equipped := defs(out)
		for t in equipped:
			if not needs_met(t, equipped):
				out.erase(t.id)
				changed = true
				break
	return out


## Why each Gift asked for did not stay in kept (sanitized's answer): id -> Problem (E6: --hero-equip and --talents
## dropped Gifts in silence, e.g. Reserva without Lâmina Faminta, the entry of its branch, or a Gift still locked).
func why_dropped(asked: Array, kept: Array, level: int, devotion: int, opened: Variant = null) -> Dictionary:
	var out := {}
	for id: Variant in asked:
		var sid := StringName(id)
		if kept.has(sid) or out.has(sid):
			continue
		var t := find(sid)
		if t == null:
			out[sid] = Problem.UNKNOWN
		elif t.unlock_level > level:
			out[sid] = Problem.LOCKED
		elif not is_open(t, opened):
			out[sid] = Problem.SEALED
		else:
			var more := kept.duplicate()
			more.append(sid)
			var p: Problem = check(more, level, devotion, opened).problem
			out[sid] = p if p != Problem.OK else Problem.NEEDS
	return out


static func _fail(problem: Problem, id: StringName) -> Dictionary:
	return {"problem": problem, "id": id}
