shader_type spatial;
// The Guerreiro in the stylized look (Eterra Stylized, STY-06; docs/art/stylized_spec.md 2.3, T18, T19, T21): the
// Meshy model's own painting, lit by the room's lights in the same three bands as the stone and the crowd
// (figure_bands), a body a step darker than the light floor (value), a warm rim from the torches (rim_*: the lightest
// edge on the screen) and the texture pulled toward its own average (flatten at mip flat_lod: the photographic noise goes,
// the patches of the painting stay). Matte: little specular, high roughness. Some of the painting is light everywhere
// (fill, HeroBody.FILL; the blink after a hit raises it, Player._show through HeroBody.set_fill) so he keeps his
// colours away from the torches. Only HeroBody puts it on him, and only in the stylized look: the classic hero keeps his
// StandardMaterial3D. The x-ray (xray.gdshader) reads albedo, fill, roughness and metallic from here; the flash, the
// glow, the curse and the x-ray passes ride on top of it as before (Player._prepare).
// Two-sided, as the model comes (its cloth is open).
render_mode cull_disabled, diffuse_lambert, specular_disabled;

uniform sampler2D albedo : source_color, filter_linear_mipmap;
uniform vec4 tint : source_color = vec4(1.0);
uniform float fill = 0.28;
uniform float roughness = 0.92;
uniform float metallic = 0.0;
uniform float specular = 0.12;
// How dark the body is drawn (1: as painted): under the floor's value, separated from it by the rim and the outline.
uniform float value = 0.85;
uniform float flatten = 0.35;
uniform float flat_lod = 3.0;
uniform vec3 rim_color : source_color = vec3(1.0, 0.82, 0.62);
uniform float rim_power = 3.2;
uniform float rim = 0.55;
// The rim is kept to the side the light comes from (the top of the head, the shoulders: view space, as the crowd's
// key) at rim_lit, rim_dark of it on the other side.
uniform vec3 rim_dir = vec3(-0.45, 0.75, 0.5);
uniform float rim_dark = 0.35;

#include "res://assets/shaders/figure_paint.gdshaderinc"

void fragment() {
	vec3 raw = texture(albedo, UV).rgb;
	vec3 c = figure_flatten(raw, textureLod(albedo, UV, flat_lod).rgb, flatten) * tint.rgb * value;
	ALBEDO = c;
	ROUGHNESS = roughness;
	METALLIC = metallic;
	SPECULAR = specular;
	float side = mix(rim_dark, 1.0, smoothstep(-0.2, 0.5, dot(NORMAL, normalize(rim_dir))));
	EMISSION = c * fill + rim_color * figure_rim(NORMAL, VIEW, rim_power) * rim * side;
}

void light() {
	// three bands of each light; past the terminator the lowest band fades out over a short ramp (a torch behind him
	// does not light his front)
	float ndl = dot(NORMAL, LIGHT);
	float band = figure_bands(ndl) * clamp(1.0 + ndl / 0.3, 0.0, 1.0);
	DIFFUSE_LIGHT += LIGHT_COLOR * ATTENUATION * band / PI;
}
