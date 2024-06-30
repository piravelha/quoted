require [[quoted]]

local function println(quote)
    local str = quote[1]
    local vars = QuoteList()
    str = str.value:gsub("{([a-zA-Z_][a-zA-Z0-9_]*)}",
        function(match)
            vars = vars:append(Quote(match))
            return "%s"
        end)
    vars = vars:map(function(var)
        return var:prepend(",")
    end)
    return [[
        print(string.format(%s %s))
    ]], str, vars:join("")
end

program("out/println.lua", [=[
    local greet = "[[quoted]]"
    println!("Hello, {greet}!")
    --> Hello, [[quoted]]!
]=])

