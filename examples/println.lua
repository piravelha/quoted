
require [[quoted]]

local function square(quote)
    return [[($x) * ($x)]], { x = quote }
end

execute() [=[
    println!(square!(10))
]=]
