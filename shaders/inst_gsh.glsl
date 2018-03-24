layout(points) in;
layout(triangle_strip, max_vertices=24) out; // 128 is hardware max
//triangle_strip, line_strip

layout(location = 0) in Vertex iv[];
layout(location = 0) out Vertex ov;

uniform mat4 iMVP = mat4(1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1);
uniform float time = 1;

const vec3 cube[6][4] = {
  {vec3(1,1,1),vec3(1,1,-1),vec3(-1,1,1),vec3(-1,1,-1)},
  {vec3(-1,-1,1),vec3(-1,-1,-1),vec3(1,-1,1),vec3(1,-1,-1)},
  {vec3(1,1,-1),vec3(1,-1,-1),vec3(-1,1,-1),vec3(-1,-1,-1)},
  {vec3(-1,1,1),vec3(-1,-1,1),vec3(1,1,1),vec3(1,-1,1)},
  {vec3(-1,1,1),vec3(-1,1,-1),vec3(-1,-1,1),vec3(-1,-1,-1)},
  {vec3(1,-1,1),vec3(1,-1,-1),vec3(1,1,1),vec3(1,1,-1)}
  };
  
void createSide(Vertex v, int side)
{
  for(int i=0;i<4;++i) {
    v.pos=cube[side][i];
    v.normal = normalize(v.pos);
    v.color = getVertexColor(v.pos,v.normal, time);
    v.world_pos    = v.pos+v.world;
    v.world_normal = normalize(v.world_pos);
    
    ov = v;
    
    gl_Position = iMVP * (vec4(v.world+v.pos,1));
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
  uint sides = uint(floor(v.sides));
  
  if((sides & 0x1) > 0) createSide(v, 4);  // LEFT
  if((sides & 0x2) > 0) createSide(v, 5);  // RIGHT
  if((sides & 0x4) > 0) createSide(v, 0);  // TOP
  if((sides & 0x8) > 0) createSide(v, 1);  // BOTTOM
  if((sides & 0x10) > 0) createSide(v, 2);  // FRONT
  if((sides & 0x20) > 0) createSide(v, 3);  // BACK

}