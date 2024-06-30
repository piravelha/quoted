function range(start, stop)
    local i = start - 1
    return function()
        i = i + 1
        if i > stop then return end
        return i
    end
end

local co = range(1, 5)
for i in co do
    print(i)
end
