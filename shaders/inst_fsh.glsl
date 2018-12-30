#import "globals.glsl"
#import "landscape.glsl"

#define DIST (1.0/(VOXEL_DIST*0.5))

precision highp sampler2DShadow;
precision highp sampler2D;

//layout(early_fragment_tests) in;
layout(location = 0) in Vertex v;
layout(location = 0) out vec4 outColor;

layout(binding = 0) uniform sampler2D iDepthMap;
layout(binding = 2) uniform sampler2D iTexturePack;
uniform int iDepth = 0;

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

float near = 0.1; 
float far  = 100.0; 
  
float LinearizeDepth(float depth) 
{
    float z = depth * 2.0 - 1.0; // back to NDC 
    return (2.0 * near * far) / (far + near - z * (far - near));	
}

void main() {
  if(v.flags.w < 0) { discard; return; } //discard
  //int glow = v.texindex==15;
  
  vec3 camPos = -iCamPos.xyz;
  vec4 color = v.color; //vec4(0,0,0,1); //color.w = color.x*color.y*color.z;
  
  bool UseLight = true; //iUseLight;
  bool UseTexture = false; //iUseTexture;
  
  vec2 texUV = v.uvs.zw;
  bool water = false;
  
  //float dist = abs(length(getUV(v.pos.xyz)-vec2(0.5)));
  //if(dist>0.5) discard;

  if(texUV.y >= 0) {
    float level = v.flags.w*0+0.5+sin(v.world_center.y/10.0)*-0.5;
    float typ = 0;
  
    //float level_air = height * 0.99;
    float level_grass = 0.95;
    float level_dirt = 0.9;
    float level_stonebricks = 0.6;
    float level_stone = 0.5;
    float level_lava =  0.2;
      
    //if (y >= level_air) typ = 0; // air or nothing
    if (level <= level_lava) { typ = 15; color = vec4(1,0,0,1); } //lava
    else if (level <= level_stone) { typ = 4; color = vec4(0.5,0.5,0.75,1); } //stone
    else if (level <= level_stonebricks) { typ = 5; color = vec4(0.25,0.25,0.5,1); } //stonebricks
    else if (level <= level_dirt) { typ = 1; color = vec4(0.75,0.5,0.5,1); } //dirt
    else { typ = 2; color = vec4(0,1,0,1); } //grass
    
    //typ *= (0.5+sin(v.world_center.x*(1.0/18.0)+iTime*0)*0.5);
    
    //water = typ > 14;
    if(water){ color = vec4(0,0,1,1); }
    
    if(UseTexture && !water){
      texUV = getTexUV(typ-1);
      vec2 UV = getUV(v.pos.xyz*DIST)*0.25f;
      
      // flip texture 
      UV.y=(1-UV.y);
      UV.x+=0.25f*texUV.x;
      UV.y+=-0.75f+0.25*texUV.y;
      UV = clamp(UV,0,1); // valid values otherwise might be break
      //UV = vec2(0,0);
      color = texture(iTexturePack, vec2(UV.y, UV.x));
    }
  }
  
  if(!UseTexture) color = vec4(vec3(0.5 + sin(v.world_center.x*(1.0/18.0))*0.5, 0.5 + sin(v.world_center.z*(1.0/18))*0.5,(0.5 + sin(v.world_center.y*(1.0/28.0)))),1);
  
  vec3 lightPos = vec3(sin(iTime)*100,70+sin(iTime*3)*30,cos(iTime)*100);
  vec3 lightDir = lightPos - v.world_center.xyz;
  float lightDist = length(lightDir);
  float H2 = clamp(dot(normalize(lightDir), normalize(v.world_pos.xyz - v.world_center.xyz)),0.0,1.0);
  float range = 1.0/(lightDist);
  
  if(UseLight){ //use phong?
    float lightAttenuation = 0.01f;
    float gammaAmount = 2.2f;
    float shininessCoefficient = 0;
  
    float alpha = radians(0);

    light.color = vec4(1,1,1,1);
    light.energy = 20;
    light.position = lightPos; //vec3(1000,500,-300); //vec3(sin(alpha),0,cos(alpha));
    light.diffuse = 1;
    light.specular = 1;

    material.emission = vec4(0.0,0.0,0.0,1.0); //vec4(glow?1:0,glow?0.5:0,0,1);
    material.ambient = vec4(0.0,0.0,0.0,1.0);
    material.diffuse = vec4(1.0,1.0,1.0,1.0);
    material.specular = vec4(1.0,1.0,1.0,1.0);
    material.shininess = 1;
     
    //vec3 lightDir = light.position - v.world_pos.xyz;
    //float lightDist = length(lightDir);
    //float range = 1.0/lightDist;
      
    vec3 L = normalize(lightDir); // Direction of the light (from the fragment to the light)
    vec3 N = normalize(v.world_pos.xyz - v.world_center.xyz); //v.normal.xyz; //normalize(v.normal.xyz); // Normal of the computed fragment, in camera space
 
    float H = water ?  1 : clamp(dot(L, N),0.0,1.0);
    float diffuseCoefficient = max(clamp(H,0.0,1.0),0.0);
    
    vec3 ambient = vec3(0,0,0);
    vec3 diffuse = vec3(0,0,0);
    vec3 specular = vec3(0,0,0);
    vec3 emission = vec3(0,0,0);
    vec3 difSpec = vec3(0,0,0);
    
    //attenuation
    float distanceToLight = 1.0/lightDist;
    //if(distanceToLight <= 0.01) distanceToLight=0;
    float attenuation = clamp(distanceToLight * light.energy,0.0,1.0); // / (1.0 + lightAttenuation * pow(distanceToLight,2));
    
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

      difSpec += (diffuse + specular) * attenuation;
    }

    emission = material.emission.xyz; //* emission Intensity
    ambient = material.ambient.xyz; //* ambient Intensity
    
    // replace alpha
    //ambient = vec4(mix(bgcolor.xyz,ambient.xyz, ambient.w*0.0),1);
    
    vec3 all = (emission + ambient + color.xyz*mix(difSpec,vec3(1),attenuation) + color.xyz*difSpec) * gammaAmount;
    color = vec4(all,color.w);
    
    if(water) {
      float a = 1.0/(lightDist*0.01);
      if(a<0.1) a = 0;
      color=vec4(0,0,1,1-a);
    }
    
    //color = vec4(pow(all, vec3(gammaAmount)),color.w)
    
    bool fog = false;
    
    if(fog) {
      float dist = distance(-iCamPos,v.world_center.xyz);
      float fogFactor = (dist/($CHUNK_SIZE*1.75)); //smoothstep(0.0f, 9.0f, dist/25);
      float old_alpha = color.a;
      color = mix(color,vec4(0.25,0.25,0.25,0.0),clamp(pow(fogFactor,10),0,1));
      if(water)  color.a = old_alpha * color.a;
    }
  }
  else color = vec4(vec3(color.xyz*range*100),color.w);
  
  if(iDepth == 1){
    float depth = gl_FragCoord.z;
    //depth = 1 - (1.0/(length(camPos - v.world_center.xyz)));
    vec2 duv = gl_FragCoord.xy / textureSize(iDepthMap,0);
    //float tdepth = texture(iDepthTexture, duv).x;
    float tdepth = texture(iDepthMap, duv).x + 0.00000003;
    //float tdepth = clamp(textureLod(iDepthMap, vec3(duv, 0), 1) + 0.00000003 ,0,1); //0.00000003 not sure why its needed
    if(tdepth<depth) discard;
    //else { depth = gl_FragCoord.z; }
    //gl_FragDepth = depth;
  }

  outColor = color;
}