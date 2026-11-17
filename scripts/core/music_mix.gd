class_name MusicMix
extends RefCounted
## The music's mixing rules, without nodes (E4-06): which tracks are playing, how loud each layer is, the crossfades.
## Music (scripts/music.gd) turns it into AudioStreamPlayers; the tests step it on their own clock.
## A track is played as a deck: all its layers start together (so they stay in time) and the level n lets the first
## n be heard (the fight's drums over the walk, Morvath's phases). A new track fades in while the old one fades out,
## so there is never a gap; a one-shot (the victory) hands over to its `then` before it ends; a sting (a Psalm's
## theme) plays over the bed, which ducks under it.
## T5: a "solo" track (the rooms, Morvath: recorded pieces that cannot be stacked) hears only layer n at level n; the
## others keep running unheard in time, so a level change is a LAYER_FADE crossfade that never restarts a piece.

## Seconds: a new track coming in, an old one going, a layer joining or leaving.
const FADE_IN := 1.5
const FADE_OUT := 2.5
const LAYER_FADE := 2.0
## The bed under a sting, linear (about -7 dB), and how fast it goes down and comes back.
const DUCK := 0.45
const DUCK_FADE := 0.6
## E6 (C15-01): the bed under one of Morvath's warnings (Audio.WARN_CUES), linear (about -6 dB): down fast, held for
## the warning, back slowly, so his tell is heard over the drums.
const WARN_DUCK := 0.5
const WARN_ATTACK := 0.06
const WARN_RELEASE := 0.5
## A one-shot track calls its `then` this long before it ends, so the next one is in before it is gone.
const HANDOVER := 2.0


class Deck:
	var id: StringName
	var loop := true
	var length := 0.0
	var then: StringName = &""
	var sting := false
	## Level n hears only layer n (T5), not the first n.
	var solo := false
	## Each layer's gain now and where it is going; the deck's own fade on top.
	var gains := PackedFloat32Array()
	var targets := PackedFloat32Array()
	var fade := 0.0
	var fade_to := 1.0
	var time := 0.0
	var handed := false

	func layers() -> int:
		return gains.size()

	func ended() -> bool:
		return not loop and time >= length

	func gain(layer: int) -> float:
		return gains[layer] * fade


## id -> {"layers": int, "length": seconds, "loop": bool, "then": StringName (optional), "sting": bool}
var catalog: Dictionary = {}
## The bed decks, the newest last (older ones are fading out); the stings over them.
var decks: Array[Deck] = []
var stings: Array[Deck] = []
var duck := 1.0
## The warning's duck (1 = none) and how long it still holds.
var warn_duck := 1.0
var warn_hold := 0.0
## Decks started and dropped since the last call to take_changes (Music makes and frees their players).
var started: Array[Deck] = []
var dropped: Array[Deck] = []


func _init(tracks: Dictionary = {}) -> void:
	catalog = tracks


func current() -> Deck:
	return decks.back() if not decks.is_empty() else null


func current_id() -> StringName:
	var d := current()
	return d.id if d != null else &""


## Plays a track at a level (layers heard). The same track already playing only changes its level.
func play(id: StringName, level: int = 1) -> Deck:
	if not catalog.has(id):
		return null
	var now := current()
	if now != null and now.id == id and now.fade_to > 0.0:
		set_level(level)
		return now
	for d in decks:
		d.fade_to = 0.0
	var spec: Dictionary = catalog[id]
	var d := Deck.new()
	d.id = id
	d.loop = spec.get("loop", true)
	d.length = spec.get("length", 0.0)
	d.then = spec.get("then", &"")
	d.solo = spec.get("solo", false)
	var n: int = spec.get("layers", 1)
	d.gains.resize(n)
	d.targets.resize(n)
	for i in n:
		d.targets[i] = _target(d, i, level)
		d.gains[i] = d.targets[i]
	d.fade_to = 1.0
	decks.append(d)
	started.append(d)
	return d


## The first n layers of the current track are heard (at least one); on a solo track, only layer n.
func set_level(n: int) -> void:
	var d := current()
	if d == null:
		return
	for i in d.layers():
		d.targets[i] = _target(d, i, n)


## Where layer i of d goes at level n.
static func _target(d: Deck, i: int, n: int) -> float:
	n = clampi(n, 1, d.layers())
	if d.solo:
		return 1.0 if i == n - 1 else 0.0
	return 1.0 if i < n else 0.0


func level() -> int:
	var d := current()
	if d == null:
		return 0
	var n := 0
	for i in d.layers():
		if d.targets[i] > 0.0:
			n = i + 1 if d.solo else n + 1
	return n


## A one-shot over the bed.
func sting(id: StringName) -> Deck:
	if not catalog.has(id):
		return null
	var spec: Dictionary = catalog[id]
	var d := Deck.new()
	d.id = id
	d.sting = true
	d.loop = false
	d.length = spec.get("length", 0.0)
	d.gains = PackedFloat32Array([1.0])
	d.targets = PackedFloat32Array([1.0])
	d.fade = 1.0
	stings.append(d)
	started.append(d)
	return d


## Everything stops (fading out).
func stop() -> void:
	for d in decks:
		d.fade_to = 0.0


func step(dt: float) -> void:
	for d in decks.duplicate():
		d.time += dt
		var rate := dt / (FADE_IN if d.fade_to > d.fade else FADE_OUT)
		d.fade = move_toward(d.fade, d.fade_to, rate)
		for i in d.layers():
			d.gains[i] = move_toward(d.gains[i], d.targets[i], dt / LAYER_FADE)
		if not d.loop and not d.handed and d.then != &"" and d.time >= d.length - HANDOVER and d == current():
			d.handed = true
			play(d.then, 1)
		if (d.fade_to <= 0.0 and d.fade <= 0.0) or d.ended():
			decks.erase(d)
			dropped.append(d)
	for s in stings.duplicate():
		s.time += dt
		if s.ended():
			stings.erase(s)
			dropped.append(s)
	duck = move_toward(duck, DUCK if not stings.is_empty() else 1.0, dt / DUCK_FADE)
	warn_hold = maxf(warn_hold - dt, 0.0)
	if warn_hold > 0.0:
		warn_duck = move_toward(warn_duck, WARN_DUCK, dt * (1.0 - WARN_DUCK) / WARN_ATTACK)
	else:
		warn_duck = move_toward(warn_duck, 1.0, dt * (1.0 - WARN_DUCK) / WARN_RELEASE)


## One of Morvath's warnings: the bed ducks under it for `seconds` (a longer one already holding is kept).
func warn(seconds: float) -> void:
	warn_hold = maxf(warn_hold, seconds)


## What a layer of a bed deck is heard at (the duck included).
func heard(d: Deck, layer: int) -> float:
	return d.gain(layer) * (1.0 if d.sting else duck * warn_duck)


## The loudest thing playing, linear: 0 is silence.
func audible() -> float:
	var most := 0.0
	for d in decks:
		if d.ended():
			continue
		for i in d.layers():
			most = maxf(most, heard(d, i))
	for s in stings:
		if not s.ended():
			most = maxf(most, s.gain(0))
	return most


func take_changes() -> Array:
	var out := [started.duplicate(), dropped.duplicate()]
	started.clear()
	dropped.clear()
	return out
