const GLOBALSHC = "
$(get_glsl_version_string())

#define PI 3.14159265359
#define HALF (0.5 + 1/PI)
#define RADIUS (1 - 0.01/PI)
#define UVHALF 0.57735
#define UVFULL (1-0.000001)

struct Vertex
{
	vec3 pos;
	vec3 normal;
	vec2 uv;
	vec4 color;
  vec3 world;
	vec3 world_pos;
	vec3 world_normal;
  float texindex;
};

vec2 getUV(vec3 vertex)
{
	int i = 1;

	bool bag = i==0;
	bool cube = i==1;
	
	float dist = bag?0:cube?UVFULL:UVHALF;
	
	vec3 normal = normalize(vertex);
	normal = clamp(cube?vertex:normal,-1,1);
	
	float x = normal.x;
	float y = normal.y;
	float z = normal.z;
		
	vec2 uv = vec2(0);
	
	bool found = false;
	
	if (bag)
	{
		uv+=vec2(x,y);
		found=true;
	}
	else
	{
		bool fb = abs(z)>=dist;
		bool rl = abs(x)>=dist;
		bool ud = abs(y)>=dist;
		
		float u = x;
		float v = y;
		
		if(fb) u = (z>0?1:-1)*x;
		if(rl) u = (x>0?1:-1)*-z;
		if(ud) {u = x; v = -z;}
		
		uv+=vec2(u,v);
		found=true;
	}
	if(!found) return vec2(-1);
	
	uv = (1+uv)*0.5;
	uv = clamp(uv,0,1);
	
	return uv;
}

vec4 getVertexColor(vec3 pos, vec3 normal, float time)
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
"

# Create and initialize shaders
const VSH_INSTANCES = """
$(GLOBALSHC)

uniform float time = 1;
uniform mat4 mvp = mat4(1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1);

layout (location = 0) in vec3 position;
layout (location = 1) in vec4 instance;

out Vertex vertex;

void main() {
  vec3 world_pos = instance.xyz;
  float texindex = instance.w;
  
  vertex.pos = position;
  vertex.normal = normalize(vertex.pos);
  vertex.uv = vec2(0);
  vertex.color = getVertexColor(vertex.pos,vertex.normal, time);
  vertex.world=world_pos;
  vertex.world_pos = vertex.pos+world_pos;
  vertex.world_normal = normalize(vertex.world_pos);
  vertex.texindex = texindex;
  
  gl_Position = mvp*vec4(vertex.world_pos, 1.0);
  if(vertex.texindex == 0) { gl_Position = vec4(0,0,0,0); }
}
"""

