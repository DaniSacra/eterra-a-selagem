extends SceneTree
## Bakes the crowd's characters into still poses: ~/tools/godot/godot --headless --path . -s tools/bake.gd [-- ids]
## Writes assets/baked/<id>.res (BakedModel). Run again after changing a model, a weapon, a clip or the lists below.
##
## The enemies of the first region are the Meshy models Daniel approved (assets/models/meshy/enemy_<id>/, the same
## 24 bones as the hero, a painted texture each; docs/art/enemies_phase1.md). Per entry of MODELS:
## "meshy" (the model's id), "height" (meters to the top of its head, standing idle, at EnemyDef.size 1: what the
## KayKit figure it replaced measured, so the sizes of the game and the life bars did not move), "triangles" (MeshSlim makes the 15 thousand of the model this
## many and repaints its texture on a new atlas, kept inside the baked file), "palette" and "held" (what the model
## does not carry by itself: KayKit weapons and simple shapes in its hands, painted by a strip of the KayKit palette
## under the atlas), "bend" (bone -> degrees added to its posed rotation, a stoop) and "anims" (name in the game ->
## [rig, clip, frames, loops, options]): the clips are made for other skeletons and carried to this one by Retarget,
## as tools/bake_hero.gd does for the hero. Options of a clip: "from" and "to" (seconds of the clip), "time"
## (seconds it plays in, in the game), "lift" (the share of the hips' rise and fall that is kept), "in_place" (the
## hips never leave the figure's place on the floor: a clip with root motion that the game does not move) and "guard"
## ([rig, clip, bones], or a list of those: the bones, parents first, point where another clip has them, e.g. the
## sword arm kept in guard while the legs run) and "bend" (as the entry's, for this clip only, on top of it), grown
## over the clip with "bend_in" (a wind-up coiling) or easing off over the first "bend_out" seconds (the blow uncoiling).
## "rigid" (pieces the model carries by itself and its rig tears between bones, e.g. the brute's tower shield, half
## of it skinned to the leg it hangs beside: {"bone": the one bone it follows from now on, "seeds": the bones that
## hold its core, "plate" or "rod": a flat or a long piece, and how far from its plane or its line it still is the
## piece, in the model's meters, "worn": true to lift its painting off the dark, turn its rim to worn light steel
## and scratch its faces, _worn}) and "hold" ({"bones": parents first, "swing": degrees}: those bones stay as the
## model rests, whatever the clip, the first one swung around the figure's upright axis; a clip's own "hold" is
## its swing: the shield arm stays behind the shield, and the shield comes in front of the body), "there_and_back" (a
## one-shot goes from `from` to `to` and back over its poses: a thrust out of a held pose and back to it). A "guard"
## entry may end with a second of its clip ([rig, clip, bones, second]): those bones held as that pose has them. A
## locked walk's "stand" (m): its hips that much higher over the same footprints, the knees bent less. A rigid or held
## piece's "name" ("shield", "sword", "staff", "orb", "crossbow") keeps its vertices in BakedModel.parts, for measures
## (guard_pose) and for where the lights of a wind-up sit (EnemyFx, BakedModel.point). An entry's "marks" (name -> bone
## names) keeps the body's vertices bound to those bones in BakedModel.marks (LC-3: the priest's hands).
## A held piece: "hand" (Right or Left), then "file" (assets/models/weapons) or "shape" (see _prop), "scale",
## "at" (meters) and "rot" (degrees) in the hand's grip (+Y along the fist toward the pinky, which is where the
## libraries' sword clips carry the blade; +Z out of the knuckles, along the forearm) and "paint" (KayKit palette
## cell of the weapon -> one of SWATCHES: the weapon is repainted in the figures' own painted tones, see _repainted).
## A staff or a crossbow, held thumb up by the other clips, is turned over: rot (0, 0, 180).
## "even_legs" (true): the model's rig has one leg's knee misplaced (the brute: its left shin bone 0.6 m long, the
## right 0.35), so the clips that straighten the legs would push that foot through the floor and leave the other in
## the air; each leg then reaches as far as it does at rest when the clip straightens it (_even_leg).
##
## The KayKit figures the game used until 2026-11-15 are kept in KAYKIT with their palettes (tools/make_palettes.gd),
## to go back: `-- kaykit [ids]` bakes them over the same files (then EnemyDef.palette draws the elites again).
## Per KayKit entry: "model" (assets/models/characters), "texture" (the palette), "weapons" ([file, bone, scale]),
## "hide" (mesh parts left out), "remap" (part or weapon name -> {from cell: to cell}), "props", "bend", "anims"
## (name in the game -> [glTF clip, frames, loops]).
## A prop hangs on "bone" at "at" (meters, the bone's own space at rest, which on the KayKit rig is the model's
## axes, +Z the front), turned by "rot" (degrees) and scaled by "scale"; it is a "part" of another KayKit model
## ("Knight.glb:Knight_Cape", which keeps its own place on its bone) or a "shape" (box, sphere, cylinder, crown) of
## "size", painted with the palette's "cell" (a part keeps its shading as the cell's gradient).

const CHAR := "res://assets/models/characters/"
const WEAPON := "res://assets/models/weapons/"
const PALETTE := "res://assets/models/palettes/"
const MESHY := "res://assets/models/meshy/enemy_%s/enemy_%s-rigged.glb"
## The skeletons the clips are made for (Retarget.RIGS): the two Universal Animation Libraries of Quaternius and
## a KayKit skeleton (all CC0).
const RIGS := {
	&"ual": "res://assets/models/anim/ual_standard.glb",
	&"ual2": "res://assets/models/anim/ual2_standard.glb",
	&"kaykit": CHAR + "Skeleton_Warrior.glb",
}
## Pixels of a baked figure's texture, and the share of its height that holds the body (the strip under it is the
## KayKit palette of the held pieces).
const ATLAS := 1024
const BODY := 0.875
const COLS := 8
const ROWS := 4
## Half the thickness of a body lying on the floor, in the models' own units (centimeters).
const BODY_THICKNESS := 10.0
## Triangles of a figure's body (MeshSlim.simplify takes the nearest level of the engine's chain, each half the one
## before: 15.5 thousand, 7.7, 3.9, 1.9). Morvath at 7.7 thousand, 5 m tall, reads the same and weighs 8 MB more.
const BODY_TRIANGLES := 3900
## The sheet's skeletons are adult figures: the skull a little smaller again than Slender leaves it (on top of
## Slender.HEAD; the props on the head shrink with it).
const HEAD_SHRINK := 0.72

## Cells of the palettes (tools/make_palettes.gd).
const C_BLACK := 2
const C_ARMOR := 3
const C_DARK_METAL := 4
const C_WRAP := 6
const C_BONE := 9
const C_BLADE := 11
const C_HOOD := 18
const C_WOOD := 22
const C_RED := 24
const C_GOLD := 25
const C_PURPLE := 26
const C_HAIR := 27
const C_GLOW_COLD := 28
const C_GLOW_PURPLE := 29
const C_EMBER := 30

## The held weapons repainted in the tones of the painted figures (VX-07; the KayKit palette made them flat toy
## colours in two-tone bands): each swatch fills one cell of the first row of the palette strip, which no held
## shape uses (the glowing cells are in the last row), and the weapon's faces are projected on it along the weapon
## (_repainted), so the grain runs down the blade or the shaft. Per swatch: the cell, the base colour (sRGB, the
## value and saturation of the figures' own painting: the brute's own sword and plate, the soldier's bone, the
## priests' cloth, as they come out of the crowd shader; docs/arte/estetica.md), "grain" (fine noise),
## "streak" (long marks along the weapon: brushed iron, wood grain), "stain" (broad darker patches, wear) and
## "scratch" (share of thin light lines along it).
const SWATCHES := {
	"iron": {"cell": 0, "color": Color(0.13, 0.135, 0.14), "grain": 0.05, "streak": 0.06, "stain": 0.12, "scratch": 0.08},
	# the rim and boss of a shield: the same iron, worn lighter where it is struck
	"iron_worn": {"cell": 1, "color": Color(0.23, 0.23, 0.225), "grain": 0.06, "streak": 0.05, "stain": 0.18, "scratch": 0.12},
	"bone": {"cell": 2, "color": Color(0.5, 0.45, 0.36), "grain": 0.05, "streak": 0.04, "stain": 0.2, "scratch": 0.0},
	"wood": {"cell": 3, "color": Color(0.1, 0.064, 0.043), "grain": 0.04, "streak": 0.16, "stain": 0.12, "scratch": 0.0},
	# tarnished bronze: the staffs' rings and claws, the knight's hilt
	"metal": {"cell": 4, "color": Color(0.18, 0.16, 0.13), "grain": 0.05, "streak": 0.05, "stain": 0.2, "scratch": 0.06},
	# Morvath's hilt: old gold on screen, hue 35 to 45, saturation under 0.5 (V-P1), never the yellow of a toy. He is
	# drawn far more saturated than painted (EnemyDef.vivid 0.9) and tinted violet (the tint takes green and adds
	# blue: the hue goes red): this paint, paler and yellower than the gold it reads as, is what comes out at hue 39
	"gold": {"cell": 5, "color": Color(0.33, 0.305, 0.21), "grain": 0.05, "streak": 0.05, "stain": 0.16, "scratch": 0.05},
	"leather": {"cell": 6, "color": Color(0.1, 0.07, 0.055), "grain": 0.06, "streak": 0.06, "stain": 0.1, "scratch": 0.0},
	# the soldier's cleaver blade (ART_REVIEW 4b): worn iron of its own, lighter than the floor it hangs over (value
	# 0.28, the iron's hue), its edge scratches at 0.48 ("lift": a scratch that much lighter than the swatch)
	"blade": {"cell": 8, "color": Color(0.27, 0.28, 0.29), "grain": 0.05, "streak": 0.06, "stain": 0.1, "scratch": 0.2, "lift": 1.7},
	"red": {"cell": 7, "color": Color(0.2, 0.06, 0.05), "grain": 0.06, "streak": 0.06, "stain": 0.12, "scratch": 0.0},
}
## A scratch: that much lighter than the swatch around it.
const SCRATCH_LIFT := 1.6
## Share of a swatch cell left at each side (the mipmaps of the compressed atlas bleed from the next cell).
const SWATCH_MARGIN := 0.12
## Lattice of the swatches' noise across a cell (along the weapon, across it): the fine grain, the streaks, the stains.
const GRAIN_LATTICE := Vector2(64, 16)
const STREAK_LATTICE := Vector2(4, 14)
const STAIN_LATTICE := Vector2(6, 2)
## How the KayKit weapons are repainted (paint of a held piece): their palette cells -> swatches.
## The cleaver: blade (11) in its own worn iron, its back (6) and the spikes of the hilt (3) in iron, the knuckle bow
## and the grip (22) in bone.
const BLADE_PAINT := {C_BLADE: "blade", C_WRAP: "iron", C_ARMOR: "iron", C_WOOD: "bone"}
## The knight's blade with a bronze hilt; Morvath's with the hilt (the hook beside his hip) in old gold.
const KNIGHT_BLADE_PAINT := {C_BLADE: "iron", C_WRAP: "iron", C_ARMOR: "iron", C_WOOD: "metal"}
const MORVATH_BLADE_PAINT := {C_BLADE: "iron", C_WRAP: "iron", C_ARMOR: "iron", C_WOOD: "gold"}
## The staff: shaft (22) and its knots (9) dark wood, the rings (17), the band (19) and the claws at the top (13)
## old metal.
const STAFF_PAINT := {C_WOOD: "wood", C_BONE: "wood", 17: "metal", 19: "metal", 13: "metal"}
## The crossbow: stock (22) in dark wood, the lock (14) old metal. LC-1 (docs/backlog.md 9): the bow (3) in the
## worn iron of the soldier's blade, lighter than the figure: in the dark iron the bow was lost against the dark robe
## and the crossbow did not read in the game's camera, not even raised to aim.
const CROSSBOW_PAINT := {C_ARMOR: "blade", C_WOOD: "wood", 14: "metal"}
## The knight's round shield: rim and skull (3) worn iron, the boards (7) dark wood, the straps (6) leather.
const SHIELD_PAINT := {C_ARMOR: "iron_worn", 7: "wood", C_WRAP: "leather"}
## The soldier's cleaver: the KayKit blade is 1.5 m long with its hilt, the steel 0.89 m, longer than the trunk
## (V-P1); this scale leaves the steel at 0.68 of the trunk, hips to the top of the head (0.87 m at the soldier's
## size, printed by the bake): 0.59 m of steel, 0.99 m with the hilt (ART_REVIEW 4b: the thin figure's weapon is
## its role, 0.6 did not read in the game's camera).
const CLEAVER_SCALE := 0.66
## The crossbow (1.1 m wide in KayKit's units): a hand crossbow beside a 1.9 m figure. LC-1: 0.62 (was 0.5, 0.55 m
## wide): at 0.5 its bow was 9 px wide at 1080 in the game's camera, smaller than the figure's hand and arm.
const CROSSBOW_SCALE := 0.62

const SOLDIER_ANIMS := {"walk": ["Walking_D_Skeletons", 10, true], "attack": ["1H_Melee_Attack_Chop", 7, false], "hit": ["Hit_A", 4, false],
	"rise": ["Spawn_Ground_Skeletons", 8, false], "death": ["Death_C_Skeletons", 8, false], "idle": ["Idle_Combat", 4, true]}
const CASTER_ANIMS := {"walk": ["Walking_C", 10, true], "attack": ["Spellcast_Shoot", 7, false], "cast": ["Spellcasting", 6, true], "hit": ["Hit_A", 4, false],
	"rise": ["Spawn_Ground_Skeletons", 8, false], "death": ["Death_C_Skeletons", 8, false], "idle": ["Idle_Combat", 4, true]}
const BRUTE_ANIMS := {"walk": ["Walking_A", 10, true], "attack": ["1H_Melee_Attack_Slice_Diagonal", 7, false], "hit": ["Block_Hit", 4, false],
	"rise": ["Spawn_Ground_Skeletons", 8, false], "death": ["Death_C_Skeletons", 8, false], "idle": ["Idle_Combat", 4, true]}

## Red rags hanging at the waist, front and back (soldier, brute, knight).
const WAIST_FRONT := {"bone": "hips", "shape": "box", "at": Vector3(0, -0.1, 0.16), "rot": Vector3(-8, 0, 0), "size": Vector3(0.3, 0.34, 0.03), "cell": C_RED}
const WAIST_BACK := {"bone": "hips", "shape": "box", "at": Vector3(0, -0.1, -0.16), "rot": Vector3(8, 0, 0), "size": Vector3(0.34, 0.3, 0.03), "cell": C_RED}
## The crown of spikes (knight, elder, Morvath): on the skull, in the head's space.
const CROWN := {"bone": "head", "shape": "crown", "at": Vector3(0, 0.92, 0), "size": Vector3(0.36, 0.34, 7), "cell": C_GOLD}
## The priests' hood (the sheet's blocks 6 and 8): in the dark cell, so the skull reads inside a dark frame; pushed
## back and its brim lifted, so the game's high camera still sees the eyes under it.
const PRIEST_HOOD := {"bone": "head", "part": "Skeleton_Rogue.glb:Skeleton_Rogue_Hood", "cell": C_BLACK,
	"at": Vector3(0, 0.03, -0.06), "rot": Vector3(-12, 0, 0)}
## The elder's crown sits on the hood, a little higher and wider than on a bare skull.
const ELDER_CROWN := {"bone": "head", "shape": "crown", "at": Vector3(0, 1.02, 0), "size": Vector3(0.4, 0.34, 7), "cell": C_GOLD}

