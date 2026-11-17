extends GutTest


func test_tone_has_the_right_length_and_stays_in_range() -> void:
	var s := Synth.tone(Synth.Wave.SQUARE, 440.0, 220.0, 0.1, 0.5)
	assert_eq(s.size(), int(0.1 * Synth.RATE))
	for v in s:
		assert_between(v, -0.5, 0.5)
	assert_almost_eq(s[s.size() - 1], 0.0, 0.05, "decays to silence")


func test_mix_adds_at_an_offset_and_grows() -> void:
	var a := PackedFloat32Array([0.1, 0.1])
	var out := Synth.mix(a, PackedFloat32Array([0.2, 0.2]), 1.0 / Synth.RATE)
	assert_eq(out.size(), 3)
	assert_almost_eq(out[1], 0.3, 0.0001)
	assert_almost_eq(out[2], 0.2, 0.0001)


func test_stream_is_16_bit_and_loops_when_asked() -> void:
	var s := Synth.to_stream(PackedFloat32Array([0.0, 1.0, -1.0, 2.0]), true)
	assert_eq(s.data.size(), 8)
	assert_eq(s.data.decode_s16(2), 32000)
	assert_eq(s.data.decode_s16(6), 32000, "clipped")
	assert_eq(s.loop_mode, AudioStreamWAV.LOOP_FORWARD)


func test_notes_follow_equal_temperament() -> void:
	assert_almost_eq(Synth.note(0), 110.0, 0.001)
	assert_almost_eq(Synth.note(12), 220.0, 0.001)


func test_every_sound_the_game_asks_for_has_a_recipe() -> void:
	var asked := {}
	var rx := RegEx.new()
	rx.compile("Audio\\.play\\(&\"([a-z_]+)\"")
	var dirs := ["res://scripts/", "res://scripts/game/", "res://scripts/ui/"]
	for dir: String in dirs:
		for file in DirAccess.get_files_at(dir):
			if file.ends_with(".gd"):
				for m in rx.search_all(FileAccess.get_file_as_string(dir + file)):
					asked[m.get_string(1)] = file
	assert_gt(asked.size(), 15)
	for sound: String in asked:
		assert_true(Audio.SOUNDS.has(StringName(sound)), "%s (asked by %s) has no recipe" % [sound, asked[sound]])
