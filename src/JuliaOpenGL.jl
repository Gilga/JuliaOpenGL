__precompile__(false)

using Pkg

function install_packages()
    return
    # install packages
    println("Update OLD Packages...")
    Pkg.update()
    list=Pkg.installed()
    open(joinpath(@__DIR__, "../REQUIRE")) do file
        line = readline(file)
        if !haskey(list, line) Pkg.add(line); println("Package $line added."); end
    end
    println("Install Packages...")
    Pkg.update()
    println("Packages done.")
end

install_packages()

module JuliaOpenGL

const USE_PROCESSES = false
const USE_THREADS = false

using Distributed

if USE_PROCESSES addprocs(1) end

@everywhere println("=== Process started ===")
@everywhere push!(LOAD_PATH, @__DIR__)
if USE_PROCESSES
  #@everywhere include(joinpath(@__DIR__,"process.jl"))
  using Main.Process
end

using App

"""
TODO
"""
function main()
  if USE_PROCESSES
    Process.start(App.run)
  elseif USE_THREADS
    #start_threads()
    error("Does not work with OpenGL, because OpenGL has to be on main thread...")
  else
    App.run()
  end
end

export main

end #JuliaOpenGL
