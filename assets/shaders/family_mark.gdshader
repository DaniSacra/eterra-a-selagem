shader_type spatial;
// The floor form of a Blessing family (vfx_pass_spec.md 5.3): what a family's gift leaves on the floor where it acts on
// its own (Skills: NOVA, METEOR, CONSECRATE) and, small, where its blow lands (Fx.family_hit). One shader, one form per
// family, drawn on a flat quad of 2 x 2 (scaled to the radius), laid over the floor (premultiplied: light under `cap`,
// the dark scorch covering), never a filled disc:
//   0 Chama: a ring of 12 to 18 tongues of fire licking out from the ring (`count`, `tongue` of the radius) that flare
//      and die in 0.4 s, over a charred ring that fades in `scorch` seconds;
//   1 Geada: hexagonal plates of frost spreading from the middle to the radius in 0.25 s, pale facets with ice edges,
//      breaking into cracks and gone at the end;
//   2 Luz: a thin ring drawn round from the side nearest the paladin in 0.12 s, eight short marks and an old gold thread
//      inside it;
//   3 Vigília: three segmented arcs (12 segments with gaps) opening from 0.55 to the radius in 0.2 s, no fill; `arc`
//      (half, radians) narrows them to a cry toward +x of the quad (Fx turns the quad to the blow's way).
render_mode unshaded, blend_premul_alpha, cull_disabled, depth_draw_never, shadows_disabled, fog_disabled;

uniform int form = 0;
uniform vec3 color : source_color = vec3(1.0, 0.6, 0.16);
uniform float cap = 0.6;
uniform float life = 0.0;
uniform float time = 0.5;
uniform float radius_m = 3.0;
uniform float seed = 0.0;
uniform float count = 15.0;
uniform float tongue = 0.22;
uniform float scorch = 1.5;
uniform float scorch_cover = 0.5;
uniform float arc = 3.2;
uniform float line_m = 0.05;
uniform float hex_m = 0.55;
uniform vec2 start = vec2(0.0, 1.0);
uniform vec3 gold : source_color = vec3(0.95, 0.72, 0.3);

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash(i), hash(i + vec2(1.0, 0.0)), u.x), mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), u.x), u.y);
}

// a line `width` metres wide at distance d (metres) from its middle, anti-aliased by the pixel's size
float line(float d, float width, float px) {
	return 1.0 - smoothstep(width * 0.5, width * 0.5 + px, abs(d));
}

// distance to the edge of the hexagon this point is in (cells `size` metres across) and the cell's middle
vec3 hex(vec2 p, float size) {
	vec2 s = vec2(1.0, 1.7320508);
	vec2 q = p / size;
	vec4 c = floor(vec4(q, q - vec2(0.5, 1.0)) / s.xyxy) + 0.5;
	vec4 h = vec4(q - c.xy * s, q - (c.zw + 0.5) * s);
	vec2 local = dot(h.xy, h.xy) < dot(h.zw, h.zw) ? h.xy : h.zw;
	vec2 middle = (q - local) * size;
	vec2 a = abs(local);
	float edge = 0.5 - max(dot(a, s * 0.5), a.x);
	return vec3(edge * size, middle);
}

