module App

  module Game
    allocate() = Core.eval(@__MODULE__, :(module TEST; x=zeros(Float32,128^3*300); end))

    delete() = Core.eval(@__MODULE__, :(module TEST end))
    
    function run()
      println("Allocate Memory...")

      allocate()

      println("Wait 5 Seconds...")
      sleep(5)

      println("Free Memory...")

      delete()

      println("Done.")
    end
  end
  
  function run()
    Game.run()
    GC.gc()
  end

end

App.run()
