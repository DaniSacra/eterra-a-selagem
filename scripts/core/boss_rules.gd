class_name BossRules
extends RefCounted
## The pure part of a boss fight: phases by life, the patterns of the attacks (always with a way out), the ritual's
## end and the ceiling of the summons. Tested in tests/test_boss.gd.


## The phase (1 to thresholds.size() + 1) for a share of life left; thresholds descend (0.66, 0.33, 0.15).
static func phase_for(hp_ratio: float, thresholds: PackedFloat32Array) -> int:
	var phase := 1
	for t in thresholds:
		if hp_ratio <= t:
			phase += 1
	return phase


## Share of life the boss cannot drop under while in this phase (the next threshold; 0 in the last phase): the blow
## that crosses it stops there, so every phase begins once and in order.
static func hp_floor(phase: int, thresholds: PackedFloat32Array) -> float:
	return thresholds[phase - 1] if phase >= 1 and phase <= thresholds.size() else 0.0


## The phase to go to now: one step at a time, never back.
static func next_phase(phase: int, hp_ratio: float, thresholds: PackedFloat32Array) -> int:
	return phase + 1 if phase_for(hp_ratio, thresholds) > phase else phase


## Directions of a ring of bullets, turned by an offset (radians).
static func ring(count: int, offset: float) -> PackedVector2Array:
	var out := PackedVector2Array()
	for i in count:
		out.append(Vector2.from_angle(offset + TAU * i / count))
	return out


## Directions of a fan aimed at a target.
static func fan(aim: Vector2, count: int, spread: float) -> PackedVector2Array:
	var out := PackedVector2Array()
	for i in count:
		var k := 0.0 if count == 1 else float(i) / (count - 1) - 0.5
		out.append(aim.rotated(k * spread))
	return out


## Daniel 2026-11-21 ("os golpes do boss tem q ser igual ao do miniboss que na hora q está carregando vai perseguindo o
## herói até soltar o golpe"): a blow's aim turns toward the paladin through its wind-up, at most max_turn radians this
## step, and holds still once `since` is within `lock` seconds of the release (the moment to dodge).
static func follow_aim(dir: Vector2, to: Vector2, max_turn: float, since: float, windup: float, lock: float) -> Vector2:
	if since >= windup - lock or to.length_squared() < 0.04 or dir.length_squared() < 0.0001:
		return dir
	return dir.rotated(clampf(dir.angle_to(to), -max_turn, max_turn))


## Where a moving paladin is aimed at: his way times the flight's time, but only `lead` of it (never a perfect lead).
static func aim_at(from: Vector2, target: Vector2, velocity: Vector2, speed: float, lead: float) -> Vector2:
	var flight := from.distance_to(target) / maxf(speed, 0.1)
	var at := target + velocity * minf(flight, 1.0) * clampf(lead, 0.0, 1.0)
	var d := at - from
	return d.normalized() if d.length() > 0.01 else Vector2.DOWN


## The Blades of the Souls: two crescents that part from each other. One flies at the aim, the other spread degrees
## to one side (side +1 or -1): the wedge between them is the way out.
static func soul_pair(aim: Vector2, spread_deg: float, side: float) -> PackedVector2Array:
	return PackedVector2Array([aim, aim.rotated(deg_to_rad(spread_deg) * signf(side if side != 0.0 else 1.0))])


## The Storm of the Six Souls: count crescents all around, turned by offset (degrees), each moved by up to jitter
## degrees, but never two neighbours closer than min_gap degrees (a way out always stays open).
static func storm(count: int, offset_deg: float, jitter_deg: float, min_gap_deg: float, rng: RandomNumberGenerator) -> PackedVector2Array:
	var out := PackedVector2Array()
	if count <= 0:
		return out
	var step := 360.0 / count
	# the jitter can bring two neighbours together by twice itself: keep it within what the gap allows
	var jitter := clampf(jitter_deg, 0.0, maxf(0.0, (step - min_gap_deg) * 0.5))
	for i in count:
		var a := offset_deg + step * i + rng.randf_range(-jitter, jitter)
		out.append(Vector2.from_angle(deg_to_rad(a)))
	return out


