#VERSION >= v"0.4.0-dev+6521" && __precompile__(true)

println("Include pre-libs.") 
#include("Includes.jl")
include("TimeManager.jl")

"""
TODO
"""
module App

#ThreadMutex = Threads.Mutex()
#PrintMutex = Threads.Mutex()

#function call(f::Function, args...;mutex=ThreadMutex)
#	Threads.lock(mutex)
#	result = f(args...)
#	Threads.unlock(mutex)
#  result
#end

#print(args...) = call(Base.print, args...; mutex=PrintMutex)
#println(args...) = call(Base.println, args...; mutex=PrintMutex)
#error(args...) = call(Base.error, args...; mutex=PrintMutex)
#warn(args...) = call(Base.warn, args...; mutex=PrintMutex)
#sleep(n) = Libc.systemsleep(n)

using ..TimeManager
#using ..ThreadManager

## INCLUDES
println("Include libs.")
include("libs.jl")
include("shader.jl")
println("Set Vars.") 

USE_PROCESSES = false

workers = Future[]
channels=Dict{Symbol,Distributed.AbstractRemoteRef}()

updateChannels(chs::Dict{Symbol,Distributed.AbstractRemoteRef}) = global channels=chs
getChannels() = channels
register(id, channel) = channels[id]=channel

## COMPILE C File
const compileAndLink = isdefined(@__MODULE__,:USE_COMPILE) 
if compileAndLink
  include("compileAndLink.jl")
  compileWithGCC()
 end

CAM_LOCK = false
WIREFRAME = false
TEXTUREMODE = true
LIGHTMODE = true
FRUSTUM_CULLING = true
HIDE_UNSEEN_CUBES = true
RENDER_METHOD = 8
mychunk = nothing
program_chunks = 0
program_compute = 0
program_screen = 0
program_compute_instances = 0
program_indirect_chunks = 0
SCENE = 2
fstm = nothing

chunkData = nothing
chunkData_upload = nothing
chunk_instances = nothing
planeData = nothing
screenData = nothing
boxData = nothing
indirectData = nothing

CHUNK_SIZE = 128
current_program = 0
load_once = true
workPool = nothing
MVP = nothing
render_ready = false
fileredCount = 0
uploaded = false
texture_screen = 0
texture_blocks = 0

GPU_FRUSTUM = true

#---------------------------------------------

channels[:JOBS]=RemoteChannel(()->Channel{Function}(Inf))
channels[:TRIGGER]=RemoteChannel(()->Channel{Bool}(1))
channels[:CAMERA]=RemoteChannel(()->Channel{Tuple{Array{Float32,1},Array{Float32,1}}}(Inf))
channels[:BOOL]=RemoteChannel(()->Channel{Tuple{Symbol,Bool}}(Inf))
channels[:SCENE]=RemoteChannel(()->Channel{Int}(1))
channels[:UPLOAD]=RemoteChannel(()->Channel{Symbol}(Inf))

#---------------------------------------------

chunk_instances = SharedArray(Float32[])
setChunkInstances(data) = global chunk_instances = data
getChunkInstances() = chunk_instances

plane_vertices = SharedArray(Float32[])
setPlaneVertices(data) = global plane_vertices = data
getPlaneVertices() = plane_vertices

box_vertices = SharedArray(Float32[])
setBoxVertices(data) = global box_vertices = data
getBoxVertices() = box_vertices

#---------------------------------------------

println("Include Objects.")
include("cubeData.jl")
using .DefaultModelData
include("camera.jl")
using .CameraManager
include("frustum.jl")
using .FrustumManager
include("chunk.jl")
using .ChunkManager
include("mesh.jl")
using .MeshManager
include("texture.jl")
using .TextureManager
println("Set Functions.")

#---------------------------------------------

CAMERA = CameraManager.CAMERA
mouseKeyPressed = CameraManager.mouseKeyPressed
keyPressed = CameraManager.keyPressed
keyPressing = CameraManager.keyPressing
keyValue = CameraManager.keyValue

