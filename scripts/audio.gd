extends Node
## Autoload "Audio": sounds by name (the music is the Music autoload, scripts/music.gd). The names are the recipes
## below (single sound map); a file res://audio/<name>.ogg or .wav (or <name>_0.ogg, <name>_1.ogg... drawn at random)
## is played instead. T5 (the PO: the synthesis "parece de fliperama"): every name has a recorded file now, CC0 and
## CC-BY recordings layered by tools/make_sfx.sh (weapon in the air, contact, impact, magic; origins and licences in
## audio/LICENSES.md and docs/design/t5_audio.md); the recipes only stand in if a file goes missing.

const W := Synth.Wave
const FILE_DIR := "res://audio/"
## Voices at once (C15-02: a blow now layers its material over the hit, and the enemies' wind-ups and shots sound).
const VOICES := 16
## A sound never starts twice this close (VoiceGate.DEFAULT_GAP_MS; the blade's family has its own gap and cap).
const REPEAT_GAP_MS := VoiceGate.DEFAULT_GAP_MS
## name -> list of voices [wave, f0, f1, seconds, volume, curve, start]
const SOUNDS := {
	&"swing": [[W.NOISE, 3000, 900, 0.09, 0.22, 5.0, 0.0]],
	# the paladin's moves as they start (ComboNode.sound, GF-11): the blade leaving, the spin's longer sweep, the
	# Omega's thrust, the special's dart. E1c (bug 2, the rising synthesised chirp sounded "like pacman" when E was
	# pressed over and over): each is played from recorded swishes in audio/ (blade_0..4, blade_spin_0..2, thrust_0..2,
	# dart_0..2: qubodup's CC0 swooshes, audio/LICENSES.md), one at random with a little pitch play, at most two at
	# once (VoiceGate); these recipes only stand in if the files are missing. The Omega's charge rises while held.
	&"blade": [[W.NOISE, 1800, 5200, 0.09, 0.2, 4.0, 0.0]],
	# T5: the second cut heavier than the first (lower air, the body behind it), the Omega special its own surge
	&"blade_heavy": [[W.NOISE, 1200, 4200, 0.14, 0.22, 3.5, 0.0]],
	&"wave_omega": [[W.NOISE, 700, 3600, 0.4, 0.22, 2.0, 0.0], [W.SINE, 147, 98, 0.4, 0.2, 2.5, 0.0]],
	&"blade_spin": [[W.NOISE, 900, 4200, 0.32, 0.22, 2.0, 0.0], [W.TRIANGLE, 330, 660, 0.28, 0.08, 2.5, 0.0]],
	&"thrust": [[W.NOISE, 2500, 6000, 0.1, 0.22, 4.0, 0.0], [W.TRIANGLE, 880, 1320, 0.12, 0.1, 3.0, 0.0]],
	&"dart": [[W.NOISE, 4000, 7000, 0.07, 0.16, 5.0, 0.0], [W.TRIANGLE, 1320, 1760, 0.08, 0.1, 4.0, 0.0]],
	&"charge_up": [[W.TRIANGLE, 220, 660, 0.6, 0.12, 1.2, 0.0], [W.NOISE, 600, 2400, 0.6, 0.06, 1.5, 0.0]],
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
	# cycle 9, Morvath's beats: the scythe lifted (a low swell) and biting the stone, the crouch before the charge and
	# its landing, a dead coming up from its rune, the curse leaving his hand, the turn of a phase (a falling chord
	# under the roar), and the ending (his power drawn away, then Emeth's clear answer)
	&"scythe_raise": [[W.SAW, 70, 140, 0.55, 0.22, 1.6, 0.0], [W.NOISE, 300, 900, 0.5, 0.12, 2.0, 0.0]],
	&"scythe_land": [[W.NOISE, 700, 90, 0.35, 0.4, 3.0, 0.0], [W.SINE, 80, 35, 0.35, 0.45, 3.0, 0.0]],
	&"dash_aim": [[W.SAW, 55, 85, 0.6, 0.22, 1.8, 0.0]],
	&"dash_land": [[W.NOISE, 500, 70, 0.4, 0.45, 3.0, 0.0], [W.SINE, 70, 30, 0.4, 0.5, 3.0, 0.0]],
	&"rise": [[W.NOISE, 300, 1100, 0.35, 0.18, 2.5, 0.0], [W.TRIANGLE, 147, 220, 0.35, 0.14, 2.5, 0.0]],
	&"curse_release": [[W.SAW, 330, 160, 0.3, 0.22, 3.0, 0.0], [W.NOISE, 1600, 500, 0.25, 0.15, 3.0, 0.0]],
	&"phase_shift": [[W.SAW, 147, 73, 1.2, 0.25, 1.5, 0.0], [W.SAW, 175, 87, 1.2, 0.18, 1.5, 0.05], [W.TRIANGLE, 587, 293, 0.9, 0.12, 2.0, 0.15]],
	&"victory_draw": [[W.NOISE, 1500, 300, 1.6, 0.25, 1.4, 0.0], [W.SINE, 110, 220, 1.6, 0.25, 1.5, 0.0]],
	&"victory_release": [[W.TRIANGLE, 392, 392, 1.0, 0.3, 1.8, 0.0], [W.TRIANGLE, 587, 587, 1.0, 0.22, 1.8, 0.08], [W.SINE, 784, 784, 0.9, 0.18, 2.0, 0.16]],
	&"bolt": [[W.SQUARE, 500, 180, 0.14, 0.2, 4.0, 0.0]],
	&"roar": [[W.SAW, 90, 45, 1.0, 0.5, 1.6, 0.0], [W.NOISE, 400, 120, 1.0, 0.4, 1.8, 0.0]],
	&"stagger": [[W.TRIANGLE, 880, 1760, 0.2, 0.35, 3.0, 0.0], [W.NOISE, 2000, 600, 0.15, 0.3, 5.0, 0.0]],
	&"boss_down": [[W.NOISE, 900, 60, 1.2, 0.5, 2.0, 0.0], [W.SINE, 220, 30, 1.2, 0.5, 2.0, 0.0]],
	&"seal": [[W.SINE, 196, 196, 1.2, 0.4, 1.6, 0.0], [W.SINE, 294, 294, 1.2, 0.3, 1.6, 0.0], [W.TRIANGLE, 784, 784, 0.8, 0.15, 2.0, 0.1]],
	&"sword_rise": [[W.TRIANGLE, 660, 990, 0.3, 0.3, 3.0, 0.0], [W.NOISE, 5000, 2500, 0.05, 0.15, 6.0, 0.0]],
	# C15-02, the fight's sounds (CombatSounds; provisional synthesis, D-12b). A blow's material, laid over the blade's
	# hit: dry bone, a shield's dull clonk, the ring of plate (also any blow on an armor bar), Morvath's hollow
	# spectral flesh; a blow on his ritual's ward; a wind-up cut by a blow; the armor bar breaking
	&"mat_bone": [[W.NOISE, 3800, 1500, 0.04, 0.22, 9.0, 0.0], [W.TRIANGLE, 900, 600, 0.04, 0.1, 8.0, 0.0]],
	&"mat_shield": [[W.SQUARE, 240, 180, 0.1, 0.16, 6.0, 0.0], [W.NOISE, 1200, 500, 0.08, 0.2, 6.0, 0.0]],
	&"mat_armor": [[W.TRIANGLE, 1760, 1480, 0.18, 0.14, 4.0, 0.0], [W.SQUARE, 660, 620, 0.12, 0.06, 5.0, 0.0], [W.NOISE, 5000, 2500, 0.05, 0.14, 7.0, 0.0]],
	&"mat_spectral": [[W.SINE, 330, 220, 0.25, 0.16, 3.0, 0.0], [W.TRIANGLE, 990, 660, 0.2, 0.08, 3.5, 0.02], [W.NOISE, 1200, 400, 0.15, 0.1, 4.0, 0.0]],
	&"ward": [[W.TRIANGLE, 1760, 1320, 0.1, 0.14, 5.0, 0.0], [W.NOISE, 6000, 3000, 0.05, 0.08, 6.0, 0.0]],
	&"interrupt": [[W.NOISE, 2600, 700, 0.07, 0.26, 7.0, 0.0], [W.SQUARE, 520, 260, 0.09, 0.12, 5.0, 0.0]],
	&"armor_break": [[W.NOISE, 5000, 1500, 0.3, 0.3, 3.0, 0.0], [W.TRIANGLE, 1320, 440, 0.25, 0.16, 3.5, 0.0], [W.SQUARE, 180, 90, 0.15, 0.12, 5.0, 0.0]],
	# the fall of a shielded or armored body, and of a spectral one
	&"kill_metal": [[W.NOISE, 2200, 400, 0.3, 0.28, 3.5, 0.0], [W.SQUARE, 330, 150, 0.2, 0.1, 4.0, 0.0], [W.TRIANGLE, 1320, 990, 0.25, 0.08, 4.0, 0.05]],
	&"kill_spectral": [[W.SINE, 440, 110, 0.6, 0.24, 2.0, 0.0], [W.NOISE, 1600, 300, 0.5, 0.14, 2.5, 0.0]],
	# an enemy's wind-up starting, one per EnemyDef.Tell, short and soft (it helps a dodge): a blade drawn, embers
	# hissing, an orb swelling, a crossbow cocked, a shield set with a grunt, a ritual's hum
	&"tell_blade": [[W.NOISE, 3000, 6000, 0.18, 0.1, 2.0, 0.0], [W.TRIANGLE, 1200, 1500, 0.15, 0.05, 3.0, 0.0]],
	&"tell_ember": [[W.NOISE, 1500, 4500, 0.25, 0.12, 1.6, 0.0]],
	&"tell_orb": [[W.SINE, 660, 990, 0.3, 0.1, 1.8, 0.0], [W.TRIANGLE, 1320, 1980, 0.25, 0.05, 2.2, 0.03]],
	&"tell_bolt": [[W.SQUARE, 160, 240, 0.12, 0.09, 3.0, 0.0], [W.NOISE, 2000, 800, 0.05, 0.12, 7.0, 0.1]],
	&"tell_shield": [[W.SAW, 90, 70, 0.3, 0.14, 2.5, 0.0], [W.NOISE, 400, 200, 0.2, 0.12, 3.0, 0.0]],
	&"tell_ritual": [[W.SINE, 147, 220, 0.5, 0.12, 1.6, 0.0], [W.TRIANGLE, 294, 440, 0.45, 0.06, 2.0, 0.0]],
	# its blow loosed, its shots leaving (the bolt is the recipe above)
	&"enemy_swing": [[W.NOISE, 900, 2600, 0.12, 0.16, 3.5, 0.0]],
	&"enemy_charge": [[W.NOISE, 300, 900, 0.35, 0.2, 2.0, 0.0], [W.SAW, 80, 60, 0.3, 0.12, 2.5, 0.0]],
	&"enemy_burst": [[W.NOISE, 2000, 300, 0.25, 0.26, 3.0, 0.0], [W.SINE, 160, 60, 0.25, 0.22, 3.0, 0.0]],
	&"shot_orb": [[W.TRIANGLE, 1100, 700, 0.12, 0.12, 4.0, 0.0], [W.SINE, 550, 350, 0.12, 0.1, 4.0, 0.0]],
	&"shot_vine": [[W.NOISE, 500, 1500, 0.3, 0.12, 2.0, 0.0], [W.SAW, 110, 90, 0.25, 0.07, 3.0, 0.0]],
	# the circle of light let go, its held version, and that one bursting
	&"circle": [[W.SINE, 523, 784, 0.35, 0.18, 2.5, 0.0], [W.TRIANGLE, 1046, 1568, 0.3, 0.08, 3.0, 0.05]],
	&"circle_omega": [[W.SINE, 392, 784, 0.5, 0.22, 2.0, 0.0], [W.TRIANGLE, 784, 1568, 0.45, 0.1, 2.5, 0.06], [W.NOISE, 2000, 5000, 0.3, 0.06, 3.0, 0.0]],
	&"circle_burst": [[W.NOISE, 1400, 300, 0.3, 0.32, 3.0, 0.0], [W.SINE, 196, 98, 0.35, 0.32, 3.0, 0.0], [W.TRIANGLE, 784, 392, 0.3, 0.12, 3.0, 0.0]],
	# the ultimate: the Emeth gathering in the gesture, the cleave splitting the floor, the Voragem's turning breath
	# and its implosion (Ultimates; CombatSounds ult_*)
	&"ult_gesture": [[W.TRIANGLE, 330, 990, 0.3, 0.14, 1.5, 0.0], [W.NOISE, 800, 3200, 0.3, 0.08, 1.8, 0.0]],
	&"ult_cleave": [[W.NOISE, 2200, 180, 0.45, 0.34, 3.0, 0.0], [W.SINE, 110, 40, 0.5, 0.36, 3.0, 0.0], [W.TRIANGLE, 660, 330, 0.3, 0.1, 3.0, 0.02]],
	&"vortex": [[W.NOISE, 400, 1600, 0.9, 0.16, 1.2, 0.0], [W.SINE, 147, 196, 0.9, 0.14, 1.5, 0.0], [W.TRIANGLE, 587, 880, 0.6, 0.06, 2.0, 0.1]],
	&"ult_implode": [[W.NOISE, 3000, 250, 0.35, 0.32, 3.0, 0.0], [W.SINE, 165, 55, 0.4, 0.34, 3.0, 0.0], [W.TRIANGLE, 988, 494, 0.3, 0.1, 3.0, 0.0]],
	&"ui_move": [[W.SQUARE, 660, 660, 0.03, 0.12, 6.0, 0.0]],
	&"ui_ok": [[W.SQUARE, 660, 990, 0.07, 0.18, 4.0, 0.0]],
}
## The ceiling of everything heard (GP-05 of cycle C12c): a hard limiter at the end of the Master bus keeps the sum
## of a full fight at most this loud (the video of cycle 12 peaked at +0.04 dBFS, a clip). E4 (C15-03): -1.5 on the
## samples, so the true peak between them stays under -1 dBTP (tools/mix_probe.gd: at -1.0 the worst storm of blows
## over Morvath's music reached -0.9 dBTP).
const LIMIT_DB := -1.5
const LIMIT_RELEASE := 0.1
## E6 (C15-01): the buses, all into Master (whose limiter is the last thing), each with its own trim in dB under the
## save's volume: the blows (SFX) sit lower so the limiter is a guard, not a compressor (B-3: it was at the ceiling
## in 67 windows of 0.1 s); the interface and the rooms' air follow the effects' volume, the air at its own level.
## Which option sets each bus's volume: Master master, Music music, SFX/UI/Ambience sfx.
const BUSES := {
	&"Music": {"option": "music", "trim": 9.0},
	&"SFX": {"option": "sfx", "trim": 2.0},
	&"UI": {"option": "sfx", "trim": -6.0},
	&"Ambience": {"option": "sfx", "trim": 0.0},
}
## Each sound's own trim, dB (C15-01, B-3; measured by tools/mix_probe.gd --log --why on a descent and Morvath): the
## sounds that stacked into the limiter in a real run (a kill landing on a blow, a phase's roar) sit lower, so the
## mix can be louder on the whole with the limiter only a guard. A sound not here plays at 0.
const GAIN_DB := {
	&"elite_down": -5.0, &"boss_down": -4.0, &"roar": -4.0, &"phase_shift": -2.0, &"bone": -5.0, &"hit": -4.0,
	&"shield": -5.0, &"stagger": -5.0, &"armor_break": -3.0, &"door": -4.0, &"dash_land": -3.0, &"scythe": -2.0,
	&"scythe_land": -2.0, &"eruption": -2.0, &"shield_down": -2.0, &"elite": -2.0, &"level_up": -3.0, &"hurt": -2.0,
	&"heal": -3.0, &"mat_spectral": -2.0, &"mat_bone": -2.0,
}
## The menus' sounds go to the UI bus.
const UI_SOUNDS: Array[StringName] = [&"ui_move", &"ui_ok"]
## Morvath's warnings (C15-01): each ducks the music and the air for this long (seconds), so the tell is heard.
const WARN_CUES := {
	&"scythe_raise": 0.9, &"dash_aim": 0.9, &"eruption": 1.2, &"curse": 1.0, &"roar": 1.2, &"summon": 0.6,
}

