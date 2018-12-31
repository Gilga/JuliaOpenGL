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

using .DefaultModelData
using .CameraManager
using .FrustumManager
using .ChunkManager
using .MeshManager
using .TextureManager

struct IndirectCommand
         count::GLuint
     primCount::GLuint
    firstIndex::GLuint
    baseVertex::GLuint
  baseInstance::GLuint
  
  IndirectCommand(count=0, primCount=0) = new(count,primCount,0,0,0)
end

GRAPHICS_DRIVER_INITALIZED = false

function cleanUp()
  global GRAPHICS_DRIVER_INITALIZED
  info("cleanUp")
  if GRAPHICS_DRIVER_INITALIZED
    MeshManager.cleanUp()
  end
  GLFW.Terminate()
  GRAPHICS_DRIVER_INITALIZED = false
end

function run()

println("Init Vars.")

TITLE = "Blocks Game"
STARTTIME = time()
PREVTIME = STARTTIME
FRAMES = 0
MAX_FRAMES = 0
FPS = 0
MAX_FPS = 0
ITERATION = 0
BLOCK_COUNT = 0
SIZE = 0

prevTime = Ref(0.0)

WIDTH = 1280 #800
HEIGHT = 800 #600
RATIO = WIDTH/(HEIGHT*1f0)
SIZE = WIDTH * HEIGHT
FOV = 60.0f0
CLIP_NEAR = 0.001f0
CLIP_FAR = 10000.0f0

CAM_LOCK = false
WIREFRAME = false
TEXTUREMODE = true
LIGHTMODE = true
FRUSTUM_CULLING = true
HIDE_UNSEEN_CUBES = true
RENDER_METHOD = 8
mychunk = nothing
programs = Dict{Symbol,GLint}(
:CHUNKS=>0,:NORMAL=>0, :SCREEN=>0, :COMPUTE=>0,
:COMPUTE_CHUNKS=>0, :CHANGE_CHUNKS=>0, :INSTANCES=>0, :INDIRECT=>0,
:BG=>0, :FG=>0, :DEPTH=>0, :RASTER=>0, :DEPTH_MIP=>0
)

SCENE = 2
FRUSTUM = nothing
WINDOW = nothing

chunkData = nothing
chunkData_upload = nothing
chunk_instances = nothing
planeData = nothing
screenData = nothing
boxData = nothing
indirectData = nothing

CHUNK_SIZE = 128
CHUNK1D_SIZE = CHUNK_SIZE
CHUNK2D_SIZE = CHUNK1D_SIZE * CHUNK1D_SIZE
CHUNK3D_SIZE = CHUNK2D_SIZE * CHUNK1D_SIZE

current_program = 0
load_once = true
workPool = nothing
MVP = nothing
render_ready = false
fileredCount = 0
uploaded = false
texture_screen = 0
texture_blocks = 0
texture_heightMap = 0
texture_depth = 0
shadow_sampler = 0
GPU_FRUSTUM = true
CAMERA = CameraManager.CAMERA
GPU_CHUNKS = ChunkManager.GPU_CHUNKS

#---------------------------------------------

chunk_instances = SharedArray(Float32[])
setChunkInstances(data) = #= global =# chunk_instances = data
getChunkInstances() = chunk_instances

plane_vertices = SharedArray(Float32[])
setPlaneVertices(data) = #= global =# plane_vertices = data
getPlaneVertices() = plane_vertices

box_vertices = SharedArray(Float32[])
setBoxVertices(data) = #= global =# box_vertices = data
getBoxVertices() = box_vertices

#---------------------------------------------

println("Set Functions.")

"""
TODO
"""
function UpdateCounters()
  UpdateTimers()
  showFrames()
end    

"""
TODO
"""
function showFrames()
  currenttime = time() #GetTimer("FRAME_TIMER")
  
  #= global =# ITERATION +=1
  if !OnTime(1.0, prevTime; time=currenttime) #= global =# FRAMES += 1; return end

  #FPS = FRAMES/(currenttime - PREVTIME)
  #PREVTIME = currenttime
  #if MAX_FPS < FPS MAX_FPS = FPS end
  #if FPS > 15 COUNT += 1 end
  #fpms = FPS > 0 ? (1000.0 / FPS) : 0
  #max_fmps = MAX_FPS > 0 ? (1000.0 / MAX_FPS) : 0
  #norm_fps = FPS/MAX_FPS
  
  if MAX_FRAMES < FRAMES #= global =# MAX_FRAMES = FRAMES end
  fps = FRAMES
  max_fps = MAX_FRAMES
  fpms = FRAMES > 0 ? (1000.0 / FRAMES) : 0
  max_fmps = MAX_FRAMES > 0 ? (1000.0 / MAX_FRAMES) : 0
  norm_fps = FRAMES / MAX_FRAMES
  
  GLFW.SetWindowTitle(WINDOW, "$(TITLE) - FPS $(round(fps; digits=2))[$(round(max_fps; digits=2))] | FMPS $(round(fpms; digits=2))[$(round(max_fmps; digits=2))] - Blocks $CHUNK_SIZE^3 ($BLOCK_COUNT) - IT $ITERATION")
  #= global =# FRAMES = 0
end

"""
sets glfw window size + viewport
"""
function rezizeWindow(window, width, height)
  #= global =# WIDTH = width
  #= global =# HEIGHT = height
  #= global =# RATIO = WIDTH/(HEIGHT*1f0)
  #= global =# SIZE = WIDTH * HEIGHT
  GLFW.SetWindowSize(window, WIDTH, HEIGHT)
  glViewport(0, 0, WIDTH, HEIGHT)
end

WINDOW_FOCUS = true

function OnFocus(window, focus)
  #= global =# WINDOW_FOCUS = focus > 0 ? true : false
end

function init()
  FRUSTUM = Frustum()
  
  presetCamera()
  
  #if myid() == 1
    #= global =# chunkData = MeshData()
    #= global =# chunkData_upload = MeshData()
    #= global =# planeData = MeshData()
    #= global =# screenData = MeshData()
    #= global =# boxData = MeshData()
    #= global =# indirectData = MeshData()
    presetTextures()
    chooseRenderMethod()
  #end
  
  #if myid() != 1 || length(procs()) <= 1
  #  #= global =# mychunk = Chunk()
  #  createChunk(mychunk)
  #end
end

function presetCamera()
  setPosition(CAMERA,[0f0,0,0])
  setProjection(CAMERA, projection_perspective(FOV, RATIO, CLIP_NEAR, CLIP_FAR))
  Update(CAMERA)
  #= global =# MVP = CAMERA.MVP
  SetFrustum(FRUSTUM, FOV+10, RATIO, CLIP_NEAR, CLIP_FAR)
  SetCamera(FRUSTUM, Vec3f(CAMERA.position), Vec3f(CAMERA.position+CameraManager.forward(CAMERA)), Vec3f(0,1,0))
end

function presetTextures()
  #= global =# texture_blocks = uploadTexture("blocks.png")
  #= global =# texture_heightMap = uploadTexture((1024,1024)) #uploadTextureGray("heightmap.png")
  #= global =# texture_screen = uploadTexture((512,512))
end

"""
TODO
"""
useProgram(program) = begin #= global =# current_program = program; glUseProgram(program) end

"""
TODO
"""
function use_program(program, f::Function)
  if program != current_program
    glCheck(glUseProgram(program))
  end
  glCheck(f())
  if program != current_program
    glCheck(glUseProgram(0))
  end
end

"""
TODO
"""
setMatrix(program, name, m) = begin cm = SMatrix{4,4,Float32}(m); glUniformMatrix4fv(glGetUniformLocation(program, name), 1, false, cm) end #const smatrix

"""
TODO
"""
function setMVP(program, mvp)
  use_program(program, () -> begin
    glCheck(setMatrix(program, "iMVP", mvp))
  end)
end

function setMode(name::String, value, mode=""; program=current_program)
  if program < 0 return end
  l = glGetUniformLocation(program, name)
  if l>-1
    elems=length(value)
    isArray = isa(value, AbstractArray{Float32,1}) || isa(value, AbstractArray{Float64,1})
    isMatrix = isa(value, AbstractArray{Float32,2}) || isa(value, AbstractArray{Float64,2})
    if isa(value, Integer) glUniform1i(l, value)
    elseif isa(value, AbstractFloat) glUniform1f(l, value)
    elseif isArray && elems==1 glUniform1fv(l, 1, Float32[value...])
    elseif isArray && elems==2 glUniform2fv(l, 1, Float32[value...])
    elseif isArray && elems==3 glUniform3fv(l, 1, Float32[value...])
    elseif isArray && elems==4 glUniform4fv(l, 1, Float32[value...])
    elseif isMatrix && elems==4 glUniformMatrix2fv(l, 1, false, Float32[value...])
    elseif isMatrix && elems==9 glUniformMatrix3fv(l, 1, false, Float32[value...])
    elseif isMatrix && elems==16 glUniformMatrix4fv(l, 1, false, Float32[value...])
    else warn("MODE($mode): $name with $(string(typeof(value))) for $elems elements is not implemented yet.")
    end
  end
  if mode != "" println("MODE(",stringColor(mode;color=:yellow),"): ",stringColor(value;color=:yellow)) end
end

"""
sets a mode in a shader.
"""
function setMode(program::Number, name::String, value, mode="")
  use_program(program, () -> begin
    setMode(name, value, mode; program=program)
  end)
end

