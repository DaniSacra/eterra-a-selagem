class_name BossLayersFixture
extends RefCounted
## Morvath ships with his attacks one at a time (Daniel, 2026-11-23). The layering mechanism (BossAttack.layers: eruptions and his
## dead laid over an attack) still exists, and these tests keep its safety checks alive on a copy of the shipped fight with the
## layers of the E2 design put back.

const LAYERS := {
	&"scythe": [[&"eruptions"], 3, 0.0],
	&"blades": [[&"summon"], 3, 0.0],
	&"curse": [[&"eruptions", &"summon"], 3, 1.0],
	&"storm": [[&"eruptions", &"summon"], 4, 0.0],
}


static func layered(path: String) -> BossDef:
	var d := (load(path) as BossDef).duplicate(true) as BossDef
	for a: BossAttack in d.attacks:
		if LAYERS.has(a.id):
			var l: Array = LAYERS[a.id]
			a.layers = Array(l[0], TYPE_STRING_NAME, &"", null)
			a.layer_from_phase = l[1]
			a.layer_chance = 1.0
			a.layer_share = l[2]
	return d
