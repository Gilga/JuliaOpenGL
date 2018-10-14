using Distributed
#w=WorkerPool([2, 3])
procs=3

addprocs(procs) # total: procs + main proc
println("Processes: ",nprocs())

import Base.show

@everywhere mutable struct Worker
  alive::Bool
  orderID::Int
  tick::UInt
  tasks::Channel{Task} #tasks.sz_max
  Worker() = new(true,0,0,Channel{Task}(0))
end

@everywhere function worker_stop() WORKER.alive=false end
@everywhere function worker_alive() WORKER.alive end
@everywhere function worker_tick(t=0); if t>0 WORKER.tick=t; end; WORKER.tick; end
@everywhere worker_ids() = (myid(),WORKER.orderID)
@everywhere worker_task(f::Function) = push!(WORKER.tasks, Task(f))

@everywhere function Base.show(io::IO, this::Worker)
  print(io, "#", this.orderID, " ")
end

@everywhere WORKER = Worker()
#@everywhere JOBS = Channel{Task}(0)

@everywhere function write(i)
  t=rand()
  sleep(t) #Libc.systemsleep(t)
  println((i,myid(),t))
  (i,myid())
end

@everywhere NOTASK=()->nothing

@everywhere function worker(update::Function; start=NOTASK,close=NOTASK,tick=0)
  println(WORKER, "start")
  start()
  running=true
  while running == true running=update() end
  println(WORKER, "close")
  close()
  (worker_ids(),"end")
end

MESSAGES=RemoteChannel(()->Channel{String}(0))
#RemoteChannel(()->Channel(messages))

Printer = ()->begin
  println(take!(MESSAGES))
  sleep(1)
  true
end

Writer = ()->begin
  put!(MESSAGES,"test")
  println("writes")
  sleep(1)
  true
end


WORKERS = Future[]
wp=WorkerPool([2, 3])

print("START")
push!(WORKERS, remotecall(worker, wp, Printer)); print(".");
push!(WORKERS, remotecall(worker, wp, Writer)); print(".");
#for i=1:length(wp.workers) push!(WORKERS, remotecall(()->worker(i), wp)); print("."); end
println()
#=
#remotecall(worker_task(()->println("hi")), wp)
#sleep(3)

println("CLOSE") # start tasks on the workers to process requests in parallel
for w in wp.workers remotecall(worker_stop, wp) end
sleep(3)
=#
println("READ")
for w in WORKERS println(fetch(w)) end
println("END")

