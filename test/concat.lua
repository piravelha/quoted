require [[quoted]]

run() [=[
    local str = concat!("abc" .. "!" .. "def")
    assert(str == "abc!def")
]=]