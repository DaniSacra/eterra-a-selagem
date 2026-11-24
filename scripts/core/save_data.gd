class_name SaveData
extends RefCounted
## Pure rules of the save file (options, best times, discovered moves, each hero's Mastery and Gifts, the Codex). The
## Save autoload does the disk part.

## 2: full screen by default (Daniel, 2026-11-16); an older file switches to it once.
## 3 (DT-012, E2a): heroes (heroes.<id>: mastery_xp, unlocked, equipped, ultimate, firsts) and codex (boons, elos,
## psalms, talents, enemies: id to a small dictionary of counts). An older file gets the Warrior's Mastery for what it
## already played, once (MasteryCurve.retro_xp).
## 4 (E6, D-63): juramentos (ranks: the Juramentos chosen for the next descent, id to rank; best: the highest Peso
## won). An older file opens with none chosen and nothing won; nothing else changes.
## 6 (Rejogabilidade, Fatia 1; sistemas.md 5.1): materials (silver, memory, emerald: what the save holds, MaterialPurse)
## and materials_total (all ever brought home); in each hero, opened (the Gifts opened with Memória), forge (temper: the
## Forja's highest Temperar bought; refine, awaken, inscribed for the next slices) and tools (the Forjador's, Fatia 2).
## An older file opens every Gift its Mastery had already unlocked, for free (nobody loses a Gift), and gets 5 silver a
## descent it played, up to 30 (Q-RJ8 a, MaterialPurse.retro_silver), once.
## 10 (Lote 5, the account's tree "O Preparo", Account): account (bought: the ids of the nodes bought, for every hero). An
## older file opens with none bought; nothing else changes.
## 12 (A Videira, V1, replaced "O Preparo"): vine (bought: ids of the nodes, Vine) in place of account. What a file had
## bought of the old tree comes back as the material it paid (Prata or Memória, exact, LEGACY_PREPARO), the old block is left.
const VERSION := 12
const MAX_BEST_TIMES := 5
## The hero every older save belongs to (HeroDef.id).
const FIRST_HERO := "warrior"
## The heroes a player can pick (HeroDef.id), the first one the default.
const HEROES: Array[String] = [FIRST_HERO, "maga"]
## Codex sections: each maps an id to a dictionary of counts (seen, formed, defeated...). E4-05: enemies (defeated,
## elite; Morvath: met, phase the highest reached, defeated) and arenas (entered).
const CODEX: Array[String] = ["boons", "elos", "psalms", "talents", "enemies", "arenas", "angels"]
## The lists of ids in a hero's block (only strings are kept).
const HERO_LISTS: Array[String] = ["unlocked", "equipped", "opened", "tools", "refined", "inscribed", "awakened", "finds", "recipes", "seen"]


static func defaults() -> Dictionary:
	var codex := {}
	for section in CODEX:
		codex[section] = {}
	return {
		"version": VERSION,
		"options": {"master": 0.8, "music": 0.7, "sfx": 0.9, "fullscreen": true, "scale": 1, "shake": true, "impact_frames": true, "slow_motion": true, "color_split": true, "rumble": true, "quality": 0, "camera": "near", "camera_chosen": false, "bindings": {},
			# DT-RS2: the visual profile (VisualProfile.NAMES); a save from before has none and opens stylized
			"look": "stylized",
			# T5 (the PO's review): the piece chosen for each place (MusicCatalog; Music.piece_for falls back to the default)
			"music_title": String(MusicCatalog.DEFAULT[MusicCatalog.TITLE]), "music_hub": String(MusicCatalog.DEFAULT[MusicCatalog.HUB]),
			"music_dungeon": String(MusicCatalog.DEFAULT[MusicCatalog.DUNGEON]),
			"music_morvath": String(MusicCatalog.DEFAULT[MusicCatalog.MORVATH])},
		"best_times": [],
		"moves": [],
		"wins": 0,
		"runs": 0,
		"heroes": {FIRST_HERO: hero_defaults()},
		# M1b: the hero picked at the Portal for the next descents (HEROES); a save from before has none: the Warrior
		"hero": FIRST_HERO,
		"codex": codex,
		"juramentos": juramentos_defaults(),
		"materials": MaterialPurse.defaults(),
		"materials_total": MaterialPurse.defaults(),
		# since version 8 (Ofícios, Roteiro A): the pick's journey, the Pedra Funda, the Vendedor's order (Oficios)
		"oficios": Oficios.defaults(),
		# when the last descent ended (unix seconds, 0: none; the slot screen's "Última partida"), by Game.log_run
		"played_at": 0,
		# since version 9: the Santuário opens by stages (HubGate): the stations whose opening was shown
		"hub": hub_defaults(),
		# since version 12: A Videira's improvements (Vine; version 10 and 11 held the old "O Preparo" under "account")
		"vine": Vine.defaults(),
	}


