shader_type canvas_item;
render_mode unshaded;
 
uniform float width : hint_range(0.0, 16.0);
uniform vec4 outline_color : source_color;
 
uniform vec4 gray : source_color;
uniform vec4 white : source_color;
uniform vec4 color : source_color;

void fragment()
{
    vec2 size = vec2(width) / vec2(textureSize(TEXTURE, 0));
   
    vec4 sprite_color = texture(TEXTURE, UV);
	if (sprite_color == gray) {
		sprite_color = color - vec4(.4, .4, .4, 0);
	}
	if (sprite_color == white) {
		sprite_color = color;
	}

    float alpha = sprite_color.a;
    alpha += texture(TEXTURE, UV + vec2(0.0, -size.y)).a;
    alpha += texture(TEXTURE, UV + vec2(size.x, -size.y)).a;
    alpha += texture(TEXTURE, UV + vec2(size.x, 0.0)).a;
    alpha += texture(TEXTURE, UV + vec2(size.x, size.y)).a;
    alpha += texture(TEXTURE, UV + vec2(0.0, size.y)).a;
    alpha += texture(TEXTURE, UV + vec2(-size.x, size.y)).a;
    alpha += texture(TEXTURE, UV + vec2(-size.x, 0.0)).a;
    alpha += texture(TEXTURE, UV + vec2(-size.x, -size.y)).a;
   
    vec3 final_color = mix(outline_color.rgb, sprite_color.rgb, sprite_color.a);
    COLOR = vec4(final_color, clamp(alpha, 0.0, 1.0));
}