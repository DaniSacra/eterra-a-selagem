extends Node
## Autoload "Save": the save in use (one of three, SaveSlots: user://save_<n>.json) with the Mastery, the Codex, the
## materials, best times, and the options, which belong to the computer and are shared by the three (profile.json).
## The first screen of the game picks the save (SaveSlotScreen, boot.gd); until then the one used last is loaded, read
## only, so the options are already there. --nosave: no save at all (nothing read, nothing written, no slot screen);
## --slot=N: that save, without the slot screen (captures, tests of a save of one's own); --save-dir=folder: the saves of
## another folder (captures of the slot screen, with --nosave so nothing is written).

## No path of its own (the slot's file is written); a test that writes a save of its own sets `path` elsewhere.
const PATH := ""

## The save in use was written (SaveSeal shows its small seal for a second; benchmark P2-4).
signal written

var data: Dictionary = SaveData.defaults()
var enabled := true
## Where it is written ("": the file of the slot in use; a test writing a save of its own points it elsewhere, never at
## the player's).
var path := PATH
## The save in use (1 to SaveSlots.COUNT; 0: none yet, a new computer before the slot screen).
var slot := 0
## A save was chosen in this session (the slot screen, or --slot): the title shows the slot screen only before.
var chosen := false
## The folder of the saves (user://; a test points it at a folder of its own).
var base := "user://"


func _ready() -> void:
	if Dev.has("save-dir"):
		# captures of the choice of save on saves made for them (read only with --nosave)
		base = Dev.arg("save-dir").trim_suffix("/") + "/"
	if Dev.has("nosave"):
		enabled = false
	if enabled or Dev.has("save-dir"):
		load_profile()
		if Dev.has("slot"):
			slot = clampi(int(Dev.num("slot", 1)), 1, SaveSlots.COUNT)
			chosen = true
		_load_slot()
	_dev_hero()
	_dev_juramentos()
	_dev_materials()


## Reads the profile (the slot used last and the shared options). Never writes.
func load_profile() -> void:
	var profile := SaveSlots.read_profile(base)
	slot = int(profile.active)
	data = SaveData.defaults()
	data.options = SaveSlots.options_of(profile.options)
	# DT-RS2: the visual style kept in the options (stylized by default; the exported build opens in it)
	VisualProfile.remember(data.options)


## The slot in use read into data (the defaults when it is empty), keeping the shared options.
func _load_slot() -> void:
	var options: Dictionary = data.options
	var got: Variant = SaveSlots.read(slot, base) if slot > 0 else null
	data = got if got is Dictionary else SaveData.defaults()
	data.options = options


## Puts save n in use (the slot screen's choice): read from disk, or a new one written at once; the options stay.
func use(n: int) -> void:
	slot = clampi(n, 1, SaveSlots.COUNT)
	chosen = true
	_load_slot()
	write()


## Erases save n for good (its file and its copy); the save in use goes back to none when it was that one.
func erase(n: int) -> void:
	if not enabled:
		return
	SaveSlots.erase(n, base)
	if n == slot:
		slot = 0
		chosen = false
		_load_slot()
		SaveSlots.write_profile(0, data.options, base)


## Captures and checks (E2-06): --hero-xp=N (with --hero-opened=a,b, only those opened) and --hero-equip=a,b set the Warrior's Mastery XP and Gifts for this
## session only (nothing is written afterwards).
func _dev_hero() -> void:
	if not Dev.has("hero-xp") and not Dev.has("hero-equip"):
		return
	enabled = false
	# the Maga's with --hero=maga (the Gifts chapter picks the same hero)
	var maga := Dev.arg("hero") == "maga"
	var block := SaveData.hero(data, "maga" if maga else SaveData.FIRST_HERO)
	if Dev.has("hero-xp"):
		block.mastery_xp = int(Dev.num("hero-xp", 0))
		# a save of that level has opened what its Mastery revealed (as the version 6 migration did); --hero-opened=a,b
		# opens only those (the others revealed stay sealed, for captures of Abrir with Memória)
		if Dev.has("hero-opened"):
			block.opened = Array(Dev.arg("hero-opened").split(",", false))
		else:
			SaveData.open_revealed(block, HeroDef.maga() if maga else null)
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


## Captures and checks (Rejogabilidade, Fatia 1): --materials=silver:30,memory:5,emerald:2 (what the save holds), --forge=N
## (the Forja's Temperar bought), for this session only (nothing is written afterwards). A run reads --forge itself too
## (Game._equip_forge, also the robot's).
func _dev_materials() -> void:
	if not Dev.has("materials") and not Dev.has("forge") and not Dev.has("tools") and not Dev.has("refined"):
		return
	enabled = false
	# Fatia 2: --tools=tool_refine (found) and --refined=refine_fio,refine_peso (forged; the first of each action on it)
	for t in Dev.arg("tools", "").split(",", false):
		Forge.add_tool(data, StringName(t))
	var block := Forge.block(data)
	for id in Dev.arg("refined", "").split(",", false):
		(block.get_or_add("refined", []) as Array).append(id)
		var r := Forge.new(Forge.load_catalog()).find(StringName(id))
		if r != null and not (block.get_or_add("refine", {}) as Dictionary).has(String(r.slot)):
			block.refine[String(r.slot)] = id
	if Dev.has("materials"):
		var got := MaterialPurse.parse(Dev.arg("materials"))
		for id: String in got:
			data.materials[id] = got[id]
	if Dev.has("forge"):
		Forge.block(data)["temper"] = int(Dev.num("forge", 0))


## Writes the save in use (and the profile: the slot and the options). Nothing without a save, nor before a slot is
## chosen (only the options then). Save 1's first write moves the save of before the slots into it (SaveSlots.migrate).
func write() -> void:
	if not enabled:
		return
	var to := path
	if to == "":
		if slot <= 0:
			SaveSlots.write_profile(0, data.options, base)
			return
		if slot == 1 and SaveSlots.has_legacy(base):
			# the save of before the slots keeps the day it was last played
			if int(data.get("played_at", 0)) <= 0 and int(data.get("runs", 0)) > 0:
				data["played_at"] = SaveSlots.legacy_time(base)
			SaveSlots.migrate(base)
		to = SaveSlots.path(slot, base)
		SaveSlots.write_profile(slot, data.options, base)
	if not SaveFile.write(to, JSON.stringify(data, "  ")):
		push_warning("save: could not write %s (the file of before is kept)" % to)
		return
	written.emit()
	if path == "" and not Dev.has("smoke"):
		SaveSeal.flash(self)


func option(key: String) -> Variant:
	return data.options[key]


func set_option(key: String, value: Variant) -> void:
	data.options[key] = value
	if key == "camera":
		# the player's own choice: no default change moves it again (SaveData version 7, LR-01)
		data.options["camera_chosen"] = true
	write_options()


## Puts a visual style and keeps it in the options (DT-RS2): the options screen's "Estilo visual" and the F7 key. The
## look reaches every registered piece at once (VisualProfile.set_look) and the world's air follows it by itself
## (RoomMood, DT-RS1); Arena.restyle is still the room's own call for what it varies outside the profile.
func choose_look(look: VisualProfile.Look) -> void:
	VisualProfile.set_look(look)
	set_option("look", VisualProfile.NAMES[look])


## Writes only the options (the profile): they belong to the computer, and changing one is not a game played (the
## save's "Última partida" stays). A test writing a save of its own (path set) writes it whole instead.
func write_options() -> void:
	if not enabled:
		return
	if path != "":
		write()
		return
	SaveSlots.write_profile(slot, data.options, base)
