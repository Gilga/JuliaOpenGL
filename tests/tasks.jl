function main()
  #ch=Channel(1)
	f1() = (for i = 1:5 println("a"); put!(ch,1); sleep(1); end);
	f2() = (for i = 1:5 println("b: ", take!(ch)); sleep(0.1); end);
  f3() = (while true; println("c"); for i = 1:9999999 b=i^i; end; sleep(0); end);
  f4() = (while true; print("."); sleep(0.1); end);
	a = Task(f1);
	b = Task(f2);
  c = Task(f3);
  d = Task(f4);
	#schedule(a);
	#schedule(b);
  schedule(c);
  schedule(d);
	#yield()
  wait(c);
end

main()