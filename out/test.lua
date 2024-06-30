local add = (function(x, y)
    return x + y
end)
print(
    add(
        1,
        (function(x, y)
            return x
        end)(2)
    )
)
print(
    add(
        (function(x)
            return x + 1
        end)(4),
        6
    )
)
