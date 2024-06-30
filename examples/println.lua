require [[quoted]]

local function println(quote)
    return [[
        print(F!(%s))
    ]], quote
end

generate "out/println.lua" [=[
    local greet = "[[quoted]]"
    println!("Hello, {greet}!")
    --> Hello, [[quoted]]!
]=]
