extends Node
## Autoload "Music" (E4-06, C15-03, T5): the game's music. Every piece is in MusicCatalog (core/music_catalog.gd): our
## own (tools/make_music.gd: "Catacumbas (original)", "Morvath (original)", the Psalms' themes, the victory) and Kevin
## MacLeod's (CC BY 4.0, tools/make_music_loops.sh). The player picks the piece of each place (title, rooms, Morvath)
## in the Músicas screen (MusicRoomScreen; save options music_*, our own by default): Music.play(place) resolves it.
## Licences and credits in audio/LICENSES.md. The rules (decks, levels, crossfades, the duck under a sting) are
## MusicMix, whose decks are the pieces' ids; this node only turns them into players on the Music bus, which runs into
## Master before its limiter (Audio.limit_master). The volume is the save's "music" option (Audio.apply_volumes).
##   Music.play(&"title")             the title screen (the first room crossfades from it, or goes on when it is the
##                                    rooms' own piece)
##   Music.play(&"catacombs", level)  the rooms: level 1 the walk, 2 the fight (Music.room_depth picks the piece when
##                                    the rooms' choice is "Alternar")
##   Music.room_won()                 MUS-2: the calm transition over the room won, until the next room's play()
##   Music.boss_phase(n)              Morvath: phase n (starts his piece if needed)
##   Music.sting(&"sentinel")         a Psalm's theme over the bed (psalm_<id>; the Psalms' front calls it)
##   Music.play(&"victory")           the end, which hands over to the rooms' walk
##   Music.ambience(&"crypt")         E6 (C15-04): the room's air (Ambience), crossfaded, on the Ambience bus
##   Music.warn(seconds)              E6 (C15-01): one of Morvath's warnings, the music and the air duck under it
##   Music.listen(piece, level)       the Músicas screen: any piece; Music.resume() goes back to where the game was

const DIR := MusicCatalog.DIR
## Under every track, so the music sits below the blows (tests/test_music.gd measures it).
const MUSIC_DB := -3.0
## The Psalms' own ids (data/psalms) to their themes (QA E4: Game.take_psalm passes p.id).
const PSALM_STING := {&"sentinela": &"psalm_sentinel", &"abrigo": &"psalm_shelter", &"pastor": &"psalm_shepherd", &"rocha": &"psalm_rock"}
## Room levels.
const WALK := 1
const FIGHT := 2

## MUS-2: the depth of the room the descent is in (Rooms sets it): the rooms' "Alternar" asks it which piece to play.
static var room_depth := 1

var mix: MusicMix
## The rooms' air: its own decks (one layer each), the same crossfades.
var air: MusicMix
var silent := false
var _players: Dictionary = {}  # MusicMix.Deck -> Array[AudioStreamPlayer]
var _last_us := 0
## Where the game's music is (a place, or the victory) and its level: the Músicas screen goes back to it.
var _place: StringName = &""
var _level := 1
## The piece the Músicas screen is playing (empty: none).
var _heard: StringName = &""


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	silent = DisplayServer.get_name() == "headless" or Dev.has("shot")
	mix = MusicMix.new(catalog())
	air = MusicMix.new(Ambience.catalog())
	_last_us = Time.get_ticks_usec()


## The pieces with their real lengths (from the files), keyed by the pieces' ids. A one-shot's `then` is a place,
## resolved to the piece chosen there now (Music.choose relinks it).
static func catalog() -> Dictionary:
	var out := {}
	for id: StringName in MusicCatalog.PIECES:
		if not MusicCatalog.is_real(id):
			continue
		var spec: Dictionary = MusicCatalog.spec(id).duplicate()
		var first := stream_of(id, 0)
		if first == null:
			continue
		spec.length = first.get_length()
		if spec.has("then"):
			spec.then = piece_for(spec.then)
		out[id] = spec
	return out


