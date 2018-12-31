#import "buffer.glsl"

precision highp float;
precision highp float;

#define COLSIZE $CHUNK1D_SIZE //?^1
#define ROWSIZE $CHUNK2D_SIZE //?^2
#define MAXSIZE $CHUNK3D_SIZE //?^3
#define LAST MAXSIZE-1
#define DISPATCHSIZE ROWSIZE

#define COLISIZE 1.0/COLSIZE
#define ROWISIZE 1.0/ROWSIZE
#define MAXISIZE 1.0/MAXSIZE

#define SEED 43758.5453123
#define NUM_OCTAVES 5

float VOXEL_DIST = 1;
float STARTDIST = (COLSIZE*VOXEL_DIST) / 2.0;
vec3 START = vec3(-1,-1,1)*STARTDIST;

layout(binding = 3) uniform sampler2D iHeightTexture;

struct MapData {
  float type;
  float sides;
  float height;
};

BuffData create(BuffData data, MapData flags) { return BuffData(data.pos,flags.type,flags.sides,flags.height); }

vec3 translate(vec3 index) { return START+index*vec3(1,1,-1)*VOXEL_DIST-vec3(0,STARTDIST,0); }

vec3 getIndex(uint index, uint lod) {
  float i = index;
  float y = floor(i*ROWISIZE);
  float height = y*ROWSIZE;
  float z = floor((i-height)*COLISIZE);
  float x = i-height-z*COLSIZE;
  return vec3(x,y,z);
}

float random (in float n) { return fract(sin(n)*43758.5453123); }
float random (in vec2 _st) { return fract(sin(dot(_st.xy,vec2(12.9898,78.233)))*43758.5453123); }

float noise (in vec2 _st) {
    vec2 i = floor(_st);
    vec2 f = fract(_st);

    // Four corners in 2D of a tile
    float a = random(i);
    float b = random(i + vec2(1.0, 0.0));
    float c = random(i + vec2(0.0, 1.0));
    float d = random(i + vec2(1.0, 1.0));

    vec2 u = f * f * (3.0 - 2.0 * f);

    return mix(a, b, u.x) +
            (c - a)* u.y * (1.0 - u.x) +
            (d - b) * u.x * u.y;
}

float fbm (in vec2 _st) {
    float v = 0.0;
    float a = 0.5;
    vec2 shift = vec2(100.0);
    // Rotate to reduce axial bias
    mat2 rot = mat2(cos(0.5), sin(0.5),
                    -sin(0.5), cos(0.50));
    for (int i = 0; i < NUM_OCTAVES; ++i) {
        v += a * noise(_st);
        _st = rot * _st * 2.0 + shift;
        a *= 0.5;
    }
    return v;
}

vec2 texSize = vec2(1.0/1024.0);

float createLandscapeHeight(vec2 uv) {
  return clamp(fbm(uv * 2),0.0,1.0);
}

float getLandscapeHeight(vec2 uv) {
 return clamp(fbm(uv*2),0.0,1.0);
 //return clamp(texture(iHeightTexture, uv).r,0.0,1.0);
}

  /*
  float typ = -1;
  
  //float level_air = height * 0.99;
  float level_grass = height * 0.95;
  float level_dirt = height * 0.9;
  float level_stonebricks = height * 0.6;
  float level_stone = height * 0.5;
  float level_lava = height * fbm(index.xz*0.002)*1.1;

  if (y <= height) {
    //if (y >= level_air) typ = 0; // air or nothing
    if (y <= level_lava) typ = 15; //lava
    else if (y <= level_stone) typ = 4; //stone
    else if (y <= level_stonebricks) typ = 5; //stonebricks
    else if (y <= level_dirt) typ = 1; //dirt
    else typ = 2; //grass
    
    float g = fbm(index.xz);
    if(g >= 0.8 && g <= 1.0) typ = 5;
    if(g >= 0.1 && g <= 0.2) typ = 4;
    if(y > level_dirt && g >= 0.3 && g <= 0.5) typ = 9;
  }
  
  if (y >= 0.33 && y <= 0.34 && typ == 0) {
    typ = 16;
    sides=4;
  }
  */


