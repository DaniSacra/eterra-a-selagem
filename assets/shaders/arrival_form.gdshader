shader_type spatial;
// The Guerreiro forming in the light of Elun (SW-O1, ArrivalScene): his own painting (the albedo and tint the body's
// material has) as a lit silhouette that grows from the floor up. Above `cut` (world meters) nothing is drawn; just under
// it a thin band of emerald light (the edge of the forming); `flash` is the one glow that stays in the beam, pulling the
// body toward ivory. Every colour is held under `cap` (the screen's ScreenTone ceiling), never white. Two-sided, as the
// model comes. Only ArrivalScene puts it on him, for 0.4 s, and takes it off.
render_mode unshaded, cull_disabled, shadows_disabled, fog_disabled;

uniform sampler2D albedo : source_color, filter_linear_mipmap;
uniform vec4 tint : source_color = vec4(1.0);
// World height (m) the body is drawn up to, the band under it, the painting's share of the light.
uniform float cut = 0.0;
uniform float band = 0.12;
uniform float body = 0.5;
uniform vec3 rim_color : source_color = vec3(1.0, 0.78, 0.34);
uniform vec3 ivory : source_color = vec3(1.0, 0.94, 0.82);
uniform float flash = 0.0;
uniform float flash_mix = 0.45;
uniform float cap = 0.8;

varying float world_y;

void vertex() {
	world_y = (MODEL_MATRIX * vec4(VERTEX, 1.0)).y;
}

void fragment() {
	if (world_y > cut) {
		discard;
	}
	vec3 paint = texture(albedo, UV).rgb * tint.rgb * body;
	float edge = 1.0 - smoothstep(0.0, band, cut - world_y);
	vec3 c = mix(paint, ivory * body, flash * flash_mix);
	c = mix(c, rim_color, edge * 0.85);
	float top = max(c.r, max(c.g, c.b));
	if (top > cap) {
		c *= cap / top;
	}
	ALBEDO = c;
}
