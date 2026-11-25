shader_type spatial;
// An enemy's shot (vfx_pass_spec.md V-11: the dead's magic is the opposite of the paladin's light): a dark core
// (`ink`, core_share of the radius) with the shooter's hue only in a rim round it (rim, a little hotter in a thin band),
// never a bright ball. The crossbowman's bolt (needle 1, the ball stretched along its flight): a dark needle whose tip
// (the front third) burns in the hue. All under the screen's 210 (rim 0.21: ScreenTone.linear_peak of the magic hues at 210 is 0.21 to 0.24; at 0.48 the exposure and the saturation of the tone curve took the magenta to 248 and the carmine to 255). One material for every shot; the hue
// per shot (instance uniform, Projectiles._tint: the magic colour with its largest channel at 1).
render_mode unshaded, cull_back, shadows_disabled;

instance uniform vec3 hue = vec3(0.53, 0.39, 1.0);
instance uniform float needle = 0.0;
uniform vec3 ink : source_color = vec3(0.05, 0.02, 0.05);
uniform float rim = 0.21;
uniform float core_share = 0.6;
uniform float hot = 0.1;
uniform float core_tone = 0.5;

varying vec3 local;

void vertex() {
	local = VERTEX;
}

void fragment() {
	float f = clamp(dot(NORMAL, VIEW), 0.0, 1.0);
	// the distance from the middle of the ball as the eye sees it (0 middle, 1 edge)
	float r = sqrt(max(1.0 - f * f, 0.0));
	float ring = smoothstep(core_share - 0.12, core_share + 0.1, r);
	float band = 1.0 - smoothstep(0.0, 0.12, abs(r - core_share - 0.08));
	// the heart is the hue's own deep shade (sweep 2026-11-25: no black core), the rim and the band brighter
	vec3 orb = mix(hue * rim * core_tone, hue * rim, ring) + hue * rim * hot * band;
	// the needle: dark, its front burning
	float tip = smoothstep(0.35, 0.85, local.z / max(length(local), 0.0001));
	vec3 bolt = mix(hue * rim * core_tone * 0.6, hue * rim, tip) + hue * rim * hot * tip * f;
	ALBEDO = mix(orb, bolt, needle);
}
