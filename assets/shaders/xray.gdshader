shader_type spatial;
// The paladin seen through whatever stands in front of him: his own body again, lit as the body itself is (the same
// painting, the same lights and fill), only where something else covers him, so going behind an enemy or an obelisk
// does not change his colours (docs/art/cycle7_spec.md 3.2; he was a flat cyan ghost). Shadows are lifted a little
// (`floor_light`), never recoloured. Three passes on his meshes, drawn after everything else (Player.XRAY_PRIORITY):
// xray_depth lays his own depth in a layer right in front of the camera, this one paints the frontmost of his
// surfaces there, xray_edge draws the thin rim around them.
render_mode blend_mix, cull_back, depth_draw_always;

// His painted texture (white where a piece has none) times its colour.
uniform sampler2D albedo : source_color, hint_default_white, filter_linear_mipmap;
uniform vec4 tint : source_color = vec4(1.0);
uniform float roughness = 0.7;
uniform float metallic = 0.0;
// The painting as light, as on the body (HeroBody.FILL; Player raises both while he blinks after a hit).
uniform float fill = 0.28;
uniform float lighten = 0.0;
// The floor of light under a cover: what is painted darker than `dark_to` (its brightest channel) gets up to this
// much light in its own hue (in `dark`, a deep petrol, where the painting is too black to have one).
uniform float floor_light = 0.2;
// More of the painting as light under a cover (on top of `fill`): the same hues, a step brighter than the crowd
// in front of him.
uniform float cover_light = 0.25;
// His colours under a cover are this much purer than painted (1 is as painted): the only saturated body in the pack.
uniform float cover_pure = 1.2;
uniform vec4 dark : source_color = vec4(0.15, 0.4, 0.43, 1.0);
uniform float dark_to = 0.4;
uniform float opacity = 0.85;
// 0 hides the x-ray (--outline=0).
uniform float show = 1.0;
// A piece drawn without light (the pale edge of the blade): its colour times this, nothing else.
uniform float own_light = 0.0;
// Emeth's blade (emeth.gdshader, the same numbers): lit from inside from `blade_from` up (the model's height).
uniform float blade = 0.0;
uniform float blade_from = -0.1;
uniform vec3 blade_color : source_color = vec3(0.08, 0.85, 0.27);
uniform float blade_glow = 1.0;
uniform float blade_paint = 0.35;
// The painted light from the top left of the screen (flash.gdshader has the same, on the uncovered body).
uniform vec3 key_dir = vec3(-0.45, 0.75, 0.5);
uniform vec4 key : source_color = vec4(1.0, 0.93, 0.8, 0.0);
uniform sampler2D depth_tex : hint_depth_texture, filter_nearest;
// Meters something must stand in front of his frontmost surface to count as hiding him (his own body does not:
// xray_depth keeps only that surface).
uniform float hidden_by = 0.25;
// His vertices are drawn this many times closer to the camera: the same place on the screen, in front of the room.
const float LAYER = 0.05;

varying float along;

void vertex() {
	along = VERTEX.y;
	POSITION = PROJECTION_MATRIX * vec4((MODELVIEW_MATRIX * vec4(VERTEX, 1.0)).xyz * LAYER, 1.0);
}

void fragment() {
	float depth = texture(depth_tex, SCREEN_UV).r;
#if CURRENT_RENDERER == RENDERER_COMPATIBILITY
	vec3 ndc = vec3(SCREEN_UV, depth) * 2.0 - 1.0;
#else
	vec3 ndc = vec3(SCREEN_UV * 2.0 - 1.0, depth);
#endif
	vec4 scene = INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
	if (-scene.z / scene.w > -VERTEX.z - hidden_by) {
		discard;
	}
	vec3 paint = texture(albedo, UV).rgb * tint.rgb;
	paint = clamp(mix(vec3(dot(paint, vec3(0.299, 0.587, 0.114))), paint, cover_pure), 0.0, 1.0);
	float bright = max(paint.r, max(paint.g, paint.b));
	float on_blade = blade * smoothstep(blade_from, blade_from + 0.06, along);
	vec3 hue = mix(dark.rgb, paint / max(bright, 0.001), smoothstep(0.03, 0.15, bright));
	float lobe = max(dot(NORMAL, normalize(key_dir)), 0.0);
	vec3 light = paint * (fill + (cover_light + lighten) * (1.0 - on_blade))
		+ hue * floor_light * (1.0 - smoothstep(0.0, dark_to, bright)) * (1.0 - on_blade)
		+ mix(blade_color * bright, paint, blade_paint) * blade_glow * on_blade
		+ key.rgb * key.a * lobe * lobe * lobe * (1.0 - on_blade);
	float lit = step(own_light, 0.0);
	ALBEDO = paint * (1.0 - 0.5 * on_blade) * lit;
	ROUGHNESS = roughness;
	METALLIC = metallic * (1.0 - on_blade);
	SPECULAR = 0.5 * lit;
	// under 1: he reads, never blooms
	EMISSION = min(mix(paint * own_light, light, lit), vec3(0.95));
	ALPHA = opacity * show;
}
