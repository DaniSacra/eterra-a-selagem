class_name WaveTable
extends Resource
## The whole run on a timeline.

@export var segments: Array[WaveSegment] = []
@export var events: Array[WaveEvent] = []
## How many seconds of the timeline pass per second of play. 1 = the full run (Morvath at 15 minutes);
## 5 = the short test run (Morvath at 3). Spawning keeps its pace per real second, so a faster timeline only
## brings each stage sooner.
@export var pace := 1.0
## Enemy life grows by this share per minute (0.2 = +20% a minute).
@export var hp_per_minute := 0.2
## Enemy damage grows by this share per minute.
@export var damage_per_minute := 0.05


func segment_at(time: float) -> WaveSegment:
	for s in segments:
		if time >= s.from and time < s.until:
			return s
	return null


## Seconds of play until Morvath comes.
func boss_play_time() -> float:
	return boss_time() / pace


func boss_time() -> float:
	for e in events:
		if e.kind == WaveEvent.Kind.BOSS:
			return e.time
	return INF
