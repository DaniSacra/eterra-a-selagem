class_name ConvergePlan
extends RefCounted
## Schedule of the Convergência Elemental (04_PLANO C.3), pure: 3 phases (ice, fire, volt) of `phase_time`,
## a tick every `tick` s, `direct_damage` spread over all ticks. In the volt phase the second-to-last tick also
## reapplies Queimadura (Sobrecarga) and the last one Frio (Cristalização).

const PHASES: Array[StringName] = [ElementBook.ICE, ElementBook.FIRE, ElementBook.VOLT]

var phase_time := 1.5
var tick := 0.5
var direct_damage := 90.0


func ticks_per_phase() -> int:
	return maxi(1, roundi(phase_time / tick))


func count() -> int:
	return ticks_per_phase() * PHASES.size()


func duration() -> float:
	return phase_time * PHASES.size()


## Direct damage of each tick (the total is `direct_damage`, not per tick).
func damage_per_tick() -> float:
	return direct_damage / float(count())


func phase_of(i: int) -> int:
	return clampi(i / ticks_per_phase(), 0, PHASES.size() - 1)


## Elements applied at tick `i` (0-based), in order: the phase element, then the volt phase's reapplication.
func elements_at(i: int) -> Array[StringName]:
	var out: Array[StringName] = [PHASES[phase_of(i)]]
	if phase_of(i) == PHASES.size() - 1:
		var last := count() - 1
		if i == last - 1:
			out.append(ElementBook.FIRE)
		elif i == last:
			out.append(ElementBook.ICE)
	return out
