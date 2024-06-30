require [[quoted]]

local answer = Quote[=[ 42 ]=]

generate "out/main.lua" [=[
    print(answer! + 69)
]=]
