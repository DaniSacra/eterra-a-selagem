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


## The Sepulchral Eruptions: up to count circles of radius r, the first on the paladin (moved a little away from his
## way out), the rest around him but never in the lane of lane_deg degrees that points from him to `toward` (the
## middle of the hall), and only where floor (a rectangle) is. Some near him, never a cage.
static func eruptions(player: Vector2, count: int, radius: float, toward: Vector2, lane_deg: float, floor_rect: Rect2, rng: RandomNumberGenerator) -> PackedVector2Array:
	var out := PackedVector2Array()
	if count <= 0:
		return out
	var way := toward - player
	var lane := way.angle() if way.length() > 1.0 else rng.randf() * TAU
	var half := deg_to_rad(lane_deg) * 0.5
	# the first: on him, nudged against his way out (his escape is shorter than its radius)
	out.append(player - Vector2.from_angle(lane) * radius * rng.randf_range(0.0, 0.35))
	var tries := 0
	while out.size() < count and tries < 24:
		tries += 1
		# outside the lane, a little past it on either side
		var off := rng.randf_range(half + deg_to_rad(15.0), TAU - half - deg_to_rad(15.0))
		var at := player + Vector2.from_angle(lane + off) * rng.randf_range(radius * 2.0 + 0.8, radius * 2.0 + 4.0)
		if not floor_rect.has_point(at):
			continue
		var apart := true
		for o in out:
			if o.distance_to(at) < radius * 1.6:
				apart = false
		if apart:
			out.append(at)
	return out


## The ritual ends when its time is up, or when everything it raised has fallen.
static func ritual_over(elapsed: float, max_time: float, raised: int, standing: int) -> bool:
	return elapsed >= max_time or (raised > 0 and standing <= 0)


## Most summons standing at once in this phase (caps: one per phase, the last holds after; empty: none).
static func adds_cap(caps: PackedInt32Array, phase: int) -> int:
	if caps.is_empty():
		return 0
	return caps[clampi(phase - 1, 0, caps.size() - 1)]


## How many of `want` may rise with `standing` already up under `cap`.
static func summon_count(want: int, standing: int, cap: int) -> int:
	return EncounterGen.room_for(standing, cap, want)
