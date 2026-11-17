class_name VoiceGate
extends RefCounted
## Which of Audio's voices a sound may take (E1c, bug 2: E pressed over and over retriggered the blade's synthesised
## chirp on every move, "parece pacman"). Pure, tested in tests/test_voice_gate.gd. As in Hades II, the blade's air
## is many recorded swishes drawn at random (audio/blade_*.ogg...) with a cap on how many sound at once:
## - a family (the blade's four moves are one) never starts twice within its GAP_MS (the same moment, one sound);
## - at most CAP voices of a family sound together: a new one takes the place of the family's oldest, so the newest
##   swing is always heard and the swishes never pile up into a buzz.
## Sounds outside FAMILY are their own family with DEFAULT_GAP_MS and no cap (Audio's round robin as before).

const FAMILY := {
	&"blade": &"blade", &"blade_heavy": &"blade", &"blade_spin": &"blade", &"thrust": &"blade", &"dart": &"blade",
	&"wave_omega": &"blade",
}
const GAP_MS := {&"blade": 70}
const CAP := {&"blade": 2}
const DEFAULT_GAP_MS := 45

## family -> ms it last started
var _last: Dictionary = {}


static func family(sound: StringName) -> StringName:
	return FAMILY.get(sound, sound)


static func gap_ms(fam: StringName) -> int:
	return int(GAP_MS.get(fam, DEFAULT_GAP_MS))


static func cap(fam: StringName) -> int:
	return int(CAP.get(fam, 0))


## Whether `sound` may start at now_ms (and, when it may, it counts as started).
func admit(sound: StringName, now_ms: int) -> bool:
	var fam := family(sound)
	if _last.has(fam) and now_ms - int(_last[fam]) < gap_ms(fam):
		return false
	_last[fam] = now_ms
	return true


## The voice to play `sound` on: `families` and `starts` say what each voice last played and when, `playing` whether
## it still sounds, `next` the round robin's turn. Over the family's cap, the oldest of its voices still sounding.
static func pick(sound: StringName, families: Array[StringName], starts: PackedInt64Array, playing: Array[bool], next: int) -> int:
	var fam := family(sound)
	var limit := cap(fam)
	if limit <= 0:
		return next
	var count := 0
	var oldest := -1
	for i in families.size():
		if playing[i] and families[i] == fam:
			count += 1
			if oldest < 0 or starts[i] < starts[oldest]:
				oldest = i
	if count >= limit:
		return oldest
	# never take another voice of the family through the round robin (it would cut one under the cap)
	var n := families.size()
	for k in n:
		var i := (next + k) % n
		if not (playing[i] and families[i] == fam):
			return i
	return next
