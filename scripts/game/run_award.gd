class_name RunAward
extends RefCounted
## What a run leaves in the save when it ends (DT-106, out of game.gd): the Mastery XP and the Gifts its level
## reveals, the first times, the Codex, and the materials and tools banked. Game.log_run calls keep once; Game keeps
## one-line delegates (mastery_gain, award_mastery, codex_run, banks_materials) so callers did not change.


## Whether a run's materials go into the save (Rejogabilidade, Fatia 1, A2): only with a save, never the robot's
## (keep: --materials-keep, for measures).
static func banks_materials(save_enabled: bool, robot: bool, keep: bool) -> bool:
	return save_enabled and (not robot or keep)


## Keeps what the run gave (gain: from gain()): the Mastery when there is a save and a person plays (or --mastery),
## the slot's "Última partida", the materials and tools; writes the save when anything went in. Sets the game's
## mastery_report, materials_banked and tools_banked for the end screen.
static func keep(g: Game, outcome: String, gain: Dictionary) -> void:
	# the Mastery is kept by a death too (D-57); never for the test robot (unless --mastery) nor without a save,
	# and the end screen only shows XP that is really kept (QA T5, Q-T5-2)
	var kept := Save.enabled and (g.bot == null or Dev.has("mastery"))
	g.mastery_report = {"gain": gain, "xp_before": int(SaveData.hero(Save.data, String(g.hero.id)).mastery_xp)} if kept else {}
	if kept:
		award(g, gain, outcome, Save.data)
		# the slot screen's "Última partida" (save slots, 2026-11-19)
		Save.data["played_at"] = int(Time.get_unix_time_from_system())
	# the materials go home once, whatever the outcome (dying keeps them all); never the robot's (unless
	# --materials-keep, for measures) nor without a save (Rejogabilidade, Fatia 1, A2)
	if banks_materials(Save.enabled, g.bot != null, Dev.has("materials-keep")):
		g.materials_banked = MaterialPurse.bank(Save.data, g.materials)
		for t in g.tools_found:
			if Forge.add_tool(Save.data, t, String(g.hero.id)):
				g.tools_banked.append(t)
	if kept or not g.materials_banked.is_empty() or not g.tools_banked.is_empty():
		Save.write()


## The Mastery XP this run gives (MasteryCurve.run_xp), by source and in total: fight rooms and guardians won,
## Morvath's highest phase reached, the sealing, and the first times against what the save data has seen (Blessings
## offered, Elos formed, the first guardian, the first victory).
static func gain(g: Game, outcome: String, data: Dictionary) -> Dictionary:
	var block := SaveData.hero(data, String(g.hero.id))
	var firsts: Dictionary = block.firsts
	var codex: Dictionary = data.get("codex", {})
	var won: Array[RunMap.Kind] = g.rooms.won if g.rooms else ([] as Array[RunMap.Kind])
	var guardians := won.count(RunMap.Kind.MINIBOSS)
	var victory := outcome == "victory"
	var seen: Dictionary = codex.get("boons", {})
	var formed: Dictionary = codex.get("elos", {})
	var known: Dictionary = codex.get("psalms", {})
	return g.hero.mastery.run_xp({
		"rooms": won.count(RunMap.Kind.COMBAT), "guardians": guardians, "phase": int(g.boss_stats.get("max_phase", 0)),
		"victory": victory,
		"new_boons": g.seen_boons.keys().filter(func(id: StringName) -> bool: return not seen.has(String(id))).size(),
		"new_elos": g.elos_formed.keys().filter(func(id: StringName) -> bool: return not formed.has(String(id))).size(),
		"new_psalms": g.psalms.seen.keys().filter(func(id: StringName) -> bool: return not known.has(String(id))).size(),
		"first_guardian": guardians > 0 and int(firsts.get("guardian", 0)) == 0,
		"first_victory": victory and int(firsts.get("victory", 0)) == 0,
		"weight": g.juramentos.weight() if g.juramentos else 0,
	})


## Adds a run's Mastery to save data: the hero's XP (kept on a death too), the Gifts its level unlocks, the first
## times and the Codex (Blessings seen, Elos formed).
static func award(g: Game, gained: Dictionary, outcome: String, data: Dictionary) -> void:
	var block := SaveData.hero(data, String(g.hero.id))
	block.mastery_xp = int(block.mastery_xp) + int(gained.get("total", 0))
	var level := g.hero.mastery.level_of(block.mastery_xp)
	block.unlocked = g.hero.talents().unlocked(level).map(func(t: TalentDef) -> String: return String(t.id))
	for id: StringName in g.seen_boons:
		SaveData.codex_add(data, "boons", String(id), "seen")
	for id: StringName in g.elos_formed:
		SaveData.codex_add(data, "elos", String(id), "formed")
	# the Psalms (E4): seen on a card (found: the Codex shows them from then on) and taken
	for id: StringName in g.psalms.seen:
		SaveData.codex_add(data, "psalms", String(id), "seen")
	for p in g.psalms.taken:
		SaveData.codex_add(data, "psalms", String(p.id), "taken")
	codex(g, outcome, data)
	var guardians := g.rooms.won.count(RunMap.Kind.MINIBOSS) if g.rooms else 0
	if guardians > 0:
		block.firsts["guardian"] = int(block.firsts.get("guardian", 0)) + guardians
	if outcome == "victory":
		block.firsts["victory"] = int(block.firsts.get("victory", 0)) + 1
		if g.juramentos:
			Juramentos.record_win(data, g.juramentos.weight())


## E4-05: the enemies defeated (an elite counts for its common kind, and as an elite), Morvath met (the highest phase
## reached, defeated on a victory) and the arenas entered, into save data's Codex.
static func codex(g: Game, outcome: String, data: Dictionary) -> void:
	for id: StringName in g.defeated:
		var kind := String(id).trim_suffix("_elite")
		SaveData.codex_add(data, "enemies", kind, "defeated", int(g.defeated[id]))
		if kind != String(id):
			SaveData.codex_add(data, "enemies", kind, "elite", int(g.defeated[id]))
	if not g.boss_stats.is_empty():
		var chief := String(g.rooms.stage.boss) if g.rooms else "morvath"
		SaveData.codex_add(data, "enemies", chief, "met")
		SaveData.codex_max(data, "enemies", chief, "phase", int(g.boss_stats.get("max_phase", 1)))
		if outcome == "victory":
			SaveData.codex_add(data, "enemies", chief, "defeated")
	for id: StringName in g.arenas_seen:
		SaveData.codex_add(data, "arenas", String(id), "entered", int(g.arenas_seen[id]))
