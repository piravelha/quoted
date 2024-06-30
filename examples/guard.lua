require [[quoted]]

local function guard(tokens)
    local cond, body = tokens:split("=>"):unpack()
    _, body = body:expect("function")
    params, body = body:take_until(")")
    params = params:append(")")
    _, body = body:expect(")")
    _, body = body:expect_last("end")
    return Quote[[
        (function %s
            if not (%s) then
                error("failure to satisfy guard '%s'", 2)
            end
            %s
        end)
    ]], params, cond, cond:str(), body
end

Quote[[
    local safe_div = guard!(b ~= 0 => function(a, b)
        return a / b
    end)
    print(safe_div(4, 2))
    print(safe_div(3, 2))
]]:write("out/guard.lua")
