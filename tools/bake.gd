extends SceneTree
## Bakes the crowd's characters into still poses: ~/tools/godot/godot --headless --path . -s tools/bake.gd [-- ids]
## Writes assets/baked/<id>.res (BakedModel). Run again after changing a model, a weapon, a palette or the list below.
##
## The enemies of the first region follow Daniel's sheet (docs/art/ref/inimigos_fase1.png, docs/art/enemies_phase1.md)
## with the KayKit skeletons: each one its own palette (tools/make_palettes.gd), parts hidden or moved to other cells
## of it, and props hung on the bones before the poses are baked (they cost nothing more per enemy on screen).
##
## Per entry: "model" (assets/models/characters), "texture" (the palette), "weapons" ([file, bone, scale]),
## "hide" (mesh parts left out), "remap" (part or weapon name -> {from cell: to cell}), "props", "bend"
## (bone -> degrees added to its posed rotation, a stoop), "anims" (name in the game -> [glTF clip, frames, loops]).
## A prop hangs on "bone" at "at" (meters, the bone's own space at rest, which on the KayKit rig is the model's
## axes, +Z the front), turned by "rot" (degrees) and scaled by "scale"; it is a "part" of another KayKit model
## ("Knight.glb:Knight_Cape", which keeps its own place on its bone) or a "shape" (box, sphere, cylinder, crown) of
## "size", painted with the palette's "cell" (a part keeps its shading as the cell's gradient).

const CHAR := "res://assets/models/characters/"
const WEAPON := "res://assets/models/weapons/"
const PALETTE := "res://assets/models/palettes/"
const COLS := 8
const ROWS := 4
## The sheet's skeletons are adult figures: the skull a little smaller again than Slender leaves it (on top of
## Slender.HEAD; the props on the head shrink with it).
const HEAD_SHRINK := 0.72

## Cells of the palettes (tools/make_palettes.gd).
const C_BLACK := 2
const C_ARMOR := 3
const C_DARK_METAL := 4
const C_BONE := 9
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

const MODELS := {
	# not an enemy: the hooded figure of the catacomb statues, one still pose (drawn in stone by ArenaKit.statue)
	"statue": {
		"model": "Rogue_Hooded.glb",
		"weapons": [],
		"anims": {"idle": ["Unarmed_Idle", 1, true]},
	},
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
