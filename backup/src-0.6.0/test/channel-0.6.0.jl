channel = RemoteChannel()

function asynccall(f)
	@async begin # if we use multiple processes
	put!(channel, true)
	f()
	take!(channel)
	end
end

println("START CHANNEL")

asynccall(()->println("1"))
asynccall(()->println("2"))
asynccall(()->println("3"))
asynccall(()->println("4"))