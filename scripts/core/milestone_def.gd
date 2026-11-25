class_name MilestoneDef
extends Resource
## One milestone of the Santuário's opening (SW-O5, docs/design/onboarding_sw_o.md): when it is reached and what it opens
## (one station, or the Ultimate). Data only: the table is written by the `milestones` part of tools/make_data.gd into
## data/milestones/NN_id.tres; Milestones.defaults() holds the same values for when the folder is not there (tests).

## The id is also the id of its guide (data/hub_guide/): tree, forge, book, account, vendor, ult, maga.
@export var id: StringName
## The order milestones come in; at most one is presented per visit (the lowest not shown yet).
@export var order := 0
## What it opens: a station of HubPlan.STATIONS, or &"ult" (the Ultimate: not a station).
@export var opens: StringName
## Descents played (SaveData.runs) it asks for; 0 asks for none.
@export var runs_min := 0
## What else it asks for (Milestones.NEEDS): &"first", &"guardian", &"win", &"stone", &"mastery2".
@export var needs: Array[StringName] = []
## True: any one of runs_min and needs is enough; false: all of them.
@export var any_of := false
