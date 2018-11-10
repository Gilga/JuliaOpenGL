using InteractiveUtils #versioninfo
using DataStructures #SortedDict
using Images
using ImageMagick
using JLD2
using Distributed
using Dates
using SharedArrays

#https://github.com/shiena/ansicolor/blob/master/README.md

include("lib_log.jl")
using .LogManager
include("lib_window.jl")
#using .WindowManager
include("lib_opengl.jl")
using .GraphicsManager
include("lib_math.jl")
using .Math
#include("TimeManager.jl")

using ModernGL
using StaticArrays

"""
TODO
"""
function waitForFileReady(path::String, func::Function, tryCount=100, tryWait=0.1) #error when functions does not exists
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

export waitForFileReady

"""
TODO
"""
function fileGetContents(path::String, tryCount=100, tryWait=0.1)
	content=nothing
	waitForFileReady(path,(x)->(content=read(x, String); content != nothing),tryCount,tryWait)
	content
end

export fileGetContents

TITLE = "Julia OpenGL"
STARTTIME = time()
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
  
  currenttime = time() #GetTimer("FRAME_TIMER")
  
  ITERATION +=1
  if !OnTime(1.0, prevTime; time=currenttime) FRAMES += 1; return end

  #FPS = FRAMES/(currenttime - PREVTIME)
  #PREVTIME = currenttime
  #if MAX_FPS < FPS MAX_FPS = FPS end
  #if FPS > 15 COUNT += 1 end
  #fpms = FPS > 0 ? (1000.0 / FPS) : 0
  #max_fmps = MAX_FPS > 0 ? (1000.0 / MAX_FPS) : 0
  #norm_fps = FPS/MAX_FPS
  
  if MAX_FRAMES < FRAMES MAX_FRAMES = FRAMES end
  fps = FRAMES
  max_fps = MAX_FRAMES
  fpms = FRAMES > 0 ? (1000.0 / FRAMES) : 0
  max_fmps = MAX_FRAMES > 0 ? (1000.0 / MAX_FRAMES) : 0
  norm_fps = FRAMES / MAX_FRAMES
  
  GLFW.SetWindowTitle(window, "$(TITLE) - FPS $(round(fps; digits=2))[$(round(max_fps; digits=2))] | FMPS $(round(fpms; digits=2))[$(round(max_fmps; digits=2))] - Blocks $CHUNK_SIZE^3 ($BLOCK_COUNT) - IT $ITERATION")
  FRAMES = 0
end

export showFrames

WIDTH = 800
HEIGHT = 600
RATIO = WIDTH/(HEIGHT*1f0)
SIZE = WIDTH * HEIGHT
FOV = 60.0f0
CLIP_NEAR = 0.001f0
CLIP_FAR = 10000.0f0

"""
sets glfw window size + viewport
"""
function rezizeWindow(window, width, height)
  global WIDTH, HEIGHT, RATIO, SIZE
  WIDTH = width
  HEIGHT = height
  RATIO = WIDTH/(HEIGHT*1f0)
  SIZE = WIDTH * HEIGHT
  GLFW.SetWindowSize(window, WIDTH, HEIGHT)
  glViewport(0, 0, WIDTH, HEIGHT)
end

export rezizeWindow
