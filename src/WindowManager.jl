__precompile__(false)

module WindowManager

using GLFW

using SystemManager

###############################################################################

DRIVER_CHOICE = Symbol(GLFW)
#macro __DRIVER__() :($DRIVER_CHOICE) end

macro DRIVER() Meta.quot(SystemManager.@DRIVER DRIVER_CHOICE) end
macro DRIVER_INIT() Meta.quot(SystemManager.@DRIVER_INIT DRIVER_CHOICE) end
macro DRIVER_CHECK() Meta.quot(SystemManager.@DRIVER_CHECK DRIVER_CHOICE) end
#macro DRIVER_ENABLED() Meta.quot(SystemManager.@DRIVER_ENABLED DRIVER_CHOICE) end

###############################################################################

@DRIVER

function driver_init()
  GLFW.Terminate()  # remove previous Window
  GLFW.Init() # OS X-specific GLFW hints to initialize the correct version of OpenGL
  @DRIVER_INIT
end

const WindowRef = GLFW.Window
export WindowRef

mutable struct Window
  id::Symbol
  ref::Union{Nothing, WindowRef}
  pos::Tuple{Int32,Int32}
  size::Tuple{UInt32,UInt32}
  title::String
  focus::Bool
  fullScreen::Bool

  listenList::Dict{Symbol, Tuple{Symbol, Function}}
  events::Array{Array{Any,1},1}

  lastPos::AbstractVector
  lastCursorPos::AbstractVector
  lastSize::Tuple{Number,Number}

  function Window(id::Union{Nothing,Symbol}=nothing)
    this=new(generateID(id), #random id
    nothing,(0,0),(1,1),"",false,false,
    Dict(),[],[],[],(1,1))
    WindowList[this.id]=this
    this
  end
end
export Window

WindowList = Dict{Symbol,Window}()
WindowRefList = Dict{Symbol,Window}()

lastKey=Number(0)
KEYS=Dict{Number,Number}()

function cleanUp()
  global WindowList, WindowRefList
  WindowList = typeof(WindowList)()
  WindowRefList = typeof(WindowRefList)()
  GLFW.Terminate()
end

getWindow(ref::WindowRef)::Window = WindowRefList[Symbol(ref)]
export getWindow

function setWindow(this::Window, ref::WindowRef)
  this.ref = ref
  WindowRefList[Symbol(ref)] = this
end

function remove(this::Window)
  global WindowRefList, WindowList
  filter!((x)->x[1]!=this.id,WindowList)
  filter!((x)->x[1]!=Symbol(this.ref),WindowRefList)
end

# Create a window and its OpenGL context
"""
TODO
"""
function open(this::Window, options::Array{Pair{Symbol,T},1}=[]) where T
    if !SystemManager.driver_check(DRIVER_CHOICE;soft=true) driver_init() end

    for (id,val) in options
      GLFW.WindowHint(eval(:(GLFW.$id)),val)
    end

    (width,height) = this.size

    setWindow(this, GLFW.CreateWindow(width, height, this.title))

		pos = GLFW.GetWindowPos(this.ref)
    this.pos = (pos.x,pos.y)

  	GLFW.MakeContextCurrent(this.ref)
    GLFW.SwapInterval(0)
    #showError(true)
    GLFW.ShowWindow(this.ref)

    # OpenGL Version
    #GLFW.WindowHint(GLFW.CONTEXT_VERSION_MAJOR,4)
    #GLFW.WindowHint(GLFW.CONTEXT_VERSION_MINOR,6)

    #GLFW.SetWindowSize(window, w, h) # Seems to be necessary to guarantee that window > 0

    # Window Callbacks
    GLFW.SetWindowIconifyCallback(this.ref, OnWindowIconify)
    GLFW.SetWindowSizeCallback(this.ref, OnWindowResize)
    GLFW.SetWindowCloseCallback(this.ref, OnWindowClose)
    GLFW.SetWindowFocusCallback(this.ref, OnWindowFocus)
    GLFW.SetWindowPosCallback(this.ref, OnWindowPos)
    GLFW.SetWindowRefreshCallback(this.ref, OnWindowRefresh)
    GLFW.SetFramebufferSizeCallback(this.ref, OnFramebufferResize)
    GLFW.SetCursorPosCallback(this.ref, OnCursorPos)
    GLFW.SetCursorEnterCallback(this.ref, OnCursorEnter)
    GLFW.SetDropCallback(this.ref, OnDroppedFiles)

	   # Input Callbacks
    GLFW.SetKeyCallback(this.ref, OnKey)
    GLFW.SetMouseButtonCallback(this.ref, OnMouseKey)
    GLFW.SetScrollCallback(this.ref, OnScroll)
    GLFW.SetCharCallback(this.ref, OnUnicodeChar)
    GLFW.SetCharModsCallback(this.ref, OnCharMods)
