#import "globals.glsl"
#import "landscape.glsl"

#define DIST VOXEL_DIST*0.5

layout(points) in;
layout(triangle_strip, max_vertices=24) out; // 128 is hardware max
//triangle_strip, line_strip

layout(location = 0) in Vertex iv[];
layout(location = 0) out Vertex ov;

const vec3 cube[6][4] = {
  {vec3(1,1,1),vec3(1,1,-1),vec3(-1,1,1),vec3(-1,1,-1)},
  {vec3(-1,-1,1),vec3(-1,-1,-1),vec3(1,-1,1),vec3(1,-1,-1)},
  {vec3(1,1,-1),vec3(1,-1,-1),vec3(-1,1,-1),vec3(-1,-1,-1)},
  {vec3(-1,1,1),vec3(-1,-1,1),vec3(1,1,1),vec3(1,-1,1)},
  {vec3(-1,1,1),vec3(-1,1,-1),vec3(-1,-1,1),vec3(-1,-1,-1)},
  {vec3(1,-1,1),vec3(1,-1,-1),vec3(1,1,1),vec3(1,1,-1)}
  };
  
void createPoint(Vertex v)
{
  ov = v;
  gl_Position = iMVP * v.world_pos;
  EmitVertex();
  EndPrimitive();
}
  
void createSide(Vertex v, int side)
{
  vec3 CameraRight_worldspace = vec3(iMVP[0][0], iMVP[1][0], iMVP[2][0]);
  vec3 CameraUp_worldspace = vec3(iMVP[0][1], iMVP[1][1], iMVP[2][1]);

  for(int i=0;i<4;++i) {
    v.pos          = vec4(cube[side][i]*DIST,1);
    //if((side == 2 && (i == 1 || i == 3)) || (side == 3 && (i == 1 || i == 3)) || (side == 4 && (i == 2 || i == 3)) || (side == 5 && (i == 0 || i == 1))) v.pos.y -= 100;
    v.normal       = normalize(v.pos);
    
    if(v.flags.y == 15) v.pos.y -= (0.5+(sin((v.pos.x+v.world_center.x)*0.1+(v.pos.z+v.world_center.z)*0.5+iTime*5))*0.5)*2;
    
    //vec3 vpos = (CameraRight_worldspace * v.pos.x + CameraUp_worldspace * v.pos.y * 0.6);
    
    v.color        = getVertexColor(v.pos.xyz, v.normal.xyz, 1);
    v.world_pos    = vec4(v.pos.xyz+v.world_center.xyz,1);
    v.world_normal = normalize(v.world_pos);

    ov = v;
    
    gl_Position = iMVP * v.world_pos;
    EmitVertex();
  }
  EndPrimitive();
}
  
void main()
{
  Vertex v;
  int i;
  int len = gl_in.length();
  
  /*
	for(i=0; i<len; ++i)
	{
    if (v.texindex < 0) continue;
    ov = v;
		gl_Position = iMVP * gl_in[i].gl_Position;
		EmitVertex();
	}
  EndPrimitive();
  */
  
  v = iv[0];
    
  if(v.flags.w < 0) return; // discard

  //createSide(v, 3);
  uint sides = uint(floor(v.flags.z));
  if((sides & 0x1) > 0) createSide(v, 4);  // LEFT
  if((sides & 0x2) > 0) createSide(v, 5);  // RIGHT
  if((sides & 0x4) > 0) createSide(v, 0);  // TOP
  if((sides & 0x8) > 0) createSide(v, 1);  // BOTTOM
  if((sides & 0x10) > 0) createSide(v, 2);  // FRONT
  if((sides & 0x20) > 0) createSide(v, 3);  // BACK
}