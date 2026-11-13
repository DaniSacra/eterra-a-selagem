class_name WaveTable
extends Resource
## The whole run on a timeline.

@export var segments: Array[WaveSegment] = []
@export var events: Array[WaveEvent] = []
## Enemy life grows by this share per minute (0.2 = +20% a minute).
@export var hp_per_minute := 0.2
## Enemy damage grows by this share per minute.
@export var damage_per_minute := 0.05


func segment_at(time: float) -> WaveSegment:
	for s in segments:
		if time >= s.from and time < s.until:
			return s
	return null


func boss_time() -> float:
	for e in events:
		if e.kind == WaveEvent.Kind.BOSS:
			return e.time
	return INF
