module CodeManager

using Distributed

""" TODO """
debug(s...) = println("\x1b[36mDEBUG: ",s...,"\x1b[39m\x1b[49m")

""" TODO """
warn(s...) = println("\x1b[35mWARNING: ",s...,"\x1b[39m\x1b[49m")

const EMPTY_FUNCTION = (args...) -> nothing

""" force garbage collection, free memory """
const force_gc = GC.gc
const free_memory = GC.gc
export force_gc, free_memory

""" TODO """
function print_backtrace(ex::Exception)
  print("\x1b[91m")
  Base.showerror(stderr, ex, catch_backtrace())
  println("\x1b[0m")
end

""" TODO """
function print_backtrace(f::Function)
  try
    return f()
  catch ex
    print_backtrace(ex)
  end
  nothing
end
export print_backtrace

""" TODO """
get_module(mod::Module, sym::Symbol) = Core.eval(Main, Meta.parse(string(Symbol(mod,:.,sym))))
export get_module

""" TODO """
function safe_include(mod::Module, path::String)
  result = (false, nothing)
  #safe_clean!(mod)
  print_backtrace(() -> begin
    result = (true, Core.include(mod, abspath(path)))
  end)
  result
end
export safe_include

#""" TODO """
#function include_module2(mod::Module, sym::Symbol, path::String)
#  result = (false, nothing)
#  safe_clean!(mod, sym)
#  print_backtrace(() -> begin
#    result = (true, Core.eval(mod, :(module $sym; include(abspath($path)); end)))
#  end)
#  result
#end

""" TODO """
function cleanCode(code::String)
	
	# problem using match(): only "function (name)" will be detected!
	# for x in eachmatch(r"function \s(\w)", code) println(x.captures[1]) end

	# TODO merge code lines
	code=replace(code, "\r" => "")
	#code=replace(code, r"\#\=(?(?=\=\#)then|else)*\=\#", "")
	code=replace(code, r"(?s)(?<=\#\=)(.*?)(?=\=\#)" => "")
	code=replace(code, r"(\#[^\n]+)" => "")
	code=replace(code, r"\n\s+\n" => "\n")
	code=replace(code, r"\n+" => "\n")
  code=replace(code, r"\s*([\+\-\*\/]?\=)\s*" => s"\1")
	code=replace(code, r"(\()\s*" => s"\1")
	code=replace(code, r"\s*(\))" => s"\1")
  code=replace(code, r"\n" => ";")
	code=replace(code, r"\s*([,;])\s*" => s"\1")
end

#code = cleanCode(code)
#code = replace(code, r"^\s*module\s+\w+\s*" => "")
#code = replace(code, r"\s+end\s*$" => "")
#println(code)

#mgr=@__MODULE__
#LF=";"
#add = ""
#add *= "const self = "*name*LF
#add *= "safe_eval(x) = $mgr.safe_eval("*name*", x)"*LF
#add *= "safe_call(x) = $mgr.safe_call("*name*", x)"*LF
#add *= "include_module(x;name=:anonymous) = $mgr.include_module("*name*", x; name=name)"*LF
#add *= "safe_clean!(x) = $mgr.safe_clean!("*name*", x)"*LF
#code = "module "*name*LF*code*LF*"end; println(names("*name*")); "