"""
TODO
"""
function setFrustumMode()
  SetCamera(FRUSTUM, Vec3f(CAMERA.position), Vec3f(CAMERA.position+CameraManager.forward(CAMERA)), Vec3f(0,1,0))
  if !GPU_FRUSTUM
    updateChunk(mychunk)
    #= global =# uploaded = :UPDATE
  end
end

"""
TODO
"""
function updateChunk(this::Chunk)
  ##= global =# chunkData, chunkData_upload, planeData, boxData
  #println("update Chunk")

  if !GPU_FRUSTUM && FRUSTUM_CULLING
    #println("checkInFrustum")
    checkInFrustum(this, FRUSTUM)
  else
    #println("showAll")
    showAll(this)
  end

  #println("setChunkInstances")
  setChunkInstances(getData(this))
  setPlaneVertices(getVertices(FRUSTUM))
  setBoxVertices(getBox(FRUSTUM))
  
  #= global =# BLOCK_COUNT = this.fileredCount
  ##= global =# VERT_COUNT = this.verticesCount
  
end

function createChunk(this::Chunk)
  println("Create chunk & create blocks...")
  
  ChunkManager.reset(this; size=CHUNK_SIZE)
  
  #println("Set Chunk scenery")
    
  if SCENE == 0 createSingle(this)
  elseif SCENE == 1 createExample(this)
  else createLandscape(this)
  end
  
  update(this; unseen=HIDE_UNSEEN_CUBES)
  
  updateChunk(this)
  #= global =# uploaded = :CREATE
end

"""
TODO
"""
function chooseRenderMethod(method=RENDER_METHOD)
  if method != RENDER_METHOD #= global =# RENDER_METHOD = method end
  
  name =
  method == 1 ? "INSTANCES of POINTS + GEOMETRY SHADER" :
  method == 2 ? "INSTANCES of TRIANGLES" :
  method == 3 ? "INSTANCES of TRIANGLES + INDICIES" :
  method == 4 ? "TRIANGLES + INDICIES" :
  method == 5 ? "TRIANGLES" :
  method == 6 ? "TRIANGLES" :
  method == 7 ? "COMPUTED" :
  method == 8 ? "COMPUTED + INSTANCES" :
                "NOT DEFINED"
  
  
  println("CHUNK SIZE: ",stringColor(string(CHUNK_SIZE,"³");color=:yellow))
  println("SCENE: ",stringColor(SCENE;color=:yellow))
  println("METHOD(",stringColor(method;color=:yellow),"): ",stringColor(method," = ", name; color=:yellow))
  
  if name == "NOT DEFINED" return end

  #createChunk(mychunk)
  
  #= global =# uploaded = :YES
  #= global =# render_ready = false
end

render_init = false

  
chunk_pos = [
  Float32[0,0,0],
  Float32[1,0,0],Float32[-1,0,0],Float32[0,0,1],Float32[0,0,-1],Float32[-1,0,-1],Float32[1,0,1],Float32[-1,0,1],Float32[1,0,-1],
  Float32[2,0,0],Float32[-2,0,0],Float32[0,0,2],Float32[0,0,-2],Float32[-2,0,-2],Float32[2,0,2],Float32[-2,0,2],Float32[2,0,-2],
  Float32[2,0,1],Float32[2,0,-1],Float32[-2,0,1],Float32[-2,0,-1],Float32[1,0,2],Float32[-1,0,2],Float32[1,0,-2],Float32[-1,0,-2]
] * CHUNK_SIZE

CHUNKS = Chunk[Chunk(;id=i,pos=chunk_pos[i]) for i=1:1] #length(chunk_pos) #Array{ChunkD,1}(undef, length(centers))

CHUNK_COUNT = length(CHUNKS)
DEPTH_SIZE = max(WIDTH, HEIGHT) #256
DEPTH_SIZE_LOG2 = round(Integer,log2(DEPTH_SIZE)) #8
LOD_LEVELS = DEPTH_SIZE_LOG2 + 1

DISPATCH_RESETER = nothing
CHUNK_ALL_BUFFERS = []
CHUNK_BUFFERS = []
CHUNK_OCCLUDED_BUFFERS = []
DISPATCH_BUFFERS = []
CHUNK_COUNTERS = []
CHUNK_INDIRECT_DRAW_BUFFERS = []
CHUNK_COUNTERS=[]
DISPATCH_COUNTERS=[]
CHUNK_OBJECTS=[]
TRANSFORM_FEEDBACK_BUFFERS=[]

frameBuffers = zeros(Integer,LOD_LEVELS)
depthrenderbuffer = 0
CHUNK_DATA = nothing
ALL_CHUNK_SIZE = CHUNK3D_SIZE*(1+8+16+24+32+40)
CHUNK_BUFFERS_SIZE = sizeof(Float32)*3*2*ALL_CHUNK_SIZE

single_indirect = true
single_storage = true

function uploadData()
  glCheck()
  
  if !GPU_CHUNKS_INIT return end

  #=
  m=uploaded
  
  #chunk_instances = sdata(chunk_instances)
  #plane_vertices = sdata(plane_vertices)
  #box_vertices = sdata(box_vertices)
  =#
  #= global =# fileredCount = length(chunk_instances)
  #=
  if m == :UPDATE
    println("Upload data...")
    upload(chunkData, :instances, chunk_instances)
    if FRUSTUM_CULLING
      upload(planeData, :vertices, plane_vertices)
      upload(boxData, :vertices, box_vertices)
    end
    glCheck()
    return
  end
    
  method = RENDER_METHOD
  
  println("Link data...")
  if method == 1 linkData(chunkData, :points=>chunk_instances)
  elseif method == 2 linkData(chunkData, :vertices=>(DATA_CUBE,3), :instances=>chunk_instances)
  elseif method == 3 linkData(chunkData, :vertices=>(DATA_CUBE_VERTEX,3), :indicies=>(DATA_CUBE_INDEX,1,GL_ELEMENT_ARRAY_BUFFER, true), :instances=>chunk_instances)
  elseif method == 4 linkData(chunkData, :vertices=>(DATA_CUBE_VERTEX,3), :indicies=>(DATA_CUBE_INDEX,1,GL_ELEMENT_ARRAY_BUFFER, true))
  elseif method > 4 && method < 7 linkData(chunkData, :vertices=>(DATA_CUBE,3))
  end
  =#
  
  if GPU_CHUNKS_INIT
    #GL_DYNAMIC_COPY
     
    ARRAY_SIZE=6*128^3 #max: 128000000
    #DISPATH_SIZE = CHUNK2D_SIZE
  
    #= global =# DISPATCH_RESETER = createBuffers(GLuint[1,1,1],1; typ=GL_DISPATCH_INDIRECT_BUFFER, usage=GL_STREAM_READ)[1]
  
    #linkData(chunkData, :vertices=>(DATA_PLANE_VERTEX,3), :indicies=>(DATA_PLANE_INDEX,1,GL_ELEMENT_ARRAY_BUFFER, true), :instances=>chunk_instances)
    
    setFrustumMode()
    plane_vertices = getVertices(FRUSTUM)
    box_vertices = getBox(FRUSTUM)
    
    linkData(planeData,  :vertices=>(plane_vertices,3))
    linkData(boxData,  :vertices=>(box_vertices,3))
      
    if RENDER_METHOD >= 7 
      linkData(screenData, :vertices=>(DATA_PLANE2D_VERTEX_STRIP,2)) #:indicies=>(DATA_PLANE_INDEX,1,GL_ELEMENT_ARRAY_BUFFER, true))
    end
    
    if RENDER_METHOD == 8
    
      #linkData(chunkData,
      #:points=>zeros(Float32,ARRAY_SIZE),
      #:chunks_default=>chunk_instances,
      #:chunks_changed=>zeros(Float32,ARRAY_SIZE),
      #:points_default=>zeros(Float32,ARRAY_SIZE),
      #:indirect_dispatch=>(GLuint[1,1,1],1,GL_DISPATCH_INDIRECT_BUFFER, GL_STREAM_READ)
      #:counter=>(GLuint[0],1,GL_ATOMIC_COUNTER_BUFFER, GL_STREAM_READ),
      #:dispatchCounter=>(GLuint[0],1,GL_ATOMIC_COUNTER_BUFFER, GL_STREAM_READ),
      #:dispatch_reset=>(GLuint[1,1,1],1,GL_DISPATCH_INDIRECT_BUFFER, GL_STREAM_READ),
      #:indirect=>(GLuint[0,1,0,0,0],1,GL_DRAW_INDIRECT_BUFFER)
      #)
    
      linkData(indirectData)
      
      #= global =# CHUNK_COUNTERS = createBuffers(GLuint[0],2; typ=GL_ATOMIC_COUNTER_BUFFER, usage=GL_STREAM_READ)
      #= global =# DISPATCH_COUNTERS = createBuffers(GLuint[0],CHUNK_COUNT; typ=GL_ATOMIC_COUNTER_BUFFER, usage=GL_STREAM_READ)

      #= global =# CHUNK_DATA = createBuffers(zeros(Float32,6),1)[1]
      #= global =# CHUNK_OBJECTS = createArrayObjects(CHUNK_COUNT)
      
      default_data = zeros(Float32,ARRAY_SIZE);
     
      if single_storage
        maxsize = glGetIntegerval(GL_MAX_SHADER_STORAGE_BLOCK_SIZE)
        info("GL_MAX_SHADER_STORAGE_BLOCK_SIZE: $maxsize")
        max_chunks=40 #sizeof(Float32)*6*128^3*42 = 2113929216 bytes ~ 2.11 GB
        #= global =# CHUNK_ALL_BUFFERS = [createBuffer(default_data,max_chunks)]
        #= global =# CHUNK_BUFFERS = [createBuffer(default_data,max_chunks)]
        ##= global =# CHUNK_OCCLUDED_BUFFERS = [createBuffer(default_data,max_chunks)]
      else
        #= global =# CHUNK_ALL_BUFFERS = createBuffers(default_data,CHUNK_COUNT)
        #= global =# CHUNK_BUFFERS = createBuffers(default_data,CHUNK_COUNT)
      end
      
      ##= global =# TRANSFORM_FEEDBACK_BUFFERS = [createBuffer(default_data,1)]
      #= global =# DISPATCH_BUFFERS = createBuffers(GLuint[1,1,1],CHUNK_COUNT; typ=GL_DISPATCH_INDIRECT_BUFFER, usage=GL_STREAM_READ)
      
      if single_indirect
        #= global =# CHUNK_INDIRECT_DRAW_BUFFERS = [createBuffer(GLuint[CHUNK3D_SIZE,1,0,0,0],CHUNK_COUNT; typ=GL_DRAW_INDIRECT_BUFFER)]
      else
        #= global =# CHUNK_INDIRECT_DRAW_BUFFERS = createBuffers(GLuint[CHUNK3D_SIZE,1,0,0,0],CHUNK_COUNT; typ=GL_DRAW_INDIRECT_BUFFER)
      end
      
      #= global =# depthrenderbuffer = glGenRenderbuffer()
      #= global =# texture_depth = createTexture((WIDTH,HEIGHT);level=LOD_LEVELS) #DEPTH_SIZE

      glActiveTexture(GL_TEXTURE0)
      glBindTexture(GL_TEXTURE_2D, texture_depth)
      
      # Sampler object that is used during occlusion culling.
      # We want GL_LINEAR shadow mode (PCF), but no filtering between miplevels as we manually specify the miplevel in the compute shader.
      shadow_sampler = glGenSampler()
      glSamplerParameteri(shadow_sampler, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_NEAREST)
      glSamplerParameteri(shadow_sampler, GL_TEXTURE_MAG_FILTER, GL_LINEAR)
      glSamplerParameteri(shadow_sampler, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE)
      glSamplerParameteri(shadow_sampler, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE)
      glSamplerParameteri(shadow_sampler, GL_TEXTURE_COMPARE_MODE, GL_COMPARE_REF_TO_TEXTURE)
      glSamplerParameteri(shadow_sampler, GL_TEXTURE_COMPARE_FUNC, GL_LEQUAL)
      
      frameBuffers=zeros(GLuint,LOD_LEVELS)
      glGenFramebuffers(LOD_LEVELS, frameBuffers)
      
      for lod=1:LOD_LEVELS
        ##= global =# frameBuffers[lod] = glGenFramebuffer()
        glBindFramebuffer(GL_FRAMEBUFFER, frameBuffers[lod])
        glFramebufferTexture2D(GL_FRAMEBUFFER, GL_DEPTH_STENCIL_ATTACHMENT, GL_TEXTURE_2D, texture_depth, lod-1)
        #glFramebufferTexture(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, texture_depth, 0)
        
        ##glBindRenderbuffer(GL_RENDERBUFFER, depthrenderbuffer)
        ##glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT, WIDTH, HEIGHT)
        ##glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, depthrenderbuffer)
            
        #glFramebufferTexture(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, texture_depth, 0) #GL_COLOR_ATTACHMENT0
        ##glDrawElementsIndirect(GL_POINTS, GL_UNSIGNED_INT, C_NULL)
        ##glDrawBuffers(1, GLenum[GL_COLOR_ATTACHMENT0])
        ##if(glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE) return false;
          
        status = glCheckFramebufferStatus(GL_FRAMEBUFFER)
        if status != GL_FRAMEBUFFER_COMPLETE error("Framebuffer is incomplete!") end
      end
      glBindFramebuffer(GL_FRAMEBUFFER, 0)
    end
    
    glBindTexture(GL_TEXTURE_2D, 0)
  end
  
  reloadShaderPrograms()
  
  if !render_init #= global =# render_init = true end
  if !render_ready #= global =# render_ready = true end
  #= global =# uploaded=:NOTHING
