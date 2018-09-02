println("START THREADS")
ENV["JULIA_NUM_THREADS"] = "4"
ENV["UV_THREADPOOL_SIZE"] = "4"
julia = joinpath(Sys.BINDIR, "julia")
start = abspath(dirname(@__FILE__),"threads-1.0.0.jl")
run(`$julia $start`)