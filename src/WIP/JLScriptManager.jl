module JLScriptManager

using Distributed

export JLComponent

""" TODO """
debug(s...) = println("\x1b[36mDEBUG: ",s...,"\x1b[39m\x1b[49m")

""" TODO """
warn(s...) = println("\x1b[35mWARNING: ",s...,"\x1b[39m\x1b[49m")

""" TODO """
abstract type AbstractObjectReference end

""" TODO """
abstract type JLComponent <: AbstractObjectReference end

""" TODO """
struct JLInvalidComponent <: JLComponent end

""" TODO """
const JL_INVALID_COMPONENT = JLInvalidComponent()

""" TODO """
mutable struct JLStateListComponent <: JLComponent
	isInitalized	::Bool
	isRunning			::Bool
	isTerminated	::Bool
	
	JLStateListComponent() = new(false,false,false)
end

export JLScriptFunction

""" TODO """
mutable struct JLScriptFunction
	func::Function
	JLScriptFunction(f::Function) = new(stabilize(f))
end

""" TODO """
mutable struct FileSource
  path  ::String
	cache ::String
  
  FileSource(path="") = new(abspath(path),"")
end

export JLScript

""" TODO """
mutable struct JLScript
  id        ::Symbol
	mod				::Module
  source    ::FileSource
	
	args			::Tuple # arguments passed on main()
  cache			::Dict{Symbol, Any}
  listener	::Dict{Symbol, Function}
	extern		::Dict{Symbol, Function}
	state			::JLComponent
	objref		::JLComponent
	funcs			::JLComponent
	events		::JLComponent
end

""" TODO """
struct EmptyObject <: AbstractObjectReference end

""" TODO """
const EMPTY_FUNCTION = () -> nothing

""" TODO """
const EMPTY_OBJECT = EmptyObject()

""" TODO """
OnException = EMPTY_FUNCTION

""" TODO """
JLScript(id::Symbol) = JLScript(id,FileSource())

""" TODO """
function JLScript(id::Symbol, source::FileSource)
  this=JLScript(id,Module(id),source,(),Dict(),Dict(),Dict(),JLStateListComponent(),JL_INVALID_COMPONENT,JL_INVALID_COMPONENT,JL_INVALID_COMPONENT)
  JLSCRIPTS[id]=this
  this
end

function JLScript(id::Symbol, path::String)
  this=JLScript(id,Module(id),FileSource(path),(),Dict(),Dict(),Dict(),JLStateListComponent(),JL_INVALID_COMPONENT,JL_INVALID_COMPONENT,JL_INVALID_COMPONENT)
  JLSCRIPTS[id]=this
  this
end

JLSCRIPTS = Dict{Symbol,JLScript}()

""" TODO """
loop(f::Function) = for (k,s) in JLSCRIPTS f(s) end

""" TODO """
listen(this::JLScript, k::Symbol, f::Function) = (this.listener[k]=f)

""" TODO """
function run(this::JLScript, args...)
	debug("run $(this.id)")
  clean(this)
  freeMemory()
	#Module(:__anon__)
	result = execute(this)
	if !result[1] result = nothing
	else result = result[2]
	end
  result
end

function clean()
  for (k,s) in JLSCRIPTS clean(s) end
  global JLSCRIPTS = Dict{Symbol,JLScript}()
  freeMemory()
end

clean(this::JLScript) = Core.eval(@__MODULE__,:(module $(this.id) end))

""" TODO """
(this::JLScript)(s::Symbol, args...) = execute(this.mod,s,args...) #@eval $f($args...)

""" TODO """
iscallable(f) = !isempty(methods(f))

""" TODO """
exists(this::JLScript, s::Symbol) = exists(this.mod,s)

#method_exists(Symbol(script.mod, :OnRender))
""" TODO """
exists(m::Module, s::Symbol) = isdefined(m,s) #&& iscallable(catchException(()->eval(e)))

""" TODO """
function execute(this::JLScript, compile_args=[], args...)
  debug("execute $(this.id)")
	result = compile(this, compile_args...)
	if result[1] result = (true, execute(result[2], args...)) end
	result
end

""" TODO """
execute(f::JLScriptFunction, args...) = (debug("execute function("*string(args...)*")"); f.func(args...))

""" TODO """
execute(m::Module, s::Symbol, args...) = isdefined(m,s) ? execute(:($m.$s),args...) : nothing #warn("$m.$s does not exist.") #(if isdefined(m,s) return execute(eval(m,s),args...); end; nothing)
#execute(o::Any, s::Symbol, args...) = isdefined(o,s) ? execute(:($o.$s),args...) : nothing

""" TODO """
execute(e::Expr, args...) = execute(catchException(()->eval(e)),args...)

""" TODO """
execute(f::Function, args...) = iscallable(f) ? invoke(f,args...) : warn("$f is not callable.")
#execute(f::Function, args...) = (debug("execute function("*string(args...)*")"); if iscallable(f) return invoke(f, args...); end; nothing)

""" TODO """
execute(t::Tuple{Bool,Any}, args...) = execute(t[1] ? t[2] : nothing, args...)

""" TODO """
execute(r::Any, args...) = (debug("result "*string(typeof(r))); r)

""" TODO """
execute(r::Nothing, args...) = (warn("Cannot execute nothing"); r)

""" TODO """
function invoke(f::Function, args...)
	result = nothing
	catchException(()	-> result = @eval $f($(args...)))
	result