const RIGHT_ARM: Array[StringName] = [&"RightShoulder", &"RightArm", &"RightForeArm", &"RightHand"]
const LEFT_ARM: Array[StringName] = [&"LeftShoulder", &"LeftArm", &"LeftForeArm", &"LeftHand"]
## Held pieces: a blade's edge turned out of the knuckles; a staff or a crossbow turned over in the fist.
const EDGE_OUT := Vector3(0, 90, 0)
const THUMB_UP := Vector3(0, 0, 180)
## The sword arm in guard while the legs walk or run (the libraries' walks are unarmed: the blade would flail).
const SWORD_GUARD := {"guard": [&"ual", "Sword_Idle", RIGHT_ARM]}
## The staff held upright, in the left hand (the library holds its torch there; the right hand casts).
const STAFF_GUARD := {"guard": [&"ual", "Idle_Torch", LEFT_ARM]}
## E1c (AUDIT.md P7): the crossbow carried low, in front of the hip, walking and standing (the pistol's arm held it
## over the head like a hat); it rises to the shoulder only to aim ("aim", "attack": Pistol_Idle, Pistol_Shoot).
const CROSSBOW_LOW := [&"ual", "Sword_Idle", RIGHT_ARM]
const CROSSBOW_GUARD := {"guard": CROSSBOW_LOW}
## The shield arm up and the sword arm in guard (the shield clip lets it hang: the blade would drag in the floor).
const SHIELD_GUARD := {"guard": [[&"ual2", "Idle_Shield", LEFT_ARM], [&"ual", "Sword_Idle", RIGHT_ARM]]}
const SHIELD_IDLE := [&"ual2", "Idle_Shield", 12, true, SWORD_GUARD]
## The walks with the feet locked on the floor (_foot_lock, E1b-A1 and A2) and their stride, set so each figure
## takes the steps a minute of its weight at its speed in the game (tools/walk_probe.gd prints them):
## the brute's heavy walk, the one its KayKit figure had, on a longer step (110 to 140); the knight and Morvath on a
## long stride (90 to 120); the elder's solemn walk.
const BRUTE_STRIDE := {"guard": [&"ual", "Sword_Idle", RIGHT_ARM], "lock": true, "stride": 0.92}
const KNIGHT_STRIDE := {"guard": [[&"ual2", "Idle_Shield", LEFT_ARM], [&"ual", "Sword_Idle", RIGHT_ARM]], "lock": true, "stride": 1.1}
## E1c (AUDIT.md P6): the elder on a shorter stride, 91 steps a minute (1.2 gave 67, a slow motion).
const ELDER_STRIDE := {"guard": [&"ual", "Idle_Torch", LEFT_ARM], "lock": true, "stride": 0.9}
## E1c (AUDIT.md P6): the soldier's run with the feet locked as the sorcerer's, on a short stride with half the hop: 149
## steps a minute at its 3.75 m/s (it ran 96, floating, with two feet in the air in 3 of 5 frames); the blade in guard.
const SOLDIER_RUN := {"guard": [&"ual", "Sword_Idle", RIGHT_ARM], "lock": true, "stride": 0.68, "lift": 0.5}
const KING_STRIDE := {"guard": [&"ual", "Sword_Idle", RIGHT_ARM], "lock": true, "stride": 1.3}
## T5-11 (docs/design/combat_cadence.md 6.4): the soldier's run read as a gazelle (Running_B on a short stride with half
## its hop: both feet off the floor in 16 of 20 poses, the trunk upright, the back foot kicked to the hip). It jogs
## instead (the library's Jog_Fwd), the feet locked, a third of the hop, the trunk leaning into the run. A-T5-2: it
## crouched (knees near square, the body 22 cm down): the body sinks half the way to each pose's own floor ("plant" 0.5,
## was 0.65) and stands 0.15 m taller over the same footprints ("stand"), its head at 99% of its idle's; 161 steps a minute.
const SOLDIER_JOG := {"guard": [&"ual", "Sword_Idle", RIGHT_ARM], "lock": true, "stride": 0.74, "lift": 0.3, "plant": 0.5, "stand": 0.15,
	"bend": {"Spine01": Vector3(-34, 0, 0)}}
## T5b P1-1 (docs/qa/t5b_boss_fight.md): the sorcerer and the crossbowman trotted as the soldier did before T5-11
## (Running_B with half its hop: 14 and 12 of 20 poses with the whole body over 0.1 m, up to 0.3 m), and the sorcerer
## runs the most (it flees to keep its range, in front of the camera). They jog as the soldier does now: the library's
## Jog_Fwd, the feet locked, a third of the hop, the body planted and standing taller; the staff upright and the free
## arm close to the body (the guard of its old trot), the crossbow low beside the hip (CROSSBOW_LOW).
const MAGE_JOG := {"guard": [[&"ual", "Idle_Torch", LEFT_ARM], [&"ual", "Idle", RIGHT_ARM]], "lock": true, "stride": 0.76,
	"lift": 0.15, "plant": 0.35, "stand": 0.15, "bend": {"Spine01": Vector3(-22, 0, 0)}}
const CROSSBOW_JOG := {"guard": CROSSBOW_LOW, "lock": true, "stride": 0.79, "lift": 0.2, "plant": 0.4, "stand": 0.15,
	"bend": {"Spine01": Vector3(-34, 0, 0)}}
## T5b Corredor (PO, 2026-11-18: "ainda tem esqueleto que anda tremendo", the rust one): the runner hopped on
## KayKit's Running_B (the whole body over 0.1 m in 14 of 20 poses, up to 0.34 m, rising and falling 0.23 m, 131 steps
## a minute). It jogs as the soldier does: the library's Jog_Fwd, the feet locked on a long stride (it is the fastest,
## 4.9 m/s: 171 steps a minute, the foot sliding 3.2 cm), the body planted toward each pose's floor ("plant" 0.6: no
## pose over 0.08 m), a sixth of the hop, standing taller. The Sprint slid 34 cm a step locked (its flight is too long).
## T5-19 (combat_cadence.md 6.5): the crossbow's recoil, the trunk 5 degrees back in 0.06 s and back in 0.2 s.
const CROSSBOW_KICK := {"at": 0.0, "up": 0.06, "down": 0.2, "bend": {"Spine01": Vector3(-5, 0, 0), "Spine02": Vector3(-2, 0, 0)}}
const RUNNER_JOG := {"lock": true, "stride": 1.2, "lift": 0.15, "plant": 0.6, "stand": 0.15, "bend": {"Spine01": Vector3(-20, 0, 0)}}
## The elite runner's stride (2B): the same jog with its feet locked a longer way, about 200 steps a minute at its
## 7.4 m/s (tools/walk_probe.gd: Jog_Fwd at 1.55 slides 4.5 cm; the Sprint slid 6 to 13 cm and leaned 37 degrees).
const RUNNER_ELITE_JOG := {"lock": true, "stride": 1.55, "lift": 0.15, "plant": 0.6, "stand": 0.15, "bend": {"Spine01": Vector3(-20, 0, 0)}}
## T5-02: the soldier's wind-up coils the trunk back and toward the blade (grown over the wind-up, "bend_in") and its
## blow uncoils it in its first 0.15 s ("bend_out").
const SOLDIER_COIL := {"Spine01": Vector3(-18, 30, 0)}
## T5-03: the sorcerer and the elder draw their trunk back as the staff comes up.
const STAFF_COIL := {"Spine01": Vector3(-8, 0, 0)}
## T5-15: Morvath leans into his charge.
const CHARGE_LEAN := {"Spine01": Vector3(32, 0, 0)}
## T5-15: and draws back, turned to the blade, as he readies the Blades.
const DRAW_BACK := {"Spine01": Vector3(-12, 20, 0)}
## The brute's own tower shield (MODELS.guard "hold"): degrees its arm and shield are swung from the model's rest
## toward the middle of the body, standing and walking, and braced for the charge.
const SHIELD_FRONT := -14.0
const SHIELD_BRACE := -26.0
## The trunk, hips up to the head (a "guard" of these keeps the body's lean of another clip over the legs of this one).
const TRUNK: Array[StringName] = [&"Spine02", &"Spine01", &"Spine", &"neck", &"Head"]
## A-T5-1 (docs/gallery/t5/ART_REVIEW.md 1.6): the charge is run, not walked up out of the brace. The legs sprint
## (the library's Sprint, quicker), the trunk (and the knight's shield arm) stay as the brace ends, low and leaning
## behind the shield ("guard" at a fixed second of Shield_Dash_RM: its 0.3 to 0.8 s stood the body up and took the
## shield aside), the brute's tower shield swung across as in the brace; the sword arm in guard.
const RUSH_AT := 0.33
const BRUTE_RUSH := {"time": 0.45, "hold": SHIELD_BRACE,
	"guard": [[&"ual2", "Shield_Dash_RM", TRUNK, RUSH_AT], [&"ual", "Sword_Idle", RIGHT_ARM]]}
const KNIGHT_RUSH := {"time": 0.45, "bend": {"Spine02": Vector3(14, 0, 0)},
	"guard": [[&"ual2", "Shield_Dash_RM", TRUNK + LEFT_ARM, RUSH_AT], [&"ual", "Sword_Idle", RIGHT_ARM]]}
## LC-3 (docs/backlog.md 9): the priest's ritual is both arms raised open over the head, a V a little wider than the
## head, the chest thrown back and the skull lifted to them (KayKit's Cheer up to its arms' highest, 0 to 0.84 s, in
## the 0.8 s the cast took before; bent back on Spine02, Spine and Head (also so its armed pose stands 0.31 m from its guard, T5 6.1), which the KayKit rig drives every pose: a bend on Spine01,
## which it does not, piles up pose after pose): it read as arms held out to the sides (Spellcast_Summon 1.0 to 3.05 s), the same
## width as the sorcerer's staff held out, and the two hooded figures were told apart only by their colour.
const RITE_BEND := {"Spine02": Vector3(-20, 0, 0), "Spine": Vector3(-26, 0, 0), "Head": Vector3(-8, 0, 0)}
## Both hands held out, palms up, as one who carries an offering (the priest: no object, no symbol).
const BOTH_ARMS: Array[StringName] = [&"LeftShoulder", &"LeftArm", &"LeftForeArm", &"LeftHand", &"RightShoulder", &"RightArm", &"RightForeArm", &"RightHand"]
const OFFERING_GUARD := {"guard": [&"ual2", "Walk_Carry", BOTH_ARMS]}
## Morvath's blows in both hands (_both_hands) and his roar thrown back (VX-14).
## E1c (bug 3, "Morvath some e aparece em outro lugar para atacar"): his blows and his throw are the libraries' and
## carry their root motion in the hips (Sword_Regular_C 3.2 m forward at size 1, 8 m on him; A and B 1.2 to 1.4,
## OverhandThrow 0.7): drawn so, his body left the place the game keeps him (his warnings, his reach, his collision)
## and came back when the clip ended. "in_place" keeps the hips over his place (tools/pose_drift.gd measures it).
const TWO_HANDS := {"two_hands": true, "in_place": true}
const ROAR_BEND := {"Spine01": Vector3(-10, 0, 0), "Head": Vector3(-18, 0, 0)}

## What every figure does the same way. The rise plays in the 0.9 s the horde gives it (Horde, State.RISE).
const COMMON_ANIMS := {
	"hit": [&"ual", "Hit_Chest", 8, false],
	"death": [&"ual", "Death01", 16, false, {"to": 1.9}],
	"rise": [&"ual2", "LayToIdle", 12, false, {"time": 0.9, "in_place": true, "centred": true}],
}
## T5b P1-2 (docs/qa/t5b_boss_fight.md): LayToIdle ends stooped; with a staff (the sorcerer, the elder) or the round
## shield (the knight) the figure ended 0.3 to 0.4 m from its guard, the sorcerer's staff lying (the top of the figure
## at 1.88 m, its idle 2.65) and its walk after it threw the body up 0.5 m. Their last 0.45 s ease into their guard.
const STAFF_RISE := [&"ual2", "LayToIdle", 12, false, {"time": 0.9, "in_place": true, "centred": true, "settle": [&"ual", "Idle_Torch", 0.45]}]
const SHIELD_RISE := [&"ual2", "LayToIdle", 12, false, {"time": 0.9, "in_place": true, "centred": true, "settle": [&"ual2", "Idle_Shield", 0.45]}]
## Horde.IMPACT_SHARE of the swing is the windup: the clips are cut so the blade comes down there.
const SWORD_BLOW := [&"ual", "Sword_Attack", 16, false, {"from": 0.1, "to": 1.2}]
const CASTER_CLIPS := {
	"attack": [&"ual", "Spell_Simple_Shoot", 14, false],
	"cast": [&"ual", "Spell_Simple_Idle", 12, true],
}
## The same with a staff: the library casts with the left hand, which is the one that holds it.
const STAFF_CLIPS := {
	"idle": [&"ual", "Idle_Torch", 12, true],
	"attack": [&"ual", "Spell_Simple_Shoot", 14, false, {"bend": STAFF_COIL, "bend_out": 0.2}],
	"cast": [&"ual", "Spell_Simple_Idle", 12, true],
	# T5-03: the staff comes up (Spell_Simple_Enter) as the wind-up arms, the trunk drawn back; it is held up
	# (Spell_Simple_Idle) in the hold. T5-13: each bolt of a burst is its own thrust (the shot's first 0.3 s in
	# 0.17, Horde restarts it each tick), and the staff comes down (Spell_Simple_Exit) in the recovery.
	# A-T5-4: the library's shot hardly moves the staff hand (5 cm: the hold already has it at arm's length), so each
	# bolt is the staff drawn back down the rise (Spell_Simple_Enter 0.53 to 0.22 s, the hand 0.27 m back) and thrust
	# out again, there and back in the 0.17 s: the bolt leaves with the staff at arm's length.
	"cast_rise": [&"ual", "Spell_Simple_Enter", 10, false, {"bend": STAFF_COIL, "bend_in": true}],
	"cast_hold": [&"ual", "Spell_Simple_Idle", 12, true, {"bend": STAFF_COIL}],
	"shot": [&"ual", "Spell_Simple_Enter", 7, false, {"from": 0.53, "to": 0.22, "there_and_back": true, "time": 0.17, "bend": STAFF_COIL}],
	"exit": [&"ual", "Spell_Simple_Exit", 8, false],
}

