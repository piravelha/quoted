require [[quoted]]

local function square(quote)
    return [=[
        ($x) * ($x)
    ]=], {
        x = quote,
    }
end

run() [=[
    print(square!(5))
]=]