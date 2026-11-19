// The painted light and the painted stone of the stylized look (STY-03 and STY-04; numbers in
// docs/art/stylized_spec.md 1.3 and 4.3). Included by the *_paint twins of the scenery's shaders (masonry_paint,
// catacomb_floor_paint, kaykit_paint), which VisualProfile puts on the materials in the stylized look; the classic
// shaders never include it, so the classic frame is the one it always was.
// - light(): three bands of light instead of the physical falloff (shadow, middle, lit), soft edges, the shadow side a
//   nearly neutral cold (never black, never violet), fire pools with a drawn edge, no shine but on the wet floor.
// - paint_brush(): the brush in world space (two sizes, stretched along the block, three soft steps of value).
// - paint_hue(), paint_luma(), paint_recolor(): the warm umber stone of the reference picture from any stone colour
//   the classic materials give (their value kept, their hue the painted one).

// The three bands: the value each takes (a share of the lit value), where N.L (times the shadow and the falloff)
// passes from one to the next, and the width of the passage (never a hard step).
// STY-09 (art-director): the shadow band was 0.42, so a cast shadow kept 42% of the key and, under the strong ambient,
// vanished on the floor (criterion 3, the reference's shadow is 53% of the slab); 0.25 draws it.
uniform vec3 paint_values = vec3(0.25, 0.72, 1.0);
uniform vec2 paint_cuts = vec2(0.3, 0.65);
uniform float paint_soft = 0.1;
// A fire's (any light but the key's) pool: where its light starts (N.L times its falloff), so the pool has an edge.
// STY-10: a warm light (a fire: its red well over its blue, paint_fire_from of its red; a fire
// chilled by a mood passes softly back to the bands) paints a flat pool instead of
// the bands: N.L times the falloff of a fire high on a pillar never left the shadow band, so the slab beside a
// brazier stayed as dark as the rest (art review, criterion 3). Inside the edge (paint_pool) the pool takes the
// middle band's value, inside paint_pool_core the lit one: two drawn rings, the energy sets how bright; the edge's
// width (in N.L times falloff).
uniform float paint_pool = 0.1;
uniform float paint_pool_core = 0.3;
uniform float paint_pool_soft = 0.02;
uniform float paint_fire_from = 0.35;
// How much brighter a fire's pool is painted than its light (only on the painted scenery: the candles' own wax and
// the figures keep the light's energy, which would burn them white at the pool's brightness).
uniform float paint_pool_gain = 2.5;
// The pool's colour a share of the fire's saturation (a warm light on the stone, not orange paint).
uniform float paint_pool_saturation = 0.65;
// The colour the shadow band takes (stylized_spec 1.3: hue 220, saturation up to 0.1).
uniform vec3 paint_shadow : source_color = vec3(0.92, 0.93, 0.98);
// The little shine left (matte stone): its share and the most it narrows on the wet floor.
uniform float paint_shine = 0.25;
// The painted stone's colour at the value of paint_ref (the classic stone's luma it stands for).
uniform vec3 paint_stone : source_color = vec3(0.355, 0.34, 0.31);
uniform float paint_ref = 0.36;
// The brush: its two sizes (m), how much it stretches along the block, the value range of its three steps and the
// width of the passage between steps, and how far it turns the hue (degrees, both ways).
uniform vec2 brush_sizes = vec2(0.6, 0.15);
uniform float brush_stretch = 2.0;
uniform vec2 brush_value = vec2(0.88, 1.12);
uniform float brush_soft = 0.12;
uniform float brush_hue = 4.0;
#ifdef PAINT_RIM
// The props' rim (stylized_spec 4.3: 0.3 of the characters', whose is (1.0, 0.82, 0.62) with a fresnel of 3 to 4).
uniform float paint_rim = 0.3;
uniform float paint_rim_power = 3.5;
uniform vec3 paint_rim_color : source_color = vec3(1.0, 0.82, 0.62);
#endif

float paint_hash(vec2 p) {
	return fract(sin(dot(p, vec2(41.31, 289.71))) * 37139.137);
}

float paint_noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	return mix(mix(paint_hash(i), paint_hash(i + vec2(1, 0)), f.x), mix(paint_hash(i + vec2(0, 1)), paint_hash(i + vec2(1, 1)), f.x), f.y);
}

float paint_luma(vec3 c) {
	return dot(c, vec3(0.2126, 0.7152, 0.0722));
}

