extends Node
## Autoload "Audio": sounds and music by name. Everything is synthesised from the recipes below (single sound map);
## to use a recorded file later, put res://audio/<name>.ogg or .wav and it is played instead.

const W := Synth.Wave
const FILE_DIR := "res://audio/"
const VOICES := 10
const REPEAT_GAP_MS := 45
## name -> list of voices [wave, f0, f1, seconds, volume, curve, start]
const SOUNDS := {
	&"swing": [[W.NOISE, 3000, 900, 0.09, 0.22, 5.0, 0.0]],
	&"hit": [[W.NOISE, 2400, 500, 0.08, 0.4, 6.0, 0.0], [W.SQUARE, 220, 110, 0.07, 0.25, 6.0, 0.0]],
	&"bone": [[W.NOISE, 3200, 1200, 0.05, 0.3, 8.0, 0.0]],
	&"hit_heavy": [[W.NOISE, 1600, 200, 0.16, 0.5, 5.0, 0.0], [W.SINE, 140, 50, 0.2, 0.6, 4.0, 0.0]],
	&"dodge": [[W.NOISE, 700, 2600, 0.13, 0.2, 3.0, 0.0]],
	&"hurt": [[W.SQUARE, 300, 90, 0.22, 0.4, 4.0, 0.0], [W.NOISE, 900, 300, 0.12, 0.3, 5.0, 0.0]],
	&"charged": [[W.TRIANGLE, 660, 1320, 0.16, 0.35, 3.0, 0.0]],
	&"shield": [[W.TRIANGLE, 880, 440, 0.2, 0.4, 4.0, 0.0], [W.NOISE, 4000, 2000, 0.06, 0.2, 6.0, 0.0]],
	&"orb": [[W.TRIANGLE, 1320, 1760, 0.06, 0.16, 5.0, 0.0]],
	&"level_up": [[W.TRIANGLE, 523, 523, 0.12, 0.3, 3.0, 0.0], [W.TRIANGLE, 659, 659, 0.12, 0.3, 3.0, 0.1], [W.TRIANGLE, 784, 784, 0.3, 0.3, 3.0, 0.2]],
	&"boon": [[W.TRIANGLE, 784, 1046, 0.25, 0.3, 3.0, 0.0], [W.SINE, 392, 392, 0.3, 0.25, 3.0, 0.0]],
	&"heal": [[W.SINE, 440, 880, 0.4, 0.35, 2.5, 0.0], [W.TRIANGLE, 660, 1320, 0.4, 0.2, 2.5, 0.08]],
	&"fountain": [[W.SINE, 330, 660, 0.6, 0.3, 2.0, 0.0], [W.TRIANGLE, 990, 990, 0.5, 0.15, 2.5, 0.2]],
	&"elite": [[W.SAW, 110, 82, 0.6, 0.35, 2.0, 0.0], [W.SAW, 165, 123, 0.6, 0.25, 2.0, 0.0]],
	&"elite_down": [[W.NOISE, 1200, 150, 0.4, 0.5, 3.5, 0.0], [W.SINE, 110, 40, 0.4, 0.5, 3.0, 0.0]],
	&"door": [[W.NOISE, 300, 90, 0.9, 0.5, 1.8, 0.0], [W.SAW, 70, 50, 0.9, 0.35, 1.8, 0.0]],
	&"boss_slash": [[W.NOISE, 1800, 300, 0.18, 0.45, 4.0, 0.0], [W.SAW, 160, 70, 0.18, 0.3, 4.0, 0.0]],
	&"boss_dash": [[W.NOISE, 500, 2600, 0.3, 0.4, 2.5, 0.0]],
	# Morvath's fight (provisional recipes): the scythe's heavy sweep, the souls' wail, the eruption's roar, the curse
	&"scythe": [[W.NOISE, 1400, 200, 0.3, 0.5, 3.0, 0.0], [W.SAW, 120, 45, 0.3, 0.4, 3.0, 0.0]],
	&"souls": [[W.TRIANGLE, 700, 1100, 0.35, 0.25, 2.5, 0.0], [W.NOISE, 2400, 900, 0.3, 0.2, 3.0, 0.0]],
	&"eruption": [[W.NOISE, 600, 120, 0.45, 0.35, 2.5, 0.0], [W.SINE, 90, 40, 0.4, 0.4, 3.0, 0.0]],
	&"curse": [[W.SAW, 220, 110, 0.5, 0.25, 2.0, 0.0], [W.TRIANGLE, 330, 165, 0.5, 0.2, 2.0, 0.05]],
	&"cursed": [[W.SQUARE, 180, 90, 0.3, 0.3, 3.0, 0.0], [W.NOISE, 900, 300, 0.25, 0.2, 3.0, 0.0]],
	&"shield_up": [[W.SINE, 220, 440, 0.6, 0.3, 2.0, 0.0], [W.TRIANGLE, 660, 880, 0.5, 0.15, 2.5, 0.1]],
	&"shield_down": [[W.NOISE, 3000, 600, 0.4, 0.45, 3.0, 0.0], [W.TRIANGLE, 880, 220, 0.4, 0.3, 3.0, 0.0]],
	&"summon": [[W.SAW, 98, 196, 0.5, 0.3, 2.0, 0.0], [W.NOISE, 500, 1500, 0.4, 0.2, 3.0, 0.0]],
	&"rain": [[W.TRIANGLE, 1200, 300, 0.35, 0.25, 3.0, 0.0]],
	&"bolt": [[W.SQUARE, 500, 180, 0.14, 0.2, 4.0, 0.0]],
	&"roar": [[W.SAW, 90, 45, 1.0, 0.5, 1.6, 0.0], [W.NOISE, 400, 120, 1.0, 0.4, 1.8, 0.0]],
	&"stagger": [[W.TRIANGLE, 880, 1760, 0.2, 0.35, 3.0, 0.0], [W.NOISE, 2000, 600, 0.15, 0.3, 5.0, 0.0]],
	&"boss_down": [[W.NOISE, 900, 60, 1.2, 0.5, 2.0, 0.0], [W.SINE, 220, 30, 1.2, 0.5, 2.0, 0.0]],
	&"seal": [[W.SINE, 196, 196, 1.2, 0.4, 1.6, 0.0], [W.SINE, 294, 294, 1.2, 0.3, 1.6, 0.0], [W.TRIANGLE, 784, 784, 0.8, 0.15, 2.0, 0.1]],
	&"sword_rise": [[W.TRIANGLE, 660, 990, 0.3, 0.3, 3.0, 0.0], [W.NOISE, 5000, 2500, 0.05, 0.15, 6.0, 0.0]],
	&"ui_move": [[W.SQUARE, 660, 660, 0.03, 0.12, 6.0, 0.0]],
	&"ui_ok": [[W.SQUARE, 660, 990, 0.07, 0.18, 4.0, 0.0]],
}
## name -> [step seconds, bass wave, lead wave, bass notes, melody notes] in semitones from A2 (-99 = rest)
const R := -99
const MUSIC := {
	&"title": [0.5, W.SINE, W.TRIANGLE, [0, R, 7, R, 5, R, 3, R, 0, R, 7, R, 8, R, 7, R], [12, R, 15, 19, 17, R, 15, 12, 12, R, 15, 19, 20, 19, 17, R]],
	&"catacombs": [0.3, W.TRIANGLE, W.SQUARE, [0, 0, 12, 0, 0, 12, 10, 12, 3, 3, 15, 3, 5, 5, 17, 15, 0, 0, 12, 0, 0, 12, 10, 12, 8, 8, 20, 8, 7, 7, 19, 17],
		[12, R, 15, R, 19, R, 15, 17, R, 15, R, 12, 10, R, 12, R, 12, R, 15, R, 19, R, 22, 20, R, 19, R, 15, 17, 19, 17, R]],
	&"morvath": [0.2, W.SAW, W.SQUARE, [0, 0, 0, 12, 0, 0, 11, 12, 1, 1, 1, 13, 1, 1, 12, 13, 0, 0, 0, 12, 0, 0, 11, 12, 5, 5, 17, 5, 6, 6, 18, 6],
		[12, 15, 12, 18, 12, 15, 12, 19, 13, 16, 13, 19, 13, 16, 13, 20, 12, 15, 12, 18, 12, 15, 24, 23, 17, 20, 17, 23, 18, 21, 18, 24]],
	&"seal": [0.6, W.SINE, W.TRIANGLE, [0, R, 5, R, 7, R, 0, R, 5, R, 7, R, 12, R, R, R], [16, R, 19, 21, 24, R, 21, 19, 16, R, 19, 21, 24, 28, 24, R]],
}