end

function resize(this::Window, size::Tuple{Integer,Integer})
  (width,height) = this.size = size
  GLFW.SetWindowSize(this.ref, width, height) # Seems to be necessary to guarantee that window > 0
end

################################################################################
# Window Events

"""
TODO
"""
getEventNames() = [
  :OnWindowResize=>[Window,Tuple{Number,Number}],
  :OnWindowIconify=>[Window,Number],
  :OnWindowClose=>[Window],
  :OnWindowFocus=>[Window,Number],
  :OnWindowRefresh=>[Window],
  :OnFramebufferResize=>[Window,Tuple{Number,Number}],
  :OnCursorEnter=>[Window,Number],
  :OnDroppedFiles=>[Window,AbstractArray],
  :OnWindowPos=>[Window,Tuple{Number,Number}],
  :OnWindowMove=>[Window,Tuple{Number,Number}],
  :OnMousePos=>[Window,Tuple{Number,Number}],
  :OnMouseMove=>[Window,Tuple{Number,Number}],
  :OnScroll=>[Window,:x=>Number,:y=>Number],
  :OnCharMods=>[Window,:code=>Char,:mods=>Number],
  :OnKey=>[Window,:key=>Number,:scancode=>Number,:action=>Number,:mods=>Number],
  :OnMouseKey=>[Window,:key=>Number,:action=>Number,:mods=>Number],
]

"""
TODO
"""
function OnWindowResize(this::WindowRef, width::Number, height::Number)
	window = getWindow(this)
	window.size = (width,height)
	OnEvent(window, :OnWindowResize, [width,height])
end

"""
TODO
"""
OnWindowIconify(this::WindowRef, iconified::Number) = OnEvent(getWindow(this), :OnWindowIconify, iconified)

"""
TODO
"""
OnWindowClose(this::WindowRef) = OnEvent(getWindow(this), :OnWindowClose)

"""
TODO
"""
OnWindowFocus(this::WindowRef, focused::Number) = OnEvent(getWindow(this), :OnWindowFocus, focused)

"""
TODO
"""
OnWindowRefresh(this::WindowRef) = OnEvent(getWindow(this), :OnWindowRefresh)

"""
TODO
"""
OnFramebufferResize(this::WindowRef, width::Number, height::Number) =  OnEvent(getWindow(this), :OnFramebufferResize, [width,height])

"""
TODO
"""
OnCursorEnter(this::WindowRef, entered::Number) = OnEvent(getWindow(this), :OnCursorEnter, entered)

"""
TODO
"""
OnDroppedFiles(this::WindowRef, files::AbstractArray) = OnEvent(getWindow(this), :OnDroppedFiles, files)

"""
TODO
"""
function OnWindowPos(this::WindowRef, x::Number, y::Number)
  window = getWindow(this)
  t = [-x,y]
  OnEvent(window, :OnWindowPos, (t[1],t[2])) #
  l = window.lastPos; if l == [] l = t end
  n = l - t
  window.lastPos = t
  OnEvent(window, :OnWindowMove, (n[1],n[2])) #
end

"""
TODO
"""
function OnCursorPos(this::WindowRef, x::Number, y::Number)
  window = getWindow(this)
  t = [x,y]
  OnEvent(window, :OnMousePos, (t[1],t[2]))
  l = window.lastCursorPos; if l == [] l = t end
  n = l - t
  window.lastCursorPos = t
  OnEvent(window, :OnMouseMove, (n[1],n[2]))
end

# Input Events
"""
TODO
"""
OnScroll(this::WindowRef, x::Number, y::Number) = OnEvent(getWindow(this), :OnScroll, [x,y])

"""
TODO
"""
OnCharMods(this::WindowRef, code::Char, mods::Number) = OnEvent(getWindow(this), :OnCharMods, code, mods)

