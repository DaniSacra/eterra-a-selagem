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
## (seconds it plays in, in the game), "lift" (the share of the hips' rise and fall that is kept) and "guard"
## ([rig, clip, bones], or a list of those: the bones, parents first, point where another clip has them, e.g. the
## sword arm kept in guard while the legs run).
## A held piece: "hand" (Right or Left), then "file" (assets/models/weapons) or "shape" (see _prop), "scale",
## "at" (meters) and "rot" (degrees) in the hand's grip (+Y along the fist toward the pinky, which is where the
## libraries' sword clips carry the blade; +Z out of the knuckles, along the forearm) and "remap" (palette cells
## moved). A staff or a crossbow, held thumb up by the other clips, is turned over: rot (0, 0, 180).
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
## The crossbow kept level.
const CROSSBOW_GUARD := {"guard": [&"ual", "Pistol_Idle", RIGHT_ARM]}
## The shield arm up and the sword arm in guard (the shield clip lets it hang: the blade would drag in the floor).
const SHIELD_GUARD := {"guard": [[&"ual2", "Idle_Shield", LEFT_ARM], [&"ual", "Sword_Idle", RIGHT_ARM]]}
const SHIELD_IDLE := [&"ual2", "Idle_Shield", 4, true, SWORD_GUARD]

## What every figure does the same way. The rise plays in the 0.9 s the horde gives it (Horde, State.RISE).
const COMMON_ANIMS := {
	"hit": [&"ual", "Hit_Chest", 4, false],
	"death": [&"ual", "Death01", 8, false, {"to": 1.9}],
	"rise": [&"ual2", "LayToIdle", 8, false, {"time": 0.9}],
}
## Horde.IMPACT_SHARE of the swing is the windup: the clips are cut so the blade comes down there.
const SWORD_BLOW := [&"ual", "Sword_Attack", 8, false, {"from": 0.1, "to": 1.2}]
const CASTER_CLIPS := {
	"attack": [&"ual", "Spell_Simple_Shoot", 6, false],
	"cast": [&"ual", "Spell_Simple_Idle", 6, true],
}
## The same with a staff: the library casts with the left hand, which is the one that holds it.
const STAFF_CLIPS := {
	"idle": [&"ual", "Idle_Torch", 4, true],
	"attack": [&"ual", "Spell_Simple_Shoot", 6, false],
	"cast": [&"ual", "Spell_Simple_Idle", 6, true],
}