## The piece for a place (the player's choice, or the default); any other id is itself (a piece, the victory).
static func piece_for(id: StringName) -> StringName:
	if not MusicCatalog.PLACES.has(id):
		return id
	var piece := MusicCatalog.resolve(id, _saved(MusicCatalog.OPTION[id]))
	return MusicCatalog.rotation_piece(room_depth) if piece == MusicCatalog.ALTERNATE else piece


## A save option, read through the tree (static: the tools call this before or without the autoloads).
static func _saved(key: String) -> Variant:
	var tree := Engine.get_main_loop() as SceneTree
	var save := tree.root.get_node_or_null(^"Save") if tree != null else null
	if save == null:
		return null
	return (save.get(&"data") as Dictionary).get("options", {}).get(key)


## The player's choice for a place (the Músicas screen): saved at once; the victory's hand-over follows the rooms.
func choose(place: StringName, piece: StringName) -> void:
	if not MusicCatalog.serves(piece, place):
		return
	Save.set_option(MusicCatalog.OPTION[place], String(piece))
	for id: StringName in mix.catalog:
		var then: Variant = MusicCatalog.spec(id).get("then")
		if then != null:
			(mix.catalog[id] as Dictionary).then = piece_for(then)


## A piece's file; places resolve to their piece (tools and tests ask for &"morvath"). `_layers` is the old signature.
static func file_of(id: StringName, layer: int, _layers: int = 0) -> String:
	return MusicCatalog.file_of(piece_for(id), layer)


static func stream_of(id: StringName, layer: int, _layers: int = 0) -> AudioStream:
	var piece := piece_for(id)
	var path := MusicCatalog.file_of(piece, layer)
	if not ResourceLoader.exists(path):
		return null
	var s: AudioStream = load(path)
	if s is AudioStreamOggVorbis:
		var spec := MusicCatalog.spec(piece)
		(s as AudioStreamOggVorbis).loop = spec.get("loop", false)
		(s as AudioStreamOggVorbis).loop_offset = spec.get("loop_from", 0.0)
	return s


## A place (title, catacombs, morvath) plays its chosen piece; any other id (victory) itself. The log keeps the place
## (tools/mix_replay.gd resolves it the same way).
func play(id: StringName, level: int = 1) -> void:
	Audio.log_event(["music", id, level])
	_place = id
	_level = level
	_heard = &""
	mix.release_calm()  # the transition goes out when the next room's music begins
	mix.play(piece_for(id), level)
	_sync()


func set_level(n: int) -> void:
	Audio.log_event(["level", n])
	_level = n
	mix.set_level(n)


## The room's air: the arena's loop (Ambience.BY_ARENA) fades in over the old one; an arena without one, silence.
func ambience(arena: StringName) -> void:
	var loop := Ambience.of(arena)
	Audio.log_event(["air", loop])
	if loop == &"" or not air.catalog.has(loop):
		air.stop()
	else:
		air.play(loop)
	_sync()


## Morvath's warning (Audio.WARN_CUES): the music and the air duck for `seconds`.
func warn(seconds: float) -> void:
	mix.warn(seconds)
	air.warn(seconds)


## CF2-06: the music dips about 3 dB for 0.3 s under the Apogeu's and the Brado's blow.
func blow() -> void:
	mix.blow()


## Morvath's phase n (1 to 4): his piece, at level n (our own adds a layer a phase, a recorded one plays its section).
func boss_phase(n: int) -> void:
	Audio.log_event(["boss", n])
	_place = MusicCatalog.MORVATH
	_level = n
	mix.release_calm()
	var piece := piece_for(MusicCatalog.MORVATH)
	if mix.current_id() != piece:
		mix.play(piece, n)
		_sync()
	else:
		mix.set_level(n)


## MUS-2: the room is won and the doors light up: the fight's layer goes, the calm transition plays over the room's
## bed (ducked under it) until the next room begins (play releases it) or it ends on its own.
func room_won() -> void:
	if mix.current() == null or not mix.catalog.has(&"room_won"):
		return
	Audio.log_event(["room_won"])
	mix.set_level(WALK)
	mix.sting(&"room_won")
	_sync()


