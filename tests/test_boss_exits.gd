extends GutTest
## Every pattern of Morvath has a way out in his round chamber (cycle C11, docs/design/boss_arena.md): with Morvath at
## 12 spots of the floor and the paladin at 12 (every pair where their bodies do not overlap), the scythe, the
## blades, the dash, the eruptions (both sequences), the storm (every wave, the crescents of the waves before still
## flying while he moves to the next one's gap) and the curse can each be escaped walking or with one dodge, after a
## person's reaction time (REACTION) and with the shortest wind-up of any phase. The floor is the chamber's own (the
## stage's boss layout), the patterns are BossRules' and the lanes are cut at the edge exactly as Boss cuts them.
## E2: so can the layers laid over his attacks late in the fight (BossAttack.layers): the storm with eruptions, the
## scythe with eruptions and the curse with eruptions (his dead rising with them stand at least summon_clear away).

const STAGE := "res://data/stages/catacombs.tres"
const DEF := "res://data/bosses/morvath.tres"
## Seconds a person needs to see a warning before moving (the bot's --bot-reaction=0.25).
const REACTION := 0.25
const DT := 1.0 / 60.0
## Directions and distances tried for a way out.
const WAYS := 32
const RINGS := 8

var def: BossDef
var floor: FloorShape
var body := 1.4
var speed := 6.75
var dodge_len := 5.6
var dodge_time := 0.2
var iframes := 0.267
## How many pairs needed the dodge (the rest walk out), by pattern: printed for the design document.
var dodged := {}
var walked := {}


func before_all() -> void:
	def = load(DEF)
	floor = (load(STAGE) as StageDef).boss_layout.floor
	body = (load("res://data/enemies/morvath.tres") as EnemyDef).radius
	var f := Feel.live()
	speed = f.speed
	dodge_time = f.dodge_time
	dodge_len = f.dodge_speed * f.dodge_time * 0.75
	iframes = f.dodge_iframes


func after_all() -> void:
	var ids := walked.keys()
	for id in dodged:
		if not ids.has(id):
			ids.append(id)
	for id in ids:
		gut.p("%s: %d pairs walk out, %d need the dodge" % [id, int(walked.get(id, 0)), int(dodged.get(id, 0))])


func _scale(phase: int) -> float:
	return BossDef.by_phase(def.windup_scale, phase, 1.0)


## Shortest wind-up of an attack over the phases it may come in.
func _windup(seconds: float, from_phase: int = 1, until_phase: int = 4) -> float:
	var least := INF
	for ph in range(from_phase, until_phase + 1):
		least = minf(least, seconds * _scale(ph))
	return least


## Morvath at 12 spots: the middle, 4 at 5 m and 7 on his edge of the floor (his body touching the balustrade).
func _boss_spots() -> PackedVector2Array:
	var out := PackedVector2Array([floor.center])
	for k in 4:
		out.append(floor.center + Vector2.from_angle(PI * 0.25 + PI * 0.5 * k) * 5.0)
	for k in 7:
		out.append(floor.center + Vector2.from_angle(TAU * k / 7.0 + 0.3) * (floor.radius - body - 0.05))
	return out


## The paladin at 12 spots: 3 close to the middle, 4 halfway, 5 on the edge of his walk (12 m).
func _hero_spots() -> PackedVector2Array:
	var out := PackedVector2Array()
	for k in 3:
		out.append(floor.center + Vector2.from_angle(TAU * k / 3.0 + 0.17) * 2.6)
	for k in 4:
		out.append(floor.center + Vector2.from_angle(PI * 0.5 * k + 0.5) * 7.0)
	for k in 5:
		out.append(floor.center + Vector2.from_angle(TAU * k / 5.0 + 0.09) * (floor.radius - 0.5))
	return out


## Every (boss, paladin) pair whose bodies do not overlap.
func _pairs() -> Array[Array]:
	var out: Array[Array] = []
	for b in _boss_spots():
		for p in _hero_spots():
			if p.distance_to(b) >= body + 0.5 + 0.1:
				out.append([b, p])
	return out


func _stand(q: Vector2, boss: Vector2) -> bool:
	return floor.contains(q, 0.5 - 0.001) and q.distance_to(boss) >= body + 0.5


