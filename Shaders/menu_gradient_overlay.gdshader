shader_type canvas_item;

uniform vec4 top_color : source_color = vec4(0.02, 0.02, 0.05, 0.65);
uniform vec4 bottom_color : source_color = vec4(0.00, 0.00, 0.00, 0.15);

void fragment() {
	float t = clamp(UV.y, 0.0, 1.0);
	COLOR = mix(top_color, bottom_color, t);
}
