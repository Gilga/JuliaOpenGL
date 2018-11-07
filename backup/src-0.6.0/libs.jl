using Compat: uninitialized, Nothing, Cvoid, AbstractDict
using Images
using ImageMagick
using DataStructures
using Distances

displayInYellow(s) = string("\x1b[93m",s,"\x1b[0m")
displayInRed(s) = string("\x1b[91m",s,"\x1b[0m")

include("lib_window.jl")
include("lib_opengl.jl")
include("lib_math.jl")
include("lib_time.jl")

"""
TODO
"""
function waitForFileReady(path::String, func::Function, tryCount=100, tryWait=0.1)
	result=false
	for i = 1:tryCount

		#try reading file
		if stat(path).size > 0
			open(path) do file
				 result=func(file)
			end
			if result break end
		end

		Libc.systemsleep(tryWait) #wait
	end
	result
end

"""
TODO
"""
function fileGetContents(path::String, tryCount=100, tryWait=0.1)
	content=nothing
	waitForFileReady(path,(x)->(content=readstring(x); content != nothing),tryCount,tryWait)
	content
end

TITLE = "Julia OpenGL"
STARTTIME = Dates.time()
PREVTIME = STARTTIME
FRAMES = 0
MAX_FRAMES = 0
FPS = 0
MAX_FPS = 0
ITERATION = 0
BLOCK_COUNT = 0
SIZE = 0

"""
TODO
"""
function UpdateCounters()
  UpdateTimers()
  showFrames()
end    

prevTime = Ref(0.0)

"""
TODO
"""
function showFrames()
  global TITLE, TIMERS, FRAMES, MAX_FRAMES, FPS, MAX_FPS, ITERATION, BLOCK_COUNT, PREVTIME, RENDER_METHOD
  
  time = Dates.time() #GetTimer("FRAME_TIMER")
  
  ITERATION +=1
  if !OnTime(1.0, prevTime, time) FRAMES += 1; return end

  #FPS = FRAMES/(time - PREVTIME)
  #PREVTIME = time
  #if MAX_FPS < FPS MAX_FPS = FPS end
  #if FPS > 15 COUNT += 1 end
  #fpms = FPS > 0 ? (1000.0 / FPS) : 0
  #max_fmps = MAX_FPS > 0 ? (1000.0 / MAX_FPS) : 0
  #norm_fps = FPS/MAX_FPS
  
  if MAX_FRAMES < FRAMES MAX_FRAMES = FRAMES end
  const fps = FRAMES
  const max_fps = MAX_FRAMES
  const fpms = FRAMES > 0 ? (1000.0 / FRAMES) : 0
  const max_fmps = MAX_FRAMES > 0 ? (1000.0 / MAX_FRAMES) : 0
  const norm_fps = FRAMES / MAX_FRAMES
  
  GLFW.SetWindowTitle(window, "$(TITLE) - FPS $(round(fps, 2))[$(round(max_fps, 2))] | FMPS $(round(fpms, 2))[$(round(max_fmps, 2))] - Blocks $CHUNK_SIZE^3 ($BLOCK_COUNT) - IT $ITERATION")
  FRAMES = 0
end

include("cubeData.jl")
include("camera.jl")
include("frustum.jl")
include("chunk.jl")
include("mesh.jl")
include("texture.jl")