var _streams: Dictionary = {}
var _players: Array[AudioStreamPlayer] = []
var _next := 0
var _gate := VoiceGate.new()
## What each voice last played (its VoiceGate family) and when it started (ms).
var _voice_family: Array[StringName] = []
var _voice_start := PackedInt64Array()
var silent := false
## Tests: every sound let through the gate, as [name, ms] (only while record is on), and the clock the gate reads
## (the real one unless a test steps the game faster than real time).
var record := false
var heard: Array = []
var clock: Callable = Time.get_ticks_msec


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	silent = DisplayServer.get_name() == "headless" or Dev.has("shot")
	make_buses()
	if Dev.has("sound-log"):
		# tools/mix_probe.gd --log: every sound, music and air change of a run on the game's clock (the smoke runs
		# use --fixed-fps 60), written when the game quits
		listen(true, func() -> int: return Engine.get_process_frames() * 1000 / 60)
	for i in VOICES:
		var p := AudioStreamPlayer.new()
		p.bus = &"SFX"
		add_child(p)
		_players.append(p)
		_voice_family.append(&"")
		_voice_start.append(0)
	limit_master()
	apply_volumes()


## Puts the limiter (LIMIT_DB) at the end of the Master bus, once. Returns it.
static func limit_master() -> AudioEffectHardLimiter:
	var bus := AudioServer.get_bus_index(&"Master")
	for i in AudioServer.get_bus_effect_count(bus):
		var fx := AudioServer.get_bus_effect(bus, i)
		if fx is AudioEffectHardLimiter:
			return fx
	var limiter := AudioEffectHardLimiter.new()
	limiter.ceiling_db = LIMIT_DB
	limiter.release = LIMIT_RELEASE
	AudioServer.add_bus_effect(bus, limiter)
	return limiter


