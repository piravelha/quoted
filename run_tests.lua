local all_pass = true
local num_tests = 0

local term_width = 50
local progress = 0
local num_tests = 12
local num_dots = 0

local fails = {}

local function test(path)
    local ok, result = pcall(function()
        require("test." .. path)
    end)
    local old_progress = progress
    progress = progress + (term_width / num_tests)
    local num_dots = math.floor((progress - old_progress)+0.5)
    local dots = ("."):rep(num_dots)
    if not ok then
        if result == nil then error("Result is nil") end
        io.write("\27[31m", dots, "\27[0m")
        table.insert(fails, "\n\27[31mTest Failed: \27[0m"
            .. path
            .. " (\27[31mtest/"
            .. path
            .. ".lua: "
            .. result
            .. "\27[0m)")
        all_pass = false
    else
        io.write("\27[32m", dots, "\27[0m")
    end
end

os.execute("cls")
test("simple")
test("append")
test("pop")
test("insert")
test("spread")
test("range")
test("enum")
test("defer")
test("trim")
test("str")
test("concat")
test("fn")

if all_pass then 
    print("\n\27[32mAll Tests Passed!\27[0m ("
        .. tostring(num_tests) .. ")")
end

for _, fail in pairs(fails) do
    print(fail)
end

if #fails > 0 then
    print("\27[31m"
        .. tostring(math.floor((#fails / num_tests) * 100))
        .. "% Tests Failed (" .. tostring(#fails) .. ")\27[0m")
end