// The hue turned by deg degrees round the grey axis (the value nearly kept).
vec3 paint_hue(vec3 c, float deg) {
	float a = radians(deg);
	vec3 k = vec3(0.57735);
	return c * cos(a) + cross(k, c) * sin(a) + k * dot(k, c) * (1.0 - cos(a));
}

// A classic stone colour turned into the painted stone: its value kept (as a share of paint_ref), its hue and
// saturation the painted stone's.
vec3 paint_recolor(vec3 c) {
	return paint_stone * (paint_luma(c) / paint_ref);
}

// A share of one in eight blocks pulls to the olive of dry moss (stylized_spec 4.3: hue 60, saturation + 0.05).
vec3 paint_olive(vec3 c) {
	return c * vec3(0.97, 1.02, 0.84);
}

// The brush at p (m, on the face), stretched along `along`: a value multiplier in three soft steps between
// brush_value.x and .y; tone (out) is -1..1 for the hue turn.
float paint_brush(vec2 p, vec2 along, out float tone) {
	vec2 a = normalize(along);
	vec2 q = vec2(dot(p, a) / brush_stretch, dot(p, vec2(-a.y, a.x)));
	float n = paint_noise(q / brush_sizes.x) * 0.62 + paint_noise(q / brush_sizes.y + 17.3) * 0.38;
	float w = brush_soft * 0.5;
	float s = (smoothstep(0.4 - w, 0.4 + w, n) + smoothstep(0.6 - w, 0.6 + w, n)) * 0.5;
	tone = paint_noise(q / (brush_sizes.x * 1.7) + 5.1) * 2.0 - 1.0;
	return mix(brush_value.x, brush_value.y, s);
}

vec3 paint_brushed(vec3 c, vec2 p, vec2 along) {
	float tone;
	float v = paint_brush(p, along, tone);
	return paint_hue(c * v, tone * brush_hue);
}

// The three bands of x (N.L times the shadow and the falloff, 0..1).
float paint_bands(float x) {
	float w = paint_soft * 0.5;
	float v = mix(paint_values.x, paint_values.y, smoothstep(paint_cuts.x - w, paint_cuts.x + w, x));
	return mix(v, paint_values.z, smoothstep(paint_cuts.y - w, paint_cuts.y + w, x));
}

void light() {
	float x = clamp(dot(NORMAL, LIGHT), 0.0, 1.0) * ATTENUATION;
	float lit = paint_bands(x);
	vec3 light_c = LIGHT_COLOR;
	if (!LIGHT_IS_DIRECTIONAL) {
		// a light's pool ends on a drawn edge, not in a long soft falloff
		float w = paint_soft * 0.5;
		float edge = smoothstep(paint_pool - w * 0.5, paint_pool + w * 0.5, x);
		// a fire's pool is flat inside its edge, a little lighter in its core, and a less saturated warm
		float fire = smoothstep(paint_fire_from * 0.6, paint_fire_from, (LIGHT_COLOR.r - LIGHT_COLOR.b) / max(LIGHT_COLOR.r, 1e-4));
		float ring = smoothstep(paint_pool - paint_pool_soft, paint_pool + paint_pool_soft, x);
		float core = smoothstep(paint_pool_core - paint_pool_soft, paint_pool_core + paint_pool_soft, x);
		lit = mix(lit * edge, ring * mix(paint_values.y, paint_values.z, core) * paint_pool_gain, fire);
		light_c = mix(LIGHT_COLOR, mix(vec3(paint_luma(LIGHT_COLOR)), LIGHT_COLOR, paint_pool_saturation), fire);
	}
	vec3 tint = mix(paint_shadow, vec3(1.0), smoothstep(paint_values.x, paint_values.z, lit));
	DIFFUSE_LIGHT += light_c * lit * tint / PI;
#ifdef PAINT_RIM
	// a faint warm rim on the edges turned from the eye, on the side the light reaches
	float rim = pow(1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0), paint_rim_power) * paint_rim;
	DIFFUSE_LIGHT += LIGHT_COLOR * ATTENUATION * paint_rim_color * rim * step(0.0, dot(NORMAL, LIGHT) + 0.3) / PI;
#endif
	// matte: a little shine, and only where the stone is smooth (the wet floor)
	float smooth_ = clamp(1.0 - ROUGHNESS, 0.0, 1.0);
	float h = max(dot(NORMAL, normalize(LIGHT + VIEW)), 0.0);
	SPECULAR_LIGHT += LIGHT_COLOR * ATTENUATION * pow(h, mix(8.0, 96.0, smooth_)) * smooth_ * smooth_ * paint_shine;
}
