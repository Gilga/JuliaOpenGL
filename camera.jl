WIDTH = 800
HEIGHT = 600
RATIO = WIDTH/(HEIGHT*1f0)
SIZE = WIDTH * HEIGHT

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

function OnKey(window, key::Number, scancode::Number, action::Number, mods::Number)
  if key == 290 && action == 1 # F1 = 290
    global fullscreen=!fullscreen
    #WindowManager.fullscreen(WINDOW,fullscreen)

  elseif key == 291 && action == 1 # F2
    global wireframe
    wireframe = !wireframe
    println("Wireframe: ",wireframe)

  elseif key == 293 && action == 1 # F4 = 293
    #this.callList[:reload]()
    #this.callList[:shaderRefresh]()
    #whos()
    println(current_module())

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
  
  #println(key)

  global keyPressed = action != 0
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


function OnRotate(camera::Camera)
  global cursorPos, cursorPos_old
  mx = cursorPos[1] - cursorPos_old[1]
  my = cursorPos[2] - cursorPos_old[2]
  #println(mx)
  cursorPos_old = cursorPos
  camera.rotation+=[-mx*2f0,my*2f0,0f0] #[-mx*2,my*2,0f0] #Vec3f((-mx+0.5f0),(-0.5f0+my),0f0)
  camera.rotationMat = computeRotation(camera.rotation)
  camera.moved=true
end

function OnMove(camera::Camera, key::Symbol, m::Number)
  if key == :FORWARD  camera.position += forward(camera)*(m*0.05f0*(!speed?1f0:100f0)); camera.moved=true
  elseif key == :RIGHT  camera.position -= right(camera)*(m*0.05f0*(!speed?1f0:100f0)); camera.moved=true #+Vec3f(-right*0.02f0,-up*0.02f0,forward*0.02f0)
  elseif key == :UP  camera.position -= up(camera)*(m*0.05f0*(!speed?1f0:100f0)); camera.moved=true
  end
  camera.translateMat = translation(camera.position)
end

function Update(camera::Camera)
  camera.viewMat = camera.scalingMat * camera.rotationMat * camera.translateMat
  camera.MVP = camera.modelMat * camera.projectionMat * camera.viewMat
end

function OnUpdate(camera::Camera)

  #if isFocus return end
  if OnTime(0.01)
    if keyFB != 0 OnMove(camera, :FORWARD, keyFB) end
    if keyLR != 0 OnMove(camera, :RIGHT, keyLR) end
    if keyUD != 0 OnMove(camera, :UP, keyUD) end
  end
  
  r = camera.moved
  if r
    camera.moved = false
    Update(camera)
  end
  
  r
end
