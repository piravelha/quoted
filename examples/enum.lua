require("quoted")

function enum(tokens)
    local name, tokens = tokens:expect_type(TokenType.Name)
    _, tokens = tokens:expect("{")
    _, tokens = tokens:expect_last("}")
    fields = tokens:split(","):filter()
    local iota = 0
    body = fields:map(function(n)
        iota = iota + 1
        return n:extend([[= %d]], iota)
    end):join(",")
    return Quote([[
        local %s = setmetatable({ %s }, {
            __tostring = function(_)
                return "%s"
            end,
        })
    ]], name, body, name)
end

Quote[[
    enum!(Fruit {
        Apple,
        Banana,
        Grape,
        Orange,
    })
    print(Fruit.Orange)
]]:write("out/enum.lua")
