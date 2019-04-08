__precompile__(false)

module Game

## INCLUDES
include(joinpath(@__DIR__,"libs.jl"))

################################################################################

####################
# JULIA
####################
using InteractiveUtils #versioninfo
using Dates
using Distributed
using SharedArrays

####################
# PACKAGES
####################
using DataStructures #SortedDict
using Images
using ImageMagick
using JLD2
using StaticArrays
using ModernGL
using GLFW

####################
# CUSTOM
####################
#using ThreadManager
using TimeManager
using FileManager
using LogManager
using MathManager
using GraphicsManager
using DefaultModelData
using CameraManager
using FrustumManager
using ChunkManager
using MeshManager
using TextureManager
using ShaderManager
using CodeManager
using WindowManager

################################################################################

const Window = WindowManager.Window

WINDOW_FOCUS = true

function OnFocus(window::Window,focus::Number)
  global WINDOW_FOCUS = focus > 0 ? true : false
end

function createWindow()
  println("Create Window...")
  #GraphicsManager.cleanUp()

  window=WindowManager.Window()

  WindowManager.open(window,[
    :OPENGL_DEBUG_CONTEXT=>true,
    :CONTEXT_VERSION_MAJOR=>4,
    :CONTEXT_VERSION_MINOR=>6,
    #:SAMPLES=>4,
  ])

  WindowManager.setListener(window, :OnWindowFocus, OnFocus)
  WindowManager.setListener(window, :OnMousePos, OnCursorPos)
  WindowManager.setListener(window, :OnKey, OnKey)
  WindowManager.setListener(window, :OnMouseKey, OnMouseKey)

#=
  # remove previous Window
  GLFW.Terminate()
  # OS X-specific GLFW hints to initialize the correct version of OpenGL
  GLFW.Init()
  # Create a windowed mode window and its OpenGL context
  window_ref = GLFW.CreateWindow(100, 100, "")

  # Make the window's context current
  GLFW.MakeContextCurrent(window_ref)

  # Window settings
  GLFW.SwapInterval(0) # intervall between canvas images (min. 2 images)

  # Graphcis Settings
  GLFW.WindowHint(GLFW.OPENGL_DEBUG_CONTEXT,true) #show debug
  #GLFW.WindowHint(GLFW.SAMPLES,4) #MSAA

  # OpenGL Version
  GLFW.WindowHint(GLFW.CONTEXT_VERSION_MAJOR,4)
  GLFW.WindowHint(GLFW.CONTEXT_VERSION_MINOR,6)

  # Event Hooks
  GLFW.SetWindowFocusCallback(this.ref, OnFocus)
  GLFW.SetCursorPosCallback(this.ref, OnCursorPos)
  GLFW.SetKeyCallback(this.ref, OnKey)
  GLFW.SetMouseButtonCallback(this.ref, OnMouseKey)

  #setEventCallbacks(OnCursorPos,OnKey,OnMouseKey)

  GLFW.ShowWindow(this.ref)
  =#

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

"""
TODO
"""
function showFrames(this::Window)
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

  WindowManager.title(this,"$(TITLE) - FPS $(round(fps; digits=2))[$(round(max_fps; digits=2))] | FMPS $(round(fpms; digits=2))[$(round(max_fmps; digits=2))] - IT $ITERATION")
  FRAMES = 0
end

function cleanUp()
  info("cleanUp")
  GraphicsManager.cleanUp()
  WindowManager.cleanUp()
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

function script_init(window::Window)
  println("Include Script...")
  include_module(joinpath(@__DIR__,"../scripts/scenes/script.jl"))
  args = Dict{Symbol,Any}()
  args[:WINDOW] = window.ref

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

function OnUpdatedKeys(window::Window)
  keyValue, keyPressed = getKey()
  if keyPressed
    if keyValue == 88 #x
      reload(window)
      return false
    end
  end
end

function reload(window::Window)
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

  while WindowManager.isOpen(window)
    CameraManager.resetKeys()
    WindowManager.OnUpdateEvents() # Poll for and process events
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

  while WindowManager.isOpen(window)
    CameraManager.resetKeys()
    WindowManager.OnUpdateEvents() # Poll for and process events
    UpdateTimers()
    showFrames(window)
    if !WINDOW_FOCUS
      sleep(0.1)
    else
      OnUpdatedKeys(window)
      OnUpdate()
      OnRender()
      # Swap front and back buffers
      WindowManager.swap(window)
      #if SLEEP>0 Libc.systemsleep(SLEEP) end
      #sleep(SLEEP)
    end
  end

  #GLFW.DestroyWindow(window) #might bug sometimes
  cleanUp()
end

end #Game
