include("libs.jl")
include("cubeData.jl")
include("camera.jl")

#include("compileAndLink.jl")
const compileAndLink = isdefined(:createLoop) 

### PROGRAM ###

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
GLFW.WindowHint(GLFW.CONTEXT_VERSION_MAJOR,3)
GLFW.WindowHint(GLFW.CONTEXT_VERSION_MINOR,3)

GLFW.SetCursorPosCallback(window, OnCursorPos)
GLFW.SetKeyCallback(window, OnKey)
GLFW.SetMouseButtonCallback(window, OnMouseKey)

#setEventCallbacks(OnCursorPos,OnKey,OnMouseKey)

rezizeWindow(WIDTH,HEIGHT)

glinfo = createcontextinfo()

println("OpenGL $(glinfo[:gl_version])")
println("GLSL $(glinfo[:glsl_version])")
println("Vendor $(glinfo[:gl_vendor])")
println("Renderer $(glinfo[:gl_renderer])")
println("---------------------------------------------------------------------")

elements = 3
vcount = length(cubeVertices_small)/elements
icount = length(cubeIndices)

# Generate a vertex array and array buffer for our data
vao = glGenVertexArray()
glBindVertexArray(vao)

vbo = glGenBuffer()
ibo = glGenBuffer()

glBindBuffer(GL_ARRAY_BUFFER, vbo)
glBufferData(GL_ARRAY_BUFFER, sizeof(cubeVertices_small), cubeVertices_small, GL_STATIC_DRAW)

glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ibo)
glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(cubeIndices), cubeIndices, GL_STATIC_DRAW)

include("shader.jl")

vertexShader = createShader(VSH, GL_VERTEX_SHADER)
fragmentShader = createShader(FSH, GL_FRAGMENT_SHADER)
program = createShaderProgram(vertexShader, fragmentShader)
glUseProgram(program)
positionAttribute = glGetAttribLocation(program, "position")
glEnableVertexAttribArray(positionAttribute)
glVertexAttribPointer(positionAttribute, elements, GL_FLOAT, false, 0, C_NULL)

CAMERA.position = [0f0,0,10]
setProjection(CAMERA, projection_perspective(60.0f0, RATIO, 0.001f0, 10000.0f0))

Update(CAMERA)

#MVP *= transform([0.0f0,0.0f0,0.0f0],[0.0f0,0.0f0,0.0f0],Float32[])
#mvp *= translation([0,0,-1.0f0])    
location_mvp = glGetUniformLocation(program, "mvp")

setMVP(mvp) = glUniformMatrix4fv(location_mvp, 1, false, mvp)

glDisable(GL_BLEND)
glEnable(GL_CULL_FACE)
glEnable(GL_BLEND)
glFrontFace(GL_CCW)
glCullFace(GL_BACK)
glPolygonMode(GL_FRONT_AND_BACK, GL_LINE)#GL_FILL,GL_LINE
glClearColor(0.0, 0.0, 0.0, 0.0)

setMVP(CAMERA.MVP)

dist = 5
r = 1f0/30 #0.005f0

const COUNTX=32
const COUNTY=32
const COUNTZ=32
global COUNT=COUNTX*COUNTY*COUNTZ #32768 #32*32*32

const STARTX = -(COUNTX*dist) / 2.0f0
const STARTY = -(COUNTY*dist) / 2.0f0
const STARTZ = -(COUNTZ*dist*2) / 2.0f0

type INDEX
  x::Integer
  y::Integer
  z::Integer
  pos::SMatrix{4,4,Float32}
  mvp::SMatrix{4,4,Float32}
  
  INDEX() = new(0,0,0,zeros(SMatrix{4,4,Float32}),zeros(SMatrix{4,4,Float32}))
end

blocks = INDEX[]; refblocks = Ptr{Void}[]
for i=1:COUNT push!(blocks,INDEX()); push!(refblocks, pointer_from_objref(blocks[i])); end #fill copies references

x=0; y=0; z=0; w=0;

for b in blocks
  x += 1
  if x >= COUNTX
    y += 1; x=0;
    if y >= COUNTY z += 1; y=0;
      if z >= COUNTX w+=1; z=0;
        if w > 1 error("invalid range"); end
      end
    end
  end

  b.x = STARTX+dist*x
  b.y = STARTY+dist*z
  b.z = STARTZ-dist*y

  b.pos = SMatrix{4,4,Float32}(translation([b.x,b.y,b.z]))
end

function updateBlocks()
  mmvp = SMatrix{4,4,Float32}(CAMERA.MVP)
  for b in blocks; b.mvp=mmvp*b.pos; end
end

const ic = icount #optimized

# Loop until the user closes the window
render = function(x)
  #mvp = mmvp*MMatrix{4,4,Float32}(unsafe_wrap(Array, mvp, (4,4)))
  #setMVP(CAMERA.MVP*translation([c.x,c.y,c.z]))

  glUniformMatrix4fv(location_mvp, 1, false, x.mvp)
  glDrawElements(GL_TRIANGLES, ic, GL_UNSIGNED_INT, C_NULL )
  #glDrawArrays(GL_TRIANGLES, 0, vcount)
  nothing
end

if compileAndLink
  objptr = createLoop(1,refblocks,render) #compileAndLink
  const loopBlocks() = loopByObject(objptr) #compileAndLink
else
  const bb = blocks
  const loopBlocks() = for b in bb; render(b); end
end

i=0
while !GLFW.WindowShouldClose(window)
  showFrames()
  #UpdateCounters()
  if OnUpdate(CAMERA) updateBlocks() end

  # Pulse the background
  c=0.5 * (1 + sin(i * 0.01)); i+=1
  glClearColor(c, c, c, 1.0)
  glClear(GL_COLOR_BUFFER_BIT)

  #print("loopBlocks "); @time
  loopBlocks()
   
  # Swap front and back buffers
  GLFW.SwapBuffers(window)
  # Poll for and process events
  GLFW.PollEvents()
end
  
GLFW.Terminate()
