shader_type canvas_item;

uniform vec2 centre = vec2(0.5, 0.5);
uniform float progress: hint_range(0.0, 1.0) = 0;

void fragment() {
	float aspect_ratio = SCREEN_PIXEL_SIZE.y / SCREEN_PIXEL_SIZE.x;
	vec2 pos = UV - centre;
	pos.x *= aspect_ratio;
	float dist = length(pos);
	if (dist < (1.0 - progress)) { 
		discard;
	}
}
