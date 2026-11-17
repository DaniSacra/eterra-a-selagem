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
enum Behavior { CHASE, ARCHER, RUNNER, CASTER, KNIGHT, PRIEST, BOSS, PULSE, CONE }
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
## Degrees its trunk sways from side to side as it runs, unsteady (drawn only: Horde.SWAY_HZ).
@export var sway := 0.0
## Meters it trembles during its wind-up (drawn only: Horde.SHAKE_HZ).
@export var windup_shake := 0.0
## The effect of its wind-up, and where it sits on the figure: meters at size 1, x to its right, y up, z ahead
## (the tip of the blade, the orb of the staff, the tip of the bolt, the shield's edge, between the hands).
@export var tell: Tell = Tell.NONE
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
## T5-01 (docs/design/combat_cadence.md 6.3): its wind-up is drawn in three beats. Settle: windup_settle seconds, the
## body stops and fades from its walk to its guard. Arm: its wind-up clip, eased in and out, until the last
## windup_hold share of the wind-up. Hold: that share, the armed pose (or its own *_hold loop) with windup_shake.
## The settle is also how long its last clip fades into the wind-up (T5-05: the crossbow rising to the shoulder).
@export var windup_settle := 0.12
@export var windup_hold := 0.3
## T5-09: seconds into its attack at which its blow lands (a soldier's blade down, a runner's arms open): the warning
## on the floor fills until that frame, and the damage is dealt there from where its body is.
@export var strike_at := 0.0
## RUNNER (T5-09): its blade's reach from the edge of its body when it lands (meters at size 1) and the arc ahead.
@export var strike_reach := 1.1
@export var strike_degrees := 120.0
## RUNNER and KNIGHT: speed of the lunge or charge (m/s) and how long it lasts.
@export var lunge_speed := 14.0
@export var lunge_time := 0.45
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
## PULSE: radius of the burst. CONE: opening in degrees.
@export var attack_width := 0.0
## KNIGHT: a slam on whoever stands close (0 damage = none).
@export var close_damage := 0.0
@export var close_range := 3.0
@export var close_windup := 0.65

@export_group("Encounters")
## Weight of this enemy in the room generator (Hades II "DifficultyRating"): a room of difficulty 100 holds
## enemies whose ratings add up to about 100.
@export var rating := 0.0
## The part it plays in a fight (EncounterPool.roles): pressure (walks in and keeps the paladin busy), react (fast,
## asks for a quick answer), control (closes space from afar), flank (makes him move sideways), block (stands in
## front, must be gone around), area (threatens ground). Empty: never drawn into a generated fight.
@export var role: StringName
## The armored version that can stand in for it in a room (empty: none).
@export var elite_version: StringName