end

function reloadShaderProgram(program::Symbol, shaders::AbstractArray; transformfeedback=false)
  result=false
  try
    p = createShaderProgram(program, shaders; transformfeedback=transformfeedback)
    if p >= 0
      glCheck(glUseProgram(0))
      glCheck(glDeleteProgram(programs[program]))
      #= global =# programs[program]=p
      result=true
    end
  catch e
  end
  result
end

function bindBuffers()
  #if GPU_CHUNKS
    #use_program(programs[:COMPUTE_CHUNKS]s, () -> begin
      #glBindBuffer(GL_DISPATCH_INDIRECT_BUFFER , indirectData.arrays[:indirect_dispatch].refID)
      #glBindBufferBase(GL_ATOMIC_COUNTER_BUFFER, 0, indirectData.arrays[:counter].refID)
      #glBindBufferBase(GL_SHADER_STORAGE_BUFFER, 0, indirectData.arrays[:chunks_default].refID)
      #glBindBufferBase(GL_SHADER_STORAGE_BUFFER, 1, indirectData.arrays[:points_default].refID)
    #end)
  #end
  
  #use_program(programs[:INSTANCES], () -> begin
    #glBindBuffer(GL_DISPATCH_INDIRECT_BUFFER , indirectData.arrays[:indirect_dispatch_instances].refID)
    #glBindBufferBase(GL_ATOMIC_COUNTER_BUFFER, 0, indirectData.arrays[:indirect].refID)
    #glBindBufferBase(GL_SHADER_STORAGE_BUFFER, 0, indirectData.arrays[:points_default].refID)
    #glBindBufferBase(GL_SHADER_STORAGE_BUFFER, 1, indirectData.arrays[:points].refID)
  #end)
end

global_vars=Dict{Symbol,Any}()

function reloadShaderPrograms()
  method = RENDER_METHOD
  #= global =# global_vars[:CHUNK_SIZE] = CHUNK_SIZE
  #= global =# global_vars[:CHUNK1D_SIZE] = CHUNK1D_SIZE
  #= global =# global_vars[:CHUNK2D_SIZE] = CHUNK2D_SIZE
  #= global =# global_vars[:CHUNK3D_SIZE] = CHUNK3D_SIZE

  println("Load shader files...")
  shaders = loadShaders(global_vars)
  
  INST_VSH = shaders[:INST_VSH]
  INST_VSH_GSH = shaders[:INST_VSH_GSH]
  INST_GSH = shaders[:INST_GSH]
  INST_FSH = shaders[:INST_FSH]
  VSH_TEXTURE = shaders[:VSH_TEXTURE]
  VSH = shaders[:VSH]
  FSH = shaders[:FSH]
  GSH = shaders[:GSH]
  CSH = shaders[:CSH]
  SCREEN_VSH = shaders[:SCREEN_VSH]
  SCREEN_FSH = shaders[:SCREEN_FSH]
  INST_CSH = shaders[:INST_CSH]
  CHUNKS_CSH = shaders[:CHUNKS_CSH]
  CHANGE_CHUNKS_CSH = shaders[:CHANGE_CHUNKS_CSH]
  INST_VSH_CSH_GSH = shaders[:INST_VSH_CSH_GSH]
  BG_FSH = shaders[:BG_FSH]
  FG_FSH = shaders[:FG_FSH]
  DEPTH_VSH = shaders[:DEPTH_VSH]
  DEPTH_FSH = shaders[:DEPTH_FSH]
  DEPTH_GSH = shaders[:DEPTH_GSH]
  DEPTH_MIP_FSH = shaders[:DEPTH_MIP_FSH]
  RASTER_VSH = shaders[:RASTER_VSH]
  RASTER_FSH = shaders[:RASTER_FSH]
  RASTER_GSH = shaders[:RASTER_GSH]
  
  println("Create & Compile shader programs...")
  program_data = [VSH, FSH]
  
  if method < 7
    if method == 1 program_data = [INST_VSH_GSH, INST_FSH, INST_GSH]
    elseif method > 1 && method <= 3 program_data = [INST_VSH, INST_FSH]
    elseif method == 4 program_data = [VSH_TEXTURE, INST_FSH]
    elseif method == 5 program_data = [VSH_TEXTURE, INST_FSH]
    elseif method == 6 program_data = [VSH, FSH]
    end
  end
  
  #= global =# reloadShaderProgram(:CHUNKS, program_data)
  #= global =# reloadShaderProgram(:NORMAL, [VSH, FSH])
  #= global =# reloadShaderProgram(:SCREEN, [SCREEN_VSH, SCREEN_FSH])
  #= global =# reloadShaderProgram(:COMPUTE, [CSH])
  ##= global =# reloadShaderProgram(:COMPUTE_CHUNKS, [CHUNKS_CSH])
  #= global =# reloadShaderProgram(:CHANGE_CHUNKS, [CHANGE_CHUNKS_CSH])
  ##= global =# reloadShaderProgram(:INSTANCES, [INST_CSH])
  #= global =# reloadShaderProgram(:INDIRECT, [INST_VSH_CSH_GSH, INST_FSH, INST_GSH])
  #= global =# reloadShaderProgram(:BG, [VSH, BG_FSH])
  #= global =# reloadShaderProgram(:FG, [VSH, FG_FSH])
  #= global =# reloadShaderProgram(:DEPTH, [INST_VSH_CSH_GSH, DEPTH_FSH, DEPTH_GSH])
  #= global =# reloadShaderProgram(:DEPTH_MIP, [SCREEN_VSH, DEPTH_MIP_FSH])
  #= global =# reloadShaderProgram(:RASTER, [RASTER_VSH, RASTER_FSH, RASTER_GSH];transformfeedback=false)
  
  println("bind Buffers...")
  bindBuffers()
  
  println("set Attributes ...")
  glBindVertexArray(CHUNK_OBJECTS[1])
  setAttributes(CHUNK_DATA, programs[:INDIRECT], [("iInstancePos",Float32,3,0),("iInstanceFlags",Float32,3,0)])
  glBindVertexArray(0)
  #setAttributes(CHUNK_OBJECTS[1:1], CHUNK_BUFFERS[1:1], programs[:INDIRECT])
  #setAttributes(indirectData, programs[:INDIRECT])
  setAttributes(planeData, programs[:NORMAL])
  setAttributes(boxData, programs[:NORMAL])
  setAttributes(screenData, programs[:SCREEN])
  setAttributes(chunkData, programs[:CHUNKS])
  #setAttributes(screenData, programs[:BG])
  #setAttributes(screenData, programs[:FG])
  #setAttributes(screenData, programs[:DEPTH])
  
  println("set Uniforms...")
  
  #= global =# location_position = glGetUniformLocation(programs[:CHUNKS], "iPosition")
  #= global =# location_texindex = glGetUniformLocation(programs[:CHUNKS], "iTexIndex")
  
  #setMVP(programs[:INDIRECT], MVP)
  #setMVP(programs[:CHUNKS], MVP)
  #setMode(programs[:INDIRECT], "iMVP", MVP)
  #setMode(programs[:CHUNKS], "iMVP", MVP)
  
  setMode(programs[:CHUNKS], "iUseLight", LIGHTMODE)
  setMode(programs[:CHUNKS], "iUseTexture", TEXTUREMODE)