end

""" TODO """
stabilize(f::Function) = (args...) -> invoke(f, args...)

""" TODO """
function linkToException(f::Function)
	global OnException = f
end

""" TODO """
function backTraceException(ex::Exception)
	warn("--- [ EXCEPTION BACKTRACE ] ---")
	Base.showerror(stderr, ex, catch_backtrace())
	println("\n---------------------")
end

""" TODO """
function catchException(f::Function, exf=OnException)
	try return f()
	catch ex exf(ex)
	end
	nothing
end

""" TODO """
function compile(this::JLScript, args...)
	debug("compile $(this.id)")
	result = (false, nothing)
	
	catchException(function()
		#if length(args)>0
			result = eval(this, args...)
		#else
		#	result = evalfile(this.source.path)
		#end
		
		if isa(result, Function) result = JLScriptFunction(result)
		else warn("Main Function not found.")
		end

		result = (true, result)
	end)
	
	result
end

""" TODO """
function cleanCode(code::String)
	
	# problem using match(): only "function (name)" will be detected!
	# for x in eachmatch(r"function \s(\w)", code) println(x.captures[1]) end

	# TODO merge code lines
	code=Base.replace(code, "\r" => "")
	#code=Base.replace(code, r"\#\=(?(?=\=\#)then|else)*\=\#", "")
	code=Base.replace(code, r"(?s)(?<=\#\=)(.*?)(?=\=\#)" => "")
	code=Base.replace(code, r"(\#[^\n]+)" => "")
	code=Base.replace(code, r"\n\s+\n" => "\n")
	code=Base.replace(code, r"\n+" => "\n")
	code=Base.replace(code, r"\s*(,)\s*" => s"\1")
	code=Base.replace(code, r"(\()\s*" => s"\1")
	code=Base.replace(code, r"\s*(\))" => s"\1")
	code=Base.replace(code, r"\n" => ";")
end

""" TODO """
function eval(this::JLScript, args...)
	
	this.mod = Module(this.id)

	debug("eval $(this.id)")
	
	# parse
	#################################################
	
	code = ""
	open(this.source.path) do fp	code = read(fp, String) end
	code=cleanCode(code)
	code=Meta.parse(code)

	#################################################
	
	funcs = ""
	funcsext = "" #"_(x) = (args...)->execute(x,args...);"
	
	xTypBody = ""
	xTypCall = ""
	fTypBody = ""
	fTypCall = ""
	eTypBody = ""
	eTypCall = ""
	
	def = (name) -> "$name::Function;"
	dec = (name) -> "(args...)->execute($name,args...)"
	
	for (name,f) in this.extern
		funcsext *= "global $name = this.extern[:$name];"
		#xTypBody *= def(name)
		#xTypCall *= (xTypCall != "" ? "," : "") * dec(name)
	end
	
	#################################################
	
	for x in code.args
		if x.head == Symbol("function")
			name=Symbol(Base.replace(string(x.args[1]), r"\(.*" => ""))

			if occursin(r"^On\w+", string(name))
				# event functions
				eTypBody *= def(name)
				eTypCall *= (eTypCall != "" ? "," : "") * dec(name)
			else
				# other functions
				fTypBody *= def(name)
				fTypCall *= (fTypCall != "" ? "," : "") * dec(name)
			end

		end
	end
	
	#################################################
	
	imports = ""
	imports *= "using $(@__MODULE__);"
  #imports *= "using Main.JuliaOpenGL.App.GAME;"
	
	typs = ""
	typ = replace(string(this.mod),"Main."=>"") #*"_JLFunctionListComponent"
	#if createExtFuncList typs *= "type "*typ*"_EXTFUNCTIONS <: JLComponent;"*xTypBody*";end;" end
	typs *= "mutable struct "*typ*"_FUNCTIONS <: JLComponent;"*fTypBody*";end;"
	typs *= "mutable struct "*typ*"_EVENTS <: JLComponent;"*eTypBody*";end;"
	
	mainFunc = "function main(args...);"
	mainFunc *= "this.args=args;"
	mainFunc *= funcsext
	#if createExtFuncList mainFunc *= "this.extfuncs = "*typ*"_EXTFUNCTIONS("*xTypCall*");" end
	mainFunc *= "this.funcs = "*typ*"_FUNCTIONS("*fTypCall*");"
	mainFunc *= "this.events = "*typ*"_EVENTS("*eTypCall*");"
	mainFunc *= "end;"
	
	#################################################
  
  #debug(imports*typs*funcs*mainFunc)
  
	ex=Expr(:toplevel,
		:(const ARGS = $(this.args)),
		:(eval(x) = Core.eval($(this.mod),x)),
		#:(eval(m,x) = Core.eval(m,x)),
		:(this=$this),
		args...,
		:(Base.include($(this.mod), $(this.source.path))), #which is faster?
		Meta.parse(imports*typs*funcs*mainFunc), #code, #which is faster?
	)
	
	#################################################
	
	#println("EXTFUNCS:\n", Base.replace(extfuncs, ",(" => "\n("),"\n")
	#println("FUNCS: ", fTypBody)
	#println("EVENTS: ", eTypBody)
	#dump(ex)
	
	#################################################
	
	Core.eval(this.mod, ex)
end

# SET
linkToException(backTraceException)

end # ScriptManager
