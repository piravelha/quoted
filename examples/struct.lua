require [[quoted]]

function struct(tokens)
    local name, tokens = tokens:expect_type("name")
    _, tokens = tokens:expect("{")
    _, tokens = tokens:expect_last("}")
    local fields = tokens:split(","):filter()
    local i = 0
    local values = fields:map(function(f)
        i = i + 1
        return Quote([[ %s = params[%d] ]], f, i)
    end):join(",")
    return [[ %s = function(params)
        return { %s } end
    ]], name, values
end

Quote[[
    struct!(Person {
        name,
        age,
    })
    local person = Person {"Ian", 15}
    print(person.name)
    print(person.age)
]]:write("out/struct.lua")
