layout(triangles) in;
layout(line_strip, max_vertices=126) out; // 128 is hardware max

layout(location = 0) in vec4 vcolors[];
out vec4 vcolor;
//layout(location = 0) in Vertex vertex[];

uniform mat4 mvp = mat4(1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1);

void main()
{
  int max = 3;
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