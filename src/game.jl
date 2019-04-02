module Game

## INCLUDES
println("Include libs.")
include("libs.jl")
include("cubeData.jl")
include("camera.jl")
include("frustum.jl")
include("chunk.jl")
include("mesh.jl")
include("texture.jl")
include("shader.jl")

using .GraphicsManager
using .DefaultModelData
using .CameraManager
using .FrustumManager
using .ChunkManager
using .MeshManager
using .TextureManager
using .ShaderManager
using ..CodeManager

WINDOW_FOCUS = true

function OnFocus(window, focus)
  global WINDOW_FOCUS = focus > 0 ? true : false
end

function createWindow()
  println("Create Window...")
  # remove previous Window
  GraphicsManager.cleanUp()
  GLFW.Terminate()
  
  # OS X-specific GLFW hints to initialize the correct version of OpenGL
  GLFW.Init()
      
  # Create a windowed mode window and its OpenGL context
  window = GLFW.CreateWindow(100, 100, "")

  # Make the window's context current
  GLFW.MakeContextCurrent(window)

  # Window settings
  GLFW.SwapInterval(0) # intervall between canvas images (min. 2 images)
  
  # Graphcis Settings
  GLFW.WindowHint(GLFW.OPENGL_DEBUG_CONTEXT,true) #show debug
  #GLFW.WindowHint(GLFW.SAMPLES,4) #MSAA

  # OpenGL Version
  GLFW.WindowHint(GLFW.CONTEXT_VERSION_MAJOR,4)
  GLFW.WindowHint(GLFW.CONTEXT_VERSION_MINOR,6)
  
  # Event Hooks
  GLFW.SetWindowFocusCallback(window, OnFocus)
  GLFW.SetCursorPosCallback(window, OnCursorPos)
  GLFW.SetKeyCallback(window, OnKey)
  GLFW.SetMouseButtonCallback(window, OnMouseKey)

  #setEventCallbacks(OnCursorPos,OnKey,OnMouseKey)

  GLFW.ShowWindow(window)
  
  GraphicsManager.init()

  glDebug(true) # set debugging

  glinfo = createcontextinfo()

  println("OpenGL $(stringColor(glinfo[:gl_version];color=:red))")
  println("GLSL $(stringColor(glinfo[:glsl_version];color=:red))")
  println("Vendor $(stringColor(glinfo[:gl_vendor];color=:red))")
  println("Renderer $(stringColor(glinfo[:gl_renderer];color=:red))")
  showExtensions()
  println("---------------------------------------------------------------------")
  sleep(0)
  
  window
end

SLEEP=0 #1f0/200
TITLE = "Blocks Game"
STARTTIME = time()
PREVTIME = STARTTIME
FRAMES = 0
MAX_FRAMES = 0
FPS = 0
MAX_FPS = 0
ITERATION = 0
REF_PREVTIME = Ref(0.0)

""" TODO """
function showFrames(window)
  global FRAMES, ITERATION, MAX_FRAMES, REF_PREVTIME, BLOCK_COUNT
  currenttime = time() #GetTimer("FRAME_TIMER")
  
  ITERATION +=1
  if !OnTime(1.0, REF_PREVTIME; time=currenttime) FRAMES += 1; return end

  #FPS = FRAMES/(currenttime - PREVTIME)
  #PREVTIME = currenttime
  #if MAX_FPS < FPS MAX_FPS = FPS end
  #if FPS > 15 COUNT += 1 end
  #fpms = FPS > 0 ? (1000.0 / FPS) : 0
  #max_fmps = MAX_FPS > 0 ? (1000.0 / MAX_FPS) : 0
  #norm_fps = FPS/MAX_FPS
  
  if MAX_FRAMES < FRAMES MAX_FRAMES = FRAMES end
  fps = FRAMES
  max_fps = MAX_FRAMES
  fpms = FRAMES > 0 ? (1000.0 / FRAMES) : 0
  max_fmps = MAX_FRAMES > 0 ? (1000.0 / MAX_FRAMES) : 0
  norm_fps = FRAMES / MAX_FRAMES
  
  GLFW.SetWindowTitle(window, "$(TITLE) - FPS $(round(fps; digits=2))[$(round(max_fps; digits=2))] | FMPS $(round(fpms; digits=2))[$(round(max_fmps; digits=2))] - IT $ITERATION")
  FRAMES = 0
