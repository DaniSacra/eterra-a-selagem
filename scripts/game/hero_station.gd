class_name HeroStation
extends Node3D
## The heroes' station in the Santuário (PT-9 planted it, V3 dressed it), beside the Vendedor: over a low plinth (stone,
## drawn by HubLook) two cloth standards hung from dark iron crossbars, one for each hero of SaveData.HEROES, and at each
## one's foot a rest for the weapon (sword, staff). The Warrior's standard is the hero's red with the lion in gold; the
## Maga's is amber with a plain eight-pointed star. While the Maga is locked her standard hangs rolled up and grey under
## its bar and the star is hidden; it unrolls when she opens. Simple pieces (boxes, cylinders, flattened spheres).
##   var s := HeroStation.make(frame, HubLook.at(u, 0.0, v))
##   s.refresh(Save.data)     # the picked hero's standard a little taller, the locked one rolled up and grey

const BAR_Y := 2.55
const POST := Vector2(0.06, 2.3)
const CLOTH := Vector3(0.78, 1.3, 0.04)
const HANG := 0.06
const SPACING := 1.5
const PICKED := 1.0
const OTHER := 0.85
const ROLLED := 0.16
const COLORS := {"warrior": Color(0.55, 0.09, 0.08), "maga": Color(0.78, 0.5, 0.12)}
const LOCKED := Color(0.22, 0.2, 0.19)
const IRON := Color(0.1, 0.1, 0.11)
const GOLD := Color(0.92, 0.7, 0.2)
const AMBER_STAR := Color(1.0, 0.86, 0.45)
const STEEL := Color(0.62, 0.65, 0.7)
const WOOD := Color(0.3, 0.2, 0.12)
const PLINTH_TOP := 0.3
const STAR_POINTS := 4
const REST_Z := 0.6

var cloths: Dictionary = {}
var rolls: Dictionary = {}
var emblems: Dictionary = {}


static func make(parent: Node3D, at: Vector3) -> HeroStation:
	var s := HeroStation.new()
	s.name = "HeroStation"
	s.position = at
	parent.add_child(s)
	s._build()
	return s


func _build() -> void:
	var heroes := SaveData.HEROES
	for i in heroes.size():
		var id: String = heroes[i]
		var x := (i - (heroes.size() - 1) * 0.5) * SPACING
		var half := CLOTH.x * 0.5 + 0.08
		for side in [-1.0, 1.0]:
			_box(Vector3(x + side * half, PLINTH_TOP + POST.y * 0.5, 0), Vector3(POST.x, POST.y, POST.x), IRON).name = "post_%s" % id
		_box(Vector3(x, BAR_Y, 0), Vector3(half * 2.0 + 0.1, 0.06, 0.07), IRON).name = "bar_%s" % id
		for side in [-1.0, 1.0]:
			_ball(Vector3(x + side * (half + 0.07), BAR_Y, 0), Vector3(0.06, 0.06, 0.06), IRON)
		var cloth := _box(Vector3(x, BAR_Y, 0), CLOTH, COLORS[id])
		cloth.name = "cloth_%s" % id
		cloths[id] = cloth
		var roll := _cyl(Vector3(x, BAR_Y - 0.08, 0.04), 0.07, CLOTH.x * 0.9, LOCKED)
		roll.rotation.z = PI * 0.5
		roll.name = "roll_%s" % id
		rolls[id] = roll
		var emblem := Node3D.new()
		emblem.name = "emblem_%s" % id
		emblem.position = Vector3(x, BAR_Y - 0.7, CLOTH.z * 0.5 + 0.015)
		add_child(emblem)
		if id == "warrior":
			_lion(emblem)
		else:
			_star(emblem)
		emblems[id] = emblem
		_weapon_rest(id, x)
	refresh({})


## The picked hero's standard shows whole and a little taller; the locked one is rolled up and grey (a save:
## SaveData.hero_open, picked_hero).
func refresh(data: Dictionary) -> void:
	var picked := SaveData.picked_hero(data)
	for id: String in cloths:
		var open := SaveData.hero_open(data, id)
		var mi := cloths[id] as MeshInstance3D
		(mi.material_override as StandardMaterial3D).albedo_color = COLORS[id] if open else LOCKED
		var s := (PICKED if id == picked else OTHER) if open else ROLLED
		mi.scale = Vector3(1.0, s, 1.0)
		mi.position.y = BAR_Y - HANG - CLOTH.y * 0.5 * s
		(rolls[id] as Node3D).visible = not open
		var emblem := emblems[id] as Node3D
		emblem.visible = open
		emblem.position.y = BAR_Y - HANG - CLOTH.y * 0.5 * s
		emblem.scale = Vector3.ONE * s


