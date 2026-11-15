class_name BarTrails
extends RefCounted
## The pale trail on an enemy's life bar (life_bar.gdshader, custom a): what a blow just took stays pale for a
## moment, then drains to the life, as on the paladin's own bar (HudBar). Only drawn: it remembers, per enemy, the
## life it last showed, and never touches the enemy.
## Real seconds (a hit stop does not freeze it, as the HUD's own bar).

## The trail stands still HOLD seconds, then drains to the life in DRAIN seconds.
const HOLD := 0.18
const DRAIN := 0.25

class Mark:
	var last := 1.0
	var from := 1.0
	var since := INF

var _marks: Dictionary = {}  # Object -> Mark


## Where the trail of who ends (0..1, >= life) when its life is now life, at the time now (seconds).
func shown(who: Object, life: float, now: float) -> float:
	var m: Mark = _marks.get(who)
	if m == null:
		m = Mark.new()
		m.last = life
		_marks[who] = m
		return life
	if life < m.last - 0.0001:
		# a second blow while the trail still shows keeps the older, longer trail
		m.from = maxf(_end(m, life, now), m.last)
		m.since = now
	m.last = life
	return _end(m, life, now)


## Forgets those no longer drawn (the dead), when there are many more marks than living enemies.
func prune(alive: Callable) -> void:
	for who: Object in _marks.keys():
		if not is_instance_valid(who) or not alive.call(who):
			_marks.erase(who)


func size() -> int:
	return _marks.size()


func _end(m: Mark, life: float, now: float) -> float:
	var t := now - m.since
	if t < 0.0 or t >= HOLD + DRAIN:
		return life
	if t <= HOLD:
		return maxf(life, m.from)
	return maxf(life, lerpf(m.from, life, (t - HOLD) / DRAIN))
