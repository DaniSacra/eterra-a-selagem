// The frame of a room turned on the floor (HUB-D, docs/design/hub_spec_art.md 2.1): the global frame_yaw (degrees,
// 0 everywhere but the hub, HubLook sets it to the camera's yaw) is how far the room's own axes are turned from the
// world's around the up axis, as a Node3D's Basis(Vector3.UP, yaw). The masonry's courses and the floor's slabs are
// laid in that frame (frame_in), so they run along the walls; at 0 both functions return their argument untouched
// (no arithmetic at all: every room but the hub is drawn exactly as before).
#ifndef FRAME_YAW_INC
#define FRAME_YAW_INC
global uniform float frame_yaw;

// A world direction or point on the floor (x, z) in the frame's axes.
vec2 frame_in(vec2 p) {
	if (frame_yaw == 0.0) {
		return p;
	}
	float a = radians(frame_yaw);
	float c = cos(a);
	float s = sin(a);
	return vec2(c * p.x - s * p.y, s * p.x + c * p.y);
}

// A direction of the frame (x, z) back in the world's axes.
vec2 frame_out(vec2 p) {
	if (frame_yaw == 0.0) {
		return p;
	}
	float a = radians(frame_yaw);
	float c = cos(a);
	float s = sin(a);
	return vec2(c * p.x + s * p.y, -s * p.x + c * p.y);
}
#endif
