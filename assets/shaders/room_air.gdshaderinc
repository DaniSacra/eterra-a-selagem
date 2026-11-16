// The room's mood on the far air (cycle 10, ART-008; RoomMood sets it, any scenery shader may follow it): room_air.rgb
// is the hue the depths turn to, room_air.a how far (0 = the scenery's own colours). The brightness is kept: only
// the hue moves, so the depths never go darker or brighter than the scenery made them.
global uniform vec4 room_air;

vec3 room_air_tint(vec3 c) {
	float luma = dot(c, vec3(0.3, 0.55, 0.15));
	float base = max(dot(room_air.rgb, vec3(0.3, 0.55, 0.15)), 0.001);
	return mix(c, room_air.rgb * (luma / base), clamp(room_air.a, 0.0, 1.0));
}
