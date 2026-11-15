shader_type spatial;
// Violet light rising from far below at the sides of the abyss: an upright card, brightest at its foot and fading
// up and to the sides, slowly breathing. It always turns round Y to face the camera (so seen from the fight's camera
// it is never a flat lit panel), fades when seen edge-on and has a ragged edge of noise. Added on top and kept out of
// the fog (it is the light the mist glows with), so it reads the same on desktop and in the browser.
render_mode unshaded, blend_add, depth_draw_never, cull_disabled, shadows_disabled, fog_disabled;

uniform vec3 color : source_color = vec3(0.45, 0.3, 0.95);
uniform float energy = 1.6;
// How far up the card the glow reaches (0 to 1 of its height), how soft its sides are, how ragged its edge (share).
uniform float reach = 0.75;
uniform float side = 0.45;
uniform float ragged = 0.3;

float hash1(vec2 p) {
	return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}

float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash1(i), hash1(i + vec2(1, 0)), f.x), mix(hash1(i + vec2(0, 1)), hash1(i + vec2(1, 1)), f.x), f.y);
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
	float v = pow(1.0 - smoothstep(0.0, reach, up + rag), 1.6);
	float h = 1.0 - smoothstep(0.5 - side, 0.5, abs(UV.x - 0.5) + rag * 0.5);
	ALBEDO = color * energy * v * h * (0.6 + 0.6 * n) * (0.9 + 0.1 * sin(TIME * 0.7));
}
