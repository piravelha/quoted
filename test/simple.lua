require [[quoted]]

local x = Quote[[ 5 ]]

local first = run [[test]] [=[
    print(x!)
]=]

local function square(quote)
    return Quote([[(%s) * (%s)]], quote, quote)
end

local second = run [[test]] [=[
    local result = square!(3)
    print(square!(result))
]=]

local function inline_add(quote)
    local a, b = quote:args()
    return Quote([[%s]], expr(a) + expr(b))
end

local third = run [[test]] [=[
    local x = inline_add!(1, 2)
    local y = inline_add!(5, 4)
    print(x + y)
]=]

assert_expected(first, [[
print(5)
]])

assert_expected(second, [[
local result = 3 * 3
print(result * result)
]])

assert_expected(third, [[
local x = 3
local y = 9
print(x + y)
]])