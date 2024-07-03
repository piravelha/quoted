local all_pass = true
local num_tests = 0

local function test(path)
    num_tests = num_tests + 1
    local ok, result = pcall(function()
        require("test." .. path)
    end)
    if not ok then
        if result == nil then error("Result is nil") end
        print("\27[31mTest Failed: \27[0m"
            .. path
            .. " (\27[31mtest/"
            .. path
            .. ".lua: "
            .. result
            .. "\27[0m)")
        all_pass = false
    else
        print("\27[32mTest Passed: \27[0m" .. path .. ".lua")
    end
end

os.execute("cls")
test("simple")
test("append")
test("pop")
test("insert")
test("spread")

if all_pass then 
    print("\27[32mAll Tests Passed!\27[0m ("
        .. tostring(num_tests) .. ")")
end
