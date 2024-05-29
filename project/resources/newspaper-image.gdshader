shader_type canvas_item;

uniform float gamma: hint_range(0.0, 3.0) = 1.5;
uniform vec4 col1: source_color = vec4(0.68, 0.48, 0.27, 1.0);
uniform vec4 col2: source_color = vec4(0.52, 0.39, 0.22, 1.0);
uniform vec4 col3: source_color = vec4(0.44, 0.33, 0.19, 1.0);
uniform vec4 col4: source_color = vec4(0.35, 0.26, 0.15, 1.0);
uniform vec4 col5: source_color = vec4(0.29, 0.21, 0.13, 1.0);

void fragment(){
	vec4 col = texture(TEXTURE, UV);
	col.r = pow(col.r, gamma);
	col.g = pow(col.g, gamma);
	col.b = pow(col.b, gamma);

	float dist1 = length(col - col1);
	float dist2 = length(col - col2);
	float dist3 = length(col - col3);
	float dist4 = length(col - col4);
	float dist5 = length(col - col5);

	float d = min(dist1,dist2);
	d = min(d,dist3);
	d = min(d,dist4);
	d = min(d,dist5);

	if (d == dist1) {col = col1;}
	if (d == dist2) {col = col2;}
	if (d == dist3) {col = col3;}
	if (d == dist4) {col = col4;}
	if (d == dist5) {col = col5;}

	COLOR = col;
}