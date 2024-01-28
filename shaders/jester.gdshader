shader_type canvas_item;
render_mode unshaded;

uniform vec4 gray_hat : source_color;
uniform vec4 gray_body : source_color;
uniform vec4 white_hat : source_color;
uniform vec4 white_body : source_color;


uniform vec4 color_hat : source_color;
uniform vec4 color_body : source_color;
 
void fragment()
{
    vec4 sprite_color = texture(TEXTURE, UV);
	if (sprite_color == gray_hat) {
		sprite_color = color_hat - vec4(.4, .4, .4, 0);
	}
	
	if (sprite_color == white_hat) {
		sprite_color = color_hat;
	}
	
	if (sprite_color == gray_body) {
		sprite_color = color_body - vec4(.4, .4, .4, 0);
	}
	if (sprite_color == white_body) {
		sprite_color = color_body;
	}
   
    COLOR = sprite_color;
}