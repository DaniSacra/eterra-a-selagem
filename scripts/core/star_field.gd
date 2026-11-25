class_name StarField
extends RefCounted
## The stars of the night sky behind the meta screens (SW-M1): a fixed scatter made from a seed, so the same screen always
## shows the same sky. Each star: p (0 to 1 on the screen), r (px at 720 lines), phase (twinkle), depth (0.2 far to 1 near,
## how much it follows the camera), warm (0 cold to 1 warm). Pure data; SkyGround draws it.

const FAR := 0.2


static func make(seed_value: int, count: int) -> Array[Dictionary]:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	var out: Array[Dictionary] = []
	for i in count:
		var depth := rng.randf_range(FAR, 1.0)
		out.append({"p": Vector2(rng.randf(), rng.randf()), "r": 0.6 + 1.6 * depth * rng.randf(),
			"phase": rng.randf() * TAU, "depth": depth, "warm": rng.randf()})
	return out
