shader_type spatial;
// A spike of emerald crystal breaking out of the floor (vfx_pass_spec.md V-09, the Judgement Cut; Fx.crystal_spike): a
// four-sided point on a CylinderMesh (top radius 0, its origin at its foot), lit faces of its own (one facet pale, the
// next deep, the edges a thin ivory-mint line), laid over what is behind (premultiplied) under `peak` (the screen's
// 226). `life` 0 to 1: it grows out in `grow` of it, holds, and from `shatter` on breaks from the tip down (Fx sprays the
// chips). Opens around the paladin where it stands between him and the camera (hero_pos, as the rift).
render_mode unshaded, blend_premul_alpha, cull_disabled, depth_draw_never, shadows_disabled, fog_disabled;

global uniform vec3 hero_pos;
uniform vec3 color : source_color = vec3(0.3, 1.0, 0.45);
uniform float peak = 0.8;
uniform float life = 0.0;
uniform float grow = 0.3;
uniform float shatter = 0.65;
uniform float height_m = 1.8;
uniform float deep = 0.32;
uniform float edge_pale = 0.4;
uniform vec2 hero_hole = vec2(0.6, 1.4);

varying vec3 local;
varying vec3 normal_local;

void vertex() {
	local = VERTEX;
	normal_local = NORMAL;
}

void fragment() {
	float up = clamp(local.y / max(height_m, 0.001), 0.0, 1.0);
	// breaking from the tip down after `shatter`
	float broken = smoothstep(shatter, 1.0, life);
	if (up > 1.0 - broken) discard;
	// facets: the side facing the key a pale crystal, the other deep
	float facet = step(0.0, normal_local.x + normal_local.z * 0.6);
	vec3 hue = color / max(max(color.r, max(color.g, color.b)), 0.0001);
	vec3 face = mix(hue * deep, mix(hue, vec3(1.0), 0.25), facet);
	// the edges between facets: where the normal turns, a thin pale line
	float turn = abs(fract(atan(normal_local.z, normal_local.x) / 6.28318 * 4.0 + 0.5) - 0.5);
	float edge = 1.0 - smoothstep(0.02, 0.06, turn);
	vec3 lit = mix(face, mix(hue, vec3(1.0), edge_pale), edge) * (0.65 + 0.35 * up);
	float top = max(lit.r, max(lit.g, lit.b));
	lit *= peak / max(top, 0.0001);
	float a = 0.92;
	// the paladin seen through it
	vec3 hero = (VIEW_MATRIX * vec4(hero_pos + vec3(0.0, 1.2, 0.0), 1.0)).xyz;
	if (hero.z < 0.0 && VERTEX.z > hero.z) {
		vec2 o = (VERTEX.xy / -VERTEX.z - hero.xy / -hero.z) * -hero.z / hero_hole;
		a *= mix(0.15, 1.0, smoothstep(0.5, 1.0, length(o)));
	}
	ALBEDO = lit * a;
	ALPHA = a;
}
