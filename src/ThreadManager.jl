__precompile__(false)

module ThreadManager

using ..LoggerManager

export Thread
export ThreadPool
export ThreadID
export thread_call
export thread_id
export thread_println
export thread_sleep
export thread_pool

export close
export run
export log
export init
export start
export set
export id

##############################################################################

DebugPrint = false

ThreadMutex = Threads.Mutex()
PrintMutex = Threads.Mutex()

ThreadID() = Threads.threadid()
THREAD_POOL = nothing

setPrintMutex(mutex::Threads.Mutex) = begin PrintMutex = mutex end
setDebugPrint(on::Bool) = begin DebugPrint = on end

##############################################################################

function thread_call(f::Function, args...;mutex::Threads.Mutex=ThreadMutex)
	Threads.lock(mutex)
	result = f(args...)
	Threads.unlock(mutex)
  result
end

thread_id() = string("T",ThreadID())
thread_println(args...) = if DebugPrint thread_call(() -> LoggerManager.println(args...);mutex=PrintMutex) end
thread_sleep(sec) = Libc.systemsleep(sec)

##############################################################################

abstract type IThreadPool end

mutable struct Thread
  pool::Union{Nothing,IThreadPool}
  id::Int32
  alive::Bool
  idleTime::Float64
  name::String
  run::Union{Nothing,Function}

  Thread(pool=nothing) = new(pool,0,true,1,"",nothing)
end

mutable struct ThreadPool <: IThreadPool
  alive::Bool
  list::Array{Thread,1}

  ThreadPool() = new(true,Thread[])
end

##############################################################################

function thread_pool(numberOfThreads=0; idleTime=1)
    global THREAD_POOL

    JULIA_NUM_THREADS = parse(Int32,ENV["JULIA_NUM_THREADS"])
    UV_THREADPOOL_SIZE = parse(Int32,ENV["UV_THREADPOOL_SIZE"])

    if THREAD_POOL != nothing return end
    if numberOfThreads <= 0 || numberOfThreads > UV_THREADPOOL_SIZE numberOfThreads=UV_THREADPOOL_SIZE end
    if numberOfThreads > JULIA_NUM_THREADS numberOfThreads=JULIA_NUM_THREADS end

    thread_println("Start Thread Pool with $numberOfThreads...")

    pool=ThreadPool()
    THREAD_POOL = pool

    for i=1:numberOfThreads
      t = Thread(pool)
      t.idleTime = idleTime
      push!(pool.list, t)
    end

    thread_println("Thread Pool created.")

    #start(pool) # anything below this line will be paused until threads are closed

    pool
end

##############################################################################

count(this::ThreadPool) = length(this.list)

function start(this::ThreadPool)
  println("Start ThreadPool...")

	global Mutex = Threads.Mutex()
	max=Threads.nthreads()
	i=0; Threads.@threads for t in this.list
    #if t.run == nothing continue end
    t.id = ThreadID()
    start(t)
		if i >= max break end
    i+=1
  end
end

function start(this::Thread, list::Array{Function,1})
	global Mutex = Threads.Mutex()
	max=Threads.nthreads()
	i=0; Threads.@threads for f in list
    f(this)
		if i >= max break end
    i+=1
  end
end

function set(this::ThreadPool, f::Function, name::String="")
  id=ThreadID()

  for t in this.list
    if (id == 0 || (id >0 && id != t.id)) && t.run == nothing
      t.run = init(t, f, name)
      return t
    end
  end

  thread_println("No free threads found.")
  nothing
end


##############################################################################

id(this::Thread) = string("T",this.id)

dummy() = string(0x0)

function start(this::Thread)
  thread_println("Start "*id(this))
  while this.pool.alive && this.alive
    if this.run != nothing
      result = this.run(this)
      if result != true this.run = nothing end
    end
    thread_sleep(this.idleTime)
  end
  thread_println("Close "*id(this))
end

function close(this::Thread)
  thread_println("Closing "*id(this)*"...")
  this.alive = false
end

function close(this::ThreadPool)
  thread_println("Closing ThreadPool...")
  this.alive = false
end

set(this::Thread, f::Function, name::String="") = begin this.run = init(this, f, name) end

log(this::Thread, f::Function, args...) = begin; try; f(this, args...); catch err; thread_call(LoggerManager.logException,err,id(this)); end; end

function init(this::Thread, f::Function, name::String="")
  this.name = name
  (this::Thread) -> begin
    thread_println(LoggerManager.msg(:Debug, ThreadManager.id(this), name, "start"))
    log(this, f)
  end
end

end # ThreadManager
