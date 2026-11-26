class_name BoonNeeds
extends RefCounted
## SW-B3: what a Blessing asks for before it can come on a card, read from the data it already has (nothing new to
## author): an Elo asks one Blessing of each list in `requires_sets`; a move tag (`needs_tag`) asks the hero's combo for
## a finisher or a spin; a Blessing of Shift asks the ultimate open. Lines are plain text in the player's language,
## one per requirement, empty when it asks nothing.
##   BoonNeeds.lines(boon, catalog)    # ["Pede Golpe em Brasa ou Golpe de Gelo", ...]

## The most names a list says before "outras".
const SHOWN := 3
const TAG_KEYS := {&"finisher": &"need_tag_finisher", &"spin": &"need_tag_spin"}


## The requirement lines of a Blessing. catalog: every Blessing (to skip the ones kept out of the draw; empty: none skipped).
## ult_open: the Golpe Supremo milestone is open; "Pede o Golpe Supremo" shows only while it is closed (sweep P2-8).
static func lines(b: Boon, catalog: Array[Boon] = [], ult_open := false) -> PackedStringArray:
	var out := PackedStringArray()
	if b == null:
		return out
	for list in b.requires_sets:
		var names := PackedStringArray()
		for id in list:
			var other := _find(catalog, StringName(id))
			if catalog.is_empty() or (other != null and not other.reserve):
				names.append(T.t("boon_" + String(id)))
		if not names.is_empty():
			# a family's list is long: three names and "outras"
			var shown := names.slice(0, SHOWN)
			if names.size() > SHOWN:
				shown.append(T.t(&"need_others"))
			out.append(T.t(&"need_set", {"names": T.t(&"need_or").join(shown)}))
	if not b.needs_all.is_empty():
		var asks := PackedStringArray()
		for cap in b.needs_all:
			asks.append(cap_name(cap))
		out.append(T.t(&"need_set", {"names": T.t(&"need_and").join(asks)}))
	if b.needs_tag != &"" and TAG_KEYS.has(b.needs_tag):
		out.append(T.t(TAG_KEYS[b.needs_tag]))
	if b.slot == Boon.Slot.ULT and not ult_open:
		out.append(T.t(&"need_ult"))
	return out


## V1: how a requirement of Boon.needs_all reads: a Blessing by its name, a capability or an angel by its own word.
static func cap_name(cap: String) -> String:
	var key := "need_cap_" + cap.replace(":", "_")
	if T.table != null and T.table.entries.has(key):
		return T.t(key)
	return T.t("boon_" + cap)


static func _find(catalog: Array[Boon], id: StringName) -> Boon:
	for x in catalog:
		if x.id == id:
			return x
	return null
