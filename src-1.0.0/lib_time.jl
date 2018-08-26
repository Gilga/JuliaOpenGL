using Dates

TIMERS = Dict{Any,Base.RefValue{Float64}}()

"""
TODO
"""
GetTimer(key) = Base.getindex(TIMERS[key])

"""
TODO
"""
SetTimer(key, time::Number) = (TIMERS[key] = Ref{Float64}(time))

SetTimer("FRAME_TIMER", Dates.time())

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
  
  (GetTimer("FRAME_TIMER") - prevTime) >= milisec
end

"""
TODO
"""
function OnTime(milisec::Number, prevTime::Ref{Float64}, time)
  r = (time - Base.getindex(prevTime)) >= milisec
  if r Base.setindex!(prevTime,time) end
  r
end