end

GPU_CHUNKS_INIT = true
CAMERA_UPDATED = true

"""
TODO
"""
function checkForUpdate()
  uploadData()
  
  #= global =# keyValue, #= global =# keyPressed = getKey()
  
  if keyPressed
  
    if keyValue == 80 #p
      setPosition(CAMERA,[0f0,0,0])
      
    elseif keyValue == 81 #q
      #= global =# WIREFRAME=!WIREFRAME
      info("WIREFRAME: $WIREFRAME")
      
    elseif keyValue == 84 && render_ready #t
      #= global =# TEXTUREMODE=!TEXTUREMODE
      info("TEXTUREMODE: $TEXTUREMODE")
      setMode(programs[:CHUNKS], "iUseTexture", TEXTUREMODE, "TEXTURE")
      
    elseif keyValue == 76 && render_ready #l
      #= global =# LIGHTMODE=!LIGHTMODE
      info("LIGHTMODE: $LIGHTMODE")
      setMode(programs[:CHUNKS], "iUseLight", LIGHTMODE, "LIGHT")

    elseif keyValue == 82 #r
      #chooseRenderMethod()
      reloadShaderPrograms()
      #= global =# GPU_CHUNKS_INIT = true
      
    elseif (keyValue >= 290 && keyValue <= 301) # F1 - F12
      chooseRenderMethod(keyValue - 289)
      
    elseif keyValue >= 49 && keyValue <= 57 #1-9
      #= global =# CHUNK_SIZE = 2^(keyValue-49)
      info("CHUNK_SIZE: $CHUNK_SIZE")
      reloadShaderPrograms()
      #= global =# GPU_CHUNKS_INIT = true
      
    elseif keyValue == 48 #0
      #= global =# CHUNK_SIZE = 2^9
      info("CHUNK_SIZE: $CHUNK_SIZE")
      reloadShaderPrograms()
      #= global =# GPU_CHUNKS_INIT = true
      
    elseif keyValue == 45 #ß
      #= global =# CHUNK_SIZE = 2^10
      info("CHUNK_SIZE: $CHUNK_SIZE")
      reloadShaderPrograms()
      #= global =# GPU_CHUNKS_INIT = true

    elseif keyValue == 66 #b
      #= global =# SCENE = 0
      chooseRenderMethod()
    elseif keyValue == 78 #n
      #= global =# SCENE = 1
      chooseRenderMethod()
    elseif keyValue == 77 #m
      #= global =# SCENE = 2
      chooseRenderMethod()
      
    elseif keyValue == 70 #f
      #= global =# CAM_LOCK = !CAM_LOCK
      info("CAM LOCK: $CAM_LOCK")
    elseif keyValue == 86 #v
      #= global =# FRUSTUM_CULLING = !FRUSTUM_CULLING
    elseif keyValue == 79 #o
      #= global =# HIDE_UNSEEN_CUBES = !HIDE_UNSEEN_CUBES
    end
  end
    
  if keyPressed resetKeys() end
end

function setFrustumProgram(program)
  use_program(program, () -> begin
    dirs=[x.mNormal for (_,x) in FRUSTUM.planes] #getDirections(FRUSTUM)
    dists=[x.d for (_,x) in FRUSTUM.planes]  #getDistances(FRUSTUM)
    glCheck(glUniform1i(glGetUniformLocation(program, "frustum"), true))
    if !CAM_LOCK
      glCheck(glUniform3fv(glGetUniformLocation(program, "frustum_dirs"), length(dirs), dirs))
      glCheck(glUniform1fv(glGetUniformLocation(program, "frustum_dists"), length(dists), dists))
    end
  end)
end

## PROGRAM

