shader_type spatial;
// SL-01 (docs/art/ref/sala01_2026-11-25, 02-planta-dados.json "water"): the hall's shallow stream and pools, a strip a
// hair over the slabs (CatacombHall.floor_strip: UV.x metres along it, UV.y 0..1 across). Cosmetic only: nobody wades
// through anything, nothing slows, nothing damages. Cold blue-grey that takes a little of the warm lights' glints, a
// soft broken edge, slow ripples (two drifting noises bent into the normal), never a perfect mirror.
render_mode blend_mix, depth_draw_never, cull_disabled, diffuse_lambert, specular_schlick_ggx;

// the water (#536F7A darkened toward the slabs) in its middle and at its edge, the share of the strip's middle that is
// the deeper one, how opaque it is
uniform vec3 deep : source_color = vec3(0.06, 0.11, 0.14);
uniform vec3 shallow : source_color = vec3(0.16, 0.25, 0.3);
uniform float alpha = 0.88;
// the edge: how far in from the bank it fades (share of half the width) and how ragged the bank is
uniform float edge_soft = 0.32;
uniform float edge_ragged = 0.3;
// the ripples: scale (per m), drift speed, how hard they bend the surface
uniform float ripple_scale = 2.6;
uniform float ripple_speed = 0.22;
uniform float ripple_bend = 0.55;
// the warm glints of the candles and the braziers on the ripples' crests: their colour and how much
uniform vec3 glint_color : source_color = vec3(0.95, 0.7, 0.36);
uniform float glint = 0.3;
uniform float roughness = 0.14;

varying vec3 world;

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash(i), hash(i + vec2(1.0, 0.0)), f.x), mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), f.x), f.y);
}

float ripples(vec2 p) {
	float t = TIME * ripple_speed;
	return noise(p + vec2(t, t * 0.6)) * 0.6 + noise(p * 1.9 - vec2(t * 0.8, t)) * 0.4;
}

void vertex() {
	world = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	float across = 1.0 - abs(UV.y * 2.0 - 1.0);
	float bank = across + (noise(world.xz * 1.7) - 0.5) * edge_ragged;
	float edge = smoothstep(0.0, edge_soft, bank);
	vec2 p = world.xz * ripple_scale;
	float h = ripples(p);
	float gx = ripples(p + vec2(0.07, 0.0)) - h;
	float gz = ripples(p + vec2(0.0, 0.07)) - h;
	vec3 n = normalize(vec3(-gx * ripple_bend * 12.0, 1.0, -gz * ripple_bend * 12.0));
	NORMAL = normalize((VIEW_MATRIX * vec4(n, 0.0)).xyz);
	ALBEDO = mix(shallow, deep, smoothstep(0.1, 0.8, across));
	ROUGHNESS = roughness;
	SPECULAR = 0.35;
	// a faint glint on the crests, strongest where the surface leans (it never glows on its own)
	EMISSION = glint_color * glint * smoothstep(0.62, 0.9, h) * edge * 0.25;
	ALPHA = alpha * edge;
}
