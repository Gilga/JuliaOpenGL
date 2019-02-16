module Game

#module SCRIPT end

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
include("script.jl")
include("WindowManager.jl")
include("../scripts/scenes/test2.jl")

using .WindowManager
using .GraphicsManager
using .CameraManager
using .ScriptManager
using ..CodeManager

STARTTIME = time()
refTime = Ref(0.0)

ITERATION = 0
FRAMES = 0
MAX_FPS = 0

function OnFocus(window_ref, focus::Bool)
  window = WindowManager.getWindow(window_ref)
  window.focus = focus
end

""" TODO """
function getFrames()
  global ITERATION, FRAMES, MAX_FPS
  timer = time() #GetTimer("FRAME_TIMER")
  
  ITERATION +=1
  FRAMES += 1
  
  if !OnTime(1.0, refTime; time=timer) return nothing end
  
  FPS = FRAMES; FRAMES = 0
  FPMS = FPS > 0 ? (1000.0 / FPS) : 0
  if MAX_FPS < FPS MAX_FPS = FPS end
  MAX_FPMS = MAX_FPS > 0 ? (1000.0 / MAX_FPS) : 0
  NORM_FPS = FPS / MAX_FPS
  
  #FPS = FRAMES/(currenttime - PREVTIME)
  #PREVTIME = currenttime
  #if FPS > 15 COUNT += 1 end
 
  (ITERATION, FPS, FPMS, MAX_FPS, MAX_FPMS)
end

function createWindow()
  println("Create Window...")
  # remove previous Window
  GraphicsManager.cleanUp()
  GLFW.Terminate()
  
  # OS X-specific GLFW hints to initialize the correct version of OpenGL
  GLFW.Init()
  
  # Create a windowed mode window and its OpenGL context
  window = Window()

  # Make the window's context current
  GLFW.MakeContextCurrent(window.ref)

  # Window settings
  GLFW.SwapInterval(0) # intervall between canvas images (min. 2 images)
  
  # Graphcis Settings
  GLFW.WindowHint(GLFW.OPENGL_DEBUG_CONTEXT,true) #show debug
  #GLFW.WindowHint(GLFW.SAMPLES,4) #MSAA

  # OpenGL Version
  GLFW.WindowHint(GLFW.CONTEXT_VERSION_MAJOR,4)
  GLFW.WindowHint(GLFW.CONTEXT_VERSION_MINOR,6)
  
  # Event Hooks
  GLFW.SetWindowFocusCallback(window.ref, OnFocus)
  GLFW.SetCursorPosCallback(window.ref, OnCursorPos)
  GLFW.SetKeyCallback(window.ref, OnKey)
  GLFW.SetMouseButtonCallback(window.ref, OnMouseKey)

  #setEventCallbacks(OnCursorPos,OnKey,OnMouseKey)

  GLFW.ShowWindow(window.ref)
  
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

function cleanUp()
  info("cleanUp")
  GraphicsManager.cleanUp()
  GLFW.Terminate()
  #safe_clean!(:SCRIPT)
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

function script_init(window::Window)
  println("Include Script...")
  #include_module("scripts/scenes/test2.jl")
  args = Dict{Symbol,Any}()
  args[:WINDOW] = window
  
  println("Init Script...")
  #global script_OnUpdate = () -> script_call(script_function(:OnUpdate))
  #global script_OnRender = () -> script_call(script_function(:OnRender))
  
  #script_call(script_function(:main), args)
  #script_call(script_function(:OnInit))
  
  SCRIPT.main(args)
  SCRIPT.OnInit()
  global script_OnUpdate = SCRIPT.OnUpdate
  global script_OnRender = SCRIPT.OnRender
end

function reload(window::Window)
  println("Reload Script...")
  GraphicsManager.cleanUp() #remove all
  #safe_clean!(:SCRIPT)
  #script_init(window)
end

#function reload(script::ScriptManager.Script)
#  println("Reload Script...")
#  #if script.clean != nothing script.clean() end
#  GraphicsManager.cleanUp() #remove all
#  include("../scripts/$(script.name).jl")
#  script.init = ScriptManager.getFunction(SCRIPT.init, script.inputs)
#  script.update = ScriptManager.getFunction(SCRIPT.update)
#  script.render = ScriptManager.getFunction(SCRIPT.render)
#  #script.clean = ScriptManager.getFunction(SCRIPT.clean)
#end

TITLE = "Blocks Game"
BLOCK_COUNT = 0
CHUNK_SIZE = 0
SIZE = 0

function OnUpdatedKeys(window::Window)
  global TITLE, CHUNK_SIZE, BLOCK_COUNT
  frames = getFrames()
  if frames != nothing
    (ITERATION, FPS, FPMS, MAX_FPS, MAX_FPMS) = frames
    #Blocks $CHUNK_SIZE^3 ($BLOCK_COUNT)
    GLFW.SetWindowTitle(window.ref, "$(TITLE) - FPS $(round(FPS; digits=2))[$(round(MAX_FPS; digits=2))] | FMPS $(round(FPMS; digits=2))[$(round(MAX_FPMS; digits=2))] | IT $ITERATION")
  end

  keyValue, keyPressed = getKey()
  if keyPressed
    resetKeys()
    
    if keyValue == 82 #r
      reload(window)
      return false
    end
  end
  true
end

function run()
  println("---------------------------------------------------------------------")
  println("Start Program @ ", Dates.time())
  InteractiveUtils.versioninfo()
  
  window = createWindow()
  
  #ScriptManager.setReload(Game.reload)
  #script = ScriptManager.Script("scenes/test3")
  #ScriptManager.reload(script)
  #eval(:(module SCRIPT; include("../scripts/scenes/test2.jl"); end))
  script_init(window)
  
  while !GLFW.WindowShouldClose(window.ref)
    GLFW.PollEvents() # Poll for and process events
    OnUpdatedKeys(window)
    script_OnUpdate()
    script_OnRender()
    GLFW.SwapBuffers(window.ref)
  end
end

end #Game