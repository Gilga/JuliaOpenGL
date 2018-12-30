module CameraManager

using ..Math
using ..TimeManager

using Distributed
using GLFW
using ModernGL

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

getKey() = keyValue, keyPressed

export getKey

resetKeys() = global keyPressed = false

export resetKeys

"""
camera object with holds position, rotation, scaling and various matrices like MVP
"""
mutable struct Camera
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

export Camera

CAMERA = Camera()

"""
gets forward vector of camera direction
"""
forward(camera::Camera) = Math.forward(camera.rotationMat)

export forward

"""
gets right vector of camera direction
"""
right(camera::Camera) = Math.right(camera.rotationMat)

export right

"""
gets up vector of camera direction
"""
up(camera::Camera) = Math.up(camera.rotationMat)

export up

"""
sets projection matrix
"""
setProjection(camera::Camera, m::AbstractArray) = (camera.projectionMat = m)

export setProjection

"""
sets view matrix
"""
setView(camera::Camera, m::AbstractArray) = (camera.viewMat = m)

export setView

VIEW_KEYS=false

"""
event which catches keyboard inputs.
here keys for wireframe, fullscreen and camera movement are defined 
"""
function OnKey(window, key, scancode, action, mods)
  key = Int32(key)
  action = Int32(action)
  scancode = Int32(action)
  mods = Int32(action)
  
  if key == 70 && action == 1 # f
    # ...
  elseif key == 71 && action == 1 # g
    #global wireframe
    #wireframe = !wireframe
    #println("Wireframe: ",wireframe)
    
  elseif key == 72 && action == 1 # h
    #global fullscreen=!fullscreen

  elseif key == 87 #w
    global keyFB = (action > 0) ? 1 : 0
  elseif key == 83 #s
    global keyFB = (action > 0) ? -1 : 0
  elseif key == 65 #a
    global keyLR = (action > 0) ? -1 : 0
  elseif key == 68 #d
    global keyLR = (action > 0) ? 1 : 0
  elseif key == 32 #space
    global keyUD = (action > 0) ? 1 : 0
  elseif key == 67 || key == 341 # c || lctrl
    global keyUD = (action > 0) ? -1 : 0
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

export OnKey

"""
event which catches mouse key inpits and hides/shows cursor when mouse button is pressed
"""
function OnMouseKey(window, key, action, mods)
  key = Int32(key)
  action = Int32(action)
  mods = Int32(mods)
  
  if keyPressing return end
   
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

export OnMouseKey

"""
event which catches mouse position for camera rotation event
"""
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

export OnCursorPos

"""
rotates camera
"""
function rotate(camera::Camera, rotation::AbstractArray)
  camera.rotation += rotation
  camera.moved=true
  if length(procs()) > 1 put!(channels[:CAMERA],(camera.position,camera.rotation)) end
  #println("rotated")
end

export rotate

"""
moves camera, adds vector to current position
"""
function move(camera::Camera, position::AbstractArray)
  camera.position += position
  camera.moved=true
  if length(procs()) > 1 put!(channels[:CAMERA],(camera.position,camera.rotation)) end
  #println("moved")
end

export move

"""
event which calculates cursor position shifts and calls rotate function
"""
function OnRotate(camera::Camera)
  global cursorPos, cursorPos_old
  mx = cursorPos[1] - cursorPos_old[1]
  my = cursorPos[2] - cursorPos_old[2]
  #println(mx)
  cursorPos_old = cursorPos
  rotate(camera, [-mx*2f0,my*2f0,0f0]) #[-mx*2,my*2,0f0] #Vec3f((-mx+0.5f0),(-0.5f0+my),0f0)
end

export OnRotate

oldposition = CAMERA.position
shiftposition = [0.0f0,0,0]

"""
sets camera position
"""
function setPosition(camera::Camera, position::AbstractArray)
  camera.position = position
  global oldposition = position
  camera.translateMat = translation(camera.position)
  camera.moved = true
  if length(procs()) > 1 put!(channels[:CAMERA],(camera.position,camera.rotation)) end
end

export setPosition

"""
event which updates positions shifts (left,right,up,down,forward,back)
key is (left,right,up,down,forward,back)
m is direction value with weight (positive, negative)
"""
function OnMove(camera::Camera, key::Symbol, m::Number)
  global shiftposition
  f=m*GetTimePassed()*10*(!speed ? 1 : 10)
  
  if key == :FORWARD  move(camera, forward(camera)*f)
  elseif key == :RIGHT  move(camera, right(camera)*-f) #+Vec3f(-right*0.02f0,-up*0.02f0,forward*0.02f0)
  elseif key == :UP  move(camera, up(camera)*-f)
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

export OnMove

"""
update function where camera translation is update only when camera was moved by input. 
here cameras MVP Matrix is updated aswell
"""
function Update(camera::Camera)
  camera.translateMat = translation(camera.position)
  camera.rotationMat = computeRotation(camera.rotation)
  camera.viewMat = camera.scalingMat * camera.rotationMat * camera.translateMat
  camera.MVP = camera.modelMat * camera.projectionMat * camera.viewMat
end

export Update

"""
event which is called by game loop and calls real update function
this event resets camera moved state
"""
function OnUpdate(camera::Camera)
  #if isFocus return end
  
  if OnTime(0.01)
    if keyFB != 0 OnMove(camera, :FORWARD, keyFB) end
    if keyLR != 0 OnMove(camera, :RIGHT, keyLR) end
    if keyUD != 0 OnMove(camera, :UP, keyUD) end
  end
  
  if camera.moved
    Update(camera)
  end
  
  r = camera.moved
  camera.moved = false
  r
end

export OnUpdate

end #CameraManager
