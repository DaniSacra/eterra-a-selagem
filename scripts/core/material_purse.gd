class_name MaterialPurse
extends RefCounted
## The materials a descent brings home (Rejogabilidade, Fatia 1; docs/design/rejogabilidade/sistemas.md 1.2 and 5),
## pure. Three currencies, each with one use only: Prata Antiga (silver, the Forja), Fragmento de Memória (memory, opens
## the Gifts) and Esmeralda (emerald, the Fatia 2; no source yet). Gold stays the descent's own (GoldPurse, Rooms.gold).
## Names are working names (Q-RJ3): the screens read material_<id> and material_<id>_short from the text table.
##
## An instance is one descent's purse: what was picked up, by source (elite, door, guardian, boss, trial), shown in the
## RESULT (report) and banked into the save once when the run ends (bank: victory, death or quit; Game.log_run), never
## by the robot nor without a save (A2; --materials-keep banks the robot's for measures). Dying keeps everything.
## The static functions read and change the save data's materials (data.materials, capped by CAP; data.materials_total
## counts all ever brought, for the Codex and the measures).
##
## API for the UI (the hub's pages, the end screen):
##   MaterialPurse.amount(data, MaterialPurse.SILVER) -> int: what the save holds now.
##   MaterialPurse.can_pay(data, id, n) -> bool; MaterialPurse.spend(data, id, n) -> bool (false: not enough, nothing
##     spent). The Forja (Forge.buy) and the Gifts (Talents.open_in) already spend through here.
##   game.materials.totals() -> {silver, memory}: what this descent picked up so far (the end screen's "Trazidos").
##   game.materials_banked -> Dictionary: what log_run put into the save ({} when nothing is kept: robot, --nosave).

const SILVER := &"silver"
const MEMORY := &"memory"
const EMERALD := &"emerald"
const IDS: Array[StringName] = [SILVER, MEMORY, EMERALD]
## The most the save holds of each (sistemas.md 1.2).
const CAP := {SILVER: 999, MEMORY: 999, EMERALD: 99}
## Where a descent's materials come from, per material (the RESULT lists each with 0 when none came from it).
const SOURCES := {SILVER: [&"elite", &"door", &"guardian", &"boss"], MEMORY: [&"door", &"guardian", &"trial", &"boss"]}
## The text keys of each material's name (long and short).
const NAME_KEY := {SILVER: &"material_silver", MEMORY: &"material_memory", EMERALD: &"material_emerald"}
const SHORT_KEY := {SILVER: &"material_silver_short", MEMORY: &"material_memory_short", EMERALD: &"material_emerald_short"}
## The retroactive silver of a save from before the Fatia 1 (Q-RJ8 a): this much a descent already played, up to MAX.
const RETRO_SILVER_PER_RUN := 5
const RETRO_SILVER_MAX := 30

## material -> {source: amount} picked up in this descent.
var found := {}


## Picks up n of a material from a source. Returns what was added (0 for nothing).
func add(material: StringName, source: StringName, n: int) -> int:
	if n <= 0 or not CAP.has(material):
		return 0
	var by: Dictionary = found.get(material, {})
	by[source] = int(by.get(source, 0)) + n
	found[material] = by
	return n


## What this descent picked up of a material.
func total(material: StringName) -> int:
	var sum := 0
	for source: StringName in found.get(material, {}):
		sum += int(found[material][source])
	return sum


## The totals of the materials with a source (silver, memory): {id: amount}.
func totals() -> Dictionary:
	var out := {}
	for m: StringName in SOURCES:
		out[String(m)] = total(m)
	return out


func is_empty() -> bool:
	for m: StringName in found:
		if total(m) > 0:
			return false
	return true


## The RESULT's materials (sistemas.md 5.2): each material's sources (all of them, 0 when none) and the totals.
func report() -> Dictionary:
	var out := {}
	for m: StringName in SOURCES:
		var by := {}
		for s: StringName in SOURCES[m]:
			by[String(s)] = int((found.get(m, {}) as Dictionary).get(s, 0))
		out[String(m)] = by
	out["total"] = totals()
	return out


# ---------- the save ----------

## The materials block of a save (zeros), and its lifetime twin.
static func defaults() -> Dictionary:
	return {"silver": 0, "memory": 0, "emerald": 0}


static func _block(data: Dictionary, key := "materials") -> Dictionary:
	if not data.get(key) is Dictionary:
		data[key] = defaults()
	return data[key]


static func amount(data: Dictionary, material: StringName) -> int:
	return int(_block(data).get(String(material), 0))


static func can_pay(data: Dictionary, material: StringName, n: int) -> bool:
	return n <= 0 or amount(data, material) >= n


## Spends n of a material from the save data. False (nothing spent) when there is not enough.
static func spend(data: Dictionary, material: StringName, n: int) -> bool:
	if not can_pay(data, material, n):
		return false
	if n > 0:
		_block(data)[String(material)] = amount(data, material) - n
	return true


## Adds n of a material to the save data, never past CAP; the lifetime total counts it too. Returns what was added.
static func give(data: Dictionary, material: StringName, n: int) -> int:
	if n <= 0 or not CAP.has(material):
		return 0
	var now := amount(data, material)
	var added := mini(n, int(CAP[material]) - now)
	if added <= 0:
		return 0
	_block(data)[String(material)] = now + added
	var life := _block(data, "materials_total")
	life[String(material)] = int(life.get(String(material), 0)) + added
	return added


## Banks a descent's purse into the save data (once, when the run ends): {id: what was really added}.
static func bank(data: Dictionary, purse: MaterialPurse) -> Dictionary:
	var out := {}
	for m: StringName in purse.found:
		var n := give(data, m, purse.total(m))
		if n > 0:
			out[String(m)] = n
	return out


## The silver a save from before the Fatia 1 gets once for the descents it played (Q-RJ8 a).
static func retro_silver(runs: int) -> int:
	return clampi(runs * RETRO_SILVER_PER_RUN, 0, RETRO_SILVER_MAX)


## "silver:30,memory:5" (the --materials switch) as {silver: 30, memory: 5}; unknown ids are left out.
static func parse(text: String) -> Dictionary:
	var out := {}
	for part in text.split(",", false):
		var kv := part.split(":")
		if kv.size() == 2 and CAP.has(StringName(kv[0])):
			out[kv[0]] = maxi(0, int(kv[1]))
	return out
