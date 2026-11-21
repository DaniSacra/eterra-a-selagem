class_name Vendor
extends RefCounted
## The Vendedor's end game (Rejogabilidade, Fatia 3; sistemas.md 1.7), pure: the Obras (ObraDef, one-time, in the three
## materials, open once the Ofícios' first order was delivered: the Vendedor's stall is open) and the trade between
## materials at a loss (the Hades II's Broker; OficiosDef.trades). The Obra made by the order (OficiosDef.order_gives,
## the angels' preview) counts as made.
##
## API for the UI (the Vendedor's page): Vendor.load_catalog(); Vendor.state(data, def, obra) -> State (LOCKED the
## stall still closed, OPEN, DONE); Vendor.missing(data, obra) -> {material: short}; Vendor.build(data, def, obra) ->
## bool; Vendor.trades(def) -> Array[Dictionary] {give, give_n, get, get_n}; Vendor.can_trade(data, def, i);
## Vendor.trade(data, def, i) -> bool. The caller writes the save. Text keys obra_<id>, obra_<id>_desc.

enum State { LOCKED, OPEN, DONE }

const DIR := "res://data/obras/"


static func load_catalog(dir: String = DIR) -> Array[ObraDef]:
	var out: Array[ObraDef] = []
	if not DirAccess.dir_exists_absolute(dir):
		return out
	var files := DirAccess.get_files_at(dir)
	files.sort()
	for file in files:
		var path := file.trim_suffix(".remap")
		if path.ends_with(".tres"):
			out.append(load(dir.path_join(path)))
	return out


static func made(data: Dictionary, obra: ObraDef) -> bool:
	return Oficios.has_recipe(data, obra.id)


static func state(data: Dictionary, def: OficiosDef, obra: ObraDef) -> State:
	if made(data, obra):
		return State.DONE
	return State.OPEN if Oficios.order_state(data, def) == Oficios.Order.DONE else State.LOCKED


## What is short of its cost (material: how many), empty when it can be paid.
static func missing(data: Dictionary, obra: ObraDef) -> Dictionary:
	var out := {}
	for m: Variant in obra.cost:
		var short := int(obra.cost[m]) - MaterialPurse.amount(data, StringName(m))
		if short > 0:
			out[StringName(m)] = short
	return out


## Makes the Obra: pays and keeps it. False when the stall is closed, it is made or something is short.
static func build(data: Dictionary, def: OficiosDef, obra: ObraDef) -> bool:
	if state(data, def, obra) != State.OPEN or not missing(data, obra).is_empty():
		return false
	for m: Variant in obra.cost:
		MaterialPurse.spend(data, StringName(m), int(obra.cost[m]))
	(Oficios.block(data).recipes as Array).append(String(obra.id))
	return true


static func trades(def: OficiosDef) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for t: Variant in def.trades:
		out.append(t)
	return out


## Whether trade i may be made now (the stall open, its price held and room under the cap of what it gives).
static func can_trade(data: Dictionary, def: OficiosDef, i: int) -> bool:
	if i < 0 or i >= def.trades.size() or Oficios.order_state(data, def) != Oficios.Order.DONE:
		return false
	var t: Dictionary = def.trades[i]
	var get_id := StringName(t["get"])
	return MaterialPurse.can_pay(data, StringName(t["give"]), int(t["give_n"])) \
		and MaterialPurse.amount(data, get_id) + int(t["get_n"]) <= int(MaterialPurse.CAP[get_id])


static func trade(data: Dictionary, def: OficiosDef, i: int) -> bool:
	if not can_trade(data, def, i):
		return false
	var t: Dictionary = def.trades[i]
	MaterialPurse.spend(data, StringName(t["give"]), int(t["give_n"]))
	MaterialPurse.give(data, StringName(t["get"]), int(t["get_n"]))
	return true


## The Obras made, as ids (a descent's: OficiosRun.works).
static func works(data: Dictionary, catalog: Array[ObraDef]) -> Array[StringName]:
	var out: Array[StringName] = []
	for o in catalog:
		if made(data, o):
			out.append(o.id)
	return out


## The stage with the numbers of the Obras made laid over it (the same stage when none changes it).
static func stage_for(stage: StageDef, catalog: Array[ObraDef], made_ids: Array[StringName]) -> StageDef:
	var out := stage
	for o in catalog:
		if not made_ids.has(o.id) or o.stage.is_empty():
			continue
		if out == stage:
			out = stage.duplicate()
		for k: Variant in o.stage:
			out.set(StringName(k), o.stage[k])
	return out
