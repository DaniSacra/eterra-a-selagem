extends SceneTree
## Bakes the crowd's characters into still poses: ~/tools/godot/godot --headless --path . -s tools/bake.gd
## Writes assets/baked/<id>.res (BakedModel). Run again after changing a model, a weapon or the list below.

const CHAR := "res://assets/models/characters/"
const WEAPON := "res://assets/models/weapons/"

## id -> model, weapons per bone, and the animations: name in the game -> [glTF animation, frames, loops].
const MODELS := {
	"minion": {
		"model": "Skeleton_Minion.glb",
		"weapons": [["Skeleton_Blade.gltf", "handslot.r"]],
		"anims": {"walk": ["Walking_D_Skeletons", 10, true], "attack": ["1H_Melee_Attack_Chop", 7, false], "hit": ["Hit_A", 4, false],
			"rise": ["Spawn_Ground_Skeletons", 8, false], "death": ["Death_C_Skeletons", 8, false], "idle": ["Idle_Combat", 4, true]},
	},
	"rogue": {
		"model": "Skeleton_Rogue.glb",
		"weapons": [["Skeleton_Crossbow.gltf", "handslot.r"]],
		"anims": {"walk": ["Running_A", 8, true], "attack": ["1H_Ranged_Shoot", 6, false], "aim": ["1H_Ranged_Aiming", 3, true], "hit": ["Hit_A", 4, false],
			"rise": ["Spawn_Ground_Skeletons", 8, false], "death": ["Death_C_Skeletons", 8, false], "idle": ["Idle_Combat", 4, true]},
	},
	"runner": {
		"model": "Skeleton_Rogue.glb",
		"weapons": [["Skeleton_Blade.gltf", "handslot.r"], ["Skeleton_Blade.gltf", "handslot.l"]],
		"anims": {"walk": ["Running_C", 8, true], "attack": ["Dualwield_Melee_Attack_Stab", 6, false], "windup": ["Idle_Combat", 3, true], "hit": ["Hit_A", 4, false],
			"rise": ["Spawn_Ground_Skeletons", 8, false], "death": ["Death_C_Skeletons", 8, false], "idle": ["Idle_Combat", 4, true]},
	},
	"warrior": {
		"model": "Skeleton_Warrior.glb",
		"weapons": [["Skeleton_Axe.gltf", "handslot.r"], ["Skeleton_Shield_Large_A.gltf", "handslot.l"]],
		"anims": {"walk": ["Walking_A", 10, true], "attack": ["1H_Melee_Attack_Slice_Diagonal", 7, false], "hit": ["Block_Hit", 4, false],
			"rise": ["Spawn_Ground_Skeletons", 8, false], "death": ["Death_C_Skeletons", 8, false], "idle": ["Idle_Combat", 4, true]},
	},
	"mage": {
		"model": "Skeleton_Mage.glb",
		"weapons": [["Skeleton_Staff.gltf", "handslot.r"]],
		"anims": {"walk": ["Walking_C", 10, true], "attack": ["Spellcast_Shoot", 7, false], "cast": ["Spellcasting", 6, true], "hit": ["Hit_A", 4, false],
			"rise": ["Spawn_Ground_Skeletons", 8, false], "death": ["Death_C_Skeletons", 8, false], "idle": ["Idle_Combat", 4, true]},
	},
	"morvath": {
		"model": "Skeleton_Warrior.glb",
		"weapons": [["Skeleton_Blade.gltf", "handslot.r"]],
		"anims": {"walk": ["Walking_A", 10, true], "slash1": ["1H_Melee_Attack_Slice_Horizontal", 8, false], "slash2": ["1H_Melee_Attack_Slice_Diagonal", 8, false],
			"slash3": ["2H_Melee_Attack_Chop", 10, false], "dash_windup": ["2H_Melee_Idle", 4, true], "dash": ["Running_B", 8, true],
			"summon": ["Spellcast_Summon", 12, false], "rain": ["Spellcast_Raise", 8, false], "volley": ["Spellcast_Shoot", 6, false],
			"roar": ["Taunt", 8, false], "stunned": ["Hit_B", 6, false], "hit": ["Hit_A", 4, false], "rise": ["Spawn_Ground_Skeletons", 8, false],
			"death": ["Death_A", 8, false], "idle": ["Idle_Combat", 4, true], "attack": ["1H_Melee_Attack_Chop", 7, false]},
	},
}


var _done := false


func _process(_delta: float) -> bool:
	if _done:
		return true
	_done = true
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://assets/baked"))
	var only := OS.get_cmdline_user_args()
	for id: String in MODELS:
		if not only.is_empty() and not only.has(id):
			continue
		var t0 := Time.get_ticks_msec()
		var baked := _bake(MODELS[id])
		ResourceSaver.save(baked, "res://assets/baked/%s.res" % id, ResourceSaver.FLAG_COMPRESS)
		print("baked %s: %d anims in %d ms" % [id, baked.anims.size(), Time.get_ticks_msec() - t0])
	quit()
	return true


func _bake(spec: Dictionary) -> BakedModel:
	var root: Node3D = (load(CHAR + spec.model) as PackedScene).instantiate()
	get_root().add_child(root)
	var skeleton := PoseBaker.find_skeleton(root)
	var player := PoseBaker.find_player(root)
	var extra: Array[Dictionary] = []
	for w: Array in spec.weapons:
		var scene: Node = (load(WEAPON + w[0]) as PackedScene).instantiate()
		var mi := _first_mesh(scene)
		extra.append({"mesh": mi.mesh, "bone": w[1], "transform": mi.transform})
		scene.free()
	var out := BakedModel.new()
	out.albedo = PoseBaker.find_albedo(root)
	for anim: String in spec.anims:
		var a: Array = spec.anims[anim]
		var clip := player.get_animation(a[0])
		var frames: int = a[1]
		var loops: bool = a[2]
		var meshes: Array = []
		for i in frames:
			# loops sample [0, length); one-shots include the last pose
			var t := clip.length * i / (frames if loops else maxi(frames - 1, 1))
			player.play(a[0])
			player.seek(t, true)
			meshes.append(PoseBaker.snapshot(root, skeleton, extra))
		out.anims[anim] = meshes
		out.fps[anim] = frames / clip.length
		out.loops[anim] = loops
	player.play(spec.anims.idle[0])
	player.seek(0.0, true)
	out.height = (out.anims.idle[0] as Mesh).get_aabb().end.y
	root.free()
	return out


func _first_mesh(n: Node) -> MeshInstance3D:
	if n is MeshInstance3D:
		return n
	for c in n.get_children():
		var m := _first_mesh(c)
		if m:
			return m
	return null
