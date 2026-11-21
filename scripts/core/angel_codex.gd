class_name AngelCodex
extends RefCounted
## The Compêndio's Anjos tab (Rejogabilidade, Fatia 3), pure: what the save knows of each angel, kept at the end of
## every descent (RunAward.codex: codex.angels.<id>, met = times it came to a meeting or a door, chosen = times its
## Blessings were taken, blessed = Blessings of its family carried to the end). An angel never met is unknown ("???"
## on the page, only its seal's outline). The UI builds the page.
##
## API: AngelCodex.entries(data) -> Array[Dictionary] {id, def (AngelDef), known, met, chosen, blessed} in the order
## of the angels' data; AngelCodex.count(data) -> [known, all].


static func entries(data: Dictionary, catalog: Array[AngelDef] = []) -> Array[Dictionary]:
	if catalog.is_empty():
		catalog = Encounter.load_catalog()
	var seen: Dictionary = (data.get("codex", {}) as Dictionary).get("angels", {})
	var out: Array[Dictionary] = []
	for a in catalog:
		var e: Dictionary = seen.get(String(a.id), {})
		var met := int(e.get("met", 0))
		out.append({"id": a.id, "def": a, "known": met > 0, "met": met, "chosen": int(e.get("chosen", 0)),
			"blessed": int(e.get("blessed", 0))})
	return out


static func count(data: Dictionary, catalog: Array[AngelDef] = []) -> Array[int]:
	var all := entries(data, catalog)
	return [all.filter(func(e: Dictionary) -> bool: return e.known).size(), all.size()]


## A descent's part (RunAward.codex): the meetings (Encounters.meetings) and the Blessings carried to the end.
static func keep(data: Dictionary, meetings: Array[Dictionary], carried: Array[Boon], catalog: Array[AngelDef] = []) -> void:
	if catalog.is_empty():
		catalog = Encounter.load_catalog()
	for m in meetings:
		for id: Variant in m.get("offered", []):
			SaveData.codex_add(data, "angels", String(id), "met")
		if String(m.get("chose", "")) != "":
			SaveData.codex_add(data, "angels", String(m.chose), "chosen")
	for b in carried:
		for a in catalog:
			if a.family == b.family:
				SaveData.codex_add(data, "angels", String(a.id), "blessed")
