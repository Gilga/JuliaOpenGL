ENV["JULIA_NUM_THREADS"] = "4"
ENV["UV_THREADPOOL_SIZE"] = "4"
julia = joinpath(Sys.BINDIR, "julia")
start = abspath(dirname(@__FILE__),"test.jl")
run(`$julia $start`)