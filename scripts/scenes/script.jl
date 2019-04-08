__precompile__(false)

module SCRIPT

using GLFW, ModernGL, SharedArrays, StaticArrays, Quaternions

#using ..WindowManager
using GraphicsManager
using DefaultModelData
using CameraManager
using FrustumManager
using ChunkManager
using MeshManager
using TextureManager
using ShaderManager
#using ..ScriptManager
using TimeManager
using LogManager
using MathManager

const GPU = GraphicsManager

struct IndirectCommand
         count::GLuint
     primCount::GLuint
    firstIndex::GLuint
    baseVertex::GLuint
  baseInstance::GLuint

  IndirectCommand(count=0, primCount=0) = new(count,primCount,0,0,0)
end

println("Init Vars.")

mutable struct ScriptVars
  WIDTH::Number
  HEIGHT::Number
  RATIO::Number
  SIZE::Number
  FOV::AbstractFloat
  CLIP_NEAR::AbstractFloat
  CLIP_FAR::AbstractFloat
  BLOCK_COUNT::Number

  CAM_LOCK::Bool
  WIREFRAME::Bool
  TEXTUREMODE::Bool
  LIGHTMODE::Bool
  FRUSTUM_CULLING::Bool
  HIDE_UNSEEN_CUBES::Bool
  RENDER_METHOD::Number
  SCENE::Number

  FRUSTUM::Union{Nothing, Frustum}
  WINDOW::Union{Nothing, Any}
  CAMERA::Union{Nothing, CameraManager.Camera}

  CHUNK_SIZE::Number
  CHUNK1D_SIZE::Number
  CHUNK2D_SIZE::Number
  CHUNK3D_SIZE::Number

  GPU_FRUSTUM::Bool
  GPU_CHUNKS::Bool
  GPU_CHUNKS_INIT::Bool
  CAMERA_UPDATED::Bool
  MSAA::Bool
  UPDATE_FRUSTUM::Bool

  MYCHUNK::Union{Nothing, Chunk}

  PROGRAMS::Union{Nothing, Dict{Symbol,GLint}}

  chunkData::Union{Nothing, MeshData}
  chunkData_upload::Union{Nothing, MeshData}
  planeData::Union{Nothing, MeshData}
  screenData::Union{Nothing, MeshData}
  boxData::Union{Nothing, MeshData}
  indirectData::Union{Nothing, MeshData}

  current_program::Number
  MVP::Union{Nothing, Any}

  texture_screen::Number
  texture_blocks::Number
  texture_heightMap::Number
  texture_depth::Number
  texture_msaa::Number

  shadow_sampler::Number

  render_init::Bool
  render_ready::Bool
  uploaded::Symbol

  fileredCount::Number

  chunk_pos::Union{Nothing, Array{Array{Float32,1},1}}

  CHUNKS::Union{Nothing, Array{Chunk,1}}

  CHUNK_COUNT::Number
  DEPTH_SIZE::Number
  DEPTH_SIZE_LOG2::Number
  LOD_LEVELS::Number

  DISPATCH_RESETER::Union{Nothing, MeshBuffer}
  CHUNK_ALL_BUFFERS::Union{Nothing, AbstractArray}
  CHUNK_BUFFERS::Union{Nothing, AbstractArray}
  CHUNK_OCCLUDED_BUFFERS::Union{Nothing, AbstractArray}
  DISPATCH_BUFFERS::Union{Nothing, AbstractArray}
  CHUNK_COUNTERS::Union{Nothing, AbstractArray}
  CHUNK_INDIRECT_DRAW_BUFFERS::Union{Nothing, AbstractArray}
  DISPATCH_COUNTERS::Union{Nothing, AbstractArray}
  CHUNK_OBJECTS::Union{Nothing, AbstractArray}
  TRANSFORM_FEEDBACK_BUFFERS::Union{Nothing, AbstractArray}

  frameBuffers::Union{Nothing, Array{Integer,1}}
  depthrenderbuffer::Number

  CHUNK_DATA::Union{Nothing, MeshBuffer}
  ALL_CHUNK_SIZE::Number
  CHUNK_BUFFERS_SIZE::Number
  CHUNK_ARRAY_LENGTH::Number

  single_indirect::Bool
  single_storage::Bool

  fbo_msaa::Number
  rbo_msaa::Number
  fbo_intermediate::Number

  global_vars::Union{Nothing, Dict{Symbol,Any}}

  RENDER_CHUNKS_COUNT::Number

  #frameBufferMax = length(vars.CHUNKS)
  #frameBufferCounter=0

  ITIME::Number

  INDIRECT_DRAW_BUFFER_SIZE::Number

  VISIBLE_CHUNKS::Union{Nothing, Array{Chunk,1}}
  VISIBLE_CHUNKS_COUNT::Number

  #atrb=[("iInstancePos",Float32,3,0),("iInstanceFlags",Float32,3,0)]
  #buffsize=sizeof(Float32)*3*2*vars.CHUNK3D_SIZE

  chunk_instances::Any #Union{Nothing, SharedArray{Float32,1}}
  plane_vertices::Any #Union{Nothing, SharedArray{Float32,1}}
  box_vertices::Any #Union{Nothing, SharedArray{Float32,1}}

  location_position::Number
  location_texindex::Number


  XBUFFER::Union{Nothing, MeshBuffer}

  function ScriptVars()
    this = new()

    #=
    this.WIDTH = 0
    this.HEIGHT = 0
    this.RATIO = 0
    this.SIZE = 0
    this.FOV = 0
    this.CLIP_NEAR = 0
    this.CLIP_FAR = 0
    this.BLOCK_COUNT = 0

    this.CAM_LOCK = false
    this.WIREFRAME = false
    this.TEXTUREMODE = false
    this.LIGHTMODE = false
    this.FRUSTUM_CULLING = false
    this.HIDE_UNSEEN_CUBES = false
    this.RENDER_METHOD = 0
    this.SCENE = 0

    this.FRUSTUM = nothing
    this.WINDOW = nothing
    this.CAMERA = nothing

    this.CHUNK_SIZE = 0
    this.CHUNK1D_SIZE = 0
    this.CHUNK2D_SIZE = 0
    this.CHUNK3D_SIZE = 0

    this.GPU_FRUSTUM = false
    this.GPU_CHUNKS = false
    this.GPU_CHUNKS_INIT = false
    this.CAMERA_UPDATED = false
    this.MSAA = false
    this.UPDATE_FRUSTUM = false

    this.MYCHUNK = nothing

    this.PROGRAMS = nothing

    this.chunkData = nothing
    this.chunkData_upload = nothing
    this.planeData = nothing
    this.screenData = nothing
    this.boxData = nothing
    this.indirectData = nothing

    this.current_program = 0
    this.MVP = nothing

    this.texture_screen = 0
    this.texture_blocks = 0
    this.texture_heightMap = 0
    this.texture_depth = 0
    this.texture_msaa = 0

    this.shadow_sampler = 0

    this.render_init = false
    this.render_ready = false
    this.uploaded = :NOTHING

    this.fileredCount = 0

    this.chunk_pos = nothing

    this.CHUNKS = nothing

    this.CHUNK_COUNT = 0
    this.DEPTH_SIZE = 0
    this.DEPTH_SIZE_LOG2 = 0
    this.LOD_LEVELS = 0

    this.DISPATCH_RESETER = nothing
    this.CHUNK_ALL_BUFFERS = nothing
    this.CHUNK_BUFFERS = nothing
    this.CHUNK_OCCLUDED_BUFFERS = nothing
    this.DISPATCH_BUFFERS = nothing
    this.CHUNK_COUNTERS = nothing
    this.CHUNK_INDIRECT_DRAW_BUFFERS = nothing
    this.DISPATCH_COUNTERS=nothing
    this.CHUNK_OBJECTS=nothing
    this.TRANSFORM_FEEDBACK_BUFFERS=nothing

    this.frameBuffers = nothing
    this.depthrenderbuffer = 0

    this.CHUNK_DATA = nothing
    this.ALL_CHUNK_SIZE = 0
    this.CHUNK_BUFFERS_SIZE = 0
    this.CHUNK_ARRAY_LENGTH=0

    this.single_indirect = true
    this.single_storage = true

    this.fbo_msaa = 0
    this.rbo_msaa = 0
    this.fbo_intermediate = 0

    this.global_vars=nothing

    this.RENDER_CHUNKS_COUNT=0

    this.ITIME = 0

    this.INDIRECT_DRAW_BUFFER_SIZE=0

    this.VISIBLE_CHUNKS=nothing
    this.VISIBLE_CHUNKS_COUNT = 0

    this.chunk_instances = nothing
    this.plane_vertices = nothing
    this.box_vertices = nothing

    this.location_position = 0
    this.location_texindex = 0

    this.XBUFFER = nothing
    =#

    this.WIDTH = 1280 #800
    this.HEIGHT = 800 #600
    this.RATIO = this.WIDTH/(this.HEIGHT*1f0)
    this.SIZE = this.WIDTH * this.HEIGHT
    this.FOV = 60.0f0
    this.CLIP_NEAR = 0.001f0
    this.CLIP_FAR = 10000.0f0
    this.BLOCK_COUNT = 0

    this.CAM_LOCK = false
    this.WIREFRAME = false
    this.TEXTUREMODE = true
    this.LIGHTMODE = true
    this.FRUSTUM_CULLING = true
    this.HIDE_UNSEEN_CUBES = true
    this.RENDER_METHOD = 8
    this.SCENE = 2

    this.FRUSTUM = nothing
    this.WINDOW = SCRIPT_ARGS[:WINDOW]
    this.CAMERA = CameraManager.CAMERA

    this.CHUNK_SIZE = 128
    this.CHUNK1D_SIZE = this.CHUNK_SIZE
    this.CHUNK2D_SIZE = this.CHUNK1D_SIZE * this.CHUNK1D_SIZE
    this.CHUNK3D_SIZE = this.CHUNK2D_SIZE * this.CHUNK1D_SIZE

    this.GPU_FRUSTUM = true
    this.GPU_CHUNKS = ChunkManager.GPU_CHUNKS
    this.GPU_CHUNKS_INIT = true
    this.CAMERA_UPDATED = true
    this.MSAA = false
    this.UPDATE_FRUSTUM = false

    this.MYCHUNK = nothing

    this.PROGRAMS = Dict{Symbol,GLint}(
    :CHUNKS=>0,:NORMAL=>0, :SCREEN=>0, :COMPUTE=>0,
    :COMPUTE_CHUNKS=>0, :CHANGE_CHUNKS=>0, :INSTANCES=>0, :INDIRECT=>0,
    :BG=>0, :FG=>0, :DEPTH=>0, :RASTER=>0, :DEPTH_MIP=>0
    )

    this.chunkData = nothing
    this.chunkData_upload = nothing
    this.planeData = nothing
    this.screenData = nothing
    this.boxData = nothing
    this.indirectData = nothing

    this.current_program = 0
    this.MVP = nothing

    this.texture_screen = 0
    this.texture_blocks = 0
    this.texture_heightMap = 0
    this.texture_depth = 0
    this.texture_msaa = 0

    this.shadow_sampler = 0

    this.render_init = false
    this.render_ready = false
    this.uploaded = :NOTHING

    this.fileredCount = 0

    this.chunk_pos = [
      Float32[0,0,0],
      Float32[1,0,0],Float32[-1,0,0],Float32[0,0,1],Float32[0,0,-1],Float32[-1,0,-1],Float32[1,0,1],Float32[-1,0,1],Float32[1,0,-1],
      Float32[2,0,0],Float32[-2,0,0],Float32[0,0,2],Float32[0,0,-2],Float32[-2,0,-2],Float32[2,0,2],Float32[-2,0,2],Float32[2,0,-2],
      Float32[2,0,1],Float32[2,0,-1],Float32[-2,0,1],Float32[-2,0,-1],Float32[1,0,2],Float32[-1,0,2],Float32[1,0,-2],Float32[-1,0,-2]
    ] * this.CHUNK_SIZE

    this.CHUNKS = Chunk[Chunk(;id=i,pos=this.chunk_pos[i]) for i=1:1] #length(this.chunk_pos) #Array{ChunkD,1}(undef, length(centers))

    this.CHUNK_COUNT = length(this.CHUNKS)
    this.DEPTH_SIZE = max(this.WIDTH, this.HEIGHT) #256
    this.DEPTH_SIZE_LOG2 = round(Integer,log2(this.DEPTH_SIZE)) #8
    this.LOD_LEVELS = 1 #this.DEPTH_SIZE_LOG2 + 1

    this.DISPATCH_RESETER = nothing
    this.CHUNK_ALL_BUFFERS = []
    this.CHUNK_BUFFERS = []
    this.CHUNK_OCCLUDED_BUFFERS = []
    this.DISPATCH_BUFFERS = []
    this.CHUNK_COUNTERS = []
    this.CHUNK_INDIRECT_DRAW_BUFFERS = []
    this.DISPATCH_COUNTERS=[]
    this.CHUNK_OBJECTS=[]
    this.TRANSFORM_FEEDBACK_BUFFERS=[]

    this.frameBuffers = zeros(Integer,this.LOD_LEVELS)
    this.depthrenderbuffer = 0

    this.CHUNK_DATA = nothing
    this.ALL_CHUNK_SIZE = this.CHUNK3D_SIZE*(1+8+16+24+32+40)
    this.CHUNK_BUFFERS_SIZE = sizeof(Float32)*3*2*this.ALL_CHUNK_SIZE
    this.CHUNK_ARRAY_LENGTH=6*128^3 #max: 128000000

    this.single_indirect = true
    this.single_storage = true

    this.fbo_msaa = 0
    this.rbo_msaa = 0
    this.fbo_intermediate = 0

    this.global_vars=Dict{Symbol,Any}()

    this.RENDER_CHUNKS_COUNT=0

    #frameBufferMax = length(this.CHUNKS)
    #frameBufferCounter=0

    this.ITIME = 0

    this.INDIRECT_DRAW_BUFFER_SIZE=sizeof(GLuint[0,1,0,0,0])

    this.VISIBLE_CHUNKS=Array{Chunk,1}(undef, length(this.CHUNKS))
    this.VISIBLE_CHUNKS_COUNT = 0

    #atrb=[("iInstancePos",Float32,3,0),("iInstanceFlags",Float32,3,0)]
    #buffsize=sizeof(Float32)*3*2*this.CHUNK3D_SIZE

    this.chunk_instances = SharedArray(Float32[])
    this.plane_vertices = SharedArray(Float32[])
    this.box_vertices = SharedArray(Float32[])

    this.location_position = 0
    this.location_texindex = 0

    this.XBUFFER = nothing

    MeshManager.clean()

    this #return
  end
