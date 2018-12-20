"""
TODO
"""
module App

function getInput()
  print("\x1b[91m>\x1b[0m\x1b[96m ")
  input = readline()
  print("\x1b[0m")
  input
end

function printError(ex)
  print("\x1b[91m")
  Base.showerror(stderr, ex, catch_backtrace())
  println("\x1b[0m")
end

function catchError(func::Function)
  try
    eval(:($func())) #@__MODULE__
  catch(ex)
    printError(ex)
  end
end

function game()
  loaded = false
  
  try
    println("=== Load ===")
    include(joinpath(@__DIR__,"game.jl"))
    loaded = true
  catch(ex)
    printError(ex)
  end
  
  if loaded
    if isdefined(Game,:run) println("=== Start ==="); catchError(Game.run) end
    if isdefined(Game,:cleanUp) println("=== CleanUp ==="); catchError(Game.cleanUp) end
  end
  
   # cleanUp: force garbage collection, free memory
  GC.gc()
end

function run()
  input = ""
  while input != "q" && input != "quit"
    input = getInput()
    if input == "q" || input == "quit" break #end program
    elseif input == "game" game()
    else println("Unknown Command")
    end
  end
end #run()

end #App