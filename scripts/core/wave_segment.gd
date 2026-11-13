class_name WaveSegment
extends Resource
## A stretch of the run: who spawns, how fast, and how many may be alive at once. Values ramp from start to end.

@export var from := 0.0
@export var until := 60.0
@export var enemies: Array[StringName] = []
@export var weights: PackedFloat32Array = PackedFloat32Array()
## Spawns per second at the start and at the end of the segment.
@export var rate_start := 1.0
@export var rate_end := 1.5
## Most enemies alive at the start and at the end of the segment.
@export var cap_start := 30
@export var cap_end := 60


func progress(time: float) -> float:
	return clampf((time - from) / maxf(until - from, 0.001), 0.0, 1.0)


func rate(time: float) -> float:
	return lerpf(rate_start, rate_end, progress(time))


func cap(time: float) -> int:
	return int(round(lerpf(cap_start, cap_end, progress(time))))
