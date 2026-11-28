shader_type spatial;
// The Maga's spells (F7, maga_redesign_v1_pack/03_ARTE_VFX.md): one painted-look shader for every piece of them, drawn
// procedurally (noise for the irregular edges, never a clean geometric ring). `form` picks the piece; t goes 0 -> 1 over
// its life. UV is the card's own space: the flat forms read it as a plane centred at (0.5, 0.5) with +x the way it points,
// the line forms (arc, streak) read UV.x along the line and UV.y across it.
//   0 cone   : the Sopro Glacial: a pale wind of mist inside the cone, a readable crystal edge, fading fast
//   1 frost  : the Inverno Eterno's creeping frost: cracked-ice cells, a rim of crystals, melt at the end (low alpha: the
//              floor and every telegraph stay readable under it)
//   2 arc    : the Tempestade's bolt: a thick jagged core and a gold glow (thick = the main arc, thin = a branch)
//   3 orb    : the glow at the staff tip and the Combustao's ball: a hot white core inside the colour, a flicker
//   4 ring   : an irregular ring that opens (the Combustao's impact, the reactions' pulse) with tongues on its outer edge
//   5 steam  : soft white blobs that rise (the thermal reaction)
//   6 streak : the Centelha's trail: a bright head and a tapered tail
//   7 crystals: a few jagged crystals standing from the middle (the crystallization), at the cone's edge too
render_mode unshaded, blend_mix, cull_disabled, depth_draw_never, shadows_disabled;

uniform int form = 0;
uniform vec4 color : source_color = vec4(1.0, 0.6, 0.2, 1.0);
uniform vec4 core : source_color = vec4(1.0, 0.95, 0.8, 1.0);
uniform float t = 0.0;
uniform float seed = 0.0;
// The most opacity the card may have: a ground form keeps it low so nothing under it (a warning, an enemy) is hidden.
uniform float alpha_cap = 0.8;
uniform float width_deg = 90.0;
uniform float thick = 1.0;
uniform bool billboard = false;

float hash(vec2 p) {
	p = fract(p * vec2(123.34, 456.21) + seed * 7.13);
	p += dot(p, p + 45.32);
	return fract(p.x * p.y);
}
float vnoise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash(i), hash(i + vec2(1.0, 0.0)), f.x), mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), f.x), f.y);
}
float fbm(vec2 p) {
	return vnoise(p) * 0.55 + vnoise(p * 2.1 + 3.7) * 0.3 + vnoise(p * 4.3 + 9.1) * 0.15;
}
// Distance to the nearest cell edge of a rough Voronoi: the cracks of the ice.
float cracks(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	float d1 = 8.0;
	float d2 = 8.0;
	for (int y = -1; y <= 1; y++) {
		for (int x = -1; x <= 1; x++) {
			vec2 g = vec2(float(x), float(y));
			vec2 o = vec2(hash(i + g), hash(i + g + 17.0));
			float d = length(g + o - f);
			if (d < d1) { d2 = d1; d1 = d; } else if (d < d2) { d2 = d; }
		}
	}
	return d2 - d1;
}

void vertex() {
	if (billboard) {
		MODELVIEW_MATRIX = VIEW_MATRIX * mat4(INV_VIEW_MATRIX[0], INV_VIEW_MATRIX[1], INV_VIEW_MATRIX[2], MODEL_MATRIX[3]);
		MODELVIEW_MATRIX = MODELVIEW_MATRIX * mat4(vec4(length(MODEL_MATRIX[0].xyz), 0.0, 0.0, 0.0), vec4(0.0, length(MODEL_MATRIX[1].xyz), 0.0, 0.0), vec4(0.0, 0.0, length(MODEL_MATRIX[2].xyz), 0.0), vec4(0.0, 0.0, 0.0, 1.0));
	}
}