## The walk from p to q passes through Morvath's body (the floor is round and convex: the rest of the way is floor).
func _through_body(p: Vector2, q: Vector2, boss: Vector2) -> bool:
	var d := q - p
	var t := clampf((boss - p).dot(d) / maxf(d.length_squared(), 0.0001), 0.0, 1.0)
	return (p + d * t).distance_to(boss) < body + 0.5 - 0.01


## Where the paladin can stand, out of `hazard`, `time` seconds after the warning shows: walking straight there, or
## dodging (dodge_len in dodge_time, through bodies) and walking on the same way. [] when there is none; else
## [the spot, true when it took the dodge].
func _way_out(p: Vector2, boss: Vector2, time: float, hazard: Callable) -> Array:
	var t := time - REACTION
	if not hazard.call(p):
		return [p, false]
	if t <= 0.0:
		return []
	var reach := speed * t
	for ring in range(1, RINGS + 1):
		for k in WAYS:
			var q := p + Vector2.from_angle(TAU * k / WAYS) * reach * ring / RINGS
			if _stand(q, boss) and not _through_body(p, q, boss) and not hazard.call(q):
				return [q, false]
	if t >= dodge_time:
		var far := dodge_len + speed * (t - dodge_time)
		for ring in range(1, RINGS + 1):
			for k in WAYS:
				var q := p + Vector2.from_angle(TAU * k / WAYS) * far * ring / RINGS
				if _stand(q, boss) and not hazard.call(q):
					return [q, true]
	return []


func _count(id: String, out: Array) -> void:
	if out.is_empty():
		return
	if out[1]:
		dodged[id] = int(dodged.get(id, 0)) + 1
	else:
		walked[id] = int(walked.get(id, 0)) + 1


## The lane a crescent sweeps from `from` along `dir` for `reach` meters (its depth and the paladin's body around it).
func _in_flight(from: Vector2, dir: Vector2, reach: float, q: Vector2) -> bool:
	var d := q - from
	var along := d.dot(dir)
	var hit := Projectiles.SOUL_DEPTH + 0.5
	return along >= -hit and along <= reach + hit and absf(d.cross(dir)) <= def.blade_width * 0.5 + 0.5 * 0.5


## A crescent of Boss._fire_soul: [from, dir, reach] (it comes undone soul_overrun past the edge).
func _crescent(boss: Vector2, dir: Vector2) -> Array:
	var from := boss + dir * 0.8
	return [from, dir, maxf(floor.cut(from, dir, def.blade_range, -def.soul_overrun), 1.0)]


func _line(boss: Vector2, dir: Vector2, length: float, width: float) -> Ground.Zone:
	var z := Ground.Zone.new()
	z.shape = Ground.Shape.LINE
	z.pos = boss
	z.dir = dir
	z.radius = maxf(floor.cut(boss, dir, length), 0.5)
	z.width = width
	return z


# ---------- the chamber ----------

func test_the_floor_is_a_circle_of_eleven_to_thirteen_meters() -> void:
	assert_true(floor.is_round(), "Morvath fights on a round floor")
	var walk := floor.radius - 0.5
	assert_between(walk, 11.0, 13.0, "the paladin's middle walks within 11 to 13 m of the seal")
	assert_eq(_pairs().size(), 12 * 12 - _overlaps(), "every pair but those whose bodies overlap")


func _overlaps() -> int:
	var n := 0
	for b in _boss_spots():
		for p in _hero_spots():
			if p.distance_to(b) < body + 0.5 + 0.1:
				n += 1
	return n


# ---------- the patterns ----------

func test_the_scythe_has_a_way_out_everywhere() -> void:
	var windup := _windup(def.scythe_windup)
	for pair in _pairs():
		var boss: Vector2 = pair[0]
		var p: Vector2 = pair[1]
		if p.distance_to(boss) > 11.0:
			continue
		var z := Ground.Zone.new()
		z.shape = Ground.Shape.ARC
		z.pos = boss
		z.dir = (p - boss).normalized()
		z.radius = def.scythe_reach
		z.width = def.scythe_degrees
		var out := _way_out(p, boss, windup, func(q: Vector2) -> bool: return Ground.inside(z, q, 0.3))
		assert_false(out.is_empty(), "scythe: boss %s, paladin %s" % [boss, p])
		_count("scythe", out)


