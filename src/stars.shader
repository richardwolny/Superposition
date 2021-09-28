shader_type canvas_item;
render_mode blend_mix;



// Star Nest by Pablo Roman Andrioli

// This content is under the MIT License.

const int iterations = 17;
const float formuparam = 0.53;

//const int volsteps = 20;
const int volsteps = 15;
const float stepsize = 0.1;

const float zoom   =0.800;
const float tile   =0.850;
const float speed = 0.00001;

const float  brightness =0.0015;
const float  darkmatter =0.300;
const float  distfading =0.730;
const float  saturation = 0.850;


void fragment()
{
	//get coords and direction
	vec2 uv=UV;
	
	vec3 col = vec3(0,0,0);
	
	if (uv.x < .5 && uv.x > .5 - 0.001) {
		col = vec3(1,1,1);
	}
	
	COLOR = vec4(col,1);
}
	