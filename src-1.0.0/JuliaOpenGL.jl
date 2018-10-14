const USE_PROCESSES = true

using Distributed

if USE_PROCESSES addprocs(1) end
  
@everywhere push!(LOAD_PATH, @__DIR__)
@everywhere include(joinpath(@__DIR__,"App.jl"))
@everywhere using Main.App

"""
TODO
"""
function main()
  Main.App.start(USE_PROCESSES)
end