func test_the_blades_have_a_way_out_everywhere() -> void:
	var windup := _windup(def.blade_windup, 1, 3)
	for pair in _pairs():
		var boss: Vector2 = pair[0]
		var p: Vector2 = pair[1]
		if p.distance_to(boss) < 3.5:
			continue
		for side in [1.0, -1.0]:
			var dirs := BossRules.soul_pair((p - boss).normalized(), def.blade_spread, side)
			var souls := [_crescent(boss, dirs[0]), _crescent(boss, dirs[1])]
			var hazard := func(q: Vector2) -> bool:
				for c: Array in souls:
					if _in_flight(c[0], c[1], c[2], q):
						return true
				return false
			var out := _way_out(p, boss, windup, hazard)
			assert_false(out.is_empty(), "blades: boss %s, paladin %s, side %d" % [boss, p, side])
			_count("blades", out)


func test_the_dash_is_cut_at_the_edge_and_has_a_way_out() -> void:
	var windup := _windup(def.dash_windup)
	var charged := 0
	for pair in _pairs():
		var boss: Vector2 = pair[0]
		var p: Vector2 = pair[1]
		var dir := (p - boss).normalized()
		var room := floor.cut(boss, dir, def.dash_length, body)
		if p.distance_to(boss) < 9.0 or room < def.dash_min_free:
			continue
		charged += 1
		# his body never leaves the floor, and the lane ends at the edge
		assert_lte((boss + dir * room).distance_to(floor.center), floor.radius - body + 0.001)
		var z := _line(boss, dir, room + body, def.dash_width)
		assert_lte((boss + dir * z.radius).distance_to(floor.center), floor.radius + 0.001, "the lane never paints the abyss")
		var out := _way_out(p, boss, windup, func(q: Vector2) -> bool: return Ground.inside(z, q, 0.3))
		assert_false(out.is_empty(), "dash: boss %s, paladin %s" % [boss, p])
		_count("dash", out)
	assert_gt(charged, 10, "the charge has room in the chamber (the paladin 9 m or more away)")


func test_the_eruptions_have_a_way_out_both_times() -> void:
	var windup := _windup(def.eruption_delay, 2)
	var rng := RandomNumberGenerator.new()
	for pair in _pairs():
		var boss: Vector2 = pair[0]
		var p: Vector2 = pair[1]
		for s in 3:
			rng.seed = hash(p) + s * 7919
			var at := p
			for sequence in def.eruption_sequences:
				var n := rng.randi_range(def.eruption_count.x, def.eruption_count.y)
				var spots := BossRules.eruptions(at, n, def.eruption_radius, floor.center, def.eruption_lane, floor, rng)
				for k in range(1, spots.size()):
					assert_true(floor.contains(spots[k], def.eruption_radius), "a whole eruption on the floor")
				assert_lte(spots[0].distance_to(at), def.eruption_radius, "the first erupts under him")
				var hazard := func(q: Vector2) -> bool:
					for e in spots:
						if q.distance_to(e) <= def.eruption_radius + 0.3:
							return true
					return false
				var out := _way_out(at, boss, windup, hazard)
				assert_false(out.is_empty(), "eruptions %d: boss %s, paladin %s" % [sequence + 1, boss, at])
				if out.is_empty():
					break
				_count("eruptions", out)
				at = out[0]


func test_the_storm_has_a_way_out_of_every_wave() -> void:
	var windup := _windup(def.storm_windup, 4)
	var rng := RandomNumberGenerator.new()
	for pair in _pairs():
		var boss: Vector2 = pair[0]
		var p: Vector2 = pair[1]
		for s in 2:
			rng.seed = hash(p) + hash(boss) + s
			var ok := _storm(boss, p, windup, rng)
			assert_true(ok, "storm: boss %s, paladin %s, seed %d" % [boss, p, s])


