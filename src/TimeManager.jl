module TimeManager

export programStartTime
export currentTime
export programTime
export programTimeStr
export OnTime
export GetTimer
export SetTimer
export UpdateTimers
export GetTimePassed

using Dates
using Printf

TIMERS = Dict{Any,Base.RefValue{Float64}}()
time_start = time()

currentTime(startTime::Real) = (time() - startTime)
programStartTime() = time_start
programTime() = currentTime(time_start)
programTimeStr() = @sprintf("%.3f", programTime())

"""
TODO
"""
GetTimer(key) = Base.getindex(TIMERS[key])

"""
TODO
"""
SetTimer(key, time::Number) = (TIMERS[key] = Ref{Float64}(time))

"""
TODO
"""
function UpdateTimers()
  global TIMERS
  time = GetTimer("FRAME_TIMER")
  
  LOCAL_TIMERS = filter(tuple -> (f=first(tuple); isa(f,AbstractFloat) || isa(f,Integer)), collect(TIMERS))
  for (milisec,prevTime) in LOCAL_TIMERS
    r=(time - Base.getindex(prevTime)) >= milisec
    if r Base.setindex!(prevTime, time) end
  end
  SetTimer("FRAME_TIMER", Dates.time())
end

timePassed = 0
GetTimePassed() = timePassed
SetTimePassed(t) = global timePassed=t

"""
TODO
"""
function OnTime(milisec::Number)
  global TIMERS
  
  if !haskey(TIMERS,milisec)
    prevTime = 0.0
    SetTimer(milisec, 0.0)
  else
    prevTime = GetTimer(milisec)
  end
  
  SetTimePassed(GetTimer("FRAME_TIMER") - prevTime) >= milisec
end

"""
TODO
"""
function OnTime(milisec::Number, prevTime::Ref{Float64}; time=time()) #RefValue
  r = (time - Base.getindex(prevTime)) >= milisec
  if r Base.setindex!(prevTime,time) end
  r
end

SetTimer("FRAME_TIMER", time())

end #TimeManager