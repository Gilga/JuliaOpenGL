layout (local_size_x = 128) in; //, local_size_y = 4, local_size_z = 4

#define COLSIZE 128 //128^1
#define ROWSIZE 16384 //128^2
#define MAXSIZE 2097152 //128^3

uniform sampler2D srcTex;

//float = 1 * 4 bytes 
// Never use a vec3 in a UBO or SSBO.
// https://stackoverflow.com/questions/38172696/should-i-ever-use-a-vec3-inside-of-a-uniform-buffer-or-shader-storage-buffer-o
struct InputData {
  float[3] index; //4*3
  float[6] next; //4*6
  float[2] flags; // 4*2
};

struct OutputData {
  float[3] pos; //4*3
  float[2] flags; // 4*2
};

// Can also do atomic operations on an SSBO.
// instanceCount in indirect draw buffer is found at offset = 4.
layout(binding = 0, offset = 0) uniform atomic_uint instanceCount;

layout(std430, binding = 0) buffer Input {
  InputData data[];
} inputset;

layout(std430, binding = 1) writeonly buffer Output {
  OutputData data[];
} outputset;

void synchronize()
{
    // Ensure that memory accesses to shared variables complete.
    memoryBarrierBuffer();
    memoryBarrierShared();
    groupMemoryBarrier();
    // Every thread in work group must reach this barrier before any other thread can continue.
    barrier();
}

#define SEED 43758.5453123
#define NUM_OCTAVES 5

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

float fbm ( in vec2 _st) {
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

float S = 1.0/128.0;
vec2 texSize = vec2(1024,1024);

float getLandscapeHeight(vec2 uv){
 return clamp(fbm(uv*3.0)*1.,0.0,1.0);// texture(srcTex, uv * texSize).r;
}

vec2 getTypeSide(vec3 index){
  float y = index.y * S;
  vec2 uv = index.xz * S;

  if(uv.x < 0 || uv.x >= 1 || uv.y < 0 || uv.y >= 1) return vec2(-1,0);

  vec4 next = vec4(uv.x-S,uv.x+S,uv.y+S,uv.y-S);
  vec2 nextTB = vec2(y+S,y-S);
  
  bool left = next.x >= 0 && next.x < 1;
  bool right = next.y >= 0 && next.y < 1;
  bool forward = next.z >= 0 && next.z < 1;
  bool back = next.w >= 0 && next.w < 1;
  bool top = nextTB.x >= 0 && nextTB.x < 1;
  bool bottom = nextTB.y >= 0 && nextTB.y < 1;
  
  float height = getLandscapeHeight(uv);
  uint sides=0;
  
  if(left) left = y <= getLandscapeHeight(vec2(next.x,uv.y));
  if(right) right = y <= getLandscapeHeight(vec2(next.y,uv.y));
  if(forward) forward = y <= getLandscapeHeight(vec2(uv.x,next.z));
  if(back) back = y <= getLandscapeHeight(vec2(uv.x,next.w));
  if(top) top = nextTB.x <= height;
  if(bottom) bottom = nextTB.y <= height;
  
  if(left && right && forward && back && top && bottom) return vec2(-1,0);
  
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
  
  float typ = 0;

  if (y <= height) {
    //if (y >= level_air) typ = 0; // air or nothing
    if (y <= level_lava) typ = 15; //lava
    else if (y <= level_stone) typ = 4; //stone
    else if (y <= level_stonebricks) typ = 5; //stonebricks
    else if (y <= level_dirt) typ = 1; //dirt
    else typ = 2; //grass
  }
  
  return vec2(typ,sides);
}

float DIST = 2;
float STARTDIST = (COLSIZE*DIST) / 2.0;
vec3 START = vec3(-1,-1,1)*STARTDIST;

vec3 translate(vec3 index) {
  return START+index*vec3(1,1,-1)*DIST;
}

bool is_visible(vec3 pos)
{
  if (frustum) {
    int result = checkSphere(pos, 1.5);
    if (result < 0) { return false; }
  }
  return true;
}

void main() {
  uint ident  = gl_GlobalInvocationID.x;
  
  if(ident == 0) atomicCounterExchange(instanceCount, 0);
  
  InputData data = inputset.data[ident];
  vec3 index =  vec3(data.index[0],data.index[1],data.index[2]);
  
  vec2 flags = getTypeSide(index);
  
  if (flags.x <= 0 || flags.y == 0) return;

  vec3 pos = translate(index);
  if (!is_visible(pos)) return;
  
  uint unique  = atomicCounterIncrement(instanceCount);
  float fpos[3] = float[3](pos.x,pos.y,pos.z);
  float fflags[2] = float[2](flags.x,flags.y);

  outputset.data[unique] = OutputData(fpos,fflags);
}