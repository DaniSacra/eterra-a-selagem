class_name BreakablePiece
extends Resource
## One thing in a room that a blow breaks (AT-Q1, docs/art/at_q0_breakables.md): a vase, an urn, an offering, a water
## jar, a crate, a plank, a cracked bench, dry branches or a frail sapling. Data (RoomLayout.breakables, made by the
## stage part of tools/make_data.gd); the rules are Breakables'. It never stops a body nor a shot (MVP, Q-AT2 (a)):
## it is not an ArenaObstacle and the walking grid never sees it. Pure (no nodes). Positions are (x, z) in meters.

enum Form { VASE, URN, OFFERING, WATER, CRATE, PLANK, BENCH, BRANCH, SAPLING }

@export var form := Form.VASE
@export var at := Vector2.ZERO
## Where blows reach it (at most Breakables.MAX_RADIUS) and how tall it stands (0.35 to 1.0 m).
@export var radius := 0.3
@export var height := 0.6
## The group it stands in (2 to 5 together, against a wall, a balustrade or a piece).
@export var group := 0


static func make(form_: Form, at_: Vector2, height_: float, group_: int, radius_ := -1.0) -> BreakablePiece:
	var p := BreakablePiece.new()
	p.form = form_
	p.at = at_
	p.height = height_
	p.group = group_
	p.radius = radius_ if radius_ > 0.0 else Breakables.radius_of(form_, height_)
	return p


func mirrored() -> BreakablePiece:
	var p := duplicate() as BreakablePiece
	p.at.x = -p.at.x
	return p
