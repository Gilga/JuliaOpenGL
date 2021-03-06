VERSION >= v"0.4.0-dev+6521" && __precompile__(true)

"""
TODO
"""
module App

## INCLUDES
include("libs.jl")
include("shader.jl")
include("compileAndLink.jl")
  
## COMPILE C File
const compileAndLink = isdefined(:USE_COMPILE) 
if compileAndLink compileWithGCC() end

WIREFRAME = false
TEXTUREMODE = true
LIGHTMODE = true
FRUSTUM_CULLING = true
HIDE_UNSEEN_CUBES = true
RENDER_METHOD = 1
mychunk = nothing
program_chunks = 0
SCENE = 2
fstm = nothing
planeData = nothing
boxData = nothing
CHUNK_SIZE = 64
current_program = 0
load_once = true

"""
TODO
"""
function use_program(program, f)
  if program != current_program
    glUseProgram(program)
    glCheckError("glUseProgram")
  end
  f()
  if program != current_program
    glUseProgram(current_program)
    glCheckError("glUseProgram")
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
      else warn("MODE("*displayInYellow(mode)*") for "*typeof(value)*" is not implemented yet.")
      end
    end
  if mode != "" println("MODE(",displayInYellow(mode),"): ",displayInYellow(value)) end
  end)
end

"""
TODO
"""
function setFrustumCulling(load=true)
  global load_once
  if load || load_once
    SetCamera(fstm, Vec3f(CAMERA.position), Vec3f(CAMERA.position+forward(CAMERA)), Vec3f(0,1,0))
    load_once = false
  end

  if FRUSTUM_CULLING checkInFrustum(mychunk, fstm)
  else showAll(mychunk)
  end
  
  if HIDE_UNSEEN_CUBES hideUnseen(mychunk) end

  if load
    update(mychunk)
    global BLOCK_COUNT = mychunk.fileredCount
    upload(chunkData, :instances, getData(mychunk))
    if FRUSTUM_CULLING
      upload(planeData, :vertices, getVertices(fstm))
      upload(boxData, :vertices, getBox(fstm))
    end
  end
end

"""
TODO
"""
function chooseRenderMethod(method=RENDER_METHOD)

  if method == 1 name="INSTANCES of POINTS + GEOMETRY SHADER"
  elseif method == 2  name="INSTANCES of TRIANGLES"
  elseif method == 3 name="INSTANCES of TRIANGLES + INDICIES"
  elseif method == 4 name="TRIANGLES + INDICIES"
  elseif method == 5 name="TRIANGLES"
  elseif method == 6 name="TRIANGLES"
  else name="NOT DEFINED"
  end
  
  global RENDER_METHOD = method
  
  println("METHOD(",method,"): ",displayInYellow(name))
  
  if name == "NOT DEFINED" return end

  info("Create chunk & create blocks...")
  
  ## BLOCKS
  global mychunk
  clean(mychunk) # free memory

  mychunk = Chunk(CHUNK_SIZE)

  if SCENE == 0 createSingle(mychunk)
  elseif SCENE == 1 createExample(mychunk)
  else createLandscape(mychunk)
  end
  
  setFrustumCulling(false)
  
  update(mychunk)
  
  global BLOCK_COUNT = mychunk.fileredCount
  #global VERT_COUNT = mychunk.verticesCount
  
  info("Upload data...")
  glCheckError("Upload data")
  
  if method == 1 linkData(chunkData, :instances=>getData(mychunk))
  elseif method == 2 linkData(chunkData, :vertices=>(DATA_CUBE,3), :instances=>getData(mychunk))
  elseif method == 3 linkData(chunkData, :vertices=>(DATA_CUBE_VERTEX,3), :indicies=>(DATA_CUBE_INDEX,1,GL_ELEMENT_ARRAY_BUFFER, true), :instances=>getData(mychunk))
  elseif method == 4 linkData(chunkData, :vertices=>(DATA_CUBE_VERTEX,3), :indicies=>(DATA_CUBE_INDEX,1,GL_ELEMENT_ARRAY_BUFFER, true))
  elseif method > 4 linkData(chunkData, :vertices=>(DATA_CUBE,3))
  end
  
  global program_chunks
  
  if program_chunks != 0
    println("Unbind & Delete previous program")
    glUseProgram(0)
    glDeleteProgram(program_chunks)
    glCheckError("glDeleteProgram")
  end
   
  (INST_VSH, INST_VSH_GSH, INST_GSH, INST_FSH, VSH_TEXTURE, VSH, FSH, GSH) = loadShaders()

  if method == 1 program_chunks = createShaderProgram(INST_VSH_GSH, INST_FSH, INST_GSH)
  elseif method > 1 && method <= 3 program_chunks = createShaderProgram(INST_VSH, INST_FSH)
  elseif method == 4 program_chunks = createShaderProgram(VSH_TEXTURE, INST_FSH)
  elseif method == 5 program_chunks = createShaderProgram(VSH_TEXTURE, INST_FSH)
  elseif method > 5 program_chunks = createShaderProgram(VSH, FSH)
  end
  
  info("Compile Shader Programs...")
  
  if program_chunks <= 0 error("No Program") end
  glUseProgram(program_chunks)
  glCheckError("glUseProgram")
    
  setAttributes(chunkData, program_chunks)
  setMatrix(program_chunks, "iMVP", CAMERA.MVP)
  glCheckError("setMatrix")
  
  global location_position = glGetUniformLocation(program_chunks, "iPosition")
  global location_texindex = glGetUniformLocation(program_chunks, "iTexIndex")
  
  setMode(program_chunks, "iUseLight", LIGHTMODE)
  setMode(program_chunks, "iUseTexture", TEXTUREMODE)
