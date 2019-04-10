__precompile__(false)

module ScriptManager

mutable struct Script
  name::String
  initalized::Bool
  inputs::Dict{Symbol, Any}
  events::Dict{Symbol, Function}
  init::Union{Nothing, Function}
  update::Union{Nothing, Function}
  render::Union{Nothing, Function}
  clean::Union{Nothing, Function}

  Script(name::String) = new(name,false,Dict(),Dict(),nothing,nothing,nothing,nothing)
end

main_script = nothing
reload_script = nothing
setReload(func::Function) = global reload_script = func

function reload(script::Union{Nothing, Script}=main_script)
  if script == nothing return end
  reload_script(script)
  global main_script = script
  GC.gc()
  script.init()
end

getFunction(func::Union{Nothing, Function}, args...) = () -> begin if func != nothing eval(:($func($args...))) end; end

getEventCall(script::Script, key::Symbol) = haskey(script.events, key) ? script.events[key] : nothing

callEvent(script::Script, key::Symbol, args...) = getFunction(getEventCall(script, key), args...)()
callEvent(key::Symbol, args...) = if main_script!= nothing getFunction(getEventCall(main_script, key), args...)() end

end #ScriptManager
