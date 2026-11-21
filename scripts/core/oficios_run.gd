class_name OficiosRun
extends RefCounted
## A descent's part of the Ofícios (Roteiro A; game.oficios): what the save allowed at its start and what happened,
## banked once at its end (Oficios.bank). Pure.

## At the start (from the save, or --oficios=noted,head,pick,preview for the robot and captures).
var has_pick := false
var wants_head := false
var pity_due := false
var preview := false
## The head's room marked on this descent's map (RunMap.mark_finds).
var marked := false
## What happened.
var noted := false
var head_found := false
var head_by := ""  # "room" or "pity"
var head_id := ""  # the find's id once found
var passed_guardian := false
var stones := 0
var veins := 0
var gather_s := 0.0


## The start of a descent from save data (a person's) or from a dev list.
static func from_save(data: Dictionary, def: OficiosDef) -> OficiosRun:
	var r := OficiosRun.new()
	r.has_pick = Oficios.has_tool(data, def)
	r.wants_head = Oficios.head_wanted(data, def)
	r.pity_due = Oficios.pity_due(data, def)
	r.preview = Oficios.has_recipe(data, def.order_gives)
	return r


## --oficios=noted,pick,pity,preview: noted (the head is wanted), pity (and due), pick, preview.
static func from_words(words: PackedStringArray) -> OficiosRun:
	var r := OficiosRun.new()
	r.has_pick = words.has("pick")
	r.wants_head = (words.has("noted") or words.has("pity")) and not r.has_pick
	r.pity_due = words.has("pity") and r.wants_head
	r.preview = words.has("preview")
	return r


## Whether a vein may still be extracted on this descent.
func may_extract(def: OficiosDef) -> bool:
	return has_pick and veins < def.veins_max


## The RESULT's and the log's fields (RunLog version 6): finds, gather, pity.
func report() -> Dictionary:
	return {"finds": [head_id] if head_found else [], "find_by": head_by, "marked": marked,
		"gather": {"veins": veins, "stones": stones, "gather_s": snappedf(gather_s, 0.01), "noted": noted},
		"pity": {"due": pity_due, "passed_guardian": passed_guardian}}
