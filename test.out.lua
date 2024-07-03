require("lib.core")

local contents = _G._(function()
	local contents
	local _ = (function(file)
		contents = file:read("*all")
		file:close()
	end)(io.open("test.lua", "r"))
	return contents
end)()
print(contents)