GPU_CHUNKS = ChunkManager.GPU_CHUNKS

#---------------------------------------------

function init()
  global fstm = Frustum()
  
  presetCamera()
  
  if myid() == 1
    global chunkData = MeshData()
    global chunkData_upload = MeshData()
    global planeData = MeshData()
    global screenData = MeshData()
    global boxData = MeshData()
    global indirectData = MeshData()
    presetTextures()
    chooseRenderMethod()
  end
  
  if myid() != 1 || length(procs()) <= 1
    global mychunk = Chunk()
    createChunk(mychunk)
  end
end

function presetCamera()
  setPosition(CAMERA,[0f0,0,0])
  setProjection(CAMERA, projection_perspective(FOV, RATIO, CLIP_NEAR, CLIP_FAR))
  Update(CAMERA)
  global MVP = CAMERA.MVP
  SetFrustum(fstm, FOV, RATIO, CLIP_NEAR, 1000f0)
  SetCamera(fstm, Vec3f(CAMERA.position), Vec3f(CAMERA.position+CameraManager.forward(CAMERA)), Vec3f(0,1,0))
end

function presetTextures()
  global texture_blocks = uploadTexture("blocks.png")
  global texture_screen = uploadTexture((512,512))
end

"""
TODO
"""
function use_program(program, f::Function)
  if program != current_program
    glCheck(glUseProgram(program))
  end
  glCheck(f())
  if program != current_program
    glCheck(glUseProgram(current_program))
  end
end

"""
sets a mode in a shader.
"""
function setMode(program, name, value, mode="")
  use_program(program, () -> begin
    l = glGetUniformLocation(program, name)
    if l>-1
      if isa(value, Integer) glUniform1i(l, value)
      elseif isa(value, AbstractFloat) glUniform1f(l, value)
      elseif isa(value, AbstractArray) glUniform1fv(l, 1, value)
      else warn("MODE("*stringColor(mode;color=:yellow)*") for "*typeof(value)*" is not implemented yet.")
      end
    end
  if mode != "" println("MODE(",stringColor(mode;color=:yellow),"): ",stringColor(value;color=:yellow)) end
  end)
end

"""
TODO
"""
function setFrustumMode()
  SetCamera(fstm, Vec3f(CAMERA.position), Vec3f(CAMERA.position+CameraManager.forward(CAMERA)), Vec3f(0,1,0))
  if !GPU_FRUSTUM
    updateChunk(mychunk)
    uploadChunk(:UPDATE)
  end
end

"""
TODO
"""
function updateChunk(this::Chunk)
  #global chunkData, chunkData_upload, planeData, boxData
  #println("update Chunk")

  if !GPU_FRUSTUM && FRUSTUM_CULLING
    #println("checkInFrustum")
    checkInFrustum(this, fstm)
  else
    #println("showAll")
    showAll(this)
  end

  #println("setChunkInstances")
  setChunkInstances(getData(this))
  setPlaneVertices(getVertices(fstm))
  setBoxVertices(getBox(fstm))
  
  global BLOCK_COUNT = this.fileredCount
  #global VERT_COUNT = this.verticesCount
  
  #println("send Chunk data")
   if myid() != 1 remotecall(setChunkInstances, 1, chunk_instances) end
end

function createChunk(this::Chunk)
  global SCENE
  
  println("Create chunk & create blocks...")
  
  if myid() != 1
    sz=channels[:SCENE]
    if isready(sz) SCENE=take!(sz) end
  end
  
  ChunkManager.reset(this; size=CHUNK_SIZE)
  
  #println("Set Chunk scenery")
    
  if SCENE == 0 createSingle(this)
  elseif SCENE == 1 createExample(this)
  else createLandscape(this)
  end
  
  update(this; unseen=HIDE_UNSEEN_CUBES)
  
  updateChunk(this)
  uploadChunk(:CREATE)
