include("Includes-1.0.0.jl")

function thread_printer(this::Thread)
  println("thread_printer")
  i=0
  while true
    global Messages
    
    println(this, i ;title="PRINT")
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
      info(this, i ;title="CALC")
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
      debug(this, i ;title="RENDER")
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
      warn(this, i ;title="SOUND")
      i+=1
    end
    sleep(0.1)
  end
end

function thread_else(this::Thread)
  println("thread_else")
  timeRef = Ref(0.0)
  i=0
  while true
    if OnTime(2.0, timeRef)
      error(this, i ;title="ELSE")
      i+=1
    end
    sleep(0.5)
  end
end

function start_pool()
  pool = thread_pool()

  set(pool, thread_printer, "Printer")
  set(pool, thread_compute, "Compute")
  set(pool, thread_renderer, "Renderer")
  set(pool, thread_sound, "Sound")
  #set(pool, thread_else, "Else")
  
  #close(pool)
  
  start(pool) # anything below this line will be paused until threads are closed
end

function start_list()
  list=Function[]
  t = ThreadManager.Thread()
  
  Base.println(Threads.nthreads())
  
  Base.push!(list, init(t, thread_printer, "Printer"))
  Base.push!(list, init(t, thread_compute, "Compute"))
  Base.push!(list, init(t, thread_renderer, "Renderer"))
  Base.push!(list, init(t, thread_sound, "Sound"))
  #Base.push!(list, init(t, thread_else, "Else"))
  
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