## A theme over the bed: "psalm_sentinel" or just the Psalm's id, "sentinel".
func sting(id: StringName) -> void:
	var key: StringName = PSALM_STING.get(id, id if mix.catalog.has(id) else StringName("psalm_" + id))
	Audio.log_event(["sting", key])
	mix.sting(key)
	_sync()


func stop() -> void:
	Audio.log_event(["stop"])
	mix.stop()


## The piece playing (the MusicMix deck id): in the rooms, Music.piece_for(&"catacombs").
func current() -> StringName:
	return mix.current_id()


## The Músicas screen: a piece at a level, crossfaded in like any other (a theme alone, without a bed under it; the
## victory does not hand over to the walk).
func listen(piece: StringName, level: int = 1) -> void:
	if not mix.catalog.has(piece):
		return
	mix.cut_stings()
	_heard = piece
	if bool((mix.catalog[piece] as Dictionary).get("sting", false)):
		mix.stop()
		mix.sting(piece)
	else:
		var d := mix.play(piece, level)
		if d != null:
			d.then = &""
	_sync()


## The level of what the Músicas screen plays (a walk or a fight, Morvath's phase).
func listen_level(level: int) -> void:
	if heard() != &"":
		mix.set_level(level)


## The piece the Músicas screen is still playing (empty when it stopped or ended).
func heard() -> StringName:
	if _heard == &"":
		return &""
	for s: MusicMix.Deck in mix.stings:
		if s.id == _heard and not s.ended():
			return _heard
	var d := mix.current()
	if d != null and d.id == _heard and d.fade_to > 0.0 and not d.ended():
		return _heard
	return &""


## Stops what the Músicas screen plays.
func quiet() -> void:
	_heard = &""
	mix.cut_stings()
	mix.stop()
	_sync()


## Back to the game's music where it was (its place's piece as chosen now), after the Músicas screen.
func resume() -> void:
	_heard = &""
	mix.cut_stings()
	if _place == &"":
		mix.stop()
	elif _place == MusicCatalog.MORVATH:
		boss_phase(_level)
	else:
		play(_place, _level)
	_sync()


func _process(_delta: float) -> void:
	# real seconds: slow motion and hit stop (Engine.time_scale) never slow the music's fades
	var now := Time.get_ticks_usec()
	var dt := minf((now - _last_us) / 1000000.0, 0.25)
	_last_us = now
	mix.step(dt)
	air.step(dt)
	_sync()


func _sync() -> void:
	for m: MusicMix in [mix, air]:
		var changes: Array = m.take_changes()
		for d: MusicMix.Deck in changes[0]:
			_start(d, m)
		for d: MusicMix.Deck in changes[1]:
			for p: AudioStreamPlayer in _players.get(d, []):
				p.queue_free()
			_players.erase(d)
	for d: MusicMix.Deck in _players:
		var m := air if air.decks.has(d) else mix
		var base := Ambience.AMBIENCE_DB if m == air else MUSIC_DB
		var list: Array = _players[d]
		for i in list.size():
			var g: float = m.heard(d, i)
			(list[i] as AudioStreamPlayer).volume_db = base + linear_to_db(maxf(g, 0.0001))


## All the layers of a deck start in the same frame, so they stay in time.
func _start(d: MusicMix.Deck, m: MusicMix) -> void:
	var list: Array[AudioStreamPlayer] = []
	var is_air := m == air
	for i in d.layers():
		var p := AudioStreamPlayer.new()
		p.bus = &"Ambience" if is_air else &"Music"
		p.stream = Ambience.stream_of(d.id) if is_air else stream_of(d.id, i)
		p.volume_db = (Ambience.AMBIENCE_DB if is_air else MUSIC_DB) + linear_to_db(maxf(m.heard(d, i), 0.0001))
		add_child(p)
		list.append(p)
	_players[d] = list
	if silent:
		return
	for p in list:
		if p.stream != null:
			p.play()
