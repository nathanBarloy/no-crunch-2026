shader_type canvas_item;

uniform sampler2D screen_texture: hint_screen_texture;
uniform float glow_extension = 0.5;


void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec4 pixel_color = texture(TEXTURE, UV);
	vec4 glow_color = pixel_color;
	pixel_color.a = 0.5;
	!m:::::::::::m
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
