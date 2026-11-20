shader_type spatial;
// The pool of the light of Elun on the floor under a RewardShaft (vfx_pass_spec.md 6.2): a flat disc, light `pool` of the
// cap in the middle falling to nothing over a soft edge, laid over the floor (premultiplied, never past the cap), under
// the figures and the reliquary (depth test on). No real light: the room's lights do not change. Near the paladin it
// falls to near_keep, like the shaft.
render_mode unshaded, blend_premul_alpha, cull_disabled, depth_draw_never, shadows_disabled, fog_disabled;

global uniform vec3 hero_pos;

uniform vec3 color : source_color = vec3(1.0, 0.94, 0.82);
uniform float cap = 1.0;
uniform float strength = 1.0;
uniform float pool = 0.32;
// Its radius now against its full radius (opens from 0.6 when the light lands) and the soft edge (share of the radius).
uniform float open = 1.0;
uniform float soft = 0.3;
uniform float near_from = 2.8;
uniform float near_to = 2.3;
uniform float near_keep = 0.6;
uniform float compat_gain = 1.0;

varying vec3 axis_of;

void vertex() {
	axis_of = NODE_POSITION_WORLD;
}

void fragment() {
	// the plane is 2 x 2 round its middle (scaled to the pool's radius)
	float r = length(UV * 2.0 - 1.0) / max(open, 0.001);
	float disc = 1.0 - smoothstep(1.0 - soft, 1.0, r);
	float falloff = mix(1.0, 0.55, smoothstep(0.0, 1.0 - soft, r));
	float near = length(hero_pos.xz - axis_of.xz);
	float keep = mix(near_keep, 1.0, smoothstep(near_to, near_from, near));
	float share = pool * disc * falloff * strength * keep;
	vec3 light = color / max(max(color.r, max(color.g, color.b)), 0.0001) * cap * share * compat_gain;
	float peak = min(max(light.r, max(light.g, light.b)), cap);
	ALBEDO = light;
	ALPHA = clamp(peak / max(cap, 0.0001), 0.0, 1.0);
}
