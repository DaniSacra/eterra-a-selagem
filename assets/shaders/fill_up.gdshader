shader_type canvas_item;
// PT28-8: an unavailable HUD slot is grey and its colour fills in from the bottom up, like a glass filling.
// Only the band y0..y1 (local pixels of the item, the slot's body) is touched; below the fill line the colour shows.
uniform float y0 = 0.0;
uniform float y1 = 1.0;
uniform float fill : hint_range(0.0, 1.0) = 0.0;
uniform float grey_dim : hint_range(0.0, 1.0) = 0.55;

varying float local_y;

void vertex() {
	local_y = VERTEX.y;
}

void fragment() {
	if (local_y >= y0 && local_y <= y1 && local_y < y1 - (y1 - y0) * fill) {
		float g = dot(COLOR.rgb, vec3(0.299, 0.587, 0.114));
		COLOR.rgb = vec3(g) * grey_dim;
	}
}
