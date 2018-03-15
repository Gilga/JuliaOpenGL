# Create and initialize shaders
const VSH = """
$(get_glsl_version_string())

#define PI 3.14159265359
#define HALF (0.5 + 1/PI)
#define RADIUS (1 - 0.01/PI)

uniform float time = 1;
uniform mat4 mvp = mat4(1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1);

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
out vec4 $(vertexColor());

void main() {
$(vertexColor()) = getVertexColor(position,normalize(position));
gl_Position = $(useMVP())vec4(position, 1.0);
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

const GSH = """
$(get_glsl_version_string())

layout(triangles) in;
layout(line_strip, max_vertices=126) out; // 128 is hardware max

layout(location = 0) in vec4 vcolors[];
out vec4 vcolor;
//layout(location = 0) in Vertex vertex[];

uniform mat4 mvp = mat4(1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1);

void main()
{
  int max = $(countOfCubesInRow());
  int count = max*max*max;
  float dist = 2;
  float center = 0; //(max/2)*dist;
  
  float x=0,y=0,z=0;
  for(int c=0; c<count; ++c)
  {
    for(int i=0; i<gl_in.length(); ++i)
    {
      gl_Position = mvp * (gl_in[i].gl_Position + vec4(-center+x*dist,-center+y*dist,-center+z*dist,0));
      vcolor = vcolors[i];
      EmitVertex();
    }
    
    EndPrimitive();
    
    ++x;
    if(x>=max) {
      x=0; ++y;
      if(y>=max) {y=0; ++z;}
    }
  }
}
"""