class_name PlainLook
extends ArenaRoom
## The provisional look of the arenas and rooms of E5 (Arena.PROVISIONAL_LOOKS) until the environment artist's own
## (SanctuaryLook, BridgeLook, RunesLook and the rooms of the Provação and the altar): the common look of ArenaRoom
## (floor with its holes, edges, every obstacle on its footprint, doors) and a cold key light over the floor so the
## fight reads. Collision never comes from here.

const KEY := Color(0.78, 0.82, 0.95)
const KEY_ENERGY := 1.6


func dress() -> void:
	key_light(KEY, KEY_ENERGY)
