shader_type spatial;
// A wisp of smoke (vfx_pass_spec.md 5.6, Fx.wisps): a card facing the camera, taller than wide, its edge torn by
// noise that drifts up, coming apart from below as it ages (the instance's custom g = its life 0..1, r its seed). The
// instance colour is its light (dark for smoke, pale for souls) and a its fade. Laid over what is behind it
// (premultiplied): dark smoke covers by WISP cover, pale souls add their light under `cap`. Never a round dot: the
// torn outline and the hole that eats it from below.
render_mode unshaded, blend_premul_alpha, cull_disabled, depth_draw_never, shadows_disabled, fog_disabled, skip_vertex_transform;

uniform float cap = 1.0;
// How much a dark wisp covers (alpha at its thickest) and how much a bright one does.
uniform float cover_dark = 0.75;
uniform float cover_light = 0.3;
uniform float torn = 0.45;

varying vec4 tone;
varying vec2 info;

void vertex() {
	tone = COLOR;
	info = INSTANCE_CUSTOM.rg;
	vec3 centre = MODEL_MATRIX[3].xyz;
	vec3 right = INV_VIEW_MATRIX[0].xyz;
	vec3 up = INV_VIEW_MATRIX[1].xyz;
	float w = length(MODEL_MATRIX[0].xyz);
	float h = length(MODEL_MATRIX[1].xyz);
	vec3 world = centre + right * VERTEX.x * w + up * VERTEX.y * h;
	VERTEX = (VIEW_MATRIX * vec4(world, 1.0)).xyz;
}

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash(i), hash(i + vec2(1.0, 0.0)), u.x), mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), u.x), u.y);
}

void fragment() {
	vec2 p = UV * 2.0 - 1.0;
	float seed = info.x * 37.0;
	float life = info.y;
	// a flame-like teardrop: wide below the middle, narrowing to the top
	float width = mix(1.0, 0.45, smoothstep(-0.6, 1.0, -p.y));
	float d = length(vec2(p.x / max(width, 0.05), p.y * 0.9));
	float n = noise(vec2(p.x * 3.0 + seed, p.y * 2.5 + TIME * 1.2 + seed)) * 0.6
		+ noise(vec2(p.x * 7.0 - seed, p.y * 6.0 + TIME * 2.0)) * 0.4;
	float edge = 1.0 - torn * n;
	float body = 1.0 - smoothstep(edge - 0.25, edge, d);
	// coming apart from below as it ages
	float eaten = smoothstep(-1.0 + life * 2.2 - 0.3, -1.0 + life * 2.2 + 0.3, -p.y + n * 0.5);
	body *= mix(1.0, eaten, smoothstep(0.2, 0.6, life));
	if (body <= 0.01) discard;
	float bright = max(tone.r, max(tone.g, tone.b));
	float cover = mix(cover_dark, cover_light, smoothstep(0.25, 0.7, bright)) * body * tone.a;
	vec3 light = tone.rgb * body * tone.a * mix(1.0, 0.6, smoothstep(0.25, 0.7, bright));
	float peak = max(light.r, max(light.g, light.b));
	if (peak > cap) {
		light *= cap / peak;
	}
	ALBEDO = light;
	ALPHA = clamp(max(cover, peak / max(cap, 0.0001)), 0.0, 1.0);
}
