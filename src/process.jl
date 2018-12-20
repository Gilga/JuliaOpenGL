module Process

using Distributed

workers = Future[]
channels=Dict{Symbol,Distributed.AbstractRemoteRef}()

channels[:JOBS]=RemoteChannel(()->Channel{Function}(Inf))
#channels[:TRIGGER]=RemoteChannel(()->Channel{Bool}(1))
#channels[:CAMERA]=RemoteChannel(()->Channel{Tuple{Array{Float32,1},Array{Float32,1}}}(Inf))
#channels[:BOOL]=RemoteChannel(()->Channel{Tuple{Symbol,Bool}}(Inf))
#channels[:SCENE]=RemoteChannel(()->Channel{Int}(1))
#channels[:UPLOAD]=RemoteChannel(()->Channel{Symbol}(Inf))

updateChannels(chs::Dict{Symbol,Distributed.AbstractRemoteRef}) = global channels=chs
getChannels() = channels
register(id, channel) = channels[id]=channel

function createProcess(pool)
  global channels
  chs = channels
  push!(workers, remotecall(function()
    println("LOOP START")
    while true
      #fetch(remoteChannels)  #wait until first channel
      #chs = Dict([c for c in remoteChannels])
      println("updateChannels")
      updateChannels(chs)
      
      has = haskey(chs, :JOBS)
      if has
        println("GET JOB")
        job=take!(chs[:JOBS])
        println("START JOB")
        job() # execute job
        println("END JOB")
      end
      
      sleep(has ? 0 : 1)
    end
    true
  end, pool))
end

waitToEnd() = for w in workers println(fetch(w)) end

addJob(job) = put!(channels[:JOBS],job)

#remoteChannels=RemoteChannel(()->Channel{Tuple{Symbol,Distributed.AbstractRemoteRef}}(0))
#put!(remoteChannels,(:JOBS,RemoteChannel(()->Channel{Function}(0))))
#put!(remoteChannels,(:TRIGGERUPDATE,RemoteChannel(()->Channel{Bool}(0))))
#channels = Dict([c for c in remoteChannels])

function getInput()
  println("\x1b[91m>\x1b[0m\x1b[96m ")
  input = readline()
  println(input,"\x1b[0m")
end

function inputLoop()
  input = ""
  while input != "q" && input != "quit"
    input = getInput()
  end
end

function outputLoop()
  #Main.App.run()
  while true
    println(".")
    sleep(3)
  end
end

function start(mainProcess::Function)
  p=procs()
  popfirst!(p)
  if length(p) > 0
    pool=WorkerPool(p)
    createProcess(pool)
    addJob(inputLoop)
  end
  mainProcess()
  waitToEnd()
end

#=
function thread_compute(this::ThreadManager.Thread)
  println("thread_compute")
  #timeRef = Ref(0.0)
  #i=0
  while true
    #take!(TRIGGERUPDATE)
    #if TimeManager.OnTime(0.25, timeRef)
    #  info(this, i ;title="CALC")
    #  i+=1
    #end
    #sleep(0.001)
    println("thread_compute: work")
    sleep(3)
  end
end

function thread_renderer(this::ThreadManager.Thread)
  println("thread_renderer")
  run()
end
=#

#=
function test_thread()
  id=Threads.threadid()
  i=1
  while true
    #if id==1
    #  print(".")
    #  Libc.systemsleep(0.1)
    #elseif id==2
    #  println("Compute", id)
    #  for i=1:99999999 b=i^i; end;
    #  tprintln("Compute", id, "end.")
    #  Libc.systemsleep(0.1)
    #else
      #println("Idle", id)
      #Libc.systemsleep(10)  #rand(1:10) #sleep(rand(0.1:3))
      i += 1
    #end
  end
end

# Does not work with OpenGL, because OpenGL has to be on main thread...
function start_threads()
  return false
  
  println("Start Threads")

  max=Threads.nthreads()
  Threads.@threads for i = 1:max
    if i == 1
      run()
    elseif i == 2
      test_thread()
    end
  end

  #pool = ThreadManager.thread_pool()

  #ThreadManager.set(pool, thread_compute, "Compute")
  #ThreadManager.set(pool, thread_renderer, "Renderer")
  #ThreadManager.set(pool, thread_sound, "Sound")

  #ThreadManager.start(pool) # anything below this line will be paused until threads are closed
end

function fetchlast!(c::Distributed.AbstractRemoteRef)
  v=nothing; while isready(c) v=take!(c); end; v
end

function waitAndUpdateChunks()
  global CAMERA, FRUSTUM_CULLING, HIDE_UNSEEN_CUBES
  
  println("Presets")
  
  cameradata=channels[:CAMERA]
  bools=channels[:BOOL]

  init()
  
  trigger=false
  
  println("start update")
  while true

    if (data=fetchlast!(cameradata)) != nothing
      CAMERA.position, CAMERA.rotation = data
      Update(CAMERA)
      #println("updated Camera")
    end
    
    while isready(bools)
      v=take!(bools)
      id, value = v
      if id == :FRUSTUM_CULLING FRUSTUM_CULLING = value;
      elseif id == :HIDE_UNSEEN_CUBES HIDE_UNSEEN_CUBES = value;
      end
      trigger = true
    end
    
    if trigger
      trigger = false
      setFrustumMode()
    end
      
    sleep(0.1)
  end
  nothing
end

updateChunk(this::Chunk) =   #println("send Chunk data")
   if myid() != 1 remotecall(setChunkInstances, 1, chunk_instances) end
   
 createChunk(this::Chunk)= 
   
  if myid() != 1
    sz=channels[:SCENE]
    if isready(sz) SCENE=take!(sz) end
  end
  

function uploadChunk(s)
  global uploaded = s
  if myid() == 1 return end
  #println("upload Chunk")
  #@save "chunk.jld2" chunk_instances
  put!(channels[:UPLOAD],s)
end


function loadChunk()
  if length(procs()) <= 1 return uploaded end

  upload=channels[:UPLOAD]
  if !isready(upload) return :NOTHING end
  #println("load Chunk")
  m = take!(upload)
  #@load "chunk.jld2" chunk_instances
  m
end

uploadData()
  m=loadChunk()
  if m == :NOTHING return end
  
  #channels["KEYS"]
  #put!(channels[:BOOL], (:NOTHING, false))
  put!(channels[:BOOL], (:FRUSTUM_CULLING, FRUSTUM_CULLING))
  put!(channels[:BOOL], (:HIDE_UNSEEN_CUBES, HIDE_UNSEEN_CUBES))
  
checkCamera() = 
      if length(procs()) > 1 put!(channels[:BOOL], (:NOTHING, false))
      else setFrustumMode()
      end
      
chooseRenderMethod(method=RENDER_METHOD) =   if myid() != 1 put!(channels[:SCENE],SCENE) end 
=#

end #Process