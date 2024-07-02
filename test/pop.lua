require [[quoted]]

local function test_pop(quote)
    _, quote = quote:expect("@")
    local value, quote = quote:pop()
    return [=[
        $quote.$value
    ]=], {
        quote = quote,
        value = value,
    }
end

run() [=[
    local person = {
        name = "Bob",
        age = 42,
    }
    assert(person.name == test_pop!(@name person))
    assert(test_pop!(@age person) == person.age)
]=]

