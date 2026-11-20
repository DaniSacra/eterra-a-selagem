extends Node
## Autoload "Save": one JSON file in user:// with options, best times and discovered moves.

const PATH := "user://save.json"

var data: Dictionary = SaveData.defaults()
var enabled := true
## Where it is written (PATH; a test writing a save of its own points it elsewhere, never at the player's).
var path := PATH


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
	_dev_materials()


## Captures and checks (E2-06): --hero-xp=N (with --hero-opened=a,b, only those opened) and --hero-equip=a,b set the Warrior's Mastery XP and Gifts for this
## session only (nothing is written afterwards).
func _dev_hero() -> void:
	if not Dev.has("hero-xp") and not Dev.has("hero-equip"):
		return
	enabled = false
	var block := SaveData.hero(data, SaveData.FIRST_HERO)
	if Dev.has("hero-xp"):
		block.mastery_xp = int(Dev.num("hero-xp", 0))
		# a save of that level has opened what its Mastery revealed (as the version 6 migration did); --hero-opened=a,b
		# opens only those (the others revealed stay sealed, for captures of Abrir with Memória)
		if Dev.has("hero-opened"):
			block.opened = Array(Dev.arg("hero-opened").split(",", false))
		else:
			SaveData.open_revealed(block)
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


## Captures and checks (Rejogabilidade, Fatia 1): --materials=silver:30,memory:5 (what the save holds) and --forge=N
## (the Forja's Temperar bought), for this session only (nothing is written afterwards). A run reads --forge itself too
## (Game._equip_forge, also the robot's).
func _dev_materials() -> void:
	if not Dev.has("materials") and not Dev.has("forge"):
		return
	enabled = false
	if Dev.has("materials"):
		var got := MaterialPurse.parse(Dev.arg("materials"))
		for id: String in got:
			data.materials[id] = got[id]
	if Dev.has("forge"):
		Forge.block(data)["temper"] = int(Dev.num("forge", 0))


func write() -> void:
	if not enabled:
		return
	if not SaveFile.write(path, JSON.stringify(data, "  ")):
		push_warning("save: could not write %s (the file of before is kept)" % path)


func option(key: String) -> Variant:
	return data.options[key]


func set_option(key: String, value: Variant) -> void:
	data.options[key] = value
	if key == "camera":
		# the player's own choice: no default change moves it again (SaveData version 7, LR-01)
		data.options["camera_chosen"] = true
	write()
