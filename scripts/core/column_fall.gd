class_name ColumnFall
extends RefCounted
## The cracked columns that topple (RP-09, docs/design/rooms_progression.md; the DestructibleTree of the Hades II): the
## obstacles of a room with ArenaObstacle.hits_to_fall. Only the paladin's blows count: the first cracks a column, the
## last topples it the way the blow went (never back onto him): its band (fall_width across, fall_length from its middle) shows for
## fall_time while it leans, then it lands, dealing fall_damage to each enemy on it and nothing to him, and the column
## is a stump. Once per column per room. Pure: ColumnFloor puts it in the room.

enum Stage { STANDING, CRACKED, LEANING, FALLEN }

## The obstacles that may topple (in the layout's order), and each one's stage, blows taken and fall's way.
var columns: Array[ArenaObstacle] = []
var stage := PackedInt32Array()
var taken := PackedInt32Array()
var way := PackedVector2Array()


func _init(obstacles: Array[ArenaObstacle]) -> void:
	for o in obstacles:
		if o.hits_to_fall > 0:
			columns.append(o)
	stage.resize(columns.size())
	taken.resize(columns.size())
	way.resize(columns.size())


## A blow of the paladin from `origin` toward `dir`: an arc of `degrees` (ComboNode.Shape.ARC), a circle (CIRCLE, any
## angle) or a band `width` wide (LINE), out to `reach`. Returns the columns it touches, as {"cracked": [...],
## "toppled": [...]} (indexes into columns).
func hit(shape: int, origin: Vector2, dir: Vector2, reach: float, width: float) -> Dictionary:
	var cracked := PackedInt32Array()
	var toppled := PackedInt32Array()
	for i in columns.size():
		if stage[i] >= Stage.LEANING:
			continue
		var o := columns[i]
		if not touches(shape, origin, dir, reach, width, o.center, o.radius):
			continue
		taken[i] += 1
		if taken[i] >= o.hits_to_fall:
			stage[i] = Stage.LEANING
			# toward where the blow went (the way the blade swung; the assist turns it to the nearest enemy), never back
			# onto him
			var away := (o.center - origin).normalized()
			var blow := dir.normalized()
			way[i] = blow if blow.dot(away) > 0.0 or away == Vector2.ZERO else away
			toppled.append(i)
		else:
			stage[i] = Stage.CRACKED
			cracked.append(i)
	return {"cracked": cracked, "toppled": toppled}


## Whether a blow's shape reaches a round piece at `center` of `radius` (as the crowd's in_arc, in_circle, in_line).
static func touches(shape: int, origin: Vector2, dir: Vector2, reach: float, width: float, center: Vector2, radius: float) -> bool:
	var d := center - origin
	match shape:
		ComboNode.Shape.LINE:
			var along := d.dot(dir.normalized())
			return along >= -radius and along <= reach + radius and absf(d.cross(dir.normalized())) <= width * 0.5 + radius
		ComboNode.Shape.CIRCLE:
			return d.length() <= reach + radius
	var r := reach + radius
	if d.length_squared() > r * r:
		return false
	return d.length() < 1.0 or absf(dir.angle_to(d)) <= deg_to_rad(width) * 0.5 + radius / maxf(d.length(), 0.5)


## Where column i falls: the band's start (the column's middle), its way, length and width.
func band(i: int) -> Dictionary:
	var o := columns[i]
	return {"from": o.center, "dir": way[i], "length": o.fall_length, "width": o.fall_width}


## Column i landed: it is a stump now.
func landed(i: int) -> void:
	stage[i] = Stage.FALLEN


## The stump left by a fallen column: the same footprint (nobody walking ends up inside anything new; the walking grid
## stays right), low, stopping bodies and no shots.
static func stump(o: ArenaObstacle) -> ArenaObstacle:
	var s := ArenaObstacle.circle(o.center, o.radius, &"column_base", 0.6, false)
	return s
