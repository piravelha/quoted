require [[quoted]]

run() [=[
    assert(trim!("  .     ") == ".")
    assert(trim!(" A A ") == "A A")
]=]