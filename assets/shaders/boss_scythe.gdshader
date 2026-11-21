shader_type spatial;
// Morvath's Sepulchral Scythe (Fx.boss_scythe): the blade sweeping across exactly the half circle it hurts, flat on
// the floor. The head is a line of blue-green across the whole radius (the blade); behind it a short trail of deep
// violet smoke, stronger toward the reach; the reach itself is a blue-green edge along the part swept. After the
// sweep everything breaks into ashes and fades. Drawn on Fx's ring-sector mesh: UV.x along the swing (0 start,
// 1 end), UV.y from the inner edge (near his feet) to the outer one (the reach of the blow): it never leaves it.
// t goes 0 -> 1 over its life; the head crosses during the first `sweep` of it.
// vfx_pass_spec.md V-16 (the same light and the same cyan edge as the paladin's cut): the violet of the body reaches the
// edge, gnawed by noise (gnaw_m deep at gnaw_scale_m, Fx gives reach_m); the head is a violet line, the palest is a
// lilac-ivory (`pale`) in the middle of the sector, never at its edge; nothing under hue 230 (`edge` is no longer
// drawn). Laid over the floor (premultiplied) under `peak` (226 on the screen).
render_mode unshaded, blend_premul_alpha, cull_disabled, depth_draw_never, shadows_disabled;

uniform vec4 body : source_color = vec4(0.62, 0.22, 1.2, 1.0);
uniform vec4 edge : source_color = vec4(0.38, 1.55, 1.1, 1.0);
uniform float t = 0.0;
uniform float sweep = 0.3;
// Share of the arc the trail covers behind the head.
uniform float tail = 0.35;
uniform bool flip = false;
uniform float intensity = 1.0;
// How bright the blade line and the rim are (above 1 they glow) and how strong the violet body is (kept under it).
uniform float blade_light = 1.0;
uniform float rim_light = 0.6;
uniform float body_light = 0.75;
uniform vec3 pale : source_color = vec3(0.8, 0.72, 0.95);
uniform float reach_m = 5.0;
uniform float band_m = 4.0;
uniform float gnaw_m = 0.15;
uniform float gnaw_scale_m = 0.4;
uniform float peak = 0.8;
uniform float smoke_alpha = 0.35;
// VFX review P2: the lilac-ivory middle reads (it was pale * fill * 0.4 and the sector came out one flat violet)
uniform float pale_light = 0.55;
// ART-05.4 (AP-2): the fill opens around the paladin standing in it (as the special's wave does, hero_hole): within
// hero_hole.x m of his feet it keeps hero_keep, back to all of it at hero_hole.y. Only the look: the area that hurts
// is the same sector.
global uniform vec3 hero_pos;
uniform vec2 hero_hole = vec2(0.7, 1.5);
uniform float hero_keep = 0.3;
varying vec3 world;

void vertex() {
	world = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
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
	float head = clamp(t / sweep, 0.0, 1.0);
	float along = flip ? 1.0 - UV.x : UV.x;
	float behind = head - along;
	if (behind < 0.0) discard;
	float rest = clamp((t - sweep) / max(1.0 - sweep, 0.001), 0.0, 1.0);
	float y = UV.y;
	// the ashes: pieces of what was swept go out one by one after the sweep
	float grain = noise(vec2(UV.x * 30.0, y * 8.0 - t * 2.0));
	if (grain < rest * 1.05) discard;
	float trail = 1.0 - smoothstep(0.0, tail, behind);
	// the reach gnawed by noise: the outer edge eaten up to gnaw_m in
	float along_m = UV.x * reach_m * 3.0;
	float gnaw = noise(vec2(along_m / gnaw_scale_m, t * 3.0)) * 0.7 + noise(vec2(along_m / (gnaw_scale_m * 0.4), 7.0)) * 0.3;
	float outer = 1.0 - gnaw * gnaw_m / max(band_m, 0.001);
	if (y > outer) discard;
	// the blade: a violet line across the radius at the head, only while it moves
	float blade = (1.0 - smoothstep(0.0, 0.03, behind)) * (1.0 - rest);
	// the rim: violet along the gnawed reach of what was swept
	float rim = (1.0 - smoothstep(0.0, 0.06, outer - y)) * (0.35 + 0.65 * trail);
	float smoke = 0.55 + 0.6 * noise(vec2(UV.x * 14.0 + t * 5.0, y * 4.0));
	float fill = mix(0.12, 0.8, y * y) * trail * smoke;
	vec3 violet = body.rgb / max(max(body.r, max(body.g, body.b)), 0.0001);
	// the palest in the middle of the band, never at the edge
	float middle = (1.0 - smoothstep(0.05, 0.22, abs(y - 0.55))) * trail;
	// the fill and the pale middle open around him; the rim and the blade line never (they are the shape)
	float keep = mix(hero_keep, 1.0, smoothstep(hero_hole.x, hero_hole.y, length(world.xz - hero_pos.xz)));
	vec3 c = violet * (fill * body_light * keep + rim * rim_light + blade * blade_light * 0.8) + pale * middle * pale_light * (0.6 + 0.4 * smoke) * keep;
	c *= (1.0 - rest) * intensity;
	float top = max(c.r, max(c.g, c.b));
	c *= min(1.0, peak / max(top, 0.0001));
	float cover = fill * smoke_alpha * (1.0 - rest) * keep;
	ALBEDO = vec3(0.04, 0.01, 0.06) * cover + c;
	ALPHA = clamp(cover + min(top, peak) / max(peak, 0.0001), 0.0, 1.0);
}