"""
TODO
"""
function loop()
  println("---------------------------------------------------------------------")
  println("Start Program @ ", Dates.time())
  InteractiveUtils.versioninfo()
  
  println("Create Window...")
  # remove previous Window
  cleanUp()
  
  # OS X-specific GLFW hints to initialize the correct version of OpenGL
  GLFW.Init()
      
  # Create a windowed mode window and its OpenGL context
  WINDOW = GLFW.CreateWindow(WIDTH, HEIGHT, "OpenGL Example")

  # Make the window's context current
  GLFW.MakeContextCurrent(WINDOW)

  GLFW.SetWindowSize(WINDOW, WIDTH, HEIGHT) # Seems to be necessary to guarantee that window > 0
  rezizeWindow(WINDOW, WIDTH,HEIGHT)

  # Window settings
  GLFW.SwapInterval(0) # intervall between canvas images (min. 2 images)

  # Graphcis Settings
  GLFW.WindowHint(GLFW.OPENGL_DEBUG_CONTEXT,true) #show debug
  #GLFW.WindowHint(GLFW.SAMPLES,4)

  # OpenGL Version
  GLFW.WindowHint(GLFW.CONTEXT_VERSION_MAJOR,4)
  GLFW.WindowHint(GLFW.CONTEXT_VERSION_MINOR,6)
  
  # Event Hooks
  GLFW.SetWindowFocusCallback(WINDOW,OnFocus)
  GLFW.SetCursorPosCallback(WINDOW, OnCursorPos)
  GLFW.SetKeyCallback(WINDOW, OnKey)
  GLFW.SetMouseButtonCallback(WINDOW, OnMouseKey)

  #setEventCallbacks(OnCursorPos,OnKey,OnMouseKey)

  GLFW.ShowWindow(WINDOW)
  global GRAPHICS_DRIVER_INITALIZED = true
  glDebug(true) # set debugging

  glinfo = createcontextinfo()

  println("OpenGL $(stringColor(glinfo[:gl_version];color=:red))")
  println("GLSL $(stringColor(glinfo[:glsl_version];color=:red))")
  println("Vendor $(stringColor(glinfo[:gl_vendor];color=:red))")
  println("Renderer $(stringColor(glinfo[:gl_renderer];color=:red))")
  showExtensions()
  println("---------------------------------------------------------------------")
  sleep(0)
  
  #------------------------------------------------------------------------------------

  init()
  
  #------------------------------------------------------------------------------------

  #const mmvp = SMatrix{4,4,Float32}(CAMERA.MVP)

  #------------------------------------------------------------------------------------

  glEnable(GL_DEPTH_TEST)
  glEnable(GL_BLEND)
  glEnable(GL_CULL_FACE)
  
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
  #glBlendEquation(GL_FUNC_ADD)
  #glFrontFace(GL_CCW)
  
  glCullFace(GL_BACK) #default: GL_BACK
  glDepthMask(GL_TRUE) #default: GL_TRUE
  glDepthFunc(GL_LEQUAL) #default: GL_LESS
  
  #glPolygonMode(GL_FRONT_AND_BACK, GL_LINE)#GL_FILL,GL_LINE
  glClearColor(0.0, 0.0, 0.0, 0.0)

  # Loop until the user closes the window
  #render = function(x)
    #mvp = mmvp*MMatrix{4,4,Float32}(unsafe_wrap(Array, mvp, (4,4)))
    #setMVP(CAMERA.MVP*translation([c.x,c.y,c.z]))

    #glUniformMatrix4fv(location_mvp, 1, false, x.mvp)
    #glDrawElements(GL_TRIANGLES, chunkData.draw.count, GL_UNSIGNED_INT, C_NULL )
    #glDrawArrays(GL_TRIANGLES, 0, chunkData.draw.count)
  #  nothing
  #end

  #=
  if use_geometry_shader
    loopBlocks() = render(mychunk.childs[1])
  else
    if compileAndLink
      objptr = createLoop(1,refblocks,render) #compileAndLink
      loopBlocks() = loopByObject(objptr) #compileAndLink
    else
      loopBlocks() = for b in mychunk.childs; render(b); end
    end
  end
  =#

  SLEEP=0 #1f0/200

  i=0
  
  function checkCamera()
    if GPU_CHUNKS_INIT || OnUpdate(CAMERA)
      #println(CAMERA.position)
      #if !CAM_LOCK
        if RENDER_METHOD < 7 
          #setMVP(programs[:CHUNKS], CAMERA.MVP)
          #setMVP(programs[:NORMAL], CAMERA.MVP)
          #setFrustumProgram(programs[:CHUNKS])
        end
      #end
      setFrustumMode()
      #= global =# CAMERA_UPDATED=true
    end
  end
  
  #frameBufferMax = length(CHUNKS)
  #frameBufferCounter=0
  itime = 0

  INDIRECT_DRAW_BUFFER_SIZE=sizeof(GLuint[0,1,0,0,0])
  
  VISIBLE_CHUNKS=Array{Chunk,1}(undef, length(CHUNKS))
  VISIBLE_CHUNKS_COUNT = 0
  
  atrb=[("iInstancePos",Float32,3,0),("iInstanceFlags",Float32,3,0)]
  buffsize=sizeof(Float32)*3*2*CHUNK3D_SIZE

  function gpu_updateChunks()
    if GPU_CHUNKS_INIT || CAMERA_UPDATED
      #SetCamera(FRUSTUM, Vec3f(CAMERA.position), Vec3f(CAMERA.position+CameraManager.forward(CAMERA)), Vec3f(0,1,0))
    
      useProgram(programs[:CHANGE_CHUNKS])
      
      setMode("iTime", itime)
      setMode("iCamPos", CAMERA.position)
      setMode("iCamAng", CAMERA.rotation)
      setMode("iProj", CAMERA.projectionMat)
      setMode("iView", CAMERA.viewMat)
      setMode("iMVP", CAMERA.MVP)
      
      setFrustumProgram(programs[:CHANGE_CHUNKS])
      
      CHUNK_COUNTER=CHUNK_COUNTERS[1]
      #DISPATCH_BUFFER=DISPATCH_BUFFERS[1]
      CHUNK_INDIRECT_DRAW_BUFFER = CHUNK_INDIRECT_DRAW_BUFFERS[1]

      #glBindBufferBase(GL_ATOMIC_COUNTER_BUFFER, 0, DISPATCH_BUFFER.refID) #DISPATH
      glBindBufferBase(GL_ATOMIC_COUNTER_BUFFER, 3, CHUNK_COUNTER.refID) #counter
      
      #buf = glMapBufferRange(GL_ATOMIC_COUNTER_BUFFER, 0, sizeof(GLuint), GL_MAP_WRITE_BIT | GL_MAP_INVALIDATE_BUFFER_BIT | GL_MAP_UNSYNCHRONIZED_BIT)
      VISIBLE_CHUNKS_COUNT = 0
      i = 0
      
      setMode("iCulling", 0)
          
      for chunk in CHUNKS
        #visible=inFrustum(chunk,FRUSTUM)
        #if !GPU_CHUNKS_INIT && !visible continue end
        
        #if visible
          #if VISIBLE_CHUNKS_COUNT > 0 break end
          VISIBLE_CHUNKS_COUNT += 1
          VISIBLE_CHUNKS[VISIBLE_CHUNKS_COUNT] = chunk
        #end
        
        i += 1

        setMode("iCenter", chunk.pos)
        
        DISPATCH_BUFFER=DISPATCH_BUFFERS[chunk.id]
        DISPATCH_COUNTER=DISPATCH_COUNTERS[chunk.id]

        glBindBufferBase(GL_ATOMIC_COUNTER_BUFFER, 1, DISPATCH_COUNTER.refID) #dispatchCount (used after GPU_CHUNKS_INIT)
        
        if single_indirect
          glBindBufferRange(GL_ATOMIC_COUNTER_BUFFER, 2, CHUNK_INDIRECT_DRAW_BUFFERS[1].refID, (i-1)*INDIRECT_DRAW_BUFFER_SIZE, sizeof(GLuint))
        else
          glBindBufferBase(GL_ATOMIC_COUNTER_BUFFER, 2, CHUNK_INDIRECT_DRAW_BUFFERS[chunk.id].refID) #instanceCount
        end
        
        if single_storage
          #glBindBufferRange(GL_SHADER_STORAGE_BUFFER, 0, CHUNK_ALL_BUFFERS[1].refID, (i-1)*CHUNK_BUFFERS_SIZE, CHUNK_BUFFERS_SIZE)
          #glBindBufferRange(GL_SHADER_STORAGE_BUFFER, 1, CHUNK_BUFFERS[1].refID, (i-1)*CHUNK_BUFFERS_SIZE, CHUNK_BUFFERS_SIZE)
          glBindBufferBase(GL_SHADER_STORAGE_BUFFER, 0, CHUNK_ALL_BUFFERS[1].refID)
          glBindBufferBase(GL_SHADER_STORAGE_BUFFER, 1, CHUNK_BUFFERS[1].refID)
        else
          glBindBufferBase(GL_SHADER_STORAGE_BUFFER, 0, CHUNK_ALL_BUFFERS[chunk.id].refID)
          glBindBufferBase(GL_SHADER_STORAGE_BUFFER, 1, CHUNK_BUFFERS[chunk.id].refID)
        end
        
        if GPU_CHUNKS_INIT
          glBindBufferBase(GL_ATOMIC_COUNTER_BUFFER, 0, DISPATCH_BUFFER.refID) #DISPATH
          glBindBuffer(GL_DISPATCH_INDIRECT_BUFFER , DISPATCH_RESETER.refID)
          setMode("STATE", -1) #RESET / SET DISPATCH VALUE
          glDispatchComputeIndirect(C_NULL)
          glMemoryBarrier(GL_COMMAND_BARRIER_BIT | GL_VERTEX_ATTRIB_ARRAY_BARRIER_BIT | GL_SHADER_STORAGE_BARRIER_BIT | GL_ATOMIC_COUNTER_BARRIER_BIT)
          glBindBufferBase(GL_ATOMIC_COUNTER_BUFFER, 0, 0)
        end
        
        glBindBuffer(GL_DISPATCH_INDIRECT_BUFFER , DISPATCH_BUFFER.refID)
        setMode("STATE", GPU_CHUNKS_INIT ? 0 : 1)
        glDispatchComputeIndirect(C_NULL)
        glMemoryBarrier(GL_COMMAND_BARRIER_BIT | GL_VERTEX_ATTRIB_ARRAY_BARRIER_BIT | GL_SHADER_STORAGE_BARRIER_BIT | GL_ATOMIC_COUNTER_BARRIER_BIT)
      end

      #glDrawBuffer(GL_NONE)
      #glReadBuffer(GL_NONE)
      #glReadBuffer(GL_BACK)
      #glCopyTexImage2D(GL_TEXTURE_2D, 0, GL_DEPTH_COMPONENT, 0, 0, WIDTH, HEIGHT, 0)
      
      glBindBuffer(GL_DISPATCH_INDIRECT_BUFFER , 0)
      glBindBufferBase(GL_SHADER_STORAGE_BUFFER, 0, 0)
      glBindBufferRange(GL_SHADER_STORAGE_BUFFER, 0, 0, 0, 0)
      
      ######################################################################
      use_depth = true
      if use_depth
      # depth buffer
      useProgram(programs[:DEPTH])
      
      # Render occlusion geometry to miplevel 0
      glBindFramebuffer(GL_FRAMEBUFFER, frameBuffers[1])
      glActiveTexture(GL_TEXTURE0)
      glBindTexture(GL_TEXTURE_2D, texture_depth)
      
      #glClearDepth(1.0)
      glDepthMask(GL_TRUE) #default: GL_TRUE
      glDepthFunc(GL_LESS) #default: GL_LESS
      glDepthRange(0.0, 1.0)
      
      glClear(GL_DEPTH_BUFFER_BIT | GL_STENCIL_BUFFER_BIT)
      glViewport(0, 0, WIDTH, HEIGHT) #DEPTH_SIZE
      setMode("iDepth", false)
      drawChunk(Float32[0,0,0])
      glMemoryBarrier(GL_SHADER_IMAGE_ACCESS_BARRIER_BIT) # make sure writing to image has finished before read
      
      glActiveTexture(GL_TEXTURE0)
      glBindTexture(GL_TEXTURE_2D, texture_depth)
      setMode("iDepth", true)
      drawChunk(Float32[0,0,0])
      glBindFramebuffer(GL_FRAMEBUFFER, 0)
      glMemoryBarrier(GL_SHADER_IMAGE_ACCESS_BARRIER_BIT) # make sure writing to image has finished before read
      
      ############################################################################
