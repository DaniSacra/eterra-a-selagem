shader_type spatial;
// A bank of pale teal mist hanging between two planes of silhouettes in the abyss, so each plane stands out against
// the one behind: a wide low card that turns round Y to the camera, densest in its middle, its edges ragged with
// noise and slowly drifting. Unlit, blended over what is behind it.
render_mode unshaded, blend_mix, depth_draw_never, cull_disabled, shadows_disabled, fog_disabled;

uniform vec3 color : source_color = vec3(0.07, 0.28, 0.31);
uniform float alpha = 0.25;
// Share of the card that is ragged edge.
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

float fbm(vec2 p) {
	float s = 0.0;
	float a = 0.5;
	for (int i = 0; i < 4; i++) {
		s += noise(p) * a;
		p = p * 2.03 + 1.3;
		a *= 0.5;
	}
	return s;
}

void vertex() {
	vec3 to_cam = INV_VIEW_MATRIX[3].xyz - MODEL_MATRIX[3].xyz;
	vec3 fwd = normalize(vec3(to_cam.x, 0.0, to_cam.z));
	vec3 right = normalize(cross(vec3(0.0, 1.0, 0.0), fwd));
	vec3 w = MODEL_MATRIX[3].xyz + right * VERTEX.x + vec3(0.0, 1.0, 0.0) * VERTEX.y;
	VERTEX = (inverse(MODEL_MATRIX) * vec4(w, 1.0)).xyz;
}

void fragment() {
	float n = fbm(vec2(UV.x * 7.0 + TIME * 0.02, UV.y * 2.5));
	vec2 e = min(UV, 1.0 - UV);
	float edge = smoothstep(0.0, ragged, e.y + (n - 0.5) * ragged) * smoothstep(0.0, ragged * 0.5, e.x + (n - 0.5) * ragged * 0.5);
	ALBEDO = color * (0.85 + 0.3 * n);
	ALPHA = alpha * edge * (0.6 + 0.8 * n);
}
