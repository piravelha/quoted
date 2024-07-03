require [[quoted]]

run() [=[
    local add = fn!((x, y) => x + y)
    local incr = fn!(x => x + 1)
    assert(add(1, incr(2)) == 4)
]=]