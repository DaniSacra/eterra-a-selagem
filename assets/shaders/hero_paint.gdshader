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
uniform float value = 0.28;
uniform float flatten = 0.35;
// HB3 (2026-11-20): the paint pushed this much away from its own grey (the flattening and the warm rim greyed his
// petrol-green cloak: 0.6% of green round him on the GPU against 3.1% in the classic look, 1% asked)
uniform float saturation = 1.8;
// STY-10 (the art-director's STY-09, criterion 5): the painting's lightest patches (the cream lining of the cape) were
// the lightest of his body; above `top` of luma the painting is brought down to it (its hue kept), so the warm rim is
// his lightest edge (value 0.28 and rim 0.7 with it). 1: off.
uniform float top = 0.3;
uniform float flat_lod = 3.0;
// AD2-01 (art review 2026-11-25: the cape read 131; 158; 143, the room-5 floor 153; 148; 158): the painting's green zone
// (the cape; where green is above red and blue) is put on the petrol 3e9094, a body of cape_value of it (the painting's
// own luma keeps the folds), under the floor's light; his warm rim is cape_rim of itself there, so the cape is the dark
// shape and the rim the fine line that separates it.
uniform vec3 cape_color : source_color = vec3(0.2, 0.55, 0.64);
uniform float cape_value = 0.42;
uniform float cape_rim = 0.55;
// H-1 (art review 2026-11-25): the painting's dark browns and purples (the plates of chest, shoulders, bracers, greaves)
// are put on dark steel (steel_color, steel_value of it, the painting's luma keeps the relief), its gold patches on old
// gold; leather stays brown only on the belt band (belt_y0..belt_y1, model units of height) and the boots (under
// boot_y). Skin and the orange scarf stay as painted.
uniform vec3 steel_color : source_color = vec3(0.16, 0.18, 0.22);
uniform float steel_value = 1.0;
uniform vec3 gold_color : source_color = vec3(0.72, 0.52, 0.2);
uniform float gold_value = 0.8;
uniform float belt_y0 = 0.86;
uniform float belt_y1 = 0.98;
uniform float boot_y = 0.24;
// 1 for the Guerreiro (HeroBody sets it with cape_cut and cape_narrow); 0 leaves the painting alone (the Maga).
uniform float armor = 0.0;
// H-2: the cape cut above the knee (cape_cut: model units of height, 0 off) and narrowed to cape_narrow of its width.
uniform float cape_cut = 0.0;
uniform float cape_narrow = 1.0;
uniform vec3 rim_color : source_color = vec3(1.0, 0.82, 0.62);
uniform float rim_power = 3.2;
uniform float rim = 0.7;
// The rim is kept to the side the light comes from (the top of the head, the shoulders: view space, as the crowd's
// key) at rim_lit, rim_dark of it on the other side.
uniform vec3 rim_dir = vec3(-0.45, 0.75, 0.5);
uniform float rim_dark = 0.35;
// LC-4 (Compatibility renderer): there light reaches the screen without the desktop's linear-to-sRGB step (a value v
// shows as about v^2.2 of the desktop's), and his body, painted at value 0.28, went black inside the outline. gamma
// (HeroBody.COMPAT_GAMMA 0.55, only in that renderer) raises his albedo, each light and his own light to it by their
// luminance (figure_gamma), so he reads as on the desktop. 1 (Forward+): untouched.
uniform float gamma = 1.0;

#include "res://assets/shaders/figure_paint.gdshaderinc"

varying float local_y;
varying float cape_v;

void vertex() {
	local_y = VERTEX.y * 0.01;  // the skinned mesh space is in centimeters (the skeleton's), the model 180 of them
	// the cape's texels (green zone, as in fragment) are narrowed toward his spine plane
	vec3 t = textureLod(albedo, UV, 3.0).rgb;
	cape_v = smoothstep(0.015, 0.06, t.g - t.r) * (1.0 - smoothstep(0.0, 0.04, t.b - t.g - 0.02));
	VERTEX.x *= mix(1.0, cape_narrow, cape_v * step(0.001, cape_cut));
}

void fragment() {
	vec3 raw = texture(albedo, UV).rgb;
	vec3 c = figure_flatten(raw, textureLod(albedo, UV, flat_lod).rgb, flatten);
	float cape = smoothstep(0.015, 0.06, c.g - c.r) * (1.0 - smoothstep(0.0, 0.04, c.b - c.g - 0.02));
	if (cape_cut > 0.0 && cape > 0.5 && local_y < cape_cut) {
		discard;
	}
	float luma0 = dot(c, vec3(0.2126, 0.7152, 0.0722));
	float mx = max(c.r, max(c.g, c.b));
	float mn = min(c.r, min(c.g, c.b));
	float sat = (mx - mn) / max(mx, 0.001);
	float gold = smoothstep(0.35, 0.5, c.r) * smoothstep(0.3, 0.45, sat) * (1.0 - smoothstep(0.1, 0.25, c.b)) * smoothstep(0.1, 0.25, c.g / max(c.r, 0.001) - 0.45);
	float skin = smoothstep(0.45, 0.6, luma0) * smoothstep(0.02, 0.08, c.r - c.b);
	float orange = smoothstep(0.3, 0.45, c.r - c.b) * (1.0 - smoothstep(0.4, 0.6, c.g));
	float dark = (1.0 - cape) * (1.0 - gold) * (1.0 - skin) * (1.0 - orange);
	float leather = max(smoothstep(belt_y0 - 0.02, belt_y0, local_y) * (1.0 - smoothstep(belt_y1, belt_y1 + 0.02, local_y)), 1.0 - smoothstep(boot_y, boot_y + 0.03, local_y));
	float steel = dark * (1.0 - leather) * armor;
	float paint_luma = dot(c, vec3(0.2126, 0.7152, 0.0722));
	float grey = dot(c, vec3(0.2126, 0.7152, 0.0722));
	c = max(mix(vec3(grey), c, saturation), vec3(0.0));
	c *= min(1.0, top / max(dot(c, vec3(0.2126, 0.7152, 0.0722)), 0.0001));
	c *= tint.rgb * value;
	c = mix(c, cape_color * clamp(paint_luma / 0.12, 0.6, 1.3) * cape_value * tint.rgb, cape);
	c = mix(c, steel_color * clamp(luma0 / 0.12, 0.6, 1.5) * steel_value * tint.rgb, steel);
	c = mix(c, gold_color * clamp(luma0 / 0.45, 0.7, 1.2) * gold_value * tint.rgb, gold * (1.0 - leather) * armor);
	ALBEDO = c;
	ROUGHNESS = roughness;
	METALLIC = metallic;
	SPECULAR = specular;
	float side = mix(rim_dark, 1.0, smoothstep(-0.2, 0.5, dot(NORMAL, normalize(rim_dir))));
	EMISSION = c * fill + rim_color * figure_rim(NORMAL, VIEW, rim_power) * rim * side * mix(1.0, cape_rim, cape);
	if (gamma != 1.0) {
		ALBEDO = figure_gamma(ALBEDO, gamma);
		EMISSION = figure_gamma(EMISSION, gamma);
	}
}

void light() {
	// three bands of each light; past the terminator the lowest band fades out over a short ramp (a torch behind him
	// does not light his front)
	float ndl = dot(NORMAL, LIGHT);
	float band = figure_bands(ndl) * clamp(1.0 + ndl / 0.3, 0.0, 1.0);
	vec3 lit = LIGHT_COLOR * ATTENUATION * band / PI;
	DIFFUSE_LIGHT += gamma != 1.0 ? figure_gamma(lit, gamma) : lit;
}
