class_name EnemyDef
extends Resource
## One kind of enemy. A new enemy with an existing behaviour and an already baked model is a new .tres in
## data/enemies, no code. Distances in meters, speeds in meters per second.

## CHASE: walks up and swings. ARCHER: keeps to the far end of its reach, runs when the paladin comes closer than
## keep_away of it, and shoots (shot_*; speed 0: it never moves and only shoots). RUNNER: marks a line and lunges
## along it. CASTER: conjures a circle under the paladin (no enemy uses it now: circles on the floor are Morvath's,
## Daniel, 2026-11-16). KNIGHT: charges along a long line, and slams the ground (close_*) when the paladin is near.
## PRIEST: raises skeletons and shoots a fan of orbs.
## PULSE: runs in and bursts all around itself. CONE: stops and blasts a wide cone ahead.
## SWEEP (C5, the Varredor): rooted, it lays a bar of floor along a line (the wind-up shows where it starts and the way it
## turns) and swings it round itself (sweep_*); within sweep_clear m of it the bar does not hurt.
## SUPPORT (C1e, the Gritador and the Coveiro): never strikes; keeps attack_range m from the paladin, runs from him closer than
## retreat_far (flee_speed), and every attack_cooldown s stands attack_windup s and calls: a shout (shout_*), the dead (raise_*) or a
## spiked plate on the floor (plate_*, the Armadilheiro).
## BEAM (C1e, lote C, the Canalizador): rooted, it holds a thin beam on the paladin: a line that shows attack_windup s (it follows him, locked the
## last aim_lock s), then shot_ticks pulses shot_interval s apart of attack_damage on whoever stands in it (attack_width across, attack_range long,
## none within sweep_clear m of it), the line turning after him at shot_turn degrees a second. A cut (the Quebra) ends it.
enum Behavior { CHASE, ARCHER, RUNNER, CASTER, KNIGHT, PRIEST, BOSS, PULSE, CONE, SWEEP, SUPPORT, LEAP, BEAM }
## What its wind-up shows besides the pose and the warning on the floor (EnemyFx; never red, gone when the attack
## is loosed). GLINT: a pale gleam on the raised blade. TREMBLE: dust at its feet (with windup_shake).
## ORB: its staff's orb swells and sparks spiral up from it. BOLT: a pale spark at the tip of the bolt as it looses.
## SHIELD: a pale stroke on the shield's edge at the blow. RITUAL: a thin ring of its magic around it and motes
## turning between its hands.
enum Tell { NONE, GLINT, TREMBLE, ORB, BOLT, SHIELD, RITUAL }

