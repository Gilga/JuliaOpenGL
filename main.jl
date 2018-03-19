__precompile__()

include("libs.jl")
include("cubeData.jl")
include("camera.jl")

#include("compileAndLink.jl")
const compileAndLink = isdefined(:createLoop) 

## BLOCKS

struct HeptaOrder{T} <: FieldVector{6, T}
  front::Union{T,Void}
  back::Union{T,Void}
  left::Union{T,Void}
  right::Union{T,Void}
  top::Union{T,Void}
  bottom::Union{T,Void}
end

type Transform
  model::Mat4x4f
  mvp::Mat4x4f
end

type MeshBuffer
  vao::GLuint
  vbo::GLuint
  ibo::GLuint
  abo::GLuint
  
  MeshBuffer() = new(0,0,0,0)
end

type MeshData
  elements::UInt32
  vcount::UInt32
  icount::UInt32
  istcount::UInt32
  
  vertices::Union{Array{Float32,1}, Array{Vec3f,1}}
  indicies::Array{UInt32,1}
  instances::Array{Vec4f,1}
  
  buffer::MeshBuffer
  
  #textures::Array{Any,1}

  MeshData() = new(1,0,0,0,Float32[],UInt32[],Vec4f[],MeshBuffer())
end

type Block
  active::Bool
  typ::Int32
  pos::Vec3f
  friends::HeptaOrder{Block}
end

type Chunk
  active::Bool
  len::UInt32
  childs::Array{Block,1}
  count::UInt32
  activeCount::UInt32
  
  Chunk(len::Integer) = new(true,len,Block[],0,0)
end

#------------------------------------------------------------------------------------

getActiveChilds(this::Chunk) = filter(c->c.active,this.childs)
getData(this::Chunk) = this.activeCount>0?(c->Vec4(c.pos,c.typ)).(getActiveChilds(this)):Vec4f[]

function update(this::Chunk)
  this.count = length(this.childs)
  this.activeCount = length(getActiveChilds(this))
end

const BlockOrder = HeptaOrder{Block}
BlockOrder() = HeptaOrder{Block}(nothing,nothing,nothing,nothing,nothing,nothing)
Block() = Block(true,rand(0:16),Vec3f(),BlockOrder()) #,zeros(Mat4x4f),zeros(Mat4x4f))

isActive(this::Block) = this.active 

mychunk = Chunk(64)

const countrow = use_geometry_shader ? 2 : 64

function createSingle(this::Chunk)
  b=Block()
  b.typ=1
  b.pos = Vec3f(0, 0, -10)
  push!(this.childs,b)
  update(this)
end

function createExample(this::Chunk)
  const DIST = Vec3f(3,5,3) #r = 1f0/30 #0.005f0
  const START = Vec3f(-(this.len*DIST.x) / 2.0f0, -(this.len*DIST.y) / 2.0f0, (this.len*DIST.z) / 2.0f0)

  x=0; y=0; z=0; w=0;

  for i=1:(this.len^3)
    b = Block()
    b.pos = Vec3f(START.x+DIST.x*x, START.y+DIST.y*z, START.z-DIST.z*y)
    #model = Mat4x4f(translation(Array(b.pos)))
    
    push!(this.childs,b)
    #push!(refblocks, pointer_from_objref(b))
    
    x += 1; if x >= this.len
      y += 1; x=0;
      if y >= this.len z += 1; y=0;
        if z >= this.len w+=1; z=0;
          if w > 1 error("invalid range"); end
        end
      end
    end
  end
  
  update(this)
end