## Every wave (BossDef.storm_waves): out of the first's lanes by its wind-up (and, with `erupting`, out of the
## eruptions laid over it as it shows, E2: their free lane from BossRules.free_way), then from there out of each next
## wave's (aimed at where he stands, turned storm_turn more each wave) while the crescents of the waves before may
## still be flying across his way.
func _storm(boss: Vector2, p: Vector2, windup: float, rng: RandomNumberGenerator, erupting := false) -> bool:
	var aim := (p - boss).normalized()
	var at := p
	var flying: Array = []
	var leaves := PackedFloat32Array()
	var shown := 0.0
	for wave in def.storm_waves:
		var to := (at - boss).normalized() if at.distance_to(boss) > 0.1 else aim
		var dirs := BossRules.storm(def.storm_count, rad_to_deg(to.angle()) + def.storm_turn * wave, def.storm_jitter, def.storm_min_gap, rng)
		var order := BossRules.storm_order(dirs, to)
		var lanes: Array = []
		for d in dirs:
			lanes.append(_crescent(boss, d))
		var spots := PackedVector2Array()
		if erupting and wave == 0:
			var way := BossRules.free_way(at, boss, body, dirs, def.blade_width * 0.5 + 0.5, floor)
			spots = BossRules.eruptions(at, def.layer_eruption_count.y, def.eruption_radius, at + way * 10.0, def.eruption_lane, floor, rng)
		var hazard := func(q: Vector2) -> bool:
			for c: Array in lanes:
				if _in_flight(c[0], c[1], c[2], q):
					return true
			for e in spots:
				if q.distance_to(e) <= def.eruption_radius + 0.3:
					return true
			return false
		var name := "storm %d%s" % [wave + 1, " + eruptions" if erupting and wave == 0 else ""]
		var out := _wave_out(at, boss, windup, shown + REACTION, hazard, flying, leaves)
		if out.is_empty():
			return false
		_count(name, out)
		at = out[0]
		var last := 0.0
		for rank in order.size():
			flying.append(lanes[order[rank]])
			leaves.append(shown + windup + def.storm_stagger * rank)
			last = shown + windup + def.storm_stagger * rank
		# the next wave shows storm_gap after the last of this one left
		shown = last + def.storm_gap
	return true


## A spot out of `hazard` by `windup` from `at` (walking, else dodging), the way there begun at `start` and clear of
## the crescents still flying from the waves before. [] when there is none; else [the spot, true with the dodge].
func _wave_out(at: Vector2, boss: Vector2, windup: float, start: float, hazard: Callable, flying: Array, leaves: PackedFloat32Array) -> Array:
	if not hazard.call(at):
		return [at, false]
	var t := windup - REACTION
	for dodge in [false, true]:
		var reach := speed * t if not dodge else dodge_len + speed * (t - dodge_time)
		for ring in range(1, RINGS + 1):
			for k in WAYS:
				var q := at + Vector2.from_angle(TAU * k / WAYS) * reach * ring / RINGS
				if not _stand(q, boss) or (not dodge and _through_body(at, q, boss)) or hazard.call(q):
					continue
				if _clear_of_first(at, q, start, flying, leaves, dodge):
					return [q, dodge]
	return []


## The way from `from` to `to`, begun at `start` (seconds of the storm), meets none of the first wave's crescents
## still flying (a dodge's safe frames let it pass through).
func _clear_of_first(from: Vector2, to: Vector2, start: float, first: Array, leaves: PackedFloat32Array, dodge: bool) -> bool:
	var length := from.distance_to(to)
	var way := (to - from).normalized() if length > 0.001 else Vector2.ZERO
	var walked_m := 0.0
	var t := start
	while walked_m < length:
		var step := (dodge_len / dodge_time if dodge and t - start < dodge_time else speed) * DT
		walked_m = minf(length, walked_m + step)
		t += DT
		if dodge and t - start <= iframes:
			continue
		var q := from + way * walked_m
		for i in first.size():
			var c: Array = first[i]
			var flown := def.blade_speed * (t - leaves[i])
			if flown < 0.0 or flown > c[2]:
				continue
			var at: Vector2 = c[0] + c[1] * flown
			var d := q - at
			if absf(d.dot(c[1])) <= Projectiles.SOUL_DEPTH + 0.5 and absf(d.cross(c[1])) <= def.blade_width * 0.5 + 0.25:
				return false
	return true


