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

using .GraphicsManager
using .CameraManager
using .ScriptManager

function cleanUp()
  info("cleanUp")
  GraphicsManager.cleanUp()
  GLFW.Terminate()
end

function OnFocus(window, focus)
  ScriptManager.callEvent(:OnFocus, window, focus) 
end

function createWindow(width=100,height=100,title="")
  println("Create Window...")
  # remove previous Window
  cleanUp()
  
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
  if script.clean != nothing script.clean() end

  GraphicsManager.cleanUp() #remove all
  
  include("../scripts/$(script.name).jl")
  script.init = ScriptManager.getFunction(SCRIPT.init, script.inputs)
  script.update = ScriptManager.getFunction(SCRIPT.update)
  script.render = ScriptManager.getFunction(SCRIPT.render)
  script.clean = ScriptManager.getFunction(SCRIPT.clean)
end

function run()
  println("---------------------------------------------------------------------")
  println("Start Program @ ", Dates.time())
  InteractiveUtils.versioninfo()
  
  ScriptManager.setReload(Game.reload)
  
  global script = ScriptManager.Script("scenes/blocks")
  
  window = createWindow()
  script.inputs[:WINDOW] = window
  
  ScriptManager.reload(script)

  while !GLFW.WindowShouldClose(window)
    GLFW.PollEvents() # Poll for and process events
    script.update()
    GLFW.SwapBuffers(window)
    script.render()
  end
  
  #GLFW.DestroyWindow(window) #might bug sometimes
  cleanUp()
  
end #run

end #Game