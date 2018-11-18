layout (local_size_x = 128) in; //, local_size_y = 4, local_size_z = 4

#define COLSIZE 128 //128^1
#define ROWSIZE 16384 //128^2
#define MAXSIZE 2097152 //128^3

//float = 1 * 4 bytes 
// Never use a vec3 in a UBO or SSBO.
// https://stackoverflow.com/questions/38172696/should-i-ever-use-a-vec3-inside-of-a-uniform-buffer-or-shader-storage-buffer-o
struct InputData {
  float[3] index; //4*3
  //float[6] next; //4*6
  float[2] flags; // 4*2
};

struct OutputData {
  float[3] pos; //4*3
  float[2] flags; // 4*2
};

// Can also do atomic operations on an SSBO.
// instanceCount in indirect draw buffer is found at offset = 4.
layout(binding = 0, offset = 0) uniform atomic_uint instanceCount;
layout(binding = 1, offset = 0) uniform atomic_uint MAX;

layout(std430, binding = 0) readonly buffer Input {
  InputData data[];
} inputset;

layout(std430, binding = 1) writeonly buffer Output {
  OutputData data[];
} outputset;

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
  
  if(ident >= atomicCounter(MAX)) return;
  
  InputData data = inputset.data[ident];
  if (data.flags[0] <= 0 || data.flags[1] == 0) return;

  if (!is_visible(vec3(data.index[0],data.index[1],data.index[2]))) return;
  
  uint unique  = atomicCounterIncrement(instanceCount);
  outputset.data[unique] = OutputData(data.index,data.flags);
}