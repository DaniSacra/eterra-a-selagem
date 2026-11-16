shader_type spatial;
// An enemy's shot (cycle 10, BUG-006: the sorcerer's orb drawn in its raw HDR magic was a white ball with a big added
// glow, and four to six of them made a white cloud): a ball in the shooter's own hue, darker at its edge, a small
// paler heart, all under the glow threshold (Game.GLOW_THRESHOLD 1.3). One material for every shot of a kind; the
// hue is each shot's (instance uniform, Projectiles._tint: the magic colour with its largest channel at 1).
render_mode unshaded, cull_back, shadows_disabled;

instance uniform vec3 hue = vec3(0.53, 0.39, 1.0);
// The ball's light where it faces the eye and at its edge (a ball, not a disc).
uniform float body = 0.85;
uniform float edge = 0.3;
// The heart: its radius (share of the ball's), its light (its largest channel) and how far toward pale it goes.
uniform float heart_share = 0.3;
uniform float heart = 1.2;
uniform float heart_pale = 0.3;

void fragment() {
	float f = clamp(dot(NORMAL, VIEW), 0.0, 1.0);
	// the distance from the middle of the ball as the eye sees it (0 middle, 1 edge)
	float r = sqrt(max(1.0 - f * f, 0.0));
	vec3 c = hue * mix(edge, body, f * f);
	float in_heart = 1.0 - smoothstep(heart_share * 0.5, heart_share, r);
	ALBEDO = mix(c, mix(hue, vec3(1.0), heart_pale) * heart, in_heart);
}