end

vars = nothing
SCRIPT_ARGS = Dict{Symbol,Any}()

function resetVars() global vars = ScriptVars() end

#--------------------------------------------

setChunkInstances(data) = vars.chunk_instances = data
setPlaneVertices(data) = vars.plane_vertices = data
setBoxVertices(data) = vars.box_vertices = data

getChunkInstances() = vars.chunk_instances
getPlaneVertices() = vars.plane_vertices
getBoxVertices() = vars.box_vertices

#--------------------------------------------

println("Set Functions.")

"""
sets glfw window size + viewport
"""
function resizeWindow(window, width, height)
  vars.WIDTH = width
  vars.HEIGHT = height
  vars.RATIO = vars.WIDTH/(vars.HEIGHT*1f0)
  vars.SIZE = vars.WIDTH * vars.HEIGHT
  GLFW.SetWindowSize(window, vars.WIDTH, vars.HEIGHT)
  glViewport(0, 0, vars.WIDTH, vars.HEIGHT)
end

function presetCamera()
  setPosition(vars.CAMERA,[0f0,0,0])
  setProjection(vars.CAMERA, projection_perspective(vars.FOV, vars.RATIO, vars.CLIP_NEAR, vars.CLIP_FAR))
  Update(vars.CAMERA)
  vars.MVP = vars.CAMERA.MVP
  SetFrustum(vars.FRUSTUM, vars.FOV+10, vars.RATIO, vars.CLIP_NEAR, vars.CLIP_FAR)
  SetCamera(vars.FRUSTUM, Vec3f(vars.CAMERA.position), Vec3f(vars.CAMERA.position+CameraManager.forward(vars.CAMERA)), Vec3f(0,1,0))
end

function presetTextures()
  vars.texture_blocks = uploadTexture(joinpath(@__DIR__,"../../blocks.png"))
  vars.texture_heightMap = uploadTexture(:HEIGHTMAP, (1024,1024)) #uploadTextureGray(joinpath(@__DIR__,"heightmap.png"))
  vars.texture_screen = uploadTexture(:SCREEN, (vars.WIDTH,vars.HEIGHT))
end

""" TODO """
useProgram(program) = begin vars.current_program = program; glUseProgram(program) end

""" TODO """
function use_program(program, f::Function)
  if program != vars.current_program
    @GLCHECK glUseProgram(program)
  end
  @GLCHECK f()
  if program != vars.current_program
    @GLCHECK glUseProgram(0)
  end
end

""" TODO """
setMatrix(program, name, m) = begin cm = SMatrix{4,4,Float32}(m); glUniformMatrix4fv(glGetUniformLocation(program, name), 1, false, cm) end #const smatrix

""" TODO """
function setMVP(program, mvp)
  use_program(program, () -> begin
    @GLCHECK setMatrix(program, "iMVP", mvp)
  end)
end

function setMode(name::String, value, mode=""; program=vars.current_program)
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

""" TODO """
function setFrustumMode()
  SetCamera(vars.FRUSTUM, Vec3f(vars.CAMERA.position), Vec3f(vars.CAMERA.position+CameraManager.forward(vars.CAMERA)), Vec3f(0,1,0))
  if !vars.GPU_FRUSTUM
    updateChunk(vars.MYCHUNK)
    #= global =# vars.uploaded = :UPDATE
  end
end

""" TODO """
function updateChunk(this::Chunk)
  ##= global =# vars.chunkData, vars.chunkData_upload, vars.planeData, vars.boxData
  #println("update Chunk")

  if !vars.GPU_FRUSTUM && vars.FRUSTUM_CULLING
    #println("checkInFrustum")
    checkInFrustum(this, vars.FRUSTUM)
  else
    #println("showAll")
    showAll(this)
  end

  #println("setChunkInstances")
  setChunkInstances(getData(this))
  setPlaneVertices(getVertices(vars.FRUSTUM))
  setBoxVertices(getBox(vars.FRUSTUM))

  vars.BLOCK_COUNT = this.fileredCount
  #global VERT_COUNT = this.verticesCount

end

function createChunk(this::Chunk)
  println("Create chunk & create blocks...")

  ChunkManager.reset(this; size=vars.CHUNK_SIZE)

  #println("Set Chunk scenery")

  if vars.SCENE == 0 createSingle(this)
  elseif vars.SCENE == 1 createExample(this)
  else createLandscape(this)
  end

  update(this; unseen=vars.HIDE_UNSEEN_CUBES)

  updateChunk(this)
  #= global =# vars.uploaded = :CREATE
end

""" TODO """
function chooseRenderMethod(method=vars.RENDER_METHOD)
  if method != vars.RENDER_METHOD vars.RENDER_METHOD = method end

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


  println("CHUNK vars.SIZE: ",stringColor(string(vars.CHUNK_SIZE,"³");color=:yellow))
  println("vars.SCENE: ",stringColor(vars.SCENE;color=:yellow))
  println("METHOD(",stringColor(method;color=:yellow),"): ",stringColor(method," = ", name; color=:yellow))

  if name == "NOT DEFINED" return end

  #createChunk(vars.MYCHUNK)

  vars.uploaded = :YES
  vars.render_ready = false
end

