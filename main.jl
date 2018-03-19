__precompile__()

include("libs.jl")
include("cubeData.jl")
include("camera.jl")
include("frustum.jl")
include("chunk.jl")
include("mesh.jl")
include("texture.jl")

#include("compileAndLink.jl")
const compileAndLink = isdefined(:createLoop) 

## BLOCKS
mychunk = Chunk(64)

const countrow = use_geometry_shader ? 2 : 64

createLandscape(mychunk)
#createSingle(mychunk)

## PROGRAM 

println("---------------------------------------------------------------------")
println("Start Program @ ", Dates.time())
versioninfo()

# OS X-specific GLFW hints to initialize the correct version of OpenGL
GLFW.Init()
    
# Create a windowed mode window and its OpenGL context
window = GLFW.CreateWindow(WIDTH, HEIGHT, "OpenGL Example")
# Make the window's context current
GLFW.MakeContextCurrent(window)
GLFW.ShowWindow(window)
GLFW.SetWindowSize(window, WIDTH, HEIGHT) # Seems to be necessary to guarantee that window > 0

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

rezizeWindow(WIDTH,HEIGHT)

glinfo = createcontextinfo()

include("shader.jl")

println("OpenGL $(glinfo[:gl_version])")
println("GLSL $(glinfo[:glsl_version])")
println("Vendor $(glinfo[:gl_vendor])")
println("Renderer $(glinfo[:gl_renderer])")
println("---------------------------------------------------------------------")

## CAMERA

setPosition(CAMERA,[0f0,0,0])
setProjection(CAMERA, projection_perspective(FOV, RATIO, CLIP_NEAR, CLIP_FAR))

fstm = Frustum()
SetFrustum(fstm, FOV, RATIO, CLIP_NEAR, 100f0)
SetCamera(fstm, Vec3f(CAMERA.position), Vec3f(CAMERA.position+forward(CAMERA)), Vec3f(0,1,0))

Update(CAMERA)

#------------------------------------------------------------------------------------

program = 0
useProgram(p) = begin global program = p; glUseProgram(p) end

setMatrix(program, name, m) = begin const cm = SMatrix{4,4,Float32}(m); glUniformMatrix4fv(glGetUniformLocation(program, name), 1, false, cm) end

function setMVP(p, mvp)
  glUseProgram(p)
  setMatrix(p, "mvp", mvp)
  glUseProgram(program)
end

setMVP(mvp) = setMatrix(program, "mvp", mvp)

#------------------------------------------------------------------------------------

chunkData = MeshData()
planeData = MeshData()

linkData(chunkData, :vertices=>(cubeVertices_small,3), :indicies=>(cubeIndices,1,GL_ELEMENT_ARRAY_BUFFER, true), :instances=>getData(mychunk))
linkData(planeData,  :vertices=>getVertices(fstm))

program_chunks = createShaderProgram(createShader(VSH_INSTANCES, GL_VERTEX_SHADER), createShader(FSH_INSTANCES, GL_FRAGMENT_SHADER), createShader(GSH, GL_GEOMETRY_SHADER))
program_normal = createShaderProgram(createShader(VSH, GL_VERTEX_SHADER), createShader(FSH, GL_FRAGMENT_SHADER), createShader(GSH, GL_GEOMETRY_SHADER))

setAttributes(chunkData, program_chunks)
setAttributes(planeData, program_normal)

setMVP(program_chunks, CAMERA.MVP)
setMVP(program_normal, CAMERA.MVP)

## TEXTURES

uploadTexture("blocks.png")

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
glFrontFace(GL_CCW)
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

cam_updated=false

FRUSTUM_KEY = 70

i=0
while !GLFW.WindowShouldClose(window)
  showFrames()
  UpdateCounters()
  if OnUpdate(CAMERA)
    setMVP(program_chunks, CAMERA.MVP)
    setMVP(program_normal, CAMERA.MVP)
    cam_updated=true
  end

  # Pulse the background
  c=0.5 * (1 + sin(i * 0.01)); i+=1
  glClearColor(c, c, c, 1.0)
  glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)

  #print("loopBlocks "); @time
  #loopBlocks()
  
  if mychunk.visibleCount > 0
    useProgram(program_chunks)
    glPolygonMode(GL_FRONT_AND_BACK, GL_FILL)
    glBindVertexArray(chunkData.vao)
    glDrawElementsInstanced(GL_TRIANGLES, chunkData.draw.count, GL_UNSIGNED_INT, C_NULL, mychunk.count)
    glBindVertexArray(0)
  end
  
  useProgram(program_normal)
  glPolygonMode(GL_FRONT_AND_BACK, GL_LINE)

  if keyPressed && keyValue == FRUSTUM_KEY
    SetCamera(fstm, Vec3f(CAMERA.position), Vec3f(CAMERA.position+forward(CAMERA)), Vec3f(0,1,0))
    checkInFrustum(mychunk, fstm)
    upload(planeData, :vertices, getVertices(fstm))
    upload(chunkData, :instances, getData(mychunk))
  end
  
  glBindVertexArray(planeData.vao)
  #glDrawElements(GL_TRIANGLES, planeData.draw.count, GL_UNSIGNED_INT, C_NULL )
  glDrawArrays(GL_TRIANGLES, 0, planeData.draw.count)
  glBindVertexArray(0)
  
  if cam_updated cam_updated=false end
  if keyPressed keyPressed=false end

  # Swap front and back buffers
  GLFW.SwapBuffers(window)
  # Poll for and process events
  GLFW.PollEvents()
end
  
GLFW.Terminate()
