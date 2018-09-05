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

######################################################

info(args...) = thread_call(() -> LoggerManager.info(args...);mutex=PrintMutex)
debug(args...) = thread_call(() -> LoggerManager.debug(args...);mutex=PrintMutex)
warn(args...) = thread_call(() -> LoggerManager.warn(args...);mutex=PrintMutex)
error(args...) = thread_call(() -> LoggerManager.error(args...);mutex=PrintMutex)

######################################################

Messages = String[] #shared object among threads
function message(this::Thread, args... ;mode="", title="", lineBreak=true) 
  global Messages
  push!(Messages, LoggerManager.msg(args... ;time=true, name=thread_id()*":"*this.name, mode=mode, title=title, lineBreak=lineBreak))
end

function showMessages()
  global Messages
  msgs = String[]
  
  # copy & clear messages
  thread_call(() -> begin msgs = deepcopy(Messages); Messages = Array{String,1}() end ;mutex=PushMutex)

  thread_call(function()
    if length(msgs) > 0
      LoggerManager.println("---[Messages]---")
      for msg in msgs LoggerManager.print(msg) end
      LoggerManager.println("----------------")
    end
  end ;mutex=PrintMutex)
end

######################################################

print(this::Thread, args... ;title="") = message(this, args... ;title=title, lineBreak=false)
println(this::Thread, args... ;title="") = message(this, args... ;title=title)

info(this::Thread, args... ;title="") = message(this, args... ;mode=:Info, title=title)
debug(this::Thread, args... ;title="") = message(this, args... ;mode=:Debug, title=title)
warn(this::Thread, args... ;title="") = message(this, args... ;mode=:Warning, title=title)
error(this::Thread, args... ;title="") = message(this, args... ;mode=:Error, title=title)