const MODELS := {
	# not an enemy: the hooded figure of the catacomb statues, one still pose (drawn in stone by ArenaKit.statue)
	"statue": {
		"model": "Rogue_Hooded.glb",
		"weapons": [],
		"anims": {"idle": ["Unarmed_Idle", 1, true]},
	},
	# 1. the soldier: bare bone, steel pauldrons and greaves, a torn red loincloth; the blade is the KayKit one
	"skeleton": {
		"meshy": "skeleton", "height": 1.92, "triangles": BODY_TRIANGLES,
		"palette": PALETTE + "skeleton.png",
		"held": [{"hand": "Right", "file": "Skeleton_Blade.gltf", "scale": 0.8, "rot": EDGE_OUT}],
		"anims": {
			"walk": [&"ual", "Jog_Fwd", 10, true, SWORD_GUARD], "idle": [&"ual", "Idle", 4, true, SWORD_GUARD],
			"attack": SWORD_BLOW,
		},
	},
	# 2. the runner: burnt bone and red rags, no weapon, stooped, an ember in the chest
	"runner": {
		"meshy": "runner", "height": 1.65, "triangles": BODY_TRIANGLES,
		"bend": {"Spine02": Vector3(14, 0, 0), "Head": Vector3(25, 0, 0)},
		"anims": {
			"walk": [&"ual", "Sprint", 8, true], "idle": [&"ual2", "Zombie_Idle", 4, true],
			"attack": [&"ual", "Punch_Cross", 6, false], "windup": [&"ual", "Crouch_Idle", 3, true],
		},
	},
	# 3. the sorcerer: dark hood and robe over the ribs, steel arms; the staff with the cold violet gem is KayKit's
	"mage": {
		"meshy": "mage", "height": 1.92, "triangles": BODY_TRIANGLES,
		"palette": PALETTE + "mage.png",
		"held": [{"hand": "Left", "file": "Skeleton_Staff.gltf", "scale": 0.75, "rot": THUMB_UP, "remap": {17: C_GLOW_COLD, C_BONE: C_WOOD}}],
		"anims": {
			"walk": [&"ual", "Jog_Fwd", 10, true, STAFF_GUARD], "idle": STAFF_CLIPS.idle,
			"attack": STAFF_CLIPS.attack, "cast": STAFF_CLIPS.cast,
		},
	},
	# 4. the crossbowman: dark hood, red scarf; the crossbow is KayKit's
	"archer": {
		"meshy": "archer", "height": 1.92, "triangles": BODY_TRIANGLES,
		"palette": PALETTE + "archer.png",
		"held": [{"hand": "Right", "file": "Skeleton_Crossbow.gltf", "scale": 0.6, "rot": THUMB_UP}],
		"anims": {
			"walk": [&"ual", "Jog_Fwd", 8, true, CROSSBOW_GUARD], "idle": [&"ual", "Pistol_Idle", 4, true],
			"attack": [&"ual", "Pistol_Shoot", 6, false], "aim": [&"ual", "Pistol_Idle", 3, true],
		},
	},
	# 5. the brute: dark plate, the tower shield with its emblem and the sword are the model's own
	"guard": {
		"meshy": "guard", "height": 2.03, "triangles": BODY_TRIANGLES,
		"anims": {
			"walk": [&"ual", "Walk", 10, true, SHIELD_GUARD], "idle": SHIELD_IDLE,
			"attack": SWORD_BLOW,
		},
	},
	# 6. the priest of the dead: dark purple hood and robes, no weapon
	"priest": {
		"meshy": "priest", "height": 1.93, "triangles": BODY_TRIANGLES,
		"anims": {
			"walk": [&"ual", "Walk", 10, true], "idle": [&"ual", "Idle", 4, true],
			"attack": CASTER_CLIPS.attack, "cast": CASTER_CLIPS.cast,
		},
	},
	# 7. the guardian knight: crowned helmet, heavy plate, red cape; blade and shield are KayKit's
	"knight": {
		"meshy": "knight", "height": 2.03, "triangles": BODY_TRIANGLES,
		"palette": PALETTE + "knight.png",
		"held": [
			{"hand": "Right", "file": "Skeleton_Blade.gltf", "scale": 0.95, "rot": EDGE_OUT, "remap": {C_BLADE: C_ARMOR, C_WRAP: C_RED}},
			{"hand": "Left", "file": "Skeleton_Shield_Large_A.gltf", "scale": 0.75, "rot": Vector3(0, -90, 0)},
		],
		"anims": {
			"walk": [&"ual", "Walk", 10, true, SHIELD_GUARD], "idle": SHIELD_IDLE,
			"attack": SWORD_BLOW,
		},
	},
	# 8. the elder priest: crown over the hood, purple and gold robes; the staff with the purple orb is KayKit's
	"priest_elder": {
		"meshy": "priest_elder", "height": 2.07, "triangles": BODY_TRIANGLES,
		"palette": PALETTE + "priest_elder.png",
		"held": [
			{"hand": "Left", "file": "Skeleton_Staff.gltf", "scale": 0.9, "rot": THUMB_UP, "remap": {17: C_GLOW_PURPLE, C_BONE: C_WOOD}},
			# the purple orb held in the top of the staff (the sheet's block 8)
			{"hand": "Left", "shape": "sphere", "at": Vector3(0, -1.38 * 0.9, 0), "size": Vector3(0.12, 0.12, 0), "cell": C_GLOW_PURPLE},
		],
		"anims": {
			"walk": [&"ual", "Walk", 10, true, STAFF_GUARD], "idle": STAFF_CLIPS.idle,
			"attack": STAFF_CLIPS.attack, "cast": STAFF_CLIPS.cast,
		},
	},
	# 9. Morvath, the king who betrayed the light: crown, long white hair, purple and gold robes, the purple gem on
	# the chest are the model's own; the blade is KayKit's
	"morvath": {
		"meshy": "morvath", "height": 2.02, "triangles": BODY_TRIANGLES,
		"palette": PALETTE + "morvath.png",
		"held": [{"hand": "Right", "file": "Skeleton_Blade.gltf", "scale": 0.8, "rot": EDGE_OUT, "remap": {C_BLADE: C_ARMOR, C_WRAP: C_PURPLE}}],
		"anims": {
			"walk": [&"ual", "Walk", 10, true, SWORD_GUARD], "idle": [&"ual", "Idle", 4, true, SWORD_GUARD],
			"attack": SWORD_BLOW,
			"slash1": [&"ual2", "Sword_Regular_A", 8, false], "slash2": [&"ual2", "Sword_Regular_B", 8, false],
			"slash3": [&"ual", "Sword_Attack", 10, false, {"from": 0.1, "to": 1.2}],
			"dash_windup": [&"kaykit", "2H_Melee_Idle", 4, true, {"lift": 0.2}],
			"dash": [&"ual2", "Sword_Dash_RM", 8, false, {"from": 0.12, "to": 0.72}],
			# the KayKit figure is half his height and hops as it conjures: on him the hop would be a flight
			"summon": [&"kaykit", "Spellcast_Summon", 12, false, {"lift": 0.2}], "rain": [&"kaykit", "Spellcast_Raise", 8, false, {"lift": 0.2}],
			"volley": [&"ual", "Spell_Simple_Shoot", 6, false], "roar": [&"kaykit", "Taunt", 8, false, {"lift": 0.2}],
			"stunned": [&"ual", "Crouch_Idle", 6, true],
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


var _done := false
## rig -> [model, AnimationPlayer, Skeleton3D], loaded when a figure first asks for it.
var _rigs := {}


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
	for id: String in models:
		if not only.is_empty() and not only.has(id):
			continue
		var t0 := Time.get_ticks_msec()
		var spec: Dictionary = models[id]
		var baked := _bake_meshy(spec) if spec.has("meshy") else _bake(spec)
		ResourceSaver.save(baked, "res://assets/baked/%s.res" % id, ResourceSaver.FLAG_COMPRESS)
		var idle: Mesh = baked.anims.idle[0]
		print("baked %s: %d anims, %d triangles, %.2f m, in %d ms" % [id, baked.anims.size(),
			(idle.surface_get_arrays(0)[Mesh.ARRAY_INDEX] as PackedInt32Array).size() / 3, baked.height, Time.get_ticks_msec() - t0])
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
	var held: Array = spec.get("held", [])
	if not held.is_empty():
		atlas = _with_strip(atlas, load(spec.palette))
		arrays[Mesh.ARRAY_TEX_UV] = _squeezed(arrays[Mesh.ARRAY_TEX_UV], 0.0, BODY)
	var light := ArrayMesh.new()
	light.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	mi.mesh = light
	var anims: Dictionary = COMMON_ANIMS.merged(spec.anims, true)
	var bend: Dictionary = spec.get("bend", {})
	# the model at the height the game draws it at size 1: measured standing idle (the models rest in poses of their
	# own, the brute with its legs apart), then scaled; Retarget measures the scaled model
	var retargets := {}
	_pose_meshy(skeleton, model, retargets, anims.idle, 0.0, bend)
	var armature := skeleton.get_parent() as Node3D
	armature.scale *= float(spec.height) / PoseBaker.snapshot(model, skeleton).get_aabb().end.y
	retargets.clear()
	var extra: Array[Dictionary] = []
	for h: Dictionary in held:
		extra.append_array(_held(h, _retarget(&"ual", retargets, skeleton, model), model))
	var out := BakedModel.new()
	out.painted = true
	# the glowing cells of the palette strip (the staffs' gems); none without a strip
	out.glow_from = Vector2(0.5, BODY + 0.75 * (1.0 - BODY)) if not held.is_empty() else Vector2(2, 2)
	# kept inside the baked file, compressed for the video card (where it is not supported the engine unpacks it)
	atlas.generate_mipmaps()
	atlas.compress(Image.COMPRESS_S3TC, Image.COMPRESS_SOURCE_SRGB)
	out.albedo = ImageTexture.create_from_image(atlas)
	for anim: String in anims:
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
		var meshes: Array = []
		var low := INF
		for i in frames:
			# loops sample [from, to); one-shots include the last pose
			var t := from + (to - from) * i / (frames if loops else maxi(frames - 1, 1))
			_pose_meshy(skeleton, model, retargets, a, t, bend)
			var mesh := PoseBaker.snapshot(model, skeleton, extra)
			low = minf(low, mesh.get_aabb().position.y)
			meshes.append(mesh)
		out.anims[anim] = meshes
		out.fps[anim] = frames / float(opts.get("time", to - from))
		out.loops[anim] = loops
		print("  %s: %s %s, %.2f s, lowest point %.2f m" % [anim, a[0], a[1], frames / float(out.fps[anim]), low])
	# the top of the head, not of what it holds (a staff stands taller than its bearer)
	out.height = spec.height
	model.free()
	return out


## The figure's skeleton in the pose of a clip at t seconds (see MODELS for the clip's fields).
func _pose_meshy(skeleton: Skeleton3D, model: Node3D, retargets: Dictionary, a: Array, t: float, bend: Dictionary) -> void:
	var opts: Dictionary = a[4] if a.size() > 4 else {}
	var guards: Array = opts.get("guard", [])
	if not guards.is_empty() and not guards[0] is Array:
		guards = [guards]
	var held: Array[Dictionary] = []
	for g: Array in guards:
		held.append(_solve(g[0], g[1], t, true, retargets, skeleton, model))
	var pose := _solve(a[0], a[1], t, false, retargets, skeleton, model)
	var rt: Retarget = retargets[a[0]]
	for i in guards.size():
		# the guarded bones (parents first) point where the guard clip has them, whatever the trunk does in this one
		for bone: StringName in guards[i][2]:
			var b := skeleton.find_bone(bone)
			pose[b] = (rt.turn(skeleton.get_bone_parent(b), pose).inverse() * rt.turn(b, held[i])).get_rotation_quaternion()
	for b: int in pose:
		skeleton.set_bone_pose_rotation(b, pose[b])
	# clips that walk across the floor (_RM) stay in place: the game moves the figure
	var hips := rt.hips_position(String(a[1]).ends_with("_RM"))
	var rest := skeleton.get_bone_rest(rt.hips_bone()).origin
	hips.y = rest.y + (hips.y - rest.y) * float(opts.get("lift", 1.0))
	skeleton.set_bone_pose_position(rt.hips_bone(), hips)
	for bone: String in bend:
		var i := skeleton.find_bone(bone)
		var deg: Vector3 = bend[bone]
		var q := Quaternion.from_euler(Vector3(deg_to_rad(deg.x), deg_to_rad(deg.y), deg_to_rad(deg.z)))
		skeleton.set_bone_pose_rotation(i, skeleton.get_bone_pose_rotation(i) * q)
	# on the floor: Retarget sets the hips by their height at rest, and a model that rests with its legs apart (the
	# brute) has longer legs than that, so standing straight would sink its feet. The lowest bone goes back to where
	# it rests (feet and toes) or to a body's thickness over the floor (lying down).
	var low := INF
	for b in skeleton.get_bone_count():
		var foot := String(skeleton.get_bone_name(b)).contains("Foot") or String(skeleton.get_bone_name(b)).contains("Toe")
		low = minf(low, skeleton.get_bone_global_pose(b).origin.y - (skeleton.get_bone_global_rest(b).origin.y if foot else BODY_THICKNESS))
	skeleton.set_bone_pose_position(rt.hips_bone(), hips - Vector3(0, low, 0))


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
		var mesh: Mesh = _moved(mi.mesh, h.remap) if h.has("remap") else mi.mesh
		pieces.append({"mesh": mesh, "bone": bone, "transform": hand * own * mi.transform})
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
	for p: Dictionary in spec.get("props", []):
		extra.append_array(_prop(p))
	var out := BakedModel.new()
	out.albedo = load(spec.texture) if spec.has("texture") else PoseBaker.find_albedo(root)
	var bend: Dictionary = spec.get("bend", {})
	for anim: String in spec.anims:
		var a: Array = spec.anims[anim]
		var clip := player.get_animation(a[0])
		if clip == null:
			push_error("bake: no clip %s in %s" % [a[0], spec.model])
			continue
		var frames: int = a[1]
		var loops: bool = a[2]
		var meshes: Array = []
		for i in frames:
			# loops sample [0, length); one-shots include the last pose
			var t := clip.length * i / (frames if loops else maxi(frames - 1, 1))
			player.play(a[0])
			player.seek(t, true)
			_pose(skeleton, bend)
			meshes.append(PoseBaker.snapshot(root, skeleton, extra))
		out.anims[anim] = meshes
		out.fps[anim] = frames / clip.length
		out.loops[anim] = loops
	player.play(spec.anims.idle[0])
	player.seek(0.0, true)
	_pose(skeleton, bend)
	out.height = (out.anims.idle[0] as Mesh).get_aabb().end.y
	root.free()
	return out


## The animated pose made slender, then stooped where the entry bends it.
func _pose(skeleton: Skeleton3D, bend: Dictionary) -> void:
	Slender.apply(skeleton)
	var head := skeleton.find_bone("head")
	skeleton.set_bone_pose_scale(head, skeleton.get_bone_pose_scale(head) * HEAD_SHRINK)
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
					sp.radial_segments = 12
					sp.rings = 6
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
