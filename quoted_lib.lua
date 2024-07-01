function printbold(str)
    print("\27[1m" .. str .. "\27[0m")
end

function cls()
    os.execute("cls")
end

function trim(str)
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


