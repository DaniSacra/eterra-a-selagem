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
	## C1e: the modifiers (ModDef ids) the first heads of a kind come with: kind id -> Array[StringName] (assign_mods).
	var mods: Dictionary = {}


static func difficulty(stage: StageDef, depth: int, mult: float = 1.0) -> float:
	return maxf(stage.min_difficulty, (stage.base_difficulty + depth * stage.depth_ramp) * mult)


## C1b: the share of difficulty a room is given (StageDef.room_budget; 1.0 when the list has none for the depth).
static func budget(stage: StageDef, depth: int) -> float:
	return stage.room_budget[depth - 1] if depth >= 1 and depth <= stage.room_budget.size() else 1.0


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


## defs: id -> EnemyDef for every id of stage.enemies. room: the arena it is fought in (cycle C12): its own range of
## enemies standing (RoomLayout.max_alive), the roles it never has and its most shooters at once.
## avoid: the parts of the room before (C1e: a fight never has the same set of parts twice in a row; drawn again up to REDRAWS times).
static func generate(stage: StageDef, depth: int, defs: Dictionary, rng: RandomNumberGenerator, mult: float = 1.0, room: RoomLayout = null,
		avoid: Array[StringName] = []) -> Fight:
	var fight := Fight.new()
	var pool := pick_pool(stage, depth, rng)
	if pool == null:
		return fight
	var banned: Array[StringName] = room.banned_roles if room else ([] as Array[StringName])
	fight.kinds = pick_kinds(stage, pool, depth, defs, rng, banned)
	var tries := 0
	while not avoid.is_empty() and same_parts(roles_of(fight.kinds, defs), avoid) and tries < REDRAWS:
		tries += 1
		pool = pick_pool(stage, depth, rng)
		fight.kinds = pick_kinds(stage, pool, depth, defs, rng, banned)
	fight.tier = pool.tier
	for id in fight.kinds:
		if (defs[id] as EnemyDef).elite:
			fight.tier = maxi(fight.tier, StageDef.Tier.HARD) as StageDef.Tier  # an elite makes a fight hard
	var alive := in_room(alive_range(stage, fight.tier), room)
	fight.cap = clampi(roundi(lerpf(alive.x, alive.y, progress(stage, depth))), alive.x, alive.y)
	fight.ceiling = alive.y
	fight.waves = waves(stage, depth, fight.kinds, alive, defs, rng, mult * budget(stage, depth))
	limit_per_room(fight.waves, fight.kinds, defs)
	if room != null and room.max_ranged > 0:
		for w in fight.waves:
			limit_ranged(w, fight.kinds, room.max_ranged, defs)
	if (room == null or room.hazard == null) and stage.big_chance > 0.0 and depth >= stage.big_from_depth \
			and rng.randf() < stage.big_chance:
		add_big(fight, alive, defs, rng)
	if not stage.mods.is_empty() and depth >= stage.mod_from_depth:
		assign_mods(fight, stage, depth, defs, rng)
	return fight


## Times a fight whose parts are those of the room before is drawn again.
const REDRAWS := 4


## The parts (EnemyDef.role) of a list of kinds, sorted.
static func roles_of(kinds: Array[StringName], defs: Dictionary) -> Array[StringName]:
	var out: Array[StringName] = []
	for id in kinds:
		var d := defs.get(id) as EnemyDef  # (a guardian is not one of the stage's common kinds)
		var role: StringName = d.role if d != null else &"guardian"
		if not out.has(role):
			out.append(role)
	out.sort()
	return out


## Whether two sets of parts are the same (both sorted).
static func same_parts(a: Array[StringName], b: Array[StringName]) -> bool:
	return a == b


## C1e: each head of the fight that may carry a modifier (a plain, single-bodied common one: not an elite, a bigger one, a Trinca, one
## of a limited kind or a SUPPORT) has the chance StageDef.mod_chance (rising by mod_step a room); at most StageDef.mod_per_room in a
## fight. The mods go to the first heads of the kind that spawn (Fight.mods). Returns how many were given.
static func assign_mods(fight: Fight, stage: StageDef, depth: int, defs: Dictionary, rng: RandomNumberGenerator) -> int:
	var chance := SupportRules.mod_chance(depth, stage.mod_from_depth, stage.mod_chance, stage.mod_step)
	var given := 0
	for wave in fight.waves:
		for id: StringName in wave:
			var d := defs[id] as EnemyDef
			if given >= stage.mod_per_room or d.elite or d.big or d.group > 1 or d.per_room > 0 or d.behavior == EnemyDef.Behavior.SUPPORT:
				continue
			if rng.randf() < chance:
				var list: Array = fight.mods.get(id, [])
				list.append(stage.mods[rng.randi() % stage.mods.size()])
				fight.mods[id] = list
				given += 1
	return given