end

function cleanUp()
  info("cleanUp")
  GraphicsManager.cleanUp()
  GLFW.Terminate()
  CodeManager.safe_clean!(@__MODULE__, :SCRIPT)
end

const EMPTY_FUNCTION = (args...) -> nothing

#script_call(name::Symbol, args...) = safe_eval(:(if isdefined(SCRIPT, Symbol($(string(name)))) SCRIPT.$name($(args...)); end))
function script_function(name::Symbol)
  result = safe_eval(:(isdefined(SCRIPT, Symbol($(string(name)))) ? SCRIPT.$name : nothing))
  if !result[1] || result[2] == nothing result = EMPTY_FUNCTION
  else result = result[2]
  end
  result
end

#script_function(name::Symbol) = eval(Meta.parse("SCRIPT.$name"))
const script_call = Base.invokelatest

script_OnUpdate = EMPTY_FUNCTION
script_OnRender = EMPTY_FUNCTION
OnUpdate = () -> script_call(script_OnUpdate)
OnRender = () -> script_call(script_OnRender)

function script_init(window)
  println("Include Script...")
  include_module("scripts/scenes/script.jl")
  args = Dict{Symbol,Any}()
  args[:WINDOW] = window
  
  println("Init Script...")
  global script_OnUpdate = script_function(:OnUpdate)
  global script_OnRender = script_function(:OnRender)
  
  script_call(script_function(:main), args)
  script_call(script_function(:OnInit))
  
  #SCRIPT.main(args)
  #SCRIPT.OnInit()
  #global script_OnUpdate = SCRIPT.OnUpdate
  #global script_OnRender = SCRIPT.OnRender
end

function OnUpdatedKeys(window)
  keyValue, keyPressed = getKey()
  if keyPressed
    if keyValue == 82
      reload(window)
      return false
    end
  end
end

function reload(window)
  println("Reload Script...")
  #script_call(script_function(:OnDestroy))
  #GraphicsManager.cleanUp() #remove all
  #CodeManager.safe_clean!(@__MODULE__, :SCRIPT)
  #safe_invoke(:(SCRIPT.free!))
  
  #waitTime = programTime() + 3
  #print("Wait...")
  #while programTime() <= waitTime
  #  GLFW.PollEvents()
  #  #glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT | GL_STENCIL_BUFFER_BIT)
  #  GLFW.SwapBuffers(window)
  #  if OnTime(1.0, REF_PREVTIME) print(".") end
  #end #wait
  #println()
  
  script_init(window)
  script_call(script_function(:OnReload))
end

function run2()
  println("---------------------------------------------------------------------")
  println("Start Program @ ", Dates.time())
  InteractiveUtils.versioninfo()
  
  window = createWindow()
  script_init(window)
  
  while !GLFW.WindowShouldClose(window)
    CameraManager.resetKeys()
    GLFW.PollEvents() # Poll for and process events
    UpdateTimers()
    showFrames(window)
    OnUpdatedKeys(window)
  end
end

function run()
  println("---------------------------------------------------------------------")
  println("Start Program @ ", Dates.time())
  InteractiveUtils.versioninfo()
  
  window = createWindow()
  script_init(window)
  
  while !GLFW.WindowShouldClose(window)
    CameraManager.resetKeys()
    GLFW.PollEvents() # Poll for and process events
    UpdateTimers()
    showFrames(window)
    if !WINDOW_FOCUS
      sleep(0.1)
    else
      OnUpdatedKeys(window)
      OnUpdate()
      OnRender()
      # Swap front and back buffers
      GLFW.SwapBuffers(window)
      #if SLEEP>0 Libc.systemsleep(SLEEP) end
      #sleep(SLEEP)
    end
  end

  #GLFW.DestroyWindow(window) #might bug sometimes
  cleanUp()
end

end #Game