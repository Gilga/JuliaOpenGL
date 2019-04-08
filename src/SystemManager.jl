__precompile__(false)

module SystemManager

DRIVER_LIST = Dict{Symbol, Bool}()

driver_init(name,init=true) = DRIVER_LIST[Symbol(name)]=init

function driver_check(name;soft=false)
  result=false
  if !haskey(DRIVER_LIST, Symbol(name)) || !DRIVER_LIST[Symbol(name)]
    if !soft error("Driver "*string(name)*" is not initalized!") end
  else
    result=true
  end
  result
end

macro DRIVER(name) Meta.quot(driver_init(name,false)) end
macro DRIVER_INIT(name) Meta.quot(driver_init(name)) end
macro DRIVER_CHECK(name) Meta.quot(driver_check(name)) end
macro DRIVER_ENABLED(name) Meta.quot(driver_check(name;soft=true)) end

export @DRIVER, @DRIVER_INIT, @DRIVER_CHECK, @DRIVER_ENABLED

generateID(id::Union{Nothing,Symbol}=nothing) = id == nothing ? Symbol(rand(UInt)) : id
export generateID

end # SystemManager
