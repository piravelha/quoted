require [[quoted]]

run() [=[
    local Fruit = enum! {
        Apple,
        Banana,
        Orange,
        Grape,
    }
    assert(Fruit.Apple == 1)
    assert(Fruit.Banana == 2)
    assert(Fruit.Orange == 3)
    assert(Fruit.Grape == 4)
]=]