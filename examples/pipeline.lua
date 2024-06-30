require [[quoted]]

local function lm(quote)
    local params = QuoteList()
    quote = quote:map(function(token)
        local new = Quote("_%s", token)
        if token.value:sub(1, 1) == "_" then
            if not params:contains(new) then
                params = params:append(new)
            end
            return new
        end
        return token
    end)
    return Quote[[
        (function(%s)
            return %s
        end)
    ]], params:join(","), quote
end

local function pipeline(tokens)
    local funcs = tokens:split("|>"):filter()
    funcs = funcs:reverse()
    local call = funcs:join("("):extend("(a")
    call = call:extend(Quote(")"):rep(#funcs))
    return [[
        (function(a)
            return %s
        end) 
    ]], call
end

Quote[[
    local double = lm!(_ * 2)
    local square = lm!(_ * _)
    local negate = lm!(-_)
    local process = pipeline!(double |> square |> negate)
    print(process(3))
]]:write("out/pipeline.lua")
