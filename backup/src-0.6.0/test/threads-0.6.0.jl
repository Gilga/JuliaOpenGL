include("includes.jl")

using TimeManager

function thread_printer()
	p=(
		"Printer",
		function()
			#init
      i=0
			while true
				global Messages
				pushMsg(p[1], "PRINT $i")
        showMessages()
				tsleep(1)
        i+=1
			end
			#cleanUp
		end,
	)
end

function thread_compute()
	p=(
		"Compute", 
		function()
			timeRef = Ref(0.0)
      i=0
			while true
				if OnTime(0.25, timeRef)
					pushMsg(p[1], "CALC $i")
          i+=1
				end
				tsleep(0.001)
			end
		end,
	)
end

function thread_renderer()
	p=(
		"Renderer",
		function()
      timeRef = Ref(0.0)
      i=0
			while true
				if OnTime(0.5, timeRef)
					pushMsg(p[1], "RENDER $i")
          i+=1
				end
				tsleep(0.01)
			end
		end,
	)
end

function thread_sound()
	p=(
		"Sound", 
		function()
      timeRef = Ref(0.0)
      i=0
			while true
				if OnTime(0.75, timeRef)
					pushMsg(p[1], "SOUND $i")
          i+=1
				end
				tsleep(0.1)
			end
		end,
	)
end

function main()
  #LoggerManager.log(()->begin
    println("Test Threads")
    list=Function[]
    push!(list, tinit(thread_printer()))
    push!(list, tinit(thread_compute()))
    push!(list, tinit(thread_renderer()))
    push!(list, tinit(thread_sound()))
    ThreadManager.run(list)
  #end)
end

main()