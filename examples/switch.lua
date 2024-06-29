require [[quoted]]

SWITCH = Macro(function(tokens)
    local match, tokens = tokens:take_until("|")
    local cases = tokens:split("|"):filter()
    cases = cases:map(function(c)
        local pattern, tokens = c:take_until("=>")
        _, tokens = tokens:expect("=>")
        return Quote([[
            if %s == %s then
                return %s
            end
        ]], match, pattern, tokens)
    end)
    return [[
        (function()
            %s
        end)()
    ]], cases:join("")
end)

local x = 1

SWITCH[[x
    | 1 => print("One")
    | 2 => print("Two")
]]()
