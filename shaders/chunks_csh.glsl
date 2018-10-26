layout (local_size_x = 128) in; //, local_size_y = 4, local_size_z = 4

//float = 1 * 4 bytes 
// Never use a vec3 in a UBO or SSBO.
// https://stackoverflow.com/questions/38172696/should-i-ever-use-a-vec3-inside-of-a-uniform-buffer-or-shader-storage-buffer-o
struct Data {
  float[3] pos;
  float[2] flags;
};

// Can also do atomic operations on an SSBO.
// instanceCount in indirect draw buffer is found at offset = 4.
layout(binding = 0, offset = 0) uniform atomic_uint instanceCount;

layout(std430, binding = 0) readonly buffer Input {
  Data data[];
} inputset;

layout(std430, binding = 1) writeonly buffer Output {
  Data data[];
} outputset;

uint get_invocation()
{
  uint work_group = gl_WorkGroupID.x * gl_NumWorkGroups.y * gl_NumWorkGroups.z + gl_WorkGroupID.y * gl_NumWorkGroups.z + gl_WorkGroupID.z;
  return work_group * gl_WorkGroupSize.x * gl_WorkGroupSize.y * gl_WorkGroupSize.z + gl_LocalInvocationIndex; //gl_GlobalInvocationID
  //return gl_WorkGroupID.z * gl_NumWorkGroups.y * gl_NumWorkGroups.z + gl_GlobalInvocationID.y * gl_NumWorkGroups.y  + gl_GlobalInvocationID.x;
}

void synchronize()
{
    // Ensure that memory accesses to shared variables complete.
    memoryBarrierShared();
    // Every thread in work group must reach this barrier before any other thread can continue.
    barrier();
}

float XSIZE = 64;
float ZSIZE = 64*64;
float YSIZE = 64*64*64;

vec3 DIST = vec3(2,2,2);
vec3 START = vec3(-(XSIZE*DIST.x) / 2.0, -(XSIZE*DIST.y) / 2.0, (XSIZE*DIST.z) / 2.0);

vec3 translate(uint ident)
{
  float index = float(ident);
  
  float y = floor(index / ZSIZE);
  float sy = y*ZSIZE;
  
  float z = floor((index - sy) / XSIZE);
  float x = (index - sy - z*XSIZE);
  
  return vec3(START.x+x*DIST.x, START.y+y*DIST.y, START.z-z*DIST.z);
}

uint index(vec3 pos)
{
  vec3 indexes = (pos + vec3(-1, -1, 1) * START) / DIST;
  if(pos.x < 0 || pos.x > XSIZE || pos.z < 0 || pos.z > XSIZE || pos.y < 0 || pos.y > XSIZE) return uint(YSIZE);
  return uint(indexes.z*YSIZE + indexes.z*XSIZE + indexes.x);
}

bool isSeen(vec3 pos){
  uint ident = index(pos);
  if(ident >= YSIZE) return true;
  Data data = inputset.data[ident];
  return data.flags[0] < 0;
}

float hide(vec3 pos){
  uint sides=0;
  if(isSeen(pos + vec3(1,0,0))) sides |= (0x1 << 0);
  if(isSeen(pos + vec3(-1,0,0))) sides |= (0x1 << 1);
  if(isSeen(pos + vec3(0,0,1))) sides |= (0x1 << 2);
  if(isSeen(pos + vec3(0,0,-1))) sides |= (0x1 << 3);
  if(isSeen(pos + vec3(0,1,0))) sides |= (0x1 << 4);
  if(isSeen(pos + vec3(0,-1,0))) sides |= (0x1 << 5);
  return float(sides);
}

void main() {
  uint ident  = gl_GlobalInvocationID.x; //get_invocation();
  
  Data data = inputset.data[ident];
  
  vec3 pos =  translate(ident);
  
  if (data.flags[0] < 0) return;
  
  data.flags[1] = hide(pos);
  
  if (data.flags[1] < 0) return;
  
  data.pos[0] = pos.x; 
  data.pos[1] = pos.y; 
  data.pos[2] = pos.z;
  data.flags[1] = flags;
  
  uint unique  = atomicCounterIncrement(instanceCount);
  outputset.data[unique] = data; 
}