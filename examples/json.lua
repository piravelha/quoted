require [[quoted]]

function json(quote)
    if #quote == 1 then
        local x = quote:pop()
        if x.value == "null" then
            return [=[ nil ]=]
        end
        return [=[ $1 ]=], { x }
    end
    if quote:peek_value() == "[" then
        _, quote = quote:pop()
        _, quote = quote:expect_last("]")
        local values = quote:split(","):filter()
        values = values:map(function(value)
            return [=[
                json!{ $1 }
            ]=], { value }
        end)
        return [=[
            { $1 }
        ]=], { values:join(",") }
    end
    if quote:peek_value() == "{" then
        _, quote = quote:pop()
        _, quote = quote:expect_last("}")
    end
    local values = quote:split(","):filter()
    values = values:map(function(field)
        local key, value = field:splits(":")
        return [=[
            [$1] = json!{ $2 }
        ]=], { key, value }
    end)
    return [=[ { $1 } ]=], { values:join(",") }
end

execute() [=[
    local info = json! {
        "name": "Ian",
        "age": 15,
        "programming": true,
    }
    println!("Name: {info.name}")
    println!("Age: {info.age}")
    println!("Programming: {info.programming}")
]=]
