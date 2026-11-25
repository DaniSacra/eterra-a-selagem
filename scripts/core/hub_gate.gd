class_name HubGate
extends RefCounted
## The Santuário opens bit by bit (Daniel, 2026-11-21; SW-O5, 2026-11-25): the player learns one station at a time. Pure,
## read from the save. WHEN a station is earned is data now (Milestones, data/milestones/): Árvore after the first descent,
## Forja and Livro on the third, Videira on the fourth, Vendedor on the fifth (or the first Pedra Funda), the Ultimate on
## the sixth with Mastery 2, the Estandarte after the first victory. At most ONE new thing is shown per visit: the lowest
## milestone reached and not shown yet (begin_visit fixes it for the whole visit, so the second waits for the next return).
## A save that already used a station (forge bought, Gift opened, an order, an Obra, a Videira node) or was shown it
## (`data.hub.presented`) keeps it open, whatever the milestones ask now: nobody loses what they have. Portal: always.
## Alquimista: off (FLAGS). A closed station has no sign, focus, use or floating name (Hub); its look is the closed one
## (HubLook.set_closed). `data.hub.presented` keeps the openings shown (once); version 9 of the save marks the earned
## ones of an older file as shown (Milestones.grandfather does the same for the milestones' version).
##   HubGate.is_open(Save.data, HubPlan.SMITH) -> bool       (what the Hub shows: the visit's one new thing included)
##   HubGate.open_ids(Save.data) -> the stations the save has earned (the limit of one per visit not applied)
##   HubGate.to_present(Save.data) -> [the one opening of this visit] (or [])
##   HubGate.begin_visit(Save.data) / end_visit()             (Hub: _ready / _exit_tree)
##   HubGate.mark_presented(Save.data, ids)

const GATED: Array[StringName] = [HubPlan.TREE, HubPlan.BOOK, HubPlan.SMITH, HubPlan.VENDOR, HubPlan.VINE, HubPlan.HEROES]
const FLAGS := {&"alchemist": false}
## The first Temperar's price when no catalog is at hand (tests); the data's wins (Forge.load_catalog).
const TEMPER_I_SILVER := 15
## The sentence an opening says (data/text_pt.tres): a station's, or the Ultimate's.
const TEXT := {HubPlan.TREE: &"hub_open_tree", HubPlan.BOOK: &"hub_open_book", HubPlan.SMITH: &"hub_open_smith",
	HubPlan.VENDOR: &"hub_open_vendor", HubPlan.VINE: &"hub_open_vine", HubPlan.HEROES: &"hub_open_heroes",
	Milestones.ULT: &"hub_open_ult"}

static var _temper_cost := -1
## The opening of this visit (begin_visit); &"" when none. Outside a visit the live next one is asked.
static var _pick: StringName = &""
static var _in_visit := false


## The Hub was entered: fixes the one new thing of this visit, so a second milestone reached waits for the next return.
static func begin_visit(data: Dictionary) -> void:
	_pick = Milestones.next_to_present(data)
	_in_visit = true


static func end_visit() -> void:
	_in_visit = false
	_pick = &""


static func visit_pick(data: Dictionary) -> StringName:
	return _pick if _in_visit else Milestones.next_to_present(data)


static func is_open(data: Dictionary, id: StringName, all := false) -> bool:
	if all or not (GATED.has(id) or id == Milestones.ULT):
		return true
	return used(data, id) or presented(data).has(String(id)) \
			or (Milestones.earned(data, id) and visit_pick(data) == id)


## The stations the save has earned (a milestone, use or having been shown), the one-per-visit limit not applied: what an
## older save marks as shown (SaveData.merged).
static func open_ids(data: Dictionary, all := false) -> Array[StringName]:
	var out: Array[StringName] = []
	for id in HubPlan.STATIONS:
		if all or not GATED.has(id) or earned(data, id):
			out.append(id)
	return out


static func earned(data: Dictionary, id: StringName) -> bool:
	return used(data, id) or presented(data).has(String(id)) or Milestones.earned(data, id)


## The opening of this visit not shown yet (a station or the Ultimate), as a list of at most one.
static func to_present(data: Dictionary) -> Array[StringName]:
	var out: Array[StringName] = []
	var id := visit_pick(data)
	if id != &"" and not presented(data).has(String(id)):
		out.append(id)
	return out


static func presented(data: Dictionary) -> Array:
	if not data.get("hub") is Dictionary:
		data["hub"] = SaveData.hub_defaults()
	var h: Dictionary = data["hub"]
	if not h.get("presented") is Array:
		h["presented"] = []
	return h["presented"]


static func mark_presented(data: Dictionary, ids: Array[StringName]) -> void:
	var done := presented(data)
	for id in ids:
		if not done.has(String(id)):
			done.append(String(id))


## What the player already did in a station: it stays open whatever the milestones ask now.
static func used(data: Dictionary, id: StringName) -> bool:
	match id:
		HubPlan.TREE, HubPlan.BOOK:
			return not (SaveData.hero(data, SaveData.FIRST_HERO).get("opened", []) as Array).is_empty()
		HubPlan.SMITH:
			return _smith_used(data)
		HubPlan.VENDOR:
			return _vendor_used(data)
		HubPlan.VINE:
			return not Vine.bought_ids(data).is_empty() or Forge.temper(data) > 0
	return false


static func _smith_used(data: Dictionary) -> bool:
	var hero := SaveData.hero(data, SaveData.FIRST_HERO)
	if not (hero.get("tools", []) as Array).is_empty():
		return true
	var f := Forge.block(data)
	if int(f.get("temper", 0)) > 0:
		return true
	for k: String in Forge.LIST_KEY.values():
		if not (f.get(k, []) as Array).is_empty():
			return true
	return Oficios.noted(data) or not (Oficios.block(data).tools as Array).is_empty()


static func _vendor_used(data: Dictionary) -> bool:
	var b := Oficios.block(data)
	for v: Variant in (b.items_total as Dictionary).values():
		if int(v) > 0:
			return true
	return not (b.orders as Dictionary).is_empty() or not (b.recipes as Array).is_empty()


## The Temperar I's silver (the catalog's first rank of the temper).
static func temper_cost() -> int:
	if _temper_cost < 0:
		_temper_cost = TEMPER_I_SILVER
		var ranks := Forge.new(Forge.load_catalog()).track(Forge.TEMPER)
		if not ranks.is_empty():
			_temper_cost = ranks[0].cost
	return _temper_cost
