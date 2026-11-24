class_name RunReport
extends RefCounted
## The run in numbers, read from a Game (DT-106, out of game.gd): the RESULT dictionary the smoke runs, captures and
## tools print, its JSON line, and the run's entry for the log (RunLog). Only reads; Game keeps one-line delegates
## (result, result_line, run_entry) so callers did not change.


## A line of numbers about the run, for smoke tests and tuning.
static func result(g: Game) -> Dictionary:
	var rooms := g.rooms
	var boss := g.boss
	var out := {"time": snappedf(g.time, 0.1), "hp": int(g.player.hp), "level": g.level, "room": rooms.depth() if rooms else 0, "gold": rooms.gold if rooms else 0, "kills": g.kills, "spawned": g.director.spawned, "best_combo": g.combat.best_combo,
		"enemies": g.horde.count(), "max_alive": g.max_alive, "boss_at": snappedf(g.boss_at, 0.1), "mode": Game.Mode.keys()[g.mode], "boss_hp": int(boss.e.hp) if boss and boss.e else -1, "phase": boss.phase if boss else 0,
		"boons": g.boons.owned().size(), "damage": int(g.combat.damage_dealt), "step_ms": snappedf(g.step_ms, 0.01),
		"step_ms_avg": snappedf(g.step_timer.average(), 0.01), "step_ms_peak": snappedf(g.step_timer.peak, 0.01), "fps": Engine.get_frames_per_second(),
		"boss": g.boss_stats, "bot": g.bot.stats() if g.bot else {}, "rooms": g.room_tally.rooms(g.time), "hp_at_boss": g.room_tally.hp_at_boss,
		"arena": String(g.arena.id) if g.arena else "", "stuck": g.horde.stuck_count(), "stuck_by": g.horde.stuck_by,
		"shots_blocked": g.projectiles.blocked, "flinches": g.horde.flinches, "interrupts": g.horde.interrupts, "breaks": g.horde.breaks, "kit": g.hero_gifts.feed.tally,
		"windups": g.horde.windup_report(), "idle": g.horde.idle_report(), "shot_flight": g.projectiles.flight_report(), "hurt_by": g.hurt_by.keys().reduce(func(a: Dictionary, k: Variant) -> Dictionary: a[k] = int(g.hurt_by[k]); return a, {}),
		"omega_charges_started": g.player.charges_started, "omega_charges_cancelled": g.player.charges_cancelled(), "boons_at_boss": g.room_tally.boons_at_boss, "shop": g.room_tally.shop, "route_shop": g.room_tally.route_shop,
		"fountain_used": g.room_tally.fountain_used, "ult": g.ults.stats(), "dealt_by": g.horde.dealt.report(), "elos": g.elos_formed.size(),
		"psalms": g.psalms.ids(), "events": g.room_tally.events.duplicate(true), "map": rooms.map.summary() if rooms else {},
		"trial": {"active": String(rooms.trials.active.curse.id) if rooms and rooms.trials.active else "",
			"left": rooms.trials.left if rooms else 0, "won": rooms.trials.won.size() if rooms else 0},
		"juramentos": g.juramentos.to_dict() if g.juramentos else {}, "weight": g.juramentos.weight() if g.juramentos else 0,
		"materials": g.materials.report(), "vine": g.vine_nodes, "forge": {"temper": g.forge_temper, "refine": g.forge_refine.duplicate(), "awaken": g.forge_awaken,
			"discern": g.discern, "rerolls_used": Discern.rerolls(g.discern) - g.rerolls_left},
		"talents_opened": g.talents_opened, "enchants": g.boons.enchants.map(func(e: EnchantDef) -> String: return String(e.id)),
		"tools": g.tools_found.map(func(t: StringName) -> String: return String(t)),
		"oficios": g.oficios.report() if g.oficios != null else {},
		"angels": g.encounters.meetings.duplicate(true) if g.encounters else []}
	if g.arcane != null:
		# the Maga only: the Warrior's RESULT stays as it was
		out["hero"] = String(g.hero.id)
		out["arcane"] = g.arcane.stats().merged({"dodges": g.dodges})
	return out


## The RESULT line the smoke runs and captures print: "RESULT " and result() as JSON (E1a-5, B-c: printed as a
## Dictionary its StringName keys came out as &"scythe", and no tool could read the line).
static func line(g: Game) -> String:
	return "RESULT " + JSON.stringify(result(g))


## The run's entry for the log (RunLog): the RESULT line, the gifts taken, the device, Omegas, dodges, what hurt last
## and (version 3) the hero, the Mastery the run gave (gain, from RunAward.gain), the Gifts and the ultimate.
static func entry(g: Game, outcome: String, gain: Dictionary) -> Dictionary:
	var gifts: Array = []
	for id in g.gifts_taken:
		gifts.append({"id": String(id), "level": g.boons.level(id), "rarity": Boon.Rarity.keys()[g.boons.rarity(id)].to_lower()})
	var device := "bot" if g.bot else RunLog.device(Controls.seen_keys, Controls.seen_pad)
	var extra := {"outcome": outcome, "when": Time.get_datetime_string_from_system(), "gifts": gifts,
		"device": device, "omegas": g.omegas, "dodges": g.dodges, "uses": RunLog.uses_of(g.uses),
		"last_hurt": {"attack": String(g.last_hurt.get("attack", &"")), "enemy": String(g.last_hurt.get("enemy", &""))},
		"defeated_by": String(g.defeated_by()) if outcome == "death" else "", "source": RunLog.source(g.bot != null),
		"slot": Save.slot}
	var by := gain.duplicate()
	by.erase("total")
	var xp_now := int(SaveData.hero(Save.data, String(g.hero.id)).mastery_xp)
	extra.merge({"hero": String(g.hero.id), "xp": int(gain.get("total", 0)), "xp_by": by,
		"mastery_level": g.hero.mastery.level_of(xp_now + int(gain.get("total", 0))),
		"talents": g.talents.map(func(id: StringName) -> String: return String(id)), "ultimate": g.ultimate})
	extra.merge(g.room_tally.run_fields())
	if g.watchdog:
		extra["watch"] = g.watchdog.samples
	return RunLog.entry(result(g), extra)