## The smallest angle (degrees) between two neighbouring directions of a pattern.
static func min_gap(dirs: PackedVector2Array) -> float:
	var angles: Array[float] = []
	for d in dirs:
		angles.append(fposmod(rad_to_deg(d.angle()), 360.0))
	angles.sort()
	var least := 360.0
	for i in angles.size():
		var next := angles[(i + 1) % angles.size()] + (360.0 if i == angles.size() - 1 else 0.0)
		least = minf(least, next - angles[i])
	return least


## Meters a whole eruption circle keeps from the floor's edge (its rune drawn wholly on the floor).
const ERUPTION_EDGE := 0.3
## How far (a part of its radius) the circle under the paladin is nudged against his way out: 0.35 with circles of
## 2 m; with 4 m (2026-11-16) 0.2, so walking out in its warning stays possible.
const ERUPTION_NUDGE := 0.2


## The Sepulchral Eruptions: up to count circles of radius r, the first on the paladin (moved a little away from his
## way out; at the floor's edge its middle stays half its radius inside it),
## the rest around him but never in the lane of lane_deg degrees that points from him to `toward` (the middle of the
## floor), and only wholly on the floor (FloorShape, ERUPTION_EDGE inside its edge). Some near him, never a cage.
static func eruptions(player: Vector2, count: int, radius: float, toward: Vector2, lane_deg: float, floor: FloorShape, rng: RandomNumberGenerator) -> PackedVector2Array:
	var out := PackedVector2Array()
	if count <= 0:
		return out
	var way := toward - player
	var lane := way.angle() if way.length() > 1.0 else rng.randf() * TAU
	var half := deg_to_rad(lane_deg) * 0.5
	# the first: on him, nudged against his way out (his escape is shorter than its radius); at the edge it stays on
	# the floor by half its radius and still covers him
	out.append(floor.clamp(player - Vector2.from_angle(lane) * radius * rng.randf_range(0.0, ERUPTION_NUDGE), radius * 0.5))
	var tries := 0
	while out.size() < count and tries < 24:
		tries += 1
		# outside the lane, a little past it on either side
		var off := rng.randf_range(half + deg_to_rad(15.0), TAU - half - deg_to_rad(15.0))
		var at := player + Vector2.from_angle(lane + off) * rng.randf_range(radius * 2.0 + 0.8, radius * 2.0 + 4.0)
		if not floor.contains(at, radius + ERUPTION_EDGE):
			continue
		var apart := true
		for o in out:
			if o.distance_to(at) < radius * 1.6:
				apart = false
		if apart:
			out.append(at)
	return out


## Meters ahead of the paladin a way out is weighed at (BossRules.free_way): about what he walks in a warning.
const FREE_PROBE := 5.0
## Ways tried around him.
const FREE_WAYS := 24


## The way out of an attack of his for a paladin at `player` (E2, the layers): of FREE_WAYS directions, the one whose
## spot FREE_PROBE meters ahead (on the floor, a meter inside its edge) stands farthest from that attack: from his
## body plus `reach` (the scythe's half circle) and from each of his `lanes` (rays from him, half_width wide: the
## blades, the storm, the curse, the charge). The eruptions laid over that attack keep their free lane on it, so the
## two never close the same way. Toward the middle when nothing on the floor is ahead.
static func free_way(player: Vector2, boss: Vector2, reach: float, lanes: PackedVector2Array, half_width: float, floor: FloorShape) -> Vector2:
	var best := Vector2.ZERO
	var most := -INF
	for k in FREE_WAYS:
		var d := Vector2.from_angle(TAU * k / FREE_WAYS)
		var q := player + d * FREE_PROBE
		if not floor.contains(q, 1.0):
			continue
		var c := clearance(q, boss, reach, lanes, half_width)
		if c > most + 0.001:
			most = c
			best = d
	if best == Vector2.ZERO:
		var mid := floor.center - player
		return mid.normalized() if mid.length() > 0.01 else Vector2.DOWN
	return best


