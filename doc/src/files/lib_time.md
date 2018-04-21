# lib_time.jl

GetTimer(key)

SetTimer(key, time::Number) 

SetTimer("FRAME_TIMER", Dates.time())

UpdateTimers()
    
OnTime(milisec::Number)

OnTime(milisec::Number, prevTime::Ref{Float64}, time)
