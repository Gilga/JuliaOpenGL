WIDTH = 800
HEIGHT = 600
RATIO = WIDTH/(HEIGHT*1f0)
SIZE = WIDTH * HEIGHT
FOV = 60.0f0
CLIP_NEAR = 0.001f0
CLIP_FAR = 10000.0f0

function rezizeWindow(width,height)
  global WIDTH, HEIGHT, RATIO, SIZE
  WIDTH = width
  HEIGHT = height
  RATIO = WIDTH/(HEIGHT*1f0)
  SIZE = WIDTH * HEIGHT
  GLFW.SetWindowSize(window, WIDTH, HEIGHT)
  glViewport(0, 0, WIDTH, HEIGHT)
end

lastCursorPos = [0,0]
cursorPos_old = [0,0]
cursorPos = [0,0]
mouseMove = [0,0]

#MVP = eye(Mat4x4f)
#MVP *= transform([0.0f0,0.0f0,0.0f0],[0.0f0,0.0f0,0.0f0],Float32[])

keyFB = 0
keyLR = 0
keyUD = 0
speed = false

mouseKeyPressed = false
keyPressed = false
keyPressing = false
keyValue = 0

type Camera
  moved::Bool
  
  position::AbstractArray
  rotation::AbstractArray
  scale::AbstractArray
  
  viewMat::AbstractArray
  projectionMat::AbstractArray
  modelMat::AbstractArray

  translateMat::AbstractArray
  rotationMat::AbstractArray
  scalingMat::AbstractArray
  
  MVP::AbstractArray
  
  Camera() = new(true, zerosVector3f,zerosVector3f,onesVector3f,
  eyeMat4x4f,eyeMat4x4f,eyeMat4x4f,eyeMat4x4f,eyeMat4x4f,eyeMat4x4f,eyeMat4x4f)
end

CAMERA = Camera()

forward(camera::Camera) = forward(camera.rotationMat)
right(camera::Camera) = right(camera.rotationMat)
up(camera::Camera) = up(camera.rotationMat)

setProjection(camera::Camera, m::AbstractArray) = (camera.projectionMat = m)
setView(camera::Camera, m::AbstractArray) = (camera.viewMat = m)

VIEW_KEYS=false

function OnKey(window, key::Number, scancode::Number, action::Number, mods::Number)
  if key == 70 && action == 1 # f
    # ...
  elseif key == 71 && action == 1 # g
    #global wireframe
    #wireframe = !wireframe
    #println("Wireframe: ",wireframe)
    
  elseif key == 72 && action == 1 # h
    #global fullscreen=!fullscreen

  elseif key == 87 #w
    global keyFB = (action > 0)?1:0
  elseif key == 83 #s
    global keyFB = (action > 0)?-1:0
  elseif key == 65 #a
    global keyLR = (action > 0)?-1:0
  elseif key == 68 #d
    global keyLR = (action > 0)?1:0
  elseif key == 32 #space
    global keyUD = (action > 0)?1:0
  elseif key == 67 || key == 341 # c || lctrl
    global keyUD = (action > 0)?-1:0
  elseif key == 340 #lshift
    global speed = (action > 0)
  end
  
  if key == 75 && action == 1 #k
    global VIEW_KEYS = !VIEW_KEYS
    println("VIEW_KEYS = $VIEW_KEYS")
  end
  
  if VIEW_KEYS println("K: ", key, " A: ", action, " C: ", scancode, " M: ", mods) end

  if action == 1 global keyPressed = true end
  global keyPressing = action != 0
  global keyValue = key
  nothing
end

function OnMouseKey(window, key::Number, action::Number, mods::Number)
  global cursorPos_old, cursorPos
  global mouseKeyPressed = action != 0
  if action == 1
    cursorPos_old = cursorPos
    GLFW.SetInputMode(window, GLFW.CURSOR, GLFW.CURSOR_DISABLED)
  end
  if action == 0
    GLFW.SetInputMode(window, GLFW.CURSOR, GLFW.CURSOR_NORMAL)
  end
  nothing
end

function OnCursorPos(window, x::Number, y::Number)
  global CAMERA, lastCursorPos, cursorPos, mouseMove, mouseKeyPressed

  t = [x/800f0,y/600f0]
  cursorPos = t
  l = lastCursorPos; if l == [] l = t end
  n = l - t
  lastCursorPos = t
  mouseMove = n
  
  if mouseKeyPressed OnRotate(CAMERA) end
  nothing
end

function rotate(camera::Camera, rotation::AbstractArray)
  camera.rotation += rotation
  camera.moved=true
  #println("rotated")
end

function move(camera::Camera, position::AbstractArray)
  camera.position += position
  camera.moved=true
  #println("moved")
end

function OnRotate(camera::Camera)
  global cursorPos, cursorPos_old
  mx = cursorPos[1] - cursorPos_old[1]
  my = cursorPos[2] - cursorPos_old[2]
  #println(mx)
  cursorPos_old = cursorPos
  rotate(camera, [-mx*2f0,my*2f0,0f0]) #[-mx*2,my*2,0f0] #Vec3f((-mx+0.5f0),(-0.5f0+my),0f0)
end

oldposition = CAMERA.position
shiftposition = [0.0f0,0,0]

function setPosition(camera::Camera, position::AbstractArray)
  camera.position = position
  global oldposition = position
  camera.translateMat = translation(camera.position)
  camera.moved = true
end

function OnMove(camera::Camera, key::Symbol, m::Number)
  global shiftposition
  if key == :FORWARD  move(camera, forward(camera)*(m*0.05f0*(!speed?1f0:10f0)))
  elseif key == :RIGHT  move(camera, right(camera)*(-m*0.05f0*(!speed?1f0:10f0))) #+Vec3f(-right*0.02f0,-up*0.02f0,forward*0.02f0)
  elseif key == :UP  move(camera, up(camera)*(-m*0.05f0*(!speed?1f0:10f0)))
  end
  
  #dif = camera.position
  #step = trunc.(dif)
  #shiftposition = dif - step 
  #step = abs.(step)
  
  #if step[1] >= 2 camera.position[1] = 0 end
  #if step[2] >= 2 camera.position[2] = 0 end
  #if step[3] >= 2 camera.position[3] = 0 end
  
  #  dist = sqrt(camera.position[1]^2+camera.position[2]^2+camera.position[3]^2)
  # if dist >= 1 camera.position = [0f0,0,0] end
end

function Update(camera::Camera)
  if OnTime(0.01)
    if keyFB != 0 OnMove(camera, :FORWARD, keyFB) end
    if keyLR != 0 OnMove(camera, :RIGHT, keyLR) end
    if keyUD != 0 OnMove(camera, :UP, keyUD) end
  end

  if camera.moved
    camera.translateMat = translation(camera.position)
    camera.rotationMat = computeRotation(camera.rotation)
    camera.viewMat = camera.scalingMat * camera.rotationMat * camera.translateMat
    camera.MVP = camera.modelMat * camera.projectionMat * camera.viewMat
  end
end

function OnUpdate(camera::Camera)
  #if isFocus return end
  Update(camera)
  r = camera.moved
  camera.moved = false
  r
end
