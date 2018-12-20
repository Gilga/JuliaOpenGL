using InteractiveUtils #versioninfo
using DataStructures #SortedDict
using Images
using ImageMagick
using JLD2
using Distributed
using Dates
using SharedArrays
using StaticArrays
using ModernGL

#https://github.com/shiena/ansicolor/blob/master/README.md

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

#include("Includes.jl")
#using ..ThreadManager
include("TimeManager.jl")
using .TimeManager
include("lib_file.jl")
using .FileManager
include("lib_log.jl")
using .LogManager
include("lib_window.jl")
#using .WindowManager
include("lib_opengl.jl")
using .GraphicsManager
include("lib_math.jl")
using .Math
#include("TimeManager.jl")

## COMPILE C File
const compileAndLink = isdefined(@__MODULE__,:USE_COMPILE) 
if compileAndLink
  include("compileAndLink.jl")
  compileWithGCC()
end
