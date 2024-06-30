require [[quoted]]

local function method(quote)
    local tbl, quote = quote:take_until(":")
    quote = quote:expect(":")
    local method, quote = quote:expect_type("name")
    quote = quote:expect("("):expect_last(")")
    if #quote > 0 then
        quote = quote:prepend(",")
    end
    return Quote([[
        %s.%s(%s %s)
    ]], tbl, method, tbl, quote)
end

generate "out/method.lua" [=[
    local person = {
        name = "Ian",
        age = 15,
        birthday = function(self)
            self.age = self.age + 1
        end,
    }
    print(person.age)
    method!(person:birthday())
    print(person.age)
]=]

