class_name HubGate
extends RefCounted
## The Santuário opens bit by bit (Daniel, 2026-11-21): the player learns one station at a time. Pure, read from the save:
##   Portal: always. Livro and Árvore de Dons: once a descent was played (runs >= TREE_BOOK_RUNS). Forja: the first guardian
##   beaten, or Prata enough for the Temperar I (what comes first). Vendedor: the third return (runs >= VENDOR_RUNS) or the
##   first Pedra Funda. Videira (V2, its own station): what opened the Forjador's choice, Vine.open. Heróis (PT-9, beside the
##   Vendedor): when he opens (or Morvath was sealed), and the Maga inside stays locked until the first Morvath is sealed (SaveData.hero_open). Alquimista: off (FLAGS). Juramentos (not a station) open on the first victory, as before.
## A save that already used a station (forge bought, Gift opened, an order, an Obra) counts it open: nobody loses what
## they have. `data.hub.presented` keeps the stations whose opening was shown (once); version 9 of the save marks the
## open ones of an older file as shown. A closed station has no sign, focus, use or floating name (Hub); its look is the
## closed one (HubLook.set_closed).
##   HubGate.is_open(Save.data, HubPlan.SMITH) -> bool
##   HubGate.to_present(Save.data) -> the stations open and not yet shown, in order
##   HubGate.mark_presented(Save.data, ids)

const GATED: Array[StringName] = [HubPlan.TREE, HubPlan.BOOK, HubPlan.SMITH, HubPlan.VENDOR, HubPlan.VINE, HubPlan.HEROES]
const FLAGS := {&"alchemist": false}
const TREE_BOOK_RUNS := 1
const VENDOR_RUNS := 3
## The first Temperar's price when no catalog is at hand (tests); the data's wins (Forge.load_catalog).
const TEMPER_I_SILVER := 15
## The sentence a station says when it opens (data/text_pt.tres).
const TEXT := {HubPlan.TREE: &"hub_open_tree", HubPlan.BOOK: &"hub_open_book", HubPlan.SMITH: &"hub_open_smith",
	HubPlan.VENDOR: &"hub_open_vendor", HubPlan.VINE: &"hub_open_vine", HubPlan.HEROES: &"hub_open_heroes"}

static var _temper_cost := -1


static func is_open(data: Dictionary, id: StringName, all := false) -> bool:
	if all or not GATED.has(id):
		return true
	match id:
		HubPlan.TREE, HubPlan.BOOK:
			return _tree_book(data)
		HubPlan.SMITH:
			return _smith(data)
		HubPlan.VENDOR:
			return _vendor(data)
		HubPlan.VINE:
			return Vine.open(data)
		HubPlan.HEROES:
			return _vendor(data) or Juramentos.unlocked(data)
	return true


## The stations that stand open (the portal included).
static func open_ids(data: Dictionary, all := false) -> Array[StringName]:
	var out: Array[StringName] = []
	for id in HubPlan.STATIONS:
		if is_open(data, id, all):
			out.append(id)
	return out


## Open stations whose opening was not shown yet, in GATED order.
static func to_present(data: Dictionary) -> Array[StringName]:
	var out: Array[StringName] = []
	var done := presented(data)
	for id in GATED:
		if is_open(data, id) and not done.has(String(id)):
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


static func _tree_book(data: Dictionary) -> bool:
	if int(data.get("runs", 0)) >= TREE_BOOK_RUNS:
		return true
	return not (SaveData.hero(data, SaveData.FIRST_HERO).get("opened", []) as Array).is_empty()


static func _smith(data: Dictionary) -> bool:
	var hero := SaveData.hero(data, SaveData.FIRST_HERO)
	if int((hero.get("firsts", {}) as Dictionary).get("guardian", 0)) > 0:
		return true
	if MaterialPurse.amount(data, MaterialPurse.SILVER) >= temper_cost():
		return true
	if not (hero.get("tools", []) as Array).is_empty():
		return true
	var f := Forge.block(data)
	if int(f.get("temper", 0)) > 0:
		return true
	for k: String in Forge.LIST_KEY.values():
		if not (f.get(k, []) as Array).is_empty():
			return true
	return Oficios.noted(data) or not (Oficios.block(data).tools as Array).is_empty()


static func _vendor(data: Dictionary) -> bool:
	if int(data.get("runs", 0)) >= VENDOR_RUNS:
		return true
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
