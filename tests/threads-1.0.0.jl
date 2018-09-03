include("Includes-1.0.0.jl")

function thread_printer(this::Thread)
  println("thread_printer")
  i=0
  while true
    global Messages
    
    pushMsg(this.name, "PRINT $i")
    showMessages()
    
    sleep(1)
    i+=1
  end
end

function thread_compute(this::Thread)
  println("thread_compute")
  timeRef = Ref(0.0)
  i=0
  while true
    if OnTime(0.25, timeRef)
      global Messages
      #thread_println("thread_compute")
      pushMsg(this.name, "CALC $i")
      i+=1
    end
    sleep(0.001)
  end
end

function thread_renderer(this::Thread)
  println("thread_renderer")
  timeRef = Ref(0.0)
  i=0
  while true
    if OnTime(0.5, timeRef)
      pushMsg(this.name, "RENDER $i")
      i+=1
    end
    sleep(0.01)
  end
end

function thread_sound(this::Thread)
  println("thread_sound")
  timeRef = Ref(0.0)
  i=0
  while true
    if OnTime(0.75, timeRef)
      pushMsg(this.name, "SOUND $i")
      i+=1
    end
    sleep(0.1)
  end
end

function start_pool()
  pool = thread_pool()

  set(pool, thread_printer, "Printer")
  set(pool, thread_compute, "Compute")
  set(pool, thread_renderer, "Renderer")
  #set(pool, thread_sound, "Sound")
  
  #close(pool)
  
  start(pool) # anything below this line will be paused until threads are closed
end

function start_list()
  list=Function[]
  t = ThreadManager.Thread()
  
  push!(list, init(t, thread_printer, "Printer"))
  push!(list, init(t, thread_compute, "Compute"))
  push!(list, init(t, thread_renderer, "Renderer"))
  push!(list, init(t, thread_sound, "Sound"))
  
  start(t, list)
end

function main()
  #LoggerManager.log(()->begin
  println("Test Threads")
  
  start_pool()
  #start_list()

  #end)
end

main()