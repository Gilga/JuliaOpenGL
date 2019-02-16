module WindowManager

export Window

using GLFW

const WINDOW_REF = GLFW.Window

mutable struct Window
  ref::WINDOW_REF
  focus::Bool
  size::Tuple{UInt32,UInt32}
  title::String
  
  function Window()
    ref=GLFW.CreateWindow(1,1,"")
    this=new(ref,false,(1,1),"")
    WindowList[Symbol(this.ref)] = this
    this
  end
end

WindowList = Dict{Symbol,Window}()

getWindow(window_ref) = WindowList[Symbol(window_ref)]

function resize(window::Window, size::Tuple{Integer,Integer})
  window.size = size
  GLFW.SetWindowSize(window.ref, window.size[1], window.size[2]) # Seems to be necessary to guarantee that window > 0
end

end #WindowManager