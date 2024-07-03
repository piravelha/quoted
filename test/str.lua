require [[quoted]]

run() [=[
    assert(str!(123) == "123")
    assert(str!(a b c) == "a b c")
    assert(str!(true) == "true")
]=]