## C1b: one head of the last wave (which has every kind) becomes the bigger version of its kind, paid for with the heads
## of that kind it is worth (by rating, at least one of the kind stays); only in a fight with another kind besides.
## Returns true when it did. At most one a fight: the fight has one last wave and this changes one head.
static func add_big(fight: Fight, alive: Vector2i, defs: Dictionary, rng: RandomNumberGenerator) -> bool:
	if fight.kinds.size() < 2 or fight.waves.is_empty():
		return false
	var wave: Array = fight.waves[fight.waves.size() - 1]
	var options: Array[StringName] = []
	for id in fight.kinds:
		var big := (defs[id] as EnemyDef).big_version
		if big != &"" and defs.has(big) and wave.has(id):
			options.append(id)
	if options.is_empty():
		return false
	var id: StringName = options[rng.randi() % options.size()]
	var big_def := defs[(defs[id] as EnemyDef).big_version] as EnemyDef
	var others := 0
	for k in fight.kinds:
		if k != id and wave.has(k):
			others += 1
	if others == 0:
		return false
	wave[wave.find(id)] = big_def.id
	var pay := mini(ceili(big_def.rating / _rating(defs, id)) - 1, wave.count(id) - 1)
	for i in pay:
		wave.erase(id)
	# kept inside the tier's fewest (the cheapest fills in), never past the ceiling
	var typed: Array[StringName] = []
	typed.assign(wave)
	_fit(typed, fight.kinds, alive, defs)
	wave.assign(typed)
	return true


## A tier's range of enemies standing brought into an arena's own (RoomLayout.max_alive; none: as it is): never past
## the tier's most nor the arena's.
static func in_room(alive: Vector2i, room: RoomLayout) -> Vector2i:
	if room == null or room.max_alive.y <= 0:
		return alive
	var most := mini(alive.y, room.max_alive.y)
	return Vector2i(clampi(room.max_alive.x, 1, most), most)


## True for a kind that shoots from afar (EnemyDef.Behavior.ARCHER: the caster, the crossbowman, the priest).
static func ranged(d: EnemyDef) -> bool:
	return d.behavior == EnemyDef.Behavior.ARCHER


## No more than `most` shooters in a wave: the others become the wave's first kind that does not shoot (or leave).
static func limit_ranged(wave: Array, kinds: Array[StringName], most: int, defs: Dictionary) -> void:
	var melee := stand_in(kinds, defs, true)
	var n := 0
	var i := 0
	while i < wave.size():
		if ranged(defs[wave[i]]):
			n += 1
			if n > most:
				if melee != &"":
					wave[i] = melee
				else:
					wave.remove_at(i)
					continue
		i += 1


## C5 (EnemyDef.per_room): no more of a kind in the whole fight than it allows (the Varredor: one); the extra heads
## become the first kind without such a limit (or leave).
static func limit_per_room(waves: Array[Array], kinds: Array[StringName], defs: Dictionary) -> void:
	var instead := stand_in(kinds, defs, false)
	var seen := {}
	for wave in waves:
		var i := 0
		while i < wave.size():
			var d := defs[wave[i]] as EnemyDef
			if d.per_room > 0:
				seen[d.name_key] = int(seen.get(d.name_key, 0)) + 1
				if int(seen[d.name_key]) > d.per_room:
					if instead != &"":
						wave[i] = instead
					else:
						wave.remove_at(i)
						continue
			i += 1


## The kind that fills in for a head taken out of a wave (a shooter over the arena's limit, a second Varredor): the first of
## `kinds` that is not a shooter (when `melee`), has no limit of its own and is a single body (C5: a trinca would put three
## where one stood); &"" for none (the head leaves).
static func stand_in(kinds: Array[StringName], defs: Dictionary, melee: bool) -> StringName:
	for id in kinds:
		var d := defs[id] as EnemyDef
		if not (melee and ranged(d)) and d.per_room <= 0 and d.group <= 1:
			return id
	return &""


## Bodies a wave puts on the floor: a head of a trinca is all its figures (EnemyDef.group).
static func bodies(wave: Array, defs: Dictionary) -> int:
	var n := 0
	for id: StringName in wave:
		n += maxi(1, (defs[id] as EnemyDef).group)
	return n


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
static func pick_kinds(stage: StageDef, pool: EncounterPool, depth: int, defs: Dictionary, rng: RandomNumberGenerator, banned: Array[StringName] = []) -> Array[StringName]:
	var out: Array[StringName] = []
	var elites := 0
	for role in pool.roles:
		if banned.has(role):
			continue
		var options: Array[StringName] = []
		for id in stage.enemies:
			var d := defs.get(id) as EnemyDef
			if d != null and not d.elite and not d.big and d.role == role and not out.has(id) and not out.has(d.elite_version) \
					and not clashes(d, out, defs):
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


## C1e (EnemyDef.never_with): whether `d` and a kind already chosen are never drawn together, either way round.
static func clashes(d: EnemyDef, chosen: Array[StringName], defs: Dictionary) -> bool:
	for id in chosen:
		var o := defs[id] as EnemyDef
		if d.never_with.has(o.role) or o.never_with.has(d.role):
			return true
	return false


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
	while bodies(wave, defs) < alive.x:
		wave.append(cheapest)
	while bodies(wave, defs) > maxi(alive.y, kinds.size()) and wave.size() > kinds.size():
		var crowded := kinds[0]
		for id in kinds:
			if wave.count(id) * maxi(1, (defs[id] as EnemyDef).group) > wave.count(crowded) * maxi(1, (defs[crowded] as EnemyDef).group):
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