function uploadData()
  if !vars.GPU_CHUNKS_INIT return end

  #=
  m=vars.uploaded

  #vars.chunk_instances = sdata(vars.chunk_instances)
  #vars.plane_vertices = sdata(vars.plane_vertices)
  #vars.box_vertices = sdata(vars.box_vertices)
  =#
  #vars.fileredCount = length(vars.chunk_instances)
  #=
  if m == :UPDATE
    println("Upload data...")
    upload(vars.chunkData, :instances, vars.chunk_instances)
    if vars.FRUSTUM_CULLING
      upload(vars.planeData, :vertices, vars.plane_vertices)
      upload(vars.boxData, :vertices, vars.box_vertices)
    end
    return
  end

  method = vars.RENDER_METHOD

  println("Link data...")
  if method == 1 linkData(vars.chunkData, :points=>vars.chunk_instances)
  elseif method == 2 linkData(vars.chunkData, :vertices=>(DATA_CUBE,3), :instances=>vars.chunk_instances)
  elseif method == 3 linkData(vars.chunkData, :vertices=>(DATA_CUBE_VERTEX,3), :indicies=>(DATA_CUBE_INDEX,1,GL_ELEMENT_ARRAY_BUFFER, true), :instances=>vars.chunk_instances)
  elseif method == 4 linkData(vars.chunkData, :vertices=>(DATA_CUBE_VERTEX,3), :indicies=>(DATA_CUBE_INDEX,1,GL_ELEMENT_ARRAY_BUFFER, true))
  elseif method > 4 && method < 7 linkData(vars.chunkData, :vertices=>(DATA_CUBE,3))
  end
  =#

  #createBuffer(:TEST,zeros(Float32,128^3*200),1) #OK

  if vars.GPU_CHUNKS_INIT
    #GL_DYNAMIC_COPY
    #DISPATH_SIZE = vars.CHUNK2D_SIZE
    max_chunks=16 #16 #40 #sizeof(Float32)*6*128^3*42 = 2113929216 bytes ~ 2.11 GB
    default_data = zeros(Float32,vars.CHUNK_ARRAY_LENGTH) #6*128^3, 0.050331648 GB, 50.331648 MB

    println("CHUNK_BUFFER4")
    createBuffer(:CHUNK_BUFFERS, default_data, max_chunks)

    vars.DISPATCH_RESETER = createBuffers(:DISPATCH_RESETER, GLuint[1,1,1],1; typ=GL_DISPATCH_INDIRECT_BUFFER, usage=GL_STREAM_READ)[1]

    #linkData(vars.chunkData, :vertices=>(DATA_PLANE_VERTEX,3), :indicies=>(DATA_PLANE_INDEX,1,GL_ELEMENT_ARRAY_BUFFER, true), :instances=>vars.chunk_instances)

    setFrustumMode()
    vars.plane_vertices = getVertices(vars.FRUSTUM)
    vars.box_vertices = getBox(vars.FRUSTUM)

    linkData(vars.planeData,  :vertices=>(vars.plane_vertices,3))
    linkData(vars.boxData,  :vertices=>(vars.box_vertices,3))

    if vars.RENDER_METHOD >= 7
      linkData(vars.screenData, :vertices=>(DATA_PLANE2D_VERTEX_STRIP,2)) #:indicies=>(DATA_PLANE_INDEX,1,GL_ELEMENT_ARRAY_BUFFER, true))
    end

    if vars.RENDER_METHOD == 8

      #linkData(vars.chunkData,
      #:points=>zeros(Float32,vars.CHUNK_ARRAY_LENGTH),
      #:chunks_default=>vars.chunk_instances,
      #:chunks_changed=>zeros(Float32,vars.CHUNK_ARRAY_LENGTH),
      #:points_default=>zeros(Float32,vars.CHUNK_ARRAY_LENGTH),
      #:indirect_dispatch=>(GLuint[1,1,1],1,GL_DISPATCH_INDIRECT_BUFFER, GL_STREAM_READ)
      #:counter=>(GLuint[0],1,GL_ATOMIC_COUNTER_BUFFER, GL_STREAM_READ),
      #:dispatchCounter=>(GLuint[0],1,GL_ATOMIC_COUNTER_BUFFER, GL_STREAM_READ),
      #:dispatch_reset=>(GLuint[1,1,1],1,GL_DISPATCH_INDIRECT_BUFFER, GL_STREAM_READ),
      #:indirect=>(GLuint[0,1,0,0,0],1,GL_DRAW_INDIRECT_BUFFER)
      #)

      linkData(vars.indirectData)

      vars.CHUNK_COUNTERS = createBuffers(:CHUNK_COUNTERS, GLuint[0],2; typ=GL_ATOMIC_COUNTER_BUFFER, usage=GL_STREAM_READ)
      vars.DISPATCH_COUNTERS = createBuffers(:DISPATCH_COUNTERS, GLuint[0],vars.CHUNK_COUNT; typ=GL_ATOMIC_COUNTER_BUFFER, usage=GL_STREAM_READ)

      vars.CHUNK_DATA = createBuffers(:CHUNK_DATA, zeros(Float32,6),1)[1]
      vars.CHUNK_OBJECTS = createArrayObjects(vars.CHUNK_COUNT)

      if vars.single_storage
        MAX_SHADER_STORAGE_BLOCK_SIZE = glGetIntegerval(GL_MAX_SHADER_STORAGE_BLOCK_SIZE)
        MAX_GEOMETRY_OUTPUT_VERTICES = glGetIntegerval(GL_MAX_GEOMETRY_OUTPUT_VERTICES)
        MAX_GEOMETRY_TOTAL_OUTPUT_COMPONENTS = glGetIntegerval(GL_MAX_GEOMETRY_TOTAL_OUTPUT_COMPONENTS )
        MAX_GEOMETRY_SHADER_INVOCATIONS = glGetIntegerval(GL_MAX_GEOMETRY_SHADER_INVOCATIONS)

        info("MAX_SHADER_STORAGE_BLOCK_SIZE: $MAX_SHADER_STORAGE_BLOCK_SIZE")
        info("MAX_GEOMETRY_OUTPUT_VERTICES: $MAX_GEOMETRY_OUTPUT_VERTICES")
        info("MAX_GEOMETRY_TOTAL_OUTPUT_COMPONENTS: $MAX_GEOMETRY_TOTAL_OUTPUT_COMPONENTS")
        info("MAX_GEOMETRY_SHADER_INVOCATIONS: $MAX_GEOMETRY_SHADER_INVOCATIONS")

        vars.CHUNK_ALL_BUFFERS = [createBuffer(:CHUNK_ALL_BUFFERS, default_data,max_chunks)]
        vars.CHUNK_BUFFERS = [createBuffer(:CHUNK_BUFFERS, default_data,max_chunks)]
        #vars.CHUNK_OCCLUDED_BUFFERS = [createBuffer(default_data,max_chunks)]
      else
        vars.CHUNK_ALL_BUFFERS = createBuffers(:CHUNK_ALL_BUFFERS, default_data,vars.CHUNK_COUNT)
        vars.CHUNK_BUFFERS = createBuffers(:CHUNK_BUFFERS, default_data,vars.CHUNK_COUNT)
      end

      #vars.TRANSFORM_FEEDBACK_BUFFERS = [createBuffer(default_data,1)]
      vars.DISPATCH_BUFFERS = createBuffers(:DISPATCH_BUFFERS, GLuint[1,1,1],vars.CHUNK_COUNT; typ=GL_DISPATCH_INDIRECT_BUFFER, usage=GL_STREAM_READ)

      if vars.single_indirect
        vars.CHUNK_INDIRECT_DRAW_BUFFERS = [createBuffer(:CHUNK_INDIRECT_DRAW_BUFFERS, GLuint[vars.CHUNK3D_SIZE,1,0,0,0],vars.CHUNK_COUNT; typ=GL_DRAW_INDIRECT_BUFFER)]
      else
        vars.CHUNK_INDIRECT_DRAW_BUFFERS = createBuffers(:CHUNK_INDIRECT_DRAW_BUFFERS, GLuint[vars.CHUNK3D_SIZE,1,0,0,0],vars.CHUNK_COUNT; typ=GL_DRAW_INDIRECT_BUFFER)
      end

      vars.depthrenderbuffer = GPU.create(:RENDERBUFFER, :RENDER1)
      vars.texture_depth = createTexture(:DEPTH, (vars.WIDTH,vars.HEIGHT);level=vars.LOD_LEVELS) #vars.DEPTH_SIZE #?

      glActiveTexture(GL_TEXTURE0)
      glBindTexture(GL_TEXTURE_2D, vars.texture_depth)

      # Sampler object that is used during occlusion culling.
      # We want GL_LINEAR shadow mode (PCF), but no filtering between miplevels as we manually specify the miplevel in the compute shader.
      vars.shadow_sampler = GPU.create(:SAMPLER, :SAMPLER1)
      glSamplerParameteri(vars.shadow_sampler, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_NEAREST)
      glSamplerParameteri(vars.shadow_sampler, GL_TEXTURE_MAG_FILTER, GL_LINEAR)
      glSamplerParameteri(vars.shadow_sampler, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE)
      glSamplerParameteri(vars.shadow_sampler, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE)
      glSamplerParameteri(vars.shadow_sampler, GL_TEXTURE_COMPARE_MODE, GL_COMPARE_REF_TO_TEXTURE)
      glSamplerParameteri(vars.shadow_sampler, GL_TEXTURE_COMPARE_FUNC, GL_LEQUAL)

      # msaa

      vars.fbo_msaa = GPU.create(:FRAMEBUFFER, :FRAME1)
      glBindFramebuffer(GL_FRAMEBUFFER, vars.fbo_msaa)

      vars.texture_msaa = createTextureMultiSample(:TEXTURE1, (vars.WIDTH, vars.HEIGHT))
      glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D_MULTISAMPLE, vars.texture_msaa, 0)

      vars.rbo_msaa = GPU.create(:RENDERBUFFER, :RENDER2)
      glBindRenderbuffer(GL_RENDERBUFFER, vars.rbo_msaa);
      glRenderbufferStorageMultisample(GL_RENDERBUFFER, 4, GL_DEPTH24_STENCIL8, vars.WIDTH, vars.HEIGHT);
      glBindRenderbuffer(GL_RENDERBUFFER, 0);
      glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_STENCIL_ATTACHMENT, GL_RENDERBUFFER, vars.rbo_msaa)

      status = glCheckFramebufferStatus(GL_FRAMEBUFFER)
      if status != GL_FRAMEBUFFER_COMPLETE error("Framebuffer is incomplete!") end
      glBindFramebuffer(GL_FRAMEBUFFER, 0)

      # intermediate

      vars.fbo_intermediate = GPU.create(:FRAMEBUFFER, :FRAME2)
      glBindFramebuffer(GL_FRAMEBUFFER, vars.fbo_intermediate)
      glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, vars.texture_screen, 0)

      status = glCheckFramebufferStatus(GL_FRAMEBUFFER)
      if status != GL_FRAMEBUFFER_COMPLETE error("Framebuffer is incomplete!") end
      glBindFramebuffer(GL_FRAMEBUFFER, 0)

      # DEPTH, LOD

      vars.frameBuffers=GPU.create(:FRAMEBUFFER, :FRAME3, vars.LOD_LEVELS)

      for lod=1:(vars.LOD_LEVELS)
        #vars.frameBuffers[lod] = glGenFramebuffer()
        glBindFramebuffer(GL_FRAMEBUFFER, vars.frameBuffers[lod])
        glFramebufferTexture2D(GL_FRAMEBUFFER, GL_DEPTH_STENCIL_ATTACHMENT, GL_TEXTURE_2D, vars.texture_depth, lod-1)
        #glFramebufferTexture(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, vars.texture_depth, 0)

        ##glBindRenderbuffer(GL_RENDERBUFFER, vars.depthrenderbuffer)
        ##glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT, vars.WIDTH, vars.HEIGHT)
        ##glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, vars.depthrenderbuffer)

        #glFramebufferTexture(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, vars.texture_depth, 0) #GL_COLOR_ATTACHMENT0
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

  if !vars.render_init vars.render_init = true end
  if !vars.render_ready vars.render_ready = true end
  vars.uploaded=:NOTHING
end

function removeShaderPrograms()
  if vars.PROGRAMS == nothing return end
  for (s,p) in vars.PROGRAMS glDeleteProgram(p) end
  vars.PROGRAMS = nothing
end

