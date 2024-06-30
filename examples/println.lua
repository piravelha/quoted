require [[quoted]]

local x = Quote [=[ 10 ]=]

generate() [=[
    local y = 20
    println!("Result: {x! + y}")
]=]