const MODELS := {
	# 1. the soldier: bare bone, steel pauldrons and greaves, a torn red loincloth; the blade is the KayKit one
	"skeleton": {
		"meshy": "skeleton", "height": 1.92, "triangles": BODY_TRIANGLES,
		"palette": PALETTE + "skeleton.png",
		"held": [{"hand": "Right", "file": "Skeleton_Blade.gltf", "scale": CLEAVER_SCALE, "rot": EDGE_OUT, "paint": BLADE_PAINT, "name": "sword"}],
		"anims": {
			"walk": [&"ual", "Jog_Fwd", 20, true, SOLDIER_JOG], "idle": [&"ual", "Idle", 12, true, SWORD_GUARD],
			# T5-02: the wind-up is the clip's whole rise, 0 to 0.35 s (the blade from the hip to its highest, over
			# the head), the trunk coiling back and to the blade's side; Horde draws it in three beats (settle, arm,
			# hold). The blow goes on from there: the blade's fall (0.35 to 0.5) as the body lands its pounce
			# (Horde.ATTACK_PLAY, EnemyDef.strike_at), the rest is its recovery at the clip's own pace (T5-12)
			"windup": [&"ual", "Sword_Attack", 10, false, {"from": 0.0, "to": 0.35, "bend": SOLDIER_COIL, "bend_in": true}],
			"attack": [&"ual", "Sword_Attack", 14, false, {"from": 0.35, "to": 1.2, "bend": SOLDIER_COIL, "bend_out": 0.15}],
			# T5-10: waiting round the paladin it steps sideways and back facing him (never the run turned aside)
			"strafe_l": [&"kaykit", "Running_Strafe_Left", 12, true, SWORD_GUARD],
			"strafe_r": [&"kaykit", "Running_Strafe_Right", 12, true, SWORD_GUARD],
			"back": [&"kaykit", "Walking_Backwards", 12, true, SWORD_GUARD],
		},
	},
	# 2. the runner: burnt bone and red rags, no weapon, stooped, an ember in the chest
	"runner": {
		"meshy": "runner", "height": 1.65, "triangles": BODY_TRIANGLES,
		"bend": {"Spine02": Vector3(14, 0, 0), "Head": Vector3(25, 0, 0)},
		"anims": {
			"walk": [&"ual", "Jog_Fwd", 20, true, RUNNER_JOG], "idle": [&"ual2", "Zombie_Idle", 12, true],
			# T5-04, T5-16: it gathers into a crouch, the arms drawn back (the coil of the library's jump), then bursts
			# all around itself spinning with its arms out (its blast lands as they open, EnemyDef.strike_at); it
			# was a still crouch and a punch ahead for a burst around it. A-T5-3: from 0.26 s, past the jump's raised knee
			# (from 0.18 one foot was 0.22 m over the other), to 0.4 to keep its pace (1.0 m/s drawn), in its 0.15 s
			"windup": [&"ual", "Jump_Start", 8, false, {"from": 0.26, "to": 0.4, "time": 0.15}],
			"attack": [&"kaykit", "2H_Melee_Attack_Spinning", 14, false],
		},
	},
	# the elite runner (7.4 m/s): the same figure on its own stride (RUNNER_ELITE_JOG); on the common one it ran 259
	# steps a minute (docs/qa/t5b_boss_fight.md), a frantic patter. Its EnemyDef.model is "runner_elite".
	"runner_elite": {
		"meshy": "runner", "height": 1.65, "triangles": BODY_TRIANGLES,
		"bend": {"Spine02": Vector3(14, 0, 0), "Head": Vector3(25, 0, 0)},
		"anims": {
			"walk": [&"ual", "Jog_Fwd", 20, true, RUNNER_ELITE_JOG], "idle": [&"ual2", "Zombie_Idle", 12, true],
			# T5-04, T5-16: it gathers into a crouch, the arms drawn back (the coil of the library's jump), then bursts
			# all around itself spinning with its arms out (its blast lands as they open, EnemyDef.strike_at); it
			# was a still crouch and a punch ahead for a burst around it. A-T5-3: from 0.26 s, past the jump's raised knee
			# (from 0.18 one foot was 0.22 m over the other), to 0.4 to keep its pace (1.0 m/s drawn), in its 0.15 s
			"windup": [&"ual", "Jump_Start", 8, false, {"from": 0.26, "to": 0.4, "time": 0.15}],
			"attack": [&"kaykit", "2H_Melee_Attack_Spinning", 14, false],
		},
	},
	# 3. the sorcerer: dark hood and robe over the ribs, steel arms; the staff with the cold violet gem is KayKit's
	"mage": {
		"meshy": "mage", "height": 1.92, "triangles": BODY_TRIANGLES,
		"palette": PALETTE + "mage.png",
		"held": [
			{"hand": "Left", "file": "Skeleton_Staff.gltf", "scale": 0.9, "rot": THUMB_UP, "paint": STAFF_PAINT, "name": "staff"},
			# the cold violet orb in the top of the staff: always lit, it swells as the bolt is conjured
			{"hand": "Left", "shape": "sphere", "at": Vector3(0, -1.27 * 0.9, 0), "size": Vector3(0.09, 0.09, 0), "cell": C_GLOW_COLD, "name": "orb", "mark": true},
		],
		"anims": {
			"walk": [&"ual", "Jog_Fwd", 20, true, MAGE_JOG], "idle": STAFF_CLIPS.idle,
			"rise": STAFF_RISE,
			"attack": STAFF_CLIPS.attack, "cast": STAFF_CLIPS.cast_rise, "cast_hold": STAFF_CLIPS.cast_hold,
			"shot": STAFF_CLIPS.shot, "exit": STAFF_CLIPS.exit,
		},
	},
	# 4. the crossbowman: dark hood, red scarf; the crossbow is KayKit's
	"archer": {
		"meshy": "archer", "height": 1.92, "triangles": BODY_TRIANGLES,
		"palette": PALETTE + "archer.png",
		# the crossbow in dark wood and iron, the size of a hand crossbow beside the figure (it was a white piece over
		# its head)
		"held": [{"hand": "Right", "file": "Skeleton_Crossbow.gltf", "scale": CROSSBOW_SCALE, "rot": THUMB_UP, "paint": CROSSBOW_PAINT, "name": "crossbow"}],
		"anims": {
			"walk": [&"ual", "Jog_Fwd", 20, true, CROSSBOW_JOG], "idle": [&"ual", "Idle", 12, true, CROSSBOW_GUARD],
			# T5-19: the shot leaves on the clip's first frame (Horde: ATTACK at state_t 0); the trunk kicks back with it
			"attack": [&"ual", "Pistol_Shoot", 14, false, {"kick": CROSSBOW_KICK}], "aim": [&"ual", "Pistol_Idle", 8, true],
		},
	},
	# 5. the brute: dark plate, the tower shield with its emblem and the sword are the model's own
	"guard": {
		"meshy": "guard", "height": 2.03, "triangles": BODY_TRIANGLES,
		# the tower shield follows the shoulder in one piece, the arm behind it as the model rests, swung in front of
		# the body; charcoal on a dark floor, it takes a rim of worn light steel and scratches. The sword is one piece too.
		"rigid": [
			{"bone": "LeftShoulder", "seeds": ["LeftHand", "LeftForeArm"], "plate": 0.09, "worn": true, "name": "shield"},
			{"bone": "RightHand", "seeds": ["RightHand"], "rod": 0.07, "name": "sword"},
		],
		"hold": {"bones": LEFT_ARM, "swing": SHIELD_FRONT},
		"even_legs": true,
		"anims": {
			"walk": [&"kaykit", "Walking_A", 20, true, BRUTE_STRIDE], "idle": [&"ual2", "Idle_Shield", 12, true, SWORD_GUARD],
			"attack": SWORD_BLOW,
			# the charge is announced braced behind the shield, brought further across the body
			"brace": [&"ual2", "Shield_Dash_RM", 8, false, {"from": 0.0, "to": 0.3, "time": 1.15, "hold": SHIELD_BRACE, "guard": [&"ual", "Sword_Idle", RIGHT_ARM]}],
			# T5-06: the charge is the shield's push that goes on from the brace (it was drawn with the middle of its
			# sword blow), run behind the shield (A-T5-1, BRUTE_RUSH), and after it the body sags, spent (T5-12,
			# Idle_Shield_Break: the shield lowered)
			"charge": [&"ual", "Sprint", 12, true, BRUTE_RUSH],
			"recover": [&"ual2", "Idle_Shield_Break", 10, false, {"guard": [&"ual", "Sword_Idle", RIGHT_ARM]}],
		},
	},
	# 6. the priest of the dead: dark purple hood and robes, no weapon
	"priest": {
		"meshy": "priest", "height": 1.93, "triangles": BODY_TRIANGLES,
		# LC-3: where its hands are in every pose (BakedModel.marks), for the light of the rite between them (EnemyFx)
		"marks": {"hands": ["LeftHand", "RightHand"], "hand_l": ["LeftHand"], "hand_r": ["RightHand"]},
		"anims": {
			"walk": [&"ual", "Walk", 20, true, OFFERING_GUARD], "idle": [&"ual", "Idle", 12, true, OFFERING_GUARD],
			# the ritual: both hands rise over the second its blow takes to fall
			"attack": CASTER_CLIPS.attack, "cast": [&"kaykit", "Cheer", 12, false, {"from": 0.0, "to": 0.84, "lift": 0.2, "time": 0.8, "bend": RITE_BEND, "bend_in": true}],
			# T5-13: the elite's three vines, each its own thrust of the hands
			"shot": [&"kaykit", "Spellcast_Shoot", 8, false, {"time": 0.3}],
		},
	},
	# 7. the guardian knight: crowned helmet, heavy plate, red cape; blade and shield are KayKit's
	"knight": {
		"meshy": "knight", "height": 2.03, "triangles": BODY_TRIANGLES,
		"palette": PALETTE + "knight.png",
		"held": [
			{"hand": "Right", "file": "Skeleton_Blade.gltf", "scale": 0.95, "rot": EDGE_OUT, "paint": KNIGHT_BLADE_PAINT, "name": "sword"},
			{"hand": "Left", "file": "Skeleton_Shield_Large_A.gltf", "scale": 0.75, "rot": Vector3(0, -90, 0), "paint": SHIELD_PAINT, "name": "shield"},
		],
		"anims": {
			"walk": [&"ual", "Walk", 20, true, KNIGHT_STRIDE], "idle": SHIELD_IDLE, "rise": SHIELD_RISE,
			"attack": SWORD_BLOW,
			# T5-07: its charge braced behind the round shield and run with it (it stood idle with a line on the floor);
			# A-T5-1: run low behind it (KNIGHT_RUSH)
			"brace": [&"ual2", "Shield_Dash_RM", 8, false, {"from": 0.0, "to": 0.3, "guard": [&"ual", "Sword_Idle", RIGHT_ARM]}],
			"charge": [&"ual", "Sprint", 12, true, KNIGHT_RUSH],
			"recover": [&"ual2", "Idle_Shield_Break", 10, false, {"guard": [&"ual", "Sword_Idle", RIGHT_ARM]}],
		},
	},
	# 8. the elder priest: crown over the hood, purple and gold robes; the staff with the purple orb is KayKit's
	"priest_elder": {
		"meshy": "priest_elder", "height": 2.07, "triangles": BODY_TRIANGLES,
		"palette": PALETTE + "priest_elder.png",
		"held": [
			{"hand": "Left", "file": "Skeleton_Staff.gltf", "scale": 0.9, "rot": THUMB_UP, "paint": STAFF_PAINT},
			# the purple orb held in the top of the staff (the sheet's block 8)
			{"hand": "Left", "shape": "sphere", "at": Vector3(0, -1.38 * 0.9, 0), "size": Vector3(0.12, 0.12, 0), "cell": C_GLOW_PURPLE, "name": "orb", "mark": true},
		],
		"anims": {
			"walk": [&"ual", "Walk_Formal", 20, true, ELDER_STRIDE], "idle": STAFF_CLIPS.idle, "rise": STAFF_RISE,
			"attack": STAFF_CLIPS.attack, "cast": STAFF_CLIPS.cast_rise, "cast_hold": STAFF_CLIPS.cast_hold,
			# T5-03: raising its dead is the priests' ritual gesture, not the staff's
			"summon": [&"kaykit", "Spellcast_Summon", 12, false, {"from": 1.0, "to": 3.05, "lift": 0.2, "time": 0.8}],
		},
	},
	# 9. Morvath, the king who betrayed the light: crown, long white hair, purple and gold robes, the purple gem on
	# the chest are the model's own; the blade is KayKit's
	"morvath": {
		"meshy": "morvath", "height": 2.02, "triangles": BODY_TRIANGLES,
		"palette": PALETTE + "morvath.png",
		"held": [{"hand": "Right", "file": "Skeleton_Blade.gltf", "scale": 0.8, "rot": EDGE_OUT, "paint": MORVATH_BLADE_PAINT}],
		"anims": {
			"walk": [&"ual", "Walk", 20, true, KING_STRIDE], "idle": [&"ual", "Idle", 12, true, SWORD_GUARD],
			"attack": SWORD_BLOW,
			# VX-14, heavier: every blow in both hands; the scythe is the library's great overhead blow, cut so the
			# blade is highest at Boss.SCYTHE_LIFT of the clip (where the wind-up holds it) and comes down inside the
			# Boss.SCYTHE_SWEEP after it, in the same 1.1 s (tools/clip_probe.gd: highest at 0.41, fastest at 0.46;
			# the one-handed Sword_Attack it replaces had already struck at 0.28, inside the wind-up)
			"slash1": [&"ual2", "Sword_Regular_A", 14, false, TWO_HANDS], "slash2": [&"ual2", "Sword_Regular_B", 14, false, TWO_HANDS],
			"slash3": [&"ual2", "Sword_Regular_C", 16, false, {"from": 0.158, "to": 1.258, "two_hands": true, "in_place": true}],
			# T5-15: the charge's own crouch, the start of the library's dash (it was the same still guard as the
			# Blades' wind-up), leaning into it; the Blades draw the blade back over the shoulder in both hands
			"dash_windup": [&"ual2", "Sword_Dash_RM", 8, false, {"from": 0.0, "to": 0.12, "bend": CHARGE_LEAN, "bend_in": true}],
			"dash": [&"ual2", "Sword_Dash_RM", 12, false, {"from": 0.12, "to": 0.72, "bend": CHARGE_LEAN, "bend_out": 0.12}],
			"blades_windup": [&"ual2", "Sword_Regular_B", 8, false, {"from": 0.0, "to": 0.2, "two_hands": true, "in_place": true, "bend": DRAW_BACK, "bend_in": true}],
			# the KayKit figure is half his height and hops as it conjures: on him the hop would be a flight
			"summon": [&"kaykit", "Spellcast_Summon", 20, false, {"lift": 0.2}], "rain": [&"kaykit", "Spellcast_Raise", 14, false, {"lift": 0.2}],
			# the curse and each wave of the storm are thrown (Boss poses it as they leave): the library's overhand
			# throw from the top of its swing, the release at the share the old cast had it, in the same 0.5 s
			"volley": [&"ual2", "OverhandThrow", 14, false, {"from": 0.26, "to": 0.92, "time": 0.5, "in_place": true}],
			# T5-17: the curse's own wind-up, the throw's draw back up to where volley starts (Boss poses it over the
			# wind-up, Horde.windup_arm; it was the start of the summon, the dead's gesture)
			"curse_windup": [&"ual2", "OverhandThrow", 8, false, {"from": 0.0, "to": 0.26, "in_place": true}],
			# T5-18: each wave of the eruptions raises the hands and brings them down (the raise of the cast, there and
			# back; Boss poses it by the share of each wave's beat), where the whole rain played once and held
			"rain_wave": [&"kaykit", "Spellcast_Raise", 12, false, {"from": 0.0, "to": 0.5, "there_and_back": true, "lift": 0.2}],
			# the roar: both arms flung up and out, chest open and head thrown back, in the same 1.03 s
			"roar": [&"kaykit", "Taunt_Longer", 14, false, {"from": 1.38, "to": 2.4133, "lift": 0.2, "bend": ROAR_BEND}],
			"stunned": [&"ual", "Crouch_Idle", 12, true],
		},
	},
}

