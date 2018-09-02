include("TimeManager-1.0.0.jl")
include("LogManager-1.0.0.jl")
include("ThreadManager-1.0.0.jl")

using ..TimeManager
using ..LoggerManager
using ..ThreadManager

using Distributed

Messages = String[] #shared object among threads
clearMessages() = (global Messages = Array{String,1}())
getMessages() = Messages

showMessages() = thread_call(function()
  global Messages
  if length(Messages) > 0
    println("---[Messages]---")
    for msg in Messages println(msg) end
    println("----------------")
    clearMessages()
  end
end)

Mmutex = Threads.Mutex()
   
pushMsg(mode, name, msg) = begin global Messages; thread_push(Messages, LoggerManager.msg(mode , thread_id(), name, msg); mutex=Mmutex) end
pushMsg(name, msg)   = pushMsg("", name, msg)
pushInfo(name, msg)  = pushMsg(:Info, name, msg)
pushDebug(name, msg) = pushMsg(:Debug, name, msg)
pushError(name, msg) = pushMsg(:Error, name, msg)
pushWarn(name, msg)  = pushMsg(:Warning, name, msg)

function pushMe(name::String, msg::String)
  global Messages
  Threads.lock(ThreadManager.Mutex)
  push!(Messages, "sd")
  Threads.unlock(ThreadManager.Mutex)
end

function thread_printer(this::Thread)
  thread_println("thread_printer")
  i=0
  while true
    global Messages
    
    pushMsg(this.name, "PRINT $i")
    showMessages()
    
    thread_sleep(1)
    i+=1
  end
end

function thread_compute(this::Thread)
  thread_println("thread_compute")
  timeRef = Ref(0.0)
  i=0
  while true
    if OnTime(0.25, timeRef)
      global Messages
      #thread_println("thread_compute")
      pushMsg(this.name, "CALC $i")
      i+=1
    end
    thread_sleep(0.001)
  end
end

function thread_renderer(this::Thread)
  thread_println("thread_renderer")
  timeRef = Ref(0.0)
  i=0
  while true
    if OnTime(0.5, timeRef)
      pushMsg(this.name, "RENDER $i")
      i+=1
    end
    thread_sleep(0.01)
  end
end

function thread_sound(this::Thread)
  thread_println("thread_sound")
  timeRef = Ref(0.0)
  i=0
  while true
    if OnTime(0.75, timeRef)
      pushMsg(this.name, "SOUND $i")
      i+=1
    end
    thread_sleep(0.1)
  end
end

function start_pool()
  pool = ThreadManager.pool()

  ThreadManager.run(pool, thread_printer, "Printer")
  ThreadManager.run(pool, thread_compute, "Compute")
  ThreadManager.run(pool, thread_renderer, "Renderer")
  #ThreadManager.run(pool, thread_sound, "Sound")
  
  #ThreadManager.close(pool)
  
  ThreadManager.start(pool) # anything below this line will be paused until threads are closed
end

function start_list()
  list=Function[]
  t = ThreadManager.Thread()
  
  push!(list, ThreadManager.init(t, thread_printer, "Printer"))
  push!(list, ThreadManager.init(t, thread_compute, "Compute"))
  push!(list, ThreadManager.init(t, thread_renderer, "Renderer"))
  push!(list, ThreadManager.init(t, thread_sound, "Sound"))
  
  ThreadManager.run(t, list)
end

function main()
  #LoggerManager.log(()->begin
  println("Test Threads")
  
  start_pool()
  #start_list()

  #end)
end

main()