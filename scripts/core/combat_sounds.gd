class_name CombatSounds
extends RefCounted
## Which sound every event of a fight plays (C15-02, D-12b: synthesis and CC0 only, credits in audio/LICENSES.md). The
## names are Audio's recipes (scripts/audio.gd SOUNDS; a file audio/<name>.ogg or <name>_0.ogg... replaces one).
## Pure: the game asks here, tests/test_combat_sounds.gd checks that every event has a recipe.

## Every event of the fight with a fixed sound. The ones that depend on the enemy (material, wind-up, shot, strike,
## kill) are the functions below; the paladin's moves play ComboNode.sound.
const EVENTS := {
	&"hit": &"hit",
	&"hit_heavy": &"hit_heavy",
	&"dart_hit": &"hit",
	&"ward": &"ward",
	&"interrupt": &"interrupt",
	&"armor_break": &"armor_break",
	&"stagger": &"stagger",
	&"omega_charge": &"charge_up",
	&"omega_ready": &"charged",
	&"circle": &"circle",
	&"circle_omega": &"circle_omega",
	&"circle_burst": &"circle_burst",
	&"dodge": &"dodge",
	&"hurt": &"hurt",
	&"hero_shield": &"shield",
	&"cursed": &"cursed",
	&"summon": &"summon",
	# the ultimate (Ultimates): its gesture, the cleave landing, the Voragem opening and imploding
	&"ult_gesture": &"ult_gesture",
	&"ult_cleave": &"ult_cleave",
	&"ult_vortex": &"vortex",
	&"ult_implode": &"ult_implode",
	# the floor of the Câmara das Runas Instáveis (RuneFloor): one sound per pattern as it arms and one as it strikes,
	# never one per tile; soft, under Morvath's warnings (not in Audio.WARN_CUES: no ducking)
	&"rune_arm": &"rune_arm",
	&"rune_fire": &"rune_crack",
	# the slabs that strike when stepped on (RP-06, PlateFloor): the same stone, one sound per slab as it arms and as
	# it strikes (at most two slabs at once, PlateHazard.MOST_AT_ONCE)
	&"plate_arm": &"rune_arm",
	&"plate_fire": &"rune_crack",
	&"chain_arm": &"rune_arm",
	&"chain_fire": &"rune_crack",
	&"breath_arm": &"rune_arm",
	&"breath_fire": &"dodge",
	&"roots_arm": &"rune_arm",
	&"roots_fire": &"rune_crack",
	&"slit_fire": &"bolt",
	&"trap_arm": &"rune_arm",
	&"trap_fire": &"bolt",
	&"column_crack": &"rune_crack",
	# A1 (rooms_progression.md): RP-14 the crystal (a chime per charge, the runes' stone as it discharges), RP-20 the
	# stones of the vault (a scrape of stone as the dust falls, the fall of a heavy body), RP-12 the oil urn (the fuse's
	# hiss as the ring shows, an explosion; the flame running hisses again)
	&"crystal_charge": &"ward",
	&"crystal_arm": &"rune_arm",
	&"crystal_fire": &"rune_crack",
	&"rocks_arm": &"rune_arm",
	&"rocks_fire": &"boss_down",
	&"urn_arm": &"tell_ember",
	&"urn_fire": &"enemy_burst",
	&"oil_arm": &"rune_arm",
	&"oil_fire": &"rune_crack",
	# AT-H2 the niche's skeleton (stone scraping as the hand comes out, the bone of the grab), AT-H3 the plant (the
	# leaves closing, the lash)
	&"niche_arm": &"rune_arm",
	&"niche_fire": &"bone",
	&"plant_arm": &"rune_arm",
	&"plant_fire": &"enemy_swing",
	&"column_fall": &"boss_down",
	# SR-P2 the slab that gives (stone cracking, the fall), SR-P3 the grate (the stone scrape, the spikes)
	&"sag_arm": &"rune_arm",
	&"sag_fire": &"boss_down",
	&"spikes_arm": &"rune_arm",
	&"spikes_fire": &"bone",
	&"spikeplate_arm": &"rune_arm",
	&"spikeplate_fire": &"bone",
	&"relic_use": &"ward",
}
## What a blow can land on, loudest first (a swing that strikes several plays the first one found here).
const MATERIALS: Array[StringName] = [&"spectral", &"armor", &"shield", &"bone"]
## The layer a blow adds on top of the blade's hit, by material.
const MATERIAL_SOUND := {&"bone": &"mat_bone", &"shield": &"mat_shield", &"armor": &"mat_armor", &"spectral": &"mat_spectral"}
## The fall of an enemy, by material (Morvath's own ending plays over it).
const KILL_SOUND := {&"bone": &"bone", &"shield": &"kill_metal", &"armor": &"kill_metal", &"spectral": &"kill_spectral"}
## A short sound when a wind-up starts, by what the wind-up shows (EnemyDef.Tell): it tells by ear which attack is
## coming, so a dodge can answer one off the screen's centre. NONE: the plain one.
const WINDUP_SOUND := {
	EnemyDef.Tell.NONE: &"tell_blade",
	EnemyDef.Tell.GLINT: &"tell_blade",
	EnemyDef.Tell.TREMBLE: &"tell_ember",
	EnemyDef.Tell.ORB: &"tell_orb",
	EnemyDef.Tell.BOLT: &"tell_bolt",
	EnemyDef.Tell.SHIELD: &"tell_shield",
	EnemyDef.Tell.RITUAL: &"tell_ritual",
}


