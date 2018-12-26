#import "globals.glsl"
#import "landscape.glsl"

layout(points) in;
//layout(triangle_strip, max_vertices=24) out; // 128 is hardware max
layout(triangle_strip,max_vertices=24) out;
//triangle_strip, line_strip

layout(location = 0) in Vertex iv[];

const vec3 cube[6][4] = {
  {vec3(1,1,1),vec3(1,1,-1),vec3(-1,1,1),vec3(-1,1,-1)},
  {vec3(-1,-1,1),vec3(-1,-1,-1),vec3(1,-1,1),vec3(1,-1,-1)},
  {vec3(1,1,-1),vec3(1,-1,-1),vec3(-1,1,-1),vec3(-1,-1,-1)},
  {vec3(-1,1,1),vec3(-1,-1,1),vec3(1,1,1),vec3(1,-1,1)},
  {vec3(-1,1,1),vec3(-1,1,-1),vec3(-1,-1,1),vec3(-1,-1,-1)},
  {vec3(1,-1,1),vec3(1,-1,-1),vec3(1,1,1),vec3(1,1,-1)}
  };
  
// struct Data {
  // float[3] pos;
  // float type;
  // float sides;
  // float height;
// };

// layout(std430, binding = 0) buffer visibleBuffer {
  // Data visibles[];
// };

flat out int objid;
  
void createSide(Vertex v, int side)
{
  objid = int(v.flags.x);
  //visibles[objid].height = 1;

  for(int i=0;i<4;++i) {
    v.pos          = vec4(cube[side][i]*VOXEL_DIST*0.5,1);
    v.normal       = normalize(v.pos);
    gl_Position = iMVP * vec4(v.pos.xyz + v.world_center.xyz,1);
    EmitVertex();
  }
  //EndPrimitive();
}
  
void main()
{
  Vertex v = iv[0];
    
  //if(v.flags.w < 0) return; // discard
  
  uint sides = uint(floor(v.flags.z));
  if((sides & 0x1) > 0) createSide(v, 4);  // LEFT
  if((sides & 0x2) > 0) createSide(v, 5);  // RIGHT
  if((sides & 0x4) > 0) createSide(v, 0);  // TOP
  if((sides & 0x8) > 0) createSide(v, 1);  // BOTTOM
  if((sides & 0x10) > 0) createSide(v, 2);  // FRONT
  if((sides & 0x20) > 0) createSide(v, 3);  // BACK
}