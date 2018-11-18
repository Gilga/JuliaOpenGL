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
  
  vec4 color = vec4(0,0,0,1);
  
  bool UseLight = iUseLight;
  bool UseTexture = iUseTexture;

  if(!UseTexture) color = v.color; //color.w = color.x*color.y*color.z;
  else {
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
    float alpha = radians(0);
    
    light.color = vec4(1,1,1,1);
    light.energy = 1;
    light.position = vec3(-3,0,0); //vec3(1000,500,-300); //vec3(sin(alpha),0,cos(alpha));
    light.diffuse = 1;
    light.specular = 1;

    material.emission = vec4(0,0,0,1); //vec4(glow?1:0,glow?0.5:0,0,1);
    material.ambient = vec4(0.1,0.1,0.1,1);
    material.diffuse = vec4(1.0,1.0,1.0,1);
    material.specular = vec4(0.25,0.25,0.25,1);
    material.shininess = 1;
    
    float lightAttenuation = 0.01f;
    float gammaAmount = 2.2f;
    float shininessCoefficient = 1;
    
    vec3 E = - vec3(0,0,0); //normalize(v.pos); // camera direction (towards the camera)
    
    vec3 lightDir = (light.position - v.world_center.xyz);
    float lightDist = length(lightDir);

    vec3 L = normalize(lightDir); // Direction of the light (from the fragment to the light)
    vec3 N = normalize(v.normal.xyz); // Normal of the computed fragment, in camera space
   
    float H = dot(L, N);

    float cosPhi = clamp(H,0,1);
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
      vec3 R = reflect(-L, N); // Direction in which the triangle reflects the light

      float cosTheta = max(0.0f, clamp(dot(R, L), 0.0, 1.0)); //E, R
      
      //float rdl = pow(cosTheta, 32.0);
      //vec4 d = mix(vec4(0.0,0.0,0.0,0.0), vec4(0.0,1.0,0.0,1.0), cosPhi);
      //vec4 s = mix(vec4(0.0,0.0,0.0,0.0), vec4(1.0,1.0,1.0,1.0), rdl);
      
      float specularCoefficient = material.shininess > 0 ? pow( cosTheta, material.shininess * shininessCoefficient) : 0.0f;

      if(light.diffuse > 0)
      {
        diffuse = material.diffuse.xyz * light.color.xyz * diffuseCoefficient * material.diffuse.w;
      }
      
      if(light.specular > 0)
      {
        specular = material.specular.xyz * light.color.xyz * specularCoefficient * material.specular.w;
      }
      
      //attenuation
      float distanceToLight = 1/(1.0 + pow(lightDist,2)*0.0001);
      float attenuation = 1 * distanceToLight; // / (1.0 + lightAttenuation * pow(distanceToLight,2));
      
      difSpec += (diffuse + specular*0) * attenuation * light.energy;
    }
    
    vec3 all = (emission + ambient + difSpec) * gammaAmount;
    color = vec4(pow(color.xyz * all, vec3(gammaAmount)),color.w);
    
    //float fogFactor = smoothstep(0.0f, 9.0f, length(camFrag));
    //color = mix(color,vec4(1,0,0,1),fogFactor);
  
  }
  
  outColor = color;
}