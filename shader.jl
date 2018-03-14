# Create and initialize shaders
const VSH = """
$(get_glsl_version_string())

#define PI 3.14159265359
#define HALF (0.5 + 1/PI)
#define RADIUS (1 - 0.01/PI)

uniform mat4 mvp = mat4(1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1);
uniform float time = 1;

vec4 getVertexColor(vec3 pos, vec3 normal)
{
	if(false) // pos.z != 0 skip planes
	{
		float len = dot(length(pos),length(normal)); // skip cubes and spheres
		if(len < RADIUS) pos = (pos + normal) * HALF; // model
	}
	
	vec3 color1 = (1-normal)*0.5;
	vec3 color2 = (1+normal)*0.5;
	vec3 color = mix(color1,color2, sin(time));
	
	return vec4(color,1.0);
}

in vec3 position;
out vec4 vcolor;

void main() {
vcolor = getVertexColor(position,normalize(position));
gl_Position = mvp * vec4(position, 1.0);
}
"""

const FSH = """
$(get_glsl_version_string())
in vec4 vcolor;
out vec4 outColor;
void main() {
outColor = vec4(vcolor.xyz,vcolor.x*vcolor.y*vcolor.z); //vec4(1.0, 1.0, 1.0, 1.0);
}
"""