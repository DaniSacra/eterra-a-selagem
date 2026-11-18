class_name SaveFile
extends RefCounted
## The save on disk, written so that it is never lost (C17, BUG-102): the new text goes to `<path>.tmp` first and
## takes the file's place only once it is whole (a power cut mid-write leaves the old file); the last good file is
## kept as `<path>.bak`; reading falls back to the `.bak` when the file is damaged, and a damaged file is copied aside
## (`<path>.broken`, never written over) before anything else is written. No nodes: the Save autoload calls it.

const TMP := ".tmp"
const BAK := ".bak"
const BROKEN := ".broken"


## The save's dictionary and where it came from: {data: Dictionary or null, from: "main" | "bak" | "none"}. "none"
## with no file at all (a new player) or when neither the file nor its copy can be read; a damaged main file is
## moved aside first (set_aside) so the next write never destroys it.
static func read(path: String) -> Dictionary:
	var main: Variant = parse(path)
	if main is Dictionary:
		return {"data": main, "from": "main"}
	if FileAccess.file_exists(path):
		set_aside(path)
	var bak: Variant = parse(path + BAK)
	if bak is Dictionary:
		return {"data": bak, "from": "bak"}
	return {"data": null, "from": "none"}


## The JSON dictionary in the file, or null (missing, empty, cut short, not a dictionary).
static func parse(path: String) -> Variant:
	if not FileAccess.file_exists(path):
		return null
	var json := JSON.new()  # quiet: JSON.parse_string prints an error for every damaged file
	if json.parse(FileAccess.get_file_as_string(path)) != OK:
		return null
	return json.data if json.data is Dictionary else null


## Writes the text safely: to the temporary file, read back, the good file of now kept as the copy, then renamed into
## place. False when anything failed (the file of before is still there).
static func write(path: String, text: String) -> bool:
	var tmp := path + TMP
	var f := FileAccess.open(tmp, FileAccess.WRITE)
	if f == null:
		return false
	f.store_string(text)
	f.flush()
	f.close()
	if not parse(tmp) is Dictionary:
		DirAccess.remove_absolute(tmp)
		return false
	if parse(path) is Dictionary:
		DirAccess.copy_absolute(path, path + BAK)
	elif FileAccess.file_exists(path):
		set_aside(path)
	if DirAccess.rename_absolute(tmp, path) != OK:
		# some systems refuse to rename over a file: the copy holds the old one while it goes
		DirAccess.remove_absolute(path)
		if DirAccess.rename_absolute(tmp, path) != OK:
			return false
	return true


## Moves a damaged file aside (`.broken`, then `.broken1`, `.broken2`... never over an older one) and returns where.
static func set_aside(path: String) -> String:
	var to := path + BROKEN
	var n := 0
	while FileAccess.file_exists(to):
		n += 1
		to = path + BROKEN + str(n)
	if DirAccess.rename_absolute(path, to) != OK:
		DirAccess.copy_absolute(path, to)
	return to
