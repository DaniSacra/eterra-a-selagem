class_name MedallionNav
extends RefCounted
## What the Gifts medallion knows without drawing (docs/art/dons_medallion_spec.md 4 and 7): where each node is, which
## nodes a prerequisite joins (the lines), where the focus goes on a direction and on LB / RB. Built from the hero's
## MedallionDef (places) and Talents catalog (rules); a new Gift or hero needs no code here.

## Half the cone of a direction press.
const CONE := deg_to_rad(30.0)

var def: MedallionDef
var catalog: Array[TalentDef]
## id -> Vector2 (centre of the node, 1280 x 720 space).
var pos: Dictionary = {}
## id -> sector key (the branch of the Gift; -1 the crown and the ultimates).
var sector: Dictionary = {}
## Node ids in clockwise order from the crown's left ultimate.
var order: Array[StringName] = []
## The branches, clockwise from twelve o'clock by the angle of their innermost node: [{branch, first (the entry's id)}].
var branches: Array[Dictionary] = []


func _init(p_def: MedallionDef, p_catalog: Array[TalentDef]) -> void:
	def = p_def
	catalog = p_catalog
	for n in def.nodes:
		pos[n.id] = def.position_of(n)
		var t := talent(n.id)
		sector[n.id] = -1 if t == null else int(t.branch)
	var ids: Array[StringName] = []
	for n in def.nodes:
		ids.append(n.id)
	ids.sort_custom(func(a: StringName, b: StringName) -> bool:
		var na := def.find(a)
		var nb := def.find(b)
		if not is_equal_approx(_clock(na.angle), _clock(nb.angle)):
			return _clock(na.angle) < _clock(nb.angle)
		return na.radius < nb.radius)
	order = ids
	branches = _branches()


## The angle as a turn that starts a little left of the crown (the left ultimate comes first).
static func _clock(angle: float) -> float:
	return angle - 360.0 if angle >= 330.0 else angle


func talent(id: StringName) -> TalentDef:
	for t in catalog:
		if t.id == id:
			return t
	return null


## The node of a direction press from `from`: the nearest inside the cone, else the nearest on that side, else the
## nearest of all. `dir` is a screen direction (y down).
func neighbor(from: StringName, dir: Vector2) -> StringName:
	var here: Vector2 = pos[from]
	var best := &""
	var best_d := INF
	for id: StringName in order:
		if id == from:
			continue
		var d: Vector2 = (pos[id] as Vector2) - here
		if absf(dir.angle_to(d)) <= CONE and d.length() < best_d:
			best = id
			best_d = d.length()
	if best != &"":
		return best
	for id: StringName in order:
		if id != from and dir.dot((pos[id] as Vector2) - here) > 0.0 and here.distance_to(pos[id]) < best_d:
			best = id
			best_d = here.distance_to(pos[id])
	return best if best != &"" else nearest(from)


func nearest(from: StringName) -> StringName:
	var best := from
	var best_d := INF
	for id: StringName in order:
		if id != from and (pos[from] as Vector2).distance_to(pos[id]) < best_d:
			best = id
			best_d = (pos[from] as Vector2).distance_to(pos[id])
	return best


## The branches of the medallion, clockwise from twelve o'clock: {branch, first (the node nearest the centre)}.
func _branches() -> Array[Dictionary]:
	var by: Dictionary = {}
	for n in def.nodes:
		var t := talent(n.id)
		if t == null:
			continue
		if not by.has(t.branch) or n.radius < def.find(by[t.branch]).radius:
			by[t.branch] = n.id
	var out: Array[Dictionary] = []
	for b: int in by:
		out.append({"branch": b, "first": by[b]})
	out.sort_custom(func(x: Dictionary, y: Dictionary) -> bool:
		return posmod(def.find(x.first).angle, 360.0) < posmod(def.find(y.first).angle, 360.0))
	return out


## The next (step 1) or previous (step -1) branch, clockwise, entered at its first node; the crown at the centre is one
## stop of the round (LB and RB), and it wraps.
func sector_step(from: StringName, step: int) -> StringName:
	var stops: Array[StringName] = [MedallionDef.CROWN_ID]
	for b in branches:
		stops.append(b.first)
	var at := 0
	if sector.get(from, -1) != -1:
		for i in branches.size():
			if branches[i].branch == sector[from]:
				at = i + 1
	return stops[posmod(at + step, stops.size())]


## The lines "from the centre": each entry to the crown, each middle to its branch's entry, each apex to its branch's
## middles; pairs [a, b] (the farther node first). Only between nodes this medallion has.
func edges() -> Array:
	var out: Array = []
	for t in catalog:
		if not pos.has(t.id):
			continue
		if t.tier == TalentDef.Tier.ENTRY:
			out.append([t.id, MedallionDef.CROWN_ID])
			continue
		for o in catalog:
			if o.branch == t.branch and int(o.tier) == int(t.tier) - 1 and pos.has(o.id):
				out.append([t.id, o.id])
	return out
