__precompile__()

include("libs.jl")
include("cubeData.jl")
include("camera.jl")

#include("compileAndLink.jl")
const compileAndLink = isdefined(:createLoop) 

### BLOCKS ###

dist = 4.0f0
r = 1f0/30 #0.005f0

const countrow = use_geometry_shader ? 2 : 64

const COUNTX=countrow
const COUNTY=countrow
const COUNTZ=countrow
global COUNT=COUNTX*COUNTY*COUNTZ #32768 #32*32*32

const STARTX = -(COUNTX*dist) / 2.0f0
const STARTY = -(COUNTY*dist) / 2.0f0
const STARTZ = -(COUNTZ*dist*2) / 2.0f0

type INDEX
  x::Float32
  y::Float32
  z::Float32
  pos::SMatrix{4,4,Float32}
  mvp::SMatrix{4,4,Float32}
  
  INDEX() = new(0,0,0,zeros(SMatrix{4,4,Float32}),zeros(SMatrix{4,4,Float32}))
end

blocks = INDEX[]; refblocks = Ptr{Void}[]; modelMatrices = Array{SVector{4,Float32}}(COUNT)
for i=1:COUNT push!(blocks,INDEX()); push!(refblocks, pointer_from_objref(blocks[i])); end #fill copies references

oneblock = blocks[1]

i=0; x=0; y=0; z=0; w=0; t=0;

for b in blocks
  i += 1

  b.x = STARTX+dist*x
  b.y = STARTY+dist*z
  b.z = STARTZ-dist*y

  m = SMatrix{4,4,Float32}(translation([b.x,b.y,b.z]))
  b.pos = m
  modelMatrices[i] = @SVector [b.x,b.y,b.z,t]
  
  t += 1; if t>=17 t = 0 end

  x += 1; if x >= COUNTX
    y += 1; x=0;
    if y >= COUNTY z += 1; y=0;
      if z >= COUNTX w+=1; z=0;
        if w > 1 error("invalid range"); end
      end
    end
  end
end

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
GLFW.WindowHint(GLFW.CONTEXT_VERSION_MAJOR,4)
GLFW.WindowHint(GLFW.CONTEXT_VERSION_MINOR,6)

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
abo = glGenBuffer()

size_vertices = sizeof(cubeVertices_small)

glBindBuffer(GL_ARRAY_BUFFER, vbo)
glBufferData(GL_ARRAY_BUFFER, size_vertices, cubeVertices_small, GL_STATIC_DRAW)

glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ibo)
glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(cubeIndices), cubeIndices, GL_STATIC_DRAW)

size_matrices = sizeof(modelMatrices)
glBindBuffer(GL_ARRAY_BUFFER, abo)
glBufferData(GL_ARRAY_BUFFER, size_matrices, modelMatrices, GL_STATIC_DRAW)

include("shader.jl")

vertexShader = createShader(VSH, GL_VERTEX_SHADER)
fragmentShader = createShader(FSH, GL_FRAGMENT_SHADER)
geometryShader = createShader(GSH, GL_GEOMETRY_SHADER)
program = createShaderProgram(vertexShader, fragmentShader, geometryShader)

glBindBuffer(GL_ARRAY_BUFFER, vbo)

positionAttribute = glGetAttribLocation(program, "position")
glEnableVertexAttribArray(positionAttribute)
glVertexAttribPointer(positionAttribute, elements, GL_FLOAT, GL_FALSE, 0, C_NULL)

glBindBuffer(GL_ARRAY_BUFFER, abo)
instanceMatrixAttribute = glGetAttribLocation(program, "instanceMatrix")
glEnableVertexAttribArray(instanceMatrixAttribute)
glVertexAttribPointer(instanceMatrixAttribute, 4, GL_FLOAT, GL_FALSE, 0, C_NULL)
glVertexAttribDivisor(instanceMatrixAttribute, 1)

#> TEXTURES

img = Images.load("blocks.png")
(imgwidth, imgheight) = size(img)
imga = reinterpret.(vec(channelview(img)))

texture = glGenTexture()
glActiveTexture(GL_TEXTURE0)
glBindTexture(GL_TEXTURE_2D, texture)
glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST) #GL_LINEAR
glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST) #GL_LINEAR
glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE) #GL_CLAMP_TO_EDGE,GL_REPEAT
glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE) #GL_CLAMP_TO_EDGE,GL_REPEAT
glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA8, imgwidth, imgheight, 0, GL_RGBA, GL_UNSIGNED_BYTE, pointer(imga))

#< TEXTURES

glUseProgram(program)

CAMERA.position = [0f0,0,10]
setProjection(CAMERA, projection_perspective(60.0f0, RATIO, 0.001f0, 10000.0f0))

Update(CAMERA)

#MVP *= transform([0.0f0,0.0f0,0.0f0],[0.0f0,0.0f0,0.0f0],Float32[])
#mvp *= translation([0,0,-1.0f0])    
location_mvp = glGetUniformLocation(program, "mvp")
#location_tex = glGetUniformLocation(program, "tex")

setMVP(mvp) = glUniformMatrix4fv(location_mvp, 1, false, mvp)

glEnable(GL_DEPTH_TEST)
glEnable(GL_BLEND)
glEnable(GL_CULL_FACE)
#glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
#glBlendEquation(GL_FUNC_ADD)
glFrontFace(GL_CCW)
glCullFace(GL_BACK)
#glPolygonMode(GL_FRONT_AND_BACK, GL_LINE)#GL_FILL,GL_LINE
glClearColor(0.0, 0.0, 0.0, 1.0)

setMVP(CAMERA.MVP)

function updateBlocks()
  const mmvp = SMatrix{4,4,Float32}(CAMERA.MVP)
  glUniformMatrix4fv(location_mvp, 1, false, mmvp)
  #for b in blocks; b.mvp=mmvp*b.pos; end
end

const ic = icount #optimized

# Loop until the user closes the window
render = function(x)
  #mvp = mmvp*MMatrix{4,4,Float32}(unsafe_wrap(Array, mvp, (4,4)))
  #setMVP(CAMERA.MVP*translation([c.x,c.y,c.z]))

  #glUniformMatrix4fv(location_mvp, 1, false, x.mvp)
  glDrawElements(GL_TRIANGLES, ic, GL_UNSIGNED_INT, C_NULL )
  #glDrawArrays(GL_TRIANGLES, 0, vcount)
  nothing
end

if use_geometry_shader
  const loopBlocks() = render(oneblock)
else
  if compileAndLink
    objptr = createLoop(1,refblocks,render) #compileAndLink
    const loopBlocks() = loopByObject(objptr) #compileAndLink
  else
    const bb = blocks
    const loopBlocks() = for b in bb; render(b); end
  end
end

i=0
while !GLFW.WindowShouldClose(window)
  showFrames()
  #UpdateCounters()
  if OnUpdate(CAMERA) updateBlocks() end

  # Pulse the background
  c=0.5 * (1 + sin(i * 0.01)); i+=1
  glClearColor(c, c, c, 1.0)
  glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)

  #print("loopBlocks "); @time
  #loopBlocks()
  glDrawElementsInstanced(GL_TRIANGLES, ic, GL_UNSIGNED_INT, C_NULL, COUNT)

  # Swap front and back buffers
  GLFW.SwapBuffers(window)
  # Poll for and process events
  GLFW.PollEvents()
end
  
GLFW.Terminate()
