class_name EmethSword
extends RefCounted
## Emeth, the sword of truth (Daniel's concept art of 2026-11-14): a blade of green light, a golden crossguard with an
## emerald at its heart, a dark leather grip and a golden pommel. Provisional, built from simple shapes until the
## real model comes; the same size and grip as the KayKit sword it replaces (blade along +Y from the grip, which is
## at the origin; its tip near BLADE_TOP).

const BLADE_TOP := 1.42
## Emerald, not cyan (cycle 5, docs/art/cycle5_spec.md A2: 18d961 on the screen; the tone mapper turns a bright green
## toward cyan, so the colour is set a little yellower than that).
const GREEN := Color(0.08, 0.85, 0.27)
## How bright the blade's body is: under the WorldEnvironment glow threshold (Game.GLOW_THRESHOLD, after the
## exposure), so the blade keeps its shape.
const BLADE_GLOW := 1.1
## The light edge down the middle, CORE_WIDTH of the blade's width: the only part of the blade that blooms.
const CORE := Color(0.6, 1.0, 0.75)
const CORE_GLOW := 1.25
const CORE_WIDTH := 0.3
## Old gold (yellow on the screen is kept for the armor bar); the emerald of the guard stays lit.
const GOLD := Color(0.6, 0.47, 0.27)
const LEATHER := Color(0.16, 0.09, 0.06)


## The sword: an empty holder at the grip with every part under it (HeroBody places the holder in the hand).
static func make() -> MeshInstance3D:
	var root := MeshInstance3D.new()
	var blade := MeshInstance3D.new()
	root.add_child(blade)
	blade.mesh = _diamond(0.075, 0.062, 1.1)
	blade.position.y = 0.2 + 0.55
	blade.material_override = _light(GREEN * BLADE_GLOW)
	var tip := MeshInstance3D.new()
	tip.mesh = _diamond(0.062, 0.0, 0.2)
	tip.position.y = 0.55 + 0.1
	tip.material_override = blade.material_override
	blade.add_child(tip)
	# a pale edge down the middle of the blade: a flat strip standing a little out of both faces
	var core := MeshInstance3D.new()
	var strip := BoxMesh.new()
	strip.size = Vector3(0.15 * CORE_WIDTH, 1.05, 0.046)
	core.mesh = strip
	core.material_override = _light(CORE * CORE_GLOW)
	blade.add_child(core)
	var gold := _metal(GOLD)
	# the crossguard: a bar whose ends sweep up toward the blade, an emerald in the middle
	var bar := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(0.5, 0.06, 0.08)
	bar.mesh = box
	bar.material_override = gold
	bar.position.y = 0.16 - blade.position.y
	blade.add_child(bar)
	for s in [-1.0, 1.0]:
		var end := MeshInstance3D.new()
		var prism := PrismMesh.new()
		prism.size = Vector3(0.08, 0.16, 0.08)
		end.mesh = prism
		end.material_override = gold
		end.position = Vector3(s * 0.26, 0.2 - blade.position.y, 0)
		end.rotation.z = -s * 0.5
		blade.add_child(end)
	blade.add_child(_gem(Vector3(0, 0.17 - blade.position.y, 0.045), 0.05))
	blade.add_child(_gem(Vector3(0, 0.17 - blade.position.y, -0.045), 0.05))
	var grip := MeshInstance3D.new()
	var cyl := CylinderMesh.new()
	cyl.top_radius = 0.032
	cyl.bottom_radius = 0.036
	cyl.height = 0.4
	cyl.radial_segments = 8
	grip.mesh = cyl
	var leather := StandardMaterial3D.new()
	leather.albedo_color = LEATHER
	leather.roughness = 0.9
	grip.material_override = leather
	grip.position.y = -0.07 - blade.position.y
	blade.add_child(grip)
	var pommel := MeshInstance3D.new()
	var ball := SphereMesh.new()
	ball.radius = 0.055
	ball.height = 0.1
	pommel.mesh = ball
	pommel.material_override = gold
	pommel.position.y = -0.3 - blade.position.y
	blade.add_child(pommel)
	blade.add_child(_gem(Vector3(0, -0.36 - blade.position.y, 0), 0.03))
	return root


## A flat blade section: a four-sided prism (diamond across) from `bottom` wide to `top` wide, `length` long.
static func _diamond(bottom: float, top: float, length: float) -> Mesh:
	var c := CylinderMesh.new()
	c.bottom_radius = bottom
	c.top_radius = top
	c.height = length
	c.radial_segments = 4
	c.rings = 1
	var m := ArrayMesh.new()
	var arrays := c.get_mesh_arrays()
	# flatten it across (the blade's thin side) and turn the diamond's points to the edges
	var verts: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
	for i in verts.size():
		var v := verts[i]
		var a := Vector2(v.x, v.z).rotated(PI * 0.25)
		verts[i] = Vector3(a.x, v.y, a.y * 0.28)
	arrays[Mesh.ARRAY_VERTEX] = verts
	arrays[Mesh.ARRAY_NORMAL] = null
	arrays[Mesh.ARRAY_TANGENT] = null
	m.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	return m


static func _gem(at: Vector3, size: float) -> MeshInstance3D:
	var g := MeshInstance3D.new()
	var s := SphereMesh.new()
	s.radius = size
	s.height = size * 2.6
	s.radial_segments = 6
	s.rings = 3
	g.mesh = s
	g.material_override = _light(Color(0.25, 1.8, 0.7))
	g.position = at
	return g


static func _light(c: Color) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.albedo_color = c
	return m


static func _metal(c: Color) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = c
	m.metallic = 0.9
	m.roughness = 0.35
	return m