## How far a spot stands from an attack (negative inside it): his body plus reach, and his lanes.
static func clearance(q: Vector2, boss: Vector2, reach: float, lanes: PackedVector2Array, half_width: float) -> float:
	var rel := q - boss
	var c := rel.length() - reach
	for l in lanes:
		var along := rel.dot(l)
		var off := absf(rel.cross(l)) if along > 0.0 else rel.length()
		c = minf(c, off - half_width)
	return c


## The ritual ends when its time is up, or when everything it raised has fallen (those still to rise count as
## standing: killing the first never ends it before the rest are up).
static func ritual_over(elapsed: float, max_time: float, raised: int, standing: int, pending: int = 0) -> bool:
	return elapsed >= max_time or (raised + pending > 0 and standing + pending <= 0)


## C1d: how long the ritual may last with `dead` of its conductors fallen (never under 0).
static func ritual_limit(max_time: float, shorten: float, dead: int) -> float:
	return maxf(0.0, max_time - shorten * float(maxi(dead, 0)))


## C1d: whether a Ruptura is due: the phase is its phase or later, the fight has a Ruptura, and its clock ran out.
static func rupture_due(phase: int, from_phase: int, every: float, left: float) -> bool:
	return every > 0.0 and phase >= from_phase and left <= 0.0


## Most summons standing at once in this phase (caps: one per phase, the last holds after; empty: none).
static func adds_cap(caps: PackedInt32Array, phase: int) -> int:
	if caps.is_empty():
		return 0
	return caps[clampi(phase - 1, 0, caps.size() - 1)]


## How many of `want` may rise with `standing` already up under `cap`.
static func summon_count(want: int, standing: int, cap: int) -> int:
	return EncounterGen.room_for(standing, cap, want)


## How many of `want` may be called now: those still rising (pending) count as standing, and over the whole fight
## never more than total_cap (total: how many were already called).
static func reinforce_room(want: int, standing: int, pending: int, cap: int, total: int, total_cap: int) -> int:
	return clampi(mini(summon_count(want, standing + pending, cap), total_cap - total), 0, maxi(want, 0))


## When each of n rises after the call (seconds): the first after `first`, then one every `stagger`.
static func rise_times(n: int, first: float, stagger: float) -> PackedFloat32Array:
	var out := PackedFloat32Array()
	for i in maxi(n, 0):
		out.append(first + stagger * i)
	return out


## The order a wave of crescents leaves in: the one nearest the aim first, then outwards one on each side in turn
## (each its own moment and its own lane, never one burst). A permutation of 0..dirs.size()-1.
static func storm_order(dirs: PackedVector2Array, aim: Vector2) -> PackedInt32Array:
	var out := PackedInt32Array()
	var n := dirs.size()
	if n == 0:
		return out
	var first := 0
	for i in n:
		if absf(aim.angle_to(dirs[i])) < absf(aim.angle_to(dirs[first])):
			first = i
	out.append(first)
	for k in range(1, n):
		# 1, -1, 2, -2... around the ring from the first
		var step := ceili(k / 2.0) * (1 if k % 2 == 1 else -1)
		var i := posmod(first + step, n)
		if not out.has(i):
			out.append(i)
	for i in n:
		if not out.has(i):
			out.append(i)
	return out


## A warning while the paladin is cursed: longer by as much as he is slower (speed_scale: what he keeps of his
## walking), so walking out of it stays as possible as uncursed (the curse never makes a blow unavoidable).
static func cursed_windup(windup: float, speed_scale: float) -> float:
	return windup / clampf(speed_scale, 0.1, 1.0)


## A combination may begin only when nothing of the first attack is left: no warning of his on the floor and none of
## his shots in the air (so every blow of a combination keeps its whole warning).
static func chain_ready(warnings_live: int, shots_live: int) -> bool:
	return warnings_live <= 0 and shots_live <= 0


## Seconds spent in each phase: phase_at holds when each phase after the first began (seconds from the start of
## the fight), `end` when the fight ended. One value per phase reached.
static func phase_times(phase_at: Array, end: float) -> Array[float]:
	var out: Array[float] = []
	var from := 0.0
	for at: float in phase_at:
		out.append(snappedf(maxf(0.0, at - from), 0.1))
		from = at
	out.append(snappedf(maxf(0.0, end - from), 0.1))
	return out