end

function uploadChunk(s)
  global uploaded = s
  if myid() == 1 return end
  #println("upload Chunk")
  #@save "chunk.jld2" chunk_instances
  put!(channels[:UPLOAD],s)
end

function loadChunk()
  if length(procs()) <= 1 return uploaded end

  upload=channels[:UPLOAD]
  if !isready(upload) return :NOTHING end
  #println("load Chunk")
  m = take!(upload)
  #@load "chunk.jld2" chunk_instances
  m
end

"""
TODO
"""
function chooseRenderMethod(method=RENDER_METHOD)
  global RENDER_METHOD
  if method != RENDER_METHOD RENDER_METHOD = method end
  
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
  
  
  println("CHUNK SIZE: ",stringColor(string(CHUNK_SIZE,"�");color=:yellow))
  println("SCENE: ",stringColor(SCENE;color=:yellow))
  println("METHOD(",stringColor(method;color=:yellow),"): ",stringColor(method," = ", name; color=:yellow))
  
  if name == "NOT DEFINED" return end

  if myid() != 1 put!(channels[:SCENE],SCENE) end
  #createChunk(mychunk)
  
  global uploaded = :YES
  global render_ready = false
end


render_init = false

struct IndirectCommand
  count::GLuint
  primCount::GLuint
  firstIndex::GLuint
  baseVertex::GLuint
  baseInstance::GLuint
  
  IndirectCommand(count=0, primCount=0) = new(count,primCount,0,0,0)
end

function createInstanceBuffer()
  if GPU_CHUNKS
    use_program(program_compute_chunks, () -> begin
      glBindBuffer(GL_DISPATCH_INDIRECT_BUFFER , indirectData.arrays[:indirect_dispatch].bufferID)
      glBindBufferBase(GL_ATOMIC_COUNTER_BUFFER, 0, indirectData.arrays[:indirect].bufferID)
      glBindBufferBase(GL_SHADER_STORAGE_BUFFER, 0, indirectData.arrays[:chunks_default].bufferID)
      glBindBufferBase(GL_SHADER_STORAGE_BUFFER, 1, indirectData.arrays[:points_default].bufferID)
    end)
  end
  
  use_program(program_compute_instances, () -> begin
    glBindBuffer(GL_DISPATCH_INDIRECT_BUFFER , indirectData.arrays[:indirect_dispatch_instances].bufferID)
    glBindBufferBase(GL_ATOMIC_COUNTER_BUFFER, 0, indirectData.arrays[:indirect].bufferID)
    glBindBufferBase(GL_SHADER_STORAGE_BUFFER, 0, indirectData.arrays[GPU_CHUNKS ? :points_default : :chunks_default].bufferID)
    glBindBufferBase(GL_SHADER_STORAGE_BUFFER, 1, indirectData.arrays[:points].bufferID)
  end)
 
  nothing
end

