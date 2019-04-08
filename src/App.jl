"""
TODO
"""
module App

using InteractiveUtils
using Distributed
############################
using CodeManager

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
  cmds = Dict([:HELP=>"help"=>"This info",:QUIT=>"quit"=>"Quit program",
  :GAME=>"game"=>"",:APP=>"app"=>"",:CLEAN=>"clean"=>"",:INFO=>"info"=>"",
  :BINDS=>"binds"=>"",:EDIT=>"edit"=>"",:CMD=>"eval"=>"",:RESTART=>"restart"=>"",:EXIT=>"exit"=>""])

  getCMD(cmd::Symbol) = cmds[cmd][1]

  while true
    list = getInput()
    input = list[1]
    value = length(list) > 1 ? string(list[2:end]...) : nothing
    if input == "?" || input == getCMD(:HELP)
        println("[ Command List ]")
        [println("- $cmd") for (_,cmd) in cmds]
    elseif input == "q" || input == getCMD(:QUIT) break
    elseif input == getCMD(:GAME) load_debug(:Game, GAME_FILE, :(Game.run), :(Game.cleanUp))
    elseif input == getCMD(:APP)
      if window_is_loaded
        safe_invoke(@__MODULE__, :(WebApp.reload))
      else
        load_debug(:WebApp, WEBAPP_FILE, :(WebApp.run), :(WebApp.cleanUp); clean=false)
        window_is_loaded = true
      end
    elseif input == getCMD(:CLEAN)
        println("<Free Memory>")
        free_memory()
    elseif input == getCMD(:INFO)
        println(varinfo(Game)) #isdefined(@__MODULE__, :Game) ? println(varinfo(Game)) : println("No info for 'Game'")
    elseif input == getCMD(:BINDS)
        println(names(Game,all=true))
    elseif input == getCMD(:EDIT)
        file=joinpath(@__DIR__,value*".jl")
        isfile(file) ? print_backtrace(()->edit(file)) : println("Error: File '"*value*"' does not exist")
    elseif input == getCMD(:CMD)
        result = safe_eval(@__MODULE__, value)
        if result[1]; println(result[2]); end;
    elseif input == getCMD(:RESTART)
        print_backtrace(()->begin this=joinpath(@__DIR__,"../test.bat")
        Base.run(`$this`); exit(); end);
    elseif input == getCMD(:EXIT)
        exit()
    else
        println("Unknown Command")
    end
  end
  println("Close App.")
end #run()

end #App
