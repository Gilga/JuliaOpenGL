#import "globals.glsl"

layout(location = 0) in Vertex v;
layout(location = 0) out vec4 outColor;

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
  if(v.flags.x < 0 || (iUseTexture && v.flags.y < 0)) { discard; return; } //discard
  //int glow = v.texindex==15;
  
  vec4 color = v.color; //vec4(0,0,0,1); //color.w = color.x*color.y*color.z;
  
  bool water = v.flags.y > 14;
  bool UseLight = iUseLight;
  bool UseTexture = iUseTexture && !water;

  if(UseTexture) {
    vec2 UV = getUV(v.pos.xyz)*0.25f;
    vec2 texUV = v.uvs.zw;
    
    // flip texture 
    UV.y=(1-UV.y);
    UV.x+=0.25f*texUV.x;
    UV.y+=-0.75f+0.25*texUV.y;
    UV = clamp(UV,0,1); // valid values otherwise might be break
    //UV = vec2(0,0);
      color = texture(tex, vec2(UV.y, UV.x));
  }
  
  if(UseLight){ //use phong?
    float lightAttenuation = 0.01f;
    float gammaAmount = 2.2f;
    float shininessCoefficient = 0;
  
    float alpha = radians(0);
    
    vec3 camPos = -iCamPos.xyz;
    
    light.color = vec4(1,1,1,1);
    light.energy = 1;
    light.position = vec3(sin(iTime)*0,100,cos(iTime)*0); //vec3(1000,500,-300); //vec3(sin(alpha),0,cos(alpha));
    light.diffuse = 1;
    light.specular = 1;

    material.emission = vec4(0,0,0,1); //vec4(glow?1:0,glow?0.5:0,0,1);
    material.ambient = vec4(0.0,0.0,0.0,1);
    material.diffuse = vec4(1.0,1.0,1.0,1);
    material.specular = vec4(1.0,1.0,1.0,1);
    material.shininess = 1;
     
    vec3 lightDir = light.position - v.world_center.xyz;
    float lightDist = length(lightDir);
      
    vec3 L = normalize(lightDir); // Direction of the light (from the fragment to the light)
    vec3 N = normalize(v.world_pos.xyz - v.world_center.xyz); //v.normal.xyz; //normalize(v.normal.xyz); // Normal of the computed fragment, in camera space
 
    float H = water ?  1 : clamp(dot(L, N), 0.0,1.0);
    float diffuseCoefficient = max(clamp(H,0,1), 0.0);
    
    vec3 ambient = vec3(0,0,0);
    vec3 diffuse = vec3(0,0,0);
    vec3 specular = vec3(0,0,0);
    vec3 emission = vec3(0,0,0);
    vec3 difSpec = vec3(0,0,0);
    
    // phong_weight
    if(diffuseCoefficient > 0.0)
    {
      if(light.diffuse > 0)
      {
        diffuse = material.diffuse.xyz * light.color.xyz * diffuseCoefficient * material.diffuse.w;
      }
      
      if(!water && light.specular > 0 && shininessCoefficient > 0 && material.shininess > 0)
      {
        vec3 E = normalize(camPos - v.world_center.xyz); //normalize(v.pos); // camera direction (towards the camera)
        vec3 R = reflect(-L, N); // Direction in which the triangle reflects the light
        float cosTheta = max(0.0f, clamp(dot(E, R), 0.0, 1.0)); //E, R, R, L
      
        float specularCoefficient = material.shininess > 0 ? pow( cosTheta, material.shininess * shininessCoefficient) : 0.0f;
        specular = material.specular.xyz * light.color.xyz * diffuseCoefficient * specularCoefficient * material.specular.w;
      }

      //attenuation
      float distanceToLight = 100.0/lightDist;
      if(distanceToLight <= 0.01) distanceToLight=0;
      float attenuation = 1  * clamp(distanceToLight,0.0,1.0); // / (1.0 + lightAttenuation * pow(distanceToLight,2));
      difSpec += (diffuse + specular) * attenuation * light.energy;
    }

    emission = material.emission.xyz; //* emission Intensity
    ambient = material.ambient.xyz; //* ambient Intensity
    
    // replace alpha
    //ambient = vec4(mix(bgcolor.xyz,ambient.xyz, ambient.w*0.0),1);
    
    vec3 all = (emission + ambient + difSpec) * gammaAmount;
    
    float a = 1.0/(lightDist*0.01);
    if(a<0.1) a = 0;
    if(water) { color=vec4(0,0,1,1-a); }
    
    color = vec4(pow(color.xyz * all, vec3(gammaAmount)),color.w);
    
    //if(!water) {
      float dist = distance(-iCamPos,v.world_center.xyz);
      float fogFactor = (dist/200.0); //smoothstep(0.0f, 9.0f, dist/25);
      float old_alpha = color.a;
      color = mix(color,vec4(0.25,0.25,0.25,0.0),clamp(pow(fogFactor,50),0,1));
      if(water)  color.a = old_alpha * color.a;
    //}
  }
  
  outColor = color;
}