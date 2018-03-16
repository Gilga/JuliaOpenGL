using Images
include("lib_window.jl")
include("lib_opengl.jl")
include("lib_math.jl")
include("lib_time.jl")

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

TITLE = "Julia OpenGL"
STARTTIME = Dates.time()
PREVTIME = STARTTIME
FRAMES = 0
MAX_FRAMES = 0
FPS = 0
MAX_FPS = 0
ITERATION = 0
COUNT = 0

function UpdateCounters()
  UpdateTimers()
  showFrames()
end    

prevTime = Ref(0.0)
function showFrames()
  global TITLE, TIMERS, FRAMES, MAX_FRAMES, FPS, MAX_FPS, ITERATION, COUNT, PREVTIME
  
  time = Dates.time() #GetTimer("FRAME_TIMER")
  
  ITERATION +=1
  if !OnTime(1.0, prevTime, time) FRAMES += 1; return end

  #FPS = FRAMES/(time - PREVTIME)
  #PREVTIME = time
  #if MAX_FPS < FPS MAX_FPS = FPS end
  #if FPS > 15 COUNT += 1 end
  #fpms = FPS > 0 ? (1000.0 / FPS) : 0
  #max_fmps = MAX_FPS > 0 ? (1000.0 / MAX_FPS) : 0
  #norm_fps = FPS/MAX_FPS
  
  if MAX_FRAMES < FRAMES MAX_FRAMES = FRAMES end
  const fps = FRAMES
  const max_fps = MAX_FRAMES
  const fpms = FRAMES > 0 ? (1000.0 / FRAMES) : 0
  const max_fmps = MAX_FRAMES > 0 ? (1000.0 / MAX_FRAMES) : 0
  const norm_fps = FRAMES / MAX_FRAMES
  
  GLFW.SetWindowTitle(window, "$(TITLE) - FPS $(round(fps, 2)) Max[$(round(max_fps, 2))] | FMPS $(round(fpms, 2)) Max[$(round(max_fmps, 2))] - Iteration $(ITERATION) - Count $(COUNT)")
  FRAMES = 0
end