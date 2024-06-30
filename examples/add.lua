require [[quoted]]

local function add(quote)
    local values = quote:split(",")
    local sum = 0
    values:foreach(function(x)
        sum = sum + expr(x)
    end)
    return Quote(sum)
end

generate "out/add.lua" [=[
    local x = add!(1, 2, 3, 4)
    print(x)
]=]