## The KayKit figures of 2026-11-14 (see the top of this file).
const KAYKIT := {
	# 1. the soldier: round steel helmet, a pauldron, red rags at the waist and the neck, a blade
	"skeleton": {
		"model": "Skeleton_Minion.glb",
		"texture": PALETTE + "skeleton.png",
		"weapons": [["Skeleton_Blade.gltf", "handslot.r"]],
		# the Minion's bib covers the whole chest: red rags at the waist instead, front and back
		"hide": ["Skeleton_Minion_Cloak"],
		"props": [
			WAIST_FRONT,
			WAIST_BACK,
			{"bone": "head", "shape": "sphere", "at": Vector3(0, 0.5, -0.02), "size": Vector3(0.6, 0.62, 0), "cell": C_ARMOR, "cut": 0.45},
			{"bone": "head", "shape": "cylinder", "at": Vector3(0, 0.52, -0.02), "size": Vector3(0.63, 0.06, 0.63), "cell": C_DARK_METAL},
			{"bone": "upperarm.l", "shape": "sphere", "at": Vector3(0.05, 0.12, 0), "size": Vector3(0.2, 0.16, 0), "cell": C_DARK_METAL, "cut": 0.5},
			{"bone": "chest", "shape": "cylinder", "at": Vector3(0, 0.26, 0), "size": Vector3(0.19, 0.08, 0.24), "cell": C_RED},
		],
		"anims": SOLDIER_ANIMS,
	},
	# 2. the runner: bare bone and red rags, no weapon, stooped, embers glowing in the chest
	"runner": {
		"model": "Skeleton_Rogue.glb",
		"texture": PALETTE + "runner.png",
		"weapons": [],
		"hide": ["Skeleton_Rogue_Hood"],
		"bend": {"spine": Vector3(22, 0, 0), "head": Vector3(-14, 0, 0)},
		"props": [
			{"bone": "chest", "shape": "sphere", "at": Vector3(0.05, 0.12, 0.2), "size": Vector3(0.09, 0.09, 0), "cell": C_EMBER},
			{"bone": "chest", "shape": "sphere", "at": Vector3(-0.07, 0.2, 0.19), "size": Vector3(0.07, 0.07, 0), "cell": C_EMBER},
			{"bone": "chest", "shape": "sphere", "at": Vector3(0.0, 0.3, 0.17), "size": Vector3(0.06, 0.06, 0), "cell": C_EMBER},
		],
		"anims": {"walk": ["Running_C", 8, true], "attack": ["Unarmed_Melee_Attack_Punch_A", 6, false], "windup": ["Idle_Combat", 3, true], "hit": ["Hit_A", 4, false],
			"rise": ["Spawn_Ground_Skeletons", 8, false], "death": ["Death_C_Skeletons", 8, false], "idle": ["Idle_Combat", 4, true]},
	},
	# 3. the sorcerer: dark hood and robe with red, cold violet eyes and staff gem
	"mage": {
		"model": "Skeleton_Mage.glb",
		"texture": PALETTE + "mage.png",
		"weapons": [["Skeleton_Staff.gltf", "handslot.r"]],
		"hide": ["Skeleton_Mage_Hat"],
		"remap": {"Skeleton_Staff.gltf": {17: C_GLOW_COLD, C_BONE: C_WOOD}},
		"props": [
			{"bone": "head", "part": "Skeleton_Rogue.glb:Skeleton_Rogue_Hood", "cell": C_PURPLE},
			{"bone": "chest", "part": "Mage.glb:Mage_Cape", "cell": C_HOOD},
		],
		"anims": CASTER_ANIMS,
	},
	# 4. the crossbowman: dark purple hood, red scarf and cape, crossbow
	"archer": {
		"model": "Skeleton_Rogue.glb",
		"texture": PALETTE + "archer.png",
		"weapons": [["Skeleton_Crossbow.gltf", "handslot.r"]],
		"remap": {"Skeleton_Rogue_Cape": {C_HOOD: C_RED}},
		"props": [
			{"bone": "chest", "shape": "cylinder", "at": Vector3(0, 0.26, 0), "size": Vector3(0.19, 0.08, 0.24), "cell": C_RED},
		],
		"anims": {"walk": ["Running_A", 8, true], "attack": ["1H_Ranged_Shoot", 6, false], "aim": ["1H_Ranged_Aiming", 3, true], "hit": ["Hit_A", 4, false],
			"rise": ["Spawn_Ground_Skeletons", 8, false], "death": ["Death_C_Skeletons", 8, false], "idle": ["Idle_Combat", 4, true]},
	},
	# 5. the brute: dark bronze plate, tower shield with an emblem, a sword (not an axe)
	"guard": {
		"model": "Skeleton_Warrior.glb",
		"texture": PALETTE + "guard.png",
		"weapons": [["Skeleton_Blade.gltf", "handslot.r", 1.15], ["Skeleton_Shield_Large_A.gltf", "handslot.l", 1.15]],
		# bronze on the chest (the Warrior's bib hidden), red cloth at the waist
		"hide": ["Skeleton_Warrior_Cloak"],
		"props": [
			WAIST_FRONT,
			WAIST_BACK,
			{"bone": "handslot.l", "shape": "box", "at": Vector3(0, 0.05, 0.2), "rot": Vector3(0, 0, 45), "size": Vector3(0.22, 0.22, 0.04), "cell": C_DARK_METAL},
		],
		"anims": BRUTE_ANIMS,
	},
	# 6. the priest of the dead: a dark hood framing the skull (the sheet: the face reads inside it), purple robe with
	# gold trims, purple eyes, no weapon
	"priest": {
		"model": "Skeleton_Mage.glb",
		"texture": PALETTE + "priest.png",
		"weapons": [],
		"hide": ["Skeleton_Mage_Hat"],
		"props": [
			PRIEST_HOOD,
			{"bone": "chest", "part": "Mage.glb:Mage_Cape", "cell": C_PURPLE},
		],
		"anims": CASTER_ANIMS,
	},
	# 7. the guardian knight: helmet with a crown of spikes, red cape, sword and shield
	"knight": {
		"model": "Skeleton_Warrior.glb",
		"texture": PALETTE + "knight.png",
		"weapons": [["Skeleton_Blade.gltf", "handslot.r", 1.2], ["Skeleton_Shield_Large_A.gltf", "handslot.l"]],
		"hide": ["Skeleton_Warrior_Cloak"],
		"props": [
			WAIST_FRONT,
			WAIST_BACK,
			{"bone": "chest", "part": "Knight.glb:Knight_Cape", "cell": C_RED},
			CROWN,
		],
		"anims": BRUTE_ANIMS,
	},
	# 8. the elder priest: the priest's dark hood under a crown, purple and gold robe and cape, staff with a purple orb
	"priest_elder": {
		"model": "Skeleton_Mage.glb",
		"texture": PALETTE + "priest_elder.png",
		"weapons": [["Skeleton_Staff.gltf", "handslot.r", 1.2]],
		"hide": ["Skeleton_Mage_Hat"],
		"remap": {"Skeleton_Staff.gltf": {17: C_GLOW_PURPLE, C_BONE: C_WOOD}},
		"props": [
			PRIEST_HOOD,
			{"bone": "chest", "part": "Mage.glb:Mage_Cape", "cell": C_PURPLE},
			ELDER_CROWN,
			{"bone": "head", "shape": "sphere", "at": Vector3(0, 1.1, 0.4), "size": Vector3(0.07, 0.1, 0), "cell": C_GLOW_PURPLE},
			# the purple orb held in the top of the staff (the sheet's block 8)
			{"bone": "handslot.r", "shape": "sphere", "at": Vector3(0, 1.38, 0), "size": Vector3(0.13, 0.13, 0), "cell": C_GLOW_PURPLE},
		],
		"anims": CASTER_ANIMS,
	},
	# 9. Morvath, the king who betrayed the light: crown, long white hair, purple and gold robes, a purple gem on
	# the chest, purple magic
	"morvath": {
		"model": "Skeleton_Warrior.glb",
		"texture": PALETTE + "morvath.png",
		"weapons": [["Skeleton_Blade.gltf", "handslot.r", 0.85]],
		"hide": ["Skeleton_Warrior_Helmet"],
		"props": [
			{"bone": "chest", "part": "Knight.glb:Knight_Cape", "cell": C_PURPLE},
			CROWN,
			{"bone": "head", "shape": "sphere", "at": Vector3(0, 1.0, 0.36), "size": Vector3(0.08, 0.11, 0), "cell": C_GLOW_PURPLE},
			# the long white hair: locks hanging from the back and the sides of the skull
			{"bone": "head", "shape": "box", "at": Vector3(0, 0.35, -0.38), "rot": Vector3(-8, 0, 0), "size": Vector3(0.62, 0.95, 0.1), "cell": C_HAIR},
			{"bone": "head", "shape": "box", "at": Vector3(0.38, 0.4, -0.1), "rot": Vector3(0, 0, -6), "size": Vector3(0.08, 0.85, 0.36), "cell": C_HAIR},
			{"bone": "head", "shape": "box", "at": Vector3(-0.38, 0.4, -0.1), "rot": Vector3(0, 0, 6), "size": Vector3(0.08, 0.85, 0.36), "cell": C_HAIR},
			{"bone": "chest", "shape": "sphere", "at": Vector3(0, 0.25, 0.3), "size": Vector3(0.11, 0.15, 0), "cell": C_GLOW_PURPLE},
			{"bone": "upperarm.l", "shape": "sphere", "at": Vector3(0.05, 0.14, 0), "size": Vector3(0.24, 0.2, 0), "cell": C_GOLD, "cut": 0.5},
			{"bone": "upperarm.r", "shape": "sphere", "at": Vector3(-0.05, 0.14, 0), "size": Vector3(0.24, 0.2, 0), "cell": C_GOLD, "cut": 0.5},
		],
		"anims": {"walk": ["Walking_A", 10, true], "slash1": ["1H_Melee_Attack_Slice_Horizontal", 8, false], "slash2": ["1H_Melee_Attack_Slice_Diagonal", 8, false],
			"slash3": ["2H_Melee_Attack_Chop", 10, false], "dash_windup": ["2H_Melee_Idle", 4, true], "dash": ["Running_B", 8, true],
			"summon": ["Spellcast_Summon", 12, false], "rain": ["Spellcast_Raise", 8, false], "volley": ["Spellcast_Shoot", 6, false],
			"roar": ["Taunt", 8, false], "stunned": ["Hit_B", 6, false], "hit": ["Hit_A", 4, false], "rise": ["Spawn_Ground_Skeletons", 8, false],
			"death": ["Death_A", 8, false], "idle": ["Idle_Combat", 4, true], "attack": ["1H_Melee_Attack_Chop", 7, false]},
	},
}

## The hub's two people (HUB-D, docs/design/hub_spec_art.md 3.8; no Meshy): KayKit adventurers baked like the old
## crowd, `-- npcs [ids]`, to assets/baked/npc_<id>.res, drawn by HubNpc (scripts/render/hub_npc.gd) through a
## CrowdRenderer of their own. Each in a palette of its own (tools/make_palettes.gd -- npcs; "embed": kept compressed
## inside the .res, the palettes folder is not exported): earth, leather, dark iron,
## a dark petrol hood; no saturated petrol, emerald nor elite gold. On top of the KAYKIT entries: "height" (meters to
## the top of the head standing idle, the poses scaled to it and its soles set on the floor), "head_shrink" (on top of Slender's; the skeletons'
## HEAD_SHRINK when absent) and a clip's 4th field {"from", "to"} (seconds of the clip baked), "bend" (on top of the
## entry's, as the Meshy clips' "bend"). A prop's "name" keeps its
## vertices in BakedModel.parts (the smith's "hammer": where the head is when it lands, for the sparks).
const NPC_HAMMER := [
	# the handle along the fist (+Y of the hand slot), the head across it, its faces toward the swing
	{"bone": "handslot.r", "shape": "cylinder", "at": Vector3(0, 0.22, 0), "size": Vector3(0.035, 0.62, 0.04), "cell": 22, "name": "handle"},
	{"bone": "handslot.r", "shape": "box", "at": Vector3(0, 0.52, 0.02), "size": Vector3(0.13, 0.13, 0.3), "cell": 23, "name": "hammer"},
]
const NPCS := {
	# the Vendedor: the hooded rogue, a dark petrol hood and cape, a mantle of muted earth, leather; empty hands (the
	# counter hides his legs)
	"npc_vendor": {
		"model": "Rogue_Hooded.glb",
		"texture": PALETTE + "npc_vendor.png",
		"embed": true,
		"weapons": [],
		"hide": ["Knife_Offhand", "1H_Crossbow", "2H_Crossbow", "Knife", "Throwable"],
		"height": 1.9,
		"head_shrink": 0.9,
		"bend": {"spine": Vector3(8, 0, 0), "head": Vector3(6, 0, 0)},
		"anims": {"idle": ["Idle", 16, true], "gesture": ["Interact", 14, false]},
	},
	# the Forjador: the knight without helmet, shield, sword nor cape, a leather apron over dark wool, bare forearms,
	# a hammer of dark iron on a wooden handle; the blow on the anvil and his breath between bouts
	"npc_smith": {
		"model": "Knight.glb",
		"texture": PALETTE + "npc_smith.png",
		"embed": true,
		"weapons": [],
		"hide": ["Knight_Helmet", "Knight_Cape", "1H_Sword_Offhand", "Badge_Shield", "Rectangle_Shield", "Round_Shield",
			"Spike_Shield", "1H_Sword", "2H_Sword"],
		# the arms' plate turns to skin (cell 20), the legs' to dark wool (cell 19), the body's to the apron (3)
		"remap": {"Knight_ArmLeft": {3: 20}, "Knight_ArmRight": {3: 20}, "Knight_LegLeft": {3: 19}, "Knight_LegRight": {3: 19}},
		"props": NPC_HAMMER,
		"height": 1.95,
		"head_shrink": 0.9,
		"bend": {"spine": Vector3(6, 0, 0)},
		# the chop from the hammer raised off the anvil to the moment its head lands (the library's swing ends there),
		# the trunk leaning back 12 degrees on top of the entry's so the head lands on the anvil's face (0.9 m), not
		# 15 cm into the iron
		"anims": {"idle": ["Idle", 16, true], "gesture": ["1H_Melee_Attack_Chop", 12, false, {"from": 0.1, "to": 0.655, "bend": {"spine": Vector3(-12, 0, 0)}}]},
	},
}


var _done := false
## rig -> [model, AnimationPlayer, Skeleton3D], loaded when a figure first asks for it.
var _rigs := {}
## The entry's "hold" while it is baked (see MODELS).
var _hold := {}
## The entry's "even_legs" (see MODELS), for _pose_meshy.
var _even_legs := false
## Only these clips are baked when not empty (tools/walk_probe.gd measures walks without baking the rest).
var only_anims: Array = []

## DT-104: what a figure was baked from, kept in its .res (meta "bake_stamp"): its entry (every option, clip and
## piece, as text) and PIPELINE. tests/test_asset_budget.gd fails when a .res is stale. Raise PIPELINE when a change
## to the code below changes what every figure bakes to (the entries' own changes are seen by themselves).
const PIPELINE := 1


static func stamp(spec: Dictionary) -> int:
	return (var_to_str(spec) + "|%d" % PIPELINE).hash()


func _process(_delta: float) -> bool:
	if _done:
		return true
	_done = true
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://assets/baked"))
	var only := Array(OS.get_cmdline_user_args())
	var models: Dictionary = MODELS
	if only.has("kaykit"):
		only.erase("kaykit")
		models = KAYKIT
	if only.has("npcs"):
		only.erase("npcs")
		models = NPCS
	for id: String in models:
		if not only.is_empty() and not only.has(id):
			continue
		var t0 := Time.get_ticks_msec()
		var spec: Dictionary = models[id]
		var baked := _bake_meshy(spec) if spec.has("meshy") else _bake(spec)
		baked.set_meta(&"bake_stamp", stamp(spec))
		ResourceSaver.save(baked, "res://assets/baked/%s.res" % id, ResourceSaver.FLAG_COMPRESS)
		print("baked %s: %d anims, %d triangles, %.2f m, in %d ms" % [id, baked.frames.size(),
			(baked.mesh.surface_get_arrays(0)[Mesh.ARRAY_INDEX] as PackedInt32Array).size() / 3, baked.height, Time.get_ticks_msec() - t0])
		# the walk in the game (E1b-A1): the slide is drawn at the enemy's size, the steps at its speed
		var def_path := "res://data/enemies/%s.tres" % id
		if baked.ground_speed.has("walk") and ResourceLoader.exists(def_path):
			var d: EnemyDef = load(def_path)
			var ground: float = baked.ground_speed.walk
			if d.speed > 0.0:
				var rate := d.speed / (ground * d.size)
				print("  walk in the game: %.0f steps a minute, the foot slides %.1f cm a step" % [120.0 * rate / baked.duration(&"walk"),
					BakedModel.slide_per_step(baked.feet.walk, 1.0 / float(baked.fps.walk), ground) * d.size * 100.0])
	quit()
	return true


# ---------- the Meshy figures ----------

