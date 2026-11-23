class_name BossDirector
extends RefCounted
## Chooses a boss's next attack (reusable for any boss with a BossDef): only what the phase allows and the moment
## permits (distance, cooldowns, what is blocked now), tilted by where the paladin is (close: the scythe; far: the
## blades; standing still: the eruptions), never the same too many times in a row and seldom what came lately.
## Never chooses nothing while the phase has an attack: when every rule closes the door it opens them again one at
## a time (cooldowns, then repetition, then distance). An empty list once crashed the exported game (`randi() % 0`).

## Attacks remembered for the repetition penalty, and how much each recent use lowers a weight.
const HISTORY := 4
const REPEAT_PENALTY := 0.45

var attacks: Array[BossAttack] = []
var near := 6.0
var far := 10.0
var still_after := 0.8
## The first attack of each phase (BossDef.phase_openers).
var openers: Array[StringName] = []
## Seconds left before each attack (by id) may come again.
var cooldowns: Dictionary = {}
## The last attacks chosen, the newest last.
var history: Array[StringName] = []


func _init(def: BossDef = null) -> void:
	if def:
		attacks = def.attacks
		near = def.near
		far = def.far
		still_after = def.still_after
		openers = def.phase_openers


func step(dt: float) -> void:
	for id: StringName in cooldowns:
		cooldowns[id] = maxf(0.0, float(cooldowns[id]) - dt)


## Marks an attack as chosen: its cooldown starts and it joins the history.
func used(id: StringName) -> void:
	for a in attacks:
		if a.id == id:
			cooldowns[id] = a.cooldown
	history.append(id)
	while history.size() > HISTORY:
		history.pop_front()


## How many times in a row the newest attacks were this one.
func streak_of(id: StringName) -> int:
	var n := 0
	for i in range(history.size() - 1, -1, -1):
		if history[i] != id:
			break
		n += 1
	return n


## The attacks that may come now. strict levels: 3 every rule, 2 without cooldowns, 1 also without the repetition
## rule, 0 also without distance. Blocked ids (the boss knows: no room for summons, the paladin already cursed) and
## the phase always hold.
func valid(phase: int, dist: float, blocked: Array[StringName] = [], strict: int = 3) -> Array[BossAttack]:
	var out: Array[BossAttack] = []
	for a in attacks:
		if not a.allowed_in(phase) or blocked.has(a.id):
			continue
		if strict >= 1 and (dist < a.min_dist or dist > a.max_dist):
			continue
		if strict >= 2 and streak_of(a.id) >= maxi(1, a.streak):
			continue
		if strict >= 3 and float(cooldowns.get(a.id, 0.0)) > 0.0:
			continue
		out.append(a)
	return out


## How much an attack is wanted now.
func weight(a: BossAttack, dist: float, still_t: float, phase := 0) -> float:
	var w := maxf(a.weight_in(phase), 0.001)
	if dist <= near:
		w *= a.near_bias
	elif dist >= far:
		w *= a.far_bias
	if still_t >= still_after:
		w *= a.still_bias
	for id in history:
		if id == a.id:
			w *= REPEAT_PENALTY
	return maxf(w, 0.0001)


## The next attack's id (&"" only when the phase has none at all).
func choose(phase: int, dist: float, still_t: float, blocked: Array[StringName], rng: RandomNumberGenerator) -> StringName:
	for strict in [3, 2, 1, 0]:
		var options := valid(phase, dist, blocked, strict)
		if not options.is_empty():
			return _draw(options, dist, still_t, rng, phase).id
	return &""


## The attack that opens a phase (&"" when the phase has none or it is blocked now).
func opener(phase: int, blocked: Array[StringName] = []) -> StringName:
	if phase < 1 or phase > openers.size():
		return &""
	var id := openers[phase - 1]
	for a in attacks:
		if a.id == id and a.allowed_in(phase) and not blocked.has(id):
			return id
	return &""


## The second blow of a combination after `id` (&"" for none): only from its phase on, and by its chance.
func follow_up(id: StringName, phase: int, rng: RandomNumberGenerator) -> StringName:
	for a in attacks:
		if a.id != id or a.then == &"" or a.then == id or a.then_from_phase <= 0 or phase < a.then_from_phase:
			continue
		for b in attacks:
			if b.id == a.then and b.allowed_in(phase) and rng.randf() < a.then_chance:
				return b.id
	return &""


## The attack with this id (null when the boss has none).
func attack(id: StringName) -> BossAttack:
	for a in attacks:
		if a.id == id:
			return a
	return null


## The patterns laid over this attack now (BossAttack.layers): from its phase on and by its chance; empty for none.
func layers_for(id: StringName, phase: int, rng: RandomNumberGenerator) -> Array[StringName]:
	var a := attack(id)
	if a == null:
		return []
	var out := a.layers_in(phase)
	if out.is_empty() or rng.randf() >= a.layer_chance:
		return []
	return out.duplicate()


func _draw(options: Array[BossAttack], dist: float, still_t: float, rng: RandomNumberGenerator, phase := 0) -> BossAttack:
	var total := 0.0
	for a in options:
		total += weight(a, dist, still_t, phase)
	var roll := rng.randf() * total
	for a in options:
		roll -= weight(a, dist, still_t, phase)
		if roll <= 0.0:
			return a
	return options[options.size() - 1]
