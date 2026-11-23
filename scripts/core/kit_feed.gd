class_name KitFeed
extends RefCounted
## C1c (docs/design/kit_c1c.md 1): the buttons feed each other. Pure rules, no nodes: how much Magia an attack hit or a
## Quebra gives (capped by a sliding window, and one wave refunds at most so much of its cost), and how many seconds
## of the Brado's recharge each gives back. HeroGifts feeds it the fight's events and does what it answers.

## Sources of a Quebra that feed (DealtBy sources): the attack, the wave, the Investida and the two Omegas. Never the Brado or the ultimate.
const BREAK_SOURCES: Array[StringName] = [&"attack", &"special", &"dash", &"omega_attack", &"omega_special"]

var hero: HeroDef
var _now := 0.0
## [time, amount] of the Magia gained by hit or Quebra inside the window.
var _gains: Array[Vector2] = []
## Magia the wave thrown last has refunded so far.
var _wave_got := 0.0
## What it did in this run (RESULT kit): Magia by hits and by Quebras, seconds of the Brado's recharge given back, waves and cries thrown.
var tally := {"magick_hit": 0.0, "magick_break": 0.0, "refund_s": 0.0, "waves": 0, "shouts": 0}


func _init(h: HeroDef) -> void:
	hero = h


func step(dt: float) -> void:
	_now += dt
	while not _gains.is_empty() and _gains[0].x <= _now - hero.gain_window:
		_gains.remove_at(0)


## A new wave was thrown: its refund starts over.
func wave_thrown() -> void:
	_wave_got = 0.0
	tally.waves += 1


## Magia of `amount` asked for a hit or a Quebra: what is let through (never over gain_cap in gain_window s).
func take(amount: float) -> float:
	if amount <= 0.0:
		return 0.0
	var used := 0.0
	for g in _gains:
		used += g.y
	var got := clampf(hero.gain_cap - used, 0.0, amount)
	if got > 0.0:
		_gains.append(Vector2(_now, got))
	return got


## Magia for an attack hit (once a swing: `per_hit` of the blow).
func hit_magick(per_hit: float) -> float:
	var got := take(per_hit)
	tally.magick_hit += got
	return got


## Magia for a Quebra by `source`; a wave's (source special) stops at wave_refund_cap in all.
func break_magick(source: StringName) -> float:
	if not BREAK_SOURCES.has(source):
		return 0.0
	var ask := hero.magick_on_break
	if source == &"special":
		ask = minf(ask, hero.wave_refund_cap - _wave_got)
	var got := take(ask)
	if source == &"special":
		_wave_got += got
	tally.magick_break += got
	return got


## Seconds off the Brado's recharge for a Quebra by `source` (none from the Brado or the ultimate).
func break_refund(source: StringName) -> float:
	return hero.cd_refund_break if BREAK_SOURCES.has(source) else 0.0