end

"""
TODO
"""
function checkForUpdate()
  global keyPressed, keyValue, cam_updated, FRUSTUM_KEY, ALL_KEY, CAMERA, mychunk, chunkData, fstm, planeData
  
  if keyPressed
  
    if keyValue == 80 #p
      setPosition(CAMERA,[0f0,0,0])
      
    elseif keyValue == 81 #q
      global WIREFRAME=!WIREFRAME
      
    elseif keyValue == 84 #t
      global TEXTUREMODE=!TEXTUREMODE
      setMode(program_chunks, "iUseTexture", TEXTUREMODE, "TEXTURE")
      
    elseif keyValue == 76 #l
      global LIGHTMODE=!LIGHTMODE
      setMode(program_chunks, "iUseLight", LIGHTMODE, "LIGHT")

    elseif keyValue == 82 #r
      chooseRenderMethod()
      
    elseif (keyValue >= 290 && keyValue <= 301) # F1 - F12
      chooseRenderMethod(keyValue - 289)
      
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
      
    elseif keyValue == 45 #ß
      global CHUNK_SIZE = 72
      chooseRenderMethod()
      
    elseif keyValue == 61 #´
      global CHUNK_SIZE = 96
      chooseRenderMethod()
      
    elseif keyValue == 96 #^
      global CHUNK_SIZE = 128
      chooseRenderMethod()
      
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
      global FRUSTUM_CULLING = !FRUSTUM_CULLING
      setFrustumCulling()
    elseif keyValue == 86 #v
      setFrustumCulling()
    elseif keyValue == 79 #o
      global HIDE_UNSEEN_CUBES = !HIDE_UNSEEN_CUBES
      setFrustumCulling()
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
setMatrix(program, name, m) = begin const cm = SMatrix{4,4,Float32}(m); glUniformMatrix4fv(glGetUniformLocation(program, name), 1, false, cm) end

"""
TODO
"""
function setMVP(program, mvp)
  use_program(program, () -> begin
    setMatrix(program, "iMVP", mvp)
    glCheckError("setMatrix")
  end)
end

#setMVP(mvp) = setMatrix(program, "iMVP", mvp)

## PROGRAM 

"""
TODO
"""
function run()

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
global boxData = MeshData()

#------------------------------------------------------------------------------------

## TEXTURES

uploadTexture("blocks.png")

## LOAD DEFAULT
chooseRenderMethod()

#------------------------------------------------------------------------------------

#linkData(chunkData, :vertices=>(DATA_PLANE_VERTEX,3), :indicies=>(DATA_PLANE_INDEX,1,GL_ELEMENT_ARRAY_BUFFER, true), :instances=>getData(mychunk))
linkData(planeData,  :vertices=>getVertices(fstm))
linkData(boxData,  :vertices=>getBox(fstm))

#chunkData.arrays[:vertices].count
#n = length(cubeVertices_small) / 3

#function compileShaderPrograms()
#  global program_chunks, program_normal

global program_normal = createShaderProgram(VSH, FSH) #, createShader(GSH, GL_GEOMETRY_SHADER)

setAttributes(planeData, program_normal)
setAttributes(boxData, program_normal)

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

"""
TODO
"""
while !GLFW.WindowShouldClose(window)
  showFrames()
  UpdateCounters()
  
  if OnUpdate(CAMERA)
    setMVP(program_chunks, CAMERA.MVP)
    setMVP(program_normal, CAMERA.MVP)
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
  
  glPolygonMode(GL_FRONT_AND_BACK, WIREFRAME ? GL_LINE : GL_FILL)
  
  """
  TODO
  """
  if isValid(mychunk)
    useProgram(program_chunks)
    #glCheckError("useProgram")
    #glPolygonMode(GL_FRONT_AND_BACK, WIREFRAME ? GL_LINE : GL_FILL)
    glBindVertexArray(chunkData.vao)
    #glCheckError("glBindVertexArray bind")
    
    if RENDER_METHOD == 1 glDrawArraysInstanced(GL_POINTS, 0, 1, mychunk.fileredCount) #GL_TRIANGLE_STRIP
    elseif RENDER_METHOD == 2 glDrawArraysInstanced(GL_TRIANGLES, 0, chunkData.draw.count, mychunk.fileredCount)
    elseif RENDER_METHOD == 3 glDrawElementsInstanced(GL_TRIANGLES, chunkData.draw.count, GL_UNSIGNED_INT, C_NULL, mychunk.fileredCount)
    #glDrawElementsInstancedBaseVertex(GL_TRIANGLES, chunkData.draw.count / 6, GL_UNSIGNED_INT, C_NULL, mychunk.count, 0)
    elseif RENDER_METHOD == 4
      #* thats slow! (glDrawElements ~60 fps, glDrawElementsInstanced ~ 200 fps !!!)
      for b in getFilteredChilds(mychunk)
        if location_texindex > -1 glUniform1f(location_texindex, b.typ) end
        if location_position > -1 glUniform3fv(location_position, 1, b.pos) end
        glDrawElements(GL_TRIANGLES, chunkData.draw.count, GL_UNSIGNED_INT, C_NULL )
        #glCheckError("glDrawElements")
      end
    elseif RENDER_METHOD == 5
      glDrawArrays(GL_TRIANGLES, 0, chunkData.draw.count)
    end
    glBindVertexArray(0)
    #glCheckError("glBindVertexArray unbind")
  end
  
  #################################

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

  #################################

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

"""
TODO
"""
function main()
  App.run()
end