MapData getTypeSide2(vec3 index, uint lod){
  float slod = 1.0 / float(lod + 1);

  float S = COLISIZE;
  float y = index.y * S;
  vec2 uv = index.xz * S;

  //if(uv.x < 0 || uv.x >= 1 || uv.y < 0 || uv.y >= 1) return vec2(-1,0);

  vec4 next = vec4(uv.x-S,uv.x+S,uv.y+S,uv.y-S);
  vec2 nextTB = vec2(y+S,y-S);
  
  bool left = true; //next.x >= 0 && next.x < 1;
  bool right = true; //next.y >= 0 && next.y < 1;
  bool forward = true; //next.z >= 0 && next.z < 1;
  bool back = true; //next.w >= 0 && next.w < 1;
  bool top = true; //nextTB.x >= 0 && nextTB.x < 1;
  bool bottom = true; //nextTB.y >= 0 && nextTB.y < 1;
  
  float height = getLandscapeHeight(uv);
  float h = y/height;
  int typ=-1;
  uint sides=0;
  uint count=0;
  float lh = 0;
  float rh = 0;
  float fh = 0;
  float bh = 0;

  if(left) { lh=getLandscapeHeight(vec2(next.x,uv.y)); left = y <= lh; lh=height-lh; if(lh<0) lh=0; }
  if(right) { rh=getLandscapeHeight(vec2(next.y,uv.y)); right = y <= rh; rh=height-rh; if(rh<0) rh=0; }
  if(forward) { fh=getLandscapeHeight(vec2(uv.x,next.z)); forward = y <= fh; fh=height-fh; if(fh<0) fh=0; }
  if(back) { bh=getLandscapeHeight(vec2(uv.x,next.w)); back = y <= bh; bh=height-bh; if(bh<0) bh=0; }
  if(top) { top = nextTB.x <= height; }
  if(bottom) { bottom = nextTB.y <= height; }
  
  if(left && right && forward && back && top && bottom) return MapData(-1,0,-1);
  
  if(!left) { sides |= (0x1 << 0); count++; } // LEFT
  if(!right) {sides |= (0x1 << 1); count++; } // RIGHT
  if(!top) { sides |= (0x1 << 2);  count++; }// TOP
  if(!bottom) { sides |= (0x1 << 3);  count++; }// BOTTOM
  if(!forward) { sides |= (0x1 << 4);  count++; }// FRONT
  if(!back) { sides |= (0x1 << 5);  count++; } // BACK
  
  if((!bottom) && y>=0.41 && y<=0.42) { h=1; sides=127+4; }
  if (sides <= 0 || h>1) { h=-1; sides=0; }
  //else if ((y+S<height)) { h=-1; sides=0; }
  //else h = 1+max(max(lh,rh), max(fh,bh));
  else h=y;

  return MapData(typ,sides,h);
}

vec3 getTypeSide(vec3 index){
  float S = COLISIZE;
  float y = index.y * S;
  vec2 uv = index.xz * S;
  
  float height = getLandscapeHeight(uv);
  y = 1;

  //if(uv.x < 0 || uv.x >= 1 || uv.y < 0 || uv.y >= 1) return vec2(-1,0);

  vec4 next = vec4(uv.x-S,uv.x+S,uv.y+S,uv.y-S);
  vec2 nextTB = vec2(y+S,y-S);
  
  bool left = true; //next.x >= 0 && next.x < 1;
  bool right = true; //next.y >= 0 && next.y < 1;
  bool forward = true; //next.z >= 0 && next.z < 1;
  bool back = true; //next.w >= 0 && next.w < 1;
  bool top = true; //nextTB.x >= 0 && nextTB.x < 1;
  bool bottom = true; //nextTB.y >= 0 && nextTB.y < 1;
  
  uint sides=0;
  float typ = 0;
  
  if(left) left = y <= getLandscapeHeight(vec2(next.x,uv.y));
  if(right) right = y <= getLandscapeHeight(vec2(next.y,uv.y));
  if(forward) forward = y <= getLandscapeHeight(vec2(uv.x,next.z));
  if(back) back = y <= getLandscapeHeight(vec2(uv.x,next.w));
  if(top) top = nextTB.x <= height;
  if(bottom) bottom = nextTB.y <= height;
  
  if(left && right && forward && back && top && bottom) return vec3(-1,0,-1);
  
  if(!left) sides |= (0x1 << 0); // LEFT
  if(!right) sides |= (0x1 << 1); // RIGHT
  if(!top) sides |= (0x1 << 2); // TOP
  if(!bottom) sides |= (0x1 << 3); // BOTTOM
  if(!forward) sides |= (0x1 << 4); // FRONT
  if(!back) sides |= (0x1 << 5); // BACK
  
  //float level_air = height * 0.99;
  float level_grass = height * 0.95;
  float level_dirt = height * 0.9;
  float level_stonebricks = height * 0.6;
  float level_stone = height * 0.5;
  float level_lava = height * fbm(index.xz*0.002)*1.1;

  //if (y <= height) {
    //if (y >= level_air) typ = 0; // air or nothing
    if (y <= level_lava) typ = 15; //lava
    else if (y <= level_stone) typ = 4; //stone
    else if (y <= level_stonebricks) typ = 5; //stonebricks
    else if (y <= level_dirt) typ = 1; //dirt
    else typ = 2; //grass
    
    float g = fbm(index.xz);
    if(g >= 0.8 && g <= 1.0) typ = 5;
    if(g >= 0.1 && g <= 0.2) typ = 4;
    if(y > level_dirt && g >= 0.3 && g <= 0.5) typ = 9;
  //}
  
  if (y >= 0.33 && y <= 0.34 && typ == 0) {
    typ = 16;
    sides=4;
  }
  
  return vec3(typ,sides,height*COLSIZE);
}