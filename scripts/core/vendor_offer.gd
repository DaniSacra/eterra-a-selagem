class_name VendorOffer
extends RefCounted
## One thing on the Vendedor's counter, whatever its kind (docs/art/shop_spec.md B): a trade of materials (Vendor.trade),
## an Obra (Vendor.build) or a grade of the Discernimento (Discern.buy, moved here from the Livro de Ahk 2026-11-23). Pure:
## it only asks the rules that already exist (Vendor, Discern, MaterialPurse), so the stall never repeats a rule of
## buying. The caller writes the save.
##   var offers := VendorOffer.all(def, catalog)       # trades first, then the Obras, then Discernimento I and II
##   offer.state(data, def) -> State; offer.cost(def); offer.gain(def); offer.commit(data, def) -> bool

enum Kind { TRADE, OBRA, DISCERN }
## CAN: may be paid now. SHORT: a material is short. FULL: a trade whose gain would pass the cap of the purse. NEEDS: a
## grade whose earlier one is closed. MADE: already built or opened. LOCKED: the stall is still closed.
enum State { CAN, SHORT, FULL, NEEDS, MADE, LOCKED }

## The beam's tilt for a deal of an Obra or a grade (degrees; a trade's depends on what is given).
const TILT_FIXED := 6.0
const TILT_MIN := 4.0
const TILT_MAX := 10.0

var kind: Kind
## The trade's index in OficiosDef.trades, or the Discernimento's grade (from 1).
var index := 0
var obra: ObraDef


## Everything the counter shows, in the order of the two columns: trades, then the Obras and the Discernimento.
static func all(def: OficiosDef, catalog: Array[ObraDef]) -> Array[VendorOffer]:
	var out: Array[VendorOffer] = []
	for i in def.trades.size():
		out.append(trade_at(i))
	for o in catalog:
		out.append(of_obra(o))
	for n in range(1, Discern.COSTS.size() + 1):
		out.append(of_discern(n))
	return out


static func trade_at(i: int) -> VendorOffer:
	var o := VendorOffer.new()
	o.kind = Kind.TRADE
	o.index = i
	return o


static func of_obra(p_obra: ObraDef) -> VendorOffer:
	var o := VendorOffer.new()
	o.kind = Kind.OBRA
	o.obra = p_obra
	return o


static func of_discern(n: int) -> VendorOffer:
	var o := VendorOffer.new()
	o.kind = Kind.DISCERN
	o.index = n
	return o


## True for the offers of the left column (Trocas); the rest are the Obras column.
func is_trade() -> bool:
	return kind == Kind.TRADE


func id() -> StringName:
	match kind:
		Kind.TRADE:
			return StringName("trade_%d" % index)
		Kind.OBRA:
			return obra.id
	return StringName("discern_%d" % index)


## What is paid, material: how many (the trade's give, the Obra's cost, the grade's Memória).
func cost(def: OficiosDef) -> Dictionary:
	match kind:
		Kind.TRADE:
			var t: Dictionary = def.trades[index]
			return {StringName(t["give"]): int(t["give_n"])}
		Kind.OBRA:
			var out := {}
			for m: Variant in obra.cost:
				out[StringName(m)] = int(obra.cost[m])
			return out
	return {MaterialPurse.MEMORY: Discern.cost(index)}


## What a trade brings, material: how many (empty for an Obra and a grade).
func gain(def: OficiosDef) -> Dictionary:
	if kind != Kind.TRADE:
		return {}
	var t: Dictionary = def.trades[index]
	return {StringName(t["get"]): int(t["get_n"])}


## What is short of the price (material: how many), empty when it can be paid.
func missing(data: Dictionary, def: OficiosDef) -> Dictionary:
	var out := {}
	var price := cost(def)
	for m: Variant in price:
		var short := int(price[m]) - MaterialPurse.amount(data, StringName(m))
		if short > 0:
			out[StringName(m)] = short
	return out


func state(data: Dictionary, def: OficiosDef) -> State:
	match kind:
		Kind.TRADE:
			if Oficios.order_state(data, def) != Oficios.Order.DONE:
				return State.LOCKED
			if Vendor.can_trade(data, def, index):
				return State.CAN
			return State.SHORT if not missing(data, def).is_empty() else State.FULL
		Kind.OBRA:
			match Vendor.state(data, def, obra):
				Vendor.State.DONE:
					return State.MADE
				Vendor.State.LOCKED:
					return State.LOCKED
			return State.CAN if missing(data, def).is_empty() else State.SHORT
	match Discern.problem(data, index):
		Discern.Problem.OWNED:
			return State.MADE
		Discern.Problem.NEEDS:
			return State.NEEDS
		Discern.Problem.SHORT:
			return State.SHORT
	return State.CAN


## The beam's tilt toward what is given, in degrees (the more is given, the more it leans).
func tilt(def: OficiosDef) -> float:
	if kind != Kind.TRADE:
		return TILT_FIXED
	return clampf(TILT_MIN + 0.4 * float((def.trades[index] as Dictionary)["give_n"]), TILT_MIN, TILT_MAX)


## Makes the deal by the rules of its kind (the caller writes the save). False when it cannot.
func commit(data: Dictionary, def: OficiosDef) -> bool:
	match kind:
		Kind.TRADE:
			return Vendor.trade(data, def, index)
		Kind.OBRA:
			return Vendor.build(data, def, obra)
	return Discern.buy(data)


func title() -> String:
	match kind:
		Kind.TRADE:
			return T.t(&"vendor_trade")
		Kind.OBRA:
			return T.t(obra.name_key)
	return T.t("discern_%d" % index)


## What it changes, in words with its numbers.
func effect(def: OficiosDef) -> String:
	match kind:
		Kind.TRADE:
			var t: Dictionary = def.trades[index]
			return T.t(&"vendor_read_trade", {"give_n": int(t["give_n"]), "give": MaterialCount.short_of(StringName(t["give"])),
				"get_n": int(t["get_n"]), "get": MaterialCount.short_of(StringName(t["get"]))})
		Kind.OBRA:
			return T.t(obra.desc_key)
	return T.t("discern_%d_desc" % index)


## The state in a few words ("Pode trocar", "Faltam 12 de Prata"...).
func state_text(data: Dictionary, def: OficiosDef) -> String:
	match state(data, def):
		State.CAN:
			return T.t(&"vendor_can_trade") if kind == Kind.TRADE else T.t(&"vendor_can_build")
		State.SHORT:
			return T.t(&"vendor_short", {"list": short_list(missing(data, def))})
		State.FULL:
			return T.t(&"vendor_full")
		State.NEEDS:
			return T.t(&"vendor_after", {"name": T.t("discern_%d" % (index - 1))})
		State.MADE:
			return T.t(&"vendor_made") if kind == Kind.OBRA else T.t(&"discern_owned")
	return T.t(&"vendor_closed")


## "4 de Prata" or "5 de Prata e 1 de Esmeralda".
static func short_list(missing_: Dictionary) -> String:
	var parts := PackedStringArray()
	for m: Variant in missing_:
		parts.append(T.t(&"vendor_of", {"n": int(missing_[m]), "name": MaterialCount.short_of(StringName(m))}))
	if parts.size() > 1:
		return T.t(&"and_join", {"a": ", ".join(parts.slice(0, parts.size() - 1)), "b": parts[-1]})
	return parts[0] if not parts.is_empty() else ""
