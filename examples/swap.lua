require [[quoted]]

local function swap(quote)
    local a, b = quote:args()
    return Quote("%s, %s", b, a)
end

generate "out/swap.lua" [=[
    local x, y = 5, 10
    print(swap!(x, y))
]=]
