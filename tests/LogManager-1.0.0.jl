module LoggerManager

import Base.print, Base.println, Base.error

using Dates
#using Suppressor
using ..TimeManager

export LOGGER_OUT
export LOGGER_ERROR

export print
export printf
export @printf
export println
export info
export warn
export error
export msg
export logException

LOGGER_OUT = "out.log"
LOGGER_ERROR = "error.log"

function __init__()
  if !isdir("logs") mkpath("logs") end
  global LOGGER_OUT = "logs/out-"*string(Dates.today())*".log"
  global LOGGER_ERROR = "logs/error-"*string(Dates.today())*".log"
	open(LOGGER_OUT, "w+")
	open(LOGGER_ERROR, "w+")
end


begin print(xs...;stream=stdout) = open(f -> (print(f, xs...); print(stream, xs...)), LOGGER_OUT, "a+") end
macro printf(stream=:STDOUT,xs...) open(f -> (:(Base.@printf(f, $xs...)); :(Base.@printf(stream, $xs...))),LOGGER_OUT, "a+") end 
begin println(xs...;stream=stdout) = open(f -> (println(f, programTimeStr(), " ", xs...); println(stream, xs...)), LOGGER_OUT, "a+") end

begin info(xs...) = open(f -> (println(f, programTimeStr(), " INFO: ", xs...); println("INFO: ",xs...;stream=stdout)), LOGGER_OUT, "a+") end
begin error(xs...) = open(f -> (println(f, programTimeStr()," ERROR: ",xs...); error(stderr,xs...)), LOGGER_ERROR, "a+") end
begin warn(xs...) = open(f -> (println(f, programTimeStr(), " WARNING: ",xs...); println("WARNING: ",xs...;stream=stderr)), LOGGER_ERROR, "a+") end

function logException(ex::Exception, title="")
	time=programTimeStr()
  m=msg(:Exception, title, "", "See '$LOGGER_ERROR' for more info.")
	open(f -> println(f, m), LOGGER_OUT, "a+")
	open(function(f)
			print(f, msg(:Exception, title, "", ":"))
			Base.showerror(f, ex, catch_backtrace())
			println(f, "\n----------")
	end, LOGGER_ERROR, "a+")
  
  println(stderr, "\x1b[91m", m, "\x1b[0m")
  print("Program will close in 3 sec")
  for i=1:3 Libc.systemsleep(1); print(".") end
  println()
  exit()
end

log(title, f::Function, args...) = try; f(args...); catch err; logException(err,title); end

msg(msg::String,lb=true) = string(programTimeStr(), " ",  msg, lb ? "\n" : "")

function msg(mode::Union{Symbol,String}, title::Union{Symbol,String}, name::Union{Symbol,String}, msg::String, lb=true)
  title=title!="" ? string("(",title,") ") : ""
  mode=mode!="" ? string("[",mode,"] ") : ""
  name=name!="" ? string("'",name,"' ") : ""
  lb=lb ? "\n" : ""
  string(programTimeStr(), " $mode$title$name$msg$lb")
end

end #LoggerManager