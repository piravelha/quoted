require("lib.core")

local _ = (function(file)
	local contents = file:read("*all")
	print(contents)
	file:close()
end)(io.open("quoted.lua", "r"))
