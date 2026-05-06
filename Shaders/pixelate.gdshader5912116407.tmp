shader_type canvas_item;

uniform float Pixel_Size : hint_range(1, 64.0) = 1;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture;

void fragment() {
    vec2 screen_res = vec2(1.0) / SCREEN_PIXEL_SIZE;
    vec2 uv = SCREEN_UV;

    uv = floor(uv * screen_res / Pixel_Size) * Pixel_Size / screen_res;

    COLOR = texture(SCREEN_TEXTURE, uv);
}