""" TODO """
function include_module(mod::Module, path::String; name::Symbol=:anonymous)
  result = (false, nothing)
  
	code = print_backtrace(() -> begin  code = ""; open(abspath(path)) do fp	code = read(fp, String) end; code; end)
	if code != nothing 
    find = r"^\s*module\s+(\w+)\s*.*$"is
    if occursin(find, code) name = Symbol(replace(code,find=>s"\1")) end
  end
  
  if isdefined(mod,name) safe_clean!(mod, name) end
  print_backtrace(() -> begin
    result = (true, Core.include(mod, abspath(path)))
    mgr=@__MODULE__
    mod_child = get_module(mod, name)
    
    expr = Expr(:toplevel,
      :(free!() = $mgr.safe_clean!(@__MODULE__)),
      :(safe_invoke(link::Expr, args...) = $mgr.safe_invoke(@__MODULE__, link, args...)),
      :(safe_eval(x::Any) = $mgr.safe_eval(@__MODULE__, x)),
      :(safe_call(x::Any) = $mgr.safe_call(@__MODULE__, x)),
      :(safe_clean!(x::Any) = $mgr.safe_clean!(@__MODULE__, x)),
      :(include_module(path::String;name=:anonymous) = $mgr.include_module(@__MODULE__, path; name=name)),
      )
      
    Core.eval(mod_child, expr)
  end)
  
  result
end
export include_module

""" TODO """
safe_invoke(mod::Module, link::Expr, args...) = safe_invoke(safe_eval(mod, link)[2], args...)

""" TODO """
function safe_invoke(f::Function, args...)
  result = (false, nothing)
  print_backtrace(() -> begin
    result = (true, Base.invokelatest(f, args...))
  end)
  result
end
export safe_invoke

""" TODO """
safe_call(mod::Module, value::Expr) = safe_eval(mod, :($value()))

""" TODO """
safe_call(mod::Module, value::Function) = safe_eval(mod, value)
export safe_call

""" TODO """
safe_eval(mod::Module, value::String) = safe_eval(mod, Meta.parse(value))

""" TODO """
safe_eval(mod::Module, value::Function) = safe_eval(mod, :($value()))

""" TODO """
function safe_eval(mod::Module, value::Any)
  result = (false, nothing)
  print_backtrace(() -> begin
    result = (true, Core.eval(mod, value))
  end)
  result
end
export safe_eval

""" TODO """
safe_clean!(mod::Module, sym::Symbol) = safe_clean!(get_module(mod, sym))
export safe_clean!

""" TODO """
#Base.compilecache()
function safe_clean!(mod::Module; clean_child_modules=false, bare=false)
  mods = Module[]
  mods_done = Module[]

  print_backtrace(() -> begin
    push!(mods,mod)
    while length(mods)>0
      mod=pop!(mods)
      parent = parentmodule(mod)
      symbol = Symbol(mod)
      name = nameof(mod) #split(string(mod),".")[end] #nameof(mod)
      for sym in names(mod, all=true)
        try 
        try value = getfield(mod,sym); catch z; value = sym end
        typ = typeof(value)
        if isa(sym, Symbol) && isdefined(mod, sym)
          if occursin(r"^\#",string(sym)); value = Function; end
          try 
            if value == Symbol || isa(value, Symbol) #ignore
            elseif value == Module || isa(value, Module) if clean_child_modules && !in(mod,mods_done) && Symbol("Main.",sym) != symbol && sym != symbol && sym != name push!(mods,getModule(mod, sym)) end #TODO
            elseif value == Function || isa(value, Function); Core.eval(mod, :($sym() = nothing));
            elseif isconst(mod, sym)
              if isa(value, Module); #ignore
              elseif isa(value, Number) Core.eval(mod,:(const $sym = $typ(0))) #set to default
              else Core.eval(mod,:(const $sym = $typ())) #set to default constructor -> when it fails it fails
              end
            else Distributed.clear!(sym;mod=mod) 
            #warn("$mod.$sym::$typ is not supported!")
            end
          catch x
            warn("$mod.$sym::$typ -> error!")
          end
        else warn("$mod.$sym::$typ is not valid!")
        end 
        catch xxx
          debug("Symbol $mod.$sym error!")
        end
      end
      push!(mods_done, mod)
      #println(names(mod,all=true))
      Core.eval(parent, bare ? :(baremodule $name end) : :(module $name end)) #clear module
      #println(names(eval(Meta.parse(string(Symbol(mod)))),all=true))
    end
  end)

  force_gc()
end
export clean

end #CodeManager
