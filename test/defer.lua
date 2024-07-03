require [[quoted]]

run() [=[
    local a = 5
    assert(a == 5)
    defer!(a = 10)
    a = 0
    assert(a == 0)
    collectgarbage("collect")
    assert(a == 10)
]=]