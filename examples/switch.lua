require [[quoted]]

SWITCH = Macro(function(tokens)
    local match, tokens = tokens:take_until("|")
    local cases = tokens:split("|"):filter()
    local i = 0
    cases = cases:map(function(c)
        i = i + 1
        if not c:contains("->") then
            return Quote([[
                else %s
            ]], c)
        end
        local pattern, tokens = c:take_until("->")
        _, tokens = tokens:expect("->")
        local branch = "elseif"
        if i == 1 then
            branch = "if"
        end
        return Quote([[
            %s %s == %s then return %s
        ]], branch, match, pattern, tokens)
    end)
    return [[
        (function()
            %s end
        end)()
    ]], cases:join("")
end)

local x = 3

SWITCH[[x
| 1 -> print("One")
| 2 -> print("Two")
| print("Unknown")
| syntax error
]]()
