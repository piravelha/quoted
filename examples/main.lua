require [[quoted]]

local answer = Quote[=[ 42 ]=]

generate "out/main.lua" [=[
    local answer = 42
    print(answer! + 69)
]=]
