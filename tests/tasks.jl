function main()
  c=Channel(1)
	f1() = (for i = 1:5 println("a"); put!(c,1); sleep(1); end);
	f2() = (for i = 1:5 println("b: ", take!(c)); sleep(0.1); end);
	a = Task(f1);
	b = Task(f2);
	schedule(a);
	schedule(b);
	#yield()
  wait(b);
end

main()