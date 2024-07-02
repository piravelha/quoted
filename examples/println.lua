require [[quoted]]

local square = [=[
    ($1) * ($1)
]=]

local x = [=[
    10 + ($1)
]=]

execute() [=[
    local a = x!(2)
    local b = square!(a)
    println!("result is {b}!")
]=]

