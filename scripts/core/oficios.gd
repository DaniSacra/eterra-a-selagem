class_name Oficios
extends RefCounted
## Ofícios, Roteiro A (docs/design/oficios/15_prototipo.md): the save's `oficios` block and every rule over it, pure.
## Block: items (id: count held; the Pedra Funda under OficiosDef.stone_cap), items_total (id: ever held), finds (ids of
## finds held, the pick's head), tools (ids, the pick), orders (id: "open" or "done"), recipes (the Obras made),
## pity (find id: descents that passed the guardian with its room marked and not taken), seen (what was noted: "vein").
## A run's part comes in an OficiosRun and goes in once at its end (bank).

enum Order { LOCKED, OPEN, DONE }

const VEIN := "vein"
## Why the pick cannot be restored now (restore_problem): &"" it can.
const NO_HEAD := &"no_head"
const SHORT := &"short"
const DONE := &"done"


static func defaults() -> Dictionary:
	return {"items": {}, "items_total": {}, "finds": [], "tools": [], "orders": {}, "recipes": [], "pity": {}, "seen": []}


## The block of save data (made when missing: a dictionary from a test).
static func block(data: Dictionary) -> Dictionary:
	if not data.get("oficios") is Dictionary:
		data["oficios"] = defaults()
	var b: Dictionary = data["oficios"]
	for k: String in defaults():
		if not b.has(k):
			b[k] = defaults()[k]
	return b


static func has_tool(data: Dictionary, def: OficiosDef) -> bool:
	return (block(data).tools as Array).has(String(def.tool))


static func has_find(data: Dictionary, id: StringName) -> bool:
	return (block(data).finds as Array).has(String(id))


## Whether the vein was noted once (the Forjador's order then shows and the head's room is marked).
static func noted(data: Dictionary) -> bool:
	return (block(data).seen as Array).has(VEIN)


## Whether a descent marks the head's room now: noted, the head not held, the pick not restored.
static func head_wanted(data: Dictionary, def: OficiosDef) -> bool:
	return noted(data) and not has_find(data, def.head) and not has_tool(data, def)


## The guardian gives the head when the room was missed pity_runs times (Q-OF6 a).
static func pity_due(data: Dictionary, def: OficiosDef) -> bool:
	return head_wanted(data, def) and int(block(data).pity.get(String(def.head), 0)) >= def.pity_runs


static func count(data: Dictionary, id: StringName) -> int:
	return int(block(data).items.get(String(id), 0))


## Adds up to n of an item, never past its cap (the Pedra Funda's stone_cap); the total ever held counts what went in.
## Returns how many went in.
static func add_item(data: Dictionary, def: OficiosDef, id: StringName, n: int) -> int:
	var b := block(data)
	var cap := def.stone_cap if id == def.stone else 1 << 20
	var have := count(data, id)
	var put := clampi(n, 0, maxi(0, cap - have))
	if put <= 0:
		return 0
	b.items[String(id)] = have + put
	b.items_total[String(id)] = int(b.items_total.get(String(id), 0)) + put
	return put


## What stops restoring the pick: &"" nothing, DONE, NO_HEAD, SHORT (Prata missing: restore_short).
static func restore_problem(data: Dictionary, def: OficiosDef) -> StringName:
	if has_tool(data, def):
		return DONE
	if not has_find(data, def.head):
		return NO_HEAD
	if restore_short(data, def) > 0:
		return SHORT
	return &""


## The Prata missing to restore the pick.
static func restore_short(data: Dictionary, def: OficiosDef) -> int:
	var want := int(def.restore_cost.get(OficiosDef.SILVER, 0))
	return maxi(0, want - MaterialPurse.amount(data, MaterialPurse.SILVER))


## Restores the pick at the Forjador: pays, the head goes, the tool comes. False (nothing changed) when it cannot.
static func restore(data: Dictionary, def: OficiosDef) -> bool:
	if restore_problem(data, def) != &"":
		return false
	MaterialPurse.spend(data, MaterialPurse.SILVER, int(def.restore_cost.get(OficiosDef.SILVER, 0)))
	var b := block(data)
	(b.finds as Array).erase(String(def.head))
	(b.tools as Array).append(String(def.tool))
	b.pity.erase(String(def.head))
	return true


## The Vendedor's order: locked until a Pedra Funda was ever held, open, done once delivered.
static func order_state(data: Dictionary, def: OficiosDef) -> Order:
	var b := block(data)
	if String(b.orders.get(String(def.order), "")) == "done":
		return Order.DONE
	if int(b.items_total.get(String(def.stone), 0)) > 0:
		return Order.OPEN
	return Order.LOCKED


## What the order still misses: id: count (empty: it can be delivered).
static func order_missing(data: Dictionary, def: OficiosDef) -> Dictionary:
	var out := {}
	for id: Variant in def.order_wants:
		var want := int(def.order_wants[id])
		var have := MaterialPurse.amount(data, StringName(id)) if StringName(id) in MaterialPurse.IDS else count(data, StringName(id))
		if have < want:
			out[StringName(id)] = want - have
	return out


## Delivers the order once: pays what it wants, makes the Obra. False when not open or something is missing.
static func deliver(data: Dictionary, def: OficiosDef) -> bool:
	if order_state(data, def) != Order.OPEN or not order_missing(data, def).is_empty():
		return false
	var b := block(data)
	for id: Variant in def.order_wants:
		var n := int(def.order_wants[id])
		if StringName(id) in MaterialPurse.IDS:
			MaterialPurse.spend(data, StringName(id), n)
		else:
			b.items[String(id)] = count(data, StringName(id)) - n
	b.orders[String(def.order)] = "done"
	if not (b.recipes as Array).has(String(def.order_gives)):
		(b.recipes as Array).append(String(def.order_gives))
	return true


static func has_recipe(data: Dictionary, id: StringName) -> bool:
	return (block(data).recipes as Array).has(String(id))


## A run's part into save data, once (Game.log_run through RunAward.keep): the vein noted, the head found, the stones
## (under the cap) and the pity (the marked room missed in a descent past the guardian counts one; the head found
## clears it). Returns what went in: {finds, items, noted}.
static func bank(data: Dictionary, def: OficiosDef, run: OficiosRun) -> Dictionary:
	var b := block(data)
	var out := {"finds": [], "items": {}, "noted": false}
	if run.noted and not noted(data):
		(b.seen as Array).append(VEIN)
		out.noted = true
	if run.head_found and not has_find(data, def.head) and not has_tool(data, def):
		(b.finds as Array).append(String(def.head))
		(out.finds as Array).append(String(def.head))
		b.pity.erase(String(def.head))
	elif run.marked and run.passed_guardian and not run.head_found:
		b.pity[String(def.head)] = int(b.pity.get(String(def.head), 0)) + 1
	if run.stones > 0:
		var put := add_item(data, def, def.stone, run.stones)
		if put > 0:
			out.items[String(def.stone)] = put
	return out