func test_the_curse_can_be_walked_or_dodged_away_from() -> void:
	var windup := _windup(def.curse_windup, 3)
	for pair in _pairs():
		var boss: Vector2 = pair[0]
		var p: Vector2 = pair[1]
		if p.distance_to(boss) < 3.0:
			continue
		var walk := _curse_walk(boss, p, windup)
		var ok := walk or _curse_dodge(boss, p, windup)
		assert_true(ok, "curse: boss %s, paladin %s" % [boss, p])
		_count("curse", [p, not walk] if ok else [])


## The curse's bolt at time t: [pos, vel, homing left].
func _bolt(boss: Vector2, p: Vector2) -> Array:
	var aim := (p - boss).normalized()
	return [boss + aim * 1.6, aim * def.curse_speed, def.curse_homing]


func _bolt_step(b: Array, hero: Vector2) -> void:
	var vel: Vector2 = b[1]
	if float(b[2]) > 0.0:
		b[2] = float(b[2]) - DT
		var want := vel.angle_to(hero - (b[0] as Vector2))
		var turn := deg_to_rad(def.curse_turn) * DT
		vel = vel.rotated(clampf(want, -turn, turn))
		b[1] = vel
	b[0] = (b[0] as Vector2) + vel * DT


## Walking one way (sliding along the floor's edge and around his body) from REACTION on: the bolt never touches him.
func _curse_walk(boss: Vector2, p: Vector2, windup: float) -> bool:
	for k in 24:
		var way := Vector2.from_angle(TAU * k / 24.0)
		var hero := p
		var b := _bolt(boss, p)
		var t := 0.0
		var hit := false
		while t < windup + def.curse_life:
			t += DT
			if t >= REACTION:
				hero = _slide(hero + way * speed * DT, boss)
			if t >= windup:
				_bolt_step(b, hero)
				if (b[0] as Vector2).distance_to(hero) < def.curse_radius + 0.5:
					hit = true
					break
		if not hit:
			return true
	return false


## Standing (or walking away) and dodging across its way when it comes close: the safe frames let it pass and it is
## gone (Projectiles: a bolt that touches him is spent, hurt or not).
func _curse_dodge(boss: Vector2, p: Vector2, windup: float) -> bool:
	for trigger in [1.4, 2.2, 3.0]:
		for k in 16:
			var way := Vector2.from_angle(TAU * k / 16.0)
			var hero := p
			var b := _bolt(boss, p)
			var t := 0.0
			var dodge_at := -1.0
			var safe := true
			while t < windup + def.curse_life:
				t += DT
				if dodge_at < 0.0 and t >= windup and (b[0] as Vector2).distance_to(hero) <= trigger:
					dodge_at = t
				if dodge_at >= 0.0:
					var s := dodge_len / dodge_time if t - dodge_at < dodge_time else speed
					hero = _slide(hero + way * s * DT, boss, true)
				if t >= windup:
					_bolt_step(b, hero)
					if (b[0] as Vector2).distance_to(hero) < def.curse_radius + 0.5:
						safe = dodge_at >= 0.0 and t - dodge_at <= iframes
						break
			if safe:
				return true
	return false


# ---------- the layers (E2: the harder end of the fight) ----------

## The attack `id` of the BossDef and the first phase it carries `layer` over it (0 when it never does).
func _layer_phase(id: StringName, layer: StringName) -> int:
	for a in def.attacks:
		if a.id == id and a.layers.has(layer) and a.layer_chance > 0.0:
			return a.layer_from_phase
	return 0


func _eruption_hazard(spots: PackedVector2Array) -> Callable:
	return func(q: Vector2) -> bool:
		for e in spots:
			if q.distance_to(e) <= def.eruption_radius + 0.3:
				return true
		return false


