module TimeManager

export now
export programStartTime
export currentTime
export programTime
export programTimeStr
export OnTime

using Dates
using Printf

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

end #TimeManager