void fragment() {
	vec2 p = UV * 2.0 - 1.0;
	float r = length(p);
	if (r > 1.25) discard;
	float a = atan(p.y, p.x);
	float age = life * time;
	float m = r * radius_m;
	float px = max(fwidth(m), 0.0005);
	vec3 light = vec3(0.0);
	float cover = 0.0;
	if (form == 0) {
		// tongues: flare in the first 0.12 s, die by 0.4 s
		float flare = smoothstep(0.0, 0.08, age) * (1.0 - smoothstep(0.15, 0.4, age));
		float n = max(count, 3.0);
		float cell = a / TAU * n + seed * 7.0;
		float u = fract(cell) * 2.0 - 1.0;
		float id = floor(cell);
		float len = tongue * mix(0.6, 1.0, hash(vec2(id, seed))) * (0.6 + 0.4 * smoothstep(0.0, 0.12, age));
		float h = (r - 0.72) / max(len, 0.001);
		float sway = 0.25 * sin(age * 30.0 + id * 2.1) * h;
		float w = pow(clamp(1.0 - h, 0.0, 1.0), 0.6) * (0.7 - 0.25 * noise(vec2(h * 6.0 - age * 9.0, id)));
		float body = step(0.0, h) * step(h, 1.0) * (1.0 - smoothstep(w - 0.12, w, abs(u - sway)));
		vec3 tip = vec3(color.r * 0.7, color.g * 0.25, color.b * 0.1);
		light += mix(color, tip, smoothstep(0.2, 0.9, h)) * body * flare;
		// the charred ring under them
		float burn = 1.0 - smoothstep(scorch * 0.3, scorch, age);
		float band = smoothstep(0.42, 0.62, r + 0.08 * noise(p * 5.0 + seed)) * (1.0 - smoothstep(0.92, 1.08, r + 0.1 * noise(p * 4.0 - seed)));
		cover = band * scorch_cover * burn * smoothstep(0.0, 0.1, age);
	} else if (form == 1) {
		vec3 h = hex(p * radius_m + seed * 3.0, hex_m);
		float from_mid = length(h.yz - seed * 3.0) / radius_m;
		float front = smoothstep(0.0, 0.25, age) * 1.05;
		float here = step(from_mid, front) * step(from_mid, 1.0);
		float fade = 1.0 - smoothstep(time * 0.55, time, age);
		// cracks eat the edges as it goes
		float broken = step(smoothstep(time * 0.4, time, age) * 0.9, noise(UV * 18.0 + seed));
		float edge = line(h.x, line_m, px) * broken;
		float facet = 0.18 * (0.5 + 0.5 * sign(sin(atan(p.y * radius_m - h.z, p.x * radius_m - h.y) * 3.0)));
		light += (mix(color, vec3(1.0), 0.45) * edge + color * facet * 0.4) * here * fade;
		cover = 0.12 * here * fade;
	} else if (form == 2) {
		// drawn round from `start` (the side nearest the paladin) in 0.12 s
		float from_start = acos(clamp(dot(normalize(p + 0.0001), normalize(start)), -1.0, 1.0)) / PI;
		float drawn = step(from_start, smoothstep(0.0, 0.12, age) * 1.01);
		float fade = 1.0 - smoothstep(time * 0.5, time, age);
		float ring = line(m - radius_m, line_m, px);
		float marks = step(0.5, fract(a / TAU * 8.0 + 0.25) < 0.04 || fract(a / TAU * 8.0 + 0.25) > 0.96 ? 1.0 : 0.0)
			* step(radius_m - 0.28, m) * step(m, radius_m + 0.12);
		float thread = line(m - radius_m * 0.86, line_m * 0.6, px);
		light += (mix(color, vec3(1.0), 0.3) * (ring + marks) + gold * thread * 0.7) * drawn * fade;
	} else {
		float open = mix(0.55, 1.0, 1.0 - pow(1.0 - smoothstep(0.0, 0.2, age), 3.0));
		float fade = 1.0 - smoothstep(time * 0.5, time, age);
		float inside_arc = 1.0 - smoothstep(arc - 0.05, arc, abs(a));
		float segments = step(0.12, fract(a / TAU * 12.0 + seed));
		float arcs = 0.0;
		for (int k = 0; k < 3; k++) {
			float rk = radius_m * open * mix(0.62, 1.0, float(k) / 2.0);
			arcs += line(m - rk, line_m * (1.3 - 0.2 * float(k)), px) * (1.0 - 0.25 * float(k));
		}
		light += mix(color, vec3(1.0), 0.15) * arcs * segments * inside_arc * fade;
	}
	float peak = max(light.r, max(light.g, light.b)) * cap;
	vec3 lit = light * cap;
	if (peak > cap) {
		lit *= cap / peak;
		peak = cap;
	}
	float a_light = clamp(peak / max(cap, 0.0001), 0.0, 1.0);
	float alpha = clamp(a_light + cover * (1.0 - a_light), 0.0, 1.0);
	if (alpha <= 0.002) discard;
	ALBEDO = lit;
	ALPHA = alpha;
}
