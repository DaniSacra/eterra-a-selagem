class_name MedallionNav
extends RefCounted
## What the Gifts medallion knows without drawing (docs/art/dons_medallion_spec.md 4 and 7): where each node is, which
## nodes a prerequisite joins (the lines), where the focus goes on a direction and on LB / RB. Built from the hero's
## MedallionDef (places) and Talents catalog (rules); a new Gift or hero needs no code here.

## Half the cone of a direction press, and the farthest an edge of the lines runs along the ring.
const CONE := deg_to_rad(30.0)
const EDGE_MAX := 130.0
## Nodes at the same angle with another radius are a spur: always linked to the ring.
const SPUR_ANGLE := 0.5

var def: MedallionDef
var catalog: Array[TalentDef]
## id -> Vector2 (centre of the node, 1280 x 720 space).
var pos: Dictionary = {}
## id -> sector key (the branch of the Gift; -1 the crown and the ultimates).
var sector: Dictionary = {}
## Node ids in clockwise order from the crown's left ultimate.
var order: Array[StringName] = []


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


## The first node of the next (step 1) or previous (step -1) sector, clockwise; wraps. The crown and the ultimates are one.
func sector_step(from: StringName, step: int) -> StringName:
	var runs: Array[StringName] = []  # first node of each run of one sector
	var cur := 999
	for id: StringName in order:
		if sector[id] != cur:
			cur = sector[id]
			runs.append(id)
	var at := 0
	for i in runs.size():
		if order.find(from) >= order.find(runs[i]):
			at = i
	# the crown's sector (with the ultimates round it) is entered at the crown itself
	for i in runs.size():
		if sector[runs[i]] == -1:
			runs[i] = MedallionDef.CROWN_ID
	return runs[posmod(at + step, runs.size())]


## The prerequisite lines: pairs [a, b] of node ids (a Gift to the one it needs, a spur to the ring node at its angle), only between neighbours of the ring.
func edges() -> Array:
	var out: Array = []
	var seen := {}
	for t in catalog:
		if not pos.has(t.id):
			continue
		var wants: Array[TalentDef] = []
		for o in catalog:
			if o.id == t.needs:
				wants.append(o)
		for w in wants:
			if pos.has(w.id) and (pos[t.id] as Vector2).distance_to(pos[w.id]) <= EDGE_MAX:
				_add(out, seen, t.id, w.id)
	for n in def.nodes:
		for m in def.nodes:
			if n.id != m.id and absf(n.angle - m.angle) < SPUR_ANGLE and absf(n.radius - MedallionDef.RING) > 1.0 \
					and absf(m.radius - MedallionDef.RING) < 1.0:
				_add(out, seen, n.id, m.id)
	return out


func _add(out: Array, seen: Dictionary, a: StringName, b: StringName) -> void:
	var key := "%s|%s" % [a, b] if String(a) < String(b) else "%s|%s" % [b, a]
	if not seen.has(key):
		seen[key] = true
		out.append([a, b])