function removeShaderProgram(program::Symbol)
  result=false
  try
    @GLCHECK glDeleteProgram(vars.PROGRAMS[program])
    vars.PROGRAMS[program]=0
    result=true
  catch e
  end
  result
end

function reloadShaderProgram(program::Symbol, shaders::AbstractArray; transformfeedback=false)
  result=false
  try
    p = createShaderProgram(program, shaders; transformfeedback=transformfeedback)
    if p >= 0
      @GLCHECK glUseProgram(0)
      @GLCHECK glDeleteProgram(vars.PROGRAMS[program])
      vars.PROGRAMS[program]=p
      result=true
    end
  catch e
  end
  result
end

function bindBuffers()
  #if vars.GPU_CHUNKS
    #use_program(vars.PROGRAMS[:COMPUTE_CHUNKS]s, () -> begin
      #glBindBuffer(GL_DISPATCH_INDIRECT_BUFFER , vars.indirectData.arrays[:indirect_dispatch].refID)
      #glBindBufferBase(GL_ATOMIC_COUNTER_BUFFER, 0, vars.indirectData.arrays[:counter].refID)
      #glBindBufferBase(GL_SHADER_STORAGE_BUFFER, 0, vars.indirectData.arrays[:chunks_default].refID)
      #glBindBufferBase(GL_SHADER_STORAGE_BUFFER, 1, vars.indirectData.arrays[:points_default].refID)
    #end)
  #end

  #use_program(vars.PROGRAMS[:INSTANCES], () -> begin
    #glBindBuffer(GL_DISPATCH_INDIRECT_BUFFER , vars.indirectData.arrays[:indirect_dispatch_instances].refID)
    #glBindBufferBase(GL_ATOMIC_COUNTER_BUFFER, 0, vars.indirectData.arrays[:indirect].refID)
    #glBindBufferBase(GL_SHADER_STORAGE_BUFFER, 0, vars.indirectData.arrays[:points_default].refID)
    #glBindBufferBase(GL_SHADER_STORAGE_BUFFER, 1, vars.indirectData.arrays[:points].refID)
  #end)
end

function reloadShaderPrograms()
  method = vars.RENDER_METHOD
  vars.global_vars[:CHUNK_SIZE] = vars.CHUNK_SIZE
  vars.global_vars[:CHUNK1D_SIZE] = vars.CHUNK1D_SIZE
  vars.global_vars[:CHUNK2D_SIZE] = vars.CHUNK2D_SIZE
  vars.global_vars[:CHUNK3D_SIZE] = vars.CHUNK3D_SIZE

  println("Load shader files...")
  shaders = loadShaders(vars.global_vars)

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

  reloadShaderProgram(:CHUNKS, program_data)
  reloadShaderProgram(:NORMAL, [VSH, FSH])
  reloadShaderProgram(:SCREEN, [SCREEN_VSH, SCREEN_FSH])
  reloadShaderProgram(:COMPUTE, [CSH])
  #reloadShaderProgram(:COMPUTE_CHUNKS, [CHUNKS_CSH])
  reloadShaderProgram(:CHANGE_CHUNKS, [CHANGE_CHUNKS_CSH])
  #reloadShaderProgram(:INSTANCES, [INST_CSH])
  reloadShaderProgram(:INDIRECT, [INST_VSH_CSH_GSH, INST_FSH, INST_GSH])
  reloadShaderProgram(:BG, [VSH, BG_FSH])
  reloadShaderProgram(:FG, [VSH, FG_FSH])
  reloadShaderProgram(:DEPTH, [DEPTH_VSH, DEPTH_FSH, DEPTH_GSH])
  reloadShaderProgram(:DEPTH_MIP, [SCREEN_VSH, DEPTH_MIP_FSH])
  reloadShaderProgram(:RASTER, [RASTER_VSH, RASTER_FSH, RASTER_GSH];transformfeedback=false)

  println("bind Buffers...")
  bindBuffers()

  println("set Attributes ...")
  glBindVertexArray(vars.CHUNK_OBJECTS[1])
  setAttributes(vars.CHUNK_DATA, vars.PROGRAMS[:INDIRECT], [("iInstancePos",Float32,3,0),("iInstanceFlags",Float32,3,0)])
  glBindVertexArray(0)
  #setAttributes(vars.CHUNK_OBJECTS[1:1], vars.CHUNK_BUFFERS[1:1], vars.PROGRAMS[:INDIRECT])
  #setAttributes(vars.indirectData, vars.PROGRAMS[:INDIRECT])
  setAttributes(vars.planeData, vars.PROGRAMS[:NORMAL])
  setAttributes(vars.boxData, vars.PROGRAMS[:NORMAL])
  setAttributes(vars.screenData, vars.PROGRAMS[:SCREEN])
  setAttributes(vars.chunkData, vars.PROGRAMS[:CHUNKS])
  #setAttributes(vars.screenData, vars.PROGRAMS[:BG])
  #setAttributes(vars.screenData, vars.PROGRAMS[:FG])
  #setAttributes(vars.screenData, vars.PROGRAMS[:DEPTH])

  println("set Uniforms...")

  #= global =# location_position = glGetUniformLocation(vars.PROGRAMS[:CHUNKS], "iPosition")
  #= global =# location_texindex = glGetUniformLocation(vars.PROGRAMS[:CHUNKS], "iTexIndex")

  #setMVP(vars.PROGRAMS[:INDIRECT], vars.MVP)
  #setMVP(vars.PROGRAMS[:CHUNKS], vars.MVP)
  #setMode(vars.PROGRAMS[:INDIRECT], "iMVP", vars.MVP)
  #setMode(vars.PROGRAMS[:CHUNKS], "iMVP", vars.MVP)

  setMode(vars.PROGRAMS[:CHUNKS], "iUseLight", vars.LIGHTMODE)
  setMode(vars.PROGRAMS[:CHUNKS], "iUseTexture", vars.TEXTUREMODE)
end

""" TODO """
function checkForUpdate()
  uploadData()

  keyValue, keyPressed = getKey()

  if keyPressed

    if keyValue == 80 #p
      setPosition(vars.CAMERA,[0f0,0,0])

    elseif keyValue == 81 #q
      vars.WIREFRAME=!vars.WIREFRAME
      info("vars.WIREFRAME: $(vars.WIREFRAME)")

    elseif keyValue == 84 && vars.render_ready #t
      vars.TEXTUREMODE=!vars.TEXTUREMODE
      info("vars.TEXTUREMODE: $(vars.TEXTUREMODE)")
      setMode(vars.PROGRAMS[:CHUNKS], "iUseTexture", vars.TEXTUREMODE, "TEXTURE")

    elseif keyValue == 85 #u
      vars.UPDATE_FRUSTUM = !vars.UPDATE_FRUSTUM
      info("vars.UPDATE_FRUSTUM: $(vars.UPDATE_FRUSTUM)")

    elseif keyValue == 76 && vars.render_ready #l
      vars.LIGHTMODE=!vars.LIGHTMODE
      info("vars.LIGHTMODE: $(vars.LIGHTMODE)")
      setMode(vars.PROGRAMS[:CHUNKS], "iUseLight", vars.LIGHTMODE, "LIGHT")

    elseif keyValue == 82 #r
      #chooseRenderMethod()
      reloadShaderPrograms()
      vars.GPU_CHUNKS_INIT = true
      #println("RELOAD INSIDE SCRIPT")

    elseif (keyValue >= 290 && keyValue <= 301) # F1 - F12
  #    chooseRenderMethod(keyValue - 289)

    elseif keyValue >= 49 && keyValue <= 57 #1-9
  #    vars.CHUNK_SIZE = 2^(keyValue-49)
  #    info("vars.CHUNK_SIZE: $(vars.CHUNK_SIZE)")
  #    reloadShaderPrograms()
  #    vars.GPU_CHUNKS_INIT = true

    elseif keyValue == 48 #0
  #    vars.CHUNK_SIZE = 2^9
  #    info("vars.CHUNK_SIZE: $(vars.CHUNK_SIZE)")
  #    reloadShaderPrograms()
  #    vars.GPU_CHUNKS_INIT = true

    elseif keyValue == 45 #ß
  #    vars.CHUNK_SIZE = 2^10
  #    info("vars.CHUNK_SIZE: $(vars.CHUNK_SIZE)")
  #    reloadShaderPrograms()
  #    vars.GPU_CHUNKS_INIT = true

    elseif keyValue == 66 #b
  #    vars.SCENE = 0
  #    chooseRenderMethod()
    elseif keyValue == 78 #n
  #    vars.SCENE = 1
  #    chooseRenderMethod()
    elseif keyValue == 77 #m
      #vars.SCENE = 2
      #chooseRenderMethod()
      vars.MSAA = !vars.MSAA

    elseif keyValue == 70 #f
  #    vars.CAM_LOCK = !vars.CAM_LOCK
  #    info("CAM LOCK: $(vars.CAM_LOCK)")
    elseif keyValue == 86 #v
  #    vars.FRUSTUM_CULLING = !vars.FRUSTUM_CULLING
    elseif keyValue == 79 #o
  #    vars.HIDE_UNSEEN_CUBES = !vars.HIDE_UNSEEN_CUBES
    end
  end

  #if keyPressed resetKeys() end
end

function setFrustumProgram(program)
  use_program(program, () -> begin
    #center = vars.FRUSTUM.pos[:CENTER]
    #center = [center.x,center.y,center.z,vars.FRUSTUM.radius]
    dirs=[x.mNormal for (_,x) in vars.FRUSTUM.planes] #getDirections(vars.FRUSTUM)
    dists=[x.d for (_,x) in vars.FRUSTUM.planes]  #getDistances(vars.FRUSTUM)
    @GLCHECK glUniform1i(glGetUniformLocation(program, "frustum"), true)
    if !vars.CAM_LOCK
      #@GLCHECK glUniform4fv(glGetUniformLocation(program, "frustum_center"), 1, center)
      @GLCHECK glUniform3fv(glGetUniformLocation(program, "frustum_dirs"), length(dirs), dirs)
      @GLCHECK glUniform1fv(glGetUniformLocation(program, "frustum_dists"), length(dists), dists)
    end
  end)
end

function checkCamera()
  if vars.GPU_CHUNKS_INIT || CameraManager.OnUpdate(vars.CAMERA)
    #println(vars.CAMERA.position)
    #if !vars.CAM_LOCK
      if vars.RENDER_METHOD < 7
        #setMVP(vars.PROGRAMS[:CHUNKS], vars.CAMERA.MVP)
        #setMVP(vars.PROGRAMS[:NORMAL], vars.CAMERA.MVP)
        #setFrustumProgram(vars.PROGRAMS[:CHUNKS])
      end
    #end
    setFrustumMode()
    vars.CAMERA_UPDATED=true #vars.UPDATE_FRUSTUM
  end
