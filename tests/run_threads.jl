println("START THREADS")
ENV["JULIA_NUM_THREADS"] = "4"
julia = joinpath(JULIA_HOME, "julia")
start = abspath(dirname(@__FILE__),"threads.jl")
run(`$julia $start`)