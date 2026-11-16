class_name HitRecoil
extends RefCounted
## How far a struck body is drawn pushed back, away from the blow, t seconds after it (E1a-3, VX-06; only drawn: the
## enemy's place in the simulation, its behaviour, damage and kills never see it). It reaches PEAK in RISE (three
## frames at 60 FPS: the blow reads on the body at once) and eases back to where it stands by BACK.

## Meters at the peak for a light body and for a heavy one (EnemyDef.heavy: guardians, the brute, Morvath).
const PEAK := 0.24
const HEAVY_PEAK := 0.15
## Seconds to the peak, and seconds from the blow to back in place (Horde.HURT_TIME, the hit pose's length).
const RISE := 0.05
const BACK := 0.3


## Meters back at t seconds after the blow (t < 0: no blow).
static func offset(t: float, heavy := false) -> float:
	if t < 0.0 or t >= BACK:
		return 0.0
	var peak := HEAVY_PEAK if heavy else PEAK
	if t < RISE:
		var k := 1.0 - t / RISE
		return peak * (1.0 - k * k)
	return peak * (1.0 - smoothstep(RISE, BACK, t))
