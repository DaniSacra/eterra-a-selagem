class_name MedallionNodeDef
extends Resource
## One place on a hero's medallion (docs/art/dons_medallion_spec.md 3): which Gift, ultimate or crown it holds, and where
## (angle in degrees clockwise from twelve o'clock, radius in pixels from the medallion's centre, diameter of the node).
## Data, written by _medallion in tools/make_data.gd: a new Gift is a new row, never code.

enum Kind { CROWN, GIFT, ULT }

@export var id: StringName
@export var kind: Kind = Kind.GIFT
@export var angle := 0.0
@export var radius := 254.0
@export var diameter := 42.0