function uploadData()
  glCheck()
  
  global render_init, render_ready

  m=loadChunk()
  if m == :NOTHING return end
  
  #chunk_instances = sdata(chunk_instances)
  #plane_vertices = sdata(plane_vertices)
  #box_vertices = sdata(box_vertices)
  
  global fileredCount = length(chunk_instances)

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
  
  if !render_init
    #linkData(chunkData, :vertices=>(DATA_PLANE_VERTEX,3), :indicies=>(DATA_PLANE_INDEX,1,GL_ELEMENT_ARRAY_BUFFER, true), :instances=>chunk_instances)
    linkData(planeData,  :vertices=>plane_vertices)
    linkData(boxData,  :vertices=>box_vertices)
    linkData(screenData,  :vertices=>(DATA_PLANE2D_VERTEX_STRIP,2)) #, :indicies=>(DATA_PLANE_INDEX,1,GL_ELEMENT_ARRAY_BUFFER, true))
     #GL_DYNAMIC_COPY
    SZ=sizeof(Float32)*5*CHUNK_SIZE^3
    dispatch = round(UInt32,Float32(length(chunk_instances)) / CHUNK_SIZE)
    linkData(indirectData, :points=>zeros(Float32,SZ), :chunks_default=>chunk_instances, :points_default=>zeros(Float32,SZ),
    :indirect_dispatch=>(GLuint[dispatch,1,1],1,GL_DISPATCH_INDIRECT_BUFFER, GL_STREAM_READ),
    :indirect_dispatch_instances=>(GLuint[dispatch,1,1],1,GL_DISPATCH_INDIRECT_BUFFER, GL_STREAM_READ),
    :indirect=>(GLuint[0,1,0,0,0],1,GL_DRAW_INDIRECT_BUFFER))
  end
  
  println("Load shader files...")
  (INST_VSH, INST_VSH_GSH, INST_GSH, INST_FSH, VSH_TEXTURE, VSH, FSH, GSH, CSH, SCREEN_VSH, SCREEN_FSH, INST_CSH, CHUNKS_CSH, INST_CSH_VSH_GSH) = loadShaders()
  
  global program_chunks
  if method < 7
    if program_chunks != 0
      println("Unbind & Delete previous program")
      glCheck(glUseProgram(program_chunks))
      glCheck(glDeleteProgram(program_chunks))
      program_chunks = 0
    end
  end
  
  println("Create & Compile shader programs...")

  if method < 7
    if method == 1 program_chunks = createShaderProgram([INST_VSH_GSH, INST_FSH, INST_GSH])
    elseif method > 1 && method <= 3 program_chunks = createShaderProgram([INST_VSH, INST_FSH])
    elseif method == 4 program_chunks = createShaderProgram([VSH_TEXTURE, INST_FSH])
    elseif method == 5 program_chunks = createShaderProgram([VSH_TEXTURE, INST_FSH])
    elseif method == 6 program_chunks = createShaderProgram([VSH, FSH])
    end
    
    if program_chunks <= 0 error("No Program") end
  end
  
  if !render_init
    global program_normal = createShaderProgram([VSH, FSH])#, createShader(GSH, GL_GEOMETRY_SHADER)
    global program_screen = createShaderProgram([SCREEN_VSH, SCREEN_FSH])
    global program_compute = createShaderProgram([CSH])
    global program_compute_chunks = createShaderProgram([CHUNKS_CSH])
    global program_compute_instances = createShaderProgram([INST_CSH])
    global program_indirect_chunks = createShaderProgram([INST_CSH_VSH_GSH, INST_FSH, INST_GSH])
    
    createInstanceBuffer()
  end
  
  println("set Attributes and Uniforms...")
  
  if !render_init
    setAttributes(indirectData, program_indirect_chunks)
    setAttributes(planeData, program_normal)
    setAttributes(boxData, program_normal)
    setAttributes(screenData, program_screen)
    
    setMVP(program_indirect_chunks, MVP)
  end
  
   println("Continue...")
  
   if method < 7 
    setAttributes(chunkData, program_chunks)

    setMVP(program_chunks, MVP)
    
    global location_position = glGetUniformLocation(program_chunks, "iPosition")
    global location_texindex = glGetUniformLocation(program_chunks, "iTexIndex")
    
    setMode(program_chunks, "iUseLight", LIGHTMODE)
    setMode(program_chunks, "iUseTexture", TEXTUREMODE)
  end
  
  if !render_init render_init = true end
  if !render_ready render_ready = true end
  global uploaded=:NOTHING
end

function fetchlast!(c::Distributed.AbstractRemoteRef)
  v=nothing; while isready(c) v=take!(c); end; v
end

