class_name TrioRules
extends RefCounted
## The Trinca's figures (lote C5, CB-7): where each stands round the paladin, and who may rise. Pure.

## Seconds a whole turn of the triangle round the paladin takes.
const TURN_TIME := 18.0


## The angle of figure `k` of `n` round the paladin at `clock` seconds, the triangle turning slowly; `phase` (0..1)
## tells one trinca from another.
static func slot_angle(clock: float, k: int, n: int, phase: float) -> float:
	return TAU * (clock / TURN_TIME + phase + float(k) / maxf(float(n), 1.0))


## Where figure `k` of `n` waits: `ring` m from `center` on its slot.
static func slot_pos(center: Vector2, clock: float, k: int, n: int, phase: float, ring: float) -> Vector2:
	return center + Vector2.from_angle(slot_angle(clock, k, n, phase)) * ring


## Where the figures of a trinca rise when it comes: round `at`, `spread` m from it.
static func birth_pos(at: Vector2, k: int, n: int, spread: float) -> Vector2:
	return at + Vector2.from_angle(TAU * float(k) / maxf(float(n), 1.0) + 0.5) * spread


## A fallen figure rises when its time is up and another of the three still stands.
static func may_rise(down_time: float, rise_time: float, others_standing: int) -> bool:
	return down_time >= rise_time and others_standing > 0
