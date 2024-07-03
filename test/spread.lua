require [[quoted]]

run() [=[
    local xs = {1, 2, 3, 4}
    spread!(x, ...xs = xs)
    assert(x == 1)
    assert(xs[2] == 3)
]=]

run() [=[
    spread!(a, b, c = {1, 2, 3})
    assert(a == 1)
    assert(b == 2)
    assert(c == 3)
]=]