func test_the_free_way_leads_out_of_the_attack_it_is_laid_over() -> void:
	# the scythe's half circle (the paladin within its reach) and a storm's wave: the way ends out of the attack
	var rng := RandomNumberGenerator.new()
	rng.seed = 5
	var lanes_half := def.blade_width * 0.5 + 0.5
	var counts := {"scythe": [0, 0], "storm": [0, 0]}
	for pair in _pairs():
		var boss: Vector2 = pair[0]
		var p: Vector2 = pair[1]
		var way := BossRules.free_way(p, boss, def.scythe_reach, PackedVector2Array(), 0.0, floor)
		assert_almost_eq(way.length(), 1.0, 0.001)
		assert_true(floor.contains(p + way * BossRules.FREE_PROBE, 1.0), "the way keeps to the floor (paladin %s)" % p)
		if p.distance_to(boss) <= def.scythe_reach + 0.5:
			counts.scythe[1] += 1
			if BossRules.clearance(p + way * BossRules.FREE_PROBE, boss, def.scythe_reach, PackedVector2Array(), 0.0) > 0.0:
				counts.scythe[0] += 1
		var dirs := BossRules.storm(def.storm_count, rad_to_deg((p - boss).angle()), def.storm_jitter, def.storm_min_gap, rng)
		var w := BossRules.free_way(p, boss, body, dirs, lanes_half, floor)
		counts.storm[1] += 1
		if BossRules.clearance(p + w * BossRules.FREE_PROBE, boss, body, dirs, lanes_half) > 0.0:
			counts.storm[0] += 1
	for id: String in counts:
		gut.p("free way out of the %s: %d of %d" % [id, counts[id][0], counts[id][1]])
		assert_gt(counts[id][1], 10)
		assert_gte(counts[id][0], counts[id][1] * 0.9, "the %s's way out ends out of it" % id)


func test_the_storm_with_eruptions_and_his_dead_has_a_way_out_of_every_wave() -> void:
	var from := _layer_phase(&"storm", &"eruptions")
	assert_gt(from, 0, "the storm carries eruptions in the last phase")
	var windup := _windup(def.storm_windup, from)
	var rng := RandomNumberGenerator.new()
	for pair in _pairs():
		var boss: Vector2 = pair[0]
		var p: Vector2 = pair[1]
		for s in 2:
			rng.seed = hash(p) + hash(boss) + s * 31
			assert_true(_storm(boss, p, windup, rng, true), "storm + eruptions: boss %s, paladin %s, seed %d" % [boss, p, s])


func test_the_scythe_with_eruptions_has_a_way_out() -> void:
	var from := _layer_phase(&"scythe", &"eruptions")
	assert_gt(from, 0, "the scythe carries eruptions late in the fight")
	# both shown at once: one spot out of the half circle and the circles, by the scythe's (shorter) wind-up
	var windup := _windup(def.scythe_windup, from)
	assert_lte(windup, _windup(def.eruption_delay, from), "the eruptions land after the scythe")
	var rng := RandomNumberGenerator.new()
	for pair in _pairs():
		var boss: Vector2 = pair[0]
		var p: Vector2 = pair[1]
		if p.distance_to(boss) > 11.0:
			continue
		for s in 3:
			rng.seed = hash(p) + hash(boss) + s * 7
			var z := Ground.Zone.new()
			z.shape = Ground.Shape.ARC
			z.pos = boss
			z.dir = (p - boss).normalized()
			z.radius = def.scythe_reach
			z.width = def.scythe_degrees
			var way := BossRules.free_way(p, boss, def.scythe_reach, PackedVector2Array(), 0.0, floor)
			var spots := BossRules.eruptions(p, def.layer_eruption_count.y, def.eruption_radius, p + way * 10.0, def.eruption_lane, floor, rng)
			var circles := _eruption_hazard(spots)
			var out := _way_out(p, boss, windup, func(q: Vector2) -> bool: return Ground.inside(z, q, 0.3) or circles.call(q))
			assert_false(out.is_empty(), "scythe + eruptions: boss %s, paladin %s, seed %d" % [boss, p, s])
			_count("scythe + eruptions", out)


## The curse with eruptions laid as its bolt leaves (BossAttack.layer_share 1), their first circle under the
## paladin wherever he is then and their free lane off the bolt's way. He sees the curse's lane and may walk one way
## (or stand) from REACTION; the circles fall where he is when the bolt leaves; then he walks one way and dodges once
## (at once, or when the bolt comes close). Out of every circle when they land and never touched by the bolt outside
## the dodge's safe frames.
func test_the_curse_with_eruptions_can_be_escaped() -> void:
	var from := _layer_phase(&"curse", &"eruptions")
	assert_gt(from, 0, "the curse carries eruptions")
	var windup := _windup(def.curse_windup, from)
	var land := _windup(def.eruption_delay, from)
	for pair in _pairs():
		var boss: Vector2 = pair[0]
		var p: Vector2 = pair[1]
		if p.distance_to(boss) < 3.0:
			continue
		for s in 2:
			var ok := _curse_and_circles(boss, p, windup, land, hash(p) + hash(boss) + s * 13)
			assert_true(ok, "curse + eruptions: boss %s, paladin %s, seed %d" % [boss, p, s])
			_count("curse + eruptions", [p, false] if ok else [])


