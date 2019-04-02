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
const WEBAPP_FILE = joinpath(@__DIR__,"webapp.jl")

load_debug(name,file,app_run,app_clean; clean=true) = print_backtrace(()->load(name,file,app_run,app_clean; clean=clean))

window_is_loaded=false

function load(name,file,app_run,app_clean; clean=true)
  println("=== Load ===")
  loaded = include_module(@__MODULE__, file)[1]
  
  if loaded
    println("=== Start ===")
    safe_invoke(@__MODULE__, app_run)
    #safe_call(@__MODULE__, app_run)
    if clean
      println("=== CleanUp ===")
      safe_invoke(@__MODULE__, app_clean)
    end
    #safe_call(@__MODULE__, app_clean)
  end
  
  if clean safe_clean!(@__MODULE__, name) end
end

function run()
  global window_is_loaded
  input = ""
  while input != "q" && input != "quit"
    list = getInput()
    input = list[1]
    value = length(list) > 1 ? string(list[2:end]...) : nothing
    if input == "q" || input == "quit" break #end program
    elseif input == "game" load_debug(:Game, GAME_FILE, :(Game.run), :(Game.cleanUp))
    elseif input == "webapp"
      if window_is_loaded
        safe_invoke(@__MODULE__, :(WebApp.reload))
      else
        load_debug(:WebApp, WEBAPP_FILE, :(WebApp.run), :(WebApp.cleanUp); clean=false)
        window_is_loaded = true
      end
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