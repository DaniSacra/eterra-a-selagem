extends SceneTree
## One-off generator of the content files in data/ (combos, enemies, gifts, waves) for the 3D version.
## The .tres files it writes are the source of truth afterwards: tune them in the editor or by hand.
## ~/tools/godot/godot --headless --path . -s tools/make_data.gd -- [combos] [enemies] [boons] [waves] [stage] [bosses] [feel]
##   [talents] [ultimates] [mastery] [hero] [psalms] [trials] [juramentos] [first] [milestones]

## Elites wear a faint old-gold edge (the rim of crowd.gdshader; cycle 5: the gilded halo is gone, the elite reads by
## its gold trims, its armor bar and a thin dark outline, CrowdRenderer.OUTLINE_COLOR).
const ELITE_RIM := Color(0.62, 0.46, 0.22)
const ELITE_RIM_POWER := 0.3
## Elites are the common figure with its steel in old gold (EnemyDef.gild, crowd.gdshader).
const ELITE_GILD := 0.85
## Finishers that swing an arc sweep this wide.
const FINISHER_ARC := 270.0
## The run: 5 plays the 15-minute timeline in 3 (Morvath at 3:00); 1 = the full run. Spawning keeps its rate per
## second of play, so the bot still meets him around level 35 with 18 gifts.
const RUN_PACE := 5.0

const L := ComboNode.In.LIGHT
const H := ComboNode.In.HEAVY
const C := ComboNode.In.CHARGE
const CL := ComboNode.In.CHARGE_LIGHT
const SH := ComboNode.In.SHOUT
const RU := ComboNode.In.RUSH

## Swing peak (seconds into the clip) of the hero's attack clips, measured from the sword hand by tools/bake_hero.gd.
const PEAK := {
	&"Slash_A": 0.23, &"Slash_B": 0.27, &"Slash_C": 0.67, &"Sword_Attack": 0.40, &"Cast": 0.10, &"Throw": 0.40,
}
## The fastest a swing clip of the hero plays in its windup (CF-09, combat_cadence.md 3: at most 1.5x).
const HERO_CLIP_MAX := 1.5
## CF-10 (combat_cadence.md 3): the body under the blade on the frame the blow lands, from sounds that exist (ComboNode
## layers): cut2 the turn of the body (cloth and air), the spin and the lance the planted step (a low thud on stone).
const LAYER_TURN: Array[StringName] = [&"dodge"]
const LAYER_SPIN: Array[StringName] = [&"dash_land", &"dodge"]
const LAYER_STEP: Array[StringName] = [&"dash_land"]
## Which way the blade crosses in each clip (ComboNode.sweep: 1 from the right to the left, 2 the other way).
const SWEEP := {
	&"Slash_A": 1, &"Slash_B": 2, &"Slash_C": 1, &"Sword_Attack": 2,
}
## The clip that brings the blade back to the guard after each swing clip that ends away from it (ComboNode.recover_anim).
const RECOVER := {&"Slash_A": &"Slash_A_Rec", &"Slash_B": &"Slash_B_Rec"}
## Seconds every finisher holds its glint on the blade before it lands (ComboNode.glint; the anticipation beat of the
## Ember & Blade, kept short so the timings of Hades II barely move: backlog BUG-003, 0.06 to 0.1 s).
const FINISHER_GLINT := 0.08
## Seconds the special and its Omega hold the legs after the dart leaves (ComboNode.move_hold; Hades II's
## Special1DisableMoveHold, D-44 (3)); only the dodge cuts it.
const SPECIAL_HOLD := 0.71
## Push of cut1 and cut2 (m/s; Horde.KNOCKBACK_DECAY 7 makes it about a seventh of that in meters). E1c: with no lunge
## to follow the enemy, 8 and 10 threw it 2.6 m back, out of the spin's 3 m. SW-C2 (SWORN: only the third blow pushes): 0.7,
## 0.1 m each, nearly none; the spin (cut3) is the one that throws.
const COMBO_PUSH := [0.7, 0.7]


func _initialize() -> void:
	var only := OS.get_cmdline_user_args()
	# the hero last: it points at the talents, ultimates and Mastery written before it
	for part in ["combos", "enemies", "mods", "boons", "waves", "stage", "bosses", "feel", "talents", "ultimates", "mastery", "hero", "psalms", "trials", "juramentos", "forge", "angels", "enchants", "oficios", "obras", "vine", "hub_guide", "maga", "medallion", "first", "milestones"]:
		if only.is_empty() or only.has(part):
			call("_" + part)
			print("wrote ", part)
	quit()


# ---------- combos ----------

func _move(id: StringName, input: ComboNode.In, anim: StringName, tags: Array[StringName], props: Dictionary, next: Array[ComboNode] = [], title: StringName = &"") -> ComboNode:
	var n := ComboNode.new()
	n.id = id
	n.input = input
	n.anim = anim
	n.tags = tags
	n.title = title
	for k: String in props:
		n.set(k, props[k])
	n.next.assign(next)
	if tags.has(&"finisher"):
		n.glint = FINISHER_GLINT
	# start the clip a little before the swing so the blade lands exactly when the windup ends
	n.sweep = SWEEP.get(anim, 0)
	n.recover_anim = RECOVER.get(anim, &"")
	var peak: float = PEAK.get(anim, 0.3)
	# (a quick move plays the end of the lift into its windup at most HERO_CLIP_MAX times its speed, starting the clip
	# nearer the peak; a slow one plays the clip at its own speed from windup seconds before the peak, so the blade
	# never lands before the blow does. CF-09: the old 0.22 s squeezed into 0.08 played cut1 at 2.75x and the dash cut
	# and the lance at 3.67x)
	n.anim_from = maxf(0.0, peak - minf(maxf(0.22, n.windup), n.windup * HERO_CLIP_MAX))
	n.anim_speed = maxf(1.0, (peak - n.anim_from) / maxf(n.windup, 0.01))
	return n


## C17, QW-103: when the recorded swishes peak after they start (audio/blade_spin_*.ogg 30 to 90 ms, thrust_* 20 to
## 30 ms, measured on their envelope): a delayed sound starts this much before its blade's frame.
const SWISH_PEAK := 0.06
const THRUST_PEAK := 0.025


## Hades II measures distances in its own units: its heroine walks 540 a second and stands 200 tall. 80 of them make
## a meter here (6.75 m/s, a 2.5 m tall paladin), so every distance below is written as Hades units / U.
const U := 80.0
## 2026-11-27 (PT-27b, "heróis dão pouco dano"): the combo, the Corte Circular and the extra blows of Maestria Marcial hit this many times
## harder than the SWORN 20/20/40 (a skeleton of 250 fell to 12 light blows; now 4 to 5). The powers already carried FIXED_X.
const HERO_X := 2.25
## PT-25-4 and PT-25-11 (Daniel: "atacar e andar um pouquinho é sempre melhor"): the short step each blow of the combo
## takes forward the moment it lands (ComboNode.step, meters): cut1, cut2 and the finisher. The finisher's is the longest,
## to reach what the first two pushed away. PT-28-1: +67% (0.3,0.3,0.8 to 0.5,0.5,1.4), the Esmagador 0.7, the Corte Circular 0.5, and Player._step_in
## steers it at the enemy ahead (StepRules.steer). It stops at bodies (BodyBlock) and walls; it replaces the planted blows of E1c.
const STEP := [0.5, 0.5, 1.4]


## The paladin's moves, built on the timings, damage and reach of the first weapon of Hades II (study only:
## our own sword, animations, names and look). Frames are at 60 a second.
func _tree(fifth: bool) -> ComboTree:
	# attack: three swings, the third a turn of the blade all around. E1c (Daniel's E1 test: "tem que atacar parado",
	# "o primeiro ataque é muito rápido", "diferença de tempo entre os 3"; his Hades II video of 2026-11-16): every
	# blow is struck almost standing still (a short step, StepRules, not a lunge), windup (+ the finisher's glint), the frame it lands, then the clip's
	# return (ComboNode.follow_speed). Numbers of Hades II's staff (docs/design/hades2_feel_study.md, "O que aplicar"),
	# seconds after the press / after the blow: windup, attack lock (recovery: the next blow of the combo starts there),
	# legs held (move_hold, only the dodge cuts it): cut1 0.08 / 8 frames / 11 frames (press to walking 0.26 s),
	# cut2 0.13 / 13 / 19 (0.45 s), the spin 0.28 + 0.08 of glint = 0.36 / 18 / 30 (0.86 s).
	var cut3 := _move(&"cut3", L, &"Slash_C", [&"light", &"spin", &"finisher"],
		{"damage": HERO_X * 40.0, "shape": ComboNode.Shape.CIRCLE, "reach": 240.0 / U, "knockback": 16.0, "windup": 0.36 - FINISHER_GLINT,
		"recovery": 18.0 / 60.0, "move_hold": 30.0 / 60.0, "magick_per_hit": 0.5, "step": STEP[2], "chain_window": 0.6, "hit_stop_ms": 100.0, "shake": 2.4, "move_scale": 0.0, "sound": &"blade_spin",
		# QW-103: the spin's swish (its samples peak 30 to 90 ms in) on the blade's frame, 0.36 s after the press; the
		# press only gathers
		"sound_at": 0.36 - SWISH_PEAK, "sound_press": &"spin_gather", "layers": LAYER_SPIN}, [], &"move_spin")
	var after_cut2: Array[ComboNode] = [cut3]
	if fifth:
		after_cut2 = [_extra_blows(cut3)]
	var cut2 := _move(&"cut2", L, &"Slash_B", [&"light"],
		{"damage": HERO_X * 20.0, "reach": 430.0 / U, "width": 150.0, "knockback": COMBO_PUSH[1], "windup": 0.13, "recovery": 13.0 / 60.0,
		"move_hold": 19.0 / 60.0, "magick_per_hit": 0.5, "step": STEP[1],
		"chain_window": 0.4, "hit_stop_ms": 60.0, "shake": 1.1, "move_scale": 0.0, "sound": &"blade_heavy", "layers": LAYER_TURN}, after_cut2)
	var cut1 := _move(&"cut1", L, &"Slash_A", [&"light"],
		{"damage": HERO_X * 20.0, "reach": 430.0 / U, "width": 150.0, "knockback": COMBO_PUSH[0], "windup": 0.08, "recovery": 8.0 / 60.0,
		"move_hold": 11.0 / 60.0, "magick_per_hit": 0.5, "step": STEP[0],
		"chain_window": 0.4, "hit_stop_ms": 35.0, "shake": 0.9, "move_scale": 0.0}, [cut2])
	# GP-1 (docs/design/heroes/warrior_v1_2026-11-26.md 2): the blows on the two buttons. Left: a tap is the combo above, held
	# 0.6 s the Golpe Esmagador (200 since 2026-11-27, was 75; 12 Magia, 2.6 m close, breaks a common's poise at once). Right: a tap is the Corte Circular
	# (40, free since 2026-11-27, 360 degrees, pushes everyone), held 0.8 s the Lança da Emeth. The Magia is spent when the blow lands
	# (Player), never when it is begun.
	# Esmagador (CHARGE_LIGHT): its windup and glint play inside the charge (GF-08), so it lands when the charge fills.
	var smash := _move(&"smash", CL, &"Slash_A", [&"light", &"omega", &"smash"],
		{"magick_cost": 12.0, "charge_time": 0.6, "damage": 200.0, "reach": 2.6, "width": 120.0, "knockback": 12.0, "windup": 0.22,
		"glint": FINISHER_GLINT, "recovery": 0.5, "move_hold": 0.5, "step": 0.7, "chain_window": 0.4, "hit_stop_ms": 90.0, "shake": 1.8,
		"move_scale": 0.0, "sound": &"blade_heavy", "layers": LAYER_TURN}, [], &"move_smash")
	# Corte Circular (HEAVY, a tap): the Poder. Tags shout and cast: the Blessings of the Poder slot count on it, the Quebra reads the
	# `shout` weight. It is no Brado: no buff, no Effect.SHOUT. Legs held 0.35 s after it lands.
	var sweep := _move(&"sweep", H, &"Slash_C", [&"shout", &"cast", &"sweep"],
		{"damage": HERO_X * 40.0, "shape": ComboNode.Shape.CIRCLE, "reach": 3.4, "knockback": 14.0, "windup": 0.18,
		"recovery": 0.30, "move_hold": 0.35, "step": 0.5, "chain_window": 0.4, "hit_stop_ms": 80.0, "shake": 1.6, "move_scale": 0.0,
		"sound": &"blade_spin", "sound_at": 0.18 - SWISH_PEAK, "layers": LAYER_SPIN}, [], &"move_sweep")
	# Lança da Emeth (CHARGE, held 0.8 s, 20 Magia): a long line of light to the front and to the back (the Omega attack of before,
	# kept whole; only its button and its tags changed: the Especial slot, `lance`). Its windup and glint play inside the charge
	# (GF-08, Player._charge_lead). Hades II's Swing5: 0.78 s after it without walking or striking.
	var lance := _move(&"lance", C, &"Sword_Attack", [&"heavy", &"omega", &"thrust", &"lance"],
		{"magick_cost": 20.0, "charge_time": 0.8, "damage": 375.0, "shape": ComboNode.Shape.LINE, "reach": 1080.0 / U, "width": 1.8,
		"both_ways": true, "knockback": 18.0, "windup": 0.06, "recovery": 0.78, "move_hold": 0.78, "chain_window": 0.4, "hit_stop_ms": 50.0, "shake": 2.0,
		"move_scale": 0.0, "sound": &"thrust", "sound_at": 0.06 - THRUST_PEAK, "layers": LAYER_STEP}, [], &"move_lance")
	var tree := ComboTree.new()
	tree.neutral = [cut1, smash, sweep, lance]
	# (no blow out of the dodge since 2026-11-21: the dodge is only a dodge)
	tree.dodge_window = 0.0
	return tree


## The tree Maestria Marcial equips (TalentDef.combos, redesign 2026-11-24): five blows, the spin still the last.
const FIFTH_TREE := "res://data/combos/paladin_fifth.tres"


func _combos() -> void:
	_save(_tree(false), "res://data/combos/paladin.tres")
	_save(_tree(true), FIFTH_TREE)


## Maestria Marcial (01_GUERREIRO): the three blows become five. A thrust (30 ahead, as Quarto Corte's was) and a backhand cut
## sit between cut2 and the spin: the blows 4 and 5 of the sequence are thrust4 and cut4, the spin (5th) is Apogeu's. Their
## tags are the attack's (light), so every Blessing of the attack counts on them.
const EXTRA := {"damage": HERO_X * 20.0, "windup": 0.14, "recovery": 12.0 / 60.0, "move_hold": 18.0 / 60.0}


func _extra_blows(spin: ComboNode) -> ComboNode:
	var back := _move(&"cut4", L, &"Slash_A", [&"light"],
		{"damage": EXTRA.damage, "reach": 430.0 / U, "width": 150.0, "knockback": COMBO_PUSH[0], "windup": 0.12, "recovery": 9.0 / 60.0,
		"move_hold": 12.0 / 60.0, "magick_per_hit": 0.5, "step": STEP[0], "chain_window": 0.4, "hit_stop_ms": 85.0, "shake": 1.8, "move_scale": 0.0}, [spin])
	return _move(&"thrust4", L, &"Sword_Attack", [&"light", &"thrust"],
		{"damage": EXTRA.damage, "shape": ComboNode.Shape.LINE, "reach": 430.0 / U, "width": 1.6, "knockback": COMBO_PUSH[1],
		"windup": EXTRA.windup, "recovery": EXTRA.recovery, "move_hold": EXTRA.move_hold, "magick_per_hit": 0.5, "step": STEP[1], "chain_window": 0.4,
		"hit_stop_ms": 85.0, "shake": 1.8, "move_scale": 0.0, "sound": &"thrust", "sound_at": EXTRA.windup - THRUST_PEAK}, [back])


# ---------- enemies ----------

func _enemy(props: Dictionary) -> void:
	var d := EnemyDef.new()
	var exact: bool = props.get("exact_windup", false)
	for k: String in props:
		if k != "exact_windup" and k != "sw_poise":
			d.set(k, props[k])
	d.hp *= _hp_scale(String(d.id))
	if props.has("sw_poise"):
		d.poise_mult = snappedf(SW_POISE_REF / float(props["sw_poise"]), 0.01)
		if not props.has("poise_stun"):
			d.poise_stun = COMMON_POISE_STUN
	# Daniel 2026-11-21 ("acho eles lentos"): every enemy but the boss walks ENEMY_PACE faster than its Hades II number
	# and waits ENEMY_COOLDOWN of its attack cooldown (lunges, windups and tells untouched: as fair as before)
	if d.behavior != EnemyDef.Behavior.BOSS:
		d.speed *= ENEMY_PACE
		d.attack_cooldown *= ENEMY_COOLDOWN
		if not exact:
			# 2026-11-23 (Daniel: "ataca mais rapido"): one knob for every wind-up of the commons and the elder
			d.attack_windup = _quick(d.attack_windup, d.heavy)
			d.close_windup = _quick(d.close_windup, d.heavy)
			d.recharge_windup = _quick(d.recharge_windup, d.heavy)
			d.guard_up_hit_windup = _quick(d.guard_up_hit_windup, d.heavy)
			d.volley_windup = _quick(d.volley_windup, d.heavy)
	if d.name_key == &"":
		d.name_key = StringName("enemy_" + String(d.id))
	d.cost = int(ENEMY_COST.get(String(d.id), 0))
	_save(d, "res://data/enemies/%s.tres" % d.id)


## 2026-11-27 (PT-27b): the hero hits HERO_X harder, so the tough ones (the commons stay at the SWORN life: a skeleton is 4 to 5 blows)
## are lengthened to keep a fight with them long enough: elites and the Captain, the bigger ones, the guardians, Morvath.
## PT-28-7 (Daniel, room 12: an elite skeleton mage "nao morria", 2340 life against blows of 45): elites back to x1.0 of the SWORN Major
## (a melee elite 1350 to 1500 falls in 13 to 15 s of a decent player's blows, about 105 a second when they land), the ranged ones
## (mage, archer, priest: they kite) x0.7 (910, 875, 910), the Captain x1.2 (1800). Was 1.8 for all (the mage 2340).
const ELITE_HP_X := 1.0
const ELITE_RANGED_HP_X := 0.7
const CAPTAIN_HP_X := 1.2
const BIG_HP_X := 1.5
const GUARDIAN_HP_X := 1.5
const MORVATH_HP_X := 2.4


func _hp_scale(id: String) -> float:
	if id == "morvath":
		return MORVATH_HP_X
	if id == "knight" or id == "priest_elder":
		return GUARDIAN_HP_X
	if id == "capitao":
		return CAPTAIN_HP_X
	if id.ends_with("_elite"):
		return ELITE_RANGED_HP_X if id in ["mage_elite", "archer_elite", "priest_elite"] else ELITE_HP_X
	if id.ends_with("_big"):
		return BIG_HP_X
	return 1.0


## Daniel 2026-11-21: the enemies read slow; every one but the boss a little faster (_enemy).
## Every wind-up of the commons (and of the elder) takes this share of what it was, never under the floor of a light blow or a
## heavy one (the study: the commons' median is 0.67 s, a heavy blow never under 0.4 s; combat_cadence.md section 9).
const ENEMY_WINDUP := 0.8
const WINDUP_FLOOR := 0.5
const WINDUP_FLOOR_HEAVY := 0.6


## A wind-up tightened by ENEMY_WINDUP (never lengthened, never under its floor).
func _quick(seconds: float, heavy: bool) -> float:
	return minf(seconds, maxf(seconds * ENEMY_WINDUP, WINDUP_FLOOR_HEAVY if heavy else WINDUP_FLOOR))


const ENEMY_PACE := 1.15
## The Cavaleiro's phases by share of toughness (SW-REA, the Butcher's 80 / 60 / 40%): guard by time, call, double charge.
## PT-25-5 (Daniel could not break the Cavaleiro's guard: the yellow bar barely moved at 1400 with light blows taking 30%):
## the bot needed about 41 s of focused fighting. Armor 550 and the light blows (cut1, cut2, the thrust) taking half of
## their damage; the strong ones (finisher, wave, dash, Omegas, shout, ultimates) still take it whole.
const KNIGHT_PHASES := [0.8, 0.6, 0.4]
const ENEMY_COOLDOWN := 0.9
## Morvath's walk (a share of Hades II's 600) and his pace between attacks (shares of BossDef.rest per phase and of
## every BossAttack cooldown): 0.5, 1.0 and 1.0 before 2026-11-21.
const BOSS_WALK := 0.7
const BOSS_REST := 0.8
const BOSS_COOLDOWN := 0.85

## Each enemy takes the numbers of the Hades II enemy that plays the same part in its first region (life, speed,
## damage, attack timings, room-generator rating, elite armor), with our own creatures, names and look.
## Look: Daniel's sheet of the first region's enemies (docs/art/enemies_phase1.md): each one its own baked model
## (the painted Meshy figures, tools/bake.gd), sizes from the sheet's scale with the soldier at 1.15, the colour
## of its magic. Radius: what it blocks and where blows reach it; it grows less than the figure (a taller enemy is
## not much wider). Every body is solid as in Hades II (EnemyDef.blocks_body, true by default: the paladin stops at
## it and it at him, only the dash goes through); a kind he walks through takes "blocks_body": false.
## Cycle 7, the part each one plays read at a glance (only drawn, EnemyDef's Look group): `tell` and `tell_at` (the
## light of its wind-up and where it sits on the figure), `sway` and `windup_shake` (the unsteady runner), `vivid`
## (the soldier is the greyest, the base line; the priests and Morvath keep their purple), `tint`, `crest`, `shine`.
## Cycle 8, the part each plays in a fight (`role`, drawn by the pools of _stage): the soldier presses, the runner asks
## for a quick answer, the caster closes space, the crossbowman makes him move sideways, the shield-bearer blocks the
## front, the priest threatens ground. Guardians and Morvath have none (their own rooms).
## GF-12 (D-42): a blow stuns a common enemy as in Hades II, per enemy (Enemies.sjson, EnemyData_*.lua of the first
## region, study of 2026-11-16). Hades plays each one's StunAnimations, whose length lives in the animations; ours is
## the hit pose (Horde.HURT_TIME). A Heavy stun plays the same pose at half speed (GrannyAnimationSpeed 0.5: Guard,
## Mage); the Brawler (our guard) plays its Default at 1.3 and its long one at 0.6; Radiator, Screamer and SiegeVine
## have only the Default. Elites flinch once their armor is broken (Hades: ImmuneToStun only while the HealthBuffer
## holds); guardians and Morvath never (ImmuneToStun).
## E1c (AUDIT.md P5, Game Director: Hades II faithfully): how long the stun lasts is the heroine's blow's, not the
## pose's: OnHitStun 0.5 s on the light blows and OnHitStunHeavy 1.1 s on the strong ones (study 1.1 and 4.1), for
## every common enemy; the hit pose is stretched over it (Horde.render).
const STUN := 0.5
## The magic of the dead (vfx_pass_spec.md 4 and 5.4, V-11, Lote 1): the danger's crimson and magenta over a dark core,
## the opposite of the hero's language; violet is Morvath's alone (the caster's cold violet, Daniel 2026-11-14, went
## to magenta with the spec). Crimson: the crossbow's bolt and the runner's burst (hue 350 to 355 on the screen);
## magenta: the caster's orbs, the priest's vine and the elder's fan (320 to 330).
const DEAD_CRIMSON := Color(1.4, 0.16, 0.3)
## The crossbowman's bolt and light: the orange of the board of 2026-11-14, never the red of a warning (combate_c1_leitura 1).
const CROSSBOW_ORANGE := Color(1.2, 0.5, 0.16)
## (ART_REVIEW P2: the spec's (1.2, 0.18, 0.85), hue 321, showed 313 on the screen; 333 in the material lands in 320 to 330)
## Sweep 2026-11-25: magenta had no owner and fought the danger's red; the casters' orbs, the priest's vine and the elder's fan
## are now the dead's sickly yellow green (hue about 100, away from the Emeth's 133 and Morvath's spectral 157); pink is the curse's only.
const DEAD_MAGENTA := Color(0.5, 1.1, 0.22)
const STUN_HEAVY := 1.1
## E1c (AUDIT.md P2): Hades II's PostAttackDuration of each one's counterpart (study 4.2), the window it stands
## still after its blow (EnemyDef.recover_time): Guard 2.1 (elite 1.5), Radiator 1.35 (elite 0.5), Brawler 1.1 after
## the slam (and after our charge), Screamer 0.6 before it backs off, Mage 0.7 to 0.9. The SiegeVine's 3.25 is its
## attack_cooldown already (it never moves: a recovery would only freeze the end of its cast).
const ENEMY_RECOVER := {"skeleton": [0.75, 0.65], "runner": [0.8, 0.5], "guard": [1.0, 0.9], "archer": [0.6, 0.6], "mage": [0.65, 0.65]}


## C1b (docs/design/combate_c1b.md): the Quebra. A common enemy has POISE; each button's blow takes the share below of it
## (Feel.poise_weights, by DealtBy source; burns, zones, echoes, Blessings that act alone and psalms take none). Attack
## 0.15 (about 7 blows, as many as it takes to kill it), the rest 1 or 2.
const POISE := 100.0
## SW-C5 (docs/design/sworn_rea_kingswood_2026-11-25.md 4): the elites, the guardians, the Capitao and Morvath have a poise bar too. The
## buttons wear it by the same weights times poise_mult (elite 0.5: 13 light blows, 3 specials; guardian 0.3, Capitao 0.4), it breaks
## into a stun (SWORN 2.0 common, 2.5 elite and captain, 3.5 guardian and boss) taking poise_vuln more damage, and each break after the first
## asks 1.25 times more. The commons keep theirs as they were (1.2 s, 0.4, always the same).
const ELITE_POISE_STUN := 2.5
const ELITE_POISE_VULN := 0.25
const GUARDIAN_POISE_STUN := 3.5
## Capitulo 1 = SWORN Kingswood (2026-11-27, docs/design/balance.md): an enemy's "sw_poise" is SWORN's stagger cap (Hammer 125, Axe 75, Boar and
## Mortoad 100, Major 300 to 400, Questing Beast 750, Bane of Crows and Gawain 800); there a light blow of 20 adds 20 to it. Our bar is worn by shares
## of the button (attack 0.15), so poise_mult makes the same number of 20-damage light blows break it: 20 / 0.15 / cap.
## A common stands stunned 2.0 s (SWORN), an elite 2.5, a guardian 3.5.
const SW_POISE_REF := 20.0 / 0.15
const COMMON_POISE_STUN := 2.0
const POISE_GROWTH := 1.25
const POISE_WEIGHTS := {"attack": 0.15, "special": 0.6, "dash": 0.5, "omega_attack": 1.0, "omega_special": 0.7,
	"cast_omega": 0.7, "shout": 0.6, "ultimate": 1.0, "crystal": 0.25}


## SW-R1 (SWORN's Kingswood: Snake 1, Hammer Mob/Axe Thrower/Boar 3, Mortoad 5, Major 10): what a head costs in a room's budget
## (EnemyDef.cost). Small 1, common 3, a shooter 4, heavy 5 (the shield, the priest, the Trinca, the Varredor, the Canalizador), an elite
## twice its kind (6 to 12), a bigger one 8 or 9, the Capitao 12 (SWORN's 10: ours has 5.5 times the life). The guardians and the summoned ones take none (never drawn).
const ENEMY_COST := {"bone_rat": 1, "skeleton": 3, "runner": 3, "saltador": 3, "lancador": 3, "gritador": 3, "coveiro": 3, "armadilheiro": 3,
	"mage": 4, "archer": 4, "guard": 5, "priest": 5, "trinca": 5, "varredor": 5, "canalizador": 5,
	"skeleton_elite": 6, "runner_elite": 7, "mage_elite": 9, "archer_elite": 9, "guard_elite": 11, "priest_elite": 12, "trinca_elite": 10,
	"varredor_elite": 11, "skeleton_big": 8, "runner_big": 9, "capitao": 12}


func _enemies() -> void:
	var B := EnemyDef.Behavior
	var T := EnemyDef.Tell
	# the foot soldier: walks up, raises its blade 0.9 s and lunges (Hades: the common melee shade)
	_pair({"id": &"skeleton", "model": &"skeleton", "behavior": B.RUNNER, "size": 1.15, "hp": 250.0, "speed": 300.0 / U, "damage": 10.0, "radius": 0.5,
		"attack_damage": 10.0, "attack_range": 290.0 / U, "attack_cooldown": 1.4, "attack_windup": 0.75, "lunge_speed": 700.0 / U, "lunge_time": 0.3,
		"rating": 5.0, "role": &"pressure", "big_version": &"skeleton_big", "tell": T.GLINT, "tell_at": Vector3(0.1, 1.9, -1.0), "vivid": -0.1,
		# at most 3 soldiers wind up at once, never two in the same 0.35 s (C1)
		"max_attackers": 3, "recover_time": ENEMY_RECOVER.skeleton[0], "aim_lock": 0.3, "windup_gap": 0.35,
		# T5-02, T5-09: it trembles in the hold of its wind-up; its blade comes down 0.1 s into its pounce, reaching
		# 1.1 m (at its size) past its body in an arc of 120 degrees ahead, as its body lands
		"windup_shake": 0.025, "strike_at": 0.1, "strike_reach": 1.1, "strike_degrees": 120.0,
		"stun_time": STUN, "stun_heavy_time": STUN_HEAVY, "poise": POISE, "sw_poise": 125.0}, {"hp": 1500.0, "attack_damage": 12.0, "damage": 12.0, "attack_windup": 1.1, "sw_poise": 400.0, "poise_stun": ELITE_POISE_STUN, "poise_vuln": ELITE_POISE_VULN, "poise_growth": POISE_GROWTH, "speed": 380.0 / U, "rating": 12.0, "recover_time": ENEMY_RECOVER.skeleton[1],
		# C19-1 (Q-11, Hades' Guard elite): two blades 0.2 s apart, the second where he stood at the end of the wind-up
		"strikes": 2, "strike_gap": 0.2})
	# the fast one that bursts all around itself (sheet: 0.9 of the soldier, stooped, embers in the chest); C17,
	# QW-102: 1.0 s of wind-up, its last 0.3 s held trembling (0.7 was the shortest warning of the game: the PO took 9
	# blows with 0.70 to 0.82 s; Hades' Radiator winds up 1.5 s)
	_pair({"id": &"runner", "ground_warning": true, "model": &"runner", "behavior": B.PULSE, "size": 1.04, "hp": 200.0, "speed": 390.0 / U, "damage": 7.0, "radius": 0.45,
		"attack_damage": 7.0, "attack_range": 1.6, "attack_width": 2.6, "attack_cooldown": 1.4, "attack_windup": 0.85,
		"magic_color": DEAD_CRIMSON, "rating": 7.0, "role": &"react", "big_version": &"runner_big", "tell": T.TREMBLE, "sway": 7.0, "windup_shake": 0.04,
		# T5-04, T5-09: it bursts as its arms open in its spin, 0.1 s into its attack
		"strike_at": 0.1,
		"death_burst": 0.7, "tint": Color(1.0, 0.72, 0.5), "vivid": 0.1, "stun_time": STUN, "stun_heavy_time": STUN_HEAVY, "recover_time": ENEMY_RECOVER.runner[0], "poise": POISE, "sw_poise": 100.0},
		# C19-2 (Q-11): the elite bursts twice in one spin, 0.5 s apart (combat_cadence.md 8.2: a new ring needs that to
		# be read), then Hades' 0.5 s of the Radiator elite
		# (its own bake, runner_elite.res: the same figure with a longer stride for its 7.4 m/s, 199 steps a minute; the
		# common one's would be 259, Lote 2B)
		{"hp": 1350.0, "attack_damage": 9.0, "damage": 9.0, "attack_windup": 1.0, "sw_poise": 300.0, "poise_stun": ELITE_POISE_STUN, "poise_vuln": ELITE_POISE_VULN, "poise_growth": POISE_GROWTH, "speed": 590.0 / U, "rating": 17.0, "recover_time": ENEMY_RECOVER.runner[1], "strikes": 2, "strike_gap": 0.5,
			"model": &"runner_elite"})
	_bigger_ones()
	_pack_and_captain()
	# Ranged enemies with the numbers of Hades II's ranged ones in its first region (study of 2026-11-16) and Daniel's
	# rule of the same day: they stay at their farthest and shoot, never close in (keep_away is ours: Hades' mage hides
	# instead of running). The caster (Hades: the Mage, its life and rating): 3.5 m/s; from up to 13.1 m (elite 16.25),
	# 1 s of aim following the paladin, a burst of 3 orbs 0.17 s apart (elite 7), each pushing it back at 5 m/s; orbs at
	# 7 m/s for 20 m that turn after him (how fast the files do not say: 20 degrees a second is ours, was 40) only in their
	# first 0.8 s, then straight (C17, QW-101: they caught him late in their flight, the PO's most unfair blow; the robot
	# took 46% of its blows in the rooms from them, 35% with both), 4 damage; then
	# 0.7 to 0.9 s and 1.5 to 2.2 s behind a pillar (elite 0.8 to 1.2), 3.1 m past it; at most 3 at once (GP-6, 2026-11-22: 6 before, a third of all the damage he took).
	# Cold violet (Daniel, 2026-11-14) until the VFX pass: magenta, DEAD_MAGENTA.
	_pair({"id": &"mage", "model": &"mage", "behavior": B.ARCHER, "size": 1.27, "hp": 175.0, "speed": 280.0 / U, "damage": 7.0, "radius": 0.5,
		"attack_damage": 7.0, "attack_range": 1050.0 / U, "attack_cooldown": 0.8 + 2.2, "attack_windup": 0.875, "magic_color": DEAD_MAGENTA,
		"shot_orb": true, "shot_speed": 560.0 / U, "shot_range": 1600.0 / U, "shot_turn": 20.0, "shot_homing": 0.8, "shot_ticks": 3, "shot_interval": 0.17,
		"recoil": 400.0 / U, "cover_hug": 250.0 / U, "max_attackers": 3, "keep_away": 0.8,
		"rating": 12.0, "role": &"control", "tell": T.ORB, "tell_at": Vector3(-0.96, 2.0, 0.58), "stun_time": STUN, "stun_heavy_time": STUN_HEAVY,
		"recover_time": ENEMY_RECOVER.mage[0], "poise": POISE, "sw_poise": 100.0},
		{"hp": 1300.0, "attack_damage": 9.0, "damage": 9.0, "attack_windup": 1.0, "sw_poise": 300.0, "poise_stun": ELITE_POISE_STUN, "poise_vuln": ELITE_POISE_VULN, "poise_growth": POISE_GROWTH, "attack_range": 1300.0 / U, "shot_ticks": 3, "attack_cooldown": 0.8 + 1.0, "rating": 24.0})
	# the crossbowman (Hades: the Screamer's life and rating; it has no shot there, a cone held on itself): a fast
	# orange bolt along a line marked on the floor (the aim locks there) from 12 m, Daniel's request of 2026-11-16;
	# from Hades, after each attack it runs 8.75 m from him for 1.5 to 1.75 s, and at most 2 wind up at once; 3.6 m/s
	_pair({"id": &"archer", "model": &"archer", "behavior": B.ARCHER, "size": 1.27, "hp": 150.0, "speed": 290.0 / U, "damage": 5.0, "radius": 0.55,
		"attack_damage": 5.0, "attack_range": 12.0, "attack_cooldown": 2.6, "attack_windup": 0.8, "magic_color": CROSSBOW_ORANGE,
		"shot_speed": 16.0, "shot_line": true, "shot_ticks": 2, "shot_interval": 0.75, "shot_relock": 0.4, "keep_away": 0.65, "retreat_far": 700.0 / U, "retreat_time": Vector2(1.5, 1.75), "max_attackers": 2,
		# T5-05: the crossbow rises to the shoulder over its settle (it rose in 0.1 s)
		"windup_settle": 0.25,
		"rating": 13.0, "role": &"flank", "tell": T.BOLT, "tell_at": Vector3(-0.05, 1.62, 1.42), "stun_time": STUN, "stun_heavy_time": STUN_HEAVY,
		"recover_time": ENEMY_RECOVER.archer[0], "poise": POISE, "sw_poise": 75.0}, {"hp": 1250.0, "attack_damage": 7.0, "damage": 7.0, "attack_windup": 1.0, "sw_poise": 300.0, "poise_stun": ELITE_POISE_STUN, "poise_vuln": ELITE_POISE_VULN, "poise_growth": POISE_GROWTH, "rating": 34.0})
	# the brute: a long charge (1.15 s warning) and a slam on whoever comes close
	_pair({"id": &"guard", "model": &"guard", "behavior": B.KNIGHT, "size": 1.5, "hp": 200.0, "speed": 260.0 / U, "damage": 7.0, "radius": 0.75,
		"heavy": true, "attack_damage": 7.0, "attack_range": 500.0 / U + 3.0, "attack_cooldown": 1.9, "attack_windup": 0.875, "lunge_speed": 15.0,
		"lunge_time": 0.4, "front_block": 0.7, "front_open": 4.0, "close_damage": 7.0, "close_range": 2.6, "close_windup": 0.85,
		# T5-06: braced in three beats, 0.15 s to settle and the last 0.35 s held with a tremble
		"windup_settle": 0.15, "windup_hold": 0.3, "windup_shake": 0.03,
		"rating": 18.0, "role": &"block", "tell": T.SHIELD, "tell_at": Vector3(0.45, 1.1, 0.4), "material": &"shield",
		# its charge in flight is not cut (Hades: the charging Brute, WeaponSetImmuneToStun while it runs)
		"stun_time": STUN, "stun_heavy_time": STUN_HEAVY, "stun_immune_attacking": true, "recover_time": ENEMY_RECOVER.guard[0]}, {"hp": 1350.0, "attack_damage": 9.0, "damage": 9.0, "close_damage": 9.0, "front_block": 0.6, "speed": 340.0 / U, "rating": 39.0, "poise": POISE, "sw_poise": 300.0, "poise_stun": ELITE_POISE_STUN, "poise_vuln": ELITE_POISE_VULN, "poise_growth": POISE_GROWTH})
	# the one rooted in place (Hades: the SiegeVine's life, rating and attack): from up to 22.5 m, 0.8 s of warning,
	# one shadow vine creeping along the floor after the paladin at 1.9 m/s, turning 90 degrees a second at first and
	# 15 less each second, for 12 s, 6 damage; then 3.25 s (elite: 3 vines 0.7 s apart, then 2.25 s). Before
	# 2026-11-16 it dropped circles under him: those are Morvath's alone now.
	_pair({"id": &"priest", "model": &"priest", "behavior": B.ARCHER, "size": 1.3, "hp": 200.0, "speed": 0.0, "damage": 9.0, "radius": 0.7,
		"heavy": true, "attack_damage": 9.0, "attack_range": 1800.0 / U, "attack_cooldown": 3.25, "attack_windup": 0.8, "magic_color": DEAD_MAGENTA,
		"shot_orb": true, "shot_speed": 150.0 / U, "shot_turn": 90.0, "shot_turn_decay": 15.0, "shot_range": 150.0 / U * 12.0, "shot_low": true,
		"rating": 22.0, "role": &"area", "tell": T.RITUAL, "tell_at": Vector3(0.0, 1.3, 0.45), "vivid": 0.25,
		"stun_time": STUN, "stun_heavy_time": STUN_HEAVY},
		{"hp": 1300.0, "shot_ticks": 3, "shot_interval": 0.7, "attack_cooldown": 2.25, "attack_windup": 1.0, "rating": 48.0, "poise": POISE, "sw_poise": 300.0, "poise_stun": ELITE_POISE_STUN, "poise_vuln": ELITE_POISE_VULN, "poise_growth": POISE_GROWTH})
	# C5, CB-7 (Daniel's names, 2026-11-22): the Trinca, three small figures that walk the corners of a triangle round the
	# paladin and pounce one at a time (a short pounce with a thin aim, the soldier's, never two blows at once). A felled
	# figure lies in a mound and rises after 3.5 s if another of them still stands; all three down, it is over. A head of
	# a wave is the three bodies (it counts as 3 of the 20 standing). No weapon, arms hanging, grey bone. The elite is four.
	_pair({"id": &"trinca", "model": &"trio", "behavior": B.RUNNER, "size": 0.85, "hp": 20.0, "speed": 300.0 / U, "damage": 3.0, "radius": 0.42,
		"attack_damage": 3.0, "attack_range": 2.6, "attack_cooldown": 1.5, "attack_windup": 0.85, "lunge_speed": 600.0 / U, "lunge_time": 0.25,
		"rating": 12.0, "role": &"swarm", "group": 3, "rise_time": 3.5, "tint": Color(0.86, 0.87, 0.90), "vivid": -0.2,
		"max_attackers": 1, "recover_time": 0.7, "aim_lock": 0.3, "windup_gap": 0.5, "windup_shake": 0.02,
		"strike_at": 0.1, "strike_reach": 0.9, "strike_degrees": 100.0,
		"stun_time": STUN, "stun_heavy_time": STUN_HEAVY}, {"group": 4, "rating": 28.0, "recover_time": 0.6, "attack_windup": 1.0, "poise": POISE, "sw_poise": 300.0, "poise_stun": ELITE_POISE_STUN, "poise_vuln": ELITE_POISE_VULN, "poise_growth": POISE_GROWTH})
	# C5, CB-7: the Varredor, rooted, 5.5 m of reach: 0.9 s of wind-up that shows where its bar starts and the way it will
	# turn, then the bar (1.1 m across) swings 200 degrees in 1.6 s; within 1.6 m of it nothing hurts; it rests 1.4 s (the
	# window to strike). One a fight (per_room), never in the room with the chain (RP-11: banned role "sweep" there).
	_pair({"id": &"varredor", "ground_warning": true, "model": &"sweeper", "behavior": B.SWEEP, "size": 1.55, "hp": 250.0, "speed": 0.0, "damage": 10.0, "radius": 0.6,
		"heavy": true, "attack_damage": 10.0, "attack_range": 5.5, "attack_width": 1.1, "attack_cooldown": 0.0, "attack_windup": 1.5,
		"sweep_degrees": 200.0, "sweep_time": 1.6, "sweep_clear": 1.6, "aim_lock": 0.3, "recover_time": 1.1, "per_room": 1,
		"rating": 22.0, "role": &"sweep", "tell": T.GLINT, "tell_at": Vector3(0.3, 2.3, 1.3), "tint": Color(0.70, 0.76, 0.82),
		"stun_time": STUN, "stun_heavy_time": STUN_HEAVY}, {"hp": 1500.0, "attack_damage": 12.0, "damage": 12.0, "rating": 44.0, "poise": POISE, "sw_poise": 400.0, "poise_stun": ELITE_POISE_STUN, "poise_vuln": ELITE_POISE_VULN, "poise_growth": POISE_GROWTH})
	_support_ones()
	_leap_and_throw()
	_beam_and_trap()
	# guardians (SWORN Questing Beast and Bane of Crows, 2026-11-27): life only
	# 2026-11-21 night (the guardian a wall for a new hero): it killed a new hero 1 time in 5, the Ancião 3 in 4; charges
	# every 2.4 s (was 3.2) and hits 18 (was 16)
	# 2026-11-23 (Daniel: "ataca mais rapido", the Butcher's run, the shield): a quick, scary Cavaleiro. Charge wind-up 0.6 s
	# (was 1.0), the line follows him until 0.15 s before it leaves, lunge 24 m/s for 0.6 s (14.4 m); the close blow 0.5 s (was
	# 0.8). 2026-11-27: no armor, 3000 life (SWORN Questing Beast). A priority list with a
	# cooldown a move (AttackList): the shield throw from the start, the charges in rows of 1, 2 and 3 as his toughness falls.
	_enemy({"id": &"knight", "model": &"knight", "size": 2.07, "behavior": B.KNIGHT, "hp": 3000.0, "speed": 417.0 / U, "damage": 10.0, "radius": 1.1,
		"heavy": true, "elite": true, "attack_damage": 10.0, "attack_range": 12.0, "attack_cooldown": 1.8,
		"attack_windup": 0.65, "lunge_speed": 24.0, "lunge_time": 0.3, "close_damage": 10.0, "close_range": 3.2, "close_windup": 0.5,
		"exact_windup": true,
		"charges": 1, "recharge_windup": 0.55, "aim_lock": 0.15, "raise_count": 3, "raise_max": 4, "raise_life": KNIGHT_PHASES[1], "raise_cooldown": 30.0, "raise_first": 10.0, "escort": [&"mage", &"mage"] as Array[StringName],
		"poise": POISE, "sw_poise": 750.0, "poise_stun": GUARDIAN_POISE_STUN, "poise_vuln": ELITE_POISE_VULN, "poise_growth": POISE_GROWTH,
		"moves": [
			_kmove(&"throw", {"from_life": 1.0, "cooldown": 10.0, "first": 5.0, "min_dist": 4.0, "max_dist": 0.0}),
			_kmove(&"charge", {"count": 2, "from_life": KNIGHT_PHASES[2], "cooldown": 8.0, "min_dist": 3.2, "max_dist": 12.0}),
			_kmove(&"charge", {"count": 1, "from_life": 1.0, "cooldown": 0.0, "min_dist": 3.2, "max_dist": 12.0}),
		] as Array[KnightMove],
		# the shield throw: 0.5 s of wind-up, a second in the air (the mark follows him until 0.35 s before it lands), 16 where it
		# lands; the wave leaves 0.25 s later at 12 m/s (the hero sprints 11), a band 0.8 m wide, 14 damage; only the dodge crosses it
		"throw_windup": 0.5, "throw_flight": 1.1, "throw_lock": 0.85, "throw_half": 2.4, "throw_damage": 10.0, "throw_open": 1.1,
		"ring_speed": 7.5, "ring_thick": 0.4, "ring_reach": 22.0, "ring_delay": 0.0, "ring_damage": 7.0,
		# T5-07: braced behind its shield in three beats (it stood idle), the last 0.25 s held with a tremble
		"windup_settle": 0.1, "windup_hold": 0.25, "windup_shake": 0.03,
		# it stood stunned 0.8 s after its charge (a stun drawn idle); E1c: the same 0.8 s as its recovery, the end of the blow held
		"recover_time": 0.9, "gap_min": 0.0, "gap_max": 0.15, "gap_min0": 0.0, "gap_max0": 0.05,
		# C1d (docs/design/chefes_c1d.md): K1 a charge into the wall leaves it 1.5 s stunned; K2 the Brado that takes its slam opens
		# it 1.0 s; K3 every 14 s, with the armor over half, the shield up 4 s (70% stopped in front, x1.5 behind), 0.6 s to raise it
		"wall_stun": 1.5, "ward_open": 1.0, "front_block": 0.7, "front_open": 4.0, "guard_up_time": 3.2, "guard_up_every": 10.0,
		"guard_up_windup": 0.85, "guard_up_walk": 0.5, "guard_up_hit_every": 0.53, "guard_up_hit_range": 4.0,
		"guard_up_hit_damage": 7.0, "guard_up_hit_windup": 0.6, "guard_back_mult": 1.5,
		# SW-REA phases (Butcher, docs/design/sworn_rea_butcher_2026-11-25.md): each one adds a move; the guard from 80% only with the
		# paladin within 6 m and a 2 s stand after it (the spin's tail); the call from 60%; the double charge from 40%; a roar at 80% and 40%
		"guard_up_life": KNIGHT_PHASES[0], "guard_up_reach": 6.0, "guard_up_rest": 2.0,
		"roar_marks": PackedFloat32Array([KNIGHT_PHASES[0], KNIGHT_PHASES[2]]), "roar_time": 1.78,
		"rating": 65.0, "rim_color": ELITE_RIM, "rim": ELITE_RIM_POWER, "tell": T.SHIELD, "tell_at": Vector3(0.5, 1.1, 0.35), "material": &"armor"})
	_enemy({"id": &"priest_elder", "name_key": &"enemy_priest_elder", "model": &"priest_elder", "size": 2.19, "behavior": B.PRIEST, "hp": 2500.0, "speed": 2.0,
		"damage": 10.0, "radius": 1.0, "heavy": true, "elite": true, "attack_damage": 5.0, "attack_range": 9.0,
		"attack_cooldown": 3.9, "attack_windup": 1.0, "magic_color": DEAD_MAGENTA, "shot_orb": true, "shot_speed": 6.0,
		"escort": [&"guard"] as Array[StringName],
		# Daniel 2026-11-23: it calls two archers at a time to the floor's edge, away from him (3 standing at most, one call every 10 to 14 s),
		# so he has to go after them; the orbs stay
		"raise_count": 2, "raise_max": 2, "raise_kind": &"archer", "raise_cd_min": 10.0, "raise_cd_max": 14.0, "raise_first": 4.0, "raise_damage": 0.6,
		"shot_count": 5, "shot_spread": 84.0, "rating": 50.0, "rim_color": ELITE_RIM, "rim": ELITE_RIM_POWER,
		# C1d (chefes_c1d.md): A2, after a fan it backs 8 m and looses 3 slow orbs that turn after him (once in 12 s); A3 it armors 3 servants (40)
		"volley_count": 3, "volley_every": 12.0, "volley_back": 8.0, "volley_back_time": 1.5, "volley_windup": 1.0, "volley_speed": 4.0,
		"volley_spread": 50.0, "volley_turn": 60.0, "volley_life": 4.0, "volley_recover": 1.5,
				"tell": T.ORB, "tell_at": Vector3(-1.02, 2.15, 0.6),
		"poise": POISE, "sw_poise": 800.0, "poise_stun": GUARDIAN_POISE_STUN, "poise_vuln": ELITE_POISE_VULN, "poise_growth": POISE_GROWTH})
	# the last of the region: Hades II's first guardian has 6050 life and hits for 4 to 14. His necromancy is the cold
	# spectral green of Daniel's request of 2026-11-15 (SPECTRAL: bluer and paler than Emeth's crystal green); the
	# fight's numbers are data/bosses/morvath.tres (_bosses)
	_enemy({"id": &"morvath", "model": &"morvath", "size": 2.53, "behavior": B.BOSS, "hp": 6000.0, "speed": 600.0 / U * BOSS_WALK, "damage": 13.0, "radius": 1.4,
		"heavy": true, "attack_damage": 16.0, "magic_color": SPECTRAL, "rim_color": Color(0.45, 0.3, 0.6), "rim": 0.3,
		"vivid": 0.9, "tint": Color(0.94, 0.86, 1.14), "crest": 0.5, "shine": 1.5, "material": &"spectral"})


## C1e, lote A (docs/design/inimigos_c1e.md): the Gritador and the Coveiro (SUPPORT: they never strike, they keep away from the
## paladin and call), and the weak dead the Coveiro and the Escoltado raise. Models we already have (the caster's and the priest's,
## no Meshy), told apart by size, colour and the way they stand; no elite version (one a fight, per_room).
const SHOUT_AMBER := Color(1.0, 0.72, 0.2)
const GRAVE_MOSS := Color(0.62, 0.78, 0.4)


func _support_ones() -> void:
	var B := EnemyDef.Behavior
	var T := EnemyDef.Tell
	# the Gritador: 120 life, 3 m/s, keeps 7 m from the paladin and runs from him inside 2 m (4.2 m/s); every 9 s a 0.9 s call (a thin
	# ring closes at its feet) that speeds the others within 8 m by 30% for 8 s and heals them 10% once; one a fight, from room 6
	_enemy({"id": &"gritador", "model": &"herald", "behavior": B.SUPPORT, "size": 1.15, "hp": 150.0, "speed": 3.0, "damage": 4.0, "radius": 0.5,
		"attack_range": 7.0, "attack_cooldown": 9.0, "attack_windup": 0.9, "retreat_far": 2.0, "flee_speed": 4.2,
		"shout_radius": 8.0, "shout_time": 8.0, "shout_pace": 0.3, "shout_heal": 0.1, "magic_color": SHOUT_AMBER,
		"tint": Color(0.52, 0.76, 1.0), "vivid": 0.15, "rating": 14.0, "role": &"rally", "per_room": 1, "tell": T.RITUAL, "tell_at": Vector3(0.0, 1.5, 0.45),
		"stun_time": STUN, "stun_heavy_time": STUN_HEAVY, "poise": POISE, "sw_poise": 75.0})
	# the Coveiro: 90 life, 3.2 m/s and 5.2 m/s running from the paladin inside 7 m; every 7 s a 0.9 s call (an X on the floor at each
	# spot) raises two weak skeletons, at most 4 of its standing; never in a fight with the swarm; one a fight, from room 8
	_enemy({"id": &"coveiro", "model": &"gravedigger", "behavior": B.SUPPORT, "size": 1.0, "hp": 150.0, "speed": 3.2, "damage": 4.0, "radius": 0.45,
		"attack_range": 10.0, "attack_cooldown": 7.0, "attack_windup": 0.9, "retreat_far": 7.0, "flee_speed": 5.2,
		"raise_count": 2, "raise_max": 4, "raise_kind": &"skeleton_raised", "raise_far": 3.0, "magic_color": GRAVE_MOSS,
		"tint": Color(0.86, 0.66, 0.46), "vivid": -0.05, "rating": 12.0, "role": &"grave", "per_room": 1, "never_with": [&"swarm"] as Array[StringName],
		"tell": T.RITUAL, "tell_at": Vector3(0.0, 1.3, 0.45), "stun_time": STUN, "stun_heavy_time": STUN_HEAVY, "poise": POISE, "sw_poise": 75.0})
	# the dead the Coveiro and the Escoltado raise: the soldier with 40 life and a blade of 4 (never drawn into a fight: no role)
	_enemy({"id": &"skeleton_raised", "model": &"skeleton", "behavior": B.RUNNER, "size": 1.0, "hp": 20.0, "speed": 300.0 / U, "damage": 3.0, "radius": 0.45,
		"attack_damage": 3.0, "attack_range": 290.0 / U, "attack_cooldown": 1.4, "attack_windup": 0.75, "lunge_speed": 700.0 / U, "lunge_time": 0.3,
		"rating": 3.0, "tell": T.GLINT, "tell_at": Vector3(0.1, 1.9, -1.0), "vivid": -0.1, "tint": Color(0.82, 0.86, 0.8),
		"max_attackers": 3, "recover_time": ENEMY_RECOVER.skeleton[0], "aim_lock": 0.3, "windup_gap": 0.35,
		"windup_shake": 0.025, "strike_at": 0.1, "strike_reach": 1.1, "strike_degrees": 120.0,
		"stun_time": STUN, "stun_heavy_time": STUN_HEAVY})


## C1e, lote B (docs/design/inimigos_c1e.md): the Saltador and the Lançador, models we already have (the runner's and the soldier's),
## told apart by size and colour; no elite version. Numbers as the doc gives them.
const RUST := Color(1.0, 0.6, 0.4)
const AXE_STEEL := Color(0.7, 1.0, 1.6)


func _leap_and_throw() -> void:
	var B := EnemyDef.Behavior
	var T := EnemyDef.Tell
	# the Saltador: 140 life, 4.2 m/s, keeps 4 to 7 m off; every 3.2 s four corners in L close on where the paladin stands over 0.8 s (the
	# spot follows him and holds the last 0.3 s), it leaps (0.5 s in the air) and lands there hurting 12 in a square of 3 m across; it
	# rests 1.0 s, low. Warning 0.8 s of marks and 0.5 s of flight. From room 3.
	_enemy({"id": &"saltador", "model": &"runner", "behavior": B.LEAP, "size": 1.1, "hp": 175.0, "speed": 4.2, "damage": 9.0, "radius": 0.5,
		"attack_damage": 9.0, "attack_range": 7.0, "attack_cooldown": 3.2, "attack_windup": 0.8, "aim_lock": 0.3, "leap_time": 0.5, "leap_half": 1.8,
		"recover_time": 0.8, "max_attackers": 1, "windup_gap": 0.5, "magic_color": Color(1.0, 0.55, 0.15), "rating": 15.0, "role": &"leap",
		"per_room": 2, "tint": RUST, "vivid": 0.15, "tell": T.TREMBLE, "sway": 5.0, "windup_shake": 0.03, "stun_time": STUN,
		"stun_heavy_time": STUN_HEAVY, "poise": POISE, "sw_poise": 100.0})
	# the Lançador: 150 life, 3.6 m/s, keeps 6 to 8 m off; every 3.4 s a thin dotted line from its hand (0.8 s, locked), then an axe at
	# 9 m/s out 11 m (less where stone is), 9 damage each way, and back along the same line; the line shows again 0.4 s before it turns.
	# After the throw it backs away. From room 4.
	_enemy({"id": &"lancador", "model": &"skeleton", "behavior": B.ARCHER, "size": 1.2, "hp": 150.0, "speed": 3.6, "damage": 7.0, "radius": 0.55,
		"attack_damage": 7.0, "attack_range": 8.0, "attack_cooldown": 3.4, "attack_windup": 0.8, "magic_color": AXE_STEEL, "shot_orb": true,
		"shot_speed": 9.0, "shot_range": 11.0, "shot_line": true, "shot_return": true, "keep_away": 0.75, "retreat_far": 6.0,
		"retreat_time": Vector2(1.0, 1.4), "max_attackers": 1, "windup_gap": 0.5, "rating": 14.0, "role": &"throw", "per_room": 2,
		"tint": Color(0.72, 0.8, 0.95), "vivid": -0.05, "tell": T.GLINT, "tell_at": Vector3(0.1, 1.9, -1.0), "stun_time": STUN,
		"stun_heavy_time": STUN_HEAVY, "recover_time": ENEMY_RECOVER.archer[0], "poise": POISE, "sw_poise": 75.0})


## C1e, lote C (docs/design/inimigos_c1e.md): the Canalizador (BEAM) and the Armadilheiro (SUPPORT laying plates), the first on the sorcerer's baked figure (bigger, rooted, steel-cyan: the baked budget is spent) and the second on a baked figure
## of its own from the crossbowman's body (trapper), no Meshy; no elite version, one a fight.
const BEAM_PALE := Color(0.7, 0.95, 1.0)


func _beam_and_trap() -> void:
	var B := EnemyDef.Behavior
	var T := EnemyDef.Tell
	# the Canalizador: 130 life, planted (speed 0); within 12 m of the paladin a thread on him for 0.9 s (it follows, locked the last 0.3 s), then
	# a beam 0.5 m across held 2.25 s in 5 pulses of 5, turning after him at 40 degrees a second; nothing hurts within 1 m of it; 2.4 s of rest. Room 6.
	_enemy({"id": &"canalizador", "ground_warning": true, "model": &"channeler", "behavior": B.BEAM, "size": 1.3, "hp": 150.0, "speed": 0.0, "damage": 5.0, "radius": 0.55,
		"attack_damage": 5.0, "attack_range": 12.0, "attack_cooldown": 2.4, "attack_windup": 1.5, "aim_lock": 0.3, "shot_ticks": 5, "shot_interval": 0.45,
		"shot_turn": 40.0, "attack_width": 0.5, "sweep_clear": 1.0, "recover_time": 0.4, "magic_color": BEAM_PALE, "tint": Color(0.62, 0.9, 0.95),
		"vivid": 0.1, "rating": 18.0, "role": &"beam", "per_room": 1, "never_with": [&"sweep"] as Array[StringName], "tell": T.ORB,
		"tell_at": Vector3(-0.96, 2.0, 0.58), "stun_time": STUN, "stun_heavy_time": STUN_HEAVY, "poise": POISE, "sw_poise": 75.0})
	# the Armadilheiro: 110 life, 3.8 m/s (4.8 running), keeps 5 to 7 m off; every 2.6 s a 0.5 s stoop and a plate of 1.6 m across where the
	# paladin stands, or where his last dodge ended if under 3 s ago: an X for 1.0 s, then 10 damage to whoever is on it (the dodge's
	# protection passes over it) and the spikes stand 0.5 s more; the plate lies dormant until 6 s after it was laid; at most 4 lie at once. Room 9.
	_enemy({"id": &"armadilheiro", "model": &"trapper", "behavior": B.SUPPORT, "size": 1.2, "hp": 150.0, "speed": 3.8, "damage": 4.0, "radius": 0.5,
		"attack_range": 7.0, "attack_cooldown": 2.6, "attack_windup": 0.5, "retreat_far": 5.0, "flee_speed": 4.8, "plate_damage": 7.0,
		"plate_time": 1.0, "plate_half": 0.8, "plate_max": 4, "plate_window": 3.0, "plate_spikes": 0.5, "plate_life": 6.0, "magic_color": Color(0.96, 0.92, 0.78),
		"tint": Color(0.7, 0.8, 0.5), "vivid": -0.05, "rating": 16.0, "role": &"trap", "per_room": 1, "tell": T.RITUAL,
		"tell_at": Vector3(0.0, 1.0, 0.45), "stun_time": STUN, "stun_heavy_time": STUN_HEAVY, "poise": POISE, "sw_poise": 75.0})


## C1e, lote A: the modifiers of the deep rooms (data/mods; the chance and the room are the stage's: StageDef.mods).
func _mods() -> void:
	DirAccess.make_dir_recursive_absolute("res://data/mods")
	for f in DirAccess.get_files_at("res://data/mods"):
		DirAccess.remove_absolute("res://data/mods/" + f)
	# Furioso (orange ring): its attacks come back 25% faster; its warning is not cut, so it keeps its 0.75 s or more
	_mod_def({"id": &"furioso", "ring": Color(1.0, 0.5, 0.1), "attack_pace": 0.25})
	# Detonante (amber ring): felled, four short lances in a cross, warned 0.7 s, 8 damage
	_mod_def({"id": &"detonante", "ring": Color(1.0, 0.84, 0.3), "burst_arms": 4, "burst_reach": 3.0, "burst_width": 0.7, "burst_damage": 8.0, "burst_time": 0.7})
	# Escoltado (white ring): born with two weak skeletons round it
	_mod_def({"id": &"escoltado", "ring": Color(0.95, 0.97, 1.0), "escort_count": 2, "escort_kind": &"skeleton_raised"})
	# Regenerante (light blue ring, lote C): 12 life back every 3 s without a blow
	_mod_def({"id": &"regenerante", "ring": Color(0.6, 0.85, 1.0), "regen_hp": 12.0, "regen_after": 3.0})
	# Eco (grey ring, lote C): felled, a mound that rises in 3.5 s with 40% of its life, once
	_mod_def({"id": &"eco", "ring": Color(0.66, 0.68, 0.72), "echo_time": 3.5, "echo_share": 0.4})


func _mod_def(props: Dictionary) -> void:
	var m := ModDef.new()
	for k: String in props:
		m.set(k, props[k])
	m.name_key = StringName("mod_" + String(m.id))
	_save(m, "res://data/mods/%s.tres" % m.id)


## C1b (combate_c1b.md, Frente 2): the bigger version of the soldier and of the runner. The same figures, bigger; life about
## 5 times the common one of before C1b (60 and 45: a Frente 1 common is 95 and 70), no armor and not an elite; its own,
## longer warning; one skill more made of what already exists (strikes: the second blow, or the second burst). One at most
## in a fight, from the 4th room (StageDef.big_version/big_chance), always beside another part. Provisional names in the text.
func _bigger_ones() -> void:
	var B := EnemyDef.Behavior
	var T := EnemyDef.Tell
	# the soldier: 1.1 s of warning (the common 0.9 or 0.75), then two blades in a wide arc 0.45 s apart, the second where he stood
	_enemy({"id": &"skeleton_big", "model": &"skeleton", "behavior": B.RUNNER, "size": 1.7, "hp": 500.0, "speed": 250.0 / U, "damage": 12.0, "radius": 0.8,
		"heavy": true, "big": true, "attack_damage": 12.0, "attack_range": 340.0 / U, "attack_cooldown": 1.8, "attack_windup": 0.875, "lunge_speed": 600.0 / U,
		"lunge_time": 0.3, "rating": 20.0, "role": &"pressure", "per_room": 1, "tell": T.GLINT, "tell_at": Vector3(0.1, 1.9, -1.0), "vivid": -0.1,
		"max_attackers": 1, "recover_time": 1.1, "aim_lock": 0.3, "windup_gap": 0.35, "windup_shake": 0.03, "strike_at": 0.1, "strike_reach": 1.7,
		"strike_degrees": 150.0, "strikes": 2, "strike_gap": 0.45, "stun_time": STUN, "stun_heavy_time": STUN_HEAVY})
	# the runner: 1.25 s of warning (the common 1.0 or 0.85), a wider burst, and a second one 0.6 s after the first
	_enemy({"id": &"runner_big", "ground_warning": true, "model": &"runner", "behavior": B.PULSE, "size": 1.6, "hp": 500.0, "speed": 330.0 / U, "damage": 10.0, "radius": 0.7,
		"heavy": true, "big": true, "attack_damage": 10.0, "attack_range": 2.2, "attack_width": 3.4, "attack_cooldown": 1.8, "attack_windup": 1.5,
		"magic_color": DEAD_CRIMSON, "rating": 28.0, "role": &"react", "per_room": 1, "tell": T.TREMBLE, "sway": 5.0, "windup_shake": 0.05, "strike_at": 0.1,
		"strikes": 2, "strike_gap": 0.6, "death_burst": 1.0, "tint": Color(1.0, 0.72, 0.5), "vivid": 0.1, "stun_time": STUN, "stun_heavy_time": STUN_HEAVY,
		"recover_time": 1.0})


## SW-C7 and SW-C8 (docs/design/sworn_rea_kingswood_2026-11-25.md 3.2 and 4: the Snake, 20 life and 3 damage, cost 1; the Major, 5 to 6 times
## a common's life, immune to being pushed, a 1.23 s warning, calls 5, cost 10). Models we already have, no Meshy.
## The Rato de osso: the soldier's figure at 0.6, fast, one blow kills it (10 life; the first blow is 15), 3 damage, in a pack of 4 or more
## (pack_min); solid like every body. The Capitao esqueleto: the shield-bearer's figure bigger and gilded, 520 life
## (5.5 times the soldier's 95), no armor, never pushed, a 1.2 s warning for its charge and its call, which raises 5 soldiers of the weak
## kind (the knight's own call, CV-2: every 2 rows of charges, never more than 5 of its own standing); one a fight, from room 4.
func _pack_and_captain() -> void:
	var B := EnemyDef.Behavior
	var T := EnemyDef.Tell
	_enemy({"id": &"bone_rat", "model": &"skeleton", "behavior": B.RUNNER, "size": 0.6, "hp": 20.0, "speed": 480.0 / U, "damage": 3.0, "radius": 0.3,
		"attack_damage": 3.0, "attack_range": 220.0 / U, "attack_cooldown": 1.2, "attack_windup": 0.6, "lunge_speed": 700.0 / U,
		"lunge_time": 0.2, "rating": 2.0, "role": &"scurry", "pack_min": 4, "pack_max": 6, "tint": Color(0.82, 0.74, 0.6), "vivid": -0.2, "max_attackers": 3,
		"recover_time": 0.6, "aim_lock": 0.2, "windup_gap": 0.25, "windup_shake": 0.02, "strike_at": 0.1, "strike_reach": 0.8, "strike_degrees": 120.0,
		"stun_time": STUN, "stun_heavy_time": STUN_HEAVY})
	_enemy({"id": &"capitao", "model": &"guard", "behavior": B.KNIGHT, "size": 1.95, "hp": 1500.0, "speed": 250.0 / U, "damage": 12.0, "radius": 0.9,
		"heavy": true, "no_push": true, "attack_damage": 12.0, "attack_range": 500.0 / U + 3.0, "attack_cooldown": 2.4, "attack_windup": 1.2, "exact_windup": true,
		"lunge_speed": 15.0, "lunge_time": 0.4, "close_damage": 12.0, "close_range": 2.8, "close_windup": 1.0, "aim_lock": 0.3,
		"raise_count": 5, "raise_max": 5, "raise_every": 2, "raise_kind": &"skeleton_raised", "raise_first": 3.0,
		"windup_settle": 0.15, "windup_hold": 0.3, "windup_shake": 0.03, "recover_time": 1.0, "gap_min": 0.2, "gap_max": 0.8, "gap_min0": 0.1, "gap_max0": 0.4,
		"poise": POISE, "sw_poise": 400.0, "poise_stun": ELITE_POISE_STUN, "poise_vuln": ELITE_POISE_VULN, "poise_growth": POISE_GROWTH,
		"rating": 30.0, "role": &"captain", "per_room": 1, "gild": ELITE_GILD, "rim_color": ELITE_RIM, "rim": ELITE_RIM_POWER, "tint": Color(1.0, 0.8, 0.72),
		"tell": T.SHIELD, "tell_at": Vector3(0.45, 1.1, 0.4), "material": &"shield", "stun_immune_attacking": true,
		"stun_time": STUN, "stun_heavy_time": STUN_HEAVY})


## An enemy and its elite version: the SWORN Major of its role (life only, no armor bar), faster and outlined.
func _pair(base: Dictionary, elite: Dictionary) -> void:
	base["elite_version"] = StringName(String(base.id) + "_elite")
	_enemy(base)
	var e := base.duplicate()
	e.erase("elite_version")
	e.erase("big_version")
	e["id"] = StringName(String(base.id) + "_elite")
	e["name_key"] = StringName("enemy_" + String(base.id))
	e["elite"] = true
	e["rim_color"] = ELITE_RIM
	e["rim"] = ELITE_RIM_POWER
	# the same figure with its steel in old gold (the KayKit figures wore a gilded palette, EnemyDef.palette:
	# assets/models/palettes/<id>_elite.png, tools/make_palettes.gd)
	e["gild"] = ELITE_GILD
	# no armor to keep it standing: an elite is staggered by its poise bar alone (SWORN Major), a blow never flinches it
	e["stun_time"] = 0.0
	e["stun_heavy_time"] = 0.0
	for k: String in elite:
		e[k] = elite[k]
	_enemy(e)


# ---------- gifts ----------

## One number of a Blessing (C13-05, Hades II's curve): base at level 1 (times the rarity), per_level the fixed gain of
## level 2, 3... (the last one again after it; never scaled by rarity). The numbers of before migrated as they were
## at a common card: base the old level 1, the gains the old steps 1 to 2 and 2 to 3.
## CB-1 (Daniel, 2026-11-22: the hero starts weak, 15, 15, 20): the share kept of the damage that is a number of its own
## (the Blessings that act alone, the fire), or they would be worth twice as much beside his blows.
const FLAT := 1.5
## Chapter 1 = SWORN numbers (2026-11-27): enemies have 2.5 to 3 times the life, so every fixed damage of the hero takes this too.
const FIXED_X := 2.5


## Stats that are a damage number of their own (not a share of a blow): they follow the enemies (FIXED_X).
const ABS_MODS: Array[StringName] = [&"dodge_ember_dps", &"detonate_dmg", &"shield_burst", &"dodge_plague_dps", &"cel_burn_dps", &"cel_combust_dmg",
	&"cel_poison_dps", &"cel_sat_dmg", &"cel_shock_zap", &"cel_whirl_dmg", &"cel_discharge"]


func _mod(stat: StringName, base: float, per_level: Array = [], tag: StringName = &"", by_rarity: bool = true) -> BoonMod:
	var m := BoonMod.new()
	m.stat = stat
	m.tag = tag
	if ABS_MODS.has(stat):
		base *= FIXED_X
		per_level = per_level.map(func(v: float) -> float: return v * FIXED_X)
	# CB-1 (2026-11-22): damage that does not grow with his blows falls with them
	m.base = maxf(1.0, roundf(base * FLAT)) if stat == &"burn_dps" else base
	m.per_level = PackedFloat32Array(per_level.map(func(v: float) -> float: return maxf(1.0, roundf(v * FLAT))) if stat == &"burn_dps" else per_level)
	m.by_rarity = by_rarity
	return m


## A number rarity must not change (counts, cooldowns, sizes).
func _fixed(stat: StringName, base: float, per_level: Array = [], tag: StringName = &"") -> BoonMod:
	return _mod(stat, base, per_level, tag, false)


func _skill(kind: SkillDef.Kind, props: Dictionary) -> SkillDef:
	var s := SkillDef.new()
	s.kind = kind
	for k: String in props:
		var v: Variant = props[k]
		if v is Array and (k == "damage" or k == "status_power" and props.get("status", &"") == &"burn"):
			v = v.map(func(x: float) -> float: return maxf(1.0, roundf(x * FLAT)))
		s.set(k, PackedFloat32Array(v) if v is Array else v)
	return s


## BO-2 (C4): the Blessings of Chama and Geada that left the draw when the two angels were cut to six, one a button: kept
## (the file, the Compêndio, an old save) and never offered. They come back one by one, by a button of their own.
## Vigia Firme (stun_pct) joined the reserve: with StunRule.NONE Combat zeroes stun_scale, so it did nothing until C6 redoes Shomael.
const RESERVE: Array[StringName] = [&"brasas", &"lamina_ardente", &"omega_brasa", &"chuva_brasas", &"estilhaco", &"peso_inverno",
	&"geada_final", &"omega_geada", &"vigia_firme"]


## Blessings that only work with a move shape some heroes lack (Boon.needs_tag; the Maga has no finisher nor spin).
const NEEDS_TAG := {&"golpe_geada": &"spin", &"final_radiante": &"finisher", &"final_veu": &"finisher", &"golpe_certeiro": &"finisher"}


func _boon(n: int, id: StringName, family: Boon.Family, icon: int, mods: Array[BoonMod], skill: SkillDef = null, slot: Boon.Slot = Boon.Slot.NONE) -> void:
	if V1_IDS.has(id):
		return  # Blessings V1: this id is defined again below (_v1_boons), in its own file
	var b := Boon.new()
	b.id = id
	b.reserve = true  # Blessings V1 (2026-11-26): the old catalog leaves the draw whole (never deleted: saves and the Compêndio know it)
	b.needs_tag = NEEDS_TAG.get(id, &"")
	b.slot = slot
	b.family = family
	b.icon = icon
	b.mods = mods
	b.skill = skill
	_save(b, "res://data/boons/%02d_%s.tres" % [n, id])


## An Elo (E3-02, Hades II's duo): one gift of each list forms it (the first of each list is the one the card shows
## when none is held); no level beyond 1 and no rarity (BUG-017), its number the old level 1.
func _elo(n: int, id: StringName, icon: int, mods: Array[BoonMod], sets: Array) -> void:
	var b := Boon.new()
	b.id = id
	b.reserve = true  # Blessings V1: no Elo in the draw this version
	b.family = Boon.Family.DUO
	b.icon = icon
	b.mods = mods
	b.max_level = 1
	for list: Array in sets:
		b.requires_sets.append(PackedStringArray(list))
	_save(b, "res://data/boons/%02d_%s.tres" % [n, id])


func _boons() -> void:
	_v1_n = 0
	for f in DirAccess.get_files_at("res://data/boons"):
		DirAccess.remove_absolute("res://data/boons/" + f)
	var F := Boon.Family
	var K := SkillDef.Kind
	var S := Boon.Slot
	var T := SkillDef.Trigger
	_boon(0, &"brasas", F.CHAMA, 0, [], _skill(K.STRIKES, {"damage": [18, 26, 36], "count": [3, 4, 6], "cooldown": [3.5, 3.0, 2.5], "radius": [2.2, 2.4, 2.6], "status": &"burn", "status_power": [5, 7, 9]}))
	# BO-2 (C4): Sarael and Nivael, one Blessing a button; the skills nascem de um botão (SkillDef.trigger), none acts alone. The
	# numbers are in the scale of before and fall by FLAT (the hero's combo is 50: 15, 15, 20).
	_boon(1, &"redemoinho", F.CHAMA, 1, [], _skill(K.ORBIT, {"trigger": T.RUSH, "damage": [10, 14, 19], "count": [2, 3, 4], "cooldown": [0.5],
		"radius": [3.0, 3.3, 3.6], "duration": [4.0], "gap": [5.0], "status": &"burn", "status_power": [4, 6, 8]}), S.RUSH)
	_boon(2, &"lamina_ardente", F.CHAMA, 2, [_mod(&"burn_dps", 6, [3, 3], &"finisher"), _mod(&"damage_pct", 0.2, [0.15, 0.15], &"finisher")])
	_boon(3, &"toque_geada", F.GEADA, 3, [_mod(&"shatter_pct", 0.5, [0.3, 0.2], &"heavy")], null, S.SPECIAL)
	_boon(4, &"estilhaco", F.GEADA, 4, [_mod(&"shatter_pct", 0.5, [0.3, 0.2])], _skill(K.NOVA, {"damage": [20, 30, 42], "cooldown": [6, 5, 4], "radius": [5, 6, 7], "status": &"freeze", "status_power": [1.2, 1.5, 1.8]}))
	_boon(5, &"peso_inverno", F.GEADA, 5, [], _skill(K.METEOR, {"damage": [60, 90, 130], "cooldown": [9, 8, 7], "radius": [4.0, 4.5, 5.0], "status": &"freeze", "status_power": [2.0, 2.2, 2.5]}))
	_boon(6, &"consolo", F.LUZ, 6, [_mod(&"heal_on_kill", 0.4, [0.3, 0.3])])
	_boon(7, &"onda_maior", F.LUZ, 7, [], _skill(K.FAN, {"damage": [16, 22, 30], "count": [5, 8, 11], "cooldown": [5.0, 4.5, 4.0], "radius": [12, 13, 14]}))
	_boon(8, &"flagelo", F.LUZ, 8, [], _skill(K.STRIKES, {"damage": [24, 32, 44], "count": [4, 6, 9], "cooldown": [4.5, 4.0, 3.5], "radius": [1.6, 1.8, 2.0], "status": &"stun", "status_power": [0.4, 0.5, 0.6]}))
	_boon(9, &"escudo", F.VIGILIA, 9, [_fixed(&"shield_cooldown", 12, [-3, -3]), _fixed(&"dome_shield", 1, [0, 0])])  # (dome_shield: the Maga's Suspensao opens with it ready)
	_boon(10, &"passos", F.VIGILIA, 10, [_fixed(&"dodge_charges", 1, [0, 1]), _fixed(&"move_speed_pct", 0.08, [0.06, 0.06])], null, S.DASH)
	_boon(11, &"firmeza", F.VIGILIA, 11, [_mod(&"max_hp", 20, [15, 15])], _skill(K.CONSECRATE, {"damage": [12, 18, 26], "cooldown": [8, 7, 6], "radius": [4, 5, 6], "status": &"slow", "status_power": [4.0, 4.5, 5.0]}))
	_boon(75, &"ultimo_brasa", F.CHAMA, 0, [], _skill(K.STRIKES, {"trigger": T.ULT, "damage": [20, 30, 42], "count": [8, 10, 12], "radius": [2.2],
		"gap": [0.0], "status": &"burn", "status_power": [6, 8, 10]}), S.ULT)
	_boon(76, &"ultimo_geada", F.GEADA, 5, [], _skill(K.METEOR, {"trigger": T.ULT, "damage": [60, 90, 130], "radius": [4.0, 4.5, 5.0],
		"gap": [0.0], "status": &"freeze", "status_power": [2.0, 2.2, 2.5]}), S.ULT)
	# Lote R9 (bencaos_por_botao.md 2.1): the four cells the Warrior's table left empty, only stats and triggers that exist.
	_boon(77, &"ultimo_radiante", F.LUZ, 8, [_mod(&"damage_pct", 0.3, [0.15, 0.15], &"ultimate"), _fixed(&"ult_charge_pct", 0.15, [0.08, 0.08])], null, S.ULT)
	_boon(78, &"passo_claro", F.LUZ, 10, [], _skill(K.NOVA, {"trigger": T.DODGE, "damage": [14, 20, 28], "cooldown": [1.0], "radius": [3.0, 3.4, 3.8]}), S.DASH)
	_boon(79, &"investida_firme", F.VIGILIA, 11, [], _skill(K.CONSECRATE, {"trigger": T.RUSH, "damage": [6, 9, 12], "radius": [2.5, 2.8, 3.1],
		"duration": [3.0], "gap": [3.0], "status": &"slow", "status_power": [3.0]}), S.RUSH)
	_boon(80, &"ultimo_firme", F.VIGILIA, 11, [], _skill(K.CONSECRATE, {"trigger": T.ULT, "damage": [10, 15, 22], "radius": [3.5, 4.0, 4.5],
		"duration": [4.0], "gap": [0.0], "status": &"slow", "status_power": [4.0]}), S.ULT)
	# The Elos (E3-02): one gift of each family's list. Burn and frost come from any gift of the flame or the frost; the
	# light that hits on its own (the fan, the scourge) is what aurora and chama_viva change; bastiao bursts the
	# Vigília's shield; rastro and passo_frio ride the dodge of any Vigília gift.
	var chama := [&"brasas", &"redemoinho", &"lamina_ardente", &"golpe_brasa", &"pesado_brasa", &"circulo_brasa", &"passo_brasa", &"omega_brasa", &"chuva_brasas", &"ultimo_brasa"]
	var geada := [&"toque_geada", &"estilhaco", &"peso_inverno", &"golpe_geada", &"circulo_geada", &"passo_geada", &"geada_final", &"floco_errante", &"omega_geada", &"ultimo_geada"]
	var luz_hits := [&"onda_maior", &"flagelo"]
	var luz := [&"consolo", &"onda_maior", &"flagelo", &"golpe_radiante", &"pesado_radiante", &"circulo_radiante", &"passo_radiante", &"final_radiante", &"onda_clara", &"ultimo_radiante", &"passo_claro"]
	var vigilia := [&"passos", &"escudo", &"firmeza", &"golpe_firme", &"pesado_firme", &"circulo_firme", &"vigia_firme", &"vigilia_longa", &"guarda_atenta", &"investida_firme", &"ultimo_firme"]
	_elo(12, &"vapor", 12, [_mod(&"steam_time", 2)], [chama, geada])
	_elo(13, &"aurora", 13, [_mod(&"freeze_time", 0.8, [], &"luz")], [luz_hits, geada])
	_elo(14, &"chama_viva", 14, [_mod(&"burn_dps", 5, [], &"luz")], [chama, [&"flagelo", &"onda_maior"]])
	_elo(15, &"bastiao", 15, [_mod(&"shield_burst", 40)], [[&"escudo"], luz])
	_elo(16, &"rastro", 16, [_mod(&"dodge_ember_dps", 8)], [vigilia, chama])
	_elo(17, &"passo_frio", 17, [_mod(&"freeze_time", 1.0, [], &"dash")], [vigilia, geada])
	# One gift per action (Boon.Slot): attack = light moves, special = heavy moves, cast = the Brado de Guerra (Q), dash.
	_boon(18, &"golpe_brasa", F.CHAMA, 2, [_mod(&"burn_dps", 4, [2, 2], &"light")], null, S.ATTACK)
	_boon(19, &"golpe_geada", F.GEADA, 3, [_mod(&"freeze_time", 0.8, [0.2, 0.2], &"spin")], null, S.ATTACK)
	_boon(20, &"golpe_radiante", F.LUZ, 8, [_mod(&"damage_pct", 0.25, [0.15, 0.15], &"light")], null, S.ATTACK)
	_boon(21, &"golpe_firme", F.VIGILIA, 11, [_fixed(&"reach_pct", 0.12, [0.06, 0.07], &"light"), _mod(&"damage_pct", 0.1, [0.05, 0.05], &"light")], null, S.ATTACK)
	_boon(22, &"pesado_brasa", F.CHAMA, 0, [], _skill(K.CONSECRATE, {"trigger": T.SPECIAL, "damage": [6, 9, 12], "radius": [2.5],
		"duration": [3.0], "gap": [3.0], "status": &"burn", "status_power": [4, 5, 6]}), S.SPECIAL)
	_boon(23, &"pesado_radiante", F.LUZ, 7, [_mod(&"damage_pct", 0.3, [0.15, 0.15], &"heavy")], null, S.SPECIAL)
	_boon(24, &"pesado_firme", F.VIGILIA, 15, [_fixed(&"wave_size_pct", 0.15, [0.07, 0.08], &"heavy"), _mod(&"damage_pct", 0.1, [0.05, 0.05], &"heavy")], null, S.SPECIAL)  # (the wave's size: the Warrior's wave takes its reach from the blade)
	_boon(25, &"circulo_brasa", F.CHAMA, 1, [_mod(&"detonate_dmg", 14, [6, 6], &"cast")], null, S.CAST)
	_boon(26, &"circulo_geada", F.GEADA, 4, [_mod(&"freeze_time", 1.0, [0.4, 0.4], &"cast"), _fixed(&"reach_pct", 0.2, [0.1, 0.1], &"cast")], null, S.CAST)
	_boon(27, &"circulo_radiante", F.LUZ, 6, [_mod(&"damage_pct", 0.3, [0.15, 0.15], &"cast")], null, S.CAST)
	_boon(28, &"circulo_firme", F.VIGILIA, 9, [_fixed(&"reach_pct", 0.25, [0.15, 0.15], &"cast"), _mod(&"damage_pct", 0.1, [0.05, 0.05], &"cast")], null, S.CAST)  # (the Brado reads reach and damage; cast_size_pct only served the old circle)
	_boon(29, &"passo_brasa", F.CHAMA, 16, [_mod(&"dodge_ember_dps", 6, [3, 3])], null, S.DASH)
	_boon(30, &"passo_geada", F.GEADA, 17, [], _skill(K.FAN, {"trigger": T.RUSH, "damage": [14, 20, 28], "count": [3, 5, 7], "radius": [10],
		"gap": [5.0], "status": &"freeze", "status_power": [0.6, 0.8, 1.0]}), S.RUSH)
	_boon(31, &"passo_radiante", F.LUZ, 10, [_mod(&"damage_pct", 0.4, [0.2, 0.2], &"dash"), _fixed(&"move_speed_pct", 0.05, [0.03, 0.03])], null, S.RUSH)  # (move_speed_pct: the dodge of the Space runs faster)
	# Fatia 2 (sistemas.md 1.6, 3.6): 2 to 3 Blessings more a family, all on their own (no action taken), so an angel
	# meets a hand with three offers more often; Geada and Vigília (six each) first. Only stats the game knows.
	_boon(32, &"geada_final", F.GEADA, 3, [_mod(&"freeze_time", 0.6, [0.3, 0.3], &"finisher")])
	_boon(33, &"floco_errante", F.GEADA, 4, [], _skill(K.ORBIT, {"trigger": T.DODGE, "damage": [8, 11, 15], "count": [2, 3, 4], "cooldown": [0.5],
		"radius": [3.0, 3.3, 3.6], "duration": [3.0], "gap": [4.0], "status": &"slow", "status_power": [1.0, 1.2, 1.4]}), S.DASH)
	_boon(34, &"omega_geada", F.GEADA, 5, [_mod(&"freeze_time", 1.2, [0.4, 0.4], &"omega")])
	_boon(35, &"vigia_firme", F.VIGILIA, 9, [_fixed(&"stun_pct", 0.3, [0.15, 0.15])])
	_boon(36, &"vigilia_longa", F.VIGILIA, 11, [_mod(&"magick_max", 15, [10, 10])])
	_boon(37, &"guarda_atenta", F.VIGILIA, 10, [_fixed(&"move_speed_pct", 0.06, [0.04, 0.04]), _fixed(&"reach_pct", 0.06, [0.03, 0.03], &"light")])
	_boon(38, &"omega_brasa", F.CHAMA, 2, [_mod(&"burn_dps", 8, [4, 4], &"omega")])
	_boon(39, &"chuva_brasas", F.CHAMA, 0, [], _skill(K.METEOR, {"damage": [40, 60, 85], "cooldown": [9, 8, 7], "radius": [3.5, 4.0, 4.5], "status": &"burn", "status_power": [6, 8, 10]}))
	_boon(40, &"final_radiante", F.LUZ, 8, [_mod(&"damage_pct", 0.2, [0.1, 0.1], &"finisher")])
	_boon(41, &"onda_clara", F.LUZ, 7, [_fixed(&"wave_size_pct", 0.2, [0.1, 0.1], &"heavy"), _mod(&"damage_pct", 0.1, [0.05, 0.05], &"heavy")])
	# AN-2 (sistemas.md 4.1): the families of Velael, Galael and Qeshael, nine Blessings each (one a button: attack, special,
	# Brado, Investida; then the passives and two that act on their own), at the strength of the four before (a golpe of
	# 25% more damage is a Mark that lets the next blows hit 25% harder; Fraqueza cuts a quarter of what an enemy deals).
	# Veu (Fraqueza: the enemy deals less, Combat.WEAK_CUT, weak_pct deepens it); the first icons are the seals' glyphs.
	_boon(42, &"golpe_veu", F.VEU, 20, [_mod(&"weak_time", 2.0, [1.0, 1.0], &"light")], null, S.ATTACK)
	_boon(43, &"pesado_veu", F.VEU, 20, [_mod(&"weak_time", 3.0, [1.0, 1.0], &"heavy")], null, S.SPECIAL)
	_boon(44, &"circulo_veu", F.VEU, 20, [_mod(&"weak_time", 4.0, [1.5, 1.5], &"cast")], null, S.CAST)
	_boon(45, &"passo_veu", F.VEU, 20, [_mod(&"weak_time", 3.0, [1.0, 1.0], &"dash")], null, S.RUSH)
	_boon(46, &"omega_veu", F.VEU, 20, [_mod(&"weak_time", 4.0, [1.5, 1.5], &"omega")])
	_boon(47, &"final_veu", F.VEU, 20, [_mod(&"weak_time", 3.0, [1.0, 1.0], &"finisher")])
	_boon(48, &"entardecer", F.VEU, 20, [_fixed(&"weak_pct", 0.1, [0.05, 0.05])])
	_boon(49, &"nevoa", F.VEU, 20, [], _skill(K.NOVA, {"damage": [14, 20, 28], "cooldown": [6.0, 5.5, 5.0], "radius": [4.5, 5.5, 6.5], "status": &"weak", "status_power": [3.0, 4.0, 5.0]}))
	_boon(50, &"fios_cinza", F.VEU, 20, [], _skill(K.ORBIT, {"damage": [7, 10, 14], "count": [2, 3, 4], "cooldown": [0.5], "radius": [3.0, 3.3, 3.6], "status": &"weak", "status_power": [1.5, 2.0, 2.5]}))
	# Mare (empurrar: knockback and a harder blow on whoever is still sliding, Combat.SHOVE_TIME)
	_boon(51, &"golpe_mare", F.MARE, 21, [_mod(&"push_pct", 0.5, [0.25, 0.25], &"light"), _mod(&"damage_pct", 0.08, [0.04, 0.04], &"light")], null, S.ATTACK)
	_boon(52, &"pesado_mare", F.MARE, 21, [_mod(&"push_pct", 0.6, [0.3, 0.3], &"heavy"), _mod(&"damage_pct", 0.08, [0.04, 0.04], &"heavy")], null, S.SPECIAL)
	_boon(53, &"circulo_mare", F.MARE, 21, [_mod(&"push_pct", 0.8, [0.4, 0.4], &"cast"), _fixed(&"reach_pct", 0.15, [0.1, 0.1], &"cast")], null, S.CAST)
	_boon(54, &"passo_mare", F.MARE, 21, [_mod(&"push_pct", 0.8, [0.4, 0.4], &"dash"), _mod(&"damage_pct", 0.15, [0.1, 0.1], &"dash")], null, S.RUSH)
	_boon(55, &"omega_mare", F.MARE, 21, [_mod(&"push_pct", 1.0, [0.5, 0.5], &"omega")])
	_boon(56, &"arrebentacao", F.MARE, 21, [_mod(&"shove_pct", 0.25, [0.15, 0.15])])
	_boon(57, &"mare_cheia", F.MARE, 21, [_mod(&"push_pct", 0.3, [0.15, 0.15])])
	_boon(58, &"vaga", F.MARE, 21, [], _skill(K.NOVA, {"damage": [18, 26, 36], "cooldown": [6.0, 5.0, 4.5], "radius": [5.0, 6.0, 7.0], "status": &"slow", "status_power": [2.5, 3.0, 3.5]}))
	_boon(59, &"espuma", F.MARE, 21, [], _skill(K.ORBIT, {"damage": [9, 13, 18], "count": [2, 3, 4], "cooldown": [0.5], "radius": [3.0, 3.3, 3.6], "status": &"slow", "status_power": [1.0, 1.2, 1.4]}))
	# Marca (marcar e criticar: a marked enemy takes Combat.MARK_CRIT more from every blow; crit_pct adds)
	_boon(60, &"golpe_marca", F.MARCA, 22, [_mod(&"mark_time", 3.0, [1.0, 1.0], &"light")], null, S.ATTACK)
	_boon(61, &"pesado_marca", F.MARCA, 22, [_mod(&"mark_time", 4.0, [1.5, 1.5], &"heavy"), _mod(&"crit_pct", 0.1, [0.05, 0.05], &"heavy")], null, S.SPECIAL)
	_boon(62, &"circulo_marca", F.MARCA, 22, [_mod(&"mark_time", 4.0, [1.5, 1.5], &"cast")], null, S.CAST)
	_boon(63, &"passo_marca", F.MARCA, 22, [_mod(&"mark_time", 3.0, [1.0, 1.0], &"dash"), _mod(&"crit_pct", 0.1, [0.05, 0.05], &"dash")], null, S.RUSH)
	_boon(64, &"omega_marca", F.MARCA, 22, [_mod(&"mark_time", 4.0, [1.5, 1.5], &"omega")])
	_boon(65, &"golpe_certeiro", F.MARCA, 22, [_mod(&"damage_pct", 0.2, [0.1, 0.1], &"finisher")])
	_boon(66, &"olho_atento", F.MARCA, 22, [_mod(&"crit_pct", 0.15, [0.1, 0.1])])
	_boon(67, &"flechas", F.MARCA, 22, [], _skill(K.STRIKES, {"damage": [16, 24, 34], "count": [3, 4, 6], "cooldown": [3.8, 3.3, 2.8], "radius": [1.8, 2.0, 2.2], "status": &"mark", "status_power": [3.0, 4.0, 5.0]}))
	_boon(68, &"chuva_flechas", F.MARCA, 22, [], _skill(K.FAN, {"damage": [14, 20, 28], "count": [4, 6, 9], "cooldown": [5.0, 4.5, 4.0], "radius": [12, 13, 14], "status": &"mark", "status_power": [3.0, 4.0, 5.0]}))
	# The Elos of the three (6 more, 12 in all): each pairs a new family with one of the four, on a move of its own.
	var veu := [&"golpe_veu", &"pesado_veu", &"circulo_veu", &"passo_veu", &"omega_veu", &"final_veu", &"entardecer", &"nevoa", &"fios_cinza"]
	var mare := [&"golpe_mare", &"pesado_mare", &"circulo_mare", &"passo_mare", &"omega_mare", &"arrebentacao", &"mare_cheia", &"vaga", &"espuma"]
	var marca := [&"golpe_marca", &"pesado_marca", &"circulo_marca", &"passo_marca", &"omega_marca", &"golpe_certeiro", &"olho_atento", &"flechas", &"chuva_flechas"]
	_elo(69, &"nevoa_gelida", 12, [_mod(&"freeze_time", 0.8, [], &"heavy")], [veu, geada])
	_elo(70, &"cinza_viva", 14, [_mod(&"burn_dps", 5, [], &"light")], [veu, chama])
	_elo(71, &"mare_ardente", 14, [_mod(&"burn_dps", 6, [], &"cast")], [mare, chama])
	_elo(72, &"correnteza", 16, [_mod(&"push_pct", 0.5, [], &"dash")], [mare, vigilia])
	_elo(73, &"mira_clara", 13, [_mod(&"mark_time", 3.0, [], &"luz")], [luz_hits, marca])
	_elo(74, &"olho_firme", 15, [_mod(&"crit_pct", 0.2, [], &"heavy")], [marca, vigilia])
	_v1_boons()


# ---------- Blessings V1 (docs/design/bencaos_v1, 2026-11-26): seven angels, 63 powers ----------

## The 81 ids of the active catalog (45 principals: five a family, one a button of the hero but E; 36 complements; V2 added the angels Zerael and Saarael). The old
## ids kept here are the ones whose action and meaning stay (docs/design/bencaos_v1/IMPLEMENTACAO.md has the whole table).
const V1_IDS: Array[StringName] = [
	&"golpe_brasa", &"pesado_brasa", &"circulo_brasa", &"passo_brasa", &"chuva_brasas", &"combustao", &"chama_contagiosa", &"brasa_persistente", &"fogo_crescente",
	&"golpe_geada", &"toque_geada", &"circulo_geada", &"floco_errante", &"peso_inverno", &"estilhaco", &"inverno_prolongado", &"geada_profunda", &"cristais_errantes",
	&"golpe_radiante", &"pesado_radiante", &"circulo_radiante", &"clarao", &"ultimo_radiante", &"luz_crescente", &"prosperidade", &"fortuna_celestial", &"esplendor",
	&"golpe_firme", &"pesado_firme", &"circulo_firme", &"passo_firme", &"ultimo_firme", &"ruptura", &"forca_inabalavel", &"peso_vigilia", &"amparo",
	&"golpe_veu", &"pesado_veu", &"circulo_veu", &"fios_cinza", &"crepusculo", &"vulnerabilidade", &"essencia_restauradora", &"veu_persistente", &"entardecer",
	&"golpe_mare", &"pesado_mare", &"circulo_mare", &"passos_leves", &"vendaval", &"cadencia", &"turbilhao", &"brisa_favoravel", &"fluxo_continuo",
	&"golpe_marca", &"pesado_marca", &"circulo_marca", &"olhar_rapido", &"exercito_ecos", &"eco_crescente", &"marca_persistente", &"sombra_revelada", &"ressonancia",
	# Blessings V2 (2026-11-26): Zerael (Peste) and Saarael (Trovao, angel id thunder)
	&"golpe_peste", &"pesado_peste", &"circulo_peste", &"passo_peste", &"epidemia_celestial", &"saturacao", &"peste_persistente", &"deterioracao", &"contagio",
	&"golpe_trovao", &"pesado_trovao", &"circulo_trovao", &"passo_trovao", &"tempestade_celestial", &"descarga", &"conducao", &"sobrecarga", &"ressonancia_eletrica"]

var _v1_n := 0


## A number of a V1 Blessing: base a common card, gain more at each level after the first (0: none), scale: the rarity
## multiplies it (only direct extra damage, DPS and the relative damage bonuses; durations, counts, radii, chances stay).
func _vm(stat: StringName, base: float, gain := 0.0, scale := false) -> BoonMod:
	var m := BoonMod.new()
	m.stat = stat
	var x := FIXED_X if ABS_MODS.has(stat) else 1.0
	m.base = base * x
	m.per_level = PackedFloat32Array([gain * x, gain * x]) if gain > 0.0 else PackedFloat32Array()
	m.by_rarity = scale
	return m


## A skill with the numbers of the spec as they are (no FLAT: the document's values are the ones to play).
func _vs(kind: SkillDef.Kind, props: Dictionary) -> SkillDef:
	var s := SkillDef.new()
	s.kind = kind
	for k: String in props:
		var v: Variant = props[k]
		if v is Array and k == "damage":
			v = v.map(func(x: float) -> float: return roundf(x * FIXED_X))
		s.set(k, PackedFloat32Array(v) if v is Array else v)
	return s


func _v(id: StringName, family: Boon.Family, icon: int, slot: Boon.Slot, mods: Array[BoonMod], skill: SkillDef = null,
		grants: Array[String] = [], needs: Array[String] = []) -> void:
	assert(V1_IDS.has(id), "not in V1_IDS: %s" % id)
	var b := Boon.new()
	b.id = id
	b.family = family
	b.icon = icon
	b.slot = slot
	b.mods = mods
	b.skill = skill
	b.grants = PackedStringArray(grants)
	b.needs_all = PackedStringArray(needs)
	var grows := false
	for m in mods:
		grows = grows or not m.per_level.is_empty()
	if skill != null and skill.damage.size() > 1:
		grows = true
	b.max_level = 3 if grows else 1
	_save(b, "res://data/boons/v1_%02d_%s.tres" % [_v1_n, id])
	_v1_n += 1


func _v1_boons() -> void:
	var F := Boon.Family
	var K := SkillDef.Kind
	var S := Boon.Slot
	var T := SkillDef.Trigger
	# Sarael (Chama): Queimadura and Combustão
	_v(&"golpe_brasa", F.CHAMA, 2, S.ATTACK, [_vm(&"cel_burn_dps", 3.5, 1.5, true)], null, ["burn"])
	_v(&"pesado_brasa", F.CHAMA, 0, S.SPECIAL, [_vm(&"cel_burn_dps", 5, 2.5, true), _vm(&"cel_antic", 0.5)], null, ["burn"])
	_v(&"circulo_brasa", F.CHAMA, 1, S.CAST, [], _vs(K.CONSECRATE, {"trigger": T.SHOUT, "damage": [6, 9, 12], "radius": [2.5], "duration": [3.0],
		"gap": [4.0], "status": &"burn", "status_power": [3.0]}), ["burn"])
	_v(&"passo_brasa", F.CHAMA, 16, S.DASH, [_vm(&"dodge_ember_dps", 6, 3, true)], null, ["burn"])
	_v(&"chuva_brasas", F.CHAMA, 0, S.ULT, [], _vs(K.STRIKES, {"trigger": T.ULT, "damage": [20, 30, 42], "count": [8], "radius": [2.2],
		"status": &"burn", "status_power": [4.0]}), ["burn"])
	_v(&"combustao", F.CHAMA, 14, S.NONE, [_vm(&"cel_combust_dmg", 9, 4.5, true), _vm(&"cel_antic_all", 0.2)], null, [], ["burn"])
	_v(&"chama_contagiosa", F.CHAMA, 14, S.NONE, [_vm(&"cel_spread_pct", 0.5)], null, [], ["burn"])
	_v(&"brasa_persistente", F.CHAMA, 2, S.NONE, [_vm(&"cel_burn_time_pct", 0.3, 0.1)], null, [], ["burn"])
	_v(&"fogo_crescente", F.CHAMA, 2, S.NONE, [_vm(&"cel_burn_dps_pct", 0.2, 0.1, true), _vm(&"cel_burn_div", 0.05)], null, [], ["burn"])
	# Nivael (Geada): Frio and estilhaçamento
	_v(&"golpe_geada", F.GEADA, 3, S.ATTACK, [_vm(&"cel_cold", 1)], null, ["cold"])
	_v(&"toque_geada", F.GEADA, 3, S.SPECIAL, [_vm(&"cel_cold", 2)], null, ["cold"])
	_v(&"circulo_geada", F.GEADA, 4, S.CAST, [], _vs(K.NOVA, {"trigger": T.SHOUT, "damage": [0.0], "radius": [3.0], "gap": [4.0],
		"status": &"cold", "status_power": [2.0]}), ["cold"])
	_v(&"floco_errante", F.GEADA, 4, S.DASH, [], _vs(K.ORBIT, {"trigger": T.DODGE, "damage": [0.0], "count": [2], "cooldown": [0.5],
		"radius": [2.6], "duration": [3.0], "gap": [0.0], "status": &"cold", "status_power": [1.0], "status_gap": 1.0}), ["cold"])
	_v(&"peso_inverno", F.GEADA, 5, S.ULT, [_vm(&"cel_slot_shatter", 0.25)], _vs(K.METEOR, {"trigger": T.ULT, "damage": [55, 80, 115], "radius": [4.0],
		"status": &"cold", "status_power": [3.0]}), ["cold"])
	_v(&"estilhaco", F.GEADA, 4, S.NONE, [_vm(&"cel_shatter_pct", 0.4, 0.15, true), _vm(&"cel_shatter_frag", 0.3)], null, [], ["cold"])
	_v(&"inverno_prolongado", F.GEADA, 17, S.NONE, [_vm(&"cel_cold_time_pct", 0.25), _vm(&"cel_cold_keep", 1.0)], null, [], ["cold"])
	_v(&"geada_profunda", F.GEADA, 12, S.NONE, [_vm(&"cel_slow_add", 0.05), _vm(&"cel_cold_impact", 1)], null, [], ["cold"])
	_v(&"cristais_errantes", F.GEADA, 12, S.NONE, [_vm(&"cel_crystal", 1), _vm(&"cel_crystal_dot", 0.3)], null, [], ["estilhaco"])
	# Lumael (Luz): chance crítica
	_v(&"golpe_radiante", F.LUZ, 8, S.ATTACK, [_vm(&"cel_crit", 0.1, 0.03)], null, ["crit"])
	_v(&"pesado_radiante", F.LUZ, 7, S.SPECIAL, [_vm(&"cel_crit", 0.1, 0.03), _vm(&"cel_crit_mult", 0.25)], null, ["crit"])
	_v(&"circulo_radiante", F.LUZ, 6, S.CAST, [_vm(&"cel_crit", 0.15, 0.03)], null, ["crit"])
	_v(&"clarao", F.LUZ, 10, S.DASH, [_vm(&"cel_crit", 0.15, 0.03)], null, ["crit"])
	_v(&"ultimo_radiante", F.LUZ, 8, S.ULT, [], _vs(K.STRIKES, {"trigger": T.ULT, "damage": [24, 36, 50], "count": [3], "radius": [1.5],
		"status": &"crit", "status_power": [0.15]}), ["crit"])
	_v(&"luz_crescente", F.LUZ, 6, S.NONE, [_vm(&"cel_crit_stack", 0.05)], null, [], ["crit"])
	_v(&"prosperidade", F.LUZ, 13, S.NONE, [_vm(&"gold_pct", 0.1)], null, [], ["fam:luz"])
	_v(&"fortuna_celestial", F.LUZ, 8, S.NONE, [_vm(&"cel_crit_global", 0.05, 0.03)], null, [], ["crit"])
	_v(&"esplendor", F.LUZ, 8, S.NONE, [_vm(&"cel_crit_mult_global", 0.2), _vm(&"cel_crit_apply", 0.5)], null, [], ["crit"])
	# Shomael (Vigília): Impacto e ruptura
	_v(&"golpe_firme", F.VIGILIA, 11, S.ATTACK, [_vm(&"cel_impact", 1)], null, ["impact"])
	_v(&"pesado_firme", F.VIGILIA, 15, S.SPECIAL, [_vm(&"cel_impact", 2), _vm(&"cel_slot_shatter", 0.25)], null, ["impact"])
	_v(&"circulo_firme", F.VIGILIA, 9, S.CAST, [], _vs(K.NOVA, {"trigger": T.SHOUT, "damage": [14, 21, 30], "radius": [3.0], "gap": [4.0],
		"status": &"impact", "status_power": [2.0]}), ["impact"])
	_v(&"passo_firme", F.VIGILIA, 10, S.DASH, [_vm(&"cel_guard_time", 1.2)], null, [], [])
	_v(&"ultimo_firme", F.VIGILIA, 11, S.ULT, [], _vs(K.NOVA, {"trigger": T.ULT, "damage": [45, 66, 96], "radius": [6.0],
		"status": &"impact", "status_power": [3.0]}), ["impact"])
	_v(&"ruptura", F.VIGILIA, 15, S.NONE, [_vm(&"cel_impact_need", -1), _vm(&"cel_stun_antic", 0.25)], null, [], ["impact"])
	_v(&"forca_inabalavel", F.VIGILIA, 11, S.NONE, [_vm(&"cel_stunned_dmg_pct", 0.3, 0.12, true), _vm(&"cel_stun_pulse", 1)], null, [], ["impact"])
	_v(&"peso_vigilia", F.VIGILIA, 9, S.NONE, [_vm(&"cel_impact_time_pct", 0.3)], null, [], ["impact"])
	_v(&"amparo", F.VIGILIA, 9, S.NONE, [_vm(&"cel_guard_time_pct", 0.25), _vm(&"cel_guard_impact", 2)], null, [], ["passo_firme"])
	# Velael (Véu): Fraqueza
	_v(&"golpe_veu", F.VEU, 20, S.ATTACK, [_vm(&"cel_weak", 2, 1)], null, ["weak"])
	_v(&"pesado_veu", F.VEU, 20, S.SPECIAL, [_vm(&"cel_weak", 3, 1)], null, ["weak"])
	_v(&"circulo_veu", F.VEU, 20, S.CAST, [], _vs(K.NOVA, {"trigger": T.SHOUT, "damage": [0.0], "radius": [3.0], "gap": [0.0],
		"status": &"weak", "status_power": [4.0, 5.5, 7.0]}), ["weak"])
	_v(&"fios_cinza", F.VEU, 20, S.DASH, [], _vs(K.NOVA, {"trigger": T.DODGE, "damage": [0.0], "radius": [2.0], "gap": [3.0],
		"status": &"weak", "status_power": [2.0, 3.0, 4.0]}), ["weak"])
	_v(&"crepusculo", F.VEU, 20, S.ULT, [_vm(&"cel_extend", 2.0)], _vs(K.NOVA, {"trigger": T.ULT, "damage": [0.0], "radius": [7.0],
		"status": &"weak", "status_power": [5.0, 6.5, 8.0]}), ["weak"])
	_v(&"vulnerabilidade", F.VEU, 20, S.NONE, [_vm(&"cel_weak_dmg_pct", 0.15, 0.07, true), _vm(&"cel_weak_div", 0.03)], null, [], ["weak"])
	_v(&"essencia_restauradora", F.VEU, 20, S.NONE, [_vm(&"cel_weak_mana", 1), _vm(&"cel_weak_mana_div", 1)], null, [], ["weak"])
	_v(&"veu_persistente", F.VEU, 20, S.NONE, [_vm(&"cel_weak_time_pct", 0.25), _vm(&"cel_weak_extend", 1.0)], null, [], ["weak"])
	_v(&"entardecer", F.VEU, 20, S.NONE, [_vm(&"weak_pct", 0.08)], null, [], ["weak"])
	# Galael (Vento, id Mare): velocidade e cadência
	_v(&"golpe_mare", F.MARE, 21, S.ATTACK, [_vm(&"cel_speed", 0.12, 0.04)], null, ["wind"])
	_v(&"pesado_mare", F.MARE, 21, S.SPECIAL, [], _vs(K.FAN, {"trigger": T.SPECIAL, "damage": [14, 21, 30], "count": [1], "radius": [10.0],
		"gap": [1.0], "status": &"spread", "status_power": [0.3]}), ["wind"])
	# GP-1: the Corte Circular has no recharge to cut; the Wind makes it faster (preparation and recovery), as the Attack's
	_v(&"circulo_mare", F.MARE, 21, S.CAST, [_vm(&"cel_speed", 0.12, 0.04)], null, ["wind"])
	_v(&"passos_leves", F.MARE, 21, S.DASH, [_vm(&"dodge_charges", 1)], null, ["wind"])
	_v(&"vendaval", F.MARE, 21, S.ULT, [_vm(&"cel_haste_speed", 0.3), _vm(&"cel_haste_move", 0.1), _vm(&"cel_haste_time", 5.0)], null, ["wind"])
	_v(&"cadencia", F.MARE, 21, S.NONE, [_vm(&"cel_cadence", 0.03)], null, ["cadence"], ["fam:mare"])
	_v(&"turbilhao", F.MARE, 21, S.NONE, [_vm(&"cel_whirl_dmg", 18, 9, true), _vm(&"cel_whirl_spread", 0.25)], null, [], ["cadencia"])
	_v(&"brisa_favoravel", F.MARE, 21, S.NONE, [_vm(&"move_speed_pct", 0.05)], null, [], ["fam:mare"])
	_v(&"fluxo_continuo", F.MARE, 21, S.NONE, [_vm(&"cel_cadence_time_pct", 0.3), _vm(&"cel_cadence_mix", 1)], null, [], ["cadencia"])
	# Qeshael (Penumbra, id Marca): Marca e ecos
	_v(&"golpe_marca", F.MARCA, 22, S.ATTACK, [_vm(&"cel_mark", 3, 1)], null, ["mark"])
	_v(&"pesado_marca", F.MARCA, 22, S.SPECIAL, [_vm(&"cel_echo", 0.4), _vm(&"cel_bleed", 0.4, 0.0, true)], null, ["echo"], ["mark"])
	_v(&"circulo_marca", F.MARCA, 22, S.CAST, [_vm(&"cel_echo", 0.35)], null, ["echo"])
	_v(&"olhar_rapido", F.MARCA, 22, S.DASH, [_vm(&"cel_mark", 3, 1), _vm(&"cel_radius", 3.0)], null, ["mark"])
	_v(&"exercito_ecos", F.MARCA, 22, S.ULT, [_vm(&"cel_echo", 0.4), _vm(&"cel_echo_time", 5.0), _vm(&"cel_bleed", 0.2, 0.0, true)], null, ["echo"])
	_v(&"eco_crescente", F.MARCA, 22, S.NONE, [_vm(&"cel_echo_pct", 0.3, 0.15, true), _vm(&"cel_bleed_pct", 0.3)], null, [], ["echo"])
	_v(&"marca_persistente", F.MARCA, 22, S.NONE, [_vm(&"cel_mark_time_pct", 0.3), _vm(&"cel_mark_pass", 1)], null, [], ["mark"])
	_v(&"sombra_revelada", F.MARCA, 22, S.NONE, [_vm(&"cel_echo_marked_pct", 0.2, 0.08, true), _vm(&"cel_bleed_crit", 0.25)], null, [], ["mark", "echo"])
	_v(&"ressonancia", F.MARCA, 22, S.NONE, [_vm(&"cel_echo_cd_cut", 0.1)], null, [], ["echo"])
	# Zerael (Peste, angel id zerael): Veneno. Provisional icon 12 (the steam's clouds) until the 18 icons are painted.
	_v(&"golpe_peste", F.PESTE, 12, S.ATTACK, [_vm(&"cel_poison_dps", 0.55, 0.2, true), _vm(&"cel_poison", 1)], null, ["poison"])
	_v(&"pesado_peste", F.PESTE, 12, S.SPECIAL, [_vm(&"cel_poison_dps", 0.8, 0.27, true), _vm(&"cel_poison", 3)], null, ["poison"])
	_v(&"circulo_peste", F.PESTE, 12, S.CAST, [], _vs(K.CONSECRATE, {"trigger": T.SHOUT, "damage": [0.0], "radius": [2.5], "duration": [4.0],
		"gap": [3.0], "status": &"poison", "status_power": [1.0], "status_gap": 1.0}), ["poison"])
	_v(&"passo_peste", F.PESTE, 12, S.DASH, [_vm(&"dodge_plague_dps", 1.0, 0.5, true)], null, ["poison"])
	_v(&"epidemia_celestial", F.PESTE, 12, S.ULT, [], _vs(K.NOVA, {"trigger": T.ULT, "damage": [24, 36, 52], "radius": [7.0],
		"status": &"poison", "status_power": [3.0]}), ["poison"])
	_v(&"saturacao", F.PESTE, 12, S.NONE, [_vm(&"cel_sat_dmg", 8, 4, true)], null, [], ["poison"])
	_v(&"peste_persistente", F.PESTE, 12, S.NONE, [_vm(&"cel_poison_time_pct", 0.3, 0.1), _vm(&"cel_poison_cold", 1)], null, [], ["poison"])
	_v(&"deterioracao", F.PESTE, 12, S.NONE, [_vm(&"cel_poison_grow", 0.06, 0.03)], null, [], ["poison"])
	_v(&"contagio", F.PESTE, 12, S.NONE, [_vm(&"cel_poison_spread", 0.5, 0.1)], null, [], ["poison"])
	# Saarael (Trovao, angel id thunder): Eletrificacao e Descarga. Provisional icon 4 (the shards bursting).
	_v(&"golpe_trovao", F.TROVAO, 4, S.ATTACK, [_vm(&"cel_shock_zap", 1.0, 0.5, true), _vm(&"cel_shock", 1)], null, ["shock"])
	_v(&"pesado_trovao", F.TROVAO, 4, S.SPECIAL, [_vm(&"cel_shock_zap", 1.5, 0.5, true), _vm(&"cel_shock", 3), _vm(&"cel_force_discharge", 1)], null, ["shock"])
	_v(&"circulo_trovao", F.TROVAO, 4, S.CAST, [], _vs(K.NOVA, {"trigger": T.SHOUT, "damage": [6, 9, 12], "radius": [3.0], "gap": [4.0],
		"status": &"shock", "status_power": [2.0]}), ["shock"])
	_v(&"passo_trovao", F.TROVAO, 4, S.DASH, [], _vs(K.NOVA, {"trigger": T.DODGE, "damage": [0.0], "radius": [2.0], "gap": [2.0],
		"status": &"shock", "status_power": [1.0]}), ["shock"])
	_v(&"tempestade_celestial", F.TROVAO, 4, S.ULT, [], _vs(K.STRIKES, {"trigger": T.ULT, "damage": [24, 36, 50], "count": [6], "radius": [1.5],
		"status": &"shock", "status_power": [2.0]}), ["shock"])
	_v(&"descarga", F.TROVAO, 4, S.NONE, [_vm(&"cel_discharge", 3, 1.5, true)], null, [], ["shock"])
	_v(&"conducao", F.TROVAO, 4, S.NONE, [_vm(&"cel_conduct", 2, 1)], null, [], ["descarga"])
	_v(&"sobrecarga", F.TROVAO, 4, S.NONE, [_vm(&"cel_overload", 0.5, 0.2)], null, [], ["shock"])
	_v(&"ressonancia_eletrica", F.TROVAO, 4, S.NONE, [_vm(&"cel_reson", 0.10, 0.03)], null, [], ["descarga"])
	assert(_v1_n == 81, "the V2 catalog has 81 powers, made %d" % _v1_n)


# ---------- waves ----------

func _segment(from: float, until: float, enemies: Array[StringName], weights: Array, rate: Vector2, cap: Vector2i) -> WaveSegment:
	var s := WaveSegment.new()
	s.from = from
	s.until = until
	s.enemies = enemies
	s.weights = PackedFloat32Array(weights)
	s.rate_start = rate.x
	s.rate_end = rate.y
	s.cap_start = cap.x
	s.cap_end = cap.y
	return s


func _event(time: float, kind: WaveEvent.Kind, enemy: StringName = &"") -> WaveEvent:
	var e := WaveEvent.new()
	e.time = time
	e.kind = kind
	e.enemy = enemy
	return e


func _waves() -> void:
	var t := WaveTable.new()
	t.segments = [
		# The first three minutes are sparse on purpose: about 140 enemies, each falling in one or two blows,
		# so every hit lands on someone you can see; the first elite closes them.
		_segment(0, 60, [&"skeleton"], [1], Vector2(0.5, 0.75), Vector2i(12, 20)),
		_segment(60, 180, [&"skeleton", &"archer", &"guard"], [8, 1, 0.6], Vector2(0.75, 0.95), Vector2i(20, 40)),
		_segment(180, 300, [&"skeleton", &"archer", &"guard", &"runner"], [7, 1.2, 0.8, 1.6], Vector2(1.2, 5.5), Vector2i(40, 170)),
		_segment(300, 480, [&"skeleton", &"archer", &"guard", &"runner", &"mage"], [7, 1.3, 1.0, 1.8, 0.9], Vector2(5.5, 7.0), Vector2i(170, 230)),
		_segment(480, 600, [&"skeleton", &"archer", &"guard", &"runner", &"mage"], [7, 1.4, 1.2, 2.0, 1.1], Vector2(7.0, 8.5), Vector2i(230, 270)),
		_segment(600, 900, [&"skeleton", &"archer", &"guard", &"runner", &"mage"], [7, 1.5, 1.4, 2.2, 1.3], Vector2(8.5, 10.0), Vector2i(270, 300)),
	]
	t.events = [_event(180, WaveEvent.Kind.ELITE, &"knight"), _event(420, WaveEvent.Kind.FOUNTAIN), _event(600, WaveEvent.Kind.ELITE, &"priest"), _event(900, WaveEvent.Kind.BOSS, &"morvath")]
	t.hp_per_minute = 0.2
	t.damage_per_minute = 0.05
	# Short test run while the game is an MVP: the same 15-minute timeline played in 3 (pace 1 is the full run).
	t.pace = RUN_PACE
	_save(t, "res://data/waves/catacombs.tres")


# ---------- the descent room by room ----------

func _layout(half: Vector2, pillars: Array[Vector3], shafts: Array[Vector2]) -> RoomLayout:
	var l := RoomLayout.new()
	l.half = half
	l.pillars = pillars
	l.shafts = shafts
	return l


func _pool(tier: StageDef.Tier, from: float, until: float, weight: float, roles: Array[StringName], elite_chance: float = 0.0) -> EncounterPool:
	var p := EncounterPool.new()
	p.tier = tier
	p.from = from
	p.until = until
	p.weight = weight
	p.roles = roles
	p.elite_chance = elite_chance
	return p


func _shop_group(items: Array, prices: Array, weights: Array, count: int = 1) -> ShopGroup:
	var g := ShopGroup.new()
	g.count = count
	g.items = PackedInt32Array(items)
	g.prices = PackedInt32Array(prices)
	g.weights = PackedFloat32Array(weights)
	return g


## The catacombs as a region of rooms, with the room generator and rewards of the first region of Hades II.
func _stage() -> void:
	var st := StageDef.new()
	# The whole region of Hades II (C13-01, decision D-61): ten rooms and Morvath in the 11th. The opening in the
	# catacomb hall, fights drawn among the crypt, the rift hall and the garden (never the same twice in a row, none
	# more than arena_max_uses times), the guardian in room 5 or 6 (GP-8: never in 4, a Blessing more before him), a
	# fountain as one of the two doors before him (GP-2; with fountain_more_chance another in 7 or 8), the shop in room
	# 10 (Hades II's antechamber shop). --medium plays the test one of 7 of cycle C12, --short the old one of 5
	# (Rooms.short_stage).
	# Daniel, 2026-11-22: 4 rooms, guardian, 4 rooms, guardian, 2 rooms, the shop, Morvath (14)
	st.rooms = 13
	st.arena_max_uses = 4  # (3 in the 11 rooms of before)
	# elites from depth 3, as in Hades II (the shorter descents keep them from the 2nd room)
	st.elite_from_depth = 3
	st.miniboss_depth_min = 5
	st.miniboss_depth_max = 5
	st.minibosses = [&"knight", &"priest_elder"]
	# Daniel, 2026-11-22: both guardians in a descent, then Morvath (the second is the one he did not choose)
	st.miniboss2_depth_min = 10
	st.miniboss2_depth_max = 10
	st.miniboss_gap = 5
	st.fountain_depth_min = 6
	st.fountain_depth_max = 11
	st.fountain_more_chance = 0.0
	st.fountains_per_path = 3  # PM-4: 4 on every way before (160% heal); 3 keeps one before the second guardian (kids found it hard)
	st.boss = &"morvath"
	# The descent's graph (DM-1; RunMap): always two doors a room, a pomegranate behind a door from room 3 (Q-25 a)
	st.pom_from_depth = 3
	# B-4 (balance.md B.5): every room harder from the start
	st.base_difficulty = 70.0
	# C1b (Frente 2): a share of that by room, low at the start, a valley after a hard room (4, 8, 12), the common having 1.6 times
	# its life (Frente 1); depths 5 and 10 are guardians' and take none. A bigger one in a fight from room 4, half of them.
	st.room_budget = PackedFloat32Array([0.65, 0.75, 0.85, 0.6, 1.0, 0.8, 0.9, 0.65, 0.9, 1.0, 0.9, 0.75])
	st.big_from_depth = 4
	st.big_chance = 0.5
	st.depth_ramp = 11.0  # (C2, 14 rooms: the last fight, room 12, is 191, was 226)
	st.enemies = [&"skeleton", &"skeleton_elite", &"runner", &"runner_elite", &"mage", &"mage_elite", &"archer", &"archer_elite",
		&"guard", &"guard_elite", &"priest", &"priest_elite", &"trinca", &"trinca_elite", &"varredor", &"varredor_elite", &"skeleton_big", &"runner_big", &"gritador", &"coveiro", &"saltador", &"lancador", &"canalizador", &"armadilheiro", &"bone_rat", &"capitao"]
	# C1e, lote A: the modifiers of the deep rooms: from room 8 each plain head has 10% (5 points more a room), two a fight at most
	st.mods = [&"furioso", &"detonante", &"regenerante", &"escoltado", &"eco"]
	st.mod_from_depth = 8
	st.mod_chance = 0.10
	st.mod_step = 0.05
	st.mod_per_room = 2
	# Few enemies at once, each with its part, a fight won by skill as in Hades II (Daniel, 2026-11-15: not a horde
	# survivor). Standing at once: common 4 to 8, hard 8 to 12 (guardians, elites), special 12 to 16, never past 20;
	# Morvath's summons have their own ceiling (BossDef.adds_cap, ritual_cap). A room may have several waves: the next one comes when
	# one enemy is left (wave_remaining), and only while there is room under the cap.
	var Tier := StageDef.Tier
	st.alive_cap = 20
	# RD2-06: the rooms that were short (2 to 4, 6 to 9: 15 to 37 s) come in 3 lighter waves, the last with an elite, the heads
	# rising one by one: 25 to 45 s there, 30 to 55 s in the deeper ones, the same life in all
	st.long_depths = PackedInt32Array([1, 2, 3, 4, 6, 7, 8, 9, 11, 12])  # (SW-R1: every fight room: the heads rise one by one, the last wave an elite)
	st.long_fewest = 2
	# SW-R1 (docs/design/rooms_progression.md, "O orçamento"): Kingswood's curve (4 in the first room, 8 in the 5th, 6 right after the
	# guardian, 11 from the 11th: sala x 5 here), a room one wave of it, two of 0.75 or a horde of 0.75 + 0.75 (half of them);
	# the guardians' depths (5, 10) take none
	# SW-R1b (Daniel, 2026-11-27: too many a room): SWORN's 4 / 8 / 6 / 11 at 1.5 (our heads have more life) in place of x5; depths 1 to 4 are
	# written by hand (opening_waves) and keep the first four numbers only as the fallback. The late rooms (11 and 12) are the fullest.
	st.cost_curve = PackedFloat32Array([6, 9, 11, 12, 12, 9, 11, 13, 16, 16, 14, 16])
	# SW-R1b: the four opening rooms, one lesson each (SWORN's tutorial: a hammer then two axes; two boars then five snakes; heavies; a mix):
	# 1 the soldier (one, then two), 2 the crossbow to dodge (one, then two with a soldier), 3 the fast ones (two runners, then a pack of rats),
	# 4 the mix (soldiers and a crossbow, then the shield with a soldier). Costs 3+6, 4+11, 6+5, 10+8: no elite, no modifier, no big one.
	st.opening_waves = {
		1: _wave_lists([["skeleton"], ["skeleton", "skeleton"]]),
		2: _wave_lists([["archer"], ["archer", "archer", "skeleton"]]),
		3: _wave_lists([["runner", "runner"], ["bone_rat", "bone_rat", "bone_rat", "bone_rat", "bone_rat"]]),
		4: _wave_lists([["skeleton", "skeleton", "archer"], ["guard", "skeleton"]]),
	}
	st.opening_cap = 4
	st.horde_share = 0.5
	st.two_wave_share = 0.5
	st.wave_coef_two = 0.6  # (SWORN 0.75: ours waits for the floor to clear between the two, which asks 10 s more)
	st.wave_most = 20
	st.long_gap = Vector2(0.45, 0.75)
	st.long_delay = 0.8
	st.long_elite_from = 4
	st.tier_alive = [Vector2i(3, 6), Vector2i(7, 11), Vector2i(11, 15)]  # (C2: the top rooms stay at 3 to 4)
	st.miniboss_tier = Tier.HARD
	# The fights by how far down the region (0 the first room, 1 the last fight before the shop; EncounterGen.progress).
	# The parts (EnemyDef.role): pressure the soldier, react the runner, control the caster, flank the crossbowman,
	# block the shield-bearer, area the priest. Never every kind at once without a reason.
	st.pools = [
		# C2 (salas_14_c2.md): the top introduces one kind a room, in narrow bands that do not touch (room 1 is only the
		# soldier: a pool of a single part), then the mixes that make a choice
		_pool(Tier.COMMON, 0.0, 0.05, 1.0, [&"pressure"]),
		_pool(Tier.COMMON, 0.05, 0.13, 1.0, [&"pressure", &"react"]),
		_pool(Tier.COMMON, 0.13, 0.22, 1.0, [&"pressure", &"flank"]),
		_pool(Tier.COMMON, 0.22, 0.30, 1.0, [&"block", &"pressure"]),
		_pool(Tier.COMMON, 0.30, 0.60, 3.0, [&"block", &"pressure", &"control"]),
		_pool(Tier.COMMON, 0.30, 0.60, 2.0, [&"react", &"flank", &"pressure"]),
		_pool(Tier.COMMON, 0.40, 0.60, 2.0, [&"block", &"flank"]),
		_pool(Tier.HARD, 0.40, 0.60, 1.0, [&"pressure", &"react", &"control"], 0.5),
		_pool(Tier.COMMON, 0.60, 0.80, 2.0, [&"block", &"area", &"pressure"]),
		_pool(Tier.HARD, 0.60, 0.80, 3.0, [&"block", &"flank", &"control"], 0.5),
		_pool(Tier.HARD, 0.60, 0.80, 2.0, [&"react", &"area", &"flank"], 0.5),
		_pool(Tier.HARD, 0.80, 1.0, 3.0, [&"block", &"area", &"control"], 0.7),
		_pool(Tier.HARD, 0.80, 1.0, 3.0, [&"react", &"flank", &"area", &"pressure"], 0.7),
		_pool(Tier.SPECIAL, 0.80, 1.0, 1.0, [&"block", &"area", &"control", &"flank"], 0.7),
		# C5 (CB-7): the Trinca and the Varredor come after the 6th room (progress 0.46 is the 7th), each a part of its own:
		# swarm (knock all three down in one window) and sweep (walk with its bar, or stand at its feet)
		_pool(Tier.COMMON, 0.46, 0.80, 2.0, [&"pressure", &"swarm", &"flank"]),
		_pool(Tier.HARD, 0.46, 0.80, 2.0, [&"block", &"swarm", &"control"], 0.5),
		_pool(Tier.HARD, 0.46, 1.0, 2.0, [&"pressure", &"sweep", &"control"], 0.5),
		_pool(Tier.HARD, 0.70, 1.0, 2.0, [&"swarm", &"sweep", &"flank"], 0.7),
		_pool(Tier.SPECIAL, 0.80, 1.0, 1.0, [&"block", &"sweep", &"control", &"swarm"], 0.7),
		# C1e, lote A: the Gritador from room 6 (progress 0.4), the Coveiro from room 8 (0.6): one new part a fight, always with a part
		# already known; the one that is the target to choose (Gritador) beside the soldiers and the shield, the one that runs (Coveiro)
		# beside the casters and the crossbow
		_pool(Tier.COMMON, 0.40, 0.80, 2.0, [&"pressure", &"rally", &"react"]),
		_pool(Tier.COMMON, 0.40, 1.0, 2.0, [&"block", &"rally", &"pressure"]),
		_pool(Tier.HARD, 0.60, 1.0, 2.0, [&"react", &"rally", &"flank"], 0.5),
		_pool(Tier.COMMON, 0.60, 1.0, 2.0, [&"control", &"grave", &"pressure"]),
		_pool(Tier.HARD, 0.60, 1.0, 2.0, [&"block", &"grave", &"flank"], 0.5),
		# C1e, lote B: the Saltador from room 3 (progress 0.18) with the soldier, the crossbow (the leap takes the dodge, the bolt asks to walk)
		# or the shield; the Lançador from room 4 (0.27) with the soldier or the Trinca (the axe crosses all three); both only deep (0.8)
		_pool(Tier.COMMON, 0.18, 0.46, 2.0, [&"pressure", &"leap"]),
		_pool(Tier.COMMON, 0.30, 0.80, 2.0, [&"flank", &"leap", &"pressure"]),
		_pool(Tier.COMMON, 0.30, 0.60, 1.0, [&"block", &"leap"]),
		_pool(Tier.COMMON, 0.27, 0.60, 2.0, [&"pressure", &"throw"]),
		_pool(Tier.COMMON, 0.46, 1.0, 2.0, [&"swarm", &"throw", &"pressure"]),
		_pool(Tier.HARD, 0.80, 1.0, 2.0, [&"leap", &"throw", &"block"], 0.5),
		# C1e, lote C: the Canalizador from room 6 (0.4) beside the soldier or the shield (go round behind it without entering the line, the
		# bodies as cover); the Armadilheiro from room 9 (0.64) beside the crossbow (the dodge is dear, the bolt asks to walk), the Saltador
		# (the landing and the plates narrow the room) or the shield. Never with the Varredor (never_with), nor the Armadilheiro on the chain's floor
		_pool(Tier.COMMON, 0.40, 0.70, 2.0, [&"pressure", &"beam"]),
		_pool(Tier.COMMON, 0.46, 1.0, 2.0, [&"block", &"beam", &"pressure"]),
		_pool(Tier.HARD, 0.70, 1.0, 2.0, [&"pressure", &"beam", &"flank"], 0.5),
		_pool(Tier.COMMON, 0.64, 1.0, 2.0, [&"pressure", &"trap", &"flank"]),
		_pool(Tier.COMMON, 0.64, 1.0, 2.0, [&"leap", &"trap", &"pressure"]),
		_pool(Tier.HARD, 0.70, 1.0, 2.0, [&"block", &"trap", &"flank"], 0.5),
		# SW-C7 (the pack of rats, from room 3) and SW-C8 (the Capitão, from room 4, the last wave, one a fight)
		_pool(Tier.COMMON, 0.18, 0.60, 2.0, [&"scurry", &"pressure"]),
		_pool(Tier.COMMON, 0.46, 1.0, 1.5, [&"scurry", &"flank", &"block"]),
		_pool(Tier.HARD, 0.27, 0.60, 2.0, [&"pressure", &"captain"]),  # (no elite before room 5, C2)
		_pool(Tier.HARD, 0.46, 1.0, 1.5, [&"control", &"captain", &"scurry"], 0.5),
		_pool(Tier.HARD, 0.60, 1.0, 1.5, [&"block", &"captain", &"flank"], 0.5),
	]
	var R := RunMap.Reward
	# The doors' deck (C13-02, Hades II's RunProgress: 4 Blessings, 2 hearts, 2 Magia tonics, 2 gold, 2 pomegranates,
	# 2 hammers, Hermes, Selene, the star path and a room of two gods). What we do not have yet is left out (hammer,
	# Selene, star path); Hermes and the two gods' room are Blessings here. Drawn without putting back, filled again.
	# Rejogabilidade, Fatia 1 (sistemas.md 3.1): one door of Prata and one of Memória more, nothing taken (14 to 16).
	# Fatia 2 (sistemas.md 1.7, 3.6): two Encantos (Hades II's two hammer cards) and a Psalm's door, and two Blessings
	# more so they keep their share of the deck (6 of 16, now 8 of 21: with the six of before the robot reached Morvath
	# with a Blessing less and won 46 of 72 against 58, 2026-11-20); of the Blessings two in six are a meeting of two
	# angels and the rest show one angel (angel_deck, Q-RJ5 a).
	# Daniel's playtest, 2026-11-27 ("sempre vem Bênção"; the rewards need not only make the hero strong, some are things to spend in
	# the hub): two Blessings became a Prata and a Memória door (6 Blessings, 4 of the hub's materials in 23).
	st.reward_deck = PackedInt32Array([R.BOON, R.BOON, R.BOON, R.BOON, R.BOON, R.BOON, R.SILVER, R.MEMORY, R.POM, R.POM,
		R.HEART, R.HEART, R.MAGICK, R.MAGICK, R.GOLD, R.GOLD, R.GOLD, R.HEART, R.SILVER, R.MEMORY, R.ENCHANT, R.ENCHANT, R.PSALM])
	st.angel_deck = PackedInt32Array([1, 1, 0, 0, 0, 0])
	# SW-R2 (Kingswood's fixed rooms: a Blessing in the first two rooms, the heart in the 2nd, the heal and the gold from the 7th and the
	# 11th): the doors of these rooms give these, in order; the guardians stand in 5 and 10 (the shop in 13 is always the same room),
	# and the room after each is a rest (a fountain on one of its two doors). The rest are drawn from the deck as ever.
	st.rest_after_guardian = true
	st.fixed_rewards = {2: PackedInt32Array([R.BOON, R.HEART]), 7: PackedInt32Array([R.POM, R.MAGICK]), 11: PackedInt32Array([R.BOON, R.GOLD])}
	# the Psalm's door from the 4th room (a Psalm needs three things of the hand); at most two Encantos on a way, the
	# second from the 5th room (Hades II's late hammer: past half the run)
	st.psalm_from_depth = 4
	st.enchant_max = 2
	st.enchant_second_from = 5
	# What a descent brings home (sistemas.md 1.2, starting numbers for the balance-designer): Prata by an elite 1, a
	# door 10, a guardian 6, Morvath 2 a phase reached (up to 8) and 10 at the sealing; Memória by a door 3, a guardian 2,
	# a Provação won 2 and the sealing 3.
	st.silver_elite = 2  # (was 1; balance 2026-11-24, Lote D)
	st.silver_room = 1  # a fight room won
	st.silver_door = 10
	st.silver_guardian = 6
	st.room_heal_base = 3.0  # the novice who skips the fountain still reaches the guardian with some life
	st.silver_phase = 2
	st.phase_max = 4
	st.silver_victory = 10
	st.memory_door = 3
	st.memory_guardian = 2
	st.memory_guardian_reach = 1  # stepping into the guardian's room
	st.memory_trial = 2
	st.memory_victory = 3
	# Esmeralda (Fatia 2): 1 when Morvath's phase 3 is reached, 1 at the sealing
	st.emerald_phase_at = 3
	st.emerald_phase = 1
	st.emerald_victory = 1
	# Gold (C13-04, Hades II): a fight's ceiling 10 to 15 plus 0.5 a room of depth, 70% that each enemy leaves its
	# share; a gold reward 100.
	st.gold_cap_min = 10
	st.gold_cap_max = 15
	st.gold_per_depth = 0.8  # (C2: 10 fights of the 14 rooms, about 190 gold)
	st.gold_drop_chance = 0.7
	st.gold_reward = 100
	# Blessings (C13-03, C13-06, E3-01): rarity tried in turn (rare 10%, epic 5%; the legendary only by a trade), the
	# guardian's (rare 90%, epic 7%; Hades II's 5% legendary is the Psalm, none yet), Elo 12% a card, trade 10% a card.
	# SW-B2: 77.4 / 14.7 / 5.9 / 2 % (was 84.6 / 9.4 / 5 / 1), the epic and the legendary felt in every descent
	st.rarity_chance = [0.16, 0.06, 0.02] as Array[float]  # decision 10 of 2026-11-22: a legendary in the common draw...
	st.guardian_rarity_chance = [0.90, 0.07, 0.03] as Array[float]  # ...and 3% at the guardian
	st.elo_chance = 0.5  # SW-B2: the Elo's ceiling, reached with 10 Blessings; none below 3 (elo_ramp: Boon.ELO_RAMP)
	st.elo_ramp = Boon.ELO_RAMP
	st.trade_chance = 0.1
	# a Psalm (E4): 10% of the cards once one can be offered, 5% at the guardian (guardian_spec.md 11.1)
	st.psalm_chance = 0.1
	st.guardian_psalm_chance = 0.05
	# The shop (C13-04, Hades II's WorldShop): items from three groups. A Blessing 150; healing 50 (40% of life) and a
	# heart 125; growth: two of a Magia tonic 100, a pomegranate 100 and its slice 50. Ours is the last shop before the
	# final boss, which in Hades II shows five items (one of each group in the shops along the way): 1 + 2 + 2. With one
	# of each (E3 first measure) the robot bought in 4 of 8 runs: healing and the slice were often not on the shelf.
	st.shop_groups = [
		_shop_group([R.BOON], [150], [1.0], 1),
		_shop_group([R.HEAL, R.HEART], [50, 125], [1.0, 1.0], 2),
		# an Encanto 200 with the growth (Fatia 2; Hades II keeps the hammer by the healing, ours keeps the healing on
		# the shelf always)
		_shop_group([R.MAGICK, R.POM, R.POM_SLICE, R.ENCHANT], [100, 100, 50, 200], [1.0, 1.0, 1.0, 1.0], 2),
	]
	st.shop_heal = 0.4
	# The arenas (cycle C12; docs/design/cycle12_arenas_plan.md, plans in docs/art/cycle12_arenas_spec.md). The catacomb
	# hall of Daniel's reference image (CatacombHall: its pieces and collision live there) is the opening, the fountain
	# and the shop (decision D-26); the fights after it are drawn among the crypt, the rift hall and the garden
	# (RunMap._layout), never the same twice in a row. Each is data: floor with holes, obstacles (collision and look),
	# spawn zones, doors, camera box, two variants.
	var hall := _layout(CatacombHall.HALF, [], [])
	hall.platform = true
	_arena(hall, &"hall", RoomLayout.Size.MEDIUM, 0, Vector2(0.0, 0.0))
	hall.fountain = true
	# E5 (docs/art/e5_spec.md): the Santuário (the guardian's house, high, from 40% of the descent), the Ponte and the
	# Câmara das Runas (high, from half of it); the rooms of the two events
	st.layouts = [hall, _crypt(), _rift(), _garden(), _sanctuary(), _bridge(), _runes(), _knight_hall(), _elder_hall()]
	st.shop_layout = hall
	_prologue(st)
	st.trial_layout = _trial_room()
	st.altar_layout = _altar_room()
	_oficios_stage(st)
	_relics(st)
	# The Provação (Hades II's Chaos, hades2_sistemas.md 7): 20% a room won, from the 2nd room to the 7th (a curse of 3
	# to 5 fights must have fights to be carried in before the shop), once in 10 rooms (once in a descent), at
	# ceil(10 + 0.5 x depth) life; three cards, the blessing's rarity as the Chaos's (rare 40%, epic 10%).
	st.trial_chance = 0.2
	st.trial_depth_min = 2
	st.trial_depth_max = 11
	st.trial_cooldown = 10
	st.trial_cost_base = 10.0
	st.trial_cost_per_depth = 0.5
	st.trial_cards = 3
	st.trial_min_hp_frac = 0.6
	st.trial_rarity_chance = [0.4, 0.1, 0.0] as Array[float]
	# The Altar Esquecido (ours): a door to it once, 20% a room from the 2nd to the 8th; 10 of the most life for a
	# pomegranate, or 75 gold (half a Blessing in the shop) for 25 more Magia
	st.altar_depth_min = 2
	st.altar_depth_max = 11
	st.altar_chance = 0.2
	# DV-2 (MAP-09): a route shop of three items (a Blessing, healing or a heart, the growth's) on one branch of the
	# 6th to 8th rooms, 35% a layer where it may stand (about a third of the maps), beside the last one in the 10th
	st.route_shop_depth_min = 7
	st.route_shop_depth_max = 11
	st.route_shop_chance = 0.2
	st.route_shop_items = 3
	st.altar_life_cost = 10.0
	st.altar_gold_cost = 75
	st.altar_magick = 25.0
	# Morvath fights in his own round chamber (cycle C11, the Seal Chamber: docs/design/boss_arena.md for the radius,
	# docs/art/boss_chamber_spec.md for the plan): a circle of 12.5 m to the balustrade's inner face, so the paladin's
	# middle walks up to 12 m from the seal; he comes in at the mouth of the south stairs facing north, Morvath stands
	# on the seal; the camera keeps to a point 0.7 m from the seal toward it and moves off it at most 3 m
	st.boss_layout = _chamber()
	_place_breakables(st)
	_save(st, "res://data/stages/catacombs.tres")


# ---------- arenas (cycle C12) ----------

## What an arena is: its id and name, who draws it, its size, difficulty and place in the descent.
func _arena(l: RoomLayout, id: StringName, size: RoomLayout.Size, difficulty: int, depth: Vector2) -> void:
	l.id = id
	l.name_key = StringName("arena_" + String(id))
	l.look = id
	l.size_class = size
	l.difficulty = difficulty
	l.depth = depth


## PT-6 (Daniel, 2026-11-23): in every room the paladin comes in at the bottom of the screen (the south edge, nearest to the
## camera, facing north) and the doors are in the north (the far wall): his way in at `spawn`, the doors in the north wall
## (z = `north`) at each x of `xs`, in the order the doors are numbered. Tests: tests/test_pt6_rooms.gd.
func _gate(l: RoomLayout, spawn: Vector2, north: float, xs: Array) -> void:
	l.hero_spawn = spawn
	l.hero_facing = Vector2.UP
	l.exits = _doors(north, xs)


## PT-6b (Daniel, 2026-11-25): the doors in use are the first ones of the list, so the first two stand together in the
## north-east corner (4 m apart, off the east wall) and the third, when there is one, to their left. Tests/test_door_corner.gd.
func _guardian_doors(h: float) -> Array:
	var right := h - 5.0 if h < 11.5 else h - 4.5
	return [right - 7.4, right, right - 14.2]


## The doors of the north wall (z = `north`) at each x of `xs`.
func _doors(north: float, xs: Array, width := 4.0, medal := Vector2(-1.0, -1.0)) -> Array[ArenaExit]:
	var list: Array[ArenaExit] = []
	for x: float in xs:
		var e := ArenaExit.at_edge(Vector2(x, north), Vector2(0, 1), width)
		if medal.x >= 0.0:
			e.medal_up = medal.x
			e.sign_up = medal.y
		list.append(e)
	return list


## A polygon from flat pairs of numbers (x, z, x, z...).
func _poly(xz: Array) -> PackedVector2Array:
	var out := PackedVector2Array()
	for i in range(0, xz.size(), 2):
		out.append(Vector2(xz[i], xz[i + 1]))
	return out


func _rect(x0: float, x1: float, z0: float, z1: float) -> Rect2:
	return Rect2(x0, z0, x1 - x0, z1 - z0)


## Obstacles of the spec's tables. A piece blocks shots when its top passes 1.25 m (spec 0.3); up to 1.0 m a shot
## flies over it. Columns and tall pieces open in a stipple round the paladin (see_through).
func _column(x: float, z: float, top: float, r := 0.7) -> ArenaObstacle:
	return ArenaObstacle.circle(Vector2(x, z), r, &"column", top, top >= 1.25, true)


## RP-09: a cracked column that topples (the falling tree of the Hades II's Erebus): the first blow of the paladin
## cracks it, the second topples it away from him: a band of 1.2 x 5 m shown 0.6 s while it leans, 50 to each enemy on
## it (a whole skeleton almost), 0 to him; then a stump. Santuário (15, -6) and (-9, 6), Jardim A (4.5, 7), Cripta B
## (6.5, -6).
func _cracked(o: ArenaObstacle) -> ArenaObstacle:
	o.hits_to_fall = 2
	o.fall_length = 5.0
	o.fall_width = 1.2
	o.fall_time = 0.6
	o.fall_damage = 50.0
	return o


## A box lying along x (or along z when turned), of size w x d.
func _sarcophagus(x: float, z: float, w: float, d: float, top := 1.35, piece := &"sarcophagus", see := false) -> ArenaObstacle:
	return ArenaObstacle.box(Vector2(x, z), Vector2(w, d) * 0.5, 0.0, piece, top, top >= 1.25, see)


## A capsule of the spec (a low wall, a root) from a to b, `width` across: a box over it, its round ends taken square.
func _capsule(a: Vector2, b: Vector2, width: float, top: float, piece := &"block") -> ArenaObstacle:
	var d := b - a
	return ArenaObstacle.box((a + b) * 0.5, Vector2(d.length() * 0.5 + width * 0.5, width * 0.5), d.angle(), piece, top, top >= 1.25)


## A root along points (each leg a capsule), from inside the trunk at `trunk` (radius r) out to its tip.
func _root(trunk: Vector2, r: float, pts: Array, top := 0.6) -> Array[ArenaObstacle]:
	var out: Array[ArenaObstacle] = []
	var first: Vector2 = pts[0]
	var prev := trunk + (first - trunk).normalized() * (r - 0.5)
	for p: Vector2 in pts:
		out.append(_capsule(prev, p, 1.0, top, &"root"))
		prev = p
	return out


## RP-17: a low wall (0.9 m: bodies go round, shots go over) on an arc round `c` of radius `r` from `from` to `to`
## degrees (the plane's angle, x toward z), in `legs` straight legs.
func _low_arc(c: Vector2, r: float, from: float, to: float, legs: int) -> Array[ArenaObstacle]:
	var out: Array[ArenaObstacle] = []
	for k in legs:
		var a := c + Vector2.from_angle(deg_to_rad(lerpf(from, to, float(k) / legs))) * r
		var b := c + Vector2.from_angle(deg_to_rad(lerpf(from, to, float(k + 1) / legs))) * r
		out.append(_capsule(a, b, 0.5, 0.9))
	return out


## A fire bowl or lantern of a door, off the walkable floor: drawn, never blocking.
func _bowl(x: float, z: float) -> ArenaObstacle:
	var o := ArenaObstacle.circle(Vector2(x, z), 0.45, &"brazier", 1.2, false)
	o.blocks_move = false
	return o


## Daniel 2026-11-27: between two doors stands a piece. A statue on its plinth against the wall (bodies go round it, shots
## fly over); the standing brazier (a bronze bowl on a pedestal with a lit flame) of the same footprint.
func _statue(x: float, z: float, height := 3.2) -> ArenaObstacle:
	return ArenaObstacle.circle(Vector2(x, z), 0.75, &"statue", height, false)


func _stand_brazier(x: float, z: float) -> ArenaObstacle:
	return ArenaObstacle.circle(Vector2(x, z), 0.5, &"brazier", 1.6, false)


func _variant(obstacles: Array[ArenaObstacle], floor: FloorShape = null, late: Array[Rect2] = []) -> ArenaVariant:
	var v := ArenaVariant.new()
	v.obstacles = obstacles
	v.floor = floor
	v.late_spawns = late
	return v


## PT-25-10 (Daniel, 2026-11-25; the SWORN's step slab): a slab is 2 x 2 tiles of SLAB_TILE metres (2.5 m a side, was one block
## of 3 x 3), drawn with its cross joint (HazardPiece.plate); the whole slab strikes together, a short clear area.
const SLAB_TILE := 1.25
## RP-06 (H-2, docs/design/rooms_progression.md): slabs (now 2 x 2 tiles, see SLAB_TILE) that anyone stepping on arms (the paladin or an enemy:
## the steam trap of the Hades II), marked at rest; 1.2 s lighting from the edge to the middle (never under an enemy's
## wind-up), a strike of 0.25 s on whoever stands on it with the runes' numbers (A1: 10 to him, 60 to an enemy), 5 s
## before it may arm again, nothing in the first 3 s; asleep (drawn, never striking) before the descent reaches `from`.
## Each slab at least 6 m from the way in and off the doors' mouths (test_plates.gd).
func _plates(rects: Array[Rect2], from := 0.0, tiled := true) -> HazardDef:
	var h := HazardDef.new()
	h.kind = HazardDef.Kind.PLATES
	var slabs: Array[Rect2] = []
	for r in rects:
		# the 2 x 2 slab keeps the middle of the block it replaces
		slabs.append(Rect2(r.get_center() - Vector2.ONE * SLAB_TILE, Vector2.ONE * SLAB_TILE * 2.0) if tiled else r)
	h.plates = slabs
	# combat_cadence.md 9.4 (P0 with the 10): 1.2 s (was 1.0), an enemy may arm it under him while he is locked
	h.warn = 1.2
	h.fire = 0.25
	h.rearm = 5.0
	h.start_delay = 3.0
	h.from_progress = from
	h.hero_damage = HAZARD_HERO
	h.enemy_damage = 60.0
	return h


## The prologue's two rooms (2026-11-26, docs/art/ref/antessala_sala00_2026-11-26, the planta JSON of each is the truth of the
## collision; x lateral, z south, the room's middle at 0). Neither is a room of the graph (Prologue): the Antessala is the corridor of
## 14 x 48 m of a new save's guided descent (the lessons: a stream only the dash crosses, six breakables with nothing in them, the
## trap's slab with a way round on each side, the monumental door of 3 x 5.5 m); the Sala 00 the chamber of 18 x 16 m with the
## altar of the Blessing at its middle and the same door in the north. The art of both is a painting to be projected on this form
## (GP-8): piece, wall, step, door, altar, stream and slab matter here, not the finish.
const ANTE_HALF := Vector2(7.0, 24.0)
## GP-8 (2026-11-27): the painted Antessala (assets/rooms/painted/antessala.png) has its stream, slab and posts where gpt-image-2 drew
## them; the gameplay data sits exactly there (measured with PaintedHall.to_floor on the painting, see docs/art/painted_gpt/README.md):
## the stream 2.3 m north of where the planta had it, the slab 5.2 x 4.4 m (was 5 x 3) 2 m north, the eight posts at the painted ones.
const ANTE_STREAM := Rect2(-7.0, -10.7, 14.0, 2.6)
const ANTE_SLAB := Rect2(-2.6, -21.3, 5.2, 4.4)
## The posts of the Antessala, x, z (the painting's, clamped inside the mureta and the door wall).
const ANTE_POSTS: Array[Vector2] = [Vector2(-6.4, 16.8), Vector2(4.9, 16.5), Vector2(-6.4, 1.9), Vector2(5.4, 2.4),
	Vector2(-6.4, -15.6), Vector2(5.5, -15.8), Vector2(-6.2, -23.3), Vector2(6.2, -23.3)]
const SALA00_HALF := Vector2(9.0, 8.0)
const SALA00_PILLARS: Array[Vector2] = [Vector2(-5.1, -5.2), Vector2(5.2, -5.3), Vector2(-5.2, 2.9), Vector2(5.1, 2.8)]
const PRELUDE_DOOR := 3.0


func _prologue(st: StageDef) -> void:
	st.ante_layout = _ante_room()
	st.sala00_layout = _sala00_room()


func _ante_room() -> RoomLayout:
	const F := BreakablePiece.Form
	var l := RoomLayout.new()
	_arena(l, &"ante", RoomLayout.Size.LONG, 0, Vector2(-1.0, -1.0))
	l.floor = FloorShape.poly([FloorShape.box(_rect(-ANTE_HALF.x, ANTE_HALF.x, -ANTE_HALF.y, ANTE_HALF.y))])
	l.half = l.floor.extent()
	l.guardian = false
	var cols: Array[ArenaObstacle] = []
	for at in ANTE_POSTS:
		cols.append(_column(at.x, at.y, 3.2, 0.5))
	l.obstacles = cols
	_gate(l, Vector2(0.0, 20.0), -ANTE_HALF.y, [0.0])
	l.exits = _doors(-ANTE_HALF.y, [0.0], PRELUDE_DOOR)
	# the stream: the dodge crosses it, walking does not, it never hurts (gap_fall 0)
	l.gaps = [ANTE_STREAM] as Array[Rect2]
	l.gap_fall = 0.0
	# the slab of the trap: asleep until stepped on, warned 1.2 s, wide of it 4.5 m of floor on each side
	l.hazard = _plates([ANTE_SLAB], 0.0, false)
	# the six to break, nothing in them (Breakables gives nothing in any room): a vase, a crate, an urn, two barricades, a vase
	l.breakables = _breakable_groups([
		[[F.VASE, -4.8, 17.0, 0.8], [F.CRATE, 4.5, 16.0, 0.8], [F.URN, 5.3, 14.5, 0.8]],
		[[F.PLANK, -4.5, 8.0, 1.0]],
		[[F.PLANK, 4.5, 4.0, 1.0]],
		[[F.VASE, -5.0, 1.0, 0.8]],
	])
	# the camera follows him along the corridor (the point it looks at runs the length, the width held near the middle)
	l.cam_bounds = Rect2(-2.0, -21.0, 4.0, 42.0)
	return l


func _sala00_room() -> RoomLayout:
	var l := RoomLayout.new()
	_arena(l, &"sala00", RoomLayout.Size.SMALL, 0, Vector2(-1.0, -1.0))
	l.floor = FloorShape.poly([FloorShape.box(_rect(-SALA00_HALF.x, SALA00_HALF.x, -SALA00_HALF.y, SALA00_HALF.y))])
	l.half = l.floor.extent()
	l.guardian = false
	var cols: Array[ArenaObstacle] = []
	# GP-8: the four pillars where the painting has them (x, z), measured on the painting
	for at in SALA00_PILLARS:
		cols.append(_column(at.x, at.y, 3.6, 0.6))
	# the altar of the Blessing: 2.2 m square, 1.35 m high, used from its south side at (0, 1.7) and reached from any side
	cols.append(_piece(0.0, 0.0, 2.2, 2.2, 1.35, &"altar"))
	l.obstacles = cols
	_gate(l, Vector2(0.0, 6.0), -SALA00_HALF.y, [0.0])
	l.exits = _doors(-SALA00_HALF.y, [0.0], PRELUDE_DOOR)
	l.cam_target = Vector2(0.0, 0.5)
	l.cam_reach = 1.5
	return l


## PT-25-9, the optional crossings of the common rooms (docs/design/rooms_progression.md, "Travessias"): a patch of floor
## (`inner`) that a ring of water or rift GAP_BAND metres across (2 m: the dash is 5.6) shuts off from the rest, so only the
## dash gets on it, with a breakable group on it for the reward. Never on the way: no door, spawn, slab or the way in is
## inside or against it (tests/test_room_gaps.gd). `sides` says which sides of the ring are left out (against a wall).
const GAP_BAND := 2.0


func _ring(inner: Rect2, sides := "nsew") -> Array[Rect2]:
	var out: Array[Rect2] = []
	var b := GAP_BAND
	var wide := Rect2(inner.position.x - (b if "w" in sides else 0.0), inner.position.y, inner.size.x + (b if "w" in sides else 0.0)
		+ (b if "e" in sides else 0.0), inner.size.y)
	if "n" in sides:
		out.append(Rect2(wide.position.x, inner.position.y - b, wide.size.x, b))
	if "s" in sides:
		out.append(Rect2(wide.position.x, inner.end.y, wide.size.x, b))
	if "w" in sides:
		out.append(Rect2(inner.position.x - b, inner.position.y, b, inner.size.y))
	if "e" in sides:
		out.append(Rect2(inner.end.x, inner.position.y, b, inner.size.y))
	return out


## The Santuário's patch of the nave, west of the middle (the aisles' columns stand at z 6 and -6, the west spawn at x -14).
const SANCTUARY_ISLAND := Rect2(-10.0, -1.0, 3.0, 2.0)
## The Fendas' patch against the west wall (x -21), between the way in's side and the breakable crates of the south-west.
const RIFT_ISLAND := Rect2(-21.0, 3.5, 3.5, 3.0)


## RP-06: the slabs wake from the 4th room (progress 0.34); in the 2nd and 3rd they lie at rest and teach.
const PLATES_FROM := 0.34
## RD-02: the Crypt A's slabs wake early (the 2nd or 3rd room) with a longer warning, to teach before the 5th room.
const TEACH_FROM := 0.15
const TEACH_WARN := 1.5
## RD2-08: the slabs that teach arm by themselves every 6 s when the pack fights within 2.5 m of them, up to the 4th room
## (progress 0.25 plus a hair), with the same 1.5 s of warning.
const TEACH_CYCLE := 6.0
const TEACH_NEAR := 2.5
const TEACH_UNTIL := 0.26


func _teach(h: HazardDef) -> HazardDef:
	h.warn = TEACH_WARN
	h.auto_cycle = TEACH_CYCLE
	h.auto_near = TEACH_NEAR
	h.auto_until = TEACH_UNTIL
	return h
## A1 (Daniel, 2026-11-20: the game must get harder): every room hazard takes 10 from the paladin (the Hades II's own
## trap damage on the same 30 of life; was 7, RP-03 step 1), the edge that crumbles 7 (was 5). Enemies keep 60.
const HAZARD_HERO := 10.0
const CRUMBLE_HERO := 7.0


## RP-10 (H-1, docs/design/rooms_progression.md): the Jardim's outer roots strike. A band 3 m across along each root
## (its metre and one more each side), from the trunk's face to `tips`; the paladin lingering 0.5 s on it, or an enemy
## 0.2 s, wakes it: 1.2 s cracking (the runes' amber), a strike of 0.25 s with the runes' numbers (A1: 10 to him, 60
## to an enemy) that throws everyone on it 1 m off the root, 6 s before that root wakes again. Asleep before the 4th
## room, as the slabs. Each band 6 m or more from the way in (test_roots.gd).
func _roots(tips: Array) -> HazardDef:
	var h := _plates([], PLATES_FROM)
	h.plates = []
	var strips := PackedVector4Array()
	for pair: Array in tips:
		var first: Vector2 = pair[0]
		var tip: Vector2 = pair[1]
		var a := TRUNK + (first - TRUNK).normalized() * TRUNK_RADIUS
		strips.append(Vector4(a.x, a.y, tip.x, tip.y))
	h.strips = strips
	h.strip_width = 4.8  # RD2-04: 4 m (was 3), S-1: 4.8 m (the spawns' edge) and a touch wakes it (0.05 s): the roots struck nobody
	h.dwell = 0.5
	# an enemy only walks over it: a fifth of a second wakes it (second pass, the Game Director: the outer roots never woke)
	h.enemy_dwell = 0.05  # (S-1 tried 0.8, who lingers: it never woke in 12 descents, 0 strikes; back to a touch)
	h.warn = 1.8  # S-1: more warning (was 1.5) for the wider strip; the pack that walks past still wakes it at a touch
	h.rearm = 6.0
	h.push_out = 1.0
	h.plate_source = &"roots"
	return h


## AT-H2 (the atlas's prototype 2, Q-AT3 a, Q-AT4 a): the skeleton in a niche of the Cripta B's west wall (z -6.5,
## off the slits' bands, 1.5 m and more from the slabs, 6 m from the way in). A short strip of 2.2 x 2.2 m
## before the niche wakes with someone in it (him 0.3 s, an enemy 0.2 s): 1.2 s of warning (combat_cadence.md 9.4, P0
## with the 10), a grab of 0.25 s, 10 to him and 60 to an enemy, a pull of 1 m toward the niche without holding (his
## dodge stays his), 6 s before it wakes again. It never dies: a blow of the Emeth only sparks on it. From the 4th room.
const NICHE_AT := Vector2(-12.0, 4.6)  # 2026-11-27: south of the east slit band (the slit moved to x -11.3 in the door pass)
const NICHE_REACH := 2.2
func _niche() -> HazardDef:
	var h := _plates([], PLATES_FROM)
	h.plates = []
	h.strips = PackedVector4Array([Vector4(NICHE_AT.x, NICHE_AT.y, NICHE_AT.x + NICHE_REACH, NICHE_AT.y)])
	h.strip_width = NICHE_REACH
	h.dwell = 0.3
	h.enemy_dwell = 0.2
	h.warn = 1.2
	h.rearm = 6.0
	h.pull = 1.0
	h.sparks = PackedVector2Array([NICHE_AT + Vector2(0.15, 0.0)])
	h.plate_source = &"niche"
	return h


## AT-H3 (the atlas's prototype 3): the hostile plant, a new skin of RP-10 in the place of the Jardim B's stub root by
## the west wall, on the damp edge: a strip of 2.5 x 1.5 m from the plant out east; it wakes as the root does (him
## 0.5 s, an enemy 0.2 s), 1.2 s of warning (the leaves closing), a lash of 0.25 s, 10 to him and 60 to an enemy, a
## push of 1 m out of the strip, 6 s before it wakes again. The Emeth does not hurt it: a blow only sparks.
const PLANT_AT := Vector2(-16.6, -1.5)
func _plant() -> HazardDef:
	var h := _plates([], PLATES_FROM)
	h.plates = []
	h.strips = PackedVector4Array([Vector4(PLANT_AT.x, PLANT_AT.y, PLANT_AT.x + 3.5, PLANT_AT.y)])
	h.strip_width = 3.2  # RD2-04: 2.5 (was 1.5), S-1: 3.2 wide and 3.5 long, wakes at a touch (0.05 s), 1.8 s of warning
	h.dwell = 0.5
	h.enemy_dwell = 0.05
	h.warn = 1.8
	h.rearm = 6.0
	h.push_out = 1.0
	h.sparks = PackedVector2Array([PLANT_AT + Vector2(0.3, 0.0)])
	h.plate_source = &"plant"
	return h


## Cripta dos Esquecidos (spec section 2): small, closed, sarcophagi and columns as cover; 4 to 6 enemies, at most 2
## shooters, no priest.
## RP-16 (docs/design/rooms_progression.md): the Ossuary's arrow slits, on the north wall either side of the dividing
## wall (the east one clear of the north door's mouth): a low block of the wall, 0.5 x 0.6 m, 1.2 m high, stopping bodies
## and shots (the environment artist's slit with the chevron cut on its top replaces the placeholder block).
const SLIT_WEST := -5.3
const SLIT_EAST := -11.3  # PT-6b (2026-11-25): the door pair now stands east of the dividing wall, so both slits shoot from its west side


func _slit(x: float) -> ArenaObstacle:
	return ArenaObstacle.box(Vector2(x, -10.75), Vector2(0.25, 0.3), 0.0, &"bolt_slit", 1.2, true)


## A1, RP-20 (the stones of the torn vault; rooms_progression.md): squares of 2 m on `zones`, at most two warming up at
## once, one every 4 s after the first 3 s, half aimed at him when he stands in a zone; warned 1.2 s (combat_cadence.md
## 9.3: the square whole from the first frame, the shadow filling), 10 to him and 60 to each enemy under it, the rubble
## drawn only. Asleep before the 4th room (PLATES_FROM), as the slabs.
func _rocks(zones: Array[Rect2]) -> HazardDef:
	var h := HazardDef.new()
	h.kind = HazardDef.Kind.DROPS
	h.drop_zones = zones
	h.drop_size = 2.4  # RD2-04: 2.4 m, one every 3 s, 0.4 aimed at him (was 2 m, 4 s, half): more fall on the horde
	h.drop_count = 2
	h.drop_every = 3.0
	h.drop_aim = 0.4
	h.warn = 1.2
	h.fire = 0.25
	h.start_delay = 3.0
	h.from_progress = PLATES_FROM
	h.hero_damage = HAZARD_HERO
	h.enemy_damage = 60.0
	return h


## A1, RP-12 (the oil urn, the Hades II's barrel): a blow of his lights an urn; its ring of 2.5 m warns 1.3 s
## (combat_cadence.md 9.4, P0 with the 10) and blasts 10 to him and 80 to each enemy in it; the oil then runs down its
## channel at 3 m/s in stretches of 2 m, each warned 1.0 s before the flame, 5 to him and 40 to an enemy, burning 2 s.
## Once per urn per room; asleep before two thirds of the descent (URNS_FROM: the late Cripta).
const URNS_FROM := 0.67
func _urns(at: PackedVector2Array, flows: PackedVector4Array) -> HazardDef:
	var h := HazardDef.new()
	h.kind = HazardDef.Kind.URNS
	h.urns = at
	h.urn_flows = flows
	h.urn_radius = 2.5
	h.warn = 1.3
	h.fire = 0.25
	h.flow_width = 1.5
	h.flow_speed = 3.0
	h.flow_step = 2.0
	h.flow_lead = 1.0
	h.flow_hero = 5.0
	h.flow_enemy = 40.0
	h.burn = 2.0
	h.from_progress = URNS_FROM
	h.hero_damage = HAZARD_HERO
	h.enemy_damage = 80.0
	return h


## The oil urn's body (0.45 m, 1.0 m tall: the body goes round, a shot over it).
func _urn(p: Vector2) -> ArenaObstacle:
	return ArenaObstacle.circle(p, 0.45, &"oil_urn", 1.0, false)


## Where the Cripta A's two urns stand (at the foot of the east and north walls, far from the way in) and their channels
## (west along the middle row's north side, east along the north wall under the door's mouth).
## SL-02 (PT-25-10): the Cripta's doors are big and closed (CryptLook): a 3 m mouth each, 4.2 m apart so masonry stands
## between them; the medallion hangs in the doorway (its height, the height where its text starts).
const CRYPT_DOOR := 3.0
## The third door (in use only with three ways), moved from -2.0 to -3.0 so the oil urn at (-1.6, -10) leaves its mouth open.
const CRYPT_THIRD := -8.6
const CRYPT_DOORS := [6.6, -2.2, CRYPT_THIRD]
const CRYPT_MEDAL := Vector2(2.5, 0.8)
const CRYPT_URNS := [Vector2(11.2, -1.6), Vector2(1.0, -10.0)]
const CRYPT_OIL := [Vector4(10.2, -2.6, 4.2, -2.6), Vector4(1.8, -9.0, 4.6, -9.0)]


func _crypt() -> RoomLayout:
	var l := RoomLayout.new()
	_arena(l, &"crypt", RoomLayout.Size.SMALL, 1, Vector2(0.05, 1.0))
	l.floor = FloorShape.poly([_poly([-12, -10.5, 8.5, -10.5, 12, -7, 12, 10.5, -12, 10.5])])
	l.half = l.floor.extent()
	l.max_alive = Vector2i(4, 6)
	l.max_ranged = 2
	l.banned_roles = [&"area"]
	l.guardian = false
	# SL-02: the fire bowls in the north wall stand between the two doors and past the east one (the doors are 3 m wide now)
	var bowls: Array[ArenaObstacle] = [_bowl(3.1, -11.0), _bowl(-5.4, -11.0)]
	var bowls_b: Array[ArenaObstacle] = [_bowl(3.1, -11.0), _bowl(-5.4, -11.0)]
	var a: Array[ArenaObstacle] = [
		_sarcophagus(0.5, 0.0, 4.0, 2.0, 1.5),
		_column(-6.0, -5.6, 5.2, 0.65), _column(7.0, -5.6, 5.2, 0.65), _column(-5.5, 5.6, 5.2, 0.65),
		_sarcophagus(0.5, -5.6, 2.5, 1.2), _sarcophagus(4.0, 5.6, 2.5, 1.2), _sarcophagus(-11.4, -6.0, 1.2, 2.5),
		_capsule(Vector2(-12, 0), Vector2(-8, 0), 0.6, 0.9), _capsule(Vector2(12, 0.5), Vector2(8, 0.5), 0.6, 0.9),
		# RP-17: a low wall of 5.5 m south of the great tomb, parallel to it, between the middle row and the south one (the
		# body goes round, the shot goes over: 0.9 m)
		_capsule(Vector2(-3.5, 3.8), Vector2(2.0, 3.8), 0.5, 0.9),
		_urn(CRYPT_URNS[0]), _urn(CRYPT_URNS[1]),
	]
	a.append_array(bowls)
	l.obstacles = a
	# variant B, "Ossuary": a dividing wall from the north wall, the south half open (LR-06, the wall to 12 m, was tried
	# on 2026-11-20 and put back: with the robot the fight went south, 40 to 55% of his time in the south third)
	var b: Array[ArenaObstacle] = [
		_sarcophagus(0.5, -7.0, 0.8, 7.0, 3.2, &"block", true),
		_sarcophagus(-5.5, -9.25, 1.2, 2.5), _cracked(_column(6.5, -5.2, 5.2, 0.65)),
		_sarcophagus(-8.5, 6.5, 2.5, 1.2), _sarcophagus(7.0, 6.5, 2.5, 1.2),
		_capsule(Vector2(-12, -2.5), Vector2(-8, -2.5), 0.6, 0.9), _capsule(Vector2(12, 1.0), Vector2(8, 1.0), 0.6, 0.9),
		_slit(SLIT_WEST), _slit(SLIT_EAST),
	]
	b.append_array(bowls_b)
	# 2026-11-27 (room review): the floor of the south half fell in (a pit of 9 x 6 m in front of the dividing wall's end): the
	# fight is no more in the middle; it goes west or east of the pit, two lanes of 7 m, shots cross the pit, the crowd does not
	var pit := _poly([-4.5, -0.5, -2, -1.5, 2, -1.5, 4.5, -0.5, 4.5, 3.5, 2, 4.5, -2, 4.5, -4.5, 3.5])
	l.variants = [_variant(b, FloorShape.poly([l.floor.polys[0]], [pit]))]
	_gate(l, Vector2(-1.0, 8.6), -10.5, CRYPT_DOORS)
	l.exits = _doors(-10.5, CRYPT_DOORS, CRYPT_DOOR, CRYPT_MEDAL)
	# B: the dividing wall stands from the north wall at x 0.5, so two doors west of it and one east
	l.variants[0].exits = _doors(-10.5, CRYPT_DOORS, CRYPT_DOOR, CRYPT_MEDAL)
	l.spawns = [_rect(2, 7, -9.5, -7.5), _rect(8.5, 11.2, -4, -0.5), _rect(6.5, 11, 7, 9.5), _rect(-10, -7.5, -10, -8)]
	# the whole crypt fits the screen: the camera keeps to one point, as in the Seal Chamber
	l.cam_target = Vector2(1.0, 1.5)
	l.cam_reach = 2.5
	# RP-01: the rows of the crypt (the north one behind the columns, the middle round the great tomb, the south one
	# of the way in); B: either side of the dividing wall, and the open south
	_areas(l, ["north", _rect(-12, 12, -10.5, -3), "middle", _rect(-12, 12, -3, 3), "south", _rect(-12, 12, 3, 10.5)])
	_areas(l.variants[0], ["west_of_wall", _rect(-12, 0.5, -10.5, -3), "east_of_wall", _rect(0.5, 12, -10.5, -3),
		"south_open", _rect(-12, 12, -3, 10.5)])
	# RP-06: slabs by the walls, off the 4 m ways round the great tomb, off the spawns and 6 m or more from the way in
	# (its south-west corner is the way in: three corners and the east side). B: at the foot of the dividing wall, one
	# on each side of its end.
	l.hazard = _plates([_rect(-11.5, -8.5, 2.0, 5.0), _rect(8.0, 11.0, -7.5, -4.5), _rect(-7.6, -4.6, -3.6, -0.6),
		_rect(8.0, 11.0, 1.3, 4.3)], TEACH_FROM)
	# RD-02: the one hazard to learn before the 5th room: awake from the 2nd room (0.15), the warning 1.5 s (the enemies' 1.2 or more),
	# the same 10 and 60, so "the red warning hurts both sides" is seen by a child who falls early
	_teach(l.hazard)
	# A1, RP-12: the oil urns beside the slabs (late)
	l.hazard.also = _urns(PackedVector2Array(CRYPT_URNS), PackedVector4Array(CRYPT_OIL))
	l.hazard.also.also = _spikes([Vector2(-4.0, -4.5), Vector2(3.0, 1.6)], TEACH_FROM)
	l.variants[0].hazard = _plates([_rect(-3.4, -0.4, -6.3, -3.3), _rect(1.4, 4.4, -6.3, -3.3)], PLATES_FROM)
	# RP-16: an arrow slit on the north wall each side of the dividing wall, firing south down its corridor to the row of
	# the south sarcophagi; the slab on one side arms the slit of the other (the pack lured beyond the wall)
	l.variants[0].hazard.aims = PackedVector4Array([Vector4(SLIT_EAST, -10.4, SLIT_EAST, 2.4),
		Vector4(SLIT_WEST, -10.4, SLIT_WEST, 2.4)])
	# AT-H2: the niche's skeleton on the west wall, beside the slabs and the slits (from the 4th room)
	l.variants[0].hazard.also = _niche()
	l.variants[0].hazard.also.also = _spikes([Vector2(-8.0, -5.5), Vector2(8.5, -3.0)], TEACH_FROM)
	return l


## AT-Q1: what a blow breaks (BreakablePiece; art in docs/art/at_q0_breakables.md, places for AT-Q4 by the
## room-designer): groups of 2 to 4 against a wall or a balustrade, 1.5 m or more from a door, a use spot, a spawn, a
## slab that strikes and a hazard's band (tests/test_breakables.gd); never in the hub. First the Salão (vases, small
## urns, a cracked bench at the edges and at the foot of the balustrades, never on the axis nor the medallion) and the
## Crypt A and B (funeral ceramics, small vases, what is left of benches).
## Ofícios, Roteiro A (docs/design/oficios/): OF-05, the doors of material deeper (Q-OF3 a, the balance-designer's
## numbers: Prata from the 4th room, Memória past the guardian's layer), and OF-08, where the veins of Pedra Funda stand
## in the Fendas and the Runas (the floor point he extracts from, near an edge, 6.5 m or more from the way in, off the
## doors and the pieces, beside the way from the reward to a door; placeholder spots for the room-designer).
## SR-P5: where the relic may stand, in the corner far from the way in of the Cripta, the Fendas, the Jardim and the
## Santuário (off every door, hazard and spawn; test_hazard_sr.gd). The theme is to confirm with the Daniel.
const RELIC_SPOTS := {&"crypt": Vector2(-9.8, 7.9), &"rift": Vector2(-18.0, -11.0), &"garden": Vector2(14.5, 7.5),
	&"sanctuary": Vector2(-18.5, 10.5)}


func _relics(st: StageDef) -> void:
	for l in st.layouts:
		if RELIC_SPOTS.has(l.id):
			l.relic_spots = PackedVector2Array([RELIC_SPOTS[l.id]])


func _oficios_stage(st: StageDef) -> void:
	st.silver_from_depth = 4
	st.memory_after_guardian = true
	for l in st.layouts:
		match l.id:
			&"rift":
				l.gather_spots = PackedVector2Array([Vector2(3.5, 7.0)])
			&"runes":
				l.gather_spots = PackedVector2Array([Vector2(-5.0, -9.5)])


func _place_breakables(st: StageDef) -> void:
	const F := BreakablePiece.Form
	for l: RoomLayout in st.layouts:
		match l.id:
			&"hall":
				l.breakables = _breakable_groups([
					# AT-Q4: against the west balustrade (it stood 1.8 m off it)
					[[F.VASE, -13.8, -6.6, 0.7], [F.URN, -13.8, -5.6, 0.85], [F.OFFERING, -13.1, -6.1, 0.4]],
					[[F.URN, -12.8, -12.4, 0.8], [F.VASE, -11.9, -12.6, 0.6]],
					[[F.VASE, 14.2, 10.6, 0.6], [F.BENCH, 13.4, 12.2, 0.5]],
					[[F.VASE, 14.3, -2.6, 0.55], [F.OFFERING, 14.3, -1.8, 0.4], [F.URN, 13.6, -2.2, 0.75]],
				])
			&"crypt":
				var south_west := [[F.URN, -8.6, 9.8, 0.8], [F.VASE, -7.7, 9.9, 0.6], [F.OFFERING, -8.2, 9.1, 0.4]]
				var north_east := [[F.VASE, 9.0, -9.4, 0.6], [F.OFFERING, 8.6, -10.0, 0.4]]
				l.breakables = _breakable_groups([
					[[F.VASE, -11.2, -3.3, 0.6], [F.URN, -11.2, -2.4, 0.8], [F.OFFERING, -10.5, -2.9, 0.4]],
					south_west, north_east])
				# AT-Q4: B's west group moved off the niche's strip (AT-H2) to the foot of the north-west sarcophagus
				l.variants[0].breakables = _breakable_groups([
					[[F.URN, -11.2, 7.4, 0.8], [F.VASE, -11.2, 8.2, 0.6]],
					south_west, north_east])
			# AT-Q4 (room-designer): every other room, groups of 2 or 3 in its corners and against its walls (the far
			# ends from the way in first), 1.5 m and more from a door and its mark, the way in, the reward, a spawn, the
			# guardian's spawn (4 m), a use spot and every band or slab of its hazards (tests/test_breakable_places.gd);
			# materials by biome (docs/art/at_q0_breakables.md 3), one or two per group
			&"rift":
				var rift := [
					[[F.PLANK, -20.5, 9.75, 0.35], [F.CRATE, -19.7, 9.75, 0.7], [F.PLANK, -20.5, 8.95, 0.35]],
					[[F.CRATE, 10.0, 14.5, 0.7], [F.PLANK, 10.8, 14.5, 0.35]],
				]
				# PT-25-9: the last group on the patch against the west wall that only a dash reaches (RIFT_ISLAND)
				l.breakables = _breakable_groups(rift + [[[F.CRATE, -20.3, 4.3, 0.7], [F.PLANK, -19.5, 4.3, 0.35]]])
			&"garden":
				l.breakables = _breakable_groups([
					[[F.BRANCH, 16.5, -13.5, 0.8], [F.SAPLING, 15.7, -13.5, 0.4], [F.BRANCH, 16.5, -12.7, 0.6]],
					[[F.WATER, -16.5, 8.75, 0.7], [F.WATER, -15.7, 8.75, 0.6], [F.SAPLING, -16.5, 7.95, 0.4]],
					[[F.BRANCH, 10.75, 13.5, 0.8], [F.SAPLING, 9.95, 13.5, 0.4], [F.BRANCH, 10.75, 12.7, 0.35]],
				])
			&"sanctuary":
				l.breakables = _breakable_groups([
					[[F.URN, -21.5, -13.5, 0.85], [F.OFFERING, -20.7, -13.5, 0.4], [F.VASE, -21.5, -12.7, 0.6]],
					[[F.VASE, 21.5, 13.5, 0.6], [F.OFFERING, 20.7, 13.5, 0.4], [F.URN, 21.5, 12.7, 0.8]],
					[[F.OFFERING, -8.5, 13.5, 0.4], [F.VASE, -9.3, 13.5, 0.55]],
					# PT-25-9: on the patch only a dash reaches (SANCTUARY_ISLAND), in place of the north-west corner's second group
					[[F.URN, -9.2, -0.4, 0.85], [F.OFFERING, -8.4, 0.3, 0.4]],
				])
			# 2026-11-23: the guardians' houses, by the west wall either side of the way in, the north wall and the south-east
			&"knight_hall":
				l.breakables = _breakable_groups([
					[[F.VASE, -10.4, -4.4, 0.6], [F.URN, -10.4, -3.6, 0.8]],
					[[F.OFFERING, 10.4, 3.6, 0.4], [F.VASE, 10.4, 4.4, 0.6]],
					[[F.URN, -4.4, 10.4, 0.8], [F.OFFERING, -4.4, 9.6, 0.4]],
				])
			&"elder_hall":
				l.breakables = _breakable_groups([
					[[F.VASE, -11.4, -5.6, 0.6], [F.URN, -11.4, -4.8, 0.8]],
					[[F.OFFERING, -11.4, 5.0, 0.4], [F.VASE, -11.4, 5.8, 0.6]],
					[[F.URN, 11.4, 9.0, 0.8], [F.OFFERING, 11.4, 9.8, 0.4]],
				])
			&"bridge":
				var bridge := [
					[[F.CRATE, 27.5, 6.75, 0.7], [F.PLANK, 26.7, 6.75, 0.35], [F.CRATE, 27.5, 5.95, 0.6]],
				]
				var bridge_a := [[[F.PLANK, -27.5, 3.0, 0.35], [F.CRATE, -27.5, 3.8, 0.7]]]  # AT-PA3: off the bridges' line and the late spawn
				l.breakables = _breakable_groups(bridge + bridge_a + [
					[[F.CRATE, 2.0, -7.5, 0.6], [F.PLANK, 2.8, -7.5, 0.35], [F.PLANK, 2.0, -6.7, 0.35]],
					[[F.PLANK, -4.75, 7.5, 0.35], [F.CRATE, -3.95, 7.5, 0.7]]])
				# B (the zigzag, 2026-11-27): the decks lie on z 3 and z -3, so the groups stand 2.5 m off both lines: the north wall of
				# the west platform, in place of the landing's and of the west end's
				l.variants[0].breakables = _breakable_groups(bridge + [
					[[F.CRATE, -16.0, -8.3, 0.6], [F.PLANK, -15.2, -8.3, 0.35], [F.PLANK, -16.8, -8.3, 0.35]],
					[[F.PLANK, -13.0, 7.25, 0.35], [F.CRATE, -13.8, 7.25, 0.7]]])
			&"runes":
				# low boxes and bowls only (the runes are straight, D-29); AT-RA3, AT-RB3: never on a tile that arms, so
				# only on the quiet floor of the way in (RUNES_ENTRY: the west walls and the south wall west of the door)
				l.breakables = _breakable_groups([
					[[F.CRATE, -5.5, 11.3, 0.6], [F.OFFERING, -4.7, 11.3, 0.35], [F.CRATE, -5.5, 10.5, 0.5]],
					[[F.OFFERING, 4.7, 11.3, 0.4], [F.CRATE, 5.5, 11.3, 0.6], [F.OFFERING, 5.5, 10.5, 0.35]],
					[[F.CRATE, -3.8, 11.5, 0.5], [F.OFFERING, -3.0, 11.5, 0.35]],
				])
	# AT-Q4: the Provação (common ceramic, never on the stele) and the Altar (offerings away from the step and candles)
	st.trial_layout.breakables = _breakable_groups([
		[[F.VASE, 7.5, 3.25, 0.6], [F.OFFERING, 6.7, 3.25, 0.4], [F.VASE, 7.5, 4.05, 0.5]],
		[[F.OFFERING, -7.5, 3.0, 0.4], [F.VASE, -7.5, 2.2, 0.6]],
		[[F.VASE, 4.25, 6.5, 0.55], [F.OFFERING, 5.05, 6.5, 0.4], [F.OFFERING, 3.45, 6.5, 0.35]],
	])
	st.altar_layout.breakables = _breakable_groups([
		[[F.OFFERING, 8.5, 4.4, 0.4], [F.VASE, 7.7, 4.4, 0.6]],
		[[F.VASE, -8.5, 2.25, 0.55], [F.OFFERING, -7.9, 1.65, 0.4]],
		[[F.OFFERING, 6.75, 6.5, 0.4], [F.VASE, 7.55, 6.5, 0.6]],
	])
	# AT-CS3: the Câmara do Selo, only on the landing of the south stairs (bearing 203 to 211, beside the way in) and on
	# the far rim, 11 to 12 m from the seal, in the half away from the camera (north-west and north-east, out of the
	# front arc whose stone opens round him), past the ritual's ring of runes (6.5 m) and never in the door's gap;
	# they stop nothing, so every way out of his patterns stays (tests/test_boss_exits.gd, whole and broken)
	if st.boss_layout != null:
		st.boss_layout.breakables = _breakable_groups([
			[[F.URN, -4.53, 10.68, 0.75], [F.VASE, -4.99, 9.8, 0.55], [F.OFFERING, -6.03, 10.03, 0.4]],
			[[F.VASE, -9.38, -6.82, 0.6], [F.OFFERING, -8.43, -7.07, 0.4], [F.URN, -8.34, -8.06, 0.8]],
			[[F.URN, 8.34, -8.06, 0.75], [F.VASE, 8.63, -6.99, 0.55]],
		])


## Pieces from groups of [form, x, z, height].
func _breakable_groups(groups: Array) -> Array[BreakablePiece]:
	var out: Array[BreakablePiece] = []
	for g in groups.size():
		for d: Array in groups[g]:
			out.append(BreakablePiece.make(d[0], Vector2(d[1], d[2]), d[3], g))
	return out


## The rift of the hall of the rifts, cut by its two bridges (each bridge is the floor left between two pieces of it)
## or by one (variant B: the north bridge fell). It runs out through the north edge into the abyss outside.
const RIFT_NORTH := [-7, -17, -7, -12, 2, -12, 2, -17]
const RIFT_MIDDLE := [-7, -7, -7.8, -5, -6.6, -3, -7, -1, 2, -1, 1.6, -3, 2.8, -5, 2, -7]
const RIFT_SOUTH := [-7, 4, -7.6, 6, -6.4, 8, -5, 9.4, -2.5, 10, 0.3, 9.2, 1.6, 8, 2.6, 6, 2, 4]
const RIFT_FALLEN := [-7, -17, -7, -12, -7, -7, -7.8, -5, -6.6, -3, -7, -1, 2, -1, 1.6, -3, 2.8, -5, 2, -7, 2, -12, 2, -17]


## Salão das Fendas (spec section 3): big, a rift across 83% of its depth, two bridges of 5 m and a way round its
## south end; every door on the east platform. 6 to 8 enemies.
func _rift() -> RoomLayout:
	var l := RoomLayout.new()
	_arena(l, &"rift", RoomLayout.Size.LARGE, 1, Vector2(0.05, 1.0))
	var outline := _poly([-21, -12, -18, -15, 21, -15, 21, 9, 15, 15, -15, 15, -21, 10])
	l.floor = FloorShape.poly([outline], [_poly(RIFT_NORTH), _poly(RIFT_MIDDLE), _poly(RIFT_SOUTH),
		_poly([8, -6.5, 9.5, -8.2, 12.5, -8.4, 14.6, -6.2, 14, -2.6, 11, -1.8, 8.4, -3.4])])
	l.half = l.floor.extent()
	l.max_alive = Vector2i(6, 8)
	var bowls: Array[ArenaObstacle] = [_bowl(10.1, -15.6), _stand_brazier(16.0, -14.0)]
	var a: Array[ArenaObstacle] = [
		_sarcophagus(14.0, 7.0, 3.6, 1.0, 2.6, &"block", true), _column(7.5, 3.0, 3.8),
		_sarcophagus(-14.0, -5.5, 1.2, 2.5), _column(-13.0, 3.0, 3.2),
		# RP-05: low stumps (1.5 m, they stop shots): one each side of the rift between the two bridge heads, off their
		# line (a foothold for the crossing), and one in the east fight, where he spends half the room (one each side
		# blocked 6% of the shots (4% before), the three 11%; the open hall stays the most open room)
		_column(-10.5, -4.0, 1.5, 0.6), _column(5.5, -4.0, 1.5, 0.6), _column(12.5, 1.0, 1.5, 0.6),
	]
	a.append_array(bowls)
	l.obstacles = a
	var b: Array[ArenaObstacle] = [
		_sarcophagus(14.0, 7.0, 3.6, 1.0, 2.6, &"block", true), _column(8.0, -4.0, 3.8), _column(13.0, -8.5, 3.4),
		_column(15.0, -1.0, 2.9), _sarcophagus(-13.5, -10.5, 2.5, 1.2),
	]
	b.append_array(bowls)
	var fallen := FloorShape.poly([outline], [_poly(RIFT_FALLEN), _poly(RIFT_SOUTH),
		_poly([-17.5, -3, -16, -5.2, -13, -5.6, -11.3, -3.5, -11.6, -0.4, -14, 0.6, -16.6, -0.6])])
	# RP-08: the rift breathes along its brink where the fight is (RIFT_BREATH: the east brink by the south bridge and
	# the south way) and on the west of the middle hole (B: along the fallen bridge), off the bridge heads and the spawns
	l.hazard = _breath(RIFT_BREATH + [_rect(-10.8, -8.0, -7, -1)], RIFT_BREATH_PUSH + [Vector2(-BREATH_PUSH, 0)])
	l.variants = [_variant(b, fallen, [_rect(-19.5, -15.5, -12, -7)])]
	# B (the north bridge fallen): its west stretch along the fallen bridge's brink, away from the second hole
	# RD-02: the east slabs wake early with the long warning, as the Crypt A's (Fendas A comes in the 2nd to 4th rooms)
	l.hazard.also = _sag([_rect(14, 19, -11.5, -8.8), _rect(13, 17, 8.2, 12)], TEACH_FROM)
	_teach(l.hazard.also)
	l.variants[0].hazard = _breath(RIFT_BREATH + [_rect(-10.0, -7.2, -13, -7)], RIFT_BREATH_PUSH + [Vector2(-BREATH_PUSH, 0)])
	# A1, RP-20: stones from the vault over the east platform's fight (north of the columns, off the north door, and the
	# middle of the platform), beside the breath (which does not hurt)
	l.variants[0].hazard.also = _rocks([_rect(3.0, 9.5, -14.5, -8.0), _rect(4.0, 11.0, -1.0, 5.0)])
	# RP-07 (the room-designer's bands, by the damage measured): A early to the middle, B from the 4th room on
	l.variant_depth = Vector2(0.1, 0.6)
	l.variants[0].depth = Vector2(0.34, 1.0)
	_gate(l, Vector2(-9.0, 12.6), -15.0, [13.0, 19.0, 7.2])
	l.gaps = _ring(RIFT_ISLAND, "nse")
	# nobody rises on a bridge or in the south way; the first wave across the rift, the west zone from the second
	# PM-3: the paladin stood 71% of the time in the east (he comes in at the south-west, but the early zones were all east and
	# the far side drew the packs to him there): the packs rise in the west (one zone: the west floor is all gaps but the north-west) and the east (three, the small south-east bridge head among them); the whole bridge head and the west wall for the late ones; no far-side draw (the pack rises where the fight is)
	l.spawns = [_rect(-17, -11, -13, -9), _rect(5, 11, -13.5, -10.5), _rect(16, 19.5, -8, -2), _rect(6, 10, 8, 12)]
	l.late_spawns = [_rect(5, 11, 7, 12)]  # integration: the west wall zones sat on the stream gaps and on unreached floor (test_arenas, test_room_gaps)
	l.far_spawn = 0.0
	l.cam_bounds = _rect(-6, 7, -4, 5)
	# RP-01: which bridge, or the way round the south
	_areas(l, ["bridge_n", _rect(-7, 2, -12, -7), "bridge_s", _rect(-7, 2, -1, 4), "south_way", _rect(-8, 3, 9, 15),
		"west", _rect(-21, -7, -15, 15), "east", _rect(2, 21, -15, 15)])
	return l


## Jardim das Raízes Mortas (spec section 4): a petrified tree off the middle (its trunk stops bodies and shots),
## low roots that stop bodies only, sarcophagi and broken columns. 6 to 8 enemies.
const TRUNK := Vector2(-8.0, -5.0)
const TRUNK_RADIUS := 3.5


const GARDEN_TRAPS := [[Vector2(17.0, -7.0), Vector2(-1, 0), 12.0], [Vector2(-0.5, 14.0), Vector2(0, -1), 10.0]]


func _garden() -> RoomLayout:
	var l := RoomLayout.new()
	_arena(l, &"garden", RoomLayout.Size.MEDIUM, 1, Vector2(0.05, 1.0))
	l.floor = FloorShape.poly([_poly([-17, -10, -13, -14, 17, -14, 17, 8, 11, 14, -12, 14, -17, 9])])
	l.half = l.floor.extent()
	l.max_alive = Vector2i(6, 8)
	var trunk := ArenaObstacle.circle(TRUNK, TRUNK_RADIUS, &"trunk", 4.5, true, true)
	var bowls: Array[ArenaObstacle] = [_bowl(2.9, -14.6)]
	var a: Array[ArenaObstacle] = [trunk]
	for pts: Array in [[Vector2(-4.5, -7.0), Vector2(-2.5, -7.7), Vector2(-0.4, -8.1), Vector2(1.8, -8.1)],
			[Vector2(-5.2, -2.2), Vector2(-3.5, -0.8), Vector2(-1.6, 0.3), Vector2(0.3, 1.2)],
			[Vector2(-10.0, -1.5), Vector2(-10.8, 0.1), Vector2(-11.4, 1.9), Vector2(-11.9, 3.6)],
			[Vector2(-11.5, -7.0), Vector2(-12.8, -7.8)]]:
		a.append_array(_root(TRUNK, TRUNK_RADIUS, pts))
	a.append_array([_sarcophagus(7.5, -5.0, 2.5, 1.2), _sarcophagus(-16.4, -1.5, 1.2, 2.5),
		_capsule(Vector2(9, 5), Vector2(13, 5), 0.8, 1.0), _cracked(_column(4.5, 7.0, 3.6))])
	# RP-17: the tree's courtyard: two low broken walls on an arc 6 m from the trunk, east and south, the three roots
	# that cross it (north-east, south-east, south-west) the three ways in, 4.5 m each with the root in its middle
	a.append_array(_low_arc(TRUNK, 6.0, -6.0, 21.0, 1))
	a.append_array(_low_arc(TRUNK, 6.0, 64.0, 98.0, 2))
	a.append_array(bowls)
	l.obstacles = a
	# RP-10: the north root and the west one (cut short of the way in), the two that keep off the middle
	l.hazard = _roots([[Vector2(-4.5, -7.0), Vector2(1.8, -8.1)], [Vector2(-10.0, -1.5), Vector2(-11.4, 1.9)]])
	# SR-P1: two wall traps in the east and south fields where the fight goes (from 0.3 of the descent, every 6 s): the
	# east wall's, firing west along y -7 between the north door and the east door; the south wall's, firing north at x -0.5
	l.hazard.also = _trap(GARDEN_TRAPS, 0.3, 5.0, 4.0)
	# RD-02: one slab to learn in the east field (awake from the 2nd room, warning 1.5 s), off the traps' lines and the spawns
	l.hazard.also.also = _plates([_rect(5.5, 10.5, -2.5, 2.5)], TEACH_FROM)
	_teach(l.hazard.also.also)
	l.obstacles.append_array(_trap_blocks(GARDEN_TRAPS))
	var b: Array[ArenaObstacle] = [trunk]
	for pts: Array in [[Vector2(-4.1, -5.7), Vector2(-2.4, -5.8), Vector2(-0.7, -5.7), Vector2(0.9, -5.4)],
			[Vector2(-6.6, -1.2), Vector2(-6.2, 0.7), Vector2(-6.1, 2.7), Vector2(-6.3, 4.7)],
			[Vector2(-11.5, -3.0), Vector2(-12.2, -2.5)]]:
		b.append_array(_root(TRUNK, TRUNK_RADIUS, pts))
	b.append_array([_sarcophagus(11.5, -6.0, 1.2, 2.5), _sarcophagus(4.5, 8.5, 2.5, 1.2), _column(12.0, 3.0, 3.4), _column(-12.5, 4.0, 3.0)])
	# 2026-11-27 (room review): the east field is a terrace: a retaining wall (0.9 m: bodies stop, shots go over) along x 8 with
	# two stairs (z -4.5 to -1.5 and 3 to 6), so the pack and the paladin take the stairs, never the straight line
	for seg: Array in [[-9.0, -4.5], [-1.5, 3.0], [6.0, 11.0]]:
		b.append(_capsule(Vector2(8.0, seg[0]), Vector2(8.0, seg[1]), 0.7, 0.9))
	b.append_array(bowls)
	l.variants = [_variant(b)]
	# RP-10: B's west root (cut short of the way in) and the stub by the west wall; the north one comes near the middle
	# AT-H3: the stub by the west wall became the hostile plant (its own hazard beside the root)
	l.variants[0].hazard = _roots([[Vector2(-6.6, -1.2), Vector2(-6.2, 3.6)]])
	l.variants[0].hazard.also = _plant()
	_gate(l, Vector2(-9.0, 11.6), -14.0, [6.6, 13.4, -0.8])
	# (LR-04, the north group north of the trunk, x -12 to -5, was tried on 2026-11-20 and put back: tree_shade stayed 5
	# to 7%, the trunk stopped 0.1 shot a room)
	l.spawns = [_rect(6, 12, -12.5, -9.5), _rect(13, 16, -4, 3), _rect(-6, 0, -13.2, -10.5), _rect(-2, 6, 9, 12.5)]
	l.late_spawns = [_rect(-15, -13, -6, -3.5)]
	l.cam_bounds = _rect(-3, 4, -2, 3)
	# RP-01: the tree as a shield (12 m round the trunk), the open field east, the rest
	_areas(l, ["tree_shade", _rect(TRUNK.x - 6, TRUNK.x + 6, TRUNK.y - 6, TRUNK.y + 6), "east_field", _rect(2, 17, -14, 14),
		"rest", _rect(-17, 2, -14, 14)])
	return l


## The Seal Chamber (cycle C11). Every number is the spec's (docs/art/boss_chamber_spec.md, sections 2 and 4).
func _chamber() -> RoomLayout:
	var c := RoomLayout.new()
	c.chamber = true
	# named only for the run's log (QW-011); its look and its name stay the chamber's own
	c.id = &"seal_chamber"
	c.floor = FloorShape.circle(12.5)
	c.half = Vector2(12.5, 12.5)
	c.hero_spawn = Vector2(-0.9, 10.4)
	c.hero_facing = Vector2.UP
	c.boss_spawn = Vector2(0.0, -1.2)
	c.cam_target = Vector2(0.40, 0.57)
	c.cam_reach = 3.0
	return c


func _save(r: Resource, path: String) -> void:
	var err := ResourceSaver.save(r, path)
	if err != OK:
		push_error("could not save %s: %d" % [path, err])


# ---------- bosses ----------

## Morvath's necromancy and the souls he throws: a cold, pale spectral green (never Emeth's warm crystal green).
const SPECTRAL := Color(0.38, 1.55, 1.1)


## One entry of the Cavaleiro's priority list (AttackList): id, life gate, cooldown, first use, distance.
func _kmove(id: StringName, props: Dictionary) -> KnightMove:
	var m := KnightMove.new()
	m.id = id
	for k: String in props:
		m.set(k, props[k])
	return m


func _attack(id: StringName, props: Dictionary) -> BossAttack:
	var a := BossAttack.new()
	a.id = id
	for k: String in props:
		a.set(k, props[k])
	return a


## Morvath, the first boss, in four phases (Daniel's request of 2026-11-15; docs/design/morvath_boss_fight.md):
## 1 "O Despertar" (100 to 66%): the Sepulchral Scythe and the Blades of the Souls, the dash to close in.
## 2 "O Ritual dos Mortos" (66 to 33%): the ritual behind a shield (the only time he cannot be hurt), then
##   eruptions and a few summons. 3 "A Maldicao dos Condenados" (33 to 15%): the curse. 4 "O Ultimo Suspiro"
##   (15 to 0%): the blades become the Storm of the Six Souls, shorter rests.
## Distances from his middle (he is 1.4 m wide of radius, the paladin walks 6.75 m/s and dodges 5.6 m in 0.2 s):
## every warning leaves time to walk out of it (tests/test_boss.gd proves each).
func _bosses() -> void:
	var b := BossDef.new()
	b.id = &"morvath"
	b.enemy = &"morvath"
	b.thresholds = PackedFloat32Array([0.66, 0.33, 0.15])
	b.ritual_phase = 2
	# E2 (Daniel's test of E1: "Morvath is too easy"; docs/qa/e2_morvath.md): shorter rests, the last phase most
	b.rest = PackedFloat32Array([0.9, 0.8, 0.5, 0.35])
	# 2026-11-23 (Daniel: "ataca mais rapido"): his wind-ups 15% shorter in the first two phases, 18% and 20% in the last two (it was
	# 1, 1, 0.95, 0.9); the quickest, the second reap (0.5 s), stays at 0.4 s
	b.windup_scale = PackedFloat32Array([0.85, 0.85, 0.82, 0.8])
	b.final_light_phase = 4
	b.adds_cap = PackedInt32Array([0, 3, 3, 3])
	# E2: what rises when a summon is laid over another attack, and the circles of eruptions laid over one
	b.layer_raise = [&"skeleton", &"mage"] as Array[StringName]
	b.layer_eruption_count = Vector2i(2, 2)
	# each phase opens on its own pattern, right after the roar: the ritual (by itself), the curse, the storm
	b.phase_openers = [&"", &"", &"curse", &"barrage"] as Array[StringName]
	# the curse and the storm are opened from the middle of the floor, as the ritual is (cycle C11)
	b.center_phases = PackedInt32Array([3, 4])
	var numbers := {
		"roar_time": 1.6, "roar_push": 4.0, "near": 6.0, "far": 10.0, "still_after": 0.8, "lead": 0.45,
		"summon_raise": [&"mage", &"mage"] as Array[StringName], "summon_windup": 1.1,
		# reinforcements rise one by one (a rune, the energy, the body, 0.45 s apart), 20 at most in the whole fight
		"adds_total_cap": 14, "rise_stagger": 0.45,
		# where they rise (cycle C11, fitted to the chamber's 12.5 m: the ritual's ring of 6.5 around the seal leaves
		# 5.5 m of floor outside it to fight in; summons 5 m around him, never within 4 m of the paladin)
		"gap_min": 0.0, "gap_max": 0.3, "gap_min0": 0.0, "gap_max0": 0.1,
		"summon_ring": 5.0, "summon_clear": 4.0, "ritual_ring": 6.5,
		# the crescents come undone 0.3 m past the floor's edge; the charge stops at the edge and needs 8 m free
		"soul_overrun": 0.3, "dash_min_free": 8.0,
		# a combination waits for nothing of the first to be left, then rests only this long
		"chain_rest": 0.35,
		# the Sepulchral Scythe: half a circle 5 m from his middle (3.6 m past his body), 0.8 s to read it, 1 s to punish
		"scythe_reach": 5.0, "scythe_degrees": 180.0, "scythe_windup": 0.8, "scythe_recovery": 0.7, "scythe_damage": 15.0, "scythe_approach": 0.7,
		# C19-3, the Double Reap (Q-09 a; Hades II's Hecate: right 0.85 / 0.4 / 0.35, at once left 0.5 / 0.5 / 2.2): two
		# sweeps of 150 degrees and 4.5 m close in, the second born where the paladin is as the first ends, then 2.2 s
		"reap_reach": 4.5, "reap_degrees": 150.0, "reap_windup": 0.85, "reap_active": 0.4, "reap_pause": 0.35, "reap2_windup": 0.5,
		"reap2_active": 0.5, "reap_recovery": 1.1, "reap_damage": 12.0,
		# the Blades of the Souls: two crescents 3 m wide, 38 degrees apart, across the hall at 11 m/s
		"blade_spread": 38.0, "blade_speed": 11.0, "blade_width": 3.0, "blade_range": 26.0, "blade_windup": 0.7, "blade_recovery": 0.6, "blade_damage": 10.0,
		# C17, Q-09 (b): phase 1 was the scythe in a loop with him close (91% scythe over 3 seeds): the Blades come at
		# any distance, a step back first when he is within 4 m
		"blade_step": 2.0, "blade_step_within": 4.0, "blade_step_time": 0.25,
		# the Storm of the Six Souls: six crescents all around (never two closer than 48 degrees), a second wave turned 30
		"storm_count": 6, "storm_jitter": 7.0, "storm_min_gap": 48.0, "storm_waves": 3, "storm_turn": 30.0, "storm_gap": 1.0, "storm_windup": 0.9,
		"storm_recovery": 0.8, "storm_damage": 15.0, "storm_stagger": 0.08,
		# Daniel 2026-11-23 (docs/reference/gameplay.md, Morvath): no walking after the paladin, no marks on the floor but the eruptions
		# (the "!" announces the rest); the last phases lean on the far attacks and the storm's fan becomes the barrage, a machine gun
		# that follows the paladin: crescents one after the other (by phase), each aimed at where he stands as it leaves
		"shots_gate": 7.0,
		"barrage_count": PackedFloat32Array([0.0, 0.0, 8.0, 12.0]), "barrage_gap": PackedFloat32Array([0.25, 0.25, 0.26, 0.2]),
		"barrage_windup": 0.7, "barrage_speed": 12.0, "barrage_width": 1.3, "barrage_damage": 7.0, "barrage_recovery": 0.6, "barrage_turn": 220.0,
		# the Sepulchral Eruptions: 2 or 3 circles of 4 m (2 m until Daniel's test of 2026-11-16: too easy to step out of; the warning 0.9 to 1.2 s so they can still be walked out of), one on the paladin, the lane to the middle of the hall kept free
		"eruption_radius": 4.0, "eruption_delay": 1.35, "eruption_count": Vector2i(2, 3), "eruption_lane": 120.0, "eruption_sequences": 2,
		"eruption_gap": 1.0, "eruption_damage": 15.0, "eruption_recovery": 0.6,
		# the ritual: at most 20 s behind the shield, 2 soldiers and 2 casters, never more than 6 of his standing
		"ritual_time": 20.0, "ritual_raise": [&"skeleton", &"skeleton", &"mage", &"mage"] as Array[StringName], "ritual_cap": 5,
		"ritual_reinforce_every": 9.0, "ritual_reinforce": [&"skeleton", &"mage"] as Array[StringName], "ritual_eruption_every": 3.5,
		"ritual_stun": 2.0, "shield_radius": 2.9,
		# C1d, the Condutores: each fallen caster of the ritual cuts 5 s off it (both fallen: the shield opens at 10 s)
		"ritual_conductors": [&"mage"] as Array[StringName], "ritual_shorten": 5.0,
		# the curse: a slow bolt that follows a little (75 degrees a second for 1.4 s), 3 s of 30% slower walking and
		# no special, then 2 s immune
		"curse_windup": 0.8, "curse_speed": 7.0, "curse_turn": 55.0, "curse_homing": 0.9, "curse_life": 4.0, "curse_radius": 0.55,
		"curse_damage": 10.0, "curse_time": 3.0, "curse_slow": 0.3, "curse_immunity": 2.0, "curse_recovery": 0.6,
		# C1d, the Corte do rastro: the paladin's wave undoes the bolt, the Brado takes it with its curse
		"curse_cut": true,
		"dash_length": 16.0, "dash_time": 0.42, "dash_windup": 0.8, "dash_width": 2.8, "dash_damage": 15.0, "dash_recovery": 0.6,
		"stagger_from_phase": 3, "stagger_hits": 3, "stagger_forget": 4.0, "stagger_time": 2.6,
		# C1d, the Postura (chefes_c1d.md): from phase 1, a bar of 900 over his life worn by the BUTTON of each blow (Feel.poise_weights
		# times posture_mult 0.5: attack 14 blows, special/Brado 3.3, Investida 4, ultimate 2); broken, he kneels 2.6 s taking +40%
		# C1d, the Ruptura (phase 4, 12 s in, then every 25 s): the floor warns 1.5 s, 16 damage, then 3 s exposed (x1.4, no Postura)
		"rupture_every": 25.0, "rupture_first": 12.0, "rupture_phase": 4, "rupture_windup": 1.5, "rupture_damage": 15.0, "rupture_window": 3.0,
		"posture": 1300.0, "posture_stun": 3.5, "posture_growth": POISE_GROWTH, "posture_vuln": 0.3, "posture_idle": 5.0, "posture_mult": 0.17,
	}
	for k: String in numbers:
		b.set(k, numbers[k])
	b.attacks = [
		# near (under `near`) he prefers the scythe and the reap; far (over `far`) the far attacks; he never chases (Daniel 2026-11-23).
		# The scythe walks in a little (scythe_approach) so it only comes up to max_dist; the last phases (late_*) lean on the far ones
		_attack(&"scythe", {"weight": 3.0, "late_from_phase": 4, "late_weight": 1.6, "max_dist": 8.0, "near_bias": 2.2, "far_bias": 0.35, "streak": 2}),
		_attack(&"reap", {"weight": 3.5, "late_from_phase": 4, "late_weight": 2.0, "max_dist": 6.0, "near_bias": 2.2, "streak": 1}),
		# far: the blades of the first two phases, in the others the barrage
		_attack(&"blades", {"weight": 2.0, "until_phase": 2, "cooldown": 3.0, "min_dist": 0.0, "near_bias": 0.5, "far_bias": 2.2}),
		_attack(&"barrage", {"from_phase": 3, "weight": 1.6, "late_from_phase": 4, "late_weight": 3.2, "cooldown": 3.0, "near_bias": 0.5, "far_bias": 1.6}),
		# the paladin keeps away: the dash closes in (seldom, never a chase)
		_attack(&"dash", {"weight": 0.7, "cooldown": 7.0, "min_dist": 9.0, "far_bias": 1.5}),
		_attack(&"eruptions", {"from_phase": 2, "weight": 1.4, "cooldown": 5.0, "still_bias": 3.0, "then": &"scythe", "then_chance": 0.6, "then_from_phase": 4}),
		# his dead (the casters) rise when the paladin is away
		_attack(&"summon", {"from_phase": 2, "weight": 0.8, "late_from_phase": 3, "late_weight": 1.3, "cooldown": 9.0, "near_bias": 0.4, "far_bias": 2.0}),
		_attack(&"curse", {"from_phase": 3, "weight": 1.6, "late_from_phase": 4, "late_weight": 2.2, "cooldown": 6.0, "min_dist": 3.0, "near_bias": 0.6, "far_bias": 1.5}),
	]
	for i in b.rest.size():
		b.rest[i] *= BOSS_REST
	for at: BossAttack in b.attacks:
		at.cooldown *= BOSS_COOLDOWN
	_save(b, "res://data/bosses/morvath.tres")


# ---------- feel ----------

## How the game feels in the hands (scripts/core/feel.gd). The F1 panel tunes these live; copy good values here.
## Movement, dash and camera of Hades II at our scale (80 of its units to a meter): walk 540, dash 450 in 0.2 s
## with 16 frames of safety and 0.74 s to come back, sprint 1.65 times the walk; a near-flat camera 30 degrees above
## the floor (its circles are drawn half as tall as wide) showing about 28 m across (ours a little farther: about 32 m).
func _feel() -> void:
	var f := Feel.new()
	f.poise_weights = POISE_WEIGHTS
	f.speed = 540.0 / U
	f.dodge_time = 0.2
	# the roll slows to half by its end, so it covers 0.75 * speed * time
	f.dodge_speed = 450.0 / U / 0.2 / 0.75
	# C1e: safe on the whole path (0.2 s) and not a frame more; the roll is the main defence, short and quick
	f.dodge_iframes = f.dodge_time
	# the close dodge: a blow within 0.15 s of the start gives 0.25 s of slow motion (0.4 speed), once in 2 s
	f.close_window = 0.15
	f.close_cooldown = 2.0
	f.close_fraction = 0.4
	f.close_slow = 0.25
	# PT-1: the "!" over a blow with no mark on the floor lights this long before it lands
	f.bang_lead = 0.45
	# (the dodge charges, 1, and their 0.8 s to come back are the hero's: _hero)
	f.sprint_scale = 890.0 / 540.0
	f.move_scale_light = 0.0
	f.move_scale_heavy = 0.0
	f.move_scale_finisher = 0.0
	# the frame of Daniel's reference image of the catacomb hall (2026-11-14): high and turned, the square room seen
	# as a diamond from its south-east corner (docs/art/arena_reference.md); cycle 5 brings it 10% closer (60 to 54,
	# Daniel's "discreet camera adjustments") so the figures read the size of the painting's; --showcase keeps 60
	f.cam_distance = 54.0
	# the near camera of the options (Daniel, 2026-11-19): Hades II's Erebus rooms are as big as ours in meters, but its
	# ZoomFraction about 0.85 shows about 28 m across (ours 41 at 54) and the room is bigger than the screen; 37 m shows
	# the same 28 m (CamRig.near, the save's "camera"; the default since LR-01; the far 54 stays in the options)
	f.cam_distance_near = 37.0
	f.cam_pitch = 30.0
	f.cam_yaw = 35.0
	f.cam_fov = 24.0
	f.cam_lead = 1.2
	f.cam_smooth = 9.0
	f.hit_stop_scale = 1.0
	f.glint_scale = 1.0
	f.shake_scale = 1.0
	f.kick_scale = 1.0
	# the black and white impact frame only on an Omega that lands and on the blow that ends a boss's phase, at most
	# one every 10 s (decision D-08 of cycle 10: it hid the boss's warnings 24 times in a 2 minute fight)
	f.impact_frame = 0.05
	f.impact_frame_every = 10.0
	# a blow taken (BUG-007, cycle 10): a short red at the edges only, half of it under 10 damage, a small colour
	# split only on the heavy ones; under the curse a violet edge (alpha 0.2 for 0.2 s) and no split
	f.hurt_tint = 0.42
	f.hurt_tint_time = 0.22
	f.hurt_tint_heavy = 10.0
	f.hurt_tint_small = 0.5
	f.hurt_split = 0.35
	f.curse_tint = 0.2
	f.curse_tint_time = 0.2
	f.outline = 0.5
	# effects a little quieter after the first test ("everything is too big"): dimmer cut, ink gone sooner
	f.slash_intensity = 1.7
	f.slash_sweep_time = 0.05  # C12d (VX-01): the head sweeps in 3 frames with the blade (Fx.SLASH_LEAD the first)
	f.ink_opacity = 0.85
	f.ink_life = 2.0
	_save(f, Feel.PATH)


# ---------- the hero ----------

const HERO_DIR := "res://data/heroes/"
const TALENT_DIR := "res://data/talents/warrior/"
const ULT_DIR := "res://data/ultimates/"
const MASTERY_PATH := "res://data/heroes/warrior_mastery.tres"
## The Maga's own copy of the numbers (maga_m2.md 1): the two may drift apart in the balance without touching each other.
const MAGA_MASTERY_PATH := "res://data/heroes/maga_mastery.tres"


## The Warrior's Mastery (guardian_spec.md 7; warrior_spec.md 4.4): 20 levels, 40 + 10 (n - 1) XP from n to n + 1
## (2470 in all), Devotion 5 + level; XP by source and first times; older saves get 40 a run and 60 a win once, up to
## level 5 (D-57).
func _mastery() -> void:
	var m := MasteryCurve.new()
	var numbers := {
		"max_level": 20, "xp_base": 40, "xp_step": 10, "devotion_base": 5,
		"room_xp": 10, "guardian_xp": 25, "phase_xp": 10, "phase_max": 4, "victory_xp": 50,
		"first_boon_xp": 2, "first_elo_xp": 10, "first_psalm_xp": 25, "first_guardian_xp": 25, "first_victory_xp": 100,
		"retro_run_xp": 40, "retro_win_xp": 60, "retro_max_level": 5,
	}
	for k: String in numbers:
		m.set(k, numbers[k])
	DirAccess.make_dir_recursive_absolute(HERO_DIR)
	_save(m, MASTERY_PATH)
	var mm := MasteryCurve.new()  # (the Maga starts at level 0, with no retroactive XP: her runs are her own)
	for k: String in numbers:
		mm.set(k, numbers[k])
	_save(mm, MAGA_MASTERY_PATH)


## The ultimate's charge besides Magia (T5): per point of damage dealt and of life lost.
const ULT_DAMAGE_CHARGE := 0.03
const ULT_HURT_CHARGE := 1.0


func _ult(n: int, id: StringName, kind: UltDef.Kind, props: Dictionary) -> void:
	var u := UltDef.new()
	u.id = id
	u.kind = kind
	u.name_key = StringName("ult_" + id)
	u.desc_key = StringName("ult_%s_desc" % id)
	for k: String in props:
		u.set(k, props[k])
	_save(u, ULT_DIR + "%02d_%s.tres" % [n, id])


## The two ultimates (D-54; warrior_spec.md 3.2; played by Ultimates, E2-08 and E2-10). U-1: a band 12 x 4 m ahead,
## 300 on the middle strip and 200 on the rest, charged by 60 of Magia spent (Sky Fall), Mastery 2. U-2, the Voragem
## (ultimate_u2_proposals.md, proposal A): 6 m thrown 4 m ahead for 4 s, ticks of 8 every 0.25 s and an implosion of
## 120 within 3 m, charged by 70 (Moon Water), Mastery 6. Names are pending (D-55, D-68: none with Elun). The gesture's
## clip lands its blade as the 0.3 s gesture ends: the overhead cut (Slash_C, peak 0.67 s, PEAK) for the cleave, the
## sword driven down (Sword_Attack, 0.40 s) for the Voragem.
func _ultimates() -> void:
	DirAccess.make_dir_recursive_absolute(ULT_DIR)
	for f in DirAccess.get_files_at(ULT_DIR):
		DirAccess.remove_absolute(ULT_DIR + f)
	# T5 (docs/design/t5_ultimate.md): it also fills with the damage dealt (ULT_DAMAGE_CHARGE a point, 3000 for the
	# cleave) and the life lost (ULT_HURT_CHARGE a point): a player who never holds an Omega still gets it
	_ult(0, &"cleave", UltDef.Kind.CLEAVE, {"charge": 75.0, "damage_charge": ULT_DAMAGE_CHARGE, "hurt_charge": ULT_HURT_CHARGE, "mastery_level": 3, "gesture": 0.3, "weapon": &"emeth",
		"tags": [&"ultimate", &"light"] as Array[StringName], "anim": &"Slash_C", "anim_peak": PEAK[&"Slash_C"], "knockback": 6.0,
		"length": 12.0, "width": 4.0, "core_width": 1.5, "core_damage": 450.0, "damage": 300.0, "stun": 1.0, "armor_mult": 2.0})
	_ult(1, &"vortex", UltDef.Kind.VORTEX, {"charge": 105.0, "damage_charge": ULT_DAMAGE_CHARGE, "hurt_charge": ULT_HURT_CHARGE, "mastery_level": 10, "gesture": 0.3, "weapon": &"", "reserve": true,
		"tags": [&"ultimate", &"cast"] as Array[StringName], "anim": &"Sword_Attack", "anim_peak": PEAK[&"Sword_Attack"], "knockback": 2.0,
		"ahead": 4.0, "aim_max": 8.0, "radius": 6.0, "radius_cap": 7.5, "duration": 4.0, "tick": 0.25, "tick_damage": 12.0,
		"implode_damage": 180.0, "implode_radius": 3.0, "implode_stun": 0.8, "pull": 3.5, "swirl": 2.0, "core": 1.2,
		"elite_pull": 0.5, "guardian_pull": 0.25, "stun": 0.0, "armor_mult": 2.0})


## Where _talent writes: the Warrior's tree, or the Maga's while _maga_talents runs.
var _talent_dir := TALENT_DIR


func _talent(n: int, id: StringName, branch: TalentDef.Branch, tier: TalentDef.Tier, cost: int, unlock: int, props: Dictionary = {}) -> void:
	var t := TalentDef.new()
	t.id = id
	t.name_key = StringName("talent_" + id)
	t.desc_key = StringName("talent_%s_desc" % id)
	t.branch = branch
	t.tier = tier
	t.cost = cost
	t.unlock_level = unlock
	# Rejogabilidade, Fatia 1 (sistemas.md 1.4): opening costs its Devotion in Memória, the first Gift (Mastery 1) comes
	# open so the first descent is no poorer than before
	# (balance 2026-11-24, Lote D: Gifts of Mastery 2 to 5 cost 1 Memoria, within a child reach; the later ones keep their Devotion)
	t.memory_cost = 0 if unlock <= 1 else (1 if unlock <= 5 else cost)
	for k: String in props:
		t.set(k, props[k])
	_save(t, _talent_dir + "%02d_%s.tres" % [n, id])


## The Warrior's tree of Gifts (redesign 2026-11-24, docs/design/heroes/redesign_2026-11-24/01_GUERREIRO.md and 04_PLANO B.1):
## three branches of four, Combo (the sequence), Ímpeto (the held blow and Magia) and Domínio (control), each an entry, two
## middles and an apex; `needs` is the Gift that must be equipped (an apex needs a middle or the entry as the package says).
## No Gift takes a button (slot NONE) and none reads a tag of the Emeth alone (spin, wave, thrust): they hold for any weapon.
## Every number is a stat of its mods (BoonState.stat, read by GiftState, Combat and Player; a tag limits it to the moves that
## carry it). Maestria Marcial is a combo tree (TalentDef.combos). The Fúria and its Gifts are gone (B.5).
func _talents() -> void:
	DirAccess.make_dir_recursive_absolute(TALENT_DIR)
	for f in DirAccess.get_files_at(TALENT_DIR):
		DirAccess.remove_absolute(TALENT_DIR + f)
	var B := TalentDef.Branch
	var T := TalentDef.Tier
	# Combo: the dodge keeps the sequence 2 s longer; each blow of it 8% faster; five blows; the 5th hits for 150% of the others
	_talent(0, &"disciplina", B.COMBO, T.ENTRY, 2, 1, {"mods": [_fixed(&"dodge_window_add", 2.0)] as Array[BoonMod]})
	_talent(1, &"cadencia", B.COMBO, T.MIDDLE, 2, 4, {"needs": &"disciplina", "mods": [_fixed(&"cadence_pct", 0.08)] as Array[BoonMod]})
	_talent(2, &"maestria_marcial", B.COMBO, T.MIDDLE, 3, 9, {"needs": &"disciplina", "combos": FIFTH_TREE})
	_talent(3, &"apogeu", B.COMBO, T.APEX, 4, 16, {"needs": &"maestria_marcial", "mods": [_fixed(&"apogee_pct", 1.5, [], &"finisher")] as Array[BoonMod]})
	# Ímpeto: the Golpe Carregado hits 40% harder; Magia from the attack doubles; it charges 30% faster; Força Titânica costs
	# twice the Magia and hits x3 at the end (final_pct 2.0, after Força Concentrada's damage_pct)
	_talent(4, &"forca_concentrada", B.IMPETO, T.ENTRY, 2, 2, {"mods": [_fixed(&"damage_pct", 0.4, [], &"omega")] as Array[BoonMod]})
	_talent(5, &"determinacao", B.IMPETO, T.MIDDLE, 2, 6, {"needs": &"forca_concentrada", "mods": [_fixed(&"attack_magick_pct", 1.0)] as Array[BoonMod]})
	_talent(6, &"concentracao", B.IMPETO, T.MIDDLE, 3, 11, {"needs": &"forca_concentrada", "mods": [_fixed(&"charge_time_pct", -0.3)] as Array[BoonMod]})
	# GP-1 (D-14): the held blows cost twice and hit three times as hard; the Magia maximum rises by 10 (30 to 40) with it alone
	_talent(7, &"forca_titanica", B.IMPETO, T.APEX, 4, 17, {"needs": &"forca_concentrada", "mods": [_fixed(&"omega_cost_pct", 1.0), _fixed(&"final_pct", 2.0, [], &"omega"),
		_fixed(&"magick_max", 10.0)] as Array[BoonMod]})
	# Domínio: the finisher wears 50% more Quebra; the Brado is wider, stronger and interrupts (the old Voz Larga's numbers);
	# the stun of a blow lasts 50% longer; the Investida goes through and stuns whoever it hits for 2 s (B.4), Quebra wears 50% more
	_talent(8, &"ruptura", B.DOMINIO, T.ENTRY, 2, 3, {"mods": [_fixed(&"poise_pct", 0.5, [], &"finisher"), _fixed(&"poise_pct", 0.5, [], &"smash")] as Array[BoonMod]})
	# GP-1 (D-12): Alcance Marcial takes the Voz do Leão's place: the Corte Circular reaches 25% farther and pushes 30% more
	_talent(9, &"alcance_marcial", B.DOMINIO, T.MIDDLE, 3, 8, {"needs": &"ruptura", "mods": [_fixed(&"reach_pct", 0.25, [], &"cast"),
		_fixed(&"push_pct", 0.3, [], &"cast")] as Array[BoonMod]})
	_talent(10, &"imposicao", B.DOMINIO, T.MIDDLE, 3, 13, {"needs": &"ruptura", "mods": [_fixed(&"stun_pct", 0.5)] as Array[BoonMod]})
	_talent(11, &"investida_implacavel", B.DOMINIO, T.APEX, 4, 18, {"needs": &"imposicao", "mods": [_fixed(&"dash_pierce", 1.0, [], &"dash"),
		_fixed(&"dash_stun", 2.0, [], &"dash"), _fixed(&"poise_pct", 0.5, [], &"dash")] as Array[BoonMod]})


## A wave a blow throws (Combat._gift_wave) on the moves with this tag: damage, meters it runs, meters across.
func _wave(tag: StringName, damage: float, reach: float, width: float) -> Array[BoonMod]:
	return [_fixed(&"blow_wave", damage, [], tag), _fixed(&"blow_wave_m", reach, [], tag), _fixed(&"blow_wave_w", width, [], tag)]


## The Warrior (DT-013; warrior_spec.md): the numbers the paladin had in constants (Player, Combat, Feel), unchanged:
## life 30 (Hades II; Lote 5 tried 18, Daniel put 30 back on 2026-11-21 when blows stopped stunning: StunRule) and 1.3 s safe after a blow (Hades II), 1 dodge charge back in 0.74 s, 50 of Magia, the circle of light
## (5.4 m, 3 s, Omega 20 of Magia held 0.6 s, bursts for 150). The passive gives 2 of Magia a finisher (D-56).
## Daniel 2026-11-21 ("aumentasse a recarga de todas as habilidades com exceção dos ataques"): the circle 6 s from its
## cast (was 0.2 s after one ended), the Brado 14 s (was 10), the dodge back in 1.1 s (was 0.74, Hades II), the
## ultimates 50% more Magia (cleave 90, was 60; Voragem 105, was 70). The attack and the special untouched.
## Daniel 2026-11-21 night ("acho q nosso herói dá muito dano no começo"; "me sentir muito fraco no começo"): the
## burst 35 for 12 Magia (was 60 for 8), the Investida gives 2 Magia a hit (was 3), the Brado's buff 15% faster blows
## (was 20%). docs/design/balance.md "Meta nova".
func _hero() -> void:
	var h := HeroDef.new()
	h.id = &"warrior"
	h.name_key = &"hero_warrior"
	h.model = &"hero_explorer"
	h.combos = "res://data/combos/paladin.tres"
	var numbers := {
		"max_hp": 50.0, "hurt_time": 0.18, "hurt_invuln": 0.7, "dodge_charges": 1, "dodge_recharge": 0.8,
		"magick_max": 30.0, "circle": false,
		"cast_charge": 0.25, "cast_slow": 0.6, "cast_cooldown": 6.0, "cast_attack_lock": 8.0 / 60.0, "cast_omega_time": 0.6,
		"cast_omega_cost": 20.0, "cast_radius": 5.4, "cast_time": 3.0, "cast_burst": 375.0,
		"magick_on_finisher": 2.0,
		# C1c (kit_c1c.md 1): the buttons feed each other
		"magick_on_break": 3.0, "cd_refund_hit": 0.0, "cd_refund_break": 0.0, "cd_floor": 0.0, "gain_cap": 3.0, "gain_window": 1.0,
		"wave_refund_cap": 8.0,
		# GP-1 (warrior_v1 6): the Ritmo de Batalha, prototype numbers (balance-designer measures)
		"rhythm_time": 3.0, "rhythm_smash_poise": 0.5, "rhythm_power_stun": 1.0, "rhythm_power_poise": 0.3, "rhythm_special_dmg": 0.5,
		"rhythm_special_reach": 0.3,
		# C19-4 (Q-12): Hades II's Swing5 charge walks at 3% with the body all but locked; the special's 60% is an
		# inference (WeaponStaffBoltInstantStop; its Omega stage has no speed of its own)
		"charge_move_light": 0.03, "charge_turn_light": 0.0, "charge_move_heavy": 0.03,
	}
	for k: String in numbers:
		h.set(k, numbers[k])
	# the passive's finishers (warrior_spec.md 3.1): the spin, the Corte Veloz that lands, the Omegas; never the ultimate
	# GP-1 (D-4): the Combo's finisher only; the Lança and the Esmagador pay, they do not refund
	h.passive_tags = [&"finisher"] as Array[StringName]
	h.passive_never = [&"ultimate"] as Array[StringName]
	var ults: Array[UltDef] = []
	var files := DirAccess.get_files_at(ULT_DIR)
	files.sort()
	for f in files:
		ults.append(ResourceLoader.load(ULT_DIR + f, "", ResourceLoader.CACHE_MODE_REPLACE))
	h.ultimates = ults
	h.weapon = &"emeth"
	h.talents_dir = TALENT_DIR
	h.mastery = ResourceLoader.load(MASTERY_PATH, "", ResourceLoader.CACHE_MODE_REPLACE)
	DirAccess.make_dir_recursive_absolute(HERO_DIR)
	_save(h, HeroDef.WARRIOR)


# ---------- the Maga (docs/design/heroes/maga.md, M1a) ----------

const MAGA_COMBOS := "res://data/combos/maga.tres"
const MAGA_ULT := "res://data/ultimates/maga/00_converge.tres"
const MAGA_TALENTS := "res://data/talents/maga/"
const MAGA_AMBER := Color(1.0, 0.62, 0.18)


## The Maga's tree (GP-5, docs/design/heroes/maga_v1_2026-11-26.md 1): left tap the Centelha (a fire bolt, free), left hold the Arco Voltaico
## (10 Magia); right tap the Estilhaço (an ice bolt through the crowd, 5 Magia), right hold the Geada (an area at the cursor, 20 Magia). No
## button of Q or E and no recharge: the Magia (2 a second back) regulates her. No blow here is struck by a blade: damage 0 and the effect
## does it (as the Warrior's bolt). The elements are Arcane's (ElementBook). The Combustão and the Suspensão Arcana left the tree.
## Tags decide where the Blessings and the Skills read each one (DealtBy, CelRules.slot_of): the Arco is an omega of the attack, the
## Estilhaço the Poder (shout, cast: no heavy), the Geada the Especial.
func _maga_tree() -> ComboTree:
	var shot := {"damage": 0.0, "shape": ComboNode.Shape.LINE, "reach": 1.0, "width": 1.0, "chain_window": 0.4, "hit_stop_ms": 0.0,
		"shake": 0.2, "move_scale": 0.0, "sound": &"dart", "effect": ComboNode.Effect.WAVE, "effect_radius": 11.0, "wave_bolt": true,
		"wave_speed": 30.0, "wave_stops": true, "wave_color": ElementLook.FIRE, "knockback": 2.0}
	# Maga V2 (docs/design/heroes/maga_v2_2026-11-27.md 3): the Centelha is a chain of three (11, 11, then the Lança de Brasa, 22: bigger, through
	# the crowd, a push of 5, a stop of 40 ms and the `finisher` tag); every hit lights the target (ArcaneKit.spark_hits 1)
	var spark3 := _move(&"spark3", L, &"Cast", [&"light", &"bolt", &"arcane", &"fire", &"finisher"],
		shot.merged({"effect_power": 22.0, "effect_size": 1.1, "windup": 0.16, "recovery": 0.26, "move_hold": 0.30, "wave_stops": false,
		"knockback": 5.0, "hit_stop_ms": 40.0}, true), [], &"move_spark")
	var spark2 := _move(&"spark2", L, &"Cast", [&"light", &"bolt", &"arcane", &"fire"],
		shot.merged({"effect_power": 11.0, "effect_size": 0.7, "windup": 0.08, "recovery": 0.12, "move_hold": 0.15}, true), [spark3], &"move_spark")
	var spark := _move(&"spark", L, &"Cast", [&"light", &"bolt", &"arcane", &"fire"],
		shot.merged({"effect_power": 11.0, "effect_size": 0.7, "windup": 0.08, "recovery": 0.12, "move_hold": 0.15}, true), [spark2], &"move_spark")
	# left held: the Arco Voltaico, to up to three, 8 Magia, 0.35 s of charge from the press
	var arc := _move(&"arc", CL, &"Cast", [&"omega", &"light", &"arcane", &"volt"],
		{"damage": 0.0, "shape": ComboNode.Shape.LINE, "reach": 1.0, "width": 1.0, "windup": 0.10, "recovery": 0.15, "move_hold": 0.20,
		"chain_window": 0.4, "magick_cost": 8.0, "charge_time": 0.35, "hit_stop_ms": 0.0, "shake": 0.3, "move_scale": 0.0,
		"sound": &"wave_omega", "effect": ComboNode.Effect.ARC}, [], &"move_arc")
	# right tap: the Estilhaço through everyone on its way, 4 Magia, no recharge
	var shard := _move(&"shard", H, &"Cast", [&"shout", &"cast", &"bolt", &"arcane", &"ice"],
		shot.merged({"effect_power": 10.0, "effect_size": 0.8, "windup": 0.12, "recovery": 0.20, "move_hold": 0.25, "magick_cost": 4.0,
		"wave_stops": false, "wave_color": ElementLook.COLD, "wave_speed": 26.0, "hit_stop_ms": 25.0}, true), [], &"move_shard")
	# right held: the Geada at the cursor, 15 Magia, 0.45 s
	var frost := _move(&"frost", C, &"Cast", [&"omega", &"heavy", &"cast", &"arcane", &"ice"],
		{"damage": 0.0, "shape": ComboNode.Shape.LINE, "reach": 1.0, "width": 1.0, "windup": 0.14, "recovery": 0.22, "move_hold": 0.30,
		"chain_window": 0.2, "magick_cost": 15.0, "charge_time": 0.45, "hit_stop_ms": 0.0, "shake": 0.3, "move_scale": 0.0,
		"sound": &"wave_omega", "effect": ComboNode.Effect.FROST}, [], &"move_frost")
	var tree := ComboTree.new()
	tree.neutral = [spark, arc, shard, frost]
	tree.dodge_window = 0.0
	return tree

## A number of a Maga Gift as the design says it (maga_m2.md 2): _mod scales every burn_dps by FLAT (the Warrior's blows fell from 50 to
## 15; the Maga's numbers were already set on that scale), so hers are written here untouched.
func _raw(stat: StringName, base: float, per_level: Array = [], tag: StringName = &"") -> BoonMod:
	var m := BoonMod.new()
	m.stat = stat
	m.tag = tag
	m.base = base
	m.by_rarity = false
	return m


## The Maga's 12 Gifts (GP-5, maga_v1_2026-11-26.md 8; they replace the provisional twelve of 2026-11-24, SaveData.GP5_REMOVED_DONS gives
## their Memória back): Elementalismo (the reactions), Conjuração (the ground), Feitiçaria (the Magia and the held spells), each an entry, two
## middles and an apex; `needs` is the Gift that must be equipped. No Gift takes a button. Every number is a stat of its mods
## (BoonState.stat, read by Arcane, Player and GiftState); no id repeats one of SaveData.LEGACY_DONS. Prototype numbers (the balance measures).
func _maga_talents() -> void:
	_talent_dir = MAGA_TALENTS
	DirAccess.make_dir_recursive_absolute(MAGA_TALENTS)
	for f in DirAccess.get_files_at(MAGA_TALENTS):
		DirAccess.remove_absolute(MAGA_TALENTS + f)
	var B := TalentDef.Branch
	var T := TalentDef.Tier
	# Elementalismo: the states last 50% longer; the reactions hit 30% harder (and the Quebra of the Cristalização); an element a blow
	# puts on spreads to the nearest within 3 m once a cast; a reaction leaves a 3 s residue and the third element makes the other two
	_talent(0, &"afinidade", B.ELEMENTALISMO, T.ENTRY, 2, 1, {"mods": [_raw(&"element_time_pct", 0.5)] as Array[BoonMod]})
	_talent(1, &"catalisador", B.ELEMENTALISMO, T.MIDDLE, 2, 5, {"needs": &"afinidade", "mods": [_raw(&"react_pct", 0.3)] as Array[BoonMod]})
	_talent(2, &"propagacao", B.ELEMENTALISMO, T.MIDDLE, 3, 10, {"needs": &"afinidade", "mods": [_raw(&"spread_range", 3.0)] as Array[BoonMod]})
	_talent(3, &"trindade", B.ELEMENTALISMO, T.APEX, 4, 17, {"needs": &"catalisador", "mods": [_raw(&"trinity", 1.0), _raw(&"trinity_time", 3.0)] as Array[BoonMod]})
	# Conjuração: the Geada and the embers last 30% longer and are 25% wider; Choque Térmico and Sobrecarga leave embers; in the Geada and an
	# ember at once a Choque Térmico every 2 s
	_talent(4, &"permanencia", B.CONJURACAO, T.ENTRY, 2, 2, {"mods": [_raw(&"area_time_pct", 0.3)] as Array[BoonMod]})
	_talent(5, &"expansao", B.CONJURACAO, T.MIDDLE, 2, 7, {"needs": &"permanencia", "mods": [_raw(&"area_size_pct", 0.25)] as Array[BoonMod]})
	_talent(6, &"manifestacao", B.CONJURACAO, T.MIDDLE, 3, 12, {"needs": &"permanencia", "mods": [_raw(&"ember_floor", 1.0)] as Array[BoonMod]})
	_talent(7, &"confluencia", B.CONJURACAO, T.APEX, 4, 18, {"needs": &"manifestacao", "mods": [_raw(&"confluence", 1.0), _raw(&"confluence_gap", 2.0)] as Array[BoonMod]})
	# Feitiçaria: the Magia comes back 1 a second faster; the held spells charge 30% sooner; a cast that makes a reaction gives 2 Magia; three
	# reactions make the next held spell free and quick
	_talent(8, &"fluxo_arcano", B.FEITICARIA, T.ENTRY, 2, 3, {"mods": [_raw(&"regen_add", 1.0)] as Array[BoonMod]})
	_talent(9, &"agilidade_arcana", B.FEITICARIA, T.MIDDLE, 2, 8, {"needs": &"fluxo_arcano", "mods": [_raw(&"charge_time_pct", -0.3)] as Array[BoonMod]})
	_talent(10, &"reciprocidade", B.FEITICARIA, T.MIDDLE, 3, 13, {"needs": &"fluxo_arcano", "mods": [_raw(&"reaction_magick", 3.0)] as Array[BoonMod]})
	_talent(11, &"transcendencia", B.FEITICARIA, T.APEX, 4, 19, {"needs": &"reciprocidade", "mods": [_raw(&"transcend_at", 3.0)] as Array[BoonMod]})
	_talent_dir = TALENT_DIR


func _maga() -> void:
	_save(_maga_tree(), MAGA_COMBOS)
	_maga_talents()
	DirAccess.make_dir_recursive_absolute(MAGA_ULT.get_base_dir())
	for f in DirAccess.get_files_at(MAGA_ULT.get_base_dir()):
		DirAccess.remove_absolute(MAGA_ULT.get_base_dir() + "/" + f)
	# the Convergência Elemental (04_PLANO C.3): 5 m at the cursor (up to 9) for 4.5 s, ice then fire then volt, a tick every
	# 0.5 s, 90 of damage in all (ArcaneKit.converge_*); 60 charge (Magia spent, damage dealt, life lost and, GP-5, her reactions), Mastery 2
	var u := UltDef.new()
	u.id = &"converge"
	u.kind = UltDef.Kind.CONVERGE
	u.name_key = &"ult_converge"
	u.desc_key = &"ult_converge_desc"
	var numbers := {"charge": 50.0, "damage_charge": ULT_DAMAGE_CHARGE, "hurt_charge": ULT_HURT_CHARGE, "mastery_level": 2, "gesture": 0.3, "weapon": &"bastao",
		"anim": &"Cast", "anim_peak": PEAK[&"Cast"], "knockback": 0.0, "ahead": 4.0, "aim_max": 9.0, "radius": 5.0, "radius_cap": 6.5,
		"duration": 4.5, "tick": 0.5, "elite_share": 0.5, "guardian_share": 0.25}
	for k: String in numbers:
		u.set(k, numbers[k])
	u.tags = [&"ultimate", &"cast"] as Array[StringName]
	_save(u, MAGA_ULT)
	var kit := ArcaneKit.new()  # (every number of ArcaneKit is its default: 04_PLANO C.1 to C.3, prototype numbers)
	var h := HeroDef.new()
	h.id = &"maga"
	h.name_key = &"hero_maga"
	h.model = &"hero_explorer"
	h.combos = MAGA_COMBOS
	# life 30 as the others (maga.md 13); the Passo has 2 charges of 1 s; 50 of Magia that comes back 2 a second (GP-5); no Magia from a
	# finisher or a Quebra, no recharge to refund; she walks (half speed) and turns (90 degrees a second) while a held spell charges
	var body := {"max_hp": 30.0, "hurt_time": 0.18, "hurt_invuln": 0.7, "dodge_charges": 2, "dodge_recharge": 1.0, "magick_max": 50.0,
		"magick_regen": 3.0, "circle": false, "magick_on_finisher": 0.0, "magick_on_break": 0.0, "cd_floor": 0.0, "gain_cap": 3.0, "gain_window": 1.0,
		"charge_move_light": 0.5, "charge_move_heavy": 0.5, "charge_turn_light": 90.0}
	for k: String in body:
		h.set(k, body[k])
	h.passive_tags = [] as Array[StringName]
	h.passive_never = [&"ultimate"] as Array[StringName]
	h.arcane = kit
	h.ultimates = [ResourceLoader.load(MAGA_ULT, "", ResourceLoader.CACHE_MODE_REPLACE)] as Array[UltDef]
	h.weapon = &"bastao"
	h.talents_dir = MAGA_TALENTS
	h.mastery = ResourceLoader.load(MAGA_MASTERY_PATH, "", ResourceLoader.CACHE_MODE_REPLACE)
	_save(h, HeroDef.MAGA)


# ---------- Psalms (E4) ----------

const PSALM_DIR := "res://data/psalms/"


func _psalm(n: int, id: StringName, theme: StringName, slot: Boon.Slot, effect: PsalmDef.Effect, requires: Array, props: Dictionary) -> void:
	var p := PsalmDef.new()
	p.id = id
	p.theme = theme
	p.name_key = StringName("psalm_" + id)
	p.desc_key = StringName("psalm_%s_desc" % id)
	p.hint_key = StringName("psalm_%s_hint" % id)
	p.line_key = StringName("psalm_%s_line" % id)
	p.slot = slot
	p.effect = effect
	for group: Array in requires:
		p.requires.append(PackedStringArray(group))
	for k: String in props:
		p.set(k, props[k])
	_save(p, PSALM_DIR + "%02d_%s.tres" % [n, id])


## The four Psalms of E4 (D-59 (a): named by theme, no number, no verse; D-60: Sentinela, Abrigo, Pastor and Rocha;
## docs/design/e4_psalms.md). Each transforms one action with a system the game has; three groups each (a Blessing or
## an Elo of a list, or an equipped Gift: PsalmDef.GIFT before its id), one held thing a group, never the same for two.
## The lists are wide on purpose so the robot (no Gifts) can meet them too; numbers are starting points for E6.
func _psalms() -> void:
	DirAccess.make_dir_recursive_absolute(PSALM_DIR)
	for f in DirAccess.get_files_at(PSALM_DIR):
		DirAccess.remove_absolute(PSALM_DIR + f)
	var S := Boon.Slot
	var E := PsalmDef.Effect
	var G := PsalmDef.GIFT
	# watching: the circle of light walks with him and strikes each one that comes in (30, the Corte Veloz's damage)
	_psalm(0, &"sentinela", &"watch", S.CAST, E.SENTINEL, [
		["circulo_brasa", "circulo_geada", "circulo_radiante", "circulo_firme"],
		["escudo", "passos", "firmeza", "golpe_firme", "pesado_firme"],
		["bastiao", "rastro", "passo_frio", G + "alcance_marcial", G + "imposicao", G + "forca_concentrada"]],
		{"damage": 75.0})
	# sheltering: the dodge leaves a shelter of 2.6 m for 3 s where it ends (two at most) that undoes enemy shots
	_psalm(1, &"abrigo", &"shelter", S.DASH, E.SHELTER, [
		["passos", "passo_brasa", "passo_geada", "passo_radiante"],
		["escudo", "firmeza", "consolo", "circulo_firme"],
		["rastro", "passo_frio", "bastiao", G + "disciplina", G + "cadencia", G + "investida_implacavel"]],
		{"radius": 2.6, "duration": 3.0, "count": 2})
	# guiding: each kill gathers a light (three at most); the special throws one more wave for each, 14 degrees apart
	_psalm(2, &"pastor", &"shepherd", S.SPECIAL, E.FLOCK, [
		["toque_geada", "pesado_brasa", "pesado_radiante", "pesado_firme"],
		["consolo", "onda_maior", "flagelo", "golpe_radiante", "circulo_radiante", "passo_radiante"],
		["aurora", "chama_viva", G + "forca_concentrada", G + "determinacao", G + "forca_titanica"]],
		{"count": 3, "spread": 14.0, "damage": 140.0, "radius": 6.0})
	# firmness: the spin plants a stone of light: 30 within 4 m, the common ones stunned 1 s, then 3 s slowing there
	_psalm(3, &"rocha", &"rock", S.ATTACK, E.STONE, [
		["golpe_brasa", "golpe_geada", "golpe_radiante", "golpe_firme"],
		["firmeza", "escudo", "pesado_firme", "estilhaco", "peso_inverno"],
		["vapor", "bastiao", G + "maestria_marcial", G + "apogeu", G + "cadencia", G + "ruptura"]],
		{"damage": 75.0, "radius": 4.0, "stun": 1.0, "duration": 3.0})


# ---------- E5: the Provação ----------

const TRIAL_DIR := "res://data/trials/"


func _trial(n: int, id: StringName, kind: TrialDef.Kind, mods: Array[BoonMod], encounters := Vector2i(3, 5)) -> void:
	var t := TrialDef.new()
	t.id = id
	t.kind = kind
	t.name_key = id
	t.desc_key = StringName("%s_desc" % id)
	t.mods = mods
	t.encounters = encounters
	_save(t, TRIAL_DIR + "%02d_%s.tres" % [n, id])


## The Provação's cards (E5; Hades II's Chaos, docs/design/hades2_sistemas.md section 7, without a god: E5-D6). A
## blessing is a strong number the game already reads, scaled by its rarity like a Blessing (Hades II's Chaos: attack
## +20% to +50% at common, life +26 to +35); a curse is carried for 3 to 5 fights (Hades II's RemainingUses 3 to 5)
## and never scales. Our numbers, starting points for E6.
func _trials() -> void:
	DirAccess.make_dir_recursive_absolute(TRIAL_DIR)
	for f in DirAccess.get_files_at(TRIAL_DIR):
		DirAccess.remove_absolute(TRIAL_DIR + f)
	var B := TrialDef.Kind.BLESSING
	var C := TrialDef.Kind.CURSE
	_trial(0, &"trial_golpe", B, [_mod(&"damage_pct", 0.3, [], &"light")])
	_trial(1, &"trial_pesado", B, [_mod(&"damage_pct", 0.4, [], &"heavy")])
	_trial(2, &"trial_circulo", B, [_mod(&"damage_pct", 0.5, [], &"cast")])
	_trial(3, &"trial_vigor", B, [_mod(&"max_hp", 15.0)])
	_trial(4, &"trial_reserva", B, [_mod(&"magick_max", 20.0)])
	# the curses: the dead walk faster, healing is halved, one more enemy a wave, blows hurt more, no gold falls
	_trial(10, &"trial_pressa", C, [_fixed(&"enemy_speed_pct", 0.25)])
	_trial(11, &"trial_ferida", C, [_fixed(&"heal_pct", -0.5)])
	_trial(12, &"trial_horda", C, [_fixed(&"wave_extra", 1.0)])
	_trial(13, &"trial_fragil", C, [_fixed(&"hurt_pct", 0.25)])
	_trial(14, &"trial_pobreza", C, [_fixed(&"gold_pct", -1.0)])


# ---------- E5: three arenas and the two rooms of the events (docs/art/e5_spec.md) ----------

## A piece of the spec's tables standing along x (or z), w x d, of its height (a bench, an altar, a pillar).
func _piece(x: float, z: float, w: float, d: float, top: float, piece: StringName, see := false) -> ArenaObstacle:
	return _sarcophagus(x, z, w, d, top, piece, see)


## Named parts of the floor (RoomLayout.areas, ArenaVariant.areas): pairs of a name and a rectangle.
func _areas(l: Resource, pairs: Array) -> void:
	var rects: Array[Rect2] = []
	var names := PackedStringArray()
	for i in range(0, pairs.size(), 2):
		names.append(pairs[i])
		rects.append(pairs[i + 1])
	l.set(&"areas", rects)
	l.set(&"area_names", names)


## Santuário Desmoronado (spec section 1, C14-A4): the guardian's house. A nave of a church under the earth, two rows of
## columns that stop shots, the nave 10.7 m free between them (the knight's charge), the side aisles 7.35 m; the
## guardian rises before the presbytery's grille (west). Variant B: the floor of the nave fell in (a hole of 8.4 x 7 m),
## the four columns over it with it.
## RP-18: the Santuário C's grid of low columns (x 3, 7, 11 by z -4, 0, 4), its two stumps and its cracked one.
const COLONNADE := [Vector2(3, -4), Vector2(7, -4), Vector2(11, -4), Vector2(3, 0), Vector2(7, 0), Vector2(11, 0),
	Vector2(3, 4), Vector2(7, 4), Vector2(11, 4)]
const COLONNADE_STUMPS := [Vector2(7, -4), Vector2(3, 4)]
const COLONNADE_CRACKED := Vector2(11, 0)
const COLONNADE_TOP := 2.5


const SANCTUARY_TRAPS := [[Vector2(7.15, -14.0), Vector2(0, 1), 18.5], [Vector2(-1.5, 14.0), Vector2(0, -1), 19.0],
	[Vector2(12.0, 14.0), Vector2(0, -1), 18.0]]


func _sanctuary() -> RoomLayout:
	var l := RoomLayout.new()
	_arena(l, &"sanctuary", RoomLayout.Size.LARGE, 2, Vector2(0.4, 1.0))
	var outline := _poly([-22, -14, 14, -14, 22, -6, 22, 14, -18, 14, -22, 10])
	l.floor = FloorShape.poly([outline])
	l.half = l.floor.extent()
	l.max_alive = Vector2i(6, 8)
	l.max_ranged = 3
	# 2026-11-23: the guardians have houses of their own (_knight_hall, _elder_hall); the Santuário is an ordinary high room
	l.guardian = false
	# fire bowls of the north door's recesses, 0.9 m out of the floor (drawn, never blocking; the bowl and its fire are
	# 0.7 m round); the grille's two are the look's own, on its end pillars (SanctuaryLook), never in the data
	var bowls: Array[ArenaObstacle] = [_bowl(7.15, -14.9)]
	var walls: Array[ArenaObstacle] = [_sarcophagus(-12.0, -13.4, 2.5, 1.2), _sarcophagus(-1.0, -13.4, 2.5, 1.2),
		_piece(-12.0, 10.2, 2.0, 0.6, 0.9, &"bench_broken"), _piece(6.0, 10.2, 2.0, 0.6, 0.9, &"bench_broken")]
	var a: Array[ArenaObstacle] = []
	for x: float in [-15.0, -9.0, -3.0, 9.0]:
		a.append(_column(x, -6.0, 5.2, 0.65))
	for x: float in [-15.0, -3.0, 3.0, 9.0, 15.0]:
		a.append(_column(x, 6.0, 5.2, 0.65))
	a.append_array([_cracked(_column(15.0, -6.0, 3.4, 0.65)), _cracked(_column(-9.0, 6.0, 3.0, 0.65)),
		ArenaObstacle.circle(Vector2(3.0, -6.0), 0.65, &"column_base", 0.6, false),
		_capsule(Vector2(3.0, -6.9), Vector2(3.0, -9.3), 1.1, 1.0, &"drums")])
	a.append_array(walls)
	a.append_array(bowls)
	l.obstacles = a
	# B, "Nave partida": the nave's floor fell (a hole), the columns of x 3 and 9 with it; the north (-9) one broken
	var b: Array[ArenaObstacle] = [_column(-15.0, -6.0, 5.2, 0.65), _column(-9.0, -6.0, 3.2, 0.65),
		_column(-3.0, -6.0, 5.2, 0.65), _cracked(_column(15.0, -6.0, 3.4, 0.65)), _column(-15.0, 6.0, 5.2, 0.65),
		_cracked(_column(-9.0, 6.0, 3.0, 0.65)), _column(-3.0, 6.0, 5.2, 0.65), _column(15.0, 6.0, 5.2, 0.65)]
	# 2026-11-27 (room review): the hole runs on to the south edge (13.9, a 0.1 m rim nobody can stand on), so the nave is cut in two:
	# the way from the east (the way in) to the west is the north aisle only, round the north lip, no more south aisle
	for w: ArenaObstacle in walls:
		if not (w.piece == &"bench_broken" and w.center.x > 0.0):  # the east bench stood over the chasm
			b.append(w)
	b.append_array(bowls)
	var fallen := FloorShape.poly([outline], [_poly([1, -3.2, 4.5, -3.5, 9, -3.1, 9.4, 0, 9.4, 13.9, 0.6, 13.9, 0.6, 0])])
	l.variants = [_variant(b, fallen)]
	l.variants[0].spawns = [_rect(-20, -14, -3, 3), _rect(-19, -15, 8, 11), _rect(-8, -2, -12, -8.5), _rect(13, 17, -4, 0),
		_rect(-2, 6, -12, -8.5)]
	l.boss_spawn = Vector2(-17.0, 0.0)
	_gate(l, Vector2(19.6, 11.6), -14.0, [-5.3, 3.3, 11.0])
	# LR-03: the first wave rises also in the south aisle's east and the middle of the north one, so the fight opens in
	# both aisles and the east third is no corridor (it was the hero's 5 s walk to a fight all in the west)
	l.spawns = [_rect(-20, -14, -3, 3), _rect(-19, -15, 8, 11), _rect(-8, -2, -12, -8.5), _rect(4, 12, 8, 12),
		_rect(-2, 6, -12, -8.5)]
	l.late_spawns = [_rect(10, 16, 8, 12)]
	l.far_spawn = 1.5  # SW-R3: west and east of the nave, both aisles: the next one rises far from where he stands
	l.cam_bounds = _rect(-10, 10, -2, 2)
	# the question of the room (spec 0.2): the open nave or the aisles behind the columns
	_areas(l, ["nave", _rect(-22, 22, -5.35, 5.35), "aisle_n", _rect(-22, 22, -14, -5.35), "aisle_s", _rect(-22, 22, 5.35, 14)])
	# RP-06: the aisles get a price (the nave has the knight's charge, the aisles the slabs): two in each, between the
	# columns, off the spawns and the doors; B the same (its hole is in the nave)
	var aisle_slabs: Array[Rect2] = [_rect(-13.5, -10.5, -11.0, -8.0), _rect(10.5, 13.5, -11.0, -8.0),
		_rect(-7.5, -4.5, 8.0, 11.0), _rect(0.0, 3.0, 8.0, 11.0)]
	l.hazard = _plates(aisle_slabs, PLATES_FROM)
	# SR-P1: wall traps through the nave and the aisles (from the middle of the descent, every 4.5 s), blades along three
	# lines between the columns: from the north wall at x -6 and from the south wall at x -1.5 and x 12 (the way in is the
	# east end, 7 m from the last); A has all three, C (the colonnade, whose grid fills x 2 to 12) the first two
	l.hazard.also = _trap(SANCTUARY_TRAPS, 0.5, 3.5, 2.8)
	l.hazard.also.also = _sag([_rect(-13.5, -10.5, -6, -3), _rect(2, 5, 0.5, 3.5), _rect(-19.5, -16.5, 4, 7)], 0.5)
	l.obstacles.append_array(_trap_blocks(SANCTUARY_TRAPS))
	# RP-13 (B): the edge that crumbles, the slabs at the two ends of the hole (the nave is 1.85 m wide along its long
	# sides, no room for a slab there): 7 to him (not 10, A1) and everyone on them thrown 2.5 m away from the hole, to the
	# firm floor (nobody falls, D-28); the same hazard as the aisles' (one hazard that hurts per room)
	var edge_slabs: Array[Rect2] = [aisle_slabs[0], aisle_slabs[1], aisle_slabs[2], _rect(6.0, 9.0, -11.0, -8.0)]  # (the south-east slab stood over the chasm: moved to the north aisle)
	edge_slabs.append_array([_rect(-2.6, 0.4, -1.5, 1.5), _rect(9.6, 12.6, -1.5, 1.5)])
	var crumble := _plates(edge_slabs, PLATES_FROM)
	crumble.plate_hero_damage = PackedFloat32Array([0, 0, 0, 0, CRUMBLE_HERO, CRUMBLE_HERO])
	crumble.plate_push = PackedVector2Array([Vector2.ZERO, Vector2.ZERO, Vector2.ZERO, Vector2.ZERO, Vector2(-2.5, 0),
		Vector2(2.5, 0)])
	l.variants[0].hazard = crumble
	# A1, RP-20: stones from the torn vault over the nave round the hole (the rent above it), 6.5 m and more from the
	# way in; never on the hole (a square only whole on the floor)
	crumble.also = _rocks([_rect(-3.5, 13.0, -5.2, 5.2)])  # (PT-25-9: from x -3.5, off the patch of SANCTUARY_ISLAND)
	crumble.also.also = _spikes([Vector2(-16.0, -3.0), Vector2(-7.5, -4.5)], 0.55)  # (PT-25-9: the second one off the patch)
	_areas(l.variants[0], ["hole_edge", _rect(-2.6, 0.4, -1.5, 1.5), "hole_edge", _rect(9.6, 12.6, -1.5, 1.5),
		"nave", _rect(-22, 22, -5.35, 5.35), "aisle_n", _rect(-22, 22, -14, -5.35), "aisle_s", _rect(-22, 22, 5.35, 14)])
	# A1, RP-18, C "Colunata": the east of the nave becomes a grid of nine low columns (2.5 m: they stop shots and bodies
	# but never hide a wind-up, combat_cadence.md 9.3), 4 m apart, two of them broken to stumps (bodies, no shots) and one
	# cracked (RP-09); the west of the nave stays open for the guardian's charge. The question: fight in the grid (cover
	# from the shooters, the pack split by the columns) or in the open west. From the middle of the descent on; A's slabs.
	var c: Array[ArenaObstacle] = [_column(-15.0, -6.0, 5.2, 0.65), _column(-9.0, -6.0, 5.2, 0.65),
		_column(-3.0, -6.0, 5.2, 0.65), _column(9.0, -6.0, 5.2, 0.65), _cracked(_column(15.0, -6.0, 3.4, 0.65)),
		_column(-15.0, 6.0, 5.2, 0.65), _cracked(_column(-9.0, 6.0, 3.0, 0.65)), _column(-3.0, 6.0, 5.2, 0.65),
		_column(9.0, 6.0, 5.2, 0.65), _column(15.0, 6.0, 5.2, 0.65)]
	for p: Vector2 in COLONNADE:
		if COLONNADE_STUMPS.has(p):
			c.append(ArenaObstacle.circle(p, 0.5, &"column_base", 0.6, false))
		elif p == COLONNADE_CRACKED:
			var k := _cracked(_column(p.x, p.y, COLONNADE_TOP, 0.5))
			k.fall_length = 3.0  # a low column falls short
			c.append(k)
		else:
			c.append(_column(p.x, p.y, COLONNADE_TOP, 0.5))
	c.append_array(walls)
	c.append_array(bowls)
	c.append_array(_trap_blocks(SANCTUARY_TRAPS.slice(0, 2)))
	var vc := _variant(c)
	vc.depth = Vector2(0.5, 1.0)
	vc.hazard = _plates(aisle_slabs, PLATES_FROM)
	vc.hazard.also = _trap(SANCTUARY_TRAPS.slice(0, 2), 0.5, 3.5, 2.8)
	_areas(vc, ["colonnade", _rect(1.0, 13.0, -5.35, 5.35), "nave", _rect(-22, 22, -5.35, 5.35),
		"aisle_n", _rect(-22, 22, -14, -5.35), "aisle_s", _rect(-22, 22, 5.35, 14)])
	l.variants.append(vc)
	l.gaps = _ring(SANCTUARY_ISLAND)
	return l


# ---------- 2026-11-23: the guardians' houses (docs/design/rooms_progression.md, "Salas dos guardiões") ----------

## The spike plate: a PLATES hazard named &"spikeplate" (the SR-P2 slab's rules without the dwell): a plate of 2.4 m that
## anyone stepping on (the paladin or an enemy) arms at once, 1.2 s of warning (the grate's tips peeking, then rising
## as the warning fills), the spikes up for 0.6 s (10 to him, 60 to an enemy standing on it), 6 s before it arms again.
## Drawn with the pit grate's piece (HazardPiece.grate). Asleep before `from`, nothing in the first 5 s.
const SPIKE_PLATE := 2.4
func _spike_plates(rects: Array[Rect2], from: float) -> HazardDef:
	var h := _plates(rects, from, false)
	h.plate_source = &"spikeplate"
	h.warn = 1.2
	h.fire = 0.6
	h.rearm = 6.0
	h.start_delay = 5.0
	return h


## A spike plate of SPIKE_PLATE metres with its north-west corner at (x, z).
func _spike_rect(x: float, z: float) -> Rect2:
	return Rect2(x, z, SPIKE_PLATE, SPIKE_PLATE)


## What both houses share (their look: GuardianLook, &"armory" or &"chapel"): a square (the way in at the west wall's middle, the NE corner cut
## by a short wall), a floor of `side` m, the guardian rising at boss_spawn, the camera on its middle.
func _guardian_house(l: RoomLayout, id: StringName, guardian_id: StringName, side: float, cut: float, look: StringName) -> void:
	_arena(l, id, RoomLayout.Size.SMALL, 2, Vector2(0.0, 1.0))
	l.look = look
	var h := side * 0.5
	l.floor = FloorShape.poly([_poly([-h, -h, h - cut, -h, h, -h + cut, h, h, -h, h])])
	l.half = l.floor.extent()
	l.max_alive = Vector2i(6, 8)
	l.max_ranged = 3
	l.guardian = true
	l.guardian_home = true
	l.guardian_id = guardian_id
	l.cam_target = Vector2.ZERO
	l.cam_reach = 2.5
	_gate(l, Vector2(0.0, h - 1.5), -h, _guardian_doors(h))


## The Knight's hall (Daniel, 2026-11-23): a square of 22 m, the four corners each with the vault's stones and, beside it,
## a plate that raises spikes; the middle open for the charge (it stuns itself on the wall). Stones from the middle of the
## descent as the others (PLATES_FROM), the spikes with them.
## A guardian's house wakes its hazards from the first guardian's room (progress 0.333 at the 5th), not from the 4th of the others.
const HOUSE_FROM := 0.3
const KNIGHT_SIDE := 22.0
func _knight_hall() -> RoomLayout:
	var l := RoomLayout.new()
	_guardian_house(l, &"knight_hall", &"knight", KNIGHT_SIDE, 2.5, &"armory")
	l.boss_spawn = Vector2(0.0, -7.0)
	l.obstacles = [_bowl(2.3, -11.5)]
	# the second guardian's escort (two mages) rises in the east half, never on a plate
	l.spawns = [_rect(-5, 5, -7.5, -3)]
	l.late_spawns = [_rect(-5, 5, -7.5, -3)]
	# the four corners: where the vault's stones fall (north-west, south-west, south-east, north-east) and, by each, a plate
	var corners: Array[Rect2] = [_rect(-10.6, -6.8, -7.6, -3.8), _rect(-10.6, -6.8, 6.8, 10.6), _rect(6.8, 10.6, 6.8, 10.6),
		_rect(7.2, 10.6, -9.2, -5.4)]
	# RD2-10: the plates lie flush against the walls where the charges end (the knight stops 1.1 m off the wall, in the plate,
	# and is stunned there 1.5 s: it arms at once and strikes after 1.2 s): the west and east middles and the south wall
	# either side of the way in (6 m off it). The paladin chooses the wall the charge will hit (the wall mark shows it).
	var plates: Array[Rect2] = [_spike_rect(-5.9, -10.4), _spike_rect(8.55, -6.4), _spike_rect(-9.0, 8.55), _spike_rect(6.6, 8.55)]
	l.hazard = _spike_plates(plates, HOUSE_FROM)
	l.hazard.also = _rocks(corners)
	l.hazard.also.from_progress = HOUSE_FROM
	_areas(l, ["corner_nw", _rect(-11, -4, -11, -4), "corner_sw", _rect(-11, -4, 4, 11), "corner_se", _rect(4, 11, 4, 11),
		"corner_ne", _rect(4, 11, -11, -4), "middle", _rect(-11, 11, -11, 11)])
	return l


## The Elder's chamber (Daniel, 2026-11-23): a square of 24 m with four tall columns (they stop bodies and orbs), 9 m
## apart, for the paladin to hide behind from the orbs; no hazard, the columns are the room's one decision.
const ELDER_SIDE := 24.0
const ELDER_COLUMNS := [Vector2(-7.5, -2.5), Vector2(7.5, -2.5), Vector2(-4.5, 4.5), Vector2(4.5, 4.5)]
func _elder_hall() -> RoomLayout:
	var l := RoomLayout.new()
	_guardian_house(l, &"elder_hall", &"priest_elder", ELDER_SIDE, 2.5, &"chapel")
	l.boss_spawn = Vector2(0.0, -7.0)
	var a: Array[ArenaObstacle] = [_statue(3.8, -11.1), _bowl(-3.3, -12.5)]
	for p: Vector2 in ELDER_COLUMNS:
		a.append(_column(p.x, p.y, 5.2, 0.9))
	l.obstacles = a
	l.spawns = [_rect(-9, 9, -9, -1)]
	l.late_spawns = [_rect(-9, 9, -9, -1)]
	_areas(l, ["columns", _rect(-8, 8, -8, 8), "walls", _rect(-12, 12, -12, 12)])
	return l


## Ponte dos Condenados (spec section 2, C14-A5): three platforms over the abyss joined by bridges of 5 m (A), or two
## and a long bridge of 24 m with a landing in its middle (B); every door on the far platform (E5-D5), nobody rises on
## a bridge, the shooters on the far side. The ruin in the middle stands east of it: the cover against them.
func _bridge() -> RoomLayout:
	var l := RoomLayout.new()
	_arena(l, &"bridge", RoomLayout.Size.LONG, 2, Vector2(0.4, 1.0))
	var west := _poly([-28, -6, -25, -9, -15, -9, -14, -7, -14, 7, -16, 9, -26, 9, -28, 7])
	var middle := _poly([-7, -6, -5, -8, 5, -8, 7, -6, 7, 6, 5, 8, -5, 8, -7, 6])
	var east := _poly([14, -7, 15, -9, 28, -9, 28, 7, 26, 9, 16, 9, 14, 7])
	# the bridges reach 0.05 m into the platforms, so the union never opens a crack at a seam
	l.floor = FloorShape.poly([west, FloorShape.box(_rect(-14.05, -6.95, -2.5, 2.5)), middle,
		FloorShape.box(_rect(6.95, 14.05, -2.5, 2.5)), east])
	l.half = l.floor.extent()
	l.max_alive = Vector2i(6, 8)
	l.max_ranged = 3
	l.banned_roles = [&"area", &"sweep", &"trap"]  # (C5: the chain of RP-11 never shares the room with the Varredor's bar; C1e: nor with the Armadilheiro's plates)
	l.guardian = false
	# 2026-11-27 (Daniel): both doors on the far wall, inside the frame of --cam-at=-4,3 --cam-dist=94 (x 17 and 22.6, the statue
	# between at 19.8); the tomb moved out of the second door's approach (to the east end, off the east door's too)
	var ends: Array[ArenaObstacle] = [_column(-21.0, -4.0, 3.0), _sarcophagus(25.6, -0.9, 2.5, 1.2), _column(20.0, 4.5, 3.6),
		_statue(19.8, -8.1)]
	var a: Array[ArenaObstacle] = ends.duplicate()
	a.append_array([_piece(0.0, -7.2, 2.8, 1.6, 6.0, &"pylon", true), _piece(2.5, 2.5, 1.0, 3.2, 2.2, &"block", true),
		_column(-2.5, 3.5, 3.4)])
	# RP-04: a block of ruin before the east end of bridge 2, 1.5 m off the deck: the one who crosses lands in cover
	a.append(_piece(16.0, 0.0, 1.0, 2.4, 2.2, &"block", true))
	l.obstacles = a
	var west_b := _poly([-28, -6, -25, -9, -13, -9, -12, -7, -12, 7, -14, 9, -26, 9, -28, 7])
	var east_b := _poly([12, -7, 13, -9, 28, -9, 28, 7, 26, 9, 14, 9, 12, 7])
	# 2026-11-27 (Daniel: B looked like A): B is a zigzag. The first deck leaves the west platform along its south side, the
	# landing is wider than A's middle island, the second deck leaves it along its north side to the east platform: the
	# crossing bends 5 m across the room, one long bridge in two flights with a landing between them
	var long_bridge := FloorShape.poly([west_b, FloorShape.box(_rect(-12.05, -2.95, 0.5, 5.5)),
		FloorShape.box(_rect(-3, 3, -5.5, 5.5)), FloorShape.box(_rect(2.95, 12.05, -5.5, -0.5)), east_b])
	var b := _variant(ends.duplicate(), long_bridge)
	b.spawns = [_rect(17, 24, -7.5, -1), _rect(17, 24, 1, 7.5)]
	_areas(b, ["west", _rect(-28, -12, -9, 9), "landing", _rect(-3, 3, -5.5, 5.5), "bridge", _rect(-12, -3, 0.5, 5.5),
		"bridge", _rect(3, 12, -5.5, -0.5), "east", _rect(12, 28, -9, 9)])
	# RP-11: the chain across the long bridge, one half then the other, never within 4 m of the landing (the shelter)
	b.hazard = _chain([_rect(-11, -9, 0.5, 5.5), _rect(9, 11, -5.5, -0.5)], [Vector2(-CHAIN_PUSH, 0), Vector2(CHAIN_PUSH, 0)])
	l.variants = [b]
	# RP-11: on A one bridge at a time, in turn
	l.hazard = _chain([_rect(-11.5, -9.5, -2.5, 2.5), _rect(9.5, 11.5, -2.5, 2.5)],
		[Vector2(-CHAIN_PUSH, 0), Vector2(CHAIN_PUSH, 0)])
	# RP-07: A in the middle of the descent, B (the long bridge) late
	l.variant_depth = Vector2(0.5, 0.8)
	l.variants[0].depth = Vector2(0.67, 1.0)
	_gate(l, Vector2(-22.0, 6.6), -9.0, [17.0, 22.6])
	l.exits.append(ArenaExit.at_edge(Vector2(28, -5.5), Vector2(-1, 0)))
	# RP-04: everybody rises on the east platform (the middle no more): the room asks to cross under fire
	l.spawns = [_rect(17, 24, -7.5, -1), _rect(17, 24, 1, 7.5)]
	# the second wave closes behind the one who crossed
	l.late_spawns = [_rect(-26, -20, -7, -4)]
	l.cam_bounds = _rect(-14, 14, -1, 3)
	# the question of the room: hold the island or cross
	_areas(l, ["west", _rect(-28, -14, -9, 9), "bridge1", _rect(-14, -7, -3, 3), "middle", _rect(-7, 7, -8, 8),
		"bridge2", _rect(7, 14, -3, 3), "east", _rect(14, 28, -9, 9)])
	return l


## RP-11 (H-3): the chain that sweeps a bridge. A band of 2 m across the deck warms up 1.2 s (as the runes), strikes
## 0.25 s with the numbers of RP-03 (A1: 10 to the paladin, 60 to an enemy) and pushes everyone in it 2.5 m along the bridge
## toward the platform it leads to (never off it); one band every 6 s, in turn, after 3 s of calm.
const CHAIN_PUSH := 2.5


func _chain(bands: Array[Rect2], pushes: Array[Vector2]) -> HazardDef:
	var h := HazardDef.new()
	h.kind = HazardDef.Kind.LINE
	h.bands = bands
	h.band_push = PackedVector2Array(pushes)
	h.warn = 1.2
	h.fire = 0.25
	h.cycle = 6.0
	h.start_delay = 3.0
	h.hero_damage = HAZARD_HERO
	h.enemy_damage = 60.0
	return h


## RP-08 (H-4): the rift that breathes, the flood trap of the Hades II (0 damage, it pushes): every 7 s a stretch of
## the brink (6 x 2 to 3 m) warms up 1.2 s (the mist rising) and pushes everyone in it 2.5 m away from the brink, cutting
## a wind-up or an attack there; after 3 s of calm.
const BREATH_PUSH := 2.5
## RD2-04c: life an enemy loses in the breath (the paladin loses none).
const BREATH_ENEMY := 10.0
## The stretches of the Salão das Fendas where the bot's fights go (measured: the south bridge, the south way and the
## east): the east brink of the middle hole, east of the south hole (by the south bridge) and the south way.
const RIFT_BREATH: Array[Rect2] = [Rect2(2.9, -7, 2.3, 6), Rect2(2.9, 4.2, 2.0, 4.8), Rect2(-8, 10.2, 10, 2)]
const RIFT_BREATH_PUSH: Array[Vector2] = [Vector2(BREATH_PUSH, 0), Vector2(BREATH_PUSH, 0), Vector2(0, BREATH_PUSH)]


func _breath(bands: Array, pushes: Array) -> HazardDef:
	var h := _chain(Array(bands, TYPE_RECT2, &"", null), Array(pushes, TYPE_VECTOR2, &"", null))
	h.band_source = &"breath"
	h.band_busy = true
	h.fire = 0.3
	h.cycle = 7.0
	h.hero_damage = 0.0
	h.enemy_damage = BREATH_ENEMY  # RD2-04c: the breath hurts only them (10), never him
	return h


## SR-P1 (the wall trap, docs/design/rooms_progression.md): a block in the wall (the `trap_block` obstacle, 1.2 x 0.6 m,
## 1.2 m high, stopping bodies and shots) that throws blades along a line 1.2 m across: the HazardDef is a LINE named
## &"trap" (the bands are the lines, band_dir the way they fly), one line at a time, the one with the most enemies in
## it first (band_busy), 1.2 s of warning (as the slabs and the chain), 10 to the paladin (HAZARD_HERO), 60 to an enemy,
## after 5 s of calm and from `from` of the descent. Each spec: [the wall's point, the way the blades fly (unit, axis),
## the metres from the wall to where they stop].
const TRAP_WIDTH := 1.6
const TRAP_HALF := 0.3


func _trap(specs: Array, from: float, cycle: float, cycle_late := 0.0) -> HazardDef:
	var rects: Array[Rect2] = []
	var dirs := PackedVector2Array()
	for sp: Array in specs:
		var at: Vector2 = sp[0]
		var d: Vector2 = sp[1]
		var a := at + d * TRAP_HALF
		var b := at + d * float(sp[2])
		var side := Vector2(-d.y, d.x) * (TRAP_WIDTH * 0.5)
		var r := Rect2(a + side, Vector2.ZERO).expand(a - side).expand(b + side).expand(b - side)
		rects.append(r)
		dirs.append(d)
	var h := _chain(rects, [] as Array[Vector2])
	h.band_source = &"trap"
	h.band_busy = true
	h.band_dir = dirs
	h.cycle = cycle
	h.cycle_late = cycle_late
	h.start_delay = 5.0
	h.from_progress = from
	return h


## SR-P2 (docs/design/rooms_progression.md, "Lote SR-P"): the slab that gives. A PLATES hazard named &"sag": 3 x 3 m of
## cracked floor; someone staying on it (him 0.7 s, an enemy 0.35 s) wakes it: 1.4 s of cracks and dust (the warning is
## longer than the enemies' 1.2 s: he may leave), then it falls, 10 to him and 60 to an enemy standing on it, 8 s before
## the floor is back (6 s from 0.7 of the descent). Asleep before `from` and 5 s of calm at the start.
func _sag(rects: Array[Rect2], from: float) -> HazardDef:
	var h := _plates(rects, from, false)
	h.plate_source = &"sag"
	h.dwell = 0.7
	h.enemy_dwell = 0.35
	h.warn = 1.4
	h.fire = 0.4
	h.rearm = 8.0
	h.rearm_late = 6.0
	h.start_delay = 5.0
	return h


## SR-P3: the pit grate. A LINE named &"spikes": 2.4 m squares, one at a time, the one with most enemies in it first
## (band_busy: draw the pack to it), spikes peeking 1.2 s then up 1.0 s, 10 to him and 60 to an enemy, every 3.5 s (2.8 s
## from 0.7 of the descent), 5 s of calm at the start, asleep before `from`.
const GRATE := 2.4
func _spikes(corners: Array[Vector2], from: float) -> HazardDef:
	var rects: Array[Rect2] = []
	for c in corners:
		rects.append(Rect2(c, Vector2(GRATE, GRATE)))
	var h := _chain(rects, [] as Array[Vector2])
	h.band_source = &"spikes"
	h.band_busy = true
	h.fire = 1.0
	h.cycle = 3.5
	h.cycle_late = 2.8
	h.start_delay = 5.0
	h.from_progress = from
	return h


## The blocks of _trap's specs, to add to the layout's obstacles.
func _trap_blocks(specs: Array) -> Array[ArenaObstacle]:
	var out: Array[ArenaObstacle] = []
	for sp: Array in specs:
		var d: Vector2 = sp[1]
		var half := Vector2(TRAP_WIDTH * 0.5, TRAP_HALF) if absf(d.y) > absf(d.x) else Vector2(TRAP_HALF, TRAP_WIDTH * 0.5)
		out.append(ArenaObstacle.box(sp[0], half, 0.0, &"trap_block", 1.2, true))
	return out


## RP-02: the tiles any part of which lies within 6 m of the way in (hero_spawn (-12.5, 3.5)) never light: columns 0
## and 1 from row 3 to 7, column 2 from row 3 to 6 (the rule of every hazard: never near the door he came in by).
const RUNES_ENTRY: Array[Rect2] = [Rect2(-6, 3, 12, 9)]


## The runes' floor (spec 3.4): tiles of 3 m, 1.2 s warming up, 0.25 s striking, 2.4 s of rest, never in the first
## 3 s; at most 35% of the tiles lit (50% for the dense patterns, with 3 enemies or fewer). It hurts everyone: 10 to the
## paladin (A1, was 7 and 4 before; the Hades hurts 10 on the same 30 of life), 60 to an enemy (a
## whole soldier; was 35): drawing them onto the band that will light is the room's play.
func _hazard(patterns: Array[StringName], quiet: Array[Rect2] = []) -> HazardDef:
	var h := HazardDef.new()
	h.origin = Vector2(-15, -12)
	h.tile = 3.0
	h.cols = 10
	h.rows = 8
	h.warn = 1.5  # RD2-07: 1.5 s (was 1.2) and a share of 30% (was 35%): the runes were 17% of the damage of room 7
	h.fire = 0.25
	h.rest = 2.4
	h.start_delay = 3.0
	h.max_share = 0.30
	h.dense_share = 0.5
	h.dense_standing = 3
	h.patterns = patterns
	h.islands = 4
	h.quiet = quiet
	h.hero_damage = HAZARD_HERO
	h.enemy_damage = 60.0
	return h


## Câmara das Runas Instáveis (spec section 3, C14-A6; name D-33): square, the floor of tiles is the room. A: bands
## (sweep, comb, cut) and four rune pillars at the grid's nodes; B: tiles (checker, frame, islands), two pillars and the
## quiet stone in the middle that never lights. The camera keeps the whole room in view.
func _runes() -> RoomLayout:
	var l := RoomLayout.new()
	_arena(l, &"runes", RoomLayout.Size.MEDIUM, 2, Vector2(0.4, 1.0))
	l.floor = FloorShape.poly([_poly([-15, -9, -12, -12, 12, -12, 15, -9, 15, 9, 12, 12, -12, 12, -15, 9])])
	l.half = l.floor.extent()
	l.max_alive = Vector2i(4, 6)
	l.max_ranged = 2
	l.banned_roles = [&"area"]
	l.guardian = false
	# the north door's fire bowls, 0.9 m out of the floor (drawn, never blocking)
	var bowls: Array[ArenaObstacle] = [_bowl(3.4, -12.9), _bowl(-4.65, -12.9)]
	var a: Array[ArenaObstacle] = []
	for p: Vector2 in [Vector2(-6, -6), Vector2(6, -6), Vector2(-6, 6), Vector2(6, 6)]:
		a.append(_piece(p.x, p.y, 1.2, 1.2, 4.0, &"rune_pillar", true))
	a.append_array(bowls)
	l.obstacles = a
	l.hazard = _hazard([&"sweep", &"comb", &"cut", &"herd", &"herd"], RUNES_ENTRY.duplicate())
	# 2026-11-27: the first pillar was in the mouth of the third door (x -8.8): moved west of it (x -12.2), out of every door's approach
	var b: Array[ArenaObstacle] = [_piece(-12.2, -6, 1.2, 1.2, 4.0, &"rune_pillar", true), _piece(9, 6, 1.2, 1.2, 4.0, &"rune_pillar", true)]
	# the quiet stone in the middle (its four tiles never light, HazardDef.quiet): drawn smooth, it stops nothing
	var quiet := ArenaObstacle.box(Vector2.ZERO, Vector2(3, 3), 0.0, &"quiet", 0.0, false)
	quiet.blocks_move = false
	b.append(quiet)
	b.append_array(bowls)
	var vb := _variant(b)
	var quiet_b: Array[Rect2] = [_rect(-3, 3, -3, 3)]
	quiet_b.append_array(RUNES_ENTRY)
	vb.hazard = _hazard([&"checker", &"frame", &"islands", &"herd", &"herd"], quiet_b)
	# A1, RP-14 (H-5): two crystals by the north wall, off the floor; three blows of his discharge one along its column
	# of tiles (col 3, x -6 to -3; col 8, x 9 to 12), warned 1.2 s, 10 to him and 60 to each enemy on it. Runas B comes
	# from the middle of the descent (RP-07), so they are awake there.
	vb.hazard.crystals = PackedVector2Array([Vector2(-4.5, -12.6), Vector2(10.5, -12.6)])
	vb.hazard.crystal_cols = PackedInt32Array([3, 8])
	vb.hazard.crystal_hits = 3
	vb.hazard.crystal_radius = 0.6
	vb.hazard.crystal_from = 0.5
	# RP-01: the quiet stone, the cross round it, the edge (B's two pillars stand on the edge)
	_areas(vb, ["quiet", _rect(-3, 3, -3, 3), "middle", _rect(-9, 9, -9, 9), "edge", _rect(-15, 15, -12, 12)])
	l.variants = [vb]
	# RP-07: B (the quiet stone, easier) in the middle, A late
	l.variant_depth = Vector2(0.67, 1.0)
	l.variants[0].depth = Vector2(0.5, 0.8)
	_gate(l, Vector2(0.0, 9.5), -12.0, [-0.5, 7.3, -8.8])
	l.spawns = [_rect(-4, 3, -11, -8), _rect(10, 13.5, -4, 4), _rect(-13, -10, -4, 4)]
	l.late_spawns = [_rect(-13, -9, -9.5, -6)]
	l.cam_target = Vector2(0.5, 1.0)
	l.cam_reach = 3.5
	# RP-01: the four tiles round each pillar, the cross between them, the edge
	_areas(l, ["pillars", _rect(-9, -3, -9, -3), "pillars", _rect(3, 9, -9, -3), "pillars", _rect(-9, -3, 3, 9),
		"pillars", _rect(3, 9, 3, 9), "middle", _rect(-9, 9, -9, 9), "edge", _rect(-15, 15, -12, 12)])
	return l


## The Provação's chamber (spec 5.2): small, no fight, the square block in the middle under the light that holds the
## corruption; the cards are taken in front of it, then its doors open (the doors of the room the slab was in: 0 north,
## 1 west, 2 east).
func _trial_room() -> RoomLayout:
	var l := RoomLayout.new()
	_arena(l, &"trial", RoomLayout.Size.SMALL, 0, Vector2(0.0, 0.0))
	l.floor = FloorShape.poly([_poly([-8, -5.5, -6.5, -7, 6.5, -7, 8, -5.5, 8, 5.5, 6.5, 7, -6.5, 7, -8, 5.5])])
	l.half = l.floor.extent()
	l.guardian = false
	l.obstacles = [_piece(0.0, 0.0, 1.2, 1.2, 1.1, &"trial_block")]
	_gate(l, Vector2(0.0, 5.2), -7.0, [-3.4, 3.8])
	l.exits.append(ArenaExit.at_edge(Vector2(-8, -3.0), Vector2(1, 0)))
	l.cam_target = Vector2(0.0, 0.5)
	l.cam_reach = 1.5
	return l


## The Altar Esquecido (spec 6.3): a chapel, the altar against the north wall, two stone benches facing it; its two
## trades stand on the worn slabs before the step; its doors open on the east (and the south front).
func _altar_room() -> RoomLayout:
	var l := RoomLayout.new()
	_arena(l, &"altar", RoomLayout.Size.SMALL, 0, Vector2(0.0, 0.0))
	l.floor = FloorShape.poly([FloorShape.box(_rect(-9, 9, -7, 7))])
	l.half = l.floor.extent()
	l.guardian = false
	# a whole bench and a broken one (spec 6.3)
	l.obstacles = [_piece(0.0, -6.2, 3.6, 1.6, 1.3, &"altar"), _piece(-3.0, -1.0, 2.0, 0.6, 0.9, &"bench"),
		_piece(3.0, -1.5, 2.0, 0.6, 0.9, &"bench_broken"),
		_stand_brazier(8.1, 1.6)]
	# 2026-11-27 (Daniel): the two doors on the back wall (top of the screen), far apart on either side of the altar's
	# tomb, which stands between them (the blind arch over it, the basins either side of it, the doors' arches beyond)
	_gate(l, Vector2(0.0, 5.2), -7.0, [-6.2, 6.2])
	l.cam_target = Vector2.ZERO
	l.cam_reach = 1.5
	return l


# ---------- PT-5: the Santuário's unlock guides (docs/reference/hub.md) ----------

const HUB_GUIDE_DIR := "res://data/hub_guide/"


## One guide per thing that unlocks in the Santuário: the station the camera comes close to, the sentence and when it is due
## (HubGuide.CONDITIONS). A new one is a line here and a text, no code.
func _hub_guide() -> void:
	DirAccess.make_dir_recursive_absolute(HUB_GUIDE_DIR)
	for f in DirAccess.get_files_at(HUB_GUIDE_DIR):
		DirAccess.remove_absolute(HUB_GUIDE_DIR + f)
	var list := [
		[&"portal", HubPlan.PORTAL, &"guide_portal", &"always"],
		[&"tree", HubPlan.TREE, &"guide_tree", &"open"],
		[&"book", HubPlan.BOOK, &"guide_book", &"open"],
		[&"forge", HubPlan.SMITH, &"guide_forge", &"open"],
		# SW-O5: the Ultimate opens at the Árvore (condition "ult": HubGuide.due, milestone batch)
		[&"ult", HubPlan.TREE, &"guide_ult", &"ult"],
		[&"vendor", HubPlan.VENDOR, &"guide_vendor", &"open"],
		[&"account", HubPlan.VINE, &"guide_account", &"account"],
		[&"maga", HubPlan.HEROES, &"guide_maga", &"maga"],
		[&"sworn", HubPlan.PORTAL, &"guide_sworn", &"wins"],
	]
	for i in list.size():
		var g := HubGuideDef.new()
		g.id = list[i][0]
		g.order = i + 1
		g.station = list[i][1]
		g.text_key = list[i][2]
		g.condition = list[i][3]
		_save(g, HUB_GUIDE_DIR + "%02d_%s.tres" % [g.order, g.id])


# ---------- SW-O4: the guided first descent (docs/design/onboarding_sw_o.md) ----------

const FIRST_PATH := "res://data/first_descent.tres"


func _wave_lists(list: Array) -> Array[PackedStringArray]:
	var out: Array[PackedStringArray] = []
	for w: Array in list:
		out.append(PackedStringArray(w))
	return out


func _first_room(layer: int, id: StringName, kind: RunMap.Kind, layout_id: StringName, props: Dictionary = {}) -> FirstRoomDef:
	var r := FirstRoomDef.new()
	r.layer = layer
	r.id = id
	r.kind = kind
	r.layout_id = layout_id
	for k: String in props:
		r.set(k, props[k])
	return r


## Nine rooms, Antessala to Morvath (Sala 0 to 8): the Antessala; the Cripta A (the skeleton alone, then two: the first
## Blessing, Sarael's); the Fendas A (the crossbow, then the crossbow with the soldier; two doors, the Nivael's Blessing or a
## pomegranate); the Jardim A (a pack of rats, then two runners; two doors, the fountain or the Cripta B); the Cripta B (the
## first mix, with the teaching slabs awake); the Casa do Cavaleiro (the Knight alone, 0.7 of his life); the Santuário (the
## mix, no hazard); the shop and Morvath's chamber (his first phase only, 0.6 of his life). The fights are written by hand:
## the long descent's budget, anchors and fixed doors do not touch them. A step with two rooms is a choice of door; every room
## of a step opens on every room of the next. Deviation from the document: Cripta A is the Ossuary variant (1) with no
## hazard and Cripta B the open one (0) with the teaching slabs (their hazard is the variant 0's), so the two do not look alike.
func _first() -> void:
	var R := RunMap.Reward
	var K := RunMap.Kind
	var d := FirstDescentDef.new()
	d.rooms_total = 8
	d.arrival_line = &"arrival_line"
	d.boss_hp_scale = 0.35  # the short Morvath: a newcomer with 4 or 5 Blessings brings his first third down (0.6 killed the robot)
	var bone5 := ["bone_rat", "bone_rat", "bone_rat", "bone_rat", "bone_rat"]
	var rooms: Array = [
		_first_room(0, &"ante", K.ANTE, &"ante", {"objective": &"obj_explore"}),
		_first_room(1, &"crypt_a", K.COMBAT, &"crypt", {"variant": 1, "reward": R.GOLD, "cap": 3,
			"waves": _wave_lists([["skeleton"], ["skeleton", "skeleton"]]),
			"tip": &"first_tip_fight", "objective": &"obj_win"}),
		_first_room(2, &"rift_a", K.COMBAT, &"rift", {"reward": R.GOLD, "cap": 3,
			"waves": _wave_lists([["archer"], ["archer", "archer", "skeleton"]]),
			"tip": &"first_tip_archer", "objective": &"obj_win"}),
		_first_room(3, &"garden_boon", K.COMBAT, &"garden", {"reward": R.BOON, "angel": &"nivael", "cap": 5,
			"waves": _wave_lists([bone5, ["runner", "runner"]]),
			"tip": &"first_tip_hold", "objective": &"obj_win"}),
		_first_room(3, &"garden_pom", K.COMBAT, &"garden", {"reward": R.POM, "cap": 5,
			"waves": _wave_lists([bone5, ["runner", "runner"]]),
			"tip": &"first_tip_hold", "objective": &"obj_win"}),
		_first_room(4, &"fountain", K.FOUNTAIN, &"hall"),
		_first_room(4, &"crypt_b", K.COMBAT, &"crypt", {"reward": R.BOON, "cap": 5, "hazards": true, "hazard_progress": 0.2,
			"waves": _wave_lists([["skeleton", "archer", "bone_rat", "bone_rat", "bone_rat"], ["guard", "skeleton", "archer"]]),
			"tip": &"first_tip_poise", "objective": &"obj_win"}),
		_first_room(5, &"knight", K.MINIBOSS, &"knight_hall", {"reward": R.BOON, "guardian": &"knight", "hp_scale": 1.0,
			"hazards": true, "hazard_progress": HOUSE_FROM + 0.06, "cap": 1,
			"waves": _wave_lists([["knight"]]),
			"tip": &"first_tip_knight", "objective": &"obj_guardian"}),
		_first_room(6, &"sanctuary", K.COMBAT, &"sanctuary", {"reward": R.GOLD, "cap": 5,
			"waves": _wave_lists([["skeleton", "skeleton", "archer"], ["mage", "runner", "bone_rat", "bone_rat", "bone_rat", "bone_rat"]]),
			"objective": &"obj_win"}),
		_first_room(7, &"shop", K.SHOP, &"hall", {"objective": &"obj_shop"}),
		_first_room(8, &"morvath", K.BOSS, &"", {"objective": &"obj_morvath"}),
	]
	for r: FirstRoomDef in rooms:
		d.rooms.append(r)
	_save(d, FIRST_PATH)


# ---------- SW-O5: the milestones that open the Santuário (data only; MilestoneDef is the milestone batch's class) ----------

const MILESTONE_DIR := "res://data/milestones/"
const MILESTONE_SCRIPT := "res://scripts/core/milestone_def.gd"


## One milestone a station (or the Ultimate): `opens`, the descents played (`runs_min`), what else it needs (`needs`: first,
## guardian, win, stone, mastery2) and whether the descents or the need suffice (`any_of`) or both are asked. The table of
## docs/design/onboarding_sw_o.md, SW-O5. Written only when the class exists (the milestone batch brings it): else skipped.
func _milestones() -> void:
	if not ResourceLoader.exists(MILESTONE_SCRIPT):
		print("milestones: ", MILESTONE_SCRIPT, " not there yet, skipped")
		return
	var script: GDScript = load(MILESTONE_SCRIPT)
	DirAccess.make_dir_recursive_absolute(MILESTONE_DIR)
	for f in DirAccess.get_files_at(MILESTONE_DIR):
		DirAccess.remove_absolute(MILESTONE_DIR + f)
	var rows := [
		# [id, opens, runs_min, needs, any_of] (the values of Milestones.defaults())
		[&"tree", HubPlan.TREE, 0, [&"first"], false],
		[&"forge", HubPlan.SMITH, 3, [&"guardian"], true],
		[&"book", HubPlan.BOOK, 3, [], false],
		[&"account", HubPlan.VINE, 4, [], false],
		[&"vendor", HubPlan.VENDOR, 5, [&"stone"], true],
		[&"ult", &"ult", 6, [&"mastery2"], false],
		[&"maga", HubPlan.HEROES, 0, [&"win"], false],
	]
	for i in rows.size():
		var m: Resource = script.new()
		m.set("id", rows[i][0])
		m.set("order", i)
		m.set("opens", rows[i][1])
		m.set("runs_min", rows[i][2])
		var needs: Array[StringName] = []
		for n: StringName in rows[i][3]:
			needs.append(n)
		m.set("needs", needs)
		m.set("any_of", rows[i][4])
		_save(m, MILESTONE_DIR + "%02d_%s.tres" % [i, rows[i][0]])


# ---------- E6: the Juramentos (D-63; docs/design/e6_juramentos.md) ----------

const JURAMENTO_DIR := "res://data/juramentos/"


func _juramento(order: int, id: StringName, stat: StringName, values: Array, weights: Array, shown := JuramentoDef.Shown.MORE) -> void:
	var j := JuramentoDef.new()
	j.id = id
	j.order = order
	j.name_key = StringName("jur_%s" % id)
	j.desc_key = StringName("jur_%s_desc" % id)
	j.stat = stat
	j.values = PackedFloat32Array(values)
	j.weights = PackedInt32Array(weights)
	j.shown = shown
	_save(j, JURAMENTO_DIR + "%02d_%s.tres" % [order, id])


## The vows of Hades II's Oath of the Unseen that map to what the run already has, with its numbers and its Fear per
## rank (the Peso; docs/design/hades2_sistemas.md, Votos da Noite e Medo). Pain, Grit, Frenzy, Hordes, Scars, Debt and
## Denial as there; Menace (foes of the next region) as more elites; Rivals (new moves) as a Morvath who rests less and
## raises more. Left out: Wards, Return, Fangs, Shadow, Forfeit, Time, Void, Hubris (docs/design/e6_juramentos.md).
func _juramentos() -> void:
	DirAccess.make_dir_recursive_absolute(JURAMENTO_DIR)
	for f in DirAccess.get_files_at(JURAMENTO_DIR):
		DirAccess.remove_absolute(JURAMENTO_DIR + f)
	_juramento(0, &"pain", &"enemy_damage_pct", [0.2, 0.6, 1.0], [1, 2, 2])
	_juramento(1, &"grit", &"enemy_hp_pct", [0.1, 0.2, 0.3], [1, 1, 1])
	_juramento(2, &"frenzy", &"enemy_speed_pct", [0.2, 0.4], [3, 3])
	_juramento(3, &"hordes", &"enemy_count_pct", [0.2, 0.4, 0.6], [1, 1, 1])
	_juramento(4, &"menace", &"elite_pct", [0.1, 0.25], [1, 2])
	_juramento(5, &"scars", &"heal_pct", [-0.25, -0.5, -1.0], [1, 1, 2], JuramentoDef.Shown.LEFT)
	_juramento(6, &"debt", &"price_pct", [0.4, 0.8], [1, 1])
	_juramento(7, &"denial", &"boon_denial", [2.0], [2], JuramentoDef.Shown.COUNT)
	_juramento(8, &"rivals", &"boss_rival", [0.25], [2])


# ---------- Rejogabilidade, Fatia 1 ----------

const FORGE_DIR := "res://data/forge/emeth/"


func _forge_rank(n: int, id: StringName, rank: int, cost: int, mods: Array[BoonMod], track: StringName = &"temper",
		slot: StringName = &"", tool: StringName = &"", material: StringName = MaterialPurse.SILVER) -> void:
	var r := ForgeRank.new()
	r.id = id
	r.track = track
	r.slot = slot
	r.tool = tool
	r.rank = rank
	r.name_key = StringName("forge_" + id)
	r.desc_key = StringName("forge_%s_desc" % id)
	if track == Forge.INSCRIBE:
		# (an inscribed Encanto reads as the Encanto: its own name and text)
		r.name_key = StringName("enchant_" + id)
		r.desc_key = StringName("enchant_%s_desc" % id)
	r.material = material
	r.cost = cost
	r.mods = mods
	_save(r, FORGE_DIR + "%02d_%s.tres" % [n, id])


## The Forja da Emeth (sistemas.md 1.5; Q-RJ7 a: the first rank early and small): Temperar I, the attack 10% more
## damage (tag light: the three cuts, the Corte Veloz and the attack's Omega), 15 Prata; Temperar II, the special and
## its Omega 10% more (tag heavy), 35 Prata. A blow sums each matching mod once, so no move gets both but the
## lance (light) never counts II: "the Omegas" are the attack's by I and the special's by II.
## Ofícios, Roteiro A (docs/design/oficios/15_prototipo.md, Q-OF1 to Q-OF4, Q-OF6 a, Q-OF11 a): the pick's journey in
## one resource (OficiosDef): restored for 20 Prata, the Pedra Funda capped at 10, two veins a descent in the Fendas and
## the Runas past the guardian, the head's room between depths 4 and 8, the guardian gives it after 2 misses, the
## Vendedor's order of 2 Pedra Funda and 30 Prata makes the angels' preview.
## The Obras of the Santuário (Fatia 3, sistemas.md 1.7, working names), made at the Vendedor once his stall is open:
## Altar Restaurado (the altar comes in 35% of its layers, was 20), Fonte Viva (it heals 55%, was 40) and Banca da Rota
## (the shop on the way, 4 items, was 3).
func _obras() -> void:
	var dir := "res://data/obras/"
	DirAccess.make_dir_recursive_absolute(dir)
	for f in DirAccess.get_files_at(dir):
		DirAccess.remove_absolute(dir + f)
	var list := [
		[&"obra_altar", {OficiosDef.SILVER: 40, OficiosDef.MEMORY: 4}, {"altar_chance": 0.35}],
		[&"obra_fonte", {OficiosDef.SILVER: 30, OficiosDef.MEMORY: 3}, {"fountain_heal": 0.55}],
		[&"obra_banca", {OficiosDef.SILVER: 50, OficiosDef.EMERALD: 1}, {"route_shop_items": 4}],
	]
	for i in list.size():
		var o := ObraDef.new()
		o.id = list[i][0]
		o.name_key = o.id
		o.desc_key = StringName(String(o.id) + "_desc")
		o.cost = list[i][1]
		o.stage = list[i][2]
		ResourceSaver.save(o, dir + "%02d_%s.tres" % [i, o.id])


func _oficios() -> void:
	DirAccess.make_dir_recursive_absolute("res://data/oficios/")
	var d := OficiosDef.new()
	d.restore_cost = {OficiosDef.SILVER: 20}
	d.stone_cap = 10
	d.vein_arenas = [&"rift", &"runes"] as Array[StringName]
	d.veins_max = 2
	d.vein_hold = 1.0
	d.vein_stones = 1
	d.find_depth_min = 4
	d.find_depth_max = 11
	d.pity_runs = 2
	d.order_wants = {&"pedra_funda": 2, OficiosDef.SILVER: 30}
	ResourceSaver.save(d, "res://data/oficios/oficios.tres")


## A Videira (Daniel 2026-11-23, docs/design/videira_pacote_2026-11-23/; it replaced "O Preparo"): 3 branches of 3 nodes (Vida has 5), no
## damage, small permanent improvements for every hero. Costs 5, 10 and 20 a branch (the package's): Vida and
## Perseverança in Prata Antiga, Provisão in Fragmento de Memória. File order = purchase order within a branch; the robot
## (--vine=N, also --account=N) takes step 1 of every branch, then step 2, then step 3 (Vine.first).
func _vine() -> void:
	var dir := "res://data/vine/"
	DirAccess.make_dir_recursive_absolute(dir)
	for f in DirAccess.get_files_at(dir):
		DirAccess.remove_absolute(dir + f)
	var S := MaterialPurse.SILVER
	var M := MaterialPurse.MEMORY
	var costs := {&"vida": [5, 10, 20, 30, 12], &"provisao": [3, 6, 10], &"perseveranca": [5, 10, 20]}
	var list := [
		# redesign 2026-11-24 (04_PLANO A.5 and G): Respiro and Ainda de Pé, the Gifts the Warrior and the Maga lost, are steps 4 and
		# 5 of Vida (Prata 30; Memória 12, as the Gift it replaces cost 5 of Memória); no fourth branch, no new trunk art
		[&"vida", S, [[&"vida_1", &"max_hp", 5], [&"vida_2", &"max_hp", 5], [&"vida_3", &"max_hp", 5],
			[&"respiro", &"room_heal", 2], [&"ainda_de_pe", &"rise_share", 0.5]]],
		[&"provisao", M, [[&"viajante", &"traveler", 1], [&"estoque", &"shop_extra", 1], [&"reserva", &"shop_care", 1]]],
		[&"perseveranca", S, [[&"prata", &"silver_pct", 0.25], [&"memoria", &"memory_pct", 0.25], [&"materiais", &"material_pct", 0.25]]],
	]
	var i := 0
	for branch: Array in list:
		for step in (branch[2] as Array).size():
			var row: Array = branch[2][step]
			var n := VineNode.new()
			n.id = row[0]
			n.branch = branch[0]
			n.step = step + 1
			n.requires = branch[2][step - 1][0] if step > 0 else &""
			n.material = M if row[0] == &"ainda_de_pe" else branch[1]
			n.cost = costs[branch[0]][step]
			n.name_key = StringName("vine_" + n.id)
			n.desc_key = StringName("vine_%s_desc" % n.id)
			var mods: Array[BoonMod] = []
			mods.assign([_fixed(row[1], row[2])])
			n.mods = mods
			_save(n, dir + "%02d_%s.tres" % [i, n.id])
			i += 1


func _forge() -> void:
	DirAccess.make_dir_recursive_absolute(FORGE_DIR)
	for f in DirAccess.get_files_at(FORGE_DIR):
		DirAccess.remove_absolute(FORGE_DIR + f)
	_forge_rank(0, &"temper_1", 1, 20, [_fixed(&"damage_pct", 0.2, [], &"light")] as Array[BoonMod])
	_forge_rank(1, &"temper_2", 2, 45, [_fixed(&"damage_pct", 0.2, [], &"heavy")] as Array[BoonMod])
	# Fatia 2: Temperar III (C2), every blow of the Emeth 10% more (the attack's and the special's tags; no blow has both), 60
	_forge_rank(2, &"temper_3", 3, 60, [_fixed(&"damage_pct", 0.1, [], &"light"), _fixed(&"damage_pct", 0.1, [], &"heavy")] as Array[BoonMod])
	# Refinar (sistemas.md 1.5): a choice on each action, 25 Prata each, opened by the Forjador's first tool; Fio
	# (reach), Peso (more Quebra worn) and Pressa (the blows faster) on the attack, their twins on the special
	var R := Forge.REFINE
	var tool := Forge.TOOL_REFINE
	_forge_rank(10, &"refine_fio", 1, 25, [_fixed(&"reach_pct", 0.1, [], &"light")] as Array[BoonMod], R, &"attack", tool)
	_forge_rank(11, &"refine_peso", 1, 25, [_fixed(&"poise_pct", 0.2, [], &"light")] as Array[BoonMod], R, &"attack", tool)
	_forge_rank(12, &"refine_pressa", 1, 25, [_fixed(&"blow_speed", 0.08, [], &"light")] as Array[BoonMod], R, &"attack", tool)
	_forge_rank(13, &"refine_onda_larga", 1, 25, [_fixed(&"wave_size_pct", 0.2, [], &"heavy")] as Array[BoonMod], R, &"special", tool)
	_forge_rank(14, &"refine_onda_pesada", 1, 25, [_fixed(&"poise_pct", 0.3, [], &"heavy")] as Array[BoonMod], R, &"special", tool)
	_forge_rank(15, &"refine_onda_pronta", 1, 25, [_fixed(&"blow_speed", 0.08, [], &"heavy")] as Array[BoonMod], R, &"special", tool)
	# Fatia 3 (sistemas.md 1.5, working names): Despertar, one property of the blade awake at a time, in Esmeralda,
	# opened by the second tool: Sede (0.5 life a kill), Ímpeto (3 Magia more on each finisher), Eco Longo (each
	# finisher strikes again 0.25 s later for a third, as the Eco da Verdade)
	var A := Forge.AWAKEN
	var wake := Forge.TOOL_AWAKEN
	_forge_rank(20, &"awaken_sede", 1, 2, [_fixed(&"heal_on_kill", 0.5)] as Array[BoonMod], A, &"blade", wake, MaterialPurse.EMERALD)
	_forge_rank(21, &"awaken_impeto", 1, 3, [_fixed(&"finisher_magick", 3)] as Array[BoonMod], A, &"blade", wake, MaterialPurse.EMERALD)
	_forge_rank(22, &"awaken_eco", 1, 4, [_fixed(&"echo_pct", 0.33, [], &"finisher"), _fixed(&"echo_delay", 0.25, [], &"finisher")] as Array[BoonMod],
		A, &"blade", wake, MaterialPurse.EMERALD)
	# Inscrever: each Encanto past the first three learned for 20 Prata (the rank's id is the Encanto's), opened by the
	# third tool; no numbers of its own (the Encanto's are summed when taken in a descent)
	for i in INSCRIBED.size():
		_forge_rank(30 + i, INSCRIBED[i], 1, 20, [] as Array[BoonMod], Forge.INSCRIBE, INSCRIBED[i], Forge.TOOL_INSCRIBE)


const ANGEL_DIR := "res://data/angels/"
const ENCHANT_DIR := "res://data/enchants/"


## The Encantos learned at the Forja (Inscrever, Fatia 3); the first three come learned.
const INSCRIBED: Array[StringName] = [&"corte_sismico", &"onda_gemea"]
## GP-1 (D-13): the Encantos that read the Investida, which left the Warrior: they stay in the catalog, never offered.
const RESERVE_ENCHANTS: Array[StringName] = [&"retorno_do_corte", &"eco_do_passo"]


func _enchant(n: int, id: StringName, slot: Boon.Slot, mods: Array[BoonMod], excludes: Array[StringName] = []) -> void:
	var e := EnchantDef.new()
	e.id = id
	e.name_key = StringName("enchant_" + id)
	e.desc_key = StringName("enchant_%s_desc" % id)
	e.slot = slot
	e.mods = mods
	e.excludes = excludes
	e.learned = not INSCRIBED.has(id)
	e.reserve = RESERVE_ENCHANTS.has(id)
	_save(e, ENCHANT_DIR + "%02d_%s.tres" % [n, id])


## The Encantos of the Fatia 2 (sistemas.md 1.7, auditoria.md 3.1: the Lapidação of hades2_sistemas.md 6, Hades II's
## hammer), all three learned from the start: Lâmina Tríplice, the spin throws three waves in a fan, 12 each, 6 m (the
## Corte Crescente's substitute: never with it); Eco da Verdade, the spin strikes again 0.3 s later for half; Retorno
## do Corte, within 1 s of a Corte Veloz the next blow reaches 30% farther and wider (never with the dash's chains).
func _enchants() -> void:
	DirAccess.make_dir_recursive_absolute(ENCHANT_DIR)
	for f in DirAccess.get_files_at(ENCHANT_DIR):
		DirAccess.remove_absolute(ENCHANT_DIR + f)
	var S := Boon.Slot
	var fan := _wave(&"spin", 30.0, 6.0, 3.0)
	fan.append(_fixed(&"blow_wave_fan", 2, [], &"spin"))
	_enchant(0, &"lamina_triplice", S.ATTACK, fan, [&"corte_crescente"] as Array[StringName])
	_enchant(1, &"eco_da_verdade", S.ATTACK, [_fixed(&"echo_pct", 0.5, [], &"spin"), _fixed(&"echo_delay", 0.3, [], &"spin")] as Array[BoonMod])
	_enchant(2, &"retorno_do_corte", S.DASH, [_fixed(&"return_time", 1.0, [], &"dash"), _fixed(&"return_reach", 0.3, [], &"dash")] as Array[BoonMod],
		[&"passo_encadeado", &"fio_do_passo"] as Array[StringName])
	# Fatia 3 (RJ-8; auditoria.md 3.1, working names), learned at the Forja (Inscrever): Corte Sísmico, the spin
	# strikes the floor: a pulse of 4.5 m for 25 round him (past the spin's 3 m); Onda Gêmea, the special throws two smaller waves in a fan,
	# 15 each, 9 m (never with the Onda Carregada); Eco do Passo, the Corte Veloz strikes again 0.3 s later for half
	# (never with the Retorno do Corte, the same dash)
	_enchant(3, &"corte_sismico", S.ATTACK, [_fixed(&"ground_pulse", 38.0, [], &"spin"), _fixed(&"ground_pulse_m", 4.5, [], &"spin")] as Array[BoonMod])
	var twin := _wave(&"heavy", 38.0, 9.0, 2.4)
	twin.append(_fixed(&"blow_wave_fan", 2, [], &"heavy"))
	twin.append(_fixed(&"blow_wave_side", 1, [], &"heavy"))
	_enchant(4, &"onda_gemea", S.SPECIAL, twin, [&"onda_carregada"] as Array[StringName])
	_enchant(5, &"eco_do_passo", S.DASH, [_fixed(&"echo_pct", 0.5, [], &"dash"), _fixed(&"echo_delay", 0.3, [], &"dash")] as Array[BoonMod],
		[&"retorno_do_corte"] as Array[StringName])


func _angel(n: int, id: StringName, family: Boon.Family, symbol: int, color: Color) -> void:
	var a := AngelDef.new()
	a.id = id
	a.family = family
	a.name_key = StringName("angel_" + id)
	a.line_key = StringName("angel_%s_line" % id)
	a.symbol = symbol
	a.color = color
	_save(a, ANGEL_DIR + "%02d_%s.tres" % [n, id])


## The four angels (sistemas.md 4, Q-RJ4 approved 2026-11-19, working names): one a family, the seal in the family's
## colour (the seal's, AngelSeal.TINT: calmer than Boon.FAMILY_COLOR).
func _angels() -> void:
	DirAccess.make_dir_recursive_absolute(ANGEL_DIR)
	for f in DirAccess.get_files_at(ANGEL_DIR):
		DirAccess.remove_absolute(ANGEL_DIR + f)
	var F := Boon.Family
	# the colors are the seals' (AngelSeal.TINT): Chama earthy amber, Geada, Luz, Vigília sage
	_angel(0, &"sarael", F.CHAMA, 0, Color(0.82, 0.5, 0.27))
	_angel(1, &"nivael", F.GEADA, 1, Color(0.58, 0.76, 0.88))
	_angel(2, &"lumael", F.LUZ, 2, Color(0.92, 0.82, 0.56))
	_angel(3, &"shomael", F.VIGILIA, 3, Color(0.58, 0.68, 0.43))
	# AN-2 (sistemas.md 4.1): Velael (the veil folded into a drop), Galael (three waves), Qeshael (an arrowhead in a ring)
	_angel(4, &"velael", F.VEU, 4, Color(0.7, 0.66, 0.6))
	_angel(5, &"galael", F.MARE, 5, Color(0.3, 0.48, 0.78))
	_angel(6, &"qeshael", F.MARCA, 6, Color(0.66, 0.58, 0.3))
	# Blessings V2: Zerael (Peste: a drop with its bubbles) and Saarael (Trovao, id thunder: a bolt), seal symbols 7 and 8
	_angel(7, &"zerael", F.PESTE, 7, Color("9fae7a"))
	_angel(8, &"thunder", F.TROVAO, 8, Color("7d8590"))


# ---------- the Gifts medallion (docs/art/dons_medallion_spec.md 3) ----------

## Node places per hero, "from the centre" (Daniel, 2026-11-25): the crown (Maestria and the lion) is the medallion at the
## middle, over the hero's figure; each branch leaves it along its own axis (up, bottom right, bottom left, 120 degrees
## apart) with four Gifts: a small entry by the crown, two middles side by side, the big apex at the tip.
## [id, angle (degrees from twelve o'clock, clockwise), radius, diameter]. A new Gift is a new id in a list below.
const MEDALLION_AXES := [0.0, 120.0, 240.0]
const MEDALLION_ENTRY := [88.0, 44.0]
const MEDALLION_MIDDLE := [170.0, 56.0]
const MEDALLION_SIDE := 14.3
const MEDALLION_APEX := [240.0, 76.0]
const MEDALLION_WARRIOR := [
	[&"disciplina", &"cadencia", &"maestria_marcial", &"apogeu"],
	[&"ruptura", &"alcance_marcial", &"imposicao", &"investida_implacavel"],
	[&"forca_concentrada", &"determinacao", &"concentracao", &"forca_titanica"],
]
const MEDALLION_MAGA := [
	[&"afinidade", &"catalisador", &"propagacao", &"trindade"],
	[&"permanencia", &"expansao", &"manifestacao", &"confluencia"],
	[&"fluxo_arcano", &"agilidade_arcana", &"reciprocidade", &"transcendencia"],
]


## The rows of a hero's branches: [entry, middle left, middle right, apex] on each axis, after the crown at the centre.
func _medallion_rows(branches: Array) -> Array:
	var rows: Array = [[&"crown", 0.0, 0.0, 72.0]]
	for i in branches.size():
		var ax: float = MEDALLION_AXES[i]
		var ids: Array = branches[i]
		rows.append([ids[0], ax, MEDALLION_ENTRY[0], MEDALLION_ENTRY[1]])
		rows.append([ids[1], ax - MEDALLION_SIDE, MEDALLION_MIDDLE[0], MEDALLION_MIDDLE[1]])
		rows.append([ids[2], ax + MEDALLION_SIDE, MEDALLION_MIDDLE[0], MEDALLION_MIDDLE[1]])
		rows.append([ids[3], ax, MEDALLION_APEX[0], MEDALLION_APEX[1]])
	return rows


func _medallion() -> void:
	for pair: Array in [["warrior", _medallion_rows(MEDALLION_WARRIOR), []], ["maga", _medallion_rows(MEDALLION_MAGA), []]]:
		var m := MedallionDef.new()
		m.hero = StringName(pair[0])
		for row: Array in pair[1]:
			var n := MedallionNodeDef.new()
			n.id = row[0]
			n.kind = MedallionNodeDef.Kind.CROWN if n.id == MedallionDef.CROWN_ID else (MedallionNodeDef.Kind.ULT if (pair[2] as Array).has(n.id) else MedallionNodeDef.Kind.GIFT)
			n.angle = float(row[1])
			n.radius = float(row[2])
			n.diameter = float(row[3])
			m.nodes.append(n)
		_save(m, MedallionDef.path_of(String(pair[0])))