#=
      glActiveTexture(GL_TEXTURE0)
      glBindTexture(GL_TEXTURE_2D, texture_depth)
     
      # Render occlusion geometry to miplevel > 0
      useProgram(programs[:DEPTH_MIP])
      glMemoryBarrier(GL_SHADER_IMAGE_ACCESS_BARRIER_BIT) # make sure writing to image has finished before read
      glActiveTexture(GL_TEXTURE0)
      glBindTexture(GL_TEXTURE_2D, texture_depth)
      glDepthFunc(GL_ALWAYS)
      
      glBindVertexArray(screenData.vao)
      
      currentWidth = WIDTH
      currentHeight = HEIGHT

      for lod=2:LOD_LEVELS
        currentWidth = round(Integer, currentWidth / 2.0)
        currentHeight = round(Integer, currentHeight / 2.0)
        if currentWidth <= 0 currentWidth = 1 end
        if currentHeight <= 0 currentHeight = 1 end
      
        glBindFramebuffer(GL_FRAMEBUFFER, frameBuffers[lod])
        glClear(GL_DEPTH_BUFFER_BIT | GL_STENCIL_BUFFER_BIT)
        glViewport(0,0, currentWidth, currentHeight) #DEPTH_SIZE >> lod
        
        # Need to do this to ensure that we cannot possibly read from the miplevel we are rendering to.
        # Otherwise, we have undefined behavior.
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_BASE_LEVEL, lod - 2)
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAX_LEVEL, lod - 2)
        
        glDrawArrays(GL_TRIANGLE_STRIP, 0, screenData.draw.count)
      end
      
      glBindVertexArray(0)
      glBindFramebuffer(GL_FRAMEBUFFER, 0)
      glDepthFunc(GL_LEQUAL)

      # Restore miplevels. MAX_LEVEL will be clamped accordingly.
      glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_BASE_LEVEL, 0)
      glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAX_LEVEL, LOD_LEVELS-1)

      glViewport(0, 0, WIDTH, HEIGHT)
      glMemoryBarrier(GL_SHADER_IMAGE_ACCESS_BARRIER_BIT) # make sure writing to image has finished before read
      
    =#
      ######################################################################

       # Bind Hi-Z depth map
      glActiveTexture(GL_TEXTURE0)
      glBindTexture(GL_TEXTURE_2D, texture_depth)
      #glBindSampler(0, shadow_sampler)
      
      ############################################################################
      end
      
      # rasterize_occluders
      rasterize=true
      
      if rasterize
        #glEnable( GL_POLYGON_OFFSET_FILL )
        #glPolygonOffset(-1,-1)
        #glEnable(GL_RASTERIZER_DISCARD)

        glBindFramebuffer(GL_FRAMEBUFFER, frameBuffers[1])
        #glDepthMask(GL_FALSE)
        glDepthFunc(GL_LESS)
        #glColorMask(GL_FALSE,GL_FALSE,GL_FALSE,GL_FALSE)

        useProgram(programs[:RASTER])
        setMode("iTime", itime)
        setMode("iResolution", Float32[WIDTH,HEIGHT])
        setMode("iCamPos", CAMERA.position)
        setMode("iCamAng", CAMERA.rotation)
        setMode("iProj", CAMERA.projectionMat)
        setMode("iView", CAMERA.viewMat)
        setMode("iMVP", CAMERA.MVP)

        glBindBufferBase(GL_SHADER_STORAGE_BUFFER, 0, CHUNK_BUFFERS[1].refID)
        glBindBuffer(GL_DRAW_INDIRECT_BUFFER , CHUNK_INDIRECT_DRAW_BUFFERS[1].refID)
        glMultiDrawArraysIndirect(GL_POINTS,C_NULL,VISIBLE_CHUNKS_COUNT,INDIRECT_DRAW_BUFFER_SIZE)
        
        #glDepthMask(GL_TRUE)
        #glColorMask(GL_TRUE,GL_TRUE,GL_TRUE,GL_TRUE)

        #glPolygonOffset(0,0)
        #glDisable(GL_POLYGON_OFFSET_FILL)
 
        glBindBufferBase(GL_SHADER_STORAGE_BUFFER, 0, 0)
        glBindBuffer(GL_DRAW_INDIRECT_BUFFER , 0)
        glBindFramebuffer(GL_FRAMEBUFFER, 0)
        glMemoryBarrier(GL_SHADER_IMAGE_ACCESS_BARRIER_BIT)
        glMemoryBarrier(GL_SHADER_STORAGE_BARRIER_BIT)
        #glDisable(GL_RASTERIZER_DISCARD)
      end
      
      ############################################################################ 
      
      useProgram(programs[:CHANGE_CHUNKS])
      
      setMode("iRasterrize", rasterize)
      
      DISPATCH_BUFFER=DISPATCH_BUFFERS[1]
      
      glBindBufferBase(GL_ATOMIC_COUNTER_BUFFER, 0, DISPATCH_BUFFER.refID)
      glBindBufferBase(GL_ATOMIC_COUNTER_BUFFER, 1, DISPATCH_COUNTERS[1].refID)
      
      #=
      glBindBuffer(GL_DISPATCH_INDIRECT_BUFFER , DISPATCH_RESETER.refID)
      setMode("STATE", -3) #RESET / SET DISPATCH VALUE
      glDispatchComputeIndirect(C_NULL)
      glMemoryBarrier(GL_COMMAND_BARRIER_BIT | GL_VERTEX_ATTRIB_ARRAY_BARRIER_BIT | GL_SHADER_STORAGE_BARRIER_BIT | GL_ATOMIC_COUNTER_BARRIER_BIT)
      glBindBuffer(GL_DISPATCH_INDIRECT_BUFFER , DISPATCH_BUFFER.refID)
      =#
      
      glBindBufferBase(GL_SHADER_STORAGE_BUFFER, 0, CHUNK_ALL_BUFFERS[1].refID)
      glBindBufferBase(GL_SHADER_STORAGE_BUFFER, 1, CHUNK_BUFFERS[1].refID)
      
      for i=1:VISIBLE_CHUNKS_COUNT
        chunk=VISIBLE_CHUNKS[i]
         
        setMode("iCenter", chunk.pos)
        
        #DISPATCH_BUFFER=DISPATCH_BUFFERS[chunk.id]
        #glBindBufferBase(GL_ATOMIC_COUNTER_BUFFER, 0, DISPATCH_BUFFER.refID) #DISPATH
        #glBindBufferBase(GL_ATOMIC_COUNTER_BUFFER, 1, DISPATCH_COUNTERS[chunk.id].refID) #dispatchCount (used after GPU_CHUNKS_INIT)
        
        if single_indirect
          glBindBufferRange(GL_ATOMIC_COUNTER_BUFFER, 2, CHUNK_INDIRECT_DRAW_BUFFERS[1].refID, (i-1)*INDIRECT_DRAW_BUFFER_SIZE, sizeof(GLuint))
        else
          glBindBufferBase(GL_ATOMIC_COUNTER_BUFFER, 2, CHUNK_INDIRECT_DRAW_BUFFERS[chunk.id].refID) #instanceCount
        end

        if single_storage
          #glBindBufferRange(GL_SHADER_STORAGE_BUFFER, 0, CHUNK_ALL_BUFFERS[1].refID, (i-1)*CHUNK_BUFFERS_SIZE, CHUNK_BUFFERS_SIZE)
          #glBindBufferRange(GL_SHADER_STORAGE_BUFFER, 1, CHUNK_BUFFERS[1].refID, (i-1)*CHUNK_BUFFERS_SIZE, CHUNK_BUFFERS_SIZE)
          
          #glBindBufferBase(GL_SHADER_STORAGE_BUFFER, 0, CHUNK_ALL_BUFFERS[1].refID)
          #glBindBufferBase(GL_SHADER_STORAGE_BUFFER, 1, CHUNK_BUFFERS[1].refID)
        else
          #glBindBufferBase(GL_SHADER_STORAGE_BUFFER, 0, CHUNK_ALL_BUFFERS[chunk.id].refID)
          #glBindBufferBase(GL_SHADER_STORAGE_BUFFER, 1, CHUNK_BUFFERS[chunk.id].refID)
        end
        
        glBindBuffer(GL_DISPATCH_INDIRECT_BUFFER , DISPATCH_RESETER.refID)
        setMode("STATE", -2) # SET DISPATCH VALUE
        glDispatchComputeIndirect(C_NULL)
        glMemoryBarrier(GL_COMMAND_BARRIER_BIT | GL_VERTEX_ATTRIB_ARRAY_BARRIER_BIT | GL_SHADER_STORAGE_BARRIER_BIT | GL_ATOMIC_COUNTER_BARRIER_BIT)
        glBindBuffer(GL_DISPATCH_INDIRECT_BUFFER , DISPATCH_BUFFER.refID)
        
        setMode("STATE", 2)
        glDispatchComputeIndirect(C_NULL)
        glMemoryBarrier(GL_COMMAND_BARRIER_BIT | GL_VERTEX_ATTRIB_ARRAY_BARRIER_BIT | GL_SHADER_STORAGE_BARRIER_BIT | GL_ATOMIC_COUNTER_BARRIER_BIT)
      end

      #=
      useProgram(programs[:CHANGE_CHUNKS])
      setMode("iCulling", 1) # Dispatch occlusion culling job

      setMode("STATE", -3) # SET DISPATCH VALUE
      glBindBuffer(GL_DISPATCH_INDIRECT_BUFFER , DISPATCH_RESETER.refID)
      glBindBufferBase(GL_ATOMIC_COUNTER_BUFFER, 2, CHUNK_INDIRECT_DRAW_BUFFER.refID)
      glDispatchComputeIndirect(C_NULL)
      glMemoryBarrier(GL_COMMAND_BARRIER_BIT | GL_VERTEX_ATTRIB_ARRAY_BARRIER_BIT | GL_SHADER_STORAGE_BARRIER_BIT | GL_ATOMIC_COUNTER_BARRIER_BIT)
      
      CHUNK_BUFFER=CHUNK_BUFFERS[1]
      glBindBufferBase(GL_SHADER_STORAGE_BUFFER, 1, CHUNK_BUFFER.refID)
      =#

      #=
      glBindBufferBase(GL_ATOMIC_COUNTER_BUFFER, 0, DISPATCH_BUFFER.refID) #DISPATH
      glBindBufferBase(GL_ATOMIC_COUNTER_BUFFER, 3, CHUNK_COUNTER.refID) #counter
        
      for chunk=1:CHUNK_COUNT
        setMode("iCenter", CHUNKS[chunk].pos)
        
        CHUNK_ALL_BUFFER=CHUNK_ALL_BUFFERS[chunk]
        CHUNK_BUFFER=CHUNK_BUFFERS[chunk]
        CHUNK_INDIRECT_DRAW_BUFFER = CHUNK_INDIRECT_DRAW_BUFFERS[chunk]
        DISPATCH_COUNTER=DISPATCH_COUNTERS[chunk]
        
        #glBindBufferBase(GL_ATOMIC_COUNTER_BUFFER, 0, DISPATCH_BUFFER.refID) #DISPATH
        glBindBufferBase(GL_ATOMIC_COUNTER_BUFFER, 1, DISPATCH_COUNTER.refID) #dispatchCount (used after GPU_CHUNKS_INIT)
        glBindBufferBase(GL_ATOMIC_COUNTER_BUFFER, 2, CHUNK_INDIRECT_DRAW_BUFFER.refID) #instanceCount
        #glBindBufferRange(GL_ATOMIC_COUNTER_BUFFER, 2 , CHUNK_INDIRECT_DRAW_BUFFER.refID, 0, INDIRECT_DRAW_BUFFER_SIZE)

        glBindBufferBase(GL_SHADER_STORAGE_BUFFER, 0, CHUNK_ALL_BUFFER.refID)
        glBindBufferBase(GL_SHADER_STORAGE_BUFFER, 1, CHUNK_BUFFER.refID)
        
        #setMode("STATE", -2) # SET DISPATCH VALUE
        #glBindBuffer(GL_DISPATCH_INDIRECT_BUFFER , DISPATCH_RESETER.refID)
        #glDispatchComputeIndirect(C_NULL)
        #glMemoryBarrier(GL_COMMAND_BARRIER_BIT | GL_VERTEX_ATTRIB_ARRAY_BARRIER_BIT | GL_SHADER_STORAGE_BARRIER_BIT | GL_ATOMIC_COUNTER_BARRIER_BIT)
        #glBindBuffer(GL_DISPATCH_INDIRECT_BUFFER , DISPATCH_BUFFER.refID)

        setMode("STATE", 2)
        glDispatchComputeIndirect(C_NULL)
        glMemoryBarrier(GL_COMMAND_BARRIER_BIT | GL_VERTEX_ATTRIB_ARRAY_BARRIER_BIT | GL_SHADER_STORAGE_BARRIER_BIT | GL_ATOMIC_COUNTER_BARRIER_BIT)
      end
      =#
 
      glBindSampler(0, 0)
      #setFrustumProgram(programs[:INSTANCES])
      #setMVP(programs[:INSTANCES], CAMERA.MVP)
      #setMode(programs[:INSTANCES], "iCamPos", CAMERA.position)
      #setMode(programs[:INSTANCES], "iCamAng", CAMERA.rotation)
      glBindBuffer(GL_DISPATCH_INDIRECT_BUFFER , 0)
      glBindBufferBase(GL_SHADER_STORAGE_BUFFER, 0, 0)
      glBindBufferRange(GL_SHADER_STORAGE_BUFFER, 0, 0, 0, 0)
    end
    #=
    glBindBufferBase(GL_SHADER_STORAGE_BUFFER, 0, indirectData.arrays[:points_default].refID)
    glBindBufferBase(GL_SHADER_STORAGE_BUFFER, 1, indirectData.arrays[:points].refID)
    setMode("STATE", 2)
    glDispatchComputeIndirect(C_NULL)
    glMemoryBarrier(GL_COMMAND_BARRIER_BIT | GL_VERTEX_ATTRIB_ARRAY_BARRIER_BIT | GL_SHADER_STORAGE_BARRIER_BIT | GL_ATOMIC_COUNTER_BARRIER_BIT)
    =#
    #=
    useProgram(programs[:INSTANCES])
    setMode("iTime", itime)
      
    glBindBuffer(GL_DISPATCH_INDIRECT_BUFFER , indirectData.arrays[:indirect_dispatch_instances].refID)
    glBindBufferBase(GL_ATOMIC_COUNTER_BUFFER, 0, indirectData.arrays[:counter2].refID) #LIMIT
    glBindBufferBase(GL_ATOMIC_COUNTER_BUFFER, 1, indirectData.arrays[:indirect].refID) #instanceCount
    glBindBufferBase(GL_SHADER_STORAGE_BUFFER, 0, indirectData.arrays[:points_default].refID)
    glBindBufferBase(GL_SHADER_STORAGE_BUFFER, 1, indirectData.arrays[:points].refID)
    
    glDispatchComputeIndirect(C_NULL)
    glMemoryBarrier(GL_COMMAND_BARRIER_BIT | GL_VERTEX_ATTRIB_ARRAY_BARRIER_BIT | GL_SHADER_STORAGE_BARRIER_BIT | GL_ATOMIC_COUNTER_BARRIER_BIT | GL_BUFFER_UPDATE_BARRIER_BIT) # GL_ATOMIC_COUNTER_BARRIER_BIT GL_SHADER_IMAGE_ACCESS_BARRIER_BIT
    #GL_BUFFER_UPDATE_BARRIER_BIT
    =#
   end

   function drawChunk(center;single=false)
    setMode("iTime", itime)
    setMode("iResolution", Float32[WIDTH,HEIGHT])
    setMode("iCamPos", CAMERA.position)
    setMode("iCamAng", CAMERA.rotation)
    setMode("iCenter", center)
    setMode("iProj", CAMERA.projectionMat)
    setMode("iView", CAMERA.viewMat)
    setMode("iMVP", CAMERA.MVP)
    setMode("iDepth", 0)
    
    #glBindVertexArray(indirectData.vao)
    
    glBindVertexArray(CHUNK_OBJECTS[1])
    iprogram=programs[:INDIRECT]
   
    #for i=1:(single ? 1 : VISIBLE_CHUNKS_COUNT)
    #  chunk=VISIBLE_CHUNKS[i]
    #  buffer=CHUNK_BUFFERS[chunk.id]
    #  ibuffer=CHUNK_INDIRECT_DRAW_BUFFERS[chunk.id]
    #  glBindBufferRange(GL_SHADER_STORAGE_BUFFER, i, buffer.refID, i*buffsize, buffsize)
    #  glBindBufferRange(GL_DRAW_INDIRECT_BUFFER, i, ibuffer.refID, i*INDIRECT_DRAW_BUFFER_SIZE, INDIRECT_DRAW_BUFFER_SIZE)
    #  setAttributes(buffer, iprogram, atrb; bindbuffer=false)
    #end

    #=
    for i=1:(single ? 1 : VISIBLE_CHUNKS_COUNT)
      chunk = VISIBLE_CHUNKS[i]
      buffer=CHUNK_BUFFERS[chunk.id]
      ibuffer=CHUNK_INDIRECT_DRAW_BUFFERS[1]
      #glBindBuffer(GL_ARRAY_BUFFER, CHUNK_DATA.refID) #buffer.refID #for vao
      #setAttributes(buffer, iprogram, atrb; bindbuffer=false)
      #glBindBuffer(GL_ARRAY_BUFFER, 0)
      #glBindBuffer(GL_SHADER_STORAGE_BUFFER, buffer.refID) #for vao
      glBindBufferBase(GL_SHADER_STORAGE_BUFFER, 0, buffer.refID)
      glBindBuffer(GL_DRAW_INDIRECT_BUFFER , ibuffer.refID)
      glDrawArraysIndirect(GL_POINTS, C_NULL)
      #glMemoryBarrier(GL_COMMAND_BARRIER_BIT | GL_VERTEX_ATTRIB_ARRAY_BARRIER_BIT | GL_SHADER_STORAGE_BARRIER_BIT | GL_ATOMIC_COUNTER_BARRIER_BIT)
    end
    =#