## The material a blow on e sounds on: armor while its bar took the blow, else its own (EnemyDef.material).
static func material_of(e: Enemy) -> StringName:
	if e.absorbed:
		return &"armor"
	return e.def.material if MATERIAL_SOUND.has(e.def.material) else &"bone"


## The loudest of the materials struck (MATERIALS order); &"" for none.
static func loudest(found: Array[StringName]) -> StringName:
	for m in MATERIALS:
		if found.has(m):
			return m
	return &""


static func material(m: StringName) -> StringName:
	return MATERIAL_SOUND.get(m, &"")


static func windup(d: EnemyDef) -> StringName:
	if d.behavior == EnemyDef.Behavior.BOSS:
		return &""  # Morvath's beats are his own (Boss)
	if d.behavior == EnemyDef.Behavior.SWEEP:
		return &"tell_sweep"  # the pole gathering its turn
	if d.behavior == EnemyDef.Behavior.SUPPORT:
		if d.plate_damage > 0.0:
			return &"tell_trap"  # C1e lote C: the Armadilheiro setting a plate
		return &"tell_dig" if d.role == &"grave" else &"tell_call"  # C1e: the Coveiro digs, the Gritador calls
	if d.behavior == EnemyDef.Behavior.BEAM:
		return &"tell_beam"  # the Canalizador gathering its beam
	if d.behavior == EnemyDef.Behavior.LEAP:
		return &"tell_leap"  # the Saltador crouching
	if d.shot_return:
		return &"tell_throw"  # the Lançador drawing the axe back
	return WINDUP_SOUND.get(d.tell, &"tell_blade")


## The sound of a shot leaving it: a creeping vine, an orb, or a bolt.
static func shot(d: EnemyDef) -> StringName:
	if d.shot_low:
		return &"shot_vine"
	return &"shot_orb" if d.shot_orb else &"bolt"


## The sound of a blow loosed (the swing, the lunge, the charge, the burst); &"" for those that shoot (shot plays).
static func strike(d: EnemyDef) -> StringName:
	match d.behavior:
		EnemyDef.Behavior.CHASE, EnemyDef.Behavior.RUNNER, EnemyDef.Behavior.CONE, EnemyDef.Behavior.SWEEP:
			return &"enemy_swing"
		EnemyDef.Behavior.KNIGHT:
			return &"enemy_charge"
		EnemyDef.Behavior.PULSE, EnemyDef.Behavior.LEAP:
			return &"enemy_burst"
		EnemyDef.Behavior.BEAM:
			return &"shot_orb"
	return &""


static func kill(d: EnemyDef) -> StringName:
	return KILL_SOUND.get(d.material, &"bone")


## Every sound name this table can give (for the test that each has a recipe).
static func all_names() -> Array[StringName]:
	var out: Array[StringName] = []
	for k in EVENTS:
		out.append(EVENTS[k])
	for t: Dictionary in [MATERIAL_SOUND, KILL_SOUND, WINDUP_SOUND]:
		for k in t:
			out.append(t[k])
	out.append_array([&"shot_vine", &"shot_orb", &"bolt", &"enemy_swing", &"enemy_charge", &"enemy_burst"])
	return out
