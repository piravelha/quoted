require [[quoted]]

run() [=[
    -- Write your code inside quotes!
    print(1 + 2)
]=]

-- You can declare constant macros as follows:

local x = [=[ 1 + 2 ]=]

run() [=[
    print(x!)
    --| print(1 + 2)
]=]

-- You can also declare a template:

local add = [=[ $1 + $2 ]=]

run() [=[
    print(add!(1, 2))
    --| print(1 + 2)
]=]


-- It is also possible to define more complex macros

local function complex_add(quote)
    local args = quote:split("and")
    local a, b = args:unpack()
    return [=[ $1 + $2 ]=], { a, b }
end

run() [=[
    print(complex_add!(1 and 2))
    --| print(1 + 2)
]=]

-- You can also output your quote to a file:

generate("basic.out.lua") [=[
    print(1 + add!(1, 1))
    --| print(1 + 1 + 1)
]=]
