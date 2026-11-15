shader_type spatial;
// Violet light rising from far below at the sides of the abyss: an upright card, bright only at its foot and fading
// fast up and to the sides, broken into drifting tatters by noise (more of them higher up), slowly breathing. It
// always turns round Y to face the camera (so seen from the fight's camera it is never a flat lit panel) and has a
// ragged edge of noise. Added on top and kept out of the fog (it is the light the mist glows with), so it reads the
// same on desktop and in the browser.
render_mode unshaded, blend_add, depth_draw_never, cull_disabled, shadows_disabled, fog_disabled;

uniform vec3 color : source_color = vec3(0.4, 0.3, 0.75);
uniform float energy = 1.6;
// How far up the card the glow reaches (0 to 1 of its height), how soft its sides are, how ragged its edge (share).
uniform float reach = 0.7;
uniform float side = 0.45;
uniform float ragged = 0.6;
// How much of the card the tatters cut away (0 none, 1 all), and how fast they drift up.
uniform float breakup = 0.25;
uniform float rise = 0.12;
// The share of the card at its foot that fades in (so its bottom edge never shows).
uniform float foot_fade = 0.12;

float hash1(vec2 p) {
	return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}

float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash1(i), hash1(i + vec2(1, 0)), f.x), mix(hash1(i + vec2(0, 1)), hash1(i + vec2(1, 1)), f.x), f.y);
}

float fbm(vec2 p) {
	float s = 0.0;
	float a = 0.5;
	for (int i = 0; i < 3; i++) {
		s += noise(p) * a;
		p = p * 2.03 + 1.7;
		a *= 0.5;
	}
	return s;
}

void vertex() {
	// turn round Y to the camera
	vec3 to_cam = INV_VIEW_MATRIX[3].xyz - MODEL_MATRIX[3].xyz;
	vec3 fwd = normalize(vec3(to_cam.x, 0.0, to_cam.z));
	vec3 right = normalize(cross(vec3(0.0, 1.0, 0.0), fwd));
	vec3 w = MODEL_MATRIX[3].xyz + right * VERTEX.x + vec3(0.0, 1.0, 0.0) * VERTEX.y;
	VERTEX = (inverse(MODEL_MATRIX) * vec4(w, 1.0)).xyz;
}

void fragment() {
	float up = 1.0 - UV.y;
	float n = noise(vec2(UV.x * 6.0, UV.y * 3.0 - TIME * 0.15));
	float rag = (noise(vec2(UV.x * 9.0, UV.y * 5.0 + 3.0)) - 0.5) * ragged;
	float v = pow(1.0 - smoothstep(0.0, reach, up + rag), 2.2) * smoothstep(0.0, foot_fade, up);
	float h = 1.0 - smoothstep(0.5 - side, 0.5, abs(UV.x - 0.5) + rag * 0.5);
	// tatters: the higher, the more of the card is cut away
	float t = fbm(vec2(UV.x * 5.0, UV.y * 2.5 + TIME * rise));
	float keep = smoothstep(breakup * (0.5 + up * 0.7) - 0.15, breakup * (0.5 + up * 0.7) + 0.15, t);
	ALBEDO = color * energy * v * h * keep * (0.6 + 0.6 * n) * (0.9 + 0.1 * sin(TIME * 0.7));
}
