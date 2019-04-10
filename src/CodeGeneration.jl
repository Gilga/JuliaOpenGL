module CodeGeneration

using CodeManager

function module_listeners(mod::Module)
  expr = Expr(:toplevel,
    :(using CodeManager),
    :(_module_listeners = Dict{Symbol, Module}()),
    :(addListener(mod::Module) = if !haskey(_module_listeners, mod) _module_listeners[Symbol(mod)] = mod end),
    :(callOnListeners(name::Symbol) = for (_, listener) in _module_listeners CodeManager.safe_call(listener, name) end),
    )
  Core.eval(mod,expr)
end
export module_listeners

end #CodeGeneration
