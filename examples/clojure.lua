require [[quoted]]

CLOJURE = Macro(function(tokens)
    _, tokens = tokens:expect("|")
    params, tokens = tokens:take_until("|")
    return [[
        (function(%s)
            return %s
        end)
    ]], params, tokens
end)

local add = CLOJURE[[|x, y| x + y]]

print(add.expr(1, 2))
