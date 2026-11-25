class_name NodeTip
extends RefCounted
## What the tip of a Videira node says (SW-M2), pure: its name and text, the price in its material and how much the save
## holds, what the node changes now and after it ("+10 -> +15", from the node's real mods), and the node to open first
## when it has a requirement. Only presentation: nothing here spends or decides.
##   var tip := NodeTip.of_vine(vine, Save.data, &"vida_2")
##   tip.name_key, tip.desc_key, tip.material, tip.cost, tip.have, tip.state, tip.needs (a node name key or &"")
##   tip.has_values, tip.now_text(), tip.next_text()

enum Unit { NONE, FLAT, PERCENT }

## How each stat reads. A stat not here (a merchant, one more item) is a switch, not a number: no "now and next".
const UNITS := {
	&"max_hp": Unit.FLAT, &"room_heal": Unit.FLAT,
	&"rise_share": Unit.PERCENT, &"silver_pct": Unit.PERCENT, &"memory_pct": Unit.PERCENT, &"material_pct": Unit.PERCENT,
}

var id: StringName
var name_key: StringName
var desc_key: StringName
var material: StringName
var cost := 0
var have := 0
var missing := 0
var state: Vine.State = Vine.State.LOCKED
## The name key of the node that must be bought first (&"" when none, or already owned).
var needs: StringName = &""
var has_values := false
var now := 0.0
var next := 0.0
var unit: Unit = Unit.NONE


static func of_vine(vine: Vine, data: Dictionary, node_id: StringName) -> NodeTip:
	var tip := NodeTip.new()
	var n := vine.find(node_id)
	if n == null:
		return tip
	tip.id = n.id
	tip.name_key = n.name_key
	tip.desc_key = n.desc_key
	tip.material = n.material
	tip.cost = n.cost
	tip.have = vine.balance(data, n.id)
	tip.missing = vine.missing(data, n.id)
	tip.state = vine.state(data, n.id)
	if n.requires != &"" and not vine.owns(data, n.requires):
		var before := vine.find(n.requires)
		tip.needs = before.name_key if before != null else &""
	if not n.mods.is_empty():
		var mod := n.mods[0]
		tip.unit = UNITS.get(mod.stat, Unit.NONE)
		if tip.unit != Unit.NONE:
			tip.has_values = true
			tip.now = _owned_sum(vine, data, mod.stat)
			tip.next = tip.now + (0.0 if vine.owns(data, n.id) else _gain_through(vine, data, n, mod.stat))
	return tip


## What buying this node brings of a stat, with the nodes before it that are not owned yet (a locked node shows the total
## it will have once the way to it is open).
static func _gain_through(vine: Vine, data: Dictionary, n: VineNode, stat: StringName) -> float:
	var total := 0.0
	var at := n
	while at != null and not vine.owns(data, at.id):
		for mod in at.mods:
			if mod.stat == stat:
				total += mod.base
		at = vine.find(at.requires) if at.requires != &"" else null
	return total


## What the owned nodes give of one stat today.
static func _owned_sum(vine: Vine, data: Dictionary, stat: StringName) -> float:
	var total := 0.0
	for n in vine.owned(data):
		for mod in n.mods:
			if mod.stat == stat:
				total += mod.base
	return total


func now_text() -> String:
	return fmt(now, unit)


func next_text() -> String:
	return fmt(next, unit)


## "+10" or "+25%" (a share stored as 0.25 reads 25%).
static func fmt(value: float, u: Unit) -> String:
	if u == Unit.PERCENT:
		return "+%d%%" % roundi(value * 100.0)
	return "+%d" % roundi(value)
