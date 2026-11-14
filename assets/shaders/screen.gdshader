shader_type canvas_item;
// Full screen pass: vignette, colour split on big hits, red edge when the paladin is hurt, and the impact frame
// (impact = 1 for a frame or two: the screen in flat black and white, the bright parts as white shapes on black).
uniform sampler2D screen : hint_screen_texture, filter_linear;
uniform float split = 0.0;
uniform float hurt = 0.0;
uniform float vignette = 0.55;
uniform float impact = 0.0;
// Slow motion: blur streaking out from the middle (0..1) and a lift of the bright parts.
uniform float radial = 0.0;
// Brightness above which a pixel turns white in the impact frame.
uniform float impact_threshold = 0.4;
uniform vec3 impact_dark : source_color = vec3(0.02, 0.015, 0.03);
uniform vec3 impact_light : source_color = vec3(1.0, 0.97, 0.92);

void fragment() {
	vec2 uv = SCREEN_UV;
	vec2 from_center = uv - 0.5;
	vec2 off = from_center * split * 0.012;
	vec3 c;
	c.r = texture(screen, uv + off).r;
	c.g = texture(screen, uv).g;
	c.b = texture(screen, uv - off).b;
	if (radial > 0.0) {
		// the middle stays sharp, the edges streak toward it (Hades II blurs from a quarter of the way out)
		vec3 acc = c;
		for (int i = 1; i < 8; i++) {
			acc += texture(screen, 0.5 + from_center * (1.0 - radial * 0.008 * float(i))).rgb;
		}
		c = mix(c, acc / 8.0, smoothstep(0.12, 0.45, length(from_center)));
		c += c * c * radial * 0.5;
	}
	float d = length(from_center * vec2(1.6, 1.0));
	float v = smoothstep(0.3, 0.95, d);
	c *= 1.0 - v * vignette;
	c = mix(c, vec3(0.7, 0.03, 0.05), v * hurt * 0.75);
	if (impact > 0.0) {
		float lum = dot(c, vec3(0.3, 0.55, 0.15));
		c = mix(impact_dark, impact_light, smoothstep(impact_threshold - 0.03, impact_threshold + 0.03, lum));
	}
	COLOR = vec4(c, 1.0);
}