func _curse_and_circles(boss: Vector2, p: Vector2, windup: float, land: float, seed: int) -> bool:
	var rng := RandomNumberGenerator.new()
	var firsts: Array[Vector2] = [Vector2.ZERO]
	for k in 8:
		firsts.append(Vector2.from_angle(TAU * k / 8.0))
	for first: Vector2 in firsts:
		# until the bolt leaves: standing, or walking one way from REACTION (the bolt is not out yet)
		var hero := p
		var t := 0.0
		while t < windup - DT * 0.5:
			t += DT
			if t >= REACTION and first != Vector2.ZERO:
				hero = _slide(hero + first * speed * DT, boss)
		rng.seed = seed
		var aim := (hero - boss).normalized()
		var way := BossRules.free_way(hero, boss, body, PackedVector2Array([aim]), 0.7 + 0.5, floor)
		var spots := BossRules.eruptions(hero, def.layer_eruption_count.y, def.eruption_radius, hero + way * 10.0, def.eruption_lane, floor, rng)
		for trigger in [-1.0, 0.0, 1.4, 2.2, 3.0]:
			for k in 16:
				if _after_release(boss, hero, Vector2.from_angle(TAU * k / 16.0), trigger, windup, land, spots, first):
					return true
	return false


## From the bolt's release (the paladin at `hero`, the bolt aimed from where he stood): walking `way`, dodging once
## by `trigger` (-1 never, 0 at once, else when the bolt is that close).
func _after_release(boss: Vector2, hero: Vector2, way: Vector2, trigger: float, windup: float, land: float, spots: PackedVector2Array, first: Vector2) -> bool:
	var circles := _eruption_hazard(spots)
	var b := _bolt(boss, hero)
	var t := windup
	var dodge_at := -1.0
	var bolt := true
	var landed := false
	while t < windup + def.curse_life or not landed:
		t += DT
		# until he reacts to the circles he goes on the way he was going
		var dir := way if t >= windup + REACTION else first
		if t >= windup + REACTION and dodge_at < 0.0 and trigger >= 0.0 and (trigger == 0.0 or (bolt and (b[0] as Vector2).distance_to(hero) <= trigger)):
			dodge_at = t
		var dodging := dodge_at >= 0.0 and t - dodge_at < dodge_time
		if dir != Vector2.ZERO:
			hero = _slide(hero + dir * (dodge_len / dodge_time if dodging else speed) * DT, boss, dodging)
		if not landed and t >= windup + land:
			landed = true
			if circles.call(hero):
				return false
		if bolt:
			_bolt_step(b, hero)
			if (b[0] as Vector2).distance_to(hero) < def.curse_radius + 0.5:
				bolt = false
				if not (dodge_at >= 0.0 and t - dodge_at <= iframes):
					return false
	return true


func test_the_layers_keep_his_ceiling_of_dead() -> void:
	# every summon laid over an attack is under the phase's ceiling and the fight's (they share _call with the rest)
	for a in def.attacks:
		if a.layers.has(&"summon"):
			assert_gt(a.layer_from_phase, 2, "his dead rise over an attack only after the ritual's phase")
			assert_lte(def.layer_raise.size(), BossRules.adds_cap(def.adds_cap, a.layer_from_phase), "a layer never asks for more than the ceiling")
	assert_eq(BossRules.reinforce_room(2, 4, 0, 4, 10, 20), 0, "a full ceiling raises nobody")
	assert_eq(BossRules.reinforce_room(2, 1, 1, 4, 19, 20), 1, "the fight's 20 hold")


func _slide(q: Vector2, boss: Vector2, through := false) -> Vector2:
	q = floor.clamp(q, 0.5)
	if not through and q.distance_to(boss) < body + 0.5:
		q = boss + (q - boss).normalized() * (body + 0.5)
	return floor.clamp(q, 0.5)