end

function gpu_updateChunks()
  if vars.GPU_CHUNKS_INIT || vars.CAMERA_UPDATED
    #print(".")
    #SetCamera(vars.FRUSTUM, Vec3f(vars.CAMERA.position), Vec3f(vars.CAMERA.position+CameraManager.forward(vars.CAMERA)), Vec3f(0,1,0))

    # rasterize_occluders
    rasterize=true

    useProgram(vars.PROGRAMS[:CHANGE_CHUNKS])

    setMode("iTime", vars.ITIME)
    setMode("iCamPos", vars.CAMERA.position)
    setMode("iCamAng", vars.CAMERA.rotation)
    setMode("iProj", vars.CAMERA.projectionMat)
    setMode("iView", vars.CAMERA.viewMat)
    setMode("iMVP", vars.CAMERA.MVP)

    setFrustumProgram(vars.PROGRAMS[:CHANGE_CHUNKS])

    CHUNK_COUNTER=vars.CHUNK_COUNTERS[1]
    #DISPATCH_BUFFER=vars.DISPATCH_BUFFERS[1]
    CHUNK_INDIRECT_DRAW_BUFFER = vars.CHUNK_INDIRECT_DRAW_BUFFERS[1]

    #glBindBufferBase(GL_ATOMIC_COUNTER_BUFFER, 0, DISPATCH_BUFFER.refID) #DISPATH
    glBindBufferBase(GL_ATOMIC_COUNTER_BUFFER, 3, CHUNK_COUNTER.refID) #counter

    #buf = glMapBufferRange(GL_ATOMIC_COUNTER_BUFFER, 0, sizeof(GLuint), GL_MAP_WRITE_BIT | GL_MAP_INVALIDATE_BUFFER_BIT | GL_MAP_UNSYNCHRONIZED_BIT)
    vars.VISIBLE_CHUNKS_COUNT = 0
    vars.RENDER_CHUNKS_COUNT = 0

    setMode("iCulling", 0)

    for chunk in vars.CHUNKS
      #visible=inFrustum(chunk,vars.FRUSTUM)
      #if !vars.GPU_CHUNKS_INIT && !visible continue end

      #if visible
        #if vars.VISIBLE_CHUNKS_COUNT > 0 break end
        vars.VISIBLE_CHUNKS_COUNT += 1
        vars.VISIBLE_CHUNKS[vars.VISIBLE_CHUNKS_COUNT] = chunk
      #end

      vars.RENDER_CHUNKS_COUNT += 1
      I_RENDER_CHUNKS_COUNT = (vars.RENDER_CHUNKS_COUNT-1)

      setMode("iCenter", chunk.pos)

      DISPATCH_BUFFER=vars.DISPATCH_BUFFERS[chunk.id]
      DISPATCH_COUNTER=vars.DISPATCH_COUNTERS[chunk.id]

      if vars.GPU_CHUNKS_INIT || vars.CAMERA_UPDATED
        glBindBufferBase(GL_ATOMIC_COUNTER_BUFFER, 1, DISPATCH_COUNTER.refID) #dispatchCount (used after vars.GPU_CHUNKS_INIT)

        if vars.single_indirect
          glBindBufferRange(GL_ATOMIC_COUNTER_BUFFER, 2, vars.CHUNK_INDIRECT_DRAW_BUFFERS[1].refID, I_RENDER_CHUNKS_COUNT*vars.INDIRECT_DRAW_BUFFER_SIZE, sizeof(GLuint))
        else
          glBindBufferBase(GL_ATOMIC_COUNTER_BUFFER, 2, vars.CHUNK_INDIRECT_DRAW_BUFFERS[chunk.id].refID) #instanceCount
        end

        if vars.single_storage
          #glBindBufferRange(GL_SHADER_STORAGE_BUFFER, 0, vars.CHUNK_ALL_BUFFERS[1].refID, I_RENDER_CHUNKS_COUNT*vars.CHUNK_BUFFERS_SIZE, vars.CHUNK_BUFFERS_SIZE)
          #glBindBufferRange(GL_SHADER_STORAGE_BUFFER, 1, vars.CHUNK_BUFFERS[1].refID, I_RENDER_CHUNKS_COUNT*vars.CHUNK_BUFFERS_SIZE, vars.CHUNK_BUFFERS_SIZE)
          glBindBufferBase(GL_SHADER_STORAGE_BUFFER, 0, vars.CHUNK_ALL_BUFFERS[1].refID)
          glBindBufferBase(GL_SHADER_STORAGE_BUFFER, 1, vars.CHUNK_BUFFERS[1].refID)
        else
          glBindBufferBase(GL_SHADER_STORAGE_BUFFER, 0, vars.CHUNK_ALL_BUFFERS[chunk.id].refID)
          glBindBufferBase(GL_SHADER_STORAGE_BUFFER, 1, vars.CHUNK_BUFFERS[chunk.id].refID)
        end

        if vars.GPU_CHUNKS_INIT
          glBindBufferBase(GL_ATOMIC_COUNTER_BUFFER, 0, DISPATCH_BUFFER.refID) #DISPATH
          glBindBuffer(GL_DISPATCH_INDIRECT_BUFFER , vars.DISPATCH_RESETER.refID)
          setMode("STATE", -1) #RESET / SET DISPATCH VALUE
          glDispatchComputeIndirect(C_NULL)
          glMemoryBarrier(GL_COMMAND_BARRIER_BIT | GL_VERTEX_ATTRIB_ARRAY_BARRIER_BIT | GL_SHADER_STORAGE_BARRIER_BIT | GL_ATOMIC_COUNTER_BARRIER_BIT)
          glBindBufferBase(GL_ATOMIC_COUNTER_BUFFER, 0, 0)
        end

        glBindBuffer(GL_DISPATCH_INDIRECT_BUFFER , DISPATCH_BUFFER.refID)
        setMode("STATE", vars.GPU_CHUNKS_INIT ? 0 : 1)
        glDispatchComputeIndirect(C_NULL)
        glMemoryBarrier(GL_COMMAND_BARRIER_BIT | GL_VERTEX_ATTRIB_ARRAY_BARRIER_BIT | GL_SHADER_STORAGE_BARRIER_BIT | GL_ATOMIC_COUNTER_BARRIER_BIT)
      end
    end

    #glDrawBuffer(GL_NONE)
    #glReadBuffer(GL_NONE)
    #glReadBuffer(GL_BACK)
    #glCopyTexImage2D(GL_TEXTURE_2D, 0, GL_DEPTH_COMPONENT, 0, 0, vars.WIDTH, vars.HEIGHT, 0)

    glBindBuffer(GL_DISPATCH_INDIRECT_BUFFER , 0)
    glBindBufferBase(GL_SHADER_STORAGE_BUFFER, 0, 0)
    glBindBufferRange(GL_SHADER_STORAGE_BUFFER, 0, 0, 0, 0)

    ######################################################################
    use_depth = true
    if use_depth
    # depth buffer
    useProgram(vars.PROGRAMS[:DEPTH])

    # Render occlusion geometry to miplevel 0
    glBindFramebuffer(GL_FRAMEBUFFER, vars.frameBuffers[1])
    glActiveTexture(GL_TEXTURE0)
    glBindTexture(GL_TEXTURE_2D, vars.texture_depth)

    #glClearDepth(1.0)
    glDepthMask(GL_TRUE) #default: GL_TRUE
    glDepthFunc(GL_LESS) #default: GL_LESS
    glDepthRange(0.0, 1.0)

    glClear(GL_DEPTH_BUFFER_BIT | GL_STENCIL_BUFFER_BIT)
    glViewport(0, 0, vars.WIDTH, vars.HEIGHT) #vars.DEPTH_SIZE
    setMode("iDepth", false)
    drawChunk(Float32[0,0,0])
    glMemoryBarrier(GL_SHADER_IMAGE_ACCESS_BARRIER_BIT) # make sure writing to image has finished before read

    glActiveTexture(GL_TEXTURE0)
    glBindTexture(GL_TEXTURE_2D, vars.texture_depth)
    setMode("iDepth", true)
    drawChunk(Float32[0,0,0])
    glBindFramebuffer(GL_FRAMEBUFFER, 0)
    glMemoryBarrier(GL_SHADER_IMAGE_ACCESS_BARRIER_BIT) # make sure writing to image has finished before read

    ############################################################################
#=
    glActiveTexture(GL_TEXTURE0)
    glBindTexture(GL_TEXTURE_2D, vars.texture_depth)

    # Render occlusion geometry to miplevel > 0
    useProgram(vars.PROGRAMS[:DEPTH_MIP])
    glMemoryBarrier(GL_SHADER_IMAGE_ACCESS_BARRIER_BIT) # make sure writing to image has finished before read
    glActiveTexture(GL_TEXTURE0)
    glBindTexture(GL_TEXTURE_2D, vars.texture_depth)
    glDepthFunc(GL_ALWAYS)

    glBindVertexArray(vars.screenData.vao)

    currentWidth = vars.WIDTH
    currentHeight = vars.HEIGHT

    for lod=2:LOD_LEVELS
      currentWidth = round(Integer, currentWidth / 2.0)
      currentHeight = round(Integer, currentHeight / 2.0)
      if currentWidth <= 0 currentWidth = 1 end
      if currentHeight <= 0 currentHeight = 1 end

      glBindFramebuffer(GL_FRAMEBUFFER, vars.frameBuffers[lod])
      glClear(GL_DEPTH_BUFFER_BIT | GL_STENCIL_BUFFER_BIT)
      glViewport(0,0, currentWidth, currentHeight) #vars.DEPTH_SIZE >> lod

      # Need to do this to ensure that we cannot possibly read from the miplevel we are rendering to.
      # Otherwise, we have undefined behavior.
      glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_BASE_LEVEL, lod - 2)
      glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAX_LEVEL, lod - 2)

      glDrawArrays(GL_TRIANGLE_STRIP, 0, vars.screenData.draw.count)
    end

    glBindVertexArray(0)
    glBindFramebuffer(GL_FRAMEBUFFER, 0)
    glDepthFunc(GL_LEQUAL)

    # Restore miplevels. MAX_LEVEL will be clamped accordingly.
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_BASE_LEVEL, 0)
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAX_LEVEL, vars.LOD_LEVELS-1)

    glViewport(0, 0, vars.WIDTH, vars.HEIGHT)
    glMemoryBarrier(GL_SHADER_IMAGE_ACCESS_BARRIER_BIT) # make sure writing to image has finished before read

  =#
    ######################################################################
