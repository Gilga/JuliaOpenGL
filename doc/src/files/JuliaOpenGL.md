# JuliaOpenGL.jl (main.jl)

```@docs
App
```

## INCLUDES
include("libs.jl")
include("shader.jl")
  
## COMPILE C File 
#include("compileAndLink.jl")
const compileAndLink = isdefined(:createLoop) 


setMode(program, name, mode)

setFrustumCulling(load=true)

chooseRenderMethod(method=RENDER_METHOD)

checkForUpdate()

useProgram(program)

setMatrix(program, name, m)

setMVP(program, mvp, old_program=nothing)

## PROGRAM 

run()

println("---------------------------------------------------------------------")
println("Start Program @ ", Dates.time())
versioninfo()

# OS X-specific GLFW hints to initialize the correct version of OpenGL
GLFW.Init()
    
# Create a windowed mode window and its OpenGL context
global window = GLFW.CreateWindow(WIDTH, HEIGHT, "OpenGL Example")

# Make the window's context current
GLFW.MakeContextCurrent(window)

GLFW.SetWindowSize(window, WIDTH, HEIGHT) # Seems to be necessary to guarantee that window > 0
rezizeWindow(WIDTH,HEIGHT)

# Window settings
GLFW.SwapInterval(0) # intervall between canvas images (min. 2 images)

# Graphcis Settings
GLFW.WindowHint(GLFW.OPENGL_DEBUG_CONTEXT,true) #show debug
#GLFW.WindowHint(GLFW.SAMPLES,4)

# OpenGL Version
GLFW.WindowHint(GLFW.CONTEXT_VERSION_MAJOR,4)
GLFW.WindowHint(GLFW.CONTEXT_VERSION_MINOR,6)

GLFW.SetCursorPosCallback(window, OnCursorPos)
GLFW.SetKeyCallback(window, OnKey)
GLFW.SetMouseButtonCallback(window, OnMouseKey)

#setEventCallbacks(OnCursorPos,OnKey,OnMouseKey)

GLFW.ShowWindow(window)

glinfo = createcontextinfo()

println("OpenGL $(displayInRed(glinfo[:gl_version]))")
println("GLSL $(glinfo[:glsl_version])")
println("Vendor $(displayInRed(glinfo[:gl_vendor]))")
println("Renderer $(displayInRed(glinfo[:gl_renderer]))")
println("---------------------------------------------------------------------")

## CAMERA

setPosition(CAMERA,[0f0,0,0])
setProjection(CAMERA, projection_perspective(FOV, RATIO, CLIP_NEAR, CLIP_FAR))

global fstm = Frustum()
SetFrustum(fstm, FOV, RATIO, CLIP_NEAR, 1000f0)
SetCamera(fstm, Vec3f(CAMERA.position), Vec3f(CAMERA.position+forward(CAMERA)), Vec3f(0,1,0))

Update(CAMERA)

#------------------------------------------------------------------------------------

program = 0

#------------------------------------------------------------------------------------

global chunkData = MeshData()
global planeData = MeshData()

#------------------------------------------------------------------------------------

## TEXTURES

uploadTexture("blocks.png")

## LOAD DEFAULT
chooseRenderMethod()

#------------------------------------------------------------------------------------

linkData(planeData,  :vertices=>getVertices(fstm))

#chunkData.arrays[:vertices].count
#n = length(cubeVertices_small) / 3

#function compileShaderPrograms()
#  global program_chunks, program_normal

global program_normal = createShaderProgram(VSH, FSH) #, createShader(GSH, GL_GEOMETRY_SHADER)

setAttributes(planeData, program_normal)
setMVP(program_normal, CAMERA.MVP)

#end

#compileShaderPrograms()

global location_position = -1
global location_texindex = -1

#------------------------------------------------------------------------------------

function updateBlocks()
  #const mmvp = SMatrix{4,4,Float32}(CAMERA.MVP)
  #setMVP(CAMERA.MVP)
  #glUniform3fv(location_shift, 1, CAMERA.position)
  #glUniform3fv(location_shift, 1, shiftposition)
  #for b in blocks; b.mvp=mmvp*b.model; end
end

#------------------------------------------------------------------------------------

