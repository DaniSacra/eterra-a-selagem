shader_type spatial;
// The comet's landing (ArrivalScene, PT-25-7): a ring of warm light that runs out over the floor from the impact and
// thins as it goes, over a short glow in the middle. Drawn on one flat plane (the plane's UV 0..1 is the circle's
// diameter). `t` is 0 at the impact and 1 when the ring is spent; every colour is held under `cap` (the ScreenTone ceiling).
render_mode unshaded, blend_add, depth_draw_never, cull_disabled, shadows_disabled, fog_disabled;

uniform vec3 color : source_color = vec3(1.0, 0.78, 0.34);
uniform float t = 0.0;
uniform float cap = 0.85;
uniform float ring_width = 0.12;

void fragment() {
	vec2 p = UV * 2.0 - 1.0;
	float r = length(p);
	float run = 1.0 - pow(1.0 - clamp(t, 0.0, 1.0), 2.0);
	float edge = run;
	float w = ring_width * (1.0 - 0.6 * run);
	float ring = smoothstep(w, 0.0, abs(r - edge)) * (1.0 - run);
	float core = smoothstep(0.55, 0.0, r) * pow(1.0 - clamp(t, 0.0, 1.0), 2.0);
	float fade = smoothstep(1.0, 0.85, r);
	float a = clamp((ring * 0.9 + core * 0.8) * fade, 0.0, 1.0);
	ALBEDO = min(color * a, vec3(cap));
	ALPHA = 1.0;
}
