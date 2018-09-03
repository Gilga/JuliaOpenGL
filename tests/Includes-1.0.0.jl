include("TimeManager-1.0.0.jl")
include("LogManager-1.0.0.jl")
include("ThreadManager-1.0.0.jl")

using ..TimeManager
using ..LoggerManager
using ..ThreadManager

using Distributed

######################################################
# Overwrite Base functions

PrintMutex = Threads.Mutex()
#ThreadManager.setPrintMutex(PrintMutex)

print(args...) = thread_call(() -> LoggerManager.print(args...);mutex=PrintMutex)
println(args...) = thread_call(() -> LoggerManager.println(args...);mutex=PrintMutex)

PushMutex = Threads.Mutex()
push!(args...) = thread_call(() -> Base.push!(args...);mutex=PushMutex)

sleep(sec) = thread_sleep(sec)
error(args...) = thread_call(() -> LoggerManager.error(args...);mutex=PrintMutex)

######################################################

info(args...) = thread_call(() -> LoggerManager.info(args...);mutex=PrintMutex)
warn(args...) = thread_call(() -> LoggerManager.warn(args...);mutex=PrintMutex)

######################################################

Messages = String[] #shared object among threads
clearMessages() = (global Messages = Array{String,1}())
getMessages() = Messages

pushMsg(mode, name, msg) = begin global Messages; push!(Messages, LoggerManager.msg(mode , thread_id(), name, msg)) end
pushMsg(name, msg)   = pushMsg("", name, msg)
pushInfo(name, msg)  = pushMsg(:Info, name, msg)
pushDebug(name, msg) = pushMsg(:Debug, name, msg)
pushError(name, msg) = pushMsg(:Error, name, msg)
pushWarn(name, msg)  = pushMsg(:Warning, name, msg)

showMessages() = thread_call(function()
  global Messages
  if length(Messages) > 0
    LoggerManager.println("---[Messages]---")
    for msg in Messages LoggerManager.print(msg) end
    LoggerManager.println("----------------")
    clearMessages()
  end
end)

######################################################