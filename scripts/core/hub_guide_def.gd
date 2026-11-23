class_name HubGuideDef
extends Resource
## One guide of the Santuário (PT-5): what a station that just opened says the first time. Data only; a new guide is a
## new file in data/hub_guide/, no code (HubGuide reads them, HubGuideOverlay draws them). Written by _hub_guide in
## tools/make_data.gd.

@export var id: StringName
## The order guides come in when several are pending.
@export var order := 0
## The station the camera comes close to (HubPlan.STATIONS).
@export var station: StringName
## The sentence in data/text_pt.tres; {key} is the real key of interact (keyboard, mouse, gamepad, remapped).
@export var text_key: StringName
## When it is due (HubGuide.CONDITIONS): "open" (the station's gate is open), "always", "wins" (Morvath sealed once),
## "account" (the Forjador's Preparo is open).
@export var condition: StringName = &"open"
