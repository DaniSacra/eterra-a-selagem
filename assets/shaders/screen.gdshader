shader_type canvas_item;
// Full screen pass: vignette, colour split on big hits, a tint at the edges when the paladin is hurt (red; the
// curse's violet under a boss's curse; HurtTint, numbers in Feel), and the impact frame
// (impact = 1 for a frame or two: the screen in flat black and white, the bright parts as white shapes on black).
uniform sampler2D screen : hint_screen_texture, filter_linear;
uniform float split = 0.0;
// Edge alpha of the red (a blow, low life) and of the curse's violet; the tint only lives toward the edges, between
// hurt_edge.x and hurt_edge.y of the distance from the middle (1 = the middle of a side), never on the fight.
uniform float hurt = 0.0;
uniform float curse = 0.0;
uniform vec3 hurt_color : source_color = vec3(0.7, 0.03, 0.05);
uniform vec3 curse_color : source_color = vec3(0.62, 0.32, 0.95);
uniform vec2 hurt_edge = vec2(0.5, 1.05);
uniform float vignette = 0.45;
// The vignette spares the highlights: it fades out between these two values of a pixel's brightest channel (fires,
// the portal and the banners keep their white core near the edges of the screen).
uniform float vignette_spare_from = 0.6;
uniform float vignette_spare_to = 1.0;
// Red and blue count less than green as a highlight: the white heart of a fire and the portal are spared, the wide
// orange halo round a fire and the violet glow of the abyss are not.
uniform vec3 vignette_spare_weight = vec3(0.7, 1.0, 0.7);
uniform float impact = 0.0;
// A flash of warm white added over the whole picture for a frame or two (Fx.screen_flash: Golpe Carregado, Apogeu, Brado, Supremo).
uniform float flash = 0.0;
// Slow motion: blur streaking out from the middle (0..1) and a lift of the bright parts.
uniform float radial = 0.0;
// The lift never takes a pixel past this (or past where it already was): the slow motion of the last kill took the
// reward's column, risen in that same instant, from 226 to 255 (GP-01 of cycle C12c: under 235 / 255).
uniform float lift_ceiling = 0.9;
// Brightness above which a pixel turns white in the impact frame.
uniform float impact_threshold = 0.4;
uniform vec3 impact_dark : source_color = vec3(0.02, 0.015, 0.03);
uniform vec3 impact_light : source_color = vec3(1.0, 0.97, 0.92);

void fragment() {
	vec2 uv = SCREEN_UV;
	vec2 from_center = uv - 0.5;
	// the colour split only shows toward the edges: nothing within 30% of the height from the middle
	float split_edge = smoothstep(0.3, 0.62, length(from_center * vec2(SCREEN_PIXEL_SIZE.y / SCREEN_PIXEL_SIZE.x, 1.0)));
	vec2 off = from_center * split * 0.012 * split_edge;
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
		c = min(c + c * c * radial * 0.5, max(c, vec3(lift_ceiling)));
	}
	float d = length(from_center * vec2(1.6, 1.0));
	float v = smoothstep(0.3, 0.95, d);
	vec3 lit = c * vignette_spare_weight;
	c *= 1.0 - v * vignette * (1.0 - smoothstep(vignette_spare_from, vignette_spare_to, max(lit.r, max(lit.g, lit.b))));
	float edge = smoothstep(hurt_edge.x, hurt_edge.y, d);
	c = mix(c, hurt_color, edge * clamp(hurt, 0.0, 1.0));
	c = mix(c, curse_color, edge * clamp(curse, 0.0, 1.0));
	if (impact > 0.0) {
		float lum = dot(c, vec3(0.3, 0.55, 0.15));
		c = mix(impact_dark, impact_light, smoothstep(impact_threshold - 0.03, impact_threshold + 0.03, lum));
	}
	c += vec3(1.0, 0.93, 0.8) * flash;
	COLOR = vec4(c, 1.0);
}