const FSH_INSTANCES = """
$(GLOBALSHC)

in Vertex vertex;
out vec4 outColor;

uniform sampler2D tex;

struct iMaterial {
  vec4 emission;    // Ecm, 16
  vec4 ambient;     // Acm, 16   
  vec4 diffuse;     // Dcm, 16   
  vec4 specular;    // Scm, 16   
  float shininess;  // Srm, 4 
} material;

struct iLight {
  vec4 color;		// 16
  vec3 position;	// 16
  float energy;	// 4
  int diffuse;	// 4
  int specular;	// 4
} light;

void main() {
  if(vertex.texindex == 0) { discard; return; }
  
  vec4 color = vec4(0,0,0,1);
  int texindex = int(vertex.texindex-1);

  int tx = 0, ty = 0;
  for(int i=texindex; i>0; --i) {
    tx++; if(tx>=4) {
      tx=0; ty++;
      if(ty>=4) ty=0;
    }
  }
  
  vec2 UV = getUV(vertex.pos)*0.25f;
  UV.x+=0.25*tx;
  UV.y-=0.25*ty;
  
  //color = vertex.color; color = vec4(color.xyz,color.x*color.y*color.z);
  color = texture(tex, vec2((1-UV.y)-0.75, UV.x));
  
  if(false){ //use phong?
    float alpha = radians(0);
    
    light.color = vec4(1,1,1,1);
    light.energy = 1;
    light.position = vec3(1000,500,-300); //vec3(sin(alpha),0,cos(alpha));
    light.diffuse = 1;
    light.specular = 1;

    material.emission = vec4(texindex==15?1:0,texindex==15?0.5:0,0,1);
    material.ambient = vec4(0.1,0.1,0.1,1);
    material.diffuse = vec4(1.0,1.0,1.0,1);
    material.specular = vec4(0.25,0.25,0.25,1);
    material.shininess = 1;
    
    float lightAttenuation = 0.01f;
    float gammaAmount = 2.2f;
    float shininessCoefficient = 1;
  
    vec3 lightDist = (light.position - vertex.world_pos);
    vec3 L = normalize(lightDist); // Direction of the light (from the fragment to the light)
    vec3 N = normalize(vertex.world_normal); // Normal of the computed fragment, in camera space
    //N-=vertex.world*0.001f;
   
    float cosPhi = dot(L, N);
    float diffuseCoefficient = max(cosPhi, 0.0);
    
    vec3 ambient = vec3(0,0,0);
    vec3 diffuse = vec3(0,0,0);
    vec3 specular = vec3(0,0,0);
    vec3 emission = vec3(0,0,0);
    vec3 difSpec = vec3(0,0,0);
    
    emission = material.emission.xyz;
    ambient = material.ambient.xyz;
    
    emission = emission * material.emission.w;
    ambient = ambient * material.ambient.w;
    
    // replace alpha
    //ambient = vec4(mix(bgcolor.xyz,ambient.xyz, ambient.w*0.0),1);
    
    // phong_weight
    if(diffuseCoefficient > 0.0)
    {
      vec3 E = vec3(0,0,1); // camera direction (towards the camera)
      vec3 R = reflect(-L, N); // Direction in which the triangle reflects the light
      
      float cosTheta = max(0.0f, dot(E, R));
      float specularCoefficient = 1.0; //material.shininess > 0 ? pow( cosTheta, material.shininess * shininessCoefficient) : 0.0f;

      if(light.diffuse > 0)
      {
        diffuse = material.diffuse.xyz * light.color.xyz * diffuseCoefficient * material.diffuse.w;
      }
      
      if(light.specular > 0)
      {
        specular = material.specular.xyz * light.color.xyz * specularCoefficient * material.specular.w;
      }
      
      //attenuation
      float distanceToLight = 1/length(lightDist);
      float attenuation = 1.0 / (1.0 + lightAttenuation * pow(distanceToLight,2));
      
      difSpec += (diffuse + specular*0) * attenuation * light.energy;
    }
    
    vec3 all = (emission + ambient + difSpec) * gammaAmount;
    color = vec4(pow(color.xyz * all, vec3(gammaAmount)),color.w);
    
    //float fogFactor = smoothstep(0.0f, 9.0f, length(camFrag));
    //color = mix(color,vec4(1,0,0,1),fogFactor);
  
  }
  
  outColor = color;
}
"""

const VSH = """
$(GLOBALSHC)

uniform float time = 1;
uniform mat4 mvp = mat4(1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1);

layout (location = 0) in vec3 position;

out Vertex vertex;

void main() {
  vertex.pos          = position;
  vertex.normal       = normalize(vertex.pos);
  vertex.uv           = vec2(0);
  vertex.color        = getVertexColor(vertex.pos, vertex.normal, time);
  vertex.world        = vec3(0,0,0);
  vertex.world_pos    = vertex.pos+vertex.world;
  vertex.world_normal = normalize(vertex.world_pos);
  vertex.texindex     = 0;
  
  gl_Position = mvp*vec4(vertex.world_pos, 1.0);
}
"""

const FSH = """
$(GLOBALSHC)

in Vertex vertex;
out vec4 outColor;

void main() {
  vec4 color = vertex.color;
  color = vec4(color.xyz,color.x*color.y*color.z);
  outColor = color;
}
"""

const GSH = """
$(GLOBALSHC)

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