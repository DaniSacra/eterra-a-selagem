class_name MusicCatalog
extends RefCounted
## Every piece of music the game has, as data (T5, the PO's review: "deixar eu ouvir as músicas que já temos e
## escolher"): the name the player reads, its files, how its layers sound together and where it may play. The player
## picks one piece per place in the Músicas screen (MusicRoomScreen), saved as the options music_title, music_dungeon
## and music_morvath; Music.play(place) plays the chosen one. A new piece is one entry here and its files in
## audio/music/ (and its name in data/text_pt.tres).

## The places: the title, the rooms (walk and fight) and Morvath (four phases). The ids are the ones the game always
## asked Music for (Music.play(&"catacombs")...).
const TITLE := &"title"
const DUNGEON := &"catacombs"
const MORVATH := &"morvath"
const PLACES: Array[StringName] = [TITLE, DUNGEON, MORVATH]
## The save option of each place (SaveData.defaults).
const OPTION := {TITLE: "music_title", DUNGEON: "music_dungeon", MORVATH: "music_morvath"}
## The default of each place: our own music everywhere (the PO liked it; the title hears the walk of the rooms, as
## before T5).
const DEFAULT := {TITLE: &"classic_catacombs", DUNGEON: &"classic_catacombs", MORVATH: &"classic_morvath"}
## Where the music files are.
const DIR := "res://audio/music/"

## id -> the piece:
##   name: text key of its name; file: audio/music/<file>.ogg (one layer) or <file>_1.ogg, _2.ogg...
##   layers: how many; solo: level n hears only layer n (a recorded piece, its sections never stacked) or, without
##   it, the first n together (our own, written in layers); loop; loop_from: seconds the loop goes back to;
##   then: the place a one-shot hands over to; sting: a short theme over the bed;
##   places: where the player may choose it (a rooms' piece on the title plays its walk); empty: only to listen.
## The order is the order of the list on screen.
const PIECES := {
	&"classic_catacombs": {"name": "music_classic_catacombs", "file": "classic_catacombs", "layers": 2, "loop": true, "places": [TITLE, DUNGEON]},
	&"classic_morvath": {"name": "music_classic_morvath", "file": "classic_morvath", "layers": 4, "loop": true, "places": [MORVATH]},
	&"tempting_secrets": {"name": "music_tempting_secrets", "file": "title", "layers": 1, "loop": true, "loop_from": 16.0, "places": [TITLE]},
	&"gloom_descent": {"name": "music_gloom_descent", "file": "catacombs", "layers": 2, "loop": true, "solo": true, "places": [TITLE, DUNGEON]},
	&"clash_defiant": {"name": "music_clash_defiant", "file": "morvath", "layers": 4, "loop": true, "solo": true, "places": [MORVATH]},
	&"victory": {"name": "music_victory", "file": "victory", "layers": 1, "loop": false, "then": DUNGEON, "places": []},
	&"psalm_sentinel": {"name": "music_psalm_sentinel", "file": "psalm_sentinel", "layers": 1, "loop": false, "sting": true, "places": []},
	&"psalm_shelter": {"name": "music_psalm_shelter", "file": "psalm_shelter", "layers": 1, "loop": false, "sting": true, "places": []},
	&"psalm_shepherd": {"name": "music_psalm_shepherd", "file": "psalm_shepherd", "layers": 1, "loop": false, "sting": true, "places": []},
	&"psalm_rock": {"name": "music_psalm_rock", "file": "psalm_rock", "layers": 1, "loop": false, "sting": true, "places": []},
}
## How many layers a place needs: the rooms a walk and a fight, Morvath one per phase; the title any piece.
const NEEDS := {TITLE: 1, DUNGEON: 2, MORVATH: 4}


static func has(id: StringName) -> bool:
	return PIECES.has(id)


static func spec(id: StringName) -> Dictionary:
	return PIECES.get(id, {})


static func layers(id: StringName) -> int:
	return int(spec(id).get("layers", 1))


## The piece may be chosen for the place.
static func serves(id: StringName, place: StringName) -> bool:
	return PIECES.has(id) and (PIECES[id].places as Array).has(place)


## The pieces the player may choose for a place, in the list's order.
static func choices(place: StringName) -> Array[StringName]:
	var out: Array[StringName] = []
	for id: StringName in PIECES:
		if serves(id, place):
			out.append(id)
	return out


## The piece that plays at a place for a saved choice: the choice when it serves there, else the default (a missing,
## damaged or old option, a piece that left the game).
static func resolve(place: StringName, chosen: Variant) -> StringName:
	if chosen is String or chosen is StringName:
		var id := StringName(chosen)
		if serves(id, place):
			return id
	return DEFAULT.get(place, &"")


## The next or previous choice for a place (wraps around).
static func step(place: StringName, current: StringName, dir: int) -> StringName:
	var list := choices(place)
	if list.is_empty():
		return current
	var i := list.find(current)
	return list[posmod((i if i >= 0 else 0) + dir, list.size())]


static func file_of(id: StringName, layer: int) -> String:
	var s := spec(id)
	var base := String(s.get("file", id))
	return DIR + (base if int(s.get("layers", 1)) == 1 else "%s_%d" % [base, layer + 1]) + ".ogg"