## The lion's face: gold mane ring, face, ears and snout, looking at the camera.
func _lion(parent: Node3D) -> void:
	var mane := TorusMesh.new()
	mane.inner_radius = 0.1
	mane.outer_radius = 0.24
	mane.rings = 12
	mane.ring_segments = 6
	var mi := _part(parent, mane, Vector3.ZERO, GOLD)
	mi.rotation.x = PI * 0.5
	mi.scale = Vector3(1, 1, 0.35)
	_part_ball(parent, Vector3(0, -0.02, 0.02), Vector3(0.14, 0.15, 0.06), GOLD)
	for side in [-1.0, 1.0]:
		_part_ball(parent, Vector3(side * 0.1, 0.12, 0.03), Vector3(0.05, 0.05, 0.03), GOLD)
	var snout := BoxMesh.new()
	snout.size = Vector3(0.07, 0.07, 0.04)
	_part(parent, snout, Vector3(0, -0.08, 0.08), GOLD * 0.8)


## A plain star of eight points: four bars crossed at 45 degrees and a hub.
func _star(parent: Node3D) -> void:
	for k in STAR_POINTS:
		var bar := BoxMesh.new()
		bar.size = Vector3(0.5, 0.07, 0.025)
		var mi := _part(parent, bar, Vector3.ZERO, AMBER_STAR)
		mi.rotation.z = PI * k / STAR_POINTS
	_part_ball(parent, Vector3(0, 0, 0.01), Vector3(0.11, 0.11, 0.03), AMBER_STAR)


## A rest for the hero's weapon at the foot of its standard: a sword upright in a forked iron rest, a staff leaning in one.
func _weapon_rest(id: String, x: float) -> void:
	var base := Vector3(x, PLINTH_TOP, REST_Z)
	_box(base + Vector3(0, 0.03, 0), Vector3(0.5, 0.06, 0.26), IRON).name = "rest_%s" % id
	for side in [-1.0, 1.0]:
		_box(base + Vector3(side * 0.2, 0.3, 0), Vector3(0.05, 0.5, 0.05), IRON)
	_box(base + Vector3(0, 0.5, 0), Vector3(0.45, 0.04, 0.05), IRON)
	var weapon := Node3D.new()
	weapon.name = "weapon_%s" % id
	weapon.position = base + Vector3(0, 0.06, 0)
	weapon.rotation.z = -0.1 if id == "warrior" else 0.1
	add_child(weapon)
	if id == "warrior":
		_part(weapon, _box_mesh(Vector3(0.07, 0.9, 0.015)), Vector3(0, 0.5, 0), STEEL)
		_part(weapon, _box_mesh(Vector3(0.3, 0.05, 0.05)), Vector3(0, 0.07, 0), IRON)
		_part(weapon, _box_mesh(Vector3(0.04, 0.16, 0.04)), Vector3(0, -0.02, 0), WOOD)
		_part_ball(weapon, Vector3(0, -0.12, 0), Vector3(0.045, 0.045, 0.045), GOLD)
	else:
		var staff := CylinderMesh.new()
		staff.top_radius = 0.022
		staff.bottom_radius = 0.026
		staff.height = 1.5
		_part(weapon, staff, Vector3(0, 0.7, 0), WOOD)
		var ring := TorusMesh.new()
		ring.inner_radius = 0.06
		ring.outer_radius = 0.085
		ring.rings = 10
		ring.ring_segments = 5
		var r := _part(weapon, ring, Vector3(0, 1.5, 0), IRON)
		r.rotation.x = PI * 0.5
		var orb := _part_ball(weapon, Vector3(0, 1.5, 0), Vector3(0.055, 0.055, 0.055), AMBER_STAR)
		var m := orb.material_override as StandardMaterial3D
		m.emission_enabled = true
		m.emission = COLORS["maga"]
		m.emission_energy_multiplier = 0.8


func _box_mesh(size: Vector3) -> BoxMesh:
	var bm := BoxMesh.new()
	bm.size = size
	return bm


func _box(at: Vector3, size: Vector3, color: Color) -> MeshInstance3D:
	return _part(self, _box_mesh(size), at, color)


func _cyl(at: Vector3, radius: float, length: float, color: Color) -> MeshInstance3D:
	var cm := CylinderMesh.new()
	cm.top_radius = radius
	cm.bottom_radius = radius
	cm.height = length
	cm.radial_segments = 8
	return _part(self, cm, at, color)


func _ball(at: Vector3, scale3: Vector3, color: Color) -> MeshInstance3D:
	return _part_ball(self, at, scale3, color)


func _part_ball(parent: Node3D, at: Vector3, scale3: Vector3, color: Color) -> MeshInstance3D:
	var sm := SphereMesh.new()
	sm.radius = 1.0
	sm.height = 2.0
	sm.radial_segments = 8
	sm.rings = 4
	var mi := _part(parent, sm, at, color)
	mi.scale = scale3
	return mi


func _part(parent: Node3D, mesh: Mesh, at: Vector3, color: Color) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	m.roughness = 0.9
	mi.material_override = m
	mi.position = at
	parent.add_child(mi)
	return mi
