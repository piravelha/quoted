require [[quoted]]

local function add(tokens)
    local a, b = tokens:split(","):unpack()
    return Quote(expr(a) + expr(b))
end

Quote[[
    local x = add!(1, 2)
    print(x)
]]:write("out/add.lua")