"""
TODO
"""
function OnKey(this::WindowRef, key::GLFW.Key, scancode::Number, action::GLFW.Action, mods::Number)
	window = getWindow(this)
  key, scancode, action, mods, unicode = UInt32(key), UInt32(scancode), UInt32(action), UInt32(mods), UInt32(0)
	global lastKey = key
	push!(window.events, [ :OnKey, key, scancode, action, mods, unicode ])
end

"""
TODO
"""
OnMouseKey(this::WindowRef, key::GLFW.MouseButton, action::GLFW.Action, mods::Number) = OnEvent(getWindow(this), :OnMouseKey, UInt32(key), UInt32(action), UInt32(mods))

"""
TODO
"""
function OnUnicodeChar(this::WindowRef, unicode::Char)
	window = getWindow(this)
	if lastKey > 0 KEYS[lastKey]=Number(unicode) end
	global lastKey=0
end

################################################################################

"""
TODO
"""
function OnUpdateEvents()
  GLFW.PollEvents()  # Poll for and process events
	for (_,window) in WindowRefList
		for e in window.events
			if length(e) > 5 && e[1] == :OnKey
				key=e[2]
				if haskey(KEYS, key) e[6]=KEYS[key] end
			end
			OnEvent(window, e...)
		end
		if length(window.events) > 0	window.events	= [] end
	end
end

"""
TODO
"""
function OnEvent(this::Window, eventName::Symbol, args...)
 #a = values(d) # convert Dict Values to Array
  for (_,listener) in this.listenList
		if listener[1] == eventName listener[2](this, args...) end
    #s = listener.storage
		#if haskey(s.events, eventName) s.events[eventName](args...) end
  end
end

################################################################################

"""
TODO
"""
setListener(this::Window, eventName::Symbol, callback::Function; id::Union{Nothing,Symbol}=nothing) =
	this.listenList[generateID(id)] = (eventName, callback)

"""
TODO
"""
function close(this::Window)
  remove(this)
	if length(WindowRefList) == 0 GLFW.Terminate() end
end


"""
TODO
"""
swap(this::Window) = GLFW.SwapBuffers(this.ref)   # Swap front and back buffers

#function GLFW_SetWindowMonitor(window::GLFW.Window, monitor::GLFW.Monitor, xpos, ypos, width, height, refreshRate)
#  ccall((:glfwSetWindowMonitor, GLFW.lib), Nothing, (GLFW.Window, GLFW.Monitor, Cint, Cint, Cint, Cint, Cint), window, monitor, xpos, ypos, width, height, refreshRate)
  # GLFW.SetWindowMonitor
#end

"""
TODO
"""
function fullscreen(this::Window, full::Bool)
	monitor = GLFW.GetPrimaryMonitor()
	mode = GLFW.GetVideoMode(monitor)
	pos = GLFW.GetMonitorPos(monitor)

	if !full
		pos = this.pos
		(width,height) = this.size = this.lastSize
		mode = GLFW.VidMode(width, height, mode.redbits, mode.greenbits, mode.bluebits, mode.refreshrate)
		monitor = GLFW.Monitor(C_NULL)
	else
		this.lastSize = this.size
		this.pos = GLFW.GetWindowPos(this.ref)
		this.size = GLFW.GetWindowSize(this.ref)
	end

	this.fullScreen = full
	GLFW.SetWindowMonitor(this.ref, monitor, pos[1], pos[2], mode.width, mode.height, mode.refreshrate)
end

"""
TODO
"""
cursor(this::Window, mode::Symbol) = GLFW.SetInputMode(this.ref, GLFW.CURSOR, eval(:(GLFW.$mode)))
#GLFW.STICKY_KEYS or GLFW.STICKY_MOUSE_BUTTONS

"""
TODO
"""
function title(this::Window, title::String)
  this.title = title
  GLFW.SetWindowTitle(this.ref, title)
end

"""
TODO
"""
function showError(debugging::Bool)
  @static if Sys.isapple() return end # not working on apple
  GLFW.WindowHint(GLFW.OPENGL_DEBUG_CONTEXT, convert(Cint, debugging))
end

"""
TODO
"""
isOpen(this::Window) = !GLFW.WindowShouldClose(this.ref)

"""
TODO
"""
function update(this::Window)
  swap(this)
	OnUpdateEvents()
end

"""
Loop until the user closes the window
"""
function loop(this::Window, repeat::Function)
	while isOpen(this)
		repeat(this)
		update(this) # update window
	end
	close(this)
end

end #WindowManager
