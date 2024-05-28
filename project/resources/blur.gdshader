shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

void fragment() {
	vec2 up = vec2(0.0, -SCREEN_PIXEL_SIZE.y);
	vec2 down = vec2(0.0, SCREEN_PIXEL_SIZE.y);
	vec2 left = vec2(-SCREEN_PIXEL_SIZE.x, 0.0);
	vec2 right = vec2(SCREEN_PIXEL_SIZE.x, 0.0);
	
	vec3 colour = vec3(0.0);
	colour += texture(screen_texture, SCREEN_UV).rgb;
	// /*
	colour += texture(screen_texture, SCREEN_UV + up + left).rgb;
	colour += texture(screen_texture, SCREEN_UV + up).rgb;
	colour += texture(screen_texture, SCREEN_UV + up + right).rgb;
	colour += texture(screen_texture, SCREEN_UV + left).rgb;
	colour += texture(screen_texture, SCREEN_UV + right).rgb;
	colour += texture(screen_texture, SCREEN_UV + down + left).rgb;
	colour += texture(screen_texture, SCREEN_UV + down).rgb;
	colour += texture(screen_texture, SCREEN_UV + down + right).rgb;
	
	colour += texture(screen_texture, SCREEN_UV + up*2.0 + left*2.0).rgb;
	colour += texture(screen_texture, SCREEN_UV + up*2.0 + left).rgb;
	colour += texture(screen_texture, SCREEN_UV + up*2.0).rgb;
	colour += texture(screen_texture, SCREEN_UV + up*2.0 + right).rgb;
	colour += texture(screen_texture, SCREEN_UV + up*2.0 + right*2.0).rgb;
	
	colour += texture(screen_texture, SCREEN_UV + up + left*2.0).rgb;
	colour += texture(screen_texture, SCREEN_UV + up + right*2.0).rgb;
	colour += texture(screen_texture, SCREEN_UV + left*2.0).rgb;
	colour += texture(screen_texture, SCREEN_UV + right*2.0).rgb;
	colour += texture(screen_texture, SCREEN_UV + down + left*2.0).rgb;
	colour += texture(screen_texture, SCREEN_UV + down + right*2.0).rgb;
	
	colour += texture(screen_texture, SCREEN_UV + down*2.0 + left*2.0).rgb;
	colour += texture(screen_texture, SCREEN_UV + down*2.0 + left).rgb;
	colour += texture(screen_texture, SCREEN_UV + down*2.0).rgb;
	colour += texture(screen_texture, SCREEN_UV + down*2.0 + right).rgb;
	colour += texture(screen_texture, SCREEN_UV + down*2.0 + right*2.0).rgb;
	
	colour /= 25.0;
	// */
	COLOR.rgb = colour;
}