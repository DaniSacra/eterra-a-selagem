extends Node
## Autoload "Music" (E4-06, C15-03): the game's music, our own synthesis (tools/make_music.gd renders it to
## audio/music/*.ogg; licence in audio/LICENSES.md). The rules (decks, levels, crossfades, the duck under a sting)
## are MusicMix; this node only turns them into players on the Music bus, which runs into Master before its limiter
## (Audio.limit_master). The volume is the save's "music" option (Audio.apply_volumes).
##   Music.play(&"catacombs", level)  the rooms: level 1 the walk, 2 the fight's drums over it
##   Music.boss_phase(n)              Morvath: phase n hears the first n layers (starts his track if needed)
##   Music.sting(&"sentinel")         a Psalm's theme over the bed (psalm_<id>; the Psalms' front calls it)
##   Music.play(&"victory")           the end, which hands over to the walk

const DIR := "res://audio/music/"
## Under every track, so the music sits below the blows (tests/test_music.gd measures it).
const MUSIC_DB := -3.0
## Bed tracks: layers (files <id>_1.ogg...; one layer is <id>.ogg), loop, and what a one-shot hands over to.
const TRACKS := {
	&"catacombs": {"layers": 2, "loop": true},
	&"morvath": {"layers": 4, "loop": true},
	&"victory": {"layers": 1, "loop": false, "then": &"catacombs"},
}
## Stings: one-shots over the bed (a Psalm discovered).
const STINGS: Array[StringName] = [&"psalm_sentinel", &"psalm_shelter", &"psalm_shepherd", &"psalm_rock"]
## Room levels.
const WALK := 1
const FIGHT := 2

var mix: MusicMix
var silent := false
var _players: Dictionary = {}  # MusicMix.Deck -> Array[AudioStreamPlayer]
var _last_us := 0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	silent = DisplayServer.get_name() == "headless" or Dev.has("shot")
	mix = MusicMix.new(catalog())
	_last_us = Time.get_ticks_usec()


## The tracks and stings with their real lengths (from the files).
static func catalog() -> Dictionary:
	var out := {}
	for id: StringName in TRACKS:
		var spec: Dictionary = (TRACKS[id] as Dictionary).duplicate()
		var first := stream_of(id, 0, spec.layers)
		if first == null:
			continue
		spec.length = first.get_length()
		out[id] = spec
	for id in STINGS:
		var s := stream_of(id, 0, 1)
		if s != null:
			out[id] = {"layers": 1, "loop": false, "sting": true, "length": s.get_length()}
	return out


static func file_of(id: StringName, layer: int, layers: int) -> String:
	return DIR + (String(id) if layers == 1 else "%s_%d" % [id, layer + 1]) + ".ogg"


static func stream_of(id: StringName, layer: int, layers: int) -> AudioStream:
	var path := file_of(id, layer, layers)
	if not ResourceLoader.exists(path):
		return null
	var s: AudioStream = load(path)
	if s is AudioStreamOggVorbis:
		(s as AudioStreamOggVorbis).loop = (TRACKS.get(id, {}) as Dictionary).get("loop", false)
	return s


func play(id: StringName, level: int = 1) -> void:
	mix.play(id, level)
	_sync()


func set_level(n: int) -> void:
	mix.set_level(n)


## Morvath's phase n (1 to 4): his track, with the first n layers.
func boss_phase(n: int) -> void:
	if mix.current_id() != &"morvath":
		mix.play(&"morvath", n)
		_sync()
	else:
		mix.set_level(n)


## A theme over the bed: "psalm_sentinel" or just the Psalm's id, "sentinel".
func sting(id: StringName) -> void:
	var key := id if mix.catalog.has(id) else StringName("psalm_" + id)
	mix.sting(key)
	_sync()


func stop() -> void:
	mix.stop()


func current() -> StringName:
	return mix.current_id()


func _process(_delta: float) -> void:
	# real seconds: slow motion and hit stop (Engine.time_scale) never slow the music's fades
	var now := Time.get_ticks_usec()
	var dt := minf((now - _last_us) / 1000000.0, 0.25)
	_last_us = now
	mix.step(dt)
	_sync()


func _sync() -> void:
	var changes: Array = mix.take_changes()
	for d: MusicMix.Deck in changes[0]:
		_start(d)
	for d: MusicMix.Deck in changes[1]:
		for p: AudioStreamPlayer in _players.get(d, []):
			p.queue_free()
		_players.erase(d)
	for d: MusicMix.Deck in _players:
		var list: Array = _players[d]
		for i in list.size():
			var g: float = mix.heard(d, i)
			(list[i] as AudioStreamPlayer).volume_db = MUSIC_DB + linear_to_db(maxf(g, 0.0001))


## All the layers of a deck start in the same frame, so they stay in time.
func _start(d: MusicMix.Deck) -> void:
	var list: Array[AudioStreamPlayer] = []
	for i in d.layers():
		var p := AudioStreamPlayer.new()
		p.bus = &"Music"
		p.stream = stream_of(d.id, i, d.layers())
		p.volume_db = MUSIC_DB + linear_to_db(maxf(mix.heard(d, i), 0.0001))
		add_child(p)
		list.append(p)
	_players[d] = list
	if silent:
		return
	for p in list:
		if p.stream != null:
			p.play()
