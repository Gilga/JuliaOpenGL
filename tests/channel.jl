const jobs = Channel{Int}(32)
const results = Channel{Tuple}(32)

function do_work()
   for job_id in jobs
       #prev_time=Dates.Time()
       exec_time = rand()*job_id
       sleep(exec_time)# simulates elapsed time doing actual work typically performed externally.
       #Libc.systemsleep(exec_time)
       put!(results, (job_id, exec_time, "hi"))
       #time=Dates.Time()-prev_time
       println("$job_id with $(round(exec_time;digits=2)) seconds")
   end
end

function make_jobs(n)
   for i in 1:n
       put!(jobs, i)
   end
end

n = 12
schedule(@task make_jobs(n))

for i in 1:4 # start 4 tasks to process requests in parallel
    schedule(@task do_work())
end
       
@elapsed while n > 0 # print out results
  global n
   job_id, exec_time, msg = take!(results)
   println("$job_id with \"$msg\" finished in $(round(exec_time;digits=2)) seconds")
   n = n - 1
end