#CHUNK_BUFFER=CHUNK_OCCLUDED_BUFFERS[1]
CHUNK_BUFFER=CHUNK_BUFFERS[1]
    if single_indirect
      glBindBufferBase(GL_SHADER_STORAGE_BUFFER, 0, CHUNK_BUFFER.refID)
      glBindBuffer(GL_DRAW_INDIRECT_BUFFER , CHUNK_INDIRECT_DRAW_BUFFERS[1].refID)
      glMultiDrawArraysIndirect(GL_POINTS,C_NULL,VISIBLE_CHUNKS_COUNT,INDIRECT_DRAW_BUFFER_SIZE)
    elseif single_storage
      for i=1:(single ? 1 : VISIBLE_CHUNKS_COUNT)
        chunk = VISIBLE_CHUNKS[i]
        glBindBufferRange(GL_SHADER_STORAGE_BUFFER, 0, CHUNK_BUFFER.refID, (i-1)*CHUNK_BUFFERS_SIZE, CHUNK_BUFFERS_SIZE)
        glBindBuffer(GL_DRAW_INDIRECT_BUFFER , CHUNK_INDIRECT_DRAW_BUFFERS[chunk.id].refID)
        glDrawArraysIndirect(GL_POINTS, C_NULL)
      end
    else
      for i=1:(single ? 1 : VISIBLE_CHUNKS_COUNT)
        chunk = VISIBLE_CHUNKS[i]
        glBindBufferBase(GL_SHADER_STORAGE_BUFFER, 0, CHUNK_BUFFERS[chunk.id].refID)
        glBindBuffer(GL_DRAW_INDIRECT_BUFFER , CHUNK_INDIRECT_DRAW_BUFFERS[chunk.id].refID)
        glDrawArraysIndirect(GL_POINTS, C_NULL)
      end
    end
    

    glBindVertexArray(0)

  end
  
  """
  TODO
  """
  while !GLFW.WindowShouldClose(WINDOW)
    GLFW.PollEvents() # Poll for and process events
    showFrames()
    if !WINDOW_FOCUS
      sleep(0.1)
    else
      UpdateCounters()
      checkForUpdate()
      

      # Pulse the background
      #c=0.5 * (1 + sin(i * 0.01)); i+=1
      #glClearColor(c, c, c, 1.0)
      #glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)

      #print("loopBlocks "); @time
      #loopBlocks()
      
      if render_ready
        checkCamera()
      
        if RENDER_METHOD < 7
          glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT | GL_STENCIL_BUFFER_BIT)
          
          glPolygonMode(GL_FRONT_AND_BACK, WIREFRAME ? GL_LINE : GL_FILL)
        
          glActiveTexture(GL_TEXTURE0)
          glBindTexture(GL_TEXTURE_2D, texture_blocks)
        
          if fileredCount > 0 #isValid(mychunk)
            useProgram(programs[:CHUNKS])
            #glPolygonMode(GL_FRONT_AND_BACK, WIREFRAME ? GL_LINE : GL_FILL)
            glBindVertexArray(chunkData.vao)
            
            if RENDER_METHOD == 1 glDrawArrays(GL_POINTS, 0, fileredCount) #GL_TRIANGLE_STRIP
            elseif RENDER_METHOD == 2 glDrawArraysInstanced(GL_TRIANGLES, 0, chunkData.draw.count, fileredCount)
            elseif RENDER_METHOD == 3 glDrawElementsInstanced(GL_TRIANGLES, chunkData.draw.count, GL_UNSIGNED_INT, C_NULL, fileredCount)
            #glDrawElementsInstancedBaseVertex(GL_TRIANGLES, chunkData.draw.count / 6, GL_UNSIGNED_INT, C_NULL, mychunk.count, 0)
            elseif RENDER_METHOD == 4
              #* thats slow! (glDrawElements ~60 fps, glDrawElementsInstanced ~ 200 fps !!!)
              for b in getFilteredChilds(mychunk)
                if location_texindex > -1 glUniform1f(location_texindex, b.typ) end
                if location_position > -1 glUniform3fv(location_position, 1, b.pos) end
                glDrawElements(GL_TRIANGLES, chunkData.draw.count, GL_UNSIGNED_INT, C_NULL)
              end
            elseif RENDER_METHOD == 5
              #glDrawArrays(GL_TRIANGLES, 0, chunkData.draw.count)
            end
            glBindVertexArray(0)
          end
        end
        
        if RENDER_METHOD == 7
          glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT | GL_STENCIL_BUFFER_BIT)
          
          useProgram(programs[:COMPUTE])
          
          setMode("destTex", 0)
          setMode("roll", FRAMES*0.01f0)
          
          #glCheck(glUniform1i(glGetUniformLocation(programs[:COMPUTE], "destTex"), 0))
          #glCheck(glUniform1f(glGetUniformLocation(programs[:COMPUTE], "roll"), FRAMES*0.01f0))
          
          glActiveTexture(GL_TEXTURE0)
          glBindTexture(GL_TEXTURE_2D, texture_screen)

          glDispatchCompute(512/1, 512/1, 1)
          
          useProgram(programs[:SCREEN])
          setMode("srcTex", 0)
          #glCheck(glUniform1i(glGetUniformLocation(programs[:SCREEN], "srcTex"), 0))
          
          glBindVertexArray(screenData.vao)
          glMemoryBarrier(GL_SHADER_IMAGE_ACCESS_BARRIER_BIT) # make sure writing to image has finished before read
          glDrawArrays(GL_TRIANGLE_STRIP, 0, screenData.draw.count)
          
          glBindVertexArray(0)
        end
        
        if RENDER_METHOD == 8
          #frameBufferCounter+=1
          #if frameBufferCounter > frameBufferMax frameBufferCounter=1 end
          
          itime = programTime()
          
          #glBlendFunc(GL_ONE, GL_ZERO)
          #glDisable( GL_BLEND )

          glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT | GL_STENCIL_BUFFER_BIT)
          
          #glActiveTexture(GL_TEXTURE0)
          #glBindTexture(GL_TEXTURE_2D, texture_screen)
          
          glActiveTexture(GL_TEXTURE1)
          glBindTexture(GL_TEXTURE_2D, texture_depth)
          
          glActiveTexture(GL_TEXTURE2)
          glBindTexture(GL_TEXTURE_2D, texture_blocks)
          
          glActiveTexture(GL_TEXTURE3)
          glBindTexture(GL_TEXTURE_2D, texture_screen)
          
          glActiveTexture(GL_TEXTURE4)
          glBindTexture(GL_TEXTURE_2D, texture_heightMap)
          
          # calculate landscape
          if GPU_CHUNKS_INIT || CAMERA_UPDATED
            useProgram(programs[:COMPUTE])
            setMode("iTime", itime)
            glDispatchCompute(512/1, 512/1, 1)
          end
                  
          ###################################
          
          glDepthMask(GL_FALSE)
          
          useProgram(programs[:BG])
          
          setMode("iTime", itime)
          setMode("iResolution", Float32[WIDTH,HEIGHT])
          setMode("iCamPos", CAMERA.position)
          setMode("iCamAng", CAMERA.rotation)
          setMode("iProj", CAMERA.projectionMat)
          setMode("iView", CAMERA.viewMat)
          #setMode("iMVP", eyeMat4x4f)
          
          glMemoryBarrier(GL_SHADER_IMAGE_ACCESS_BARRIER_BIT) # make sure writing to image has finished before read
          
          glBindVertexArray(screenData.vao)
          glDrawArrays(GL_TRIANGLE_STRIP, 0, screenData.draw.count)
          
          glBindVertexArray(0)
          glDepthMask(GL_TRUE)
          #################################
          
          gpu_updateChunks()
          
          glPolygonMode(GL_FRONT_AND_BACK, WIREFRAME ? GL_LINE : GL_FILL)
          useProgram(programs[:INDIRECT])
          drawChunk(Float32[0,0,0])
          glPolygonMode(GL_FRONT_AND_BACK, GL_FILL)        
          
          #################################
          #=
          useProgram(programs[:NORMAL])
          glPolygonMode(GL_FRONT_AND_BACK, GL_LINE)
          
          if GPU_CHUNKS_INIT #|| CAMERA_UPDATED
            SetCamera(FRUSTUM, Vec3f(CAMERA.position), Vec3f(CAMERA.position+CameraManager.forward(CAMERA)), Vec3f(0,1,0); far=100f0)
            linkData(planeData, :vertices=>(getVertices(FRUSTUM),3))
            linkData(boxData, :vertices=>(DATA_CUBE,3)) #getBox(FRUSTUM)
            setAttributes(planeData, programs[:NORMAL])
            setAttributes(boxData, programs[:NORMAL])
          end
          setMode("iMVP", CAMERA.MVP)

          setMode("color", Vec4f(1,0,0,1))
          glBindVertexArray(planeData.vao)
          glDrawArrays(GL_TRIANGLES, 0, planeData.draw.count)
          
          glBindVertexArray(0)
          glPolygonMode(GL_FRONT_AND_BACK, GL_FILL)
          
          setMode("color", Vec4f(0,0,1,1))
          glBindVertexArray(boxData.vao)
          
          for i=1:VISIBLE_CHUNKS_COUNT
            setMode("iPosition", VISIBLE_CHUNKS[i].pos)
            glDrawArrays(GL_TRIANGLES, 0, boxData.draw.count)
          end
          =#
          
          #################################
   
          useProgram(programs[:FG])
          setMode("iTime", itime)
          setMode("iResolution", Float32[WIDTH,HEIGHT])
          setMode("iCamPos", CAMERA.position)
          setMode("iCamAng", CAMERA.rotation)
          setMode("iProj", CAMERA.projectionMat)
          setMode("iView", CAMERA.viewMat)
          
          glActiveTexture(GL_TEXTURE1)
          glBindTexture(GL_TEXTURE_2D, texture_depth)

          glBindVertexArray(screenData.vao)
          glMemoryBarrier(GL_SHADER_IMAGE_ACCESS_BARRIER_BIT) # make sure writing to image has finished before read
          glDrawArrays(GL_TRIANGLE_STRIP, 0, screenData.draw.count)
    
          #glDrawBuffer(GL_BACK)
          #glReadBuffer(GL_FRONT)
        end

        ##############################################

        #ptr = Ptr{GLuint}(glMapBufferRange(GL_ATOMIC_COUNTER_BUFFER, 0,1*sizeof(GLuint),  GL_MAP_READ_BIT|GL_MAP_WRITE_BIT))
        #counter = convert(GLuint, unsafe_load(ptr))
        #println(counter)

      end 
      if CAMERA_UPDATED #= global =# CAMERA_UPDATED=false end
      if GPU_CHUNKS_INIT #= global =# GPU_CHUNKS_INIT=false end
      # Swap front and back buffers
      GLFW.SwapBuffers(WINDOW)
      #if SLEEP>0 Libc.systemsleep(SLEEP) end
      sleep(SLEEP)
    end
  end

  #GLFW.DestroyWindow(WINDOW) #might bug sometimes
  cleanUp()

  true
end #loop()

loop()
end #run

end #Game