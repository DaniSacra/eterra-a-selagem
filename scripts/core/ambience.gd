class_name Ambience
extends RefCounted
## The air of each room (E6, C15-04): a quiet loop per arena, rendered by our own synthesis (tools/make_ambience.gd,
## audio/ambience/<loop>.ogg, licence in audio/LICENSES.md), played by Music on the Ambience bus and crossfaded on a
## room change by its own MusicMix (FADE_IN, FADE_OUT). The room calls Music.ambience(arena id) as it enters
## (Rooms._enter); an arena not in the table keeps silence. A new arena with an existing air is one line here.

const DIR := "res://audio/ambience/"
## Arena id (RoomLayout.id; the boss's room is "seal_chamber") -> its loop.
const BY_ARENA := {
	&"hall": &"amb_hall",
	&"crypt": &"amb_crypt",
	&"rift": &"amb_rift",
	&"garden": &"amb_garden",
	&"sanctuary": &"amb_sanctuary",
	&"knight_hall": &"amb_sanctuary",  # the guardians' houses keep the Santuário's air (2026-11-23)
	&"elder_hall": &"amb_sanctuary",
	&"bridge": &"amb_bridge",
	&"runes": &"amb_runes",
	&"trial": &"amb_trial",
	&"altar": &"amb_altar",
	&"seal_chamber": &"amb_seal",
}
## Under every loop on the Ambience bus: the air sits well below the music and the blows (tools/mix_probe.gd).
const AMBIENCE_DB := -6.0


static func of(arena: StringName) -> StringName:
	return BY_ARENA.get(arena, &"")


static func file_of(loop: StringName) -> String:
	return DIR + String(loop) + ".ogg"


static func stream_of(loop: StringName) -> AudioStream:
	var path := file_of(loop)
	if loop == &"" or not ResourceLoader.exists(path):
		return null
	var s: AudioStream = load(path)
	if s is AudioStreamOggVorbis:
		(s as AudioStreamOggVorbis).loop = true
	return s


## The loops with their lengths, as a MusicMix catalog (one layer, looping).
static func catalog() -> Dictionary:
	var out := {}
	for arena: StringName in BY_ARENA:
		var loop: StringName = BY_ARENA[arena]
		var s := stream_of(loop)
		if s != null:
			out[loop] = {"layers": 1, "loop": true, "length": s.get_length()}
	return out