function waitAndUpdateChunks()
  global CAMERA, FRUSTUM_CULLING, HIDE_UNSEEN_CUBES
  
  println("Presets")
  
  cameradata=channels[:CAMERA]
  bools=channels[:BOOL]

  init()
  
  trigger=false
  
  println("start update")
  while true

    if (data=fetchlast!(cameradata)) != nothing
      CAMERA.position, CAMERA.rotation = data
      Update(CAMERA)
      #println("updated Camera")
    end
    
    while isready(bools)
      v=take!(bools)
      id, value = v
      if id == :FRUSTUM_CULLING FRUSTUM_CULLING = value;
      elseif id == :HIDE_UNSEEN_CUBES HIDE_UNSEEN_CUBES = value;
      end
      trigger = true
    end
    
    if trigger
      trigger = false
      setFrustumMode()
    end
      
    sleep(0.1)
  end
  nothing
end


GPU_CHUNKS_INIT = true

"""
TODO
"""
function checkForUpdate()
  global keyPressed, keyValue, cam_updated, FRUSTUM_KEY, ALL_KEY, CAMERA
  #channels["KEYS"]
  
  uploadData()
  
  if RENDER_METHOD == 7
    use_program(program_compute, () -> begin
      glCheck(glUniform1i(glGetUniformLocation(program_compute, "destTex"), 0))
      glCheck(glUniform1f(glGetUniformLocation(program_compute, "roll"), FRAMES*0.01f0))
    end)
    
    use_program(program_screen, () -> begin
      glCheck(glUniform1i(glGetUniformLocation(program_screen, "srcTex"), 0))
    end)
  end
  
  if keyPressed
  
    if keyValue == 80 #p
      setPosition(CAMERA,[0f0,0,0])
      
    elseif keyValue == 81 #q
      global WIREFRAME=!WIREFRAME
      info("WIREFRAME: $WIREFRAME")
      
    elseif keyValue == 84 && render_ready #t
      global TEXTUREMODE=!TEXTUREMODE
      info("TEXTUREMODE: $TEXTUREMODE")
      setMode(program_chunks, "iUseTexture", TEXTUREMODE, "TEXTURE")
      
    elseif keyValue == 76 && render_ready #l
      global LIGHTMODE=!LIGHTMODE
      info("LIGHTMODE: $LIGHTMODE")
      setMode(program_chunks, "iUseLight", LIGHTMODE, "LIGHT")

    elseif keyValue == 82 #r
      chooseRenderMethod()
      
    elseif (keyValue >= 290 && keyValue <= 301) # F1 - F12
      chooseRenderMethod(keyValue - 289)
      
    elseif keyValue >= 49 && keyValue <= 57 #1
      global CHUNK_SIZE = 2^(58-keyValue)
      global GPU_CHUNKS_INIT = true
      
    #=
    elseif keyValue == 49 #1
      global CHUNK_SIZE = 1
      chooseRenderMethod()
      
    elseif keyValue == 50 #2
      global CHUNK_SIZE = 4
      chooseRenderMethod()
      
    elseif keyValue == 51 #3
      global CHUNK_SIZE = 8
      chooseRenderMethod()
      
    elseif keyValue == 52 #4
      global CHUNK_SIZE = 16
      chooseRenderMethod()
      
    elseif keyValue == 53 #5
      global CHUNK_SIZE = 24
      chooseRenderMethod()
      
    elseif keyValue == 54 #6
      global CHUNK_SIZE = 32
      chooseRenderMethod()
      
    elseif keyValue == 55 #7
      global CHUNK_SIZE = 40
      chooseRenderMethod()
      
    elseif keyValue == 56 #8
      global CHUNK_SIZE = 48
      chooseRenderMethod()
      
    elseif keyValue == 57 #9
      global CHUNK_SIZE = 56
      chooseRenderMethod()
      
    elseif keyValue == 48 #0
      global CHUNK_SIZE = 64
      chooseRenderMethod()
      
    elseif keyValue == 45 #�
      global CHUNK_SIZE = 72
      chooseRenderMethod()
      
    elseif keyValue == 61 #�
      global CHUNK_SIZE = 96
      chooseRenderMethod()
      
    elseif keyValue == 96 #^
      global CHUNK_SIZE = 128
      chooseRenderMethod()
    =#
      
    elseif keyValue == 66 #b
      global SCENE = 0
      chooseRenderMethod()
    elseif keyValue == 78 #n
      global SCENE = 1
      chooseRenderMethod()
    elseif keyValue == 77 #m
      global SCENE = 2
      chooseRenderMethod()
      
    elseif keyValue == 70 #f
      #put!(channels[:BOOL], (:NOTHING, false))
      global CAM_LOCK = !CAM_LOCK
      info("CAM LOCK: $CAM_LOCK")
    elseif keyValue == 86 #v
      global FRUSTUM_CULLING = !FRUSTUM_CULLING
      put!(channels[:BOOL], (:FRUSTUM_CULLING, FRUSTUM_CULLING))
    elseif keyValue == 79 #o
      global HIDE_UNSEEN_CUBES = !HIDE_UNSEEN_CUBES
      put!(channels[:BOOL], (:HIDE_UNSEEN_CUBES, HIDE_UNSEEN_CUBES))
    end
  end
    
  if keyPressed keyPressed=false end