func _bake_meshy(spec: Dictionary) -> BakedModel:
	var model := (load(MESHY % [spec.meshy, spec.meshy]) as PackedScene).instantiate() as Node3D
	get_root().add_child(model)
	var skeleton := PoseBaker.find_skeleton(model)
	var mi := _first_mesh(model)
	var slim := MeshSlim.slim(mi.mesh.surface_get_arrays(0), PoseBaker.find_albedo(mi).get_image(), spec.triangles, ATLAS)
	var arrays: Array = slim[0]
	var atlas: Image = slim[1]
	var parts := {}
	for r: Dictionary in spec.get("rigid", []):
		var piece := _rigid(arrays, mi, r)
		if r.get("worn", false):
			_worn(arrays, atlas, piece)
		if r.has("name"):
			var mine := PackedInt32Array()
			for v in piece.size():
				if piece[v] == 1:
					mine.append(v)
			parts[r["name"]] = mine
	var marks := {}
	for mark: String in spec.get("marks", {}):
		marks[mark] = _marked(arrays, mi.skin, spec.marks[mark])
	var held: Array = spec.get("held", [])
	if not held.is_empty():
		atlas = _with_strip(atlas, load(spec.palette))
		_paint_swatches(atlas)
		arrays[Mesh.ARRAY_TEX_UV] = _squeezed(arrays[Mesh.ARRAY_TEX_UV], 0.0, BODY)
	var light := ArrayMesh.new()
	light.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	mi.mesh = light
	var anims: Dictionary = COMMON_ANIMS.merged(spec.anims, true)
	var bend: Dictionary = spec.get("bend", {})
	_hold = spec.get("hold", {})
	_even_legs = spec.get("even_legs", false)
	# the model at the height the game draws it at size 1: measured standing idle (the models rest in poses of their
	# own, the brute with its legs apart), then scaled; Retarget measures the scaled model
	var retargets := {}
	_pose_meshy(skeleton, model, retargets, anims.idle, 0.0, bend)
	var armature := skeleton.get_parent() as Node3D
	armature.scale *= float(spec.height) / PoseBaker.snapshot(model, skeleton).get_aabb().end.y
	retargets.clear()
	_pose_meshy(skeleton, model, retargets, anims.idle, 0.0, bend)
	var trunk := (armature.global_transform * skeleton.get_bone_global_pose(skeleton.find_bone("Head")).origin).y \
		- (armature.global_transform * skeleton.get_bone_global_pose(skeleton.find_bone("Hips")).origin).y
	print("  trunk (hips to the head bone) %.2f m, hips to the top of the head %.2f m" % [trunk,
		float(spec.height) - (armature.global_transform * skeleton.get_bone_global_pose(skeleton.find_bone("Hips")).origin).y])
	var extra: Array[Dictionary] = []
	# the held pieces' vertices come after the body's, in this order (PoseBaker.pose_arrays)
	var held_at := (arrays[Mesh.ARRAY_VERTEX] as PackedVector3Array).size()
	for h: Dictionary in held:
		var pieces := _held(h, _retarget(&"ual", retargets, skeleton, model), model)
		var mine := PackedInt32Array()
		for p: Dictionary in pieces:
			var n := ((p.mesh as Mesh).surface_get_arrays(0)[Mesh.ARRAY_VERTEX] as PackedVector3Array).size()
			for v in n:
				mine.append(held_at + v)
			held_at += n
		if h.has("name"):
			# "mark": a place kept in BakedModel.marks, not a part it carries (the staffs' orbs: the measures of the body
			# that leave the carried parts out stay what they were)
			if h.get("mark", false):
				marks[h["name"]] = mine
			else:
				parts[h["name"]] = mine
		extra.append_array(pieces)
	var out := BakedModel.new()
	out.painted = true
	out.parts = parts
	out.marks = marks
	# the glowing cells of the palette strip (the staffs' gems); none without a strip
	out.glow_from = Vector2(0.5, BODY + 0.75 * (1.0 - BODY)) if not held.is_empty() else Vector2(2, 2)
	# kept inside the baked file, compressed for the video card (where it is not supported the engine unpacks it)
	atlas.generate_mipmaps()
	atlas.compress(Image.COMPRESS_S3TC, Image.COMPRESS_SOURCE_SRGB)
	out.albedo = ImageTexture.create_from_image(atlas)
	var clips := {}
	var walk_poses: Array = []
	for anim: String in anims:
		if not only_anims.is_empty() and not only_anims.has(anim):
			continue
		var a: Array = anims[anim]
		var opts: Dictionary = a[4] if a.size() > 4 else {}
		var rig: Array = _rig(a[0])
		var player: AnimationPlayer = rig[1]
		if not player.has_animation(a[1]):
			push_error("bake: no clip %s in %s" % [a[1], a[0]])
			continue
		var from: float = opts.get("from", 0.0)
		var to: float = opts.get("to", player.get_animation(a[1]).length)
		var frames: int = a[2]
		var loops: bool = a[3]
		var poses: Array = []
		var low := INF
		var lean := 0.0
		# the walk keeps the clip's own rise and fall (E1a-2): one lift for the whole loop, the deepest any pose needs
		var ground := NAN
		var locked: Array = []
		# degrees the upper arms swing out to the side at most (left, right; ART_REVIEW E1a 2b: a free arm held out
		# like a scarecrow's)
		var arm_out := [0.0, 0.0]
		if anim == "walk":
			for i in frames:
				ground = minf(ground if not is_nan(ground) else INF,
					_pose_meshy(skeleton, model, retargets, a, from + (to - from) * i / frames, _bends(bend, opts.get("bend", {}))))
			if opts.get("lock", false):
				locked = _foot_lock(skeleton, model, retargets, a, ground, arrays, mi.skin, _bends(bend, opts.get("bend", {})))
		for i in frames:
			# loops sample [from, to); one-shots include the last pose; "there_and_back" goes to `to` and back to `from`
			var share := float(i) / (frames if loops else maxi(frames - 1, 1))
			if opts.get("there_and_back", false):
				share = 1.0 - absf(2.0 * share - 1.0)
			var t := from + (to - from) * share
			_pose_meshy(skeleton, model, retargets, a, t, _bends(bend, opts.get("bend", {})), _planted(skeleton, model, retargets, a, t, _bends(bend, opts.get("bend", {})), ground))
			if not locked.is_empty():
				# "stand" (m, A-T5-2): the hips that much higher over feet that stay where they were, the knees less bent
				var stand := Vector3(0.0, float(opts.get("stand", 0.0)) / PoseBaker.local_to(model, skeleton).basis.get_scale().y, 0.0)
				var hips_bone := skeleton.find_bone("Hips")
				skeleton.set_bone_pose_position(hips_bone, skeleton.get_bone_pose_position(hips_bone) + stand)
				_place_feet(skeleton, locked[i], -stand)
			if anim == "walk":
				for side in 2:
					arm_out[side] = maxf(arm_out[side], _arm_out(skeleton, model, "Left" if side == 0 else "Right"))
			if i == 0:
				lean = _lean(skeleton)
			var posed := PoseBaker.pose_arrays(model, skeleton, extra)
			for at: Vector3 in posed[Mesh.ARRAY_VERTEX]:
				low = minf(low, at.y)
			poses.append(posed)
			if anim == "walk":
				walk_poses.append(posed[Mesh.ARRAY_VERTEX])
		if opts.get("centred", false):
			_centre(poses)
		clips[anim] = poses
		if anim == "walk":
			print("  walk: the upper arms out to the side at most %.0f (left) and %.0f (right) degrees" % arm_out)
		out.fps[anim] = frames / float(opts.get("time", to - from))
		out.loops[anim] = loops
		print("  %s: %s %s, %d poses, %.2f s, lowest point %.2f m, trunk leaning %.0f degrees" % [anim, a[0], a[1], frames, frames / float(out.fps[anim]), low, lean])
	out.feet["walk"] = _soles(arrays, mi.skin, walk_poses)
	_pack(out, clips)
	# the top of the head, not of what it holds (a staff stands taller than its bearer)
	out.height = spec.height
	model.free()
	return out


## "centred" (T5b P2-2): a clip that must stay on its place on the floor though its body does not (the rise, lying
## down beside its hips and standing up) is moved in x and z so the middle of its vertices (BakedModel.pose_centre)
## goes from the place itself at the first pose to where the last one already stands, in a straight line; the last
## pose does not move (the clip after it starts there).
func _centre(poses: Array) -> void:
	var middles: Array[Vector2] = []
	for posed: Array in poses:
		var verts: PackedVector3Array = posed[Mesh.ARRAY_VERTEX]
		var sum := Vector2.ZERO
		var n := 0
		for v in range(0, verts.size(), 7):
			sum += Vector2(verts[v].x, verts[v].z)
			n += 1
		middles.append(sum / maxf(n, 1))
	var last := middles[middles.size() - 1]
	for i in poses.size():
		var share := float(i) / maxf(poses.size() - 1, 1)
		var by := last * share - middles[i]
		var shift := Vector3(by.x, 0.0, by.y)
		var verts: PackedVector3Array = poses[i][Mesh.ARRAY_VERTEX]
		for v in verts.size():
			verts[v] += shift
		poses[i][Mesh.ARRAY_VERTEX] = verts


## The poses of every clip (animation name -> Array of PoseBaker.pose_arrays) into the model's vertex animation
## (BakedModel.pack), with the walk's stride measured (BakedModel.ground_speed).
func _pack(out: BakedModel, clips: Dictionary) -> void:
	var idle: Array = clips.idle[0]
	var shape := ArrayMesh.new()
	# the shape drawn: triangles and texture coordinates (its vertices are replaced by the poses' in the shader); full
	# precision, it is only one mesh
	shape.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, idle)
	var packed := {}
	for anim: String in clips:
		var poses: Array = []
		for arrays: Array in clips[anim]:
			poses.append([arrays[Mesh.ARRAY_VERTEX], arrays[Mesh.ARRAY_NORMAL]])
		packed[anim] = poses
	out.pack(shape, packed)
	if out.loops.get("walk", false) and out.feet.has("walk"):
		var walk: Array = out.feet.walk
		var dt := 1.0 / float(out.fps.walk)
		var ground := BakedModel.ground_of(walk, dt)
		out.ground_speed["walk"] = ground
		print("  walk: the floor runs %.2f m/s under the planted foot, it slides %.3f m a step" % [ground, BakedModel.slide_per_step(walk, dt, ground)])
	print("  %d vertices, %d poses, pose images %dx%d" % [out.vertices, out.positions.get_height() * BakedModel.WIDTH / maxi(out.vertices, 1), BakedModel.WIDTH, out.positions.get_height()])


## The figure's skeleton in the pose of a clip at t seconds (see MODELS for the clip's fields).
## Returns how far the lowest bone was lifted to the floor (or `ground`, when given, is used for every pose of the clip:
## the walk, so a jog's flight stays in the air and the foot on the floor is never one pinned there in mid stride).
func _pose_meshy(skeleton: Skeleton3D, model: Node3D, retargets: Dictionary, a: Array, t: float, bend: Dictionary, ground := NAN) -> float:
	var opts: Dictionary = a[4] if a.size() > 4 else {}
	var guards: Array = opts.get("guard", [])
	if not guards.is_empty() and not guards[0] is Array:
		guards = [guards]
	var held: Array[Dictionary] = []
	for g: Array in guards:
		held.append(_solve(g[0], g[1], float(g[3]) if g.size() > 3 else t, true, retargets, skeleton, model))
	# "settle" ([rig, clip, seconds], T5b P1-2): over the clip's last seconds every bone eases into that clip's first
	# pose (a rise that ends in the figure's own guard, standing, the staff upright)
	var settle: Array = opts.get("settle", [])
	var settled := {}
	var settled_hips := Vector3.ZERO
	var settle_w := 0.0
	if not settle.is_empty():
		var end: float = opts.get("to", (_rig(a[0])[1] as AnimationPlayer).get_animation(a[1]).length)
		var span: float = float(settle[2]) * (end - float(opts.get("from", 0.0))) / float(opts.get("time", end - float(opts.get("from", 0.0))))
		settle_w = smoothstep(end - span, end, t)
		if settle_w > 0.0:
			settled = _solve(settle[0], settle[1], 0.0, true, retargets, skeleton, model)
			settled_hips = (retargets[settle[0]] as Retarget).hips_position(true)
	var pose := _solve(a[0], a[1], t, false, retargets, skeleton, model)
	var rt: Retarget = retargets[a[0]]
	for b: int in settled:
		if pose.has(b):
			pose[b] = (pose[b] as Quaternion).slerp(settled[b], settle_w)
	for i in guards.size():
		# the guarded bones (parents first) point where the guard clip has them, whatever the trunk does in this one
		for bone: StringName in guards[i][2]:
			var b := skeleton.find_bone(bone)
			pose[b] = (rt.turn(skeleton.get_bone_parent(b), pose).inverse() * rt.turn(b, held[i])).get_rotation_quaternion()
	if not _hold.is_empty():
		var held_bones: Array = _hold.bones
		for bone: StringName in held_bones:
			var b := skeleton.find_bone(bone)
			pose[b] = skeleton.get_bone_rest(b).basis.get_rotation_quaternion()
		var first := skeleton.find_bone(held_bones[0])
		var parent := rt.turn(skeleton.get_bone_parent(first), pose)
		var swing := Basis(Vector3.UP, deg_to_rad(float(opts.get("hold", _hold.get("swing", 0.0)))))
		pose[first] = (parent.inverse() * swing * parent * Basis(pose[first] as Quaternion)).get_rotation_quaternion()
	for b: int in pose:
		skeleton.set_bone_pose_rotation(b, pose[b])
	# clips that walk across the floor (_RM, or "in_place") stay in place: the game moves the figure
	var hips := rt.hips_position(String(a[1]).ends_with("_RM") or opts.get("in_place", false))
	var rest := skeleton.get_bone_rest(rt.hips_bone()).origin
	hips.y = rest.y + (hips.y - rest.y) * float(opts.get("lift", 1.0))
	if settle_w > 0.0:
		hips = hips.lerp(settled_hips, settle_w)
	skeleton.set_bone_pose_position(rt.hips_bone(), hips)
	# the clip's own bend may grow over it ("bend_in") or ease off from its start ("bend_out" seconds): a wind-up
	# that coils into the pose its blow uncoils from (T5-02)
	var own: Dictionary = opts.get("bend", {})
	var from: float = opts.get("from", 0.0)
	var to: float = opts.get("to", from + 1.0)
	var coil := 1.0
	if opts.get("bend_in", false):
		coil = smoothstep(from, to, t)
	elif opts.has("bend_out"):
		coil = 1.0 - smoothstep(from, from + float(opts.bend_out), t)
	for bone: String in bend:
		var i := skeleton.find_bone(bone)
		var deg: Vector3 = bend[bone] - (own.get(bone, Vector3.ZERO) as Vector3) * (1.0 - coil)
		var q := Quaternion.from_euler(Vector3(deg_to_rad(deg.x), deg_to_rad(deg.y), deg_to_rad(deg.z)))
		skeleton.set_bone_pose_rotation(i, skeleton.get_bone_pose_rotation(i) * q)
	# "kick" ({"at", "up", "down" in the clip's seconds, "bend"}, T5-19): a recoil, that bend grown over `up` seconds
	# from `at` and eased off over the `down` after
	if opts.has("kick"):
		var k: Dictionary = opts.kick
		var at := from + float(k.at)
		var up := float(k.up)
		var w := smoothstep(at, at + up, t) if t < at + up else 1.0 - smoothstep(at + up, at + up + float(k.down), t)
		for bone: String in k.bend:
			var i := skeleton.find_bone(bone)
			var deg: Vector3 = (k.bend[bone] as Vector3) * w
			var q := Quaternion.from_euler(Vector3(deg_to_rad(deg.x), deg_to_rad(deg.y), deg_to_rad(deg.z)))
			skeleton.set_bone_pose_rotation(i, skeleton.get_bone_pose_rotation(i) * q)
	if _even_legs:
		for leg: Array in LEGS:
			_even_leg(skeleton, leg)
	if opts.get("two_hands", false):
		_both_hands(skeleton, model, retargets)
	# on the floor: Retarget sets the hips by their height at rest, and a model that rests with its legs apart (the
	# brute) has longer legs than that, so standing straight would sink its feet. The lowest bone goes back to where
	# it rests (feet and toes) or to a body's thickness over the floor (lying down).
	var low := INF
	for b in skeleton.get_bone_count():
		var foot := String(skeleton.get_bone_name(b)).contains("Foot") or String(skeleton.get_bone_name(b)).contains("Toe")
		low = minf(low, skeleton.get_bone_global_pose(b).origin.y - (skeleton.get_bone_global_rest(b).origin.y if foot else BODY_THICKNESS))
	if not is_nan(ground):
		low = ground
	skeleton.set_bone_pose_position(rt.hips_bone(), hips - Vector3(0, low, 0))
	return low


## The walk's one floor for the whole loop (`ground`), or ("plant", T5-11) that share of the way to each pose's own
## lowest point: the body sinks a little where both feet are off the floor, so a run's flight stays near the floor.
func _planted(skeleton: Skeleton3D, model: Node3D, retargets: Dictionary, a: Array, t: float, bend: Dictionary, ground: float) -> float:
	var opts: Dictionary = a[4] if a.size() > 4 else {}
	if is_nan(ground) or not opts.has("plant"):
		return ground
	var own := _pose_meshy(skeleton, model, retargets, a, t, bend)
	return lerpf(ground, own, float(opts.plant))


## The bones of each leg, hip to ankle.
const LEGS := [[&"LeftUpLeg", &"LeftLeg", &"LeftFoot"], [&"RightUpLeg", &"RightLeg", &"RightFoot"]]


