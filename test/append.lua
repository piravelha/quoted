require [[quoted]]

local function test_append(quote)
    quote = Quote("("):extend(quote):append(")"):extend("+ 1")
    return [[$quote]], { quote = quote }
end

run() [=[
    assert(10 == test_append!(9))
]=]