end

"""
TODO
"""
useProgram(program) = begin global current_program = program; glUseProgram(program) end

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

function setFrustum(program)
  use_program(program, () -> begin
    dirs=[x.mNormal for (_,x) in fstm.planes] #getDirections(fstm)
    dists=[x.d for (_,x) in fstm.planes]  #getDistances(fstm)
    glCheck(glUniform1i(glGetUniformLocation(program, "frustum"), true))
    if !CAM_LOCK
      glCheck(glUniform3fv(glGetUniformLocation(program, "frustum_dirs"), length(dirs), dirs))
      glCheck(glUniform1fv(glGetUniformLocation(program, "frustum_dists"), length(dists), dists))
    end
  end)
end

#setMVP(mvp) = setMatrix(program, "iMVP", mvp)

## PROGRAM

function createProcess(pool)
  global channels
  chs = channels
  push!(workers, remotecall(function()
    println("LOOP START")
    while true
      #fetch(remoteChannels)  #wait until first channel
      #chs = Dict([c for c in remoteChannels])
      println("updateChannels")
      updateChannels(chs)
      
      has = haskey(chs, :JOBS)
      if has
        println("GET JOB")
        job=take!(chs[:JOBS])
        println("START JOB")
        job() # execute job
        println("END JOB")
      end
      
      sleep(has ? 0 : 1)
    end
    true
  end, pool))
end

waitToEnd() = for w in workers println(fetch(w)) end

addJob(job) = put!(channels[:JOBS],job)

#remoteChannels=RemoteChannel(()->Channel{Tuple{Symbol,Distributed.AbstractRemoteRef}}(0))
#put!(remoteChannels,(:JOBS,RemoteChannel(()->Channel{Function}(0))))
#put!(remoteChannels,(:TRIGGERUPDATE,RemoteChannel(()->Channel{Bool}(0))))
#channels = Dict([c for c in remoteChannels])
  