@export var id: StringName
@export var name_key: StringName
@export_group("Look")
## Baked model in assets/baked (tools/bake.gd).
@export var model: StringName = &"skeleton"
## Its own palette over the baked model's (tools/make_palettes.gd): the elites wear the gilded one. Empty: the model's.
@export var palette: Texture2D
@export var size := 1.0
@export var tint := Color.WHITE
## Glow around the edges (elites and the boss stand out from the crowd).
@export var rim_color := Color(0.4, 0.55, 1.0)
@export var rim := 0.0
## How much of its steel is old gold (0..1): the elites of the painted figures, the same model as the common one.
@export var gild := 0.0
## Colour of its magic (bolts, the burst where its blows land, the fan of its volley). Alpha 0: the default look.
@export var magic_color := Color(0, 0, 0, 0)
## Colour added to the painting or taken from it (crowd.gdshader): above 0 the figure is more saturated than the
## crowd (Morvath's violet robes, the priests' purple), below 0 greyer (the soldier is the crowd's base line).
@export var vivid := 0.0
## A pale light on the edges of the top of the figure, cutting it out of the dark floor (Morvath's crown).
@export var crest := 0.0
## How much more than the crowd the painting's eyes and gems shine (1: as everyone; CrowdRenderer.PAINT_GLOW).
@export var shine := 1.0
## Degrees its trunk sways from side to side as it runs, unsteady, once to each side a stride (drawn only: Horde.stride_lean).
@export var sway := 0.0
## Meters it trembles during its wind-up (drawn only: Horde.SHAKE_HZ).
@export var windup_shake := 0.0
## The effect of its wind-up, and where it sits on the figure: meters at size 1, x to its right, y up, z ahead
## (the tip of the blade, the orb of the staff, the tip of the bolt, the shield's edge, between the hands).
@export var tell: Tell = Tell.NONE
## PT-1 (Daniel, 2026-11-23): whether its blows lay a mark on the floor. False: a melee blow or a shot is told only by the
## "!" over its head (Horde.strike_in, EnemyFx.alert), its zone still exists but is not drawn (Ground.mute). True: it is an
## area (a circle, a bar, a beam), drawn as before.
@export var ground_warning := false
@export var tell_at := Vector3.ZERO
@export_group("Body")
@export var behavior: Behavior = Behavior.CHASE
@export var hp := 20.0
@export var speed := 2.5
## Damage when it touches the paladin.
@export var damage := 6.0
@export var radius := 0.45
## Its body stops the paladin and he stops it (BodyBlock; Hades II: StopsUnits). false: a body he walks through
## and that walks through him (a swarm, a wisp), still kept apart from the other enemies.
@export var blocks_body := true
@export var xp := 1
## The risen dead take more damage from the Luz gifts.
@export var undead := true
## Heavy enemies cannot be launched or pushed far, and freeze for less time.
@export var heavy := false
@export var elite := false
## A yellow bar over the life bar: blows wear it down first and do not push or stun while it holds.
## When it breaks the enemy staggers for armor_stagger seconds. 0 = no armor.
@export var armor := 0.0
@export var armor_stagger := 1.5
## C1b, the Quebra (Poise): poise a common enemy has, worn by each button's blows (Feel.poise_weights); 0 = none (elites,
## guardians, bosses and the Trinca keep their own rules). On breaking: stunned poise_stun seconds, its wind-up cut, it takes
## poise_vuln more damage meanwhile, then the poise is full again; poise_idle seconds with no blow that wore it also refill it.
@export var poise := 0.0
@export var poise_stun := 1.2
@export var poise_vuln := 0.4
@export var poise_idle := 4.0
## SW-C5 (SWORN's stagger bar): the elites, the guardians and the Capitão have poise too. poise_mult: the share of a common's of each
## blow they take (as BossDef.posture_mult; 1: the same); poise_growth: each break after the first needs this many times more
## (SWORN 1.25; 1: always the same, the commons').
@export var poise_mult := 1.0
@export var poise_growth := 1.0
## SW-C8: a blow never pushes it (SWORN's immuneToKnockback: the Capitão and the bosses); `heavy` only pushes it less.
@export var no_push := false
## SW-C7: a kind that comes in a pack (EncounterGen): never fewer than this many heads in a wave it is in (0: as many as its rating buys).
@export var pack_min := 0
## ... and never more than this many in one wave (0: no limit; SW-C7: 6).
@export var pack_max := 0
## GF-12 (D-42, Hades II per enemy): seconds a blow that wounds it stuns it (it stops, a wind-up or an attack under
## way is cut and never lands, its warning on the floor goes; Horde.flinch). Hades plays its StunAnimations; their
## length is in the animations, not the scripts: ours is the hit pose's (Horde.HURT_TIME). 0: never (Hades
## ImmuneToStun: the guardians and Morvath). An elite's armor keeps it from flinching until it breaks.
@export var stun_time := 0.0
## The same for a strong blow (finishers, Omegas: Hades' Heavy stun, the same pose played slower).
@export var stun_heavy_time := 0.0
## Its own attack once loosed is not cut (Hades WeaponSetImmuneToStun: a charge in flight); the wind-up still is.
@export var stun_immune_attacking := false
## What a blow sounds on (CombatSounds.MATERIALS): bone, shield, armor (a guardian's plate), spectral (Morvath).
## A blow on the armor bar always sounds armor.
@export var material: StringName = &"bone"