var _streams: Dictionary = {}
var _players: Array[AudioStreamPlayer] = []
var _next := 0
var _last_played: Dictionary = {}
var _music: AudioStreamPlayer
var _track: StringName = &""
var _threads: Dictionary = {}
var silent := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	silent = DisplayServer.get_name() == "headless" or Dev.has("shot")
	for bus in ["Music", "SFX"]:
		if AudioServer.get_bus_index(bus) < 0:
			AudioServer.add_bus()
			AudioServer.set_bus_name(AudioServer.bus_count - 1, bus)
	for i in VOICES:
		var p := AudioStreamPlayer.new()
		p.bus = &"SFX"
		add_child(p)
		_players.append(p)
	_music = AudioStreamPlayer.new()
	_music.bus = &"Music"
	add_child(_music)
	apply_volumes()


func apply_volumes() -> void:
	for pair: Array in [["Master", "master"], ["Music", "music"], ["SFX", "sfx"]]:
		var idx := AudioServer.get_bus_index(pair[0])
		var v: float = Save.option(pair[1])
		AudioServer.set_bus_mute(idx, v <= 0.001)
		AudioServer.set_bus_volume_db(idx, linear_to_db(maxf(v, 0.001)))


func play(sound: StringName, pitch: float = 1.0) -> void:
	if silent or not SOUNDS.has(sound):
		return
	var now := Time.get_ticks_msec()
	if now - int(_last_played.get(sound, -1000)) < REPEAT_GAP_MS:
		return
	_last_played[sound] = now
	var p := _players[_next]
	_next = (_next + 1) % VOICES
	p.stream = stream(sound)
	p.pitch_scale = pitch
	p.play()