"""
TODO
"""
function run()
  println("---------------------------------------------------------------------")
  println("Start Program @ ", Dates.time())
  InteractiveUtils.versioninfo()
  
  println("Create Window...")
  # OS X-specific GLFW hints to initialize the correct version of OpenGL
  GLFW.Init()
      
  # Create a windowed mode window and its OpenGL context
  global window = GLFW.CreateWindow(WIDTH, HEIGHT, "OpenGL Example")

  # Make the window's context current
  GLFW.MakeContextCurrent(window)

  GLFW.SetWindowSize(window, WIDTH, HEIGHT) # Seems to be necessary to guarantee that window > 0
  rezizeWindow(window, WIDTH,HEIGHT)

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
  glDebug(true) # set debugging

  glinfo = createcontextinfo()

  println("OpenGL $(stringColor(glinfo[:gl_version];color=:red))")
  println("GLSL $(stringColor(glinfo[:glsl_version];color=:red))")
  println("Vendor $(stringColor(glinfo[:gl_vendor];color=:red))")
  println("Renderer $(stringColor(glinfo[:gl_renderer];color=:red))")
  println("---------------------------------------------------------------------")
  sleep(0)
  
  #------------------------------------------------------------------------------------

  init()
  
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

  cam_updated=false

  SLEEP=0 #1f0/200

  i=0
  
  function checkCamera()
    if OnUpdate(CAMERA)
      #if !CAM_LOCK
        if RENDER_METHOD < 7 
          setMVP(program_chunks, CAMERA.MVP)
          setMVP(program_normal, CAMERA.MVP)
          setFrustum(program_chunks)
        end
        if RENDER_METHOD == 8
          setMVP(program_indirect_chunks, CAMERA.MVP)
          setFrustum(program_compute_instances)
        end
      #end
      if length(procs()) > 1 put!(channels[:BOOL], (:NOTHING, false))
      else setFrustumMode()
      end
      cam_updated=true
    end
  end
  
  """
  TODO
  """
  while !GLFW.WindowShouldClose(window)
    showFrames()
    UpdateCounters()
    checkForUpdate()

    # Pulse the background
    #c=0.5 * (1 + sin(i * 0.01)); i+=1
    #glClearColor(c, c, c, 1.0)
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)

    #print("loopBlocks "); @time
    #loopBlocks()
    
    glPolygonMode(GL_FRONT_AND_BACK, WIREFRAME ? GL_LINE : GL_FILL)
    
    if render_ready
      checkCamera()
      if cam_updated cam_updated=false end
    
      if RENDER_METHOD < 7
        glActiveTexture(GL_TEXTURE0)
        glBindTexture(GL_TEXTURE_2D, texture_blocks)
      
        if fileredCount > 0 #isValid(mychunk)
          useProgram(program_chunks)
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

        ##############################################
        
        useProgram(program_normal)
        glPolygonMode(GL_FRONT_AND_BACK, GL_LINE)
        
        #setMode(program_normal, "color", Vec3f(1,0,0))
        
        glBindVertexArray(boxData.vao)
        glDrawArrays(GL_TRIANGLES, 0, boxData.draw.count)
        glBindVertexArray(0)

        #setMode(program_normal, "color", Vec3f(1,1,0))
        
        glBindVertexArray(planeData.vao)
        glDrawArrays(GL_TRIANGLES, 0, planeData.draw.count)
        glBindVertexArray(0)
      end
      
      if RENDER_METHOD == 7
        useProgram(program_compute)
        glBindVertexArray(0)
        
        glActiveTexture(GL_TEXTURE0)
        glBindTexture(GL_TEXTURE_2D, texture_screen)

        glDispatchCompute(512/1, 512/1, 1)
        
        useProgram(program_screen)
        glBindVertexArray(screenData.vao)
        glMemoryBarrier(GL_SHADER_IMAGE_ACCESS_BARRIER_BIT) # make sure writing to image has finished before read
        glDrawArrays(GL_TRIANGLE_STRIP, 0, screenData.draw.count)
        
        glBindVertexArray(0)
      end
      
      if RENDER_METHOD == 8
      
        if GPU_CHUNKS && GPU_CHUNKS_INIT
          global GPU_CHUNKS_INIT = false
          useProgram(program_compute_chunks)
          glDispatchComputeIndirect(C_NULL)
          glMemoryBarrier(GL_COMMAND_BARRIER_BIT | GL_VERTEX_ATTRIB_ARRAY_BARRIER_BIT | GL_SHADER_STORAGE_BARRIER_BIT | GL_ATOMIC_COUNTER_BARRIER_BIT)
        end
      
        useProgram(program_compute_instances)
        glDispatchComputeIndirect(C_NULL)
        glMemoryBarrier(GL_COMMAND_BARRIER_BIT | GL_VERTEX_ATTRIB_ARRAY_BARRIER_BIT | GL_SHADER_STORAGE_BARRIER_BIT | GL_ATOMIC_COUNTER_BARRIER_BIT) # GL_ATOMIC_COUNTER_BARRIER_BIT GL_SHADER_IMAGE_ACCESS_BARRIER_BIT
        
        glActiveTexture(GL_TEXTURE0)
        glBindTexture(GL_TEXTURE_2D, texture_blocks)
      
        useProgram(program_indirect_chunks)
        
        glBindVertexArray(indirectData.vao)
        #glDrawElementsIndirect(GL_POINTS, GL_UNSIGNED_INT, Ptr{Nothing}(0))
        glDrawArraysIndirect(GL_POINTS, Ptr{Nothing}(0))
        glBindVertexArray(0)
      end
      
      #ptr = Ptr{GLuint}(glMapBufferRange(GL_ATOMIC_COUNTER_BUFFER, 0,1*sizeof(GLuint),  GL_MAP_READ_BIT|GL_MAP_WRITE_BIT))
      #counter = convert(GLuint, unsafe_load(ptr))
      #println(counter)
    end 

    # Swap front and back buffers
    GLFW.SwapBuffers(window)
    # Poll for and process events
    GLFW.PollEvents()
    
    #if SLEEP>0 Libc.systemsleep(SLEEP) end
    sleep(SLEEP)
  end
    
  GLFW.DestroyWindow(window)
  GLFW.Terminate()

  true