static func hub_defaults() -> Dictionary:
	return {"presented": [], "guided": [], "tips": []}


## The Juramentos block (E6): the ranks chosen for the next descent (id: rank; read through Juramentos.set_all) and the
## highest Peso a victory was won with.
static func juramentos_defaults() -> Dictionary:
	return {"ranks": {}, "best": 0}


## One hero's block: the Mastery XP (the level comes out of it), the Gifts unlocked (ids, what the screens have shown),
## the Gifts equipped for the next descent (ids), the ultimate chosen (id or "") and first times (guardian, victory:
## counts) for the Mastery's first-time XP.
## Since version 6: opened (the Gifts opened with Memória, ids), forge (forge_defaults) and tools (ids, Fatia 2);
## discern (the Discernimento bought in the Book, 0 to Discern.COSTS.size(), Fatia 3).
static func hero_defaults() -> Dictionary:
	return {"mastery_xp": 0, "unlocked": [], "equipped": [], "ultimate": "", "firsts": {}, "opened": [],
		"forge": forge_defaults(), "tools": [], "discern": 0}


## The Forja's block of a hero (Forge): the highest Temperar bought (0: none); refine (action: the Refinar on it, Fatia
## 2) and refined (the Refinar bought, ids); awaken (the one awakened) and inscribed (Encantos learned) wait for the
## Fatia 3.
static func forge_defaults() -> Dictionary:
	return {"temper": 0, "refine": {}, "refined": [], "awaken": "", "awakened": [], "inscribed": []}


## Fills anything missing from an older or damaged file, never dropping what is valid. Dictionaries with free keys
## (the heroes, the Codex sections, bindings, firsts) keep every entry whose value has the right type (DT-012: before
## version 3 only the keys of defaults() survived, so a Mastery or a Codex would have been wiped at every read).
static func merged(loaded: Variant) -> Dictionary:
	var out := defaults()
	if not loaded is Dictionary:
		return out
	for key: String in out:
		if not loaded.has(key):
			continue
		match key:
			"heroes":
				if loaded.heroes is Dictionary:
					for id: Variant in loaded.heroes:
						if id is String and loaded.heroes[id] is Dictionary:
							out.heroes[id] = _fixed_keys(loaded.heroes[id], hero_defaults())
			"codex":
				if loaded.codex is Dictionary:
					for section in CODEX:
						if loaded.codex.get(section) is Dictionary:
							out.codex[section] = _entries(loaded.codex[section])
			_:
				if out[key] is Dictionary and loaded[key] is Dictionary:
					out[key] = _fixed_keys(loaded[key], out[key])
				else:
					out[key] = _coerced(loaded[key], out[key])
	if not HEROES.has(String(out.hero)):
		out.hero = FIRST_HERO
	var version := int(_coerced(loaded.get("version", 1), 1))
	# files before version 2 kept the old windowed default: they open in full screen once, then the choice is theirs
	if version < 2:
		out.options.fullscreen = true
	# files before version 3 had no Mastery: what was played counts once (40 a run, 60 a win, up to level 5, D-57)
	if version < 3:
		var hero_block: Dictionary = out.heroes[FIRST_HERO]
		hero_block.mastery_xp = maxi(int(hero_block.mastery_xp), HeroDef.warrior().mastery.retro_xp(int(out.runs), int(out.wins)))
		if int(out.wins) > 0:
			# a player who already won has met the guardian and the sealing: no first-time XP for them again
			hero_block.firsts = {"guardian": int(out.wins), "victory": int(out.wins)}
	# files before version 5 hold the music defaults of the T5 (MUS-1 made new defaults): a place still on its old
	# default moves to the new one once; a piece the player picked stays
	if version < 5:
		var old_defaults := {"music_title": "classic_catacombs", "music_dungeon": "classic_catacombs",
				"music_morvath": "classic_morvath"}
		var places := {"music_title": MusicCatalog.TITLE, "music_dungeon": MusicCatalog.DUNGEON,
				"music_morvath": MusicCatalog.MORVATH}
		for key: String in old_defaults:
			if String(out.options.get(key, "")) == old_defaults[key]:
				out.options[key] = String(MusicCatalog.DEFAULT[places[key]])
	# files before version 6 (Rejogabilidade, Fatia 1): every Gift the Mastery had unlocked is opened for free and the
	# descents already played give their silver once
	if version < 6:
		open_revealed(out.heroes[FIRST_HERO])
		var retro := MaterialPurse.retro_silver(int(out.runs))
		MaterialPurse.give(out, MaterialPurse.SILVER, maxi(0, retro - MaterialPurse.amount(out, MaterialPurse.SILVER)))
	# files before version 7 (LR-01): the near camera is the default now; a save still on the old default ("far") moves
	# to it once, unless the player chose the camera by hand (camera_chosen, set by Save.set_option)
	if version < 7 and String(out.options.camera) == "far" and not bool(out.options.camera_chosen):
		out.options.camera = "near"
	# files before version 9 (the Santuário opens by stages): what is open already counts as shown (no announcement)
	if version < 9:
		HubGate.mark_presented(out, HubGate.open_ids(out).filter(func(id: StringName) -> bool: return HubGate.GATED.has(id)))
	# files before version 11 (PT-5, the Santuário's guides): what is due already counts as shown (no guide for what he knows)
	if version < 11:
		HubGuide.mark_shown(out, HubGuide.pending(out).map(func(d: HubGuideDef) -> StringName: return d.id))
	# files before version 12 (A Videira): the old tree "O Preparo" is gone; what he bought comes back as what he paid
	if version < 12:
		refund_preparo(out, loaded.get("account"))
	# version 8 (Ofícios): nothing to move, an older file opens with the empty block (defaults)
	out.version = VERSION
	return out


