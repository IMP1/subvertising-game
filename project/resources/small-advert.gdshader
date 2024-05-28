shader_type canvas_item;

uniform float pixel_size: hint_range(1.0, 48.0) = 1.0;

void fragment() {
	vec2 size = vec2(textureSize(TEXTURE, 0));
	size /= pixel_size;
	vec2 uv = UV;
	uv = round(UV * size) / size;
	COLOR = texture(TEXTURE, uv);
}
