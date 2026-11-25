class_name ArenaExit
extends Resource
## One way out of an arena (cycle C12): where the paladin stands in front of it, the way into the room from it (its
## sign floats that way) and the zone of floor that leaves by it when stepped on. RoomLayout.exits, in the order the
## doors are numbered. Pure.

## The spot in front of the door, on the floor (Arena.exits, where the bot walks to leave).
@export var at := Vector2.ZERO
## The way into the room from the door (unit).
@export var inward := Vector2(0, 1)
## Stepping inside this rectangle leaves by the door (Arena.exit_zones).
@export var zone := Rect2()
## The mouth: floor beyond the room's edge (the top landing of its stairs), walkable only when the door is used.
@export var mouth := Rect2()
## PT-2: where the door's medallion hangs, on the door's own arch (or over its stairs): height of its middle over the
## floor, meters inward from the edge (0: in the arch's plane) and the height where its sign's text starts, under it.
@export var medal_up := 4.7
@export var medal_in := 0.0
@export var sign_up := 1.9
## The spot on the floor's edge, in the middle of the opening, when the mouth is not given (at_edge puts `at` this far
## out of the room: 0.75 of its 2.4 m).
const EDGE_FROM_SPOT := 1.8


static func make(spot: Vector2, into: Vector2, leave: Rect2, landing := Rect2()) -> ArenaExit:
	var e := ArenaExit.new()
	e.at = spot
	e.inward = into.normalized()
	e.zone = leave
	e.mouth = landing
	return e


## A door in a straight edge (cycle C12 spec, section 0.4): its mouth `width` wide reaching `beyond` meters out of the
## room from `edge` (the middle of the door on the edge), the outer half of the mouth leaves, the spot in its middle.
static func at_edge(edge: Vector2, into: Vector2, width := 4.0, beyond := 2.4) -> ArenaExit:
	var u := into.normalized()
	var side := Vector2(-u.y, u.x) * width * 0.5
	var out := edge - u * beyond
	var landing := Rect2(edge + side, Vector2.ZERO).expand(edge - side).expand(out + side).expand(out - side)
	var half_out := edge - u * beyond * 0.5
	var zone_r := Rect2(half_out + side, Vector2.ZERO).expand(half_out - side).expand(out + side).expand(out - side)
	return make(edge - u * beyond * 0.75, u, zone_r, landing)


## The middle of the opening on the room's edge (the landing's inner side, or EDGE_FROM_SPOT in from the spot).
func edge() -> Vector2:
	if mouth.has_area():
		return mouth.get_center() + inward * absf(mouth.size.dot(inward)) * 0.5
	return at + inward * EDGE_FROM_SPOT


## Where the medallion hangs (x, height, z): the edge's middle moved `medal_in` into the room.
func medal_anchor() -> Vector3:
	var p := edge() + inward * medal_in
	return Vector3(p.x, medal_up, p.y)


func mirrored() -> ArenaExit:
	var m := make(Vector2(-at.x, at.y), Vector2(-inward.x, inward.y), RoomLayout.mirror_rect(zone), RoomLayout.mirror_rect(mouth))
	m.medal_up = medal_up
	m.medal_in = medal_in
	m.sign_up = sign_up
	return m
