class_name HeroStation
extends Node3D
## The hero's station in the Santuário (PT-9), beside the Vendedor: two standards on poles over a low plinth, one for each
## hero of SaveData.HEROES (the Warrior's in the petrol blue of his scarf, the Maga's in amber), the Maga's grey while she
## is locked. PROVISIONAL pieces (cloth boxes on poles); the plinth is stone drawn by HubLook.
##   var s := HeroStation.make(frame, HubLook.at(u, 0.0, v))
##   s.refresh(Save.data)     # the picked hero's standard a little taller, the locked one grey

const POLE_H := 2.6
const CLOTH := Vector3(0.7, 1.2, 0.05)
const COLORS := {"warrior": Color(0.05, 0.3, 0.32), "maga": Color(0.78, 0.5, 0.12)}
const LOCKED := Color(0.22, 0.2, 0.19)
const WOOD := Color(0.3, 0.2, 0.12)

var cloths: Dictionary = {}


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
		var x := (i - (heroes.size() - 1) * 0.5) * 1.5
		_box(Vector3(x, POLE_H * 0.5 + 0.3, 0), Vector3(0.09, POLE_H, 0.09), WOOD).name = "pole_%s" % heroes[i]
		var cloth := _box(Vector3(x, POLE_H - CLOTH.y * 0.5, 0.0), CLOTH, COLORS[heroes[i]])
		cloth.name = "cloth_%s" % heroes[i]
		cloths[heroes[i]] = cloth
		_box(Vector3(x, POLE_H + 0.32, 0), Vector3(CLOTH.x + 0.14, 0.07, 0.07), WOOD)
	refresh({})


## The picked hero's standard shows its colour whole and the locked one goes grey (a save: SaveData.hero_open, picked_hero).
func refresh(data: Dictionary) -> void:
	var picked := SaveData.picked_hero(data)
	for id: String in cloths:
		var mi := cloths[id] as MeshInstance3D
		var m := mi.material_override as StandardMaterial3D
		m.albedo_color = COLORS[id] if SaveData.hero_open(data, id) else LOCKED
		mi.scale = Vector3(1.0, 1.0 if id == picked else 0.85, 1.0)
		mi.position.y = POLE_H - CLOTH.y * 0.5 * mi.scale.y


func _box(at: Vector3, size: Vector3, color: Color) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = size
	mi.mesh = bm
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	m.roughness = 0.9
	mi.material_override = m
	mi.position = at
	add_child(mi)
	return mi