## The old "O Preparo" (versions 10 and 11), node id: [material, cost], kept only to give back what was paid.
const LEGACY_PREPARO := {"vida_1": ["silver", 12], "cura_1": ["silver", 15], "vida_2": ["silver", 25], "forca_1": ["silver", 30],
	"bencao_1": ["memory", 6], "ouro_1": ["silver", 12], "renascer": ["memory", 20], "cura_2": ["silver", 30],
	"vida_3": ["silver", 45], "ouro_2": ["silver", 30], "bencao_2": ["memory", 12], "forca_2": ["silver", 60]}


## Gives back, in the material it was paid with, each node of the old tree the file had bought (once per id; no cap, not
## counted as brought home). Returns what was given back, {material: amount}.
static func refund_preparo(out: Dictionary, old: Variant) -> Dictionary:
	var given := {}
	if not (old is Dictionary and (old as Dictionary).get("bought") is Array):
		return given
	var seen := []
	for id: Variant in (old as Dictionary).bought:
		if not (id is String and LEGACY_PREPARO.has(id)) or seen.has(id):
			continue
		seen.append(id)
		var row: Array = LEGACY_PREPARO[id]
		MaterialPurse.refund(out, StringName(row[0]), int(row[1]))
		given[row[0]] = int(given.get(row[0], 0)) + int(row[1])
	return given


## Opens for free every Gift the Warrior's block has revealed by its Mastery (the version 6 migration; a test or a
## capture that sets the Mastery and wants the save of a player who got there before the Memória).
static func open_revealed(block: Dictionary, hero: HeroDef = null) -> void:
	var warrior := hero if hero != null else HeroDef.warrior()
	var opened: Array = block.opened
	for t in warrior.talents().unlocked(warrior.mastery.level_of(int(block.mastery_xp))):
		if not opened.has(String(t.id)):
			opened.append(String(t.id))


## A dictionary with known keys: each known key read in its default's type (an empty default dictionary, as bindings
## and firsts, keeps the loaded one whole; the lists of ids keep their strings); unknown keys are dropped.
static func _fixed_keys(loaded: Dictionary, model: Dictionary) -> Dictionary:
	var out := model.duplicate(true)
	for sub: String in model:
		if not loaded.has(sub):
			continue
		if sub in HERO_LISTS and loaded[sub] is Array:
			out[sub] = (loaded[sub] as Array).filter(func(v: Variant) -> bool: return v is String)
		elif model[sub] is Dictionary and not (model[sub] as Dictionary).is_empty() and loaded[sub] is Dictionary:
			out[sub] = _fixed_keys(loaded[sub], model[sub])  # a block with known keys inside (forge)
		else:
			out[sub] = _coerced(loaded[sub], model[sub])
	return out


