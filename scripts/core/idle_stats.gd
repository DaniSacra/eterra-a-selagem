class_name IdleStats
extends RefCounted
## How long a boss or guardian stands doing nothing between two attacks (docs/design/combat_cadence.md, section 12):
## the gaps (seconds from the end of one attack's recovery to the start of the next wind-up, earned openings left out)
## and the share of the fight spent idle. Pure numbers; Horde and Boss feed it, RunReport prints `report()`.

var gaps: Array[float] = []
## Seconds from the end of a strike (its recovery included) to the next wind-up: the stretch the player sees as nothing.
var deads: Array[float] = []
## Seconds of fight that count (earned openings left out), and of those spent idle (walking without attacking).
var fight_t := 0.0
var idle_t := 0.0
var rec_t := 0.0


func add_gap(seconds: float) -> void:
	gaps.append(seconds)


## One step of `dt` seconds: `idle` when he is walking without attacking, `earned` when it is an earned opening (stun,
## shield away, posture break...), which is not counted at all.
func tick(dt: float, idle: bool, earned: bool, recovering := false) -> void:
	if earned:
		return
	fight_t += dt
	if idle:
		idle_t += dt
	elif recovering:
		rec_t += dt


func add_dead(seconds: float) -> void:
	deads.append(seconds)


static func percentile(sorted: Array[float], q: float) -> float:
	if sorted.is_empty():
		return 0.0
	return sorted[clampi(int(ceil(q * sorted.size())) - 1, 0, sorted.size() - 1)]


func report() -> Dictionary:
	var g := _summary(gaps)
	var d := _summary(deads)
	return {"n": g.n, "mean": g.mean, "p90": g.p90, "max": g.max, "share": snappedf(idle_t / maxf(fight_t, 0.001), 0.01),
		"share_rec": snappedf((idle_t + rec_t) / maxf(fight_t, 0.001), 0.01), "fight": snappedf(fight_t, 0.1),
		"dead_mean": d.mean, "dead_p90": d.p90, "dead_max": d.max}


static func _summary(list: Array[float]) -> Dictionary:
	var s := list.duplicate()
	s.sort()
	var sum := 0.0
	for v in s:
		sum += v
	var n := s.size()
	return {"n": n, "mean": snappedf(sum / maxf(n, 1.0), 0.01), "p90": snappedf(percentile(s, 0.9), 0.01),
		"max": snappedf(s[n - 1] if n > 0 else 0.0, 0.01)}
