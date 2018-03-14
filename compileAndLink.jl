### COMPILE WITH GCC ###

# obtain the environment variable
env_path = abspath(dirname(@__FILE__))

# it MUST be declared as a `const` for `ccall` to work
const clibname = "mylibByGCC"
const optimizer = "JuliaOptimizer"

# write the C code inside a raw string
cfile = write_c_file(clibname)

# find gcc compiler
gcc = find_system_gcc()

# set paths
ENVS = compiler_setPaths(gcc,env_path)

# the path to store the C library file
const Clib = joinpath(env_path,clibname)

# compile the C code into a shared library
gcc_compile(gcc,cfile,Clib,ENVS)

### LINK LIB FUNCTIONS ###

function createLoop(index, array, func)
  cfunc = (x)->func(unsafe_pointer_to_objref(x))
  cLoopFunc = cfunction(cfunc, Void, Tuple{Ptr{Void},})
  ccall((:createLoop, optimizer),
  Ptr{Void},
  (Cuint,Ptr{Ptr{Void}},Cuint,Ptr{Void}),
  index,pointer(array),length(array),cLoopFunc)
end

function loopByIndex(index)
  ccall((:loopByIndex, optimizer),Void,(Cuint,),(index))
end

function loopByObject(pointer)
  ccall((:loopByObject, optimizer),Void,(Ptr{Void},),(pointer))
end

function prepareStaticLoop(x,a)
  f = cfunction(x, Void, Tuple{Ptr{Float32},})
  ccall((:prepare, optimizer),Void,(Ptr{Void},Ptr{Ptr{Void}},Cuint),f,pointer(a),length(a))
end

function staticloop()
  ccall((:loop, optimizer),Void,())
end