return
     # Bind Hi-Z depth map
    glActiveTexture(GL_TEXTURE0)
    glBindTexture(GL_TEXTURE_2D, vars.texture_depth)
    #glBindSampler(0, vars.shadow_sampler)

    ############################################################################
    end

    if rasterize
      #glEnable( GL_POLYGON_OFFSET_FILL )
      #glPolygonOffset(-1,-1)
      #glEnable(GL_RASTERIZER_DISCARD)

      glBindFramebuffer(GL_FRAMEBUFFER, vars.frameBuffers[1])
      #glDepthMask(GL_FALSE)
      glDepthFunc(GL_LESS)
      #glColorMask(GL_FALSE,GL_FALSE,GL_FALSE,GL_FALSE)

      useProgram(vars.PROGRAMS[:RASTER])
      setMode("iTime", vars.ITIME)
      setMode("iResolution", Float32[vars.WIDTH,vars.HEIGHT])
      setMode("iCamPos", vars.CAMERA.position)
      setMode("iCamAng", vars.CAMERA.rotation)
      setMode("iProj", vars.CAMERA.projectionMat)
      setMode("iView", vars.CAMERA.viewMat)
      setMode("iMVP", vars.CAMERA.MVP)

      glBindBufferBase(GL_SHADER_STORAGE_BUFFER, 0, vars.CHUNK_BUFFERS[1].refID)
      glBindBuffer(GL_DRAW_INDIRECT_BUFFER , vars.CHUNK_INDIRECT_DRAW_BUFFERS[1].refID)
      glMultiDrawArraysIndirect(GL_POINTS,C_NULL,vars.VISIBLE_CHUNKS_COUNT,vars.INDIRECT_DRAW_BUFFER_SIZE)

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

    useProgram(vars.PROGRAMS[:CHANGE_CHUNKS])

    setMode("iRasterrize", rasterize)

    DISPATCH_BUFFER=vars.DISPATCH_BUFFERS[1]

    glBindBufferBase(GL_ATOMIC_COUNTER_BUFFER, 0, DISPATCH_BUFFER.refID)
    glBindBufferBase(GL_ATOMIC_COUNTER_BUFFER, 1, vars.DISPATCH_COUNTERS[1].refID)

    #=
    glBindBuffer(GL_DISPATCH_INDIRECT_BUFFER , vars.DISPATCH_RESETER.refID)
    setMode("STATE", -3) #RESET / SET DISPATCH VALUE
    glDispatchComputeIndirect(C_NULL)
    glMemoryBarrier(GL_COMMAND_BARRIER_BIT | GL_VERTEX_ATTRIB_ARRAY_BARRIER_BIT | GL_SHADER_STORAGE_BARRIER_BIT | GL_ATOMIC_COUNTER_BARRIER_BIT)
    glBindBuffer(GL_DISPATCH_INDIRECT_BUFFER , DISPATCH_BUFFER.refID)
    =#

    glBindBufferBase(GL_SHADER_STORAGE_BUFFER, 0, vars.CHUNK_ALL_BUFFERS[1].refID)
    glBindBufferBase(GL_SHADER_STORAGE_BUFFER, 1, vars.CHUNK_BUFFERS[1].refID)

    for i=1:(vars.VISIBLE_CHUNKS_COUNT)
      chunk=vars.VISIBLE_CHUNKS[i]

      setMode("iCenter", chunk.pos)

      #DISPATCH_BUFFER=vars.DISPATCH_BUFFERS[chunk.id]
      #glBindBufferBase(GL_ATOMIC_COUNTER_BUFFER, 0, DISPATCH_BUFFER.refID) #DISPATH
      #glBindBufferBase(GL_ATOMIC_COUNTER_BUFFER, 1, vars.DISPATCH_COUNTERS[chunk.id].refID) #dispatchCount (used after vars.GPU_CHUNKS_INIT)

      if vars.single_indirect
        glBindBufferRange(GL_ATOMIC_COUNTER_BUFFER, 2, vars.CHUNK_INDIRECT_DRAW_BUFFERS[1].refID, (i-1)*vars.INDIRECT_DRAW_BUFFER_SIZE, sizeof(GLuint))
      else
        glBindBufferBase(GL_ATOMIC_COUNTER_BUFFER, 2, vars.CHUNK_INDIRECT_DRAW_BUFFERS[chunk.id].refID) #instanceCount
      end

      if vars.single_storage
        #glBindBufferRange(GL_SHADER_STORAGE_BUFFER, 0, vars.CHUNK_ALL_BUFFERS[1].refID, (i-1)*vars.CHUNK_BUFFERS_SIZE, vars.CHUNK_BUFFERS_SIZE)
        #glBindBufferRange(GL_SHADER_STORAGE_BUFFER, 1, vars.CHUNK_BUFFERS[1].refID, (i-1)*vars.CHUNK_BUFFERS_SIZE, vars.CHUNK_BUFFERS_SIZE)

        #glBindBufferBase(GL_SHADER_STORAGE_BUFFER, 0, vars.CHUNK_ALL_BUFFERS[1].refID)
        #glBindBufferBase(GL_SHADER_STORAGE_BUFFER, 1, vars.CHUNK_BUFFERS[1].refID)
      else
        #glBindBufferBase(GL_SHADER_STORAGE_BUFFER, 0, vars.CHUNK_ALL_BUFFERS[chunk.id].refID)
        #glBindBufferBase(GL_SHADER_STORAGE_BUFFER, 1, vars.CHUNK_BUFFERS[chunk.id].refID)
      end

      glBindBuffer(GL_DISPATCH_INDIRECT_BUFFER , vars.DISPATCH_RESETER.refID)
      setMode("STATE", -2) # SET DISPATCH VALUE
      glDispatchComputeIndirect(C_NULL)
      glMemoryBarrier(GL_COMMAND_BARRIER_BIT | GL_VERTEX_ATTRIB_ARRAY_BARRIER_BIT | GL_SHADER_STORAGE_BARRIER_BIT | GL_ATOMIC_COUNTER_BARRIER_BIT)
      glBindBuffer(GL_DISPATCH_INDIRECT_BUFFER , DISPATCH_BUFFER.refID)

      setMode("STATE", 2)
      glDispatchComputeIndirect(C_NULL)
      glMemoryBarrier(GL_COMMAND_BARRIER_BIT | GL_VERTEX_ATTRIB_ARRAY_BARRIER_BIT | GL_SHADER_STORAGE_BARRIER_BIT | GL_ATOMIC_COUNTER_BARRIER_BIT)
    end

    #=
    useProgram(vars.PROGRAMS[:CHANGE_CHUNKS])
    setMode("iCulling", 1) # Dispatch occlusion culling job

    setMode("STATE", -3) # SET DISPATCH VALUE
    glBindBuffer(GL_DISPATCH_INDIRECT_BUFFER , vars.DISPATCH_RESETER.refID)
    glBindBufferBase(GL_ATOMIC_COUNTER_BUFFER, 2, CHUNK_INDIRECT_DRAW_BUFFER.refID)
    glDispatchComputeIndirect(C_NULL)
    glMemoryBarrier(GL_COMMAND_BARRIER_BIT | GL_VERTEX_ATTRIB_ARRAY_BARRIER_BIT | GL_SHADER_STORAGE_BARRIER_BIT | GL_ATOMIC_COUNTER_BARRIER_BIT)

    CHUNK_BUFFER=vars.CHUNK_BUFFERS[1]
    glBindBufferBase(GL_SHADER_STORAGE_BUFFER, 1, CHUNK_BUFFER.refID)
    =#

    #=
    glBindBufferBase(GL_ATOMIC_COUNTER_BUFFER, 0, DISPATCH_BUFFER.refID) #DISPATH
    glBindBufferBase(GL_ATOMIC_COUNTER_BUFFER, 3, CHUNK_COUNTER.refID) #counter

    for chunk=1:(vars.CHUNK_COUNT)
      setMode("iCenter", vars.CHUNKS[chunk].pos)

      CHUNK_ALL_BUFFER=vars.CHUNK_ALL_BUFFERS[chunk]
      CHUNK_BUFFER=vars.CHUNK_BUFFERS[chunk]
      CHUNK_INDIRECT_DRAW_BUFFER = vars.CHUNK_INDIRECT_DRAW_BUFFERS[chunk]
      DISPATCH_COUNTER=vars.DISPATCH_COUNTERS[chunk]

      #glBindBufferBase(GL_ATOMIC_COUNTER_BUFFER, 0, DISPATCH_BUFFER.refID) #DISPATH
      glBindBufferBase(GL_ATOMIC_COUNTER_BUFFER, 1, DISPATCH_COUNTER.refID) #dispatchCount (used after vars.GPU_CHUNKS_INIT)
      glBindBufferBase(GL_ATOMIC_COUNTER_BUFFER, 2, CHUNK_INDIRECT_DRAW_BUFFER.refID) #instanceCount
      #glBindBufferRange(GL_ATOMIC_COUNTER_BUFFER, 2 , CHUNK_INDIRECT_DRAW_BUFFER.refID, 0, vars.INDIRECT_DRAW_BUFFER_SIZE)

      glBindBufferBase(GL_SHADER_STORAGE_BUFFER, 0, CHUNK_ALL_BUFFER.refID)
      glBindBufferBase(GL_SHADER_STORAGE_BUFFER, 1, CHUNK_BUFFER.refID)

      #setMode("STATE", -2) # SET DISPATCH VALUE
      #glBindBuffer(GL_DISPATCH_INDIRECT_BUFFER , vars.DISPATCH_RESETER.refID)
      #glDispatchComputeIndirect(C_NULL)
      #glMemoryBarrier(GL_COMMAND_BARRIER_BIT | GL_VERTEX_ATTRIB_ARRAY_BARRIER_BIT | GL_SHADER_STORAGE_BARRIER_BIT | GL_ATOMIC_COUNTER_BARRIER_BIT)
      #glBindBuffer(GL_DISPATCH_INDIRECT_BUFFER , DISPATCH_BUFFER.refID)

      setMode("STATE", 2)
      glDispatchComputeIndirect(C_NULL)
      glMemoryBarrier(GL_COMMAND_BARRIER_BIT | GL_VERTEX_ATTRIB_ARRAY_BARRIER_BIT | GL_SHADER_STORAGE_BARRIER_BIT | GL_ATOMIC_COUNTER_BARRIER_BIT)
    end
    =#

    glBindSampler(0, 0)
    #setFrustumProgram(vars.PROGRAMS[:INSTANCES])
    #setMVP(vars.PROGRAMS[:INSTANCES], vars.CAMERA.MVP)
    #setMode(vars.PROGRAMS[:INSTANCES], "iCamPos", vars.CAMERA.position)
    #setMode(vars.PROGRAMS[:INSTANCES], "iCamAng", vars.CAMERA.rotation)
    glBindBuffer(GL_DISPATCH_INDIRECT_BUFFER , 0)
    glBindBufferBase(GL_SHADER_STORAGE_BUFFER, 0, 0)
    glBindBufferRange(GL_SHADER_STORAGE_BUFFER, 0, 0, 0, 0)
  end
  #=
  glBindBufferBase(GL_SHADER_STORAGE_BUFFER, 0, vars.indirectData.arrays[:points_default].refID)
  glBindBufferBase(GL_SHADER_STORAGE_BUFFER, 1, vars.indirectData.arrays[:points].refID)
  setMode("STATE", 2)
  glDispatchComputeIndirect(C_NULL)
  glMemoryBarrier(GL_COMMAND_BARRIER_BIT | GL_VERTEX_ATTRIB_ARRAY_BARRIER_BIT | GL_SHADER_STORAGE_BARRIER_BIT | GL_ATOMIC_COUNTER_BARRIER_BIT)
  =#
  #=
  useProgram(vars.PROGRAMS[:INSTANCES])
  setMode("iTime", vars.ITIME)

  glBindBuffer(GL_DISPATCH_INDIRECT_BUFFER , vars.indirectData.arrays[:indirect_dispatch_instances].refID)
  glBindBufferBase(GL_ATOMIC_COUNTER_BUFFER, 0, vars.indirectData.arrays[:counter2].refID) #LIMIT
  glBindBufferBase(GL_ATOMIC_COUNTER_BUFFER, 1, vars.indirectData.arrays[:indirect].refID) #instanceCount
  glBindBufferBase(GL_SHADER_STORAGE_BUFFER, 0, vars.indirectData.arrays[:points_default].refID)
  glBindBufferBase(GL_SHADER_STORAGE_BUFFER, 1, vars.indirectData.arrays[:points].refID)

  glDispatchComputeIndirect(C_NULL)
  glMemoryBarrier(GL_COMMAND_BARRIER_BIT | GL_VERTEX_ATTRIB_ARRAY_BARRIER_BIT | GL_SHADER_STORAGE_BARRIER_BIT | GL_ATOMIC_COUNTER_BARRIER_BIT | GL_BUFFER_UPDATE_BARRIER_BIT) # GL_ATOMIC_COUNTER_BARRIER_BIT GL_SHADER_IMAGE_ACCESS_BARRIER_BIT
  #GL_BUFFER_UPDATE_BARRIER_BIT
  =#
