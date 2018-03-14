TIMERS = Dict{Any,Base.RefValue{Float64}}()

GetTimer(key) = Base.getindex(TIMERS[key])
SetTimer(key, time::Float64) = (TIMERS[key] = Ref(time))

SetTimer("FRAME_TIMER", Dates.time())

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
		
function OnTime(milisec::Float64)
	global TIMERS
	
	if !haskey(TIMERS,milisec)
		prevTime = 0.0
		SetTimer(milisec, 0.0)
	else
		prevTime = GetTimer(milisec)
	end
	
	(GetTimer("FRAME_TIMER") - prevTime) >= milisec
end

function OnTime(milisec::Float64, prevTime::Ref{Float64}, time)
	r = (time - Base.getindex(prevTime)) >= milisec
	if r Base.setindex!(prevTime,time) end
	r
end
