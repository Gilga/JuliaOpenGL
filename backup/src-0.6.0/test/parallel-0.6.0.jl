@everywhere function write(i)
  Libc.systemsleep(5)
  (myid(),i)
end

sss = Future[]
println("Write")

for i=1:nprocs() println("$i"); push!(sss, @spawn write(i)) end
println("Read - Wait ~ 5 sec")
for s in sss println(fetch(s)) end

#s = @spawnat 1 myid()
#println(fetch(s))