end

function drawChunk(center;single=false)
  setMode("iTime", vars.ITIME)
  setMode("iResolution", Float32[vars.WIDTH,vars.HEIGHT])
  setMode("iCamPos", vars.CAMERA.position)
  setMode("iCamAng", vars.CAMERA.rotation)
  setMode("iCenter", center)
  setMode("iProj", vars.CAMERA.projectionMat)
  setMode("iView", vars.CAMERA.viewMat)
  setMode("iMVP", vars.CAMERA.MVP)
  setMode("iDepth", 0)

  #glBindVertexArray(vars.indirectData.vao)

  glBindVertexArray(vars.CHUNK_OBJECTS[1])
  iprogram=vars.PROGRAMS[:INDIRECT]

  #for i=1:(single ? 1 : vars.VISIBLE_CHUNKS_COUNT)
  #  chunk=vars.VISIBLE_CHUNKS[i]
  #  buffer=vars.CHUNK_BUFFERS[chunk.id]
  #  ibuffer=vars.CHUNK_INDIRECT_DRAW_BUFFERS[chunk.id]
  #  glBindBufferRange(GL_SHADER_STORAGE_BUFFER, i, buffer.refID, i*buffsize, buffsize)
  #  glBindBufferRange(GL_DRAW_INDIRECT_BUFFER, i, ibuffer.refID, i*vars.INDIRECT_DRAW_BUFFER_SIZE, vars.INDIRECT_DRAW_BUFFER_SIZE)
  #  setAttributes(buffer, iprogram, atrb; bindbuffer=false)
  #end

  #=
  for i=1:(single ? 1 : vars.VISIBLE_CHUNKS_COUNT)
    chunk = vars.VISIBLE_CHUNKS[i]
    buffer=vars.CHUNK_BUFFERS[chunk.id]
    ibuffer=vars.CHUNK_INDIRECT_DRAW_BUFFERS[1]
    #glBindBuffer(GL_ARRAY_BUFFER, vars.CHUNK_DATA.refID) #buffer.refID #for vao
    #setAttributes(buffer, iprogram, atrb; bindbuffer=false)
    #glBindBuffer(GL_ARRAY_BUFFER, 0)
    #glBindBuffer(GL_SHADER_STORAGE_BUFFER, buffer.refID) #for vao
    glBindBufferBase(GL_SHADER_STORAGE_BUFFER, 0, buffer.refID)
    glBindBuffer(GL_DRAW_INDIRECT_BUFFER , ibuffer.refID)
    glDrawArraysIndirect(GL_POINTS, C_NULL)
    #glMemoryBarrier(GL_COMMAND_BARRIER_BIT | GL_VERTEX_ATTRIB_ARRAY_BARRIER_BIT | GL_SHADER_STORAGE_BARRIER_BIT | GL_ATOMIC_COUNTER_BARRIER_BIT)
  end
  =#
  #CHUNK_BUFFER=vars.CHUNK_OCCLUDED_BUFFERS[1]
  CHUNK_BUFFER=vars.CHUNK_BUFFERS[1]
  if vars.single_indirect
    glBindBufferBase(GL_SHADER_STORAGE_BUFFER, 0, CHUNK_BUFFER.refID)
    glBindBuffer(GL_DRAW_INDIRECT_BUFFER , vars.CHUNK_INDIRECT_DRAW_BUFFERS[1].refID)
    glMultiDrawArraysIndirect(GL_POINTS,C_NULL,vars.VISIBLE_CHUNKS_COUNT,vars.INDIRECT_DRAW_BUFFER_SIZE)
  elseif vars.single_storage
    for i=1:(single ? 1 : vars.VISIBLE_CHUNKS_COUNT)
      chunk = vars.VISIBLE_CHUNKS[i]
      glBindBufferRange(GL_SHADER_STORAGE_BUFFER, 0, CHUNK_BUFFER.refID, (i-1)*vars.CHUNK_BUFFERS_SIZE, vars.CHUNK_BUFFERS_SIZE)
      glBindBuffer(GL_DRAW_INDIRECT_BUFFER , vars.CHUNK_INDIRECT_DRAW_BUFFERS[chunk.id].refID)
      glDrawArraysIndirect(GL_POINTS, C_NULL)
    end
  else
    for i=1:(single ? 1 : vars.VISIBLE_CHUNKS_COUNT)
      chunk = vars.VISIBLE_CHUNKS[i]
      glBindBufferBase(GL_SHADER_STORAGE_BUFFER, 0, vars.CHUNK_BUFFERS[chunk.id].refID)
      glBindBuffer(GL_DRAW_INDIRECT_BUFFER , vars.CHUNK_INDIRECT_DRAW_BUFFERS[chunk.id].refID)
      glDrawArraysIndirect(GL_POINTS, C_NULL)
    end
  end


  glBindVertexArray(0)

end

## PROGRAM

function main(args::Dict{Symbol,Any})
	#$(this.args),
  println("Script: $(basename(@__FILE__)), $(args), time: $(mtime(@__FILE__))")
  global SCRIPT_ARGS = args
  resetVars()
end

#XXX=Float32[]
#function OnInit()
#  global XXX=zeros(Float32,128^3*300)
#end

using ModernGL

function test()
  #vars.XBUFFER=createBuffer(:TEST,zeros(Float32,128^3*1),1) #200
  #MeshManager.delete(vars.XBUFFER)

  data=zeros(Float32,128^3*1); size=sizeof(data)
  refID=GLuint[0]; glGenBuffers(1, refID); refID=refID[]
  println("refID: $refID - $size")
  glBindBuffer(GL_ARRAY_BUFFER, refID)
  glBufferData(GL_ARRAY_BUFFER, 1*size, data, GL_STATIC_DRAW)
  #for i=1:1 glBufferSubData(GL_ARRAY_BUFFER , (i-1)*size, size, data) end
  glBindBuffer(GL_ARRAY_BUFFER, 0)
  glBindBuffer(GL_ARRAY_BUFFER, refID)
  glInvalidateBufferData(GL_ARRAY_BUFFER)
  glDeleteBuffers(1, [refID])
  glBindBuffer(GL_ARRAY_BUFFER, 0)
  glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT | GL_STENCIL_BUFFER_BIT)
  GC.gc()
end

function OnDestroy()
  println("OnDestroy")
  removeShaderPrograms()
  resetVars()
  MeshManager.clean()
  GraphicsManager.cleanUp() #remove all
  GC.gc()
end

function OnInit()
  #WindowManager.resize(vars.WINDOW, (800,600))
  #glViewport(0, 0, vars.WINDOW.size[1], vars.WINDOW.size[2])
  #GLFW.SetWindowSize(window, vars.WIDTH, vars.HEIGHT) # Seems to be necessary to guarantee that window > 0
  resizeWindow(vars.WINDOW, vars.WIDTH, vars.HEIGHT)
  #vars.WINDOW = args[:WINDOW]

  vars.FRUSTUM = Frustum()

  presetCamera()

  #if myid() == 1
    vars.chunkData = MeshData()
    vars.chunkData_upload = MeshData()
    vars.planeData = MeshData()
    vars.screenData = MeshData()
    vars.boxData = MeshData()
    vars.indirectData = MeshData()
    presetTextures()
    chooseRenderMethod()
  #end

  #if myid() != 1 || length(procs()) <= 1
  #  vars.MYCHUNK = Chunk()
  #  createChunk(vars.MYCHUNK)
  #end

  #------------------------------------------------------------------------------------

  #const mmvp = SMatrix{4,4,Float32}(vars.CAMERA.MVP)

  #------------------------------------------------------------------------------------

  glEnable(GL_DEPTH_TEST)
  glEnable(GL_BLEND)
  glEnable(GL_CULL_FACE)
  #glEnable(GL_MULTISAMPLE)

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
    #setMVP(vars.CAMERA.MVP*translation([c.x,c.y,c.z]))

    #glUniformMatrix4fv(location_mvp, 1, false, x.mvp)
    #glDrawElements(GL_TRIANGLES, vars.chunkData.draw.count, GL_UNSIGNED_INT, C_NULL )
    #glDrawArrays(GL_TRIANGLES, 0, vars.chunkData.draw.count)
  #  nothing
  #end

  #=
  if use_geometry_shader
    loopBlocks() = render(vars.MYCHUNK.childs[1])
  else
    if compileAndLink
      objptr = createLoop(1,refblocks,render) #compileAndLink
      loopBlocks() = loopByObject(objptr) #compileAndLink
    else
      loopBlocks() = for b in vars.MYCHUNK.childs; render(b); end
    end
  end
  =#
  #test()
  #uploadData()
end

function OnReload()
end

function OnRender2()
end

function OnUpdate2()
end

""" TODO """
function OnUpdate()
  checkForUpdate()
