shader_type canvas_item;
// Full screen pass: vignette, colour split on big hits, red edge when the paladin is hurt.
uniform sampler2D screen : hint_screen_texture, filter_linear;
uniform float split = 0.0;
uniform float hurt = 0.0;
uniform float vignette = 0.8;

void fragment() {
	vec2 uv = SCREEN_UV;
	vec2 from_center = uv - 0.5;
	vec2 off = from_center * split * 0.012;
	vec3 c;
	c.r = texture(screen, uv + off).r;
	c.g = texture(screen, uv).g;
	c.b = texture(screen, uv - off).b;
	float d = length(from_center * vec2(1.6, 1.0));
	float v = smoothstep(0.3, 0.95, d);
	c *= 1.0 - v * vignette;
	c = mix(c, vec3(0.7, 0.03, 0.05), v * hurt * 0.75);
	COLOR = vec4(c, 1.0);
}