@export_group("Attack")
## Damage of its special attack (bolt, lunge, circle, charge).
@export var attack_damage := 10.0
@export var attack_range := 0.0
@export var attack_cooldown := 2.5
## Warning time before the attack lands. Every attack is announced.
@export var attack_windup := 0.6
## E1c (Hades II's PostAttackDuration, the punish window): seconds it stands still after its attack, showing the
## end of its blow (Enemy.State.RECOVER) before it walks again. A blow there stuns it but cuts nothing (the window is
## already open). 0: it walks at once.
@export var recover_time := 0.0
## Daniel, 2026-11-23: the rest between the end of its recovery and its next wind-up is random, uniform in
## [gap_min, gap_max] at full life and sliding to [gap_min0, gap_max0] at none (AttackGap; a knight's life is its toughness).
## gap_max 0: the old rest (Horde.AFTER_RECOVER).
@export var gap_min := 0.0
@export var gap_max := 0.0
@export var gap_min0 := 0.0
@export var gap_max0 := 0.0
## T5-01 (docs/design/combat_cadence.md 6.3): its wind-up is drawn in three beats. Settle: windup_settle seconds, the
## body stops and fades from its walk to its guard. Arm: its wind-up clip, eased in and out, until the last
## windup_hold share of the wind-up. Hold: that share, the armed pose (or its own *_hold loop) with windup_shake.
## The settle is also how long its last clip fades into the wind-up (T5-05: the crossbow rising to the shoulder).
@export var windup_settle := 0.12
@export var windup_hold := 0.3
## QW-104 P2 (combat_cadence.md 8.1; Hades II lights the body over the last min(0.5 s, wind-up)): seconds before the
## blow over which its body clears in "about to strike", whatever share of the wind-up its held pose takes.
@export var tell_time := 0.5
## T5-09: seconds into its attack at which its blow lands (a soldier's blade down, a runner's arms open): the warning
## on the floor fills until that frame, and the damage is dealt there from where its body is.
@export var strike_at := 0.0
## RUNNER (T5-09): its blade's reach from the edge of its body when it lands (meters at size 1) and the arc ahead.
@export var strike_reach := 1.1
@export var strike_degrees := 120.0
## C19-1, C19-2 (Q-11; Hades II's elites, docs/design/combat_cadence.md 8.2): blows in one attack, strike_gap seconds
## apart. RUNNER: the second blade aims where the paladin stood at the end of the wind-up (its thread shows from the
## wind-up on); PULSE: a second burst where its body is, its ring born on the frame of the first. A stun cuts the rest.
@export var strikes := 1
@export var strike_gap := 0.2
## RUNNER and KNIGHT: speed of the lunge or charge (m/s) and how long it lasts.
@export var lunge_speed := 14.0
@export var lunge_time := 0.45
## KNIGHT: charges in a row (the guardian's second, braced again for recharge_windup where the first one ended).
@export var charges := 1
@export var recharge_windup := 0.8
## KNIGHT and RUNNER (CV-1, CB-4; Daniel, 2026-11-22): the blow's line follows the paladin through its wind-up and
## holds still for the last aim_lock seconds (0: it is locked from the start, as the shield-bearer's).
@export var aim_lock := 0.0
## KNIGHT (CV-2): as the fight opens and every raise_every rows of charges it stops and raises raise_count skeletons, never more than raise_max
## of its own standing (raise_count 0: it raises none).
@export var raise_count := 0
@export var raise_every := 1
@export var raise_max := 4
## C1e: whom it raises (an EnemyDef id; the knight and the elder raise the soldier) and, for a SUPPORT, the fewest meters from the paladin a body rises.
@export var raise_kind: StringName = &"skeleton"
@export var raise_far := 3.0
## Scale of the damage of whom this one raises (the elder's archers deal less than the common ones: Lote R7); 1 = the same.
@export var raise_damage := 1.0
## PRIEST (the Elder, Daniel 2026-11-23): when raise_cd_max > 0 it calls raise_count of its raise_kind (never more than
## raise_max of its own standing) to the floor's edge, away from the paladin, every raise_cd_min to raise_cd_max seconds
## (the first after raise_first), instead of raising skeletons round itself every other cast.
@export var raise_cd_min := 0.0
@export var raise_cd_max := 0.0
@export var raise_first := 3.0
## CB-4 (Daniel, 2026-11-22: each enemy asks for another answer). The share of the paladin's attack its shield stops
## from the front (the attack's tag &"light"; the Investida, the Omegas and the special go past it), and the seconds the
## special (&"heavy") leaves its guard open.
@export var front_block := 0.0
@export var front_open := 3.0
## C1d (docs/design/chefes_c1d.md), the guardians' own answers. KNIGHT, guarded by time (K3): every guard_up_every seconds, with
## its armor over guard_up_armor of the full bar, it raises its shield guard_up_windup s ahead (a signal), then holds it guard_up_time
## seconds (front_block holds only then), walking at guard_up_walk of its speed and swinging every guard_up_hit_every s at
## guard_up_hit_range m; the special opens it (front_open); a blow from behind does guard_back_mult times (0: no guard by time).
@export var guard_up_time := 0.0
@export var guard_up_every := 14.0
@export var guard_up_windup := 0.6
@export var guard_up_armor := 0.5
@export var guard_up_walk := 0.6
@export var guard_up_hit_every := 1.6
@export var guard_up_hit_range := 1.6
@export var guard_back_mult := 1.5
@export var guard_up_hit_damage := 12.0
@export var guard_up_hit_windup := 0.85
## KNIGHT (K2): when the Brado takes its close slam, it stands open (stunned) this many seconds (0: it does not open).
@export var ward_open := 0.0
## KNIGHT (K1): a charge that ends against the arena's wall leaves it stunned and turned away this many seconds (its own
## collision, never a blow of the paladin's: the F8 rule does not touch it; 0: none).
@export var wall_stun := 0.0
## PRIEST, the elder's second answer (A2, C1d): after a fan, every volley_every seconds it backs volley_back meters away over
## volley_back_time s (it stops at a wall), then raises its staff volley_windup s (a thread to each orb) and looses volley_count
## slow orbs (volley_speed m/s) in volley_spread degrees; they turn after the paladin volley_turn degrees a second for volley_life
## seconds; then volley_recover s of rest (volley_count 0: none).
@export var volley_count := 0
@export var volley_every := 12.0
@export var volley_back := 8.0
@export var volley_back_time := 1.5
@export var volley_windup := 1.0
@export var volley_speed := 4.0
@export var volley_spread := 50.0
@export var volley_turn := 60.0
@export var volley_life := 5.0
@export var volley_recover := 1.5
## Felled, it bursts this many seconds later where it fell (its attack's width and damage; 0: it does not).
@export var death_burst := 0.0
## Seconds between the starts of two wind-ups of this kind (they never lock their aim together; 0: no wait).
@export var windup_gap := 0.0
## ARCHER with shot_line: the shots after the first are aimed again, locked this many seconds before they leave (0: along
## the first's line).
@export var shot_relock := 0.0
## While it stands, every ward_every seconds it gives ward_armor of armor to up to ward_count of the plain enemies within
## ward_radius m (they lose it when it falls; ward_count 0: none).
@export var ward_count := 0
@export var ward_every := 5.0
@export var ward_armor := 40.0
@export var ward_radius := 10.0
## A guardian: who rises with it when it is the second of a descent (Daniel, 2026-11-22: harder by its company, never
## by more life).
@export var escort: Array[StringName] = []
## ARCHER and PRIEST: the shots. A bolt (fast, thin) or an orb (slow, round); shot_count of them in a fan of
## shot_spread degrees; shot_line marks the aim on the floor during the wind-up (it locks there).
@export var shot_speed := 13.0
@export var shot_count := 1
@export var shot_spread := 0.0
@export var shot_orb := false
@export var shot_line := false
## ARCHER: the part of attack_range the paladin may come to before it runs away (it shoots from the far end).
@export var keep_away := 0.7
## ARCHER and PRIEST, the numbers of Hades II's ranged enemies (study of 2026-11-16): shot_ticks volleys shot_interval
## seconds apart (Hades FireTicks, FireInterval), each pushing it back at recoil m/s (FireTickSelfVelocity, a little
## less each tick); shots that turn after the paladin at shot_turn degrees a second, that rate falling shot_turn_decay
## a second (MaxAdjustRate, AdjustRateAcceleration); shot_range meters of flight (0: 1.5 of its reach); shot_low:
## it creeps along the floor (the vines).
@export var shot_ticks := 1
@export var shot_interval := 0.17
@export var recoil := 0.0
@export var shot_turn := 0.0
@export var shot_turn_decay := 0.0
## Seconds of its flight a shot keeps turning after the paladin, then flies straight (0: its whole flight). C17, QW-101:
## the caster's orb turns only in its first 0.8 s, so it catches him early or not at all (it caught him 2 to 3 s
## into its flight, with the dash ready: 33% of the PO's blows taken).
@export var shot_homing := 0.0
@export var shot_range := 0.0
@export var shot_low := false
## ARCHER: between attacks it goes behind the nearest pillar, cover_hug meters past it from the paladin (Hades
## HideAndPeekAI, CoverHugDistance; 0: no cover). After each attack it runs retreat_far meters from him for
## retreat_time seconds (RetreatAfterAttack; 0: it stays). At most max_attackers of its kind wind up or shoot at
## once (MaxAttackers; 0: no limit; E1c: also the soldiers' lunges, RUNNER).
@export var cover_hug := 0.0
@export var retreat_far := 0.0
@export var retreat_time := Vector2.ZERO
@export var max_attackers := 0
## PULSE: radius of the burst. CONE: opening in degrees. SWEEP: width of the bar (attack_range is its reach).
@export var attack_width := 0.0
## SWEEP (C5): degrees the bar turns, the seconds that takes, and the meters round its root where it does not hurt.
@export var sweep_degrees := 200.0
@export var sweep_time := 1.6
@export var sweep_clear := 1.6
## C1e, lote B, LEAP (the Saltador): as its wind-up begins it takes the paladin's spot (never following him, Daniel 2026-11-23) and
## the floor shows a red circle of leap_half m there; then it leaves the floor and lands there leap_time s later, hurting
## whoever stands in the circle (attack_damage). attack_range is how far it jumps from; it rests recover_time s after.
@export var leap_time := 0.5
@export var leap_half := 1.5
## ARCHER, the Lançador (lote B): the shot flies out shot_range m (shorter where stone is), turns there and flies back the same way to
## where it left, hurting the paladin once each way; its line shows again ThrowRules.RETURN_WARN s before it turns.
@export var shot_return := false
## C1e, SUPPORT: a shout reaches the others within shout_radius m: they walk and recover from their blows (1 + shout_pace) times
## as fast for shout_time s (the wind-up is never shortened) and take shout_heal of their life back, once a shout. flee_speed:
## its speed when it runs from the paladin (0: its speed).
@export var shout_radius := 0.0
@export var shout_time := 8.0
@export var shout_pace := 0.3
@export var shout_heal := 0.1
@export var flee_speed := 0.0
## C1e, lote C, SUPPORT with plate_damage > 0 (the Armadilheiro): each call lays a plate of 2 x plate_half m where the paladin stands, or where
## his last dodge ended if that was under plate_window s ago; it shows an X for plate_time s and then hurts plate_damage whoever stands on
## it (the dodge's own protection passes over it); at most plate_max of them lie at once.
@export var plate_damage := 0.0
@export var plate_time := 1.0
@export var plate_half := 0.8
@export var plate_max := 4
@export var plate_window := 3.0
## ... then its spikes stand for plate_spikes s (they hurt whoever steps on them and was not hurt at the landing), and the plate lies dormant
## (a dim X that still counts against plate_max) until plate_life s after it was laid.
@export var plate_spikes := 0.5
@export var plate_life := 6.0
## Roles it is never drawn into a fight with (EncounterGen.pick_kinds; the Coveiro and the swarm).
@export var never_with: Array[StringName] = []
## C5, the Trinca: figures that come together (a head count of the room's wave stands for this many bodies) and fall
## together; a fallen one lies rise_time seconds and rises if another of them stands (0: it dies when it falls).
@export var group := 1
@export var rise_time := 0.0
## At most this many of the kind (with its elite) in a fight, all its waves together (0: no limit; the Varredor: one).
@export var per_room := 0
## KNIGHT: a slam on whoever stands close (0 damage = none).
@export var close_damage := 0.0
@export var close_range := 3.0
@export var close_windup := 0.65
## KNIGHT, the priority list (AttackList; empty: the old order, charge when far and slam when near): the special moves it
## draws from, top first, each with its life gate, distance and cooldown.
@export var moves: Array[KnightMove] = []
## KNIGHT (Daniel, 2026-11-23): how much of a blow reaches its armor when the blow is not a strong one (the finisher, the
## special's wave, the dash cut, the Omegas, the Brado's shout: DamageCalc.STRONG_TAGS). 1: every blow the same.
@export var armor_soft := 1.0
## KNIGHT, the shield throw (throw_flight > 0): it winds up throw_windup s, hurls the shield up and it comes down on the
## spot the paladin stood on as it left the hand (a red circle of throw_half m on the floor; it never follows him since 2026-11-23,
## throw_lock unused), hurting throw_damage; throw_open s after it lands it has the shield back. Where it lands a wave spreads at
## ring_speed m/s, ring_thick m thin, ring_reach m far, born ring_delay s after the landing, hurting ring_damage.
@export var throw_windup := 0.5
@export var throw_flight := 0.0
@export var throw_lock := 0.35
@export var throw_half := 1.5
@export var throw_damage := 16.0
@export var throw_open := 1.6
@export var ring_speed := 12.0
@export var ring_thick := 0.8
@export var ring_reach := 32.0
@export var ring_delay := 0.25
@export var ring_damage := 14.0

