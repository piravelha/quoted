require [[quoted]]

generate() [=[
    local x = 5
    r!(x += 10)
    print(x)
]=]
