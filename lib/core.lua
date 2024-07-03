_G["_"] = function(x)
    return x
end

function printbold(str)
    print("\27[1m" .. str .. "\27[0m")
end

function cls()
    os.execute("cls")
end

local function trim(str)
    return str:gsub("^%s*", ""):gsub("%s*$", "")
end

function assert_expected(str, expected)
    local line = debug.getinfo(2).currentline
    assert(trim(str) == trim(expected), tostring(line), 2)
end

local is = {}
local last
function forever(_, prev)
    if last and prev and last >= prev then
        table.remove(is, #is)
    end
    if not prev then
        table.insert(is, 0)
    end
    last = prev
    is[#is] = is[#is] + 1
    return is[#is]
end

function id(x)
    return x
end

function repr(object)
    if type(object) == "table" then
        if getmetatable(object)
        and getmetatable(object).__tostring then
            return tostring(object)
        end
        local str = "{"
        local i = 1
        for k, v in pairs(object) do
            if i > 1 then
                str = str .. ", "
            end
            if type(k) == "number" then
                str = str .. repr(v)
            else
                str = str .. "["
                    .. repr(k) .. "] = "
                    .. repr(v)
            end
            i = i + 1
        end
        return str .. "}"
    end
    return tostring(object)
end

System = {
    out = {
        println = print,
    },
}