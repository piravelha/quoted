require [[quoted]]

local function let(quote)
    local var, quote = quote:expect_name()
    quote = quote << "="
    local value, quote = quote // "in"
    return Quote([[
        id(function(%s)
            return %s
        end)(%s)
    ]], var, quote, value)
end

run [=[
    local x = 5
    print(let!{ y = 10
        in f!"Result is: {x + y}" })
]=]

