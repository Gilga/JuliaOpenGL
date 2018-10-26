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
  
  Data data = inputset.data[ident];
  
  vec3 pos =  vec3(data.pos[0],data.pos[1],data.pos[2]);
  
  if (!is_visible(pos) || data.flags[0] < 0 || data.flags[1] < 0) return;
  
  uint unique  = atomicCounterIncrement(instanceCount);
  outputset.data[unique] = data; 
}