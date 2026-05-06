shader_type canvas_item;

uniform float intensity : hint_range(0.0, 1.0) = 0.08;
uniform float scale = 220.0;
uniform vec2 scroll_velocity = vec2(0.06, 0.02);
uniform float refresh_rate = 60.0;
uniform float seed = 1.0;

float hash(vec2 p, float t) {
	return fract(sin(dot(p, vec2(127.1, 311.7)) + t * 269.5 + seed) * 43758.5453123);
}

void fragment() {
	float frame_step = floor(TIME * refresh_rate);

	vec2 static_cell = floor(UV * scale);
	vec2 moving_cell = floor((UV + TIME * scroll_velocity) * (scale * 0.85));

	float static_noise = hash(static_cell, frame_step);
	float moving_noise = hash(moving_cell, frame_step + 31.0);

	float grain = mix(static_noise, moving_noise, 0.5);
	float alpha = grain * intensity;
	COLOR = vec4(vec3(1.0), alpha);
}
