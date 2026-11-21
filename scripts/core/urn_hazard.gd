class_name UrnHazard
extends RefCounted
## The oil urns (RP-12, the Hades II's barrel; docs/design/rooms_progression.md, combat_cadence.md 9.3): a blow of the
## paladin lights an urn (HazardDef.urns). From that frame its ring of urn_radius warns HazardDef.warn seconds and it
## blasts; the oil then runs down its channel (HazardDef.flow_of) at flow_speed m/s in stretches of flow_step m: each
## stretch warns flow_lead seconds before the flame reaches it (the first one inside the fuse), is struck as the flame
## reaches it and burns `burn` seconds after (UrnFloor strikes once whoever walks in). The fuse is always the same time
## from the frame the urn is lit. Once per urn per room. Asleep before HazardDef.from_progress (a blow only rings on the
## bronze). Pure: UrnFloor lays it on the floor.

enum Stage { IDLE, LIT, DONE }

var def: HazardDef
var awake := true
## Each urn's stage and the seconds since it was lit.
var stage := PackedInt32Array()
var since := PackedFloat32Array()
## Each urn's stretches of oil: [from, dir, length] per stretch, the second the flame reaches it (from the light), and
## which of them warned and struck already (1).
var stretches: Array = []
var lit_count := 0
var blasts := 0


func _init(hazard: HazardDef, is_awake := true) -> void:
	def = hazard
	awake = is_awake
	var n := def.urns.size()
	stage.resize(n)
	since.resize(n)
	for i in n:
		var list: Array = []
		var f := def.flow_of(i)
		if f != Vector4.ZERO:
			var a := Vector2(f.x, f.y)
			var b := Vector2(f.z, f.w)
			var length := a.distance_to(b)
			var dir := (b - a) / maxf(length, 0.001)
			var k := 0
			var at := 0.0
			while at < length - 0.01:
				var seg := minf(def.flow_step, length - at)
				list.append({"from": a + dir * at, "dir": dir, "length": seg,
					"reach": def.warn + (a.distance_to(def.urns[i]) + at) / maxf(def.flow_speed, 0.1),
					"armed": false, "struck": false})
				at += seg
				k += 1
		stretches.append(list)


func count() -> int:
	return def.urns.size()


## Lights urn i (a blow of his reached it). Returns whether it lit (asleep, or lit before: no).
func light(i: int) -> bool:
	if not awake or stage[i] != Stage.IDLE:
		return false
	stage[i] = Stage.LIT
	since[i] = 0.0
	lit_count += 1
	return true


## One step. Returns {"blasted": urns that blast now, "armed": [urn, stretch] pairs that begin to warn now, "reached":
## [urn, stretch] pairs the flame reaches now}.
func step(dt: float) -> Dictionary:
	var blasted := PackedInt32Array()
	var armed: Array = []
	var reached: Array = []
	for i in count():
		if stage[i] != Stage.LIT:
			continue
		var was := since[i]
		since[i] += dt
		if was < def.warn and since[i] >= def.warn:
			blasted.append(i)
			blasts += 1
		var done := since[i] >= def.warn
		for k in stretches[i].size():
			var s: Dictionary = stretches[i][k]
			if not s.armed and since[i] >= s.reach - def.flow_lead:
				s.armed = true
				armed.append([i, k])
			if not s.struck and since[i] >= s.reach:
				s.struck = true
				reached.append([i, k])
			if since[i] < s.reach + def.burn:
				done = false
		if done:
			stage[i] = Stage.DONE
	return {"blasted": blasted, "armed": armed, "reached": reached}


## Whether stretch k of urn i is burning now (struck, its burn not over).
func burning(i: int, k: int) -> bool:
	var s: Dictionary = stretches[i][k]
	return stage[i] != Stage.IDLE and s.struck and since[i] < s.reach + def.burn


## The fight is over: no urn lights any more.
func stop() -> void:
	awake = false
	for i in count():
		if stage[i] == Stage.LIT:
			stage[i] = Stage.DONE