function createLandscape(this::Chunk)
  #Texture* heightTexture = m_pRenderer->GetTexture(m_pChunkManager->GetHeightMapTexture());
  
  b=Block()
  b.typ=1
  b.pos = Vec3f(0,0,0)
  push!(this.childs,b)
  
  rgbImage=Images.load("heightmap.jpg")
  (imgwidth, imgheight) = size(rgbImage)

  grayImage = Gray.(rgbImage)
  imgMatrix = reinterpret.(channelview(grayImage)) #convert(Array{Int32},raw(grayImage))

  w = imgwidth/this.len
  h = imgheight/this.len
  
  const DIST = Vec3f(2,2,2)
  const START = Vec3f(-(this.len*DIST.x) / 2.0f0, -(this.len*DIST.y) / 2.0f0, (this.len*DIST.z) / 2.0f0)
  
  for x=1:this.len
    for z=1:this.len
      # Use the height map texture to get the height value of x, z
      height = (imgMatrix[UInt32(trunc(z*h)), UInt32(trunc(x*w))] / 0xFF)* 1.25 * this.len
      if height >= this.len height=this.len end
      
      level_air = height * 0.95
      level_grass = height * 0.9
      level_dirt = height * 0.8
      level_stonebricks = height * 0.7
      level_stone = height * 0.4
      level_lava = height * 0

      for y=1:height
        #id = y*this.len^2+z*this.len+x
        #c = this.childs[id]
        #c.active = true
        b = Block()
        b.pos = Vec3f(START.x+x*DIST.x, START.y+y*DIST.y, START.z-z*DIST.z)
        #if y >= level_air b.typ = 0 # air or nothing
        if y >= level_grass  b.typ = 2 #grass
        elseif y >= level_dirt b.typ = 1 #dirt
        elseif y >= level_stonebricks b.typ = 5 #stonebricks
        elseif y >= level_stone b.typ = 4 #stone
        elseif y >= level_lava b.typ = 15 #lava
        end
        if b.typ > 0 push!(this.childs,b) end
      end
    end
  end
  
  update(this)
end

createLandscape(mychunk)
#createSingle(mychunk)

oneblock = mychunk.childs[1]

#fill copies references
refblocks = Ptr{Void}[]
for c in mychunk.childs push!(refblocks, pointer_from_objref(c)) end

include("frustum.jl")

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

println("OpenGL $(glinfo[:gl_version])")
println("GLSL $(glinfo[:glsl_version])")
println("Vendor $(glinfo[:gl_vendor])")
println("Renderer $(glinfo[:gl_renderer])")
println("---------------------------------------------------------------------")

include("shader.jl")

## CAMERA

setPosition(CAMERA,[0f0,0,0])
setProjection(CAMERA, projection_perspective(FOV, RATIO, CLIP_NEAR, CLIP_FAR))

fstm = Frustum()
SetFrustum(fstm, FOV, RATIO, CLIP_NEAR, 100f0)
SetCamera(fstm, Vec3f(CAMERA.position), Vec3f(CAMERA.position+forward(CAMERA)), Vec3f(0,1,0))

#resetChunks()
Update(CAMERA)

#------------------------------------------------------------------------------------

function setAttributePosition(program,vbo)
  glBindBuffer(GL_ARRAY_BUFFER, vbo)
  positionAttribute = glGetAttribLocation(program, "position")
  glEnableVertexAttribArray(positionAttribute)
  glVertexAttribPointer(positionAttribute, 3, GL_FLOAT, GL_FALSE, 0, C_NULL)
end

function setAttributeInstance(program,abo)
  glBindBuffer(GL_ARRAY_BUFFER, abo)
  instanceMatrixAttribute = glGetAttribLocation(program, "instance")
  glEnableVertexAttribArray(instanceMatrixAttribute)
  glVertexAttribPointer(instanceMatrixAttribute, 4, GL_FLOAT, GL_FALSE, 0, C_NULL)
  glVertexAttribDivisor(instanceMatrixAttribute, 1)
end

function createBuffer(this::MeshData)
  if this.buffer.vao != 0 return end
  this.buffer.vao = glGenVertexArray()
  if this.vcount > 0 this.buffer.vbo = glGenBuffer() end
  if this.icount > 0 this.buffer.ibo = glGenBuffer() end
  if this.istcount > 0 this.buffer.abo = glGenBuffer() end
end

function setAttributes(this::MeshData, program)
  glBindVertexArray(this.buffer.vao)
  if this.vcount > 0 setAttributePosition(program, this.buffer.vbo) end
  if this.istcount > 0 setAttributeInstance(program, this.buffer.abo) end
  glBindVertexArray(0)
end

function linkData(this::MeshData, vertices, indicies, instances)
  this.vertices = vertices
  this.indicies = indicies
  this.instances = instances
  
  this.vcount = length(this.vertices)/this.elements
  this.icount = length(this.indicies)
  this.istcount = length(this.instances)
  
  createBuffer(this)
  upload(this)