## One leg of a rig with a misplaced knee ("even_legs"), after the clip posed it: Retarget lines the rest up with
## the mannequin's straight leg, so a knee that rests far out of the line hip to ankle makes the leg that much
## longer once straight (the brute's left: 1.06 of its units against 0.8 at rest). The ankle is pulled back along
## the line from the hip to the share of its reach the clip gives it, times the leg's reach at rest, the knee
## bending toward the front of the body; the foot keeps the turn the clip gave it. A leg that rests straight is
## left as it is.
func _even_leg(skeleton: Skeleton3D, leg: Array) -> void:
	var up := skeleton.find_bone(leg[0])
	var mid := skeleton.find_bone(leg[1])
	var end := skeleton.find_bone(leg[2])
	var rest_a := skeleton.get_bone_global_rest(up).origin
	var rest_b := skeleton.get_bone_global_rest(mid).origin
	var rest_c := skeleton.get_bone_global_rest(end).origin
	var thigh := rest_a.distance_to(rest_b)
	var shin := rest_b.distance_to(rest_c)
	var share := rest_a.distance_to(rest_c) / (thigh + shin)
	if share > 0.97:
		return
	var hip := skeleton.get_bone_global_pose(up)
	var knee := skeleton.get_bone_global_pose(mid)
	var ankle := skeleton.get_bone_global_pose(end)
	var reach := hip.origin.distance_to(ankle.origin)
	var down := (ankle.origin - hip.origin).normalized()
	var hips := skeleton.find_bone("Hips")
	var front := skeleton.get_bone_global_pose(hips).basis * skeleton.get_bone_global_rest(hips).basis.inverse() * Vector3(0, 0, 1)
	_bend_limb(skeleton, leg, hip.origin + down * reach * share, front, thigh, shin)


## Meters between the two wrists on a hilt held in both hands ("two_hands").
const HAND_GAP := 0.11


## The blade held in both hands ("two_hands" in a clip's options, VX-14: the libraries' sword clips are one-handed,
## Morvath's blows are heavy): the left wrist goes to the hilt below the right one (toward the pommel, against the
## blade, along the grip _held puts the weapon on), the arm bent to reach it, the elbow out the way it bends.
func _both_hands(skeleton: Skeleton3D, model: Node3D, retargets: Dictionary) -> void:
	var ual := _retarget(&"ual", retargets, skeleton, model)
	var grip: Vector3 = ual.carry(&"RightHand", ual.source_rest(&"DEF-f_pinky.01.R") - ual.source_rest(&"DEF-f_index.01.R"), Vector3.ZERO)[0]
	var right := skeleton.get_bone_global_pose(skeleton.find_bone("RightHand"))
	var unit := PoseBaker.local_to(model, skeleton).basis.get_scale().x
	var target := right.origin - (right.basis * grip).normalized() * HAND_GAP / unit
	var up := skeleton.find_bone(LEFT_ARM[1])
	var mid := skeleton.find_bone(LEFT_ARM[2])
	var end := skeleton.find_bone(LEFT_ARM[3])
	var upper := skeleton.get_bone_global_rest(up).origin.distance_to(skeleton.get_bone_global_rest(mid).origin)
	var lower := skeleton.get_bone_global_rest(mid).origin.distance_to(skeleton.get_bone_global_rest(end).origin)
	var shoulder := skeleton.get_bone_global_pose(up).origin
	var elbow := skeleton.get_bone_global_pose(mid).origin
	var line := (target - shoulder).normalized()
	var bent := (elbow - shoulder) - line * (elbow - shoulder).dot(line)
	var pole := bent if bent.length() > 0.05 * (upper + lower) else Vector3.DOWN
	_bend_limb(skeleton, [LEFT_ARM[1], LEFT_ARM[2], LEFT_ARM[3]], target, pole, upper, lower)


## Two-bone reach: the end of a limb ([upper, lower, end] bones: a leg's ankle, an arm's wrist) to `target`
## (skeleton space), or as near as the limb reaches, the middle joint bending toward `pole`; the end (the foot, the
## hand) keeps the turn the clip gave it. thigh, shin: the lengths of its two bones.
func _bend_limb(skeleton: Skeleton3D, leg: Array, target: Vector3, pole: Vector3, thigh: float, shin: float) -> void:
	var up := skeleton.find_bone(leg[0])
	var mid := skeleton.find_bone(leg[1])
	var end := skeleton.find_bone(leg[2])
	var hip := skeleton.get_bone_global_pose(up)
	var knee := skeleton.get_bone_global_pose(mid)
	var ankle := skeleton.get_bone_global_pose(end)
	var want := clampf(hip.origin.distance_to(target), absf(thigh - shin) + 0.01 * (thigh + shin), (thigh + shin) * 0.995)
	var down := (target - hip.origin).normalized()
	var side := (pole - down * pole.dot(down)).normalized()
	var along := (thigh * thigh + want * want - shin * shin) / (2.0 * want)
	var new_knee := hip.origin + down * along + side * sqrt(maxf(thigh * thigh - along * along, 0.0))
	var turn_thigh := Quaternion((knee.origin - hip.origin).normalized(), (new_knee - hip.origin).normalized())
	skeleton.set_bone_global_pose(up, Transform3D(Basis(turn_thigh) * hip.basis, hip.origin))
	var knee_now := skeleton.get_bone_global_pose(mid)
	var ankle_now := skeleton.get_bone_global_pose(end).origin
	var reached := hip.origin + down * want
	var turn_shin := Quaternion((ankle_now - knee_now.origin).normalized(), (reached - knee_now.origin).normalized())
	skeleton.set_bone_global_pose(mid, Transform3D(Basis(turn_shin) * knee_now.basis, knee_now.origin))
	skeleton.set_bone_global_pose(end, Transform3D(ankle.basis, skeleton.get_bone_global_pose(end).origin))


## A foot is planted (and locked, "lock") while its sole is this close to the lowest the feet go in the loop.
const LOCK_CONTACT := 0.06


## The walk's feet locked on the floor ("lock" in a clip's options, E1b-A2): the libraries' walks, carried to
## another skeleton, slide at any one pace (the planted foot drifts back faster or slower than the body goes on).
## Every pose of the loop is posed once and the soles read (as _soles); then, while a foot is planted, the point it
## stands on (its lowest vertex) is made to go back at one speed, the mean the clip gives it times "stride"
## (above 1, a longer step at the same pace: fewer steps a minute for the same speed in the game), by moving the
## foot along the floor, its turn kept; in the air the foot goes smoothly from where it was lifted to where it comes
## down. Returns, per pose, per leg (LEGS), how far the ankle moves (skeleton space); _place_feet bends the leg there.
func _foot_lock(skeleton: Skeleton3D, model: Node3D, retargets: Dictionary, a: Array, ground: float, body: Array, skin: Skin, bend: Dictionary) -> Array:
	var opts: Dictionary = a[4] if a.size() > 4 else {}
	var from: float = opts.get("from", 0.0)
	var to: float = opts.get("to", (_rig(a[0])[1] as AnimationPlayer).get_animation(a[1]).length)
	var frames: int = a[2]
	var dt := float(opts.get("time", to - from)) / frames
	var verts: Array = []
	for i in frames:
		var at := from + (to - from) * i / frames
		_pose_meshy(skeleton, model, retargets, a, at, bend, _planted(skeleton, model, retargets, a, at, bend, ground))
		verts.append(PoseBaker.pose_arrays(model, skeleton)[Mesh.ARRAY_VERTEX])
	var soles := _soles(body, skin, verts)
	var floor_y := INF
	for track: Array in soles:
		for p: PackedVector3Array in track:
			for at in p:
				floor_y = minf(floor_y, at.y)
	# per foot: which poses it is planted in, the vertex it stands on, and its move to the next pose (x, z)
	var planted: Array = []
	var moves: Array = []
	var back := 0.0
	var count := 0
	for track: Array in soles:
		var down: Array[bool] = []
		var step: Array[Vector2] = []
		for i in frames:
			var p: PackedVector3Array = track[i]
			var v := 0
			for k in p.size():
				if p[k].y < p[v].y:
					v = k
			down.append(p[v].y < floor_y + LOCK_CONTACT)
			var next: Vector3 = (track[(i + 1) % frames] as PackedVector3Array)[v]
			step.append(Vector2(next.x - p[v].x, next.z - p[v].z))
			if down[i]:
				back -= step[i].y
				count += 1
		planted.append(down)
		moves.append(step)
	if count == 0:
		return []
	var speed := back / (count * dt) * float(opts.get("stride", 1.0))
	var to_root := PoseBaker.local_to(model, skeleton).basis.inverse()
	var out: Array = []
	out.resize(frames)
	for i in frames:
		out[i] = [Vector3.ZERO, Vector3.ZERO]
	for f in soles.size():
		var down: Array[bool] = planted[f]
		var step: Array[Vector2] = moves[f]
		if not down.has(false) or not down.has(true):
			continue
		# the offsets along each run of planted poses (and the pose after it, where the foot lifts off)
		var shift: Array[Vector2] = []
		shift.resize(frames)
		var known: Array[bool] = []
		known.resize(frames)
		known.fill(false)
		var start := down.find(true)
		while down[(start + frames - 1) % frames]:
			start = (start + frames - 1) % frames
		var i := start
		for _guard in frames:
			if down[i] and not down[(i + frames - 1) % frames]:
				# a run starts: offsets add up the slide, then centered on the run
				var run: Array[int] = [i]
				var at := Vector2.ZERO
				var sum := Vector2.ZERO
				var j := i
				var acc: Array[Vector2] = [at]
				while down[j] and run.size() <= frames:
					at += Vector2(0.0, -speed * dt) - step[j]
					j = (j + 1) % frames
					run.append(j)
					acc.append(at)
				for k in acc.size():
					sum += acc[k]
				for k in run.size():
					shift[run[k]] = acc[k] - sum / acc.size()
					known[run[k]] = true
			i = (i + 1) % frames
		# in the air: from the offset it lifted off with to the one it comes down with
		for k in frames:
			if known[k]:
				continue
			var b := k
			while not known[(b + frames - 1) % frames]:
				b = (b + frames - 1) % frames
			var e := k
			while not known[e]:
				e = (e + 1) % frames
			var span := ((e - b + frames) % frames) + 1
			var w := smoothstep(0.0, 1.0, float((k - b + frames) % frames + 1) / span)
			shift[k] = shift[(b + frames - 1) % frames].lerp(shift[e], w)
		for k in frames:
			(out[k] as Array)[f] = to_root * Vector3(shift[k].x, 0.0, shift[k].y)
	return out


## The feet of a posed skeleton moved by _foot_lock's offsets for the pose (per leg, skeleton space), each leg bent
## to reach (_bend_limb), the knee keeping the side it bends to.
func _place_feet(skeleton: Skeleton3D, offsets: Array, drop := Vector3.ZERO) -> void:
	var hips := skeleton.find_bone("Hips")
	var front := skeleton.get_bone_global_pose(hips).basis * skeleton.get_bone_global_rest(hips).basis.inverse() * Vector3(0, 0, 1)
	for l in LEGS.size():
		var leg: Array = LEGS[l]
		var up := skeleton.find_bone(leg[0])
		var mid := skeleton.find_bone(leg[1])
		var end := skeleton.find_bone(leg[2])
		var thigh := skeleton.get_bone_global_rest(up).origin.distance_to(skeleton.get_bone_global_rest(mid).origin)
		var shin := skeleton.get_bone_global_rest(mid).origin.distance_to(skeleton.get_bone_global_rest(end).origin)
		var hip := skeleton.get_bone_global_pose(up).origin
		var knee := skeleton.get_bone_global_pose(mid).origin
		var ankle := skeleton.get_bone_global_pose(end).origin
		var line := (ankle - hip).normalized()
		var bent := (knee - hip) - line * (knee - hip).dot(line)
		var pole := front if bent.length() < 0.02 * (thigh + shin) else bent.normalized() + front * 0.2
		_bend_limb(skeleton, leg, ankle + (offsets[l] as Vector3) + drop, pole, thigh, shin)


## The bones of each foot (left, then right): their vertices are the feet whose stride is measured.
const FEET := [[&"LeftFoot", &"LeftToeBase"], [&"RightFoot", &"RightToeBase"]]
const SOLE := 0.08


## The soles of the feet through the poses of a loop (BakedModel.feet): per foot, per pose, the vertices of the foot
## (half their skin or more on its bones) that come within SOLE meters of the floor in some pose of the loop. body: the figure's own mesh
## arrays (the first vertices of every pose), skin: its binds.
## LC-3: the body's vertices bound at least half to these bones (a mark: where its hands are, BakedModel.marks).
func _marked(body: Array, skin: Skin, names: Array) -> PackedInt32Array:
	var bones: PackedInt32Array = body[Mesh.ARRAY_BONES]
	var weights: PackedFloat32Array = body[Mesh.ARRAY_WEIGHTS]
	var count := (body[Mesh.ARRAY_VERTEX] as PackedVector3Array).size()
	var per := bones.size() / count
	var binds: Array[int] = []
	for i in skin.get_bind_count():
		if names.has(String(skin.get_bind_name(i))):
			binds.append(i)
	var out := PackedInt32Array()
	for v in count:
		var share := 0.0
		for k in per:
			if binds.has(bones[v * per + k]):
				share += weights[v * per + k]
		if share >= 0.5:
			out.append(v)
	print("  mark %s: %d vertices" % [names, out.size()])
	return out


func _soles(body: Array, skin: Skin, poses: Array) -> Array:
	var bones: PackedInt32Array = body[Mesh.ARRAY_BONES]
	var weights: PackedFloat32Array = body[Mesh.ARRAY_WEIGHTS]
	var count := (body[Mesh.ARRAY_VERTEX] as PackedVector3Array).size()
	var per := bones.size() / count
	var out := []
	for foot: Array in FEET:
		var binds: Array[int] = []
		for i in skin.get_bind_count():
			if foot.has(skin.get_bind_name(i)):
				binds.append(i)
		var mine: Array[int] = []
		var floor_y := INF
		for v in count:
			var share := 0.0
			for k in per:
				if binds.has(bones[v * per + k]):
					share += weights[v * per + k]
			if share >= 0.5:
				mine.append(v)
				for p: PackedVector3Array in poses:
					floor_y = minf(floor_y, p[v].y)
		var sole: Array[int] = []
		for v in mine:
			var low := INF
			for p: PackedVector3Array in poses:
				low = minf(low, p[v].y)
			if low < floor_y + SOLE:
				sole.append(v)
		var track: Array = []
		for p: PackedVector3Array in poses:
			var at := PackedVector3Array()
			for v in sole:
				at.append(p[v])
			track.append(at)
		out.append(track)
	return out


## Two lists of bends as one (the same bone in both: the degrees add up).
func _bends(a: Dictionary, b: Dictionary) -> Dictionary:
	var out := a.duplicate()
	for bone: String in b:
		out[bone] = (out.get(bone, Vector3.ZERO) as Vector3) + (b[bone] as Vector3)
	return out


## Degrees an upper arm ("Left" or "Right") is out to the side of the body, in the plane across it (0: hanging
## along the side, 90: held level out to the side), in the pose the skeleton is in (the model faces +z).
func _arm_out(skeleton: Skeleton3D, model: Node3D, side: String) -> float:
	var to_root := PoseBaker.local_to(model, skeleton)
	var arm := to_root * skeleton.get_bone_global_pose(skeleton.find_bone(side + "Arm")).origin
	var fore := to_root * skeleton.get_bone_global_pose(skeleton.find_bone(side + "ForeArm")).origin
	var d := (fore - arm).normalized()
	return rad_to_deg(atan2(absf(d.x), -d.y))


## Degrees the trunk leans from upright in the pose the skeleton is in (hips to neck).
func _lean(skeleton: Skeleton3D) -> float:
	var up := skeleton.get_bone_global_pose(skeleton.find_bone("neck")).origin - skeleton.get_bone_global_pose(skeleton.find_bone("Hips")).origin
	return rad_to_deg(up.angle_to(Vector3.UP))


## The figure's bone rotations for a clip of a rig at t seconds (wrap: t past the end starts again).
func _solve(rig_id: StringName, clip: String, t: float, wrap: bool, retargets: Dictionary, skeleton: Skeleton3D, model: Node3D) -> Dictionary:
	var player: AnimationPlayer = _rig(rig_id)[1]
	player.play(clip)
	player.seek(fmod(t, player.get_animation(clip).length) if wrap else t, true)
	return _retarget(rig_id, retargets, skeleton, model).solve()


func _rig(id: StringName) -> Array:
	if not _rigs.has(id):
		var src := (load(RIGS[id]) as PackedScene).instantiate() as Node3D
		get_root().add_child(src)
		_rigs[id] = [src, PoseBaker.find_player(src), PoseBaker.find_skeleton(src)]
	return _rigs[id]