## A Codex section: every id whose value is a dictionary of numbers, flags or words; whole numbers back to ints (JSON
## reads every number as a float).
static func _entries(loaded: Dictionary) -> Dictionary:
	var out := {}
	for id: Variant in loaded:
		if not (id is String and loaded[id] is Dictionary):
			continue
		var entry := {}
		for k: Variant in loaded[id]:
			var v: Variant = loaded[id][k]
			if v is float and is_equal_approx(v, roundf(v)):
				v = int(v)
			if k is String and (v is int or v is float or v is bool or v is String):
				entry[k] = v
		out[id] = entry
	return out


## PT-9: whether a hero may be picked in this save: the Warrior always, the Maga after the first Morvath sealed (wins).
static func hero_open(data: Dictionary, id: String) -> bool:
	return id != "maga" or int(data.get("wins", 0)) > 0


## The heroes of HEROES that may be picked now, in order.
static func open_heroes(data: Dictionary) -> Array[String]:
	var out: Array[String] = []
	for id in HEROES:
		if hero_open(data, id):
			out.append(id)
	return out


## The hero picked in this save (always one of HEROES, and open: a Maga picked before PT-9 reads as the Warrior).
static func picked_hero(data: Dictionary) -> String:
	var id := String(data.get("hero", FIRST_HERO))
	return id if HEROES.has(id) and hero_open(data, id) else FIRST_HERO


## The other open hero of HEROES after the picked one (walks the list; the Warrior again while the Maga is locked).
static func next_hero(data: Dictionary) -> String:
	var open := open_heroes(data)
	return open[(open.find(picked_hero(data)) + 1) % open.size()]


## A hero's block (made when missing).
static func hero(data: Dictionary, id: String) -> Dictionary:
	if not data.get("heroes") is Dictionary:
		data["heroes"] = {}
	if not data.heroes.has(id):
		data.heroes[id] = hero_defaults()
	return data.heroes[id]


## Counts one more of what (seen, formed, defeated...) for an id in a Codex section. Returns true the first time.
static func codex_add(data: Dictionary, section: String, id: String, what: String, amount: int = 1) -> bool:
	var entries: Dictionary = _section(data, section)
	var first := not entries.has(id)
	var entry: Dictionary = entries.get(id, {})
	entry[what] = int(entry.get(what, 0)) + amount
	entries[id] = entry
	return first


## Keeps the highest value of what for an id in a Codex section (Morvath's phase reached). Returns true the first time.
static func codex_max(data: Dictionary, section: String, id: String, what: String, value: int) -> bool:
	var entries: Dictionary = _section(data, section)
	var first := not entries.has(id)
	var entry: Dictionary = entries.get(id, {})
	entry[what] = maxi(int(entry.get(what, 0)), value)
	entries[id] = entry
	return first


static func _section(data: Dictionary, section: String) -> Dictionary:
	if not data.get("codex") is Dictionary:
		data["codex"] = {}
	if not data.codex.get(section) is Dictionary:
		data.codex[section] = {}
	return data.codex[section]


## The loaded value in the type of the default (JSON turns every number into a float), or the default itself.
static func _coerced(value: Variant, fallback: Variant) -> Variant:
	if fallback is int and (value is float or value is int):
		return int(value)
	if fallback is float and (value is float or value is int):
		return float(value)
	return value if typeof(value) == typeof(fallback) else fallback


## Adds a winning time (seconds), keeping the fastest few. Returns true when it is the new best.
static func add_best_time(data: Dictionary, seconds: float) -> bool:
	var times: Array = data.best_times
	var best: bool = times.is_empty() or seconds < float(times[0])
	times.append(seconds)
	times.sort()
	if times.size() > MAX_BEST_TIMES:
		times.resize(MAX_BEST_TIMES)
	return best


## A won run's time, kept only when the run has a save (saving false, as with --nosave: no record, never a new best,
## BUG-008). Returns true when it is the new best.
static func record_win_time(data: Dictionary, seconds: float, saving: bool) -> bool:
	return saving and add_best_time(data, seconds)


static func discover_move(data: Dictionary, id: String) -> bool:
	if (data.moves as Array).has(id):
		return false
	data.moves.append(id)
	return true


static func format_time(seconds: float) -> String:
	var s := int(seconds)
	return "%d:%02d" % [s / 60, s % 60]
