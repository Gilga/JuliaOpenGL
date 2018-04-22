# [lib_time.jl](@id lib_time.jl)

GetTimer(key)

SetTimer(key, time::Number) 

SetTimer("FRAME_TIMER", Dates.time())

```@docs
App.UpdateTimers()
```

```@docs 
App.OnTime(milisec::Number)
```

```@docs
App.OnTime(milisec::Number, prevTime::Ref{Float64}, time)
```