func stream(sound: StringName) -> AudioStream:
	if not _streams.has(sound):
		_streams[sound] = _from_file(sound)
		if _streams[sound] == null:
			var samples := PackedFloat32Array()
			for v: Array in SOUNDS[sound]:
				samples = Synth.mix(samples, Synth.tone(v[0], v[1], v[2], v[3], v[4], 0.004, v[5]), v[6])
			_streams[sound] = Synth.to_stream(samples)
	return _streams[sound]


## Starts a looping track ("" stops the music). Tracks are built on a worker thread the first time.
func music(track: StringName) -> void:
	_track = track
	if silent:
		return
	_music.stop()
	if track == &"" or not MUSIC.has(track):
		return
	if _streams.has(track):
		_start_music(track)
		return
	var file := _from_file(track)
	if file != null:
		_streams[track] = file
		_start_music(track)
		return
	if not _threads.has(track):
		_threads[track] = WorkerThreadPool.add_task(_build_track.bind(track))


func _build_track(track: StringName) -> void:
	var m: Array = MUSIC[track]
	var s := Synth.to_stream(Synth.loop_track(m[3], m[4], m[0], m[1], m[2]), true, 11025)
	_track_ready.call_deferred(track, s)


func _track_ready(track: StringName, s: AudioStream) -> void:
	_streams[track] = s
	if _track == track:
		_start_music(track)


func _start_music(track: StringName) -> void:
	_music.stream = _streams[track]
	_music.play()


func _from_file(sound: StringName) -> AudioStream:
	# <name>_0.ogg, <name>_1.ogg...: one of them at random each time, with a little pitch play
	if ResourceLoader.exists(FILE_DIR + sound + "_0.ogg"):
		var r := AudioStreamRandomizer.new()
		r.random_pitch = 1.12
		r.random_volume_offset_db = 2.0
		var i := 0
		while ResourceLoader.exists(FILE_DIR + "%s_%d.ogg" % [sound, i]):
			r.add_stream(-1, load(FILE_DIR + "%s_%d.ogg" % [sound, i]))
			i += 1
		return r
	for ext: String in [".ogg", ".wav"]:
		if ResourceLoader.exists(FILE_DIR + sound + ext):
			return load(FILE_DIR + sound + ext)
	return null
