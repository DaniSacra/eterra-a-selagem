shader_type canvas_item;
// SW-B1: the cards of the Blessing screen come apart when one is chosen. Noise by screen position (the same on every part of
// a card, so text, medallion and frame go together), a bright edge in the angel's colour where it is burning away.
uniform float progress : hint_range(0.0, 1.0) = 0.0;
uniform vec4 edge : source_color = vec4(1.0, 0.85, 0.5, 1.0);
uniform float grain = 5.0;

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

void fragment() {
	vec2 cell = floor(FRAGCOORD.xy / grain);
	// a slow sweep from the bottom up under the noise, so the card goes in a wave, not all at once
	float n = hash(cell) * 0.7 + clamp(FRAGCOORD.y / 1200.0, 0.0, 1.0) * 0.3;
	float t = progress * 1.3 - 0.15;
	float gone = step(n, t - 0.12);
	float burning = step(n, t) * (1.0 - gone);
	COLOR.rgb = mix(COLOR.rgb, edge.rgb, burning * 0.85);
	COLOR.a *= 1.0 - gone;
}
