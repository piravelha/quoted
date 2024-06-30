require [[quoted]]

local function inc(quote)
    local first, quote =
        quote:expect_type(Token.name, Token.special)
    if first:is_name() then
        local op, quote = quote:expect_special()
        local num
        if #quote == 0 then
            num = Quote("1")
        else
            quote = quote << "["
            quote = quote >> "]"
            num, quote = quote:expect_number()
        end
        op = Quote(op) + "1"
        return Quote([[
            id(function()
                local result = %s
                %s = %s %s
                return result
            end)()
        ]], first, first, first, op * expr(num))
    end
    local var, quote = quote:expect_name()
    local num
    if #quote == 0 then
        num = Quote("1")
    else
        quote = quote << "["
        quote = quote >> "]"
        num, quote = quote:expect_number()
    end
    first = Quote(first) + "1"
    return Quote([[
        id(function()
            %s = %s %s
            return %s
        end)()
    ]], var, var, first * expr(num), var)
end

run [=[
    local x = 1
    println!("Incrementing: {inc!(+x)}")
    println!("Decrementing: {inc!(-x)}")
]=]
