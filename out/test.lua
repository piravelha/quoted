local add = (function(x, y)
    return (function()
        print(string.format("add called with arguments '%s' and '%s'", x, y))
        return x + y
    end)()
end)
print(
    add(
        1,
        (function(x)
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
