shader_type spatial;
// Where an enemy's blow lands on the floor (vfx_pass_spec.md V-12, Fx.smoke_ring): a ring of dark carmine smoke with a
// torn edge that opens from the body to the warning's radius in `open_time` of its life, a dark middle, its inner rim
// in the shooter's colour under `cap` (the screen's 205), fading out. Laid over the floor (premultiplied): never a lit
// orange disc. `thin`: only a thin ring (a blow with another right after it, P2-C19a).
render_mode unshaded, blend_premul_alpha, cull_disabled, depth_draw_never, shadows_disabled, fog_disabled;

uniform vec3 color : source_color = vec3(1.0, 0.1, 0.2);
uniform vec3 smoke : source_color = vec3(0.07, 0.02, 0.03);
uniform float cap = 0.7;
uniform float life = 0.0;
uniform float thin = 0.0;
// V-15: 1 closes the ring from the radius in (an elite rising from inside it), 0 opens it from the body out
uniform float closing = 0.0;
uniform float open_time = 0.33;
// VFX pass review P2: wider (0.3, it was 0.22), a darker middle that stays longer and a brighter inner rim
uniform float band = 0.3;
uniform float torn = 0.35;
uniform float smoke_alpha = 0.7;
uniform float rim_light = 0.8;
uniform float middle_dark = 0.5;

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
	float d = length(p);
	float a = atan(p.y, p.x);
	float seed = fract(dot(NODE_POSITION_WORLD, vec3(0.31, 0.0, 0.17))) * 30.0;
	float opened = 1.0 - pow(1.0 - clamp(life / open_time, 0.0, 1.0), 3.0);
	float r = mix(mix(0.25, 0.92, opened), mix(0.95, 0.4, opened), closing);
	float w = mix(band, band * 0.35, thin);
	float n = noise(vec2(a * 4.0 + seed, d * 6.0 + life * 3.0)) - 0.5;
	float n2 = noise(vec2(a * 11.0 - seed, life * 5.0)) - 0.5;
	float off = d - r + n * torn * w * 2.0;
	float ring = 1.0 - smoothstep(0.0, w, abs(off));
	// the smoke drifts outward and thins as it ages; the inner rim burns in the colour, only while it opens
	float fade = 1.0 - smoothstep(0.35, 1.0, life);
	float body = ring * (0.75 + n2) * fade;
	float rim = (1.0 - smoothstep(0.0, w * 0.35, abs(off + w * 0.35))) * (1.0 - smoothstep(0.2, 0.6, life));
	// the middle stays dark a moment, never a filled disc
	float middle = (1.0 - smoothstep(r * 0.5, r, d)) * middle_dark * (1.0 - thin) * (1.0 - closing) * (1.0 - smoothstep(0.1, 0.7, life));
	vec3 hue = color / max(max(color.r, max(color.g, color.b)), 0.0001);
	vec3 light = smoke * body * smoke_alpha + hue * cap * rim_light * rim * fade;
	float peak = max(light.r, max(light.g, light.b));
	if (peak > cap) {
		light *= cap / peak;
	}
	if (body + rim + middle <= 0.01) discard;
	ALBEDO = light;
	ALPHA = clamp(max(body * smoke_alpha + middle, rim * rim_light), 0.0, 1.0);
}
