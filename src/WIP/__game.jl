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
include("script.jl")
include("JLScriptManager.jl")

using .GraphicsManager
using .CameraManager
using .ScriptManager
using .JLScriptManager

""" TODO """
mutable struct ScriptRefs <: JLComponent
	WINDOW::Union{Nothing, GLFW.Window}
	ScriptRefs() = new(nothing)
end

""" TODO """
mutable struct ScriptState <: JLComponent
end

WINDOW = nothing

function create(id::Symbol, path::String)
  script = JLScript(id, path)
  script.state = ScriptState()
  script.objref = ScriptRefs()
  script.objref.WINDOW = WINDOW
  
  list=Dict{Symbol,Function}(
    :reload => function()
      println("Reload Script...")
      GraphicsManager.cleanUp() #remove all
      reload(script)
    end
  )
  script.extern = merge(script.extern,list)
  
  list[:reload]()
end

function reload(script::JLScript)
	JLScriptManager.run(script)
  script(:OnInit)
end


function loop(script::JLScript)
  script(:OnUpdate)
  script(:OnRender)
  GLFW.SwapBuffers(WINDOW)
end

cleanScript() = eval(:(module SCRIPT end))
#eval(Expr(:toplevel,:(Main.Base.include(@__MODULE__, "clear_scripts.jl"))))

function cleanUp()
  info("cleanUp")
  GraphicsManager.cleanUp()
  JLScriptManager.clean()
  GLFW.Terminate()
  #cleanScript()
end

function OnFocus(window, focus)
  #ScriptManager.callEvent(:OnFocus, window, focus) 
end

function createWindow(width=100,height=100,title="")
  println("Create Window...")
  # remove previous Window
  GraphicsManager.cleanUp()
  GLFW.Terminate()
  
  # OS X-specific GLFW hints to initialize the correct version of OpenGL
  GLFW.Init()
  
  # Create a windowed mode window and its OpenGL context
  window = GLFW.CreateWindow(width, height, title)

  # Make the window's context current
  GLFW.MakeContextCurrent(window)

  GLFW.SetWindowSize(window, width, height) # Seems to be necessary to guarantee that window > 0

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

function reload(script::ScriptManager.Script)
  println("Reload Script...")
  #if script.clean != nothing script.clean() end
  GraphicsManager.cleanUp() #remove all
  
  #eval(:(Main.Base.include(@__MODULE__, "../scripts/$(script.name).jl")))

  #include("../scripts/$(script.name).jl")
  #script.init = ScriptManager.getFunction(SCRIPT.init, script.inputs)
  #script.update = ScriptManager.getFunction(SCRIPT.update)
  #script.render = ScriptManager.getFunction(SCRIPT.render)
  #script.clean = ScriptManager.getFunction(SCRIPT.clean)
end


function run()
  println("---------------------------------------------------------------------")
  println("Start Program @ ", Dates.time())
  InteractiveUtils.versioninfo()
  
  create(:input, "./scripts/scenes/test2.jl")

  #ScriptManager.setReload(Game.reload)
  
  #global script = ScriptManager.Script("scenes/test")
  
  window = createWindow()
  global WINDOW = window
  script.inputs[:WINDOW] = window
  
  #ScriptManager.reload(script)

  while !GLFW.WindowShouldClose(window)
    GLFW.PollEvents() # Poll for and process events
    #script.update()
    JLScriptManager.loop(loop)
    #script.render()
  end
  
  #GLFW.DestroyWindow(window) #might bug sometimes
  cleanUp()
  
end #run

end #Game