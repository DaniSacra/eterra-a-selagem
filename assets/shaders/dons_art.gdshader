shader_type canvas_item;
// The Gifts medallion's painted pieces (docs/art/dons_medallion_spec.md 1 and 9): the ground (blurred and darkened,
// the placeholder) with the vignette toward its edges, and the hero's figure with a soft edge mask (the placeholder is
// a portrait on its own ground; the final cut-out has its own alpha and leaves `edge_fade` at 0).
uniform float blur = 0.0;
uniform float dark : hint_range(0.0, 2.0) = 1.0;
uniform float vignette : hint_range(0.0, 1.0) = 0.0;
uniform float edge_fade : hint_range(0.0, 0.5) = 0.0;
// 0..1: how far the colours go to the dusk amber (the placeholder ground is violet, which the spec forbids).
uniform float warm : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	vec4 c = texture(TEXTURE, UV);
	if (blur > 0.0) {
		c = vec4(0.0);
		float w = 0.0;
		for (int x = -2; x <= 2; x++) {
			for (int y = -2; y <= 2; y++) {
				float k = 1.0 / (1.0 + float(x * x + y * y));
				c += texture(TEXTURE, UV + vec2(float(x), float(y)) * blur) * k;
				w += k;
			}
		}
		c /= w;
	}
	float lum = dot(c.rgb, vec3(0.3, 0.55, 0.15));
	c.rgb = mix(c.rgb, vec3(1.0, 0.72, 0.45) * lum * 1.5, warm);
	float v = 1.0 - vignette * smoothstep(0.35, 1.0, length((UV - 0.5) * vec2(1.6, 1.0)) * 1.3);
	float e = 1.0;
	if (edge_fade > 0.0) {
		e = smoothstep(0.0, edge_fade, UV.x) * smoothstep(0.0, edge_fade, 1.0 - UV.x)
			* smoothstep(0.0, edge_fade, UV.y) * smoothstep(0.0, edge_fade, 1.0 - UV.y);
	}
	COLOR = vec4(c.rgb * dark * v, c.a * e);
}
