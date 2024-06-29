require [[quoted]]

STRUCT = Macro(function(tokens)
    local name, tokens = tokens:expect_type("name")
    _, tokens = tokens:expect(":")
    local fields = tokens:split(","):filter()
    local i = 0
    local values = fields:map(function(f)
        i = i + 1
        return Quote(f, "= params[", i, "]")
    end):join(",")
    return [[
        %s = function(params)
            return { %s }
        end
  ]], name, values, name
end)

STRUCT[[Person:
    name,
    age,
]]()

local person = Person {"Ian", 15}
print(person.name)
print(person.age)