end

""" TODO """
function OnRender()
  # Pulse the background
  #c=0.5 * (1 + sin(i * 0.01)); i+=1
  #glClearColor(c, c, c, 1.0)
  #glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)

  #print("loopBlocks "); @time
  #loopBlocks()

  if vars.render_ready
    checkCamera()

    if vars.RENDER_METHOD < 7
      glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT | GL_STENCIL_BUFFER_BIT)

      glPolygonMode(GL_FRONT_AND_BACK, vars.WIREFRAME ? GL_LINE : GL_FILL)

      glActiveTexture(GL_TEXTURE0)
      glBindTexture(GL_TEXTURE_2D, vars.texture_blocks)

      if vars.fileredCount > 0 #isValid(vars.MYCHUNK)
        useProgram(vars.PROGRAMS[:CHUNKS])
        #glPolygonMode(GL_FRONT_AND_BACK, vars.WIREFRAME ? GL_LINE : GL_FILL)
        glBindVertexArray(vars.chunkData.vao)

        if vars.RENDER_METHOD == 1 glDrawArrays(GL_POINTS, 0, vars.fileredCount) #GL_TRIANGLE_STRIP
        elseif vars.RENDER_METHOD == 2 glDrawArraysInstanced(GL_TRIANGLES, 0, vars.chunkData.draw.count, vars.fileredCount)
        elseif vars.RENDER_METHOD == 3 glDrawElementsInstanced(GL_TRIANGLES, vars.chunkData.draw.count, GL_UNSIGNED_INT, C_NULL, vars.fileredCount)
        #glDrawElementsInstancedBaseVertex(GL_TRIANGLES, vars.chunkData.draw.count / 6, GL_UNSIGNED_INT, C_NULL, mychunk.count, 0)
        elseif vars.RENDER_METHOD == 4
          #* thats slow! (glDrawElements ~60 fps, glDrawElementsInstanced ~ 200 fps !!!)
          for b in getFilteredChilds(vars.MYCHUNK)
            if location_texindex > -1 glUniform1f(location_texindex, b.typ) end
            if location_position > -1 glUniform3fv(location_position, 1, b.pos) end
            glDrawElements(GL_TRIANGLES, vars.chunkData.draw.count, GL_UNSIGNED_INT, C_NULL)
          end
        elseif vars.RENDER_METHOD == 5
          #glDrawArrays(GL_TRIANGLES, 0, vars.chunkData.draw.count)
        end
        glBindVertexArray(0)
      end
    end

    if vars.RENDER_METHOD == 7
      glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT | GL_STENCIL_BUFFER_BIT)

      useProgram(vars.PROGRAMS[:COMPUTE])

      setMode("destTex", 0)
      setMode("roll", FRAMES*0.01f0)

      #@GLCHECK glUniform1i(glGetUniformLocation(vars.PROGRAMS[:COMPUTE], "destTex"), 0)
      #@GLCHECK glUniform1f(glGetUniformLocation(vars.PROGRAMS[:COMPUTE], "roll"), FRAMES*0.01f0)

      glActiveTexture(GL_TEXTURE0)
      glBindTexture(GL_TEXTURE_2D, vars.texture_screen)

      glDispatchCompute(512/1, 512/1, 1)

      useProgram(vars.PROGRAMS[:SCREEN])
      setMode("srcTex", 0)
      #@GLCHECK glUniform1i(glGetUniformLocation(vars.PROGRAMS[:SCREEN], "srcTex"), 0)

      glBindVertexArray(vars.screenData.vao)
      glMemoryBarrier(GL_SHADER_IMAGE_ACCESS_BARRIER_BIT) # make sure writing to image has finished before read
      glDrawArrays(GL_TRIANGLE_STRIP, 0, vars.screenData.draw.count)

      glBindVertexArray(0)
    end

    if vars.RENDER_METHOD == 8
      #frameBufferCounter+=1
      #if frameBufferCounter > frameBufferMax frameBufferCounter=1 end

      vars.ITIME = programTime()

      #glBlendFunc(GL_ONE, GL_ZERO)
      #glDisable( GL_BLEND )

      glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT | GL_STENCIL_BUFFER_BIT)

      #glActiveTexture(GL_TEXTURE0)
      #glBindTexture(GL_TEXTURE_2D, vars.texture_screen)

      glActiveTexture(GL_TEXTURE1)
      glBindTexture(GL_TEXTURE_2D, vars.texture_depth)

      glActiveTexture(GL_TEXTURE2)
      glBindTexture(GL_TEXTURE_2D, vars.texture_blocks)

      glActiveTexture(GL_TEXTURE3)
      glBindTexture(GL_TEXTURE_2D, vars.texture_screen)

      glActiveTexture(GL_TEXTURE4)
      glBindTexture(GL_TEXTURE_2D, vars.texture_heightMap)

      # calculate landscape
      if vars.GPU_CHUNKS_INIT || vars.CAMERA_UPDATED
        useProgram(vars.PROGRAMS[:COMPUTE])
        setMode("iTime", vars.ITIME)
        glDispatchCompute(512/1, 512/1, 1)
      end

      ###################################

      glDepthMask(GL_FALSE)

      useProgram(vars.PROGRAMS[:BG])

      setMode("iTime", vars.ITIME)
      setMode("iResolution", Float32[vars.WIDTH,vars.HEIGHT])
      setMode("iCamPos", vars.CAMERA.position)
      setMode("iCamAng", vars.CAMERA.rotation)
      setMode("iProj", vars.CAMERA.projectionMat)
      setMode("iView", vars.CAMERA.viewMat)
      #setMode("iMVP", eyeMat4x4f)

      glMemoryBarrier(GL_SHADER_IMAGE_ACCESS_BARRIER_BIT) # make sure writing to image has finished before read

      glBindVertexArray(vars.screenData.vao)
      glDrawArrays(GL_TRIANGLE_STRIP, 0, vars.screenData.draw.count)

      glBindVertexArray(0)
      glDepthMask(GL_TRUE)
      #################################

      gpu_updateChunks()

      if vars.MSAA
        glBindFramebuffer(GL_FRAMEBUFFER, vars.fbo_msaa)
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT | GL_STENCIL_BUFFER_BIT)
      end
      glPolygonMode(GL_FRONT_AND_BACK, vars.WIREFRAME ? GL_LINE : GL_FILL)
      useProgram(vars.PROGRAMS[:INDIRECT])
      drawChunk(Float32[0,0,0])
      glPolygonMode(GL_FRONT_AND_BACK, GL_FILL)

      if vars.MSAA
        # 2. now blit multisampled buffer(s) to normal colorbuffer of intermediate FBO. Image is stored in screenTexture
        glBindFramebuffer(GL_READ_FRAMEBUFFER, vars.fbo_msaa);
        glBindFramebuffer(GL_DRAW_FRAMEBUFFER, vars.fbo_intermediate);
        glBlitFramebuffer(0, 0, vars.WIDTH, vars.HEIGHT, 0, 0, vars.WIDTH, vars.HEIGHT, GL_COLOR_BUFFER_BIT, GL_NEAREST);

        # 3. now render quad with scene's visuals as its texture image
        glBindFramebuffer(GL_FRAMEBUFFER, 0);

        useProgram(vars.PROGRAMS[:SCREEN])
        setMode("srcTex", 0)

        glMemoryBarrier(GL_SHADER_IMAGE_ACCESS_BARRIER_BIT) # make sure writing to image has finished before read
        glBindVertexArray(vars.screenData.vao)
        glActiveTexture(GL_TEXTURE0)
        glBindTexture(GL_TEXTURE_2D, vars.texture_screen)
        glDrawArrays(GL_TRIANGLE_STRIP, 0, vars.screenData.draw.count)
      end
      #################################
      #=
      useProgram(vars.PROGRAMS[:NORMAL])
      glPolygonMode(GL_FRONT_AND_BACK, GL_LINE)

      if vars.GPU_CHUNKS_INIT #|| vars.CAMERA_UPDATED
        SetCamera(vars.FRUSTUM, Vec3f(vars.CAMERA.position), Vec3f(vars.CAMERA.position+CameraManager.forward(vars.CAMERA)), Vec3f(0,1,0); far=100f0)
        linkData(vars.planeData, :vertices=>(getVertices(vars.FRUSTUM),3))
        linkData(vars.boxData, :vertices=>(DATA_CUBE,3)) #getBox(vars.FRUSTUM)
        setAttributes(vars.planeData, vars.PROGRAMS[:NORMAL])
        setAttributes(vars.boxData, vars.PROGRAMS[:NORMAL])
      end
      setMode("iMVP", vars.CAMERA.MVP)

      setMode("color", Vec4f(1,0,0,1))
      glBindVertexArray(vars.planeData.vao)
      glDrawArrays(GL_TRIANGLES, 0, vars.planeData.draw.count)

      glBindVertexArray(0)
      glPolygonMode(GL_FRONT_AND_BACK, GL_FILL)

      setMode("color", Vec4f(0,0,1,1))
      glBindVertexArray(vars.boxData.vao)

      for i=1:(vars.VISIBLE_CHUNKS_COUNT)
        setMode("iPosition", vars.VISIBLE_CHUNKS[i].pos)
        glDrawArrays(GL_TRIANGLES, 0, vars.boxData.draw.count)
      end
      =#

      #################################

      useProgram(vars.PROGRAMS[:FG])
      setMode("iTime", vars.ITIME)
      setMode("iResolution", Float32[vars.WIDTH,vars.HEIGHT])
      setMode("iCamPos", vars.CAMERA.position)
      setMode("iCamAng", vars.CAMERA.rotation)
      setMode("iProj", vars.CAMERA.projectionMat)
      setMode("iView", vars.CAMERA.viewMat)

      glActiveTexture(GL_TEXTURE1)
      glBindTexture(GL_TEXTURE_2D, vars.texture_depth)

      glBindVertexArray(vars.screenData.vao)
      glMemoryBarrier(GL_SHADER_IMAGE_ACCESS_BARRIER_BIT) # make sure writing to image has finished before read
      glDrawArrays(GL_TRIANGLE_STRIP, 0, vars.screenData.draw.count)

      #glDrawBuffer(GL_BACK)
      #glReadBuffer(GL_FRONT)
    end

    ##############################################

    #ptr = Ptr{GLuint}(glMapBufferRange(GL_ATOMIC_COUNTER_BUFFER, 0,1*sizeof(GLuint),  GL_MAP_READ_BIT|GL_MAP_WRITE_BIT))
    #counter = convert(GLuint, unsafe_load(ptr))
    #println(counter)

  end
  if vars.CAMERA_UPDATED vars.CAMERA_UPDATED=false end
  if vars.GPU_CHUNKS_INIT vars.GPU_CHUNKS_INIT=false end

end

end # SCRIPT
