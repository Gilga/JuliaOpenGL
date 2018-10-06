module LoggerManager

using Dates

using ..TimeManager

export LOGGER_OUT
export LOGGER_ERROR

#export printf

#export print
#export @printf
#export println
#export info
#export warn
#export error

LOGGER_OUT = "out.log"
LOGGER_ERROR = "error.log"

function __init__()
  if !isdir("logs") mkpath("logs") end
  global LOGGER_OUT = "logs/out-"*string(Dates.today())*".log"
  global LOGGER_ERROR = "logs/error-"*string(Dates.today())*".log"
	open(LOGGER_OUT, "w+")
	open(LOGGER_ERROR, "w+")
end


begin print(xs...;stream=stdout) = open(f -> (Base.print(f, xs...); Base.print(stream, xs...)), LOGGER_OUT, "a+") end
macro printf(stream=:STDOUT,xs...) open(f -> (:(Base.@printf(f, $xs...)); :(Base.@printf(stream, $xs...))),LOGGER_OUT, "a+") end 
begin println(xs...;stream=stdout) = open(f -> (Base.println(f, programTimeStr(), " ", xs...); Base.println(stream, xs...)), LOGGER_OUT, "a+") end

begin info(xs...) = open(f -> (Base.println(f, programTimeStr(), " INFO: ", xs...); Base.println("INFO: ",xs...;stream=stdout)), LOGGER_OUT, "a+") end
begin error(xs...) = open(f -> (Base.println(f, programTimeStr()," ERROR: ",xs...); error(stderr,xs...)), LOGGER_ERROR, "a+") end
begin warn(xs...) = open(f -> (Base.println(f, programTimeStr(), " WARNING: ",xs...); Base.println("WARNING: ",xs...;stream=stderr)), LOGGER_ERROR, "a+") end
begin debug(xs...) = open(f -> (Base.println(f, programTimeStr(), " DEBUG: ",xs...); Base.println("DEBUG: ",xs...;stream=stderr)), LOGGER_ERROR, "a+") end

function logException(ex::Exception, title="")
	time=programTimeStr()
  m=msg(:Exception, title, "", "See '$LOGGER_ERROR' for more info.")
	open(f -> println(f, m), LOGGER_OUT, "a+")
	open(function(f)
			Base.print(f, msg(:Exception, title, "", ":"))
			Base.showerror(f, ex, catch_backtrace())
			Base.println(f, "\n----------")
	end, LOGGER_ERROR, "a+")
  
  Base.println(stderr, "\x1b[91m", m, "\x1b[0m")
  Base.print("Program will close in 3 sec")
  for i=1:3 Libc.systemsleep(1); Base.print(".") end
  Base.println()
  exit()
end

log(title, f::Function, args...) = try; f(args...); catch err; logException(err,title); end

function msg(args... ;time=true, name="", mode="", title="", lineBreak=true)
  m=""
  if time m *= programTimeStr()*" " end
  if name!="" m *= string("(",name,") ") end
  if mode!="" m *= string("[",mode,"] ") end
  if title!="" m *= string("'",title,"' ") end
  m *= string(args...)
  if lineBreak m *= "\n" end
  m
end

end #LoggerManager