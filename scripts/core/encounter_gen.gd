class_name EncounterGen
extends RefCounted
## The fight of a room, drawn the way Hades II draws its generated encounters: a difficulty that grows with depth,
## split into waves; a few kinds of enemy (one of them in every wave); each kind's share turned into a head count
## by its rating. Pure: the game spawns what this returns.

## Most of one kind in a single wave (keeps a bad draw sane).
const MAX_PER_TYPE := 14


static func difficulty(stage: StageDef, depth: int, mult: float = 1.0) -> float:
	return maxf(stage.min_difficulty, (stage.base_difficulty + depth * stage.depth_ramp) * mult)


## Enemies on the floor at once.
static func cap(stage: StageDef, depth: int) -> int:
	return mini(stage.cap_max, int(stage.cap_base + stage.cap_per_depth * depth))


static func type_count(stage: StageDef, depth: int) -> int:
	return clampi(int(stage.min_types + stage.types_per_depth * depth), 1, stage.max_types)


## defs: id -> EnemyDef for every id of stage.enemies. Returns the waves, each a list of enemy ids.
static func generate(stage: StageDef, depth: int, defs: Dictionary, rng: RandomNumberGenerator, mult: float = 1.0) -> Array[Array]:
	var types := pick_types(stage, depth, defs, rng)
	var waves: Array[Array] = []
	if types.is_empty():
		return waves
	var count := clampi(rng.randi_range(stage.min_waves, stage.max_waves), 1, stage.wave_split.size())
	var split: PackedFloat32Array = stage.wave_split[count - 1]
	var total := difficulty(stage, depth, mult)
	for w in count:
		# the first kind (the highlight) is in every wave; later waves add the others, the last has them all
		var kinds := clampi(w + 1 + types.size() - count, 1, types.size())
		var wave: Array[StringName] = []
		var share := total * split[w]
		var mean := share / kinds
		for k in kinds:
			var id: StringName = types[k]
			var rating := maxf(1.0, (defs[id] as EnemyDef).rating)
			var slice := maxf(rating, rng.randfn(mean, mean / 3.0))
			for n in mini(MAX_PER_TYPE, ceili(slice / rating)):
				wave.append(id)
		_shuffle(wave, rng)
		waves.append(wave)
	return waves


## The kinds of enemy of one room: type_count of them, at most max_elite_types elites, never an enemy together
## with its own elite version.
static func pick_types(stage: StageDef, depth: int, defs: Dictionary, rng: RandomNumberGenerator) -> Array[StringName]:
	var pool: Array[StringName] = []
	for id in stage.enemies:
		var d := defs.get(id) as EnemyDef
		if d != null and (not d.elite or depth >= stage.elite_from_depth):
			pool.append(id)
	_shuffle(pool, rng)
	var out: Array[StringName] = []
	var elites := 0
	var want := type_count(stage, depth)
	for id in pool:
		if out.size() >= want:
			break
		var d := defs[id] as EnemyDef
		if d.elite and elites >= stage.max_elite_types:
			continue
		if _same_family(id, out, defs):
			continue
		out.append(id)
		if d.elite:
			elites += 1
	return out


static func _same_family(id: StringName, chosen: Array[StringName], defs: Dictionary) -> bool:
	var d := defs[id] as EnemyDef
	for other in chosen:
		var o := defs[other] as EnemyDef
		if d.elite_version == other or o.elite_version == id:
			return true
	return false


static func _shuffle(list: Array, rng: RandomNumberGenerator) -> void:
	for i in range(list.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var t: Variant = list[i]
		list[i] = list[j]
		list[j] = t