@export_group("Encounters")
## Weight of this enemy in the room generator (Hades II "DifficultyRating"): a room of difficulty 100 holds
## enemies whose ratings add up to about 100.
@export var rating := 0.0
## SW-R1: what a head costs in a room's budget (SWORN's scale: small 1, common 3, heavy 5, the Capitao 10; an elite or a bigger one 5 to 7).
## 0: from the rating (cost_of).
@export var cost := 0
## The part it plays in a fight (EncounterPool.roles): pressure (walks in and keeps the paladin busy), react (fast,
## asks for a quick answer), control (closes space from afar), flank (makes him move sideways), block (stands in
## front, must be gone around), area (threatens ground). Empty: never drawn into a generated fight.
@export var role: StringName
## The armored version that can stand in for it in a room (empty: none).
@export var elite_version: StringName
## C1b (combate_c1b.md, Frente 2): the bigger version of this kind that may take a head's place in a fight (empty: none).
@export var big_version: StringName
## C1b: true for that bigger version (not an elite, no armor): never drawn as a part of a fight, only put in by EncounterGen.add_big.
@export var big := false


## SW-R1: the cost of one head in the room's budget (EncounterGen): `cost`, or about 0.6 of the rating when none is set.
func cost_of() -> int:
	return cost if cost > 0 else maxi(1, roundi(rating * 0.6))