end #run()

function start(use_procs::Bool)
  global USE_PROCESSES = use_procs
  if use_procs
    start_processes()
  else
    #start_threads()
    error("Does not work with OpenGL, because OpenGL has to be on main thread...")
  end
end

function start_processes()
  p=procs()
  popfirst!(p)
  if length(p) > 0
    pool=WorkerPool(p)
    createProcess(pool)
    addJob(waitAndUpdateChunks)
  end
  run()
  waitToEnd()
end

#=
function thread_compute(this::ThreadManager.Thread)
  println("thread_compute")
  #timeRef = Ref(0.0)
  #i=0
  while true
    #take!(TRIGGERUPDATE)
    #if TimeManager.OnTime(0.25, timeRef)
    #  info(this, i ;title="CALC")
    #  i+=1
    #end
    #sleep(0.001)
    println("thread_compute: work")
    sleep(3)
  end
end

function thread_renderer(this::ThreadManager.Thread)
  println("thread_renderer")
  run()
end
=#

#=
function test_thread()
  id=Threads.threadid()
  i=1
  while true
    #if id==1
    #  print(".")
    #  Libc.systemsleep(0.1)
    #elseif id==2
    #  println("Compute", id)
    #  for i=1:99999999 b=i^i; end;
    #  tprintln("Compute", id, "end.")
    #  Libc.systemsleep(0.1)
    #else
      #println("Idle", id)
      #Libc.systemsleep(10)  #rand(1:10) #sleep(rand(0.1:3))
      i += 1
    #end
  end
end

# Does not work with OpenGL, because OpenGL has to be on main thread...
function start_threads()
  return false
  
  println("Start Threads")

  max=Threads.nthreads()
  Threads.@threads for i = 1:max
    if i == 1
      run()
    elseif i == 2
      test_thread()
    end
  end

  #pool = ThreadManager.thread_pool()

  #ThreadManager.set(pool, thread_compute, "Compute")
  #ThreadManager.set(pool, thread_renderer, "Renderer")
  #ThreadManager.set(pool, thread_sound, "Sound")

  #ThreadManager.start(pool) # anything below this line will be paused until threads are closed
end
=#

end #App