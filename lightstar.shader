shader_type canvas_item;
render_mode blend_mix;

uniform sampler2D noise : hint_albedo;
uniform float mid_slider : hint_range(0,1);
uniform float dim_slider : hint_range(0,1);
uniform float high_slider : hint_range(0,1);
uniform float dim_range_slider : hint_range(0.001,0.01);
uniform float mid_range_slider : hint_range(0.001,0.01);
uniform float high_range_slider : hint_range(0.001,0.01);

uniform vec4 dim_color : hint_color;
uniform vec4 mid_color : hint_color;
uniform vec4 high_color : hint_color;
uniform vec4 background_color : hint_color;
void fragment()
{
	//get coords and direction
	vec2 uv=UV;
	
	vec3 col = background_color.rgb;
	
	float noise_sample = texture(noise, uv).r;
	


	if (noise_sample < dim_slider && noise_sample > dim_slider - dim_range_slider) {
		col = dim_color.rgb;
	}
	if (noise_sample < mid_slider && noise_sample > mid_slider - mid_range_slider) {
		col = mid_color.rgb;
	}
	if (noise_sample < high_slider && noise_sample > high_slider - high_range_slider) {
		col = high_color.rgb;
	}

	
	
	COLOR = vec4(col,1);
	
	//COLOR = texture(noise1, uv);
}
	