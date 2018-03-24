module TimeManager
export now
export programStartTime
export currentTime
export programTime
export programTimeStr
export OnTime

now() = Dates.time()
programStartTime = now()

currentTime(startTime::Real) = (now() - startTime)
programTime() = currentTime(programStartTime)
programTimeStr() = @sprintf("%.3f", programTime())

function OnTime(milisec::Number, prevTime::Base.RefValue{Float64})
	time=now()
	r=(time - Base.getindex(prevTime)) >= milisec
	if r Base.setindex!(prevTime, time) end
	r
end

end

module LoggerManager

import Base.print, Base.println, Base.info, Base.warn, Base.error

export @printf # cannot replace Base.@printf

using Suppressor
using TimeManager

export LOGGER_OUT
export LOGGER_ERROR

export print
export printf
export println
export info
export warn
export error

LOGGER_OUT = "out.log"
LOGGER_ERROR = "error.log"

function __init__()
	open(LOGGER_OUT, "w+")
	open(LOGGER_ERROR, "w+")
end


@suppress begin print(xs...) = open(f -> (print(f, xs...); print(STDOUT, xs...)), LOGGER_OUT, "a+") end
macro printf(xs...) open(f -> (:(Base.@printf(f, $xs...)); :(Base.@printf(:STDOUT, $xs...))),LOGGER_OUT, "a+") end 
@suppress begin println(xs...) = open(f -> (println(f, programTimeStr(), " ", xs...); println(STDOUT, xs...)), LOGGER_OUT, "a+") end

@suppress begin info(xs...) = open(f -> (info(f, programTimeStr(), " ", xs...); info(STDOUT, xs...)), LOGGER_OUT, "a+") end
@suppress begin error(xs...) = open(f -> (error(f, programTimeStr()," ", xs...); error(STDERR, xs...)), LOGGER_ERROR, "a+") end
@suppress begin warn(xs...) = open(f -> (warn(f, programTimeStr()," ", xs...); warn(STDERR, xs...)), LOGGER_ERROR, "a+") end

function logException(ex::Exception, title="")
	time=programTimeStr()
  m=msg(:Exception, title, "", "See '$LOGGER_ERROR' for more info.")
	open(f -> println(f, m), LOGGER_OUT, "a+")
	open(function(f)
			print(f, msg(:Exception, title, "", ":"))
			Base.showerror(f, ex, catch_backtrace())
			println(f, "\n----------")
	end, LOGGER_ERROR, "a+")
  
  println(STDERR, "\x1b[91m", m, "\x1b[0m")
  print("Program will close in 3 sec")
  for i=1:3 Libc.systemsleep(1); print(".") end
  println()
  quit()
end

log(title, f::Function, args...) = try; f(args...); catch err; logException(err,title); end

msg(msg::String,lb=true) = string(programTimeStr(), " ",  msg, lb?"\n":"")

function msg(mode::Union{Symbol,String}, title::Union{Symbol,String}, name::Union{Symbol,String}, msg::String, lb=true)
  title=title!=""?string("(",title,") "):""
  mode=mode!=""?string("[",mode,"] "):""
  name=name!=""?string("'",name,"' "):""
  lb=lb?"\n":""
  string(programTimeStr(), " $mode$title$name$msg$lb")
end

end #LoggerManager

module ThreadManager

export ThreadID
export tcall

Mutex = Threads.Mutex()

ThreadID() = Threads.threadid()

function tcall(m::Threads.Mutex, f::Function, args...)
	Threads.lock(m)
	f(args...)
	Threads.unlock(m)
end

tcall(f::Function, args...) = tcall(Mutex, f, args...)

function run(a::Array{Function,1})
	global Mutex = Threads.Mutex()
	max=Threads.nthreads()
	i=0; Threads.@threads for start in a
		start()
		if i >= max break end; i+=1
  end
end

end # ThreadManager

tinfo(args...) = ThreadManager.tcall(() -> info(args...))
twarn(args...) = ThreadManager.tcall(() -> warn(args...))
terror(args...) = ThreadManager.tcall(() -> error(args...))

tprint(args...) = ThreadManager.tcall(() -> print(args...))
tprintln(args...) = ThreadManager.tcall(() -> println(args...))

tpush(args...) = ThreadManager.tcall(() -> push!(args...))

tsleep(sec) = Libc.systemsleep(sec)

tcheck(f::Function, args...) = ThreadManager.tcall(()->LoggerManager.log(string("T",ThreadManager.ThreadID()),f, args...))

tinit(p::Tuple{String,Function}) = function()
	tprint(LoggerManager.msg(:Debug, string("T",ThreadManager.ThreadID()), p[1], "start"))
	tcheck(p[2])
end

Messages = String[] #shared object among threads
clearMessages() = (global Messages = Array{String,1}())
getMessages() = Messages

showMessages() = ThreadManager.tcall(function()
					if length(Messages) > 0
						println("---[Messages]---")
						for msg in Messages print(msg) end
						clearMessages()
						println("----------------")
					end
				end)

pushMsg(mode, name, msg) = tpush(Messages, LoggerManager.msg(mode , string("T",ThreadManager.ThreadID()), name, msg)) 
pushMsg(name, msg)   = pushMsg("", name, msg)
pushInfo(name, msg)  = pushMsg(:Info, name, msg)
pushDebug(name, msg) = pushMsg(:Debug, name, msg)
pushError(name, msg) = pushMsg(:Error, name, msg)
pushWarn(name, msg)  = pushMsg(:Warning, name, msg)