## The buses of BUSES under Master (made once).
static func make_buses() -> void:
	for bus: StringName in BUSES:
		if AudioServer.get_bus_index(bus) < 0:
			AudioServer.add_bus()
			AudioServer.set_bus_name(AudioServer.bus_count - 1, bus)
		AudioServer.set_bus_send(AudioServer.get_bus_index(bus), &"Master")


## A bus's level in dB for a volume option (0 to 1) and its trim.
static func bus_db(volume: float, trim: float) -> float:
	return linear_to_db(maxf(volume, 0.001)) + trim


func apply_volumes() -> void:
	var master: float = Save.option("master")
	var idx := AudioServer.get_bus_index(&"Master")
	AudioServer.set_bus_mute(idx, master <= 0.001)
	AudioServer.set_bus_volume_db(idx, bus_db(master, 0.0))
	for bus: StringName in BUSES:
		var v: float = Save.option(BUSES[bus].option)
		idx = AudioServer.get_bus_index(bus)
		AudioServer.set_bus_mute(idx, v <= 0.001)
		AudioServer.set_bus_volume_db(idx, bus_db(v, BUSES[bus].trim))


## The sound log (--sound-log=file): one entry, stamped with the clock, if the log is on.
func log_event(entry: Array) -> void:
	if record and Dev.has("sound-log"):
		heard.append([int(clock.call())] + entry)


