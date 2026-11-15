class_name EncounterGen
extends RefCounted
## The fight of a room, drawn the way Hades II draws its generated encounters: a difficulty that grows with depth,
## split into waves; a few kinds of enemy, each with a clear part to play (an EncounterPool of the stage, chosen by
## how far down the region the room is), the first of them in every wave; each kind's share turned into a head count
## by its rating. Few enemies stand at once (Daniel, 2026-11-15: a fight won by skill, not a horde): every wave is
## brought into the range of its tier (StageDef.tier_alive) and nothing ever stands past StageDef.alive_cap.
## Pure: the game spawns what this returns.


## What a room's fight is.
class Fight:
	## The waves, each a list of enemy ids.
	var waves: Array[Array] = []
	var kinds: Array[StringName] = []
	var tier := StageDef.Tier.COMMON
	## Enemies on the floor at once while the waves come in (a queued one waits for room).
	var cap := 4
	## Nobody rises past this many standing, summons included (Horde.alive_cap).
	var ceiling := 20


static func difficulty(stage: StageDef, depth: int, mult: float = 1.0) -> float:
	return maxf(stage.min_difficulty, (stage.base_difficulty + depth * stage.depth_ramp) * mult)


## How far down the region a depth is: 0 at the first room, 1 at the last fight before the shop.
static func progress(stage: StageDef, depth: int) -> float:
	return clampf(float(depth - 1) / maxf(1.0, stage.rooms - 2.0), 0.0, 1.0)


## The fewest and the most enemies standing at once in a fight of this tier, never past the stage's ceiling.
static func alive_range(stage: StageDef, tier: StageDef.Tier) -> Vector2i:
	var r: Vector2i = stage.tier_alive[clampi(tier, 0, stage.tier_alive.size() - 1)]
	var most := mini(r.y, stage.alive_cap)
	return Vector2i(mini(r.x, most), most)


## Enemies on the floor at once: the tier's fewest at the top of the region, growing to its most at the bottom.
static func cap(stage: StageDef, tier: StageDef.Tier, depth: int) -> int:
	var r := alive_range(stage, tier)
	return clampi(roundi(lerpf(r.x, r.y, progress(stage, depth))), r.x, r.y)


## How many of `want` may still rise with `alive` standing under `ceiling` (summons, reinforcements): fewer, or none.
static func room_for(alive: int, ceiling: int, want: int) -> int:
	return clampi(ceiling - alive, 0, want)


## defs: id -> EnemyDef for every id of stage.enemies.
static func generate(stage: StageDef, depth: int, defs: Dictionary, rng: RandomNumberGenerator, mult: float = 1.0) -> Fight:
	var fight := Fight.new()
	var pool := pick_pool(stage, depth, rng)
	if pool == null:
		return fight
	fight.kinds = pick_kinds(stage, pool, depth, defs, rng)
	fight.tier = pool.tier
	for id in fight.kinds:
		if (defs[id] as EnemyDef).elite:
			fight.tier = maxi(fight.tier, StageDef.Tier.HARD) as StageDef.Tier  # an elite makes a fight hard
	var alive := alive_range(stage, fight.tier)
	fight.cap = cap(stage, fight.tier, depth)
	fight.ceiling = alive.y
	fight.waves = waves(stage, depth, fight.kinds, alive, defs, rng, mult)
	return fight


## One of the stage's pools that may be drawn at this depth, by weight (null: none).
static func pick_pool(stage: StageDef, depth: int, rng: RandomNumberGenerator) -> EncounterPool:
	var at := progress(stage, depth)
	var found: Array[EncounterPool] = []
	var weights := PackedFloat32Array()
	for pool in stage.pools:
		if at >= pool.from and at <= pool.until and pool.weight > 0.0:
			found.append(pool)
			weights.append(pool.weight)
	if found.is_empty():
		return null
	return found[rng.rand_weighted(weights)]


## One kind for each part of the pool (EnemyDef.role), in its order; some in their elite version (at most
## max_elite_types, from elite_from_depth on), never a kind twice nor a kind with its own elite.
static func pick_kinds(stage: StageDef, pool: EncounterPool, depth: int, defs: Dictionary, rng: RandomNumberGenerator) -> Array[StringName]:
	var out: Array[StringName] = []
	var elites := 0
	for role in pool.roles:
		var options: Array[StringName] = []
		for id in stage.enemies:
			var d := defs.get(id) as EnemyDef
			if d != null and not d.elite and d.role == role and not out.has(id) and not out.has(d.elite_version):
				options.append(id)
		if options.is_empty():
			continue
		var id: StringName = options[rng.randi() % options.size()]
		var elite := (defs[id] as EnemyDef).elite_version
		if elite != &"" and defs.has(elite) and depth >= stage.elite_from_depth and elites < stage.max_elite_types \
				and rng.randf() < pool.elite_chance:
			id = elite
			elites += 1
		out.append(id)
	return out


## The waves of a fight: the room's difficulty split among them, each brought into the tier's range (alive: fewest,
## most).
static func waves(stage: StageDef, depth: int, kinds: Array[StringName], alive: Vector2i, defs: Dictionary, rng: RandomNumberGenerator, mult: float = 1.0) -> Array[Array]:
	var out: Array[Array] = []
	if kinds.is_empty():
		return out
	var total := difficulty(stage, depth, mult)
	var mean_rating := 0.0
	for id in kinds:
		mean_rating += _rating(defs, id)
	mean_rating /= kinds.size()
	# heads the budget buys: never more waves than it fills with the tier's fewest, never fewer than it needs to keep
	# each under the tier's most (a big budget comes in more waves, not all at once)
	var heads := total / mean_rating
	var most := clampi(floori(heads / maxf(1.0, alive.x)), 1, stage.wave_split.size())
	var least := clampi(ceili(heads / maxf(1.0, alive.y)), 1, most)
	var count := clampi(rng.randi_range(stage.min_waves, stage.max_waves), least, most)
	var split: PackedFloat32Array = stage.wave_split[count - 1]
	for w in count:
		# the first kind (the highlight) is in every wave; later waves add the others, the last has them all
		var n := clampi(w + 1 + kinds.size() - count, 1, kinds.size())
		var in_wave := kinds.slice(0, n)
		var wave: Array[StringName] = []
		var mean := total * split[w] / n
		for id in in_wave:
			var rating := _rating(defs, id)
			var slice := maxf(rating, rng.randfn(mean, mean / 3.0))
			for i in ceili(slice / rating):
				wave.append(id)
		_fit(wave, in_wave, alive, defs)
		_shuffle(wave, rng)
		out.append(wave)
	return out


## Brings a wave into the range: the cheapest of its kinds fills it up to the fewest; past the most, the kind with
## the most heads gives way (every kind keeps one).
static func _fit(wave: Array[StringName], kinds: Array[StringName], alive: Vector2i, defs: Dictionary) -> void:
	var cheapest := kinds[0]
	for id in kinds:
		if _rating(defs, id) < _rating(defs, cheapest):
			cheapest = id
	while wave.size() < alive.x:
		wave.append(cheapest)
	while wave.size() > maxi(alive.y, kinds.size()):
		var crowded := kinds[0]
		for id in kinds:
			if wave.count(id) > wave.count(crowded):
				crowded = id
		wave.erase(crowded)


static func _rating(defs: Dictionary, id: StringName) -> float:
	return maxf(1.0, (defs[id] as EnemyDef).rating)


static func _shuffle(list: Array, rng: RandomNumberGenerator) -> void:
	for i in range(list.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var t: Variant = list[i]
		list[i] = list[j]
		list[j] = t
