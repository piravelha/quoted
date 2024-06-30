require [[quoted]]

local function lambda(quote)
    local params, quote = quote:take_until("=>")
    local _, body = quote:expect("=>")
    if #params == 1 then
        params = params:prepend("("):append(")")
    end
    if body[1].value == "do" then
        body = Quote("(function()"):extend(body:slice(2, -2)):extend("end)()")
    end
    return [[
        (function %s
            return %s
        end)
    ]], params, body
end

local program = Quote[[
    local add = lambda!((x, y) => do
        print(string.format("add called with arguments '%s' and '%s'", x, y))
        return x + y
    end)
    print(add(1, lambda!(x => x)(2)))
    print(add(lambda!(x => x + 1)(4), 6))
]]

program:write("out/test.lua")
