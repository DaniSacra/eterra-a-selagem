shader_type canvas_item;
// The title painting, contained on the screen. Where an edge meets a band (screens that are not 16:9) it melts into
// the blurred fill behind it instead of ending in a hard line.

// Fraction of the width and of the height that fades at both edges of that axis; 0 = the edge is the screen's edge.
uniform vec2 seam = vec2(0.0);
// Negative keeps the painting crisp when it is drawn a little smaller than its pixels (1280 wide: 77%); the mipmaps
// still take over on small windows.
uniform float lod_bias = -0.6;

// 0 at the edge, 1 at the end of the seam, most of the way early: the painting has figures right up to its edges
// (the cleric's cross 19 px from the top, the Emeth's tip 16 px from the bottom) and they must still read.
float rise(float t) {
	float left = 1.0 - clamp(t, 0.0, 1.0);
	return 1.0 - left * left;
}

void fragment() {
	vec2 edge = min(UV, 1.0 - UV);
	float a = 1.0;
	if (seam.x > 0.0) {
		a *= rise(edge.x / seam.x);
	}
	if (seam.y > 0.0) {
		a *= rise(edge.y / seam.y);
	}
	COLOR = vec4(texture(TEXTURE, UV, lod_bias).rgb, a);
}
