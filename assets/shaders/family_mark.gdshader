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
// GP-3 (VFX "tinta em movimento", assinatura 4), the other forms, each with a shape of its own (not only a colour):
//   4 Véu: a grey-yellow mist, a band of noisy fog thickening on the ring (no violet), dimming what is under it a little;
//   5 Maré: two flowing ribbons round the ring (a wave in the radius, `arc` narrows them to a way) with silver foam
//      specks riding their crests;
//   6 Marca: thin oblique incisions (one slope, broken by gaps) crossing the ring's band, bronze, never a long line;
//   7 Peste: threads of mist rising off the ring in strands (`color` sulphur, `accent` lichen) with luminous seeds in them,
//      over a charcoal heart (`ink`);
//   8 Trovão: segmented zigzag bolts from the middle (one forks at half way), slate (`color`), and for the first 3 frames
//      (0.05 s) only the flash `accent` (lightning yellow).
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
// The second hue of a form (Peste lichen, Trovão flash, Maré foam) and the dark that covers (Peste charcoal)
uniform vec3 accent : source_color = vec3(0.62, 0.68, 0.48);
uniform vec3 ink : source_color = vec3(0.18, 0.17, 0.15);

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
	} else if (form == 3) {
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
	} else if (form == 4) {
		// Véu: fog on the ring, drifting; born in 0.1 s, thinning out to the end
		float fade = smoothstep(0.0, 0.1, age) * (1.0 - smoothstep(time * 0.45, time, age));
		float band = smoothstep(0.35, 0.8, r) * (1.0 - smoothstep(0.88, 1.12, r));
		float fog = noise(p * 4.5 + vec2(age * 1.4, seed * 9.0)) * 0.65 + noise(p * 9.0 - vec2(0.0, age * 2.0)) * 0.35;
		float body = band * smoothstep(0.3, 0.75, fog);
		// the amber is the dim edge of the cloud only
		float rim = band * (1.0 - smoothstep(0.42, 0.6, fog)) * smoothstep(0.2, 0.4, fog);
		light += (color * 0.55 * body + vec3(0.9, 0.62, 0.22) * 0.22 * rim) * fade;
		cover = body * 0.3 * fade;
	} else if (form == 5) {
		// Maré: the ribbons run round the ring and swing in and out, foam on the crests
		float open = 1.0 - pow(1.0 - smoothstep(0.0, 0.18, age), 3.0);
		float fade = 1.0 - smoothstep(time * 0.5, time, age);
		float inside_arc = 1.0 - smoothstep(arc - 0.05, arc, abs(a));
		float ribbons = 0.0;
		float foam = 0.0;
		for (int k = 0; k < 2; k++) {
			float swing = sin(a * 5.0 + float(k) * 2.4 - age * 9.0 + seed * 6.0);
			float rk = radius_m * open * (0.8 + 0.2 * float(k)) + swing * 0.12 * radius_m * 0.5;
			float wide = line_m * (2.6 - 0.8 * float(k)) * (0.7 + 0.5 * smoothstep(-1.0, 1.0, swing));
			ribbons += line(m - rk, wide, px) * (1.0 - 0.3 * float(k));
			float speck = step(0.8, hash(vec2(floor(a * 24.0 + float(k) * 7.0), floor(age * 12.0))));
			foam += line(m - rk - 0.04, line_m * 1.8, px) * speck * step(0.6, swing);
		}
		light += (color * ribbons + mix(accent, vec3(1.0), 0.6) * foam * 0.9) * inside_arc * fade;
	} else if (form == 6) {
		// Marca: oblique incisions, every one short; they land one after the other in 0.1 s
		float fade = 1.0 - smoothstep(time * 0.5, time, age);
		vec2 q = p * radius_m;
		float slope = 0.62;
		vec2 across = vec2(cos(slope), sin(slope));
		vec2 along = vec2(-across.y, across.x);
		float lane = dot(q, across) / 0.32;
		float lane_id = floor(lane);
		float d = (fract(lane) - 0.5) * 0.32;
		float at = dot(q, along);
		float from_at = (hash(vec2(lane_id, seed)) - 0.5) * 1.2;
		float len = 0.35 + 0.5 * hash(vec2(lane_id, seed + 3.0));
		float cut = line(d, line_m * 0.8, px) * step(from_at, at) * step(at, from_at + len);
		float band = step(0.45, r) * step(r, 1.0 + 0.02);
		float order = hash(vec2(lane_id, 5.0)) * 0.1;
		float shown = step(order, age) * step(0.4, hash(vec2(lane_id, seed + 9.0)) + 0.35);
		light += mix(color, vec3(1.0), 0.12) * cut * band * shown * fade;
		cover = cut * band * shown * 0.35 * fade;
	} else if (form == 7) {
		// Peste: strands rising off the ring, then seeds that glow; the charcoal heart under the ring
		float fade = smoothstep(0.0, 0.12, age) * (1.0 - smoothstep(time * 0.5, time, age));
		float n = max(count, 6.0);
		float cell = a / TAU * n + seed * 5.0;
		float lane = abs(fract(cell) * 2.0 - 1.0);
		float rise = (r - 0.55) / 0.5;
		float wob = 0.18 * sin(rise * 7.0 + floor(cell) * 3.0 - age * 6.0);
		float strand = (1.0 - smoothstep(0.04, 0.16, abs(lane - 0.5 - wob))) * step(0.0, rise) * (1.0 - smoothstep(0.55, 1.0, rise));
		strand *= step(0.3, hash(vec2(floor(cell), seed)));
		vec2 g = p * radius_m * 6.0 + vec2(0.0, -age * 2.0);
		vec2 gi = floor(g);
		float seedpt = step(0.93, hash(gi + seed)) * (1.0 - smoothstep(0.08, 0.2, length(fract(g) - 0.5))) * step(0.5, r) * step(r, 1.05);
		light += (color * strand * 0.75 + accent * seedpt * 1.0) * fade;
		float heart = smoothstep(0.5, 0.7, r + 0.08 * noise(p * 5.0 + seed)) * (1.0 - smoothstep(0.88, 1.05, r));
		cover = heart * 0.4 * fade;
	} else {
		// Trovão: bolts of segments with a fork; the flash first
		float flash = 1.0 - step(0.05, age);
		float fade = 1.0 - smoothstep(time * 0.3, time, age);
		float bolts = 0.0;
		for (int k = 0; k < 6; k++) {
			// ART_REVIEW_2026-11-26c: uneven spacing (+-0.8 rad off the sixths, was 0 to 0.8) and uneven lengths (0.65 to 1.0
			// of the radius), so six bolts never read as a sun's rays
			float ak = TAU * float(k) / 6.0 + (hash(vec2(float(k), seed)) - 0.5) * 1.6;
			float klen = 0.65 + 0.35 * hash(vec2(float(k), seed + 9.0));
			float da = mod(a - ak + PI, TAU) - PI;
			float lateral = da * m;
			float seg = 0.42;
			float sid = floor(m / seg);
			float off = mix(hash(vec2(sid, float(k) + seed)), hash(vec2(sid + 1.0, float(k) + seed)), fract(m / seg)) - 0.5;
			float main = line(lateral - off * 0.5, line_m * 1.4, px);
			float fork = line(lateral - off * 0.5 - (m - radius_m * 0.5) * 0.55, line_m, px) * step(radius_m * 0.5, m) * step(0.5, hash(vec2(float(k), seed + 4.0)));
			float gaps = step(0.12, fract(m / seg * 1.7 + float(k) * 0.3));
			float reach = step(m, radius_m * klen * smoothstep(0.0, 0.07, age) * 1.05) * step(0.2 * radius_m, m);
			bolts += (main + fork * 0.8) * gaps * reach;
		}
		bolts = clamp(bolts, 0.0, 1.0);
		light += mix(color, accent, flash) * bolts * (0.8 + 0.4 * flash) * fade;
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