func _retarget(rig_id: StringName, retargets: Dictionary, skeleton: Skeleton3D, model: Node3D) -> Retarget:
	if not retargets.has(rig_id):
		var rig := _rig(rig_id)
		retargets[rig_id] = Retarget.new(rig[2], rig[0], skeleton, model, Retarget.RIGS[rig_id])
	return retargets[rig_id]


## One held piece as pieces for PoseBaker.snapshot. The hand's grip comes from the mannequin's fist, as the hero's
## sword (tools/bake_hero.gd): the handle runs across the knuckles, through the middle of the hand.
func _held(h: Dictionary, ual: Retarget, model: Node3D) -> Array[Dictionary]:
	var side := "R" if h.hand == "Right" else "L"
	var bone := StringName(String(h.hand) + "Hand")
	var index := ual.source_rest(StringName("DEF-f_index.01." + side))
	var pinky := ual.source_rest(StringName("DEF-f_pinky.01." + side))
	var wrist := ual.source_rest(StringName("DEF-hand." + side))
	var middle := ual.source_rest(StringName("DEF-f_middle.01." + side))
	var grip := ual.carry(bone, pinky - index, (index + pinky) * 0.5 - wrist)
	var out_of_fist: Vector3 = ual.carry(bone, middle - wrist, Vector3.ZERO)[0]
	var y: Vector3 = grip[0]
	var z := (out_of_fist - y * out_of_fist.dot(y)).normalized()
	var unit := Retarget._space(ual.target, model).get_scale().x
	var hand := Transform3D(Basis(y.cross(z), y, z).scaled(Vector3.ONE / unit), grip[1])
	var rot: Vector3 = h.get("rot", Vector3.ZERO)
	var own := Transform3D(Basis.from_euler(Vector3(deg_to_rad(rot.x), deg_to_rad(rot.y), deg_to_rad(rot.z))).scaled(Vector3.ONE * float(h.get("scale", 1.0))), h.get("at", Vector3.ZERO))
	var pieces: Array[Dictionary] = []
	if h.has("file"):
		var scene: Node = (load(WEAPON + h.file) as PackedScene).instantiate()
		var mi := _first_mesh(scene)
		var mesh: Mesh = _lod(mi.mesh, int(h.lod)) if int(h.get("lod", 0)) > 0 else mi.mesh
		mesh = _repainted(mesh, h.paint) if h.has("paint") else mesh
		pieces.append({"mesh": mesh, "bone": bone, "transform": hand * own * mi.transform})
		print("  held %s: %.2f m long" % [h.file, mi.mesh.get_aabb().get_longest_axis_size() * float(h.get("scale", 1.0))])
		scene.free()
	else:
		var shape := h.duplicate()
		shape.erase("at")
		shape.erase("rot")
		shape.erase("scale")
		shape["bone"] = bone
		for p in _prop(shape):
			p.transform = hand * own * (p.transform as Transform3D)
			pieces.append(p)
	# the held pieces are painted by the palette strip under the body's atlas
	for p in pieces:
		var arrays := (p.mesh as Mesh).surface_get_arrays(0)
		arrays[Mesh.ARRAY_TEX_UV] = _squeezed(arrays[Mesh.ARRAY_TEX_UV], BODY, 1.0 - BODY)
		var strip := ArrayMesh.new()
		strip.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
		p.mesh = strip
	return pieces


## DT-107: a held piece's "lod" (1, 2...): that level of the engine's own chain of simpler meshes (generate_lods, as
## MeshSlim does for the bodies), the vertices it no longer uses dropped; its UVs and normals kept (the palette's
## cells stay where they were). The KayKit pieces end on their seams: blade 457 to 227 and 41, staff 1519 to 759
## and 218, crossbow 584 to 292, shield 626 to 304 and 78 triangles. Level 1 keeps each piece's outline (the staff's
## level 2 loses its head, 0.2 m of its length).
func _lod(mesh: Mesh, level: int) -> Mesh:
	var arrays := mesh.surface_get_arrays(0)
	var chain := ImporterMesh.new()
	chain.add_surface(Mesh.PRIMITIVE_TRIANGLES, arrays)
	chain.generate_lods(MeshSlim.SMOOTH_ANGLE, 0.0, [])
	var count := chain.get_surface_lod_count(0)
	if count == 0:
		return mesh
	var index := chain.get_surface_lod_indices(0, mini(level, count) - 1)
	var keep := {}
	var out := []
	out.resize(Mesh.ARRAY_MAX)
	var verts := PackedVector3Array()
	var normals := PackedVector3Array()
	var uvs := PackedVector2Array()
	var src_v: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
	var src_n: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]
	var src_uv: PackedVector2Array = arrays[Mesh.ARRAY_TEX_UV]
	var out_i := PackedInt32Array()
	for i in index:
		if not keep.has(i):
			keep[i] = verts.size()
			verts.append(src_v[i])
			normals.append(src_n[i])
			uvs.append(src_uv[i])
		out_i.append(keep[i])
	out[Mesh.ARRAY_VERTEX] = verts
	out[Mesh.ARRAY_NORMAL] = normals
	out[Mesh.ARRAY_TEX_UV] = uvs
	out[Mesh.ARRAY_INDEX] = out_i
	var lean := ArrayMesh.new()
	lean.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, out)
	lean.surface_set_material(0, mesh.surface_get_material(0))
	print("  held lod %d: %d to %d triangles, size %s to %s" % [level, (arrays[Mesh.ARRAY_INDEX] as PackedInt32Array).size() / 3,
		out_i.size() / 3, mesh.get_aabb().size, lean.get_aabb().size])
	return lean


## Worn light steel (the rim of a shield, a scratch), how much lighter the plate's painting gets, how many scratches
## cross its faces and how wide they are (the model's meters).
const WORN_STEEL := Color(0.6, 0.6, 0.57)
const WORN_LIFT := 1.4
const WORN_SCRATCHES := 16
const WORN_SCRATCH_WIDTH := 0.0055
## A triangle whose normal is this close to the faces' plane is rim; the faces take a band of the same steel this
## wide (meters of the model: 3 to 4 cm at the brute's size) along it.
const WORN_RIM := 0.45
const WORN_EDGE := 0.024


## A piece of the model's own body made rigid (see "rigid" in MODELS): from the vertices its seed bones hold, the
## piece is everything joined to them that lies in the same plane (a plate) or along the same line (a rod); all of
## it then follows one bone. Returns which vertices are the piece.
func _rigid(arrays: Array, mi: MeshInstance3D, r: Dictionary) -> PackedByteArray:
	var verts: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
	var index: PackedInt32Array = arrays[Mesh.ARRAY_INDEX]
	var bones: PackedInt32Array = arrays[Mesh.ARRAY_BONES]
	var weights: PackedFloat32Array = arrays[Mesh.ARRAY_WEIGHTS]
	var per := bones.size() / verts.size()
	var binds := {}
	for i in mi.skin.get_bind_count():
		binds[String(mi.skin.get_bind_name(i))] = i
	var seed_binds: Array[int] = []
	for name: String in r.seeds:
		seed_binds.append(binds[name])
	var seeds: Array[int] = []
	for v in verts.size():
		var share := 0.0
		for k in per:
			if seed_binds.has(bones[v * per + k]):
				share += weights[v * per + k]
		if share > 0.6:
			seeds.append(v)
	var plate := r.has("plate")
	var band: float = r.plate if plate else r.rod
	# vertices at the same place are one (the texture's seams split them), joined along the triangles' sides
	var place := {}
	var rep := PackedInt32Array()
	rep.resize(verts.size())
	for v in verts.size():
		var key := Vector3i((verts[v] * 20000.0).round())
		if not place.has(key):
			place[key] = v
		rep[v] = place[key]
	var next := {}
	for t in range(0, index.size(), 3):
		for k in 3:
			var a := rep[index[t + k]]
			var b := rep[index[t + (k + 1) % 3]]
			if not next.has(a):
				next[a] = []
			if not next.has(b):
				next[b] = []
			(next[a] as Array).append(b)
			(next[b] as Array).append(a)
	# its plane (the direction it is thinnest in) or its line (the one it is longest in) is fitted to the seeds,
	# the piece is grown from them over the surface as far as it stays in that plane or on that line, and the fit
	# is made again on what was found (the seeds are only the part of it the right bones happened to hold)
	var inside := PackedByteArray()
	var chosen := seeds
	for pass_i in 5:
		var center := Vector3.ZERO
		for v in chosen:
			center += verts[v]
		center /= chosen.size()
		var cov := Basis(Vector3.ZERO, Vector3.ZERO, Vector3.ZERO)
		for v in chosen:
			var d := verts[v] - center
			cov.x += d * d.x
			cov.y += d * d.y
			cov.z += d * d.z
		var trace := cov.x.x + cov.y.y + cov.z.z
		var m := Basis(Vector3(trace, 0, 0) - cov.x, Vector3(0, trace, 0) - cov.y, Vector3(0, 0, trace) - cov.z) if plate else cov
		var axis := Vector3(0.3, 0.5, 0.8).normalized()
		for it in 80:
			axis = (m * axis).normalized()
		inside = PackedByteArray()
		inside.resize(verts.size())
		var queue: Array[int] = []
		for v in seeds:
			if inside[rep[v]] == 0 and _off(verts[v], center, axis, plate) < band:
				inside[rep[v]] = 1
				queue.append(rep[v])
		chosen = queue.duplicate()
		while not queue.is_empty():
			var v: int = queue.pop_back()
			for o: int in next.get(v, []):
				if inside[o] == 0 and _off(verts[o], center, axis, plate) < band:
					inside[o] = 1
					queue.append(o)
					chosen.append(o)
	var bind: int = binds[String(r.bone)]
	var count := 0
	for v in verts.size():
		inside[v] = inside[rep[v]]
		if inside[v] == 1:
			count += 1
			for k in per:
				bones[v * per + k] = bind
				weights[v * per + k] = 1.0 if k == 0 else 0.0
	arrays[Mesh.ARRAY_BONES] = bones
	arrays[Mesh.ARRAY_WEIGHTS] = weights
	print("  rigid on %s: %d of %d vertices, %d seeds" % [r.bone, count, verts.size(), seeds.size()])
	return inside


## How far a point is from a plate's plane (axis: its normal) or from a rod's line (axis: its direction).
func _off(p: Vector3, center: Vector3, axis: Vector3, plate: bool) -> float:
	var d := p - center
	return absf(d.dot(axis)) if plate else (d - axis * d.dot(axis)).length()


## Repaints a rigid piece of the model's own body in its texture: its flat faces are lifted off the dark and
## scratched; what joins them (the rim) becomes worn light steel.
func _worn(arrays: Array, atlas: Image, part: PackedByteArray) -> void:
	var verts: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
	var uvs: PackedVector2Array = arrays[Mesh.ARRAY_TEX_UV]
	var index: PackedInt32Array = arrays[Mesh.ARRAY_INDEX]
	# the piece's triangles, and the axis its faces look along (the mean of their normals, folded to one side)
	var tris: Array[int] = []
	var normals: Array[Vector3] = []
	var face := Vector3.ZERO
	var biggest := 0.0
	for t in range(0, index.size(), 3):
		if part[index[t]] + part[index[t + 1]] + part[index[t + 2]] < 3:
			continue
		var n := (verts[index[t + 1]] - verts[index[t]]).cross(verts[index[t + 2]] - verts[index[t]])
		tris.append(t)
		normals.append(n)
		if n.length() > biggest:
			biggest = n.length()
			face = n.normalized()
	if tris.is_empty():
		push_error("bake: nothing to wear")
		return
	for pass_i in 6:
		var sum := Vector3.ZERO
		for n in normals:
			sum += n * signf(n.dot(face))
		face = sum.normalized()
	var across := face.cross(Vector3.UP).normalized()
	var along := face.cross(across)
	# scratches: short straight strokes across the faces, the same every bake
	var rng := RandomNumberGenerator.new()
	rng.seed = 11
	var lo := Vector2(INF, INF)
	var hi := Vector2(-INF, -INF)
	for t in tris:
		for k in 3:
			var p := verts[index[t + k]]
			lo = lo.min(Vector2(p.dot(across), p.dot(along)))
			hi = hi.max(Vector2(p.dot(across), p.dot(along)))
	var strokes: Array[PackedVector2Array] = []
	for i in WORN_SCRATCHES:
		var from := Vector2(rng.randf_range(lo.x, hi.x), rng.randf_range(lo.y, hi.y))
		var to := from + Vector2.from_angle(rng.randf_range(-1.2, -0.3) + (PI if rng.randf() < 0.3 else 0.0)) * rng.randf_range(0.12, 0.3) * (hi - lo).length()
		strokes.append(PackedVector2Array([from, to]))
	# where a face meets the rim: the sides shared by a triangle of each (by place: the texture's seams split them)
	var sides := {}
	for i in tris.size():
		var is_rim := absf(normals[i].normalized().dot(face)) < WORN_RIM
		for k in 3:
			var p0 := verts[index[tris[i] + k]]
			var p1 := verts[index[tris[i] + (k + 1) % 3]]
			var k0 := Vector3i((p0 * 20000.0).round())
			var k1 := Vector3i((p1 * 20000.0).round())
			var key := [k0, k1] if k0 < k1 else [k1, k0]
			if not sides.has(key):
				sides[key] = [false, false, p0, p1]
			sides[key][0 if is_rim else 1] = true
	var creases: Array[PackedVector3Array] = []
	for key: Array in sides:
		if sides[key][0] and sides[key][1]:
			creases.append(PackedVector3Array([sides[key][2], sides[key][3]]))
	var size := Vector2(atlas.get_width(), atlas.get_height())
	var painted := 0
	for i in tris.size():
		var t := tris[i]
		var rim := absf(normals[i].normalized().dot(face)) < WORN_RIM
		var middle := (verts[index[t]] + verts[index[t + 1]] + verts[index[t + 2]]) / 3.0
		var reach := maxf(middle.distance_to(verts[index[t]]), maxf(middle.distance_to(verts[index[t + 1]]), middle.distance_to(verts[index[t + 2]]))) + WORN_EDGE
		var close: Array[PackedVector3Array] = []
		if not rim:
			for crease in creases:
				if Geometry3D.get_closest_point_to_segment(middle, crease[0], crease[1]).distance_to(middle) < reach:
					close.append(crease)
		var a := uvs[index[t]] * size
		var b := uvs[index[t + 1]] * size
		var c := uvs[index[t + 2]] * size
		var area := (b - a).cross(c - a)
		if absf(area) < 0.0001:
			continue
		var from_px := Vector2i(a.min(b).min(c).floor()) - Vector2i.ONE
		var to_px := Vector2i(a.max(b).max(c).ceil()) + Vector2i.ONE
		for y in range(maxi(from_px.y, 0), mini(to_px.y, atlas.get_height() - 1) + 1):
			for x in range(maxi(from_px.x, 0), mini(to_px.x, atlas.get_width() - 1) + 1):
				var q := Vector2(x + 0.5, y + 0.5)
				var wa := (b - q).cross(c - q) / area
				var wb := (c - q).cross(a - q) / area
				var wc := 1.0 - wa - wb
				# a texel past the edge is still painted: the texture is sampled between texels
				if wa < -0.35 or wb < -0.35 or wc < -0.35:
					continue
				var old := atlas.get_pixel(x, y)
				var steel := WORN_STEEL * (0.8 + 0.2 * rng.randf())
				var out: Color
				if rim:
					out = old.lerp(steel, 0.85)
				else:
					var p := verts[index[t]] * wa + verts[index[t + 1]] * wb + verts[index[t + 2]] * wc
					var flat := Vector2(p.dot(across), p.dot(along))
					var scratched := false
					for s in strokes:
						if Geometry2D.get_closest_point_to_segment(flat, s[0], s[1]).distance_to(flat) < WORN_SCRATCH_WIDTH:
							scratched = true
							break
					var edge := false
					for crease in close:
						if Geometry3D.get_closest_point_to_segment(p, crease[0], crease[1]).distance_to(p) < WORN_EDGE:
							edge = true
							break
					out = Color(old.r * WORN_LIFT, old.g * WORN_LIFT, old.b * WORN_LIFT).lerp(steel, 0.85 if edge else (0.75 if scratched else 0.0))
				atlas.set_pixel(x, y, Color(minf(out.r, 1.0), minf(out.g, 1.0), minf(out.b, 1.0)))
				painted += 1
	print("  worn: %d triangles, %d texels" % [tris.size(), painted])


