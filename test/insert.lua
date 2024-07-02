require [[quoted]]

local function test_insert(quote)
    quote = quote:insert(2, "+")
    return [=[
        $quote
    ]=], { quote = quote }
end

run() [=[
    assert(3 == test_insert!(1 2))
    assert(10 == test_insert!(5 5))
]=]
