require [[quoted]]

ENUM = Macro(function(tokens)
    local name, tokens = tokens:expect_type("name")
    _, tokens = tokens:expect("{")
    _, tokens = tokens:expect_last("}")
    names = tokens:split(","):filter()
    local iota = 0
    values = names:map(function(n)
        iota = iota + 1
        return n:extend(" = %d", iota)
    end):join(",")
    return [[
        %s = setmetatable({ %s }, {
            __tostring = function(_)
                return "%s"
            end,
        })
    ]], name, values, name
end)

ENUM[[Fruit {
    Apple,
    Banana,
    Grape,
}]]()

print(Fruit.Apple)
