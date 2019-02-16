"""
TODO
"""
module App

using InteractiveUtils
using Distributed

############################

include("CodeManager.jl")
using .CodeManager

#names(CodeManager) #shows external links

###########################

#Base.PROGRAM_FILE 

module Game end #init

function getInput()
  print("\x1b[91m>\x1b[0m\x1b[96m ")
  input = readline()
  print("\x1b[0m")
  split(input)
end

const GAME_FILE = joinpath(@__DIR__,"game.jl") #../backup/backup_

function game()
  println("=== Load ===")
  loaded = false
  loaded = include_module(@__MODULE__, GAME_FILE)[1]
  
  if loaded
    println("=== Start ===")
    safe_invoke(@__MODULE__, :(Game.run))
    #safe_call(@__MODULE__, :(Game.run))
    println("=== CleanUp ===")
    safe_invoke(@__MODULE__, :(Game.cleanUp))
    #safe_call(@__MODULE__, :(Game.cleanUp))
  end
  
  safe_clean!(@__MODULE__, :Game)
end

function run()
  input = ""
  while input != "q" && input != "quit"
    list = getInput()
    input = list[1]
    value = length(list) > 1 ? string(list[2:end]...) : nothing
    if input == "q" || input == "quit" break #end program
    elseif input == "game" print_backtrace(game)
    elseif input == "clean" println("<Free Memory>"); free_memory();
    elseif input == "info" println(varinfo(Game)) #isdefined(@__MODULE__, :Game) ? println(varinfo(Game)) : println("No info for 'Game'")
    elseif input == "binds" println(names(Game,all=true))
    elseif input == "edit" file=joinpath(@__DIR__,value*".jl"); isfile(file) ? print_backtrace(()->edit(file)) : println("Error: File '"*value*"' does not exist")
    elseif input == "eval" result = safe_eval(@__MODULE__, value); if result[1]; println(result[2]); end;
    elseif input == "restart" print_backtrace(()->begin this=joinpath(@__DIR__,"../test.bat"); Base.run(`$this`); exit(); end);
    elseif input == "exit" exit()
    else println("Unknown Command")
    end
  end
end #run()

end #App