glEnable(GL_DEPTH_TEST)
glEnable(GL_BLEND)
glEnable(GL_CULL_FACE)
#glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
#glBlendEquation(GL_FUNC_ADD)
#glFrontFace(GL_CCW)
glCullFace(GL_BACK)
#glPolygonMode(GL_FRONT_AND_BACK, GL_LINE)#GL_FILL,GL_LINE
glClearColor(0.0, 0.0, 0.0, 1.0)

# Loop until the user closes the window
render = function(x)
  #mvp = mmvp*MMatrix{4,4,Float32}(unsafe_wrap(Array, mvp, (4,4)))
  #setMVP(CAMERA.MVP*translation([c.x,c.y,c.z]))

  #glUniformMatrix4fv(location_mvp, 1, false, x.mvp)
  #glDrawElements(GL_TRIANGLES, chunkData.draw.count, GL_UNSIGNED_INT, C_NULL )
  #glDrawArrays(GL_TRIANGLES, 0, chunkData.draw.count)
  nothing
end

#=
if use_geometry_shader
  const loopBlocks() = render(mychunk.childs[1])
else
  if compileAndLink
    objptr = createLoop(1,refblocks,render) #compileAndLink
    const loopBlocks() = loopByObject(objptr) #compileAndLink
  else
    const loopBlocks() = for b in mychunk.childs; render(b); end
  end
end
=#

cam_updated=false

const SLEEP=0 #1f0/200

i=0
while !GLFW.WindowShouldClose(window)
  showFrames()
  UpdateCounters()
  
  if OnUpdate(CAMERA)
    setMVP(program_chunks, CAMERA.MVP)
    #setMVP(program_normal, CAMERA.MVP)
    cam_updated=true
  end
  
  checkForUpdate()
  if cam_updated cam_updated=false end

  # Pulse the background
  #c=0.5 * (1 + sin(i * 0.01)); i+=1
  #glClearColor(c, c, c, 1.0)
  glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)

  #print("loopBlocks "); @time
  #loopBlocks()
  
  if isValid(mychunk) 
    useProgram(program_chunks)
    #glCheckError("useProgram")
    glPolygonMode(GL_FRONT_AND_BACK, WIREFRAME ? GL_LINE : GL_FILL)
    glBindVertexArray(chunkData.vao)
    #glCheckError("glBindVertexArray bind")
    
    if RENDER_METHOD == 1 glDrawArraysInstanced(GL_POINTS, 0, 1, mychunk.fileredCount) #GL_TRIANGLE_STRIP
    elseif RENDER_METHOD == 2 glDrawArraysInstanced(GL_TRIANGLES, 0, chunkData.draw.count, mychunk.fileredCount)
    elseif RENDER_METHOD == 3 glDrawElementsInstanced(GL_TRIANGLES, chunkData.draw.count, GL_UNSIGNED_INT, C_NULL, mychunk.fileredCount)
    #glDrawElementsInstancedBaseVertex(GL_TRIANGLES, chunkData.draw.count / 6, GL_UNSIGNED_INT, C_NULL, mychunk.count, 0)
    elseif RENDER_METHOD > 3
      #* thats slow! (glDrawElements ~60 fps, glDrawElementsInstanced ~ 200 fps !!!)
      for b in getFilteredChilds(mychunk)
        if location_texindex > -1 glUniform1f(location_texindex, b.typ) end
        if location_position > -1 glUniform3fv(location_position, 1, b.pos) end
        glDrawElements(GL_TRIANGLES, chunkData.draw.count, GL_UNSIGNED_INT, C_NULL )
        #glCheckError("glDrawElements")
      end
    end
    glBindVertexArray(0)
    #glCheckError("glBindVertexArray unbind")
  end
  
  #=
  useProgram(program_normal)
  glPolygonMode(GL_FRONT_AND_BACK, GL_LINE)

  glBindVertexArray(planeData.vao)
  #glDrawElements(GL_TRIANGLES, planeData.draw.count, GL_UNSIGNED_INT, C_NULL )
  glDrawArrays(GL_TRIANGLES, 0, planeData.draw.count)
  glBindVertexArray(0)
  =#

  # Swap front and back buffers
  GLFW.SwapBuffers(window)
  # Poll for and process events
  GLFW.PollEvents()
  
  if SLEEP>0 Libc.systemsleep(SLEEP) end
end
  
GLFW.DestroyWindow(window)
GLFW.Terminate()

end

end

function main()
  App.run()
end
