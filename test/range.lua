require [[quoted]]

run() [=[
    local sum = 0
    range!(i = 1:10, do
        r!(sum += i)
    end)
    assert(sum == 55)
]=]
