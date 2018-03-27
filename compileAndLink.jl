@static if is_windows() using WinRPM end

function find_system_gcc()
    # On Windows, check to see if WinRPM is installed, and if so, see if gcc is installed
    @static if is_windows()
        try
            winrpmgcc = joinpath(WinRPM.installdir,"usr","$(Sys.ARCH)-w64-mingw32", "sys-root","mingw","bin","gcc.exe")
            if success(`$winrpmgcc --version`)
                return winrpmgcc
            end
        end
    end

    # See if `gcc` exists
    @static if is_unix()
        try
            if success(`gcc -v`)
                return "gcc"
            end
        end
    end

    error( "GCC not found on system: " * (is_windows() ? "GCC can be installed via `Pkg.add(\"WinRPM\"); WinRPM.install(\"gcc\")`" : "" ))
end

function gcc_compile(gcc,file,libname,env)
  gcc = find_system_gcc()
  C_cmd = setenv(`$gcc -fPIC -O3 -msse3 -xc -shared $file -Wl,-Bstatic -lopengl32 -o $(libname * "." * Libdl.dlext)`, env)
  run(C_cmd)
  
  if !(!isempty(libname) && Libdl.dlopen_e(libname) != C_NULL) # HAS LIB?
    error("Cannot open lib $(libname)!")
  end
end

function write_c_file(libname)
  # write the C code inside a raw string
  C_code = raw"""
  
	__declspec(dllexport) unsigned long NvOptimusEnablement = 0x00000001; // NVIDIA
	//__declspec(dllexport) int AmdPowerXpressRequestHighPerformance = 1; // AMD Radeon

  int add(unsigned int a, unsigned int b){
      return a+b;
  }
  """

  cfile = libname * ".c" 

  open(cfile, "w") do f
      print( f, C_code)
  end
  
  cfile
end

function compiler_setPaths(gcc,env_path)
  # set paths
  binary_path = dirname(gcc)
  inlcude_path = joinpath(abspath(binary_path,"../"),"include")
  lib_path = joinpath(abspath(binary_path,"../"),"lib")

  ENV2 = deepcopy(ENV)
  ENV2["CPATH"] = ""
  ENV2["LIBRARY_PATH"] = ""

  ENV2["PATH"] *= ";" * env_path
  ENV2["PATH"] *= ";" * binary_path

  ENV2["CPATH"] *= ";" * inlcude_path

  ENV2["LIBRARY_PATH"] *= ";" * env_path
  ENV2["LIBRARY_PATH"] *= ";" * binary_path
  ENV2["LIBRARY_PATH"] *= ";" * lib_path
  
  ENV2
end

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