function main()
	v1 = 0
	v2 = 0
	f1() = (for i = 1:1000 println("a") end);
	f2() = (println("b"));
	a = Task(f1);
	b = Task(f2);
	schedule(a);
	schedule(b);
	yield()
	println(v1," == ",v2)
end

main()