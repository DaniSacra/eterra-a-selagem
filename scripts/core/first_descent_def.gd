class_name FirstDescentDef
extends Resource
## The guided first descent in data (SW-O4; docs/design/onboarding_sw_o.md): its rooms, the arrival's times and the
## numbers the HUD's objective reads. Written by `_first` in tools/make_data.gd (data/first_descent.tres); tuned there.

const PATH := "res://data/first_descent.tres"

@export var rooms: Array[FirstRoomDef] = []
## "Sala N de M": M, the last step's number (Morvath's).
@export var rooms_total := 8
## The text key of the arrival's one line (SW-O1) and its times, in seconds from the black (ArrivalTimeline reads them).
@export var arrival_line: StringName = &"arrival_line"
@export var arrival_star_at := 0.6
@export var arrival_open_at := 1.6
@export var arrival_open_s := 0.8
@export var arrival_hero_at := 3.6
@export var arrival_control_at := 4.0
@export var arrival_caption_at := 4.2
@export var arrival_skip_after := 1.0
## Morvath's short fight: his life (1.0: whole) and the last phase he fights (1: he never rises to the second).
@export var boss_hp_scale := 0.6
@export var boss_last_phase := 1
## The meters at which the objective speaks of the slabs and of a vase, and the seconds standing still before it blinks.
@export var obj_dodge_near := 6.0
@export var obj_break_near := 5.0
@export var idle_blink_s := 25.0


static func live() -> FirstDescentDef:
	return load(PATH) as FirstDescentDef if ResourceLoader.exists(PATH) else null


## The rooms of one step, in order.
func layer(n: int) -> Array[FirstRoomDef]:
	var out: Array[FirstRoomDef] = []
	for r in rooms:
		if r.layer == n:
			out.append(r)
	return out


func last_layer() -> int:
	var most := 0
	for r in rooms:
		most = maxi(most, r.layer)
	return most
