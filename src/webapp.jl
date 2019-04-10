__precompile__(false)

module WebApp

using Blink

addListener(win::Window, event::String, callback::Function) = nothing #if active(win) Blink.@dot win on($event,$callback); end

closed = false
isclosed(win::Window) = closed
#Blink.@dot win on("closed", ()->)global closed = true)

const WEB_FILE = abspath(joinpath(@__DIR__,"../web/index.html")) #"C:/Users/Mario/AppData/Local/Julia-1.0.0/JuliaOpenGL/JuliaOpenGL/web/index.html"

webWindow = nothing

function init()
  if Blink.AtomShell.isinstalled() return end
  println("> INIT AtomShell...")
  Blink.AtomShell.install()
  println("\n----------\n")
end

function run()
  init()
  create()
end

function create()
  println("> Create Window...")
  global webWindow = Window()
  addListener(webWindow, "closed", ()->global closed = true)
  println("Read File")
  #f = open(WEB_FILE) do file read(file, String) end
  #println("Write into Window")
  #body!(webWindow,f)
  loadfile(webWindow, WEB_FILE)
  #println("Wait...")
  #while !isclosed(webWindow) yield() end
end

function reload()
  if active(webWindow)
    loadfile(webWindow, WEB_FILE)
  else
    close(webWindow)
    create()
  end
end

function cleanUp()
  #close(webWindow)
  #Blink.AtomShell.uninstall()
end

end #WebApp
