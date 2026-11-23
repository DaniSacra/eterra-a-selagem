class_name ThrowRules
extends RefCounted
## The Lançador's axe (lote C1e B): flies out, turns and flies back the same way to where it left. Pure: Projectiles steps it.

## Meters short of the stone it turns (the shot dies on stone, so a turn exactly there would never come back).
const EDGE := 0.5
## Seconds before it turns that the thin line of its way back shows.
const RETURN_WARN := 0.4
## The least it goes out (meters).
const MIN_RANGE := 1.5


## How far out it goes: `reach` m clear of stone, less EDGE when stone stopped it short of `want`.
static func out_range(want: float, reach: float) -> float:
	return maxf(MIN_RANGE, want if reach >= want else reach - EDGE)


## Seconds into its flight when it turns.
static func turn_age(out: float, speed: float) -> float:
	return out / maxf(speed, 0.1)


## Seconds it lives: out and back (and a frame of grace).
static func life(out: float, speed: float) -> float:
	return 2.0 * turn_age(out, speed) + 0.1


## Seconds into its flight when the line of its way back shows (never before it leaves).
static func warn_age(turn: float) -> float:
	return maxf(0.0, turn - RETURN_WARN)
