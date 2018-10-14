info(xs...) = println("INFO: ", xs...)

function capture_streams(f)
    _stdout, _stderr = stdout, stderr
    stdout_rd, stdout_wr = redirect_stdout()
    stderr_rd, stderr_wr = redirect_stderr()

    # buf combines the stdout and stderr
    buf, buf_stdout, buf_stderr = IOBuffer(), IOBuffer(), IOBuffer()

    # the signature of the callback is cb(stream, n)
    function cb_stdout(s,n)
        bytes = read(s,n)
        write(buf_stdout, bytes)
        write(buf, bytes)
        false
    end
    Base.start_reading(stdout_rd, cb_stdout)

    function cb_stderr(s,n)
        bytes = read(s,n)
        write(buf_stderr, bytes)
        write(buf, bytes)
        false
    end
    Base.start_reading(stderr_rd, cb_stderr)

    ret = try
        f()
    catch e
        println("ERROR in capture_streams(): $e")
    finally
        # read and restore
        redirect_stdout(_stdout)
        redirect_stderr(_stderr)

        close(stdout_wr)
        close(stderr_wr)

        #stdout_buf = readstring(stdout_rd)
        #stderr_buf = readstring(stderr_rd)

        close(stdout_rd)
        close(stderr_rd)
    end
    ret, takebuf_string(buf), takebuf_string(buf_stdout), takebuf_string(buf_stderr)
end

# Test / examples

function foo(x)
    for n = 1:x
        info("$n/$x \t[to STDERR]")
        println("$n/$x \t[to STDOUT]")
    end
    x
end

function test_capture(f)
    ret, all, out, err = capture_streams(f)
    println("Return value: $(ret)")
    println("------ STDOUT+STDERR -------")
    println(all)
    println("---------- STDOUT ----------")
    println(out)
    println("---------- STDERR ----------")
    println(err)
    println("----------------------------")
end
info("Capturing normally:")
test_capture() do
    info("Calling foo()")
    foo(5)
end

println(); println()

info("Capturing when error is thrown:")
try
    test_capture() do
        f(200) # error -- function does not exist
    end
catch e
    println("ERROR: $e")
end

info("Streams restored.")