## The body's atlas squeezed into the top BODY of the square, the palette into the strip under it.
func _with_strip(atlas: Image, palette: Texture2D) -> Image:
	var body_h := int(ATLAS * BODY)
	var body := atlas.duplicate() as Image
	body.resize(ATLAS, body_h, Image.INTERPOLATE_LANCZOS)
	var strip := palette.get_image()
	if strip.is_compressed():
		strip.decompress()
	strip.convert(Image.FORMAT_RGB8)
	strip.resize(ATLAS, ATLAS - body_h, Image.INTERPOLATE_BILINEAR)
	var out := Image.create_empty(ATLAS, ATLAS, false, Image.FORMAT_RGB8)
	out.blit_rect(body, Rect2i(0, 0, ATLAS, body_h), Vector2i.ZERO)
	out.blit_rect(strip, Rect2i(0, 0, ATLAS, ATLAS - body_h), Vector2i(0, body_h))
	return out


## UVs moved into a band of the texture: from `top`, `share` of its height.
func _squeezed(uvs: PackedVector2Array, top: float, share: float) -> PackedVector2Array:
	var out := PackedVector2Array()
	out.resize(uvs.size())
	for i in uvs.size():
		out[i] = Vector2(uvs[i].x, top + fposmod(uvs[i].y, 1.0) * share)
	return out


# ---------- the KayKit figures ----------

func _bake(spec: Dictionary) -> BakedModel:
	var root: Node3D = (load(CHAR + spec.model) as PackedScene).instantiate()
	get_root().add_child(root)
	var skeleton := PoseBaker.find_skeleton(root)
	var player := PoseBaker.find_player(root)
	var remap: Dictionary = spec.get("remap", {})
	for mi: MeshInstance3D in root.find_children("*", "MeshInstance3D", true, false):
		if (spec.get("hide", []) as Array).has(String(mi.name)):
			mi.visible = false
		elif remap.has(String(mi.name)):
			mi.mesh = _moved(mi.mesh, remap[String(mi.name)])
	var extra: Array[Dictionary] = []
	for w: Array in spec.weapons:
		var scene: Node = (load(WEAPON + w[0]) as PackedScene).instantiate()
		var mi := _first_mesh(scene)
		var mesh: Mesh = _moved(mi.mesh, remap[w[0]]) if remap.has(w[0]) else mi.mesh
		var s: float = w[2] if w.size() > 2 else 1.0
		extra.append({"mesh": mesh, "bone": w[1], "transform": mi.transform.scaled_local(Vector3.ONE * s)})
		scene.free()
	var named := {}
	for p: Dictionary in spec.get("props", []):
		var pieces := _prop(p)
		if p.has("name"):
			named[pieces[0]] = p["name"]
		extra.append_array(pieces)
	var out := BakedModel.new()
	out.albedo = load(spec.texture) if spec.has("texture") else PoseBaker.find_albedo(root)
	if spec.get("embed", false):
		# kept inside the baked file, compressed for the video card (assets/models/palettes is not exported)
		var pal := out.albedo.get_image()
		if pal.is_compressed():
			pal.decompress()
		pal.convert(Image.FORMAT_RGB8)
		pal.generate_mipmaps()
		pal.compress(Image.COMPRESS_S3TC, Image.COMPRESS_SOURCE_SRGB)
		out.albedo = ImageTexture.create_from_image(pal)
	var bend: Dictionary = spec.get("bend", {})
	var shrink: float = spec.get("head_shrink", HEAD_SHRINK)
	var clips := {}
	for anim: String in spec.anims:
		var a: Array = spec.anims[anim]
		var clip := player.get_animation(a[0])
		if clip == null:
			push_error("bake: no clip %s in %s" % [a[0], spec.model])
			continue
		var frames: int = a[1]
		var loops: bool = a[2]
		var opts: Dictionary = a[3] if a.size() > 3 else {}
		var t0: float = opts.get("from", 0.0)
		var t1: float = opts.get("to", clip.length)
		var clip_bend := _bends(bend, opts.get("bend", {}))
		var poses: Array = []
		for i in frames:
			# loops sample [0, length); one-shots include the last pose
			var t := t0 + (t1 - t0) * i / (frames if loops else maxi(frames - 1, 1))
			player.play(a[0])
			player.seek(t, true)
			_pose(skeleton, clip_bend, shrink)
			poses.append(PoseBaker.pose_arrays(root, skeleton, extra))
		clips[anim] = poses
		out.fps[anim] = frames / (t1 - t0)
		out.loops[anim] = loops
	if spec.has("height"):
		# the poses scaled so the figure standing idle is "height" tall (the KayKit adventurers are 2.5 m slender)
		var top := -INF
		for v: Vector3 in (clips.idle[0] as Array)[Mesh.ARRAY_VERTEX]:
			top = maxf(top, v.y)
		# and set on the floor: the lowest vertex of the idle's first pose at 0 (Slender's stretch leaves the soles 8 cm
		# under it); every clip moves with it
		var low := INF
		for v: Vector3 in (clips.idle[0] as Array)[Mesh.ARRAY_VERTEX]:
			low = minf(low, v.y)
		var k := float(spec.height) / (top - low)
		for anim: String in clips:
			for arrays: Array in clips[anim]:
				var vs: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
				for i in vs.size():
					vs[i] = Vector3(vs[i].x, vs[i].y - low, vs[i].z) * k
				arrays[Mesh.ARRAY_VERTEX] = vs
	if not named.is_empty():
		# the props' vertices come last, in the order of `extra` (PoseBaker.pose_arrays)
		var at := ((clips.idle[0] as Array)[Mesh.ARRAY_VERTEX] as PackedVector3Array).size()
		for i in range(extra.size() - 1, -1, -1):
			var n := (((extra[i].mesh as Mesh).surface_get_arrays(0))[Mesh.ARRAY_VERTEX] as PackedVector3Array).size()
			at -= n
			if named.has(extra[i]):
				var mine := PackedInt32Array()
				for v in n:
					mine.append(at + v)
				out.parts[named[extra[i]]] = mine
	_pack(out, clips)
	out.height = out.mesh.get_aabb().end.y
	root.free()
	return out


## The animated pose made slender, then stooped where the entry bends it.
func _pose(skeleton: Skeleton3D, bend: Dictionary, shrink := HEAD_SHRINK) -> void:
	Slender.apply(skeleton)
	var head := skeleton.find_bone("head")
	skeleton.set_bone_pose_scale(head, skeleton.get_bone_pose_scale(head) * shrink)
	for bone: String in bend:
		var i := skeleton.find_bone(bone)
		var deg: Vector3 = bend[bone]
		var q := Quaternion.from_euler(Vector3(deg_to_rad(deg.x), deg_to_rad(deg.y), deg_to_rad(deg.z)))
		skeleton.set_bone_pose_rotation(i, skeleton.get_bone_pose_rotation(i) * q)


## One prop as pieces for PoseBaker.snapshot: {mesh, bone, transform}.
func _prop(p: Dictionary) -> Array[Dictionary]:
	var rot: Vector3 = p.get("rot", Vector3.ZERO)
	var s = p.get("scale", 1.0)
	var scale: Vector3 = s if s is Vector3 else Vector3.ONE * float(s)
	var xf := Transform3D(Basis.from_euler(Vector3(deg_to_rad(rot.x), deg_to_rad(rot.y), deg_to_rad(rot.z))).scaled(scale), p.get("at", Vector3.ZERO))
	var cell: int = p.cell
	if p.has("part"):
		var where: PackedStringArray = String(p.part).split(":")
		var scene: Node = (load(CHAR + where[0]) as PackedScene).instantiate()
		var mi := scene.find_child(where[1], true, false) as MeshInstance3D
		var shade := PoseBaker.find_albedo(mi).get_image()
		shade.decompress()
		var piece := {"mesh": _painted(mi.mesh.surface_get_arrays(0), cell, shade), "bone": p.bone, "transform": xf * mi.transform}
		scene.free()
		return [piece]
	var size: Vector3 = p.get("size", Vector3.ONE)
	var pieces: Array[Dictionary] = []
	match String(p.shape):
		"crown":
			# a gold band and size.z spikes standing on it
			var band := CylinderMesh.new()
			band.top_radius = size.x
			band.bottom_radius = size.x * 1.04
			band.height = size.y * 0.35
			band.radial_segments = 14
			band.rings = 1
			pieces.append({"mesh": _painted(band.get_mesh_arrays(), cell), "bone": p.bone, "transform": xf})
			for k in int(size.z):
				var spike := CylinderMesh.new()
				spike.top_radius = 0.0
				spike.bottom_radius = size.x * 0.2
				spike.height = size.y * (1.0 if k % 2 == 0 else 0.7)
				spike.radial_segments = 4
				spike.rings = 1
				var a := TAU * k / size.z
				var at := Vector3(sin(a) * size.x, size.y * 0.15 + spike.height * 0.5, cos(a) * size.x)
				pieces.append({"mesh": _painted(spike.get_mesh_arrays(), cell), "bone": p.bone, "transform": xf * Transform3D(Basis(), at)})
		_:
			var shape: PrimitiveMesh
			match String(p.shape):
				"box":
					var b := BoxMesh.new()
					b.size = size
					shape = b
				"sphere":
					var sp := SphereMesh.new()
					sp.radius = size.x
					sp.height = size.y * (1.0 if p.has("cut") else 2.0)
					sp.radial_segments = int(p.get("segments", 12))
					sp.rings = int(p.get("segments", 12)) / 2
					if p.has("cut"):
						# a dome: only the top share of the sphere
						sp.is_hemisphere = true
					shape = sp
				"cylinder":
					var c := CylinderMesh.new()
					c.top_radius = size.x
					c.height = size.y
					c.bottom_radius = size.z
					c.radial_segments = 12
					c.rings = 1
					shape = c
			pieces.append({"mesh": _painted(shape.get_mesh_arrays(), cell), "bone": p.bone, "transform": xf})
	return pieces


## A mesh with every UV moved into one cell of the palette: lighter at the top of the piece, or (shade: the piece's
## own texture) as light as its own colour there, so a part keeps its folds as the cell's gradient.
func _painted(arrays: Array, cell: int, shade: Image = null) -> ArrayMesh:
	var verts: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
	var old: PackedVector2Array = arrays[Mesh.ARRAY_TEX_UV]
	var lo := INF
	var hi := -INF
	for v in verts:
		lo = minf(lo, v.y)
		hi = maxf(hi, v.y)
	var uvs := PackedVector2Array()
	uvs.resize(verts.size())
	var u0 := (cell % COLS + 0.3) / COLS
	var v0 := float(cell / COLS) / ROWS
	for i in verts.size():
		var dark: float
		if shade != null and i < old.size():
			var px := Vector2i((old[i].posmod(1.0) * Vector2(shade.get_width(), shade.get_height())).floor())
			dark = 1.0 - shade.get_pixelv(px.clamp(Vector2i.ZERO, Vector2i(shade.get_width() - 1, shade.get_height() - 1))).get_luminance()
		else:
			dark = 1.0 - (verts[i].y - lo) / maxf(hi - lo, 0.0001)
		uvs[i] = Vector2(u0, v0 + (0.08 + 0.84 * clampf(dark, 0.0, 1.0)) / ROWS)
	var out := []
	out.resize(Mesh.ARRAY_MAX)
	out[Mesh.ARRAY_VERTEX] = verts
	out[Mesh.ARRAY_NORMAL] = arrays[Mesh.ARRAY_NORMAL]
	out[Mesh.ARRAY_TEX_UV] = uvs
	out[Mesh.ARRAY_INDEX] = arrays[Mesh.ARRAY_INDEX]
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, out)
	return mesh


## The same mesh (skin weights and all) with the UVs of some cells moved to others: {from: to}.
## A held weapon repainted (see SWATCHES): each face of a painted palette cell takes its swatch, projected along the
## weapon's longest side and across its second, so the grain runs down it.
func _repainted(mesh: Mesh, paint: Dictionary) -> ArrayMesh:
	var arrays := mesh.surface_get_arrays(0)
	var uvs: PackedVector2Array = arrays[Mesh.ARRAY_TEX_UV]
	var verts: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
	var box := mesh.get_aabb()
	var long := box.get_longest_axis_index()
	var size := box.size
	size[long] = -1.0
	var across := size.max_axis_index()
	for i in uvs.size():
		var cell := clampi(int(fposmod(uvs[i].x, 1.0) * COLS), 0, COLS - 1) + clampi(int(fposmod(uvs[i].y, 1.0) * ROWS), 0, ROWS - 1) * COLS
		if not paint.has(cell):
			push_error("bake: palette cell %d of a held weapon has no swatch" % cell)
			continue
		var to: int = SWATCHES[paint[cell]].cell
		var at := Vector2((verts[i][long] - box.position[long]) / box.size[long], (verts[i][across] - box.position[across]) / maxf(box.size[across], 0.001))
		at = Vector2.ONE * SWATCH_MARGIN + at * (1.0 - 2.0 * SWATCH_MARGIN)
		uvs[i] = Vector2((to % COLS + at.x) / COLS, (to / COLS + at.y) / ROWS)
	arrays[Mesh.ARRAY_TEX_UV] = uvs
	var out := ArrayMesh.new()
	out.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	return out


## Paints SWATCHES into their cells of the palette strip under the body's atlas (see _with_strip).
func _paint_swatches(atlas: Image) -> void:
	var top := int(ATLAS * BODY)
	var w := ATLAS / COLS
	var h := (ATLAS - top) / ROWS
	for id: String in SWATCHES:
		var sw: Dictionary = SWATCHES[id]
		var x0: int = (sw.cell % COLS) * w
		var y0: int = top + (sw.cell / COLS) * h
		var seed := float(sw.cell) * 17.0
		for y in h:
			for x in w:
				var at := Vector2(float(x) / w, float(y) / h)
				var lift := (_noise(at * GRAIN_LATTICE, seed) - 0.5) * 2.0 * float(sw.grain)
				lift += (_noise(at * STREAK_LATTICE, seed + 3.0) - 0.5) * 2.0 * float(sw.streak)
				lift -= smoothstep(0.45, 0.85, _noise(at * STAIN_LATTICE, seed + 7.0)) * float(sw.stain)
				var c: Color = sw.color * (1.0 + lift)
				# thin light lines along the weapon: a scratch on one row, broken along it
				if _hash(Vector2(0, y), seed + 11.0) < float(sw.scratch) and _noise(Vector2(at.x * 10.0, y), seed + 13.0) > 0.55:
					c *= float(sw.get("lift", SCRATCH_LIFT))
				c.a = 1.0
				atlas.set_pixel(x0 + x, y0 + y, c.clamp())


func _hash(p: Vector2, seed: float) -> float:
	return fposmod(sin(p.dot(Vector2(12.9898, 78.233)) + seed * 3.17) * 43758.5453, 1.0)


## Smooth value noise on a lattice.
func _noise(p: Vector2, seed: float) -> float:
	var i := p.floor()
	var f := p - i
	f = f * f * (Vector2(3, 3) - 2.0 * f)
	var a := _hash(i, seed)
	var b := _hash(i + Vector2(1, 0), seed)
	var c := _hash(i + Vector2(0, 1), seed)
	var d := _hash(i + Vector2(1, 1), seed)
	return lerpf(lerpf(a, b, f.x), lerpf(c, d, f.x), f.y)


func _moved(mesh: Mesh, cells: Dictionary) -> ArrayMesh:
	var arrays := mesh.surface_get_arrays(0)
	var uvs: PackedVector2Array = arrays[Mesh.ARRAY_TEX_UV]
	for i in uvs.size():
		var uv := uvs[i]
		var cell := clampi(int(fposmod(uv.x, 1.0) * COLS), 0, COLS - 1) + clampi(int(fposmod(uv.y, 1.0) * ROWS), 0, ROWS - 1) * COLS
		if cells.has(cell):
			var to: int = cells[cell]
			uvs[i] = uv + Vector2(float(to % COLS - cell % COLS) / COLS, float(to / COLS - cell / COLS) / ROWS)
	arrays[Mesh.ARRAY_TEX_UV] = uvs
	var out := ArrayMesh.new()
	out.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	return out


func _first_mesh(n: Node) -> MeshInstance3D:
	if n is MeshInstance3D:
		return n
	for c in n.get_children():
		var m := _first_mesh(c)
		if m:
			return m
	return null
