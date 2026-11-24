class_name MedallionDef
extends Resource
## The medallion of one hero (docs/art/dons_medallion_spec.md): where each node sits, in the 1280 x 720 design space.
## data/heroes/<id>_medallion.tres, written by _medallion in tools/make_data.gd. Pure data and geometry (no drawing).

const CENTER := Vector2(620.0, 378.0)
const RING := 254.0
const CROWN_ID := &"crown"

@export var hero: StringName
@export var nodes: Array[MedallionNodeDef] = []


static func path_of(hero_id: String) -> String:
	return "res://data/heroes/%s_medallion.tres" % hero_id


static func of(hero_id: String) -> MedallionDef:
	return load(path_of(hero_id)) as MedallionDef


## Where a node is, from the medallion's centre (angle clockwise from twelve o'clock).
static func place(angle_deg: float, radius: float) -> Vector2:
	var a := deg_to_rad(angle_deg)
	return CENTER + Vector2(sin(a), -cos(a)) * radius


func position_of(n: MedallionNodeDef) -> Vector2:
	return place(n.angle, n.radius)


func find(id: StringName) -> MedallionNodeDef:
	for n in nodes:
		if n.id == id:
			return n
	return null