end

function upload(bufferID, data, typ=GL_ARRAY_BUFFER)
  const cdata = data
  glBindBuffer(typ, bufferID)
  glBufferData(typ, sizeof(cdata), cdata, GL_STATIC_DRAW)
end

function upload(this::MeshData)
  glBindVertexArray(this.buffer.vao)
  if this.vcount > 0 upload(this.buffer.vbo, this.vertices) end
  if this.icount > 0 upload(this.buffer.ibo, this.indicies, GL_ELEMENT_ARRAY_BUFFER) end
  if this.istcount > 0 upload(this.buffer.abo, this.instances) end
  glBindVertexArray(0)
end

function uploadTexture(path)
  img = Images.load(path)
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
end

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
chunkData.elements = 3
linkData(chunkData, cubeVertices_small, cubeIndices, getData(mychunk))

planeData = MeshData()
linkData(planeData,  getVertices(fstm), [], [])

program_chunks = createShaderProgram(createShader(VSH_INSTANCES, GL_VERTEX_SHADER), createShader(FSH_INSTANCES, GL_FRAGMENT_SHADER), createShader(GSH, GL_GEOMETRY_SHADER))
program_normal = createShaderProgram(createShader(VSH, GL_VERTEX_SHADER), createShader(FSH, GL_FRAGMENT_SHADER), createShader(GSH, GL_GEOMETRY_SHADER))

setAttributes(chunkData, program_chunks)
setAttributes(planeData, program_normal)

setMVP(program_chunks, CAMERA.MVP)
setMVP(program_normal, CAMERA.MVP)

## TEXTURES

uploadTexture("blocks.png")

## BLOCKS

function resetChunks()
  for c in mychunk.childs
    c.active = checkSphere(fstm, c.pos, 1.5) != 0
  end
  update(mychunk)
  
  chunkData.instances = getData(mychunk)
  chunkData.istcount = length(chunkData.instances)
  upload(chunkData)
  
  global COUNT = mychunk.activeCount
end

COUNT = mychunk.activeCount

#------------------------------------------------------------------------------------

function updateBlocks()
  #const mmvp = SMatrix{4,4,Float32}(CAMERA.MVP)
  #setMVP(CAMERA.MVP)
  #glUniform3fv(location_shift, 1, CAMERA.position)
  #glUniform3fv(location_shift, 1, shiftposition)
  #for b in blocks; b.mvp=mmvp*b.model; end
end


#updateBlocks()

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
  glDrawElements(GL_TRIANGLES, chunkData.icount, GL_UNSIGNED_INT, C_NULL )
  #glDrawArrays(GL_TRIANGLES, 0, chunkData.vcount)
  nothing
end

if use_geometry_shader
  const loopBlocks() = render(oneblock)
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
  
  if mychunk.activeCount > 0
    useProgram(program_chunks)
    glPolygonMode(GL_FRONT_AND_BACK, GL_FILL)
    glBindVertexArray(chunkData.buffer.vao)
    glDrawElementsInstanced(GL_TRIANGLES, chunkData.icount, GL_UNSIGNED_INT, C_NULL, mychunk.count)
    glBindVertexArray(0)
  end
  
  useProgram(program_normal)
  glPolygonMode(GL_FRONT_AND_BACK, GL_LINE)

  if keyPressed && keyValue == FRUSTUM_KEY
    println("RESET FRUSTUM")
    SetCamera(fstm, Vec3f(CAMERA.position), Vec3f(CAMERA.position+forward(CAMERA)), Vec3f(0,1,0))
    linkData(planeData,  getVertices(fstm), [], [])
    resetChunks()
  end
  
  glBindVertexArray(planeData.buffer.vao)
  #glDrawElements(GL_TRIANGLES, planeData.icount, GL_UNSIGNED_INT, C_NULL )
  glDrawArrays(GL_TRIANGLES, 0, planeData.vcount)
  glBindVertexArray(0)
  
  if cam_updated cam_updated=false end
  if keyPressed keyPressed=false end

  # Swap front and back buffers
  GLFW.SwapBuffers(window)
  # Poll for and process events
  GLFW.PollEvents()
end
  
GLFW.Terminate()
