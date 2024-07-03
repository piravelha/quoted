require [[quoted]]

execute() [=[
    open!(file = "quoted.lua", "r";
        local contents = file:read("*all")
        print(contents)
    end)
]=]
