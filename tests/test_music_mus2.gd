extends GutTest
## MUS-2 (the PO, 2026-11-25): the Santuário's own piece, the rooms taking turns between two pieces by depth, and the
## calm transition that plays over the room won until the next room's music begins.

var _options: Dictionary
var _depth: int


func before_each() -> void:
	_options = (Save.data.options as Dictionary).duplicate()
	_depth = Music.room_depth
	for place in MusicCatalog.PLACES:
		Save.data.options[MusicCatalog.OPTION[place]] = String(MusicCatalog.DEFAULT[place])
	Music.mix = MusicMix.new(Music.catalog())


func after_each() -> void:
	Save.data.options = _options
	Music.room_depth = _depth
	Music.mix = MusicMix.new(Music.catalog())


func test_the_hub_has_its_own_piece_and_its_files_are_there() -> void:
	assert_eq(MusicCatalog.DEFAULT[MusicCatalog.HUB], &"thatched_villagers")
	assert_eq(Music.piece_for(MusicCatalog.HUB), &"thatched_villagers")
	assert_eq(Music.piece_for(MusicCatalog.TITLE), &"blade_march", "the title keeps its piece")
	for id: StringName in [&"thatched_villagers", &"heroic_age", &"room_won"]:
		assert_true(ResourceLoader.exists(MusicCatalog.file_of(id, 0)), String(id))
		assert_true(Music.catalog().has(id), "%s is in the mix's catalog" % id)
	assert_false(Music.catalog().has(MusicCatalog.ALTERNATE), "the stand-in has no files")


func test_the_rooms_take_turns_by_depth() -> void:
	var seen := []
	for depth in range(1, 14):
		seen.append(MusicCatalog.rotation_piece(depth))
	assert_eq(seen.slice(0, 5), [&"blade_march", &"blade_march", &"blade_march", &"blade_march", &"blade_march"])
	assert_eq(seen.slice(5, 10), [&"heroic_age", &"heroic_age", &"heroic_age", &"heroic_age", &"heroic_age"])
	assert_eq(seen.slice(10, 13), [&"blade_march", &"blade_march", &"blade_march"])
	assert_eq(MusicCatalog.DEFAULT[MusicCatalog.DUNGEON], MusicCatalog.ALTERNATE)
	Music.room_depth = 3
	assert_eq(Music.piece_for(&"catacombs"), &"blade_march")
	Music.room_depth = 7
	assert_eq(Music.piece_for(&"catacombs"), &"heroic_age")
	# a piece the player picks plays in every room
	Save.data.options.music_dungeon = "heroic_age"
	Music.room_depth = 2
	assert_eq(Music.piece_for(&"catacombs"), &"heroic_age")
	Save.data.options.music_dungeon = "deep_drums"
	Music.room_depth = 8
	assert_eq(Music.piece_for(&"catacombs"), &"deep_drums")


func test_a_whole_piece_serves_the_walk_and_the_fight() -> void:
	assert_true(MusicCatalog.fits(&"heroic_age", MusicCatalog.DUNGEON))
	assert_false(MusicCatalog.fits(&"thatched_villagers", MusicCatalog.DUNGEON))
	Music.room_depth = 6
	Music.play(&"catacombs", Music.FIGHT)
	assert_eq(Music.current(), &"heroic_age")
	assert_eq(Music.mix.level(), 1, "one layer: the fight hears it too")
	Music.mix.step(2.0)
	assert_gt(Music.mix.audible(), 0.5)
	# the next stretch: the other piece crossfades in, the old one fades out (no gap)
	Music.room_depth = 11
	Music.play(&"catacombs", Music.WALK)
	assert_eq(Music.current(), &"blade_march")
	for i in 40:
		Music.mix.step(0.1)
	assert_eq(Music.mix.decks.size(), 1)


func test_the_calm_transition_ducks_the_bed_and_goes_out_with_the_next_room() -> void:
	Music.room_depth = 2
	Music.play(&"catacombs", Music.FIGHT)
	Music.room_won()
	assert_eq(Music.mix.level(), 1, "the fight's layer goes")
	assert_eq(Music.mix.stings.size(), 1)
	assert_eq(Music.mix.stings[0].id, &"room_won")
	for i in 20:
		Music.mix.step(0.1)
	assert_almost_eq(Music.mix.duck, MusicMix.CALM_DUCK, 0.01, "the bed is far below the transition")
	assert_gt(Music.mix.stings[0].gain(0), 0.99, "the transition is heard")
	# the next room begins: the transition fades out in CALM_RELEASE and the bed comes back
	Music.play(&"catacombs", Music.WALK)
	for i in int(MusicMix.CALM_RELEASE / 0.1) + 2:
		Music.mix.step(0.1)
	assert_true(Music.mix.stings.is_empty(), "the transition is gone")
	for i in 10:
		Music.mix.step(0.1)
	assert_almost_eq(Music.mix.duck, 1.0, 0.01)
	assert_gt(Music.mix.audible(), 0.5, "never silence")


func test_a_psalm_sting_is_not_released_by_the_next_room() -> void:
	Music.play(&"catacombs", Music.WALK)
	Music.sting(&"sentinela")
	Music.play(&"catacombs", Music.FIGHT)
	assert_false(Music.mix.stings[0].releasing)


func test_the_transition_without_a_bed_plays_nothing() -> void:
	Music.mix = MusicMix.new(Music.catalog())
	Music.room_won()
	assert_true(Music.mix.stings.is_empty())


func test_old_saves_move_the_old_default_once() -> void:
	var old := SaveData.merged({"version": 14, "options": {"music_hub": "blade_march", "music_dungeon": "blade_march"}})
	assert_eq(old.options.music_hub, "thatched_villagers")
	assert_eq(old.options.music_dungeon, "alternate")
	var picked := SaveData.merged({"version": 14, "options": {"music_hub": "tempting_secrets", "music_dungeon": "deep_drums"}})
	assert_eq(picked.options.music_hub, "tempting_secrets", "a piece picked by hand stays")
	assert_eq(picked.options.music_dungeon, "deep_drums")
	var now := SaveData.merged({"version": 15, "options": {"music_hub": "blade_march"}})
	assert_eq(now.options.music_hub, "blade_march", "a current save's choice stays")


## PT-25-2: the shared options (profile.json) have no version, so the Santuário stayed on blade_march on old computers.
func test_the_profile_moves_the_old_default_once() -> void:
	var old := SaveSlots.options_of({"music_hub": "blade_march", "music_dungeon": "blade_march", "music_title": "blade_march"})
	assert_eq(old.music_hub, "thatched_villagers")
	assert_eq(old.music_dungeon, "alternate")
	assert_eq(old.music_title, "blade_march", "the title keeps its piece")
	assert_true(old.music_moved)
	var later := SaveSlots.options_of({"music_hub": "blade_march", "music_moved": true})
	assert_eq(later.music_hub, "blade_march", "picked by hand after the move, it stays")
	assert_true(SaveSlots.options_of(null).music_hub == "thatched_villagers")
