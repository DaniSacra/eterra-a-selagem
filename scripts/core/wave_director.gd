class_name WaveDirector
extends RefCounted
## Turns the wave table and the clock into "spawn these now". Pure: the game decides where they appear.

var table: WaveTable
var time := 0.0
## Once the crypt opens, the crowd stops coming.
var stopped := false
## How many of the crowd have been sent so far (for pacing checks).
var spawned := 0
var _acc := 0.0
var _next_event := 0
var _rng: RandomNumberGenerator


func _init(wave_table: WaveTable, rng: RandomNumberGenerator = null) -> void:
	table = wave_table
	_rng = rng if rng != null else RandomNumberGenerator.new()


## Advances the clock by dt seconds of play (the timeline moves table.pace times as fast). Returns the ids of the enemies to spawn this step, never going past the cap.
func step(dt: float, alive: int) -> Array[StringName]:
	time += dt * table.pace
	var out: Array[StringName] = []
	var seg := table.segment_at(time)
	if seg == null or stopped or seg.enemies.is_empty():
		return out
	_acc += seg.rate(time) * dt
	var room := seg.cap(time) - alive
	while _acc >= 1.0:
		_acc -= 1.0
		if out.size() < room:
			out.append(pick(seg))
	spawned += out.size()
	return out


func pick(seg: WaveSegment) -> StringName:
	if seg.weights.size() != seg.enemies.size():
		return seg.enemies[_rng.randi() % seg.enemies.size()]
	return seg.enemies[_rng.rand_weighted(seg.weights)]


## Events whose time has come, each returned once, in order.
func due_events() -> Array[WaveEvent]:
	var out: Array[WaveEvent] = []
	while _next_event < table.events.size() and table.events[_next_event].time <= time:
		out.append(table.events[_next_event])
		_next_event += 1
	return out


func hp_scale() -> float:
	return 1.0 + table.hp_per_minute * time / 60.0


func damage_scale() -> float:
	return 1.0 + table.damage_per_minute * time / 60.0
