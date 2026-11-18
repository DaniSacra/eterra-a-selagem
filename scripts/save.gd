extends Node
## Autoload "Save": one JSON file in user:// with options, best times and discovered moves.

const PATH := "user://save.json"

var data: Dictionary = SaveData.defaults()
var enabled := true


func _ready() -> void:
	if Dev.has("nosave"):
		enabled = false
	else:
		# C17, BUG-102: a damaged file falls back to its copy and is moved aside, never written over
		var got := SaveFile.read(PATH)
		if got.data != null:
			data = SaveData.merged(got.data)
		if got.from == "bak":
			push_warning("save: %s could not be read; loaded its copy %s%s" % [PATH, PATH, SaveFile.BAK])
	_dev_hero()
	_dev_juramentos()


## Captures and checks (E2-06): --hero-xp=N and --hero-equip=a,b set the Warrior's Mastery XP and Gifts for this
## session only (nothing is written afterwards).
func _dev_hero() -> void:
	if not Dev.has("hero-xp") and not Dev.has("hero-equip"):
		return
	enabled = false
	var block := SaveData.hero(data, SaveData.FIRST_HERO)
	if Dev.has("hero-xp"):
		block.mastery_xp = int(Dev.num("hero-xp", 0))
	if Dev.has("hero-equip"):
		block.equipped = Array(Dev.arg("hero-equip").split(",", false))
	if Dev.has("hero-ult"):
		block.ultimate = Dev.arg("hero-ult")


## Captures and checks (E6): --wins=N (Morvath sealed N times: the Juramentos open) and, on the title,
## --juramentos=id:rank,... as the ranks chosen; for this session only (nothing is written afterwards).
func _dev_juramentos() -> void:
	if not Dev.has("wins") and not (Dev.has("juramentos") and Dev.has("title")):
		return
	enabled = false
	if Dev.has("wins"):
		data.wins = int(Dev.num("wins", 0))
	if Dev.has("juramentos"):
		Juramentos.block(data)["ranks"] = Juramentos.parse(Dev.arg("juramentos"))


func write() -> void:
	if not enabled:
		return
	if not SaveFile.write(PATH, JSON.stringify(data, "  ")):
		push_warning("save: could not write %s (the file of before is kept)" % PATH)


func option(key: String) -> Variant:
	return data.options[key]


func set_option(key: String, value: Variant) -> void:
	data.options[key] = value
	write()
