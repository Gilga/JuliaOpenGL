__precompile__(false)

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
#using ThreadManager

## COMPILE C File
const compileAndLink = isdefined(@__MODULE__,:USE_COMPILE)
if compileAndLink
  include(joinpath(@__DIR__,"compileAndLink.jl"))
  compileWithGCC()
end
