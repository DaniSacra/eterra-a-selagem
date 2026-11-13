extends Node
## Autoload "Save": one JSON file in user:// with options, best times and discovered moves.

const PATH := "user://save.json"

var data: Dictionary = SaveData.defaults()
var enabled := true


func _ready() -> void:
	if Dev.has("nosave"):
		enabled = false
		return
	if FileAccess.file_exists(PATH):
		data = SaveData.merged(JSON.parse_string(FileAccess.get_file_as_string(PATH)))


func write() -> void:
	if not enabled:
		return
	var f := FileAccess.open(PATH, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(data, "  "))


func option(key: String) -> Variant:
	return data.options[key]


func set_option(key: String, value: Variant) -> void:
	data.options[key] = value
	write()