func _exit_tree() -> void:
	if Dev.has("sound-log"):
		var f := FileAccess.open(Dev.arg("sound-log"), FileAccess.WRITE)
		if f:
			f.store_string(JSON.stringify({"events": heard}))


## Tests: start recording what is heard on the given clock, with the gate's memory cleared.
func listen(on: bool, by: Callable = Time.get_ticks_msec) -> void:
	record = on
	heard.clear()
	clock = by
	_gate = VoiceGate.new()


func play(sound: StringName, pitch: float = 1.0) -> void:
	if not SOUNDS.has(sound) or (silent and not record):
		return
	var now := int(clock.call())
	if not _gate.admit(sound, now):
		return
	if record:
		if Dev.has("sound-log"):
			heard.append([now, "sfx", sound, pitch])
		else:
			heard.append([sound, now])
	if WARN_CUES.has(sound):
		Music.warn(WARN_CUES[sound])
	if silent:
		return
	var playing: Array[bool] = []
	for v in _players:
		playing.append(v.playing)
	var i := VoiceGate.pick(sound, _voice_family, _voice_start, playing, _next)
	if i == _next:
		_next = (_next + 1) % VOICES
	_voice_family[i] = VoiceGate.family(sound)
	_voice_start[i] = now
	var p := _players[i]
	p.stop()
	p.stream = stream(sound)
	p.bus = &"UI" if sound in UI_SOUNDS else &"SFX"
	p.pitch_scale = pitch
	p.volume_db = GAIN_DB.get(sound, 0.0)
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