void fragment() {
	vec2 uv = UV;
	vec2 p = (uv - 0.5) * 2.0;
	float r = length(p);
	float a = 0.0;
	vec3 c = color.rgb;
	float fade = 1.0 - t;
	if (form == 0) {
		float half_w = radians(width_deg) * 0.5;
		float ang = abs(atan(p.y, p.x));
		float reach = clamp(t * 4.0, 0.0, 1.0);
		float jag = fbm(vec2(ang * 9.0 + seed, r * 6.0)) * 0.16;
		float edge_r = reach * (1.0 - jag);
		float inside = step(ang, half_w) * smoothstep(edge_r, edge_r - 0.12, r) * step(0.12, p.x);
		float side = smoothstep(half_w - 0.14, half_w, ang + jag * 0.25);
		float mist = fbm(p * 5.0 + vec2(-t * 3.0, seed)) * 0.5;
		float rim = smoothstep(edge_r - 0.1, edge_r, r) * inside;
		float crystals = step(0.62, vnoise(vec2(ang * 22.0, floor(r * 9.0)))) * (side + rim) * inside;
		a = inside * (0.1 + mist * 0.5) + (side * inside + rim) * 0.45 + crystals * 0.5;
		c = mix(color.rgb, core.rgb, clamp(rim * 0.8 + crystals + mist * 0.3, 0.0, 1.0));
		a *= pow(fade, 1.6);
	} else if (form == 1) {
		float grow = clamp(t * 7.0, 0.0, 1.0);
		float melt = smoothstep(0.78, 1.0, t);
		float edge = 1.0 - (0.07 + 0.1 * vnoise(vec2(atan(p.y, p.x) * 5.0, seed))) ;
		float limit = grow * (0.97 + 0.03 * vnoise(vec2(atan(p.y, p.x) * 11.0, seed + 2.0)));
		float body = smoothstep(limit, limit - 0.1, r);
		float cr = cracks(p * 4.5 + seed);
		float line = 1.0 - smoothstep(0.0, 0.1, cr);
		float frost = fbm(p * 6.0 + seed) ;
		float rim = smoothstep(limit - 0.2, limit - 0.02, r) * body;
		float spikes = step(0.6, vnoise(vec2(atan(p.y, p.x) * 17.0, seed + 5.0))) * smoothstep(limit - 0.3, limit, r) * body;
		a = body * (0.07 + frost * 0.11) + line * body * 0.2 + rim * 0.2 + spikes * 0.3;
		c = mix(color.rgb, core.rgb, clamp(line * 0.7 + spikes + rim * 0.3, 0.0, 1.0));
		a *= (1.0 - melt) * (1.0 - melt * 0.4 * frost);
	} else if (form == 2) {
		float u = uv.x;
		float v = (uv.y - 0.5) * 2.0;
		float env = sin(3.14159 * clamp(u, 0.0, 1.0));
		float wob = (fbm(vec2(u * 9.0 * (1.0 + 0.3 * thick), seed + floor(t * 14.0))) - 0.5) * 1.1 * env;
		float d = abs(v - wob);
		float w = 0.1 * thick;
		float coreline = 1.0 - smoothstep(w * 0.4, w, d);
		float glow = 1.0 - smoothstep(w, w * 4.5 + 0.12, d);
		float flick = 0.75 + 0.25 * step(0.5, hash(vec2(floor(t * 24.0), seed)));
		a = (coreline + glow * 0.35) * env * flick;
		c = mix(color.rgb, core.rgb, coreline);
		a *= pow(fade, 1.3);
	} else if (form == 3) {
		float flick = 0.88 + 0.12 * vnoise(vec2(t * 30.0 + seed, 1.0));
		float body = pow(1.0 - clamp(r, 0.0, 1.0), 2.0) * flick;
		float hot = pow(1.0 - clamp(r / 0.45, 0.0, 1.0), 1.5);
		float tongue = fbm(vec2(atan(p.y, p.x) * 3.0 + t * 6.0, r * 3.0 + seed));
		a = clamp(body * (0.6 + tongue * 0.6) + hot, 0.0, 1.0);
		c = mix(color.rgb, core.rgb, hot);
		a *= smoothstep(1.0, 0.8, r);
	} else if (form == 4) {
		float ang = atan(p.y, p.x);
		float open = clamp(t * 3.0, 0.0, 1.0);
		float open_e = 1.0 - pow(1.0 - open, 2.0);
		float ruff = fbm(vec2(ang * 4.0 + seed, 1.0));
		float rr = open_e * (0.8 + 0.2 * ruff);
		float wd = 0.08 + 0.1 * (1.0 - open_e) + 0.06 * vnoise(vec2(ang * 7.0, seed + 3.0));
		float ring = 1.0 - smoothstep(0.0, wd, abs(r - rr));
		float tongues = step(0.55, vnoise(vec2(ang * 9.0 + seed, t * 4.0))) * smoothstep(rr, rr + 0.15, r) * (1.0 - smoothstep(rr + 0.1, rr + 0.28, r));
		float fill = (1.0 - smoothstep(0.0, rr, r)) * 0.18;
		a = ring + tongues * 0.7 + fill;
		c = mix(color.rgb, core.rgb, clamp(ring * 0.6 * (1.0 - open), 0.0, 1.0));
		a *= pow(1.0 - t, 1.4);
	} else if (form == 5) {
		float n = fbm(p * 3.0 + vec2(0.0, -t * 1.5) + seed);
		a = smoothstep(0.35, 0.8, n) * smoothstep(1.0, 0.3, r) * 0.7 * sin(3.14159 * clamp(t * 1.2, 0.0, 1.0));
		c = mix(color.rgb, core.rgb, 0.6);
	} else if (form == 6) {
		float u = uv.x;
		float v = abs(uv.y - 0.5) * 2.0;
		float taper = mix(0.05, 1.0, u);
		float body = 1.0 - smoothstep(taper * 0.5, taper, v);
		float head = pow(u, 3.0);
		float coreline = (1.0 - smoothstep(0.0, taper * 0.35, v)) * u;
		a = (body * 0.55 + coreline) * (0.4 + head) * smoothstep(0.0, 0.15, u);
		c = mix(color.rgb, core.rgb, clamp(coreline * 1.2, 0.0, 1.0));
		a *= fade;
	} else {
		float ang = atan(p.y, p.x);
		float spokes = pow(abs(sin(ang * 3.5 + seed * 6.0)), 6.0);
		float height = clamp(t * 6.0, 0.0, 1.0);
		float len = spokes * height * (0.55 + 0.35 * vnoise(vec2(ang * 5.0, seed)));
		float crystal = 1.0 - smoothstep(len * 0.85, len, r);
		a = crystal * step(0.05, len) * 0.8 + (1.0 - smoothstep(0.0, 0.25, r)) * 0.25 * height;
		c = mix(color.rgb, core.rgb, crystal * 0.7);
		a *= smoothstep(1.0, 0.55, t);
	}
	ALBEDO = c * 1.15;
	ALPHA = clamp(a, 0.0, 1.0) * alpha_cap;
}
